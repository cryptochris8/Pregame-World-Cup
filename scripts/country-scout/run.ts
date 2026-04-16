#!/usr/bin/env npx ts-node
/**
 * Country Scout — Main Coordinator / Runner
 *
 * CLI entry point that orchestrates the full scouting pipeline:
 *   Phase 1 — DISPATCH: Build prompts and dispatch scout agents per team
 *   Phase 2 — MERGE:    Merge scout results into canonical JSON + changelog
 *   Phase 3 — SEED:     Sync changed data to Firestore via seed-all.ts
 *   Phase 4 — NARRATIVE: Regenerate match narratives for affected matches
 *
 * Usage:
 *   npx ts-node run.ts                              # Scout ALL 48 teams
 *   npx ts-node run.ts --teams=ARG,BRA              # Scout specific teams
 *   npx ts-node run.ts --group=A                    # Scout one group
 *   npx ts-node run.ts --dryRun                     # Preview without side effects
 *   npx ts-node run.ts --skipSeed                   # Skip Firestore seeding
 *   npx ts-node run.ts --skipNarratives             # Skip narrative regeneration
 *   npx ts-node run.ts --teams=ARG --dryRun --skipSeed
 *
 * IMPORTANT: Never reference trademarked tournament organizer names in code.
 */

import * as fs from "fs";
import * as path from "path";
import { execSync } from "child_process";

// ---------------------------------------------------------------------------
// Path Constants
// ---------------------------------------------------------------------------

const SCRIPT_DIR = __dirname;
const PROJECT_ROOT = path.resolve(SCRIPT_DIR, "../../");
const DATA_DIR = path.join(PROJECT_ROOT, "assets/data/worldcup");
const FUNCTIONS_DIR = path.join(PROJECT_ROOT, "functions");

const TEAMS_METADATA_PATH = path.join(DATA_DIR, "teams_metadata.json");
const INJURY_TRACKER_PATH = path.join(DATA_DIR, "injury_tracker.json");
const TACTICAL_PROFILES_PATH = path.join(DATA_DIR, "tactical_profiles.json");

// Agent prompt template (read at dispatch time)
const AGENT_TEMPLATE_PATH = path.join(SCRIPT_DIR, "country-scout.md");

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

export interface TeamMeta {
  teamCode: string;
  countryName: string;
  shortName: string;
  nickname: string;
  confederation: string;
  group: string;
  worldRanking: number;
  coachName: string;
  captainName: string;
  starPlayers: string[];
  isHostNation: boolean;
}

export interface CLIFlags {
  teams: string[];
  group: string | null;
  dryRun: boolean;
  skipSeed: boolean;
  skipNarratives: boolean;
}

export interface ScoutResult {
  teamCode: string;
  status: "success" | "skipped" | "error";
  injuriesChanged: boolean;
  formChanged: boolean;
  tacticalChanged: boolean;
  squadChanged: boolean;
  significantChange: boolean; // injury to star player, manager change, 3+ form updates
  message: string;
}

// ---------------------------------------------------------------------------
// Group → Team mapping (World Cup 2026)
// ---------------------------------------------------------------------------

export const GROUP_TEAMS: Record<string, string[]> = {
  A: ["MEX", "KOR", "CZE", "RSA"],
  B: ["BIH", "SUI", "CAN", "QAT"],
  C: ["BRA", "MAR", "SCO", "HAI"],
  D: ["USA", "PAR", "TUR", "AUS"],
  E: ["GER", "ECU", "CIV", "CUR"],
  F: ["NED", "JPN", "SWE", "TUN"],
  G: ["BEL", "EGY", "IRN", "NZL"],
  H: ["ESP", "URU", "KSA", "CPV"],
  I: ["FRA", "NOR", "SEN", "IRQ"],
  J: ["ARG", "ALG", "AUT", "JOR"],
  K: ["POR", "COL", "UZB", "COD"],
  L: ["ENG", "CRO", "PAN", "GHA"],
};

const ALL_TEAM_CODES = Object.values(GROUP_TEAMS).flat();

// ---------------------------------------------------------------------------
// CLI Argument Parsing
// ---------------------------------------------------------------------------

export function parseCLIArgs(argv: string[]): CLIFlags {
  const args = argv.slice(2); // skip node + script path

  let teams: string[] = [];
  let group: string | null = null;
  let dryRun = false;
  let skipSeed = false;
  let skipNarratives = false;

  for (const arg of args) {
    if (arg.startsWith("--teams=")) {
      teams = arg
        .replace("--teams=", "")
        .split(",")
        .map((t) => t.trim().toUpperCase())
        .filter((t) => t.length > 0);
    } else if (arg.startsWith("--group=")) {
      group = arg.replace("--group=", "").trim().toUpperCase();
    } else if (arg === "--dryRun") {
      dryRun = true;
    } else if (arg === "--skipSeed") {
      skipSeed = true;
    } else if (arg === "--skipNarratives") {
      skipNarratives = true;
    }
  }

  return { teams, group, dryRun, skipSeed, skipNarratives };
}

// ---------------------------------------------------------------------------
// Team Selection — resolve CLI flags to a list of team codes
// ---------------------------------------------------------------------------

export function resolveTeams(flags: CLIFlags): string[] {
  // Explicit team list takes precedence
  if (flags.teams.length > 0) {
    const invalid = flags.teams.filter((t) => !ALL_TEAM_CODES.includes(t));
    if (invalid.length > 0) {
      throw new Error(
        `Unknown team code(s): ${invalid.join(", ")}. ` +
          `Valid codes: ${ALL_TEAM_CODES.join(", ")}`
      );
    }
    return flags.teams;
  }

  // Group filter
  if (flags.group) {
    const groupTeams = GROUP_TEAMS[flags.group];
    if (!groupTeams) {
      throw new Error(
        `Unknown group: ${flags.group}. Valid groups: ${Object.keys(GROUP_TEAMS).join(", ")}`
      );
    }
    return groupTeams;
  }

  // Default: all 48 teams
  return [...ALL_TEAM_CODES];
}

// ---------------------------------------------------------------------------
// Data Loading helpers
// ---------------------------------------------------------------------------

function loadJson(filePath: string): any {
  try {
    return JSON.parse(fs.readFileSync(filePath, "utf-8"));
  } catch {
    return null;
  }
}

export function loadTeamMetadata(): Record<string, TeamMeta> {
  const raw = loadJson(TEAMS_METADATA_PATH);
  if (!raw) throw new Error(`Cannot load teams metadata from ${TEAMS_METADATA_PATH}`);
  return raw as Record<string, TeamMeta>;
}

export function loadTeamInjuries(teamCode: string): any[] {
  const data = loadJson(INJURY_TRACKER_PATH);
  if (!data?.players) return [];
  return data.players.filter((p: any) => p.teamCode === teamCode);
}

export function loadTeamTactical(teamCode: string): any | null {
  const data = loadJson(TACTICAL_PROFILES_PATH);
  if (!data?.profiles) return null;
  return data.profiles[teamCode] || null;
}

export function loadTeamForm(teamCode: string): any | null {
  // Recent form data may live in a per-team file or a combined file
  const perTeamPath = path.join(DATA_DIR, "recent_form", `${teamCode}.json`);
  const combined = loadJson(path.join(DATA_DIR, "recent_form.json"));
  if (fs.existsSync(perTeamPath)) {
    return loadJson(perTeamPath);
  }
  if (combined && combined[teamCode]) {
    return combined[teamCode];
  }
  return null;
}

// ---------------------------------------------------------------------------
// Phase 1 — DISPATCH
// ---------------------------------------------------------------------------

function loadAgentTemplate(): string {
  try {
    return fs.readFileSync(AGENT_TEMPLATE_PATH, "utf-8");
  } catch {
    return "[Agent template not found — will use default scouting prompt]";
  }
}

function buildScoutPrompt(
  teamCode: string,
  meta: TeamMeta,
  injuries: any[],
  tactical: any | null,
  form: any | null,
  template: string
): string {
  const context = [
    `Team: ${meta.countryName} (${teamCode})`,
    `Group: ${meta.group}`,
    `World Ranking: ${meta.worldRanking}`,
    `Coach: ${meta.coachName}`,
    `Captain: ${meta.captainName}`,
    `Star Players: ${meta.starPlayers.join(", ")}`,
    `Confederation: ${meta.confederation}`,
    `Host Nation: ${meta.isHostNation ? "Yes" : "No"}`,
    "",
    `Current Injuries (${injuries.length} tracked):`,
    ...injuries.map(
      (i) => `  - ${i.playerName}: ${i.injuryType} [${i.availabilityStatus}]`
    ),
    "",
    `Tactical Profile: ${tactical ? tactical.preferredFormation + " — " + (tactical.playingStyle || "N/A") : "Not available"}`,
    "",
    `Recent Form: ${form ? JSON.stringify(form).slice(0, 500) : "Not available"}`,
  ].join("\n");

  // Inject team context into the agent template
  return template
    .replace("{{TEAM_CODE}}", teamCode)
    .replace("{{TEAM_NAME}}", meta.countryName)
    .replace("{{TEAM_CONTEXT}}", context);
}

/**
 * Placeholder for dispatching a scout agent.
 *
 * In production, this will call Claude Code's Agent tool to run the
 * country-scout agent with the built prompt. For now it logs what
 * would be dispatched and returns a mock result.
 */
export async function dispatchScout(
  teamCode: string,
  prompt: string,
  dryRun: boolean
): Promise<ScoutResult> {
  console.log(`  [DISPATCH] ${teamCode} — prompt length: ${prompt.length} chars`);

  if (dryRun) {
    console.log(`  [DRY RUN]  Would dispatch scout for ${teamCode}`);
    return {
      teamCode,
      status: "skipped",
      injuriesChanged: false,
      formChanged: false,
      tacticalChanged: false,
      squadChanged: false,
      significantChange: false,
      message: "Dry run — no dispatch",
    };
  }

  // TODO: Replace with actual Agent tool dispatch:
  //   const result = await agentTool.dispatch({
  //     prompt,
  //     subagent_type: "general-purpose",
  //     tools: ["Read", "Write", "Edit", "Bash", "Glob", "Grep"],
  //   });
  //   return parseScoutResult(result);

  console.log(`  [PLACEHOLDER] Scout dispatch for ${teamCode} — agent not yet wired`);
  return {
    teamCode,
    status: "success",
    injuriesChanged: false,
    formChanged: false,
    tacticalChanged: false,
    squadChanged: false,
    significantChange: false,
    message: "Placeholder — agent not yet wired",
  };
}

async function phaseDispatch(
  teamCodes: string[],
  flags: CLIFlags
): Promise<ScoutResult[]> {
  console.log("\n╔══════════════════════════════════════════╗");
  console.log("║  PHASE 1 — DISPATCH SCOUTS               ║");
  console.log("╚══════════════════════════════════════════╝\n");

  const metadata = loadTeamMetadata();
  const template = loadAgentTemplate();
  const results: ScoutResult[] = [];

  for (const code of teamCodes) {
    const meta = metadata[code];
    if (!meta) {
      console.log(`  [SKIP] ${code} — not found in teams metadata`);
      results.push({
        teamCode: code,
        status: "error",
        injuriesChanged: false,
        formChanged: false,
        tacticalChanged: false,
        squadChanged: false,
        significantChange: false,
        message: `Team ${code} not found in metadata`,
      });
      continue;
    }

    const injuries = loadTeamInjuries(code);
    const tactical = loadTeamTactical(code);
    const form = loadTeamForm(code);

    const prompt = buildScoutPrompt(code, meta, injuries, tactical, form, template);
    const result = await dispatchScout(code, prompt, flags.dryRun);
    results.push(result);
  }

  const succeeded = results.filter((r) => r.status === "success").length;
  const skipped = results.filter((r) => r.status === "skipped").length;
  const errored = results.filter((r) => r.status === "error").length;
  console.log(
    `\n  Phase 1 complete: ${succeeded} dispatched, ${skipped} skipped, ${errored} errors`
  );

  return results;
}

// ---------------------------------------------------------------------------
// Phase 2 — MERGE
// ---------------------------------------------------------------------------

async function phaseMerge(
  results: ScoutResult[],
  flags: CLIFlags
): Promise<ScoutResult[]> {
  console.log("\n╔══════════════════════════════════════════╗");
  console.log("║  PHASE 2 — MERGE RESULTS                 ║");
  console.log("╚══════════════════════════════════════════╝\n");

  const changedTeams = results.filter(
    (r) =>
      r.status === "success" &&
      (r.injuriesChanged || r.formChanged || r.tacticalChanged)
  );

  if (changedTeams.length === 0) {
    console.log("  No data changes detected — skipping merge.");
    return results;
  }

  console.log(
    `  ${changedTeams.length} team(s) have data changes — merging...`
  );

  // Import merge functions dynamically (they may not exist yet).
  // Using require() to avoid TS type-checking on modules that don't exist yet.
  try {
    // eslint-disable-next-line @typescript-eslint/no-var-requires
    const mergeMod: any = require("./merge-injuries");
    if (mergeMod.mergeInjuries) {
      const injuryTeams = changedTeams
        .filter((r) => r.injuriesChanged)
        .map((r) => r.teamCode);
      if (injuryTeams.length > 0) {
        console.log(`  Merging injuries for: ${injuryTeams.join(", ")}`);
        if (!flags.dryRun) mergeMod.mergeInjuries(injuryTeams);
      }
    }
  } catch {
    console.log("  [WARN] merge-injuries module not available yet");
  }

  try {
    // eslint-disable-next-line @typescript-eslint/no-var-requires
    const mergeMod: any = require("./merge-recent-form");
    if (mergeMod.mergeRecentForm) {
      const formTeams = changedTeams
        .filter((r) => r.formChanged)
        .map((r) => r.teamCode);
      if (formTeams.length > 0) {
        console.log(`  Merging recent form for: ${formTeams.join(", ")}`);
        if (!flags.dryRun) mergeMod.mergeRecentForm(formTeams);
      }
    }
  } catch {
    console.log("  [WARN] merge-recent-form module not available yet");
  }

  try {
    // eslint-disable-next-line @typescript-eslint/no-var-requires
    const mergeMod: any = require("./merge-tactical");
    if (mergeMod.mergeTactical) {
      const tacTeams = changedTeams
        .filter((r) => r.tacticalChanged)
        .map((r) => r.teamCode);
      if (tacTeams.length > 0) {
        console.log(`  Merging tactical data for: ${tacTeams.join(", ")}`);
        if (!flags.dryRun) mergeMod.mergeTactical(tacTeams);
      }
    }
  } catch {
    console.log("  [WARN] merge-tactical module not available yet");
  }

  // Generate changelog
  try {
    // eslint-disable-next-line @typescript-eslint/no-var-requires
    const changelogMod: any = require("./changelog");
    if (changelogMod.generateChangelog) {
      console.log("\n  Generating changelog...");
      const log = changelogMod.generateChangelog(results);
      console.log("\n--- CHANGELOG ---");
      console.log(log);
      console.log("--- END CHANGELOG ---\n");
    }
  } catch {
    console.log("  [WARN] changelog module not available yet");
    // Fallback: print a simple summary
    console.log("\n--- CHANGE SUMMARY ---");
    for (const r of changedTeams) {
      const changes: string[] = [];
      if (r.injuriesChanged) changes.push("injuries");
      if (r.formChanged) changes.push("form");
      if (r.tacticalChanged) changes.push("tactical");
      if (r.squadChanged) changes.push("squad");
      console.log(`  ${r.teamCode}: ${changes.join(", ")}`);
    }
    console.log("--- END SUMMARY ---\n");
  }

  return results;
}

// ---------------------------------------------------------------------------
// Phase 3 — SEED
// ---------------------------------------------------------------------------

function determineSeedTargets(results: ScoutResult[]): string[] {
  const targets = new Set<string>();

  for (const r of results) {
    if (r.status !== "success") continue;
    if (r.injuriesChanged || r.formChanged || r.tacticalChanged) {
      targets.add("summaries");
    }
    if (r.squadChanged) {
      targets.add("players");
    }
  }

  return Array.from(targets);
}

function phaseSeed(results: ScoutResult[], flags: CLIFlags): void {
  console.log("\n╔══════════════════════════════════════════╗");
  console.log("║  PHASE 3 — SEED FIRESTORE                ║");
  console.log("╚══════════════════════════════════════════╝\n");

  if (flags.skipSeed) {
    console.log("  --skipSeed flag set — skipping Firestore seeding.");
    return;
  }

  const targets = determineSeedTargets(results);
  if (targets.length === 0) {
    console.log("  No data changes require seeding — skipping.");
    return;
  }

  const targetStr = targets.join(",");
  const cmd = `npx ts-node src/seed-all.ts --only=${targetStr}${flags.dryRun ? " --dryRun" : ""}`;

  console.log(`  Seed targets: ${targetStr}`);
  console.log(`  Running: ${cmd}`);
  console.log(`  Working directory: ${FUNCTIONS_DIR}\n`);

  if (flags.dryRun) {
    console.log("  [DRY RUN] Would execute seed command above.");
    return;
  }

  try {
    execSync(cmd, {
      cwd: FUNCTIONS_DIR,
      stdio: "inherit",
      timeout: 120_000,
    });
    console.log("\n  Seeding complete.");
  } catch (err: any) {
    console.error(`\n  [ERROR] Seed failed: ${err.message}`);
  }
}

// ---------------------------------------------------------------------------
// Phase 4 — NARRATIVE REGENERATION
// ---------------------------------------------------------------------------

function findAffectedMatches(
  results: ScoutResult[],
  metadata: Record<string, TeamMeta>
): string[] {
  const significantTeams = results
    .filter((r) => r.significantChange)
    .map((r) => r.teamCode);

  if (significantTeams.length === 0) return [];

  // Build match keys for affected teams.
  // Match keys follow the pattern: TEAM1_TEAM2 (alphabetical order).
  // We find all group opponents for each significant team.
  const matchKeys = new Set<string>();

  for (const code of significantTeams) {
    const meta = metadata[code];
    if (!meta) continue;

    const groupTeams = GROUP_TEAMS[meta.group];
    if (!groupTeams) continue;

    for (const opponent of groupTeams) {
      if (opponent === code) continue;
      // Alphabetical ordering for consistent match keys
      const pair = [code, opponent].sort();
      matchKeys.add(`${pair[0]}_${pair[1]}`);
    }
  }

  return Array.from(matchKeys);
}

function phaseNarratives(results: ScoutResult[], flags: CLIFlags): void {
  console.log("\n╔══════════════════════════════════════════╗");
  console.log("║  PHASE 4 — NARRATIVE REGENERATION        ║");
  console.log("╚══════════════════════════════════════════╝\n");

  if (flags.skipNarratives) {
    console.log("  --skipNarratives flag set — skipping narrative regeneration.");
    return;
  }

  const metadata = loadTeamMetadata();
  const matchKeys = findAffectedMatches(results, metadata);

  if (matchKeys.length === 0) {
    console.log("  No significant changes require narrative regeneration.");
    return;
  }

  const matchArg = matchKeys.join(",");
  const cmd = `npx ts-node src/generate-match-narratives.ts --force --match=${matchArg}`;

  console.log(`  Affected matches (${matchKeys.length}): ${matchKeys.join(", ")}`);
  console.log(`  Running: ${cmd}`);
  console.log(`  Working directory: ${FUNCTIONS_DIR}\n`);

  if (flags.dryRun) {
    console.log("  [DRY RUN] Would execute narrative generation above.");
    return;
  }

  try {
    execSync(cmd, {
      cwd: FUNCTIONS_DIR,
      stdio: "inherit",
      timeout: 300_000, // narratives may take a while
    });
    console.log("\n  Narrative regeneration complete.");
  } catch (err: any) {
    console.error(`\n  [ERROR] Narrative generation failed: ${err.message}`);
  }
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

async function main(): Promise<void> {
  console.log("╔══════════════════════════════════════════╗");
  console.log("║  COUNTRY SCOUT — Pipeline Runner         ║");
  console.log("╚══════════════════════════════════════════╝");

  const flags = parseCLIArgs(process.argv);
  let teamCodes: string[];

  try {
    teamCodes = resolveTeams(flags);
  } catch (err: any) {
    console.error(`\n  [ERROR] ${err.message}`);
    process.exit(1);
  }

  console.log(`\n  Teams to scout (${teamCodes.length}): ${teamCodes.join(", ")}`);
  console.log(
    `  Flags: dryRun=${flags.dryRun}, skipSeed=${flags.skipSeed}, skipNarratives=${flags.skipNarratives}`
  );

  // Phase 1 — Dispatch scouts
  const results = await phaseDispatch(teamCodes, flags);

  // Phase 2 — Merge results
  await phaseMerge(results, flags);

  // Phase 3 — Seed Firestore
  phaseSeed(results, flags);

  // Phase 4 — Regenerate narratives
  phaseNarratives(results, flags);

  // Final summary
  console.log("\n╔══════════════════════════════════════════╗");
  console.log("║  PIPELINE COMPLETE                        ║");
  console.log("╚══════════════════════════════════════════╝");

  const changed = results.filter(
    (r) =>
      r.injuriesChanged || r.formChanged || r.tacticalChanged || r.squadChanged
  );
  console.log(`\n  Total teams scouted: ${results.length}`);
  console.log(`  Teams with changes:  ${changed.length}`);
  console.log(
    `  Significant changes: ${results.filter((r) => r.significantChange).length}`
  );
  console.log("");
}

// Run if executed directly
main().catch((err) => {
  console.error("Fatal error:", err);
  process.exit(1);
});

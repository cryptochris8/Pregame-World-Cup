/**
 * Apply all per-team ScoutOutput JSON files at scout-results/ to the bundled
 * data layers (injury_tracker, tactical_profiles, recent_form) via the
 * existing merge utilities. Creates one timestamped backup per data file.
 *
 * Usage: npx ts-node apply-scout-deltas.ts [--dryRun]
 */

import * as fs from "fs";
import * as path from "path";
import { mergeInjuries } from "./merge-injuries";
import { mergeTacticalBatch } from "./merge-tactical";
import { mergeRecentFormBatch } from "./merge-recent-form";
import type { ScoutOutput } from "./types";

const RESULTS_DIR = path.join(__dirname, "scout-results");

function loadAllScoutOutputs(): ScoutOutput[] {
  const files = fs
    .readdirSync(RESULTS_DIR)
    .filter((f) => f.endsWith(".json"))
    .sort();
  const outputs: ScoutOutput[] = [];
  for (const f of files) {
    try {
      const raw = fs.readFileSync(path.join(RESULTS_DIR, f), "utf-8");
      outputs.push(JSON.parse(raw) as ScoutOutput);
    } catch (e) {
      console.error(`  [SKIP] ${f}: failed to parse — ${(e as Error).message}`);
    }
  }
  return outputs;
}

function main(): void {
  const dryRun = process.argv.includes("--dryRun");
  const scouts = loadAllScoutOutputs();

  console.log("==========================================");
  console.log(` Applying scout deltas (${scouts.length} teams)`);
  console.log(` Mode: ${dryRun ? "DRY RUN" : "LIVE"}`);
  console.log("==========================================");

  // ---- Injuries: concat across all teams, single merge call ----
  const allInjuries = scouts.flatMap((s) => s.injuryUpdates || []);
  console.log(`\n[INJURIES] ${allInjuries.length} updates across ${scouts.length} teams`);
  const inputBreakdown = allInjuries.reduce<Record<string, number>>((acc, u) => {
    acc[u.action] = (acc[u.action] || 0) + 1;
    return acc;
  }, {});
  console.log(`  input breakdown:`, inputBreakdown);
  if (!dryRun) {
    const result = mergeInjuries(allInjuries);
    console.log(`  changesApplied: ${result.changesApplied}`);
  } else {
    console.log(`  (dry run — not applying)`);
  }

  // ---- Tactical + Coach: batch merge ----
  const tacticalInputs = scouts.map((s) => ({
    teamCode: s.teamCode,
    tacticalUpdates: s.tacticalUpdates || [],
    coachUpdate: s.coachUpdate,
  }));
  const totalTactical = tacticalInputs.reduce(
    (n, t) => n + t.tacticalUpdates.length,
    0
  );
  const totalCoach = tacticalInputs.filter((t) => t.coachUpdate?.changed).length;
  console.log(`\n[TACTICAL] ${totalTactical} tactical field updates + ${totalCoach} coach changes`);
  if (!dryRun) {
    const result = mergeTacticalBatch(tacticalInputs);
    console.log(`  changesApplied: ${result.changesApplied}`);
  } else {
    console.log(`  would apply (dry run)`);
  }

  // ---- Recent form: skip if zero (window was quiet) ----
  const formInputs = scouts
    .filter((s) => (s.recentFormUpdates || []).length > 0)
    .map((s) => ({
      teamCode: s.teamCode,
      recentFormUpdates: s.recentFormUpdates,
    }));
  console.log(`\n[RECENT FORM] ${formInputs.length} teams with new matches`);
  if (formInputs.length > 0 && !dryRun) {
    const result = mergeRecentFormBatch(formInputs);
    console.log(`  changesApplied: ${result.changesApplied}`);
  } else if (formInputs.length === 0) {
    console.log(`  (no new matches in window — skipping)`);
  }

  console.log("\n==========================================");
  console.log(" Done");
  console.log("==========================================");
  if (dryRun) console.log("DRY RUN — no files modified.");
}

main();

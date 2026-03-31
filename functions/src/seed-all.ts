/**
 * Seed All — Run all seed scripts in sequence to sync local JSON → Firestore.
 *
 * This is the single command to run after updating any local JSON data files.
 * It clears and re-seeds every collection to ensure Firestore matches local JSON.
 *
 * Usage:
 *   npx ts-node src/seed-all.ts                # LIVE — seeds everything
 *   npx ts-node src/seed-all.ts --dryRun       # Preview without writing
 *   npx ts-node src/seed-all.ts --only=h2h,summaries  # Run specific seeds only
 *
 * Requires GOOGLE_APPLICATION_CREDENTIALS environment variable pointing to
 * a Firebase service account key JSON file.
 *
 * Available seed targets:
 *   matches      — Group stage match schedule (worldcup_matches)
 *   knockouts    — Knockout stage matches (worldcup_matches)
 *   summaries    — AI match previews (matchSummaries)
 *   h2h          — Head-to-head records (headToHead)
 *   managers     — Manager profiles (managers)
 *   players      — Team rosters (players, worldcup_players)
 *   history      — World Cup history (worldCupHistory)
 *   venues       — Venue enhancements (worldcup_venues)
 *   playerstats  — Player World Cup stats (playerWorldCupStats)
 */

import { execSync } from "child_process";
import * as path from "path";

// NOTE: Knockouts must run BEFORE group stage because both write to
// 'worldcup_matches'. Knockouts uses --clear which wipes the collection,
// then group stage adds its docs on top without clearing.
const SEEDS: { name: string; key: string; script: string; noFlags?: boolean }[] = [
  { name: "Knockout Matches", key: "knockouts", script: "seed-knockout-matches.ts" },
  { name: "Group Stage Matches", key: "matches", script: "seed-june2026-matches.ts", noFlags: true },
  { name: "Match Summaries", key: "summaries", script: "seed-match-summaries.ts" },
  { name: "Head-to-Head Records", key: "h2h", script: "seed-head-to-head.ts" },
  { name: "Managers", key: "managers", script: "seed-managers.ts" },
  { name: "Team Players", key: "players", script: "seed-team-players.ts" },
  { name: "World Cup History", key: "history", script: "seed-world-cup-history.ts" },
  { name: "Venue Enhancements", key: "venues", script: "seed-venue-enhancements.ts" },
  { name: "Player World Cup Stats", key: "playerstats", script: "seed-player-world-cup-stats.ts" },
];

function main() {
  const args = process.argv.slice(2);
  const dryRun = args.includes("--dryRun");
  const onlyArg = args.find((a) => a.startsWith("--only="));
  const onlyKeys = onlyArg ? onlyArg.replace("--only=", "").split(",") : null;

  const seedsToRun = onlyKeys
    ? SEEDS.filter((s) => onlyKeys.includes(s.key))
    : SEEDS;

  if (seedsToRun.length === 0) {
    console.error(`No matching seeds found. Available keys: ${SEEDS.map((s) => s.key).join(", ")}`);
    process.exit(1);
  }

  console.log("╔══════════════════════════════════════════╗");
  console.log("║         SEED ALL — JSON → Firestore      ║");
  console.log("╚══════════════════════════════════════════╝");
  console.log(`Mode: ${dryRun ? "DRY RUN" : "LIVE"}`);
  console.log(`Seeds: ${seedsToRun.map((s) => s.key).join(", ")}`);
  console.log("");

  const results: { name: string; status: string; duration: number }[] = [];

  for (const seed of seedsToRun) {
    const scriptPath = path.join(__dirname, seed.script);
    const flags: string[] = [];
    if (!seed.noFlags) flags.push("--clear");
    if (dryRun) flags.push("--dryRun");

    console.log(`── ${seed.name} ──────────────────────────`);
    const start = Date.now();

    try {
      execSync(`npx ts-node "${scriptPath}" ${flags.join(" ")}`, {
        stdio: "inherit",
        cwd: path.join(__dirname, ".."),
        env: process.env,
      });
      const duration = Date.now() - start;
      results.push({ name: seed.name, status: "OK", duration });
    } catch (err) {
      const duration = Date.now() - start;
      results.push({ name: seed.name, status: "FAILED", duration });
      console.error(`  ✗ ${seed.name} failed\n`);
    }
    console.log("");
  }

  // Summary
  console.log("╔══════════════════════════════════════════╗");
  console.log("║               SUMMARY                    ║");
  console.log("╚══════════════════════════════════════════╝");
  for (const r of results) {
    const icon = r.status === "OK" ? "+" : "✗";
    console.log(`  ${icon} ${r.name.padEnd(28)} ${r.status.padEnd(8)} (${(r.duration / 1000).toFixed(1)}s)`);
  }

  const failed = results.filter((r) => r.status === "FAILED");
  if (failed.length > 0) {
    console.log(`\n${failed.length} seed(s) failed. Check logs above.`);
    process.exit(1);
  } else {
    console.log(`\nAll ${results.length} seeds completed successfully.`);
  }
}

main();

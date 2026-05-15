/**
 * Seed AI Match Narratives for World Cup 2026
 *
 * Reads all JSON files from assets/data/worldcup/match_narratives/ and
 * uploads them to the Firestore 'match_narratives' collection.
 *
 * Document IDs are derived from the JSON filename (e.g. ARG_BRA.json -> ARG_BRA).
 *
 * The Flutter app's MatchNarrativeService reads from this collection first and
 * falls back to bundled JSON when a doc is missing or Firestore is unreachable.
 * Run this script after every regenerate-match-narratives.ts run to ship fresh
 * content to live users without an App Store release.
 *
 * Flags:
 *   --dryRun   Preview changes without writing to Firestore
 *   --clear    Clear existing collection before seeding
 *   --team=XXX Filter to narratives involving a specific team code
 *   --verbose  Enable verbose logging
 *
 * Usage:
 *   npx ts-node src/seed-match-narratives.ts [--dryRun] [--clear] [--team=BRA]
 */

import * as fs from "fs";
import * as path from "path";
import { initFirebase, parseArgs, batchWrite, clearCollection } from "./seed-utils";

const JSON_DIR = path.resolve(__dirname, "../../assets/data/worldcup/match_narratives");

async function main(): Promise<void> {
  const { dryRun, clear, team, verbose } = parseArgs();
  const db = initFirebase();

  console.log("========================================");
  console.log("Seeding AI Match Narratives");
  console.log("========================================");
  console.log(`Mode: ${dryRun ? "DRY RUN" : "LIVE"}`);
  if (team) console.log(`Filter: team=${team}`);
  console.log(`Source: ${JSON_DIR}`);
  console.log("");

  if (clear) {
    await clearCollection(db, "match_narratives", dryRun);
  }

  const files = fs.readdirSync(JSON_DIR).filter(f => f.endsWith(".json"));

  const docs: { id: string; data: Record<string, any> }[] = [];

  for (const file of files) {
    const id = path.basename(file, ".json"); // e.g. "ARG_BRA"
    const data = JSON.parse(fs.readFileSync(path.join(JSON_DIR, file), "utf-8"));

    if (team && data.team1Code !== team && data.team2Code !== team) {
      continue;
    }

    if (verbose) {
      console.log(`  ${id}: ${data.team1Name} vs ${data.team2Name}`);
    }

    docs.push({ id, data });
  }

  console.log(`Narratives found: ${docs.length}`);
  console.log("");

  const written = await batchWrite(db, "match_narratives", docs, dryRun);

  console.log("");
  console.log("========================================");
  console.log("Summary");
  console.log("========================================");
  console.log(`Total: ${written}/${docs.length}`);

  if (dryRun) {
    console.log("");
    console.log("This was a DRY RUN. No data was uploaded.");
    console.log("Run without --dryRun to upload to Firestore.");
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Fatal error:", error);
    process.exit(1);
  });

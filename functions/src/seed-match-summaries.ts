/**
 * Seed AI Match Summaries for World Cup 2026
 *
 * Reads all JSON files from assets/data/worldcup/match_summaries/ and
 * uploads them to the Firestore 'matchSummaries' collection.
 *
 * Document IDs are derived from the JSON filename (e.g. CRO_ENG.json -> CRO_ENG).
 *
 * Flags:
 *   --dryRun   Preview changes without writing to Firestore
 *   --clear    Clear existing collection before seeding
 *   --team=XXX Filter to summaries involving a specific team code
 *   --verbose  Enable verbose logging
 *
 * Usage:
 *   npx ts-node src/seed-match-summaries.ts [--dryRun] [--clear] [--team=BRA]
 */

import * as fs from "fs";
import * as path from "path";
import { initFirebase, parseArgs, batchWrite, clearCollection } from "./seed-utils";

const JSON_DIR = path.resolve(__dirname, "../../assets/data/worldcup/match_summaries");

async function main(): Promise<void> {
  const { dryRun, clear, team, verbose } = parseArgs();
  const db = initFirebase();

  console.log("========================================");
  console.log("Seeding AI Match Summaries");
  console.log("========================================");
  console.log(`Mode: ${dryRun ? "DRY RUN" : "LIVE"}`);
  if (team) console.log(`Filter: team=${team}`);
  console.log(`Source: ${JSON_DIR}`);
  console.log("");

  if (clear) {
    await clearCollection(db, "matchSummaries", dryRun);
  }

  // Read all JSON files from the match_summaries directory
  const files = fs.readdirSync(JSON_DIR).filter(f => f.endsWith(".json"));

  // Build document array: id from filename, data from JSON contents
  const docs: { id: string; data: Record<string, any> }[] = [];

  for (const file of files) {
    const id = path.basename(file, ".json"); // e.g. "CRO_ENG"
    const data = JSON.parse(fs.readFileSync(path.join(JSON_DIR, file), "utf-8"));

    // Optional team filter
    if (team && data.team1Code !== team && data.team2Code !== team) {
      continue;
    }

    if (verbose) {
      console.log(`  ${id}: ${data.team1Name} vs ${data.team2Name}`);
    }

    docs.push({ id, data });
  }

  console.log(`Summaries found: ${docs.length}`);
  console.log("");

  const written = await batchWrite(db, "matchSummaries", docs, dryRun);

  console.log("");
  console.log("========================================");
  console.log("Summary");
  console.log("========================================");
  console.log(`Total: ${written}/${docs.length}`);
  console.log(`First-time meetings: ${docs.filter(d => d.data.isFirstMeeting).length}`);

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

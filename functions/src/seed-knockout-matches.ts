/**
 * Seed World Cup 2026 Knockout Stage Matches (Round of 32 through Final)
 *
 * Reads match data from assets/data/worldcup/matches/knockout.json
 *
 * Usage:
 *   npx ts-node src/seed-knockout-matches.ts [--dryRun] [--clear]
 */

import { initFirebase, parseArgs, readJsonFile, batchWrite, clearCollection } from "./seed-utils";

const COLLECTION = "worldcup_matches";
const JSON_PATH = "../../assets/data/worldcup/matches/knockout.json";

async function seedKnockoutMatches() {
  const { dryRun, clear } = parseArgs();
  const db = initFirebase();
  const matches: any[] = readJsonFile(JSON_PATH);

  console.log("========================================");
  console.log("Seeding World Cup 2026 Knockout Matches");
  console.log(`Mode: ${dryRun ? "DRY RUN" : "LIVE"}`);
  console.log(`Matches to seed: ${matches.length}`);
  console.log("========================================\n");

  if (clear) {
    await clearCollection(db, COLLECTION, dryRun);
  }

  const docs = matches.map((m) => ({
    id: m.matchId,
    data: m,
  }));

  const count = await batchWrite(db, COLLECTION, docs, dryRun);

  console.log(`\nDone: ${count} knockout matches ${dryRun ? "would be" : ""} seeded.`);
}

seedKnockoutMatches()
  .then(() => process.exit(0))
  .catch((e) => {
    console.error("Error:", e);
    process.exit(1);
  });

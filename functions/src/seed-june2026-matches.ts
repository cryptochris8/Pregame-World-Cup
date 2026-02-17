/**
 * Seed June 2026 World Cup Group Stage Matches
 *
 * Reads match data from assets/data/worldcup/matches/group_stage.json
 *
 * Usage:
 *   npx ts-node src/seed-june2026-matches.ts [--dryRun] [--clear]
 */

import { initFirebase, parseArgs, readJsonFile, batchWrite, clearCollection } from "./seed-utils";

const COLLECTION = "worldcup_matches";
const JSON_PATH = "../../assets/data/worldcup/matches/group_stage.json";

async function seedGroupStageMatches() {
  const { dryRun, clear } = parseArgs();
  const db = initFirebase();
  const matches: any[] = readJsonFile(JSON_PATH);

  console.log("========================================");
  console.log("Seeding June 2026 World Cup Group Stage Matches");
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

  console.log(`\nDone: ${count} group stage matches ${dryRun ? "would be" : ""} seeded.`);
}

seedGroupStageMatches()
  .then(() => process.exit(0))
  .catch((e) => {
    console.error("Error:", e);
    process.exit(1);
  });

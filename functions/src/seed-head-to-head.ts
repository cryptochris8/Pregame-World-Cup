/**
 * Seed Head-to-Head Records Script
 *
 * Reads all H2H JSON files (historical + June 2026 matchups) and seeds
 * them into the 'headToHead' Firestore collection.
 *
 * Usage:
 *   npx ts-node src/seed-head-to-head.ts [--dryRun] [--clear]
 */

import { initFirebase, parseArgs, readJsonDir, batchWrite, clearCollection } from "./seed-utils";

const DATA_DIR = "../../assets/data/worldcup/head_to_head";

async function main() {
  const { dryRun, clear } = parseArgs();
  const db = initFirebase();

  console.log("=== Seed Head-to-Head Records ===");
  console.log(`Mode: ${dryRun ? "DRY RUN" : "LIVE"}`);

  if (clear) {
    await clearCollection(db, "headToHead", dryRun);
  }

  const records: any[] = readJsonDir(DATA_DIR);
  console.log(`Found ${records.length} H2H JSON files`);

  const docs = records.map((r) => {
    const codes = [r.team1Code, r.team2Code].sort();
    const id = `${codes[0]}_${codes[1]}`;
    return { id, data: { id, ...r } };
  });

  await batchWrite(db, "headToHead", docs, dryRun);
  console.log("Done.");
}

main()
  .then(() => process.exit(0))
  .catch((err) => { console.error(err); process.exit(1); });

/**
 * Seed World Cup History Script
 *
 * Reads tournaments.json and records.json and seeds them into the
 * 'worldCupHistory' and 'worldCupRecords' Firestore collections.
 *
 * Usage:
 *   npx ts-node src/seed-world-cup-history.ts [--dryRun] [--clear]
 */

import { initFirebase, parseArgs, readJsonFile, batchWrite, clearCollection } from "./seed-utils";

const TOURNAMENTS_FILE = "../../assets/data/worldcup/history/tournaments.json";
const RECORDS_FILE = "../../assets/data/worldcup/history/records.json";

async function main() {
  const { dryRun, clear } = parseArgs();
  const db = initFirebase();

  console.log("=== Seed World Cup History ===");
  console.log(`Mode: ${dryRun ? "DRY RUN" : "LIVE"}`);

  if (clear) {
    await clearCollection(db, "worldCupHistory", dryRun);
    await clearCollection(db, "worldCupRecords", dryRun);
  }

  // Seed tournaments
  const tournaments: any[] = readJsonFile(TOURNAMENTS_FILE);
  console.log(`Found ${tournaments.length} tournaments`);

  const tournamentDocs = tournaments.map((t) => {
    const id = `wc_${t.year}`;
    return { id, data: { id, ...t } };
  });

  await batchWrite(db, "worldCupHistory", tournamentDocs, dryRun);

  // Seed all-time records
  const records: any[] = readJsonFile(RECORDS_FILE);
  console.log(`Found ${records.length} all-time records`);

  const recordDocs = records.map((r) => {
    const id = r.category.toLowerCase().replace(/[^a-z0-9]/g, "_");
    return { id, data: { id, ...r } };
  });

  await batchWrite(db, "worldCupRecords", recordDocs, dryRun);
  console.log("Done.");
}

main()
  .then(() => process.exit(0))
  .catch((err) => { console.error(err); process.exit(1); });

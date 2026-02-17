/**
 * Seed Managers Script
 *
 * Reads manager JSON files from assets/data/worldcup/managers/ and uploads
 * them to the Firestore 'managers' collection.
 *
 * Usage:
 *   npx ts-node src/seed-managers.ts [--team=USA] [--dryRun] [--clear] [--verbose]
 */

import { initFirebase, parseArgs, readJsonDir, batchWrite, clearCollection } from "./seed-utils";

const COLLECTION = "managers";
const JSON_DIR = "../../assets/data/worldcup/managers";

async function main() {
  const { dryRun, team, clear, verbose } = parseArgs();
  const db = initFirebase();

  console.log(`Seed Managers | ${dryRun ? "DRY RUN" : "LIVE"}${team ? ` | team=${team}` : ""}`);

  if (clear) await clearCollection(db, COLLECTION, dryRun);

  let records: any[] = readJsonDir(JSON_DIR);

  if (team) {
    records = records.filter((r: any) => r.currentTeamCode === team);
  }

  if (records.length === 0) {
    console.log("No managers found.");
    return;
  }

  if (verbose) records.forEach((r: any) => console.log(`  ${r.currentTeamCode} - ${r.firstName} ${r.lastName}`));

  const docs = records.map((r: any) => ({ id: r.id, data: r }));
  await batchWrite(db, COLLECTION, docs, dryRun);
}

main()
  .then(() => { console.log("Done."); process.exit(0); })
  .catch((e) => { console.error("Failed:", e); process.exit(1); });

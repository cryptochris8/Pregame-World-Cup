/**
 * Seed Venue Enhancements Script
 *
 * Reads venue enhancement data from assets/data/worldcup/venues/enhancements.json
 * and uploads it to the Firestore 'venue_enhancements' collection.
 *
 * Usage:
 *   npx ts-node src/seed-venue-enhancements.ts [--dryRun] [--clear] [--verbose]
 */

import * as admin from "firebase-admin";
import { initFirebase, parseArgs, readJsonFile, batchWrite, clearCollection } from "./seed-utils";

const COLLECTION = "venue_enhancements";
const JSON_FILE = "../../assets/data/worldcup/venues/enhancements.json";

async function main() {
  const { dryRun, clear, verbose } = parseArgs();
  const db = initFirebase();

  console.log(`Seed Venue Enhancements | ${dryRun ? "DRY RUN" : "LIVE"}`);

  if (clear) await clearCollection(db, COLLECTION, dryRun);

  const venues: any[] = readJsonFile(JSON_FILE);

  if (venues.length === 0) {
    console.log("No venues found.");
    return;
  }

  const now = admin.firestore.Timestamp.now();
  const oneMonthFromNow = admin.firestore.Timestamp.fromDate(
    new Date(Date.now() + 30 * 24 * 60 * 60 * 1000)
  );

  const docs = venues.map((v: any) => {
    const data = { ...v };
    delete data.venueId;
    delete data.venueName;

    // Add timestamps
    data.createdAt = now;
    data.updatedAt = now;
    if (data.broadcastingSchedule) data.broadcastingSchedule.lastUpdated = now;
    if (data.gameSpecials) data.gameSpecials.forEach((s: any) => { s.createdAt = now; });
    if (data.liveCapacity) data.liveCapacity.lastUpdated = now;
    if (data.featuredUntil === true) data.featuredUntil = oneMonthFromNow;

    if (verbose) console.log(`  ${v.venueId} (${v.subscriptionTier})`);

    return { id: v.venueId, data };
  });

  await batchWrite(db, COLLECTION, docs, dryRun);
}

main()
  .then(() => { console.log("Done."); process.exit(0); })
  .catch((e) => { console.error("Failed:", e); process.exit(1); });

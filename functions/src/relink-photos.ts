/**
 * Re-link Player & Manager Photos
 *
 * Lists existing photos in Firebase Storage and updates Firestore
 * documents with the correct photoUrl. Does NOT fetch from TheSportsDB —
 * only re-links photos already uploaded to Storage.
 *
 * Usage:
 *   npx ts-node src/relink-photos.ts [--dryRun]
 */

import * as admin from "firebase-admin";

// Initialize Firebase Admin
if (!admin.apps.length) {
  admin.initializeApp({
    storageBucket: "pregame-b089e.firebasestorage.app",
  });
}

const db = admin.firestore();
const bucket = admin.storage().bucket();

async function main() {
  const dryRun = process.argv.includes("--dryRun");
  console.log(`\n=== Re-link Photos from Firebase Storage ===`);
  console.log(`Mode: ${dryRun ? "DRY RUN" : "LIVE"}\n`);

  // 1. List all player photos in Storage
  console.log("Scanning Firebase Storage for player photos...");
  const [playerFiles] = await bucket.getFiles({ prefix: "players/" });
  console.log(`Found ${playerFiles.length} player photos in Storage\n`);

  // 2. List all manager photos in Storage
  console.log("Scanning Firebase Storage for manager photos...");
  const [managerFiles] = await bucket.getFiles({ prefix: "managers/" });
  console.log(`Found ${managerFiles.length} manager photos in Storage\n`);

  // 3. Build a map of Firestore doc ID → public URL
  // Storage files: "players/alg_alg_1.jpg" or "players/alg_alg_1.png"
  // Firestore doc IDs: "alg_1"
  // Mapping: strip "players/" prefix, strip extension, then strip the first teamCode prefix
  // e.g. "players/alg_alg_1.png" → "alg_alg_1" → docId "alg_1"
  const playerPhotoMap = new Map<string, string>();
  for (const file of playerFiles) {
    const url = `https://firebasestorage.googleapis.com/v0/b/${bucket.name}/o/${encodeURIComponent(file.name)}?alt=media`;
    // Extract: "players/usa_usa_5.png" → key "usa_usa_5"
    const key = file.name.replace("players/", "").replace(/\.(png|jpg|jpeg)$/, "");
    // Map to Firestore doc ID: "usa_usa_5" → "usa_5" (strip first teamCode_ prefix)
    const match = key.match(/^([a-z]+)_\1_(.+)$/);
    if (match) {
      const docId = `${match[1]}_${match[2]}`; // "usa_5"
      // Prefer .png over .jpg if both exist
      if (!playerPhotoMap.has(docId) || file.name.endsWith(".png")) {
        playerPhotoMap.set(docId, url);
      }
    }
  }

  // 4. Update player Firestore docs
  console.log("Updating player documents in Firestore...");
  const playersSnapshot = await db.collection("players").get();
  let playerUpdated = 0;
  let playerSkipped = 0;
  let playerNotFound = 0;

  let playerBatch = db.batch();
  let batchCount = 0;

  for (const doc of playersSnapshot.docs) {
    const data = doc.data();
    const currentUrl = data.photoUrl || "";

    // Skip if already has a valid Storage URL
    if (currentUrl.includes("storage.googleapis.com")) {
      playerSkipped++;
      continue;
    }

    // Try to find matching photo in Storage
    const storageKey = doc.id; // e.g. "alg_2"
    const url = playerPhotoMap.get(storageKey);

    if (url) {
      if (!dryRun) {
        playerBatch.update(doc.ref, { photoUrl: url });
        batchCount++;
        // Firestore batch limit is 500
        if (batchCount >= 490) {
          await playerBatch.commit();
          playerBatch = db.batch();
          batchCount = 0;
        }
      }
      playerUpdated++;
    } else {
      playerNotFound++;
    }
  }

  if (!dryRun && batchCount > 0) {
    await playerBatch.commit();
  }

  console.log(`  Players: ${playerUpdated} updated, ${playerSkipped} already had URLs, ${playerNotFound} no photo in Storage`);

  // 5. Update manager Firestore docs
  console.log("\nUpdating manager documents in Firestore...");
  const managersSnapshot = await db.collection("managers").get();
  let managerUpdated = 0;
  let managerSkipped = 0;
  let managerNotFound = 0;

  const managerBatch = db.batch();
  let mBatchCount = 0;

  for (const doc of managersSnapshot.docs) {
    const data = doc.data();
    const currentUrl = data.photoUrl || "";

    // Skip if already has a valid Storage URL
    if (currentUrl.includes("storage.googleapis.com")) {
      managerSkipped++;
      continue;
    }

    // Try to find matching photo in Storage
    const teamCode = (data.currentTeamCode || "").toLowerCase();
    let matchedUrl: string | null = null;

    for (const file of managerFiles) {
      if (file.name.toLowerCase().includes(teamCode) || file.name.toLowerCase().includes(doc.id.toLowerCase())) {
        matchedUrl = `https://firebasestorage.googleapis.com/v0/b/${bucket.name}/o/${encodeURIComponent(file.name)}?alt=media`;
        break;
      }
    }

    if (matchedUrl) {
      if (!dryRun) {
        managerBatch.update(doc.ref, { photoUrl: matchedUrl });
        mBatchCount++;
      }
      managerUpdated++;
    } else {
      managerNotFound++;
    }
  }

  if (!dryRun && mBatchCount > 0) {
    await managerBatch.commit();
  }

  console.log(`  Managers: ${managerUpdated} updated, ${managerSkipped} already had URLs, ${managerNotFound} no photo in Storage`);

  console.log("\n=== Done ===\n");
  process.exit(0);
}

main().catch((e) => {
  console.error("FATAL:", e);
  process.exit(1);
});

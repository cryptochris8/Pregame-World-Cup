/**
 * Re-link Photos from Firebase Storage
 *
 * Scans Firebase Storage for existing player and manager photos,
 * then updates the corresponding Firestore documents with the Storage URLs.
 *
 * This avoids calling any external APIs — it only reads from Storage
 * and writes to Firestore.
 *
 * Usage:
 *   npx ts-node src/relink-photos-from-storage.ts [--dryRun] [--type=players|managers|both]
 */

import * as admin from "firebase-admin";
import * as fs from "fs";
import * as path from "path";

// ============================================================================
// Configuration
// ============================================================================

const DRY_RUN = process.argv.includes("--dryRun");
const TYPE_ARG = process.argv.find((a) => a.startsWith("--type="))?.split("=")[1] || "both";
const BUCKET_NAME = "pregame-b089e.firebasestorage.app";

// ============================================================================
// Firebase Initialization
// ============================================================================

const serviceAccountPath = path.join(__dirname, "../../service-account-key.json");

if (fs.existsSync(serviceAccountPath)) {
  const serviceAccount = require(serviceAccountPath);
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    storageBucket: BUCKET_NAME,
  });
} else {
  admin.initializeApp({
    projectId: "pregame-b089e",
    storageBucket: BUCKET_NAME,
  });
}

const db = admin.firestore();
const bucket = admin.storage().bucket();

// ============================================================================
// Helpers
// ============================================================================

function storageUrlFromPath(filePath: string): string {
  const encoded = encodeURIComponent(filePath);
  return `https://firebasestorage.googleapis.com/v0/b/${BUCKET_NAME}/o/${encoded}?alt=media`;
}

// ============================================================================
// Re-link Players
// ============================================================================

async function relinkPlayers(): Promise<{ updated: number; skipped: number; noFile: number }> {
  console.log("\n── Re-linking Player Photos ──────────────────────────");

  // 1. List all files in the players/ folder in Storage
  console.log("Scanning Firebase Storage for player photos...");
  const [files] = await bucket.getFiles({ prefix: "players/" });

  // Build a map: fileName (without extension) → Storage URL
  const storageMap = new Map<string, string>();
  for (const file of files) {
    const name = file.name; // e.g., "players/arg_arg_1.jpg"
    storageMap.set(name, storageUrlFromPath(name));
  }
  console.log(`Found ${storageMap.size} player photos in Storage`);

  // 2. Get all players from Firestore
  console.log("Fetching players from Firestore...");
  const snapshot = await db.collection("players").get();
  console.log(`Found ${snapshot.size} player documents`);

  let updated = 0;
  let skipped = 0;
  let noFile = 0;

  // 3. For each player, check if they already have a photoUrl.
  //    If not, try to find their photo in Storage by matching patterns.
  let batch = db.batch();
  let batchCount = 0;

  for (const doc of snapshot.docs) {
    const data = doc.data();

    // Skip if already has a valid Storage URL
    if (data.photoUrl?.includes("firebasestorage.googleapis.com")) {
      skipped++;
      continue;
    }

    // Try to find a matching file in Storage
    // Storage path pattern: players/{teamCode}_{docId}.jpg or players/{teamCode}_{docId}.png
    const docId = doc.id;
    const teamCode = (data.teamCode || "").toLowerCase();

    let matchedUrl: string | null = null;

    // Try exact match patterns
    for (const [storagePath, url] of storageMap) {
      // Match by doc ID in the filename
      if (storagePath.includes(docId)) {
        matchedUrl = url;
        break;
      }
    }

    // Also try matching by teamCode + jersey/position pattern
    if (!matchedUrl && teamCode) {
      for (const [storagePath, url] of storageMap) {
        if (storagePath.startsWith(`players/${teamCode}_`)) {
          // Extract the suffix and see if it matches the doc
          const suffix = storagePath.replace(`players/${teamCode}_`, "").replace(/\.\w+$/, "");
          if (docId.endsWith(suffix) || docId.includes(suffix)) {
            matchedUrl = url;
            break;
          }
        }
      }
    }

    if (matchedUrl) {
      if (!DRY_RUN) {
        batch.update(doc.ref, { photoUrl: matchedUrl });
        batchCount++;

        // Commit in chunks of 490 and create new batch
        if (batchCount >= 490) {
          await batch.commit();
          updated += batchCount;
          console.log(`  Committed batch (${updated} updated so far)`);
          batch = db.batch();
          batchCount = 0;
        }
      } else {
        updated++;
      }
    } else {
      noFile++;
    }
  }

  // Commit remaining
  if (!DRY_RUN && batchCount > 0) {
    await batch.commit();
    updated += batchCount;
  }

  console.log(`\nPlayers: ${updated} re-linked, ${skipped} already had URLs, ${noFile} no Storage file found`);
  return { updated, skipped, noFile };
}

// ============================================================================
// Re-link Managers
// ============================================================================

async function relinkManagers(): Promise<{ updated: number; skipped: number; noFile: number }> {
  console.log("\n── Re-linking Manager Photos ──────────────────────────");

  // 1. List all files in the managers/ folder in Storage
  console.log("Scanning Firebase Storage for manager photos...");
  const [files] = await bucket.getFiles({ prefix: "managers/" });

  const storageMap = new Map<string, string>();
  for (const file of files) {
    storageMap.set(file.name, storageUrlFromPath(file.name));
  }
  console.log(`Found ${storageMap.size} manager photos in Storage`);

  // 2. Get all managers from Firestore
  console.log("Fetching managers from Firestore...");
  const snapshot = await db.collection("managers").get();
  console.log(`Found ${snapshot.size} manager documents`);

  let updated = 0;
  let skipped = 0;
  let noFile = 0;

  let batch = db.batch();
  let batchCount = 0;

  for (const doc of snapshot.docs) {
    const data = doc.data();

    // Skip if already has a valid Storage URL
    if (data.photoUrl?.includes("firebasestorage.googleapis.com")) {
      skipped++;
      continue;
    }

    const docId = doc.id;
    const teamCode = (data.currentTeamCode || data.teamCode || "").toLowerCase();

    let matchedUrl: string | null = null;

    // Storage files use various patterns:
    //   managers/{tc}_manager.jpg
    //   managers/{tc}_{tc}_{name}.png
    //   managers/xx_manager_{tc}.jpg
    //   managers/{tc}_manager.png
    // Firestore doc IDs: manager_{tc}

    // Try all patterns matching this teamCode
    if (teamCode) {
      for (const [storagePath, url] of storageMap) {
        const lowerPath = storagePath.toLowerCase();
        if (
          lowerPath === `managers/${teamCode}_manager.jpg` ||
          lowerPath === `managers/${teamCode}_manager.png` ||
          lowerPath.startsWith(`managers/${teamCode}_${teamCode}_`) ||
          lowerPath === `managers/xx_manager_${teamCode}.jpg` ||
          lowerPath === `managers/xx_manager_${teamCode}.png`
        ) {
          matchedUrl = url;
          break;
        }
      }
    }

    // Fallback: try matching by doc ID
    if (!matchedUrl) {
      for (const [storagePath, url] of storageMap) {
        if (storagePath.includes(docId)) {
          matchedUrl = url;
          break;
        }
      }
    }

    if (matchedUrl) {
      if (!DRY_RUN) {
        batch.update(doc.ref, { photoUrl: matchedUrl });
        batchCount++;

        if (batchCount >= 490) {
          await batch.commit();
          updated += batchCount;
          batch = db.batch();
          batchCount = 0;
        }
      } else {
        updated++;
      }
    } else {
      noFile++;
    }
  }

  if (!DRY_RUN && batchCount > 0) {
    await batch.commit();
    updated += batchCount;
  }

  console.log(`\nManagers: ${updated} re-linked, ${skipped} already had URLs, ${noFile} no Storage file found`);
  return { updated, skipped, noFile };
}

// ============================================================================
// Main
// ============================================================================

async function main() {
  console.log("╔══════════════════════════════════════════╗");
  console.log("║   Re-link Photos from Firebase Storage   ║");
  console.log("╚══════════════════════════════════════════╝");
  console.log(`Mode: ${DRY_RUN ? "DRY RUN" : "LIVE"}`);
  console.log(`Type: ${TYPE_ARG}`);

  const results: { type: string; updated: number; skipped: number; noFile: number }[] = [];

  if (TYPE_ARG === "players" || TYPE_ARG === "both") {
    const r = await relinkPlayers();
    results.push({ type: "Players", ...r });
  }

  if (TYPE_ARG === "managers" || TYPE_ARG === "both") {
    const r = await relinkManagers();
    results.push({ type: "Managers", ...r });
  }

  console.log("\n╔══════════════════════════════════════════╗");
  console.log("║               SUMMARY                    ║");
  console.log("╚══════════════════════════════════════════╝");
  for (const r of results) {
    console.log(`  ${r.type}: ${r.updated} re-linked, ${r.skipped} already OK, ${r.noFile} not in Storage`);
  }
  console.log("");
}

main()
  .then(() => { console.log("Done."); process.exit(0); })
  .catch((e) => { console.error("Failed:", e); process.exit(1); });

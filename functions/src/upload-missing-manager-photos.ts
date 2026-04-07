/**
 * Upload Missing Manager Photos from Wikimedia Commons
 *
 * Downloads manager photos for Steve Clarke (SCO) and Jon Dahl Tomasson (SWE)
 * from Wikimedia Commons URLs and uploads them to Firebase Storage,
 * then updates their Firestore documents.
 *
 * Usage: npx ts-node src/upload-missing-manager-photos.ts [--dryRun]
 */

import * as admin from "firebase-admin";
import axios from "axios";

if (!admin.apps.length) {
  admin.initializeApp({
    storageBucket: "pregame-b089e.firebasestorage.app",
  });
}

const db = admin.firestore();
const bucket = admin.storage().bucket();

const sleep = (ms: number) => new Promise((r) => setTimeout(r, ms));

// Manager photos sourced from Wikimedia Commons
// Each entry has a primary URL and fallback URLs in case the primary fails.
const MANAGER_PHOTOS: {
  teamCode: string;
  name: string;
  urls: string[];
}[] = [
  {
    teamCode: "SCO",
    name: "Steve Clarke",
    urls: [
      "https://upload.wikimedia.org/wikipedia/commons/3/3e/Steve_Clarke.jpg",
      "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3e/Steve_Clarke.jpg/440px-Steve_Clarke.jpg",
      "https://upload.wikimedia.org/wikipedia/commons/e/e7/Steve_Clarke_2019.jpg",
    ],
  },
  {
    teamCode: "SWE",
    name: "Jon Dahl Tomasson",
    urls: [
      "https://upload.wikimedia.org/wikipedia/commons/8/8e/Jon_Dahl_Tomasson.jpg",
      "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8e/Jon_Dahl_Tomasson.jpg/440px-Jon_Dahl_Tomasson.jpg",
      "https://upload.wikimedia.org/wikipedia/commons/0/0e/Jon_Dahl_Tomasson_2023.jpg",
    ],
  },
];

async function downloadImage(urls: string[]): Promise<{ buffer: Buffer; url: string } | null> {
  for (const url of urls) {
    try {
      console.log(`  Trying: ${url}`);
      const resp = await axios.get(url, {
        responseType: "arraybuffer",
        headers: { "User-Agent": "PregameApp/1.0 (photo fetch script)" },
        timeout: 15000,
      });
      console.log(`  Download succeeded (${(resp.data.byteLength / 1024).toFixed(0)} KB)`);
      return { buffer: Buffer.from(resp.data), url };
    } catch (e: any) {
      console.error(`  Download failed for ${url}: ${e.message}`);
    }
  }
  console.error(`  All URLs failed for this manager.`);
  return null;
}

async function main() {
  const dryRun = process.argv.includes("--dryRun");
  console.log(`\n=== Upload Missing Manager Photos from Wikimedia ===`);
  console.log(`Mode: ${dryRun ? "DRY RUN" : "LIVE"}\n`);

  let success = 0;
  let failed = 0;

  for (const mgr of MANAGER_PHOTOS) {
    console.log(`[${mgr.teamCode}] ${mgr.name}`);

    // Find matching Firestore doc
    const snap = await db.collection("managers")
      .where("currentTeamCode", "==", mgr.teamCode)
      .limit(1)
      .get();

    if (snap.empty) {
      console.log(`  Firestore doc not found, skipping`);
      failed++;
      continue;
    }

    const doc = snap.docs[0];
    const existing = doc.data().photoUrl || "";
    if (existing.includes("storage.googleapis.com")) {
      console.log(`  Already has Storage URL, skipping`);
      success++;
      continue;
    }

    // Download with fallback URLs
    console.log(`  Downloading...`);
    const result = await downloadImage(mgr.urls);
    if (!result) {
      failed++;
      continue;
    }

    const { buffer: imageBuffer, url: usedUrl } = result;
    const ext = usedUrl.match(/\.(png|jpg|jpeg)/i)?.[1]?.toLowerCase() || "jpg";
    const fileName = `managers/${mgr.teamCode.toLowerCase()}_manager.${ext}`;

    if (dryRun) {
      console.log(`  [DRY RUN] Would upload ${imageBuffer.length} bytes as ${fileName}`);
      success++;
      continue;
    }

    // Upload to Storage
    console.log(`  Uploading to Storage (${(imageBuffer.length / 1024).toFixed(0)} KB)...`);
    try {
      const file = bucket.file(fileName);
      await file.save(imageBuffer, {
        metadata: {
          contentType: `image/${ext === "jpg" ? "jpeg" : ext}`,
          cacheControl: "public, max-age=31536000",
        },
      });
      await file.makePublic();

      const publicUrl = `https://firebasestorage.googleapis.com/v0/b/${bucket.name}/o/${encodeURIComponent(fileName)}?alt=media`;

      // Update Firestore
      await doc.ref.update({ photoUrl: publicUrl });
      console.log(`  Success: ${publicUrl}`);
      success++;
    } catch (e: any) {
      console.error(`  Upload failed: ${e.message}`);
      failed++;
    }

    await sleep(3000); // Avoid Wikimedia rate limiting
  }

  console.log(`\n=== Done ===`);
  console.log(`Success: ${success}, Failed: ${failed}`);
  process.exit(0);
}

main().catch((e) => {
  console.error("FATAL:", e);
  process.exit(1);
});

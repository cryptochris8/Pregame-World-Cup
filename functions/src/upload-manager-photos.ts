/**
 * Upload Manager Photos from Wikimedia Commons
 *
 * Downloads manager photos from known Wikimedia URLs and uploads
 * them to Firebase Storage, then updates Firestore.
 *
 * Usage: npx ts-node src/upload-manager-photos.ts [--dryRun]
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
const MANAGER_PHOTOS: { teamCode: string; name: string; url: string }[] = [
  { teamCode: "ALG", name: "Vladimir Petković", url: "https://upload.wikimedia.org/wikipedia/commons/e/ee/Vladimir_Petkovi%C4%87%2C_APS_-_20240304_%28cropped%29.png" },
  { teamCode: "AUT", name: "Ralf Rangnick", url: "https://upload.wikimedia.org/wikipedia/commons/b/bb/2022-07-30_Fu%C3%9Fball%2C_M%C3%A4nner%2C_DFL-Supercup%2C_RB_Leipzig_-_FC_Bayern_M%C3%BCnchen_1DX_3148_by_Stepro.jpg" },
  { teamCode: "CIV", name: "Emerse Faé", url: "https://upload.wikimedia.org/wikipedia/commons/3/3a/Emerse_Fa%C3%A9.jpg" },
  { teamCode: "COD", name: "Sébastien Desabre", url: "https://upload.wikimedia.org/wikipedia/commons/a/a8/S%C3%A9bastien_Desabre.JPG" },
  { teamCode: "CUR", name: "Fred Rutten", url: "https://upload.wikimedia.org/wikipedia/commons/a/aa/Zaria-Feyenord_%281%29.jpg" },
  { teamCode: "EGY", name: "Hossam Hassan", url: "https://upload.wikimedia.org/wikipedia/commons/b/b7/Hossam_Hassan.png" },
  { teamCode: "IDN", name: "Shin Tae-yong", url: "https://upload.wikimedia.org/wikipedia/commons/4/4d/%EC%8B%A0%ED%83%9C%EC%9A%A9_%28Shin_Tae-yong%29.jpg" },
  { teamCode: "IRN", name: "Amir Ghalenoei", url: "https://upload.wikimedia.org/wikipedia/commons/9/91/Amir_Ghalenoei_14021114000776638425776058160814_23579.jpg" },
  { teamCode: "JOR", name: "Jamal Sellami", url: "https://upload.wikimedia.org/wikipedia/commons/7/71/WAC_vs._FUS_%2822.08.12%29_-_1.jpg" },
  { teamCode: "KSA", name: "Hervé Renard", url: "https://upload.wikimedia.org/wikipedia/commons/0/0d/Herv%C3%A9_Renard.jpg" },
  { teamCode: "MEX", name: "Javier Aguirre", url: "https://upload.wikimedia.org/wikipedia/commons/b/b4/Javier_Aguirre.png" },
  { teamCode: "NOR", name: "Ståle Solbakken", url: "https://upload.wikimedia.org/wikipedia/commons/8/85/Kopengagen-_%282%29.jpg" },
  { teamCode: "NZL", name: "Darren Bazeley", url: "https://upload.wikimedia.org/wikipedia/commons/7/7c/Darren_Bazeley_%2830_March%29.jpg" },
  { teamCode: "PAN", name: "Thomas Christiansen", url: "https://upload.wikimedia.org/wikipedia/commons/9/95/Partido_Galicia_-_Panam%C3%A1_en_Bala%C3%ADdos_149_%28cropped%29.jpg" },
  { teamCode: "PAR", name: "Gustavo Alfaro", url: "https://upload.wikimedia.org/wikipedia/commons/d/d0/Gustavo_Alfaro_%282022%29_%28cropped%29.jpg" },
  { teamCode: "QAT", name: "Julen Lopetegui", url: "https://upload.wikimedia.org/wikipedia/commons/2/25/Julen_Lopetegui_2017_%28cropped%29.jpg" },
  { teamCode: "RSA", name: "Hugo Broos", url: "https://upload.wikimedia.org/wikipedia/commons/f/f0/Hugo_Broos_1.jpg" },
  { teamCode: "TUN", name: "Sabri Lamouchi", url: "https://upload.wikimedia.org/wikipedia/commons/a/af/Sabri_Lamouchi_-_Portrait_2022.jpg" },
  { teamCode: "TUR", name: "Vincenzo Montella", url: "https://upload.wikimedia.org/wikipedia/commons/2/2b/Vincenzo_Montella_ICC_2016_%28edited%29.jpg" },
  { teamCode: "UZB", name: "Fabio Cannavaro", url: "https://upload.wikimedia.org/wikipedia/commons/0/09/Fabio_Cannavaro_2011.jpg" },
];

async function downloadImage(url: string): Promise<Buffer | null> {
  try {
    const resp = await axios.get(url, {
      responseType: "arraybuffer",
      headers: { "User-Agent": "PregameApp/1.0 (photo fetch script)" },
      timeout: 15000,
    });
    return Buffer.from(resp.data);
  } catch (e: any) {
    console.error(`  Download failed: ${e.message}`);
    return null;
  }
}

async function main() {
  const dryRun = process.argv.includes("--dryRun");
  console.log(`\n=== Upload Manager Photos from Wikimedia ===`);
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

    // Download
    console.log(`  Downloading...`);
    const imageBuffer = await downloadImage(mgr.url);
    if (!imageBuffer) {
      failed++;
      continue;
    }

    const ext = mgr.url.match(/\.(png|jpg|jpeg)/i)?.[1]?.toLowerCase() || "jpg";
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

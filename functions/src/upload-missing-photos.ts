/**
 * Upload Missing Player & Manager Photos
 *
 * Downloads photos from known URLs and uploads to Firebase Storage,
 * then updates Firestore documents. One-time script to fill gaps.
 *
 * Usage: npx ts-node src/upload-missing-photos.ts [--dryRun]
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
const DRY_RUN = process.argv.includes("--dryRun");

// ============================================================================
// Missing Managers (2)
// ============================================================================

const MISSING_MANAGERS: { teamCode: string; name: string; url: string }[] = [
  {
    teamCode: "SCO",
    name: "Steve Clarke",
    url: "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e3/Steve_Clarke_2019.jpg/440px-Steve_Clarke_2019.jpg",
  },
  {
    teamCode: "SWE",
    name: "Jon Dahl Tomasson",
    url: "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5c/Jon_Dahl_Tomasson_2023.jpg/440px-Jon_Dahl_Tomasson_2023.jpg",
  },
];

// Alternate URLs in case primary fails
const MANAGER_FALLBACKS: Record<string, string[]> = {
  SCO: [
    "https://upload.wikimedia.org/wikipedia/commons/e/e3/Steve_Clarke_2019.jpg",
    "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4a/Steve_Clarke_Scotland.jpg/440px-Steve_Clarke_Scotland.jpg",
  ],
  SWE: [
    "https://upload.wikimedia.org/wikipedia/commons/5/5c/Jon_Dahl_Tomasson_2023.jpg",
    "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a1/Jon_Dahl_Tomasson_%28cropped%29.jpg/440px-Jon_Dahl_Tomasson_%28cropped%29.jpg",
  ],
};

// ============================================================================
// Missing Players (23)
// ============================================================================

const MISSING_PLAYERS: { teamCode: string; name: string; url: string }[] = [
  // Bosnia (BIH) - 3
  { teamCode: "BIH", name: "Stjepan Radeljic", url: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3d/Stjepan_Radeljic.jpg/440px-Stjepan_Radeljic.jpg" },
  { teamCode: "BIH", name: "Kenan Piric", url: "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d0/Kenan_Piri%C4%87.jpg/440px-Kenan_Piri%C4%87.jpg" },
  { teamCode: "BIH", name: "Nail Omerovic", url: "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e1/Nail_Omerovi%C4%87.jpg/440px-Nail_Omerovi%C4%87.jpg" },
  // Curaçao (CUR) - 1
  { teamCode: "CUR", name: "Shanon Carmelia", url: "https://upload.wikimedia.org/wikipedia/commons/thumb/8/89/Shanon_Carmelia.jpg/440px-Shanon_Carmelia.jpg" },
  // Haiti (HAI) - 3
  { teamCode: "HAI", name: "Mondy Prunier", url: "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/Mondy_Prunier.jpg/440px-Mondy_Prunier.jpg" },
  { teamCode: "HAI", name: "Zachary Hérivaux", url: "https://upload.wikimedia.org/wikipedia/commons/thumb/7/7e/Zachary_Herivaux.jpg/440px-Zachary_Herivaux.jpg" },
  { teamCode: "HAI", name: "Bryan Alceus", url: "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b2/Bryan_Alceus.jpg/440px-Bryan_Alceus.jpg" },
  // Iran (IRN) - 1
  { teamCode: "IRN", name: "Shoja Khalilzadeh", url: "https://upload.wikimedia.org/wikipedia/commons/thumb/5/55/Shoja_Khalilzadeh_2019.jpg/440px-Shoja_Khalilzadeh_2019.jpg" },
  // Iraq (IRQ) - 2
  { teamCode: "IRQ", name: "Ibrahim Bayesh", url: "https://upload.wikimedia.org/wikipedia/commons/thumb/9/9e/Ibrahim_Bayesh.jpg/440px-Ibrahim_Bayesh.jpg" },
  { teamCode: "IRQ", name: "Mohammed Dawood", url: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/38/Mohammed_Dawood.jpg/440px-Mohammed_Dawood.jpg" },
  // Jordan (JOR) - 5
  { teamCode: "JOR", name: "Mohammad Al-Basha", url: "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2f/Mohammad_Al_Basha.jpg/440px-Mohammad_Al_Basha.jpg" },
  { teamCode: "JOR", name: "Hamza Al-Dardour", url: "https://upload.wikimedia.org/wikipedia/commons/thumb/a/ab/Hamza_Al-Dardour.jpg/440px-Hamza_Al-Dardour.jpg" },
  { teamCode: "JOR", name: "Yousef Al-Rawashdeh", url: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3b/Yousef_Rawashdeh.jpg/440px-Yousef_Rawashdeh.jpg" },
  { teamCode: "JOR", name: "Oday Dabbagh", url: "https://upload.wikimedia.org/wikipedia/commons/thumb/f/fc/Oday_Dabbagh.jpg/440px-Oday_Dabbagh.jpg" },
  { teamCode: "JOR", name: "Mohammad Abu Zuraiq", url: "https://upload.wikimedia.org/wikipedia/commons/thumb/0/0e/Abu_Zuraiq.jpg/440px-Abu_Zuraiq.jpg" },
  { teamCode: "JOR", name: "Salem Al-Ajalin", url: "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4a/Salem_Al_Ajalin.jpg/440px-Salem_Al_Ajalin.jpg" },
  // Saudi Arabia (KSA) - 1
  { teamCode: "KSA", name: "Nawaf Al-Aqidi", url: "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6e/Nawaf_Al_Aqidi.jpg/440px-Nawaf_Al_Aqidi.jpg" },
  // New Zealand (NZL) - 1
  { teamCode: "NZL", name: "Alex Greive", url: "https://upload.wikimedia.org/wikipedia/commons/thumb/a/ab/Alex_Greive.jpg/440px-Alex_Greive.jpg" },
  // Paraguay (PAR) - 2
  { teamCode: "PAR", name: "Adam Bareiro", url: "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5a/Adam_Bareiro_2023.jpg/440px-Adam_Bareiro_2023.jpg" },
  { teamCode: "PAR", name: "Carlos Gonzalez", url: "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6c/Carlos_Gonzalez_footballer.jpg/440px-Carlos_Gonzalez_footballer.jpg" },
  // South Africa (RSA) - 2
  { teamCode: "RSA", name: "Patrick Maswanganyi", url: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/39/Patrick_Maswanganyi.jpg/440px-Patrick_Maswanganyi.jpg" },
  { teamCode: "RSA", name: "Bruce Bvuma", url: "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e1/Bruce_Bvuma.jpg/440px-Bruce_Bvuma.jpg" },
  // Uzbekistan (UZB) - 1
  { teamCode: "UZB", name: "Akmal Shorakhmedov", url: "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2f/Akmal_Shorakhmedov.jpg/440px-Akmal_Shorakhmedov.jpg" },
];

// ============================================================================
// Download & Upload Helpers
// ============================================================================

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

async function uploadToStorage(
  data: Buffer,
  storagePath: string,
  contentType: string = "image/jpeg"
): Promise<string> {
  const file = bucket.file(storagePath);
  await file.save(data, {
    metadata: { contentType, cacheControl: "public, max-age=31536000" },
  });
  const encodedPath = encodeURIComponent(storagePath);
  return `https://firebasestorage.googleapis.com/v0/b/pregame-b089e.firebasestorage.app/o/${encodedPath}?alt=media`;
}

// ============================================================================
// Process Managers
// ============================================================================

async function processManagers(): Promise<{ success: number; failed: number }> {
  console.log("\n── Uploading Missing Manager Photos ──────────────────────────\n");
  let success = 0, failed = 0;

  for (const mgr of MISSING_MANAGERS) {
    console.log(`[${mgr.teamCode}] ${mgr.name}`);

    const snap = await db.collection("managers")
      .where("currentTeamCode", "==", mgr.teamCode)
      .limit(1)
      .get();

    if (snap.empty) {
      console.log("  Not found in Firestore, skipping");
      failed++;
      continue;
    }

    // Skip if already has photo
    if (snap.docs[0].data().photoUrl?.includes("firebasestorage")) {
      console.log("  Already has photo, skipping");
      continue;
    }

    // Try primary URL, then fallbacks
    const urls = [mgr.url, ...(MANAGER_FALLBACKS[mgr.teamCode] || [])];
    let uploaded = false;

    for (const url of urls) {
      if (DRY_RUN) {
        console.log(`  [DRY RUN] Would download from: ${url}`);
        success++;
        uploaded = true;
        break;
      }

      const data = await downloadImage(url);
      if (data) {
        const ext = url.includes(".png") ? "png" : "jpg";
        const storagePath = `managers/xx_manager_${mgr.teamCode.toLowerCase()}.${ext}`;
        const storageUrl = await uploadToStorage(data, storagePath);
        await snap.docs[0].ref.update({ photoUrl: storageUrl });
        console.log(`  ✓ Uploaded → ${storageUrl}`);
        success++;
        uploaded = true;
        break;
      }
      await sleep(2000);
    }

    if (!uploaded) {
      console.log("  ✗ All URLs failed");
      failed++;
    }

    await sleep(3000);
  }

  return { success, failed };
}

// ============================================================================
// Process Players
// ============================================================================

async function processPlayers(): Promise<{ success: number; failed: number }> {
  console.log("\n── Uploading Missing Player Photos ──────────────────────────\n");
  let success = 0, failed = 0;

  for (const player of MISSING_PLAYERS) {
    console.log(`[${player.teamCode}] ${player.name}`);

    // Find player in Firestore by fullName and teamCode
    const snap = await db.collection("players")
      .where("fullName", "==", player.name)
      .where("teamCode", "==", player.teamCode)
      .limit(1)
      .get();

    if (snap.empty) {
      // Try without teamCode filter
      const snap2 = await db.collection("players")
        .where("fullName", "==", player.name)
        .limit(1)
        .get();

      if (snap2.empty) {
        console.log("  Not found in Firestore, skipping");
        failed++;
        continue;
      }
    }

    const doc = snap.empty ? (await db.collection("players").where("fullName", "==", player.name).limit(1).get()).docs[0] : snap.docs[0];

    if (!doc) {
      console.log("  Not found in Firestore, skipping");
      failed++;
      continue;
    }

    // Skip if already has photo
    if (doc.data().photoUrl?.includes("firebasestorage")) {
      console.log("  Already has photo, skipping");
      continue;
    }

    if (DRY_RUN) {
      console.log(`  [DRY RUN] Would download from: ${player.url}`);
      success++;
      continue;
    }

    const data = await downloadImage(player.url);
    if (data) {
      const tc = player.teamCode.toLowerCase();
      const storagePath = `players/${tc}_${doc.id}.jpg`;
      const storageUrl = await uploadToStorage(data, storagePath);
      await doc.ref.update({ photoUrl: storageUrl });
      console.log(`  ✓ Uploaded → ${storageUrl}`);
      success++;
    } else {
      console.log("  ✗ Download failed");
      failed++;
    }

    await sleep(2000);
  }

  return { success, failed };
}

// ============================================================================
// Main
// ============================================================================

async function main() {
  console.log("╔══════════════════════════════════════════╗");
  console.log("║    Upload Missing Photos (One-Time)      ║");
  console.log("╚══════════════════════════════════════════╝");
  console.log(`Mode: ${DRY_RUN ? "DRY RUN" : "LIVE"}\n`);

  const mgrResult = await processManagers();
  const playerResult = await processPlayers();

  console.log("\n╔══════════════════════════════════════════╗");
  console.log("║               SUMMARY                    ║");
  console.log("╚══════════════════════════════════════════╝");
  console.log(`  Managers: ${mgrResult.success} uploaded, ${mgrResult.failed} failed`);
  console.log(`  Players:  ${playerResult.success} uploaded, ${playerResult.failed} failed`);
  console.log("");
}

main()
  .then(() => { console.log("Done."); process.exit(0); })
  .catch((e) => { console.error("Failed:", e); process.exit(1); });

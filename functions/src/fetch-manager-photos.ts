/**
 * Manager Photo Fetcher Script
 *
 * Fetches manager photos from TheSportsDB and uploads them to Firebase Storage.
 * Then updates Firestore with the new photo URLs.
 *
 * Usage: npx ts-node src/fetch-manager-photos.ts
 */

import * as admin from 'firebase-admin';
import axios from 'axios';
import * as fs from 'fs';
import * as path from 'path';

// Initialize Firebase Admin
const serviceAccountPath = path.join(__dirname, '../../service-account-key.json');

if (fs.existsSync(serviceAccountPath)) {
  const serviceAccount = require(serviceAccountPath);
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    storageBucket: 'pregame-b089e.firebasestorage.app'
  });
} else {
  // Use default credentials (for local development with gcloud auth)
  admin.initializeApp({
    projectId: 'pregame-b089e',
    storageBucket: 'pregame-b089e.firebasestorage.app'
  });
}

const db = admin.firestore();
const bucket = admin.storage().bucket();

// TheSportsDB API (free tier)
const SPORTSDB_BASE_URL = 'https://www.thesportsdb.com/api/v1/json/3';

interface Manager {
  managerId: string;
  fullName: string;
  fifaCode: string;
  photoUrl: string;
}

interface SportsDBManager {
  idPlayer: string;
  strPlayer: string;
  strThumb: string | null;
  strCutout: string | null;
  strRender: string | null;
  strJob: string | null;
}

interface SportsDBResponse {
  player: SportsDBManager[] | null;
}

// Rate limiting helper
const sleep = (ms: number) => new Promise(resolve => setTimeout(resolve, ms));

/**
 * Search for a manager on TheSportsDB
 * Note: TheSportsDB uses the same endpoint for players and managers
 */
async function searchManager(managerName: string): Promise<SportsDBManager | null> {
  try {
    const url = `${SPORTSDB_BASE_URL}/searchplayers.php?p=${encodeURIComponent(managerName)}`;
    const response = await axios.get<SportsDBResponse>(url);

    if (response.data.player && response.data.player.length > 0) {
      // Try to find a manager specifically, otherwise take first result
      const manager = response.data.player.find(p =>
        p.strJob?.toLowerCase().includes('manager') ||
        p.strJob?.toLowerCase().includes('coach')
      );
      return manager || response.data.player[0];
    }
    return null;
  } catch (error) {
    console.error(`Error searching for manager ${managerName}:`, error);
    return null;
  }
}

/**
 * Download an image from URL
 */
async function downloadImage(url: string): Promise<Buffer | null> {
  try {
    const response = await axios.get(url, { responseType: 'arraybuffer' });
    return Buffer.from(response.data);
  } catch (error) {
    console.error(`Error downloading image from ${url}:`, error);
    return null;
  }
}

/**
 * Upload image to Firebase Storage
 */
async function uploadToStorage(
  imageBuffer: Buffer,
  managerId: string,
  fifaCode: string
): Promise<string | null> {
  try {
    const fileName = `managers/${fifaCode.toLowerCase()}_${managerId}.png`;
    const file = bucket.file(fileName);

    await file.save(imageBuffer, {
      metadata: {
        contentType: 'image/png',
        cacheControl: 'public, max-age=31536000', // Cache for 1 year
      },
    });

    // Make the file publicly accessible
    await file.makePublic();

    // Return the public URL (Firebase Storage format)
    const publicUrl = `https://firebasestorage.googleapis.com/v0/b/${bucket.name}/o/${encodeURIComponent(fileName)}?alt=media`;
    return publicUrl;
  } catch (error) {
    console.error(`Error uploading to storage:`, error);
    return null;
  }
}

/**
 * Update Firestore with new photo URL
 */
async function updateManagerPhotoUrl(managerId: string, photoUrl: string): Promise<boolean> {
  try {
    await db.collection('managers').doc(managerId).update({
      photoUrl: photoUrl
    });
    return true;
  } catch (error) {
    console.error(`Error updating Firestore for manager ${managerId}:`, error);
    return false;
  }
}

/**
 * Process a single manager
 */
async function processManager(manager: Manager): Promise<{
  managerId: string;
  name: string;
  status: 'success' | 'not_found' | 'error';
  photoUrl?: string;
}> {
  console.log(`\n📸 Processing: ${manager.fullName} (${manager.fifaCode})`);

  // Skip if already has a valid Firebase Storage URL
  if (manager.photoUrl && manager.photoUrl.includes('storage.googleapis.com')) {
    console.log(`  ✅ Already has Firebase Storage URL, skipping`);
    return { managerId: manager.managerId, name: manager.fullName, status: 'success', photoUrl: manager.photoUrl };
  }

  // Search for manager on TheSportsDB
  const sportsDbManager = await searchManager(manager.fullName);

  if (!sportsDbManager) {
    console.log(`  ❌ Manager not found on TheSportsDB`);
    return { managerId: manager.managerId, name: manager.fullName, status: 'not_found' };
  }

  // Get the best available photo URL
  const photoUrl = sportsDbManager.strCutout || sportsDbManager.strThumb || sportsDbManager.strRender;

  if (!photoUrl) {
    console.log(`  ❌ No photo available on TheSportsDB`);
    return { managerId: manager.managerId, name: manager.fullName, status: 'not_found' };
  }

  console.log(`  📥 Downloading photo...`);
  const imageBuffer = await downloadImage(photoUrl);

  if (!imageBuffer) {
    console.log(`  ❌ Failed to download photo`);
    return { managerId: manager.managerId, name: manager.fullName, status: 'error' };
  }

  console.log(`  ☁️ Uploading to Firebase Storage...`);
  const storageUrl = await uploadToStorage(imageBuffer, manager.managerId, manager.fifaCode);

  if (!storageUrl) {
    console.log(`  ❌ Failed to upload to Firebase Storage`);
    return { managerId: manager.managerId, name: manager.fullName, status: 'error' };
  }

  console.log(`  📝 Updating Firestore...`);
  const updated = await updateManagerPhotoUrl(manager.managerId, storageUrl);

  if (!updated) {
    console.log(`  ❌ Failed to update Firestore`);
    return { managerId: manager.managerId, name: manager.fullName, status: 'error' };
  }

  console.log(`  ✅ Success! URL: ${storageUrl}`);
  return { managerId: manager.managerId, name: manager.fullName, status: 'success', photoUrl: storageUrl };
}

/**
 * Main function
 */
async function main() {
  console.log('🚀 Starting Manager Photo Fetch Script');
  console.log('======================================\n');

  // Fetch all managers from Firestore
  console.log('📋 Fetching managers from Firestore...');
  const managersSnapshot = await db.collection('managers').get();

  const managers: Manager[] = managersSnapshot.docs.map(doc => ({
    managerId: doc.id,
    fullName: doc.data().fullName || '',
    fifaCode: doc.data().fifaCode || '',
    photoUrl: doc.data().photoUrl || '',
  }));

  console.log(`Found ${managers.length} managers\n`);

  // Process results tracking
  const results = {
    success: 0,
    not_found: 0,
    error: 0,
  };

  const notFoundManagers: string[] = [];
  const errorManagers: string[] = [];

  // Process each manager with rate limiting
  for (let i = 0; i < managers.length; i++) {
    const manager = managers[i];
    console.log(`\n[${i + 1}/${managers.length}]`);

    const result = await processManager(manager);

    switch (result.status) {
      case 'success':
        results.success++;
        break;
      case 'not_found':
        results.not_found++;
        notFoundManagers.push(`${result.name} (${manager.fifaCode})`);
        break;
      case 'error':
        results.error++;
        errorManagers.push(`${result.name} (${manager.fifaCode})`);
        break;
    }

    // Rate limiting
    if (i < managers.length - 1) {
      await sleep(1000);
    }
  }

  // Print summary
  console.log('\n\n======================================');
  console.log('📊 SUMMARY');
  console.log('======================================');
  console.log(`✅ Success: ${results.success}`);
  console.log(`❌ Not Found: ${results.not_found}`);
  console.log(`⚠️ Errors: ${results.error}`);
  console.log(`Total: ${managers.length}`);

  if (notFoundManagers.length > 0) {
    console.log('\n📋 Managers Not Found on TheSportsDB:');
    notFoundManagers.forEach(m => console.log(`  - ${m}`));
  }

  if (errorManagers.length > 0) {
    console.log('\n⚠️ Managers with Errors:');
    errorManagers.forEach(m => console.log(`  - ${m}`));
  }

  console.log('\n✨ Script completed!');
  process.exit(0);
}

// Run the script
main().catch(error => {
  console.error('Fatal error:', error);
  process.exit(1);
});

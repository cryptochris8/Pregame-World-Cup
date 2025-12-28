/**
 * Player Photo Fetcher Script
 *
 * Fetches player photos from TheSportsDB and uploads them to Firebase Storage.
 * Then updates Firestore with the new photo URLs.
 *
 * Usage: npx ts-node src/fetch-player-photos.ts
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

interface Player {
  playerId: string;
  fullName: string;
  commonName: string;
  fifaCode: string;
  photoUrl: string;
}

interface SportsDBPlayer {
  idPlayer: string;
  strPlayer: string;
  strThumb: string | null;
  strCutout: string | null;
  strRender: string | null;
}

interface SportsDBResponse {
  player: SportsDBPlayer[] | null;
}

// Rate limiting helper
const sleep = (ms: number) => new Promise(resolve => setTimeout(resolve, ms));

/**
 * Search for a player on TheSportsDB
 */
async function searchPlayer(playerName: string): Promise<SportsDBPlayer | null> {
  try {
    const url = `${SPORTSDB_BASE_URL}/searchplayers.php?p=${encodeURIComponent(playerName)}`;
    const response = await axios.get<SportsDBResponse>(url);

    if (response.data.player && response.data.player.length > 0) {
      // Return the first match
      return response.data.player[0];
    }
    return null;
  } catch (error) {
    console.error(`Error searching for player ${playerName}:`, error);
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
  playerId: string,
  fifaCode: string
): Promise<string | null> {
  try {
    const fileName = `players/${fifaCode.toLowerCase()}_${playerId}.png`;
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
async function updatePlayerPhotoUrl(playerId: string, photoUrl: string): Promise<boolean> {
  try {
    await db.collection('players').doc(playerId).update({
      photoUrl: photoUrl
    });
    return true;
  } catch (error) {
    console.error(`Error updating Firestore for player ${playerId}:`, error);
    return false;
  }
}

/**
 * Process a single player
 */
async function processPlayer(player: Player): Promise<{
  playerId: string;
  name: string;
  status: 'success' | 'not_found' | 'error';
  photoUrl?: string;
}> {
  console.log(`\n📸 Processing: ${player.fullName} (${player.fifaCode})`);

  // Skip if already has a valid Firebase Storage URL
  if (player.photoUrl && player.photoUrl.includes('storage.googleapis.com')) {
    console.log(`  ✅ Already has Firebase Storage URL, skipping`);
    return { playerId: player.playerId, name: player.fullName, status: 'success', photoUrl: player.photoUrl };
  }

  // Search for player on TheSportsDB
  // Try full name first, then common name
  let sportsDbPlayer = await searchPlayer(player.fullName);

  if (!sportsDbPlayer) {
    console.log(`  🔍 Full name not found, trying common name: ${player.commonName}`);
    sportsDbPlayer = await searchPlayer(player.commonName);
  }

  if (!sportsDbPlayer) {
    console.log(`  ❌ Player not found on TheSportsDB`);
    return { playerId: player.playerId, name: player.fullName, status: 'not_found' };
  }

  // Get the best available photo URL
  const photoUrl = sportsDbPlayer.strCutout || sportsDbPlayer.strThumb || sportsDbPlayer.strRender;

  if (!photoUrl) {
    console.log(`  ❌ No photo available on TheSportsDB`);
    return { playerId: player.playerId, name: player.fullName, status: 'not_found' };
  }

  console.log(`  📥 Downloading photo...`);
  const imageBuffer = await downloadImage(photoUrl);

  if (!imageBuffer) {
    console.log(`  ❌ Failed to download photo`);
    return { playerId: player.playerId, name: player.fullName, status: 'error' };
  }

  console.log(`  ☁️ Uploading to Firebase Storage...`);
  const storageUrl = await uploadToStorage(imageBuffer, player.playerId, player.fifaCode);

  if (!storageUrl) {
    console.log(`  ❌ Failed to upload to Firebase Storage`);
    return { playerId: player.playerId, name: player.fullName, status: 'error' };
  }

  console.log(`  📝 Updating Firestore...`);
  const updated = await updatePlayerPhotoUrl(player.playerId, storageUrl);

  if (!updated) {
    console.log(`  ❌ Failed to update Firestore`);
    return { playerId: player.playerId, name: player.fullName, status: 'error' };
  }

  console.log(`  ✅ Success! URL: ${storageUrl}`);
  return { playerId: player.playerId, name: player.fullName, status: 'success', photoUrl: storageUrl };
}

/**
 * Main function
 */
async function main() {
  console.log('🚀 Starting Player Photo Fetch Script');
  console.log('=====================================\n');

  // Fetch all players from Firestore
  console.log('📋 Fetching players from Firestore...');
  const playersSnapshot = await db.collection('players').get();

  const players: Player[] = playersSnapshot.docs.map(doc => ({
    playerId: doc.id,
    fullName: doc.data().fullName || '',
    commonName: doc.data().commonName || '',
    fifaCode: doc.data().fifaCode || '',
    photoUrl: doc.data().photoUrl || '',
  }));

  console.log(`Found ${players.length} players\n`);

  // Process results tracking
  const results = {
    success: 0,
    not_found: 0,
    error: 0,
    skipped: 0,
  };

  const notFoundPlayers: string[] = [];
  const errorPlayers: string[] = [];

  // Process each player with rate limiting
  for (let i = 0; i < players.length; i++) {
    const player = players[i];
    console.log(`\n[${i + 1}/${players.length}]`);

    const result = await processPlayer(player);

    switch (result.status) {
      case 'success':
        results.success++;
        break;
      case 'not_found':
        results.not_found++;
        notFoundPlayers.push(`${result.name} (${player.fifaCode})`);
        break;
      case 'error':
        results.error++;
        errorPlayers.push(`${result.name} (${player.fifaCode})`);
        break;
    }

    // Rate limiting: TheSportsDB free tier has limits
    // Wait 1 second between requests to be safe
    if (i < players.length - 1) {
      await sleep(1000);
    }
  }

  // Print summary
  console.log('\n\n=====================================');
  console.log('📊 SUMMARY');
  console.log('=====================================');
  console.log(`✅ Success: ${results.success}`);
  console.log(`❌ Not Found: ${results.not_found}`);
  console.log(`⚠️ Errors: ${results.error}`);
  console.log(`Total: ${players.length}`);

  if (notFoundPlayers.length > 0) {
    console.log('\n📋 Players Not Found on TheSportsDB:');
    notFoundPlayers.forEach(p => console.log(`  - ${p}`));
  }

  if (errorPlayers.length > 0) {
    console.log('\n⚠️ Players with Errors:');
    errorPlayers.forEach(p => console.log(`  - ${p}`));
  }

  console.log('\n✨ Script completed!');
  process.exit(0);
}

// Run the script
main().catch(error => {
  console.error('Fatal error:', error);
  process.exit(1);
});

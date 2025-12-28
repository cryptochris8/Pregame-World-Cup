/**
 * Enhanced Player Photo Fetcher Script (v2)
 *
 * Fetches player photos from multiple sources with fallbacks and robust error handling.
 * Uploads to Firebase Storage and updates Firestore.
 *
 * Features:
 * - Multiple photo sources (TheSportsDB, Wikipedia, etc.)
 * - Automatic fallback on failure
 * - Rate limiting to avoid API throttling
 * - Progress tracking with ETA
 * - Detailed logging and error reporting
 *
 * Usage:
 *   npx ts-node src/fetch-player-photos-v2.ts [--limit=10] [--dryRun]
 *
 * Examples:
 *   npx ts-node src/fetch-player-photos-v2.ts              # Process all players
 *   npx ts-node src/fetch-player-photos-v2.ts --limit=50   # Process first 50
 *   npx ts-node src/fetch-player-photos-v2.ts --dryRun     # Preview without uploading
 */

import * as admin from 'firebase-admin';
import * as fs from 'fs';
import * as path from 'path';
import {
  PhotoFetcher,
  ProgressTracker,
} from './photo-fetcher-utils';

// ============================================================================
// Configuration
// ============================================================================

const RATE_DELAY_MS = 500;
const DRY_RUN = process.argv.includes('--dryRun');
const LIMIT = parseInt(
  process.argv.find(arg => arg.startsWith('--limit='))?.split('=')[1] || '0'
);

// ============================================================================
// Firebase Initialization
// ============================================================================

const serviceAccountPath = path.join(__dirname, '../../service-account-key.json');

if (fs.existsSync(serviceAccountPath)) {
  const serviceAccount = require(serviceAccountPath);
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    storageBucket: 'pregame-b089e.firebasestorage.app',
  });
} else {
  admin.initializeApp({
    projectId: 'pregame-b089e',
    storageBucket: 'pregame-b089e.firebasestorage.app',
  });
}

const db = admin.firestore();
const bucket = admin.storage().bucket();

// ============================================================================
// Types
// ============================================================================

interface PlayerRecord {
  id: string;
  fullName: string;
  commonName?: string;
  fifaCode?: string;
  photoUrl?: string;
}

// ============================================================================
// Main Script
// ============================================================================

async function main() {
  console.log('=====================================');
  console.log('Enhanced Player Photo Fetcher v2');
  console.log('=====================================\n');

  if (DRY_RUN) {
    console.log('DRY RUN MODE - No changes will be saved\n');
  }

  // Initialize services
  const fetcher = new PhotoFetcher(bucket, db, RATE_DELAY_MS);

  // Fetch players from Firestore
  console.log('Fetching players from Firestore...');
  let query: admin.firestore.Query = db.collection('players');

  if (LIMIT > 0) {
    query = query.limit(LIMIT);
  }

  const snapshot = await query.get();
  const players: PlayerRecord[] = snapshot.docs.map(doc => ({
    id: doc.id,
    ...doc.data(),
  })) as PlayerRecord[];

  console.log(`Found ${players.length} players\n`);

  // Initialize progress tracker
  const progress = new ProgressTracker(players.length);

  // Results tracking
  const results = {
    success: [] as string[],
    notFound: [] as string[],
    error: [] as string[],
    skipped: [] as string[],
  };

  // Process each player
  for (let i = 0; i < players.length; i++) {
    const player = players[i];
    const progressInfo = progress.getProgress();

    console.log(`\n[${progressInfo.processed + 1}/${players.length}] ${player.fullName}`);
    console.log(`   ETA: ${progressInfo.estimatedRemaining}`);

    // Skip if already has valid Firebase Storage URL
    if (player.photoUrl?.includes('firebasestorage.googleapis.com')) {
      console.log('   Status: Already has Firebase Storage URL');
      progress.record('skipped');
      results.skipped.push(player.fullName);
      continue;
    }

    try {
      // Fetch and upload photo
      const result = await fetcher.fetchAndUpload(
        player.fullName,
        'player',
        player.id,
        player.fifaCode || 'XX',
        player.commonName ? [player.commonName] : undefined,
        player.photoUrl
      );

      if (result.success) {
        console.log(`   Status: SUCCESS`);
        console.log(`   Source: ${result.source}`);
        console.log(`   URL: ${result.photoUrl}`);
        progress.record('success');
        results.success.push(`${player.fullName} (${result.source})`);
      } else {
        console.log(`   Status: FAILED`);
        console.log(`   Error: ${result.error}`);
        progress.record('error');
        results.notFound.push(`${player.fullName} - ${result.error}`);
      }
    } catch (error) {
      console.log(`   Status: ERROR`);
      console.log(`   Error: ${error}`);
      progress.record('error');
      results.error.push(`${player.fullName} - ${String(error)}`);
    }
  }

  // Print final summary
  progress.printSummary();

  if (results.success.length > 0) {
    console.log('\nSuccessfully fetched:');
    results.success.slice(0, 10).forEach(p => console.log(`  + ${p}`));
    if (results.success.length > 10) {
      console.log(`  ... and ${results.success.length - 10} more`);
    }
  }

  if (results.notFound.length > 0) {
    console.log('\nNot found on any source:');
    results.notFound.slice(0, 10).forEach(p => console.log(`  - ${p}`));
    if (results.notFound.length > 10) {
      console.log(`  ... and ${results.notFound.length - 10} more`);
    }
  }

  if (results.error.length > 0) {
    console.log('\nEncountered errors:');
    results.error.slice(0, 10).forEach(p => console.log(`  ! ${p}`));
    if (results.error.length > 10) {
      console.log(`  ... and ${results.error.length - 10} more`);
    }
  }

  console.log('\n✨ Script completed!');
  process.exit(0);
}

// ============================================================================
// Run
// ============================================================================

main().catch(error => {
  console.error('\nFATAL ERROR:', error);
  process.exit(1);
});

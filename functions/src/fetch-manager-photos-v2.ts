/**
 * Enhanced Manager Photo Fetcher Script (v2)
 *
 * Fetches manager photos from multiple sources with fallbacks and robust error handling.
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
 *   npx ts-node src/fetch-manager-photos-v2.ts [--limit=10] [--dryRun]
 *
 * Examples:
 *   npx ts-node src/fetch-manager-photos-v2.ts              # Process all managers
 *   npx ts-node src/fetch-manager-photos-v2.ts --limit=20   # Process first 20
 *   npx ts-node src/fetch-manager-photos-v2.ts --dryRun     # Preview without uploading
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

interface ManagerRecord {
  id: string;
  fullName: string;
  fifaCode?: string;
  photoUrl?: string;
}

// ============================================================================
// Main Script
// ============================================================================

async function main() {
  console.log('=====================================');
  console.log('Enhanced Manager Photo Fetcher v2');
  console.log('=====================================\n');

  if (DRY_RUN) {
    console.log('DRY RUN MODE - No changes will be saved\n');
  }

  // Initialize services
  const fetcher = new PhotoFetcher(bucket, db, RATE_DELAY_MS);

  // Fetch managers from Firestore
  console.log('Fetching managers from Firestore...');
  let query: admin.firestore.Query = db.collection('managers');

  if (LIMIT > 0) {
    query = query.limit(LIMIT);
  }

  const snapshot = await query.get();
  const managers: ManagerRecord[] = snapshot.docs.map(doc => ({
    id: doc.id,
    ...doc.data(),
  })) as ManagerRecord[];

  console.log(`Found ${managers.length} managers\n`);

  // Initialize progress tracker
  const progress = new ProgressTracker(managers.length);

  // Results tracking
  const results = {
    success: [] as string[],
    notFound: [] as string[],
    error: [] as string[],
    skipped: [] as string[],
  };

  // Process each manager
  for (let i = 0; i < managers.length; i++) {
    const manager = managers[i];
    const progressInfo = progress.getProgress();

    console.log(`\n[${progressInfo.processed + 1}/${managers.length}] ${manager.fullName}`);
    console.log(`   ETA: ${progressInfo.estimatedRemaining}`);

    // Skip if already has valid Firebase Storage URL
    if (manager.photoUrl?.includes('firebasestorage.googleapis.com')) {
      console.log('   Status: Already has Firebase Storage URL');
      progress.record('skipped');
      results.skipped.push(manager.fullName);
      continue;
    }

    try {
      // Fetch and upload photo
      const result = await fetcher.fetchAndUpload(
        manager.fullName,
        'manager',
        manager.id,
        manager.fifaCode || 'XX',
        undefined,
        manager.photoUrl
      );

      if (result.success) {
        console.log(`   Status: SUCCESS`);
        console.log(`   Source: ${result.source}`);
        console.log(`   URL: ${result.photoUrl}`);
        progress.record('success');
        results.success.push(`${manager.fullName} (${result.source})`);
      } else {
        console.log(`   Status: FAILED`);
        console.log(`   Error: ${result.error}`);
        progress.record('error');
        results.notFound.push(`${manager.fullName} - ${result.error}`);
      }
    } catch (error) {
      console.log(`   Status: ERROR`);
      console.log(`   Error: ${error}`);
      progress.record('error');
      results.error.push(`${manager.fullName} - ${String(error)}`);
    }
  }

  // Print final summary
  progress.printSummary();

  if (results.success.length > 0) {
    console.log('\nSuccessfully fetched:');
    results.success.slice(0, 10).forEach(m => console.log(`  + ${m}`));
    if (results.success.length > 10) {
      console.log(`  ... and ${results.success.length - 10} more`);
    }
  }

  if (results.notFound.length > 0) {
    console.log('\nNot found on any source:');
    results.notFound.slice(0, 10).forEach(m => console.log(`  - ${m}`));
    if (results.notFound.length > 10) {
      console.log(`  ... and ${results.notFound.length - 10} more`);
    }
  }

  if (results.error.length > 0) {
    console.log('\nEncountered errors:');
    results.error.slice(0, 10).forEach(m => console.log(`  ! ${m}`));
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

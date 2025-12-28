/**
 * Enhanced Photo Status Checker (v2)
 *
 * Checks and reports on photo URLs in Firestore.
 * Provides statistics on photo coverage and sources.
 *
 * Usage:
 *   npx ts-node src/check-photos-v2.ts [--players|--managers|--all]
 *
 * Examples:
 *   npx ts-node src/check-photos-v2.ts              # Check all
 *   npx ts-node src/check-photos-v2.ts --players    # Check only players
 *   npx ts-node src/check-photos-v2.ts --managers   # Check only managers
 */

import * as admin from 'firebase-admin';
import * as fs from 'fs';
import * as path from 'path';

// ============================================================================
// Firebase Initialization
// ============================================================================

const serviceAccountPath = path.join(__dirname, '../../service-account-key.json');

if (fs.existsSync(serviceAccountPath)) {
  const serviceAccount = require(serviceAccountPath);
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
} else {
  admin.initializeApp({
    projectId: 'pregame-b089e',
  });
}

const db = admin.firestore();

// ============================================================================
// Types
// ============================================================================

interface PhotoStats {
  total: number;
  withPhoto: number;
  withFirebasePhoto: number;
  withOtherPhoto: number;
  withoutPhoto: number;
  photoSources: Record<string, number>;
}

interface EntityRecord {
  id: string;
  name: string;
  photoUrl?: string;
  photoSource?: string;
  photoUpdatedAt?: any;
}

// ============================================================================
// Functions
// ============================================================================

function categorizePhotoUrl(
  url?: string
): 'firebase' | 'other' | 'none' {
  if (!url) return 'none';
  if (url.includes('firebasestorage.googleapis.com')) return 'firebase';
  return 'other';
}

function getPhotoSource(url?: string, source?: string): string {
  if (source && source !== 'null') return source;

  if (!url) return 'None';
  if (url.includes('thesportsdb')) return 'TheSportsDB';
  if (url.includes('wikipedia') || url.includes('wikimedia')) return 'Wikipedia';
  if (url.includes('firebasestorage')) return 'Firebase Storage';
  return 'Unknown';
}

async function checkCollection(
  collectionName: 'players' | 'managers'
): Promise<PhotoStats> {
  const displayName = collectionName === 'players' ? 'Players' : 'Managers';

  console.log(`\n${'='.repeat(50)}`);
  console.log(`${displayName} Photo Status`);
  console.log(`${'='.repeat(50)}\n`);

  // Fetch all entities
  const snapshot = await db.collection(collectionName).get();

  const entities: EntityRecord[] = snapshot.docs.map(doc => {
    const data = doc.data();
    return {
      id: doc.id,
      name: data.fullName || data.commonName || 'Unknown',
      photoUrl: data.photoUrl,
      photoSource: data.photoSource,
      photoUpdatedAt: data.photoUpdatedAt,
    };
  });

  // Calculate stats
  const stats: PhotoStats = {
    total: entities.length,
    withPhoto: 0,
    withFirebasePhoto: 0,
    withOtherPhoto: 0,
    withoutPhoto: 0,
    photoSources: {},
  };

  const withoutPhotoList: string[] = [];
  const recentlyFetchedList: Array<{
    name: string;
    source: string;
    date: string;
  }> = [];

  entities.forEach(entity => {
    const category = categorizePhotoUrl(entity.photoUrl);

    if (category === 'firebase') {
      stats.withFirebasePhoto++;
      stats.withPhoto++;

      const source = getPhotoSource(entity.photoUrl, entity.photoSource);
      stats.photoSources[source] = (stats.photoSources[source] || 0) + 1;

      if (entity.photoUpdatedAt) {
        const date = new Date(entity.photoUpdatedAt.toDate?.() || entity.photoUpdatedAt)
          .toLocaleDateString();
        recentlyFetchedList.push({
          name: entity.name,
          source,
          date,
        });
      }
    } else if (category === 'other') {
      stats.withOtherPhoto++;
      stats.withPhoto++;

      const source = getPhotoSource(entity.photoUrl, entity.photoSource);
      stats.photoSources[source] = (stats.photoSources[source] || 0) + 1;
    } else {
      stats.withoutPhoto++;
      withoutPhotoList.push(entity.name);
    }
  });

  // Print summary
  console.log('SUMMARY');
  console.log('-'.repeat(50));
  console.log(`Total ${collectionName}:        ${stats.total}`);
  console.log(`With Photo:               ${stats.withPhoto} (${((stats.withPhoto / stats.total) * 100).toFixed(1)}%)`);
  console.log(`  - Firebase Storage:     ${stats.withFirebasePhoto}`);
  console.log(`  - Other Source:         ${stats.withOtherPhoto}`);
  console.log(`Without Photo:            ${stats.withoutPhoto} (${((stats.withoutPhoto / stats.total) * 100).toFixed(1)}%)`);

  // Print photo sources breakdown
  if (Object.keys(stats.photoSources).length > 0) {
    console.log('\nPHOTO SOURCES');
    console.log('-'.repeat(50));
    Object.entries(stats.photoSources)
      .sort((a, b) => b[1] - a[1])
      .forEach(([source, count]) => {
        const percentage = ((count / stats.withPhoto) * 100).toFixed(1);
        console.log(`${source.padEnd(25)} ${count.toString().padStart(4)} (${percentage.padStart(5)}%)`);
      });
  }

  // Print entities without photos
  if (withoutPhotoList.length > 0 && withoutPhotoList.length <= 30) {
    console.log('\nWITHOUT PHOTOS');
    console.log('-'.repeat(50));
    withoutPhotoList.forEach(name => {
      console.log(`  - ${name}`);
    });
  } else if (withoutPhotoList.length > 30) {
    console.log('\nWITHOUT PHOTOS');
    console.log('-'.repeat(50));
    withoutPhotoList.slice(0, 20).forEach(name => {
      console.log(`  - ${name}`);
    });
    console.log(`  ... and ${withoutPhotoList.length - 20} more`);
  }

  // Print recently fetched (if Firebase photos exist)
  if (recentlyFetchedList.length > 0 && recentlyFetchedList.length <= 10) {
    console.log('\nRECENTLY FETCHED');
    console.log('-'.repeat(50));
    recentlyFetchedList
      .sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime())
      .forEach(item => {
        console.log(`  ${item.name.padEnd(40)} ${item.source.padEnd(20)} ${item.date}`);
      });
  }

  return stats;
}

async function main() {
  console.log('\n=====================================');
  console.log('Enhanced Photo Status Checker v2');
  console.log('=====================================');

  const checkPlayers = !process.argv.includes('--managers');
  const checkManagers = !process.argv.includes('--players');

  const allStats = {
    players: null as PhotoStats | null,
    managers: null as PhotoStats | null,
  };

  if (checkPlayers) {
    allStats.players = await checkCollection('players');
  }

  if (checkManagers) {
    allStats.managers = await checkCollection('managers');
  }

  // Print combined summary if both checked
  if (checkPlayers && checkManagers) {
    console.log(`\n${'='.repeat(50)}`);
    console.log('OVERALL SUMMARY');
    console.log(`${'='.repeat(50)}\n`);

    const totalEntities = (allStats.players?.total || 0) + (allStats.managers?.total || 0);
    const totalWithPhoto = (allStats.players?.withPhoto || 0) + (allStats.managers?.withPhoto || 0);
    const totalWithFirebase = (allStats.players?.withFirebasePhoto || 0) + (allStats.managers?.withFirebasePhoto || 0);

    console.log(`Total Entities:          ${totalEntities}`);
    console.log(`With Photo:              ${totalWithPhoto} (${((totalWithPhoto / totalEntities) * 100).toFixed(1)}%)`);
    console.log(`Firebase Storage:        ${totalWithFirebase} (${((totalWithFirebase / totalEntities) * 100).toFixed(1)}%)`);
    console.log(`Without Photo:           ${totalEntities - totalWithPhoto} (${(((totalEntities - totalWithPhoto) / totalEntities) * 100).toFixed(1)}%)`);
  }

  console.log('\nDone!');
  process.exit(0);
}

// ============================================================================
// Run
// ============================================================================

main().catch(error => {
  console.error('Error:', error);
  process.exit(1);
});

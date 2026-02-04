import * as admin from 'firebase-admin';
import * as fs from 'fs';
import * as path from 'path';

const serviceAccountPath = path.join(__dirname, '../../service-account-key.json');
if (fs.existsSync(serviceAccountPath)) {
  const serviceAccount = require(serviceAccountPath);
  admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
} else {
  admin.initializeApp({ projectId: 'pregame-b089e' });
}

const db = admin.firestore();

async function checkCollections() {
  const collections = [
    'worldcup_matches',
    'worldcup_players',
    'players',
    'worldcup_teams',
    'teams',
    'worldcup_managers',
    'managers',
    'headToHead',
    'head_to_head',
    'worldCupHistory',
    'world_cup_history',
    'matchSummaries',
    'match_summaries',
    'worldcup_venues',
    'venues',
    'watch_party_venues'
  ];

  console.log('=== Firestore Collection Counts ===\n');
  for (const col of collections) {
    try {
      const snapshot = await db.collection(col).get();
      console.log(`${col}: ${snapshot.size} documents`);
    } catch (e: any) {
      console.log(`${col}: error - ${e.message}`);
    }
  }
}

checkCollections().then(() => process.exit(0)).catch(e => {
  console.error('Error:', e);
  process.exit(1);
});

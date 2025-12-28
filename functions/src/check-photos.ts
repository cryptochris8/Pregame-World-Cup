/**
 * Quick diagnostic to check photo URLs in Firestore
 */

import * as admin from 'firebase-admin';
import * as fs from 'fs';
import * as path from 'path';

// Initialize Firebase Admin
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

async function main() {
  console.log('🔍 Checking Player Photo URLs in Firestore...\n');

  // Get first 10 players
  const playersSnapshot = await db.collection('players').limit(10).get();

  console.log('Sample Player Photo URLs:');
  console.log('========================');
  playersSnapshot.docs.forEach(doc => {
    const data = doc.data();
    console.log(`${data.commonName || data.fullName}:`);
    console.log(`  photoUrl: ${data.photoUrl || '(empty)'}`);
    console.log('');
  });

  // Get first 5 managers
  const managersSnapshot = await db.collection('managers').limit(5).get();

  console.log('\nSample Manager Photo URLs:');
  console.log('==========================');
  managersSnapshot.docs.forEach(doc => {
    const data = doc.data();
    console.log(`${data.fullName}:`);
    console.log(`  photoUrl: ${data.photoUrl || '(empty)'}`);
    console.log('');
  });

  // Count how many have Firebase Storage URLs
  const allPlayers = await db.collection('players').get();
  let playersWithFirebaseUrls = 0;
  let playersWithOldUrls = 0;
  let playersWithNoUrls = 0;

  allPlayers.docs.forEach(doc => {
    const photoUrl = doc.data().photoUrl || '';
    if (photoUrl.includes('firebasestorage.googleapis.com')) {
      playersWithFirebaseUrls++;
    } else if (photoUrl.length > 0) {
      playersWithOldUrls++;
    } else {
      playersWithNoUrls++;
    }
  });

  console.log('\n📊 Player Photo URL Summary:');
  console.log(`  ✅ Firebase Storage URLs: ${playersWithFirebaseUrls}`);
  console.log(`  ⚠️ Old/Other URLs: ${playersWithOldUrls}`);
  console.log(`  ❌ No URL: ${playersWithNoUrls}`);
  console.log(`  Total: ${allPlayers.docs.length}`);

  process.exit(0);
}

main().catch(err => {
  console.error('Error:', err);
  process.exit(1);
});

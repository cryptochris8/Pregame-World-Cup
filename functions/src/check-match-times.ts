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

async function checkMatchTimes() {
  console.log('=== World Cup 2026 Match Schedule Check ===\n');

  // Get all matches sorted by match number
  const snapshot = await db.collection('worldcup_matches')
    .orderBy('matchNumber')
    .get();

  console.log(`Total matches: ${snapshot.size}\n`);

  // Group stage samples
  console.log('--- GROUP STAGE SAMPLES ---');
  const groupMatches = [1, 2, 3, 10, 20, 50, 72];

  for (const matchNum of groupMatches) {
    const match = snapshot.docs.find(d => d.data().matchNumber === matchNum);
    if (match) {
      const data = match.data();
      const dateTime = data.dateTime ? new Date(data.dateTime) : null;
      console.log(`Match ${matchNum}: ${data.homeTeamName || data.homeTeamCode || data.homeTeamPlaceholder} vs ${data.awayTeamName || data.awayTeamCode || data.awayTeamPlaceholder}`);
      console.log(`  Date/Time: ${dateTime ? dateTime.toISOString() : 'Not set'}`);
      console.log(`  Venue: ${data.venueName}, ${data.venueCity}`);
      console.log(`  Stage: ${data.stage}, Group: ${data.group || 'N/A'}`);
      console.log('');
    }
  }

  // Knockout samples
  console.log('--- KNOCKOUT STAGE SAMPLES ---');
  const knockoutMatches = [73, 89, 97, 101, 103, 104];

  for (const matchNum of knockoutMatches) {
    const match = snapshot.docs.find(d => d.data().matchNumber === matchNum);
    if (match) {
      const data = match.data();
      const dateTime = data.dateTime ? new Date(data.dateTime) : null;
      console.log(`Match ${matchNum}: ${data.homeTeamPlaceholder || data.homeTeamName} vs ${data.awayTeamPlaceholder || data.awayTeamName}`);
      console.log(`  Date/Time: ${dateTime ? dateTime.toISOString() : 'Not set'}`);
      console.log(`  Venue: ${data.venueName}, ${data.venueCity}`);
      console.log(`  Stage: ${data.stage}`);
      console.log('');
    }
  }

  // Check date range
  console.log('--- DATE RANGE CHECK ---');
  const dates = snapshot.docs
    .map(d => d.data().dateTime)
    .filter(d => d)
    .map(d => new Date(d))
    .sort((a, b) => a.getTime() - b.getTime());

  if (dates.length > 0) {
    console.log(`First match: ${dates[0].toISOString()}`);
    console.log(`Last match: ${dates[dates.length - 1].toISOString()}`);
    console.log(`\nExpected: June 11, 2026 - July 19, 2026`);
  }
}

checkMatchTimes().then(() => process.exit(0)).catch(e => {
  console.error('Error:', e);
  process.exit(1);
});

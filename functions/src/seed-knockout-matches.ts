/**
 * Seed World Cup 2026 Knockout Stage Matches (Round of 32 through Final)
 *
 * Based on official FIFA schedule with 48-team format
 *
 * Usage:
 *   npx ts-node src/seed-knockout-matches.ts [--dryRun]
 */

import * as admin from 'firebase-admin';
import * as fs from 'fs';
import * as path from 'path';

const DRY_RUN = process.argv.includes('--dryRun');

// Firebase init
const serviceAccountPath = path.join(__dirname, '../../service-account-key.json');
if (fs.existsSync(serviceAccountPath)) {
  const serviceAccount = require(serviceAccountPath);
  admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
} else {
  admin.initializeApp({ projectId: 'pregame-b089e' });
}

const db = admin.firestore();

// Knockout Stage Matches (73-104)
// Round of 32: June 28 - July 2, 2026 (16 matches)
// Round of 16: July 4-6, 2026 (8 matches)
// Quarterfinals: July 9-10, 2026 (4 matches)
// Semifinals: July 13-14, 2026 (2 matches)
// Third Place: July 18, 2026 (1 match)
// Final: July 19, 2026 (1 match)

const KNOCKOUT_MATCHES = [
  // ============ ROUND OF 32 (June 28 - July 2) ============
  // June 28
  { matchNumber: 73, stage: 'roundOf32', homePlaceholder: 'Winner A', awayPlaceholder: 'Third B/C/E', date: '2026-06-28', time: '15:00', venue: 'MetLife Stadium', city: 'New York' },
  { matchNumber: 74, stage: 'roundOf32', homePlaceholder: 'Runner-up A', awayPlaceholder: 'Runner-up C', date: '2026-06-28', time: '18:00', venue: 'Estadio Azteca', city: 'Mexico City' },
  { matchNumber: 75, stage: 'roundOf32', homePlaceholder: 'Winner B', awayPlaceholder: 'Third A/D/E', date: '2026-06-28', time: '21:00', venue: 'SoFi Stadium', city: 'Los Angeles' },

  // June 29
  { matchNumber: 76, stage: 'roundOf32', homePlaceholder: 'Runner-up B', awayPlaceholder: 'Runner-up D', date: '2026-06-29', time: '15:00', venue: 'AT&T Stadium', city: 'Dallas' },
  { matchNumber: 77, stage: 'roundOf32', homePlaceholder: 'Winner C', awayPlaceholder: 'Third A/B/F', date: '2026-06-29', time: '18:00', venue: 'Hard Rock Stadium', city: 'Miami' },
  { matchNumber: 78, stage: 'roundOf32', homePlaceholder: 'Winner D', awayPlaceholder: 'Third C/E/F', date: '2026-06-29', time: '21:00', venue: 'Mercedes-Benz Stadium', city: 'Atlanta' },

  // June 30
  { matchNumber: 79, stage: 'roundOf32', homePlaceholder: 'Winner E', awayPlaceholder: 'Third B/D/F', date: '2026-06-30', time: '15:00', venue: 'NRG Stadium', city: 'Houston' },
  { matchNumber: 80, stage: 'roundOf32', homePlaceholder: 'Runner-up E', awayPlaceholder: 'Runner-up F', date: '2026-06-30', time: '18:00', venue: 'Lincoln Financial Field', city: 'Philadelphia' },
  { matchNumber: 81, stage: 'roundOf32', homePlaceholder: 'Winner F', awayPlaceholder: 'Third A/C/D', date: '2026-06-30', time: '21:00', venue: 'Levi\'s Stadium', city: 'San Francisco' },

  // July 1
  { matchNumber: 82, stage: 'roundOf32', homePlaceholder: 'Winner G', awayPlaceholder: 'Third H/I/K', date: '2026-07-01', time: '15:00', venue: 'Lumen Field', city: 'Seattle' },
  { matchNumber: 83, stage: 'roundOf32', homePlaceholder: 'Runner-up G', awayPlaceholder: 'Runner-up I', date: '2026-07-01', time: '18:00', venue: 'BC Place', city: 'Vancouver' },
  { matchNumber: 84, stage: 'roundOf32', homePlaceholder: 'Winner H', awayPlaceholder: 'Third G/J/K', date: '2026-07-01', time: '21:00', venue: 'BMO Field', city: 'Toronto' },

  // July 2
  { matchNumber: 85, stage: 'roundOf32', homePlaceholder: 'Runner-up H', awayPlaceholder: 'Runner-up J', date: '2026-07-02', time: '15:00', venue: 'Gillette Stadium', city: 'Boston' },
  { matchNumber: 86, stage: 'roundOf32', homePlaceholder: 'Winner I', awayPlaceholder: 'Third G/H/L', date: '2026-07-02', time: '18:00', venue: 'GEHA Field at Arrowhead Stadium', city: 'Kansas City' },
  { matchNumber: 87, stage: 'roundOf32', homePlaceholder: 'Winner J', awayPlaceholder: 'Third I/K/L', date: '2026-07-02', time: '18:00', venue: 'Estadio Akron', city: 'Guadalajara' },
  { matchNumber: 88, stage: 'roundOf32', homePlaceholder: 'Winner K', awayPlaceholder: 'Runner-up L', date: '2026-07-02', time: '21:00', venue: 'Estadio BBVA', city: 'Monterrey' },

  // ============ ROUND OF 16 (July 4-6) ============
  // July 4
  { matchNumber: 89, stage: 'roundOf16', homePlaceholder: 'Winner Match 73', awayPlaceholder: 'Winner Match 76', date: '2026-07-04', time: '18:00', venue: 'MetLife Stadium', city: 'New York' },
  { matchNumber: 90, stage: 'roundOf16', homePlaceholder: 'Winner Match 74', awayPlaceholder: 'Winner Match 75', date: '2026-07-04', time: '21:00', venue: 'AT&T Stadium', city: 'Dallas' },

  // July 5
  { matchNumber: 91, stage: 'roundOf16', homePlaceholder: 'Winner Match 77', awayPlaceholder: 'Winner Match 80', date: '2026-07-05', time: '18:00', venue: 'SoFi Stadium', city: 'Los Angeles' },
  { matchNumber: 92, stage: 'roundOf16', homePlaceholder: 'Winner Match 78', awayPlaceholder: 'Winner Match 79', date: '2026-07-05', time: '21:00', venue: 'Hard Rock Stadium', city: 'Miami' },

  // July 6
  { matchNumber: 93, stage: 'roundOf16', homePlaceholder: 'Winner Match 81', awayPlaceholder: 'Winner Match 84', date: '2026-07-06', time: '15:00', venue: 'Mercedes-Benz Stadium', city: 'Atlanta' },
  { matchNumber: 94, stage: 'roundOf16', homePlaceholder: 'Winner Match 82', awayPlaceholder: 'Winner Match 85', date: '2026-07-06', time: '18:00', venue: 'NRG Stadium', city: 'Houston' },
  { matchNumber: 95, stage: 'roundOf16', homePlaceholder: 'Winner Match 83', awayPlaceholder: 'Winner Match 86', date: '2026-07-06', time: '18:00', venue: 'Lumen Field', city: 'Seattle' },
  { matchNumber: 96, stage: 'roundOf16', homePlaceholder: 'Winner Match 87', awayPlaceholder: 'Winner Match 88', date: '2026-07-06', time: '21:00', venue: 'Lincoln Financial Field', city: 'Philadelphia' },

  // ============ QUARTERFINALS (July 9-10) ============
  // July 9
  { matchNumber: 97, stage: 'quarterFinal', homePlaceholder: 'Winner Match 89', awayPlaceholder: 'Winner Match 91', date: '2026-07-09', time: '18:00', venue: 'SoFi Stadium', city: 'Los Angeles' },
  { matchNumber: 98, stage: 'quarterFinal', homePlaceholder: 'Winner Match 90', awayPlaceholder: 'Winner Match 92', date: '2026-07-09', time: '21:00', venue: 'AT&T Stadium', city: 'Dallas' },

  // July 10
  { matchNumber: 99, stage: 'quarterFinal', homePlaceholder: 'Winner Match 93', awayPlaceholder: 'Winner Match 95', date: '2026-07-10', time: '18:00', venue: 'Hard Rock Stadium', city: 'Miami' },
  { matchNumber: 100, stage: 'quarterFinal', homePlaceholder: 'Winner Match 94', awayPlaceholder: 'Winner Match 96', date: '2026-07-10', time: '21:00', venue: 'MetLife Stadium', city: 'New York' },

  // ============ SEMIFINALS (July 13-14) ============
  // July 13
  { matchNumber: 101, stage: 'semiFinal', homePlaceholder: 'Winner Match 97', awayPlaceholder: 'Winner Match 98', date: '2026-07-13', time: '21:00', venue: 'AT&T Stadium', city: 'Dallas' },

  // July 14
  { matchNumber: 102, stage: 'semiFinal', homePlaceholder: 'Winner Match 99', awayPlaceholder: 'Winner Match 100', date: '2026-07-14', time: '21:00', venue: 'Mercedes-Benz Stadium', city: 'Atlanta' },

  // ============ THIRD PLACE PLAYOFF (July 18) ============
  { matchNumber: 103, stage: 'thirdPlace', homePlaceholder: 'Loser Match 101', awayPlaceholder: 'Loser Match 102', date: '2026-07-18', time: '18:00', venue: 'Hard Rock Stadium', city: 'Miami' },

  // ============ FINAL (July 19) ============
  { matchNumber: 104, stage: 'final', homePlaceholder: 'Winner Match 101', awayPlaceholder: 'Winner Match 102', date: '2026-07-19', time: '19:00', venue: 'MetLife Stadium', city: 'New York' },
];

async function seedKnockoutMatches() {
  console.log('========================================');
  console.log('Seeding World Cup 2026 Knockout Matches');
  console.log('========================================');
  console.log(`Mode: ${DRY_RUN ? 'DRY RUN' : 'LIVE'}`);
  console.log(`Matches to seed: ${KNOCKOUT_MATCHES.length}`);
  console.log('');

  let successCount = 0;

  for (const match of KNOCKOUT_MATCHES) {
    const matchData = {
      matchId: `wc2026_${match.matchNumber}`,
      matchNumber: match.matchNumber,
      stage: match.stage,
      group: null,
      homeTeamCode: null,
      homeTeamName: null,
      homeTeamFlagUrl: null,
      homeTeamPlaceholder: match.homePlaceholder,
      awayTeamCode: null,
      awayTeamName: null,
      awayTeamFlagUrl: null,
      awayTeamPlaceholder: match.awayPlaceholder,
      status: 'scheduled',
      homeScore: null,
      awayScore: null,
      dateTime: new Date(`${match.date}T${match.time}:00`).toISOString(),
      dateTimeUtc: new Date(`${match.date}T${match.time}:00Z`).toISOString(),
      venueName: match.venue,
      venueCity: match.city,
    };

    const stageName = match.stage === 'roundOf32' ? 'R32' :
                     match.stage === 'roundOf16' ? 'R16' :
                     match.stage === 'quarterFinal' ? 'QF' :
                     match.stage === 'semiFinal' ? 'SF' :
                     match.stage === 'thirdPlace' ? '3rd' : 'FINAL';

    if (DRY_RUN) {
      console.log(`[DRY RUN] Match ${match.matchNumber} (${stageName}): ${match.homePlaceholder} vs ${match.awayPlaceholder} (${match.date})`);
    } else {
      await db.collection('worldcup_matches').doc(matchData.matchId).set(matchData, { merge: true });
      console.log(`✅ Match ${match.matchNumber} (${stageName}): ${match.homePlaceholder} vs ${match.awayPlaceholder}`);
    }
    successCount++;
  }

  console.log('');
  console.log('========================================');
  console.log(`Total: ${successCount} knockout matches ${DRY_RUN ? 'would be' : ''} seeded`);
  console.log('Stages:');
  console.log('  - Round of 32: Matches 73-88 (June 28 - July 2)');
  console.log('  - Round of 16: Matches 89-96 (July 4-6)');
  console.log('  - Quarterfinals: Matches 97-100 (July 9-10)');
  console.log('  - Semifinals: Matches 101-102 (July 13-14)');
  console.log('  - Third Place: Match 103 (July 18)');
  console.log('  - Final: Match 104 (July 19)');
  console.log('========================================');
}

seedKnockoutMatches()
  .then(() => process.exit(0))
  .catch((e) => {
    console.error('Error:', e);
    process.exit(1);
  });

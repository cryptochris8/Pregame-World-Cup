/**
 * Seed ALL June 2026 World Cup Group Stage Matches
 *
 * Based on the official FIFA/MLS schedule
 *
 * Usage:
 *   npx ts-node src/seed-june2026-matches.ts [--dryRun]
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

// Team data for flag URLs and names
const TEAMS: Record<string, { name: string; flagUrl: string }> = {
  'ALG': { name: 'Algeria', flagUrl: 'https://flagcdn.com/w80/dz.png' },
  'ARG': { name: 'Argentina', flagUrl: 'https://flagcdn.com/w80/ar.png' },
  'AUS': { name: 'Australia', flagUrl: 'https://flagcdn.com/w80/au.png' },
  'AUT': { name: 'Austria', flagUrl: 'https://flagcdn.com/w80/at.png' },
  'BEL': { name: 'Belgium', flagUrl: 'https://flagcdn.com/w80/be.png' },
  'BRA': { name: 'Brazil', flagUrl: 'https://flagcdn.com/w80/br.png' },
  'CAN': { name: 'Canada', flagUrl: 'https://flagcdn.com/w80/ca.png' },
  'CIV': { name: 'Ivory Coast', flagUrl: 'https://flagcdn.com/w80/ci.png' },
  'COL': { name: 'Colombia', flagUrl: 'https://flagcdn.com/w80/co.png' },
  'CPV': { name: 'Cape Verde', flagUrl: 'https://flagcdn.com/w80/cv.png' },
  'CRO': { name: 'Croatia', flagUrl: 'https://flagcdn.com/w80/hr.png' },
  'CUR': { name: 'Curaçao', flagUrl: 'https://flagcdn.com/w80/cw.png' },
  'ECU': { name: 'Ecuador', flagUrl: 'https://flagcdn.com/w80/ec.png' },
  'EGY': { name: 'Egypt', flagUrl: 'https://flagcdn.com/w80/eg.png' },
  'ENG': { name: 'England', flagUrl: 'https://flagcdn.com/w80/gb-eng.png' },
  'ESP': { name: 'Spain', flagUrl: 'https://flagcdn.com/w80/es.png' },
  'FRA': { name: 'France', flagUrl: 'https://flagcdn.com/w80/fr.png' },
  'GER': { name: 'Germany', flagUrl: 'https://flagcdn.com/w80/de.png' },
  'GHA': { name: 'Ghana', flagUrl: 'https://flagcdn.com/w80/gh.png' },
  'HAI': { name: 'Haiti', flagUrl: 'https://flagcdn.com/w80/ht.png' },
  'IRN': { name: 'Iran', flagUrl: 'https://flagcdn.com/w80/ir.png' },
  'JOR': { name: 'Jordan', flagUrl: 'https://flagcdn.com/w80/jo.png' },
  'JPN': { name: 'Japan', flagUrl: 'https://flagcdn.com/w80/jp.png' },
  'KOR': { name: 'South Korea', flagUrl: 'https://flagcdn.com/w80/kr.png' },
  'MAR': { name: 'Morocco', flagUrl: 'https://flagcdn.com/w80/ma.png' },
  'MEX': { name: 'Mexico', flagUrl: 'https://flagcdn.com/w80/mx.png' },
  'NED': { name: 'Netherlands', flagUrl: 'https://flagcdn.com/w80/nl.png' },
  'NOR': { name: 'Norway', flagUrl: 'https://flagcdn.com/w80/no.png' },
  'NZL': { name: 'New Zealand', flagUrl: 'https://flagcdn.com/w80/nz.png' },
  'PAN': { name: 'Panama', flagUrl: 'https://flagcdn.com/w80/pa.png' },
  'PAR': { name: 'Paraguay', flagUrl: 'https://flagcdn.com/w80/py.png' },
  'POR': { name: 'Portugal', flagUrl: 'https://flagcdn.com/w80/pt.png' },
  'QAT': { name: 'Qatar', flagUrl: 'https://flagcdn.com/w80/qa.png' },
  'RSA': { name: 'South Africa', flagUrl: 'https://flagcdn.com/w80/za.png' },
  'SAU': { name: 'Saudi Arabia', flagUrl: 'https://flagcdn.com/w80/sa.png' },
  'SCO': { name: 'Scotland', flagUrl: 'https://flagcdn.com/w80/gb-sct.png' },
  'SEN': { name: 'Senegal', flagUrl: 'https://flagcdn.com/w80/sn.png' },
  'SUI': { name: 'Switzerland', flagUrl: 'https://flagcdn.com/w80/ch.png' },
  'TUN': { name: 'Tunisia', flagUrl: 'https://flagcdn.com/w80/tn.png' },
  'URU': { name: 'Uruguay', flagUrl: 'https://flagcdn.com/w80/uy.png' },
  'USA': { name: 'United States', flagUrl: 'https://flagcdn.com/w80/us.png' },
  'UZB': { name: 'Uzbekistan', flagUrl: 'https://flagcdn.com/w80/uz.png' },
  'TBD': { name: 'TBD', flagUrl: '' },
};

// Complete June 2026 Schedule
const JUNE_2026_MATCHES = [
  // June 11
  { matchNumber: 1, homeTeam: 'MEX', awayTeam: 'RSA', date: '2026-06-11', time: '15:00', venue: 'Estadio Azteca', city: 'Mexico City', group: 'A' },
  { matchNumber: 2, homeTeam: 'KOR', awayTeam: 'TBD', date: '2026-06-11', time: '22:00', venue: 'Estadio Akron', city: 'Guadalajara', group: 'A' },

  // June 12
  { matchNumber: 3, homeTeam: 'USA', awayTeam: 'PAR', date: '2026-06-12', time: '21:00', venue: 'SoFi Stadium', city: 'Los Angeles', group: 'D' },
  { matchNumber: 4, homeTeam: 'CAN', awayTeam: 'TBD', date: '2026-06-12', time: '15:00', venue: 'BMO Field', city: 'Toronto', group: 'B' },

  // June 13
  { matchNumber: 5, homeTeam: 'HAI', awayTeam: 'SCO', date: '2026-06-13', time: '15:00', venue: 'Gillette Stadium', city: 'Boston', group: 'C' },
  { matchNumber: 6, homeTeam: 'BRA', awayTeam: 'MAR', date: '2026-06-13', time: '18:00', venue: 'MetLife Stadium', city: 'New York', group: 'C' },
  { matchNumber: 7, homeTeam: 'AUS', awayTeam: 'TBD', date: '2026-06-13', time: '18:00', venue: 'BC Place', city: 'Vancouver', group: 'D' },
  { matchNumber: 8, homeTeam: 'QAT', awayTeam: 'SUI', date: '2026-06-13', time: '21:00', venue: 'Levi\'s Stadium', city: 'San Francisco', group: 'B' },

  // June 14
  { matchNumber: 9, homeTeam: 'NED', awayTeam: 'JPN', date: '2026-06-14', time: '15:00', venue: 'AT&T Stadium', city: 'Dallas', group: 'E' },
  { matchNumber: 10, homeTeam: 'GER', awayTeam: 'CUR', date: '2026-06-14', time: '18:00', venue: 'NRG Stadium', city: 'Houston', group: 'F' },
  { matchNumber: 11, homeTeam: 'CIV', awayTeam: 'ECU', date: '2026-06-14', time: '18:00', venue: 'Lincoln Financial Field', city: 'Philadelphia', group: 'F' },
  { matchNumber: 12, homeTeam: 'TBD', awayTeam: 'TUN', date: '2026-06-14', time: '21:00', venue: 'Estadio BBVA', city: 'Monterrey', group: 'E' },

  // June 15
  { matchNumber: 13, homeTeam: 'ESP', awayTeam: 'CPV', date: '2026-06-15', time: '15:00', venue: 'Mercedes-Benz Stadium', city: 'Atlanta', group: 'G' },
  { matchNumber: 14, homeTeam: 'IRN', awayTeam: 'NZL', date: '2026-06-15', time: '18:00', venue: 'SoFi Stadium', city: 'Los Angeles', group: 'H' },
  { matchNumber: 15, homeTeam: 'BEL', awayTeam: 'EGY', date: '2026-06-15', time: '18:00', venue: 'Lumen Field', city: 'Seattle', group: 'H' },
  { matchNumber: 16, homeTeam: 'SAU', awayTeam: 'URU', date: '2026-06-15', time: '21:00', venue: 'Hard Rock Stadium', city: 'Miami', group: 'G' },

  // June 16
  { matchNumber: 17, homeTeam: 'TBD', awayTeam: 'RSA', date: '2026-06-16', time: '12:00', venue: 'Mercedes-Benz Stadium', city: 'Atlanta', group: 'A' },
  { matchNumber: 18, homeTeam: 'TBD', awayTeam: 'NOR', date: '2026-06-16', time: '15:00', venue: 'Gillette Stadium', city: 'Boston', group: 'I' },
  { matchNumber: 19, homeTeam: 'ARG', awayTeam: 'ALG', date: '2026-06-16', time: '18:00', venue: 'GEHA Field at Arrowhead Stadium', city: 'Kansas City', group: 'J' },
  { matchNumber: 20, homeTeam: 'FRA', awayTeam: 'SEN', date: '2026-06-16', time: '18:00', venue: 'MetLife Stadium', city: 'New York', group: 'I' },
  { matchNumber: 21, homeTeam: 'AUT', awayTeam: 'JOR', date: '2026-06-16', time: '21:00', venue: 'Levi\'s Stadium', city: 'San Francisco', group: 'J' },

  // June 17
  { matchNumber: 22, homeTeam: 'ENG', awayTeam: 'CRO', date: '2026-06-17', time: '16:00', venue: 'AT&T Stadium', city: 'Dallas', group: 'L' },
  { matchNumber: 23, homeTeam: 'POR', awayTeam: 'TBD', date: '2026-06-17', time: '18:00', venue: 'NRG Stadium', city: 'Houston', group: 'K' },
  { matchNumber: 24, homeTeam: 'UZB', awayTeam: 'COL', date: '2026-06-17', time: '22:00', venue: 'Estadio Azteca', city: 'Mexico City', group: 'K' },
  { matchNumber: 25, homeTeam: 'GHA', awayTeam: 'PAN', date: '2026-06-17', time: '19:00', venue: 'BMO Field', city: 'Toronto', group: 'L' },

  // June 18
  { matchNumber: 26, homeTeam: 'MEX', awayTeam: 'KOR', date: '2026-06-18', time: '18:00', venue: 'Estadio Akron', city: 'Guadalajara', group: 'A' },
  { matchNumber: 27, homeTeam: 'SUI', awayTeam: 'TBD', date: '2026-06-18', time: '18:00', venue: 'SoFi Stadium', city: 'Los Angeles', group: 'B' },
  { matchNumber: 28, homeTeam: 'CAN', awayTeam: 'QAT', date: '2026-06-18', time: '21:00', venue: 'BC Place', city: 'Vancouver', group: 'B' },

  // June 19
  { matchNumber: 29, homeTeam: 'SCO', awayTeam: 'MAR', date: '2026-06-19', time: '15:00', venue: 'Gillette Stadium', city: 'Boston', group: 'C' },
  { matchNumber: 30, homeTeam: 'BRA', awayTeam: 'HAI', date: '2026-06-19', time: '18:00', venue: 'Lincoln Financial Field', city: 'Philadelphia', group: 'C' },
  { matchNumber: 31, homeTeam: 'USA', awayTeam: 'AUS', date: '2026-06-19', time: '18:00', venue: 'Lumen Field', city: 'Seattle', group: 'D' },
  { matchNumber: 32, homeTeam: 'TBD', awayTeam: 'PAR', date: '2026-06-19', time: '21:00', venue: 'Levi\'s Stadium', city: 'San Francisco', group: 'D' },

  // June 20
  { matchNumber: 33, homeTeam: 'NED', awayTeam: 'TBD', date: '2026-06-20', time: '15:00', venue: 'NRG Stadium', city: 'Houston', group: 'E' },
  { matchNumber: 34, homeTeam: 'ECU', awayTeam: 'CUR', date: '2026-06-20', time: '18:00', venue: 'GEHA Field at Arrowhead Stadium', city: 'Kansas City', group: 'F' },
  { matchNumber: 35, homeTeam: 'GER', awayTeam: 'CIV', date: '2026-06-20', time: '18:00', venue: 'BMO Field', city: 'Toronto', group: 'F' },
  { matchNumber: 36, homeTeam: 'TUN', awayTeam: 'JPN', date: '2026-06-20', time: '21:00', venue: 'Estadio BBVA', city: 'Monterrey', group: 'E' },

  // June 21
  { matchNumber: 37, homeTeam: 'ESP', awayTeam: 'SAU', date: '2026-06-21', time: '15:00', venue: 'Mercedes-Benz Stadium', city: 'Atlanta', group: 'G' },
  { matchNumber: 38, homeTeam: 'BEL', awayTeam: 'IRN', date: '2026-06-21', time: '18:00', venue: 'SoFi Stadium', city: 'Los Angeles', group: 'H' },
  { matchNumber: 39, homeTeam: 'NZL', awayTeam: 'EGY', date: '2026-06-21', time: '18:00', venue: 'BC Place', city: 'Vancouver', group: 'H' },
  { matchNumber: 40, homeTeam: 'URU', awayTeam: 'CPV', date: '2026-06-21', time: '21:00', venue: 'Hard Rock Stadium', city: 'Miami', group: 'G' },

  // June 22
  { matchNumber: 41, homeTeam: 'ARG', awayTeam: 'AUT', date: '2026-06-22', time: '13:00', venue: 'AT&T Stadium', city: 'Dallas', group: 'J' },
  { matchNumber: 42, homeTeam: 'FRA', awayTeam: 'TBD', date: '2026-06-22', time: '17:00', venue: 'Lincoln Financial Field', city: 'Philadelphia', group: 'I' },
  { matchNumber: 43, homeTeam: 'JOR', awayTeam: 'ALG', date: '2026-06-22', time: '23:00', venue: 'Levi\'s Stadium', city: 'San Francisco', group: 'J' },
  { matchNumber: 44, homeTeam: 'NOR', awayTeam: 'SEN', date: '2026-06-22', time: '20:00', venue: 'MetLife Stadium', city: 'New York', group: 'I' },

  // June 23
  { matchNumber: 45, homeTeam: 'COL', awayTeam: 'TBD', date: '2026-06-23', time: '15:00', venue: 'Estadio Akron', city: 'Guadalajara', group: 'K' },
  { matchNumber: 46, homeTeam: 'POR', awayTeam: 'UZB', date: '2026-06-23', time: '13:00', venue: 'NRG Stadium', city: 'Houston', group: 'K' },
  { matchNumber: 47, homeTeam: 'PAN', awayTeam: 'CRO', date: '2026-06-23', time: '19:00', venue: 'BMO Field', city: 'Toronto', group: 'L' },
  { matchNumber: 48, homeTeam: 'ENG', awayTeam: 'GHA', date: '2026-06-23', time: '16:00', venue: 'Gillette Stadium', city: 'Boston', group: 'L' },

  // June 24
  { matchNumber: 49, homeTeam: 'MAR', awayTeam: 'HAI', date: '2026-06-24', time: '18:00', venue: 'Mercedes-Benz Stadium', city: 'Atlanta', group: 'C' },
  { matchNumber: 50, homeTeam: 'RSA', awayTeam: 'KOR', date: '2026-06-24', time: '18:00', venue: 'Estadio BBVA', city: 'Monterrey', group: 'A' },
  { matchNumber: 51, homeTeam: 'SCO', awayTeam: 'BRA', date: '2026-06-24', time: '18:00', venue: 'Hard Rock Stadium', city: 'Miami', group: 'C' },
  { matchNumber: 52, homeTeam: 'TBD', awayTeam: 'QAT', date: '2026-06-24', time: '18:00', venue: 'Lumen Field', city: 'Seattle', group: 'B' },
  { matchNumber: 53, homeTeam: 'SUI', awayTeam: 'CAN', date: '2026-06-24', time: '18:00', venue: 'BC Place', city: 'Vancouver', group: 'B' },
  { matchNumber: 54, homeTeam: 'TBD', awayTeam: 'MEX', date: '2026-06-24', time: '21:00', venue: 'Estadio Azteca', city: 'Mexico City', group: 'A' },

  // June 25
  { matchNumber: 55, homeTeam: 'TBD', awayTeam: 'USA', date: '2026-06-25', time: '21:00', venue: 'SoFi Stadium', city: 'Los Angeles', group: 'D' },
  { matchNumber: 56, homeTeam: 'JPN', awayTeam: 'TBD', date: '2026-06-25', time: '18:00', venue: 'AT&T Stadium', city: 'Dallas', group: 'E' },
  { matchNumber: 57, homeTeam: 'TUN', awayTeam: 'NED', date: '2026-06-25', time: '18:00', venue: 'GEHA Field at Arrowhead Stadium', city: 'Kansas City', group: 'E' },
  { matchNumber: 58, homeTeam: 'ECU', awayTeam: 'GER', date: '2026-06-25', time: '18:00', venue: 'MetLife Stadium', city: 'New York', group: 'F' },
  { matchNumber: 59, homeTeam: 'CUR', awayTeam: 'CIV', date: '2026-06-25', time: '18:00', venue: 'Lincoln Financial Field', city: 'Philadelphia', group: 'F' },
  { matchNumber: 60, homeTeam: 'PAR', awayTeam: 'AUS', date: '2026-06-25', time: '21:00', venue: 'Levi\'s Stadium', city: 'San Francisco', group: 'D' },

  // June 26
  { matchNumber: 61, homeTeam: 'URU', awayTeam: 'ESP', date: '2026-06-26', time: '18:00', venue: 'Estadio Akron', city: 'Guadalajara', group: 'G' },
  { matchNumber: 62, homeTeam: 'CPV', awayTeam: 'SAU', date: '2026-06-26', time: '18:00', venue: 'NRG Stadium', city: 'Houston', group: 'G' },
  { matchNumber: 63, homeTeam: 'EGY', awayTeam: 'IRN', date: '2026-06-26', time: '18:00', venue: 'Lumen Field', city: 'Seattle', group: 'H' },
  { matchNumber: 64, homeTeam: 'NZL', awayTeam: 'BEL', date: '2026-06-26', time: '18:00', venue: 'BC Place', city: 'Vancouver', group: 'H' },
  { matchNumber: 65, homeTeam: 'COL', awayTeam: 'POR', date: '2026-06-26', time: '21:00', venue: 'Hard Rock Stadium', city: 'Miami', group: 'K' },
  { matchNumber: 66, homeTeam: 'SEN', awayTeam: 'TBD', date: '2026-06-26', time: '21:00', venue: 'BMO Field', city: 'Toronto', group: 'I' },

  // June 27
  { matchNumber: 67, homeTeam: 'TBD', awayTeam: 'UZB', date: '2026-06-27', time: '18:00', venue: 'Mercedes-Benz Stadium', city: 'Atlanta', group: 'K' },
  { matchNumber: 68, homeTeam: 'NOR', awayTeam: 'FRA', date: '2026-06-27', time: '18:00', venue: 'Gillette Stadium', city: 'Boston', group: 'I' },
  { matchNumber: 69, homeTeam: 'JOR', awayTeam: 'ARG', date: '2026-06-27', time: '18:00', venue: 'AT&T Stadium', city: 'Dallas', group: 'J' },
  { matchNumber: 70, homeTeam: 'ALG', awayTeam: 'AUT', date: '2026-06-27', time: '18:00', venue: 'GEHA Field at Arrowhead Stadium', city: 'Kansas City', group: 'J' },
  { matchNumber: 71, homeTeam: 'CRO', awayTeam: 'GHA', date: '2026-06-27', time: '18:00', venue: 'Lincoln Financial Field', city: 'Philadelphia', group: 'L' },
  { matchNumber: 72, homeTeam: 'PAN', awayTeam: 'ENG', date: '2026-06-27', time: '18:00', venue: 'MetLife Stadium', city: 'New York', group: 'L' },
];

async function seedMatches() {
  console.log('========================================');
  console.log('Seeding June 2026 World Cup Matches');
  console.log('========================================');
  console.log(`Mode: ${DRY_RUN ? 'DRY RUN' : 'LIVE'}`);
  console.log(`Matches to seed: ${JUNE_2026_MATCHES.length}`);
  console.log('');

  // First, delete existing matches
  if (!DRY_RUN) {
    const existing = await db.collection('worldcup_matches').get();
    if (existing.size > 0) {
      console.log(`Deleting ${existing.size} existing matches...`);
      const batch = db.batch();
      existing.docs.forEach(doc => batch.delete(doc.ref));
      await batch.commit();
      console.log('Deleted existing matches.\n');
    }
  }

  let successCount = 0;

  for (const match of JUNE_2026_MATCHES) {
    const homeTeam = TEAMS[match.homeTeam] || { name: match.homeTeam, flagUrl: '' };
    const awayTeam = TEAMS[match.awayTeam] || { name: match.awayTeam, flagUrl: '' };

    const matchData = {
      matchId: `wc2026_${match.matchNumber}`,
      matchNumber: match.matchNumber,
      stage: 'groupStage',
      group: match.group,
      groupMatchDay: Math.ceil(match.matchNumber / 24),
      homeTeamCode: match.homeTeam,
      homeTeamName: homeTeam.name,
      homeTeamFlagUrl: homeTeam.flagUrl,
      awayTeamCode: match.awayTeam,
      awayTeamName: awayTeam.name,
      awayTeamFlagUrl: awayTeam.flagUrl,
      status: 'scheduled',
      homeScore: null,
      awayScore: null,
      dateTime: new Date(`${match.date}T${match.time}:00`).toISOString(),
      dateTimeUtc: new Date(`${match.date}T${match.time}:00Z`).toISOString(),
      venueName: match.venue,
      venueCity: match.city,
    };

    if (DRY_RUN) {
      console.log(`[DRY RUN] Match ${match.matchNumber}: ${homeTeam.name} vs ${awayTeam.name} (${match.date})`);
    } else {
      await db.collection('worldcup_matches').doc(matchData.matchId).set(matchData);
      console.log(`✅ Match ${match.matchNumber}: ${homeTeam.name} vs ${awayTeam.name}`);
    }
    successCount++;
  }

  console.log('');
  console.log('========================================');
  console.log(`Total: ${successCount} matches ${DRY_RUN ? 'would be' : ''} seeded`);
  console.log('========================================');
}

seedMatches()
  .then(() => process.exit(0))
  .catch((e) => {
    console.error('Error:', e);
    process.exit(1);
  });

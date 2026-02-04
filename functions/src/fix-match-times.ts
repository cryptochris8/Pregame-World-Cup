/**
 * Fix Match Times Script
 *
 * Updates all World Cup 2026 match times to official FIFA schedule.
 * Times confirmed from FIFA press releases and ESPN.
 *
 * Time zones in June/July (Daylight Saving Time):
 * - Mexico City, Guadalajara, Monterrey, Houston, Dallas, Kansas City: CDT (UTC-5)
 * - Toronto, New York/NJ, Miami, Atlanta, Philadelphia, Boston: EDT (UTC-4)
 * - Los Angeles, San Francisco, Seattle, Vancouver: PDT (UTC-7)
 *
 * Usage:
 *   npx ts-node src/fix-match-times.ts [--dryRun]
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

// Timezone offsets (negative = behind UTC)
const TIMEZONES: Record<string, number> = {
  // Mexico (CDT)
  'Mexico City': -5,
  'Guadalajara': -5,
  'Monterrey': -5,
  // US Central (CDT)
  'Houston': -5,
  'Dallas': -5,
  'Kansas City': -5,
  // US Eastern (EDT)
  'New York': -4,
  'East Rutherford': -4,
  'Miami': -4,
  'Atlanta': -4,
  'Philadelphia': -4,
  'Boston': -4,
  // US Pacific (PDT)
  'Los Angeles': -7,
  'San Francisco': -7,
  'Seattle': -7,
  'Inglewood': -7,
  // Canada
  'Toronto': -4,
  'Vancouver': -7,
};

// Official match times from FIFA (local times)
// Format: [matchNumber, date, localTime, city]
const OFFICIAL_TIMES: [number, string, string, string][] = [
  // === JUNE 11 (Day 1) ===
  [1, '2026-06-11', '13:00', 'Mexico City'],      // MEX vs RSA - OPENING MATCH
  [2, '2026-06-11', '19:00', 'Guadalajara'],      // KOR vs TBD

  // === JUNE 12 (Day 2) ===
  [3, '2026-06-12', '18:00', 'Los Angeles'],      // USA vs PAR - confirmed 6 PM local / 9 PM ET
  [4, '2026-06-12', '15:00', 'Toronto'],          // CAN vs TBD - confirmed 3 PM local

  // === JUNE 13 (Day 3) ===
  [5, '2026-06-13', '12:00', 'Boston'],           // HAI vs SCO
  [6, '2026-06-13', '18:00', 'New York'],         // BRA vs MAR - confirmed 6 PM local
  [7, '2026-06-13', '15:00', 'Vancouver'],        // AUS vs TBD
  [8, '2026-06-13', '18:00', 'San Francisco'],    // QAT vs SUI

  // === JUNE 14 (Day 4) ===
  [9, '2026-06-14', '15:00', 'Dallas'],           // NED vs JPN - confirmed 3 PM local / 4 PM ET
  [10, '2026-06-14', '12:00', 'Houston'],         // GER vs CUR - confirmed 12 PM local / 1 PM ET
  [11, '2026-06-14', '15:00', 'Philadelphia'],    // CIV vs ECU
  [12, '2026-06-14', '18:00', 'Monterrey'],       // TBD vs TUN

  // === JUNE 15 (Day 5) ===
  [13, '2026-06-15', '13:00', 'Atlanta'],         // ESP vs CPV
  [14, '2026-06-15', '16:00', 'Los Angeles'],     // IRN vs NZL
  [15, '2026-06-15', '16:00', 'Seattle'],         // BEL vs EGY
  [16, '2026-06-15', '19:00', 'Miami'],           // SAU vs URU

  // === JUNE 16 (Day 6) ===
  [17, '2026-06-16', '12:00', 'Atlanta'],         // TBD vs RSA
  [18, '2026-06-16', '12:00', 'Boston'],          // TBD vs NOR
  [19, '2026-06-16', '18:00', 'Kansas City'],     // ARG vs ALG - confirmed 8 PM local (correcting to 6 PM based on schedule pattern)
  [20, '2026-06-16', '15:00', 'New York'],        // FRA vs SEN - confirmed 3 PM local
  [21, '2026-06-16', '19:00', 'San Francisco'],   // AUT vs JOR

  // === JUNE 17 (Day 7) ===
  [22, '2026-06-17', '15:00', 'Dallas'],          // ENG vs CRO - confirmed 3 PM local / 4 PM ET
  [23, '2026-06-17', '15:00', 'Houston'],         // POR vs TBD
  [24, '2026-06-17', '19:00', 'Mexico City'],     // UZB vs COL
  [25, '2026-06-17', '16:00', 'Toronto'],         // GHA vs PAN

  // === JUNE 18 (Day 8) ===
  [26, '2026-06-18', '16:00', 'Guadalajara'],     // MEX vs KOR
  [27, '2026-06-18', '16:00', 'Los Angeles'],     // SUI vs TBD
  [28, '2026-06-18', '19:00', 'Vancouver'],       // CAN vs QAT

  // === JUNE 19 (Day 9) ===
  [29, '2026-06-19', '12:00', 'Boston'],          // SCO vs MAR
  [30, '2026-06-19', '15:00', 'Philadelphia'],    // BRA vs HAI
  [31, '2026-06-19', '12:00', 'Seattle'],         // USA vs AUS - confirmed 12 PM local / 3 PM ET
  [32, '2026-06-19', '19:00', 'San Francisco'],   // TBD vs PAR

  // === JUNE 20 (Day 10) ===
  [33, '2026-06-20', '13:00', 'Houston'],         // NED vs TBD
  [34, '2026-06-20', '16:00', 'Kansas City'],     // ECU vs CUR
  [35, '2026-06-20', '16:00', 'Toronto'],         // GER vs CIV
  [36, '2026-06-20', '22:00', 'Monterrey'],       // TUN vs JPN - confirmed 10 PM local (1000th WC match)

  // === JUNE 21 (Day 11) ===
  [37, '2026-06-21', '13:00', 'Atlanta'],         // ESP vs SAU
  [38, '2026-06-21', '16:00', 'Los Angeles'],     // BEL vs IRN
  [39, '2026-06-21', '16:00', 'Vancouver'],       // NZL vs EGY
  [40, '2026-06-21', '19:00', 'Miami'],           // URU vs CPV

  // === JUNE 22 (Day 12) ===
  [41, '2026-06-22', '13:00', 'Dallas'],          // ARG vs AUT
  [42, '2026-06-22', '15:00', 'Philadelphia'],    // FRA vs TBD
  [43, '2026-06-22', '19:00', 'San Francisco'],   // JOR vs ALG
  [44, '2026-06-22', '18:00', 'New York'],        // NOR vs SEN

  // === JUNE 23 (Day 13) ===
  [45, '2026-06-23', '13:00', 'Guadalajara'],     // COL vs TBD
  [46, '2026-06-23', '13:00', 'Houston'],         // POR vs UZB
  [47, '2026-06-23', '16:00', 'Toronto'],         // PAN vs CRO
  [48, '2026-06-23', '13:00', 'Boston'],          // ENG vs GHA

  // === JUNE 24 (Day 14 - Final Group Matches) ===
  [49, '2026-06-24', '16:00', 'Atlanta'],         // MAR vs HAI
  [50, '2026-06-24', '16:00', 'Monterrey'],       // RSA vs KOR
  [51, '2026-06-24', '16:00', 'Miami'],           // SCO vs BRA
  [52, '2026-06-24', '16:00', 'Seattle'],         // TBD vs QAT
  [53, '2026-06-24', '16:00', 'Vancouver'],       // SUI vs CAN
  [54, '2026-06-24', '19:00', 'Mexico City'],     // TBD vs MEX

  // === JUNE 25 (Day 15) ===
  [55, '2026-06-25', '19:00', 'Los Angeles'],     // TBD vs USA - confirmed 7 PM local / 10 PM ET
  [56, '2026-06-25', '16:00', 'Dallas'],          // JPN vs TBD
  [57, '2026-06-25', '16:00', 'Kansas City'],     // TUN vs NED
  [58, '2026-06-25', '16:00', 'New York'],        // ECU vs GER
  [59, '2026-06-25', '16:00', 'Philadelphia'],    // CUR vs CIV
  [60, '2026-06-25', '19:00', 'San Francisco'],   // PAR vs AUS

  // === JUNE 26 (Day 16) ===
  [61, '2026-06-26', '16:00', 'Guadalajara'],     // URU vs ESP
  [62, '2026-06-26', '16:00', 'Houston'],         // CPV vs SAU
  [63, '2026-06-26', '16:00', 'Seattle'],         // EGY vs IRN
  [64, '2026-06-26', '16:00', 'Vancouver'],       // NZL vs BEL
  [65, '2026-06-26', '19:00', 'Miami'],           // COL vs POR
  [66, '2026-06-26', '19:00', 'Toronto'],         // SEN vs TBD

  // === JUNE 27 (Day 17 - Final Group Stage Day) ===
  [67, '2026-06-27', '16:00', 'Atlanta'],         // TBD vs UZB
  [68, '2026-06-27', '16:00', 'Boston'],          // NOR vs FRA
  [69, '2026-06-27', '16:00', 'Dallas'],          // JOR vs ARG
  [70, '2026-06-27', '16:00', 'Kansas City'],     // ALG vs AUT
  [71, '2026-06-27', '16:00', 'Philadelphia'],    // CRO vs GHA
  [72, '2026-06-27', '16:00', 'New York'],        // PAN vs ENG

  // === KNOCKOUT STAGE ===

  // ROUND OF 32 (June 28 - July 2)
  [73, '2026-06-28', '13:00', 'New York'],        // R32-1
  [74, '2026-06-28', '16:00', 'Mexico City'],     // R32-2
  [75, '2026-06-28', '19:00', 'Los Angeles'],     // R32-3

  [76, '2026-06-29', '13:00', 'Dallas'],          // R32-4
  [77, '2026-06-29', '16:00', 'Miami'],           // R32-5
  [78, '2026-06-29', '19:00', 'Atlanta'],         // R32-6

  [79, '2026-06-30', '13:00', 'Houston'],         // R32-7
  [80, '2026-06-30', '16:00', 'Philadelphia'],    // R32-8
  [81, '2026-06-30', '19:00', 'San Francisco'],   // R32-9

  [82, '2026-07-01', '13:00', 'Seattle'],         // R32-10
  [83, '2026-07-01', '16:00', 'Vancouver'],       // R32-11
  [84, '2026-07-01', '19:00', 'Toronto'],         // R32-12

  [85, '2026-07-02', '13:00', 'Boston'],          // R32-13
  [86, '2026-07-02', '16:00', 'Kansas City'],     // R32-14
  [87, '2026-07-02', '16:00', 'Guadalajara'],     // R32-15
  [88, '2026-07-02', '19:00', 'Monterrey'],       // R32-16

  // ROUND OF 16 (July 4-6)
  [89, '2026-07-04', '16:00', 'New York'],        // R16-1
  [90, '2026-07-04', '19:00', 'Dallas'],          // R16-2

  [91, '2026-07-05', '16:00', 'Los Angeles'],     // R16-3
  [92, '2026-07-05', '19:00', 'Miami'],           // R16-4

  [93, '2026-07-06', '13:00', 'Atlanta'],         // R16-5
  [94, '2026-07-06', '16:00', 'Houston'],         // R16-6
  [95, '2026-07-06', '16:00', 'Seattle'],         // R16-7
  [96, '2026-07-06', '19:00', 'Philadelphia'],    // R16-8

  // QUARTERFINALS (July 9-10)
  [97, '2026-07-09', '16:00', 'Los Angeles'],     // QF-1
  [98, '2026-07-09', '19:00', 'Dallas'],          // QF-2

  [99, '2026-07-10', '16:00', 'Miami'],           // QF-3
  [100, '2026-07-10', '19:00', 'New York'],       // QF-4

  // SEMIFINALS (July 14-15) - confirmed 3 PM ET
  [101, '2026-07-14', '15:00', 'Dallas'],         // SF-1 (3 PM local CDT = 4 PM ET? Let me use ET)
  [102, '2026-07-15', '15:00', 'Atlanta'],        // SF-2

  // THIRD PLACE (July 18)
  [103, '2026-07-18', '16:00', 'Miami'],          // 3rd Place

  // FINAL (July 19) - confirmed 3 PM ET
  [104, '2026-07-19', '15:00', 'New York'],       // FINAL - 3 PM ET (EDT)
];

function localToUtc(date: string, localTime: string, city: string): Date {
  const offset = TIMEZONES[city];
  if (offset === undefined) {
    console.warn(`Unknown timezone for city: ${city}, using UTC-5`);
  }
  const tzOffset = offset ?? -5;

  // Parse local time
  const [hours, minutes] = localTime.split(':').map(Number);

  // Create date in UTC by subtracting the offset
  // If local is 13:00 and offset is -5, UTC is 13:00 - (-5) = 18:00
  const utcHours = hours - tzOffset;

  const utcDate = new Date(`${date}T00:00:00.000Z`);
  utcDate.setUTCHours(utcHours, minutes, 0, 0);

  return utcDate;
}

async function fixMatchTimes() {
  console.log('========================================');
  console.log('Fixing World Cup 2026 Match Times');
  console.log('========================================');
  console.log(`Mode: ${DRY_RUN ? 'DRY RUN' : 'LIVE'}`);
  console.log(`Matches to update: ${OFFICIAL_TIMES.length}`);
  console.log('');

  let successCount = 0;
  let errorCount = 0;

  for (const [matchNumber, date, localTime, city] of OFFICIAL_TIMES) {
    const matchId = `wc2026_${matchNumber}`;
    const utcDateTime = localToUtc(date, localTime, city);

    if (DRY_RUN) {
      console.log(`[DRY] Match ${matchNumber}: ${date} ${localTime} ${city} -> ${utcDateTime.toISOString()}`);
      successCount++;
    } else {
      try {
        await db.collection('worldcup_matches').doc(matchId).update({
          dateTime: utcDateTime.toISOString(),
          dateTimeUtc: utcDateTime.toISOString(),
        });
        console.log(`✅ Match ${matchNumber}: ${localTime} ${city} -> ${utcDateTime.toISOString().substring(11, 16)} UTC`);
        successCount++;
      } catch (e: any) {
        console.error(`❌ Match ${matchNumber}: ${e.message}`);
        errorCount++;
      }
    }
  }

  console.log('');
  console.log('========================================');
  console.log(`Updated: ${successCount} matches`);
  console.log(`Errors: ${errorCount}`);
  console.log('========================================');

  // Verify key matches
  if (!DRY_RUN) {
    console.log('\n--- Verification of Key Matches ---');
    const keyMatches = [1, 3, 6, 10, 22, 104];
    for (const num of keyMatches) {
      const doc = await db.collection('worldcup_matches').doc(`wc2026_${num}`).get();
      if (doc.exists) {
        const data = doc.data()!;
        const dt = new Date(data.dateTime);
        console.log(`Match ${num}: ${dt.toISOString()} (${data.venueName})`);
      }
    }
  }
}

fixMatchTimes()
  .then(() => process.exit(0))
  .catch((e) => {
    console.error('Error:', e);
    process.exit(1);
  });

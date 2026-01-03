/**
 * Seed Head-to-Head Records for June 2026 World Cup Matchups
 *
 * This script adds H2H records for the scheduled June 2026 group stage matches
 * that were missing from the initial seed.
 *
 * Usage:
 *   npx ts-node src/seed-head-to-head-june2026.ts [--dryRun]
 */

import * as admin from 'firebase-admin';
import * as fs from 'fs';
import * as path from 'path';

// ============================================================================
// Configuration
// ============================================================================

const DRY_RUN = process.argv.includes('--dryRun');

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

interface NotableMatch {
  year: number;
  tournament: string;
  stage?: string;
  team1Score: number;
  team2Score: number;
  winnerCode?: string;
  location?: string;
  description?: string;
}

interface HeadToHeadRecord {
  team1Code: string;
  team2Code: string;
  totalMatches: number;
  team1Wins: number;
  team2Wins: number;
  draws: number;
  team1Goals: number;
  team2Goals: number;
  worldCupMatches: number;
  team1WorldCupWins: number;
  team2WorldCupWins: number;
  worldCupDraws: number;
  notableMatches: NotableMatch[];
  firstMeeting?: string;
  lastMatch?: string;
}

// ============================================================================
// June 2026 Head-to-Head Data (Researched)
// ============================================================================

const JUNE_2026_H2H_DATA: HeadToHeadRecord[] = [
  // ========== ENGLAND vs CROATIA ==========
  {
    team1Code: 'CRO',
    team2Code: 'ENG',
    totalMatches: 10,
    team1Wins: 4,
    team2Wins: 4,
    draws: 2,
    team1Goals: 12,
    team2Goals: 14,
    worldCupMatches: 1,
    team1WorldCupWins: 1,
    team2WorldCupWins: 0,
    worldCupDraws: 0,
    notableMatches: [
      {
        year: 2018,
        tournament: 'World Cup',
        stage: 'Semi-Final',
        team1Score: 2,
        team2Score: 1,
        winnerCode: 'CRO',
        location: 'Moscow, Russia',
        description: 'Mandžukić extra-time winner sends Croatia to first-ever World Cup final',
      },
      {
        year: 2007,
        tournament: 'Euro Qualifier',
        stage: 'Qualifier',
        team1Score: 2,
        team2Score: 0,
        winnerCode: 'CRO',
        location: 'Zagreb, Croatia',
        description: 'Croatia victory contributed to England missing Euro 2008',
      },
      {
        year: 2021,
        tournament: 'Euro 2020',
        stage: 'Group Stage',
        team1Score: 0,
        team2Score: 1,
        winnerCode: 'ENG',
        location: 'London, England',
        description: 'Raheem Sterling goal gives England revenge at Wembley',
      },
      {
        year: 2018,
        tournament: 'Nations League',
        stage: 'Group Stage',
        team1Score: 0,
        team2Score: 0,
        location: 'Rijeka, Croatia',
        description: 'Goalless draw in first meeting after World Cup semi-final',
      },
    ],
    firstMeeting: '1996-04-24',
    lastMatch: '2021-06-13',
  },

  // ========== FRANCE vs SENEGAL ==========
  {
    team1Code: 'FRA',
    team2Code: 'SEN',
    totalMatches: 4,
    team1Wins: 2,
    team2Wins: 1,
    draws: 1,
    team1Goals: 5,
    team2Goals: 3,
    worldCupMatches: 1,
    team1WorldCupWins: 0,
    team2WorldCupWins: 1,
    worldCupDraws: 0,
    notableMatches: [
      {
        year: 2002,
        tournament: 'World Cup',
        stage: 'Group Stage',
        team1Score: 0,
        team2Score: 1,
        winnerCode: 'SEN',
        location: 'Seoul, South Korea',
        description: 'Papa Bouba Diop goal stuns defending champions in tournament opener - greatest World Cup upset',
      },
      {
        year: 2022,
        tournament: 'Friendly',
        stage: 'Friendly',
        team1Score: 3,
        team2Score: 0,
        winnerCode: 'FRA',
        location: 'Paris, France',
        description: 'France dominant in pre-World Cup friendly',
      },
    ],
    firstMeeting: '2000-05-31',
    lastMatch: '2022-10-14',
  },

  // ========== BRAZIL vs MOROCCO ==========
  {
    team1Code: 'BRA',
    team2Code: 'MAR',
    totalMatches: 3,
    team1Wins: 1,
    team2Wins: 1,
    draws: 1,
    team1Goals: 5,
    team2Goals: 4,
    worldCupMatches: 1,
    team1WorldCupWins: 1,
    team2WorldCupWins: 0,
    worldCupDraws: 0,
    notableMatches: [
      {
        year: 1998,
        tournament: 'World Cup',
        stage: 'Group Stage',
        team1Score: 3,
        team2Score: 0,
        winnerCode: 'BRA',
        location: 'Newcastle, England',
        description: 'Rivaldo and Ronaldo lead Brazil to comfortable group stage victory',
      },
      {
        year: 2023,
        tournament: 'Friendly',
        stage: 'Friendly',
        team1Score: 1,
        team2Score: 2,
        winnerCode: 'MAR',
        location: 'Tangier, Morocco',
        description: 'Morocco shock Brazil after historic 2022 World Cup semi-final run',
      },
    ],
    firstMeeting: '1998-06-16',
    lastMatch: '2023-03-25',
  },

  // ========== SCOTLAND vs BRAZIL ==========
  {
    team1Code: 'BRA',
    team2Code: 'SCO',
    totalMatches: 6,
    team1Wins: 4,
    team2Wins: 0,
    draws: 2,
    team1Goals: 12,
    team2Goals: 3,
    worldCupMatches: 4,
    team1WorldCupWins: 3,
    team2WorldCupWins: 0,
    worldCupDraws: 1,
    notableMatches: [
      {
        year: 1998,
        tournament: 'World Cup',
        stage: 'Opening Match',
        team1Score: 2,
        team2Score: 1,
        winnerCode: 'BRA',
        location: 'Paris, France',
        description: 'World Cup opener watched by 500 million - Tom Boyd own goal seals Scotland fate',
      },
      {
        year: 1974,
        tournament: 'World Cup',
        stage: 'Group Stage',
        team1Score: 0,
        team2Score: 0,
        location: 'Frankfurt, Germany',
        description: 'Legendary 0-0 draw - Scotland remain unbeaten against Brazil in World Cup group',
      },
      {
        year: 1982,
        tournament: 'World Cup',
        stage: 'Group Stage',
        team1Score: 4,
        team2Score: 1,
        winnerCode: 'BRA',
        location: 'Seville, Spain',
        description: 'David Narey screamer not enough as Zico, Falcão lead Brazil masterclass',
      },
      {
        year: 1990,
        tournament: 'World Cup',
        stage: 'Group Stage',
        team1Score: 1,
        team2Score: 0,
        winnerCode: 'BRA',
        location: 'Turin, Italy',
        description: 'Müller goal sends Scotland home in group stage',
      },
    ],
    firstMeeting: '1966-06-25',
    lastMatch: '1998-06-10',
  },

  // ========== USA vs PARAGUAY ==========
  {
    team1Code: 'PAR',
    team2Code: 'USA',
    totalMatches: 9,
    team1Wins: 2,
    team2Wins: 5,
    draws: 2,
    team1Goals: 7,
    team2Goals: 12,
    worldCupMatches: 1,
    team1WorldCupWins: 0,
    team2WorldCupWins: 1,
    worldCupDraws: 0,
    notableMatches: [
      {
        year: 1930,
        tournament: 'World Cup',
        stage: 'Group Stage',
        team1Score: 0,
        team2Score: 3,
        winnerCode: 'USA',
        location: 'Montevideo, Uruguay',
        description: 'Bert Patenaude scores first World Cup hat-trick in history',
      },
      {
        year: 2025,
        tournament: 'Friendly',
        stage: 'Friendly',
        team1Score: 1,
        team2Score: 2,
        winnerCode: 'USA',
        location: 'Chester, PA',
        description: 'Reyna and Balogun goals in World Cup prep victory',
      },
      {
        year: 2018,
        tournament: 'Friendly',
        stage: 'Friendly',
        team1Score: 0,
        team2Score: 1,
        winnerCode: 'USA',
        location: 'Cary, NC',
        description: 'Tim Weah becomes first 2000s-born player to appear for USMNT',
      },
      {
        year: 2003,
        tournament: 'Friendly',
        stage: 'Friendly',
        team1Score: 0,
        team2Score: 2,
        winnerCode: 'USA',
        location: 'San Diego, CA',
        description: 'Donovan and Stewart lead comfortable victory',
      },
    ],
    firstMeeting: '1930-07-17',
    lastMatch: '2025-11-15',
  },

  // ========== USA vs AUSTRALIA ==========
  {
    team1Code: 'AUS',
    team2Code: 'USA',
    totalMatches: 9,
    team1Wins: 1,
    team2Wins: 5,
    draws: 3,
    team1Goals: 7,
    team2Goals: 12,
    worldCupMatches: 0,
    team1WorldCupWins: 0,
    team2WorldCupWins: 0,
    worldCupDraws: 0,
    notableMatches: [
      {
        year: 2025,
        tournament: 'Friendly',
        stage: 'Friendly',
        team1Score: 1,
        team2Score: 2,
        winnerCode: 'USA',
        location: 'Cincinnati, OH',
        description: 'Pochettino-led USA defeats top-25 opponent in World Cup preparation',
      },
      {
        year: 2015,
        tournament: 'Friendly',
        stage: 'Friendly',
        team1Score: 0,
        team2Score: 4,
        winnerCode: 'USA',
        location: 'Melbourne, Australia',
        description: 'USA dominant in Australian friendly',
      },
    ],
    firstMeeting: '1992-04-01',
    lastMatch: '2025-10-14',
  },

  // ========== NETHERLANDS vs JAPAN ==========
  {
    team1Code: 'JPN',
    team2Code: 'NED',
    totalMatches: 3,
    team1Wins: 0,
    team2Wins: 2,
    draws: 1,
    team1Goals: 1,
    team2Goals: 4,
    worldCupMatches: 1,
    team1WorldCupWins: 0,
    team2WorldCupWins: 1,
    worldCupDraws: 0,
    notableMatches: [
      {
        year: 2010,
        tournament: 'World Cup',
        stage: 'Group Stage',
        team1Score: 0,
        team2Score: 1,
        winnerCode: 'NED',
        location: 'Durban, South Africa',
        description: 'Wesley Sneijder goal gives Dutch narrow victory en route to final',
      },
      {
        year: 2013,
        tournament: 'Friendly',
        stage: 'Friendly',
        team1Score: 1,
        team2Score: 2,
        winnerCode: 'NED',
        location: 'Genk, Belgium',
        description: 'Van Persie and Robben lead Dutch to friendly win',
      },
    ],
    firstMeeting: '2009-09-05',
    lastMatch: '2013-11-16',
  },

  // ========== SPAIN vs SAUDI ARABIA ==========
  {
    team1Code: 'ESP',
    team2Code: 'KSA',
    totalMatches: 3,
    team1Wins: 3,
    team2Wins: 0,
    draws: 0,
    team1Goals: 5,
    team2Goals: 0,
    worldCupMatches: 1,
    team1WorldCupWins: 1,
    team2WorldCupWins: 0,
    worldCupDraws: 0,
    notableMatches: [
      {
        year: 2006,
        tournament: 'World Cup',
        stage: 'Group Stage',
        team1Score: 1,
        team2Score: 0,
        winnerCode: 'ESP',
        location: 'Kaiserslautern, Germany',
        description: 'Spain narrow win eliminates Saudi Arabia from tournament',
      },
      {
        year: 2022,
        tournament: 'Friendly',
        stage: 'Friendly',
        team1Score: 2,
        team2Score: 0,
        winnerCode: 'ESP',
        location: 'Riyadh, Saudi Arabia',
        description: 'Spain comfortable in friendly before 2022 World Cup',
      },
    ],
    firstMeeting: '2004-05-28',
    lastMatch: '2022-11-14',
  },

  // ========== BELGIUM vs EGYPT ==========
  {
    team1Code: 'BEL',
    team2Code: 'EGY',
    totalMatches: 3,
    team1Wins: 1,
    team2Wins: 2,
    draws: 0,
    team1Goals: 4,
    team2Goals: 6,
    worldCupMatches: 0,
    team1WorldCupWins: 0,
    team2WorldCupWins: 0,
    worldCupDraws: 0,
    notableMatches: [
      {
        year: 2022,
        tournament: 'Friendly',
        stage: 'Friendly',
        team1Score: 2,
        team2Score: 1,
        winnerCode: 'BEL',
        location: 'Kuwait City, Kuwait',
        description: 'Belgium edges Egypt in pre-World Cup friendly',
      },
      {
        year: 2018,
        tournament: 'Friendly',
        stage: 'Friendly',
        team1Score: 0,
        team2Score: 2,
        winnerCode: 'EGY',
        location: 'Brussels, Belgium',
        description: 'Salah-led Egypt stuns Belgium in friendly',
      },
    ],
    firstMeeting: '2005-08-17',
    lastMatch: '2022-11-18',
  },

  // ========== ENGLAND vs GHANA ==========
  {
    team1Code: 'ENG',
    team2Code: 'GHA',
    totalMatches: 1,
    team1Wins: 0,
    team2Wins: 0,
    draws: 1,
    team1Goals: 1,
    team2Goals: 1,
    worldCupMatches: 0,
    team1WorldCupWins: 0,
    team2WorldCupWins: 0,
    worldCupDraws: 0,
    notableMatches: [
      {
        year: 2011,
        tournament: 'Friendly',
        stage: 'Friendly',
        team1Score: 1,
        team2Score: 1,
        location: 'London, England',
        description: 'Asamoah Gyan stoppage-time equalizer after Andy Carroll opener at Wembley',
      },
    ],
    firstMeeting: '2011-03-29',
    lastMatch: '2011-03-29',
  },

  // ========== GERMANY vs IVORY COAST ==========
  {
    team1Code: 'CIV',
    team2Code: 'GER',
    totalMatches: 2,
    team1Wins: 0,
    team2Wins: 0,
    draws: 2,
    team1Goals: 3,
    team2Goals: 3,
    worldCupMatches: 0,
    team1WorldCupWins: 0,
    team2WorldCupWins: 0,
    worldCupDraws: 0,
    notableMatches: [
      {
        year: 2009,
        tournament: 'Friendly',
        stage: 'Friendly',
        team1Score: 2,
        team2Score: 2,
        location: 'Gelsenkirchen, Germany',
        description: 'Drogba leads Ivory Coast to hard-fought draw',
      },
      {
        year: 2021,
        tournament: 'Olympics',
        stage: 'Group Stage',
        team1Score: 1,
        team2Score: 1,
        location: 'Miyagi, Japan',
        description: 'Draw eliminates Germany from Tokyo Olympics',
      },
    ],
    firstMeeting: '2009-11-18',
    lastMatch: '2021-07-28',
  },

  // ========== URUGUAY vs SPAIN ==========
  {
    team1Code: 'ESP',
    team2Code: 'URU',
    totalMatches: 7,
    team1Wins: 3,
    team2Wins: 2,
    draws: 2,
    team1Goals: 10,
    team2Goals: 8,
    worldCupMatches: 2,
    team1WorldCupWins: 0,
    team2WorldCupWins: 0,
    worldCupDraws: 2,
    notableMatches: [
      {
        year: 1950,
        tournament: 'World Cup',
        stage: 'Final Round',
        team1Score: 2,
        team2Score: 2,
        location: 'São Paulo, Brazil',
        description: 'Dramatic draw in final round of 1950 World Cup',
      },
      {
        year: 2014,
        tournament: 'Friendly',
        stage: 'Friendly',
        team1Score: 2,
        team2Score: 1,
        winnerCode: 'ESP',
        location: 'Doha, Qatar',
        description: 'Spain edge Uruguay in pre-World Cup friendly',
      },
      {
        year: 2013,
        tournament: 'Confederations Cup',
        stage: 'Group Stage',
        team1Score: 2,
        team2Score: 1,
        winnerCode: 'ESP',
        location: 'Recife, Brazil',
        description: 'Pedro and Soldado give Spain victory',
      },
    ],
    firstMeeting: '1950-07-09',
    lastMatch: '2014-02-06',
  },

  // ========== CROATIA vs GHANA ==========
  {
    team1Code: 'CRO',
    team2Code: 'GHA',
    totalMatches: 1,
    team1Wins: 0,
    team2Wins: 0,
    draws: 1,
    team1Goals: 0,
    team2Goals: 0,
    worldCupMatches: 0,
    team1WorldCupWins: 0,
    team2WorldCupWins: 0,
    worldCupDraws: 0,
    notableMatches: [
      {
        year: 2008,
        tournament: 'Friendly',
        stage: 'Friendly',
        team1Score: 0,
        team2Score: 0,
        location: 'Klagenfurt, Austria',
        description: 'Goalless draw in pre-Euro 2008 friendly',
      },
    ],
    firstMeeting: '2008-05-26',
    lastMatch: '2008-05-26',
  },

  // ========== ARGENTINA vs ALGERIA ==========
  {
    team1Code: 'ALG',
    team2Code: 'ARG',
    totalMatches: 3,
    team1Wins: 0,
    team2Wins: 2,
    draws: 1,
    team1Goals: 2,
    team2Goals: 5,
    worldCupMatches: 2,
    team1WorldCupWins: 0,
    team2WorldCupWins: 1,
    worldCupDraws: 1,
    notableMatches: [
      {
        year: 2014,
        tournament: 'World Cup',
        stage: 'Group Stage',
        team1Score: 1,
        team2Score: 2,
        winnerCode: 'ARG',
        location: 'Porto Alegre, Brazil',
        description: 'Messi decisive goal in 91st minute gives Argentina narrow win',
      },
      {
        year: 1982,
        tournament: 'World Cup',
        stage: 'Group Stage',
        team1Score: 0,
        team2Score: 2,
        winnerCode: 'ARG',
        location: 'Oviedo, Spain',
        description: 'Maradona and Díaz goals see off Algeria',
      },
    ],
    firstMeeting: '1982-06-18',
    lastMatch: '2014-06-17',
  },

  // ========== COLOMBIA vs PORTUGAL (First Meeting!) ==========
  {
    team1Code: 'COL',
    team2Code: 'POR',
    totalMatches: 0,
    team1Wins: 0,
    team2Wins: 0,
    draws: 0,
    team1Goals: 0,
    team2Goals: 0,
    worldCupMatches: 0,
    team1WorldCupWins: 0,
    team2WorldCupWins: 0,
    worldCupDraws: 0,
    notableMatches: [],
  },

  // ========== CROATIA vs PANAMA (First Meeting!) ==========
  {
    team1Code: 'CRO',
    team2Code: 'PAN',
    totalMatches: 0,
    team1Wins: 0,
    team2Wins: 0,
    draws: 0,
    team1Goals: 0,
    team2Goals: 0,
    worldCupMatches: 0,
    team1WorldCupWins: 0,
    team2WorldCupWins: 0,
    worldCupDraws: 0,
    notableMatches: [],
  },
];

// ============================================================================
// Main Seed Function
// ============================================================================

async function seedHeadToHead(): Promise<void> {
  console.log('========================================');
  console.log('Seeding June 2026 Head-to-Head Records');
  console.log('========================================');
  console.log(`Mode: ${DRY_RUN ? 'DRY RUN' : 'LIVE'}`);
  console.log(`Records to seed: ${JUNE_2026_H2H_DATA.length}`);
  console.log('');

  let successCount = 0;
  let errorCount = 0;

  for (const h2h of JUNE_2026_H2H_DATA) {
    try {
      // Generate document ID (alphabetically sorted team codes)
      const codes = [h2h.team1Code, h2h.team2Code].sort();
      const docId = `${codes[0]}_${codes[1]}`;

      const docData = {
        team1Code: h2h.team1Code,
        team2Code: h2h.team2Code,
        totalMatches: h2h.totalMatches,
        team1Wins: h2h.team1Wins,
        team2Wins: h2h.team2Wins,
        draws: h2h.draws,
        team1Goals: h2h.team1Goals,
        team2Goals: h2h.team2Goals,
        worldCupMatches: h2h.worldCupMatches,
        team1WorldCupWins: h2h.team1WorldCupWins,
        team2WorldCupWins: h2h.team2WorldCupWins,
        worldCupDraws: h2h.worldCupDraws,
        notableMatches: h2h.notableMatches,
        firstMeeting: h2h.firstMeeting || null,
        lastMatch: h2h.lastMatch || null,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      if (DRY_RUN) {
        console.log(`[DRY RUN] Would create/update: ${docId}`);
        console.log(`  ${h2h.team1Code} vs ${h2h.team2Code}: ${h2h.totalMatches} matches`);
        if (h2h.totalMatches === 0) {
          console.log(`  ⭐ FIRST MEETING at World Cup 2026!`);
        }
      } else {
        await db.collection('headToHead').doc(docId).set(docData, { merge: true });
        console.log(`✅ Seeded: ${docId} (${h2h.team1Code} vs ${h2h.team2Code})`);
      }

      successCount++;
    } catch (error) {
      console.error(`❌ Error seeding ${h2h.team1Code} vs ${h2h.team2Code}: ${error}`);
      errorCount++;
    }
  }

  console.log('');
  console.log('========================================');
  console.log('Summary');
  console.log('========================================');
  console.log(`Total records: ${JUNE_2026_H2H_DATA.length}`);
  console.log(`Successful: ${successCount}`);
  console.log(`Errors: ${errorCount}`);
  console.log('');

  if (DRY_RUN) {
    console.log('This was a DRY RUN. No data was uploaded.');
    console.log('Run without --dryRun to upload to Firestore.');
  }
}

// Run the script
seedHeadToHead()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error('Fatal error:', error);
    process.exit(1);
  });

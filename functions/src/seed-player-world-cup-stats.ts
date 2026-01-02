/**
 * Seed Player World Cup Stats Script
 *
 * Updates player records with real World Cup career data.
 * Includes appearances, goals, assists, memorable moments, and awards.
 *
 * Usage:
 *   npx ts-node src/seed-player-world-cup-stats.ts [--dryRun]
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

interface WorldCupTournamentStats {
  year: number;
  matches: number;
  goals: number;
  assists: number;
  yellowCards?: number;
  redCards?: number;
  minutesPlayed?: number;
  stage: string; // How far team got
  keyMoment?: string;
}

interface PlayerWorldCupData {
  playerName: string;
  fifaCode: string;
  worldCupAppearances: number;
  worldCupGoals: number;
  worldCupAssists: number;
  previousWorldCups: number[];
  tournamentStats: WorldCupTournamentStats[];
  worldCupAwards: string[];
  memorableMoments: string[];
  worldCupLegacyRating: number; // 1-10 based on World Cup impact
  comparisonToLegend: string;
  worldCup2026Prediction: string;
}

// ============================================================================
// Player World Cup Data
// ============================================================================

const PLAYER_WORLD_CUP_DATA: PlayerWorldCupData[] = [
  // ========== ARGENTINA ==========
  {
    playerName: 'Lionel Messi',
    fifaCode: 'ARG',
    worldCupAppearances: 26,
    worldCupGoals: 13,
    worldCupAssists: 8,
    previousWorldCups: [2006, 2010, 2014, 2018, 2022],
    tournamentStats: [
      { year: 2006, matches: 3, goals: 1, assists: 1, stage: 'Quarter-Finals', keyMoment: 'Youngest Argentine to play and score at World Cup' },
      { year: 2010, matches: 5, goals: 0, assists: 1, stage: 'Quarter-Finals', keyMoment: 'Led attack but couldn\'t find the net' },
      { year: 2014, matches: 7, goals: 4, assists: 1, stage: 'Final', keyMoment: 'Won Golden Ball, lost final to Germany' },
      { year: 2018, matches: 4, goals: 1, assists: 2, stage: 'Round of 16', keyMoment: 'Magical goal vs Nigeria' },
      { year: 2022, matches: 7, goals: 7, assists: 3, stage: 'Winner', keyMoment: 'Won World Cup, 2 goals in final, tournament MVP' },
    ],
    worldCupAwards: ['World Cup Winner 2022', 'Golden Ball 2014', 'Golden Ball 2022', 'Silver Ball 2022'],
    memorableMoments: [
      'Lifting the World Cup trophy in 2022',
      'Two goals in 2022 final against France',
      'Penalty shootout celebration vs Netherlands',
      'Record-breaking goal vs Croatia in semi-final',
    ],
    worldCupLegacyRating: 10,
    comparisonToLegend: 'Finally matched Diego Maradona\'s World Cup legacy in Qatar 2022',
    worldCup2026Prediction: 'If fit, expected to feature in his 6th World Cup as defending champion captain',
  },
  {
    playerName: 'Julian Alvarez',
    fifaCode: 'ARG',
    worldCupAppearances: 7,
    worldCupGoals: 4,
    worldCupAssists: 0,
    previousWorldCups: [2022],
    tournamentStats: [
      { year: 2022, matches: 7, goals: 4, assists: 0, stage: 'Winner', keyMoment: 'Scored in semi-final and final, tournament breakthrough' },
    ],
    worldCupAwards: ['World Cup Winner 2022'],
    memorableMoments: [
      'Goal in World Cup final vs France',
      'Brace against Croatia in semi-final',
      'Tireless running throughout tournament',
    ],
    worldCupLegacyRating: 7,
    comparisonToLegend: 'Work rate compared to Carlos Tevez, clinical finishing like Gabriel Batistuta',
    worldCup2026Prediction: 'Expected to be Argentina\'s main striker in title defense',
  },

  // ========== BRAZIL ==========
  {
    playerName: 'Neymar',
    fifaCode: 'BRA',
    worldCupAppearances: 12,
    worldCupGoals: 8,
    worldCupAssists: 3,
    previousWorldCups: [2014, 2018, 2022],
    tournamentStats: [
      { year: 2014, matches: 5, goals: 4, assists: 1, stage: 'Semi-Finals', keyMoment: 'Injured in quarter-final, missed 7-1 humiliation' },
      { year: 2018, matches: 5, goals: 2, assists: 0, stage: 'Quarter-Finals', keyMoment: 'Controversial diving antics criticized' },
      { year: 2022, matches: 2, goals: 1, assists: 1, stage: 'Quarter-Finals', keyMoment: 'Stunning goal vs Croatia, but lost on penalties' },
    ],
    worldCupAwards: ['Bronze Ball 2014'],
    memorableMoments: [
      'Opening goal vs Croatia 2014',
      'Wonder goal vs Croatia 2022',
      'Emotional return from back injury 2014',
    ],
    worldCupLegacyRating: 7,
    comparisonToLegend: 'Skill compared to Ronaldinho, but yet to match World Cup success',
    worldCup2026Prediction: 'Will be 34, but remains key to Brazil\'s hopes if fit',
  },
  {
    playerName: 'Vinicius Jr',
    fifaCode: 'BRA',
    worldCupAppearances: 5,
    worldCupGoals: 1,
    worldCupAssists: 1,
    previousWorldCups: [2022],
    tournamentStats: [
      { year: 2022, matches: 5, goals: 1, assists: 1, stage: 'Quarter-Finals', keyMoment: 'Dancing celebration became iconic' },
    ],
    worldCupAwards: [],
    memorableMoments: [
      'Goal and dance vs South Korea',
      'Dazzling runs throughout tournament',
    ],
    worldCupLegacyRating: 5,
    comparisonToLegend: 'Speed and skill reminiscent of young Ronaldo Nazário',
    worldCup2026Prediction: 'Expected to be Brazil\'s main star and potential Golden Ball contender',
  },

  // ========== FRANCE ==========
  {
    playerName: 'Kylian Mbappe',
    fifaCode: 'FRA',
    worldCupAppearances: 14,
    worldCupGoals: 12,
    worldCupAssists: 2,
    previousWorldCups: [2018, 2022],
    tournamentStats: [
      { year: 2018, matches: 7, goals: 4, assists: 0, stage: 'Winner', keyMoment: 'Became second teenager after Pelé to score in final' },
      { year: 2022, matches: 7, goals: 8, assists: 2, stage: 'Final', keyMoment: 'Hat-trick in final, still lost to Argentina' },
    ],
    worldCupAwards: ['World Cup Winner 2018', 'Golden Boot 2022', 'Best Young Player 2018', 'Silver Ball 2022'],
    memorableMoments: [
      'Hat-trick in 2022 final - only second player after Hurst',
      'Brace vs Argentina in group stage 2018',
      'Stunning goals vs Croatia in 2018 final',
      'Four goals vs Argentina in 2022',
    ],
    worldCupLegacyRating: 9,
    comparisonToLegend: 'Already compared to Pelé and Thierry Henry for World Cup impact',
    worldCup2026Prediction: 'Will be 27 and entering prime - favorite for Golden Ball',
  },
  {
    playerName: 'Antoine Griezmann',
    fifaCode: 'FRA',
    worldCupAppearances: 14,
    worldCupGoals: 4,
    worldCupAssists: 4,
    previousWorldCups: [2014, 2018, 2022],
    tournamentStats: [
      { year: 2014, matches: 5, goals: 0, assists: 0, stage: 'Quarter-Finals' },
      { year: 2018, matches: 7, goals: 4, assists: 2, stage: 'Winner', keyMoment: 'Goal in final, key to France\'s success' },
      { year: 2022, matches: 7, goals: 0, assists: 2, stage: 'Final', keyMoment: 'Orchestrated from midfield, reinvented role' },
    ],
    worldCupAwards: ['World Cup Winner 2018', 'Bronze Ball 2018'],
    memorableMoments: [
      'Free kick in World Cup final 2018',
      'Crucial goals in knockout stages 2018',
      'Selfless midfield role in 2022',
    ],
    worldCupLegacyRating: 8,
    comparisonToLegend: 'Complete attacker like David Trezeguet with better playmaking',
    worldCup2026Prediction: 'Veteran presence expected to guide younger players',
  },

  // ========== GERMANY ==========
  {
    playerName: 'Jamal Musiala',
    fifaCode: 'GER',
    worldCupAppearances: 3,
    worldCupGoals: 0,
    worldCupAssists: 0,
    previousWorldCups: [2022],
    tournamentStats: [
      { year: 2022, matches: 3, goals: 0, assists: 0, stage: 'Group Stage', keyMoment: 'Germany shock early exit despite Musiala brilliance' },
    ],
    worldCupAwards: [],
    memorableMoments: [
      'Dazzling runs vs Japan and Spain',
      'Youngest German World Cup player since 1934',
    ],
    worldCupLegacyRating: 4,
    comparisonToLegend: 'Dribbling ability compared to Mesut Özil with more directness',
    worldCup2026Prediction: 'Expected to be Germany\'s main creative force and potential star of tournament',
  },
  {
    playerName: 'Florian Wirtz',
    fifaCode: 'GER',
    worldCupAppearances: 0,
    worldCupGoals: 0,
    worldCupAssists: 0,
    previousWorldCups: [],
    tournamentStats: [],
    worldCupAwards: [],
    memorableMoments: [],
    worldCupLegacyRating: 0,
    comparisonToLegend: 'Technical ability compared to young Michael Ballack',
    worldCup2026Prediction: 'First World Cup - expected to form deadly partnership with Musiala',
  },

  // ========== ENGLAND ==========
  {
    playerName: 'Harry Kane',
    fifaCode: 'ENG',
    worldCupAppearances: 11,
    worldCupGoals: 8,
    worldCupAssists: 2,
    previousWorldCups: [2018, 2022],
    tournamentStats: [
      { year: 2018, matches: 6, goals: 6, assists: 0, stage: 'Semi-Finals', keyMoment: 'Won Golden Boot as England reached semis' },
      { year: 2022, matches: 5, goals: 2, assists: 2, stage: 'Quarter-Finals', keyMoment: 'Missed crucial penalty vs France' },
    ],
    worldCupAwards: ['Golden Boot 2018'],
    memorableMoments: [
      'Hat-trick vs Panama 2018',
      'Last-minute winner vs Tunisia 2018',
      'Penalty miss vs France that haunts England',
    ],
    worldCupLegacyRating: 7,
    comparisonToLegend: 'Goal record approaching Gary Lineker levels',
    worldCup2026Prediction: 'Will be 32 - likely final chance to win World Cup as captain',
  },
  {
    playerName: 'Jude Bellingham',
    fifaCode: 'ENG',
    worldCupAppearances: 5,
    worldCupGoals: 1,
    worldCupAssists: 1,
    previousWorldCups: [2022],
    tournamentStats: [
      { year: 2022, matches: 5, goals: 1, assists: 1, stage: 'Quarter-Finals', keyMoment: 'Youngest England World Cup scorer at 19' },
    ],
    worldCupAwards: [],
    memorableMoments: [
      'Stunning header vs Iran',
      'Commanding midfield performances at just 19',
    ],
    worldCupLegacyRating: 5,
    comparisonToLegend: 'All-round ability compared to Frank Lampard and Steven Gerrard combined',
    worldCup2026Prediction: 'Expected to be one of the best players at the tournament',
  },

  // ========== SPAIN ==========
  {
    playerName: 'Pedri',
    fifaCode: 'ESP',
    worldCupAppearances: 3,
    worldCupGoals: 0,
    worldCupAssists: 0,
    previousWorldCups: [2022],
    tournamentStats: [
      { year: 2022, matches: 3, goals: 0, assists: 0, stage: 'Round of 16', keyMoment: 'Young conductor of Spain\'s midfield' },
    ],
    worldCupAwards: [],
    memorableMoments: [
      'Controlled midfield vs Costa Rica',
    ],
    worldCupLegacyRating: 4,
    comparisonToLegend: 'Ball control and vision compared to Xavi Hernández',
    worldCup2026Prediction: 'Expected to be Spain\'s midfield maestro in their title bid',
  },
  {
    playerName: 'Lamine Yamal',
    fifaCode: 'ESP',
    worldCupAppearances: 0,
    worldCupGoals: 0,
    worldCupAssists: 0,
    previousWorldCups: [],
    tournamentStats: [],
    worldCupAwards: [],
    memorableMoments: [],
    worldCupLegacyRating: 0,
    comparisonToLegend: 'Already compared to Lionel Messi for precocious talent',
    worldCup2026Prediction: 'Will be 18 at World Cup - could be breakthrough tournament star',
  },

  // ========== PORTUGAL ==========
  {
    playerName: 'Cristiano Ronaldo',
    fifaCode: 'POR',
    worldCupAppearances: 22,
    worldCupGoals: 8,
    worldCupAssists: 2,
    previousWorldCups: [2006, 2010, 2014, 2018, 2022],
    tournamentStats: [
      { year: 2006, matches: 6, goals: 1, assists: 2, stage: 'Semi-Finals', keyMoment: 'Iconic wink after Rooney red card' },
      { year: 2010, matches: 4, goals: 1, assists: 1, stage: 'Round of 16' },
      { year: 2014, matches: 3, goals: 1, assists: 0, stage: 'Group Stage', keyMoment: 'Played through injury' },
      { year: 2018, matches: 4, goals: 4, assists: 0, stage: 'Round of 16', keyMoment: 'Hat-trick vs Spain in group stage' },
      { year: 2022, matches: 5, goals: 1, assists: 0, stage: 'Quarter-Finals', keyMoment: 'Dropped for knockout stages, cried on exit' },
    ],
    worldCupAwards: [],
    memorableMoments: [
      'Hat-trick vs Spain 2018',
      'Tears after 2022 elimination',
      'Header vs Morocco 2018',
    ],
    worldCupLegacyRating: 7,
    comparisonToLegend: 'Elite goalscorer but World Cup remains only major trophy without',
    worldCup2026Prediction: 'If selected at 41, would be oldest outfield player in World Cup history',
  },

  // ========== NETHERLANDS ==========
  {
    playerName: 'Virgil van Dijk',
    fifaCode: 'NED',
    worldCupAppearances: 5,
    worldCupGoals: 0,
    worldCupAssists: 0,
    previousWorldCups: [2022],
    tournamentStats: [
      { year: 2022, matches: 5, goals: 0, assists: 0, stage: 'Quarter-Finals', keyMoment: 'Marshalled defence until Argentina loss' },
    ],
    worldCupAwards: [],
    memorableMoments: [
      'Commanding presence vs Argentina',
      'Leadership in tempestuous quarter-final',
    ],
    worldCupLegacyRating: 5,
    comparisonToLegend: 'Defensive ability compared to Ronald Koeman at his peak',
    worldCup2026Prediction: 'Expected to captain Netherlands as they chase first World Cup since 1978',
  },

  // ========== USA ==========
  {
    playerName: 'Christian Pulisic',
    fifaCode: 'USA',
    worldCupAppearances: 5,
    worldCupGoals: 1,
    worldCupAssists: 0,
    previousWorldCups: [2022],
    tournamentStats: [
      { year: 2022, matches: 5, goals: 1, assists: 0, stage: 'Round of 16', keyMoment: 'Goal vs Iran to qualify for knockouts, collided with goalkeeper' },
    ],
    worldCupAwards: [],
    memorableMoments: [
      'Crucial goal vs Iran',
      'Brave performance despite injury',
    ],
    worldCupLegacyRating: 5,
    comparisonToLegend: 'Most talented American since Landon Donovan',
    worldCup2026Prediction: 'Home World Cup - expected to be face of tournament for USA',
  },
  {
    playerName: 'Weston McKennie',
    fifaCode: 'USA',
    worldCupAppearances: 4,
    worldCupGoals: 0,
    worldCupAssists: 1,
    previousWorldCups: [2022],
    tournamentStats: [
      { year: 2022, matches: 4, goals: 0, assists: 1, stage: 'Round of 16', keyMoment: 'Box-to-box engine for young US team' },
    ],
    worldCupAwards: [],
    memorableMoments: [
      'Assist vs Wales',
      'Work rate throughout tournament',
    ],
    worldCupLegacyRating: 4,
    comparisonToLegend: 'Energy and versatility compared to Michael Bradley',
    worldCup2026Prediction: 'Key midfield presence for home World Cup',
  },

  // ========== MEXICO ==========
  {
    playerName: 'Hirving Lozano',
    fifaCode: 'MEX',
    worldCupAppearances: 7,
    worldCupGoals: 1,
    worldCupAssists: 0,
    previousWorldCups: [2018, 2022],
    tournamentStats: [
      { year: 2018, matches: 4, goals: 1, assists: 0, stage: 'Round of 16', keyMoment: 'Stunning goal vs Germany in famous upset' },
      { year: 2022, matches: 3, goals: 0, assists: 0, stage: 'Group Stage', keyMoment: 'Mexico fail to advance despite talent' },
    ],
    worldCupAwards: [],
    memorableMoments: [
      'Goal that caused earthquake in Mexico City vs Germany',
      'Electric performances on the wing',
    ],
    worldCupLegacyRating: 5,
    comparisonToLegend: 'Pace and directness compared to Cuauhtémoc Blanco',
    worldCup2026Prediction: 'Home World Cup - big occasion for Chucky to shine',
  },

  // ========== MOROCCO ==========
  {
    playerName: 'Achraf Hakimi',
    fifaCode: 'MAR',
    worldCupAppearances: 6,
    worldCupGoals: 0,
    worldCupAssists: 0,
    previousWorldCups: [2018, 2022],
    tournamentStats: [
      { year: 2018, matches: 1, goals: 0, assists: 0, stage: 'Group Stage' },
      { year: 2022, matches: 5, goals: 0, assists: 0, stage: 'Semi-Finals', keyMoment: 'Panenka penalty vs Spain, historic semi run' },
    ],
    worldCupAwards: [],
    memorableMoments: [
      'Audacious Panenka to beat Spain',
      'Marauding runs in historic campaign',
      'Celebrating with his mother on the pitch',
    ],
    worldCupLegacyRating: 7,
    comparisonToLegend: 'Attacking full-back excellence like Cafu',
    worldCup2026Prediction: 'Expected to lead Morocco as they aim to match or exceed 2022 heroics',
  },

  // ========== CROATIA ==========
  {
    playerName: 'Luka Modric',
    fifaCode: 'CRO',
    worldCupAppearances: 16,
    worldCupGoals: 2,
    worldCupAssists: 2,
    previousWorldCups: [2006, 2014, 2018, 2022],
    tournamentStats: [
      { year: 2006, matches: 3, goals: 0, assists: 0, stage: 'Group Stage' },
      { year: 2014, matches: 3, goals: 1, assists: 0, stage: 'Group Stage' },
      { year: 2018, matches: 7, goals: 1, assists: 1, stage: 'Final', keyMoment: 'Won Golden Ball, led Croatia to first ever final' },
      { year: 2022, matches: 7, goals: 0, assists: 1, stage: 'Third Place', keyMoment: 'Led Croatia to third place at 37' },
    ],
    worldCupAwards: ['Golden Ball 2018'],
    memorableMoments: [
      'Lifting Silver Medal in Moscow 2018',
      'Stunning goal vs Argentina 2018',
      'Leadership throughout 2018 and 2022',
    ],
    worldCupLegacyRating: 9,
    comparisonToLegend: 'Midfield mastery compared to Zidane and Iniesta',
    worldCup2026Prediction: 'If selected at 40, would provide invaluable experience for young Croatian squad',
  },

  // ========== BELGIUM ==========
  {
    playerName: 'Kevin De Bruyne',
    fifaCode: 'BEL',
    worldCupAppearances: 11,
    worldCupGoals: 1,
    worldCupAssists: 4,
    previousWorldCups: [2014, 2018, 2022],
    tournamentStats: [
      { year: 2014, matches: 5, goals: 0, assists: 2, stage: 'Quarter-Finals' },
      { year: 2018, matches: 7, goals: 1, assists: 2, stage: 'Third Place', keyMoment: 'Stunning counter-attack goal vs Brazil' },
      { year: 2022, matches: 3, goals: 0, assists: 0, stage: 'Group Stage', keyMoment: 'Belgium\'s golden generation exits early' },
    ],
    worldCupAwards: [],
    memorableMoments: [
      'Goal vs Brazil 2018 in stunning counter',
      'Playmaking throughout 2018 run',
    ],
    worldCupLegacyRating: 6,
    comparisonToLegend: 'Passing range compared to Michael Laudrup',
    worldCup2026Prediction: 'Last chance for golden generation to finally win major trophy',
  },

  // ========== JAPAN ==========
  {
    playerName: 'Takefusa Kubo',
    fifaCode: 'JPN',
    worldCupAppearances: 4,
    worldCupGoals: 0,
    worldCupAssists: 0,
    previousWorldCups: [2022],
    tournamentStats: [
      { year: 2022, matches: 4, goals: 0, assists: 0, stage: 'Round of 16', keyMoment: 'Part of Japan\'s historic wins over Germany and Spain' },
    ],
    worldCupAwards: [],
    memorableMoments: [
      'Dribbling runs vs Germany',
      'Part of historic group stage performance',
    ],
    worldCupLegacyRating: 4,
    comparisonToLegend: 'Skill compared to Shinji Kagawa with more flair',
    worldCup2026Prediction: 'Expected to be one of Japan\'s main attacking threats',
  },

  // ========== SOUTH KOREA ==========
  {
    playerName: 'Son Heung-min',
    fifaCode: 'KOR',
    worldCupAppearances: 11,
    worldCupGoals: 3,
    worldCupAssists: 1,
    previousWorldCups: [2014, 2018, 2022],
    tournamentStats: [
      { year: 2014, matches: 3, goals: 0, assists: 0, stage: 'Group Stage' },
      { year: 2018, matches: 3, goals: 2, assists: 0, stage: 'Group Stage', keyMoment: 'Goal vs Germany in famous upset' },
      { year: 2022, matches: 4, goals: 1, assists: 1, stage: 'Round of 16', keyMoment: 'Played with protective mask after facial injury' },
    ],
    worldCupAwards: [],
    memorableMoments: [
      'Goal to seal Germany elimination 2018',
      'Brave performance with face mask 2022',
      'Tears after reaching knockouts 2022',
    ],
    worldCupLegacyRating: 6,
    comparisonToLegend: 'Best Asian player of his generation, compared to Park Ji-sung',
    worldCup2026Prediction: 'Will be 33 - likely final chance to make deep World Cup run',
  },

  // ========== CANADA ==========
  {
    playerName: 'Alphonso Davies',
    fifaCode: 'CAN',
    worldCupAppearances: 3,
    worldCupGoals: 0,
    worldCupAssists: 0,
    previousWorldCups: [2022],
    tournamentStats: [
      { year: 2022, matches: 3, goals: 0, assists: 0, stage: 'Group Stage', keyMoment: 'Missed penalty vs Belgium in Canada\'s return to World Cup' },
    ],
    worldCupAwards: [],
    memorableMoments: [
      'Penalty miss vs Belgium',
      'Electric runs despite team struggles',
    ],
    worldCupLegacyRating: 3,
    comparisonToLegend: 'Pace and attacking ability compared to Roberto Carlos',
    worldCup2026Prediction: 'Home World Cup for Canada - Davies will be main star',
  },
  {
    playerName: 'Jonathan David',
    fifaCode: 'CAN',
    worldCupAppearances: 3,
    worldCupGoals: 0,
    worldCupAssists: 0,
    previousWorldCups: [2022],
    tournamentStats: [
      { year: 2022, matches: 3, goals: 0, assists: 0, stage: 'Group Stage', keyMoment: 'Part of Canada\'s first World Cup squad since 1986' },
    ],
    worldCupAwards: [],
    memorableMoments: [
      'Led line for historic Canadian return',
    ],
    worldCupLegacyRating: 3,
    comparisonToLegend: 'Clinical striker ability compared to Thierry Henry',
    worldCup2026Prediction: 'Expected to lead Canada\'s attack on home soil',
  },
];

// ============================================================================
// Main Function
// ============================================================================

async function seedPlayerWorldCupStats() {
  console.log('========================================');
  console.log('Player World Cup Stats Seed Script');
  console.log('========================================');
  console.log(`Mode: ${DRY_RUN ? 'DRY RUN (no data will be uploaded)' : 'LIVE (uploading to Firestore)'}`);
  console.log('');

  console.log(`Processing ${PLAYER_WORLD_CUP_DATA.length} player World Cup records...`);
  console.log('');

  let successCount = 0;
  let errorCount = 0;
  let notFoundCount = 0;

  for (const playerData of PLAYER_WORLD_CUP_DATA) {
    try {
      console.log(`Processing: ${playerData.playerName} (${playerData.fifaCode})`);

      // Find the player in Firestore
      const playerQuery = await db.collection('players')
        .where('fifaCode', '==', playerData.fifaCode)
        .get();

      // Try to match by name
      let matchedPlayer: admin.firestore.DocumentSnapshot | null = null;
      for (const doc of playerQuery.docs) {
        const data = doc.data();
        const fullName = data.fullName || `${data.firstName} ${data.lastName}`;
        if (fullName.toLowerCase().includes(playerData.playerName.split(' ').pop()?.toLowerCase() || '')) {
          matchedPlayer = doc;
          break;
        }
      }

      if (!matchedPlayer) {
        console.log(`  ⚠️  Player not found: ${playerData.playerName}`);
        notFoundCount++;
        continue;
      }

      const updateData = {
        worldCupAppearances: playerData.worldCupAppearances,
        worldCupGoals: playerData.worldCupGoals,
        worldCupAssists: playerData.worldCupAssists,
        previousWorldCups: playerData.previousWorldCups,
        worldCupTournamentStats: playerData.tournamentStats,
        worldCupAwards: playerData.worldCupAwards,
        memorableMoments: playerData.memorableMoments,
        worldCupLegacyRating: playerData.worldCupLegacyRating,
        comparisonToLegend: playerData.comparisonToLegend,
        worldCup2026Prediction: playerData.worldCup2026Prediction,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      if (DRY_RUN) {
        console.log(`  [DRY RUN] Would update: ${playerData.playerName}`);
        console.log(`    - World Cup Appearances: ${playerData.worldCupAppearances}`);
        console.log(`    - World Cup Goals: ${playerData.worldCupGoals}`);
        console.log(`    - Awards: ${playerData.worldCupAwards.length}`);
      } else {
        await matchedPlayer.ref.update(updateData);
        console.log(`  ✅ Updated: ${playerData.playerName}`);
      }

      successCount++;
    } catch (error) {
      console.error(`  ❌ ERROR processing ${playerData.playerName}: ${error}`);
      errorCount++;
    }
  }

  console.log('');
  console.log('========================================');
  console.log('Summary');
  console.log('========================================');
  console.log(`Total records processed: ${PLAYER_WORLD_CUP_DATA.length}`);
  console.log(`Successful: ${successCount}`);
  console.log(`Not Found: ${notFoundCount}`);
  console.log(`Errors: ${errorCount}`);
  console.log('');

  if (DRY_RUN) {
    console.log('This was a DRY RUN. No data was uploaded.');
    console.log('Run without --dryRun to upload to Firestore.');
  }
}

// Run the script
seedPlayerWorldCupStats()
  .then(() => {
    console.log('Player World Cup stats seed script completed.');
    process.exit(0);
  })
  .catch((error) => {
    console.error('Player World Cup stats seed script failed:', error);
    process.exit(1);
  });

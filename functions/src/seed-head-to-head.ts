/**
 * Seed Head-to-Head Records Script
 *
 * Adds historical head-to-head records between national teams to Firestore.
 * Includes World Cup specific stats and notable matches.
 *
 * Usage:
 *   npx ts-node src/seed-head-to-head.ts [--dryRun]
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

interface HeadToHeadInput {
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
  lastMatch?: string;
  firstMeeting?: string;
  notableMatches: NotableMatch[];
}

// ============================================================================
// Head-to-Head Data - Comprehensive Records
// ============================================================================

const HEAD_TO_HEAD_DATA: HeadToHeadInput[] = [
  // ========== SOUTH AMERICAN RIVALRIES ==========

  // Argentina vs Brazil - El Superclásico de las Américas
  {
    team1Code: 'ARG',
    team2Code: 'BRA',
    totalMatches: 111,
    team1Wins: 40,
    team2Wins: 46,
    draws: 25,
    team1Goals: 163,
    team2Goals: 168,
    worldCupMatches: 6,
    team1WorldCupWins: 3,
    team2WorldCupWins: 2,
    worldCupDraws: 1,
    lastMatch: '2024-11-19',
    firstMeeting: '1914-09-20',
    notableMatches: [
      { year: 2022, tournament: 'World Cup', stage: 'Final', team1Score: 3, team2Score: 3, winnerCode: 'ARG', location: 'Lusail, Qatar', description: 'Argentina won 4-2 on penalties, Messi crowned' },
      { year: 2014, tournament: 'World Cup', stage: 'Round of 16', team1Score: 1, team2Score: 0, winnerCode: 'ARG', location: 'Brasília, Brazil', description: 'Higuaín goal in hostile territory' },
      { year: 1990, tournament: 'World Cup', stage: 'Round of 16', team1Score: 1, team2Score: 0, winnerCode: 'ARG', location: 'Turin, Italy', description: 'Caniggia stunner eliminates Brazil' },
      { year: 1982, tournament: 'World Cup', stage: 'Second Round', team1Score: 1, team2Score: 3, winnerCode: 'BRA', location: 'Barcelona, Spain', description: 'Zico masterclass, Maradona sent off' },
      { year: 1978, tournament: 'World Cup', stage: 'Second Round', team1Score: 0, team2Score: 0, location: 'Rosario, Argentina', description: 'Tense draw in Argentina\'s World Cup run' },
      { year: 1974, tournament: 'World Cup', stage: 'Second Round', team1Score: 1, team2Score: 2, winnerCode: 'BRA', location: 'Hanover, Germany', description: 'Rivellino and Jairzinho goals' },
    ],
  },

  // Argentina vs Uruguay - Río de la Plata Derby
  {
    team1Code: 'ARG',
    team2Code: 'URU',
    totalMatches: 197,
    team1Wins: 91,
    team2Wins: 58,
    draws: 48,
    team1Goals: 350,
    team2Goals: 260,
    worldCupMatches: 6,
    team1WorldCupWins: 2,
    team2WorldCupWins: 3,
    worldCupDraws: 1,
    lastMatch: '2024-11-15',
    firstMeeting: '1901-05-16',
    notableMatches: [
      { year: 2030, tournament: 'World Cup', stage: 'Final', team1Score: 2, team2Score: 4, winnerCode: 'URU', location: 'Montevideo, Uruguay', description: 'Uruguay win first ever World Cup final' },
      { year: 1930, tournament: 'World Cup', stage: 'Final', team1Score: 2, team2Score: 4, winnerCode: 'URU', location: 'Montevideo, Uruguay', description: 'Uruguay wins inaugural World Cup' },
      { year: 1986, tournament: 'World Cup', stage: 'Round of 16', team1Score: 1, team2Score: 0, winnerCode: 'ARG', location: 'Puebla, Mexico', description: 'Pasculli goal sends Argentina through' },
      { year: 1966, tournament: 'World Cup', stage: 'Group Stage', team1Score: 0, team2Score: 0, location: 'Birmingham, England', description: 'Goalless draw in group stage' },
    ],
  },

  // Brazil vs Uruguay
  {
    team1Code: 'BRA',
    team2Code: 'URU',
    totalMatches: 80,
    team1Wins: 38,
    team2Wins: 21,
    draws: 21,
    team1Goals: 140,
    team2Goals: 100,
    worldCupMatches: 5,
    team1WorldCupWins: 3,
    team2WorldCupWins: 2,
    worldCupDraws: 0,
    lastMatch: '2024-10-15',
    firstMeeting: '1916-07-12',
    notableMatches: [
      { year: 1950, tournament: 'World Cup', stage: 'Final Round', team1Score: 1, team2Score: 2, winnerCode: 'URU', location: 'Rio de Janeiro, Brazil', description: 'The Maracanazo - Uruguay shock Brazil at home' },
      { year: 1970, tournament: 'World Cup', stage: 'Semi-Final', team1Score: 3, team2Score: 1, winnerCode: 'BRA', location: 'Guadalajara, Mexico', description: 'Brazil reach final en route to third title' },
      { year: 2014, tournament: 'World Cup', stage: 'Round of 16', team1Score: 2, team2Score: 1, winnerCode: 'BRA', location: 'Belo Horizonte, Brazil', description: 'James Rodriguez brace eliminates Uruguay' },
    ],
  },

  // Colombia vs Argentina
  {
    team1Code: 'ARG',
    team2Code: 'COL',
    totalMatches: 42,
    team1Wins: 19,
    team2Wins: 8,
    draws: 15,
    team1Goals: 74,
    team2Goals: 48,
    worldCupMatches: 1,
    team1WorldCupWins: 1,
    team2WorldCupWins: 0,
    worldCupDraws: 0,
    lastMatch: '2024-07-14',
    firstMeeting: '1945-12-16',
    notableMatches: [
      { year: 2024, tournament: 'Copa America', stage: 'Final', team1Score: 1, team2Score: 0, winnerCode: 'ARG', location: 'Miami, USA', description: 'Lautaro Martinez goal in extra time' },
      { year: 2022, tournament: 'World Cup Qualifier', team1Score: 1, team2Score: 0, winnerCode: 'ARG', location: 'Córdoba, Argentina', description: 'Key qualifier victory' },
      { year: 1994, tournament: 'World Cup', stage: 'Group Stage', team1Score: 0, team2Score: 5, winnerCode: 'COL', location: 'Boston, USA', description: 'Colombia\'s famous 5-0 demolition' },
    ],
  },

  // ========== EUROPEAN RIVALRIES ==========

  // England vs Germany
  {
    team1Code: 'ENG',
    team2Code: 'GER',
    totalMatches: 37,
    team1Wins: 14,
    team2Wins: 15,
    draws: 8,
    team1Goals: 53,
    team2Goals: 49,
    worldCupMatches: 8,
    team1WorldCupWins: 2,
    team2WorldCupWins: 4,
    worldCupDraws: 2,
    lastMatch: '2022-09-26',
    firstMeeting: '1930-05-10',
    notableMatches: [
      { year: 2021, tournament: 'Euro 2020', stage: 'Round of 16', team1Score: 2, team2Score: 0, winnerCode: 'ENG', location: 'London, England', description: 'Sterling and Kane end German hex at Wembley' },
      { year: 2010, tournament: 'World Cup', stage: 'Round of 16', team1Score: 1, team2Score: 4, winnerCode: 'GER', location: 'Bloemfontein, South Africa', description: 'Lampard ghost goal denied, Germany rout' },
      { year: 1996, tournament: 'Euro 96', stage: 'Semi-Final', team1Score: 1, team2Score: 1, winnerCode: 'GER', location: 'London, England', description: 'Germany wins 6-5 on penalties, Southgate miss' },
      { year: 1990, tournament: 'World Cup', stage: 'Semi-Final', team1Score: 1, team2Score: 1, winnerCode: 'GER', location: 'Turin, Italy', description: 'Germany wins 4-3 on penalties, Waddle blazes over' },
      { year: 1970, tournament: 'World Cup', stage: 'Quarter-Final', team1Score: 2, team2Score: 3, winnerCode: 'GER', location: 'León, Mexico', description: 'Beckenbauer plays with dislocated shoulder' },
      { year: 1966, tournament: 'World Cup', stage: 'Final', team1Score: 4, team2Score: 2, winnerCode: 'ENG', location: 'London, England', description: 'Hurst hat-trick, "They think it\'s all over"' },
    ],
  },

  // France vs Germany
  {
    team1Code: 'FRA',
    team2Code: 'GER',
    totalMatches: 32,
    team1Wins: 13,
    team2Wins: 10,
    draws: 9,
    team1Goals: 52,
    team2Goals: 45,
    worldCupMatches: 4,
    team1WorldCupWins: 1,
    team2WorldCupWins: 2,
    worldCupDraws: 1,
    lastMatch: '2024-03-23',
    firstMeeting: '1931-03-15',
    notableMatches: [
      { year: 2014, tournament: 'World Cup', stage: 'Quarter-Final', team1Score: 0, team2Score: 1, winnerCode: 'GER', location: 'Rio de Janeiro, Brazil', description: 'Hummels header sends Germany through' },
      { year: 1982, tournament: 'World Cup', stage: 'Semi-Final', team1Score: 3, team2Score: 3, winnerCode: 'GER', location: 'Seville, Spain', description: 'Epic match, Schumacher foul, Germany win on penalties' },
      { year: 1986, tournament: 'World Cup', stage: 'Semi-Final', team1Score: 2, team2Score: 0, winnerCode: 'FRA', location: 'Guadalajara, Mexico', description: 'France revenge, reach second straight final' },
      { year: 2016, tournament: 'Euro 2016', stage: 'Semi-Final', team1Score: 2, team2Score: 0, winnerCode: 'FRA', location: 'Marseille, France', description: 'Griezmann brace sends hosts to final' },
    ],
  },

  // Netherlands vs Germany - Der Klassiker
  {
    team1Code: 'GER',
    team2Code: 'NED',
    totalMatches: 46,
    team1Wins: 17,
    team2Wins: 15,
    draws: 14,
    team1Goals: 74,
    team2Goals: 65,
    worldCupMatches: 4,
    team1WorldCupWins: 2,
    team2WorldCupWins: 1,
    worldCupDraws: 1,
    lastMatch: '2024-03-26',
    firstMeeting: '1910-04-10',
    notableMatches: [
      { year: 1974, tournament: 'World Cup', stage: 'Final', team1Score: 2, team2Score: 1, winnerCode: 'GER', location: 'Munich, Germany', description: 'Germany comeback, Müller winner' },
      { year: 1988, tournament: 'Euro 88', stage: 'Semi-Final', team1Score: 1, team2Score: 2, winnerCode: 'NED', location: 'Hamburg, Germany', description: 'Van Basten penalty seals Dutch revenge' },
      { year: 1978, tournament: 'World Cup', stage: 'Group Stage', team1Score: 2, team2Score: 2, location: 'Córdoba, Argentina', description: 'Thrilling draw, both reach second round' },
      { year: 1990, tournament: 'World Cup', stage: 'Round of 16', team1Score: 2, team2Score: 1, winnerCode: 'GER', location: 'Milan, Italy', description: 'Rijkaard-Völler spitting incident' },
    ],
  },

  // France vs Italy
  {
    team1Code: 'FRA',
    team2Code: 'ITA',
    totalMatches: 38,
    team1Wins: 18,
    team2Wins: 10,
    draws: 10,
    team1Goals: 64,
    team2Goals: 40,
    worldCupMatches: 5,
    team1WorldCupWins: 2,
    team2WorldCupWins: 2,
    worldCupDraws: 1,
    lastMatch: '2024-09-06',
    firstMeeting: '1910-05-15',
    notableMatches: [
      { year: 2006, tournament: 'World Cup', stage: 'Final', team1Score: 1, team2Score: 1, winnerCode: 'ITA', location: 'Berlin, Germany', description: 'Zidane headbutt, Italy win on penalties' },
      { year: 2000, tournament: 'Euro 2000', stage: 'Final', team1Score: 2, team2Score: 1, winnerCode: 'FRA', location: 'Rotterdam, Netherlands', description: 'Trezeguet golden goal wins it' },
      { year: 1998, tournament: 'World Cup', stage: 'Quarter-Final', team1Score: 0, team2Score: 0, winnerCode: 'FRA', location: 'Saint-Denis, France', description: 'France win on penalties at home' },
      { year: 1938, tournament: 'World Cup', stage: 'Quarter-Final', team1Score: 1, team2Score: 3, winnerCode: 'ITA', location: 'Paris, France', description: 'Italy defend title en route to win' },
    ],
  },

  // Spain vs Portugal - Iberian Derby
  {
    team1Code: 'ESP',
    team2Code: 'POR',
    totalMatches: 38,
    team1Wins: 17,
    team2Wins: 7,
    draws: 14,
    team1Goals: 72,
    team2Goals: 35,
    worldCupMatches: 2,
    team1WorldCupWins: 0,
    team2WorldCupWins: 0,
    worldCupDraws: 2,
    lastMatch: '2024-09-08',
    firstMeeting: '1921-12-18',
    notableMatches: [
      { year: 2018, tournament: 'World Cup', stage: 'Group Stage', team1Score: 3, team2Score: 3, location: 'Sochi, Russia', description: 'Ronaldo hat-trick in epic draw' },
      { year: 2012, tournament: 'Euro 2012', stage: 'Semi-Final', team1Score: 0, team2Score: 0, winnerCode: 'ESP', location: 'Donetsk, Ukraine', description: 'Spain win on penalties, Cesc decisive' },
      { year: 2010, tournament: 'World Cup', stage: 'Round of 16', team1Score: 1, team2Score: 0, winnerCode: 'ESP', location: 'Cape Town, South Africa', description: 'Villa goal, Spain march on to glory' },
    ],
  },

  // England vs Argentina
  {
    team1Code: 'ARG',
    team2Code: 'ENG',
    totalMatches: 15,
    team1Wins: 7,
    team2Wins: 5,
    draws: 3,
    team1Goals: 21,
    team2Goals: 16,
    worldCupMatches: 5,
    team1WorldCupWins: 2,
    team2WorldCupWins: 1,
    worldCupDraws: 2,
    lastMatch: '2023-03-28',
    firstMeeting: '1951-05-09',
    notableMatches: [
      { year: 1986, tournament: 'World Cup', stage: 'Quarter-Final', team1Score: 2, team2Score: 1, winnerCode: 'ARG', location: 'Mexico City, Mexico', description: 'Hand of God and Goal of the Century' },
      { year: 1998, tournament: 'World Cup', stage: 'Round of 16', team1Score: 2, team2Score: 2, winnerCode: 'ARG', location: 'Saint-Etienne, France', description: 'Beckham red card, Argentina win on penalties' },
      { year: 2002, tournament: 'World Cup', stage: 'Group Stage', team1Score: 0, team2Score: 1, winnerCode: 'ENG', location: 'Sapporo, Japan', description: 'Beckham penalty redemption' },
      { year: 1966, tournament: 'World Cup', stage: 'Quarter-Final', team1Score: 0, team2Score: 1, winnerCode: 'ENG', location: 'London, England', description: 'Hurst goal, Rattin sent off' },
    ],
  },

  // Argentina vs Germany
  {
    team1Code: 'ARG',
    team2Code: 'GER',
    totalMatches: 23,
    team1Wins: 6,
    team2Wins: 10,
    draws: 7,
    team1Goals: 30,
    team2Goals: 35,
    worldCupMatches: 7,
    team1WorldCupWins: 2,
    team2WorldCupWins: 3,
    worldCupDraws: 2,
    lastMatch: '2022-11-21',
    firstMeeting: '1958-06-08',
    notableMatches: [
      { year: 2014, tournament: 'World Cup', stage: 'Final', team1Score: 0, team2Score: 1, winnerCode: 'GER', location: 'Rio de Janeiro, Brazil', description: 'Götze extra-time goal wins Germany\'s 4th title' },
      { year: 2010, tournament: 'World Cup', stage: 'Quarter-Final', team1Score: 0, team2Score: 4, winnerCode: 'GER', location: 'Cape Town, South Africa', description: 'Germany demolish Messi\'s Argentina' },
      { year: 1986, tournament: 'World Cup', stage: 'Final', team1Score: 3, team2Score: 2, winnerCode: 'ARG', location: 'Mexico City, Mexico', description: 'Maradona inspires dramatic comeback win' },
      { year: 1990, tournament: 'World Cup', stage: 'Final', team1Score: 0, team2Score: 1, winnerCode: 'GER', location: 'Rome, Italy', description: 'Brehme penalty, bitter rematch for Argentina' },
      { year: 2006, tournament: 'World Cup', stage: 'Quarter-Final', team1Score: 1, team2Score: 1, winnerCode: 'GER', location: 'Berlin, Germany', description: 'Germany win on penalties, Lehmann heroics' },
    ],
  },

  // Brazil vs Germany
  {
    team1Code: 'BRA',
    team2Code: 'GER',
    totalMatches: 23,
    team1Wins: 12,
    team2Wins: 5,
    draws: 6,
    team1Goals: 41,
    team2Goals: 32,
    worldCupMatches: 4,
    team1WorldCupWins: 2,
    team2WorldCupWins: 2,
    worldCupDraws: 0,
    lastMatch: '2023-03-27',
    firstMeeting: '1963-05-05',
    notableMatches: [
      { year: 2014, tournament: 'World Cup', stage: 'Semi-Final', team1Score: 1, team2Score: 7, winnerCode: 'GER', location: 'Belo Horizonte, Brazil', description: 'The Mineirazo - Germany\'s historic demolition' },
      { year: 2002, tournament: 'World Cup', stage: 'Final', team1Score: 2, team2Score: 0, winnerCode: 'BRA', location: 'Yokohama, Japan', description: 'Ronaldo brace crowns Brazil\'s 5th title' },
      { year: 1958, tournament: 'World Cup', stage: 'Group Stage', team1Score: 2, team2Score: 0, winnerCode: 'BRA', location: 'Gothenburg, Sweden', description: 'Brazil win group stage clash' },
    ],
  },

  // Brazil vs France
  {
    team1Code: 'BRA',
    team2Code: 'FRA',
    totalMatches: 14,
    team1Wins: 5,
    team2Wins: 4,
    draws: 5,
    team1Goals: 22,
    team2Goals: 21,
    worldCupMatches: 5,
    team1WorldCupWins: 2,
    team2WorldCupWins: 2,
    worldCupDraws: 1,
    lastMatch: '2023-03-26',
    firstMeeting: '1930-07-22',
    notableMatches: [
      { year: 1998, tournament: 'World Cup', stage: 'Final', team1Score: 0, team2Score: 3, winnerCode: 'FRA', location: 'Saint-Denis, France', description: 'Zidane double, France first title' },
      { year: 2006, tournament: 'World Cup', stage: 'Quarter-Final', team1Score: 0, team2Score: 1, winnerCode: 'FRA', location: 'Frankfurt, Germany', description: 'Henry goal ends Brazil\'s run' },
      { year: 1986, tournament: 'World Cup', stage: 'Quarter-Final', team1Score: 1, team2Score: 1, winnerCode: 'FRA', location: 'Guadalajara, Mexico', description: 'France win on penalties, Platini era' },
      { year: 1958, tournament: 'World Cup', stage: 'Semi-Final', team1Score: 5, team2Score: 2, winnerCode: 'BRA', location: 'Stockholm, Sweden', description: 'Pelé hat-trick, Brazil cruise to final' },
    ],
  },

  // ========== CONCACAF RIVALRIES ==========

  // USA vs Mexico
  {
    team1Code: 'MEX',
    team2Code: 'USA',
    totalMatches: 76,
    team1Wins: 36,
    team2Wins: 23,
    draws: 17,
    team1Goals: 139,
    team2Goals: 99,
    worldCupMatches: 2,
    team1WorldCupWins: 0,
    team2WorldCupWins: 0,
    worldCupDraws: 2,
    lastMatch: '2024-10-15',
    firstMeeting: '1934-05-24',
    notableMatches: [
      { year: 2022, tournament: 'World Cup Qualifier', team1Score: 0, team2Score: 0, location: 'Mexico City, Mexico', description: 'Crucial qualifier draw at Azteca' },
      { year: 2021, tournament: 'Nations League Final', team1Score: 2, team2Score: 3, winnerCode: 'USA', location: 'Denver, USA', description: 'Pulisic penalty wins it in extra time' },
      { year: 2002, tournament: 'World Cup', stage: 'Round of 16', team1Score: 0, team2Score: 2, winnerCode: 'USA', location: 'Jeonju, South Korea', description: 'Dos a Cero - USA\'s famous World Cup upset' },
      { year: 1934, tournament: 'World Cup Qualifier', team1Score: 4, team2Score: 2, winnerCode: 'MEX', location: 'Rome, Italy', description: 'First ever World Cup meeting' },
    ],
  },

  // USA vs Canada
  {
    team1Code: 'CAN',
    team2Code: 'USA',
    totalMatches: 74,
    team1Wins: 13,
    team2Wins: 41,
    draws: 20,
    team1Goals: 58,
    team2Goals: 117,
    worldCupMatches: 0,
    team1WorldCupWins: 0,
    team2WorldCupWins: 0,
    worldCupDraws: 0,
    lastMatch: '2024-09-07',
    firstMeeting: '1885-11-28',
    notableMatches: [
      { year: 2022, tournament: 'World Cup Qualifier', team1Score: 2, team2Score: 0, winnerCode: 'CAN', location: 'Hamilton, Canada', description: 'Canada defeat USA in qualifier' },
      { year: 2021, tournament: 'Nations League', team1Score: 0, team2Score: 1, winnerCode: 'USA', location: 'Nashville, USA', description: 'USA clinch Nations League' },
    ],
  },

  // Mexico vs Canada
  {
    team1Code: 'CAN',
    team2Code: 'MEX',
    totalMatches: 37,
    team1Wins: 5,
    team2Wins: 23,
    draws: 9,
    team1Goals: 26,
    team2Goals: 75,
    worldCupMatches: 0,
    team1WorldCupWins: 0,
    team2WorldCupWins: 0,
    worldCupDraws: 0,
    lastMatch: '2024-09-10',
    firstMeeting: '1957-03-20',
    notableMatches: [
      { year: 2021, tournament: 'Gold Cup', stage: 'Semi-Final', team1Score: 0, team2Score: 2, winnerCode: 'MEX', location: 'Houston, USA', description: 'Mexico reach Gold Cup final' },
      { year: 2022, tournament: 'World Cup Qualifier', team1Score: 2, team2Score: 1, winnerCode: 'CAN', location: 'Edmonton, Canada', description: 'Canada upset Mexico in freezing conditions' },
    ],
  },

  // ========== ASIAN RIVALRIES ==========

  // Japan vs South Korea
  {
    team1Code: 'JPN',
    team2Code: 'KOR',
    totalMatches: 85,
    team1Wins: 16,
    team2Wins: 44,
    draws: 25,
    team1Goals: 75,
    team2Goals: 142,
    worldCupMatches: 0,
    team1WorldCupWins: 0,
    team2WorldCupWins: 0,
    worldCupDraws: 0,
    lastMatch: '2024-03-21',
    firstMeeting: '1954-03-07',
    notableMatches: [
      { year: 2011, tournament: 'Asian Cup', stage: 'Semi-Final', team1Score: 2, team2Score: 2, winnerCode: 'JPN', location: 'Doha, Qatar', description: 'Japan win on penalties, reach final' },
      { year: 2019, tournament: 'Asian Cup', stage: 'Round of 16', team1Score: 1, team2Score: 0, winnerCode: 'JPN', location: 'Abu Dhabi, UAE', description: 'Shiotani goal secures Japan win' },
    ],
  },

  // Japan vs Australia
  {
    team1Code: 'AUS',
    team2Code: 'JPN',
    totalMatches: 24,
    team1Wins: 7,
    team2Wins: 12,
    draws: 5,
    team1Goals: 31,
    team2Goals: 40,
    worldCupMatches: 1,
    team1WorldCupWins: 0,
    team2WorldCupWins: 1,
    worldCupDraws: 0,
    lastMatch: '2024-10-15',
    firstMeeting: '1963-10-13',
    notableMatches: [
      { year: 2006, tournament: 'World Cup', stage: 'Group Stage', team1Score: 3, team2Score: 1, winnerCode: 'AUS', location: 'Kaiserslautern, Germany', description: 'Australia dramatic late comeback' },
      { year: 2011, tournament: 'Asian Cup', stage: 'Final', team1Score: 0, team2Score: 1, winnerCode: 'JPN', location: 'Doha, Qatar', description: 'Lee goal in extra time wins it for Japan' },
    ],
  },

  // Iran vs Saudi Arabia
  {
    team1Code: 'IRN',
    team2Code: 'KSA',
    totalMatches: 16,
    team1Wins: 5,
    team2Wins: 5,
    draws: 6,
    team1Goals: 19,
    team2Goals: 17,
    worldCupMatches: 0,
    team1WorldCupWins: 0,
    team2WorldCupWins: 0,
    worldCupDraws: 0,
    lastMatch: '2023-06-12',
    firstMeeting: '1975-09-01',
    notableMatches: [
      { year: 2019, tournament: 'Asian Cup', stage: 'Group Stage', team1Score: 0, team2Score: 2, winnerCode: 'KSA', location: 'Abu Dhabi, UAE', description: 'Saudi Arabia upset Iran' },
    ],
  },

  // ========== AFRICAN RIVALRIES ==========

  // Senegal vs Ghana
  {
    team1Code: 'GHA',
    team2Code: 'SEN',
    totalMatches: 19,
    team1Wins: 6,
    team2Wins: 6,
    draws: 7,
    team1Goals: 19,
    team2Goals: 17,
    worldCupMatches: 0,
    team1WorldCupWins: 0,
    team2WorldCupWins: 0,
    worldCupDraws: 0,
    lastMatch: '2024-03-26',
    firstMeeting: '1963-03-24',
    notableMatches: [
      { year: 2022, tournament: 'Africa Cup of Nations', stage: 'Final', team1Score: 0, team2Score: 0, winnerCode: 'SEN', location: 'Yaoundé, Cameroon', description: 'Mané wins AFCON for Senegal on penalties' },
      { year: 2002, tournament: 'Africa Cup of Nations', stage: 'Quarter-Final', team1Score: 1, team2Score: 0, winnerCode: 'GHA', location: 'Bamako, Mali', description: 'Ghana advances to semi-final' },
    ],
  },

  // Morocco vs Algeria
  {
    team1Code: 'ALG',
    team2Code: 'MAR',
    totalMatches: 35,
    team1Wins: 15,
    team2Wins: 7,
    draws: 13,
    team1Goals: 42,
    team2Goals: 31,
    worldCupMatches: 0,
    team1WorldCupWins: 0,
    team2WorldCupWins: 0,
    worldCupDraws: 0,
    lastMatch: '2024-01-13',
    firstMeeting: '1957-01-01',
    notableMatches: [
      { year: 2019, tournament: 'Africa Cup of Nations', stage: 'Group Stage', team1Score: 0, team2Score: 1, winnerCode: 'MAR', location: 'Cairo, Egypt', description: 'Morocco shock Algeria' },
    ],
  },

  // Nigeria vs Cameroon
  {
    team1Code: 'CMR',
    team2Code: 'NGA',
    totalMatches: 40,
    team1Wins: 14,
    team2Wins: 16,
    draws: 10,
    team1Goals: 48,
    team2Goals: 51,
    worldCupMatches: 1,
    team1WorldCupWins: 1,
    team2WorldCupWins: 0,
    worldCupDraws: 0,
    lastMatch: '2023-09-12',
    firstMeeting: '1960-11-06',
    notableMatches: [
      { year: 1994, tournament: 'World Cup', stage: 'Round of 16', team1Score: 1, team2Score: 2, winnerCode: 'NGA', location: 'Boston, USA', description: 'Nigeria comeback victory' },
      { year: 2000, tournament: 'Africa Cup of Nations', stage: 'Final', team1Score: 2, team2Score: 2, winnerCode: 'CMR', location: 'Lagos, Nigeria', description: 'Cameroon win on penalties in Lagos' },
    ],
  },

  // Egypt vs Algeria
  {
    team1Code: 'ALG',
    team2Code: 'EGY',
    totalMatches: 28,
    team1Wins: 9,
    team2Wins: 11,
    draws: 8,
    team1Goals: 33,
    team2Goals: 35,
    worldCupMatches: 0,
    team1WorldCupWins: 0,
    team2WorldCupWins: 0,
    worldCupDraws: 0,
    lastMatch: '2023-06-16',
    firstMeeting: '1959-08-25',
    notableMatches: [
      { year: 2009, tournament: 'World Cup Qualifier', team1Score: 1, team2Score: 0, winnerCode: 'ALG', location: 'Omdurman, Sudan', description: 'Algeria qualify for 2010 World Cup in playoff' },
      { year: 2010, tournament: 'Africa Cup of Nations', stage: 'Semi-Final', team1Score: 0, team2Score: 4, winnerCode: 'EGY', location: 'Benguela, Angola', description: 'Egypt rout Algeria to reach final' },
    ],
  },

  // ========== CROSS-CONTINENTAL NOTABLE MATCHUPS ==========

  // Brazil vs Italy
  {
    team1Code: 'BRA',
    team2Code: 'ITA',
    totalMatches: 19,
    team1Wins: 10,
    team2Wins: 5,
    draws: 4,
    team1Goals: 31,
    team2Goals: 20,
    worldCupMatches: 5,
    team1WorldCupWins: 3,
    team2WorldCupWins: 2,
    worldCupDraws: 0,
    lastMatch: '2024-10-12',
    firstMeeting: '1956-04-25',
    notableMatches: [
      { year: 1970, tournament: 'World Cup', stage: 'Final', team1Score: 4, team2Score: 1, winnerCode: 'BRA', location: 'Mexico City, Mexico', description: 'Brazil win their third title in style' },
      { year: 1994, tournament: 'World Cup', stage: 'Final', team1Score: 0, team2Score: 0, winnerCode: 'BRA', location: 'Los Angeles, USA', description: 'Brazil win on penalties, Baggio miss' },
      { year: 1982, tournament: 'World Cup', stage: 'Second Round', team1Score: 2, team2Score: 3, winnerCode: 'ITA', location: 'Barcelona, Spain', description: 'Paolo Rossi hat-trick stuns Brazil' },
    ],
  },

  // Spain vs Netherlands
  {
    team1Code: 'ESP',
    team2Code: 'NED',
    totalMatches: 14,
    team1Wins: 5,
    team2Wins: 5,
    draws: 4,
    team1Goals: 19,
    team2Goals: 20,
    worldCupMatches: 3,
    team1WorldCupWins: 2,
    team2WorldCupWins: 1,
    worldCupDraws: 0,
    lastMatch: '2023-11-16',
    firstMeeting: '1920-08-29',
    notableMatches: [
      { year: 2010, tournament: 'World Cup', stage: 'Final', team1Score: 1, team2Score: 0, winnerCode: 'ESP', location: 'Johannesburg, South Africa', description: 'Iniesta goal wins Spain first World Cup' },
      { year: 2014, tournament: 'World Cup', stage: 'Group Stage', team1Score: 1, team2Score: 5, winnerCode: 'NED', location: 'Salvador, Brazil', description: 'Netherlands destroy defending champions' },
    ],
  },

  // Germany vs Italy
  {
    team1Code: 'GER',
    team2Code: 'ITA',
    totalMatches: 37,
    team1Wins: 9,
    team2Wins: 15,
    draws: 13,
    team1Goals: 50,
    team2Goals: 58,
    worldCupMatches: 5,
    team1WorldCupWins: 1,
    team2WorldCupWins: 3,
    worldCupDraws: 1,
    lastMatch: '2022-06-14',
    firstMeeting: '1923-01-28',
    notableMatches: [
      { year: 1970, tournament: 'World Cup', stage: 'Semi-Final', team1Score: 3, team2Score: 4, winnerCode: 'ITA', location: 'Mexico City, Mexico', description: 'Game of the Century, Beckenbauer plays injured' },
      { year: 2006, tournament: 'World Cup', stage: 'Semi-Final', team1Score: 0, team2Score: 2, winnerCode: 'ITA', location: 'Dortmund, Germany', description: 'Late goals send Italy to final' },
      { year: 2016, tournament: 'Euro 2016', stage: 'Quarter-Final', team1Score: 1, team2Score: 1, winnerCode: 'GER', location: 'Bordeaux, France', description: 'Germany finally beat Italy on penalties' },
    ],
  },

  // England vs France
  {
    team1Code: 'ENG',
    team2Code: 'FRA',
    totalMatches: 31,
    team1Wins: 17,
    team2Wins: 9,
    draws: 5,
    team1Goals: 70,
    team2Goals: 43,
    worldCupMatches: 2,
    team1WorldCupWins: 0,
    team2WorldCupWins: 2,
    worldCupDraws: 0,
    lastMatch: '2022-12-10',
    firstMeeting: '1923-05-10',
    notableMatches: [
      { year: 2022, tournament: 'World Cup', stage: 'Quarter-Final', team1Score: 1, team2Score: 2, winnerCode: 'FRA', location: 'Al Khor, Qatar', description: 'Kane missed penalty, France advance' },
      { year: 1982, tournament: 'World Cup', stage: 'Group Stage', team1Score: 3, team2Score: 1, winnerCode: 'ENG', location: 'Bilbao, Spain', description: 'Bryan Robson scores in 27 seconds' },
    ],
  },

  // Croatia vs Brazil
  {
    team1Code: 'BRA',
    team2Code: 'CRO',
    totalMatches: 5,
    team1Wins: 3,
    team2Wins: 1,
    draws: 1,
    team1Goals: 8,
    team2Goals: 5,
    worldCupMatches: 3,
    team1WorldCupWins: 2,
    team2WorldCupWins: 1,
    worldCupDraws: 0,
    lastMatch: '2022-12-09',
    firstMeeting: '2006-06-13',
    notableMatches: [
      { year: 2022, tournament: 'World Cup', stage: 'Quarter-Final', team1Score: 1, team2Score: 1, winnerCode: 'CRO', location: 'Lusail, Qatar', description: 'Croatia win on penalties, Neymar wonder goal not enough' },
      { year: 2014, tournament: 'World Cup', stage: 'Group Stage', team1Score: 3, team2Score: 1, winnerCode: 'BRA', location: 'São Paulo, Brazil', description: 'Opening match, controversial penalty' },
    ],
  },

  // Morocco vs Spain
  {
    team1Code: 'ESP',
    team2Code: 'MAR',
    totalMatches: 5,
    team1Wins: 2,
    team2Wins: 2,
    draws: 1,
    team1Goals: 6,
    team2Goals: 6,
    worldCupMatches: 2,
    team1WorldCupWins: 0,
    team2WorldCupWins: 1,
    worldCupDraws: 1,
    lastMatch: '2022-12-06',
    firstMeeting: '1961-03-19',
    notableMatches: [
      { year: 2022, tournament: 'World Cup', stage: 'Round of 16', team1Score: 0, team2Score: 0, winnerCode: 'MAR', location: 'Doha, Qatar', description: 'Morocco stun Spain on penalties' },
      { year: 2018, tournament: 'World Cup', stage: 'Group Stage', team1Score: 2, team2Score: 2, location: 'Kaliningrad, Russia', description: 'Dramatic draw, Iago Aspas late equalizer' },
    ],
  },

  // Morocco vs Portugal
  {
    team1Code: 'MAR',
    team2Code: 'POR',
    totalMatches: 5,
    team1Wins: 2,
    team2Wins: 3,
    draws: 0,
    team1Goals: 5,
    team2Goals: 8,
    worldCupMatches: 2,
    team1WorldCupWins: 1,
    team2WorldCupWins: 1,
    worldCupDraws: 0,
    lastMatch: '2022-12-10',
    firstMeeting: '1986-06-11',
    notableMatches: [
      { year: 2022, tournament: 'World Cup', stage: 'Quarter-Final', team1Score: 1, team2Score: 0, winnerCode: 'MAR', location: 'Doha, Qatar', description: 'Morocco reach semi-finals, first African team' },
      { year: 1986, tournament: 'World Cup', stage: 'Group Stage', team1Score: 3, team2Score: 1, winnerCode: 'MAR', location: 'Guadalajara, Mexico', description: 'Morocco upset Portugal' },
    ],
  },

  // Japan vs Germany
  {
    team1Code: 'GER',
    team2Code: 'JPN',
    totalMatches: 5,
    team1Wins: 3,
    team2Wins: 2,
    draws: 0,
    team1Goals: 12,
    team2Goals: 6,
    worldCupMatches: 1,
    team1WorldCupWins: 0,
    team2WorldCupWins: 1,
    worldCupDraws: 0,
    lastMatch: '2023-09-09',
    firstMeeting: '2004-12-16',
    notableMatches: [
      { year: 2022, tournament: 'World Cup', stage: 'Group Stage', team1Score: 1, team2Score: 2, winnerCode: 'JPN', location: 'Doha, Qatar', description: 'Japan shock Germany with comeback' },
    ],
  },

  // Japan vs Spain
  {
    team1Code: 'ESP',
    team2Code: 'JPN',
    totalMatches: 4,
    team1Wins: 2,
    team2Wins: 1,
    draws: 1,
    team1Goals: 6,
    team2Goals: 4,
    worldCupMatches: 1,
    team1WorldCupWins: 0,
    team2WorldCupWins: 1,
    worldCupDraws: 0,
    lastMatch: '2022-12-01',
    firstMeeting: '2001-06-03',
    notableMatches: [
      { year: 2022, tournament: 'World Cup', stage: 'Group Stage', team1Score: 1, team2Score: 2, winnerCode: 'JPN', location: 'Doha, Qatar', description: 'Japan top group, Spain through as runners-up' },
    ],
  },

  // Saudi Arabia vs Argentina
  {
    team1Code: 'ARG',
    team2Code: 'KSA',
    totalMatches: 4,
    team1Wins: 2,
    team2Wins: 1,
    draws: 1,
    team1Goals: 7,
    team2Goals: 4,
    worldCupMatches: 2,
    team1WorldCupWins: 1,
    team2WorldCupWins: 1,
    worldCupDraws: 0,
    lastMatch: '2022-11-22',
    firstMeeting: '1992-02-19',
    notableMatches: [
      { year: 2022, tournament: 'World Cup', stage: 'Group Stage', team1Score: 1, team2Score: 2, winnerCode: 'KSA', location: 'Lusail, Qatar', description: 'Saudi Arabia stun Argentina in biggest WC upset' },
      { year: 1998, tournament: 'World Cup', stage: 'Group Stage', team1Score: 2, team2Score: 1, winnerCode: 'ARG', location: 'Paris, France', description: 'Argentina edge past Saudi Arabia' },
    ],
  },
];

// ============================================================================
// Main Function
// ============================================================================

async function seedHeadToHead() {
  console.log('========================================');
  console.log('World Cup Head-to-Head Seed Script');
  console.log('========================================');
  console.log(`Mode: ${DRY_RUN ? 'DRY RUN (no data will be uploaded)' : 'LIVE (uploading to Firestore)'}`);
  console.log('');

  console.log(`Processing ${HEAD_TO_HEAD_DATA.length} head-to-head records...`);
  console.log('');

  let successCount = 0;
  let errorCount = 0;

  for (const h2h of HEAD_TO_HEAD_DATA) {
    try {
      // Generate document ID - sort codes alphabetically for consistency
      const codes = [h2h.team1Code, h2h.team2Code].sort();
      const docId = `${codes[0]}_${codes[1]}`;

      console.log(`Processing: ${h2h.team1Code} vs ${h2h.team2Code} (${docId})`);

      const h2hDoc = {
        id: docId,
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
        lastMatch: h2h.lastMatch || null,
        firstMeeting: h2h.firstMeeting || null,
        notableMatches: h2h.notableMatches.map(match => ({
          year: match.year,
          tournament: match.tournament,
          stage: match.stage || null,
          team1Score: match.team1Score,
          team2Score: match.team2Score,
          winnerCode: match.winnerCode || null,
          location: match.location || null,
          description: match.description || null,
        })),
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      if (DRY_RUN) {
        console.log(`  [DRY RUN] Would upload: ${h2h.team1Code} vs ${h2h.team2Code}`);
        console.log(`    - Total Matches: ${h2h.totalMatches}`);
        console.log(`    - World Cup Matches: ${h2h.worldCupMatches}`);
        console.log(`    - Notable Matches: ${h2h.notableMatches.length}`);
      } else {
        await db.collection('headToHead').doc(docId).set(h2hDoc, { merge: true });
        console.log(`  Uploaded: ${h2h.team1Code} vs ${h2h.team2Code}`);
      }

      successCount++;
    } catch (error) {
      console.error(`  ERROR processing ${h2h.team1Code} vs ${h2h.team2Code}: ${error}`);
      errorCount++;
    }
  }

  console.log('');
  console.log('========================================');
  console.log('Summary');
  console.log('========================================');
  console.log(`Total records processed: ${HEAD_TO_HEAD_DATA.length}`);
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
  .then(() => {
    console.log('Head-to-head seed script completed.');
    process.exit(0);
  })
  .catch((error) => {
    console.error('Head-to-head seed script failed:', error);
    process.exit(1);
  });

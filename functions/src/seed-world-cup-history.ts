/**
 * Seed World Cup History Script
 *
 * Adds historical World Cup tournament data to Firestore.
 * Includes all tournaments from 1930-2022 with winners, hosts, and key stats.
 *
 * Usage:
 *   npx ts-node src/seed-world-cup-history.ts [--dryRun]
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

interface WorldCupTournament {
  year: number;
  hostCountries: string[];
  hostCodes: string[];
  winner: string;
  winnerCode: string;
  runnerUp: string;
  runnerUpCode: string;
  thirdPlace: string;
  thirdPlaceCode: string;
  fourthPlace: string;
  fourthPlaceCode: string;
  totalTeams: number;
  totalMatches: number;
  totalGoals: number;
  topScorer: string;
  topScorerCountry: string;
  topScorerGoals: number;
  goldenBall?: string;
  goldenBallCountry?: string;
  bestYoungPlayer?: string;
  bestYoungPlayerCountry?: string;
  goldenGlove?: string;
  goldenGloveCountry?: string;
  finalScore: string;
  finalVenue: string;
  finalCity: string;
  finalAttendance: number;
  highlights: string[];
}

interface AllTimeRecord {
  category: string;
  record: string;
  holder: string;
  holderType: 'player' | 'team' | 'match';
  value: number | string;
  details?: string;
}

// ============================================================================
// World Cup Tournament Data (1930-2022)
// ============================================================================

const WORLD_CUP_TOURNAMENTS: WorldCupTournament[] = [
  {
    year: 1930,
    hostCountries: ['Uruguay'],
    hostCodes: ['URU'],
    winner: 'Uruguay',
    winnerCode: 'URU',
    runnerUp: 'Argentina',
    runnerUpCode: 'ARG',
    thirdPlace: 'United States',
    thirdPlaceCode: 'USA',
    fourthPlace: 'Yugoslavia',
    fourthPlaceCode: 'YUG',
    totalTeams: 13,
    totalMatches: 18,
    totalGoals: 70,
    topScorer: 'Guillermo Stábile',
    topScorerCountry: 'Argentina',
    topScorerGoals: 8,
    finalScore: '4-2',
    finalVenue: 'Estadio Centenario',
    finalCity: 'Montevideo',
    finalAttendance: 68346,
    highlights: [
      'First ever FIFA World Cup',
      'Uruguay win inaugural tournament on home soil',
      'Only 4 European teams traveled to South America',
      'USA reaches semi-finals in best World Cup finish',
    ],
  },
  {
    year: 1934,
    hostCountries: ['Italy'],
    hostCodes: ['ITA'],
    winner: 'Italy',
    winnerCode: 'ITA',
    runnerUp: 'Czechoslovakia',
    runnerUpCode: 'CZE',
    thirdPlace: 'Germany',
    thirdPlaceCode: 'GER',
    fourthPlace: 'Austria',
    fourthPlaceCode: 'AUT',
    totalTeams: 16,
    totalMatches: 17,
    totalGoals: 70,
    topScorer: 'Oldřich Nejedlý',
    topScorerCountry: 'Czechoslovakia',
    topScorerGoals: 5,
    finalScore: '2-1 (AET)',
    finalVenue: 'Stadio Nazionale PNF',
    finalCity: 'Rome',
    finalAttendance: 55000,
    highlights: [
      'First World Cup held in Europe',
      'Straight knockout format throughout',
      'Uruguay boycotted as defending champions',
      'Italy win first of two consecutive titles',
    ],
  },
  {
    year: 1938,
    hostCountries: ['France'],
    hostCodes: ['FRA'],
    winner: 'Italy',
    winnerCode: 'ITA',
    runnerUp: 'Hungary',
    runnerUpCode: 'HUN',
    thirdPlace: 'Brazil',
    thirdPlaceCode: 'BRA',
    fourthPlace: 'Sweden',
    fourthPlaceCode: 'SWE',
    totalTeams: 15,
    totalMatches: 18,
    totalGoals: 84,
    topScorer: 'Leônidas',
    topScorerCountry: 'Brazil',
    topScorerGoals: 7,
    finalScore: '4-2',
    finalVenue: 'Stade Olympique de Colombes',
    finalCity: 'Paris',
    finalAttendance: 45000,
    highlights: [
      'Italy become first nation to retain World Cup',
      'Last World Cup before 12-year gap due to WWII',
      'Leônidas "The Black Diamond" dazzles for Brazil',
      'Austria withdrew after German annexation',
    ],
  },
  {
    year: 1950,
    hostCountries: ['Brazil'],
    hostCodes: ['BRA'],
    winner: 'Uruguay',
    winnerCode: 'URU',
    runnerUp: 'Brazil',
    runnerUpCode: 'BRA',
    thirdPlace: 'Sweden',
    thirdPlaceCode: 'SWE',
    fourthPlace: 'Spain',
    fourthPlaceCode: 'ESP',
    totalTeams: 13,
    totalMatches: 22,
    totalGoals: 88,
    topScorer: 'Ademir',
    topScorerCountry: 'Brazil',
    topScorerGoals: 9,
    finalScore: '2-1',
    finalVenue: 'Maracanã Stadium',
    finalCity: 'Rio de Janeiro',
    finalAttendance: 199854,
    highlights: [
      'The Maracanazo - Uruguay shock Brazil in final round',
      'Record attendance of 199,854 at Maracanã',
      'Final round robin format instead of knockout',
      'First World Cup after WWII',
    ],
  },
  {
    year: 1954,
    hostCountries: ['Switzerland'],
    hostCodes: ['SUI'],
    winner: 'West Germany',
    winnerCode: 'GER',
    runnerUp: 'Hungary',
    runnerUpCode: 'HUN',
    thirdPlace: 'Austria',
    thirdPlaceCode: 'AUT',
    fourthPlace: 'Uruguay',
    fourthPlaceCode: 'URU',
    totalTeams: 16,
    totalMatches: 26,
    totalGoals: 140,
    topScorer: 'Sándor Kocsis',
    topScorerCountry: 'Hungary',
    topScorerGoals: 11,
    finalScore: '3-2',
    finalVenue: 'Wankdorf Stadium',
    finalCity: 'Bern',
    finalAttendance: 62500,
    highlights: [
      'Miracle of Bern - West Germany beat unbeaten Hungary',
      'Highest goals-per-game average in World Cup history (5.38)',
      'Hungary entered as heavy favorites, unbeaten for 4 years',
      'Austria beat Switzerland 7-5 in highest-scoring World Cup match',
    ],
  },
  {
    year: 1958,
    hostCountries: ['Sweden'],
    hostCodes: ['SWE'],
    winner: 'Brazil',
    winnerCode: 'BRA',
    runnerUp: 'Sweden',
    runnerUpCode: 'SWE',
    thirdPlace: 'France',
    thirdPlaceCode: 'FRA',
    fourthPlace: 'West Germany',
    fourthPlaceCode: 'GER',
    totalTeams: 16,
    totalMatches: 35,
    totalGoals: 126,
    topScorer: 'Just Fontaine',
    topScorerCountry: 'France',
    topScorerGoals: 13,
    finalScore: '5-2',
    finalVenue: 'Råsunda Stadium',
    finalCity: 'Solna',
    finalAttendance: 51800,
    highlights: [
      '17-year-old Pelé announces himself to the world',
      'Just Fontaine scores record 13 goals in single tournament',
      'Brazil win first World Cup outside South America',
      'First World Cup televised internationally',
    ],
  },
  {
    year: 1962,
    hostCountries: ['Chile'],
    hostCodes: ['CHI'],
    winner: 'Brazil',
    winnerCode: 'BRA',
    runnerUp: 'Czechoslovakia',
    runnerUpCode: 'CZE',
    thirdPlace: 'Chile',
    thirdPlaceCode: 'CHI',
    fourthPlace: 'Yugoslavia',
    fourthPlaceCode: 'YUG',
    totalTeams: 16,
    totalMatches: 32,
    totalGoals: 89,
    topScorer: 'Garrincha/Vavá/Leonel Sánchez/others',
    topScorerCountry: 'Various',
    topScorerGoals: 4,
    finalScore: '3-1',
    finalVenue: 'Estadio Nacional',
    finalCity: 'Santiago',
    finalAttendance: 68679,
    highlights: [
      'Brazil defend title without injured Pelé',
      'Garrincha emerges as tournament star',
      'Battle of Santiago - violent Italy vs Chile match',
      'Host Chile achieve best ever finish (3rd)',
    ],
  },
  {
    year: 1966,
    hostCountries: ['England'],
    hostCodes: ['ENG'],
    winner: 'England',
    winnerCode: 'ENG',
    runnerUp: 'West Germany',
    runnerUpCode: 'GER',
    thirdPlace: 'Portugal',
    thirdPlaceCode: 'POR',
    fourthPlace: 'Soviet Union',
    fourthPlaceCode: 'RUS',
    totalTeams: 16,
    totalMatches: 32,
    totalGoals: 89,
    topScorer: 'Eusébio',
    topScorerCountry: 'Portugal',
    topScorerGoals: 9,
    goldenBall: 'Bobby Charlton',
    goldenBallCountry: 'England',
    finalScore: '4-2 (AET)',
    finalVenue: 'Wembley Stadium',
    finalCity: 'London',
    finalAttendance: 96924,
    highlights: [
      'England win only World Cup on home soil',
      'Geoff Hurst scores only hat-trick in World Cup final',
      'Controversial third goal - "did it cross the line?"',
      'Eusébio announces Portugal as force in world football',
    ],
  },
  {
    year: 1970,
    hostCountries: ['Mexico'],
    hostCodes: ['MEX'],
    winner: 'Brazil',
    winnerCode: 'BRA',
    runnerUp: 'Italy',
    runnerUpCode: 'ITA',
    thirdPlace: 'West Germany',
    thirdPlaceCode: 'GER',
    fourthPlace: 'Uruguay',
    fourthPlaceCode: 'URU',
    totalTeams: 16,
    totalMatches: 32,
    totalGoals: 95,
    topScorer: 'Gerd Müller',
    topScorerCountry: 'West Germany',
    topScorerGoals: 10,
    goldenBall: 'Pelé',
    goldenBallCountry: 'Brazil',
    finalScore: '4-1',
    finalVenue: 'Estadio Azteca',
    finalCity: 'Mexico City',
    finalAttendance: 107412,
    highlights: [
      'Brazil win third title and keep original Jules Rimet trophy permanently',
      'Considered greatest Brazil team ever assembled',
      'Italy vs West Germany "Game of the Century" semi-final',
      'First World Cup broadcast in color',
    ],
  },
  {
    year: 1974,
    hostCountries: ['West Germany'],
    hostCodes: ['GER'],
    winner: 'West Germany',
    winnerCode: 'GER',
    runnerUp: 'Netherlands',
    runnerUpCode: 'NED',
    thirdPlace: 'Poland',
    thirdPlaceCode: 'POL',
    fourthPlace: 'Brazil',
    fourthPlaceCode: 'BRA',
    totalTeams: 16,
    totalMatches: 38,
    totalGoals: 97,
    topScorer: 'Grzegorz Lato',
    topScorerCountry: 'Poland',
    topScorerGoals: 7,
    goldenBall: 'Johan Cruyff',
    goldenBallCountry: 'Netherlands',
    finalScore: '2-1',
    finalVenue: 'Olympiastadion',
    finalCity: 'Munich',
    finalAttendance: 75200,
    highlights: [
      'Dutch "Total Football" revolutionizes the game',
      'Netherlands score before Germany touch ball in final',
      'Johan Cruyff and Dutch team mesmerize world',
      'East and West Germany meet in group stage (1-0 East)',
    ],
  },
  {
    year: 1978,
    hostCountries: ['Argentina'],
    hostCodes: ['ARG'],
    winner: 'Argentina',
    winnerCode: 'ARG',
    runnerUp: 'Netherlands',
    runnerUpCode: 'NED',
    thirdPlace: 'Brazil',
    thirdPlaceCode: 'BRA',
    fourthPlace: 'Italy',
    fourthPlaceCode: 'ITA',
    totalTeams: 16,
    totalMatches: 38,
    totalGoals: 102,
    topScorer: 'Mario Kempes',
    topScorerCountry: 'Argentina',
    topScorerGoals: 6,
    goldenBall: 'Mario Kempes',
    goldenBallCountry: 'Argentina',
    finalScore: '3-1 (AET)',
    finalVenue: 'Estadio Monumental',
    finalCity: 'Buenos Aires',
    finalAttendance: 71483,
    highlights: [
      'Argentina win first World Cup title',
      'Mario Kempes becomes tournament hero',
      'Ticker-tape celebrations become iconic',
      'Tournament held during military dictatorship controversy',
    ],
  },
  {
    year: 1982,
    hostCountries: ['Spain'],
    hostCodes: ['ESP'],
    winner: 'Italy',
    winnerCode: 'ITA',
    runnerUp: 'West Germany',
    runnerUpCode: 'GER',
    thirdPlace: 'Poland',
    thirdPlaceCode: 'POL',
    fourthPlace: 'France',
    fourthPlaceCode: 'FRA',
    totalTeams: 24,
    totalMatches: 52,
    totalGoals: 146,
    topScorer: 'Paolo Rossi',
    topScorerCountry: 'Italy',
    topScorerGoals: 6,
    goldenBall: 'Paolo Rossi',
    goldenBallCountry: 'Italy',
    finalScore: '3-1',
    finalVenue: 'Santiago Bernabéu',
    finalCity: 'Madrid',
    finalAttendance: 90000,
    highlights: [
      'Paolo Rossi wins Golden Boot and Golden Ball after match-fixing ban',
      'Italy eliminate brilliant Brazil with Rossi hat-trick',
      'France vs West Germany semi-final features Schumacher foul on Battiston',
      'First World Cup with 24 teams',
    ],
  },
  {
    year: 1986,
    hostCountries: ['Mexico'],
    hostCodes: ['MEX'],
    winner: 'Argentina',
    winnerCode: 'ARG',
    runnerUp: 'West Germany',
    runnerUpCode: 'GER',
    thirdPlace: 'France',
    thirdPlaceCode: 'FRA',
    fourthPlace: 'Belgium',
    fourthPlaceCode: 'BEL',
    totalTeams: 24,
    totalMatches: 52,
    totalGoals: 132,
    topScorer: 'Gary Lineker',
    topScorerCountry: 'England',
    topScorerGoals: 6,
    goldenBall: 'Diego Maradona',
    goldenBallCountry: 'Argentina',
    finalScore: '3-2',
    finalVenue: 'Estadio Azteca',
    finalCity: 'Mexico City',
    finalAttendance: 114600,
    highlights: [
      'Diego Maradona\'s tournament - Hand of God and Goal of the Century',
      'Argentina vs England quarter-final becomes legendary',
      'Mexico hosts again after Colombia withdraws',
      'Maradona almost single-handedly wins World Cup',
    ],
  },
  {
    year: 1990,
    hostCountries: ['Italy'],
    hostCodes: ['ITA'],
    winner: 'West Germany',
    winnerCode: 'GER',
    runnerUp: 'Argentina',
    runnerUpCode: 'ARG',
    thirdPlace: 'Italy',
    thirdPlaceCode: 'ITA',
    fourthPlace: 'England',
    fourthPlaceCode: 'ENG',
    totalTeams: 24,
    totalMatches: 52,
    totalGoals: 115,
    topScorer: 'Salvatore Schillaci',
    topScorerCountry: 'Italy',
    topScorerGoals: 6,
    goldenBall: 'Salvatore Schillaci',
    goldenBallCountry: 'Italy',
    finalScore: '1-0',
    finalVenue: 'Stadio Olimpico',
    finalCity: 'Rome',
    finalAttendance: 73603,
    highlights: [
      'Last World Cup for West Germany before reunification',
      'Italy\'s "Notti Magiche" (Magical Nights)',
      'Cameroon and Roger Milla inspire African football',
      'England heartbreak on penalties vs West Germany',
    ],
  },
  {
    year: 1994,
    hostCountries: ['United States'],
    hostCodes: ['USA'],
    winner: 'Brazil',
    winnerCode: 'BRA',
    runnerUp: 'Italy',
    runnerUpCode: 'ITA',
    thirdPlace: 'Sweden',
    thirdPlaceCode: 'SWE',
    fourthPlace: 'Bulgaria',
    fourthPlaceCode: 'BUL',
    totalTeams: 24,
    totalMatches: 52,
    totalGoals: 141,
    topScorer: 'Hristo Stoichkov/Oleg Salenko',
    topScorerCountry: 'Bulgaria/Russia',
    topScorerGoals: 6,
    goldenBall: 'Romário',
    goldenBallCountry: 'Brazil',
    finalScore: '0-0 (3-2 pens)',
    finalVenue: 'Rose Bowl',
    finalCity: 'Pasadena',
    finalAttendance: 94194,
    highlights: [
      'First World Cup held in United States',
      'First final decided on penalties - Baggio miss',
      'Maradona expelled for failed drug test',
      'Record average attendance (68,991)',
    ],
  },
  {
    year: 1998,
    hostCountries: ['France'],
    hostCodes: ['FRA'],
    winner: 'France',
    winnerCode: 'FRA',
    runnerUp: 'Brazil',
    runnerUpCode: 'BRA',
    thirdPlace: 'Croatia',
    thirdPlaceCode: 'CRO',
    fourthPlace: 'Netherlands',
    fourthPlaceCode: 'NED',
    totalTeams: 32,
    totalMatches: 64,
    totalGoals: 171,
    topScorer: 'Davor Šuker',
    topScorerCountry: 'Croatia',
    topScorerGoals: 6,
    goldenBall: 'Ronaldo',
    goldenBallCountry: 'Brazil',
    bestYoungPlayer: 'Michael Owen',
    bestYoungPlayerCountry: 'England',
    finalScore: '3-0',
    finalVenue: 'Stade de France',
    finalCity: 'Saint-Denis',
    finalAttendance: 80000,
    highlights: [
      'France win first World Cup on home soil',
      'Zidane heads two goals in final',
      'Ronaldo mysterious illness before final',
      'Croatia reach semi-finals in first World Cup as independent nation',
    ],
  },
  {
    year: 2002,
    hostCountries: ['South Korea', 'Japan'],
    hostCodes: ['KOR', 'JPN'],
    winner: 'Brazil',
    winnerCode: 'BRA',
    runnerUp: 'Germany',
    runnerUpCode: 'GER',
    thirdPlace: 'Turkey',
    thirdPlaceCode: 'TUR',
    fourthPlace: 'South Korea',
    fourthPlaceCode: 'KOR',
    totalTeams: 32,
    totalMatches: 64,
    totalGoals: 161,
    topScorer: 'Ronaldo',
    topScorerCountry: 'Brazil',
    topScorerGoals: 8,
    goldenBall: 'Oliver Kahn',
    goldenBallCountry: 'Germany',
    goldenGlove: 'Oliver Kahn',
    goldenGloveCountry: 'Germany',
    bestYoungPlayer: 'Landon Donovan',
    bestYoungPlayerCountry: 'USA',
    finalScore: '2-0',
    finalVenue: 'International Stadium Yokohama',
    finalCity: 'Yokohama',
    finalAttendance: 69029,
    highlights: [
      'First World Cup held in Asia and co-hosted',
      'Brazil win record 5th title',
      'Ronaldo redemption after 1998 final',
      'South Korea reach semi-finals, Turkey third',
    ],
  },
  {
    year: 2006,
    hostCountries: ['Germany'],
    hostCodes: ['GER'],
    winner: 'Italy',
    winnerCode: 'ITA',
    runnerUp: 'France',
    runnerUpCode: 'FRA',
    thirdPlace: 'Germany',
    thirdPlaceCode: 'GER',
    fourthPlace: 'Portugal',
    fourthPlaceCode: 'POR',
    totalTeams: 32,
    totalMatches: 64,
    totalGoals: 147,
    topScorer: 'Miroslav Klose',
    topScorerCountry: 'Germany',
    topScorerGoals: 5,
    goldenBall: 'Zinedine Zidane',
    goldenBallCountry: 'France',
    goldenGlove: 'Gianluigi Buffon',
    goldenGloveCountry: 'Italy',
    bestYoungPlayer: 'Lukas Podolski',
    bestYoungPlayerCountry: 'Germany',
    finalScore: '1-1 (5-3 pens)',
    finalVenue: 'Olympiastadion',
    finalCity: 'Berlin',
    finalAttendance: 69000,
    highlights: [
      'Zidane headbutt on Materazzi in final',
      'Italy win fourth World Cup title',
      'Germany hosts successful "Summer Fairy Tale"',
      'Italy unbeaten throughout tournament',
    ],
  },
  {
    year: 2010,
    hostCountries: ['South Africa'],
    hostCodes: ['RSA'],
    winner: 'Spain',
    winnerCode: 'ESP',
    runnerUp: 'Netherlands',
    runnerUpCode: 'NED',
    thirdPlace: 'Germany',
    thirdPlaceCode: 'GER',
    fourthPlace: 'Uruguay',
    fourthPlaceCode: 'URU',
    totalTeams: 32,
    totalMatches: 64,
    totalGoals: 145,
    topScorer: 'Thomas Müller/David Villa/Wesley Sneijder/Diego Forlán',
    topScorerCountry: 'Various',
    topScorerGoals: 5,
    goldenBall: 'Diego Forlán',
    goldenBallCountry: 'Uruguay',
    goldenGlove: 'Iker Casillas',
    goldenGloveCountry: 'Spain',
    bestYoungPlayer: 'Thomas Müller',
    bestYoungPlayerCountry: 'Germany',
    finalScore: '1-0 (AET)',
    finalVenue: 'Soccer City',
    finalCity: 'Johannesburg',
    finalAttendance: 84490,
    highlights: [
      'First World Cup held in Africa',
      'Spain win first World Cup with tiki-taka style',
      'Iniesta scores winning goal in final',
      'Vuvuzelas become iconic sound of tournament',
    ],
  },
  {
    year: 2014,
    hostCountries: ['Brazil'],
    hostCodes: ['BRA'],
    winner: 'Germany',
    winnerCode: 'GER',
    runnerUp: 'Argentina',
    runnerUpCode: 'ARG',
    thirdPlace: 'Netherlands',
    thirdPlaceCode: 'NED',
    fourthPlace: 'Brazil',
    fourthPlaceCode: 'BRA',
    totalTeams: 32,
    totalMatches: 64,
    totalGoals: 171,
    topScorer: 'James Rodríguez',
    topScorerCountry: 'Colombia',
    topScorerGoals: 6,
    goldenBall: 'Lionel Messi',
    goldenBallCountry: 'Argentina',
    goldenGlove: 'Manuel Neuer',
    goldenGloveCountry: 'Germany',
    bestYoungPlayer: 'Paul Pogba',
    bestYoungPlayerCountry: 'France',
    finalScore: '1-0 (AET)',
    finalVenue: 'Maracanã Stadium',
    finalCity: 'Rio de Janeiro',
    finalAttendance: 74738,
    highlights: [
      'Germany beat Brazil 7-1 in semi-final (Mineirazo)',
      'Germany win fourth title',
      'Götze scores winner in extra time of final',
      'James Rodríguez wonder goals for Colombia',
    ],
  },
  {
    year: 2018,
    hostCountries: ['Russia'],
    hostCodes: ['RUS'],
    winner: 'France',
    winnerCode: 'FRA',
    runnerUp: 'Croatia',
    runnerUpCode: 'CRO',
    thirdPlace: 'Belgium',
    thirdPlaceCode: 'BEL',
    fourthPlace: 'England',
    fourthPlaceCode: 'ENG',
    totalTeams: 32,
    totalMatches: 64,
    totalGoals: 169,
    topScorer: 'Harry Kane',
    topScorerCountry: 'England',
    topScorerGoals: 6,
    goldenBall: 'Luka Modrić',
    goldenBallCountry: 'Croatia',
    goldenGlove: 'Thibaut Courtois',
    goldenGloveCountry: 'Belgium',
    bestYoungPlayer: 'Kylian Mbappé',
    bestYoungPlayerCountry: 'France',
    finalScore: '4-2',
    finalVenue: 'Luzhniki Stadium',
    finalCity: 'Moscow',
    finalAttendance: 78011,
    highlights: [
      'France win second World Cup title',
      'Croatia reach first final in remarkable run',
      'VAR used for first time at World Cup',
      'Mbappé becomes second teenager to score in final after Pelé',
    ],
  },
  {
    year: 2022,
    hostCountries: ['Qatar'],
    hostCodes: ['QAT'],
    winner: 'Argentina',
    winnerCode: 'ARG',
    runnerUp: 'France',
    runnerUpCode: 'FRA',
    thirdPlace: 'Croatia',
    thirdPlaceCode: 'CRO',
    fourthPlace: 'Morocco',
    fourthPlaceCode: 'MAR',
    totalTeams: 32,
    totalMatches: 64,
    totalGoals: 172,
    topScorer: 'Kylian Mbappé',
    topScorerCountry: 'France',
    topScorerGoals: 8,
    goldenBall: 'Lionel Messi',
    goldenBallCountry: 'Argentina',
    goldenGlove: 'Emiliano Martínez',
    goldenGloveCountry: 'Argentina',
    bestYoungPlayer: 'Enzo Fernández',
    bestYoungPlayerCountry: 'Argentina',
    finalScore: '3-3 (4-2 pens)',
    finalVenue: 'Lusail Stadium',
    finalCity: 'Lusail',
    finalAttendance: 88966,
    highlights: [
      'Greatest World Cup final ever - Messi vs Mbappé',
      'Messi finally wins World Cup in likely last tournament',
      'Morocco become first African team to reach semi-finals',
      'First winter World Cup (November-December)',
    ],
  },
];

// ============================================================================
// All-Time World Cup Records
// ============================================================================

const ALL_TIME_RECORDS: AllTimeRecord[] = [
  // Player Records
  { category: 'Most Goals (Career)', record: 'Most World Cup goals all-time', holder: 'Miroslav Klose', holderType: 'player', value: 16, details: 'Germany - 2002, 2006, 2010, 2014' },
  { category: 'Most Goals (Single Tournament)', record: 'Most goals in single World Cup', holder: 'Just Fontaine', holderType: 'player', value: 13, details: 'France - 1958' },
  { category: 'Most Appearances', record: 'Most World Cup matches played', holder: 'Lothar Matthäus', holderType: 'player', value: 25, details: 'Germany - 1982-1998' },
  { category: 'Most Finals Played', record: 'Most World Cup finals', holder: 'Cafu', holderType: 'player', value: 3, details: 'Brazil - 1994, 1998, 2002 (won 2)' },
  { category: 'Oldest Goalscorer', record: 'Oldest player to score', holder: 'Roger Milla', holderType: 'player', value: '42 years 39 days', details: 'Cameroon vs Russia 1994' },
  { category: 'Youngest Goalscorer', record: 'Youngest player to score', holder: 'Pelé', holderType: 'player', value: '17 years 239 days', details: 'Brazil vs Wales 1958' },
  { category: 'Most Goals (Final)', record: 'Most goals in World Cup final', holder: 'Kylian Mbappé/Geoff Hurst', holderType: 'player', value: 3, details: 'Hat-trick in final (1966, 2022)' },
  { category: 'Fastest Goal', record: 'Fastest goal from kick-off', holder: 'Hakan Şükür', holderType: 'player', value: '10.8 seconds', details: 'Turkey vs South Korea 2002' },
  { category: 'Most Tournaments (Player)', record: 'Most World Cups participated', holder: 'Lionel Messi/Antonio Carbajal/Rafael Márquez/Lothar Matthäus/Gianluigi Buffon', holderType: 'player', value: 5, details: 'Various' },

  // Team Records
  { category: 'Most Titles', record: 'Most World Cup wins', holder: 'Brazil', holderType: 'team', value: 5, details: '1958, 1962, 1970, 1994, 2002' },
  { category: 'Most Finals', record: 'Most World Cup final appearances', holder: 'Germany', holderType: 'team', value: 8, details: 'Won 4, Lost 4' },
  { category: 'Most Appearances', record: 'Most World Cup tournaments', holder: 'Brazil', holderType: 'team', value: 22, details: 'Never missed a World Cup' },
  { category: 'Most Consecutive Titles', record: 'Back-to-back World Cup wins', holder: 'Italy/Brazil', holderType: 'team', value: 2, details: 'Italy 1934-38, Brazil 1958-62' },
  { category: 'Highest Win Margin', record: 'Largest victory margin', holder: 'Hungary', holderType: 'match', value: '10-1', details: 'Hungary vs El Salvador 1982' },
  { category: 'Most Goals (Team, Tournament)', record: 'Most goals in single tournament', holder: 'Hungary', holderType: 'team', value: 27, details: 'Hungary 1954' },
  { category: 'Longest Unbeaten Run', record: 'Most consecutive matches unbeaten', holder: 'Brazil', holderType: 'team', value: 13, details: '2002-2010' },

  // Match Records
  { category: 'Highest Scoring Match', record: 'Most goals in single match', holder: 'Austria vs Switzerland', holderType: 'match', value: 12, details: 'Austria 7-5 Switzerland 1954' },
  { category: 'Most Red Cards (Match)', record: 'Most red cards in single match', holder: 'Portugal vs Netherlands', holderType: 'match', value: 4, details: '2006 - "Battle of Nuremberg"' },
  { category: 'Largest Final Win', record: 'Biggest winning margin in final', holder: 'Brazil vs Italy', holderType: 'match', value: '4-1', details: 'Brazil 4-1 Italy 1970' },
  { category: 'Highest Attendance', record: 'Highest World Cup attendance', holder: 'Brazil vs Uruguay', holderType: 'match', value: 199854, details: 'Maracanã 1950' },
];

// ============================================================================
// Main Function
// ============================================================================

async function seedWorldCupHistory() {
  console.log('========================================');
  console.log('World Cup History Seed Script');
  console.log('========================================');
  console.log(`Mode: ${DRY_RUN ? 'DRY RUN (no data will be uploaded)' : 'LIVE (uploading to Firestore)'}`);
  console.log('');

  // Seed Tournaments
  console.log(`Processing ${WORLD_CUP_TOURNAMENTS.length} World Cup tournaments...`);
  console.log('');

  let successCount = 0;
  let errorCount = 0;

  for (const tournament of WORLD_CUP_TOURNAMENTS) {
    try {
      const docId = `wc_${tournament.year}`;
      console.log(`Processing: World Cup ${tournament.year}`);

      const tournamentDoc = {
        id: docId,
        ...tournament,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      if (DRY_RUN) {
        console.log(`  [DRY RUN] Would upload World Cup ${tournament.year}`);
        console.log(`    - Winner: ${tournament.winner}`);
        console.log(`    - Host: ${tournament.hostCountries.join(', ')}`);
      } else {
        await db.collection('worldCupHistory').doc(docId).set(tournamentDoc, { merge: true });
        console.log(`  Uploaded: World Cup ${tournament.year}`);
      }

      successCount++;
    } catch (error) {
      console.error(`  ERROR processing World Cup ${tournament.year}: ${error}`);
      errorCount++;
    }
  }

  // Seed All-Time Records
  console.log('');
  console.log(`Processing ${ALL_TIME_RECORDS.length} all-time records...`);
  console.log('');

  for (const record of ALL_TIME_RECORDS) {
    try {
      const docId = record.category.toLowerCase().replace(/[^a-z0-9]/g, '_');
      console.log(`Processing: ${record.category}`);

      const recordDoc = {
        id: docId,
        ...record,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      if (DRY_RUN) {
        console.log(`  [DRY RUN] Would upload record: ${record.category}`);
        console.log(`    - Holder: ${record.holder}`);
        console.log(`    - Value: ${record.value}`);
      } else {
        await db.collection('worldCupRecords').doc(docId).set(recordDoc, { merge: true });
        console.log(`  Uploaded: ${record.category}`);
      }

      successCount++;
    } catch (error) {
      console.error(`  ERROR processing record ${record.category}: ${error}`);
      errorCount++;
    }
  }

  console.log('');
  console.log('========================================');
  console.log('Summary');
  console.log('========================================');
  console.log(`Total items processed: ${WORLD_CUP_TOURNAMENTS.length + ALL_TIME_RECORDS.length}`);
  console.log(`Successful: ${successCount}`);
  console.log(`Errors: ${errorCount}`);
  console.log('');

  if (DRY_RUN) {
    console.log('This was a DRY RUN. No data was uploaded.');
    console.log('Run without --dryRun to upload to Firestore.');
  }
}

// Run the script
seedWorldCupHistory()
  .then(() => {
    console.log('World Cup history seed script completed.');
    process.exit(0);
  })
  .catch((error) => {
    console.error('World Cup history seed script failed:', error);
    process.exit(1);
  });

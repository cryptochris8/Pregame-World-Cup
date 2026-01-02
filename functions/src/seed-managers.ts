/**
 * Seed Managers Script
 *
 * Adds manager data for World Cup 2026 teams to Firestore.
 * Uses curated manager data based on actual national team coaches.
 *
 * Usage:
 *   npx ts-node src/seed-managers.ts [--team=USA] [--dryRun]
 *
 * Examples:
 *   npx ts-node src/seed-managers.ts              # Process all teams
 *   npx ts-node src/seed-managers.ts --team=USA   # Process only USA
 *   npx ts-node src/seed-managers.ts --dryRun     # Preview without uploading
 */

import * as admin from 'firebase-admin';
import * as fs from 'fs';
import * as path from 'path';

// ============================================================================
// Configuration
// ============================================================================

const DRY_RUN = process.argv.includes('--dryRun');
const SINGLE_TEAM = process.argv.find(arg => arg.startsWith('--team='))?.split('=')[1];

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

interface ManagerInput {
  firstName: string;
  lastName: string;
  commonName?: string;
  dateOfBirth: string;
  nationality: string;
  photoFileName: string;
  preferredFormation: string;
  coachingStyle: string;
  yearsExperience: number;
  previousTeams: string[];
  trophies: string[];
  careerWins: number;
  careerDraws: number;
  careerLosses: number;
  bio: string;
}

interface TeamManagerData {
  teamName: string;
  fifaCode: string;
  manager: ManagerInput;
}

// ============================================================================
// Manager Data - Based on actual 2024/2025 national team coaches
// ============================================================================

const MANAGERS_DATA: TeamManagerData[] = [
  // ========== USA ==========
  {
    teamName: 'United States',
    fifaCode: 'USA',
    manager: {
      firstName: 'Mauricio',
      lastName: 'Pochettino',
      dateOfBirth: '1972-03-02',
      nationality: 'Argentina',
      photoFileName: 'pochettino.png',
      preferredFormation: '4-3-3',
      coachingStyle: 'High Press',
      yearsExperience: 15,
      previousTeams: ['Espanyol', 'Southampton', 'Tottenham', 'PSG', 'Chelsea'],
      trophies: ['Ligue 1 2021-22'],
      careerWins: 320,
      careerDraws: 120,
      careerLosses: 140,
      bio: 'Argentine tactician known for developing young talent and implementing high-intensity pressing football. Appointed to lead USA into their home World Cup.'
    }
  },
  // ========== Mexico ==========
  {
    teamName: 'Mexico',
    fifaCode: 'MEX',
    manager: {
      firstName: 'Javier',
      lastName: 'Aguirre',
      dateOfBirth: '1958-12-01',
      nationality: 'Mexico',
      photoFileName: 'aguirre.png',
      preferredFormation: '4-4-2',
      coachingStyle: 'Pragmatic',
      yearsExperience: 30,
      previousTeams: ['Pachuca', 'Osasuna', 'Atletico Madrid', 'Zaragoza', 'Espanyol', 'Japan NT', 'Egypt NT'],
      trophies: ['Liga MX titles', 'Copa MX'],
      careerWins: 400,
      careerDraws: 200,
      careerLosses: 180,
      bio: 'Veteran Mexican coach in his third stint with El Tri. Known for pragmatic approach and ability to organize defensively solid teams.'
    }
  },
  // ========== Canada ==========
  {
    teamName: 'Canada',
    fifaCode: 'CAN',
    manager: {
      firstName: 'Jesse',
      lastName: 'Marsch',
      dateOfBirth: '1973-11-08',
      nationality: 'United States',
      photoFileName: 'marsch.png',
      preferredFormation: '4-2-2-2',
      coachingStyle: 'High Press',
      yearsExperience: 12,
      previousTeams: ['Montreal Impact', 'New York Red Bulls', 'RB Salzburg', 'RB Leipzig', 'Leeds United'],
      trophies: ['Austrian Bundesliga', 'Austrian Cup'],
      careerWins: 180,
      careerDraws: 70,
      careerLosses: 90,
      bio: 'American coach who developed through the Red Bull system. Known for implementing gegenpressing and developing young players.'
    }
  },
  // ========== Brazil ==========
  {
    teamName: 'Brazil',
    fifaCode: 'BRA',
    manager: {
      firstName: 'Carlo',
      lastName: 'Ancelotti',
      dateOfBirth: '1959-06-10',
      nationality: 'Italy',
      photoFileName: 'ancelotti.png',
      preferredFormation: '4-3-3',
      coachingStyle: 'Balanced',
      yearsExperience: 30,
      previousTeams: ['Reggiana', 'Parma', 'Juventus', 'AC Milan', 'Chelsea', 'PSG', 'Real Madrid', 'Bayern Munich', 'Napoli', 'Everton'],
      trophies: ['UEFA Champions League x5', 'Serie A x1', 'La Liga x2', 'Premier League x1', 'Ligue 1 x1'],
      careerWins: 650,
      careerDraws: 220,
      careerLosses: 180,
      bio: 'One of the most decorated coaches in football history. The Italian maestro brings elite experience to lead Brazil to World Cup glory on US soil.'
    }
  },
  // ========== Argentina ==========
  {
    teamName: 'Argentina',
    fifaCode: 'ARG',
    manager: {
      firstName: 'Lionel',
      lastName: 'Scaloni',
      dateOfBirth: '1978-05-16',
      nationality: 'Argentina',
      photoFileName: 'scaloni.png',
      preferredFormation: '4-3-3',
      coachingStyle: 'Possession',
      yearsExperience: 7,
      previousTeams: ['Argentina U20', 'Argentina (Assistant)'],
      trophies: ['FIFA World Cup 2022', 'Copa America 2021', 'Copa America 2024', 'Finalissima 2022'],
      careerWins: 55,
      careerDraws: 12,
      careerLosses: 6,
      bio: 'Led Argentina to World Cup glory in 2022 and consecutive Copa America titles. Known for tactical flexibility and creating a united team culture.'
    }
  },
  // ========== France ==========
  {
    teamName: 'France',
    fifaCode: 'FRA',
    manager: {
      firstName: 'Didier',
      lastName: 'Deschamps',
      dateOfBirth: '1968-10-15',
      nationality: 'France',
      photoFileName: 'deschamps.png',
      preferredFormation: '4-3-3',
      coachingStyle: 'Pragmatic',
      yearsExperience: 20,
      previousTeams: ['Monaco', 'Juventus', 'Marseille'],
      trophies: ['FIFA World Cup 2018', 'UEFA Nations League 2021', 'Ligue 1', 'Serie A'],
      careerWins: 420,
      careerDraws: 150,
      careerLosses: 130,
      bio: 'The only person to win World Cup as both player and coach. Deschamps has built France into consistent contenders with pragmatic yet effective football.'
    }
  },
  // ========== England ==========
  {
    teamName: 'England',
    fifaCode: 'ENG',
    manager: {
      firstName: 'Thomas',
      lastName: 'Tuchel',
      dateOfBirth: '1973-08-29',
      nationality: 'Germany',
      photoFileName: 'tuchel.png',
      preferredFormation: '3-4-2-1',
      coachingStyle: 'Tactical',
      yearsExperience: 15,
      previousTeams: ['Mainz 05', 'Borussia Dortmund', 'PSG', 'Chelsea', 'Bayern Munich'],
      trophies: ['UEFA Champions League 2021', 'DFB-Pokal', 'Ligue 1', 'Bundesliga'],
      careerWins: 280,
      careerDraws: 90,
      careerLosses: 100,
      bio: 'German tactician appointed to end England decades-long wait for major tournament success. Known for tactical adaptability and elite preparation.'
    }
  },
  // ========== Spain ==========
  {
    teamName: 'Spain',
    fifaCode: 'ESP',
    manager: {
      firstName: 'Luis',
      lastName: 'de la Fuente',
      dateOfBirth: '1961-06-05',
      nationality: 'Spain',
      photoFileName: 'delafuente.png',
      preferredFormation: '4-3-3',
      coachingStyle: 'Possession',
      yearsExperience: 20,
      previousTeams: ['Athletic Bilbao B', 'Spain U19', 'Spain U21', 'Spain U23'],
      trophies: ['UEFA Euro 2024', 'UEFA Nations League 2023', 'U19 Euro', 'U21 Euro', 'Olympic Silver'],
      careerWins: 150,
      careerDraws: 40,
      careerLosses: 30,
      bio: 'Progressed through Spanish youth system before leading the senior team to Euro 2024 glory with attractive, dominant football.'
    }
  },
  // ========== Germany ==========
  {
    teamName: 'Germany',
    fifaCode: 'GER',
    manager: {
      firstName: 'Julian',
      lastName: 'Nagelsmann',
      dateOfBirth: '1987-07-23',
      nationality: 'Germany',
      photoFileName: 'nagelsmann.png',
      preferredFormation: '4-2-3-1',
      coachingStyle: 'High Press',
      yearsExperience: 10,
      previousTeams: ['Hoffenheim', 'RB Leipzig', 'Bayern Munich'],
      trophies: ['Bundesliga 2022-23'],
      careerWins: 200,
      careerDraws: 60,
      careerLosses: 70,
      bio: 'One of the brightest young coaches in world football. Appointed to rebuild German football ahead of World Cup 2026 with modern, attacking approach.'
    }
  },
  // ========== Netherlands ==========
  {
    teamName: 'Netherlands',
    fifaCode: 'NED',
    manager: {
      firstName: 'Ronald',
      lastName: 'Koeman',
      dateOfBirth: '1963-03-21',
      nationality: 'Netherlands',
      photoFileName: 'koeman.png',
      preferredFormation: '4-3-3',
      coachingStyle: 'Possession',
      yearsExperience: 20,
      previousTeams: ['Vitesse', 'Ajax', 'Benfica', 'PSV', 'Valencia', 'AZ', 'Feyenoord', 'Southampton', 'Everton', 'Barcelona'],
      trophies: ['Eredivisie', 'KNVB Cup'],
      careerWins: 300,
      careerDraws: 100,
      careerLosses: 150,
      bio: 'Dutch legend in his second spell as national team coach. Brings the traditional Dutch philosophy with modern tactical adaptations.'
    }
  },
  // ========== Portugal ==========
  {
    teamName: 'Portugal',
    fifaCode: 'POR',
    manager: {
      firstName: 'Roberto',
      lastName: 'Martinez',
      dateOfBirth: '1973-07-13',
      nationality: 'Spain',
      photoFileName: 'martinez.png',
      preferredFormation: '4-3-3',
      coachingStyle: 'Possession',
      yearsExperience: 17,
      previousTeams: ['Swansea', 'Wigan', 'Everton', 'Belgium NT'],
      trophies: ['FA Cup 2013'],
      careerWins: 280,
      careerDraws: 110,
      careerLosses: 140,
      bio: 'Spanish coach who led Belgium to third place at 2018 World Cup. Now tasked with leading Portugal talented golden generation.'
    }
  },
  // ========== Italy ==========
  {
    teamName: 'Italy',
    fifaCode: 'ITA',
    manager: {
      firstName: 'Luciano',
      lastName: 'Spalletti',
      dateOfBirth: '1959-03-07',
      nationality: 'Italy',
      photoFileName: 'spalletti.png',
      preferredFormation: '4-3-3',
      coachingStyle: 'Tactical',
      yearsExperience: 28,
      previousTeams: ['Empoli', 'Udinese', 'Sampdoria', 'Roma', 'Zenit', 'Inter', 'Napoli'],
      trophies: ['Serie A 2022-23', 'Coppa Italia', 'Russian Premier League'],
      careerWins: 380,
      careerDraws: 180,
      careerLosses: 170,
      bio: 'Masterful Italian tactician who led Napoli to their first Scudetto in 33 years. Brings experience and tactical nous to the Azzurri.'
    }
  },
  // ========== Uruguay ==========
  {
    teamName: 'Uruguay',
    fifaCode: 'URU',
    manager: {
      firstName: 'Marcelo',
      lastName: 'Bielsa',
      dateOfBirth: '1955-07-21',
      nationality: 'Argentina',
      photoFileName: 'bielsa.png',
      preferredFormation: '3-3-1-3',
      coachingStyle: 'High Press',
      yearsExperience: 35,
      previousTeams: ['Newell Old Boys', 'Atlas', 'America', 'Velez', 'Espanyol', 'Argentina NT', 'Chile NT', 'Athletic Bilbao', 'Marseille', 'Lille', 'Leeds United'],
      trophies: ['Olympic Gold 2004', 'Copa America 2024 (3rd)'],
      careerWins: 350,
      careerDraws: 120,
      careerLosses: 180,
      bio: 'Revolutionary coach known as El Loco for his tactical innovation and demanding training methods. One of the most influential coaches in modern football.'
    }
  },
  // ========== Belgium ==========
  {
    teamName: 'Belgium',
    fifaCode: 'BEL',
    manager: {
      firstName: 'Domenico',
      lastName: 'Tedesco',
      dateOfBirth: '1985-09-12',
      nationality: 'Italy',
      photoFileName: 'tedesco.png',
      preferredFormation: '4-3-3',
      coachingStyle: 'Tactical',
      yearsExperience: 8,
      previousTeams: ['Stuttgart', 'Schalke 04', 'RB Leipzig'],
      trophies: [],
      careerWins: 120,
      careerDraws: 50,
      careerLosses: 60,
      bio: 'Young Italian-German coach tasked with transitioning Belgium to a new generation after their golden era.'
    }
  },
  // ========== Colombia ==========
  {
    teamName: 'Colombia',
    fifaCode: 'COL',
    manager: {
      firstName: 'Nestor',
      lastName: 'Lorenzo',
      dateOfBirth: '1966-02-19',
      nationality: 'Argentina',
      photoFileName: 'lorenzo.png',
      preferredFormation: '4-4-2',
      coachingStyle: 'Balanced',
      yearsExperience: 15,
      previousTeams: ['Deportivo Cali (Assistant)', 'Colombia NT (Assistant)', 'Melgar'],
      trophies: ['Copa America 2024 Runner-up'],
      careerWins: 80,
      careerDraws: 30,
      careerLosses: 25,
      bio: 'Former assistant to Jose Pekerman, now leads Colombia resurgence. Guided them to Copa America 2024 final with organized, effective football.'
    }
  },
  // ========== Japan ==========
  {
    teamName: 'Japan',
    fifaCode: 'JPN',
    manager: {
      firstName: 'Hajime',
      lastName: 'Moriyasu',
      dateOfBirth: '1968-08-23',
      nationality: 'Japan',
      photoFileName: 'moriyasu.png',
      preferredFormation: '4-2-3-1',
      coachingStyle: 'High Press',
      yearsExperience: 15,
      previousTeams: ['Sanfrecce Hiroshima', 'Japan U23'],
      trophies: ['J1 League x3', 'Asian Games Gold 2018'],
      careerWins: 200,
      careerDraws: 80,
      careerLosses: 70,
      bio: 'Led Japan to shock wins over Germany and Spain at 2022 World Cup. Known for meticulous preparation and tactical flexibility.'
    }
  },
  // ========== Morocco ==========
  {
    teamName: 'Morocco',
    fifaCode: 'MAR',
    manager: {
      firstName: 'Walid',
      lastName: 'Regragui',
      dateOfBirth: '1975-09-23',
      nationality: 'Morocco',
      photoFileName: 'regragui.png',
      preferredFormation: '4-3-3',
      coachingStyle: 'Defensive',
      yearsExperience: 8,
      previousTeams: ['FUS Rabat', 'Wydad Casablanca'],
      trophies: ['CAF Champions League 2022', 'Botola Pro', 'World Cup 2022 4th Place'],
      careerWins: 100,
      careerDraws: 40,
      careerLosses: 30,
      bio: 'Made history by leading Morocco to 2022 World Cup semi-finals, the first African nation to achieve this. Combines defensive organization with counter-attacking threat.'
    }
  },
  // ========== Senegal ==========
  {
    teamName: 'Senegal',
    fifaCode: 'SEN',
    manager: {
      firstName: 'Aliou',
      lastName: 'Cisse',
      dateOfBirth: '1976-03-24',
      nationality: 'Senegal',
      photoFileName: 'cisse.png',
      preferredFormation: '4-3-3',
      coachingStyle: 'Physical',
      yearsExperience: 10,
      previousTeams: ['Senegal U23'],
      trophies: ['AFCON 2022'],
      careerWins: 60,
      careerDraws: 25,
      careerLosses: 20,
      bio: 'Former captain who led Senegal to their first ever AFCON title in 2022. Known for building physical, well-organized teams.'
    }
  },
  // ========== Croatia ==========
  {
    teamName: 'Croatia',
    fifaCode: 'CRO',
    manager: {
      firstName: 'Zlatko',
      lastName: 'Dalic',
      dateOfBirth: '1966-10-26',
      nationality: 'Croatia',
      photoFileName: 'dalic.png',
      preferredFormation: '4-3-3',
      coachingStyle: 'Possession',
      yearsExperience: 20,
      previousTeams: ['Varteks', 'Rijeka', 'Dinamo Tirana', 'Al-Faisaly', 'Al-Hilal', 'Al-Ain'],
      trophies: ['World Cup 2018 Runner-up', 'World Cup 2022 3rd Place', 'Nations League 2023 Runner-up'],
      careerWins: 200,
      careerDraws: 80,
      careerLosses: 90,
      bio: 'Has led Croatia to unprecedented success including 2018 World Cup final and 2022 third place. Master of tournament football.'
    }
  },
  // ========== South Korea ==========
  {
    teamName: 'South Korea',
    fifaCode: 'KOR',
    manager: {
      firstName: 'Hong',
      lastName: 'Myung-bo',
      dateOfBirth: '1969-02-12',
      nationality: 'South Korea',
      photoFileName: 'hongmyungbo.png',
      preferredFormation: '4-4-2',
      coachingStyle: 'Defensive',
      yearsExperience: 12,
      previousTeams: ['South Korea U23', 'South Korea NT', 'Ulsan Hyundai'],
      trophies: ['K League 1', 'Asian Games Gold'],
      careerWins: 100,
      careerDraws: 50,
      careerLosses: 45,
      bio: 'Legendary defender who captained Korea to 2002 World Cup semi-finals. Returns to lead the national team with defensive expertise.'
    }
  },
  // ========== Ecuador ==========
  {
    teamName: 'Ecuador',
    fifaCode: 'ECU',
    manager: {
      firstName: 'Sebastian',
      lastName: 'Beccacece',
      dateOfBirth: '1981-01-31',
      nationality: 'Argentina',
      photoFileName: 'beccacece.png',
      preferredFormation: '4-3-3',
      coachingStyle: 'High Press',
      yearsExperience: 10,
      previousTeams: ['Defensa y Justicia', 'Independiente', 'Racing Club'],
      trophies: ['Copa Sudamericana 2020 (Defensa y Justicia)'],
      careerWins: 100,
      careerDraws: 50,
      careerLosses: 60,
      bio: 'Former Bielsa disciple known for intense pressing and attacking football. Bringing modern tactical approach to Ecuador.'
    }
  },
  // ========== Chile ==========
  {
    teamName: 'Chile',
    fifaCode: 'CHI',
    manager: {
      firstName: 'Ricardo',
      lastName: 'Gareca',
      dateOfBirth: '1958-02-10',
      nationality: 'Argentina',
      photoFileName: 'gareca.png',
      preferredFormation: '4-2-3-1',
      coachingStyle: 'Balanced',
      yearsExperience: 25,
      previousTeams: ['Talleres', 'Velez Sarsfield', 'America', 'Universitario', 'Peru NT'],
      trophies: ['Copa America Runner-up 2019 (Peru)'],
      careerWins: 280,
      careerDraws: 130,
      careerLosses: 150,
      bio: 'Experienced Argentine coach who transformed Peru into World Cup qualifiers. Now tasked with rebuilding Chile.'
    }
  },
  // ========== Peru ==========
  {
    teamName: 'Peru',
    fifaCode: 'PER',
    manager: {
      firstName: 'Jorge',
      lastName: 'Fossati',
      dateOfBirth: '1952-11-27',
      nationality: 'Uruguay',
      photoFileName: 'fossati.png',
      preferredFormation: '3-5-2',
      coachingStyle: 'Tactical',
      yearsExperience: 35,
      previousTeams: ['Penarol', 'Cerro Porteno', 'LDU Quito', 'Universitario', 'Qatar NT'],
      trophies: ['Uruguayan Primera x2', 'Copa Sudamericana'],
      careerWins: 300,
      careerDraws: 150,
      careerLosses: 180,
      bio: 'Vastly experienced Uruguayan coach with success across South America. Known for tactical flexibility and defensive organization.'
    }
  },
  // ========== Denmark ==========
  {
    teamName: 'Denmark',
    fifaCode: 'DEN',
    manager: {
      firstName: 'Kasper',
      lastName: 'Hjulmand',
      dateOfBirth: '1972-04-09',
      nationality: 'Denmark',
      photoFileName: 'hjulmand.png',
      preferredFormation: '3-4-3',
      coachingStyle: 'Possession',
      yearsExperience: 20,
      previousTeams: ['Lyngby', 'Nordsjaelland', 'Mainz 05'],
      trophies: ['Danish Superliga'],
      careerWins: 180,
      careerDraws: 80,
      careerLosses: 90,
      bio: 'Transformed Denmark into exciting attacking force. Known for player development and building team spirit.'
    }
  },
  // ========== Switzerland ==========
  {
    teamName: 'Switzerland',
    fifaCode: 'SUI',
    manager: {
      firstName: 'Murat',
      lastName: 'Yakin',
      dateOfBirth: '1974-09-15',
      nationality: 'Switzerland',
      photoFileName: 'yakin.png',
      preferredFormation: '3-4-2-1',
      coachingStyle: 'Tactical',
      yearsExperience: 12,
      previousTeams: ['FC Thun', 'Luzern', 'Basel', 'Spartak Moscow', 'Grasshoppers', 'Schaffhausen'],
      trophies: ['Swiss Super League x2'],
      careerWins: 150,
      careerDraws: 70,
      careerLosses: 80,
      bio: 'Former Swiss international who has brought tactical innovation and tournament success to the Nati.'
    }
  },
  // ========== Austria ==========
  {
    teamName: 'Austria',
    fifaCode: 'AUT',
    manager: {
      firstName: 'Ralf',
      lastName: 'Rangnick',
      dateOfBirth: '1958-06-29',
      nationality: 'Germany',
      photoFileName: 'rangnick.png',
      preferredFormation: '4-4-2',
      coachingStyle: 'High Press',
      yearsExperience: 35,
      previousTeams: ['Hoffenheim', 'Schalke 04', 'RB Leipzig', 'Manchester United'],
      trophies: ['German Cup'],
      careerWins: 280,
      careerDraws: 120,
      careerLosses: 150,
      bio: 'Godfather of gegenpressing and architect of the Red Bull football philosophy. Has transformed Austria into a pressing machine.'
    }
  },
  // ========== Poland ==========
  {
    teamName: 'Poland',
    fifaCode: 'POL',
    manager: {
      firstName: 'Michal',
      lastName: 'Probierz',
      dateOfBirth: '1972-02-07',
      nationality: 'Poland',
      photoFileName: 'probierz.png',
      preferredFormation: '3-5-2',
      coachingStyle: 'Attacking',
      yearsExperience: 20,
      previousTeams: ['Jagiellonia', 'Cracovia', 'Lechia Gdansk', 'Widzew Lodz'],
      trophies: ['Ekstraklasa'],
      careerWins: 200,
      careerDraws: 100,
      careerLosses: 120,
      bio: 'Polish coach known for attacking football and tactical flexibility. Bringing fresh approach to the national team.'
    }
  },
  // ========== Serbia ==========
  {
    teamName: 'Serbia',
    fifaCode: 'SRB',
    manager: {
      firstName: 'Dragan',
      lastName: 'Stojkovic',
      commonName: 'Piksi',
      dateOfBirth: '1965-03-03',
      nationality: 'Serbia',
      photoFileName: 'stojkovic.png',
      preferredFormation: '3-4-2-1',
      coachingStyle: 'Technical',
      yearsExperience: 15,
      previousTeams: ['Nagoya Grampus', 'Guangzhou R&F'],
      trophies: ['J1 League', 'Emperor Cup'],
      careerWins: 200,
      careerDraws: 80,
      careerLosses: 70,
      bio: 'Serbian legend known as Piksi. One of the greatest players in Serbian football history, now leading the nation with technical football.'
    }
  },
  // ========== Australia ==========
  {
    teamName: 'Australia',
    fifaCode: 'AUS',
    manager: {
      firstName: 'Tony',
      lastName: 'Popovic',
      dateOfBirth: '1973-07-04',
      nationality: 'Australia',
      photoFileName: 'popovic.png',
      preferredFormation: '4-4-2',
      coachingStyle: 'Physical',
      yearsExperience: 12,
      previousTeams: ['Western Sydney Wanderers', 'Karabukspor', 'Perth Glory', 'Melbourne Victory'],
      trophies: ['AFC Champions League 2014', 'A-League'],
      careerWins: 150,
      careerDraws: 60,
      careerLosses: 80,
      bio: 'Former Socceroos defender who won Asian Champions League as a coach. Brings winning mentality and organization to Australia.'
    }
  },
  // ========== Nigeria ==========
  {
    teamName: 'Nigeria',
    fifaCode: 'NGA',
    manager: {
      firstName: 'Eric Chelle',
      lastName: 'Chelle',
      dateOfBirth: '1977-01-14',
      nationality: 'Mali',
      photoFileName: 'chelle.png',
      preferredFormation: '4-3-3',
      coachingStyle: 'Balanced',
      yearsExperience: 8,
      previousTeams: ['Mali NT', 'MC Oran', 'Algerian clubs'],
      trophies: [],
      careerWins: 60,
      careerDraws: 30,
      careerLosses: 35,
      bio: 'French-Malian coach with experience in African football. Tasked with maximizing Nigeria talented squad.'
    }
  },
  // ========== Cameroon ==========
  {
    teamName: 'Cameroon',
    fifaCode: 'CMR',
    manager: {
      firstName: 'Marc',
      lastName: 'Brys',
      dateOfBirth: '1962-12-15',
      nationality: 'Belgium',
      photoFileName: 'brys.png',
      preferredFormation: '4-2-3-1',
      coachingStyle: 'Tactical',
      yearsExperience: 25,
      previousTeams: ['OH Leuven', 'Sint-Truiden', 'Beerschot'],
      trophies: ['Belgian Second Division'],
      careerWins: 200,
      careerDraws: 100,
      careerLosses: 120,
      bio: 'Experienced Belgian coach bringing European tactical knowledge to the Indomitable Lions.'
    }
  },
  // ========== Ghana ==========
  {
    teamName: 'Ghana',
    fifaCode: 'GHA',
    manager: {
      firstName: 'Otto',
      lastName: 'Addo',
      dateOfBirth: '1975-06-09',
      nationality: 'Germany',
      photoFileName: 'addo.png',
      preferredFormation: '4-2-3-1',
      coachingStyle: 'Tactical',
      yearsExperience: 8,
      previousTeams: ['Borussia Dortmund (Assistant)', 'Ghana NT'],
      trophies: [],
      careerWins: 40,
      careerDraws: 20,
      careerLosses: 25,
      bio: 'German-Ghanaian who played for Ghana at 2006 World Cup. Returned to lead the Black Stars with Bundesliga tactical expertise.'
    }
  },
  // ========== Egypt ==========
  {
    teamName: 'Egypt',
    fifaCode: 'EGY',
    manager: {
      firstName: 'Hossam',
      lastName: 'Hassan',
      dateOfBirth: '1966-08-10',
      nationality: 'Egypt',
      photoFileName: 'hossamhassan.png',
      preferredFormation: '4-3-3',
      coachingStyle: 'Attacking',
      yearsExperience: 15,
      previousTeams: ['Zamalek', 'Egyptian clubs'],
      trophies: ['Egyptian Premier League'],
      careerWins: 150,
      careerDraws: 70,
      careerLosses: 80,
      bio: 'Egyptian legend and all-time top scorer. Known for attacking philosophy and maximizing star players.'
    }
  },
  // ========== Iran ==========
  {
    teamName: 'Iran',
    fifaCode: 'IRN',
    manager: {
      firstName: 'Amir',
      lastName: 'Ghalenoei',
      dateOfBirth: '1964-03-06',
      nationality: 'Iran',
      photoFileName: 'ghalenoei.png',
      preferredFormation: '4-4-2',
      coachingStyle: 'Defensive',
      yearsExperience: 20,
      previousTeams: ['Sepahan', 'Al-Ain', 'Esteghlal', 'Tractor'],
      trophies: ['Iranian Pro League x4', 'AFC Champions League Runner-up'],
      careerWins: 250,
      careerDraws: 100,
      careerLosses: 90,
      bio: 'Most successful Iranian club coach, now leading Team Melli. Known for disciplined, organized teams.'
    }
  },
  // ========== Saudi Arabia ==========
  {
    teamName: 'Saudi Arabia',
    fifaCode: 'KSA',
    manager: {
      firstName: 'Roberto',
      lastName: 'Mancini',
      dateOfBirth: '1964-11-27',
      nationality: 'Italy',
      photoFileName: 'mancini.png',
      preferredFormation: '4-3-3',
      coachingStyle: 'Tactical',
      yearsExperience: 20,
      previousTeams: ['Fiorentina', 'Lazio', 'Inter', 'Manchester City', 'Galatasaray', 'Zenit', 'Italy NT'],
      trophies: ['UEFA Euro 2020', 'Premier League', 'Serie A x3', 'FA Cup'],
      careerWins: 400,
      careerDraws: 150,
      careerLosses: 140,
      bio: 'Euro 2020 winner who shocked the world with Saudi Arabia victory over Argentina at 2022 World Cup. Elite experience at all levels.'
    }
  },
  // ========== Costa Rica ==========
  {
    teamName: 'Costa Rica',
    fifaCode: 'CRC',
    manager: {
      firstName: 'Claudio',
      lastName: 'Vivas',
      dateOfBirth: '1966-12-17',
      nationality: 'Argentina',
      photoFileName: 'vivas.png',
      preferredFormation: '5-4-1',
      coachingStyle: 'Defensive',
      yearsExperience: 15,
      previousTeams: ['Sporting Cristal', 'Bolivar', 'Costa Rica NT (Assistant)'],
      trophies: ['Peruvian Primera', 'Bolivian Primera'],
      careerWins: 150,
      careerDraws: 80,
      careerLosses: 70,
      bio: 'Former Bielsa assistant who knows Costa Rica football deeply from previous stint. Brings organization and discipline.'
    }
  },
  // ========== New Zealand ==========
  {
    teamName: 'New Zealand',
    fifaCode: 'NZL',
    manager: {
      firstName: 'Darren',
      lastName: 'Bazeley',
      dateOfBirth: '1972-10-04',
      nationality: 'New Zealand',
      photoFileName: 'bazeley.png',
      preferredFormation: '4-4-2',
      coachingStyle: 'Physical',
      yearsExperience: 10,
      previousTeams: ['Wellington Phoenix (Assistant)', 'New Zealand U-teams'],
      trophies: [],
      careerWins: 50,
      careerDraws: 30,
      careerLosses: 40,
      bio: 'New Zealand native who has progressed through the national team system. Understands Kiwi football DNA.'
    }
  },
  // ========== Qatar ==========
  {
    teamName: 'Qatar',
    fifaCode: 'QAT',
    manager: {
      firstName: 'Luis',
      lastName: 'Garcia',
      dateOfBirth: '1975-04-24',
      nationality: 'Spain',
      photoFileName: 'luisgarcia.png',
      preferredFormation: '3-4-3',
      coachingStyle: 'Tactical',
      yearsExperience: 10,
      previousTeams: ['Villarreal B', 'Central Coast Mariners'],
      trophies: [],
      careerWins: 80,
      careerDraws: 40,
      careerLosses: 50,
      bio: 'Former Liverpool and Barcelona winger turned coach. Bringing Spanish tactical philosophy to Qatar.'
    }
  },
  // ========== Ivory Coast ==========
  {
    teamName: 'Ivory Coast',
    fifaCode: 'CIV',
    manager: {
      firstName: 'Emerse',
      lastName: 'Fae',
      dateOfBirth: '1984-01-24',
      nationality: 'Ivory Coast',
      photoFileName: 'fae.png',
      preferredFormation: '4-3-3',
      coachingStyle: 'Attacking',
      yearsExperience: 3,
      previousTeams: ['Ivory Coast (Assistant)'],
      trophies: ['AFCON 2024'],
      careerWins: 20,
      careerDraws: 5,
      careerLosses: 5,
      bio: 'Former midfielder who dramatically led Ivory Coast to AFCON 2024 glory on home soil after mid-tournament appointment.'
    }
  },
  // ========== Algeria ==========
  {
    teamName: 'Algeria',
    fifaCode: 'ALG',
    manager: {
      firstName: 'Vladimir',
      lastName: 'Petkovic',
      dateOfBirth: '1963-08-15',
      nationality: 'Bosnia',
      photoFileName: 'petkovic.png',
      preferredFormation: '4-3-3',
      coachingStyle: 'Tactical',
      yearsExperience: 18,
      previousTeams: ['Lazio', 'Switzerland NT', 'Bordeaux'],
      trophies: ['Coppa Italia'],
      careerWins: 180,
      careerDraws: 80,
      careerLosses: 90,
      bio: 'Led Switzerland to Euro 2020 quarter-finals with famous win over France. Brings European experience to Algeria.'
    }
  },
  // ========== Tunisia ==========
  {
    teamName: 'Tunisia',
    fifaCode: 'TUN',
    manager: {
      firstName: 'Faouzi',
      lastName: 'Benzarti',
      dateOfBirth: '1950-11-13',
      nationality: 'Tunisia',
      photoFileName: 'benzarti.png',
      preferredFormation: '4-2-3-1',
      coachingStyle: 'Defensive',
      yearsExperience: 40,
      previousTeams: ['Club Africain', 'Esperance', 'Wydad', 'Tunisia NT'],
      trophies: ['CAF Champions League', 'Tunisian League x5'],
      careerWins: 400,
      careerDraws: 180,
      careerLosses: 150,
      bio: 'Most decorated Tunisian coach in history. Veteran tactician returning to lead Eagles of Carthage.'
    }
  },
  // ========== Jamaica ==========
  {
    teamName: 'Jamaica',
    fifaCode: 'JAM',
    manager: {
      firstName: 'Heimir',
      lastName: 'Hallgrimsson',
      dateOfBirth: '1967-06-10',
      nationality: 'Iceland',
      photoFileName: 'hallgrimsson.png',
      preferredFormation: '4-4-2',
      coachingStyle: 'Defensive',
      yearsExperience: 15,
      previousTeams: ['Iceland NT', 'Iceland (Co-manager)'],
      trophies: ['Euro 2016 Quarter-finals (Iceland)'],
      careerWins: 60,
      careerDraws: 30,
      careerLosses: 40,
      bio: 'Part of the Iceland duo that shocked England at Euro 2016. Bringing organization and giant-killing mentality to the Reggae Boyz.'
    }
  },
  // ========== Honduras ==========
  {
    teamName: 'Honduras',
    fifaCode: 'HON',
    manager: {
      firstName: 'Reinaldo',
      lastName: 'Rueda',
      dateOfBirth: '1957-04-16',
      nationality: 'Colombia',
      photoFileName: 'rueda.png',
      preferredFormation: '4-4-2',
      coachingStyle: 'Pragmatic',
      yearsExperience: 30,
      previousTeams: ['Deportivo Cali', 'Honduras NT', 'Ecuador NT', 'Chile NT', 'Colombia NT', 'Atletico Nacional', 'Flamengo'],
      trophies: ['Copa Libertadores', 'Colombian League'],
      careerWins: 350,
      careerDraws: 150,
      careerLosses: 180,
      bio: 'Vastly experienced Colombian coach who previously led Honduras to 2010 and 2014 World Cups. Returns for another campaign.'
    }
  },
  // ========== Panama ==========
  {
    teamName: 'Panama',
    fifaCode: 'PAN',
    manager: {
      firstName: 'Thomas',
      lastName: 'Christiansen',
      dateOfBirth: '1973-03-29',
      nationality: 'Denmark',
      photoFileName: 'christiansen.png',
      preferredFormation: '4-4-2',
      coachingStyle: 'Balanced',
      yearsExperience: 12,
      previousTeams: ['AEK Larnaca', 'APOEL', 'Leeds United', 'Real Union'],
      trophies: ['Cypriot League', 'Cypriot Cup'],
      careerWins: 150,
      careerDraws: 60,
      careerLosses: 70,
      bio: 'Spanish-born Danish coach who played for Spain. Has brought stability and tactical organization to Panama.'
    }
  },
];

// ============================================================================
// Main Function
// ============================================================================

async function seedManagers() {
  console.log('========================================');
  console.log('World Cup 2026 Manager Seed Script');
  console.log('========================================');
  console.log(`Mode: ${DRY_RUN ? 'DRY RUN (no data will be uploaded)' : 'LIVE (uploading to Firestore)'}`);
  if (SINGLE_TEAM) {
    console.log(`Single Team Mode: ${SINGLE_TEAM}`);
  }
  console.log('');

  const managersToProcess = SINGLE_TEAM
    ? MANAGERS_DATA.filter(t => t.fifaCode === SINGLE_TEAM)
    : MANAGERS_DATA;

  if (managersToProcess.length === 0) {
    console.log(`No teams found${SINGLE_TEAM ? ` matching ${SINGLE_TEAM}` : ''}`);
    return;
  }

  console.log(`Processing ${managersToProcess.length} teams...`);
  console.log('');

  let successCount = 0;
  let errorCount = 0;

  for (const teamData of managersToProcess) {
    try {
      console.log(`Processing: ${teamData.teamName} (${teamData.fifaCode})`);

      const manager = teamData.manager;
      const managerId = `manager_${teamData.fifaCode.toLowerCase()}`;

      const managerDoc = {
        id: managerId,
        firstName: manager.firstName,
        lastName: manager.lastName,
        commonName: manager.commonName || `${manager.firstName} ${manager.lastName}`,
        dateOfBirth: manager.dateOfBirth,
        nationality: manager.nationality,
        currentTeam: teamData.teamName,
        currentTeamCode: teamData.fifaCode,
        photoUrl: `assets/managers/${manager.photoFileName}`,
        preferredFormation: manager.preferredFormation,
        coachingStyle: manager.coachingStyle,
        yearsExperience: manager.yearsExperience,
        previousTeams: manager.previousTeams,
        trophies: manager.trophies,
        careerWins: manager.careerWins,
        careerDraws: manager.careerDraws,
        careerLosses: manager.careerLosses,
        careerWinPercentage: Math.round((manager.careerWins / (manager.careerWins + manager.careerDraws + manager.careerLosses)) * 100),
        bio: manager.bio,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      if (DRY_RUN) {
        console.log(`  [DRY RUN] Would upload manager: ${manager.firstName} ${manager.lastName}`);
        console.log(`    - Formation: ${manager.preferredFormation}`);
        console.log(`    - Style: ${manager.coachingStyle}`);
        console.log(`    - Experience: ${manager.yearsExperience} years`);
      } else {
        await db.collection('managers').doc(managerId).set(managerDoc, { merge: true });
        console.log(`  Uploaded manager: ${manager.firstName} ${manager.lastName}`);
      }

      successCount++;
    } catch (error) {
      console.error(`  ERROR processing ${teamData.teamName}: ${error}`);
      errorCount++;
    }
  }

  console.log('');
  console.log('========================================');
  console.log('Summary');
  console.log('========================================');
  console.log(`Total teams processed: ${managersToProcess.length}`);
  console.log(`Successful: ${successCount}`);
  console.log(`Errors: ${errorCount}`);
  console.log('');

  if (DRY_RUN) {
    console.log('This was a DRY RUN. No data was uploaded.');
    console.log('Run without --dryRun to upload to Firestore.');
  }
}

// Run the script
seedManagers()
  .then(() => {
    console.log('Manager seed script completed.');
    process.exit(0);
  })
  .catch((error) => {
    console.error('Manager seed script failed:', error);
    process.exit(1);
  });

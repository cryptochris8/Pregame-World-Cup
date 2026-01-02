/**
 * Seed Team Players Script
 *
 * Adds player data for World Cup 2026 teams to Firestore.
 * Uses curated player data based on actual national team squads.
 *
 * Usage:
 *   npx ts-node src/seed-team-players.ts [--team=USA] [--dryRun]
 *
 * Examples:
 *   npx ts-node src/seed-team-players.ts              # Process all pending teams
 *   npx ts-node src/seed-team-players.ts --team=USA   # Process only USA
 *   npx ts-node src/seed-team-players.ts --dryRun     # Preview without uploading
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

interface PlayerInput {
  firstName: string;
  lastName: string;
  commonName?: string;
  jerseyNumber: number;
  position: string;
  dateOfBirth: string;
  height: number;
  weight: number;
  preferredFoot: string;
  club: string;
  clubLeague: string;
  marketValue: number;
  caps: number;
  goals: number;
}

interface TeamData {
  name: string;
  fifaCode: string;
  players: PlayerInput[];
}

// ============================================================================
// Team Data - Based on actual 2024/2025 national team squads
// ============================================================================

const TEAMS_DATA: TeamData[] = [
  // ========== USA ==========
  {
    name: 'United States',
    fifaCode: 'USA',
    players: [
      { firstName: 'Matt', lastName: 'Turner', jerseyNumber: 1, position: 'GK', dateOfBirth: '1994-06-24', height: 191, weight: 82, preferredFoot: 'Right', club: 'Nottingham Forest', clubLeague: 'Premier League', marketValue: 5000000, caps: 35, goals: 0 },
      { firstName: 'Sergino', lastName: 'Dest', jerseyNumber: 2, position: 'RB', dateOfBirth: '2000-11-03', height: 175, weight: 68, preferredFoot: 'Right', club: 'PSV Eindhoven', clubLeague: 'Eredivisie', marketValue: 20000000, caps: 30, goals: 2 },
      { firstName: 'Chris', lastName: 'Richards', jerseyNumber: 3, position: 'CB', dateOfBirth: '2000-03-28', height: 188, weight: 82, preferredFoot: 'Right', club: 'Crystal Palace', clubLeague: 'Premier League', marketValue: 15000000, caps: 15, goals: 0 },
      { firstName: 'Tyler', lastName: 'Adams', commonName: 'Adams', jerseyNumber: 4, position: 'CDM', dateOfBirth: '1999-02-14', height: 175, weight: 63, preferredFoot: 'Right', club: 'Bournemouth', clubLeague: 'Premier League', marketValue: 25000000, caps: 45, goals: 1 },
      { firstName: 'Antonee', lastName: 'Robinson', jerseyNumber: 5, position: 'LB', dateOfBirth: '1997-08-08', height: 180, weight: 72, preferredFoot: 'Left', club: 'Fulham', clubLeague: 'Premier League', marketValue: 25000000, caps: 40, goals: 2 },
      { firstName: 'Yunus', lastName: 'Musah', jerseyNumber: 6, position: 'CM', dateOfBirth: '2002-11-29', height: 178, weight: 68, preferredFoot: 'Right', club: 'AC Milan', clubLeague: 'Serie A', marketValue: 20000000, caps: 35, goals: 0 },
      { firstName: 'Gio', lastName: 'Reyna', commonName: 'Reyna', jerseyNumber: 7, position: 'CAM', dateOfBirth: '2002-11-13', height: 185, weight: 75, preferredFoot: 'Right', club: 'Borussia Dortmund', clubLeague: 'Bundesliga', marketValue: 22000000, caps: 25, goals: 4 },
      { firstName: 'Weston', lastName: 'McKennie', jerseyNumber: 8, position: 'CM', dateOfBirth: '1998-08-28', height: 185, weight: 77, preferredFoot: 'Right', club: 'Juventus', clubLeague: 'Serie A', marketValue: 30000000, caps: 55, goals: 10 },
      { firstName: 'Ricardo', lastName: 'Pepi', jerseyNumber: 9, position: 'ST', dateOfBirth: '2003-01-09', height: 185, weight: 70, preferredFoot: 'Right', club: 'PSV Eindhoven', clubLeague: 'Eredivisie', marketValue: 10000000, caps: 20, goals: 7 },
      { firstName: 'Christian', lastName: 'Pulisic', jerseyNumber: 10, position: 'LW', dateOfBirth: '1998-09-18', height: 177, weight: 70, preferredFoot: 'Right', club: 'AC Milan', clubLeague: 'Serie A', marketValue: 55000000, caps: 70, goals: 26 },
      { firstName: 'Brenden', lastName: 'Aaronson', jerseyNumber: 11, position: 'CAM', dateOfBirth: '2000-10-22', height: 178, weight: 68, preferredFoot: 'Left', club: 'Leeds United', clubLeague: 'Championship', marketValue: 18000000, caps: 35, goals: 6 },
      { firstName: 'Miles', lastName: 'Robinson', jerseyNumber: 12, position: 'CB', dateOfBirth: '1997-03-16', height: 188, weight: 82, preferredFoot: 'Right', club: 'Cincinnati FC', clubLeague: 'MLS', marketValue: 8000000, caps: 25, goals: 3 },
      { firstName: 'Tim', lastName: 'Ream', jerseyNumber: 13, position: 'CB', dateOfBirth: '1987-10-05', height: 185, weight: 79, preferredFoot: 'Left', club: 'Fulham', clubLeague: 'Premier League', marketValue: 3000000, caps: 55, goals: 1 },
      { firstName: 'Luca', lastName: 'de la Torre', jerseyNumber: 14, position: 'CM', dateOfBirth: '1998-05-23', height: 175, weight: 68, preferredFoot: 'Right', club: 'Celta Vigo', clubLeague: 'La Liga', marketValue: 5000000, caps: 20, goals: 1 },
      { firstName: 'Johnny', lastName: 'Cardoso', jerseyNumber: 15, position: 'CDM', dateOfBirth: '2001-09-17', height: 183, weight: 75, preferredFoot: 'Right', club: 'Real Betis', clubLeague: 'La Liga', marketValue: 15000000, caps: 15, goals: 0 },
      { firstName: 'Folarin', lastName: 'Balogun', jerseyNumber: 16, position: 'ST', dateOfBirth: '2001-07-03', height: 178, weight: 70, preferredFoot: 'Right', club: 'Monaco', clubLeague: 'Ligue 1', marketValue: 25000000, caps: 15, goals: 5 },
      { firstName: 'Ethan', lastName: 'Horvath', jerseyNumber: 17, position: 'GK', dateOfBirth: '1995-06-09', height: 193, weight: 84, preferredFoot: 'Right', club: 'Cardiff City', clubLeague: 'Championship', marketValue: 2000000, caps: 10, goals: 0 },
      { firstName: 'Cameron', lastName: 'Carter-Vickers', jerseyNumber: 18, position: 'CB', dateOfBirth: '1997-12-31', height: 183, weight: 79, preferredFoot: 'Right', club: 'Celtic', clubLeague: 'Scottish Premiership', marketValue: 12000000, caps: 15, goals: 0 },
      { firstName: 'Josh', lastName: 'Sargent', jerseyNumber: 19, position: 'ST', dateOfBirth: '2000-02-20', height: 185, weight: 77, preferredFoot: 'Right', club: 'Norwich City', clubLeague: 'Championship', marketValue: 12000000, caps: 25, goals: 5 },
      { firstName: 'Timothy', lastName: 'Weah', jerseyNumber: 20, position: 'RW', dateOfBirth: '2000-02-22', height: 183, weight: 72, preferredFoot: 'Right', club: 'Juventus', clubLeague: 'Serie A', marketValue: 18000000, caps: 35, goals: 4 },
      { firstName: 'Joe', lastName: 'Scally', jerseyNumber: 21, position: 'RB', dateOfBirth: '2002-12-31', height: 183, weight: 75, preferredFoot: 'Right', club: 'Borussia Monchengladbach', clubLeague: 'Bundesliga', marketValue: 10000000, caps: 10, goals: 0 },
      { firstName: 'DeAndre', lastName: 'Yedlin', jerseyNumber: 22, position: 'RB', dateOfBirth: '1993-07-09', height: 173, weight: 63, preferredFoot: 'Right', club: 'Cincinnati FC', clubLeague: 'MLS', marketValue: 2000000, caps: 75, goals: 0 },
      { firstName: 'Kellyn', lastName: 'Acosta', jerseyNumber: 23, position: 'CM', dateOfBirth: '1995-07-24', height: 175, weight: 70, preferredFoot: 'Right', club: 'LAFC', clubLeague: 'MLS', marketValue: 4000000, caps: 55, goals: 2 },
      { firstName: 'Zack', lastName: 'Steffen', jerseyNumber: 24, position: 'GK', dateOfBirth: '1995-04-02', height: 191, weight: 86, preferredFoot: 'Right', club: 'Colorado Rapids', clubLeague: 'MLS', marketValue: 3000000, caps: 30, goals: 0 },
      { firstName: 'Mark', lastName: 'McKenzie', jerseyNumber: 25, position: 'CB', dateOfBirth: '1999-02-25', height: 185, weight: 77, preferredFoot: 'Right', club: 'Toulouse', clubLeague: 'Ligue 1', marketValue: 6000000, caps: 10, goals: 0 },
      { firstName: 'Haji', lastName: 'Wright', jerseyNumber: 26, position: 'ST', dateOfBirth: '1998-03-27', height: 191, weight: 79, preferredFoot: 'Right', club: 'Coventry City', clubLeague: 'Championship', marketValue: 5000000, caps: 10, goals: 2 },
    ],
  },

  // ========== MEXICO ==========
  {
    name: 'Mexico',
    fifaCode: 'MEX',
    players: [
      { firstName: 'Guillermo', lastName: 'Ochoa', jerseyNumber: 1, position: 'GK', dateOfBirth: '1985-07-13', height: 183, weight: 78, preferredFoot: 'Right', club: 'Salernitana', clubLeague: 'Serie A', marketValue: 2000000, caps: 135, goals: 0 },
      { firstName: 'Nestor', lastName: 'Araujo', jerseyNumber: 2, position: 'CB', dateOfBirth: '1991-08-29', height: 186, weight: 80, preferredFoot: 'Right', club: 'America', clubLeague: 'Liga MX', marketValue: 4000000, caps: 60, goals: 2 },
      { firstName: 'Carlos', lastName: 'Salcedo', jerseyNumber: 3, position: 'CB', dateOfBirth: '1993-09-29', height: 185, weight: 82, preferredFoot: 'Right', club: 'Cruz Azul', clubLeague: 'Liga MX', marketValue: 3000000, caps: 50, goals: 1 },
      { firstName: 'Edson', lastName: 'Alvarez', jerseyNumber: 4, position: 'CDM', dateOfBirth: '1997-10-24', height: 187, weight: 76, preferredFoot: 'Right', club: 'West Ham', clubLeague: 'Premier League', marketValue: 35000000, caps: 65, goals: 1 },
      { firstName: 'Johan', lastName: 'Vasquez', jerseyNumber: 5, position: 'CB', dateOfBirth: '1998-10-22', height: 188, weight: 80, preferredFoot: 'Right', club: 'Genoa', clubLeague: 'Serie A', marketValue: 8000000, caps: 25, goals: 2 },
      { firstName: 'Gerardo', lastName: 'Arteaga', jerseyNumber: 6, position: 'LB', dateOfBirth: '1998-09-07', height: 173, weight: 70, preferredFoot: 'Left', club: 'Monterrey', clubLeague: 'Liga MX', marketValue: 6000000, caps: 20, goals: 0 },
      { firstName: 'Luis', lastName: 'Chavez', jerseyNumber: 7, position: 'CM', dateOfBirth: '1996-01-15', height: 175, weight: 70, preferredFoot: 'Left', club: 'Pachuca', clubLeague: 'Liga MX', marketValue: 7000000, caps: 25, goals: 4 },
      { firstName: 'Carlos', lastName: 'Rodriguez', jerseyNumber: 8, position: 'CM', dateOfBirth: '1997-01-03', height: 174, weight: 65, preferredFoot: 'Right', club: 'Cruz Azul', clubLeague: 'Liga MX', marketValue: 6000000, caps: 30, goals: 1 },
      { firstName: 'Raul', lastName: 'Jimenez', jerseyNumber: 9, position: 'ST', dateOfBirth: '1991-05-05', height: 187, weight: 76, preferredFoot: 'Right', club: 'Fulham', clubLeague: 'Premier League', marketValue: 12000000, caps: 100, goals: 32 },
      { firstName: 'Orbelin', lastName: 'Pineda', jerseyNumber: 10, position: 'CAM', dateOfBirth: '1996-03-24', height: 169, weight: 60, preferredFoot: 'Right', club: 'AEK Athens', clubLeague: 'Super League Greece', marketValue: 4000000, caps: 50, goals: 6 },
      { firstName: 'Roberto', lastName: 'Alvarado', jerseyNumber: 11, position: 'LW', dateOfBirth: '1998-09-07', height: 170, weight: 64, preferredFoot: 'Right', club: 'Guadalajara', clubLeague: 'Liga MX', marketValue: 6000000, caps: 30, goals: 3 },
      { firstName: 'Hirving', lastName: 'Lozano', commonName: 'Chucky', jerseyNumber: 22, position: 'RW', dateOfBirth: '1995-07-30', height: 175, weight: 70, preferredFoot: 'Right', club: 'PSV Eindhoven', clubLeague: 'Eredivisie', marketValue: 18000000, caps: 70, goals: 16 },
      { firstName: 'Jesus', lastName: 'Gallardo', jerseyNumber: 23, position: 'LB', dateOfBirth: '1994-08-15', height: 172, weight: 66, preferredFoot: 'Left', club: 'Monterrey', clubLeague: 'Liga MX', marketValue: 4000000, caps: 75, goals: 1 },
      { firstName: 'Luis', lastName: 'Romo', jerseyNumber: 24, position: 'CM', dateOfBirth: '1995-06-05', height: 180, weight: 75, preferredFoot: 'Right', club: 'Monterrey', clubLeague: 'Liga MX', marketValue: 7000000, caps: 35, goals: 3 },
      { firstName: 'Jorge', lastName: 'Sanchez', jerseyNumber: 25, position: 'RB', dateOfBirth: '1997-12-10', height: 177, weight: 72, preferredFoot: 'Right', club: 'Cruz Azul', clubLeague: 'Liga MX', marketValue: 5000000, caps: 40, goals: 0 },
      { firstName: 'Santiago', lastName: 'Gimenez', jerseyNumber: 19, position: 'ST', dateOfBirth: '2001-04-18', height: 181, weight: 76, preferredFoot: 'Right', club: 'Feyenoord', clubLeague: 'Eredivisie', marketValue: 35000000, caps: 25, goals: 12 },
      { firstName: 'Alexis', lastName: 'Vega', jerseyNumber: 14, position: 'LW', dateOfBirth: '1997-11-25', height: 172, weight: 68, preferredFoot: 'Right', club: 'Toluca', clubLeague: 'Liga MX', marketValue: 8000000, caps: 35, goals: 6 },
      { firstName: 'Uriel', lastName: 'Antuna', jerseyNumber: 15, position: 'RW', dateOfBirth: '1997-08-21', height: 175, weight: 68, preferredFoot: 'Right', club: 'Cruz Azul', clubLeague: 'Liga MX', marketValue: 5000000, caps: 45, goals: 6 },
      { firstName: 'Hector', lastName: 'Moreno', jerseyNumber: 16, position: 'CB', dateOfBirth: '1988-01-17', height: 182, weight: 77, preferredFoot: 'Right', club: 'Monterrey', clubLeague: 'Liga MX', marketValue: 1500000, caps: 130, goals: 6 },
      { firstName: 'Cesar', lastName: 'Montes', jerseyNumber: 17, position: 'CB', dateOfBirth: '1997-02-24', height: 191, weight: 80, preferredFoot: 'Right', club: 'Almeria', clubLeague: 'La Liga', marketValue: 6000000, caps: 40, goals: 0 },
      { firstName: 'Andres', lastName: 'Guardado', jerseyNumber: 18, position: 'CM', dateOfBirth: '1986-09-28', height: 169, weight: 64, preferredFoot: 'Left', club: 'Leon', clubLeague: 'Liga MX', marketValue: 1000000, caps: 180, goals: 28 },
      { firstName: 'Jesus', lastName: 'Corona', commonName: 'Tecatito', jerseyNumber: 20, position: 'RW', dateOfBirth: '1993-01-06', height: 173, weight: 67, preferredFoot: 'Left', club: 'LAFC', clubLeague: 'MLS', marketValue: 4000000, caps: 75, goals: 10 },
      { firstName: 'Henry', lastName: 'Martin', jerseyNumber: 21, position: 'ST', dateOfBirth: '1992-11-18', height: 180, weight: 75, preferredFoot: 'Right', club: 'America', clubLeague: 'Liga MX', marketValue: 4000000, caps: 45, goals: 11 },
      { firstName: 'Alfredo', lastName: 'Talavera', jerseyNumber: 12, position: 'GK', dateOfBirth: '1982-09-18', height: 186, weight: 84, preferredFoot: 'Right', club: 'Juarez', clubLeague: 'Liga MX', marketValue: 500000, caps: 45, goals: 0 },
      { firstName: 'Rodolfo', lastName: 'Cota', jerseyNumber: 13, position: 'GK', dateOfBirth: '1987-07-03', height: 183, weight: 80, preferredFoot: 'Right', club: 'Leon', clubLeague: 'Liga MX', marketValue: 1000000, caps: 20, goals: 0 },
      { firstName: 'Julian', lastName: 'Quinones', jerseyNumber: 26, position: 'LW', dateOfBirth: '1997-07-18', height: 173, weight: 67, preferredFoot: 'Left', club: 'America', clubLeague: 'Liga MX', marketValue: 8000000, caps: 15, goals: 2 },
    ],
  },

  // ========== CANADA ==========
  {
    name: 'Canada',
    fifaCode: 'CAN',
    players: [
      { firstName: 'Milan', lastName: 'Borjan', jerseyNumber: 18, position: 'GK', dateOfBirth: '1987-10-23', height: 193, weight: 90, preferredFoot: 'Right', club: 'Crvena Zvezda', clubLeague: 'Serbian SuperLiga', marketValue: 2000000, caps: 70, goals: 0 },
      { firstName: 'Alistair', lastName: 'Johnston', jerseyNumber: 2, position: 'RB', dateOfBirth: '1998-10-08', height: 180, weight: 72, preferredFoot: 'Right', club: 'Celtic', clubLeague: 'Scottish Premiership', marketValue: 12000000, caps: 35, goals: 1 },
      { firstName: 'Sam', lastName: 'Adekugbe', jerseyNumber: 3, position: 'LB', dateOfBirth: '1995-01-16', height: 175, weight: 70, preferredFoot: 'Left', club: 'Hatayspor', clubLeague: 'Super Lig', marketValue: 2500000, caps: 35, goals: 0 },
      { firstName: 'Kamal', lastName: 'Miller', jerseyNumber: 4, position: 'CB', dateOfBirth: '1997-05-16', height: 185, weight: 77, preferredFoot: 'Left', club: 'Portland Timbers', clubLeague: 'MLS', marketValue: 3000000, caps: 40, goals: 0 },
      { firstName: 'Steven', lastName: 'Vitoria', jerseyNumber: 5, position: 'CB', dateOfBirth: '1987-01-11', height: 193, weight: 85, preferredFoot: 'Right', club: 'Chaves', clubLeague: 'Primeira Liga', marketValue: 1000000, caps: 40, goals: 2 },
      { firstName: 'Samuel', lastName: 'Piette', jerseyNumber: 6, position: 'CDM', dateOfBirth: '1994-11-12', height: 176, weight: 68, preferredFoot: 'Right', club: 'CF Montreal', clubLeague: 'MLS', marketValue: 1500000, caps: 65, goals: 1 },
      { firstName: 'Stephen', lastName: 'Eustaquio', jerseyNumber: 7, position: 'CM', dateOfBirth: '1996-12-21', height: 180, weight: 72, preferredFoot: 'Right', club: 'Porto', clubLeague: 'Primeira Liga', marketValue: 18000000, caps: 50, goals: 4 },
      { firstName: 'David', lastName: 'Wotherspoon', jerseyNumber: 8, position: 'CAM', dateOfBirth: '1990-01-16', height: 175, weight: 70, preferredFoot: 'Right', club: 'St Johnstone', clubLeague: 'Scottish Premiership', marketValue: 300000, caps: 15, goals: 0 },
      { firstName: 'Cyle', lastName: 'Larin', jerseyNumber: 17, position: 'ST', dateOfBirth: '1995-04-17', height: 188, weight: 82, preferredFoot: 'Right', club: 'Real Valladolid', clubLeague: 'La Liga', marketValue: 5000000, caps: 60, goals: 29 },
      { firstName: 'David', lastName: 'Junior Hoilett', jerseyNumber: 10, position: 'LW', dateOfBirth: '1990-06-05', height: 175, weight: 70, preferredFoot: 'Right', club: 'Aberdeen', clubLeague: 'Scottish Premiership', marketValue: 800000, caps: 55, goals: 8 },
      { firstName: 'Tajon', lastName: 'Buchanan', jerseyNumber: 11, position: 'RW', dateOfBirth: '1999-02-08', height: 178, weight: 72, preferredFoot: 'Right', club: 'Inter Milan', clubLeague: 'Serie A', marketValue: 10000000, caps: 40, goals: 7 },
      { firstName: 'Ismael', lastName: 'Kone', jerseyNumber: 12, position: 'CM', dateOfBirth: '2002-06-16', height: 185, weight: 75, preferredFoot: 'Right', club: 'Olympique Marseille', clubLeague: 'Ligue 1', marketValue: 12000000, caps: 20, goals: 1 },
      { firstName: 'Mark-Anthony', lastName: 'Kaye', jerseyNumber: 14, position: 'CM', dateOfBirth: '1994-12-02', height: 183, weight: 75, preferredFoot: 'Right', club: 'Toronto FC', clubLeague: 'MLS', marketValue: 1500000, caps: 45, goals: 2 },
      { firstName: 'Derek', lastName: 'Cornelius', jerseyNumber: 15, position: 'CB', dateOfBirth: '1998-01-25', height: 185, weight: 77, preferredFoot: 'Right', club: 'Malmo FF', clubLeague: 'Allsvenskan', marketValue: 2000000, caps: 20, goals: 0 },
      { firstName: 'Maxime', lastName: 'Crepeau', jerseyNumber: 16, position: 'GK', dateOfBirth: '1994-05-11', height: 185, weight: 77, preferredFoot: 'Right', club: 'Portland Timbers', clubLeague: 'MLS', marketValue: 2500000, caps: 25, goals: 0 },
      { firstName: 'Jonathan', lastName: 'Osorio', jerseyNumber: 21, position: 'CM', dateOfBirth: '1992-06-12', height: 175, weight: 68, preferredFoot: 'Right', club: 'Toronto FC', clubLeague: 'MLS', marketValue: 3000000, caps: 70, goals: 9 },
      { firstName: 'Richie', lastName: 'Laryea', jerseyNumber: 22, position: 'RB', dateOfBirth: '1995-01-07', height: 171, weight: 66, preferredFoot: 'Right', club: 'Toronto FC', clubLeague: 'MLS', marketValue: 2000000, caps: 40, goals: 1 },
      { firstName: 'Alphonso', lastName: 'Davies', jerseyNumber: 19, position: 'LB', dateOfBirth: '2000-11-02', height: 183, weight: 75, preferredFoot: 'Left', club: 'Bayern Munich', clubLeague: 'Bundesliga', marketValue: 70000000, caps: 45, goals: 5 },
      { firstName: 'Jonathan', lastName: 'David', jerseyNumber: 9, position: 'ST', dateOfBirth: '2000-01-14', height: 180, weight: 71, preferredFoot: 'Both', club: 'Lille', clubLeague: 'Ligue 1', marketValue: 55000000, caps: 55, goals: 28 },
      { firstName: 'Lucas', lastName: 'Cavallini', jerseyNumber: 20, position: 'ST', dateOfBirth: '1992-12-28', height: 188, weight: 84, preferredFoot: 'Right', club: 'Vancouver Whitecaps', clubLeague: 'MLS', marketValue: 1500000, caps: 40, goals: 8 },
      { firstName: 'Liam', lastName: 'Millar', jerseyNumber: 13, position: 'LW', dateOfBirth: '1999-09-27', height: 178, weight: 70, preferredFoot: 'Right', club: 'Preston North End', clubLeague: 'Championship', marketValue: 2000000, caps: 20, goals: 3 },
      { firstName: 'Dayne', lastName: 'St. Clair', jerseyNumber: 1, position: 'GK', dateOfBirth: '1997-05-09', height: 193, weight: 84, preferredFoot: 'Right', club: 'Minnesota United', clubLeague: 'MLS', marketValue: 2000000, caps: 15, goals: 0 },
      { firstName: 'Scott', lastName: 'Kennedy', jerseyNumber: 23, position: 'CB', dateOfBirth: '1997-03-20', height: 191, weight: 82, preferredFoot: 'Right', club: 'SSV Jahn Regensburg', clubLeague: '2. Bundesliga', marketValue: 1000000, caps: 10, goals: 0 },
      { firstName: 'Jacob', lastName: 'Shaffelburg', jerseyNumber: 24, position: 'LW', dateOfBirth: '2000-01-11', height: 180, weight: 73, preferredFoot: 'Left', club: 'Nashville SC', clubLeague: 'MLS', marketValue: 1500000, caps: 15, goals: 1 },
      { firstName: 'Moise', lastName: 'Bombito', jerseyNumber: 25, position: 'CB', dateOfBirth: '2000-01-14', height: 191, weight: 80, preferredFoot: 'Right', club: 'Colorado Rapids', clubLeague: 'MLS', marketValue: 3000000, caps: 10, goals: 0 },
      { firstName: 'Theo', lastName: 'Corbeanu', jerseyNumber: 26, position: 'RW', dateOfBirth: '2002-05-15', height: 191, weight: 77, preferredFoot: 'Right', club: 'Blackpool', clubLeague: 'Championship', marketValue: 1500000, caps: 10, goals: 0 },
    ],
  },

  // ========== BELGIUM ==========
  {
    name: 'Belgium',
    fifaCode: 'BEL',
    players: [
      { firstName: 'Thibaut', lastName: 'Courtois', jerseyNumber: 1, position: 'GK', dateOfBirth: '1992-05-11', height: 199, weight: 96, preferredFoot: 'Left', club: 'Real Madrid', clubLeague: 'La Liga', marketValue: 35000000, caps: 105, goals: 0 },
      { firstName: 'Toby', lastName: 'Alderweireld', jerseyNumber: 2, position: 'CB', dateOfBirth: '1989-03-02', height: 186, weight: 81, preferredFoot: 'Right', club: 'Royal Antwerp', clubLeague: 'Pro League', marketValue: 3000000, caps: 125, goals: 5 },
      { firstName: 'Arthur', lastName: 'Theate', jerseyNumber: 3, position: 'CB', dateOfBirth: '2000-05-25', height: 186, weight: 80, preferredFoot: 'Left', club: 'Rennes', clubLeague: 'Ligue 1', marketValue: 18000000, caps: 20, goals: 1 },
      { firstName: 'Wout', lastName: 'Faes', jerseyNumber: 4, position: 'CB', dateOfBirth: '1998-04-03', height: 187, weight: 79, preferredFoot: 'Right', club: 'Leicester City', clubLeague: 'Championship', marketValue: 18000000, caps: 20, goals: 0 },
      { firstName: 'Jan', lastName: 'Vertonghen', jerseyNumber: 5, position: 'CB', dateOfBirth: '1987-04-24', height: 189, weight: 82, preferredFoot: 'Left', club: 'Anderlecht', clubLeague: 'Pro League', marketValue: 2000000, caps: 155, goals: 10 },
      { firstName: 'Axel', lastName: 'Witsel', jerseyNumber: 6, position: 'CDM', dateOfBirth: '1989-01-12', height: 186, weight: 81, preferredFoot: 'Right', club: 'Atletico Madrid', clubLeague: 'La Liga', marketValue: 4000000, caps: 130, goals: 11 },
      { firstName: 'Kevin', lastName: 'De Bruyne', jerseyNumber: 7, position: 'CAM', dateOfBirth: '1991-06-28', height: 181, weight: 76, preferredFoot: 'Right', club: 'Manchester City', clubLeague: 'Premier League', marketValue: 75000000, caps: 105, goals: 27 },
      { firstName: 'Youri', lastName: 'Tielemans', jerseyNumber: 8, position: 'CM', dateOfBirth: '1997-05-07', height: 176, weight: 70, preferredFoot: 'Right', club: 'Aston Villa', clubLeague: 'Premier League', marketValue: 35000000, caps: 65, goals: 6 },
      { firstName: 'Romelu', lastName: 'Lukaku', jerseyNumber: 9, position: 'ST', dateOfBirth: '1993-05-13', height: 190, weight: 94, preferredFoot: 'Left', club: 'Roma', clubLeague: 'Serie A', marketValue: 35000000, caps: 115, goals: 85 },
      { firstName: 'Eden', lastName: 'Hazard', jerseyNumber: 10, position: 'LW', dateOfBirth: '1991-01-07', height: 175, weight: 74, preferredFoot: 'Right', club: 'Retired', clubLeague: '-', marketValue: 0, caps: 130, goals: 33 },
      { firstName: 'Yannick', lastName: 'Carrasco', jerseyNumber: 11, position: 'LW', dateOfBirth: '1993-09-04', height: 180, weight: 74, preferredFoot: 'Right', club: 'Al-Shabab', clubLeague: 'Saudi Pro League', marketValue: 8000000, caps: 70, goals: 9 },
      { firstName: 'Simon', lastName: 'Mignolet', jerseyNumber: 12, position: 'GK', dateOfBirth: '1988-03-06', height: 193, weight: 88, preferredFoot: 'Right', club: 'Club Brugge', clubLeague: 'Pro League', marketValue: 1500000, caps: 35, goals: 0 },
      { firstName: 'Koen', lastName: 'Casteels', jerseyNumber: 13, position: 'GK', dateOfBirth: '1992-06-25', height: 197, weight: 88, preferredFoot: 'Right', club: 'Wolfsburg', clubLeague: 'Bundesliga', marketValue: 10000000, caps: 25, goals: 0 },
      { firstName: 'Dries', lastName: 'Mertens', jerseyNumber: 14, position: 'RW', dateOfBirth: '1987-05-06', height: 169, weight: 61, preferredFoot: 'Right', club: 'Galatasaray', clubLeague: 'Super Lig', marketValue: 3000000, caps: 110, goals: 21 },
      { firstName: 'Thomas', lastName: 'Meunier', jerseyNumber: 15, position: 'RB', dateOfBirth: '1991-09-12', height: 191, weight: 84, preferredFoot: 'Right', club: 'Trabzonspor', clubLeague: 'Super Lig', marketValue: 5000000, caps: 65, goals: 8 },
      { firstName: 'Thorgan', lastName: 'Hazard', jerseyNumber: 16, position: 'LW', dateOfBirth: '1993-03-29', height: 174, weight: 69, preferredFoot: 'Right', club: 'Anderlecht', clubLeague: 'Pro League', marketValue: 6000000, caps: 50, goals: 6 },
      { firstName: 'Leandro', lastName: 'Trossard', jerseyNumber: 17, position: 'LW', dateOfBirth: '1994-12-04', height: 172, weight: 61, preferredFoot: 'Right', club: 'Arsenal', clubLeague: 'Premier League', marketValue: 35000000, caps: 40, goals: 8 },
      { firstName: 'Orel', lastName: 'Mangala', jerseyNumber: 18, position: 'CM', dateOfBirth: '1998-03-18', height: 182, weight: 73, preferredFoot: 'Right', club: 'Lyon', clubLeague: 'Ligue 1', marketValue: 15000000, caps: 15, goals: 0 },
      { firstName: 'Timothy', lastName: 'Castagne', jerseyNumber: 21, position: 'RB', dateOfBirth: '1995-12-05', height: 185, weight: 82, preferredFoot: 'Right', club: 'Fulham', clubLeague: 'Premier League', marketValue: 22000000, caps: 40, goals: 1 },
      { firstName: 'Charles', lastName: 'De Ketelaere', jerseyNumber: 22, position: 'CAM', dateOfBirth: '2001-03-10', height: 192, weight: 78, preferredFoot: 'Left', club: 'Atalanta', clubLeague: 'Serie A', marketValue: 30000000, caps: 15, goals: 2 },
      { firstName: 'Michy', lastName: 'Batshuayi', jerseyNumber: 23, position: 'ST', dateOfBirth: '1993-10-02', height: 185, weight: 77, preferredFoot: 'Right', club: 'Galatasaray', clubLeague: 'Super Lig', marketValue: 5000000, caps: 50, goals: 27 },
      { firstName: 'Amadou', lastName: 'Onana', jerseyNumber: 24, position: 'CDM', dateOfBirth: '2001-08-16', height: 195, weight: 86, preferredFoot: 'Right', club: 'Aston Villa', clubLeague: 'Premier League', marketValue: 50000000, caps: 20, goals: 1 },
      { firstName: 'Jeremy', lastName: 'Doku', jerseyNumber: 25, position: 'RW', dateOfBirth: '2002-05-27', height: 173, weight: 66, preferredFoot: 'Right', club: 'Manchester City', clubLeague: 'Premier League', marketValue: 60000000, caps: 30, goals: 3 },
      { firstName: 'Lois', lastName: 'Openda', jerseyNumber: 26, position: 'ST', dateOfBirth: '2000-02-16', height: 178, weight: 75, preferredFoot: 'Right', club: 'RB Leipzig', clubLeague: 'Bundesliga', marketValue: 55000000, caps: 25, goals: 5 },
      { firstName: 'Zeno', lastName: 'Debast', jerseyNumber: 19, position: 'CB', dateOfBirth: '2003-10-24', height: 188, weight: 78, preferredFoot: 'Right', club: 'Sporting CP', clubLeague: 'Primeira Liga', marketValue: 20000000, caps: 15, goals: 0 },
      { firstName: 'Aster', lastName: 'Vranckx', jerseyNumber: 20, position: 'CM', dateOfBirth: '2002-10-04', height: 183, weight: 73, preferredFoot: 'Right', club: 'Wolfsburg', clubLeague: 'Bundesliga', marketValue: 12000000, caps: 10, goals: 0 },
    ],
  },

  // ========== COLOMBIA ==========
  {
    name: 'Colombia',
    fifaCode: 'COL',
    players: [
      { firstName: 'David', lastName: 'Ospina', jerseyNumber: 1, position: 'GK', dateOfBirth: '1988-08-31', height: 183, weight: 80, preferredFoot: 'Right', club: 'Al-Nassr', clubLeague: 'Saudi Pro League', marketValue: 2000000, caps: 130, goals: 0 },
      { firstName: 'Daniel', lastName: 'Munoz', jerseyNumber: 2, position: 'RB', dateOfBirth: '1996-05-26', height: 183, weight: 77, preferredFoot: 'Right', club: 'Crystal Palace', clubLeague: 'Premier League', marketValue: 20000000, caps: 30, goals: 1 },
      { firstName: 'Jhon', lastName: 'Lucumi', jerseyNumber: 3, position: 'CB', dateOfBirth: '1998-06-26', height: 187, weight: 82, preferredFoot: 'Left', club: 'Bologna', clubLeague: 'Serie A', marketValue: 18000000, caps: 25, goals: 0 },
      { firstName: 'Davinson', lastName: 'Sanchez', jerseyNumber: 4, position: 'CB', dateOfBirth: '1996-06-12', height: 187, weight: 85, preferredFoot: 'Right', club: 'Galatasaray', clubLeague: 'Super Lig', marketValue: 10000000, caps: 60, goals: 0 },
      { firstName: 'Yerry', lastName: 'Mina', jerseyNumber: 13, position: 'CB', dateOfBirth: '1994-09-23', height: 195, weight: 94, preferredFoot: 'Right', club: 'Fiorentina', clubLeague: 'Serie A', marketValue: 10000000, caps: 45, goals: 7 },
      { firstName: 'Wilmar', lastName: 'Barrios', jerseyNumber: 5, position: 'CDM', dateOfBirth: '1993-10-16', height: 177, weight: 71, preferredFoot: 'Right', club: 'Zenit St. Petersburg', clubLeague: 'Russian Premier League', marketValue: 12000000, caps: 55, goals: 0 },
      { firstName: 'Juan', lastName: 'Cuadrado', jerseyNumber: 11, position: 'RW', dateOfBirth: '1988-05-26', height: 179, weight: 72, preferredFoot: 'Right', club: 'Inter Miami', clubLeague: 'MLS', marketValue: 3000000, caps: 115, goals: 10 },
      { firstName: 'Jefferson', lastName: 'Lerma', jerseyNumber: 6, position: 'CDM', dateOfBirth: '1994-10-25', height: 179, weight: 78, preferredFoot: 'Right', club: 'Crystal Palace', clubLeague: 'Premier League', marketValue: 10000000, caps: 45, goals: 0 },
      { firstName: 'Duvan', lastName: 'Zapata', jerseyNumber: 9, position: 'ST', dateOfBirth: '1991-04-01', height: 189, weight: 88, preferredFoot: 'Right', club: 'Torino', clubLeague: 'Serie A', marketValue: 10000000, caps: 45, goals: 17 },
      { firstName: 'James', lastName: 'Rodriguez', jerseyNumber: 10, position: 'CAM', dateOfBirth: '1991-07-12', height: 180, weight: 75, preferredFoot: 'Left', club: 'Rayo Vallecano', clubLeague: 'La Liga', marketValue: 5000000, caps: 105, goals: 25 },
      { firstName: 'Luis', lastName: 'Diaz', jerseyNumber: 7, position: 'LW', dateOfBirth: '1997-01-13', height: 178, weight: 70, preferredFoot: 'Right', club: 'Liverpool', clubLeague: 'Premier League', marketValue: 75000000, caps: 55, goals: 10 },
      { firstName: 'Jorge', lastName: 'Carrascal', jerseyNumber: 8, position: 'CAM', dateOfBirth: '1998-05-25', height: 177, weight: 70, preferredFoot: 'Right', club: 'Dynamo Moscow', clubLeague: 'Russian Premier League', marketValue: 5000000, caps: 15, goals: 1 },
      { firstName: 'Rafael', lastName: 'Santos Borre', jerseyNumber: 19, position: 'ST', dateOfBirth: '1995-09-15', height: 174, weight: 71, preferredFoot: 'Right', club: 'Werder Bremen', clubLeague: 'Bundesliga', marketValue: 10000000, caps: 40, goals: 6 },
      { firstName: 'Johan', lastName: 'Mojica', jerseyNumber: 17, position: 'LB', dateOfBirth: '1992-08-21', height: 186, weight: 78, preferredFoot: 'Left', club: 'Mallorca', clubLeague: 'La Liga', marketValue: 5000000, caps: 35, goals: 0 },
      { firstName: 'Luis', lastName: 'Sinisterra', jerseyNumber: 14, position: 'LW', dateOfBirth: '1999-06-17', height: 172, weight: 71, preferredFoot: 'Right', club: 'Bournemouth', clubLeague: 'Premier League', marketValue: 20000000, caps: 25, goals: 5 },
      { firstName: 'Mateus', lastName: 'Uribe', jerseyNumber: 15, position: 'CM', dateOfBirth: '1991-03-21', height: 183, weight: 78, preferredFoot: 'Right', club: 'Al-Sadd', clubLeague: 'Qatar Stars League', marketValue: 3000000, caps: 60, goals: 5 },
      { firstName: 'John', lastName: 'Cordoba', jerseyNumber: 16, position: 'ST', dateOfBirth: '1993-05-11', height: 188, weight: 88, preferredFoot: 'Right', club: 'Krasnodar', clubLeague: 'Russian Premier League', marketValue: 6000000, caps: 20, goals: 4 },
      { firstName: 'Camilo', lastName: 'Vargas', jerseyNumber: 12, position: 'GK', dateOfBirth: '1989-03-09', height: 187, weight: 85, preferredFoot: 'Right', club: 'Atlas', clubLeague: 'Liga MX', marketValue: 1500000, caps: 45, goals: 0 },
      { firstName: 'Carlos', lastName: 'Cuesta', jerseyNumber: 18, position: 'CB', dateOfBirth: '1999-03-15', height: 184, weight: 78, preferredFoot: 'Right', club: 'Genk', clubLeague: 'Pro League', marketValue: 15000000, caps: 15, goals: 0 },
      { firstName: 'Stefan', lastName: 'Medina', jerseyNumber: 20, position: 'RB', dateOfBirth: '1992-06-04', height: 174, weight: 70, preferredFoot: 'Right', club: 'Monterrey', clubLeague: 'Liga MX', marketValue: 1500000, caps: 35, goals: 0 },
      { firstName: 'Juan', lastName: 'Fernando Quintero', jerseyNumber: 21, position: 'CAM', dateOfBirth: '1993-01-18', height: 168, weight: 62, preferredFoot: 'Left', club: 'Racing Club', clubLeague: 'Argentine Primera', marketValue: 3000000, caps: 45, goals: 4 },
      { firstName: 'Jhon', lastName: 'Arias', jerseyNumber: 22, position: 'RW', dateOfBirth: '1997-09-21', height: 171, weight: 69, preferredFoot: 'Left', club: 'Fluminense', clubLeague: 'Serie A', marketValue: 15000000, caps: 20, goals: 3 },
      { firstName: 'Deiver', lastName: 'Machado', jerseyNumber: 23, position: 'LB', dateOfBirth: '1993-09-08', height: 177, weight: 72, preferredFoot: 'Left', club: 'Lens', clubLeague: 'Ligue 1', marketValue: 6000000, caps: 10, goals: 0 },
      { firstName: 'Kevin', lastName: 'Castaño', jerseyNumber: 24, position: 'CM', dateOfBirth: '1998-09-13', height: 180, weight: 73, preferredFoot: 'Right', club: 'Krasnodar', clubLeague: 'Russian Premier League', marketValue: 4000000, caps: 10, goals: 0 },
      { firstName: 'Alvaro', lastName: 'Montero', jerseyNumber: 25, position: 'GK', dateOfBirth: '1995-05-24', height: 189, weight: 83, preferredFoot: 'Right', club: 'Millonarios', clubLeague: 'Categoria Primera A', marketValue: 1500000, caps: 5, goals: 0 },
      { firstName: 'Richard', lastName: 'Rios', jerseyNumber: 26, position: 'CM', dateOfBirth: '2000-01-05', height: 181, weight: 75, preferredFoot: 'Right', club: 'Palmeiras', clubLeague: 'Serie A', marketValue: 20000000, caps: 15, goals: 1 },
    ],
  },

  // ========== JAPAN ==========
  {
    name: 'Japan',
    fifaCode: 'JPN',
    players: [
      { firstName: 'Shuichi', lastName: 'Gonda', jerseyNumber: 1, position: 'GK', dateOfBirth: '1989-03-03', height: 187, weight: 88, preferredFoot: 'Right', club: 'Shimizu S-Pulse', clubLeague: 'J1 League', marketValue: 500000, caps: 35, goals: 0 },
      { firstName: 'Miki', lastName: 'Yamane', jerseyNumber: 2, position: 'RB', dateOfBirth: '1993-12-22', height: 177, weight: 75, preferredFoot: 'Right', club: 'Kawasaki Frontale', clubLeague: 'J1 League', marketValue: 2000000, caps: 20, goals: 0 },
      { firstName: 'Shogo', lastName: 'Taniguchi', jerseyNumber: 3, position: 'CB', dateOfBirth: '1991-07-15', height: 187, weight: 76, preferredFoot: 'Right', club: 'Kawasaki Frontale', clubLeague: 'J1 League', marketValue: 1500000, caps: 35, goals: 2 },
      { firstName: 'Ko', lastName: 'Itakura', jerseyNumber: 4, position: 'CB', dateOfBirth: '1997-01-27', height: 186, weight: 77, preferredFoot: 'Right', club: 'Borussia Monchengladbach', clubLeague: 'Bundesliga', marketValue: 15000000, caps: 25, goals: 0 },
      { firstName: 'Yuto', lastName: 'Nagatomo', jerseyNumber: 5, position: 'LB', dateOfBirth: '1986-09-12', height: 170, weight: 68, preferredFoot: 'Right', club: 'FC Tokyo', clubLeague: 'J1 League', marketValue: 300000, caps: 145, goals: 4 },
      { firstName: 'Wataru', lastName: 'Endo', jerseyNumber: 6, position: 'CDM', dateOfBirth: '1993-02-09', height: 178, weight: 76, preferredFoot: 'Right', club: 'Liverpool', clubLeague: 'Premier League', marketValue: 25000000, caps: 55, goals: 2 },
      { firstName: 'Takefusa', lastName: 'Kubo', jerseyNumber: 7, position: 'RW', dateOfBirth: '2001-06-04', height: 173, weight: 67, preferredFoot: 'Left', club: 'Real Sociedad', clubLeague: 'La Liga', marketValue: 50000000, caps: 35, goals: 3 },
      { firstName: 'Ritsu', lastName: 'Doan', jerseyNumber: 8, position: 'RW', dateOfBirth: '1998-06-16', height: 172, weight: 69, preferredFoot: 'Left', club: 'Freiburg', clubLeague: 'Bundesliga', marketValue: 20000000, caps: 40, goals: 6 },
      { firstName: 'Kaoru', lastName: 'Mitoma', jerseyNumber: 9, position: 'LW', dateOfBirth: '1997-05-20', height: 178, weight: 72, preferredFoot: 'Right', club: 'Brighton', clubLeague: 'Premier League', marketValue: 40000000, caps: 30, goals: 5 },
      { firstName: 'Takumi', lastName: 'Minamino', jerseyNumber: 10, position: 'LW', dateOfBirth: '1995-01-16', height: 174, weight: 67, preferredFoot: 'Right', club: 'Monaco', clubLeague: 'Ligue 1', marketValue: 15000000, caps: 50, goals: 17 },
      { firstName: 'Kyogo', lastName: 'Furuhashi', jerseyNumber: 11, position: 'ST', dateOfBirth: '1995-01-20', height: 170, weight: 65, preferredFoot: 'Right', club: 'Celtic', clubLeague: 'Scottish Premiership', marketValue: 15000000, caps: 20, goals: 6 },
      { firstName: 'Daniel', lastName: 'Schmidt', jerseyNumber: 12, position: 'GK', dateOfBirth: '1992-02-03', height: 197, weight: 88, preferredFoot: 'Right', club: 'Sint-Truiden', clubLeague: 'Pro League', marketValue: 2000000, caps: 20, goals: 0 },
      { firstName: 'Hiroki', lastName: 'Sakai', jerseyNumber: 13, position: 'RB', dateOfBirth: '1990-04-12', height: 183, weight: 77, preferredFoot: 'Right', club: 'Urawa Reds', clubLeague: 'J1 League', marketValue: 1000000, caps: 75, goals: 1 },
      { firstName: 'Junya', lastName: 'Ito', jerseyNumber: 14, position: 'RW', dateOfBirth: '1993-03-09', height: 176, weight: 69, preferredFoot: 'Left', club: 'Stade Reims', clubLeague: 'Ligue 1', marketValue: 12000000, caps: 45, goals: 4 },
      { firstName: 'Daichi', lastName: 'Kamada', jerseyNumber: 15, position: 'CAM', dateOfBirth: '1996-08-05', height: 180, weight: 72, preferredFoot: 'Left', club: 'Crystal Palace', clubLeague: 'Premier League', marketValue: 25000000, caps: 45, goals: 5 },
      { firstName: 'Maya', lastName: 'Yoshida', jerseyNumber: 22, position: 'CB', dateOfBirth: '1988-08-24', height: 189, weight: 82, preferredFoot: 'Right', club: 'Los Angeles Galaxy', clubLeague: 'MLS', marketValue: 500000, caps: 130, goals: 12 },
      { firstName: 'Ao', lastName: 'Tanaka', jerseyNumber: 17, position: 'CM', dateOfBirth: '1998-09-10', height: 180, weight: 72, preferredFoot: 'Right', club: 'Leeds United', clubLeague: 'Championship', marketValue: 10000000, caps: 30, goals: 2 },
      { firstName: 'Takehiro', lastName: 'Tomiyasu', jerseyNumber: 16, position: 'CB', dateOfBirth: '1998-11-05', height: 188, weight: 84, preferredFoot: 'Right', club: 'Arsenal', clubLeague: 'Premier League', marketValue: 30000000, caps: 35, goals: 1 },
      { firstName: 'Hidemasa', lastName: 'Morita', jerseyNumber: 18, position: 'CM', dateOfBirth: '1995-05-10', height: 177, weight: 66, preferredFoot: 'Right', club: 'Sporting CP', clubLeague: 'Primeira Liga', marketValue: 12000000, caps: 35, goals: 0 },
      { firstName: 'Hiroki', lastName: 'Ito', jerseyNumber: 19, position: 'CB', dateOfBirth: '1999-05-12', height: 188, weight: 80, preferredFoot: 'Left', club: 'Bayern Munich', clubLeague: 'Bundesliga', marketValue: 22000000, caps: 15, goals: 0 },
      { firstName: 'Yuki', lastName: 'Soma', jerseyNumber: 20, position: 'LW', dateOfBirth: '1997-02-25', height: 166, weight: 60, preferredFoot: 'Right', club: 'Nagoya Grampus', clubLeague: 'J1 League', marketValue: 2500000, caps: 20, goals: 2 },
      { firstName: 'Ayase', lastName: 'Ueda', jerseyNumber: 21, position: 'ST', dateOfBirth: '1998-08-28', height: 182, weight: 73, preferredFoot: 'Right', club: 'Feyenoord', clubLeague: 'Eredivisie', marketValue: 10000000, caps: 25, goals: 8 },
      { firstName: 'Zion', lastName: 'Suzuki', jerseyNumber: 23, position: 'GK', dateOfBirth: '2002-08-21', height: 190, weight: 84, preferredFoot: 'Right', club: 'Parma', clubLeague: 'Serie A', marketValue: 8000000, caps: 5, goals: 0 },
      { firstName: 'Koki', lastName: 'Machida', jerseyNumber: 24, position: 'CB', dateOfBirth: '1997-08-13', height: 185, weight: 76, preferredFoot: 'Right', club: 'Union Berlin', clubLeague: 'Bundesliga', marketValue: 10000000, caps: 10, goals: 0 },
      { firstName: 'Daizen', lastName: 'Maeda', jerseyNumber: 25, position: 'ST', dateOfBirth: '1997-10-20', height: 170, weight: 63, preferredFoot: 'Right', club: 'Celtic', clubLeague: 'Scottish Premiership', marketValue: 12000000, caps: 20, goals: 4 },
      { firstName: 'Keito', lastName: 'Nakamura', jerseyNumber: 26, position: 'RW', dateOfBirth: '2000-07-28', height: 164, weight: 60, preferredFoot: 'Left', club: 'Reims', clubLeague: 'Ligue 1', marketValue: 12000000, caps: 10, goals: 2 },
    ],
  },

  // ========== MOROCCO ==========
  {
    name: 'Morocco',
    fifaCode: 'MAR',
    players: [
      { firstName: 'Yassine', lastName: 'Bounou', commonName: 'Bono', jerseyNumber: 1, position: 'GK', dateOfBirth: '1991-04-05', height: 192, weight: 82, preferredFoot: 'Right', club: 'Al-Hilal', clubLeague: 'Saudi Pro League', marketValue: 18000000, caps: 55, goals: 0 },
      { firstName: 'Achraf', lastName: 'Hakimi', jerseyNumber: 2, position: 'RB', dateOfBirth: '1998-11-04', height: 181, weight: 73, preferredFoot: 'Right', club: 'Paris Saint-Germain', clubLeague: 'Ligue 1', marketValue: 65000000, caps: 75, goals: 9 },
      { firstName: 'Noussair', lastName: 'Mazraoui', jerseyNumber: 3, position: 'RB', dateOfBirth: '1997-11-14', height: 183, weight: 76, preferredFoot: 'Right', club: 'Manchester United', clubLeague: 'Premier League', marketValue: 30000000, caps: 30, goals: 0 },
      { firstName: 'Sofyan', lastName: 'Amrabat', jerseyNumber: 4, position: 'CDM', dateOfBirth: '1996-08-21', height: 183, weight: 77, preferredFoot: 'Right', club: 'Fenerbahce', clubLeague: 'Super Lig', marketValue: 18000000, caps: 65, goals: 0 },
      { firstName: 'Nayef', lastName: 'Aguerd', jerseyNumber: 5, position: 'CB', dateOfBirth: '1996-03-30', height: 190, weight: 82, preferredFoot: 'Left', club: 'West Ham', clubLeague: 'Premier League', marketValue: 28000000, caps: 35, goals: 3 },
      { firstName: 'Romain', lastName: 'Saiss', jerseyNumber: 6, position: 'CB', dateOfBirth: '1990-03-26', height: 188, weight: 80, preferredFoot: 'Left', club: 'Al-Shabab', clubLeague: 'Saudi Pro League', marketValue: 3000000, caps: 85, goals: 4 },
      { firstName: 'Hakim', lastName: 'Ziyech', jerseyNumber: 7, position: 'RW', dateOfBirth: '1993-03-19', height: 181, weight: 65, preferredFoot: 'Left', club: 'Galatasaray', clubLeague: 'Super Lig', marketValue: 18000000, caps: 55, goals: 20 },
      { firstName: 'Azzedine', lastName: 'Ounahi', jerseyNumber: 8, position: 'CM', dateOfBirth: '2000-04-19', height: 182, weight: 70, preferredFoot: 'Right', club: 'Marseille', clubLeague: 'Ligue 1', marketValue: 18000000, caps: 25, goals: 1 },
      { firstName: 'Youssef', lastName: 'En-Nesyri', jerseyNumber: 9, position: 'ST', dateOfBirth: '1997-06-01', height: 189, weight: 73, preferredFoot: 'Right', club: 'Fenerbahce', clubLeague: 'Super Lig', marketValue: 25000000, caps: 70, goals: 20 },
      { firstName: 'Brahim', lastName: 'Diaz', jerseyNumber: 10, position: 'CAM', dateOfBirth: '1999-08-03', height: 171, weight: 63, preferredFoot: 'Right', club: 'Real Madrid', clubLeague: 'La Liga', marketValue: 35000000, caps: 15, goals: 3 },
      { firstName: 'Abdelhamid', lastName: 'Sabiri', jerseyNumber: 11, position: 'CAM', dateOfBirth: '1996-11-28', height: 180, weight: 75, preferredFoot: 'Right', club: 'Fiorentina', clubLeague: 'Serie A', marketValue: 7000000, caps: 20, goals: 2 },
      { firstName: 'Munir', lastName: 'Mohamedi', jerseyNumber: 12, position: 'GK', dateOfBirth: '1989-05-10', height: 195, weight: 89, preferredFoot: 'Right', club: 'Al-Wehda', clubLeague: 'Saudi Pro League', marketValue: 1000000, caps: 45, goals: 0 },
      { firstName: 'Jawad', lastName: 'El Yamiq', jerseyNumber: 13, position: 'CB', dateOfBirth: '1992-02-29', height: 189, weight: 88, preferredFoot: 'Right', club: 'Real Valladolid', clubLeague: 'La Liga', marketValue: 4000000, caps: 35, goals: 0 },
      { firstName: 'Zakaria', lastName: 'Aboukhlal', jerseyNumber: 14, position: 'LW', dateOfBirth: '2000-02-18', height: 174, weight: 70, preferredFoot: 'Right', club: 'Toulouse', clubLeague: 'Ligue 1', marketValue: 8000000, caps: 25, goals: 3 },
      { firstName: 'Selim', lastName: 'Amallah', jerseyNumber: 15, position: 'CM', dateOfBirth: '1996-11-15', height: 185, weight: 74, preferredFoot: 'Right', club: 'Real Valladolid', clubLeague: 'La Liga', marketValue: 5000000, caps: 25, goals: 2 },
      { firstName: 'Abde', lastName: 'Ezzalzouli', jerseyNumber: 16, position: 'LW', dateOfBirth: '2001-12-17', height: 176, weight: 67, preferredFoot: 'Right', club: 'Real Betis', clubLeague: 'La Liga', marketValue: 18000000, caps: 15, goals: 1 },
      { firstName: 'Sofiane', lastName: 'Boufal', jerseyNumber: 17, position: 'LW', dateOfBirth: '1993-09-17', height: 172, weight: 69, preferredFoot: 'Right', club: 'Al-Rayyan', clubLeague: 'Qatar Stars League', marketValue: 4000000, caps: 45, goals: 4 },
      { firstName: 'Youssef', lastName: 'Chermiti', jerseyNumber: 18, position: 'ST', dateOfBirth: '2004-05-24', height: 193, weight: 80, preferredFoot: 'Right', club: 'Everton', clubLeague: 'Premier League', marketValue: 10000000, caps: 5, goals: 0 },
      { firstName: 'Youssouf', lastName: 'Fofana', jerseyNumber: 19, position: 'CM', dateOfBirth: '1999-01-10', height: 182, weight: 72, preferredFoot: 'Right', club: 'AC Milan', clubLeague: 'Serie A', marketValue: 35000000, caps: 10, goals: 0 },
      { firstName: 'Achraf', lastName: 'Dari', jerseyNumber: 20, position: 'CB', dateOfBirth: '1999-05-06', height: 183, weight: 73, preferredFoot: 'Right', club: 'Brest', clubLeague: 'Ligue 1', marketValue: 8000000, caps: 15, goals: 0 },
      { firstName: 'Walid', lastName: 'Cheddira', jerseyNumber: 21, position: 'ST', dateOfBirth: '1998-01-21', height: 190, weight: 79, preferredFoot: 'Right', club: 'Bari', clubLeague: 'Serie B', marketValue: 5000000, caps: 20, goals: 3 },
      { firstName: 'Ahmed', lastName: 'Tagnaouti', jerseyNumber: 22, position: 'GK', dateOfBirth: '1996-04-05', height: 187, weight: 78, preferredFoot: 'Right', club: 'Wydad AC', clubLeague: 'Botola Pro', marketValue: 500000, caps: 5, goals: 0 },
      { firstName: 'Bilal', lastName: 'El Khannouss', jerseyNumber: 23, position: 'CAM', dateOfBirth: '2004-05-10', height: 178, weight: 68, preferredFoot: 'Right', club: 'Leicester City', clubLeague: 'Championship', marketValue: 15000000, caps: 10, goals: 1 },
      { firstName: 'Yahya', lastName: 'Attiyat Allah', jerseyNumber: 24, position: 'LB', dateOfBirth: '1995-03-02', height: 184, weight: 73, preferredFoot: 'Left', club: 'Wydad AC', clubLeague: 'Botola Pro', marketValue: 1500000, caps: 25, goals: 0 },
      { firstName: 'Adam', lastName: 'Masina', jerseyNumber: 25, position: 'LB', dateOfBirth: '1994-01-02', height: 190, weight: 82, preferredFoot: 'Left', club: 'Torino', clubLeague: 'Serie A', marketValue: 4000000, caps: 15, goals: 0 },
      { firstName: 'Ilias', lastName: 'Chair', jerseyNumber: 26, position: 'CAM', dateOfBirth: '1997-10-30', height: 177, weight: 67, preferredFoot: 'Right', club: 'QPR', clubLeague: 'Championship', marketValue: 4000000, caps: 15, goals: 1 },
    ],
  },

  // ========== SENEGAL ==========
  {
    name: 'Senegal',
    fifaCode: 'SEN',
    players: [
      { firstName: 'Edouard', lastName: 'Mendy', jerseyNumber: 1, position: 'GK', dateOfBirth: '1992-03-01', height: 197, weight: 86, preferredFoot: 'Right', club: 'Al-Ahli', clubLeague: 'Saudi Pro League', marketValue: 12000000, caps: 45, goals: 0 },
      { firstName: 'Formose', lastName: 'Mendy', jerseyNumber: 2, position: 'LB', dateOfBirth: '1998-12-29', height: 178, weight: 69, preferredFoot: 'Left', club: 'Lorient', clubLeague: 'Ligue 2', marketValue: 2500000, caps: 10, goals: 0 },
      { firstName: 'Kalidou', lastName: 'Koulibaly', jerseyNumber: 3, position: 'CB', dateOfBirth: '1991-06-20', height: 187, weight: 89, preferredFoot: 'Right', club: 'Al-Hilal', clubLeague: 'Saudi Pro League', marketValue: 10000000, caps: 75, goals: 2 },
      { firstName: 'Abdou', lastName: 'Diallo', jerseyNumber: 4, position: 'CB', dateOfBirth: '1996-05-21', height: 187, weight: 77, preferredFoot: 'Left', club: 'Al-Arabi', clubLeague: 'Qatar Stars League', marketValue: 8000000, caps: 40, goals: 0 },
      { firstName: 'Youssouf', lastName: 'Sabaly', jerseyNumber: 5, position: 'RB', dateOfBirth: '1993-03-05', height: 176, weight: 70, preferredFoot: 'Right', club: 'Real Betis', clubLeague: 'La Liga', marketValue: 5000000, caps: 45, goals: 0 },
      { firstName: 'Nampalys', lastName: 'Mendy', jerseyNumber: 6, position: 'CDM', dateOfBirth: '1992-06-23', height: 167, weight: 62, preferredFoot: 'Right', club: 'Lens', clubLeague: 'Ligue 1', marketValue: 5000000, caps: 35, goals: 0 },
      { firstName: 'Moussa', lastName: 'Niakhate', jerseyNumber: 7, position: 'CB', dateOfBirth: '1996-03-08', height: 190, weight: 84, preferredFoot: 'Right', club: 'Nottingham Forest', clubLeague: 'Premier League', marketValue: 20000000, caps: 25, goals: 1 },
      { firstName: 'Cheikhou', lastName: 'Kouyate', jerseyNumber: 8, position: 'CDM', dateOfBirth: '1989-12-21', height: 189, weight: 81, preferredFoot: 'Right', club: 'Nottingham Forest', clubLeague: 'Premier League', marketValue: 2000000, caps: 95, goals: 5 },
      { firstName: 'Boulaye', lastName: 'Dia', jerseyNumber: 9, position: 'ST', dateOfBirth: '1996-11-16', height: 180, weight: 77, preferredFoot: 'Right', club: 'Lazio', clubLeague: 'Serie A', marketValue: 15000000, caps: 30, goals: 8 },
      { firstName: 'Sadio', lastName: 'Mane', jerseyNumber: 10, position: 'LW', dateOfBirth: '1992-04-10', height: 174, weight: 69, preferredFoot: 'Right', club: 'Al-Nassr', clubLeague: 'Saudi Pro League', marketValue: 15000000, caps: 105, goals: 40 },
      { firstName: 'Nicolas', lastName: 'Jackson', jerseyNumber: 11, position: 'ST', dateOfBirth: '2001-06-20', height: 186, weight: 73, preferredFoot: 'Right', club: 'Chelsea', clubLeague: 'Premier League', marketValue: 50000000, caps: 25, goals: 7 },
      { firstName: 'Seny', lastName: 'Dieng', jerseyNumber: 12, position: 'GK', dateOfBirth: '1994-11-23', height: 193, weight: 80, preferredFoot: 'Right', club: 'Middlesbrough', clubLeague: 'Championship', marketValue: 3000000, caps: 15, goals: 0 },
      { firstName: 'Pape', lastName: 'Abou Cisse', jerseyNumber: 13, position: 'CB', dateOfBirth: '1995-09-14', height: 196, weight: 93, preferredFoot: 'Right', club: 'Olympiakos', clubLeague: 'Super League Greece', marketValue: 5000000, caps: 35, goals: 3 },
      { firstName: 'Krepin', lastName: 'Diatta', jerseyNumber: 14, position: 'RW', dateOfBirth: '1999-02-25', height: 178, weight: 72, preferredFoot: 'Left', club: 'Monaco', clubLeague: 'Ligue 1', marketValue: 15000000, caps: 35, goals: 3 },
      { firstName: 'Ismaila', lastName: 'Sarr', jerseyNumber: 18, position: 'RW', dateOfBirth: '1998-02-25', height: 185, weight: 76, preferredFoot: 'Right', club: 'Crystal Palace', clubLeague: 'Premier League', marketValue: 25000000, caps: 55, goals: 11 },
      { firstName: 'Idrissa', lastName: 'Gueye', jerseyNumber: 5, position: 'CDM', dateOfBirth: '1989-09-26', height: 174, weight: 66, preferredFoot: 'Right', club: 'Everton', clubLeague: 'Premier League', marketValue: 5000000, caps: 110, goals: 5 },
      { firstName: 'Pape', lastName: 'Matar Sarr', jerseyNumber: 17, position: 'CM', dateOfBirth: '2002-09-14', height: 180, weight: 72, preferredFoot: 'Right', club: 'Tottenham', clubLeague: 'Premier League', marketValue: 35000000, caps: 20, goals: 1 },
      { firstName: 'Iliman', lastName: 'Ndiaye', jerseyNumber: 19, position: 'CAM', dateOfBirth: '2000-03-06', height: 178, weight: 74, preferredFoot: 'Right', club: 'Everton', clubLeague: 'Premier League', marketValue: 25000000, caps: 20, goals: 5 },
      { firstName: 'Bamba', lastName: 'Dieng', jerseyNumber: 20, position: 'ST', dateOfBirth: '2000-03-23', height: 178, weight: 70, preferredFoot: 'Right', club: 'Lorient', clubLeague: 'Ligue 2', marketValue: 8000000, caps: 15, goals: 3 },
      { firstName: 'Habib', lastName: 'Diallo', jerseyNumber: 21, position: 'ST', dateOfBirth: '1995-06-18', height: 188, weight: 78, preferredFoot: 'Right', club: 'Al-Shabab', clubLeague: 'Saudi Pro League', marketValue: 10000000, caps: 35, goals: 10 },
      { firstName: 'Lamine', lastName: 'Camara', jerseyNumber: 22, position: 'CM', dateOfBirth: '2000-04-01', height: 173, weight: 67, preferredFoot: 'Right', club: 'Monaco', clubLeague: 'Ligue 1', marketValue: 20000000, caps: 15, goals: 2 },
      { firstName: 'Alfred', lastName: 'Gomis', jerseyNumber: 16, position: 'GK', dateOfBirth: '1993-09-05', height: 196, weight: 89, preferredFoot: 'Right', club: 'Rennes', clubLeague: 'Ligue 1', marketValue: 3000000, caps: 20, goals: 0 },
      { firstName: 'Fode', lastName: 'Ballo-Toure', jerseyNumber: 23, position: 'LB', dateOfBirth: '1997-01-03', height: 182, weight: 75, preferredFoot: 'Left', club: 'Fulham', clubLeague: 'Premier League', marketValue: 5000000, caps: 25, goals: 0 },
      { firstName: 'Pathe', lastName: 'Ciss', jerseyNumber: 24, position: 'CM', dateOfBirth: '1994-03-16', height: 181, weight: 73, preferredFoot: 'Right', club: 'Rayo Vallecano', clubLeague: 'La Liga', marketValue: 4000000, caps: 20, goals: 1 },
      { firstName: 'Demba', lastName: 'Seck', jerseyNumber: 25, position: 'CM', dateOfBirth: '2001-05-10', height: 178, weight: 69, preferredFoot: 'Right', club: 'Torino', clubLeague: 'Serie A', marketValue: 4000000, caps: 5, goals: 0 },
      { firstName: 'Aliou', lastName: 'Cisse', jerseyNumber: 26, position: 'CDM', dateOfBirth: '1976-03-24', height: 183, weight: 78, preferredFoot: 'Right', club: 'Coach', clubLeague: '-', marketValue: 0, caps: 35, goals: 0 },
    ],
  },

  // ========== CROATIA ==========
  {
    name: 'Croatia',
    fifaCode: 'CRO',
    players: [
      { firstName: 'Dominik', lastName: 'Livakovic', jerseyNumber: 1, position: 'GK', dateOfBirth: '1995-01-09', height: 188, weight: 82, preferredFoot: 'Right', club: 'Fenerbahce', clubLeague: 'Super Lig', marketValue: 15000000, caps: 50, goals: 0 },
      { firstName: 'Josip', lastName: 'Stanisic', jerseyNumber: 2, position: 'RB', dateOfBirth: '2000-04-02', height: 184, weight: 78, preferredFoot: 'Right', club: 'Bayer Leverkusen', clubLeague: 'Bundesliga', marketValue: 22000000, caps: 15, goals: 0 },
      { firstName: 'Borna', lastName: 'Barisic', jerseyNumber: 3, position: 'LB', dateOfBirth: '1992-11-10', height: 186, weight: 79, preferredFoot: 'Left', club: 'Rangers', clubLeague: 'Scottish Premiership', marketValue: 3000000, caps: 40, goals: 3 },
      { firstName: 'Ivan', lastName: 'Perisic', jerseyNumber: 4, position: 'LW', dateOfBirth: '1989-02-02', height: 186, weight: 78, preferredFoot: 'Both', club: 'Hajduk Split', clubLeague: 'Prva HNL', marketValue: 3000000, caps: 135, goals: 33 },
      { firstName: 'Martin', lastName: 'Erlic', jerseyNumber: 5, position: 'CB', dateOfBirth: '1998-01-24', height: 193, weight: 85, preferredFoot: 'Right', club: 'Bologna', clubLeague: 'Serie A', marketValue: 8000000, caps: 15, goals: 0 },
      { firstName: 'Dejan', lastName: 'Lovren', jerseyNumber: 6, position: 'CB', dateOfBirth: '1989-07-05', height: 188, weight: 84, preferredFoot: 'Right', club: 'Lyon', clubLeague: 'Ligue 1', marketValue: 3000000, caps: 85, goals: 5 },
      { firstName: 'Lovro', lastName: 'Majer', jerseyNumber: 7, position: 'CAM', dateOfBirth: '1998-01-17', height: 176, weight: 65, preferredFoot: 'Right', club: 'Wolfsburg', clubLeague: 'Bundesliga', marketValue: 30000000, caps: 30, goals: 4 },
      { firstName: 'Mateo', lastName: 'Kovacic', jerseyNumber: 8, position: 'CM', dateOfBirth: '1994-05-06', height: 177, weight: 78, preferredFoot: 'Right', club: 'Manchester City', clubLeague: 'Premier League', marketValue: 40000000, caps: 95, goals: 3 },
      { firstName: 'Andrej', lastName: 'Kramaric', jerseyNumber: 9, position: 'ST', dateOfBirth: '1991-06-19', height: 177, weight: 73, preferredFoot: 'Right', club: 'Hoffenheim', clubLeague: 'Bundesliga', marketValue: 12000000, caps: 90, goals: 26 },
      { firstName: 'Luka', lastName: 'Modric', jerseyNumber: 10, position: 'CM', dateOfBirth: '1985-09-09', height: 172, weight: 66, preferredFoot: 'Both', club: 'Real Madrid', clubLeague: 'La Liga', marketValue: 8000000, caps: 180, goals: 25 },
      { firstName: 'Marcelo', lastName: 'Brozovic', jerseyNumber: 11, position: 'CDM', dateOfBirth: '1992-11-16', height: 181, weight: 68, preferredFoot: 'Right', club: 'Al-Nassr', clubLeague: 'Saudi Pro League', marketValue: 10000000, caps: 100, goals: 8 },
      { firstName: 'Ivica', lastName: 'Ivusic', jerseyNumber: 12, position: 'GK', dateOfBirth: '1995-02-01', height: 192, weight: 85, preferredFoot: 'Right', club: 'Pafos', clubLeague: 'Cypriot First Division', marketValue: 1500000, caps: 15, goals: 0 },
      { firstName: 'Mario', lastName: 'Pasalic', jerseyNumber: 13, position: 'CAM', dateOfBirth: '1995-02-09', height: 189, weight: 78, preferredFoot: 'Right', club: 'Atalanta', clubLeague: 'Serie A', marketValue: 25000000, caps: 50, goals: 6 },
      { firstName: 'Marko', lastName: 'Livaja', jerseyNumber: 14, position: 'ST', dateOfBirth: '1993-08-26', height: 184, weight: 78, preferredFoot: 'Right', club: 'Hajduk Split', clubLeague: 'Prva HNL', marketValue: 5000000, caps: 30, goals: 10 },
      { firstName: 'Bruno', lastName: 'Petkovic', jerseyNumber: 16, position: 'ST', dateOfBirth: '1994-09-16', height: 191, weight: 87, preferredFoot: 'Right', club: 'Dinamo Zagreb', clubLeague: 'Prva HNL', marketValue: 8000000, caps: 45, goals: 9 },
      { firstName: 'Josko', lastName: 'Gvardiol', jerseyNumber: 24, position: 'CB', dateOfBirth: '2002-01-23', height: 185, weight: 80, preferredFoot: 'Left', club: 'Manchester City', clubLeague: 'Premier League', marketValue: 85000000, caps: 35, goals: 3 },
      { firstName: 'Luka', lastName: 'Sucic', jerseyNumber: 17, position: 'CAM', dateOfBirth: '2002-09-08', height: 181, weight: 73, preferredFoot: 'Left', club: 'Real Sociedad', clubLeague: 'La Liga', marketValue: 20000000, caps: 15, goals: 2 },
      { firstName: 'Mislav', lastName: 'Orsic', jerseyNumber: 18, position: 'LW', dateOfBirth: '1992-12-29', height: 177, weight: 74, preferredFoot: 'Right', club: 'Trabzonspor', clubLeague: 'Super Lig', marketValue: 5000000, caps: 35, goals: 10 },
      { firstName: 'Borna', lastName: 'Sosa', jerseyNumber: 19, position: 'LB', dateOfBirth: '1998-01-21', height: 187, weight: 75, preferredFoot: 'Left', club: 'Ajax', clubLeague: 'Eredivisie', marketValue: 15000000, caps: 25, goals: 0 },
      { firstName: 'Domagoj', lastName: 'Vida', jerseyNumber: 21, position: 'CB', dateOfBirth: '1989-04-29', height: 184, weight: 79, preferredFoot: 'Right', club: 'AEK Athens', clubLeague: 'Super League Greece', marketValue: 1000000, caps: 110, goals: 4 },
      { firstName: 'Josip', lastName: 'Juranovic', jerseyNumber: 22, position: 'RB', dateOfBirth: '1995-08-16', height: 173, weight: 70, preferredFoot: 'Right', club: 'Union Berlin', clubLeague: 'Bundesliga', marketValue: 10000000, caps: 40, goals: 1 },
      { firstName: 'Duje', lastName: 'Caleta-Car', jerseyNumber: 23, position: 'CB', dateOfBirth: '1996-09-17', height: 192, weight: 89, preferredFoot: 'Right', club: 'Lyon', clubLeague: 'Ligue 1', marketValue: 10000000, caps: 35, goals: 0 },
      { firstName: 'Ante', lastName: 'Budimir', jerseyNumber: 15, position: 'ST', dateOfBirth: '1991-07-22', height: 190, weight: 84, preferredFoot: 'Right', club: 'Osasuna', clubLeague: 'La Liga', marketValue: 6000000, caps: 20, goals: 4 },
      { firstName: 'Dominik', lastName: 'Kotarski', jerseyNumber: 25, position: 'GK', dateOfBirth: '2000-02-10', height: 193, weight: 85, preferredFoot: 'Right', club: 'PAOK', clubLeague: 'Super League Greece', marketValue: 4000000, caps: 5, goals: 0 },
      { firstName: 'Josip', lastName: 'Sutalo', jerseyNumber: 20, position: 'CB', dateOfBirth: '2000-02-28', height: 190, weight: 83, preferredFoot: 'Right', club: 'Ajax', clubLeague: 'Eredivisie', marketValue: 18000000, caps: 20, goals: 0 },
      { firstName: 'Nikola', lastName: 'Vlasic', jerseyNumber: 26, position: 'CAM', dateOfBirth: '1997-10-04', height: 178, weight: 73, preferredFoot: 'Right', club: 'Torino', clubLeague: 'Serie A', marketValue: 15000000, caps: 45, goals: 4 },
    ],
  },

  // ========== KOREA REPUBLIC ==========
  {
    name: 'Korea Republic',
    fifaCode: 'KOR',
    players: [
      { firstName: 'Kim', lastName: 'Seung-gyu', jerseyNumber: 1, position: 'GK', dateOfBirth: '1990-09-30', height: 187, weight: 84, preferredFoot: 'Right', club: 'Al-Shabab', clubLeague: 'Saudi Pro League', marketValue: 2000000, caps: 60, goals: 0 },
      { firstName: 'Lee', lastName: 'Yong', jerseyNumber: 2, position: 'RB', dateOfBirth: '1986-12-24', height: 178, weight: 70, preferredFoot: 'Right', club: 'Jeonbuk', clubLeague: 'K League 1', marketValue: 300000, caps: 85, goals: 2 },
      { firstName: 'Kim', lastName: 'Jin-su', jerseyNumber: 3, position: 'LB', dateOfBirth: '1992-06-13', height: 177, weight: 67, preferredFoot: 'Left', club: 'Jeonbuk', clubLeague: 'K League 1', marketValue: 1500000, caps: 65, goals: 4 },
      { firstName: 'Kim', lastName: 'Min-jae', jerseyNumber: 4, position: 'CB', dateOfBirth: '1996-11-15', height: 190, weight: 88, preferredFoot: 'Right', club: 'Bayern Munich', clubLeague: 'Bundesliga', marketValue: 70000000, caps: 50, goals: 2 },
      { firstName: 'Jung', lastName: 'Woo-young', jerseyNumber: 5, position: 'CDM', dateOfBirth: '1989-12-14', height: 186, weight: 75, preferredFoot: 'Right', club: 'Al-Sadd', clubLeague: 'Qatar Stars League', marketValue: 2000000, caps: 110, goals: 1 },
      { firstName: 'Hwang', lastName: 'In-beom', jerseyNumber: 6, position: 'CM', dateOfBirth: '1996-09-20', height: 177, weight: 67, preferredFoot: 'Right', club: 'Feyenoord', clubLeague: 'Eredivisie', marketValue: 12000000, caps: 45, goals: 5 },
      { firstName: 'Heung-Min', lastName: 'Son', jerseyNumber: 7, position: 'LW', dateOfBirth: '1992-07-08', height: 183, weight: 78, preferredFoot: 'Both', club: 'Tottenham', clubLeague: 'Premier League', marketValue: 65000000, caps: 120, goals: 45 },
      { firstName: 'Paik', lastName: 'Seung-ho', jerseyNumber: 8, position: 'CM', dateOfBirth: '1997-03-17', height: 183, weight: 68, preferredFoot: 'Right', club: 'Jeonbuk', clubLeague: 'K League 1', marketValue: 2000000, caps: 30, goals: 2 },
      { firstName: 'Cho', lastName: 'Gue-sung', jerseyNumber: 9, position: 'ST', dateOfBirth: '1998-01-25', height: 188, weight: 78, preferredFoot: 'Right', club: 'Midtjylland', clubLeague: 'Danish Superliga', marketValue: 6000000, caps: 25, goals: 9 },
      { firstName: 'Lee', lastName: 'Jae-sung', jerseyNumber: 10, position: 'CAM', dateOfBirth: '1992-08-10', height: 180, weight: 71, preferredFoot: 'Right', club: 'Mainz', clubLeague: 'Bundesliga', marketValue: 5000000, caps: 75, goals: 11 },
      { firstName: 'Hwang', lastName: 'Hee-chan', jerseyNumber: 11, position: 'ST', dateOfBirth: '1996-01-26', height: 177, weight: 73, preferredFoot: 'Right', club: 'Wolverhampton', clubLeague: 'Premier League', marketValue: 28000000, caps: 55, goals: 12 },
      { firstName: 'Jo', lastName: 'Hyeon-woo', jerseyNumber: 12, position: 'GK', dateOfBirth: '1991-09-25', height: 189, weight: 84, preferredFoot: 'Right', club: 'Ulsan HD', clubLeague: 'K League 1', marketValue: 1500000, caps: 45, goals: 0 },
      { firstName: 'Son', lastName: 'Jun-ho', jerseyNumber: 13, position: 'CM', dateOfBirth: '1992-05-12', height: 183, weight: 74, preferredFoot: 'Right', club: 'Shandong Taishan', clubLeague: 'Chinese Super League', marketValue: 2000000, caps: 50, goals: 3 },
      { firstName: 'Hong', lastName: 'Chul', jerseyNumber: 14, position: 'LB', dateOfBirth: '1990-09-17', height: 173, weight: 62, preferredFoot: 'Left', club: 'Daegu FC', clubLeague: 'K League 1', marketValue: 500000, caps: 50, goals: 0 },
      { firstName: 'Na', lastName: 'Sang-ho', jerseyNumber: 15, position: 'RW', dateOfBirth: '1996-08-12', height: 173, weight: 68, preferredFoot: 'Right', club: 'FC Seoul', clubLeague: 'K League 1', marketValue: 1500000, caps: 35, goals: 2 },
      { firstName: 'Hwang', lastName: 'Ui-jo', jerseyNumber: 16, position: 'ST', dateOfBirth: '1992-08-28', height: 185, weight: 78, preferredFoot: 'Right', club: 'Alanyaspor', clubLeague: 'Super Lig', marketValue: 4000000, caps: 60, goals: 18 },
      { firstName: 'Lee', lastName: 'Kang-in', jerseyNumber: 17, position: 'RW', dateOfBirth: '2001-02-19', height: 173, weight: 63, preferredFoot: 'Left', club: 'Paris Saint-Germain', clubLeague: 'Ligue 1', marketValue: 45000000, caps: 40, goals: 8 },
      { firstName: 'Jeong', lastName: 'Woo-yeong', jerseyNumber: 18, position: 'CAM', dateOfBirth: '1999-09-20', height: 180, weight: 70, preferredFoot: 'Right', club: 'Freiburg', clubLeague: 'Bundesliga', marketValue: 10000000, caps: 25, goals: 3 },
      { firstName: 'Kim', lastName: 'Young-gwon', jerseyNumber: 19, position: 'CB', dateOfBirth: '1990-02-27', height: 186, weight: 81, preferredFoot: 'Left', club: 'Ulsan HD', clubLeague: 'K League 1', marketValue: 1500000, caps: 105, goals: 5 },
      { firstName: 'Lee', lastName: 'Dong-jun', jerseyNumber: 20, position: 'CM', dateOfBirth: '1997-09-15', height: 176, weight: 67, preferredFoot: 'Right', club: 'Ulsan HD', clubLeague: 'K League 1', marketValue: 1000000, caps: 15, goals: 0 },
      { firstName: 'Kim', lastName: 'Tae-hwan', jerseyNumber: 21, position: 'RB', dateOfBirth: '1989-07-24', height: 175, weight: 68, preferredFoot: 'Right', club: 'Ulsan HD', clubLeague: 'K League 1', marketValue: 500000, caps: 45, goals: 0 },
      { firstName: 'Kwon', lastName: 'Chang-hoon', jerseyNumber: 22, position: 'CAM', dateOfBirth: '1994-06-30', height: 173, weight: 68, preferredFoot: 'Right', club: 'Gimcheon Sangmu', clubLeague: 'K League 1', marketValue: 2000000, caps: 45, goals: 6 },
      { firstName: 'Song', lastName: 'Bum-keun', jerseyNumber: 23, position: 'GK', dateOfBirth: '1997-10-15', height: 193, weight: 84, preferredFoot: 'Right', club: 'Jeonbuk', clubLeague: 'K League 1', marketValue: 1500000, caps: 10, goals: 0 },
      { firstName: 'Seol', lastName: 'Young-woo', jerseyNumber: 24, position: 'CB', dateOfBirth: '1999-01-26', height: 187, weight: 77, preferredFoot: 'Right', club: 'Ulsan HD', clubLeague: 'K League 1', marketValue: 2000000, caps: 10, goals: 0 },
      { firstName: 'Kim', lastName: 'Moon-hwan', jerseyNumber: 25, position: 'RB', dateOfBirth: '1995-08-01', height: 175, weight: 65, preferredFoot: 'Right', club: 'Jeonbuk', clubLeague: 'K League 1', marketValue: 1500000, caps: 40, goals: 0 },
      { firstName: 'Oh', lastName: 'Hyeon-gyu', jerseyNumber: 26, position: 'ST', dateOfBirth: '2001-01-12', height: 180, weight: 75, preferredFoot: 'Right', club: 'Celtic', clubLeague: 'Scottish Premiership', marketValue: 12000000, caps: 10, goals: 2 },
    ],
  },

  // ========== BRAZIL ==========
  {
    name: 'Brazil',
    fifaCode: 'BRA',
    players: [
      { firstName: 'Alisson', lastName: 'Becker', jerseyNumber: 1, position: 'GK', dateOfBirth: '1992-10-02', height: 191, weight: 91, preferredFoot: 'Right', club: 'Liverpool', clubLeague: 'Premier League', marketValue: 35000000, caps: 70, goals: 0 },
      { firstName: 'Danilo', lastName: 'Luiz', jerseyNumber: 2, position: 'RB', dateOfBirth: '1991-07-15', height: 184, weight: 77, preferredFoot: 'Right', club: 'Juventus', clubLeague: 'Serie A', marketValue: 5000000, caps: 65, goals: 2 },
      { firstName: 'Thiago', lastName: 'Silva', jerseyNumber: 3, position: 'CB', dateOfBirth: '1984-09-22', height: 183, weight: 79, preferredFoot: 'Right', club: 'Fluminense', clubLeague: 'Serie A Brazil', marketValue: 3000000, caps: 115, goals: 7 },
      { firstName: 'Marquinhos', lastName: 'Aoás', jerseyNumber: 4, position: 'CB', dateOfBirth: '1994-05-14', height: 183, weight: 75, preferredFoot: 'Right', club: 'Paris Saint-Germain', clubLeague: 'Ligue 1', marketValue: 40000000, caps: 85, goals: 5 },
      { firstName: 'Casemiro', lastName: 'Henrique', jerseyNumber: 5, position: 'CDM', dateOfBirth: '1992-02-23', height: 185, weight: 84, preferredFoot: 'Right', club: 'Manchester United', clubLeague: 'Premier League', marketValue: 20000000, caps: 75, goals: 7 },
      { firstName: 'Alex', lastName: 'Sandro', jerseyNumber: 6, position: 'LB', dateOfBirth: '1991-01-26', height: 181, weight: 78, preferredFoot: 'Left', club: 'Flamengo', clubLeague: 'Serie A Brazil', marketValue: 3000000, caps: 40, goals: 2 },
      { firstName: 'Vinícius', lastName: 'Júnior', jerseyNumber: 7, position: 'LW', dateOfBirth: '2000-07-12', height: 176, weight: 73, preferredFoot: 'Right', club: 'Real Madrid', clubLeague: 'La Liga', marketValue: 180000000, caps: 35, goals: 6 },
      { firstName: 'Lucas', lastName: 'Paquetá', jerseyNumber: 8, position: 'CAM', dateOfBirth: '1997-08-27', height: 180, weight: 72, preferredFoot: 'Left', club: 'West Ham', clubLeague: 'Premier League', marketValue: 45000000, caps: 50, goals: 11 },
      { firstName: 'Richarlison', lastName: 'de Andrade', jerseyNumber: 9, position: 'ST', dateOfBirth: '1997-05-10', height: 184, weight: 83, preferredFoot: 'Right', club: 'Tottenham', clubLeague: 'Premier League', marketValue: 45000000, caps: 55, goals: 20 },
      { firstName: 'Rodrygo', lastName: 'Goes', jerseyNumber: 10, position: 'RW', dateOfBirth: '2001-01-09', height: 174, weight: 64, preferredFoot: 'Right', club: 'Real Madrid', clubLeague: 'La Liga', marketValue: 110000000, caps: 25, goals: 6 },
      { firstName: 'Raphinha', lastName: 'Dias', jerseyNumber: 11, position: 'RW', dateOfBirth: '1996-12-14', height: 176, weight: 68, preferredFoot: 'Left', club: 'Barcelona', clubLeague: 'La Liga', marketValue: 65000000, caps: 30, goals: 7 },
      { firstName: 'Ederson', lastName: 'Moraes', jerseyNumber: 12, position: 'GK', dateOfBirth: '1993-08-17', height: 188, weight: 86, preferredFoot: 'Left', club: 'Manchester City', clubLeague: 'Premier League', marketValue: 35000000, caps: 20, goals: 0 },
      { firstName: 'Éder', lastName: 'Militão', jerseyNumber: 13, position: 'CB', dateOfBirth: '1998-01-18', height: 186, weight: 78, preferredFoot: 'Right', club: 'Real Madrid', clubLeague: 'La Liga', marketValue: 60000000, caps: 30, goals: 1 },
      { firstName: 'Bruno', lastName: 'Guimarães', jerseyNumber: 14, position: 'CM', dateOfBirth: '1997-11-16', height: 182, weight: 77, preferredFoot: 'Right', club: 'Newcastle', clubLeague: 'Premier League', marketValue: 80000000, caps: 25, goals: 1 },
      { firstName: 'Guilherme', lastName: 'Arana', jerseyNumber: 15, position: 'LB', dateOfBirth: '1997-04-14', height: 176, weight: 71, preferredFoot: 'Left', club: 'Atlético Mineiro', clubLeague: 'Serie A Brazil', marketValue: 10000000, caps: 15, goals: 2 },
      { firstName: 'Wendell', lastName: 'Nascimento', jerseyNumber: 16, position: 'LB', dateOfBirth: '1993-07-20', height: 175, weight: 67, preferredFoot: 'Left', club: 'Porto', clubLeague: 'Primeira Liga', marketValue: 5000000, caps: 10, goals: 0 },
      { firstName: 'Endrick', lastName: 'Felipe', jerseyNumber: 17, position: 'ST', dateOfBirth: '2006-07-21', height: 173, weight: 72, preferredFoot: 'Right', club: 'Real Madrid', clubLeague: 'La Liga', marketValue: 60000000, caps: 10, goals: 3 },
      { firstName: 'Gabriel', lastName: 'Jesus', jerseyNumber: 18, position: 'ST', dateOfBirth: '1997-04-03', height: 175, weight: 73, preferredFoot: 'Right', club: 'Arsenal', clubLeague: 'Premier League', marketValue: 45000000, caps: 60, goals: 19 },
      { firstName: 'Gabriel', lastName: 'Magalhães', jerseyNumber: 19, position: 'CB', dateOfBirth: '1997-12-19', height: 190, weight: 78, preferredFoot: 'Left', club: 'Arsenal', clubLeague: 'Premier League', marketValue: 70000000, caps: 15, goals: 0 },
      { firstName: 'Antony', lastName: 'Santos', jerseyNumber: 20, position: 'RW', dateOfBirth: '2000-02-24', height: 176, weight: 65, preferredFoot: 'Left', club: 'Manchester United', clubLeague: 'Premier League', marketValue: 30000000, caps: 15, goals: 2 },
      { firstName: 'Yan', lastName: 'Couto', jerseyNumber: 21, position: 'RB', dateOfBirth: '2002-06-03', height: 168, weight: 62, preferredFoot: 'Right', club: 'Borussia Dortmund', clubLeague: 'Bundesliga', marketValue: 25000000, caps: 5, goals: 0 },
      { firstName: 'Bento', lastName: 'Krepski', jerseyNumber: 22, position: 'GK', dateOfBirth: '1999-03-16', height: 193, weight: 90, preferredFoot: 'Right', club: 'Athletico Paranaense', clubLeague: 'Serie A Brazil', marketValue: 10000000, caps: 5, goals: 0 },
      { firstName: 'João', lastName: 'Gomes', jerseyNumber: 23, position: 'CM', dateOfBirth: '2001-02-12', height: 177, weight: 72, preferredFoot: 'Right', club: 'Wolverhampton', clubLeague: 'Premier League', marketValue: 30000000, caps: 15, goals: 0 },
      { firstName: 'Bremer', lastName: 'Silva', jerseyNumber: 24, position: 'CB', dateOfBirth: '1997-03-18', height: 188, weight: 85, preferredFoot: 'Right', club: 'Juventus', clubLeague: 'Serie A', marketValue: 45000000, caps: 10, goals: 0 },
      { firstName: 'Pedro', lastName: 'Guilherme', jerseyNumber: 25, position: 'ST', dateOfBirth: '1997-06-20', height: 185, weight: 77, preferredFoot: 'Right', club: 'Flamengo', clubLeague: 'Serie A Brazil', marketValue: 15000000, caps: 10, goals: 3 },
      { firstName: 'Savinho', lastName: 'Moura', jerseyNumber: 26, position: 'RW', dateOfBirth: '2004-04-10', height: 176, weight: 64, preferredFoot: 'Left', club: 'Manchester City', clubLeague: 'Premier League', marketValue: 65000000, caps: 5, goals: 1 },
    ],
  },

  // ========== ARGENTINA ==========
  {
    name: 'Argentina',
    fifaCode: 'ARG',
    players: [
      { firstName: 'Emiliano', lastName: 'Martínez', jerseyNumber: 1, position: 'GK', dateOfBirth: '1992-09-02', height: 195, weight: 88, preferredFoot: 'Right', club: 'Aston Villa', clubLeague: 'Premier League', marketValue: 35000000, caps: 50, goals: 0 },
      { firstName: 'Nahuel', lastName: 'Molina', jerseyNumber: 2, position: 'RB', dateOfBirth: '1998-04-06', height: 175, weight: 70, preferredFoot: 'Right', club: 'Atlético Madrid', clubLeague: 'La Liga', marketValue: 30000000, caps: 35, goals: 3 },
      { firstName: 'Nicolás', lastName: 'Tagliafico', jerseyNumber: 3, position: 'LB', dateOfBirth: '1992-08-31', height: 172, weight: 65, preferredFoot: 'Left', club: 'Lyon', clubLeague: 'Ligue 1', marketValue: 10000000, caps: 55, goals: 1 },
      { firstName: 'Gonzalo', lastName: 'Montiel', jerseyNumber: 4, position: 'RB', dateOfBirth: '1997-01-01', height: 176, weight: 74, preferredFoot: 'Right', club: 'Sevilla', clubLeague: 'La Liga', marketValue: 12000000, caps: 25, goals: 0 },
      { firstName: 'Leandro', lastName: 'Paredes', jerseyNumber: 5, position: 'CM', dateOfBirth: '1994-06-29', height: 180, weight: 78, preferredFoot: 'Right', club: 'Roma', clubLeague: 'Serie A', marketValue: 12000000, caps: 60, goals: 5 },
      { firstName: 'Germán', lastName: 'Pezzella', jerseyNumber: 6, position: 'CB', dateOfBirth: '1991-06-27', height: 187, weight: 79, preferredFoot: 'Right', club: 'River Plate', clubLeague: 'Liga Argentina', marketValue: 3000000, caps: 35, goals: 1 },
      { firstName: 'Rodrigo', lastName: 'De Paul', jerseyNumber: 7, position: 'CM', dateOfBirth: '1994-05-24', height: 180, weight: 70, preferredFoot: 'Right', club: 'Atlético Madrid', clubLeague: 'La Liga', marketValue: 30000000, caps: 60, goals: 3 },
      { firstName: 'Enzo', lastName: 'Fernández', jerseyNumber: 8, position: 'CM', dateOfBirth: '2001-01-17', height: 178, weight: 77, preferredFoot: 'Right', club: 'Chelsea', clubLeague: 'Premier League', marketValue: 85000000, caps: 30, goals: 3 },
      { firstName: 'Julián', lastName: 'Álvarez', jerseyNumber: 9, position: 'ST', dateOfBirth: '2000-01-31', height: 170, weight: 71, preferredFoot: 'Right', club: 'Atlético Madrid', clubLeague: 'La Liga', marketValue: 90000000, caps: 35, goals: 12 },
      { firstName: 'Lionel', lastName: 'Messi', jerseyNumber: 10, position: 'RW', dateOfBirth: '1987-06-24', height: 170, weight: 72, preferredFoot: 'Left', club: 'Inter Miami', clubLeague: 'MLS', marketValue: 25000000, caps: 185, goals: 109 },
      { firstName: 'Ángel', lastName: 'Di María', jerseyNumber: 11, position: 'RW', dateOfBirth: '1988-02-14', height: 180, weight: 75, preferredFoot: 'Left', club: 'Benfica', clubLeague: 'Primeira Liga', marketValue: 8000000, caps: 140, goals: 30 },
      { firstName: 'Gerónimo', lastName: 'Rulli', jerseyNumber: 12, position: 'GK', dateOfBirth: '1992-05-20', height: 189, weight: 87, preferredFoot: 'Right', club: 'Marseille', clubLeague: 'Ligue 1', marketValue: 8000000, caps: 10, goals: 0 },
      { firstName: 'Cristian', lastName: 'Romero', jerseyNumber: 13, position: 'CB', dateOfBirth: '1998-04-27', height: 185, weight: 78, preferredFoot: 'Right', club: 'Tottenham', clubLeague: 'Premier League', marketValue: 55000000, caps: 25, goals: 2 },
      { firstName: 'Exequiel', lastName: 'Palacios', jerseyNumber: 14, position: 'CM', dateOfBirth: '1998-10-05', height: 177, weight: 66, preferredFoot: 'Right', club: 'Bayer Leverkusen', clubLeague: 'Bundesliga', marketValue: 25000000, caps: 25, goals: 1 },
      { firstName: 'Nicolás', lastName: 'González', jerseyNumber: 15, position: 'LW', dateOfBirth: '1998-04-06', height: 180, weight: 75, preferredFoot: 'Left', club: 'Juventus', clubLeague: 'Serie A', marketValue: 25000000, caps: 35, goals: 6 },
      { firstName: 'Thiago', lastName: 'Almada', jerseyNumber: 16, position: 'CAM', dateOfBirth: '2001-04-26', height: 171, weight: 66, preferredFoot: 'Right', club: 'Botafogo', clubLeague: 'Serie A Brazil', marketValue: 25000000, caps: 15, goals: 1 },
      { firstName: 'Alejandro', lastName: 'Garnacho', jerseyNumber: 17, position: 'LW', dateOfBirth: '2004-07-01', height: 180, weight: 72, preferredFoot: 'Right', club: 'Manchester United', clubLeague: 'Premier League', marketValue: 50000000, caps: 10, goals: 2 },
      { firstName: 'Guido', lastName: 'Rodríguez', jerseyNumber: 18, position: 'CDM', dateOfBirth: '1994-04-12', height: 185, weight: 80, preferredFoot: 'Right', club: 'West Ham', clubLeague: 'Premier League', marketValue: 15000000, caps: 35, goals: 0 },
      { firstName: 'Nicolás', lastName: 'Otamendi', jerseyNumber: 19, position: 'CB', dateOfBirth: '1988-02-12', height: 183, weight: 82, preferredFoot: 'Right', club: 'Benfica', clubLeague: 'Primeira Liga', marketValue: 3000000, caps: 110, goals: 7 },
      { firstName: 'Giovani', lastName: 'Lo Celso', jerseyNumber: 20, position: 'CAM', dateOfBirth: '1996-04-09', height: 177, weight: 68, preferredFoot: 'Left', club: 'Real Betis', clubLeague: 'La Liga', marketValue: 20000000, caps: 50, goals: 4 },
      { firstName: 'Paulo', lastName: 'Dybala', jerseyNumber: 21, position: 'CAM', dateOfBirth: '1993-11-15', height: 177, weight: 75, preferredFoot: 'Left', club: 'Roma', clubLeague: 'Serie A', marketValue: 25000000, caps: 40, goals: 5 },
      { firstName: 'Lautaro', lastName: 'Martínez', jerseyNumber: 22, position: 'ST', dateOfBirth: '1997-08-22', height: 174, weight: 72, preferredFoot: 'Right', club: 'Inter Milan', clubLeague: 'Serie A', marketValue: 85000000, caps: 60, goals: 28 },
      { firstName: 'Franco', lastName: 'Armani', jerseyNumber: 23, position: 'GK', dateOfBirth: '1986-10-16', height: 189, weight: 85, preferredFoot: 'Right', club: 'River Plate', clubLeague: 'Liga Argentina', marketValue: 2000000, caps: 20, goals: 0 },
      { firstName: 'Lisandro', lastName: 'Martínez', jerseyNumber: 24, position: 'CB', dateOfBirth: '1998-01-18', height: 175, weight: 77, preferredFoot: 'Left', club: 'Manchester United', clubLeague: 'Premier League', marketValue: 55000000, caps: 25, goals: 0 },
      { firstName: 'Marcos', lastName: 'Acuña', jerseyNumber: 25, position: 'LB', dateOfBirth: '1991-10-28', height: 172, weight: 69, preferredFoot: 'Left', club: 'River Plate', clubLeague: 'Liga Argentina', marketValue: 3000000, caps: 60, goals: 5 },
      { firstName: 'Valentín', lastName: 'Carboni', jerseyNumber: 26, position: 'CAM', dateOfBirth: '2005-03-05', height: 178, weight: 68, preferredFoot: 'Left', club: 'Inter Milan', clubLeague: 'Serie A', marketValue: 25000000, caps: 5, goals: 0 },
    ],
  },

  // ========== FRANCE ==========
  {
    name: 'France',
    fifaCode: 'FRA',
    players: [
      { firstName: 'Mike', lastName: 'Maignan', jerseyNumber: 1, position: 'GK', dateOfBirth: '1995-07-03', height: 191, weight: 91, preferredFoot: 'Right', club: 'AC Milan', clubLeague: 'Serie A', marketValue: 40000000, caps: 20, goals: 0 },
      { firstName: 'Benjamin', lastName: 'Pavard', jerseyNumber: 2, position: 'RB', dateOfBirth: '1996-03-28', height: 186, weight: 85, preferredFoot: 'Right', club: 'Inter Milan', clubLeague: 'Serie A', marketValue: 35000000, caps: 55, goals: 3 },
      { firstName: 'Presnel', lastName: 'Kimpembe', jerseyNumber: 3, position: 'CB', dateOfBirth: '1995-08-13', height: 183, weight: 84, preferredFoot: 'Left', club: 'Paris Saint-Germain', clubLeague: 'Ligue 1', marketValue: 20000000, caps: 35, goals: 0 },
      { firstName: 'Raphaël', lastName: 'Varane', jerseyNumber: 4, position: 'CB', dateOfBirth: '1993-04-25', height: 191, weight: 81, preferredFoot: 'Right', club: 'Como', clubLeague: 'Serie A', marketValue: 10000000, caps: 95, goals: 5 },
      { firstName: 'Jules', lastName: 'Koundé', jerseyNumber: 5, position: 'RB', dateOfBirth: '1998-11-12', height: 180, weight: 75, preferredFoot: 'Right', club: 'Barcelona', clubLeague: 'La Liga', marketValue: 60000000, caps: 30, goals: 0 },
      { firstName: 'Eduardo', lastName: 'Camavinga', jerseyNumber: 6, position: 'CM', dateOfBirth: '2002-11-10', height: 182, weight: 68, preferredFoot: 'Left', club: 'Real Madrid', clubLeague: 'La Liga', marketValue: 70000000, caps: 25, goals: 1 },
      { firstName: 'Antoine', lastName: 'Griezmann', jerseyNumber: 7, position: 'CAM', dateOfBirth: '1991-03-21', height: 176, weight: 73, preferredFoot: 'Left', club: 'Atlético Madrid', clubLeague: 'La Liga', marketValue: 25000000, caps: 135, goals: 45 },
      { firstName: 'Aurélien', lastName: 'Tchouaméni', jerseyNumber: 8, position: 'CDM', dateOfBirth: '2000-01-27', height: 187, weight: 81, preferredFoot: 'Right', club: 'Real Madrid', clubLeague: 'La Liga', marketValue: 80000000, caps: 35, goals: 2 },
      { firstName: 'Olivier', lastName: 'Giroud', jerseyNumber: 9, position: 'ST', dateOfBirth: '1986-09-30', height: 193, weight: 93, preferredFoot: 'Right', club: 'LA FC', clubLeague: 'MLS', marketValue: 2000000, caps: 135, goals: 57 },
      { firstName: 'Kylian', lastName: 'Mbappé', jerseyNumber: 10, position: 'LW', dateOfBirth: '1998-12-20', height: 178, weight: 75, preferredFoot: 'Right', club: 'Real Madrid', clubLeague: 'La Liga', marketValue: 180000000, caps: 85, goals: 48 },
      { firstName: 'Ousmane', lastName: 'Dembélé', jerseyNumber: 11, position: 'RW', dateOfBirth: '1997-05-15', height: 178, weight: 67, preferredFoot: 'Both', club: 'Paris Saint-Germain', clubLeague: 'Ligue 1', marketValue: 70000000, caps: 50, goals: 6 },
      { firstName: 'Brice', lastName: 'Samba', jerseyNumber: 12, position: 'GK', dateOfBirth: '1994-04-25', height: 187, weight: 85, preferredFoot: 'Right', club: 'Lens', clubLeague: 'Ligue 1', marketValue: 12000000, caps: 5, goals: 0 },
      { firstName: 'William', lastName: 'Saliba', jerseyNumber: 13, position: 'CB', dateOfBirth: '2001-03-24', height: 192, weight: 90, preferredFoot: 'Right', club: 'Arsenal', clubLeague: 'Premier League', marketValue: 80000000, caps: 20, goals: 1 },
      { firstName: 'Adrien', lastName: 'Rabiot', jerseyNumber: 14, position: 'CM', dateOfBirth: '1995-04-03', height: 188, weight: 77, preferredFoot: 'Left', club: 'Marseille', clubLeague: 'Ligue 1', marketValue: 25000000, caps: 50, goals: 5 },
      { firstName: 'Marcus', lastName: 'Thuram', jerseyNumber: 15, position: 'ST', dateOfBirth: '1997-08-06', height: 192, weight: 90, preferredFoot: 'Right', club: 'Inter Milan', clubLeague: 'Serie A', marketValue: 60000000, caps: 25, goals: 5 },
      { firstName: 'Alphonse', lastName: 'Areola', jerseyNumber: 16, position: 'GK', dateOfBirth: '1993-02-27', height: 195, weight: 85, preferredFoot: 'Right', club: 'West Ham', clubLeague: 'Premier League', marketValue: 8000000, caps: 10, goals: 0 },
      { firstName: 'Dayot', lastName: 'Upamecano', jerseyNumber: 17, position: 'CB', dateOfBirth: '1998-10-27', height: 186, weight: 90, preferredFoot: 'Right', club: 'Bayern Munich', clubLeague: 'Bundesliga', marketValue: 50000000, caps: 20, goals: 1 },
      { firstName: 'Warren', lastName: 'Zaïre-Emery', jerseyNumber: 18, position: 'CM', dateOfBirth: '2006-03-08', height: 178, weight: 68, preferredFoot: 'Right', club: 'Paris Saint-Germain', clubLeague: 'Ligue 1', marketValue: 60000000, caps: 15, goals: 2 },
      { firstName: 'Youssouf', lastName: 'Fofana', jerseyNumber: 19, position: 'CDM', dateOfBirth: '1999-01-10', height: 185, weight: 75, preferredFoot: 'Right', club: 'AC Milan', clubLeague: 'Serie A', marketValue: 35000000, caps: 20, goals: 0 },
      { firstName: 'Kingsley', lastName: 'Coman', jerseyNumber: 20, position: 'RW', dateOfBirth: '1996-06-13', height: 180, weight: 67, preferredFoot: 'Right', club: 'Bayern Munich', clubLeague: 'Bundesliga', marketValue: 45000000, caps: 60, goals: 8 },
      { firstName: 'Jonathan', lastName: 'Clauss', jerseyNumber: 21, position: 'RB', dateOfBirth: '1992-09-25', height: 180, weight: 75, preferredFoot: 'Right', club: 'Nice', clubLeague: 'Ligue 1', marketValue: 8000000, caps: 20, goals: 2 },
      { firstName: 'Theo', lastName: 'Hernández', jerseyNumber: 22, position: 'LB', dateOfBirth: '1997-10-06', height: 184, weight: 81, preferredFoot: 'Left', club: 'AC Milan', clubLeague: 'Serie A', marketValue: 55000000, caps: 25, goals: 3 },
      { firstName: 'Ferland', lastName: 'Mendy', jerseyNumber: 23, position: 'LB', dateOfBirth: '1995-06-08', height: 180, weight: 73, preferredFoot: 'Left', club: 'Real Madrid', clubLeague: 'La Liga', marketValue: 35000000, caps: 15, goals: 0 },
      { firstName: 'Ibrahima', lastName: 'Konaté', jerseyNumber: 24, position: 'CB', dateOfBirth: '1999-05-25', height: 194, weight: 95, preferredFoot: 'Right', club: 'Liverpool', clubLeague: 'Premier League', marketValue: 55000000, caps: 15, goals: 0 },
      { firstName: 'Randal', lastName: 'Kolo Muani', jerseyNumber: 25, position: 'ST', dateOfBirth: '1998-12-05', height: 187, weight: 80, preferredFoot: 'Right', club: 'Paris Saint-Germain', clubLeague: 'Ligue 1', marketValue: 50000000, caps: 20, goals: 4 },
      { firstName: 'Michael', lastName: 'Olise', jerseyNumber: 26, position: 'RW', dateOfBirth: '2001-12-12', height: 185, weight: 75, preferredFoot: 'Left', club: 'Bayern Munich', clubLeague: 'Bundesliga', marketValue: 55000000, caps: 10, goals: 3 },
    ],
  },

  // ========== ENGLAND ==========
  {
    name: 'England',
    fifaCode: 'ENG',
    players: [
      { firstName: 'Jordan', lastName: 'Pickford', jerseyNumber: 1, position: 'GK', dateOfBirth: '1994-03-07', height: 185, weight: 77, preferredFoot: 'Left', club: 'Everton', clubLeague: 'Premier League', marketValue: 25000000, caps: 65, goals: 0 },
      { firstName: 'Kyle', lastName: 'Walker', jerseyNumber: 2, position: 'RB', dateOfBirth: '1990-05-28', height: 183, weight: 80, preferredFoot: 'Right', club: 'Manchester City', clubLeague: 'Premier League', marketValue: 12000000, caps: 90, goals: 1 },
      { firstName: 'Luke', lastName: 'Shaw', jerseyNumber: 3, position: 'LB', dateOfBirth: '1995-07-12', height: 185, weight: 75, preferredFoot: 'Left', club: 'Manchester United', clubLeague: 'Premier League', marketValue: 25000000, caps: 35, goals: 1 },
      { firstName: 'Declan', lastName: 'Rice', jerseyNumber: 4, position: 'CDM', dateOfBirth: '1999-01-14', height: 188, weight: 80, preferredFoot: 'Right', club: 'Arsenal', clubLeague: 'Premier League', marketValue: 120000000, caps: 60, goals: 3 },
      { firstName: 'John', lastName: 'Stones', jerseyNumber: 5, position: 'CB', dateOfBirth: '1994-05-28', height: 188, weight: 82, preferredFoot: 'Right', club: 'Manchester City', clubLeague: 'Premier League', marketValue: 50000000, caps: 75, goals: 3 },
      { firstName: 'Harry', lastName: 'Maguire', jerseyNumber: 6, position: 'CB', dateOfBirth: '1993-03-05', height: 194, weight: 100, preferredFoot: 'Right', club: 'Manchester United', clubLeague: 'Premier League', marketValue: 20000000, caps: 65, goals: 7 },
      { firstName: 'Bukayo', lastName: 'Saka', jerseyNumber: 7, position: 'RW', dateOfBirth: '2001-09-05', height: 178, weight: 72, preferredFoot: 'Left', club: 'Arsenal', clubLeague: 'Premier League', marketValue: 140000000, caps: 45, goals: 12 },
      { firstName: 'Trent', lastName: 'Alexander-Arnold', jerseyNumber: 8, position: 'RB', dateOfBirth: '1998-10-07', height: 180, weight: 69, preferredFoot: 'Right', club: 'Liverpool', clubLeague: 'Premier League', marketValue: 70000000, caps: 30, goals: 2 },
      { firstName: 'Harry', lastName: 'Kane', jerseyNumber: 9, position: 'ST', dateOfBirth: '1993-07-28', height: 188, weight: 86, preferredFoot: 'Right', club: 'Bayern Munich', clubLeague: 'Bundesliga', marketValue: 100000000, caps: 100, goals: 65 },
      { firstName: 'Jude', lastName: 'Bellingham', jerseyNumber: 10, position: 'CAM', dateOfBirth: '2003-06-29', height: 186, weight: 75, preferredFoot: 'Right', club: 'Real Madrid', clubLeague: 'La Liga', marketValue: 180000000, caps: 40, goals: 6 },
      { firstName: 'Phil', lastName: 'Foden', jerseyNumber: 11, position: 'LW', dateOfBirth: '2000-05-28', height: 171, weight: 69, preferredFoot: 'Left', club: 'Manchester City', clubLeague: 'Premier League', marketValue: 150000000, caps: 45, goals: 4 },
      { firstName: 'Aaron', lastName: 'Ramsdale', jerseyNumber: 12, position: 'GK', dateOfBirth: '1998-05-14', height: 188, weight: 77, preferredFoot: 'Right', club: 'Southampton', clubLeague: 'Premier League', marketValue: 18000000, caps: 5, goals: 0 },
      { firstName: 'Marc', lastName: 'Guéhi', jerseyNumber: 13, position: 'CB', dateOfBirth: '2000-07-13', height: 182, weight: 72, preferredFoot: 'Right', club: 'Crystal Palace', clubLeague: 'Premier League', marketValue: 50000000, caps: 20, goals: 0 },
      { firstName: 'Kalvin', lastName: 'Phillips', jerseyNumber: 14, position: 'CDM', dateOfBirth: '1995-12-02', height: 179, weight: 72, preferredFoot: 'Right', club: 'Manchester City', clubLeague: 'Premier League', marketValue: 15000000, caps: 35, goals: 0 },
      { firstName: 'Kieran', lastName: 'Trippier', jerseyNumber: 15, position: 'RB', dateOfBirth: '1990-09-19', height: 178, weight: 71, preferredFoot: 'Right', club: 'Newcastle', clubLeague: 'Premier League', marketValue: 12000000, caps: 55, goals: 1 },
      { firstName: 'Conor', lastName: 'Gallagher', jerseyNumber: 16, position: 'CM', dateOfBirth: '2000-02-06', height: 182, weight: 72, preferredFoot: 'Right', club: 'Atlético Madrid', clubLeague: 'La Liga', marketValue: 40000000, caps: 20, goals: 0 },
      { firstName: 'Ivan', lastName: 'Toney', jerseyNumber: 17, position: 'ST', dateOfBirth: '1996-03-16', height: 185, weight: 85, preferredFoot: 'Right', club: 'Al-Ahli', clubLeague: 'Saudi Pro League', marketValue: 30000000, caps: 15, goals: 4 },
      { firstName: 'Anthony', lastName: 'Gordon', jerseyNumber: 18, position: 'LW', dateOfBirth: '2001-02-24', height: 183, weight: 76, preferredFoot: 'Right', club: 'Newcastle', clubLeague: 'Premier League', marketValue: 60000000, caps: 10, goals: 0 },
      { firstName: 'Ollie', lastName: 'Watkins', jerseyNumber: 19, position: 'ST', dateOfBirth: '1995-12-30', height: 180, weight: 70, preferredFoot: 'Right', club: 'Aston Villa', clubLeague: 'Premier League', marketValue: 55000000, caps: 15, goals: 5 },
      { firstName: 'Jarrod', lastName: 'Bowen', jerseyNumber: 20, position: 'RW', dateOfBirth: '1996-12-20', height: 175, weight: 70, preferredFoot: 'Left', club: 'West Ham', clubLeague: 'Premier League', marketValue: 45000000, caps: 15, goals: 1 },
      { firstName: 'Eberechi', lastName: 'Eze', jerseyNumber: 21, position: 'CAM', dateOfBirth: '1998-06-29', height: 178, weight: 74, preferredFoot: 'Left', club: 'Crystal Palace', clubLeague: 'Premier League', marketValue: 55000000, caps: 10, goals: 0 },
      { firstName: 'Nick', lastName: 'Pope', jerseyNumber: 22, position: 'GK', dateOfBirth: '1992-04-19', height: 198, weight: 87, preferredFoot: 'Right', club: 'Newcastle', clubLeague: 'Premier League', marketValue: 15000000, caps: 12, goals: 0 },
      { firstName: 'Ben', lastName: 'Chilwell', jerseyNumber: 23, position: 'LB', dateOfBirth: '1996-12-21', height: 178, weight: 77, preferredFoot: 'Left', club: 'Chelsea', clubLeague: 'Premier League', marketValue: 25000000, caps: 25, goals: 1 },
      { firstName: 'Cole', lastName: 'Palmer', jerseyNumber: 24, position: 'RW', dateOfBirth: '2002-05-06', height: 189, weight: 65, preferredFoot: 'Left', club: 'Chelsea', clubLeague: 'Premier League', marketValue: 90000000, caps: 15, goals: 4 },
      { firstName: 'Ezri', lastName: 'Konsa', jerseyNumber: 25, position: 'CB', dateOfBirth: '1997-10-23', height: 183, weight: 79, preferredFoot: 'Right', club: 'Aston Villa', clubLeague: 'Premier League', marketValue: 45000000, caps: 5, goals: 0 },
      { firstName: 'Kobbie', lastName: 'Mainoo', jerseyNumber: 26, position: 'CM', dateOfBirth: '2005-04-19', height: 180, weight: 70, preferredFoot: 'Right', club: 'Manchester United', clubLeague: 'Premier League', marketValue: 50000000, caps: 10, goals: 1 },
    ],
  },

  // ========== SPAIN ==========
  {
    name: 'Spain',
    fifaCode: 'ESP',
    players: [
      { firstName: 'Unai', lastName: 'Simón', jerseyNumber: 1, position: 'GK', dateOfBirth: '1997-06-11', height: 190, weight: 82, preferredFoot: 'Right', club: 'Athletic Bilbao', clubLeague: 'La Liga', marketValue: 30000000, caps: 45, goals: 0 },
      { firstName: 'Dani', lastName: 'Carvajal', jerseyNumber: 2, position: 'RB', dateOfBirth: '1992-01-11', height: 173, weight: 73, preferredFoot: 'Right', club: 'Real Madrid', clubLeague: 'La Liga', marketValue: 20000000, caps: 55, goals: 4 },
      { firstName: 'Aymeric', lastName: 'Laporte', jerseyNumber: 3, position: 'CB', dateOfBirth: '1994-05-27', height: 189, weight: 86, preferredFoot: 'Left', club: 'Al-Nassr', clubLeague: 'Saudi Pro League', marketValue: 20000000, caps: 35, goals: 2 },
      { firstName: 'Nacho', lastName: 'Fernández', jerseyNumber: 4, position: 'CB', dateOfBirth: '1990-01-18', height: 180, weight: 76, preferredFoot: 'Right', club: 'Al-Qadsiah', clubLeague: 'Saudi Pro League', marketValue: 5000000, caps: 45, goals: 2 },
      { firstName: 'Robin', lastName: 'Le Normand', jerseyNumber: 5, position: 'CB', dateOfBirth: '1996-11-11', height: 187, weight: 81, preferredFoot: 'Right', club: 'Atlético Madrid', clubLeague: 'La Liga', marketValue: 35000000, caps: 20, goals: 1 },
      { firstName: 'Mikel', lastName: 'Merino', jerseyNumber: 6, position: 'CM', dateOfBirth: '1996-06-22', height: 189, weight: 81, preferredFoot: 'Right', club: 'Arsenal', clubLeague: 'Premier League', marketValue: 45000000, caps: 25, goals: 2 },
      { firstName: 'Álvaro', lastName: 'Morata', jerseyNumber: 7, position: 'ST', dateOfBirth: '1992-10-23', height: 189, weight: 85, preferredFoot: 'Right', club: 'AC Milan', clubLeague: 'Serie A', marketValue: 15000000, caps: 85, goals: 35 },
      { firstName: 'Fabián', lastName: 'Ruiz', jerseyNumber: 8, position: 'CM', dateOfBirth: '1996-04-03', height: 189, weight: 74, preferredFoot: 'Left', club: 'Paris Saint-Germain', clubLeague: 'Ligue 1', marketValue: 40000000, caps: 40, goals: 7 },
      { firstName: 'Joselu', lastName: 'Mato', jerseyNumber: 9, position: 'ST', dateOfBirth: '1990-03-27', height: 192, weight: 80, preferredFoot: 'Right', club: 'Al-Gharafa', clubLeague: 'Qatar Stars League', marketValue: 5000000, caps: 20, goals: 8 },
      { firstName: 'Dani', lastName: 'Olmo', jerseyNumber: 10, position: 'CAM', dateOfBirth: '1998-05-07', height: 179, weight: 70, preferredFoot: 'Right', club: 'Barcelona', clubLeague: 'La Liga', marketValue: 60000000, caps: 50, goals: 10 },
      { firstName: 'Ferran', lastName: 'Torres', jerseyNumber: 11, position: 'LW', dateOfBirth: '2000-02-29', height: 184, weight: 72, preferredFoot: 'Right', club: 'Barcelona', clubLeague: 'La Liga', marketValue: 35000000, caps: 50, goals: 18 },
      { firstName: 'David', lastName: 'Raya', jerseyNumber: 12, position: 'GK', dateOfBirth: '1995-09-15', height: 183, weight: 80, preferredFoot: 'Right', club: 'Arsenal', clubLeague: 'Premier League', marketValue: 35000000, caps: 5, goals: 0 },
      { firstName: 'Alejandro', lastName: 'Grimaldo', jerseyNumber: 13, position: 'LB', dateOfBirth: '1995-09-20', height: 171, weight: 69, preferredFoot: 'Left', club: 'Bayer Leverkusen', clubLeague: 'Bundesliga', marketValue: 40000000, caps: 10, goals: 0 },
      { firstName: 'Rodri', lastName: 'Hernández', jerseyNumber: 14, position: 'CDM', dateOfBirth: '1996-06-22', height: 191, weight: 82, preferredFoot: 'Right', club: 'Manchester City', clubLeague: 'Premier League', marketValue: 120000000, caps: 65, goals: 3 },
      { firstName: 'Marc', lastName: 'Cucurella', jerseyNumber: 15, position: 'LB', dateOfBirth: '1998-07-22', height: 172, weight: 66, preferredFoot: 'Left', club: 'Chelsea', clubLeague: 'Premier League', marketValue: 30000000, caps: 20, goals: 0 },
      { firstName: 'Pedri', lastName: 'González', jerseyNumber: 16, position: 'CM', dateOfBirth: '2002-11-25', height: 174, weight: 63, preferredFoot: 'Right', club: 'Barcelona', clubLeague: 'La Liga', marketValue: 100000000, caps: 35, goals: 2 },
      { firstName: 'Nico', lastName: 'Williams', jerseyNumber: 17, position: 'LW', dateOfBirth: '2002-07-12', height: 181, weight: 71, preferredFoot: 'Right', club: 'Athletic Bilbao', clubLeague: 'La Liga', marketValue: 70000000, caps: 25, goals: 5 },
      { firstName: 'Martín', lastName: 'Zubimendi', jerseyNumber: 18, position: 'CDM', dateOfBirth: '1999-02-02', height: 180, weight: 72, preferredFoot: 'Right', club: 'Real Sociedad', clubLeague: 'La Liga', marketValue: 60000000, caps: 10, goals: 0 },
      { firstName: 'Lamine', lastName: 'Yamal', jerseyNumber: 19, position: 'RW', dateOfBirth: '2007-07-13', height: 180, weight: 66, preferredFoot: 'Left', club: 'Barcelona', clubLeague: 'La Liga', marketValue: 150000000, caps: 20, goals: 4 },
      { firstName: 'Jesús', lastName: 'Navas', jerseyNumber: 20, position: 'RB', dateOfBirth: '1985-11-21', height: 172, weight: 60, preferredFoot: 'Right', club: 'Sevilla', clubLeague: 'La Liga', marketValue: 1000000, caps: 60, goals: 5 },
      { firstName: 'Mikel', lastName: 'Oyarzabal', jerseyNumber: 21, position: 'LW', dateOfBirth: '1997-04-21', height: 181, weight: 78, preferredFoot: 'Right', club: 'Real Sociedad', clubLeague: 'La Liga', marketValue: 35000000, caps: 40, goals: 9 },
      { firstName: 'Pau', lastName: 'Torres', jerseyNumber: 22, position: 'CB', dateOfBirth: '1997-01-16', height: 191, weight: 79, preferredFoot: 'Left', club: 'Aston Villa', clubLeague: 'Premier League', marketValue: 40000000, caps: 30, goals: 1 },
      { firstName: 'Álex', lastName: 'Remiro', jerseyNumber: 23, position: 'GK', dateOfBirth: '1995-03-24', height: 191, weight: 79, preferredFoot: 'Right', club: 'Real Sociedad', clubLeague: 'La Liga', marketValue: 18000000, caps: 5, goals: 0 },
      { firstName: 'Gavi', lastName: 'Páez', jerseyNumber: 24, position: 'CM', dateOfBirth: '2004-08-05', height: 173, weight: 70, preferredFoot: 'Right', club: 'Barcelona', clubLeague: 'La Liga', marketValue: 90000000, caps: 25, goals: 1 },
      { firstName: 'Ayoze', lastName: 'Pérez', jerseyNumber: 25, position: 'RW', dateOfBirth: '1993-07-29', height: 178, weight: 72, preferredFoot: 'Right', club: 'Villarreal', clubLeague: 'La Liga', marketValue: 12000000, caps: 10, goals: 2 },
      { firstName: 'Vivian', lastName: 'Dani', jerseyNumber: 26, position: 'CB', dateOfBirth: '1999-07-05', height: 186, weight: 78, preferredFoot: 'Right', club: 'Athletic Bilbao', clubLeague: 'La Liga', marketValue: 30000000, caps: 5, goals: 0 },
    ],
  },

  // ========== GERMANY ==========
  {
    name: 'Germany',
    fifaCode: 'GER',
    players: [
      { firstName: 'Manuel', lastName: 'Neuer', jerseyNumber: 1, position: 'GK', dateOfBirth: '1986-03-27', height: 193, weight: 92, preferredFoot: 'Right', club: 'Bayern Munich', clubLeague: 'Bundesliga', marketValue: 8000000, caps: 120, goals: 0 },
      { firstName: 'Antonio', lastName: 'Rüdiger', jerseyNumber: 2, position: 'CB', dateOfBirth: '1993-03-03', height: 190, weight: 85, preferredFoot: 'Right', club: 'Real Madrid', clubLeague: 'La Liga', marketValue: 35000000, caps: 70, goals: 3 },
      { firstName: 'David', lastName: 'Raum', jerseyNumber: 3, position: 'LB', dateOfBirth: '1998-04-22', height: 180, weight: 75, preferredFoot: 'Left', club: 'RB Leipzig', clubLeague: 'Bundesliga', marketValue: 30000000, caps: 25, goals: 1 },
      { firstName: 'Jonathan', lastName: 'Tah', jerseyNumber: 4, position: 'CB', dateOfBirth: '1996-02-11', height: 195, weight: 94, preferredFoot: 'Right', club: 'Bayer Leverkusen', clubLeague: 'Bundesliga', marketValue: 35000000, caps: 30, goals: 1 },
      { firstName: 'Nico', lastName: 'Schlotterbeck', jerseyNumber: 5, position: 'CB', dateOfBirth: '1999-12-01', height: 191, weight: 84, preferredFoot: 'Left', club: 'Borussia Dortmund', clubLeague: 'Bundesliga', marketValue: 40000000, caps: 15, goals: 0 },
      { firstName: 'Joshua', lastName: 'Kimmich', jerseyNumber: 6, position: 'CDM', dateOfBirth: '1995-02-08', height: 177, weight: 73, preferredFoot: 'Right', club: 'Bayern Munich', clubLeague: 'Bundesliga', marketValue: 60000000, caps: 95, goals: 6 },
      { firstName: 'Kai', lastName: 'Havertz', jerseyNumber: 7, position: 'CF', dateOfBirth: '1999-06-11', height: 190, weight: 83, preferredFoot: 'Left', club: 'Arsenal', clubLeague: 'Premier League', marketValue: 70000000, caps: 50, goals: 17 },
      { firstName: 'Leon', lastName: 'Goretzka', jerseyNumber: 8, position: 'CM', dateOfBirth: '1995-02-06', height: 189, weight: 82, preferredFoot: 'Right', club: 'Bayern Munich', clubLeague: 'Bundesliga', marketValue: 40000000, caps: 60, goals: 15 },
      { firstName: 'Niclas', lastName: 'Füllkrug', jerseyNumber: 9, position: 'ST', dateOfBirth: '1993-02-09', height: 189, weight: 88, preferredFoot: 'Right', club: 'West Ham', clubLeague: 'Premier League', marketValue: 25000000, caps: 20, goals: 12 },
      { firstName: 'Jamal', lastName: 'Musiala', jerseyNumber: 10, position: 'CAM', dateOfBirth: '2003-02-26', height: 183, weight: 72, preferredFoot: 'Right', club: 'Bayern Munich', clubLeague: 'Bundesliga', marketValue: 130000000, caps: 40, goals: 5 },
      { firstName: 'Chris', lastName: 'Führich', jerseyNumber: 11, position: 'LW', dateOfBirth: '1998-01-09', height: 179, weight: 75, preferredFoot: 'Right', club: 'VfB Stuttgart', clubLeague: 'Bundesliga', marketValue: 22000000, caps: 10, goals: 0 },
      { firstName: 'Marc-André', lastName: 'ter Stegen', jerseyNumber: 12, position: 'GK', dateOfBirth: '1992-04-30', height: 187, weight: 85, preferredFoot: 'Right', club: 'Barcelona', clubLeague: 'La Liga', marketValue: 25000000, caps: 40, goals: 0 },
      { firstName: 'Thomas', lastName: 'Müller', jerseyNumber: 13, position: 'CAM', dateOfBirth: '1989-09-13', height: 185, weight: 75, preferredFoot: 'Right', club: 'Bayern Munich', clubLeague: 'Bundesliga', marketValue: 8000000, caps: 130, goals: 45 },
      { firstName: 'Maximilian', lastName: 'Mittelstädt', jerseyNumber: 14, position: 'LB', dateOfBirth: '1997-03-18', height: 181, weight: 73, preferredFoot: 'Left', club: 'VfB Stuttgart', clubLeague: 'Bundesliga', marketValue: 18000000, caps: 10, goals: 0 },
      { firstName: 'İlkay', lastName: 'Gündoğan', jerseyNumber: 15, position: 'CM', dateOfBirth: '1990-10-24', height: 180, weight: 80, preferredFoot: 'Right', club: 'Barcelona', clubLeague: 'La Liga', marketValue: 15000000, caps: 80, goals: 18 },
      { firstName: 'Benjamin', lastName: 'Henrichs', jerseyNumber: 16, position: 'RB', dateOfBirth: '1997-02-23', height: 183, weight: 75, preferredFoot: 'Right', club: 'RB Leipzig', clubLeague: 'Bundesliga', marketValue: 18000000, caps: 25, goals: 0 },
      { firstName: 'Florian', lastName: 'Wirtz', jerseyNumber: 17, position: 'CAM', dateOfBirth: '2003-05-03', height: 176, weight: 68, preferredFoot: 'Right', club: 'Bayer Leverkusen', clubLeague: 'Bundesliga', marketValue: 130000000, caps: 30, goals: 5 },
      { firstName: 'Aleksandar', lastName: 'Pavlović', jerseyNumber: 18, position: 'CDM', dateOfBirth: '2004-03-16', height: 182, weight: 73, preferredFoot: 'Right', club: 'Bayern Munich', clubLeague: 'Bundesliga', marketValue: 40000000, caps: 5, goals: 0 },
      { firstName: 'Leroy', lastName: 'Sané', jerseyNumber: 19, position: 'RW', dateOfBirth: '1996-01-11', height: 183, weight: 75, preferredFoot: 'Left', club: 'Bayern Munich', clubLeague: 'Bundesliga', marketValue: 60000000, caps: 65, goals: 14 },
      { firstName: 'Robin', lastName: 'Koch', jerseyNumber: 20, position: 'CB', dateOfBirth: '1996-07-17', height: 191, weight: 83, preferredFoot: 'Right', club: 'Eintracht Frankfurt', clubLeague: 'Bundesliga', marketValue: 18000000, caps: 15, goals: 1 },
      { firstName: 'Serge', lastName: 'Gnabry', jerseyNumber: 21, position: 'RW', dateOfBirth: '1995-07-14', height: 176, weight: 77, preferredFoot: 'Right', club: 'Bayern Munich', clubLeague: 'Bundesliga', marketValue: 50000000, caps: 50, goals: 22 },
      { firstName: 'Oliver', lastName: 'Baumann', jerseyNumber: 22, position: 'GK', dateOfBirth: '1990-06-02', height: 187, weight: 82, preferredFoot: 'Right', club: 'TSG Hoffenheim', clubLeague: 'Bundesliga', marketValue: 5000000, caps: 5, goals: 0 },
      { firstName: 'Robert', lastName: 'Andrich', jerseyNumber: 23, position: 'CDM', dateOfBirth: '1994-09-22', height: 186, weight: 80, preferredFoot: 'Right', club: 'Bayer Leverkusen', clubLeague: 'Bundesliga', marketValue: 35000000, caps: 15, goals: 1 },
      { firstName: 'Waldemar', lastName: 'Anton', jerseyNumber: 24, position: 'CB', dateOfBirth: '1996-07-20', height: 188, weight: 85, preferredFoot: 'Right', club: 'Borussia Dortmund', clubLeague: 'Bundesliga', marketValue: 25000000, caps: 10, goals: 0 },
      { firstName: 'Deniz', lastName: 'Undav', jerseyNumber: 25, position: 'ST', dateOfBirth: '1996-07-19', height: 176, weight: 78, preferredFoot: 'Right', club: 'VfB Stuttgart', clubLeague: 'Bundesliga', marketValue: 30000000, caps: 10, goals: 3 },
      { firstName: 'Tim', lastName: 'Kleindienst', jerseyNumber: 26, position: 'ST', dateOfBirth: '1995-08-31', height: 194, weight: 93, preferredFoot: 'Right', club: 'Borussia Mönchengladbach', clubLeague: 'Bundesliga', marketValue: 12000000, caps: 5, goals: 1 },
    ],
  },

  // ========== NETHERLANDS ==========
  {
    name: 'Netherlands',
    fifaCode: 'NED',
    players: [
      { firstName: 'Bart', lastName: 'Verbruggen', jerseyNumber: 1, position: 'GK', dateOfBirth: '2002-08-18', height: 193, weight: 84, preferredFoot: 'Right', club: 'Brighton', clubLeague: 'Premier League', marketValue: 25000000, caps: 10, goals: 0 },
      { firstName: 'Lutsharel', lastName: 'Geertruida', jerseyNumber: 2, position: 'RB', dateOfBirth: '2000-07-18', height: 180, weight: 75, preferredFoot: 'Right', club: 'RB Leipzig', clubLeague: 'Bundesliga', marketValue: 25000000, caps: 15, goals: 0 },
      { firstName: 'Matthijs', lastName: 'de Ligt', jerseyNumber: 3, position: 'CB', dateOfBirth: '1999-08-12', height: 189, weight: 89, preferredFoot: 'Right', club: 'Manchester United', clubLeague: 'Premier League', marketValue: 50000000, caps: 50, goals: 2 },
      { firstName: 'Virgil', lastName: 'van Dijk', jerseyNumber: 4, position: 'CB', dateOfBirth: '1991-07-08', height: 193, weight: 92, preferredFoot: 'Right', club: 'Liverpool', clubLeague: 'Premier League', marketValue: 30000000, caps: 70, goals: 7 },
      { firstName: 'Nathan', lastName: 'Aké', jerseyNumber: 5, position: 'CB', dateOfBirth: '1995-02-18', height: 180, weight: 75, preferredFoot: 'Left', club: 'Manchester City', clubLeague: 'Premier League', marketValue: 40000000, caps: 55, goals: 2 },
      { firstName: 'Stefan', lastName: 'de Vrij', jerseyNumber: 6, position: 'CB', dateOfBirth: '1992-02-05', height: 189, weight: 80, preferredFoot: 'Right', club: 'Inter Milan', clubLeague: 'Serie A', marketValue: 10000000, caps: 65, goals: 3 },
      { firstName: 'Xavi', lastName: 'Simons', jerseyNumber: 7, position: 'CAM', dateOfBirth: '2003-04-21', height: 179, weight: 67, preferredFoot: 'Right', club: 'RB Leipzig', clubLeague: 'Bundesliga', marketValue: 80000000, caps: 20, goals: 4 },
      { firstName: 'Georginio', lastName: 'Wijnaldum', jerseyNumber: 8, position: 'CM', dateOfBirth: '1990-11-11', height: 175, weight: 69, preferredFoot: 'Right', club: 'Al-Ettifaq', clubLeague: 'Saudi Pro League', marketValue: 8000000, caps: 95, goals: 26 },
      { firstName: 'Wout', lastName: 'Weghorst', jerseyNumber: 9, position: 'ST', dateOfBirth: '1992-08-07', height: 197, weight: 89, preferredFoot: 'Right', club: 'Ajax', clubLeague: 'Eredivisie', marketValue: 10000000, caps: 35, goals: 12 },
      { firstName: 'Memphis', lastName: 'Depay', jerseyNumber: 10, position: 'ST', dateOfBirth: '1994-02-13', height: 178, weight: 78, preferredFoot: 'Right', club: 'Corinthians', clubLeague: 'Serie A Brazil', marketValue: 12000000, caps: 95, goals: 46 },
      { firstName: 'Cody', lastName: 'Gakpo', jerseyNumber: 11, position: 'LW', dateOfBirth: '1999-05-07', height: 193, weight: 89, preferredFoot: 'Right', club: 'Liverpool', clubLeague: 'Premier League', marketValue: 65000000, caps: 35, goals: 13 },
      { firstName: 'Justin', lastName: 'Bijlow', jerseyNumber: 12, position: 'GK', dateOfBirth: '1998-01-22', height: 187, weight: 80, preferredFoot: 'Right', club: 'Feyenoord', clubLeague: 'Eredivisie', marketValue: 12000000, caps: 10, goals: 0 },
      { firstName: 'Jeremie', lastName: 'Frimpong', jerseyNumber: 13, position: 'RB', dateOfBirth: '2000-12-10', height: 171, weight: 64, preferredFoot: 'Right', club: 'Bayer Leverkusen', clubLeague: 'Bundesliga', marketValue: 55000000, caps: 10, goals: 0 },
      { firstName: 'Tijjani', lastName: 'Reijnders', jerseyNumber: 14, position: 'CM', dateOfBirth: '1998-07-29', height: 185, weight: 75, preferredFoot: 'Right', club: 'AC Milan', clubLeague: 'Serie A', marketValue: 50000000, caps: 20, goals: 2 },
      { firstName: 'Micky', lastName: 'van de Ven', jerseyNumber: 15, position: 'CB', dateOfBirth: '2001-04-19', height: 193, weight: 80, preferredFoot: 'Left', club: 'Tottenham', clubLeague: 'Premier League', marketValue: 55000000, caps: 10, goals: 0 },
      { firstName: 'Quinten', lastName: 'Timber', jerseyNumber: 16, position: 'CM', dateOfBirth: '2001-06-17', height: 180, weight: 72, preferredFoot: 'Right', club: 'Feyenoord', clubLeague: 'Eredivisie', marketValue: 20000000, caps: 5, goals: 0 },
      { firstName: 'Daley', lastName: 'Blind', jerseyNumber: 17, position: 'LB', dateOfBirth: '1990-03-09', height: 180, weight: 76, preferredFoot: 'Left', club: 'Girona', clubLeague: 'La Liga', marketValue: 4000000, caps: 105, goals: 2 },
      { firstName: 'Donyell', lastName: 'Malen', jerseyNumber: 18, position: 'RW', dateOfBirth: '1999-01-19', height: 178, weight: 71, preferredFoot: 'Right', club: 'Aston Villa', clubLeague: 'Premier League', marketValue: 45000000, caps: 40, goals: 10 },
      { firstName: 'Ian', lastName: 'Maatsen', jerseyNumber: 19, position: 'LB', dateOfBirth: '2002-03-10', height: 178, weight: 72, preferredFoot: 'Left', club: 'Aston Villa', clubLeague: 'Premier League', marketValue: 35000000, caps: 10, goals: 1 },
      { firstName: 'Teun', lastName: 'Koopmeiners', jerseyNumber: 20, position: 'CM', dateOfBirth: '1998-02-28', height: 183, weight: 78, preferredFoot: 'Left', club: 'Juventus', clubLeague: 'Serie A', marketValue: 55000000, caps: 20, goals: 2 },
      { firstName: 'Frenkie', lastName: 'de Jong', jerseyNumber: 21, position: 'CM', dateOfBirth: '1997-05-12', height: 180, weight: 74, preferredFoot: 'Right', club: 'Barcelona', clubLeague: 'La Liga', marketValue: 60000000, caps: 55, goals: 1 },
      { firstName: 'Denzel', lastName: 'Dumfries', jerseyNumber: 22, position: 'RB', dateOfBirth: '1996-04-18', height: 188, weight: 80, preferredFoot: 'Right', club: 'Inter Milan', clubLeague: 'Serie A', marketValue: 30000000, caps: 55, goals: 5 },
      { firstName: 'Mark', lastName: 'Flekken', jerseyNumber: 23, position: 'GK', dateOfBirth: '1993-06-13', height: 194, weight: 90, preferredFoot: 'Right', club: 'Brentford', clubLeague: 'Premier League', marketValue: 10000000, caps: 5, goals: 0 },
      { firstName: 'Jurrien', lastName: 'Timber', jerseyNumber: 24, position: 'CB', dateOfBirth: '2001-06-17', height: 182, weight: 78, preferredFoot: 'Right', club: 'Arsenal', clubLeague: 'Premier League', marketValue: 45000000, caps: 15, goals: 0 },
      { firstName: 'Ryan', lastName: 'Gravenberch', jerseyNumber: 25, position: 'CM', dateOfBirth: '2002-05-16', height: 190, weight: 80, preferredFoot: 'Right', club: 'Liverpool', clubLeague: 'Premier League', marketValue: 45000000, caps: 15, goals: 1 },
      { firstName: 'Joshua', lastName: 'Zirkzee', jerseyNumber: 26, position: 'ST', dateOfBirth: '2001-05-22', height: 193, weight: 80, preferredFoot: 'Right', club: 'Manchester United', clubLeague: 'Premier League', marketValue: 45000000, caps: 5, goals: 1 },
    ],
  },

  // ========== PORTUGAL ==========
  {
    name: 'Portugal',
    fifaCode: 'POR',
    players: [
      { firstName: 'Diogo', lastName: 'Costa', jerseyNumber: 1, position: 'GK', dateOfBirth: '1999-09-19', height: 186, weight: 83, preferredFoot: 'Right', club: 'Porto', clubLeague: 'Primeira Liga', marketValue: 45000000, caps: 25, goals: 0 },
      { firstName: 'Nelson', lastName: 'Semedo', jerseyNumber: 2, position: 'RB', dateOfBirth: '1993-11-16', height: 177, weight: 67, preferredFoot: 'Right', club: 'Wolverhampton', clubLeague: 'Premier League', marketValue: 18000000, caps: 40, goals: 1 },
      { firstName: 'Pepe', lastName: 'Dos Santos', jerseyNumber: 3, position: 'CB', dateOfBirth: '1983-02-26', height: 187, weight: 81, preferredFoot: 'Right', club: 'Free Agent', clubLeague: 'N/A', marketValue: 1000000, caps: 140, goals: 8 },
      { firstName: 'Rúben', lastName: 'Dias', jerseyNumber: 4, position: 'CB', dateOfBirth: '1997-05-14', height: 186, weight: 82, preferredFoot: 'Right', club: 'Manchester City', clubLeague: 'Premier League', marketValue: 75000000, caps: 55, goals: 1 },
      { firstName: 'Raphaël', lastName: 'Guerreiro', jerseyNumber: 5, position: 'LB', dateOfBirth: '1993-12-22', height: 170, weight: 64, preferredFoot: 'Left', club: 'Bayern Munich', clubLeague: 'Bundesliga', marketValue: 20000000, caps: 60, goals: 6 },
      { firstName: 'João', lastName: 'Palhinha', jerseyNumber: 6, position: 'CDM', dateOfBirth: '1995-07-09', height: 190, weight: 85, preferredFoot: 'Right', club: 'Bayern Munich', clubLeague: 'Bundesliga', marketValue: 45000000, caps: 40, goals: 1 },
      { firstName: 'Cristiano', lastName: 'Ronaldo', jerseyNumber: 7, position: 'ST', dateOfBirth: '1985-02-05', height: 187, weight: 85, preferredFoot: 'Right', club: 'Al-Nassr', clubLeague: 'Saudi Pro League', marketValue: 15000000, caps: 210, goals: 130 },
      { firstName: 'Bruno', lastName: 'Fernandes', jerseyNumber: 8, position: 'CAM', dateOfBirth: '1994-09-08', height: 179, weight: 69, preferredFoot: 'Right', club: 'Manchester United', clubLeague: 'Premier League', marketValue: 60000000, caps: 70, goals: 17 },
      { firstName: 'André', lastName: 'Silva', jerseyNumber: 9, position: 'ST', dateOfBirth: '1995-11-06', height: 185, weight: 80, preferredFoot: 'Right', club: 'RB Leipzig', clubLeague: 'Bundesliga', marketValue: 15000000, caps: 55, goals: 21 },
      { firstName: 'Bernardo', lastName: 'Silva', jerseyNumber: 10, position: 'RW', dateOfBirth: '1994-08-10', height: 173, weight: 64, preferredFoot: 'Left', club: 'Manchester City', clubLeague: 'Premier League', marketValue: 80000000, caps: 95, goals: 12 },
      { firstName: 'Rafael', lastName: 'Leão', jerseyNumber: 11, position: 'LW', dateOfBirth: '1999-06-10', height: 188, weight: 81, preferredFoot: 'Right', club: 'AC Milan', clubLeague: 'Serie A', marketValue: 90000000, caps: 35, goals: 7 },
      { firstName: 'José', lastName: 'Sá', jerseyNumber: 12, position: 'GK', dateOfBirth: '1993-01-17', height: 192, weight: 88, preferredFoot: 'Right', club: 'Wolverhampton', clubLeague: 'Premier League', marketValue: 15000000, caps: 10, goals: 0 },
      { firstName: 'Danilo', lastName: 'Pereira', jerseyNumber: 13, position: 'CDM', dateOfBirth: '1991-09-09', height: 188, weight: 82, preferredFoot: 'Right', club: 'Paris Saint-Germain', clubLeague: 'Ligue 1', marketValue: 8000000, caps: 75, goals: 7 },
      { firstName: 'William', lastName: 'Carvalho', jerseyNumber: 14, position: 'CM', dateOfBirth: '1992-04-07', height: 187, weight: 82, preferredFoot: 'Right', club: 'Real Betis', clubLeague: 'La Liga', marketValue: 5000000, caps: 85, goals: 4 },
      { firstName: 'João', lastName: 'Neves', jerseyNumber: 15, position: 'CM', dateOfBirth: '2004-09-27', height: 174, weight: 64, preferredFoot: 'Right', club: 'Paris Saint-Germain', clubLeague: 'Ligue 1', marketValue: 80000000, caps: 15, goals: 0 },
      { firstName: 'Rúben', lastName: 'Neves', jerseyNumber: 16, position: 'CM', dateOfBirth: '1997-03-13', height: 180, weight: 75, preferredFoot: 'Right', club: 'Al-Hilal', clubLeague: 'Saudi Pro League', marketValue: 30000000, caps: 55, goals: 3 },
      { firstName: 'Pedro', lastName: 'Gonçalves', jerseyNumber: 17, position: 'CAM', dateOfBirth: '1998-06-28', height: 173, weight: 65, preferredFoot: 'Right', club: 'Sporting CP', clubLeague: 'Primeira Liga', marketValue: 30000000, caps: 15, goals: 3 },
      { firstName: 'Nélson', lastName: 'Semedo', jerseyNumber: 18, position: 'LB', dateOfBirth: '2002-02-19', height: 180, weight: 73, preferredFoot: 'Left', club: 'Porto', clubLeague: 'Primeira Liga', marketValue: 25000000, caps: 10, goals: 0 },
      { firstName: 'Nuno', lastName: 'Mendes', jerseyNumber: 19, position: 'LB', dateOfBirth: '2002-06-19', height: 176, weight: 70, preferredFoot: 'Left', club: 'Paris Saint-Germain', clubLeague: 'Ligue 1', marketValue: 55000000, caps: 25, goals: 0 },
      { firstName: 'João', lastName: 'Cancelo', jerseyNumber: 20, position: 'RB', dateOfBirth: '1994-05-27', height: 182, weight: 74, preferredFoot: 'Right', club: 'Al-Hilal', clubLeague: 'Saudi Pro League', marketValue: 35000000, caps: 60, goals: 4 },
      { firstName: 'Diogo', lastName: 'Jota', jerseyNumber: 21, position: 'LW', dateOfBirth: '1996-12-04', height: 178, weight: 74, preferredFoot: 'Right', club: 'Liverpool', clubLeague: 'Premier League', marketValue: 65000000, caps: 40, goals: 12 },
      { firstName: 'Rui', lastName: 'Patrício', jerseyNumber: 22, position: 'GK', dateOfBirth: '1988-02-15', height: 190, weight: 83, preferredFoot: 'Right', club: 'Atalanta', clubLeague: 'Serie A', marketValue: 3000000, caps: 110, goals: 0 },
      { firstName: 'Vitinha', lastName: 'Machado', jerseyNumber: 23, position: 'CM', dateOfBirth: '2000-02-13', height: 172, weight: 63, preferredFoot: 'Right', club: 'Paris Saint-Germain', clubLeague: 'Ligue 1', marketValue: 75000000, caps: 30, goals: 1 },
      { firstName: 'António', lastName: 'Silva', jerseyNumber: 24, position: 'CB', dateOfBirth: '2003-10-30', height: 187, weight: 79, preferredFoot: 'Right', club: 'Benfica', clubLeague: 'Primeira Liga', marketValue: 50000000, caps: 20, goals: 1 },
      { firstName: 'Gonçalo', lastName: 'Inácio', jerseyNumber: 25, position: 'CB', dateOfBirth: '2001-08-25', height: 185, weight: 76, preferredFoot: 'Left', club: 'Sporting CP', clubLeague: 'Primeira Liga', marketValue: 45000000, caps: 15, goals: 0 },
      { firstName: 'Francisco', lastName: 'Conceição', jerseyNumber: 26, position: 'RW', dateOfBirth: '2002-12-14', height: 170, weight: 63, preferredFoot: 'Left', club: 'Juventus', clubLeague: 'Serie A', marketValue: 35000000, caps: 15, goals: 2 },
    ],
  },

  // ========== ITALY ==========
  {
    name: 'Italy',
    fifaCode: 'ITA',
    players: [
      { firstName: 'Gianluigi', lastName: 'Donnarumma', jerseyNumber: 1, position: 'GK', dateOfBirth: '1999-02-25', height: 196, weight: 90, preferredFoot: 'Right', club: 'Paris Saint-Germain', clubLeague: 'Ligue 1', marketValue: 40000000, caps: 70, goals: 0 },
      { firstName: 'Giovanni', lastName: 'Di Lorenzo', jerseyNumber: 2, position: 'RB', dateOfBirth: '1993-08-04', height: 183, weight: 77, preferredFoot: 'Right', club: 'Napoli', clubLeague: 'Serie A', marketValue: 30000000, caps: 45, goals: 2 },
      { firstName: 'Federico', lastName: 'Dimarco', jerseyNumber: 3, position: 'LB', dateOfBirth: '1997-11-10', height: 175, weight: 68, preferredFoot: 'Left', club: 'Inter Milan', clubLeague: 'Serie A', marketValue: 40000000, caps: 30, goals: 2 },
      { firstName: 'Alessandro', lastName: 'Bastoni', jerseyNumber: 4, position: 'CB', dateOfBirth: '1999-04-13', height: 190, weight: 75, preferredFoot: 'Left', club: 'Inter Milan', clubLeague: 'Serie A', marketValue: 65000000, caps: 30, goals: 0 },
      { firstName: 'Gianluca', lastName: 'Mancini', jerseyNumber: 5, position: 'CB', dateOfBirth: '1996-04-17', height: 190, weight: 80, preferredFoot: 'Right', club: 'Roma', clubLeague: 'Serie A', marketValue: 22000000, caps: 20, goals: 3 },
      { firstName: 'Leonardo', lastName: 'Bonucci', jerseyNumber: 6, position: 'CB', dateOfBirth: '1987-05-01', height: 190, weight: 85, preferredFoot: 'Right', club: 'Free Agent', clubLeague: 'N/A', marketValue: 1000000, caps: 125, goals: 8 },
      { firstName: 'Lorenzo', lastName: 'Pellegrini', jerseyNumber: 7, position: 'CAM', dateOfBirth: '1996-06-19', height: 186, weight: 76, preferredFoot: 'Right', club: 'Roma', clubLeague: 'Serie A', marketValue: 30000000, caps: 40, goals: 7 },
      { firstName: 'Sandro', lastName: 'Tonali', jerseyNumber: 8, position: 'CM', dateOfBirth: '2000-05-08', height: 181, weight: 71, preferredFoot: 'Right', club: 'Newcastle', clubLeague: 'Premier League', marketValue: 55000000, caps: 20, goals: 0 },
      { firstName: 'Gianluca', lastName: 'Scamacca', jerseyNumber: 9, position: 'ST', dateOfBirth: '1999-01-01', height: 195, weight: 90, preferredFoot: 'Right', club: 'Atalanta', clubLeague: 'Serie A', marketValue: 45000000, caps: 20, goals: 5 },
      { firstName: 'Roberto', lastName: 'Insigne', jerseyNumber: 10, position: 'LW', dateOfBirth: '1991-06-04', height: 163, weight: 59, preferredFoot: 'Right', club: 'Toronto FC', clubLeague: 'MLS', marketValue: 3000000, caps: 55, goals: 10 },
      { firstName: 'Giacomo', lastName: 'Raspadori', jerseyNumber: 11, position: 'ST', dateOfBirth: '2000-02-18', height: 172, weight: 66, preferredFoot: 'Right', club: 'Napoli', clubLeague: 'Serie A', marketValue: 30000000, caps: 30, goals: 8 },
      { firstName: 'Alex', lastName: 'Meret', jerseyNumber: 12, position: 'GK', dateOfBirth: '1997-03-22', height: 190, weight: 80, preferredFoot: 'Right', club: 'Napoli', clubLeague: 'Serie A', marketValue: 18000000, caps: 15, goals: 0 },
      { firstName: 'Matteo', lastName: 'Darmian', jerseyNumber: 13, position: 'RB', dateOfBirth: '1989-12-02', height: 182, weight: 78, preferredFoot: 'Right', club: 'Inter Milan', clubLeague: 'Serie A', marketValue: 6000000, caps: 40, goals: 1 },
      { firstName: 'Federico', lastName: 'Chiesa', jerseyNumber: 14, position: 'RW', dateOfBirth: '1997-10-25', height: 175, weight: 70, preferredFoot: 'Right', club: 'Liverpool', clubLeague: 'Premier League', marketValue: 35000000, caps: 45, goals: 6 },
      { firstName: 'Mattia', lastName: 'Zaccagni', jerseyNumber: 15, position: 'LW', dateOfBirth: '1995-06-16', height: 177, weight: 70, preferredFoot: 'Right', club: 'Lazio', clubLeague: 'Serie A', marketValue: 25000000, caps: 20, goals: 2 },
      { firstName: 'Nicolò', lastName: 'Barella', jerseyNumber: 16, position: 'CM', dateOfBirth: '1997-02-07', height: 172, weight: 68, preferredFoot: 'Right', club: 'Inter Milan', clubLeague: 'Serie A', marketValue: 80000000, caps: 55, goals: 8 },
      { firstName: 'Ciro', lastName: 'Immobile', jerseyNumber: 17, position: 'ST', dateOfBirth: '1990-02-20', height: 185, weight: 78, preferredFoot: 'Right', club: 'Besiktas', clubLeague: 'Super Lig', marketValue: 6000000, caps: 60, goals: 17 },
      { firstName: 'Nicolo', lastName: 'Fagioli', jerseyNumber: 18, position: 'CM', dateOfBirth: '2001-02-12', height: 178, weight: 72, preferredFoot: 'Right', club: 'Juventus', clubLeague: 'Serie A', marketValue: 25000000, caps: 10, goals: 0 },
      { firstName: 'Mateo', lastName: 'Retegui', jerseyNumber: 19, position: 'ST', dateOfBirth: '1999-04-29', height: 186, weight: 80, preferredFoot: 'Right', club: 'Atalanta', clubLeague: 'Serie A', marketValue: 35000000, caps: 15, goals: 7 },
      { firstName: 'Riccardo', lastName: 'Calafiori', jerseyNumber: 20, position: 'CB', dateOfBirth: '2002-05-19', height: 188, weight: 82, preferredFoot: 'Left', club: 'Arsenal', clubLeague: 'Premier League', marketValue: 50000000, caps: 10, goals: 1 },
      { firstName: 'Andrea', lastName: 'Cambiaso', jerseyNumber: 21, position: 'LB', dateOfBirth: '2000-02-20', height: 180, weight: 71, preferredFoot: 'Left', club: 'Juventus', clubLeague: 'Serie A', marketValue: 35000000, caps: 15, goals: 0 },
      { firstName: 'Guglielmo', lastName: 'Vicario', jerseyNumber: 22, position: 'GK', dateOfBirth: '1996-10-07', height: 194, weight: 84, preferredFoot: 'Right', club: 'Tottenham', clubLeague: 'Premier League', marketValue: 35000000, caps: 10, goals: 0 },
      { firstName: 'Davide', lastName: 'Frattesi', jerseyNumber: 23, position: 'CM', dateOfBirth: '1999-09-22', height: 178, weight: 72, preferredFoot: 'Right', club: 'Inter Milan', clubLeague: 'Serie A', marketValue: 45000000, caps: 20, goals: 4 },
      { firstName: 'Bryan', lastName: 'Cristante', jerseyNumber: 24, position: 'CDM', dateOfBirth: '1995-03-03', height: 186, weight: 78, preferredFoot: 'Right', club: 'Roma', clubLeague: 'Serie A', marketValue: 18000000, caps: 35, goals: 3 },
      { firstName: 'Nicolo', lastName: 'Zaniolo', jerseyNumber: 25, position: 'RW', dateOfBirth: '1999-07-02', height: 190, weight: 80, preferredFoot: 'Right', club: 'Atalanta', clubLeague: 'Serie A', marketValue: 25000000, caps: 20, goals: 2 },
      { firstName: 'Daniel', lastName: 'Maldini', jerseyNumber: 26, position: 'CAM', dateOfBirth: '2001-10-11', height: 184, weight: 72, preferredFoot: 'Left', club: 'Monza', clubLeague: 'Serie A', marketValue: 15000000, caps: 5, goals: 1 },
    ],
  },

  // ========== URUGUAY ==========
  {
    name: 'Uruguay',
    fifaCode: 'URU',
    players: [
      { firstName: 'Sergio', lastName: 'Rochet', jerseyNumber: 1, position: 'GK', dateOfBirth: '1993-03-23', height: 185, weight: 80, preferredFoot: 'Right', club: 'Inter Miami', clubLeague: 'MLS', marketValue: 3000000, caps: 25, goals: 0 },
      { firstName: 'José María', lastName: 'Giménez', jerseyNumber: 2, position: 'CB', dateOfBirth: '1995-01-20', height: 185, weight: 80, preferredFoot: 'Right', club: 'Atlético Madrid', clubLeague: 'La Liga', marketValue: 25000000, caps: 80, goals: 4 },
      { firstName: 'Diego', lastName: 'Godín', jerseyNumber: 3, position: 'CB', dateOfBirth: '1986-02-16', height: 187, weight: 78, preferredFoot: 'Right', club: 'Free Agent', clubLeague: 'N/A', marketValue: 1000000, caps: 165, goals: 8 },
      { firstName: 'Ronald', lastName: 'Araújo', jerseyNumber: 4, position: 'CB', dateOfBirth: '1999-03-07', height: 188, weight: 85, preferredFoot: 'Right', club: 'Barcelona', clubLeague: 'La Liga', marketValue: 60000000, caps: 30, goals: 2 },
      { firstName: 'Manuel', lastName: 'Ugarte', jerseyNumber: 5, position: 'CDM', dateOfBirth: '2001-04-11', height: 182, weight: 75, preferredFoot: 'Right', club: 'Manchester United', clubLeague: 'Premier League', marketValue: 60000000, caps: 25, goals: 0 },
      { firstName: 'Rodrigo', lastName: 'Bentancur', jerseyNumber: 6, position: 'CM', dateOfBirth: '1997-06-25', height: 187, weight: 79, preferredFoot: 'Right', club: 'Tottenham', clubLeague: 'Premier League', marketValue: 35000000, caps: 60, goals: 2 },
      { firstName: 'Nicolás', lastName: 'De La Cruz', jerseyNumber: 7, position: 'CM', dateOfBirth: '1997-06-01', height: 167, weight: 61, preferredFoot: 'Right', club: 'Flamengo', clubLeague: 'Serie A Brazil', marketValue: 18000000, caps: 30, goals: 3 },
      { firstName: 'Nahitan', lastName: 'Nández', jerseyNumber: 8, position: 'CM', dateOfBirth: '1995-12-28', height: 175, weight: 72, preferredFoot: 'Right', club: 'Al-Qadsiah', clubLeague: 'Saudi Pro League', marketValue: 10000000, caps: 55, goals: 1 },
      { firstName: 'Luis', lastName: 'Suárez', jerseyNumber: 9, position: 'ST', dateOfBirth: '1987-01-24', height: 182, weight: 86, preferredFoot: 'Right', club: 'Inter Miami', clubLeague: 'MLS', marketValue: 3000000, caps: 140, goals: 69 },
      { firstName: 'Giorgian', lastName: 'De Arrascaeta', jerseyNumber: 10, position: 'CAM', dateOfBirth: '1994-06-01', height: 172, weight: 71, preferredFoot: 'Right', club: 'Flamengo', clubLeague: 'Serie A Brazil', marketValue: 15000000, caps: 60, goals: 10 },
      { firstName: 'Darwin', lastName: 'Núñez', jerseyNumber: 11, position: 'ST', dateOfBirth: '1999-06-24', height: 187, weight: 81, preferredFoot: 'Right', club: 'Liverpool', clubLeague: 'Premier League', marketValue: 70000000, caps: 30, goals: 10 },
      { firstName: 'Fernando', lastName: 'Muslera', jerseyNumber: 12, position: 'GK', dateOfBirth: '1986-06-16', height: 190, weight: 83, preferredFoot: 'Right', club: 'Galatasaray', clubLeague: 'Super Lig', marketValue: 2000000, caps: 135, goals: 0 },
      { firstName: 'Guillermo', lastName: 'Varela', jerseyNumber: 13, position: 'RB', dateOfBirth: '1993-03-24', height: 172, weight: 68, preferredFoot: 'Right', club: 'Flamengo', clubLeague: 'Serie A Brazil', marketValue: 4000000, caps: 30, goals: 1 },
      { firstName: 'Lucas', lastName: 'Torreira', jerseyNumber: 14, position: 'CDM', dateOfBirth: '1996-02-11', height: 168, weight: 66, preferredFoot: 'Right', club: 'Galatasaray', clubLeague: 'Super Lig', marketValue: 15000000, caps: 60, goals: 2 },
      { firstName: 'Federico', lastName: 'Valverde', jerseyNumber: 15, position: 'CM', dateOfBirth: '1998-07-22', height: 182, weight: 78, preferredFoot: 'Right', club: 'Real Madrid', clubLeague: 'La Liga', marketValue: 150000000, caps: 65, goals: 8 },
      { firstName: 'Mathías', lastName: 'Olivera', jerseyNumber: 16, position: 'LB', dateOfBirth: '1997-10-31', height: 185, weight: 75, preferredFoot: 'Left', club: 'Napoli', clubLeague: 'Serie A', marketValue: 20000000, caps: 30, goals: 1 },
      { firstName: 'Maximiliano', lastName: 'Gómez', jerseyNumber: 17, position: 'ST', dateOfBirth: '1996-08-14', height: 186, weight: 80, preferredFoot: 'Right', club: 'Trabzonspor', clubLeague: 'Super Lig', marketValue: 10000000, caps: 30, goals: 7 },
      { firstName: 'Facundo', lastName: 'Pellistri', jerseyNumber: 18, position: 'RW', dateOfBirth: '2001-12-20', height: 175, weight: 66, preferredFoot: 'Right', club: 'Manchester United', clubLeague: 'Premier League', marketValue: 20000000, caps: 20, goals: 2 },
      { firstName: 'Sebastián', lastName: 'Coates', jerseyNumber: 19, position: 'CB', dateOfBirth: '1990-10-07', height: 196, weight: 86, preferredFoot: 'Left', club: 'Sporting CP', clubLeague: 'Primeira Liga', marketValue: 6000000, caps: 55, goals: 1 },
      { firstName: 'Jonathan', lastName: 'Rodríguez', jerseyNumber: 20, position: 'ST', dateOfBirth: '1993-05-06', height: 182, weight: 78, preferredFoot: 'Right', club: 'América', clubLeague: 'Liga MX', marketValue: 5000000, caps: 25, goals: 5 },
      { firstName: 'Edinson', lastName: 'Cavani', jerseyNumber: 21, position: 'ST', dateOfBirth: '1987-02-14', height: 184, weight: 77, preferredFoot: 'Right', club: 'Boca Juniors', clubLeague: 'Liga Argentina', marketValue: 2000000, caps: 140, goals: 58 },
      { firstName: 'Santiago', lastName: 'Mele', jerseyNumber: 22, position: 'GK', dateOfBirth: '1997-05-13', height: 188, weight: 82, preferredFoot: 'Right', club: 'Junior FC', clubLeague: 'Liga Colombia', marketValue: 2000000, caps: 5, goals: 0 },
      { firstName: 'Matías', lastName: 'Viña', jerseyNumber: 23, position: 'LB', dateOfBirth: '1997-11-09', height: 180, weight: 75, preferredFoot: 'Left', club: 'Flamengo', clubLeague: 'Serie A Brazil', marketValue: 6000000, caps: 25, goals: 0 },
      { firstName: 'Agustín', lastName: 'Canobbio', jerseyNumber: 24, position: 'RW', dateOfBirth: '1998-09-01', height: 176, weight: 71, preferredFoot: 'Left', club: 'Athletico Paranaense', clubLeague: 'Serie A Brazil', marketValue: 8000000, caps: 15, goals: 2 },
      { firstName: 'Facundo', lastName: 'Torres', jerseyNumber: 25, position: 'LW', dateOfBirth: '2000-04-13', height: 178, weight: 72, preferredFoot: 'Right', club: 'Orlando City', clubLeague: 'MLS', marketValue: 12000000, caps: 15, goals: 3 },
      { firstName: 'Cristian', lastName: 'Olivera', jerseyNumber: 26, position: 'RW', dateOfBirth: '2002-08-25', height: 178, weight: 70, preferredFoot: 'Right', club: 'Los Angeles FC', clubLeague: 'MLS', marketValue: 8000000, caps: 5, goals: 1 },
    ],
  },

  // ========== ECUADOR ==========
  {
    name: 'Ecuador',
    fifaCode: 'ECU',
    players: [
      { firstName: 'Hernán', lastName: 'Galíndez', jerseyNumber: 1, position: 'GK', dateOfBirth: '1987-03-30', height: 185, weight: 82, preferredFoot: 'Right', club: 'Huracán', clubLeague: 'Liga Argentina', marketValue: 1000000, caps: 35, goals: 0 },
      { firstName: 'Félix', lastName: 'Torres', jerseyNumber: 2, position: 'CB', dateOfBirth: '1997-01-11', height: 187, weight: 80, preferredFoot: 'Right', club: 'Corinthians', clubLeague: 'Serie A Brazil', marketValue: 8000000, caps: 40, goals: 3 },
      { firstName: 'Piero', lastName: 'Hincapié', jerseyNumber: 3, position: 'CB', dateOfBirth: '2002-01-09', height: 184, weight: 78, preferredFoot: 'Left', club: 'Bayer Leverkusen', clubLeague: 'Bundesliga', marketValue: 40000000, caps: 35, goals: 1 },
      { firstName: 'Robert', lastName: 'Arboleda', jerseyNumber: 4, position: 'CB', dateOfBirth: '1991-10-22', height: 187, weight: 82, preferredFoot: 'Right', club: 'São Paulo', clubLeague: 'Serie A Brazil', marketValue: 3000000, caps: 45, goals: 2 },
      { firstName: 'José', lastName: 'Cifuentes', jerseyNumber: 5, position: 'CM', dateOfBirth: '1999-03-12', height: 177, weight: 70, preferredFoot: 'Right', club: 'Cruzeiro', clubLeague: 'Serie A Brazil', marketValue: 5000000, caps: 25, goals: 1 },
      { firstName: 'Byron', lastName: 'Castillo', jerseyNumber: 6, position: 'RB', dateOfBirth: '1998-11-10', height: 172, weight: 68, preferredFoot: 'Right', club: 'León', clubLeague: 'Liga MX', marketValue: 3000000, caps: 20, goals: 0 },
      { firstName: 'Pervis', lastName: 'Estupiñán', jerseyNumber: 7, position: 'LB', dateOfBirth: '1998-01-21', height: 175, weight: 68, preferredFoot: 'Left', club: 'Brighton', clubLeague: 'Premier League', marketValue: 35000000, caps: 40, goals: 2 },
      { firstName: 'Carlos', lastName: 'Gruezo', jerseyNumber: 8, position: 'CDM', dateOfBirth: '1995-04-19', height: 172, weight: 70, preferredFoot: 'Right', club: 'Santos Laguna', clubLeague: 'Liga MX', marketValue: 2000000, caps: 50, goals: 0 },
      { firstName: 'Enner', lastName: 'Valencia', jerseyNumber: 9, position: 'ST', dateOfBirth: '1989-11-04', height: 176, weight: 75, preferredFoot: 'Right', club: 'Internacional', clubLeague: 'Serie A Brazil', marketValue: 3000000, caps: 85, goals: 40 },
      { firstName: 'Moisés', lastName: 'Caicedo', jerseyNumber: 10, position: 'CM', dateOfBirth: '2001-11-02', height: 178, weight: 70, preferredFoot: 'Right', club: 'Chelsea', clubLeague: 'Premier League', marketValue: 120000000, caps: 45, goals: 3 },
      { firstName: 'Jeremy', lastName: 'Sarmiento', jerseyNumber: 11, position: 'LW', dateOfBirth: '2002-06-16', height: 178, weight: 70, preferredFoot: 'Right', club: 'Brighton', clubLeague: 'Premier League', marketValue: 12000000, caps: 15, goals: 1 },
      { firstName: 'Alexander', lastName: 'Domínguez', jerseyNumber: 12, position: 'GK', dateOfBirth: '1987-06-05', height: 190, weight: 85, preferredFoot: 'Right', club: 'Liga de Quito', clubLeague: 'Liga Pro', marketValue: 500000, caps: 60, goals: 0 },
      { firstName: 'Angelo', lastName: 'Preciado', jerseyNumber: 13, position: 'RB', dateOfBirth: '1998-02-18', height: 174, weight: 72, preferredFoot: 'Right', club: 'Sparta Prague', clubLeague: 'Czech First League', marketValue: 4000000, caps: 35, goals: 1 },
      { firstName: 'Xavier', lastName: 'Arreaga', jerseyNumber: 14, position: 'CB', dateOfBirth: '1994-09-28', height: 185, weight: 80, preferredFoot: 'Left', club: 'Seattle Sounders', clubLeague: 'MLS', marketValue: 2000000, caps: 25, goals: 0 },
      { firstName: 'Ángel', lastName: 'Mena', jerseyNumber: 15, position: 'LW', dateOfBirth: '1988-01-21', height: 168, weight: 66, preferredFoot: 'Left', club: 'León', clubLeague: 'Liga MX', marketValue: 2000000, caps: 65, goals: 13 },
      { firstName: 'Kendry', lastName: 'Páez', jerseyNumber: 16, position: 'CAM', dateOfBirth: '2007-05-08', height: 168, weight: 60, preferredFoot: 'Left', club: 'Independiente del Valle', clubLeague: 'Liga Pro', marketValue: 30000000, caps: 15, goals: 3 },
      { firstName: 'Nilson', lastName: 'Angulo', jerseyNumber: 17, position: 'LB', dateOfBirth: '2003-02-02', height: 175, weight: 68, preferredFoot: 'Left', club: 'LAFC', clubLeague: 'MLS', marketValue: 3000000, caps: 10, goals: 0 },
      { firstName: 'Alan', lastName: 'Franco', jerseyNumber: 18, position: 'CB', dateOfBirth: '1998-09-21', height: 184, weight: 78, preferredFoot: 'Right', club: 'Atlético Mineiro', clubLeague: 'Serie A Brazil', marketValue: 6000000, caps: 15, goals: 0 },
      { firstName: 'Gonzalo', lastName: 'Plata', jerseyNumber: 19, position: 'RW', dateOfBirth: '2000-11-01', height: 178, weight: 72, preferredFoot: 'Left', club: 'Al-Sadd', clubLeague: 'Qatar Stars League', marketValue: 12000000, caps: 40, goals: 6 },
      { firstName: 'Jordy', lastName: 'Caicedo', jerseyNumber: 20, position: 'ST', dateOfBirth: '1997-10-07', height: 189, weight: 82, preferredFoot: 'Right', club: 'Barracas Central', clubLeague: 'Liga Argentina', marketValue: 1500000, caps: 15, goals: 3 },
      { firstName: 'Alan', lastName: 'Minda', jerseyNumber: 21, position: 'RW', dateOfBirth: '2003-04-12', height: 175, weight: 68, preferredFoot: 'Right', club: 'Lommel SK', clubLeague: 'Belgian First Division B', marketValue: 3000000, caps: 10, goals: 1 },
      { firstName: 'Moisés', lastName: 'Ramírez', jerseyNumber: 22, position: 'GK', dateOfBirth: '2000-07-15', height: 187, weight: 80, preferredFoot: 'Right', club: 'Independiente del Valle', clubLeague: 'Liga Pro', marketValue: 2000000, caps: 5, goals: 0 },
      { firstName: 'Willian', lastName: 'Pacho', jerseyNumber: 23, position: 'CB', dateOfBirth: '2001-10-16', height: 189, weight: 80, preferredFoot: 'Left', club: 'Paris Saint-Germain', clubLeague: 'Ligue 1', marketValue: 45000000, caps: 25, goals: 0 },
      { firstName: 'Diego', lastName: 'Palacios', jerseyNumber: 24, position: 'LB', dateOfBirth: '1999-07-12', height: 180, weight: 75, preferredFoot: 'Left', club: 'LAFC', clubLeague: 'MLS', marketValue: 4000000, caps: 20, goals: 0 },
      { firstName: 'John', lastName: 'Yeboah', jerseyNumber: 25, position: 'LW', dateOfBirth: '2000-02-21', height: 175, weight: 70, preferredFoot: 'Right', club: 'Racine', clubLeague: 'Belgian First Division A', marketValue: 2000000, caps: 5, goals: 0 },
      { firstName: 'Kevin', lastName: 'Rodríguez', jerseyNumber: 26, position: 'ST', dateOfBirth: '2000-12-12', height: 183, weight: 76, preferredFoot: 'Right', club: 'Metz', clubLeague: 'Ligue 2', marketValue: 3000000, caps: 10, goals: 2 },
    ],
  },

  // ========== CHILE ==========
  {
    name: 'Chile',
    fifaCode: 'CHI',
    players: [
      { firstName: 'Claudio', lastName: 'Bravo', jerseyNumber: 1, position: 'GK', dateOfBirth: '1983-04-13', height: 184, weight: 80, preferredFoot: 'Right', club: 'Real Betis', clubLeague: 'La Liga', marketValue: 500000, caps: 150, goals: 0 },
      { firstName: 'Eugenio', lastName: 'Mena', jerseyNumber: 2, position: 'LB', dateOfBirth: '1988-07-18', height: 168, weight: 67, preferredFoot: 'Left', club: 'Universidad Católica', clubLeague: 'Chilean Primera', marketValue: 500000, caps: 80, goals: 2 },
      { firstName: 'Guillermo', lastName: 'Maripán', jerseyNumber: 3, position: 'CB', dateOfBirth: '1994-05-06', height: 193, weight: 88, preferredFoot: 'Right', club: 'Monaco', clubLeague: 'Ligue 1', marketValue: 10000000, caps: 55, goals: 3 },
      { firstName: 'Mauricio', lastName: 'Isla', jerseyNumber: 4, position: 'RB', dateOfBirth: '1988-06-12', height: 174, weight: 73, preferredFoot: 'Right', club: 'Colo-Colo', clubLeague: 'Chilean Primera', marketValue: 500000, caps: 140, goals: 4 },
      { firstName: 'Erick', lastName: 'Pulgar', jerseyNumber: 5, position: 'CM', dateOfBirth: '1994-01-15', height: 188, weight: 78, preferredFoot: 'Right', club: 'Flamengo', clubLeague: 'Serie A Brazil', marketValue: 5000000, caps: 50, goals: 4 },
      { firstName: 'Francisco', lastName: 'Sierralta', jerseyNumber: 6, position: 'CB', dateOfBirth: '1997-05-06', height: 195, weight: 88, preferredFoot: 'Right', club: 'Watford', clubLeague: 'Championship', marketValue: 4000000, caps: 20, goals: 0 },
      { firstName: 'Alexis', lastName: 'Sánchez', jerseyNumber: 7, position: 'RW', dateOfBirth: '1988-12-19', height: 169, weight: 62, preferredFoot: 'Right', club: 'Udinese', clubLeague: 'Serie A', marketValue: 3000000, caps: 170, goals: 50 },
      { firstName: 'Arturo', lastName: 'Vidal', jerseyNumber: 8, position: 'CM', dateOfBirth: '1987-05-22', height: 180, weight: 75, preferredFoot: 'Right', club: 'Colo-Colo', clubLeague: 'Chilean Primera', marketValue: 1000000, caps: 145, goals: 34 },
      { firstName: 'Jean', lastName: 'Meneses', jerseyNumber: 9, position: 'LW', dateOfBirth: '1993-05-16', height: 175, weight: 70, preferredFoot: 'Right', club: 'Toluca', clubLeague: 'Liga MX', marketValue: 3000000, caps: 25, goals: 3 },
      { firstName: 'Darío', lastName: 'Osorio', jerseyNumber: 10, position: 'CAM', dateOfBirth: '2004-02-23', height: 172, weight: 65, preferredFoot: 'Right', club: 'FC Midtjylland', clubLeague: 'Danish Superliga', marketValue: 12000000, caps: 20, goals: 2 },
      { firstName: 'Eduardo', lastName: 'Vargas', jerseyNumber: 11, position: 'ST', dateOfBirth: '1989-11-20', height: 173, weight: 70, preferredFoot: 'Right', club: 'Nacional', clubLeague: 'Uruguayan Primera', marketValue: 1000000, caps: 115, goals: 42 },
      { firstName: 'Gabriel', lastName: 'Arias', jerseyNumber: 12, position: 'GK', dateOfBirth: '1987-09-13', height: 184, weight: 78, preferredFoot: 'Right', club: 'Racing Club', clubLeague: 'Liga Argentina', marketValue: 1500000, caps: 20, goals: 0 },
      { firstName: 'Paulo', lastName: 'Díaz', jerseyNumber: 13, position: 'CB', dateOfBirth: '1994-08-25', height: 182, weight: 75, preferredFoot: 'Right', club: 'River Plate', clubLeague: 'Liga Argentina', marketValue: 8000000, caps: 40, goals: 1 },
      { firstName: 'Gary', lastName: 'Medel', jerseyNumber: 14, position: 'CB', dateOfBirth: '1987-08-03', height: 171, weight: 66, preferredFoot: 'Right', club: 'Boca Juniors', clubLeague: 'Liga Argentina', marketValue: 1000000, caps: 155, goals: 4 },
      { firstName: 'Diego', lastName: 'Valdés', jerseyNumber: 15, position: 'CAM', dateOfBirth: '1994-01-30', height: 168, weight: 62, preferredFoot: 'Left', club: 'América', clubLeague: 'Liga MX', marketValue: 6000000, caps: 30, goals: 5 },
      { firstName: 'Marcelino', lastName: 'Núñez', jerseyNumber: 16, position: 'CM', dateOfBirth: '2000-03-01', height: 175, weight: 67, preferredFoot: 'Left', club: 'Norwich City', clubLeague: 'Championship', marketValue: 8000000, caps: 25, goals: 4 },
      { firstName: 'Víctor', lastName: 'Dávila', jerseyNumber: 17, position: 'LW', dateOfBirth: '1997-08-07', height: 170, weight: 63, preferredFoot: 'Right', club: 'CSKA Moscow', clubLeague: 'Russian Premier League', marketValue: 4000000, caps: 15, goals: 2 },
      { firstName: 'Gabriel', lastName: 'Suazo', jerseyNumber: 18, position: 'LB', dateOfBirth: '1997-08-09', height: 175, weight: 70, preferredFoot: 'Left', club: 'Toulouse', clubLeague: 'Ligue 1', marketValue: 5000000, caps: 25, goals: 0 },
      { firstName: 'Lucas', lastName: 'Assadi', jerseyNumber: 19, position: 'CAM', dateOfBirth: '2004-09-13', height: 170, weight: 62, preferredFoot: 'Right', club: 'Universidad de Chile', clubLeague: 'Chilean Primera', marketValue: 5000000, caps: 10, goals: 1 },
      { firstName: 'Charles', lastName: 'Aránguiz', jerseyNumber: 20, position: 'CM', dateOfBirth: '1989-04-17', height: 171, weight: 68, preferredFoot: 'Right', club: 'Internacional', clubLeague: 'Serie A Brazil', marketValue: 2000000, caps: 100, goals: 9 },
      { firstName: 'Ben', lastName: 'Brereton Díaz', jerseyNumber: 21, position: 'ST', dateOfBirth: '1999-04-18', height: 185, weight: 77, preferredFoot: 'Right', club: 'Southampton', clubLeague: 'Premier League', marketValue: 12000000, caps: 35, goals: 8 },
      { firstName: 'Brayan', lastName: 'Cortés', jerseyNumber: 22, position: 'GK', dateOfBirth: '1995-03-16', height: 190, weight: 88, preferredFoot: 'Right', club: 'Colo-Colo', clubLeague: 'Chilean Primera', marketValue: 2500000, caps: 15, goals: 0 },
      { firstName: 'Tomás', lastName: 'Alarcón', jerseyNumber: 23, position: 'CM', dateOfBirth: '1999-01-18', height: 173, weight: 66, preferredFoot: 'Right', club: 'Cádiz', clubLeague: 'La Liga 2', marketValue: 2000000, caps: 10, goals: 0 },
      { firstName: 'Igor', lastName: 'Lichnovsky', jerseyNumber: 24, position: 'CB', dateOfBirth: '1994-03-07', height: 186, weight: 80, preferredFoot: 'Right', club: 'América', clubLeague: 'Liga MX', marketValue: 3000000, caps: 20, goals: 0 },
      { firstName: 'Clemente', lastName: 'Montes', jerseyNumber: 25, position: 'RW', dateOfBirth: '2000-06-30', height: 175, weight: 67, preferredFoot: 'Right', club: 'Universidad Católica', clubLeague: 'Chilean Primera', marketValue: 2000000, caps: 5, goals: 0 },
      { firstName: 'Alexander', lastName: 'Aravena', jerseyNumber: 26, position: 'ST', dateOfBirth: '2003-07-19', height: 180, weight: 72, preferredFoot: 'Right', club: 'Universidad Católica', clubLeague: 'Chilean Primera', marketValue: 4000000, caps: 5, goals: 1 },
    ],
  },

  // ========== PERU ==========
  {
    name: 'Peru',
    fifaCode: 'PER',
    players: [
      { firstName: 'Pedro', lastName: 'Gallese', jerseyNumber: 1, position: 'GK', dateOfBirth: '1990-02-23', height: 188, weight: 85, preferredFoot: 'Right', club: 'Orlando City', clubLeague: 'MLS', marketValue: 2500000, caps: 95, goals: 0 },
      { firstName: 'Luis', lastName: 'Advíncula', jerseyNumber: 2, position: 'RB', dateOfBirth: '1990-03-02', height: 176, weight: 68, preferredFoot: 'Right', club: 'Boca Juniors', clubLeague: 'Liga Argentina', marketValue: 2000000, caps: 115, goals: 2 },
      { firstName: 'Aldo', lastName: 'Corzo', jerseyNumber: 3, position: 'RB', dateOfBirth: '1989-07-20', height: 175, weight: 72, preferredFoot: 'Right', club: 'Universitario', clubLeague: 'Liga 1 Peru', marketValue: 500000, caps: 50, goals: 0 },
      { firstName: 'Alexander', lastName: 'Callens', jerseyNumber: 4, position: 'CB', dateOfBirth: '1992-05-04', height: 181, weight: 75, preferredFoot: 'Right', club: 'AEK Athens', clubLeague: 'Super League Greece', marketValue: 2000000, caps: 55, goals: 3 },
      { firstName: 'Carlos', lastName: 'Zambrano', jerseyNumber: 5, position: 'CB', dateOfBirth: '1989-07-10', height: 184, weight: 80, preferredFoot: 'Right', club: 'Alianza Lima', clubLeague: 'Liga 1 Peru', marketValue: 800000, caps: 80, goals: 1 },
      { firstName: 'Miguel', lastName: 'Trauco', jerseyNumber: 6, position: 'LB', dateOfBirth: '1992-08-25', height: 175, weight: 72, preferredFoot: 'Left', club: 'Criciúma', clubLeague: 'Serie A Brazil', marketValue: 1500000, caps: 75, goals: 2 },
      { firstName: 'Andy', lastName: 'Polo', jerseyNumber: 7, position: 'RW', dateOfBirth: '1994-09-29', height: 173, weight: 68, preferredFoot: 'Right', club: 'Universitario', clubLeague: 'Liga 1 Peru', marketValue: 1000000, caps: 40, goals: 3 },
      { firstName: 'Christian', lastName: 'Cueva', jerseyNumber: 8, position: 'CAM', dateOfBirth: '1991-11-23', height: 168, weight: 67, preferredFoot: 'Left', club: 'Cienciano', clubLeague: 'Liga 1 Peru', marketValue: 1000000, caps: 110, goals: 13 },
      { firstName: 'Paolo', lastName: 'Guerrero', jerseyNumber: 9, position: 'ST', dateOfBirth: '1984-01-01', height: 185, weight: 84, preferredFoot: 'Right', club: 'Alianza Lima', clubLeague: 'Liga 1 Peru', marketValue: 500000, caps: 120, goals: 40 },
      { firstName: 'Bryan', lastName: 'Reyna', jerseyNumber: 10, position: 'LW', dateOfBirth: '1998-12-23', height: 170, weight: 67, preferredFoot: 'Right', club: 'Belgrano', clubLeague: 'Liga Argentina', marketValue: 2500000, caps: 15, goals: 2 },
      { firstName: 'Raúl', lastName: 'Ruidíaz', jerseyNumber: 11, position: 'ST', dateOfBirth: '1990-07-25', height: 168, weight: 69, preferredFoot: 'Right', club: 'Seattle Sounders', clubLeague: 'MLS', marketValue: 3000000, caps: 55, goals: 5 },
      { firstName: 'Carlos', lastName: 'Cáceda', jerseyNumber: 12, position: 'GK', dateOfBirth: '1991-09-27', height: 189, weight: 82, preferredFoot: 'Right', club: 'Melgar', clubLeague: 'Liga 1 Peru', marketValue: 500000, caps: 10, goals: 0 },
      { firstName: 'Renato', lastName: 'Tapia', jerseyNumber: 13, position: 'CDM', dateOfBirth: '1995-07-28', height: 185, weight: 78, preferredFoot: 'Right', club: 'Leganés', clubLeague: 'La Liga', marketValue: 3000000, caps: 75, goals: 2 },
      { firstName: 'Gianluca', lastName: 'Lapadula', jerseyNumber: 14, position: 'ST', dateOfBirth: '1990-02-07', height: 178, weight: 76, preferredFoot: 'Right', club: 'Cagliari', clubLeague: 'Serie A', marketValue: 3000000, caps: 30, goals: 10 },
      { firstName: 'Jesús', lastName: 'Castillo', jerseyNumber: 15, position: 'CM', dateOfBirth: '1998-10-22', height: 178, weight: 72, preferredFoot: 'Right', club: 'Gil Vicente', clubLeague: 'Primeira Liga', marketValue: 1500000, caps: 15, goals: 0 },
      { firstName: 'Marcos', lastName: 'López', jerseyNumber: 16, position: 'LB', dateOfBirth: '1999-10-10', height: 181, weight: 73, preferredFoot: 'Left', club: 'Feyenoord', clubLeague: 'Eredivisie', marketValue: 7000000, caps: 30, goals: 0 },
      { firstName: 'Luis', lastName: 'Iberico', jerseyNumber: 17, position: 'LW', dateOfBirth: '1995-07-04', height: 172, weight: 68, preferredFoot: 'Right', club: 'Melgar', clubLeague: 'Liga 1 Peru', marketValue: 800000, caps: 10, goals: 1 },
      { firstName: 'André', lastName: 'Carrillo', jerseyNumber: 18, position: 'RW', dateOfBirth: '1991-06-14', height: 180, weight: 77, preferredFoot: 'Right', club: 'Al-Qadisiyah', clubLeague: 'Saudi Pro League', marketValue: 2000000, caps: 95, goals: 10 },
      { firstName: 'Yoshimar', lastName: 'Yotún', jerseyNumber: 19, position: 'CM', dateOfBirth: '1990-04-07', height: 167, weight: 62, preferredFoot: 'Left', club: 'Sporting Cristal', clubLeague: 'Liga 1 Peru', marketValue: 800000, caps: 115, goals: 6 },
      { firstName: 'Edison', lastName: 'Flores', jerseyNumber: 20, position: 'CAM', dateOfBirth: '1994-05-14', height: 173, weight: 68, preferredFoot: 'Right', club: 'Universitario', clubLeague: 'Liga 1 Peru', marketValue: 1500000, caps: 75, goals: 15 },
      { firstName: 'Sergio', lastName: 'Peña', jerseyNumber: 21, position: 'CM', dateOfBirth: '1995-09-28', height: 177, weight: 72, preferredFoot: 'Right', club: 'Malmö', clubLeague: 'Allsvenskan', marketValue: 3000000, caps: 45, goals: 4 },
      { firstName: 'Diego', lastName: 'Romero', jerseyNumber: 22, position: 'GK', dateOfBirth: '2001-05-03', height: 186, weight: 78, preferredFoot: 'Right', club: 'Universitario', clubLeague: 'Liga 1 Peru', marketValue: 1000000, caps: 5, goals: 0 },
      { firstName: 'Pedro', lastName: 'Aquino', jerseyNumber: 23, position: 'CM', dateOfBirth: '1995-04-13', height: 180, weight: 76, preferredFoot: 'Right', club: 'Santos Laguna', clubLeague: 'Liga MX', marketValue: 2000000, caps: 35, goals: 1 },
      { firstName: 'Piero', lastName: 'Quispe', jerseyNumber: 24, position: 'CAM', dateOfBirth: '2001-08-09', height: 169, weight: 64, preferredFoot: 'Right', club: 'Pumas UNAM', clubLeague: 'Liga MX', marketValue: 5000000, caps: 20, goals: 3 },
      { firstName: 'Joao', lastName: 'Grimaldo', jerseyNumber: 25, position: 'LW', dateOfBirth: '2002-03-08', height: 175, weight: 68, preferredFoot: 'Right', club: 'Partizan', clubLeague: 'Serbian SuperLiga', marketValue: 3000000, caps: 10, goals: 1 },
      { firstName: 'Franco', lastName: 'Zanelatto', jerseyNumber: 26, position: 'RW', dateOfBirth: '2002-07-16', height: 170, weight: 66, preferredFoot: 'Right', club: 'Alianza Lima', clubLeague: 'Liga 1 Peru', marketValue: 1500000, caps: 5, goals: 0 },
    ],
  },

  // ========== DENMARK ==========
  {
    name: 'Denmark',
    fifaCode: 'DEN',
    players: [
      { firstName: 'Kasper', lastName: 'Schmeichel', jerseyNumber: 1, position: 'GK', dateOfBirth: '1986-11-05', height: 189, weight: 84, preferredFoot: 'Right', club: 'Celtic', clubLeague: 'Scottish Premiership', marketValue: 2000000, caps: 95, goals: 0 },
      { firstName: 'Joachim', lastName: 'Andersen', jerseyNumber: 2, position: 'CB', dateOfBirth: '1996-05-31', height: 192, weight: 87, preferredFoot: 'Right', club: 'Fulham', clubLeague: 'Premier League', marketValue: 30000000, caps: 35, goals: 0 },
      { firstName: 'Jannik', lastName: 'Vestergaard', jerseyNumber: 3, position: 'CB', dateOfBirth: '1992-08-03', height: 199, weight: 98, preferredFoot: 'Right', club: 'Leicester City', clubLeague: 'Premier League', marketValue: 5000000, caps: 45, goals: 3 },
      { firstName: 'Simon', lastName: 'Kjær', jerseyNumber: 4, position: 'CB', dateOfBirth: '1989-03-26', height: 189, weight: 81, preferredFoot: 'Right', club: 'AC Milan', clubLeague: 'Serie A', marketValue: 3000000, caps: 130, goals: 5 },
      { firstName: 'Joakim', lastName: 'Mæhle', jerseyNumber: 5, position: 'LB', dateOfBirth: '1997-05-20', height: 185, weight: 78, preferredFoot: 'Left', club: 'Wolfsburg', clubLeague: 'Bundesliga', marketValue: 15000000, caps: 45, goals: 5 },
      { firstName: 'Andreas', lastName: 'Christensen', jerseyNumber: 6, position: 'CB', dateOfBirth: '1996-04-10', height: 188, weight: 82, preferredFoot: 'Right', club: 'Barcelona', clubLeague: 'La Liga', marketValue: 25000000, caps: 70, goals: 1 },
      { firstName: 'Mikkel', lastName: 'Damsgaard', jerseyNumber: 7, position: 'LW', dateOfBirth: '2000-07-03', height: 180, weight: 70, preferredFoot: 'Right', club: 'Brentford', clubLeague: 'Premier League', marketValue: 25000000, caps: 30, goals: 3 },
      { firstName: 'Thomas', lastName: 'Delaney', jerseyNumber: 8, position: 'CM', dateOfBirth: '1991-09-03', height: 182, weight: 78, preferredFoot: 'Right', club: 'Anderlecht', clubLeague: 'Belgian First Division', marketValue: 3000000, caps: 80, goals: 7 },
      { firstName: 'Rasmus', lastName: 'Højlund', jerseyNumber: 9, position: 'ST', dateOfBirth: '2003-02-04', height: 191, weight: 82, preferredFoot: 'Right', club: 'Manchester United', clubLeague: 'Premier League', marketValue: 65000000, caps: 20, goals: 5 },
      { firstName: 'Christian', lastName: 'Eriksen', jerseyNumber: 10, position: 'CAM', dateOfBirth: '1992-02-14', height: 182, weight: 76, preferredFoot: 'Right', club: 'Manchester United', clubLeague: 'Premier League', marketValue: 15000000, caps: 130, goals: 42 },
      { firstName: 'Andreas', lastName: 'Skov Olsen', jerseyNumber: 11, position: 'RW', dateOfBirth: '1999-12-29', height: 187, weight: 80, preferredFoot: 'Left', club: 'Club Brugge', clubLeague: 'Belgian First Division', marketValue: 18000000, caps: 30, goals: 6 },
      { firstName: 'Mads', lastName: 'Hermansen', jerseyNumber: 12, position: 'GK', dateOfBirth: '2000-07-13', height: 190, weight: 85, preferredFoot: 'Right', club: 'Leicester City', clubLeague: 'Premier League', marketValue: 15000000, caps: 5, goals: 0 },
      { firstName: 'Rasmus', lastName: 'Kristensen', jerseyNumber: 13, position: 'RB', dateOfBirth: '1997-07-11', height: 187, weight: 80, preferredFoot: 'Right', club: 'Eintracht Frankfurt', clubLeague: 'Bundesliga', marketValue: 8000000, caps: 30, goals: 1 },
      { firstName: 'Victor', lastName: 'Kristiansen', jerseyNumber: 14, position: 'LB', dateOfBirth: '2002-12-16', height: 178, weight: 70, preferredFoot: 'Left', club: 'Bologna', clubLeague: 'Serie A', marketValue: 15000000, caps: 15, goals: 0 },
      { firstName: 'Pierre-Emile', lastName: 'Højbjerg', jerseyNumber: 15, position: 'CDM', dateOfBirth: '1995-08-05', height: 185, weight: 80, preferredFoot: 'Right', club: 'Marseille', clubLeague: 'Ligue 1', marketValue: 30000000, caps: 80, goals: 5 },
      { firstName: 'Alexander', lastName: 'Bah', jerseyNumber: 16, position: 'RB', dateOfBirth: '1997-12-09', height: 183, weight: 78, preferredFoot: 'Right', club: 'Benfica', clubLeague: 'Primeira Liga', marketValue: 20000000, caps: 20, goals: 0 },
      { firstName: 'Jens', lastName: 'Stryger Larsen', jerseyNumber: 17, position: 'RB', dateOfBirth: '1991-02-21', height: 180, weight: 73, preferredFoot: 'Right', club: 'Trabzonspor', clubLeague: 'Super Lig', marketValue: 2000000, caps: 55, goals: 2 },
      { firstName: 'Morten', lastName: 'Hjulmand', jerseyNumber: 18, position: 'CDM', dateOfBirth: '1999-06-25', height: 185, weight: 80, preferredFoot: 'Right', club: 'Sporting CP', clubLeague: 'Primeira Liga', marketValue: 45000000, caps: 30, goals: 3 },
      { firstName: 'Jonas', lastName: 'Wind', jerseyNumber: 19, position: 'ST', dateOfBirth: '1999-02-07', height: 190, weight: 83, preferredFoot: 'Right', club: 'Wolfsburg', clubLeague: 'Bundesliga', marketValue: 18000000, caps: 35, goals: 8 },
      { firstName: 'Yussuf', lastName: 'Poulsen', jerseyNumber: 20, position: 'ST', dateOfBirth: '1994-06-15', height: 193, weight: 83, preferredFoot: 'Right', club: 'RB Leipzig', clubLeague: 'Bundesliga', marketValue: 8000000, caps: 80, goals: 12 },
      { firstName: 'Mathias', lastName: 'Jensen', jerseyNumber: 21, position: 'CM', dateOfBirth: '1996-01-01', height: 180, weight: 72, preferredFoot: 'Right', club: 'Brentford', clubLeague: 'Premier League', marketValue: 15000000, caps: 25, goals: 1 },
      { firstName: 'Frederik', lastName: 'Rønnow', jerseyNumber: 22, position: 'GK', dateOfBirth: '1992-08-04', height: 190, weight: 85, preferredFoot: 'Right', club: 'Union Berlin', clubLeague: 'Bundesliga', marketValue: 3000000, caps: 10, goals: 0 },
      { firstName: 'Jacob', lastName: 'Bruun Larsen', jerseyNumber: 23, position: 'LW', dateOfBirth: '1998-09-19', height: 180, weight: 73, preferredFoot: 'Right', club: 'Burnley', clubLeague: 'Championship', marketValue: 4000000, caps: 15, goals: 1 },
      { firstName: 'Matt', lastName: "O'Riley", jerseyNumber: 24, position: 'CM', dateOfBirth: '2000-11-21', height: 184, weight: 76, preferredFoot: 'Right', club: 'Brighton', clubLeague: 'Premier League', marketValue: 30000000, caps: 10, goals: 1 },
      { firstName: 'Gustav', lastName: 'Isaksen', jerseyNumber: 25, position: 'RW', dateOfBirth: '2001-04-19', height: 180, weight: 68, preferredFoot: 'Left', club: 'Lazio', clubLeague: 'Serie A', marketValue: 20000000, caps: 15, goals: 2 },
      { firstName: 'Patrick', lastName: 'Dorgu', jerseyNumber: 26, position: 'LB', dateOfBirth: '2004-10-15', height: 181, weight: 72, preferredFoot: 'Left', club: 'Lecce', clubLeague: 'Serie A', marketValue: 25000000, caps: 5, goals: 0 },
    ],
  },

  // ========== SWITZERLAND ==========
  {
    name: 'Switzerland',
    fifaCode: 'SUI',
    players: [
      { firstName: 'Yann', lastName: 'Sommer', jerseyNumber: 1, position: 'GK', dateOfBirth: '1988-12-17', height: 183, weight: 78, preferredFoot: 'Right', club: 'Inter Milan', clubLeague: 'Serie A', marketValue: 4000000, caps: 95, goals: 0 },
      { firstName: 'Leonidas', lastName: 'Stergiou', jerseyNumber: 2, position: 'CB', dateOfBirth: '2002-03-03', height: 185, weight: 78, preferredFoot: 'Right', club: 'VfB Stuttgart', clubLeague: 'Bundesliga', marketValue: 15000000, caps: 15, goals: 0 },
      { firstName: 'Silvan', lastName: 'Widmer', jerseyNumber: 3, position: 'RB', dateOfBirth: '1993-03-05', height: 183, weight: 80, preferredFoot: 'Right', club: 'Mainz', clubLeague: 'Bundesliga', marketValue: 4000000, caps: 45, goals: 2 },
      { firstName: 'Nico', lastName: 'Elvedi', jerseyNumber: 4, position: 'CB', dateOfBirth: '1996-09-30', height: 189, weight: 82, preferredFoot: 'Right', club: 'Borussia M\'gladbach', clubLeague: 'Bundesliga', marketValue: 20000000, caps: 55, goals: 1 },
      { firstName: 'Manuel', lastName: 'Akanji', jerseyNumber: 5, position: 'CB', dateOfBirth: '1995-07-19', height: 188, weight: 85, preferredFoot: 'Right', club: 'Manchester City', clubLeague: 'Premier League', marketValue: 45000000, caps: 60, goals: 1 },
      { firstName: 'Remo', lastName: 'Freuler', jerseyNumber: 6, position: 'CM', dateOfBirth: '1992-04-15', height: 180, weight: 75, preferredFoot: 'Right', club: 'Bologna', clubLeague: 'Serie A', marketValue: 10000000, caps: 70, goals: 4 },
      { firstName: 'Breel', lastName: 'Embolo', jerseyNumber: 7, position: 'ST', dateOfBirth: '1997-02-14', height: 187, weight: 85, preferredFoot: 'Right', club: 'Monaco', clubLeague: 'Ligue 1', marketValue: 20000000, caps: 65, goals: 13 },
      { firstName: 'Fabian', lastName: 'Frei', jerseyNumber: 8, position: 'CM', dateOfBirth: '1989-01-08', height: 180, weight: 75, preferredFoot: 'Right', club: 'Basel', clubLeague: 'Swiss Super League', marketValue: 1000000, caps: 50, goals: 3 },
      { firstName: 'Noah', lastName: 'Okafor', jerseyNumber: 9, position: 'LW', dateOfBirth: '2000-05-24', height: 185, weight: 78, preferredFoot: 'Right', club: 'AC Milan', clubLeague: 'Serie A', marketValue: 25000000, caps: 25, goals: 5 },
      { firstName: 'Granit', lastName: 'Xhaka', jerseyNumber: 10, position: 'CM', dateOfBirth: '1992-09-27', height: 185, weight: 82, preferredFoot: 'Left', club: 'Bayer Leverkusen', clubLeague: 'Bundesliga', marketValue: 25000000, caps: 130, goals: 14 },
      { firstName: 'Renato', lastName: 'Steffen', jerseyNumber: 11, position: 'LW', dateOfBirth: '1991-11-03', height: 170, weight: 68, preferredFoot: 'Right', club: 'Lugano', clubLeague: 'Swiss Super League', marketValue: 2000000, caps: 35, goals: 5 },
      { firstName: 'Gregor', lastName: 'Kobel', jerseyNumber: 12, position: 'GK', dateOfBirth: '1997-12-06', height: 195, weight: 90, preferredFoot: 'Right', club: 'Borussia Dortmund', clubLeague: 'Bundesliga', marketValue: 40000000, caps: 10, goals: 0 },
      { firstName: 'Ricardo', lastName: 'Rodríguez', jerseyNumber: 13, position: 'LB', dateOfBirth: '1992-08-25', height: 180, weight: 82, preferredFoot: 'Left', club: 'Real Betis', clubLeague: 'La Liga', marketValue: 3500000, caps: 110, goals: 9 },
      { firstName: 'Steven', lastName: 'Zuber', jerseyNumber: 14, position: 'LW', dateOfBirth: '1991-08-17', height: 182, weight: 78, preferredFoot: 'Right', club: 'AEK Athens', clubLeague: 'Super League Greece', marketValue: 2000000, caps: 60, goals: 7 },
      { firstName: 'Djibril', lastName: 'Sow', jerseyNumber: 15, position: 'CM', dateOfBirth: '1997-02-06', height: 183, weight: 78, preferredFoot: 'Right', club: 'Sevilla', clubLeague: 'La Liga', marketValue: 22000000, caps: 40, goals: 2 },
      { firstName: 'Dan', lastName: 'Ndoye', jerseyNumber: 16, position: 'RW', dateOfBirth: '2000-10-25', height: 180, weight: 73, preferredFoot: 'Right', club: 'Bologna', clubLeague: 'Serie A', marketValue: 25000000, caps: 20, goals: 2 },
      { firstName: 'Ruben', lastName: 'Vargas', jerseyNumber: 17, position: 'LW', dateOfBirth: '1998-08-05', height: 179, weight: 72, preferredFoot: 'Left', club: 'Augsburg', clubLeague: 'Bundesliga', marketValue: 12000000, caps: 35, goals: 4 },
      { firstName: 'Vincent', lastName: 'Sierro', jerseyNumber: 18, position: 'CM', dateOfBirth: '1995-01-08', height: 185, weight: 80, preferredFoot: 'Right', club: 'Toulouse', clubLeague: 'Ligue 1', marketValue: 3000000, caps: 10, goals: 0 },
      { firstName: 'Cedric', lastName: 'Itten', jerseyNumber: 19, position: 'ST', dateOfBirth: '1996-12-27', height: 190, weight: 85, preferredFoot: 'Right', club: 'Young Boys', clubLeague: 'Swiss Super League', marketValue: 4000000, caps: 15, goals: 2 },
      { firstName: 'Zeki', lastName: 'Amdouni', jerseyNumber: 20, position: 'ST', dateOfBirth: '2000-12-04', height: 186, weight: 78, preferredFoot: 'Right', club: 'Benfica', clubLeague: 'Primeira Liga', marketValue: 15000000, caps: 20, goals: 6 },
      { firstName: 'Philipp', lastName: 'Köhn', jerseyNumber: 21, position: 'GK', dateOfBirth: '1998-05-02', height: 191, weight: 82, preferredFoot: 'Right', club: 'Monaco', clubLeague: 'Ligue 1', marketValue: 8000000, caps: 5, goals: 0 },
      { firstName: 'Fabian', lastName: 'Schär', jerseyNumber: 22, position: 'CB', dateOfBirth: '1991-12-20', height: 186, weight: 85, preferredFoot: 'Right', club: 'Newcastle', clubLeague: 'Premier League', marketValue: 12000000, caps: 85, goals: 8 },
      { firstName: 'Xherdan', lastName: 'Shaqiri', jerseyNumber: 23, position: 'RW', dateOfBirth: '1991-10-10', height: 169, weight: 72, preferredFoot: 'Left', club: 'Basel', clubLeague: 'Swiss Super League', marketValue: 2000000, caps: 125, goals: 32 },
      { firstName: 'Denis', lastName: 'Zakaria', jerseyNumber: 24, position: 'CDM', dateOfBirth: '1996-11-20', height: 191, weight: 82, preferredFoot: 'Right', club: 'Monaco', clubLeague: 'Ligue 1', marketValue: 25000000, caps: 45, goals: 2 },
      { firstName: 'Ardon', lastName: 'Jashari', jerseyNumber: 25, position: 'CM', dateOfBirth: '2002-07-30', height: 182, weight: 76, preferredFoot: 'Right', club: 'Club Brugge', clubLeague: 'Belgian First Division', marketValue: 12000000, caps: 10, goals: 0 },
      { firstName: 'Eray', lastName: 'Cömert', jerseyNumber: 26, position: 'CB', dateOfBirth: '1998-02-04', height: 183, weight: 76, preferredFoot: 'Right', club: 'Valencia', clubLeague: 'La Liga', marketValue: 5000000, caps: 25, goals: 0 },
    ],
  },

  // ========== AUSTRIA ==========
  {
    name: 'Austria',
    fifaCode: 'AUT',
    players: [
      { firstName: 'Patrick', lastName: 'Pentz', jerseyNumber: 1, position: 'GK', dateOfBirth: '1997-01-02', height: 195, weight: 90, preferredFoot: 'Right', club: 'Bröndby', clubLeague: 'Danish Superliga', marketValue: 3000000, caps: 15, goals: 0 },
      { firstName: 'Stefan', lastName: 'Posch', jerseyNumber: 2, position: 'CB', dateOfBirth: '1997-05-14', height: 190, weight: 84, preferredFoot: 'Right', club: 'Bologna', clubLeague: 'Serie A', marketValue: 18000000, caps: 40, goals: 1 },
      { firstName: 'Maximilian', lastName: 'Wöber', jerseyNumber: 3, position: 'CB', dateOfBirth: '1998-02-04', height: 188, weight: 82, preferredFoot: 'Left', club: 'Borussia M\'gladbach', clubLeague: 'Bundesliga', marketValue: 10000000, caps: 35, goals: 1 },
      { firstName: 'Kevin', lastName: 'Danso', jerseyNumber: 4, position: 'CB', dateOfBirth: '1998-09-19', height: 190, weight: 85, preferredFoot: 'Right', club: 'Lens', clubLeague: 'Ligue 1', marketValue: 25000000, caps: 30, goals: 1 },
      { firstName: 'Philipp', lastName: 'Lienhart', jerseyNumber: 5, position: 'CB', dateOfBirth: '1996-07-11', height: 190, weight: 82, preferredFoot: 'Right', club: 'Freiburg', clubLeague: 'Bundesliga', marketValue: 15000000, caps: 25, goals: 0 },
      { firstName: 'Nicolas', lastName: 'Seiwald', jerseyNumber: 6, position: 'CDM', dateOfBirth: '2001-05-04', height: 180, weight: 73, preferredFoot: 'Right', club: 'RB Leipzig', clubLeague: 'Bundesliga', marketValue: 30000000, caps: 25, goals: 1 },
      { firstName: 'Marko', lastName: 'Arnautović', jerseyNumber: 7, position: 'ST', dateOfBirth: '1989-04-19', height: 192, weight: 85, preferredFoot: 'Right', club: 'Inter Milan', clubLeague: 'Serie A', marketValue: 3000000, caps: 115, goals: 36 },
      { firstName: 'David', lastName: 'Alaba', jerseyNumber: 8, position: 'CB', dateOfBirth: '1992-06-24', height: 180, weight: 76, preferredFoot: 'Left', club: 'Real Madrid', clubLeague: 'La Liga', marketValue: 25000000, caps: 105, goals: 15 },
      { firstName: 'Michael', lastName: 'Gregoritsch', jerseyNumber: 9, position: 'ST', dateOfBirth: '1994-04-18', height: 193, weight: 87, preferredFoot: 'Left', club: 'Freiburg', clubLeague: 'Bundesliga', marketValue: 8000000, caps: 55, goals: 14 },
      { firstName: 'Florian', lastName: 'Grillitsch', jerseyNumber: 10, position: 'CM', dateOfBirth: '1995-08-07', height: 187, weight: 77, preferredFoot: 'Right', club: 'Hoffenheim', clubLeague: 'Bundesliga', marketValue: 8000000, caps: 40, goals: 2 },
      { firstName: 'Christoph', lastName: 'Baumgartner', jerseyNumber: 11, position: 'CAM', dateOfBirth: '1999-08-01', height: 179, weight: 73, preferredFoot: 'Left', club: 'RB Leipzig', clubLeague: 'Bundesliga', marketValue: 28000000, caps: 45, goals: 11 },
      { firstName: 'Heinz', lastName: 'Lindner', jerseyNumber: 12, position: 'GK', dateOfBirth: '1990-07-17', height: 193, weight: 88, preferredFoot: 'Right', club: 'Union Saint-Gilloise', clubLeague: 'Belgian First Division', marketValue: 1500000, caps: 20, goals: 0 },
      { firstName: 'Philipp', lastName: 'Mwene', jerseyNumber: 13, position: 'LB', dateOfBirth: '1994-01-04', height: 184, weight: 77, preferredFoot: 'Left', club: 'Mainz', clubLeague: 'Bundesliga', marketValue: 3000000, caps: 20, goals: 0 },
      { firstName: 'Patrick', lastName: 'Wimmer', jerseyNumber: 14, position: 'LW', dateOfBirth: '2001-05-30', height: 181, weight: 74, preferredFoot: 'Right', club: 'Wolfsburg', clubLeague: 'Bundesliga', marketValue: 15000000, caps: 20, goals: 1 },
      { firstName: 'Marcel', lastName: 'Sabitzer', jerseyNumber: 15, position: 'CM', dateOfBirth: '1994-03-17', height: 177, weight: 74, preferredFoot: 'Right', club: 'Borussia Dortmund', clubLeague: 'Bundesliga', marketValue: 22000000, caps: 80, goals: 12 },
      { firstName: 'Alexander', lastName: 'Prass', jerseyNumber: 16, position: 'LB', dateOfBirth: '2001-07-28', height: 183, weight: 75, preferredFoot: 'Left', club: 'Sporting CP', clubLeague: 'Primeira Liga', marketValue: 15000000, caps: 10, goals: 0 },
      { firstName: 'Andreas', lastName: 'Weimann', jerseyNumber: 17, position: 'RW', dateOfBirth: '1991-08-05', height: 180, weight: 76, preferredFoot: 'Right', club: 'Blackburn Rovers', clubLeague: 'Championship', marketValue: 2000000, caps: 35, goals: 5 },
      { firstName: 'Romano', lastName: 'Schmid', jerseyNumber: 18, position: 'CAM', dateOfBirth: '2000-01-27', height: 174, weight: 68, preferredFoot: 'Right', club: 'Werder Bremen', clubLeague: 'Bundesliga', marketValue: 8000000, caps: 15, goals: 2 },
      { firstName: 'Konrad', lastName: 'Laimer', jerseyNumber: 19, position: 'CM', dateOfBirth: '1997-05-27', height: 180, weight: 75, preferredFoot: 'Right', club: 'Bayern Munich', clubLeague: 'Bundesliga', marketValue: 35000000, caps: 50, goals: 2 },
      { firstName: 'Alexander', lastName: 'Schlager', jerseyNumber: 20, position: 'GK', dateOfBirth: '1996-06-01', height: 191, weight: 86, preferredFoot: 'Right', club: 'LASK', clubLeague: 'Austrian Bundesliga', marketValue: 3000000, caps: 5, goals: 0 },
      { firstName: 'Stefan', lastName: 'Lainer', jerseyNumber: 21, position: 'RB', dateOfBirth: '1992-08-27', height: 178, weight: 72, preferredFoot: 'Right', club: 'Borussia M\'gladbach', clubLeague: 'Bundesliga', marketValue: 5000000, caps: 50, goals: 4 },
      { firstName: 'Valentino', lastName: 'Lazaro', jerseyNumber: 22, position: 'RB', dateOfBirth: '1996-03-24', height: 181, weight: 77, preferredFoot: 'Right', club: 'Feyenoord', clubLeague: 'Eredivisie', marketValue: 5000000, caps: 40, goals: 3 },
      { firstName: 'Xaver', lastName: 'Schlager', jerseyNumber: 23, position: 'CM', dateOfBirth: '1997-09-28', height: 173, weight: 68, preferredFoot: 'Right', club: 'RB Leipzig', clubLeague: 'Bundesliga', marketValue: 25000000, caps: 40, goals: 2 },
      { firstName: 'Matthias', lastName: 'Seidl', jerseyNumber: 24, position: 'CM', dateOfBirth: '2002-11-18', height: 178, weight: 72, preferredFoot: 'Right', club: 'Rapid Wien', clubLeague: 'Austrian Bundesliga', marketValue: 5000000, caps: 10, goals: 1 },
      { firstName: 'Junior', lastName: 'Adamu', jerseyNumber: 25, position: 'ST', dateOfBirth: '2001-05-27', height: 176, weight: 73, preferredFoot: 'Right', club: 'Freiburg', clubLeague: 'Bundesliga', marketValue: 5000000, caps: 15, goals: 2 },
      { firstName: 'Maximilian', lastName: 'Entrup', jerseyNumber: 26, position: 'ST', dateOfBirth: '1997-09-25', height: 191, weight: 85, preferredFoot: 'Right', club: 'TSV Hartberg', clubLeague: 'Austrian Bundesliga', marketValue: 2000000, caps: 5, goals: 1 },
    ],
  },

  // ========== POLAND ==========
  {
    name: 'Poland',
    fifaCode: 'POL',
    players: [
      { firstName: 'Wojciech', lastName: 'Szczęsny', jerseyNumber: 1, position: 'GK', dateOfBirth: '1990-04-18', height: 196, weight: 90, preferredFoot: 'Right', club: 'Barcelona', clubLeague: 'La Liga', marketValue: 3000000, caps: 90, goals: 0 },
      { firstName: 'Matty', lastName: 'Cash', jerseyNumber: 2, position: 'RB', dateOfBirth: '1997-08-07', height: 185, weight: 75, preferredFoot: 'Right', club: 'Aston Villa', clubLeague: 'Premier League', marketValue: 30000000, caps: 20, goals: 1 },
      { firstName: 'Jakub', lastName: 'Kiwior', jerseyNumber: 3, position: 'CB', dateOfBirth: '2000-02-15', height: 189, weight: 80, preferredFoot: 'Left', club: 'Arsenal', clubLeague: 'Premier League', marketValue: 25000000, caps: 25, goals: 0 },
      { firstName: 'Sebastian', lastName: 'Walukiewicz', jerseyNumber: 4, position: 'CB', dateOfBirth: '2000-04-05', height: 189, weight: 84, preferredFoot: 'Right', club: 'Torino', clubLeague: 'Serie A', marketValue: 7000000, caps: 10, goals: 0 },
      { firstName: 'Jan', lastName: 'Bednarek', jerseyNumber: 5, position: 'CB', dateOfBirth: '1996-04-12', height: 189, weight: 84, preferredFoot: 'Right', club: 'Southampton', clubLeague: 'Premier League', marketValue: 12000000, caps: 65, goals: 2 },
      { firstName: 'Jakub', lastName: 'Moder', jerseyNumber: 6, position: 'CM', dateOfBirth: '1999-04-07', height: 189, weight: 80, preferredFoot: 'Right', club: 'Brighton', clubLeague: 'Premier League', marketValue: 15000000, caps: 30, goals: 2 },
      { firstName: 'Kamil', lastName: 'Grosicki', jerseyNumber: 7, position: 'LW', dateOfBirth: '1988-06-08', height: 180, weight: 75, preferredFoot: 'Right', club: 'Pogoń Szczecin', clubLeague: 'Ekstraklasa', marketValue: 500000, caps: 95, goals: 17 },
      { firstName: 'Piotr', lastName: 'Zieliński', jerseyNumber: 8, position: 'CM', dateOfBirth: '1994-05-20', height: 180, weight: 75, preferredFoot: 'Right', club: 'Inter Milan', clubLeague: 'Serie A', marketValue: 35000000, caps: 95, goals: 11 },
      { firstName: 'Robert', lastName: 'Lewandowski', jerseyNumber: 9, position: 'ST', dateOfBirth: '1988-08-21', height: 185, weight: 81, preferredFoot: 'Right', club: 'Barcelona', clubLeague: 'La Liga', marketValue: 15000000, caps: 155, goals: 84 },
      { firstName: 'Sebastian', lastName: 'Szymański', jerseyNumber: 10, position: 'CAM', dateOfBirth: '1999-05-10', height: 178, weight: 70, preferredFoot: 'Right', club: 'Fenerbahçe', clubLeague: 'Super Lig', marketValue: 20000000, caps: 35, goals: 6 },
      { firstName: 'Przemysław', lastName: 'Frankowski', jerseyNumber: 11, position: 'RW', dateOfBirth: '1995-04-12', height: 174, weight: 67, preferredFoot: 'Right', club: 'Lens', clubLeague: 'Ligue 1', marketValue: 15000000, caps: 50, goals: 5 },
      { firstName: 'Łukasz', lastName: 'Skorupski', jerseyNumber: 12, position: 'GK', dateOfBirth: '1991-05-05', height: 187, weight: 80, preferredFoot: 'Right', club: 'Bologna', clubLeague: 'Serie A', marketValue: 5000000, caps: 25, goals: 0 },
      { firstName: 'Bartosz', lastName: 'Bereszyński', jerseyNumber: 13, position: 'RB', dateOfBirth: '1992-07-12', height: 183, weight: 75, preferredFoot: 'Right', club: 'Empoli', clubLeague: 'Serie A', marketValue: 2000000, caps: 55, goals: 0 },
      { firstName: 'Taras', lastName: 'Romanczuk', jerseyNumber: 14, position: 'CDM', dateOfBirth: '1991-12-21', height: 178, weight: 74, preferredFoot: 'Right', club: 'Jagiellonia', clubLeague: 'Ekstraklasa', marketValue: 1500000, caps: 15, goals: 0 },
      { firstName: 'Kamil', lastName: 'Glik', jerseyNumber: 15, position: 'CB', dateOfBirth: '1988-02-03', height: 190, weight: 85, preferredFoot: 'Right', club: 'Cracovia', clubLeague: 'Ekstraklasa', marketValue: 500000, caps: 100, goals: 6 },
      { firstName: 'Karol', lastName: 'Świderski', jerseyNumber: 16, position: 'ST', dateOfBirth: '1997-01-23', height: 184, weight: 78, preferredFoot: 'Right', club: 'Verona', clubLeague: 'Serie A', marketValue: 5000000, caps: 35, goals: 7 },
      { firstName: 'Nicola', lastName: 'Zalewski', jerseyNumber: 17, position: 'LB', dateOfBirth: '2002-01-23', height: 175, weight: 66, preferredFoot: 'Left', club: 'Roma', clubLeague: 'Serie A', marketValue: 18000000, caps: 30, goals: 1 },
      { firstName: 'Bartosz', lastName: 'Slisz', jerseyNumber: 18, position: 'CM', dateOfBirth: '1999-03-17', height: 183, weight: 78, preferredFoot: 'Right', club: 'Atlanta United', clubLeague: 'MLS', marketValue: 5000000, caps: 20, goals: 0 },
      { firstName: 'Adam', lastName: 'Buksa', jerseyNumber: 19, position: 'ST', dateOfBirth: '1996-07-12', height: 193, weight: 83, preferredFoot: 'Right', club: 'Midtjylland', clubLeague: 'Danish Superliga', marketValue: 4000000, caps: 25, goals: 6 },
      { firstName: 'Kacper', lastName: 'Urbański', jerseyNumber: 20, position: 'CAM', dateOfBirth: '2004-09-07', height: 175, weight: 65, preferredFoot: 'Left', club: 'Bologna', clubLeague: 'Serie A', marketValue: 12000000, caps: 10, goals: 1 },
      { firstName: 'Kamil', lastName: 'Piątkowski', jerseyNumber: 21, position: 'CB', dateOfBirth: '2000-01-28', height: 190, weight: 80, preferredFoot: 'Right', club: 'Red Bull Salzburg', clubLeague: 'Austrian Bundesliga', marketValue: 12000000, caps: 20, goals: 0 },
      { firstName: 'Marcin', lastName: 'Bułka', jerseyNumber: 22, position: 'GK', dateOfBirth: '1999-10-04', height: 199, weight: 90, preferredFoot: 'Right', club: 'Nice', clubLeague: 'Ligue 1', marketValue: 12000000, caps: 10, goals: 0 },
      { firstName: 'Krzysztof', lastName: 'Piątek', jerseyNumber: 23, position: 'ST', dateOfBirth: '1995-07-01', height: 183, weight: 77, preferredFoot: 'Right', club: 'İstanbul Başakşehir', clubLeague: 'Super Lig', marketValue: 5000000, caps: 35, goals: 7 },
      { firstName: 'Jakub', lastName: 'Piotrowski', jerseyNumber: 24, position: 'CM', dateOfBirth: '1997-10-03', height: 185, weight: 78, preferredFoot: 'Right', club: 'Ludogorets', clubLeague: 'Bulgarian First League', marketValue: 2500000, caps: 15, goals: 2 },
      { firstName: 'Paweł', lastName: 'Dawidowicz', jerseyNumber: 25, position: 'CB', dateOfBirth: '1995-05-20', height: 189, weight: 78, preferredFoot: 'Right', club: 'Verona', clubLeague: 'Serie A', marketValue: 4000000, caps: 15, goals: 0 },
      { firstName: 'Michał', lastName: 'Skóraś', jerseyNumber: 26, position: 'RW', dateOfBirth: '2000-02-28', height: 178, weight: 70, preferredFoot: 'Right', club: 'Club Brugge', clubLeague: 'Belgian First Division', marketValue: 10000000, caps: 15, goals: 2 },
    ],
  },

  // ========== SERBIA ==========
  {
    name: 'Serbia',
    fifaCode: 'SRB',
    players: [
      { firstName: 'Predrag', lastName: 'Rajković', jerseyNumber: 1, position: 'GK', dateOfBirth: '1995-10-31', height: 191, weight: 88, preferredFoot: 'Right', club: 'Mallorca', clubLeague: 'La Liga', marketValue: 5000000, caps: 30, goals: 0 },
      { firstName: 'Strahinja', lastName: 'Pavlović', jerseyNumber: 2, position: 'CB', dateOfBirth: '2001-05-24', height: 194, weight: 88, preferredFoot: 'Left', club: 'AC Milan', clubLeague: 'Serie A', marketValue: 30000000, caps: 30, goals: 2 },
      { firstName: 'Filip', lastName: 'Mladenović', jerseyNumber: 3, position: 'LB', dateOfBirth: '1991-08-15', height: 180, weight: 75, preferredFoot: 'Left', club: 'Panathinaikos', clubLeague: 'Super League Greece', marketValue: 1500000, caps: 35, goals: 1 },
      { firstName: 'Nikola', lastName: 'Milenković', jerseyNumber: 4, position: 'CB', dateOfBirth: '1997-10-12', height: 195, weight: 90, preferredFoot: 'Right', club: 'Nottingham Forest', clubLeague: 'Premier League', marketValue: 20000000, caps: 55, goals: 4 },
      { firstName: 'Miloš', lastName: 'Veljković', jerseyNumber: 5, position: 'CB', dateOfBirth: '1995-09-26', height: 189, weight: 85, preferredFoot: 'Right', club: 'Werder Bremen', clubLeague: 'Bundesliga', marketValue: 6000000, caps: 40, goals: 2 },
      { firstName: 'Nemanja', lastName: 'Gudelj', jerseyNumber: 6, position: 'CDM', dateOfBirth: '1991-11-16', height: 187, weight: 80, preferredFoot: 'Right', club: 'Sevilla', clubLeague: 'La Liga', marketValue: 5000000, caps: 55, goals: 2 },
      { firstName: 'Dušan', lastName: 'Tadić', jerseyNumber: 7, position: 'CAM', dateOfBirth: '1988-11-20', height: 181, weight: 80, preferredFoot: 'Left', club: 'Fenerbahçe', clubLeague: 'Super Lig', marketValue: 5000000, caps: 105, goals: 23 },
      { firstName: 'Nemanja', lastName: 'Maksimović', jerseyNumber: 8, position: 'CM', dateOfBirth: '1995-01-26', height: 183, weight: 77, preferredFoot: 'Right', club: 'Getafe', clubLeague: 'La Liga', marketValue: 5000000, caps: 35, goals: 1 },
      { firstName: 'Aleksandar', lastName: 'Mitrović', jerseyNumber: 9, position: 'ST', dateOfBirth: '1994-09-16', height: 189, weight: 82, preferredFoot: 'Right', club: 'Al-Hilal', clubLeague: 'Saudi Pro League', marketValue: 20000000, caps: 90, goals: 58 },
      { firstName: 'Dušan', lastName: 'Vlahović', jerseyNumber: 10, position: 'ST', dateOfBirth: '2000-01-28', height: 190, weight: 80, preferredFoot: 'Left', club: 'Juventus', clubLeague: 'Serie A', marketValue: 65000000, caps: 30, goals: 11 },
      { firstName: 'Filip', lastName: 'Kostić', jerseyNumber: 11, position: 'LW', dateOfBirth: '1992-11-01', height: 184, weight: 79, preferredFoot: 'Left', club: 'Juventus', clubLeague: 'Serie A', marketValue: 12000000, caps: 60, goals: 3 },
      { firstName: 'Vanja', lastName: 'Milinković-Savić', jerseyNumber: 12, position: 'GK', dateOfBirth: '1997-02-20', height: 202, weight: 92, preferredFoot: 'Right', club: 'Torino', clubLeague: 'Serie A', marketValue: 8000000, caps: 15, goals: 0 },
      { firstName: 'Stefan', lastName: 'Mitrović', jerseyNumber: 13, position: 'CB', dateOfBirth: '1990-05-22', height: 190, weight: 84, preferredFoot: 'Right', club: 'Getafe', clubLeague: 'La Liga', marketValue: 2000000, caps: 25, goals: 1 },
      { firstName: 'Andrija', lastName: 'Živković', jerseyNumber: 14, position: 'RW', dateOfBirth: '1996-07-11', height: 170, weight: 66, preferredFoot: 'Left', club: 'PAOK', clubLeague: 'Super League Greece', marketValue: 6000000, caps: 40, goals: 5 },
      { firstName: 'Srđan', lastName: 'Babić', jerseyNumber: 15, position: 'CB', dateOfBirth: '1996-03-10', height: 190, weight: 85, preferredFoot: 'Right', club: 'Spartak Moscow', clubLeague: 'Russian Premier League', marketValue: 3000000, caps: 15, goals: 0 },
      { firstName: 'Sasa', lastName: 'Lukić', jerseyNumber: 16, position: 'CM', dateOfBirth: '1996-08-13', height: 183, weight: 77, preferredFoot: 'Right', club: 'Fulham', clubLeague: 'Premier League', marketValue: 12000000, caps: 45, goals: 4 },
      { firstName: 'Filip', lastName: 'Đuričić', jerseyNumber: 17, position: 'CAM', dateOfBirth: '1992-01-30', height: 181, weight: 77, preferredFoot: 'Right', club: 'Sampdoria', clubLeague: 'Serie B', marketValue: 2000000, caps: 40, goals: 6 },
      { firstName: 'Sergej', lastName: 'Milinković-Savić', jerseyNumber: 18, position: 'CM', dateOfBirth: '1995-02-27', height: 191, weight: 76, preferredFoot: 'Right', club: 'Al-Hilal', clubLeague: 'Saudi Pro League', marketValue: 35000000, caps: 55, goals: 6 },
      { firstName: 'Luka', lastName: 'Jović', jerseyNumber: 19, position: 'ST', dateOfBirth: '1997-12-23', height: 182, weight: 82, preferredFoot: 'Right', club: 'AC Milan', clubLeague: 'Serie A', marketValue: 8000000, caps: 35, goals: 9 },
      { firstName: 'Mijat', lastName: 'Gaćinović', jerseyNumber: 20, position: 'CM', dateOfBirth: '1995-02-08', height: 175, weight: 68, preferredFoot: 'Right', club: 'AEK Athens', clubLeague: 'Super League Greece', marketValue: 3000000, caps: 30, goals: 1 },
      { firstName: 'Uroš', lastName: 'Spajić', jerseyNumber: 21, position: 'CB', dateOfBirth: '1993-02-13', height: 186, weight: 79, preferredFoot: 'Right', club: 'Red Star Belgrade', clubLeague: 'Serbian SuperLiga', marketValue: 2000000, caps: 25, goals: 1 },
      { firstName: 'Đorđe', lastName: 'Petrović', jerseyNumber: 22, position: 'GK', dateOfBirth: '1999-10-08', height: 194, weight: 87, preferredFoot: 'Right', club: 'Chelsea', clubLeague: 'Premier League', marketValue: 15000000, caps: 10, goals: 0 },
      { firstName: 'Srđan', lastName: 'Mijailović', jerseyNumber: 23, position: 'LB', dateOfBirth: '2000-02-20', height: 188, weight: 80, preferredFoot: 'Left', club: 'Red Star Belgrade', clubLeague: 'Serbian SuperLiga', marketValue: 3500000, caps: 10, goals: 0 },
      { firstName: 'Ivan', lastName: 'Ilić', jerseyNumber: 24, position: 'CM', dateOfBirth: '2001-03-17', height: 188, weight: 78, preferredFoot: 'Left', club: 'Torino', clubLeague: 'Serie A', marketValue: 20000000, caps: 20, goals: 1 },
      { firstName: 'Veljko', lastName: 'Birmančević', jerseyNumber: 25, position: 'RW', dateOfBirth: '1998-04-09', height: 177, weight: 70, preferredFoot: 'Left', club: 'Sparta Prague', clubLeague: 'Czech First League', marketValue: 6000000, caps: 10, goals: 2 },
      { firstName: 'Strahinja', lastName: 'Eraković', jerseyNumber: 26, position: 'CB', dateOfBirth: '2001-01-22', height: 190, weight: 82, preferredFoot: 'Right', club: 'Celtic', clubLeague: 'Scottish Premiership', marketValue: 8000000, caps: 5, goals: 0 },
    ],
  },

  // ========== AUSTRALIA ==========
  {
    name: 'Australia',
    fifaCode: 'AUS',
    players: [
      { firstName: 'Mat', lastName: 'Ryan', jerseyNumber: 1, position: 'GK', dateOfBirth: '1992-04-08', height: 184, weight: 78, preferredFoot: 'Right', club: 'Roma', clubLeague: 'Serie A', marketValue: 3000000, caps: 95, goals: 0 },
      { firstName: 'Miloš', lastName: 'Degenek', jerseyNumber: 2, position: 'CB', dateOfBirth: '1994-04-28', height: 187, weight: 80, preferredFoot: 'Right', club: 'Columbus Crew', clubLeague: 'MLS', marketValue: 1500000, caps: 45, goals: 0 },
      { firstName: 'Aziz', lastName: 'Behich', jerseyNumber: 3, position: 'LB', dateOfBirth: '1990-12-16', height: 172, weight: 65, preferredFoot: 'Left', club: 'Dundee United', clubLeague: 'Scottish Premiership', marketValue: 500000, caps: 65, goals: 0 },
      { firstName: 'Kye', lastName: 'Rowles', jerseyNumber: 4, position: 'CB', dateOfBirth: '1998-06-24', height: 183, weight: 78, preferredFoot: 'Right', club: 'Hearts', clubLeague: 'Scottish Premiership', marketValue: 2000000, caps: 25, goals: 1 },
      { firstName: 'Harry', lastName: 'Souttar', jerseyNumber: 5, position: 'CB', dateOfBirth: '1998-10-22', height: 198, weight: 90, preferredFoot: 'Right', club: 'Leicester City', clubLeague: 'Premier League', marketValue: 12000000, caps: 25, goals: 5 },
      { firstName: 'Bailey', lastName: 'Wright', jerseyNumber: 6, position: 'CB', dateOfBirth: '1992-07-28', height: 185, weight: 82, preferredFoot: 'Right', club: 'West Bromwich Albion', clubLeague: 'Championship', marketValue: 1500000, caps: 30, goals: 2 },
      { firstName: 'Mathew', lastName: 'Leckie', jerseyNumber: 7, position: 'RW', dateOfBirth: '1991-02-04', height: 181, weight: 74, preferredFoot: 'Right', club: 'Melbourne City', clubLeague: 'A-League', marketValue: 800000, caps: 80, goals: 13 },
      { firstName: 'Aaron', lastName: 'Mooy', jerseyNumber: 8, position: 'CM', dateOfBirth: '1990-09-15', height: 174, weight: 72, preferredFoot: 'Right', club: 'Free Agent', clubLeague: 'N/A', marketValue: 1000000, caps: 60, goals: 8 },
      { firstName: 'Jamie', lastName: 'Maclaren', jerseyNumber: 9, position: 'ST', dateOfBirth: '1993-07-29', height: 175, weight: 73, preferredFoot: 'Right', club: 'Melbourne City', clubLeague: 'A-League', marketValue: 2500000, caps: 35, goals: 15 },
      { firstName: 'Ajdin', lastName: 'Hrustić', jerseyNumber: 10, position: 'CAM', dateOfBirth: '1996-07-05', height: 178, weight: 75, preferredFoot: 'Left', club: 'Lecce', clubLeague: 'Serie A', marketValue: 4000000, caps: 30, goals: 3 },
      { firstName: 'Awer', lastName: 'Mabil', jerseyNumber: 11, position: 'RW', dateOfBirth: '1995-09-15', height: 180, weight: 73, preferredFoot: 'Right', club: 'Grasshopper', clubLeague: 'Swiss Super League', marketValue: 1500000, caps: 35, goals: 6 },
      { firstName: 'Danny', lastName: 'Vukovic', jerseyNumber: 12, position: 'GK', dateOfBirth: '1985-03-27', height: 189, weight: 82, preferredFoot: 'Right', club: 'Central Coast', clubLeague: 'A-League', marketValue: 250000, caps: 15, goals: 0 },
      { firstName: 'Nathaniel', lastName: 'Atkinson', jerseyNumber: 13, position: 'RB', dateOfBirth: '1999-06-13', height: 178, weight: 72, preferredFoot: 'Right', club: 'Hearts', clubLeague: 'Scottish Premiership', marketValue: 2500000, caps: 15, goals: 0 },
      { firstName: 'Riley', lastName: 'McGree', jerseyNumber: 14, position: 'CM', dateOfBirth: '1998-11-02', height: 176, weight: 72, preferredFoot: 'Right', club: 'Middlesbrough', clubLeague: 'Championship', marketValue: 5000000, caps: 25, goals: 3 },
      { firstName: 'Jackson', lastName: 'Irvine', jerseyNumber: 15, position: 'CM', dateOfBirth: '1993-03-07', height: 190, weight: 82, preferredFoot: 'Right', club: 'St. Pauli', clubLeague: 'Bundesliga', marketValue: 5000000, caps: 65, goals: 8 },
      { firstName: 'Craig', lastName: 'Goodwin', jerseyNumber: 16, position: 'LW', dateOfBirth: '1991-12-16', height: 177, weight: 74, preferredFoot: 'Left', club: 'Al-Wehda', clubLeague: 'Saudi Pro League', marketValue: 2000000, caps: 25, goals: 3 },
      { firstName: 'Keanu', lastName: 'Baccus', jerseyNumber: 17, position: 'CM', dateOfBirth: '1998-06-07', height: 175, weight: 70, preferredFoot: 'Right', club: 'St. Mirren', clubLeague: 'Scottish Premiership', marketValue: 1500000, caps: 15, goals: 0 },
      { firstName: 'Connor', lastName: 'Metcalfe', jerseyNumber: 18, position: 'LB', dateOfBirth: '1999-11-04', height: 183, weight: 75, preferredFoot: 'Left', club: 'St. Pauli', clubLeague: 'Bundesliga', marketValue: 3000000, caps: 15, goals: 0 },
      { firstName: 'Garang', lastName: 'Kuol', jerseyNumber: 19, position: 'ST', dateOfBirth: '2004-09-15', height: 174, weight: 64, preferredFoot: 'Right', club: 'Newcastle United', clubLeague: 'Premier League', marketValue: 3000000, caps: 10, goals: 1 },
      { firstName: 'Trent', lastName: 'Sainsbury', jerseyNumber: 20, position: 'CB', dateOfBirth: '1992-01-05', height: 183, weight: 79, preferredFoot: 'Right', club: 'Al-Wakrah', clubLeague: 'Qatar Stars League', marketValue: 800000, caps: 60, goals: 1 },
      { firstName: 'Cameron', lastName: 'Devlin', jerseyNumber: 21, position: 'CDM', dateOfBirth: '1998-06-07', height: 172, weight: 68, preferredFoot: 'Right', club: 'Hearts', clubLeague: 'Scottish Premiership', marketValue: 1500000, caps: 10, goals: 0 },
      { firstName: 'Joe', lastName: 'Gauci', jerseyNumber: 22, position: 'GK', dateOfBirth: '2000-10-04', height: 192, weight: 84, preferredFoot: 'Right', club: 'Aston Villa', clubLeague: 'Premier League', marketValue: 1500000, caps: 5, goals: 0 },
      { firstName: 'Mitchell', lastName: 'Duke', jerseyNumber: 23, position: 'ST', dateOfBirth: '1991-01-18', height: 187, weight: 80, preferredFoot: 'Right', club: 'Machida Zelvia', clubLeague: 'J1 League', marketValue: 800000, caps: 40, goals: 10 },
      { firstName: 'Alessandro', lastName: 'Circati', jerseyNumber: 24, position: 'CB', dateOfBirth: '2003-04-23', height: 190, weight: 80, preferredFoot: 'Right', club: 'Parma', clubLeague: 'Serie A', marketValue: 5000000, caps: 5, goals: 0 },
      { firstName: 'Lewis', lastName: 'Miller', jerseyNumber: 25, position: 'RB', dateOfBirth: '1999-11-14', height: 181, weight: 73, preferredFoot: 'Right', club: 'Hibernian', clubLeague: 'Scottish Premiership', marketValue: 1000000, caps: 5, goals: 0 },
      { firstName: 'Nestory', lastName: 'Irankunda', jerseyNumber: 26, position: 'LW', dateOfBirth: '2006-02-09', height: 178, weight: 68, preferredFoot: 'Right', club: 'Bayern Munich', clubLeague: 'Bundesliga', marketValue: 4000000, caps: 5, goals: 1 },
    ],
  },

  // ========== NIGERIA ==========
  {
    name: 'Nigeria',
    fifaCode: 'NGA',
    players: [
      { firstName: 'Francis', lastName: 'Uzoho', jerseyNumber: 1, position: 'GK', dateOfBirth: '1998-10-28', height: 196, weight: 88, preferredFoot: 'Right', club: 'Omonia Nicosia', clubLeague: 'Cypriot First Division', marketValue: 1500000, caps: 20, goals: 0 },
      { firstName: 'Ola', lastName: 'Aina', jerseyNumber: 2, position: 'RB', dateOfBirth: '1996-10-08', height: 183, weight: 75, preferredFoot: 'Right', club: 'Nottingham Forest', clubLeague: 'Premier League', marketValue: 15000000, caps: 45, goals: 1 },
      { firstName: 'Calvin', lastName: 'Bassey', jerseyNumber: 3, position: 'CB', dateOfBirth: '1999-12-31', height: 185, weight: 80, preferredFoot: 'Left', club: 'Fulham', clubLeague: 'Premier League', marketValue: 25000000, caps: 30, goals: 0 },
      { firstName: 'William', lastName: 'Ekong', jerseyNumber: 4, position: 'CB', dateOfBirth: '1993-10-21', height: 186, weight: 78, preferredFoot: 'Right', club: 'Al-Kholood', clubLeague: 'Saudi Pro League', marketValue: 2000000, caps: 70, goals: 1 },
      { firstName: 'Semi', lastName: 'Ajayi', jerseyNumber: 5, position: 'CB', dateOfBirth: '1993-11-09', height: 191, weight: 82, preferredFoot: 'Right', club: 'West Bromwich Albion', clubLeague: 'Championship', marketValue: 4000000, caps: 35, goals: 3 },
      { firstName: 'Wilfred', lastName: 'Ndidi', jerseyNumber: 6, position: 'CDM', dateOfBirth: '1996-12-16', height: 183, weight: 74, preferredFoot: 'Right', club: 'Leicester City', clubLeague: 'Premier League', marketValue: 30000000, caps: 55, goals: 2 },
      { firstName: 'Ahmed', lastName: 'Musa', jerseyNumber: 7, position: 'LW', dateOfBirth: '1992-10-14', height: 170, weight: 64, preferredFoot: 'Right', club: 'Sivasspor', clubLeague: 'Super Lig', marketValue: 1000000, caps: 130, goals: 24 },
      { firstName: 'Frank', lastName: 'Onyeka', jerseyNumber: 8, position: 'CM', dateOfBirth: '1997-01-01', height: 178, weight: 74, preferredFoot: 'Right', club: 'Brentford', clubLeague: 'Premier League', marketValue: 12000000, caps: 20, goals: 0 },
      { firstName: 'Victor', lastName: 'Osimhen', jerseyNumber: 9, position: 'ST', dateOfBirth: '1998-12-29', height: 186, weight: 78, preferredFoot: 'Right', club: 'Galatasaray', clubLeague: 'Super Lig', marketValue: 75000000, caps: 35, goals: 21 },
      { firstName: 'Joe', lastName: 'Aribo', jerseyNumber: 10, position: 'CAM', dateOfBirth: '1996-07-21', height: 183, weight: 71, preferredFoot: 'Right', club: 'Southampton', clubLeague: 'Premier League', marketValue: 10000000, caps: 35, goals: 4 },
      { firstName: 'Samuel', lastName: 'Chukwueze', jerseyNumber: 11, position: 'RW', dateOfBirth: '1999-05-22', height: 173, weight: 68, preferredFoot: 'Left', club: 'AC Milan', clubLeague: 'Serie A', marketValue: 25000000, caps: 35, goals: 5 },
      { firstName: 'Maduka', lastName: 'Okoye', jerseyNumber: 12, position: 'GK', dateOfBirth: '1999-08-28', height: 195, weight: 85, preferredFoot: 'Right', club: 'Udinese', clubLeague: 'Serie A', marketValue: 5000000, caps: 15, goals: 0 },
      { firstName: 'Bright', lastName: 'Osayi-Samuel', jerseyNumber: 13, position: 'RB', dateOfBirth: '1997-12-31', height: 175, weight: 72, preferredFoot: 'Right', club: 'Fenerbahçe', clubLeague: 'Super Lig', marketValue: 15000000, caps: 25, goals: 1 },
      { firstName: 'Kelechi', lastName: 'Iheanacho', jerseyNumber: 14, position: 'ST', dateOfBirth: '1996-10-03', height: 185, weight: 79, preferredFoot: 'Right', club: 'Sevilla', clubLeague: 'La Liga', marketValue: 8000000, caps: 50, goals: 13 },
      { firstName: 'Moses', lastName: 'Simon', jerseyNumber: 15, position: 'LW', dateOfBirth: '1995-07-12', height: 162, weight: 60, preferredFoot: 'Right', club: 'Nantes', clubLeague: 'Ligue 1', marketValue: 12000000, caps: 60, goals: 10 },
      { firstName: 'Taiwo', lastName: 'Awoniyi', jerseyNumber: 16, position: 'ST', dateOfBirth: '1997-08-12', height: 183, weight: 80, preferredFoot: 'Right', club: 'Nottingham Forest', clubLeague: 'Premier League', marketValue: 20000000, caps: 25, goals: 5 },
      { firstName: 'Alex', lastName: 'Iwobi', jerseyNumber: 17, position: 'CM', dateOfBirth: '1996-05-03', height: 180, weight: 75, preferredFoot: 'Right', club: 'Fulham', clubLeague: 'Premier League', marketValue: 30000000, caps: 75, goals: 5 },
      { firstName: 'Zaidu', lastName: 'Sanusi', jerseyNumber: 18, position: 'LB', dateOfBirth: '1997-06-17', height: 181, weight: 74, preferredFoot: 'Left', club: 'Porto', clubLeague: 'Primeira Liga', marketValue: 8000000, caps: 25, goals: 0 },
      { firstName: 'Ademola', lastName: 'Lookman', jerseyNumber: 19, position: 'LW', dateOfBirth: '1997-10-20', height: 174, weight: 70, preferredFoot: 'Right', club: 'Atalanta', clubLeague: 'Serie A', marketValue: 45000000, caps: 30, goals: 8 },
      { firstName: 'Eberechi', lastName: 'Eze', jerseyNumber: 20, position: 'CAM', dateOfBirth: '1998-06-29', height: 178, weight: 68, preferredFoot: 'Left', club: 'Crystal Palace', clubLeague: 'Premier League', marketValue: 60000000, caps: 10, goals: 2 },
      { firstName: 'Bruno', lastName: 'Onyemaechi', jerseyNumber: 21, position: 'LB', dateOfBirth: '1999-08-22', height: 181, weight: 75, preferredFoot: 'Left', club: 'Boavista', clubLeague: 'Primeira Liga', marketValue: 3000000, caps: 10, goals: 0 },
      { firstName: 'Stanley', lastName: 'Nwabali', jerseyNumber: 22, position: 'GK', dateOfBirth: '1996-04-07', height: 195, weight: 88, preferredFoot: 'Right', club: 'Chippa United', clubLeague: 'South African Premier', marketValue: 500000, caps: 10, goals: 0 },
      { firstName: 'Nathan', lastName: 'Collins', jerseyNumber: 23, position: 'CB', dateOfBirth: '2001-04-30', height: 193, weight: 82, preferredFoot: 'Right', club: 'Brentford', clubLeague: 'Premier League', marketValue: 35000000, caps: 5, goals: 0 },
      { firstName: 'Fisayo', lastName: 'Dele-Bashiru', jerseyNumber: 24, position: 'CM', dateOfBirth: '2001-01-17', height: 186, weight: 76, preferredFoot: 'Right', club: 'Lazio', clubLeague: 'Serie A', marketValue: 10000000, caps: 10, goals: 1 },
      { firstName: 'Raphael', lastName: 'Onyedika', jerseyNumber: 25, position: 'CDM', dateOfBirth: '2001-06-10', height: 175, weight: 68, preferredFoot: 'Right', club: 'Club Brugge', clubLeague: 'Belgian First Division', marketValue: 15000000, caps: 15, goals: 0 },
      { firstName: 'Victor', lastName: 'Boniface', jerseyNumber: 26, position: 'ST', dateOfBirth: '2000-12-23', height: 190, weight: 85, preferredFoot: 'Right', club: 'Bayer Leverkusen', clubLeague: 'Bundesliga', marketValue: 35000000, caps: 15, goals: 6 },
    ],
  },

  // ========== CAMEROON ==========
  {
    name: 'Cameroon',
    fifaCode: 'CMR',
    players: [
      { firstName: 'André', lastName: 'Onana', jerseyNumber: 1, position: 'GK', dateOfBirth: '1996-04-02', height: 190, weight: 85, preferredFoot: 'Right', club: 'Manchester United', clubLeague: 'Premier League', marketValue: 35000000, caps: 45, goals: 0 },
      { firstName: 'Christopher', lastName: 'Wooh', jerseyNumber: 2, position: 'CB', dateOfBirth: '2001-09-18', height: 191, weight: 84, preferredFoot: 'Right', club: 'Stade Rennais', clubLeague: 'Ligue 1', marketValue: 10000000, caps: 20, goals: 1 },
      { firstName: 'Nicolas', lastName: 'Nkoulou', jerseyNumber: 3, position: 'CB', dateOfBirth: '1990-03-27', height: 182, weight: 80, preferredFoot: 'Right', club: 'Aris Thessaloniki', clubLeague: 'Super League Greece', marketValue: 1000000, caps: 80, goals: 3 },
      { firstName: 'Enzo', lastName: 'Ebosse', jerseyNumber: 4, position: 'CB', dateOfBirth: '1999-03-11', height: 184, weight: 78, preferredFoot: 'Left', club: 'Udinese', clubLeague: 'Serie A', marketValue: 8000000, caps: 15, goals: 0 },
      { firstName: 'Michael', lastName: 'Ngadeu-Ngadjui', jerseyNumber: 5, position: 'CB', dateOfBirth: '1990-11-23', height: 190, weight: 85, preferredFoot: 'Right', club: 'Gent', clubLeague: 'Belgian First Division', marketValue: 2000000, caps: 55, goals: 4 },
      { firstName: 'Ambroise', lastName: 'Oyongo', jerseyNumber: 6, position: 'LB', dateOfBirth: '1991-06-22', height: 175, weight: 72, preferredFoot: 'Left', club: 'Montpellier', clubLeague: 'Ligue 1', marketValue: 1500000, caps: 50, goals: 1 },
      { firstName: 'Léandre', lastName: 'Tawamba', jerseyNumber: 7, position: 'ST', dateOfBirth: '1989-12-20', height: 188, weight: 82, preferredFoot: 'Right', club: 'Al-Taawoun', clubLeague: 'Saudi Pro League', marketValue: 1000000, caps: 35, goals: 8 },
      { firstName: 'André-Frank', lastName: 'Zambo Anguissa', jerseyNumber: 8, position: 'CM', dateOfBirth: '1995-11-16', height: 184, weight: 80, preferredFoot: 'Right', club: 'Napoli', clubLeague: 'Serie A', marketValue: 50000000, caps: 60, goals: 5 },
      { firstName: 'Eric Maxim', lastName: 'Choupo-Moting', jerseyNumber: 9, position: 'ST', dateOfBirth: '1989-03-23', height: 191, weight: 83, preferredFoot: 'Right', club: 'Bayern Munich', clubLeague: 'Bundesliga', marketValue: 4000000, caps: 80, goals: 20 },
      { firstName: 'Vincent', lastName: 'Aboubakar', jerseyNumber: 10, position: 'ST', dateOfBirth: '1992-01-22', height: 184, weight: 78, preferredFoot: 'Right', club: 'Beşiktaş', clubLeague: 'Super Lig', marketValue: 5000000, caps: 100, goals: 35 },
      { firstName: 'Bryan', lastName: 'Mbeumo', jerseyNumber: 11, position: 'RW', dateOfBirth: '1999-08-07', height: 175, weight: 69, preferredFoot: 'Left', club: 'Brentford', clubLeague: 'Premier League', marketValue: 50000000, caps: 15, goals: 2 },
      { firstName: 'Devis', lastName: 'Epassy', jerseyNumber: 12, position: 'GK', dateOfBirth: '1993-02-02', height: 192, weight: 85, preferredFoot: 'Right', club: 'Abha', clubLeague: 'Saudi Pro League', marketValue: 1000000, caps: 25, goals: 0 },
      { firstName: 'Collins', lastName: 'Fai', jerseyNumber: 13, position: 'RB', dateOfBirth: '1992-08-13', height: 174, weight: 70, preferredFoot: 'Right', club: 'Standard Liège', clubLeague: 'Belgian First Division', marketValue: 1500000, caps: 55, goals: 0 },
      { firstName: 'Martin', lastName: 'Hongla', jerseyNumber: 14, position: 'CM', dateOfBirth: '1998-03-16', height: 180, weight: 75, preferredFoot: 'Right', club: 'Verona', clubLeague: 'Serie A', marketValue: 8000000, caps: 30, goals: 1 },
      { firstName: 'Jean-Charles', lastName: 'Castelletto', jerseyNumber: 15, position: 'CB', dateOfBirth: '1995-01-26', height: 183, weight: 78, preferredFoot: 'Right', club: 'Nantes', clubLeague: 'Ligue 1', marketValue: 5000000, caps: 35, goals: 2 },
      { firstName: 'Olivier', lastName: 'Ntcham', jerseyNumber: 16, position: 'CM', dateOfBirth: '1996-02-09', height: 180, weight: 75, preferredFoot: 'Right', club: 'Free Agent', clubLeague: 'N/A', marketValue: 2000000, caps: 25, goals: 2 },
      { firstName: 'Karl Toko', lastName: 'Ekambi', jerseyNumber: 17, position: 'LW', dateOfBirth: '1992-09-14', height: 185, weight: 77, preferredFoot: 'Right', club: 'Lyon', clubLeague: 'Ligue 1', marketValue: 12000000, caps: 60, goals: 14 },
      { firstName: 'Clinton', lastName: "N'Jie", jerseyNumber: 18, position: 'RW', dateOfBirth: '1993-08-15', height: 173, weight: 67, preferredFoot: 'Right', club: 'Paphos', clubLeague: 'Cypriot First Division', marketValue: 500000, caps: 40, goals: 5 },
      { firstName: 'Christian', lastName: 'Bassogog', jerseyNumber: 19, position: 'LW', dateOfBirth: '1995-10-18', height: 177, weight: 72, preferredFoot: 'Right', club: 'Shanghai Shenhua', clubLeague: 'Chinese Super League', marketValue: 2000000, caps: 45, goals: 5 },
      { firstName: 'Georges-Kevin', lastName: 'Nkoudou', jerseyNumber: 20, position: 'LW', dateOfBirth: '1995-02-13', height: 174, weight: 67, preferredFoot: 'Right', club: 'Beşiktaş', clubLeague: 'Super Lig', marketValue: 3000000, caps: 15, goals: 0 },
      { firstName: 'Jean-Pierre', lastName: 'Nsame', jerseyNumber: 21, position: 'ST', dateOfBirth: '1993-05-01', height: 182, weight: 80, preferredFoot: 'Right', club: 'Young Boys', clubLeague: 'Swiss Super League', marketValue: 3000000, caps: 20, goals: 5 },
      { firstName: 'Simon', lastName: 'Ngapandouetnbu', jerseyNumber: 22, position: 'GK', dateOfBirth: '2004-06-10', height: 193, weight: 80, preferredFoot: 'Right', club: 'Marseille', clubLeague: 'Ligue 1', marketValue: 3000000, caps: 5, goals: 0 },
      { firstName: 'Nouhou', lastName: 'Tolo', jerseyNumber: 23, position: 'LB', dateOfBirth: '1997-06-23', height: 178, weight: 75, preferredFoot: 'Left', club: 'Seattle Sounders', clubLeague: 'MLS', marketValue: 3000000, caps: 20, goals: 0 },
      { firstName: 'Pierre', lastName: 'Kunde', jerseyNumber: 24, position: 'CM', dateOfBirth: '1995-07-26', height: 178, weight: 75, preferredFoot: 'Right', club: 'Olympiacos', clubLeague: 'Super League Greece', marketValue: 3000000, caps: 30, goals: 1 },
      { firstName: 'Carlos', lastName: 'Baleba', jerseyNumber: 25, position: 'CDM', dateOfBirth: '2004-01-03', height: 182, weight: 72, preferredFoot: 'Right', club: 'Brighton', clubLeague: 'Premier League', marketValue: 30000000, caps: 10, goals: 0 },
      { firstName: 'Georges', lastName: 'Douath', jerseyNumber: 26, position: 'CM', dateOfBirth: '2003-01-17', height: 175, weight: 70, preferredFoot: 'Right', club: 'Red Bull Salzburg', clubLeague: 'Austrian Bundesliga', marketValue: 10000000, caps: 5, goals: 0 },
    ],
  },

  // ========== GHANA ==========
  {
    name: 'Ghana',
    fifaCode: 'GHA',
    players: [
      { firstName: 'Lawrence', lastName: 'Ati-Zigi', jerseyNumber: 1, position: 'GK', dateOfBirth: '1996-12-29', height: 192, weight: 85, preferredFoot: 'Right', club: 'St. Gallen', clubLeague: 'Swiss Super League', marketValue: 2000000, caps: 25, goals: 0 },
      { firstName: 'Tariq', lastName: 'Lamptey', jerseyNumber: 2, position: 'RB', dateOfBirth: '2000-09-30', height: 163, weight: 59, preferredFoot: 'Right', club: 'Brighton', clubLeague: 'Premier League', marketValue: 25000000, caps: 15, goals: 0 },
      { firstName: 'Denis', lastName: 'Odoi', jerseyNumber: 3, position: 'CB', dateOfBirth: '1988-05-27', height: 182, weight: 78, preferredFoot: 'Right', club: 'Club Brugge', clubLeague: 'Belgian First Division', marketValue: 1000000, caps: 25, goals: 0 },
      { firstName: 'Gideon', lastName: 'Mensah', jerseyNumber: 4, position: 'LB', dateOfBirth: '1998-07-18', height: 180, weight: 75, preferredFoot: 'Left', club: 'Auxerre', clubLeague: 'Ligue 1', marketValue: 5000000, caps: 25, goals: 0 },
      { firstName: 'Mohammed', lastName: 'Salisu', jerseyNumber: 5, position: 'CB', dateOfBirth: '1999-04-17', height: 188, weight: 82, preferredFoot: 'Left', club: 'Monaco', clubLeague: 'Ligue 1', marketValue: 20000000, caps: 25, goals: 0 },
      { firstName: 'Thomas', lastName: 'Partey', jerseyNumber: 6, position: 'CDM', dateOfBirth: '1993-06-13', height: 185, weight: 77, preferredFoot: 'Right', club: 'Arsenal', clubLeague: 'Premier League', marketValue: 35000000, caps: 50, goals: 13 },
      { firstName: 'Kamaldeen', lastName: 'Sulemana', jerseyNumber: 7, position: 'LW', dateOfBirth: '2002-02-15', height: 175, weight: 66, preferredFoot: 'Right', club: 'Southampton', clubLeague: 'Premier League', marketValue: 18000000, caps: 15, goals: 2 },
      { firstName: 'Daniel-Kofi', lastName: 'Kyereh', jerseyNumber: 8, position: 'CAM', dateOfBirth: '1996-03-08', height: 176, weight: 69, preferredFoot: 'Right', club: 'Freiburg', clubLeague: 'Bundesliga', marketValue: 5000000, caps: 20, goals: 2 },
      { firstName: 'Jordan', lastName: 'Ayew', jerseyNumber: 9, position: 'ST', dateOfBirth: '1991-09-11', height: 182, weight: 77, preferredFoot: 'Right', club: 'Crystal Palace', clubLeague: 'Premier League', marketValue: 5000000, caps: 100, goals: 23 },
      { firstName: 'André', lastName: 'Ayew', jerseyNumber: 10, position: 'CAM', dateOfBirth: '1989-12-17', height: 176, weight: 72, preferredFoot: 'Left', club: 'Le Havre', clubLeague: 'Ligue 1', marketValue: 1500000, caps: 120, goals: 24 },
      { firstName: 'Mohammed', lastName: 'Kudus', jerseyNumber: 11, position: 'RW', dateOfBirth: '2000-08-02', height: 177, weight: 70, preferredFoot: 'Left', club: 'West Ham', clubLeague: 'Premier League', marketValue: 70000000, caps: 30, goals: 8 },
      { firstName: 'Abdul Manaf', lastName: 'Nurudeen', jerseyNumber: 12, position: 'GK', dateOfBirth: '1999-01-08', height: 188, weight: 82, preferredFoot: 'Right', club: 'Eupen', clubLeague: 'Belgian First Division', marketValue: 1000000, caps: 10, goals: 0 },
      { firstName: 'Daniel', lastName: 'Amartey', jerseyNumber: 13, position: 'CB', dateOfBirth: '1994-12-21', height: 186, weight: 80, preferredFoot: 'Right', club: 'Beşiktaş', clubLeague: 'Super Lig', marketValue: 3000000, caps: 50, goals: 1 },
      { firstName: 'Alexander', lastName: 'Djiku', jerseyNumber: 14, position: 'CB', dateOfBirth: '1994-08-09', height: 181, weight: 78, preferredFoot: 'Right', club: 'Fenerbahçe', clubLeague: 'Super Lig', marketValue: 8000000, caps: 30, goals: 0 },
      { firstName: 'Antoine', lastName: 'Semenyo', jerseyNumber: 15, position: 'RW', dateOfBirth: '2000-01-07', height: 177, weight: 72, preferredFoot: 'Right', club: 'Bournemouth', clubLeague: 'Premier League', marketValue: 25000000, caps: 20, goals: 3 },
      { firstName: 'Abdul Salis', lastName: 'Samed', jerseyNumber: 16, position: 'CM', dateOfBirth: '2000-03-26', height: 176, weight: 70, preferredFoot: 'Right', club: 'Lens', clubLeague: 'Ligue 1', marketValue: 12000000, caps: 15, goals: 0 },
      { firstName: 'Abdul Rahman', lastName: 'Baba', jerseyNumber: 17, position: 'LB', dateOfBirth: '1994-07-02', height: 180, weight: 75, preferredFoot: 'Left', club: 'Reading', clubLeague: 'Championship', marketValue: 2000000, caps: 50, goals: 0 },
      { firstName: 'Salis Abdul', lastName: 'Samed', jerseyNumber: 18, position: 'CM', dateOfBirth: '2000-03-26', height: 176, weight: 70, preferredFoot: 'Right', club: 'Lens', clubLeague: 'Ligue 1', marketValue: 12000000, caps: 15, goals: 0 },
      { firstName: 'Iñaki', lastName: 'Williams', jerseyNumber: 19, position: 'RW', dateOfBirth: '1994-06-15', height: 185, weight: 78, preferredFoot: 'Right', club: 'Athletic Bilbao', clubLeague: 'La Liga', marketValue: 20000000, caps: 20, goals: 4 },
      { firstName: 'Mohamed', lastName: 'Kudus', jerseyNumber: 20, position: 'CAM', dateOfBirth: '2000-08-02', height: 177, weight: 70, preferredFoot: 'Left', club: 'West Ham', clubLeague: 'Premier League', marketValue: 70000000, caps: 30, goals: 8 },
      { firstName: 'Braydon', lastName: 'Manu', jerseyNumber: 21, position: 'RW', dateOfBirth: '1997-02-10', height: 177, weight: 72, preferredFoot: 'Right', club: 'Darmstadt', clubLeague: '2. Bundesliga', marketValue: 1500000, caps: 5, goals: 0 },
      { firstName: 'Joseph', lastName: 'Wollacott', jerseyNumber: 22, position: 'GK', dateOfBirth: '1996-09-22', height: 193, weight: 88, preferredFoot: 'Right', club: 'Charlton Athletic', clubLeague: 'League One', marketValue: 500000, caps: 10, goals: 0 },
      { firstName: 'Alidu', lastName: 'Seidu', jerseyNumber: 23, position: 'RB', dateOfBirth: '2000-06-04', height: 176, weight: 70, preferredFoot: 'Right', club: 'Stade Rennais', clubLeague: 'Ligue 1', marketValue: 12000000, caps: 20, goals: 0 },
      { firstName: 'Ibrahim', lastName: 'Sulemana', jerseyNumber: 24, position: 'CM', dateOfBirth: '2003-01-18', height: 175, weight: 68, preferredFoot: 'Right', club: 'Cagliari', clubLeague: 'Serie A', marketValue: 3000000, caps: 5, goals: 0 },
      { firstName: 'Ernest', lastName: 'Nuamah', jerseyNumber: 25, position: 'RW', dateOfBirth: '2003-11-01', height: 173, weight: 65, preferredFoot: 'Right', club: 'Lyon', clubLeague: 'Ligue 1', marketValue: 15000000, caps: 10, goals: 1 },
      { firstName: 'Ransford-Yeboah', lastName: 'Königsdörffer', jerseyNumber: 26, position: 'ST', dateOfBirth: '2001-10-13', height: 180, weight: 74, preferredFoot: 'Right', club: 'Hamburg', clubLeague: '2. Bundesliga', marketValue: 4000000, caps: 5, goals: 0 },
    ],
  },

  // ========== EGYPT ==========
  {
    name: 'Egypt',
    fifaCode: 'EGY',
    players: [
      { firstName: 'Mohamed', lastName: 'El-Shenawy', jerseyNumber: 1, position: 'GK', dateOfBirth: '1988-12-18', height: 191, weight: 86, preferredFoot: 'Right', club: 'Al-Ahly', clubLeague: 'Egyptian Premier League', marketValue: 1500000, caps: 100, goals: 0 },
      { firstName: 'Ahmed', lastName: 'Fatouh', jerseyNumber: 2, position: 'LB', dateOfBirth: '1992-03-05', height: 175, weight: 70, preferredFoot: 'Left', club: 'Al-Ahly', clubLeague: 'Egyptian Premier League', marketValue: 1000000, caps: 40, goals: 0 },
      { firstName: 'Ahmed', lastName: 'Hegazi', jerseyNumber: 3, position: 'CB', dateOfBirth: '1991-01-25', height: 192, weight: 84, preferredFoot: 'Right', club: 'Al-Ittihad', clubLeague: 'Saudi Pro League', marketValue: 3000000, caps: 70, goals: 4 },
      { firstName: 'Omar', lastName: 'Gaber', jerseyNumber: 4, position: 'RB', dateOfBirth: '1992-02-30', height: 180, weight: 75, preferredFoot: 'Right', club: 'Pyramids FC', clubLeague: 'Egyptian Premier League', marketValue: 1500000, caps: 45, goals: 3 },
      { firstName: 'Ali', lastName: 'Gabr', jerseyNumber: 5, position: 'CB', dateOfBirth: '1989-01-10', height: 191, weight: 82, preferredFoot: 'Right', club: 'Pyramids FC', clubLeague: 'Egyptian Premier League', marketValue: 500000, caps: 35, goals: 2 },
      { firstName: 'Tarek', lastName: 'Hamed', jerseyNumber: 6, position: 'CDM', dateOfBirth: '1988-10-24', height: 185, weight: 77, preferredFoot: 'Right', club: 'Zamalek', clubLeague: 'Egyptian Premier League', marketValue: 800000, caps: 60, goals: 1 },
      { firstName: 'Trezeguet', lastName: '', commonName: 'Trezeguet', jerseyNumber: 7, position: 'RW', dateOfBirth: '1994-10-01', height: 177, weight: 73, preferredFoot: 'Left', club: 'Trabzonspor', clubLeague: 'Super Lig', marketValue: 5000000, caps: 60, goals: 11 },
      { firstName: 'Emam', lastName: 'Ashour', jerseyNumber: 8, position: 'CM', dateOfBirth: '1998-02-10', height: 182, weight: 75, preferredFoot: 'Right', club: 'Al-Ahly', clubLeague: 'Egyptian Premier League', marketValue: 3500000, caps: 20, goals: 1 },
      { firstName: 'Marwan', lastName: 'Mohsen', jerseyNumber: 9, position: 'ST', dateOfBirth: '1989-08-26', height: 181, weight: 76, preferredFoot: 'Right', club: 'Al-Ahly', clubLeague: 'Egyptian Premier League', marketValue: 500000, caps: 45, goals: 10 },
      { firstName: 'Mohamed', lastName: 'Salah', jerseyNumber: 10, position: 'RW', dateOfBirth: '1992-06-15', height: 175, weight: 71, preferredFoot: 'Left', club: 'Liverpool', clubLeague: 'Premier League', marketValue: 100000000, caps: 100, goals: 55 },
      { firstName: 'Mostafa', lastName: 'Mohamed', jerseyNumber: 11, position: 'ST', dateOfBirth: '1997-11-28', height: 187, weight: 83, preferredFoot: 'Right', club: 'Nantes', clubLeague: 'Ligue 1', marketValue: 12000000, caps: 35, goals: 10 },
      { firstName: 'Mohamed', lastName: 'Awad', jerseyNumber: 12, position: 'GK', dateOfBirth: '1988-01-31', height: 193, weight: 88, preferredFoot: 'Right', club: 'Zamalek', clubLeague: 'Egyptian Premier League', marketValue: 500000, caps: 15, goals: 0 },
      { firstName: 'Ahmed', lastName: 'El-Mohamady', jerseyNumber: 13, position: 'RB', dateOfBirth: '1987-09-09', height: 182, weight: 76, preferredFoot: 'Right', club: 'Al-Ittihad Alexandria', clubLeague: 'Egyptian Premier League', marketValue: 300000, caps: 95, goals: 1 },
      { firstName: 'Mohamed', lastName: 'Hany', jerseyNumber: 14, position: 'RB', dateOfBirth: '1990-11-26', height: 182, weight: 77, preferredFoot: 'Right', club: 'Al-Ahly', clubLeague: 'Egyptian Premier League', marketValue: 1000000, caps: 25, goals: 0 },
      { firstName: 'Mahmoud', lastName: 'Hamdy', commonName: 'El-Wensh', jerseyNumber: 15, position: 'CB', dateOfBirth: '1997-12-09', height: 186, weight: 81, preferredFoot: 'Right', club: 'Zamalek', clubLeague: 'Egyptian Premier League', marketValue: 2000000, caps: 20, goals: 1 },
      { firstName: 'Afsha', lastName: '', commonName: 'Afsha', jerseyNumber: 16, position: 'CAM', dateOfBirth: '1996-02-16', height: 178, weight: 73, preferredFoot: 'Right', club: 'Al-Ahly', clubLeague: 'Egyptian Premier League', marketValue: 3000000, caps: 25, goals: 4 },
      { firstName: 'Mohamed', lastName: 'Elneny', jerseyNumber: 17, position: 'CM', dateOfBirth: '1992-07-11', height: 180, weight: 75, preferredFoot: 'Right', club: 'Arsenal', clubLeague: 'Premier League', marketValue: 5000000, caps: 95, goals: 3 },
      { firstName: 'Ahmed', lastName: 'Sayed', commonName: 'Zizo', jerseyNumber: 18, position: 'RW', dateOfBirth: '1996-03-11', height: 176, weight: 73, preferredFoot: 'Right', club: 'Zamalek', clubLeague: 'Egyptian Premier League', marketValue: 4000000, caps: 30, goals: 5 },
      { firstName: 'Abdallah', lastName: 'El-Said', jerseyNumber: 19, position: 'CAM', dateOfBirth: '1985-10-20', height: 178, weight: 74, preferredFoot: 'Right', club: 'Pyramids FC', clubLeague: 'Egyptian Premier League', marketValue: 400000, caps: 50, goals: 6 },
      { firstName: 'Omar', lastName: 'Marmoush', jerseyNumber: 20, position: 'LW', dateOfBirth: '1999-02-07', height: 180, weight: 73, preferredFoot: 'Right', club: 'Eintracht Frankfurt', clubLeague: 'Bundesliga', marketValue: 40000000, caps: 25, goals: 5 },
      { firstName: 'Ayman', lastName: 'Ashraf', jerseyNumber: 21, position: 'RB', dateOfBirth: '1991-05-26', height: 178, weight: 75, preferredFoot: 'Right', club: 'Al-Ahly', clubLeague: 'Egyptian Premier League', marketValue: 1000000, caps: 25, goals: 0 },
      { firstName: 'Ahmed', lastName: 'Sobhi', jerseyNumber: 22, position: 'GK', dateOfBirth: '1991-06-22', height: 191, weight: 83, preferredFoot: 'Right', club: 'Al-Ahly', clubLeague: 'Egyptian Premier League', marketValue: 500000, caps: 5, goals: 0 },
      { firstName: 'Ramadan', lastName: 'Sobhi', jerseyNumber: 23, position: 'LW', dateOfBirth: '1997-01-23', height: 175, weight: 69, preferredFoot: 'Right', club: 'Pyramids FC', clubLeague: 'Egyptian Premier League', marketValue: 3000000, caps: 35, goals: 5 },
      { firstName: 'Mahmoud', lastName: 'Trezeguet', jerseyNumber: 24, position: 'LW', dateOfBirth: '1994-10-01', height: 177, weight: 73, preferredFoot: 'Left', club: 'Trabzonspor', clubLeague: 'Super Lig', marketValue: 5000000, caps: 60, goals: 11 },
      { firstName: 'Karim', lastName: 'Hafez', jerseyNumber: 25, position: 'LB', dateOfBirth: '1995-02-07', height: 176, weight: 72, preferredFoot: 'Left', club: 'Ittihad El Shorta', clubLeague: 'Egyptian Premier League', marketValue: 500000, caps: 10, goals: 0 },
      { firstName: 'Ibrahim', lastName: 'Adel', jerseyNumber: 26, position: 'RW', dateOfBirth: '2001-03-05', height: 178, weight: 70, preferredFoot: 'Right', club: 'Al-Ahly', clubLeague: 'Egyptian Premier League', marketValue: 3000000, caps: 15, goals: 2 },
    ],
  },

  // ========== IRAN ==========
  {
    name: 'Iran',
    fifaCode: 'IRN',
    players: [
      { firstName: 'Alireza', lastName: 'Beiranvand', jerseyNumber: 1, position: 'GK', dateOfBirth: '1992-09-21', height: 195, weight: 88, preferredFoot: 'Right', club: 'Persepolis', clubLeague: 'Persian Gulf Pro League', marketValue: 2000000, caps: 70, goals: 0 },
      { firstName: 'Sadegh', lastName: 'Moharrami', jerseyNumber: 2, position: 'RB', dateOfBirth: '1996-02-01', height: 180, weight: 75, preferredFoot: 'Right', club: 'Dinamo Zagreb', clubLeague: 'HNL', marketValue: 5000000, caps: 25, goals: 0 },
      { firstName: 'Ehsan', lastName: 'Hajsafi', jerseyNumber: 3, position: 'LB', dateOfBirth: '1990-02-25', height: 178, weight: 73, preferredFoot: 'Left', club: 'AEK Athens', clubLeague: 'Super League Greece', marketValue: 1500000, caps: 130, goals: 11 },
      { firstName: 'Shoja', lastName: 'Khalilzadeh', jerseyNumber: 4, position: 'CB', dateOfBirth: '1989-09-03', height: 182, weight: 78, preferredFoot: 'Right', club: 'Al-Ahli Dubai', clubLeague: 'UAE Pro League', marketValue: 1500000, caps: 50, goals: 1 },
      { firstName: 'Milad', lastName: 'Mohammadi', jerseyNumber: 5, position: 'LB', dateOfBirth: '1993-09-29', height: 181, weight: 75, preferredFoot: 'Left', club: 'AEK Athens', clubLeague: 'Super League Greece', marketValue: 3000000, caps: 60, goals: 2 },
      { firstName: 'Saeid', lastName: 'Ezatolahi', jerseyNumber: 6, position: 'CDM', dateOfBirth: '1996-10-01', height: 185, weight: 82, preferredFoot: 'Right', club: 'Vejle', clubLeague: 'Danish Superliga', marketValue: 2000000, caps: 55, goals: 2 },
      { firstName: 'Alireza', lastName: 'Jahanbakhsh', jerseyNumber: 7, position: 'RW', dateOfBirth: '1993-08-11', height: 180, weight: 75, preferredFoot: 'Left', club: 'Feyenoord', clubLeague: 'Eredivisie', marketValue: 5000000, caps: 80, goals: 15 },
      { firstName: 'Morteza', lastName: 'Pouraliganji', jerseyNumber: 8, position: 'CB', dateOfBirth: '1992-04-19', height: 185, weight: 78, preferredFoot: 'Right', club: 'Persepolis', clubLeague: 'Persian Gulf Pro League', marketValue: 1000000, caps: 70, goals: 2 },
      { firstName: 'Mehdi', lastName: 'Taremi', jerseyNumber: 9, position: 'ST', dateOfBirth: '1992-07-18', height: 187, weight: 82, preferredFoot: 'Right', club: 'Inter Milan', clubLeague: 'Serie A', marketValue: 25000000, caps: 75, goals: 45 },
      { firstName: 'Karim', lastName: 'Ansarifard', jerseyNumber: 10, position: 'ST', dateOfBirth: '1990-04-03', height: 185, weight: 82, preferredFoot: 'Right', club: 'Omonia Nicosia', clubLeague: 'Cypriot First Division', marketValue: 1500000, caps: 95, goals: 30 },
      { firstName: 'Vahid', lastName: 'Amiri', jerseyNumber: 11, position: 'RW', dateOfBirth: '1988-04-10', height: 181, weight: 75, preferredFoot: 'Right', club: 'Persepolis', clubLeague: 'Persian Gulf Pro League', marketValue: 800000, caps: 80, goals: 7 },
      { firstName: 'Hossein', lastName: 'Hosseini', jerseyNumber: 12, position: 'GK', dateOfBirth: '1992-06-18', height: 192, weight: 84, preferredFoot: 'Right', club: 'Esteghlal', clubLeague: 'Persian Gulf Pro League', marketValue: 1200000, caps: 20, goals: 0 },
      { firstName: 'Majid', lastName: 'Hosseini', jerseyNumber: 13, position: 'CB', dateOfBirth: '1996-06-20', height: 190, weight: 82, preferredFoot: 'Right', club: 'Kayserispor', clubLeague: 'Super Lig', marketValue: 3000000, caps: 45, goals: 2 },
      { firstName: 'Saman', lastName: 'Ghoddos', jerseyNumber: 14, position: 'CAM', dateOfBirth: '1993-09-06', height: 182, weight: 77, preferredFoot: 'Right', club: 'Brentford', clubLeague: 'Premier League', marketValue: 5000000, caps: 40, goals: 5 },
      { firstName: 'Rouzbeh', lastName: 'Cheshmi', jerseyNumber: 15, position: 'CB', dateOfBirth: '1993-07-24', height: 187, weight: 82, preferredFoot: 'Right', club: 'Esteghlal', clubLeague: 'Persian Gulf Pro League', marketValue: 1500000, caps: 35, goals: 2 },
      { firstName: 'Mehdi', lastName: 'Torabi', jerseyNumber: 16, position: 'CM', dateOfBirth: '1994-09-10', height: 180, weight: 76, preferredFoot: 'Left', club: 'Persepolis', clubLeague: 'Persian Gulf Pro League', marketValue: 1500000, caps: 35, goals: 3 },
      { firstName: 'Ali', lastName: 'Gholizadeh', jerseyNumber: 17, position: 'LW', dateOfBirth: '1996-03-10', height: 172, weight: 66, preferredFoot: 'Right', club: 'Charleroi', clubLeague: 'Belgian First Division', marketValue: 4000000, caps: 40, goals: 6 },
      { firstName: 'Ali', lastName: 'Karimi', jerseyNumber: 18, position: 'CM', dateOfBirth: '1994-01-16', height: 175, weight: 68, preferredFoot: 'Right', club: 'Kayserispor', clubLeague: 'Super Lig', marketValue: 3500000, caps: 30, goals: 1 },
      { firstName: 'Sardar', lastName: 'Azmoun', jerseyNumber: 19, position: 'ST', dateOfBirth: '1995-01-01', height: 186, weight: 76, preferredFoot: 'Right', club: 'Roma', clubLeague: 'Serie A', marketValue: 15000000, caps: 75, goals: 50 },
      { firstName: 'Ahmad', lastName: 'Nourollahi', jerseyNumber: 20, position: 'CM', dateOfBirth: '1993-08-01', height: 183, weight: 77, preferredFoot: 'Right', club: 'Shabab Al-Ahli', clubLeague: 'UAE Pro League', marketValue: 2500000, caps: 55, goals: 4 },
      { firstName: 'Omid', lastName: 'Noorafkan', jerseyNumber: 21, position: 'LB', dateOfBirth: '1997-04-09', height: 180, weight: 74, preferredFoot: 'Left', club: 'Esteghlal', clubLeague: 'Persian Gulf Pro League', marketValue: 2000000, caps: 20, goals: 0 },
      { firstName: 'Amir', lastName: 'Abedzadeh', jerseyNumber: 22, position: 'GK', dateOfBirth: '1993-04-27', height: 188, weight: 81, preferredFoot: 'Right', club: 'Ponferradina', clubLeague: 'La Liga 2', marketValue: 1000000, caps: 15, goals: 0 },
      { firstName: 'Ramin', lastName: 'Rezaeian', jerseyNumber: 23, position: 'RB', dateOfBirth: '1990-03-21', height: 181, weight: 78, preferredFoot: 'Right', club: 'Sepahan', clubLeague: 'Persian Gulf Pro League', marketValue: 800000, caps: 50, goals: 1 },
      { firstName: 'Mohammad', lastName: 'Mohebi', jerseyNumber: 24, position: 'RB', dateOfBirth: '1998-03-17', height: 175, weight: 71, preferredFoot: 'Right', club: 'Esteghlal', clubLeague: 'Persian Gulf Pro League', marketValue: 1500000, caps: 15, goals: 0 },
      { firstName: 'Shahab', lastName: 'Zahedi', jerseyNumber: 25, position: 'ST', dateOfBirth: '1996-07-08', height: 184, weight: 78, preferredFoot: 'Right', club: 'Zorya Luhansk', clubLeague: 'Ukrainian Premier League', marketValue: 2000000, caps: 20, goals: 4 },
      { firstName: 'Allahyar', lastName: 'Sayyadmanesh', jerseyNumber: 26, position: 'LW', dateOfBirth: '2001-06-29', height: 178, weight: 68, preferredFoot: 'Right', club: 'Hull City', clubLeague: 'Championship', marketValue: 4000000, caps: 10, goals: 1 },
    ],
  },

  // ========== SAUDI ARABIA ==========
  {
    name: 'Saudi Arabia',
    fifaCode: 'KSA',
    players: [
      { firstName: 'Mohammed', lastName: 'Al-Owais', jerseyNumber: 1, position: 'GK', dateOfBirth: '1991-10-10', height: 185, weight: 78, preferredFoot: 'Right', club: 'Al-Hilal', clubLeague: 'Saudi Pro League', marketValue: 3500000, caps: 60, goals: 0 },
      { firstName: 'Sultan', lastName: 'Al-Ghannam', jerseyNumber: 2, position: 'RB', dateOfBirth: '1994-05-06', height: 179, weight: 74, preferredFoot: 'Right', club: 'Al-Nassr', clubLeague: 'Saudi Pro League', marketValue: 2000000, caps: 55, goals: 2 },
      { firstName: 'Abdullah', lastName: 'Madu', jerseyNumber: 3, position: 'CB', dateOfBirth: '1993-06-13', height: 186, weight: 82, preferredFoot: 'Right', club: 'Al-Nassr', clubLeague: 'Saudi Pro League', marketValue: 2500000, caps: 50, goals: 1 },
      { firstName: 'Abdulelah', lastName: 'Al-Amri', jerseyNumber: 4, position: 'CB', dateOfBirth: '1997-01-15', height: 183, weight: 78, preferredFoot: 'Right', club: 'Al-Nassr', clubLeague: 'Saudi Pro League', marketValue: 4000000, caps: 30, goals: 0 },
      { firstName: 'Ali', lastName: 'Al-Bulaihi', jerseyNumber: 5, position: 'CB', dateOfBirth: '1989-11-21', height: 182, weight: 80, preferredFoot: 'Left', club: 'Al-Hilal', clubLeague: 'Saudi Pro League', marketValue: 1500000, caps: 60, goals: 2 },
      { firstName: 'Salman', lastName: 'Al-Faraj', jerseyNumber: 6, position: 'CM', dateOfBirth: '1989-08-01', height: 180, weight: 72, preferredFoot: 'Left', club: 'Al-Hilal', clubLeague: 'Saudi Pro League', marketValue: 2500000, caps: 80, goals: 8 },
      { firstName: 'Salman', lastName: 'Al-Dawsari', jerseyNumber: 7, position: 'LW', dateOfBirth: '1991-08-19', height: 170, weight: 68, preferredFoot: 'Right', club: 'Al-Hilal', clubLeague: 'Saudi Pro League', marketValue: 4000000, caps: 75, goals: 20 },
      { firstName: 'Abdulrahman', lastName: 'Ghareeb', jerseyNumber: 8, position: 'LW', dateOfBirth: '1997-03-31', height: 172, weight: 65, preferredFoot: 'Right', club: 'Al-Ahli', clubLeague: 'Saudi Pro League', marketValue: 3000000, caps: 25, goals: 2 },
      { firstName: 'Firas', lastName: 'Al-Buraikan', jerseyNumber: 9, position: 'ST', dateOfBirth: '2000-05-14', height: 179, weight: 74, preferredFoot: 'Right', club: 'Al-Nassr', clubLeague: 'Saudi Pro League', marketValue: 6000000, caps: 25, goals: 10 },
      { firstName: 'Salem', lastName: 'Al-Dawsari', jerseyNumber: 10, position: 'LW', dateOfBirth: '1991-08-19', height: 170, weight: 68, preferredFoot: 'Right', club: 'Al-Hilal', clubLeague: 'Saudi Pro League', marketValue: 4000000, caps: 75, goals: 20 },
      { firstName: 'Hatan', lastName: 'Bahbri', jerseyNumber: 11, position: 'RW', dateOfBirth: '1992-11-16', height: 175, weight: 70, preferredFoot: 'Left', club: 'Al-Shabab', clubLeague: 'Saudi Pro League', marketValue: 2000000, caps: 45, goals: 5 },
      { firstName: 'Fawaz', lastName: 'Al-Qarni', jerseyNumber: 12, position: 'GK', dateOfBirth: '1992-12-17', height: 188, weight: 80, preferredFoot: 'Right', club: 'Al-Shabab', clubLeague: 'Saudi Pro League', marketValue: 1000000, caps: 15, goals: 0 },
      { firstName: 'Yasser', lastName: 'Al-Shahrani', jerseyNumber: 13, position: 'LB', dateOfBirth: '1992-05-25', height: 172, weight: 66, preferredFoot: 'Left', club: 'Al-Hilal', clubLeague: 'Saudi Pro League', marketValue: 3000000, caps: 75, goals: 5 },
      { firstName: 'Abdullah', lastName: 'Otayf', jerseyNumber: 14, position: 'CM', dateOfBirth: '1992-08-03', height: 172, weight: 68, preferredFoot: 'Right', club: 'Al-Hilal', clubLeague: 'Saudi Pro League', marketValue: 2000000, caps: 50, goals: 3 },
      { firstName: 'Nasser', lastName: 'Al-Dawsari', jerseyNumber: 15, position: 'CM', dateOfBirth: '1998-12-19', height: 180, weight: 75, preferredFoot: 'Right', club: 'Al-Hilal', clubLeague: 'Saudi Pro League', marketValue: 3500000, caps: 20, goals: 1 },
      { firstName: 'Saud', lastName: 'Abdulhamid', jerseyNumber: 16, position: 'RB', dateOfBirth: '1999-07-18', height: 178, weight: 72, preferredFoot: 'Right', club: 'Roma', clubLeague: 'Serie A', marketValue: 8000000, caps: 25, goals: 1 },
      { firstName: 'Hassan', lastName: 'Al-Tambakti', jerseyNumber: 17, position: 'CB', dateOfBirth: '1999-02-09', height: 186, weight: 80, preferredFoot: 'Right', club: 'Al-Shabab', clubLeague: 'Saudi Pro League', marketValue: 4000000, caps: 20, goals: 0 },
      { firstName: 'Nawaf', lastName: 'Al-Abed', jerseyNumber: 18, position: 'CAM', dateOfBirth: '1990-01-26', height: 174, weight: 68, preferredFoot: 'Right', club: 'Al-Shabab', clubLeague: 'Saudi Pro League', marketValue: 1500000, caps: 60, goals: 8 },
      { firstName: 'Haitham', lastName: 'Asiri', jerseyNumber: 19, position: 'LW', dateOfBirth: '2001-05-11', height: 175, weight: 70, preferredFoot: 'Right', club: 'Al-Ahli', clubLeague: 'Saudi Pro League', marketValue: 3000000, caps: 15, goals: 3 },
      { firstName: 'Abdulrahman', lastName: 'Al-Obaid', jerseyNumber: 20, position: 'CB', dateOfBirth: '1998-09-04', height: 184, weight: 79, preferredFoot: 'Right', club: 'Al-Shabab', clubLeague: 'Saudi Pro League', marketValue: 2500000, caps: 15, goals: 0 },
      { firstName: 'Mohammed', lastName: 'Al-Rubaie', jerseyNumber: 21, position: 'GK', dateOfBirth: '1997-07-03', height: 190, weight: 82, preferredFoot: 'Right', club: 'Al-Ahli', clubLeague: 'Saudi Pro League', marketValue: 1500000, caps: 5, goals: 0 },
      { firstName: 'Mohammed', lastName: 'Kanno', jerseyNumber: 22, position: 'CM', dateOfBirth: '1994-09-22', height: 182, weight: 77, preferredFoot: 'Right', club: 'Al-Hilal', clubLeague: 'Saudi Pro League', marketValue: 3500000, caps: 55, goals: 4 },
      { firstName: 'Ayman', lastName: 'Yahya', jerseyNumber: 23, position: 'ST', dateOfBirth: '2002-01-28', height: 180, weight: 75, preferredFoot: 'Right', club: 'Al-Nassr', clubLeague: 'Saudi Pro League', marketValue: 4000000, caps: 10, goals: 3 },
      { firstName: 'Ali', lastName: 'Lajami', jerseyNumber: 24, position: 'CB', dateOfBirth: '1999-04-07', height: 188, weight: 82, preferredFoot: 'Right', club: 'Al-Ahli', clubLeague: 'Saudi Pro League', marketValue: 3000000, caps: 15, goals: 0 },
      { firstName: 'Khalid', lastName: 'Al-Ghannam', jerseyNumber: 25, position: 'RW', dateOfBirth: '2002-06-05', height: 175, weight: 68, preferredFoot: 'Right', club: 'Al-Nassr', clubLeague: 'Saudi Pro League', marketValue: 2500000, caps: 5, goals: 0 },
      { firstName: 'Musab', lastName: 'Al-Juwayr', jerseyNumber: 26, position: 'ST', dateOfBirth: '2003-08-10', height: 182, weight: 76, preferredFoot: 'Right', club: 'Al-Hilal', clubLeague: 'Saudi Pro League', marketValue: 2000000, caps: 5, goals: 1 },
    ],
  },

  // ========== COSTA RICA ==========
  {
    name: 'Costa Rica',
    fifaCode: 'CRC',
    players: [
      { firstName: 'Keylor', lastName: 'Navas', jerseyNumber: 1, position: 'GK', dateOfBirth: '1986-12-15', height: 185, weight: 80, preferredFoot: 'Right', club: 'Nottingham Forest', clubLeague: 'Premier League', marketValue: 2000000, caps: 115, goals: 0 },
      { firstName: 'Bryan', lastName: 'Oviedo', jerseyNumber: 2, position: 'LB', dateOfBirth: '1990-02-18', height: 174, weight: 68, preferredFoot: 'Left', club: 'Real Salt Lake', clubLeague: 'MLS', marketValue: 1000000, caps: 65, goals: 4 },
      { firstName: 'Juan Pablo', lastName: 'Vargas', jerseyNumber: 3, position: 'CB', dateOfBirth: '1995-07-07', height: 192, weight: 82, preferredFoot: 'Left', club: 'Millonarios', clubLeague: 'Liga Colombia', marketValue: 1500000, caps: 30, goals: 3 },
      { firstName: 'Keysher', lastName: 'Fuller', jerseyNumber: 4, position: 'RB', dateOfBirth: '1994-07-12', height: 186, weight: 78, preferredFoot: 'Right', club: 'Herediano', clubLeague: 'Liga Promérica', marketValue: 1000000, caps: 40, goals: 3 },
      { firstName: 'Celso', lastName: 'Borges', jerseyNumber: 5, position: 'CM', dateOfBirth: '1988-05-27', height: 186, weight: 77, preferredFoot: 'Right', club: 'Alajuelense', clubLeague: 'Liga Promérica', marketValue: 500000, caps: 160, goals: 25 },
      { firstName: 'Óscar', lastName: 'Duarte', jerseyNumber: 6, position: 'CB', dateOfBirth: '1989-06-03', height: 183, weight: 78, preferredFoot: 'Right', club: 'Al-Wehda', clubLeague: 'Saudi Pro League', marketValue: 1000000, caps: 75, goals: 3 },
      { firstName: 'Anthony', lastName: 'Hernández', jerseyNumber: 7, position: 'RW', dateOfBirth: '2000-04-04', height: 172, weight: 66, preferredFoot: 'Right', club: 'Pumas UNAM', clubLeague: 'Liga MX', marketValue: 2500000, caps: 15, goals: 1 },
      { firstName: 'Bryan', lastName: 'Ruiz', jerseyNumber: 8, position: 'CAM', dateOfBirth: '1985-08-18', height: 187, weight: 79, preferredFoot: 'Left', club: 'Free Agent', clubLeague: 'N/A', marketValue: 200000, caps: 145, goals: 29 },
      { firstName: 'Joel', lastName: 'Campbell', jerseyNumber: 9, position: 'RW', dateOfBirth: '1992-06-26', height: 178, weight: 72, preferredFoot: 'Left', club: 'Alajuelense', clubLeague: 'Liga Promérica', marketValue: 1000000, caps: 130, goals: 25 },
      { firstName: 'Brandon', lastName: 'Aguilera', jerseyNumber: 10, position: 'CAM', dateOfBirth: '2003-10-03', height: 173, weight: 66, preferredFoot: 'Right', club: 'Nottingham Forest', clubLeague: 'Premier League', marketValue: 5000000, caps: 15, goals: 1 },
      { firstName: 'Johan', lastName: 'Venegas', jerseyNumber: 11, position: 'LW', dateOfBirth: '1988-11-27', height: 172, weight: 68, preferredFoot: 'Right', club: 'Alajuelense', clubLeague: 'Liga Promérica', marketValue: 400000, caps: 80, goals: 18 },
      { firstName: 'Leonel', lastName: 'Moreira', jerseyNumber: 12, position: 'GK', dateOfBirth: '1990-01-01', height: 183, weight: 76, preferredFoot: 'Right', club: 'Alajuelense', clubLeague: 'Liga Promérica', marketValue: 500000, caps: 25, goals: 0 },
      { firstName: 'Francisco', lastName: 'Calvo', jerseyNumber: 13, position: 'CB', dateOfBirth: '1992-07-08', height: 180, weight: 76, preferredFoot: 'Left', club: 'San Jose Earthquakes', clubLeague: 'MLS', marketValue: 1500000, caps: 75, goals: 5 },
      { firstName: 'Manfred', lastName: 'Ugalde', jerseyNumber: 14, position: 'ST', dateOfBirth: '2002-02-09', height: 175, weight: 70, preferredFoot: 'Right', club: 'Spartak Moscow', clubLeague: 'Russian Premier League', marketValue: 8000000, caps: 30, goals: 12 },
      { firstName: 'Gerson', lastName: 'Torres', jerseyNumber: 15, position: 'CM', dateOfBirth: '1997-08-28', height: 180, weight: 75, preferredFoot: 'Right', club: 'Herediano', clubLeague: 'Liga Promérica', marketValue: 2000000, caps: 25, goals: 2 },
      { firstName: 'Youstin', lastName: 'Salas', jerseyNumber: 16, position: 'CM', dateOfBirth: '1996-01-04', height: 175, weight: 70, preferredFoot: 'Right', club: 'Saprissa', clubLeague: 'Liga Promérica', marketValue: 1000000, caps: 20, goals: 1 },
      { firstName: 'Alonso', lastName: 'Martínez', jerseyNumber: 17, position: 'LW', dateOfBirth: '2000-02-17', height: 180, weight: 72, preferredFoot: 'Right', club: 'New York City FC', clubLeague: 'MLS', marketValue: 4000000, caps: 20, goals: 4 },
      { firstName: 'Patrick', lastName: 'Sequeira', jerseyNumber: 18, position: 'GK', dateOfBirth: '2003-07-16', height: 187, weight: 78, preferredFoot: 'Right', club: 'Ibiza', clubLeague: 'La Liga 2', marketValue: 2000000, caps: 5, goals: 0 },
      { firstName: 'Kendall', lastName: 'Waston', jerseyNumber: 19, position: 'CB', dateOfBirth: '1988-01-01', height: 196, weight: 90, preferredFoot: 'Right', club: 'Saprissa', clubLeague: 'Liga Promérica', marketValue: 500000, caps: 60, goals: 7 },
      { firstName: 'Daniel', lastName: 'Chacón', jerseyNumber: 20, position: 'RW', dateOfBirth: '2004-04-09', height: 178, weight: 70, preferredFoot: 'Right', club: 'Colorado Rapids', clubLeague: 'MLS', marketValue: 3500000, caps: 10, goals: 1 },
      { firstName: 'Carlos', lastName: 'Martínez', jerseyNumber: 21, position: 'CB', dateOfBirth: '1999-02-27', height: 182, weight: 78, preferredFoot: 'Right', club: 'San Carlos', clubLeague: 'Liga Promérica', marketValue: 800000, caps: 10, goals: 0 },
      { firstName: 'Jewison', lastName: 'Bennette', jerseyNumber: 22, position: 'LW', dateOfBirth: '2004-06-15', height: 171, weight: 63, preferredFoot: 'Right', club: 'Sunderland', clubLeague: 'Championship', marketValue: 4000000, caps: 20, goals: 2 },
      { firstName: 'Yeltsin', lastName: 'Tejeda', jerseyNumber: 23, position: 'CDM', dateOfBirth: '1992-03-17', height: 180, weight: 75, preferredFoot: 'Right', club: 'Herediano', clubLeague: 'Liga Promérica', marketValue: 800000, caps: 70, goals: 2 },
      { firstName: 'Aaron', lastName: 'Suárez', jerseyNumber: 24, position: 'RW', dateOfBirth: '2001-01-10', height: 175, weight: 70, preferredFoot: 'Left', club: 'Herediano', clubLeague: 'Liga Promérica', marketValue: 1500000, caps: 10, goals: 1 },
      { firstName: 'Haxzel', lastName: 'Quirós', jerseyNumber: 25, position: 'LB', dateOfBirth: '1998-04-18', height: 175, weight: 70, preferredFoot: 'Left', club: 'Real Sociedad B', clubLeague: 'La Liga 2', marketValue: 2000000, caps: 15, goals: 0 },
      { firstName: 'Andy', lastName: 'Rojas', jerseyNumber: 26, position: 'ST', dateOfBirth: '2002-03-22', height: 180, weight: 74, preferredFoot: 'Right', club: 'Saprissa', clubLeague: 'Liga Promérica', marketValue: 1500000, caps: 5, goals: 0 },
    ],
  },

  // ========== NEW ZEALAND ==========
  {
    name: 'New Zealand',
    fifaCode: 'NZL',
    players: [
      { firstName: 'Stefan', lastName: 'Marinovic', jerseyNumber: 1, position: 'GK', dateOfBirth: '1991-03-07', height: 192, weight: 85, preferredFoot: 'Right', club: 'Wellington Phoenix', clubLeague: 'A-League', marketValue: 500000, caps: 30, goals: 0 },
      { firstName: 'Bill', lastName: 'Tuiloma', jerseyNumber: 2, position: 'CB', dateOfBirth: '1995-03-27', height: 191, weight: 82, preferredFoot: 'Right', club: 'Huracán', clubLeague: 'Liga Argentina', marketValue: 1500000, caps: 40, goals: 3 },
      { firstName: 'Nando', lastName: 'Pijnaker', jerseyNumber: 3, position: 'CB', dateOfBirth: '1995-05-18', height: 193, weight: 88, preferredFoot: 'Right', club: 'Portland Timbers', clubLeague: 'MLS', marketValue: 1000000, caps: 20, goals: 0 },
      { firstName: 'Michael', lastName: 'Boxall', jerseyNumber: 4, position: 'CB', dateOfBirth: '1988-08-18', height: 188, weight: 82, preferredFoot: 'Right', club: 'Minnesota United', clubLeague: 'MLS', marketValue: 500000, caps: 45, goals: 2 },
      { firstName: 'Tim', lastName: 'Payne', jerseyNumber: 5, position: 'LB', dateOfBirth: '1994-10-12', height: 181, weight: 75, preferredFoot: 'Left', club: 'Wellington Phoenix', clubLeague: 'A-League', marketValue: 400000, caps: 15, goals: 0 },
      { firstName: 'Joe', lastName: 'Bell', jerseyNumber: 6, position: 'CM', dateOfBirth: '1999-02-19', height: 180, weight: 75, preferredFoot: 'Right', club: 'Standard Liège', clubLeague: 'Belgian First Division', marketValue: 3000000, caps: 25, goals: 2 },
      { firstName: 'Elijah', lastName: 'Just', jerseyNumber: 7, position: 'RW', dateOfBirth: '1998-04-16', height: 180, weight: 73, preferredFoot: 'Right', club: 'Wellington Phoenix', clubLeague: 'A-League', marketValue: 800000, caps: 15, goals: 2 },
      { firstName: 'Alex', lastName: 'Greive', jerseyNumber: 8, position: 'ST', dateOfBirth: '2000-04-11', height: 183, weight: 78, preferredFoot: 'Right', club: 'New York Red Bulls', clubLeague: 'MLS', marketValue: 2000000, caps: 10, goals: 3 },
      { firstName: 'Chris', lastName: 'Wood', jerseyNumber: 9, position: 'ST', dateOfBirth: '1991-12-07', height: 191, weight: 85, preferredFoot: 'Right', club: 'Nottingham Forest', clubLeague: 'Premier League', marketValue: 20000000, caps: 75, goals: 35 },
      { firstName: 'Marko', lastName: 'Stamenic', jerseyNumber: 10, position: 'CM', dateOfBirth: '2000-08-13', height: 183, weight: 77, preferredFoot: 'Right', club: 'Red Bull Salzburg', clubLeague: 'Austrian Bundesliga', marketValue: 5000000, caps: 20, goals: 2 },
      { firstName: 'Kosta', lastName: 'Barbarouses', jerseyNumber: 11, position: 'LW', dateOfBirth: '1990-02-19', height: 175, weight: 73, preferredFoot: 'Right', club: 'Wellington Phoenix', clubLeague: 'A-League', marketValue: 500000, caps: 50, goals: 9 },
      { firstName: 'Max', lastName: 'Crocombe', jerseyNumber: 12, position: 'GK', dateOfBirth: '1993-08-02', height: 188, weight: 80, preferredFoot: 'Right', club: 'Oxford United', clubLeague: 'Championship', marketValue: 500000, caps: 10, goals: 0 },
      { firstName: 'Storm', lastName: 'Roux', jerseyNumber: 13, position: 'RB', dateOfBirth: '1994-05-28', height: 177, weight: 71, preferredFoot: 'Right', club: 'Melbourne City', clubLeague: 'A-League', marketValue: 500000, caps: 25, goals: 1 },
      { firstName: 'Ryan', lastName: 'Thomas', jerseyNumber: 14, position: 'CM', dateOfBirth: '1994-12-20', height: 176, weight: 73, preferredFoot: 'Right', club: 'PSV Eindhoven', clubLeague: 'Eredivisie', marketValue: 3000000, caps: 25, goals: 2 },
      { firstName: 'Clayton', lastName: 'Lewis', jerseyNumber: 15, position: 'CM', dateOfBirth: '1997-10-05', height: 180, weight: 76, preferredFoot: 'Right', club: 'Wellington Phoenix', clubLeague: 'A-League', marketValue: 600000, caps: 20, goals: 0 },
      { firstName: 'Liberato', lastName: 'Cacace', jerseyNumber: 16, position: 'LB', dateOfBirth: '2000-09-27', height: 177, weight: 70, preferredFoot: 'Left', club: 'Empoli', clubLeague: 'Serie A', marketValue: 8000000, caps: 30, goals: 1 },
      { firstName: 'Sarpreet', lastName: 'Singh', jerseyNumber: 17, position: 'CAM', dateOfBirth: '1999-02-26', height: 180, weight: 73, preferredFoot: 'Left', club: 'Regensburg', clubLeague: '2. Bundesliga', marketValue: 2000000, caps: 15, goals: 1 },
      { firstName: 'Dane', lastName: 'Ingham', jerseyNumber: 18, position: 'RB', dateOfBirth: '1994-07-22', height: 180, weight: 75, preferredFoot: 'Right', club: 'Brisbane Roar', clubLeague: 'A-League', marketValue: 300000, caps: 20, goals: 0 },
      { firstName: 'Matthew', lastName: 'Garbett', jerseyNumber: 19, position: 'CM', dateOfBirth: '2002-02-02', height: 178, weight: 72, preferredFoot: 'Right', club: 'Napoli', clubLeague: 'Serie A', marketValue: 3000000, caps: 10, goals: 1 },
      { firstName: 'Andre', lastName: 'De Jong', jerseyNumber: 20, position: 'CB', dateOfBirth: '1990-01-18', height: 190, weight: 84, preferredFoot: 'Right', club: 'Phoenix Rising', clubLeague: 'USL Championship', marketValue: 200000, caps: 10, goals: 0 },
      { firstName: 'Oskar', lastName: 'van Hattum', jerseyNumber: 21, position: 'GK', dateOfBirth: '2001-06-14', height: 193, weight: 83, preferredFoot: 'Right', club: 'Wellington Phoenix', clubLeague: 'A-League', marketValue: 300000, caps: 5, goals: 0 },
      { firstName: 'Logan', lastName: 'Rogerson', jerseyNumber: 22, position: 'RW', dateOfBirth: '2003-05-27', height: 175, weight: 68, preferredFoot: 'Right', club: 'Wellington Phoenix', clubLeague: 'A-League', marketValue: 800000, caps: 5, goals: 0 },
      { firstName: 'Gianni', lastName: 'Stensness', jerseyNumber: 23, position: 'CB', dateOfBirth: '1999-03-21', height: 185, weight: 80, preferredFoot: 'Right', club: 'Viking', clubLeague: 'Eliteserien', marketValue: 2000000, caps: 15, goals: 0 },
      { firstName: 'Ben', lastName: 'Waine', jerseyNumber: 24, position: 'ST', dateOfBirth: '2001-04-24', height: 185, weight: 78, preferredFoot: 'Right', club: 'Plymouth Argyle', clubLeague: 'Championship', marketValue: 3000000, caps: 15, goals: 4 },
      { firstName: 'Jesse', lastName: 'Randall', jerseyNumber: 25, position: 'LW', dateOfBirth: '2002-09-18', height: 177, weight: 70, preferredFoot: 'Left', club: 'Vitesse', clubLeague: 'Eredivisie', marketValue: 1500000, caps: 5, goals: 1 },
      { firstName: 'Jay', lastName: 'Herdman', jerseyNumber: 26, position: 'CM', dateOfBirth: '2003-01-14', height: 175, weight: 68, preferredFoot: 'Right', club: 'New Zealand', clubLeague: 'Free Agent', marketValue: 500000, caps: 5, goals: 0 },
    ],
  },

  // ========== QATAR ==========
  {
    name: 'Qatar',
    fifaCode: 'QAT',
    players: [
      { firstName: 'Saad', lastName: 'Al-Sheeb', jerseyNumber: 1, position: 'GK', dateOfBirth: '1990-02-19', height: 185, weight: 80, preferredFoot: 'Right', club: 'Al-Sadd', clubLeague: 'Qatar Stars League', marketValue: 1500000, caps: 75, goals: 0 },
      { firstName: 'Pedro', lastName: 'Miguel', jerseyNumber: 2, position: 'RB', dateOfBirth: '1990-08-06', height: 175, weight: 68, preferredFoot: 'Right', club: 'Al-Sadd', clubLeague: 'Qatar Stars League', marketValue: 1500000, caps: 70, goals: 3 },
      { firstName: 'Abdelkarim', lastName: 'Hassan', jerseyNumber: 3, position: 'LB', dateOfBirth: '1993-08-28', height: 179, weight: 75, preferredFoot: 'Left', club: 'Al-Sadd', clubLeague: 'Qatar Stars League', marketValue: 2500000, caps: 100, goals: 6 },
      { firstName: 'Mohammed', lastName: 'Muntari', jerseyNumber: 4, position: 'ST', dateOfBirth: '1993-12-30', height: 182, weight: 78, preferredFoot: 'Right', club: 'Al-Duhail', clubLeague: 'Qatar Stars League', marketValue: 2000000, caps: 55, goals: 12 },
      { firstName: 'Tarek', lastName: 'Salman', jerseyNumber: 5, position: 'CB', dateOfBirth: '1997-12-05', height: 188, weight: 82, preferredFoot: 'Right', club: 'Al-Sadd', clubLeague: 'Qatar Stars League', marketValue: 2500000, caps: 45, goals: 2 },
      { firstName: 'Abdulaziz', lastName: 'Hatem', jerseyNumber: 6, position: 'CM', dateOfBirth: '1990-10-28', height: 175, weight: 72, preferredFoot: 'Right', club: 'Al-Rayyan', clubLeague: 'Qatar Stars League', marketValue: 1500000, caps: 75, goals: 8 },
      { firstName: 'Ahmed', lastName: 'Fatehi', jerseyNumber: 7, position: 'LW', dateOfBirth: '1993-04-14', height: 172, weight: 68, preferredFoot: 'Right', club: 'Al-Sadd', clubLeague: 'Qatar Stars League', marketValue: 1000000, caps: 35, goals: 3 },
      { firstName: 'Homam', lastName: 'Ahmed', jerseyNumber: 8, position: 'CB', dateOfBirth: '1999-08-25', height: 186, weight: 80, preferredFoot: 'Left', club: 'Al-Gharafa', clubLeague: 'Qatar Stars League', marketValue: 3000000, caps: 30, goals: 1 },
      { firstName: 'Almoez', lastName: 'Ali', jerseyNumber: 9, position: 'ST', dateOfBirth: '1996-08-19', height: 180, weight: 75, preferredFoot: 'Right', club: 'Al-Duhail', clubLeague: 'Qatar Stars League', marketValue: 4000000, caps: 85, goals: 50 },
      { firstName: 'Hassan', lastName: 'Al-Haydos', jerseyNumber: 10, position: 'CAM', dateOfBirth: '1990-12-11', height: 170, weight: 67, preferredFoot: 'Right', club: 'Al-Sadd', clubLeague: 'Qatar Stars League', marketValue: 1000000, caps: 180, goals: 40 },
      { firstName: 'Akram', lastName: 'Afif', jerseyNumber: 11, position: 'LW', dateOfBirth: '1996-11-18', height: 177, weight: 68, preferredFoot: 'Right', club: 'Al-Sadd', clubLeague: 'Qatar Stars League', marketValue: 8000000, caps: 95, goals: 25 },
      { firstName: 'Meshaal', lastName: 'Barsham', jerseyNumber: 12, position: 'GK', dateOfBirth: '1998-02-14', height: 195, weight: 85, preferredFoot: 'Right', club: 'Al-Sadd', clubLeague: 'Qatar Stars League', marketValue: 2000000, caps: 20, goals: 0 },
      { firstName: 'Musaab', lastName: 'Khidir', jerseyNumber: 13, position: 'RB', dateOfBirth: '1994-08-21', height: 178, weight: 72, preferredFoot: 'Right', club: 'Al-Wakrah', clubLeague: 'Qatar Stars League', marketValue: 1000000, caps: 35, goals: 1 },
      { firstName: 'Boualem', lastName: 'Khoukhi', jerseyNumber: 14, position: 'CB', dateOfBirth: '1990-07-09', height: 188, weight: 83, preferredFoot: 'Right', club: 'Al-Sadd', clubLeague: 'Qatar Stars League', marketValue: 1500000, caps: 90, goals: 4 },
      { firstName: 'Bassam', lastName: 'Al-Rawi', jerseyNumber: 15, position: 'CB', dateOfBirth: '1997-12-16', height: 185, weight: 78, preferredFoot: 'Left', club: 'Al-Duhail', clubLeague: 'Qatar Stars League', marketValue: 2000000, caps: 50, goals: 2 },
      { firstName: 'Assim', lastName: 'Madibo', jerseyNumber: 16, position: 'CDM', dateOfBirth: '1996-10-22', height: 178, weight: 75, preferredFoot: 'Right', club: 'Al-Duhail', clubLeague: 'Qatar Stars League', marketValue: 3000000, caps: 60, goals: 1 },
      { firstName: 'Ismaeel', lastName: 'Mohammad', jerseyNumber: 17, position: 'RW', dateOfBirth: '1990-04-05', height: 174, weight: 70, preferredFoot: 'Right', club: 'Al-Gharafa', clubLeague: 'Qatar Stars League', marketValue: 1000000, caps: 100, goals: 15 },
      { firstName: 'Karim', lastName: 'Boudiaf', jerseyNumber: 18, position: 'CM', dateOfBirth: '1990-09-16', height: 183, weight: 80, preferredFoot: 'Right', club: 'Al-Duhail', clubLeague: 'Qatar Stars League', marketValue: 1500000, caps: 100, goals: 5 },
      { firstName: 'Yusuf', lastName: 'Abdurisag', jerseyNumber: 19, position: 'ST', dateOfBirth: '1998-03-14', height: 176, weight: 72, preferredFoot: 'Right', club: 'Al-Arabi', clubLeague: 'Qatar Stars League', marketValue: 1500000, caps: 20, goals: 4 },
      { firstName: 'Ali', lastName: 'Asad', jerseyNumber: 20, position: 'RW', dateOfBirth: '1996-01-19', height: 172, weight: 67, preferredFoot: 'Right', club: 'Al-Sadd', clubLeague: 'Qatar Stars League', marketValue: 1500000, caps: 35, goals: 3 },
      { firstName: 'Yusuf', lastName: 'Saleh', jerseyNumber: 21, position: 'GK', dateOfBirth: '2000-03-12', height: 191, weight: 82, preferredFoot: 'Right', club: 'Al-Wakrah', clubLeague: 'Qatar Stars League', marketValue: 1000000, caps: 5, goals: 0 },
      { firstName: 'Jassem', lastName: 'Gaber', jerseyNumber: 22, position: 'CB', dateOfBirth: '2000-06-18', height: 187, weight: 80, preferredFoot: 'Right', club: 'Al-Sadd', clubLeague: 'Qatar Stars League', marketValue: 2000000, caps: 15, goals: 0 },
      { firstName: 'Ahmed', lastName: 'Alaaeldin', jerseyNumber: 23, position: 'CAM', dateOfBirth: '1993-01-20', height: 178, weight: 72, preferredFoot: 'Right', club: 'Al-Gharafa', clubLeague: 'Qatar Stars League', marketValue: 1500000, caps: 45, goals: 6 },
      { firstName: 'Sultan', lastName: 'Al-Brake', jerseyNumber: 24, position: 'RW', dateOfBirth: '2001-10-15', height: 174, weight: 68, preferredFoot: 'Right', club: 'Al-Duhail', clubLeague: 'Qatar Stars League', marketValue: 1500000, caps: 10, goals: 1 },
      { firstName: 'Hazem', lastName: 'Shehata', jerseyNumber: 25, position: 'LB', dateOfBirth: '1998-08-07', height: 177, weight: 73, preferredFoot: 'Left', club: 'Al-Sadd', clubLeague: 'Qatar Stars League', marketValue: 1500000, caps: 15, goals: 0 },
      { firstName: 'Hisham', lastName: 'Ali', jerseyNumber: 26, position: 'ST', dateOfBirth: '2002-02-20', height: 180, weight: 74, preferredFoot: 'Right', club: 'Al-Gharafa', clubLeague: 'Qatar Stars League', marketValue: 1500000, caps: 5, goals: 1 },
    ],
  },

  // ========== IVORY COAST ==========
  {
    name: 'Ivory Coast',
    fifaCode: 'CIV',
    players: [
      { firstName: 'Yahia', lastName: 'Fofana', jerseyNumber: 1, position: 'GK', dateOfBirth: '1999-02-05', height: 194, weight: 88, preferredFoot: 'Right', club: 'Angers', clubLeague: 'Ligue 1', marketValue: 5000000, caps: 10, goals: 0 },
      { firstName: 'Serge', lastName: 'Aurier', jerseyNumber: 2, position: 'RB', dateOfBirth: '1992-12-24', height: 176, weight: 75, preferredFoot: 'Right', club: 'Galatasaray', clubLeague: 'Super Lig', marketValue: 4000000, caps: 85, goals: 4 },
      { firstName: 'Ghislain', lastName: 'Konan', jerseyNumber: 3, position: 'LB', dateOfBirth: '1996-01-25', height: 182, weight: 75, preferredFoot: 'Left', club: 'Reims', clubLeague: 'Ligue 1', marketValue: 5000000, caps: 30, goals: 0 },
      { firstName: 'Odilon', lastName: 'Kossounou', jerseyNumber: 4, position: 'CB', dateOfBirth: '2001-01-04', height: 191, weight: 85, preferredFoot: 'Right', club: 'Bayer Leverkusen', clubLeague: 'Bundesliga', marketValue: 25000000, caps: 35, goals: 1 },
      { firstName: 'Willy', lastName: 'Boly', jerseyNumber: 5, position: 'CB', dateOfBirth: '1991-02-03', height: 195, weight: 89, preferredFoot: 'Right', club: 'Nottingham Forest', clubLeague: 'Premier League', marketValue: 5000000, caps: 35, goals: 0 },
      { firstName: 'Seko', lastName: 'Fofana', jerseyNumber: 6, position: 'CM', dateOfBirth: '1995-05-07', height: 186, weight: 82, preferredFoot: 'Right', club: 'Al-Nassr', clubLeague: 'Saudi Pro League', marketValue: 25000000, caps: 35, goals: 2 },
      { firstName: 'Maxwel', lastName: 'Cornet', jerseyNumber: 7, position: 'LW', dateOfBirth: '1996-09-27', height: 178, weight: 72, preferredFoot: 'Left', club: 'West Ham', clubLeague: 'Premier League', marketValue: 15000000, caps: 45, goals: 5 },
      { firstName: 'Franck', lastName: 'Kessié', jerseyNumber: 8, position: 'CM', dateOfBirth: '1996-12-19', height: 183, weight: 83, preferredFoot: 'Right', club: 'Al-Ahli', clubLeague: 'Saudi Pro League', marketValue: 20000000, caps: 65, goals: 8 },
      { firstName: 'Sébastien', lastName: 'Haller', jerseyNumber: 9, position: 'ST', dateOfBirth: '1994-06-22', height: 190, weight: 83, preferredFoot: 'Right', club: 'Borussia Dortmund', clubLeague: 'Bundesliga', marketValue: 20000000, caps: 40, goals: 15 },
      { firstName: 'Ibrahim', lastName: 'Sangaré', jerseyNumber: 10, position: 'CM', dateOfBirth: '1997-12-02', height: 190, weight: 85, preferredFoot: 'Right', club: 'Nottingham Forest', clubLeague: 'Premier League', marketValue: 35000000, caps: 45, goals: 3 },
      { firstName: 'Simon', lastName: 'Adingra', jerseyNumber: 11, position: 'RW', dateOfBirth: '2002-01-01', height: 174, weight: 68, preferredFoot: 'Left', club: 'Brighton', clubLeague: 'Premier League', marketValue: 30000000, caps: 20, goals: 4 },
      { firstName: 'Ali', lastName: 'Badra', jerseyNumber: 12, position: 'GK', dateOfBirth: '1996-03-10', height: 188, weight: 82, preferredFoot: 'Right', club: 'Mamelodi Sundowns', clubLeague: 'South African Premier', marketValue: 1000000, caps: 10, goals: 0 },
      { firstName: 'Eric', lastName: 'Bailly', jerseyNumber: 13, position: 'CB', dateOfBirth: '1994-04-12', height: 187, weight: 79, preferredFoot: 'Right', club: 'Villarreal', clubLeague: 'La Liga', marketValue: 4000000, caps: 40, goals: 1 },
      { firstName: 'Evan', lastName: 'Ndicka', jerseyNumber: 14, position: 'CB', dateOfBirth: '1999-08-20', height: 193, weight: 83, preferredFoot: 'Left', club: 'Roma', clubLeague: 'Serie A', marketValue: 25000000, caps: 20, goals: 0 },
      { firstName: 'Max-Alain', lastName: 'Gradel', jerseyNumber: 15, position: 'LW', dateOfBirth: '1987-11-30', height: 175, weight: 72, preferredFoot: 'Left', club: 'Sivasspor', clubLeague: 'Super Lig', marketValue: 500000, caps: 85, goals: 15 },
      { firstName: 'Jean Michaël', lastName: 'Seri', jerseyNumber: 16, position: 'CM', dateOfBirth: '1991-07-19', height: 175, weight: 68, preferredFoot: 'Right', club: 'Hull City', clubLeague: 'Championship', marketValue: 2000000, caps: 50, goals: 2 },
      { firstName: 'Emmanuel', lastName: 'Agbadou', jerseyNumber: 17, position: 'CB', dateOfBirth: '1997-07-01', height: 193, weight: 85, preferredFoot: 'Right', club: 'Reims', clubLeague: 'Ligue 1', marketValue: 8000000, caps: 15, goals: 1 },
      { firstName: 'Oumar', lastName: 'Diakité', jerseyNumber: 18, position: 'CM', dateOfBirth: '2002-04-23', height: 180, weight: 75, preferredFoot: 'Right', club: 'Reims', clubLeague: 'Ligue 1', marketValue: 8000000, caps: 15, goals: 2 },
      { firstName: 'Nicolas', lastName: 'Pépé', jerseyNumber: 19, position: 'RW', dateOfBirth: '1995-05-29', height: 183, weight: 72, preferredFoot: 'Left', club: 'Villarreal', clubLeague: 'La Liga', marketValue: 10000000, caps: 50, goals: 8 },
      { firstName: 'Karim', lastName: 'Konaté', jerseyNumber: 20, position: 'ST', dateOfBirth: '2004-02-21', height: 183, weight: 75, preferredFoot: 'Left', club: 'Red Bull Salzburg', clubLeague: 'Austrian Bundesliga', marketValue: 12000000, caps: 10, goals: 3 },
      { firstName: 'Jean-Philippe', lastName: 'Gbamin', jerseyNumber: 21, position: 'CDM', dateOfBirth: '1995-09-25', height: 186, weight: 80, preferredFoot: 'Right', club: 'Trabzonspor', clubLeague: 'Super Lig', marketValue: 3000000, caps: 25, goals: 1 },
      { firstName: 'Eliezer', lastName: 'Ira', jerseyNumber: 22, position: 'GK', dateOfBirth: '1998-04-06', height: 190, weight: 82, preferredFoot: 'Right', club: 'Djurgårdens IF', clubLeague: 'Allsvenskan', marketValue: 1000000, caps: 5, goals: 0 },
      { firstName: 'Wilfried', lastName: 'Zaha', jerseyNumber: 23, position: 'LW', dateOfBirth: '1992-11-10', height: 180, weight: 74, preferredFoot: 'Right', club: 'Galatasaray', clubLeague: 'Super Lig', marketValue: 12000000, caps: 20, goals: 3 },
      { firstName: 'Christian', lastName: 'Kouamé', jerseyNumber: 24, position: 'ST', dateOfBirth: '1997-12-06', height: 186, weight: 75, preferredFoot: 'Right', club: 'Fiorentina', clubLeague: 'Serie A', marketValue: 10000000, caps: 25, goals: 5 },
      { firstName: 'Jérémie', lastName: 'Boga', jerseyNumber: 25, position: 'LW', dateOfBirth: '1997-01-03', height: 172, weight: 68, preferredFoot: 'Left', club: 'Nice', clubLeague: 'Ligue 1', marketValue: 15000000, caps: 15, goals: 2 },
      { firstName: 'Ousmane', lastName: 'Diomandé', jerseyNumber: 26, position: 'CB', dateOfBirth: '2003-02-20', height: 188, weight: 80, preferredFoot: 'Left', club: 'Sporting CP', clubLeague: 'Primeira Liga', marketValue: 20000000, caps: 10, goals: 0 },
    ],
  },

  // ========== ALGERIA ==========
  {
    name: 'Algeria',
    fifaCode: 'ALG',
    players: [
      { firstName: 'Raïs', lastName: "M'Bolhi", jerseyNumber: 1, position: 'GK', dateOfBirth: '1986-04-25', height: 193, weight: 83, preferredFoot: 'Right', club: 'Al-Shabab', clubLeague: 'Saudi Pro League', marketValue: 500000, caps: 105, goals: 0 },
      { firstName: 'Aïssa', lastName: 'Mandi', jerseyNumber: 2, position: 'CB', dateOfBirth: '1991-10-22', height: 184, weight: 79, preferredFoot: 'Right', club: 'Villarreal', clubLeague: 'La Liga', marketValue: 5000000, caps: 85, goals: 3 },
      { firstName: 'Djamel', lastName: 'Benlamri', jerseyNumber: 3, position: 'CB', dateOfBirth: '1989-01-28', height: 185, weight: 83, preferredFoot: 'Right', club: 'Al-Shabab', clubLeague: 'Saudi Pro League', marketValue: 1000000, caps: 60, goals: 3 },
      { firstName: 'Youcef', lastName: 'Atal', jerseyNumber: 4, position: 'RB', dateOfBirth: '1996-05-17', height: 175, weight: 70, preferredFoot: 'Right', club: 'Adana Demirspor', clubLeague: 'Super Lig', marketValue: 8000000, caps: 35, goals: 3 },
      { firstName: 'Ramy', lastName: 'Bensebaini', jerseyNumber: 5, position: 'LB', dateOfBirth: '1995-04-16', height: 187, weight: 78, preferredFoot: 'Left', club: 'Borussia Dortmund', clubLeague: 'Bundesliga', marketValue: 20000000, caps: 60, goals: 8 },
      { firstName: 'Adlène', lastName: 'Guedioura', jerseyNumber: 6, position: 'CM', dateOfBirth: '1985-11-12', height: 187, weight: 80, preferredFoot: 'Right', club: 'Free Agent', clubLeague: 'N/A', marketValue: 200000, caps: 65, goals: 3 },
      { firstName: 'Riyad', lastName: 'Mahrez', jerseyNumber: 7, position: 'RW', dateOfBirth: '1991-02-21', height: 179, weight: 67, preferredFoot: 'Left', club: 'Al-Ahli', clubLeague: 'Saudi Pro League', marketValue: 15000000, caps: 95, goals: 29 },
      { firstName: 'Yacine', lastName: 'Brahimi', jerseyNumber: 8, position: 'LW', dateOfBirth: '1990-02-08', height: 179, weight: 67, preferredFoot: 'Right', club: 'Al-Gharafa', clubLeague: 'Qatar Stars League', marketValue: 3000000, caps: 75, goals: 12 },
      { firstName: 'Islam', lastName: 'Slimani', jerseyNumber: 9, position: 'ST', dateOfBirth: '1988-06-18', height: 188, weight: 84, preferredFoot: 'Right', club: 'Al-Shabab', clubLeague: 'Saudi Pro League', marketValue: 1000000, caps: 95, goals: 42 },
      { firstName: 'Sofiane', lastName: 'Feghouli', jerseyNumber: 10, position: 'RW', dateOfBirth: '1989-12-26', height: 178, weight: 72, preferredFoot: 'Left', club: 'Fatih Karagümrük', clubLeague: 'Super Lig', marketValue: 1500000, caps: 85, goals: 15 },
      { firstName: 'Saïd', lastName: 'Benrahma', jerseyNumber: 11, position: 'LW', dateOfBirth: '1995-08-10', height: 175, weight: 70, preferredFoot: 'Right', club: 'Lyon', clubLeague: 'Ligue 1', marketValue: 15000000, caps: 30, goals: 4 },
      { firstName: 'Alexandre', lastName: 'Oukidja', jerseyNumber: 12, position: 'GK', dateOfBirth: '1988-07-08', height: 190, weight: 80, preferredFoot: 'Right', club: 'Metz', clubLeague: 'Ligue 1', marketValue: 1500000, caps: 10, goals: 0 },
      { firstName: 'Abdelkader', lastName: 'Bedrane', jerseyNumber: 13, position: 'CB', dateOfBirth: '1994-12-07', height: 189, weight: 82, preferredFoot: 'Right', club: 'CS Constantine', clubLeague: 'Ligue 1 Algeria', marketValue: 500000, caps: 25, goals: 1 },
      { firstName: 'Ismaël', lastName: 'Bennacer', jerseyNumber: 14, position: 'CM', dateOfBirth: '1997-12-01', height: 175, weight: 68, preferredFoot: 'Left', club: 'AC Milan', clubLeague: 'Serie A', marketValue: 40000000, caps: 50, goals: 2 },
      { firstName: 'Haris', lastName: 'Belkebla', jerseyNumber: 15, position: 'CM', dateOfBirth: '1994-01-28', height: 178, weight: 72, preferredFoot: 'Right', club: 'Brest', clubLeague: 'Ligue 1', marketValue: 5000000, caps: 20, goals: 0 },
      { firstName: 'Nabil', lastName: 'Bentaleb', jerseyNumber: 16, position: 'CM', dateOfBirth: '1994-11-24', height: 188, weight: 78, preferredFoot: 'Left', club: 'Angers', clubLeague: 'Ligue 1', marketValue: 2500000, caps: 55, goals: 3 },
      { firstName: 'Ramiz', lastName: 'Zerrouki', jerseyNumber: 17, position: 'CM', dateOfBirth: '1996-07-17', height: 182, weight: 75, preferredFoot: 'Right', club: 'Twente', clubLeague: 'Eredivisie', marketValue: 6000000, caps: 20, goals: 0 },
      { firstName: 'Amine', lastName: 'Gouiri', jerseyNumber: 18, position: 'LW', dateOfBirth: '2000-02-16', height: 180, weight: 72, preferredFoot: 'Right', club: 'Rennes', clubLeague: 'Ligue 1', marketValue: 30000000, caps: 15, goals: 3 },
      { firstName: 'Baghdad', lastName: 'Bounedjah', jerseyNumber: 19, position: 'ST', dateOfBirth: '1991-11-30', height: 184, weight: 80, preferredFoot: 'Right', club: 'Al-Sadd', clubLeague: 'Qatar Stars League', marketValue: 2500000, caps: 50, goals: 20 },
      { firstName: 'Farès', lastName: 'Chaïbi', jerseyNumber: 20, position: 'CAM', dateOfBirth: '2003-02-09', height: 175, weight: 68, preferredFoot: 'Right', club: 'Eintracht Frankfurt', clubLeague: 'Bundesliga', marketValue: 15000000, caps: 10, goals: 1 },
      { firstName: 'Adam', lastName: 'Ounas', jerseyNumber: 21, position: 'RW', dateOfBirth: '1996-11-11', height: 172, weight: 63, preferredFoot: 'Left', club: 'Lille', clubLeague: 'Ligue 1', marketValue: 10000000, caps: 35, goals: 4 },
      { firstName: 'Mostafa', lastName: 'Zeghba', jerseyNumber: 22, position: 'GK', dateOfBirth: '1994-08-25', height: 191, weight: 84, preferredFoot: 'Right', club: 'ES Sétif', clubLeague: 'Ligue 1 Algeria', marketValue: 500000, caps: 5, goals: 0 },
      { firstName: 'Houssem', lastName: 'Aouar', jerseyNumber: 23, position: 'CAM', dateOfBirth: '1998-06-30', height: 175, weight: 70, preferredFoot: 'Right', club: 'Roma', clubLeague: 'Serie A', marketValue: 12000000, caps: 20, goals: 2 },
      { firstName: 'Mehdi', lastName: 'Tahrat', jerseyNumber: 24, position: 'CB', dateOfBirth: '1991-05-30', height: 185, weight: 78, preferredFoot: 'Right', club: 'Lens', clubLeague: 'Ligue 1', marketValue: 3000000, caps: 20, goals: 0 },
      { firstName: 'Yassine', lastName: 'Benzia', jerseyNumber: 25, position: 'LW', dateOfBirth: '1994-09-08', height: 178, weight: 72, preferredFoot: 'Right', club: 'Antalyaspor', clubLeague: 'Super Lig', marketValue: 2000000, caps: 20, goals: 2 },
      { firstName: 'Mohamed', lastName: 'Amoura', jerseyNumber: 26, position: 'ST', dateOfBirth: '2000-07-13', height: 174, weight: 66, preferredFoot: 'Right', club: 'Wolfsburg', clubLeague: 'Bundesliga', marketValue: 15000000, caps: 15, goals: 5 },
    ],
  },

  // ========== TUNISIA ==========
  {
    name: 'Tunisia',
    fifaCode: 'TUN',
    players: [
      { firstName: 'Aymen', lastName: 'Dahmen', jerseyNumber: 1, position: 'GK', dateOfBirth: '1997-01-28', height: 188, weight: 82, preferredFoot: 'Right', club: 'Montpellier', clubLeague: 'Ligue 1', marketValue: 3000000, caps: 20, goals: 0 },
      { firstName: 'Mohamed', lastName: 'Dräger', jerseyNumber: 2, position: 'RB', dateOfBirth: '1996-06-25', height: 181, weight: 75, preferredFoot: 'Right', club: 'Luzern', clubLeague: 'Swiss Super League', marketValue: 3000000, caps: 40, goals: 1 },
      { firstName: 'Montassar', lastName: 'Talbi', jerseyNumber: 3, position: 'CB', dateOfBirth: '1998-05-26', height: 194, weight: 88, preferredFoot: 'Right', club: 'Lorient', clubLeague: 'Ligue 2', marketValue: 5000000, caps: 35, goals: 2 },
      { firstName: 'Yassine', lastName: 'Meriah', jerseyNumber: 4, position: 'CB', dateOfBirth: '1993-03-02', height: 184, weight: 80, preferredFoot: 'Right', club: 'Espérance de Tunis', clubLeague: 'Tunisian Ligue 1', marketValue: 1500000, caps: 70, goals: 3 },
      { firstName: 'Dylan', lastName: 'Bronn', jerseyNumber: 5, position: 'CB', dateOfBirth: '1995-06-19', height: 190, weight: 85, preferredFoot: 'Left', club: 'Salernitana', clubLeague: 'Serie B', marketValue: 3000000, caps: 45, goals: 2 },
      { firstName: 'Adem', lastName: 'Zorgane', jerseyNumber: 6, position: 'CM', dateOfBirth: '1999-02-02', height: 178, weight: 72, preferredFoot: 'Right', club: 'Burnley', clubLeague: 'Championship', marketValue: 5000000, caps: 20, goals: 1 },
      { firstName: 'Youssef', lastName: 'Msakni', jerseyNumber: 7, position: 'LW', dateOfBirth: '1990-10-28', height: 180, weight: 73, preferredFoot: 'Right', club: 'Al-Arabi', clubLeague: 'Qatar Stars League', marketValue: 2500000, caps: 95, goals: 25 },
      { firstName: 'Anis', lastName: 'Ben Slimane', jerseyNumber: 8, position: 'CM', dateOfBirth: '2001-03-16', height: 178, weight: 72, preferredFoot: 'Right', club: 'Brondby', clubLeague: 'Danish Superliga', marketValue: 5000000, caps: 15, goals: 1 },
      { firstName: 'Seifeddine', lastName: 'Jaziri', jerseyNumber: 9, position: 'ST', dateOfBirth: '1993-02-12', height: 182, weight: 78, preferredFoot: 'Right', club: 'Zamalek', clubLeague: 'Egyptian Premier League', marketValue: 2500000, caps: 35, goals: 8 },
      { firstName: 'Wahbi', lastName: 'Khazri', jerseyNumber: 10, position: 'CAM', dateOfBirth: '1991-02-08', height: 182, weight: 76, preferredFoot: 'Right', club: 'Montpellier', clubLeague: 'Ligue 1', marketValue: 3000000, caps: 75, goals: 25 },
      { firstName: 'Hannibal', lastName: 'Mejbri', jerseyNumber: 11, position: 'CM', dateOfBirth: '2003-01-21', height: 181, weight: 72, preferredFoot: 'Right', club: 'Burnley', clubLeague: 'Championship', marketValue: 10000000, caps: 15, goals: 0 },
      { firstName: 'Mouez', lastName: 'Hassen', jerseyNumber: 12, position: 'GK', dateOfBirth: '1995-03-05', height: 191, weight: 85, preferredFoot: 'Right', club: 'Nice', clubLeague: 'Ligue 1', marketValue: 2000000, caps: 30, goals: 0 },
      { firstName: 'Ferjani', lastName: 'Sassi', jerseyNumber: 13, position: 'CM', dateOfBirth: '1992-03-18', height: 183, weight: 78, preferredFoot: 'Right', club: 'Al-Duhail', clubLeague: 'Qatar Stars League', marketValue: 2500000, caps: 75, goals: 8 },
      { firstName: 'Aissa', lastName: 'Laïdouni', jerseyNumber: 14, position: 'CM', dateOfBirth: '1996-12-13', height: 180, weight: 75, preferredFoot: 'Right', club: 'Union Berlin', clubLeague: 'Bundesliga', marketValue: 10000000, caps: 35, goals: 2 },
      { firstName: 'Mohamed Ali', lastName: 'Ben Romdhane', jerseyNumber: 15, position: 'CM', dateOfBirth: '1999-09-06', height: 178, weight: 72, preferredFoot: 'Right', club: 'Ferencváros', clubLeague: 'NB I', marketValue: 4000000, caps: 25, goals: 2 },
      { firstName: 'Ali', lastName: 'Abdi', jerseyNumber: 16, position: 'LB', dateOfBirth: '1993-12-20', height: 183, weight: 78, preferredFoot: 'Left', club: 'Caen', clubLeague: 'Ligue 2', marketValue: 2500000, caps: 50, goals: 2 },
      { firstName: 'Ellyes', lastName: 'Skhiri', jerseyNumber: 17, position: 'CDM', dateOfBirth: '1995-05-10', height: 185, weight: 80, preferredFoot: 'Right', club: 'Eintracht Frankfurt', clubLeague: 'Bundesliga', marketValue: 20000000, caps: 50, goals: 3 },
      { firstName: 'Ghaylane', lastName: 'Chaalali', jerseyNumber: 18, position: 'CM', dateOfBirth: '1994-02-28', height: 175, weight: 70, preferredFoot: 'Right', club: 'Espérance de Tunis', clubLeague: 'Tunisian Ligue 1', marketValue: 1500000, caps: 35, goals: 2 },
      { firstName: 'Naim', lastName: 'Sliti', jerseyNumber: 19, position: 'RW', dateOfBirth: '1992-07-27', height: 173, weight: 68, preferredFoot: 'Right', club: 'Ettifaq', clubLeague: 'Saudi Pro League', marketValue: 2500000, caps: 70, goals: 10 },
      { firstName: 'Saad', lastName: 'Bguir', jerseyNumber: 20, position: 'CAM', dateOfBirth: '1993-02-21', height: 175, weight: 68, preferredFoot: 'Right', club: 'Espérance de Tunis', clubLeague: 'Tunisian Ligue 1', marketValue: 1500000, caps: 40, goals: 5 },
      { firstName: 'Hamza', lastName: 'Mathlouthi', jerseyNumber: 21, position: 'CB', dateOfBirth: '1989-08-14', height: 189, weight: 85, preferredFoot: 'Right', club: 'Free Agent', clubLeague: 'N/A', marketValue: 200000, caps: 25, goals: 0 },
      { firstName: 'Farouk', lastName: 'Ben Mustapha', jerseyNumber: 22, position: 'GK', dateOfBirth: '1989-07-01', height: 195, weight: 87, preferredFoot: 'Right', club: 'Al-Shabab', clubLeague: 'Saudi Pro League', marketValue: 500000, caps: 55, goals: 0 },
      { firstName: 'Taha Yassine', lastName: 'Khenissi', jerseyNumber: 23, position: 'ST', dateOfBirth: '1992-01-06', height: 187, weight: 82, preferredFoot: 'Left', club: 'Kuwait SC', clubLeague: 'Kuwait Premier League', marketValue: 1500000, caps: 40, goals: 15 },
      { firstName: 'Bilel', lastName: 'Ifa', jerseyNumber: 24, position: 'CB', dateOfBirth: '1990-03-09', height: 185, weight: 80, preferredFoot: 'Right', club: 'Kuwait SC', clubLeague: 'Kuwait Premier League', marketValue: 500000, caps: 30, goals: 1 },
      { firstName: 'Mohamed', lastName: 'Ben Amor', jerseyNumber: 25, position: 'CM', dateOfBirth: '1995-09-16', height: 178, weight: 72, preferredFoot: 'Right', club: 'Espérance de Tunis', clubLeague: 'Tunisian Ligue 1', marketValue: 1500000, caps: 25, goals: 1 },
      { firstName: 'Adem', lastName: 'Zelfani', jerseyNumber: 26, position: 'ST', dateOfBirth: '2002-05-05', height: 181, weight: 75, preferredFoot: 'Right', club: 'Clermont', clubLeague: 'Ligue 2', marketValue: 3000000, caps: 5, goals: 1 },
    ],
  },

  // ========== JAMAICA ==========
  {
    name: 'Jamaica',
    fifaCode: 'JAM',
    players: [
      { firstName: 'Andre', lastName: 'Blake', jerseyNumber: 1, position: 'GK', dateOfBirth: '1990-11-21', height: 193, weight: 89, preferredFoot: 'Right', club: 'Philadelphia Union', clubLeague: 'MLS', marketValue: 5000000, caps: 55, goals: 0 },
      { firstName: 'Greg', lastName: 'Leigh', jerseyNumber: 2, position: 'LB', dateOfBirth: '1994-03-30', height: 175, weight: 72, preferredFoot: 'Left', club: 'Oxford United', clubLeague: 'Championship', marketValue: 1000000, caps: 15, goals: 0 },
      { firstName: 'Damion', lastName: 'Lowe', jerseyNumber: 3, position: 'CB', dateOfBirth: '1993-02-21', height: 185, weight: 82, preferredFoot: 'Right', club: 'Inter Miami', clubLeague: 'MLS', marketValue: 1500000, caps: 45, goals: 3 },
      { firstName: 'Ravel', lastName: 'Morrison', jerseyNumber: 4, position: 'CM', dateOfBirth: '1993-02-02', height: 175, weight: 72, preferredFoot: 'Left', club: 'Free Agent', clubLeague: 'N/A', marketValue: 500000, caps: 15, goals: 0 },
      { firstName: 'Ethan', lastName: 'Pinnock', jerseyNumber: 5, position: 'CB', dateOfBirth: '1993-05-29', height: 192, weight: 90, preferredFoot: 'Left', club: 'Brentford', clubLeague: 'Premier League', marketValue: 15000000, caps: 20, goals: 0 },
      { firstName: 'Tyreek', lastName: 'Magee', jerseyNumber: 6, position: 'RW', dateOfBirth: '2000-01-26', height: 178, weight: 70, preferredFoot: 'Right', club: 'Philadelphia Union', clubLeague: 'MLS', marketValue: 2000000, caps: 15, goals: 1 },
      { firstName: 'Leon', lastName: 'Bailey', jerseyNumber: 7, position: 'RW', dateOfBirth: '1997-08-09', height: 178, weight: 72, preferredFoot: 'Left', club: 'Aston Villa', clubLeague: 'Premier League', marketValue: 25000000, caps: 30, goals: 6 },
      { firstName: 'Oniel', lastName: 'Fisher', jerseyNumber: 8, position: 'RB', dateOfBirth: '1990-10-07', height: 173, weight: 68, preferredFoot: 'Right', club: 'Ludogorets', clubLeague: 'Bulgarian First League', marketValue: 500000, caps: 45, goals: 1 },
      { firstName: 'Michail', lastName: 'Antonio', jerseyNumber: 9, position: 'ST', dateOfBirth: '1990-03-28', height: 180, weight: 82, preferredFoot: 'Right', club: 'West Ham', clubLeague: 'Premier League', marketValue: 8000000, caps: 20, goals: 5 },
      { firstName: 'Jamal', lastName: 'Lowe', jerseyNumber: 10, position: 'LW', dateOfBirth: '1994-07-21', height: 178, weight: 70, preferredFoot: 'Right', club: 'Sheffield Wednesday', clubLeague: 'Championship', marketValue: 2500000, caps: 25, goals: 2 },
      { firstName: 'Bobby', lastName: 'Decordova-Reid', jerseyNumber: 11, position: 'RW', dateOfBirth: '1993-02-02', height: 172, weight: 68, preferredFoot: 'Right', club: 'Fulham', clubLeague: 'Premier League', marketValue: 8000000, caps: 25, goals: 3 },
      { firstName: 'Dillon', lastName: 'Barnes', jerseyNumber: 12, position: 'GK', dateOfBirth: '1996-08-31', height: 188, weight: 82, preferredFoot: 'Right', club: 'QPR', clubLeague: 'Championship', marketValue: 1000000, caps: 5, goals: 0 },
      { firstName: 'Michael', lastName: 'Hector', jerseyNumber: 13, position: 'CB', dateOfBirth: '1992-07-19', height: 193, weight: 88, preferredFoot: 'Right', club: 'Free Agent', clubLeague: 'N/A', marketValue: 500000, caps: 30, goals: 1 },
      { firstName: 'Daniel', lastName: 'Johnson', jerseyNumber: 14, position: 'CM', dateOfBirth: '1992-10-08', height: 175, weight: 70, preferredFoot: 'Right', club: 'Preston North End', clubLeague: 'Championship', marketValue: 3000000, caps: 20, goals: 3 },
      { firstName: 'Blair', lastName: 'Turgott', jerseyNumber: 15, position: 'RW', dateOfBirth: '1994-05-22', height: 178, weight: 72, preferredFoot: 'Right', club: 'Stevenage', clubLeague: 'League One', marketValue: 500000, caps: 5, goals: 0 },
      { firstName: 'Kasey', lastName: 'Palmer', jerseyNumber: 16, position: 'CAM', dateOfBirth: '1997-02-09', height: 175, weight: 70, preferredFoot: 'Right', club: 'Coventry City', clubLeague: 'Championship', marketValue: 3000000, caps: 10, goals: 1 },
      { firstName: 'Amari\'i', lastName: 'Bell', jerseyNumber: 17, position: 'LB', dateOfBirth: '1994-05-05', height: 183, weight: 75, preferredFoot: 'Left', club: 'Luton Town', clubLeague: 'Championship', marketValue: 1500000, caps: 15, goals: 0 },
      { firstName: 'Kevon', lastName: 'Lambert', jerseyNumber: 18, position: 'CDM', dateOfBirth: '1996-09-15', height: 188, weight: 82, preferredFoot: 'Right', club: 'Hull City', clubLeague: 'Championship', marketValue: 2000000, caps: 20, goals: 0 },
      { firstName: 'Adrian', lastName: 'Mariappa', jerseyNumber: 19, position: 'CB', dateOfBirth: '1986-10-03', height: 180, weight: 75, preferredFoot: 'Right', club: 'Free Agent', clubLeague: 'N/A', marketValue: 200000, caps: 75, goals: 1 },
      { firstName: 'Kemar', lastName: 'Roofe', jerseyNumber: 20, position: 'ST', dateOfBirth: '1993-01-06', height: 183, weight: 77, preferredFoot: 'Right', club: 'Rangers', clubLeague: 'Scottish Premiership', marketValue: 3000000, caps: 20, goals: 4 },
      { firstName: 'Alex', lastName: 'Marshall', jerseyNumber: 21, position: 'GK', dateOfBirth: '1999-01-28', height: 190, weight: 82, preferredFoot: 'Right', club: 'New York City FC', clubLeague: 'MLS', marketValue: 800000, caps: 5, goals: 0 },
      { firstName: 'Nathan', lastName: 'Patterson', jerseyNumber: 22, position: 'RB', dateOfBirth: '2001-10-16', height: 180, weight: 72, preferredFoot: 'Right', club: 'Everton', clubLeague: 'Premier League', marketValue: 10000000, caps: 5, goals: 0 },
      { firstName: 'Demarai', lastName: 'Gray', jerseyNumber: 23, position: 'LW', dateOfBirth: '1996-06-28', height: 178, weight: 68, preferredFoot: 'Right', club: 'Al-Ettifaq', clubLeague: 'Saudi Pro League', marketValue: 8000000, caps: 15, goals: 2 },
      { firstName: 'Shamar', lastName: 'Nicholson', jerseyNumber: 24, position: 'ST', dateOfBirth: '1997-12-31', height: 185, weight: 78, preferredFoot: 'Right', club: 'Spartak Moscow', clubLeague: 'Russian Premier League', marketValue: 3000000, caps: 20, goals: 8 },
      { firstName: 'Lamar', lastName: 'Walker', jerseyNumber: 25, position: 'CM', dateOfBirth: '2000-03-14', height: 175, weight: 70, preferredFoot: 'Right', club: 'Harbour View', clubLeague: 'Jamaica Premier League', marketValue: 300000, caps: 5, goals: 0 },
      { firstName: 'Cory', lastName: 'Burke', jerseyNumber: 26, position: 'ST', dateOfBirth: '1992-01-07', height: 188, weight: 80, preferredFoot: 'Right', club: 'Philadelphia Union', clubLeague: 'MLS', marketValue: 2000000, caps: 15, goals: 3 },
    ],
  },

  // ========== HONDURAS ==========
  {
    name: 'Honduras',
    fifaCode: 'HON',
    players: [
      { firstName: 'Luis', lastName: 'López', jerseyNumber: 1, position: 'GK', dateOfBirth: '1993-09-13', height: 188, weight: 82, preferredFoot: 'Right', club: 'Real España', clubLeague: 'Liga Nacional de Honduras', marketValue: 400000, caps: 20, goals: 0 },
      { firstName: 'Andy', lastName: 'Najar', jerseyNumber: 2, position: 'RB', dateOfBirth: '1993-03-16', height: 175, weight: 70, preferredFoot: 'Right', club: 'DC United', clubLeague: 'MLS', marketValue: 1500000, caps: 55, goals: 4 },
      { firstName: 'Maynor', lastName: 'Figueroa', jerseyNumber: 3, position: 'CB', dateOfBirth: '1983-05-02', height: 185, weight: 78, preferredFoot: 'Left', club: 'Free Agent', clubLeague: 'N/A', marketValue: 100000, caps: 135, goals: 7 },
      { firstName: 'Wesly', lastName: 'Decas', jerseyNumber: 4, position: 'CB', dateOfBirth: '1998-07-21', height: 182, weight: 78, preferredFoot: 'Right', club: 'CD Marathon', clubLeague: 'Liga Nacional de Honduras', marketValue: 400000, caps: 10, goals: 0 },
      { firstName: 'Denil', lastName: 'Maldonado', jerseyNumber: 5, position: 'CB', dateOfBirth: '1998-01-13', height: 186, weight: 82, preferredFoot: 'Right', club: 'Pachuca', clubLeague: 'Liga MX', marketValue: 2500000, caps: 35, goals: 1 },
      { firstName: 'Bryan', lastName: 'Acosta', jerseyNumber: 6, position: 'CM', dateOfBirth: '1993-11-24', height: 175, weight: 70, preferredFoot: 'Right', club: 'FC Dallas', clubLeague: 'MLS', marketValue: 1500000, caps: 65, goals: 3 },
      { firstName: 'Emilio', lastName: 'Izaguirre', jerseyNumber: 7, position: 'LB', dateOfBirth: '1986-05-10', height: 173, weight: 68, preferredFoot: 'Left', club: 'Motagua', clubLeague: 'Liga Nacional de Honduras', marketValue: 100000, caps: 130, goals: 3 },
      { firstName: 'Carlos', lastName: 'Pineda', jerseyNumber: 8, position: 'CM', dateOfBirth: '1998-03-28', height: 178, weight: 72, preferredFoot: 'Right', club: 'Olympia', clubLeague: 'Liga Nacional de Honduras', marketValue: 500000, caps: 20, goals: 1 },
      { firstName: 'Anthony', lastName: 'Lozano', jerseyNumber: 9, position: 'ST', dateOfBirth: '1993-04-25', height: 175, weight: 72, preferredFoot: 'Right', club: 'Cádiz', clubLeague: 'La Liga 2', marketValue: 1500000, caps: 65, goals: 20 },
      { firstName: 'Kervin', lastName: 'Arriaga', jerseyNumber: 10, position: 'CM', dateOfBirth: '1999-01-24', height: 185, weight: 78, preferredFoot: 'Right', club: 'Minnesota United', clubLeague: 'MLS', marketValue: 2500000, caps: 20, goals: 2 },
      { firstName: 'Romell', lastName: 'Quioto', jerseyNumber: 11, position: 'LW', dateOfBirth: '1991-08-09', height: 177, weight: 73, preferredFoot: 'Right', club: 'CF Montreal', clubLeague: 'MLS', marketValue: 2500000, caps: 50, goals: 12 },
      { firstName: 'Edrick', lastName: 'Menjívar', jerseyNumber: 12, position: 'GK', dateOfBirth: '1982-11-30', height: 183, weight: 78, preferredFoot: 'Right', club: 'Alianza', clubLeague: 'Liga Nacional de Honduras', marketValue: 50000, caps: 85, goals: 0 },
      { firstName: 'Joseph', lastName: 'Rosales', jerseyNumber: 13, position: 'CM', dateOfBirth: '1999-08-11', height: 175, weight: 70, preferredFoot: 'Right', club: 'Houston Dynamo', clubLeague: 'MLS', marketValue: 1500000, caps: 25, goals: 2 },
      { firstName: 'Boniek', lastName: 'García', jerseyNumber: 14, position: 'CM', dateOfBirth: '1984-09-14', height: 178, weight: 75, preferredFoot: 'Right', club: 'Olimpia', clubLeague: 'Liga Nacional de Honduras', marketValue: 100000, caps: 130, goals: 10 },
      { firstName: 'Jonathan', lastName: 'Rubio', jerseyNumber: 15, position: 'RW', dateOfBirth: '1998-08-10', height: 175, weight: 70, preferredFoot: 'Right', club: 'Académica', clubLeague: 'Liga Portugal 2', marketValue: 800000, caps: 15, goals: 2 },
      { firstName: 'Diego', lastName: 'Rodríguez', jerseyNumber: 16, position: 'CB', dateOfBirth: '1997-07-28', height: 184, weight: 80, preferredFoot: 'Right', club: 'Motagua', clubLeague: 'Liga Nacional de Honduras', marketValue: 500000, caps: 20, goals: 1 },
      { firstName: 'Alberth', lastName: 'Elis', jerseyNumber: 17, position: 'RW', dateOfBirth: '1996-02-12', height: 178, weight: 74, preferredFoot: 'Right', club: 'Bordeaux', clubLeague: 'Ligue 2', marketValue: 4000000, caps: 50, goals: 10 },
      { firstName: 'Deybi', lastName: 'Flores', jerseyNumber: 18, position: 'CM', dateOfBirth: '1996-01-04', height: 175, weight: 68, preferredFoot: 'Right', club: 'Motagua', clubLeague: 'Liga Nacional de Honduras', marketValue: 400000, caps: 25, goals: 1 },
      { firstName: 'Brayan', lastName: 'Moya', jerseyNumber: 19, position: 'ST', dateOfBirth: '1994-03-11', height: 178, weight: 75, preferredFoot: 'Right', club: 'Bolívar', clubLeague: 'Bolivian Primera División', marketValue: 1500000, caps: 30, goals: 8 },
      { firstName: 'Jorge', lastName: 'Álvarez', jerseyNumber: 20, position: 'RW', dateOfBirth: '2000-04-14', height: 170, weight: 65, preferredFoot: 'Right', club: 'New York City FC', clubLeague: 'MLS', marketValue: 1000000, caps: 10, goals: 1 },
      { firstName: 'Harold', lastName: 'Fonseca', jerseyNumber: 21, position: 'GK', dateOfBirth: '1994-02-21', height: 186, weight: 80, preferredFoot: 'Right', club: 'Marathon', clubLeague: 'Liga Nacional de Honduras', marketValue: 300000, caps: 10, goals: 0 },
      { firstName: 'Edwin', lastName: 'Rodríguez', jerseyNumber: 22, position: 'CM', dateOfBirth: '2003-03-04', height: 178, weight: 72, preferredFoot: 'Right', club: 'Bayern Munich II', clubLeague: 'Regionalliga Bayern', marketValue: 800000, caps: 10, goals: 0 },
      { firstName: 'Jerry', lastName: 'Bengtson', jerseyNumber: 23, position: 'ST', dateOfBirth: '1987-04-08', height: 193, weight: 85, preferredFoot: 'Right', club: 'Olimpia', clubLeague: 'Liga Nacional de Honduras', marketValue: 100000, caps: 70, goals: 25 },
      { firstName: 'Jose', lastName: 'García', jerseyNumber: 24, position: 'CB', dateOfBirth: '2000-05-21', height: 182, weight: 78, preferredFoot: 'Right', club: 'Orlando City', clubLeague: 'MLS', marketValue: 2000000, caps: 10, goals: 0 },
      { firstName: 'Marlon', lastName: 'Licona', jerseyNumber: 25, position: 'GK', dateOfBirth: '1995-07-24', height: 190, weight: 82, preferredFoot: 'Right', club: 'Olimpia', clubLeague: 'Liga Nacional de Honduras', marketValue: 300000, caps: 5, goals: 0 },
      { firstName: 'Luis', lastName: 'Palma', jerseyNumber: 26, position: 'LW', dateOfBirth: '2000-01-17', height: 178, weight: 72, preferredFoot: 'Right', club: 'Celtic', clubLeague: 'Scottish Premiership', marketValue: 12000000, caps: 20, goals: 4 },
    ],
  },

  // ========== PANAMA ==========
  {
    name: 'Panama',
    fifaCode: 'PAN',
    players: [
      { firstName: 'Luis', lastName: 'Mejía', jerseyNumber: 1, position: 'GK', dateOfBirth: '1996-01-26', height: 190, weight: 82, preferredFoot: 'Right', club: 'Leganés', clubLeague: 'La Liga', marketValue: 3000000, caps: 30, goals: 0 },
      { firstName: 'Michael', lastName: 'Murillo', jerseyNumber: 2, position: 'RB', dateOfBirth: '1996-01-11', height: 181, weight: 77, preferredFoot: 'Right', club: 'Anderlecht', clubLeague: 'Belgian First Division', marketValue: 3500000, caps: 55, goals: 2 },
      { firstName: 'Harold', lastName: 'Cummings', jerseyNumber: 3, position: 'CB', dateOfBirth: '1992-03-24', height: 188, weight: 84, preferredFoot: 'Right', club: 'Comunicaciones', clubLeague: 'Liga Nacional de Guatemala', marketValue: 400000, caps: 70, goals: 3 },
      { firstName: 'Fidel', lastName: 'Escobar', jerseyNumber: 4, position: 'CB', dateOfBirth: '1995-01-16', height: 186, weight: 80, preferredFoot: 'Right', club: 'Alianza', clubLeague: 'Liga Panameña', marketValue: 400000, caps: 60, goals: 2 },
      { firstName: 'Roman', lastName: 'Torres', jerseyNumber: 5, position: 'CB', dateOfBirth: '1986-03-20', height: 188, weight: 85, preferredFoot: 'Right', club: 'Free Agent', clubLeague: 'N/A', marketValue: 100000, caps: 120, goals: 10 },
      { firstName: 'Adalberto', lastName: 'Carrasquilla', jerseyNumber: 6, position: 'CM', dateOfBirth: '1998-05-21', height: 170, weight: 66, preferredFoot: 'Right', club: 'Houston Dynamo', clubLeague: 'MLS', marketValue: 3000000, caps: 40, goals: 3 },
      { firstName: 'Blas', lastName: 'Pérez', jerseyNumber: 7, position: 'ST', dateOfBirth: '1981-03-13', height: 191, weight: 88, preferredFoot: 'Right', club: 'Free Agent', clubLeague: 'N/A', marketValue: 50000, caps: 130, goals: 43 },
      { firstName: 'César', lastName: 'Yanis', jerseyNumber: 8, position: 'RW', dateOfBirth: '2000-07-07', height: 172, weight: 68, preferredFoot: 'Right', club: 'Orlando City', clubLeague: 'MLS', marketValue: 2500000, caps: 20, goals: 3 },
      { firstName: 'Freddy', lastName: 'Góndola', jerseyNumber: 9, position: 'LW', dateOfBirth: '1994-05-18', height: 175, weight: 70, preferredFoot: 'Right', club: 'Pirata FC', clubLeague: 'Liga 1 Peru', marketValue: 300000, caps: 35, goals: 5 },
      { firstName: 'Édgar', lastName: 'Bárcenas', jerseyNumber: 10, position: 'LW', dateOfBirth: '1993-12-14', height: 177, weight: 72, preferredFoot: 'Right', club: 'Girona', clubLeague: 'La Liga', marketValue: 3500000, caps: 60, goals: 8 },
      { firstName: 'Cecilio', lastName: 'Waterman', jerseyNumber: 11, position: 'ST', dateOfBirth: '1992-08-12', height: 185, weight: 78, preferredFoot: 'Right', club: 'Tauro', clubLeague: 'Liga Panameña', marketValue: 300000, caps: 25, goals: 8 },
      { firstName: 'Orlando', lastName: 'Mosquera', jerseyNumber: 12, position: 'GK', dateOfBirth: '1994-10-17', height: 188, weight: 80, preferredFoot: 'Right', club: 'Millonarios', clubLeague: 'Liga Colombia', marketValue: 800000, caps: 15, goals: 0 },
      { firstName: 'Eric', lastName: 'Davis', jerseyNumber: 13, position: 'LB', dateOfBirth: '1991-03-30', height: 175, weight: 70, preferredFoot: 'Left', club: 'FC DAC 1904', clubLeague: 'Slovak Super Liga', marketValue: 400000, caps: 65, goals: 1 },
      { firstName: 'José', lastName: 'Fajardo', jerseyNumber: 14, position: 'ST', dateOfBirth: '1997-03-09', height: 178, weight: 75, preferredFoot: 'Right', club: 'Cincinnati FC', clubLeague: 'MLS', marketValue: 2500000, caps: 25, goals: 8 },
      { firstName: 'Erick', lastName: 'Davis', jerseyNumber: 15, position: 'CB', dateOfBirth: '1994-10-07', height: 188, weight: 82, preferredFoot: 'Right', club: 'Slovan Bratislava', clubLeague: 'Slovak Super Liga', marketValue: 600000, caps: 30, goals: 0 },
      { firstName: 'José Luis', lastName: 'Rodríguez', jerseyNumber: 16, position: 'CM', dateOfBirth: '1992-06-28', height: 175, weight: 70, preferredFoot: 'Right', club: 'Club America', clubLeague: 'Liga MX', marketValue: 1500000, caps: 45, goals: 2 },
      { firstName: 'Yoel', lastName: 'Bárcenas', jerseyNumber: 17, position: 'RW', dateOfBirth: '1996-08-30', height: 175, weight: 68, preferredFoot: 'Right', club: 'Leganes', clubLeague: 'La Liga', marketValue: 2500000, caps: 30, goals: 3 },
      { firstName: 'José', lastName: 'Guerra', jerseyNumber: 18, position: 'GK', dateOfBirth: '1998-05-11', height: 188, weight: 80, preferredFoot: 'Right', club: 'Tauro', clubLeague: 'Liga Panameña', marketValue: 400000, caps: 5, goals: 0 },
      { firstName: 'Alberto', lastName: 'Quintero', jerseyNumber: 19, position: 'RW', dateOfBirth: '1987-10-20', height: 168, weight: 63, preferredFoot: 'Right', club: 'Universitario', clubLeague: 'Liga 1 Peru', marketValue: 400000, caps: 85, goals: 15 },
      { firstName: 'Aníbal', lastName: 'Godoy', jerseyNumber: 20, position: 'CDM', dateOfBirth: '1990-02-10', height: 182, weight: 75, preferredFoot: 'Right', club: 'Nashville SC', clubLeague: 'MLS', marketValue: 1000000, caps: 130, goals: 3 },
      { firstName: 'Armando', lastName: 'Cooper', jerseyNumber: 21, position: 'CM', dateOfBirth: '1987-11-05', height: 178, weight: 75, preferredFoot: 'Right', club: 'Alianza', clubLeague: 'Liga Panameña', marketValue: 100000, caps: 95, goals: 5 },
      { firstName: 'José', lastName: 'Murillo', jerseyNumber: 22, position: 'CB', dateOfBirth: '2000-06-24', height: 184, weight: 78, preferredFoot: 'Right', club: 'Minnesota United', clubLeague: 'MLS', marketValue: 1500000, caps: 10, goals: 0 },
      { firstName: 'Jovani', lastName: 'Welch', jerseyNumber: 23, position: 'CB', dateOfBirth: '1993-03-26', height: 186, weight: 82, preferredFoot: 'Right', club: 'Sporting San José', clubLeague: 'Liga Panameña', marketValue: 300000, caps: 30, goals: 0 },
      { firstName: 'Jair', lastName: 'Catuy', jerseyNumber: 24, position: 'CM', dateOfBirth: '2002-01-22', height: 175, weight: 70, preferredFoot: 'Right', club: 'Alianza', clubLeague: 'Liga Panameña', marketValue: 500000, caps: 5, goals: 0 },
      { firstName: 'Rolando', lastName: 'Blackburn', jerseyNumber: 25, position: 'ST', dateOfBirth: '1990-06-05', height: 183, weight: 78, preferredFoot: 'Right', club: 'Lechia Gdansk', clubLeague: 'Ekstraklasa', marketValue: 400000, caps: 30, goals: 5 },
      { firstName: 'Ismael', lastName: 'Díaz', jerseyNumber: 26, position: 'LW', dateOfBirth: '1997-10-27', height: 173, weight: 68, preferredFoot: 'Right', club: 'AD Alcorcón', clubLeague: 'La Liga 2', marketValue: 400000, caps: 20, goals: 2 },
    ],
  },
];

// ============================================================================
// Helper Functions
// ============================================================================

function calculateAge(dateOfBirth: string): number {
  const birthDate = new Date(dateOfBirth);
  const today = new Date();
  let age = today.getFullYear() - birthDate.getFullYear();
  const monthDiff = today.getMonth() - birthDate.getMonth();
  if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
    age--;
  }
  return age;
}

function generateStrengths(position: string): string[] {
  const positionStrengths: Record<string, string[]> = {
    'GK': ['Shot-stopping', 'Command of area', 'Distribution'],
    'CB': ['Aerial ability', 'Tackling', 'Positioning'],
    'LB': ['Overlapping runs', 'Crossing', 'Defensive awareness'],
    'RB': ['Pace', 'Crossing', 'One-on-one defending'],
    'CDM': ['Ball recovery', 'Passing range', 'Tactical awareness'],
    'CM': ['Ball retention', 'Vision', 'Work rate'],
    'CAM': ['Creativity', 'Final third passes', 'Movement'],
    'LW': ['Dribbling', 'Pace', 'Direct play'],
    'RW': ['Crossing', 'Cutting inside', 'Finishing'],
    'ST': ['Clinical finishing', 'Movement', 'Hold-up play'],
    'CF': ['Link-up play', 'Finishing', 'Intelligence'],
  };
  return positionStrengths[position] || ['Technical ability', 'Football intelligence', 'Team player'];
}

function generateWeaknesses(position: string): string[] {
  const positionWeaknesses: Record<string, string[]> = {
    'GK': ['Penalty saves', 'Playing out from the back'],
    'CB': ['Pace against quick forwards', 'Playing out under pressure'],
    'LB': ['Defensive concentration', 'Aerial duels'],
    'RB': ['Positional discipline', 'Final ball quality'],
    'CDM': ['Attacking contribution', 'Carrying ball forward'],
    'CM': ['Goal contribution', 'Defensive intensity'],
    'CAM': ['Defensive work', 'Physical duels'],
    'LW': ['Defensive tracking', 'Aerial ability'],
    'RW': ['Consistency', 'Decision making under pressure'],
    'ST': ['Link-up play', 'Pressing from the front'],
    'CF': ['Pace', 'Running in behind'],
  };
  return positionWeaknesses[position] || ['Consistency at top level', 'Big game experience'];
}

function generatePlayStyle(position: string): string {
  const styles: Record<string, string> = {
    'GK': 'Modern sweeper-keeper who commands the box and is comfortable with the ball at feet',
    'CB': 'Ball-playing defender with excellent reading of the game and leadership qualities',
    'LB': 'Attacking full-back who provides width and delivers quality crosses',
    'RB': 'Dynamic right-back combining defensive solidity with attacking threat',
    'CDM': 'Shield in front of the defense, breaking up play and distributing efficiently',
    'CM': 'Box-to-box midfielder with energy, vision, and goal contributions',
    'CAM': 'Creative playmaker who unlocks defenses with incisive passing and movement',
    'LW': 'Direct winger who takes on defenders and creates chances',
    'RW': 'Versatile wide player capable of scoring and creating goals',
    'ST': 'Clinical finisher with excellent movement and composure in front of goal',
    'CF': 'Complete forward who links play and finishes chances',
  };
  return styles[position] || 'Versatile player who adapts to tactical demands';
}

// ============================================================================
// Main Script
// ============================================================================

async function seedTeamPlayers(teamData: TeamData): Promise<number> {
  console.log(`\n==================================================`);
  console.log(`Processing: ${teamData.name} (${teamData.fifaCode})`);
  console.log(`==================================================`);

  // Check if team already has players
  const existingPlayers = await db.collection('players').where('fifaCode', '==', teamData.fifaCode).get();
  if (!existingPlayers.empty) {
    console.log(`⚠️  Team ${teamData.fifaCode} already has ${existingPlayers.size} players - skipping`);
    return 0;
  }

  console.log(`Processing ${teamData.players.length} players...`);

  let addedCount = 0;
  const batch = db.batch();

  for (let i = 0; i < teamData.players.length; i++) {
    const player = teamData.players[i];
    const age = calculateAge(player.dateOfBirth);

    const playerData = {
      playerId: `${teamData.fifaCode.toLowerCase()}_${i + 1}`,
      fifaCode: teamData.fifaCode,
      firstName: player.firstName,
      lastName: player.lastName,
      fullName: `${player.firstName} ${player.lastName}`,
      commonName: player.commonName || player.lastName,
      jerseyNumber: player.jerseyNumber,
      position: player.position,
      dateOfBirth: player.dateOfBirth,
      age: age,
      height: player.height,
      weight: player.weight,
      preferredFoot: player.preferredFoot,
      club: player.club,
      clubLeague: player.clubLeague,
      photoUrl: '',
      marketValue: player.marketValue,
      caps: player.caps,
      goals: player.goals,
      assists: Math.floor(player.goals * 0.5),
      worldCupAppearances: Math.floor(Math.random() * 3),
      worldCupGoals: Math.floor(Math.random() * 3),
      previousWorldCups: [],
      stats: {
        club: {
          season: '2024-25',
          appearances: Math.floor(Math.random() * 30) + 10,
          goals: ['ST', 'CF', 'LW', 'RW'].includes(player.position) ? Math.floor(Math.random() * 15) : Math.floor(Math.random() * 5),
          assists: Math.floor(Math.random() * 10),
          minutesPlayed: Math.floor(Math.random() * 2000) + 500,
        },
        international: {
          appearances: player.caps,
          goals: player.goals,
          assists: Math.floor(player.goals * 0.5),
          minutesPlayed: player.caps * 70,
        },
      },
      honors: [],
      strengths: generateStrengths(player.position),
      weaknesses: generateWeaknesses(player.position),
      playStyle: generatePlayStyle(player.position),
      keyMoment: `Key contributor in ${teamData.name}'s World Cup 2026 qualification campaign`,
      comparisonToLegend: '',
      worldCup2026Prediction: `Expected to play a key role for ${teamData.name} in World Cup 2026`,
      socialMedia: {
        instagram: '',
        twitter: '',
        followers: Math.floor(Math.random() * 5000000),
      },
      trivia: [],
    };

    if (DRY_RUN) {
      console.log(`[DRY RUN] Would add: ${playerData.fullName} (#${playerData.jerseyNumber}, ${playerData.position})`);
    } else {
      const docRef = db.collection('players').doc(playerData.playerId);
      batch.set(docRef, playerData);
    }
    addedCount++;
  }

  if (!DRY_RUN && addedCount > 0) {
    await batch.commit();
    console.log(`✅ Added ${addedCount} players for ${teamData.fifaCode}`);
  } else if (DRY_RUN) {
    console.log(`[DRY RUN] Would add ${addedCount} players for ${teamData.fifaCode}`);
  }

  return addedCount;
}

async function main() {
  console.log('=====================================');
  console.log('World Cup 2026 Team Player Seeder');
  console.log('=====================================\n');

  if (DRY_RUN) {
    console.log('🔍 DRY RUN MODE - No changes will be saved\n');
  }

  const teamsToProcess = SINGLE_TEAM
    ? TEAMS_DATA.filter(t => t.fifaCode === SINGLE_TEAM)
    : TEAMS_DATA;

  if (SINGLE_TEAM && teamsToProcess.length === 0) {
    console.log(`❌ Team ${SINGLE_TEAM} not found in configuration`);
    console.log(`Available teams: ${TEAMS_DATA.map(t => t.fifaCode).join(', ')}`);
    process.exit(1);
  }

  let totalAdded = 0;

  for (const teamData of teamsToProcess) {
    try {
      const added = await seedTeamPlayers(teamData);
      totalAdded += added;
    } catch (error) {
      console.error(`Error processing ${teamData.fifaCode}:`, error);
    }
  }

  console.log(`\n=====================================`);
  console.log(`SUMMARY`);
  console.log(`=====================================`);
  console.log(`Teams processed: ${teamsToProcess.length}`);
  console.log(`Total players added: ${totalAdded}`);
  console.log(`=====================================\n`);

  process.exit(0);
}

// ============================================================================
// Run
// ============================================================================

main().catch(error => {
  console.error('\nFATAL ERROR:', error);
  process.exit(1);
});

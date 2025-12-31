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

/**
 * Seed Remaining Team Players Script
 *
 * Adds player data for the 9 teams missing from the main seed script.
 * These are recently qualified teams for World Cup 2026.
 *
 * Teams: RSA, PAR, HAI, SCO, CPV, NOR, JOR, CUR, UZB
 *
 * Usage:
 *   npx ts-node src/seed-remaining-team-players.ts [--dryRun]
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

const REMAINING_TEAMS: TeamData[] = [
  // ========== SOUTH AFRICA (RSA) ==========
  {
    name: 'South Africa',
    fifaCode: 'RSA',
    players: [
      { firstName: 'Ronwen', lastName: 'Williams', jerseyNumber: 1, position: 'GK', dateOfBirth: '1992-03-28', height: 183, weight: 78, preferredFoot: 'Right', club: 'Mamelodi Sundowns', clubLeague: 'DStv Premiership', marketValue: 1500000, caps: 50, goals: 0 },
      { firstName: 'Siyanda', lastName: 'Xulu', jerseyNumber: 2, position: 'CB', dateOfBirth: '1991-12-29', height: 189, weight: 84, preferredFoot: 'Right', club: 'Sekhukhune United', clubLeague: 'DStv Premiership', marketValue: 400000, caps: 40, goals: 2 },
      { firstName: 'Rushine', lastName: 'De Reuck', jerseyNumber: 3, position: 'CB', dateOfBirth: '1996-11-21', height: 186, weight: 80, preferredFoot: 'Right', club: 'Mamelodi Sundowns', clubLeague: 'DStv Premiership', marketValue: 800000, caps: 25, goals: 1 },
      { firstName: 'Thibang', lastName: 'Phete', jerseyNumber: 4, position: 'CB', dateOfBirth: '1994-06-20', height: 182, weight: 76, preferredFoot: 'Right', club: 'Belenenses', clubLeague: 'Liga Portugal 2', marketValue: 600000, caps: 20, goals: 0 },
      { firstName: 'Aubrey', lastName: 'Modiba', jerseyNumber: 5, position: 'LB', dateOfBirth: '1995-02-16', height: 175, weight: 70, preferredFoot: 'Left', club: 'Mamelodi Sundowns', clubLeague: 'DStv Premiership', marketValue: 600000, caps: 15, goals: 1 },
      { firstName: 'Mothobi', lastName: 'Mvala', jerseyNumber: 6, position: 'CDM', dateOfBirth: '1994-05-25', height: 180, weight: 74, preferredFoot: 'Right', club: 'Mamelodi Sundowns', clubLeague: 'DStv Premiership', marketValue: 700000, caps: 25, goals: 2 },
      { firstName: 'Bongani', lastName: 'Zungu', jerseyNumber: 8, position: 'CM', dateOfBirth: '1992-10-09', height: 182, weight: 78, preferredFoot: 'Right', club: 'Mamelodi Sundowns', clubLeague: 'DStv Premiership', marketValue: 500000, caps: 35, goals: 3 },
      { firstName: 'Percy', lastName: 'Tau', jerseyNumber: 10, position: 'RW', dateOfBirth: '1994-05-13', height: 171, weight: 67, preferredFoot: 'Right', club: 'Al Ahly', clubLeague: 'Egyptian Premier League', marketValue: 4000000, caps: 50, goals: 16 },
      { firstName: 'Themba', lastName: 'Zwane', jerseyNumber: 7, position: 'LW', dateOfBirth: '1989-09-23', height: 170, weight: 65, preferredFoot: 'Right', club: 'Mamelodi Sundowns', clubLeague: 'DStv Premiership', marketValue: 600000, caps: 35, goals: 8 },
      { firstName: 'Evidence', lastName: 'Makgopa', jerseyNumber: 9, position: 'ST', dateOfBirth: '2000-07-02', height: 180, weight: 75, preferredFoot: 'Right', club: 'Mamelodi Sundowns', clubLeague: 'DStv Premiership', marketValue: 1200000, caps: 20, goals: 7 },
      { firstName: 'Lebo', lastName: 'Mothiba', jerseyNumber: 11, position: 'ST', dateOfBirth: '1996-01-28', height: 182, weight: 79, preferredFoot: 'Right', club: 'Strasbourg', clubLeague: 'Ligue 1', marketValue: 2500000, caps: 20, goals: 7 },
      { firstName: 'Thapelo', lastName: 'Morena', jerseyNumber: 12, position: 'RB', dateOfBirth: '1993-01-02', height: 168, weight: 65, preferredFoot: 'Right', club: 'Mamelodi Sundowns', clubLeague: 'DStv Premiership', marketValue: 600000, caps: 25, goals: 2 },
      { firstName: 'Keagan', lastName: 'Dolly', jerseyNumber: 14, position: 'CAM', dateOfBirth: '1993-01-22', height: 176, weight: 72, preferredFoot: 'Right', club: 'Kaizer Chiefs', clubLeague: 'DStv Premiership', marketValue: 800000, caps: 35, goals: 4 },
      { firstName: 'Sipho', lastName: 'Mbule', jerseyNumber: 15, position: 'CM', dateOfBirth: '1999-01-15', height: 175, weight: 68, preferredFoot: 'Right', club: 'Mamelodi Sundowns', clubLeague: 'DStv Premiership', marketValue: 700000, caps: 10, goals: 0 },
      { firstName: 'Teboho', lastName: 'Mokoena', jerseyNumber: 16, position: 'CM', dateOfBirth: '1997-08-11', height: 178, weight: 73, preferredFoot: 'Right', club: 'Mamelodi Sundowns', clubLeague: 'DStv Premiership', marketValue: 1000000, caps: 30, goals: 4 },
      { firstName: 'Lyle', lastName: 'Foster', jerseyNumber: 17, position: 'ST', dateOfBirth: '2000-09-03', height: 184, weight: 78, preferredFoot: 'Right', club: 'Burnley', clubLeague: 'Premier League', marketValue: 6000000, caps: 20, goals: 3 },
      { firstName: 'Grant', lastName: 'Kekana', jerseyNumber: 18, position: 'CB', dateOfBirth: '1990-03-14', height: 186, weight: 80, preferredFoot: 'Right', club: 'Mamelodi Sundowns', clubLeague: 'DStv Premiership', marketValue: 400000, caps: 10, goals: 0 },
      { firstName: 'Mihlali', lastName: 'Mayambela', jerseyNumber: 19, position: 'LW', dateOfBirth: '2000-02-19', height: 168, weight: 62, preferredFoot: 'Right', club: 'AmaZulu', clubLeague: 'DStv Premiership', marketValue: 400000, caps: 5, goals: 0 },
      { firstName: 'Khuliso', lastName: 'Mudau', jerseyNumber: 20, position: 'RB', dateOfBirth: '1997-04-29', height: 176, weight: 72, preferredFoot: 'Right', club: 'Mamelodi Sundowns', clubLeague: 'DStv Premiership', marketValue: 800000, caps: 15, goals: 0 },
      { firstName: 'Elias', lastName: 'Mokwana', jerseyNumber: 21, position: 'RW', dateOfBirth: '2001-02-28', height: 170, weight: 65, preferredFoot: 'Right', club: 'Esperance', clubLeague: 'Tunisian Ligue 1', marketValue: 700000, caps: 8, goals: 1 },
      { firstName: 'Ethan', lastName: 'Brooks', jerseyNumber: 22, position: 'CM', dateOfBirth: '2002-02-16', height: 178, weight: 72, preferredFoot: 'Right', club: 'Mamelodi Sundowns', clubLeague: 'DStv Premiership', marketValue: 500000, caps: 5, goals: 0 },
      { firstName: 'Veli', lastName: 'Mothwa', jerseyNumber: 23, position: 'GK', dateOfBirth: '1990-09-21', height: 188, weight: 82, preferredFoot: 'Right', club: 'AmaZulu', clubLeague: 'DStv Premiership', marketValue: 300000, caps: 10, goals: 0 },
      { firstName: 'Innocent', lastName: 'Maela', jerseyNumber: 24, position: 'LB', dateOfBirth: '1992-06-03', height: 175, weight: 70, preferredFoot: 'Left', club: 'Orlando Pirates', clubLeague: 'DStv Premiership', marketValue: 400000, caps: 20, goals: 1 },
      { firstName: 'Bruce', lastName: 'Bvuma', jerseyNumber: 25, position: 'GK', dateOfBirth: '1995-06-22', height: 186, weight: 80, preferredFoot: 'Right', club: 'Kaizer Chiefs', clubLeague: 'DStv Premiership', marketValue: 400000, caps: 5, goals: 0 },
      { firstName: 'Sphephelo', lastName: 'Sithole', jerseyNumber: 26, position: 'CM', dateOfBirth: '2000-01-17', height: 175, weight: 68, preferredFoot: 'Right', club: 'Beerschot', clubLeague: 'Belgian First Division B', marketValue: 500000, caps: 3, goals: 0 },
    ],
  },

  // ========== PARAGUAY (PAR) ==========
  {
    name: 'Paraguay',
    fifaCode: 'PAR',
    players: [
      { firstName: 'Antony', lastName: 'Silva', jerseyNumber: 1, position: 'GK', dateOfBirth: '1983-09-01', height: 185, weight: 80, preferredFoot: 'Right', club: 'Cerro Porteno', clubLeague: 'Division Profesional', marketValue: 500000, caps: 35, goals: 0 },
      { firstName: 'Alberto', lastName: 'Espinola', jerseyNumber: 2, position: 'RB', dateOfBirth: '1997-05-21', height: 178, weight: 73, preferredFoot: 'Right', club: 'Cerro Porteno', clubLeague: 'Division Profesional', marketValue: 1200000, caps: 20, goals: 0 },
      { firstName: 'Omar', lastName: 'Alderete', jerseyNumber: 3, position: 'CB', dateOfBirth: '1996-12-26', height: 190, weight: 85, preferredFoot: 'Left', club: 'Getafe', clubLeague: 'La Liga', marketValue: 6000000, caps: 30, goals: 2 },
      { firstName: 'Fabian', lastName: 'Balbuena', jerseyNumber: 4, position: 'CB', dateOfBirth: '1991-08-23', height: 188, weight: 84, preferredFoot: 'Right', club: 'Dynamo Moscow', clubLeague: 'Russian Premier League', marketValue: 3000000, caps: 50, goals: 3 },
      { firstName: 'Gustavo', lastName: 'Gomez', jerseyNumber: 5, position: 'CB', dateOfBirth: '1993-05-06', height: 186, weight: 82, preferredFoot: 'Right', club: 'Palmeiras', clubLeague: 'Serie A Brazil', marketValue: 5000000, caps: 75, goals: 6 },
      { firstName: 'Junior', lastName: 'Alonso', jerseyNumber: 6, position: 'CB', dateOfBirth: '1993-10-15', height: 180, weight: 76, preferredFoot: 'Left', club: 'Krasnodar', clubLeague: 'Russian Premier League', marketValue: 4000000, caps: 35, goals: 2 },
      { firstName: 'Mathias', lastName: 'Villasanti', jerseyNumber: 8, position: 'CM', dateOfBirth: '1997-05-13', height: 180, weight: 75, preferredFoot: 'Right', club: 'Gremio', clubLeague: 'Serie A Brazil', marketValue: 8000000, caps: 25, goals: 1 },
      { firstName: 'Julio', lastName: 'Enciso', jerseyNumber: 10, position: 'CAM', dateOfBirth: '2004-01-23', height: 165, weight: 58, preferredFoot: 'Right', club: 'Brighton', clubLeague: 'Premier League', marketValue: 20000000, caps: 15, goals: 2 },
      { firstName: 'Angel', lastName: 'Romero', jerseyNumber: 11, position: 'LW', dateOfBirth: '1992-07-04', height: 178, weight: 75, preferredFoot: 'Right', club: 'Corinthians', clubLeague: 'Serie A Brazil', marketValue: 4000000, caps: 75, goals: 14 },
      { firstName: 'Miguel', lastName: 'Almiron', jerseyNumber: 7, position: 'RW', dateOfBirth: '1994-02-10', height: 174, weight: 65, preferredFoot: 'Left', club: 'Newcastle', clubLeague: 'Premier League', marketValue: 25000000, caps: 60, goals: 9 },
      { firstName: 'Adam', lastName: 'Bareiro', jerseyNumber: 9, position: 'ST', dateOfBirth: '1996-07-26', height: 180, weight: 75, preferredFoot: 'Right', club: 'River Plate', clubLeague: 'Liga Argentina', marketValue: 6000000, caps: 25, goals: 7 },
      { firstName: 'Rodrigo', lastName: 'Fernandez', jerseyNumber: 12, position: 'GK', dateOfBirth: '1995-08-01', height: 188, weight: 82, preferredFoot: 'Right', club: 'America Mineiro', clubLeague: 'Serie A Brazil', marketValue: 800000, caps: 10, goals: 0 },
      { firstName: 'Santiago', lastName: 'Arzamendia', jerseyNumber: 13, position: 'LB', dateOfBirth: '1998-05-05', height: 172, weight: 68, preferredFoot: 'Left', club: 'Monterrey', clubLeague: 'Liga MX', marketValue: 3000000, caps: 20, goals: 0 },
      { firstName: 'Andres', lastName: 'Cubas', jerseyNumber: 14, position: 'CDM', dateOfBirth: '1996-04-16', height: 180, weight: 76, preferredFoot: 'Right', club: 'Vancouver Whitecaps', clubLeague: 'MLS', marketValue: 2500000, caps: 15, goals: 0 },
      { firstName: 'Hernesto', lastName: 'Caballero', jerseyNumber: 15, position: 'CM', dateOfBirth: '1999-02-14', height: 175, weight: 70, preferredFoot: 'Right', club: 'Libertad', clubLeague: 'Division Profesional', marketValue: 1500000, caps: 10, goals: 0 },
      { firstName: 'Robert', lastName: 'Morales', jerseyNumber: 16, position: 'RB', dateOfBirth: '1992-02-14', height: 177, weight: 73, preferredFoot: 'Right', club: 'Cerro Porteno', clubLeague: 'Division Profesional', marketValue: 800000, caps: 15, goals: 1 },
      { firstName: 'Alejandro', lastName: 'Romero Gamarra', jerseyNumber: 17, position: 'CM', dateOfBirth: '1995-04-08', height: 174, weight: 69, preferredFoot: 'Right', club: 'Gremio', clubLeague: 'Serie A Brazil', marketValue: 4000000, caps: 30, goals: 2 },
      { firstName: 'Blas', lastName: 'Riveros', jerseyNumber: 18, position: 'LB', dateOfBirth: '1998-01-20', height: 177, weight: 72, preferredFoot: 'Left', club: 'Olimpia', clubLeague: 'Division Profesional', marketValue: 1000000, caps: 10, goals: 0 },
      { firstName: 'Derlis', lastName: 'Gonzalez', jerseyNumber: 19, position: 'RW', dateOfBirth: '1994-05-20', height: 175, weight: 68, preferredFoot: 'Right', club: 'Olimpia', clubLeague: 'Division Profesional', marketValue: 1500000, caps: 35, goals: 5 },
      { firstName: 'Antonio', lastName: 'Sanabria', jerseyNumber: 20, position: 'ST', dateOfBirth: '1996-03-04', height: 185, weight: 80, preferredFoot: 'Right', club: 'Torino', clubLeague: 'Serie A', marketValue: 10000000, caps: 35, goals: 10 },
      { firstName: 'Oscar', lastName: 'Cardozo', jerseyNumber: 21, position: 'ST', dateOfBirth: '1983-05-20', height: 193, weight: 88, preferredFoot: 'Right', club: 'Retired', clubLeague: '-', marketValue: 0, caps: 85, goals: 28 },
      { firstName: 'Robert', lastName: 'Piris da Motta', jerseyNumber: 22, position: 'LB', dateOfBirth: '1994-04-12', height: 180, weight: 76, preferredFoot: 'Left', club: 'Sao Paulo', clubLeague: 'Serie A Brazil', marketValue: 2500000, caps: 25, goals: 1 },
      { firstName: 'Carlos', lastName: 'Gonzalez', jerseyNumber: 23, position: 'GK', dateOfBirth: '1992-09-30', height: 186, weight: 80, preferredFoot: 'Right', club: 'Olimpia', clubLeague: 'Division Profesional', marketValue: 600000, caps: 5, goals: 0 },
      { firstName: 'Ramon', lastName: 'Sosa', jerseyNumber: 24, position: 'LW', dateOfBirth: '1999-09-20', height: 171, weight: 66, preferredFoot: 'Right', club: 'Talleres', clubLeague: 'Liga Argentina', marketValue: 4000000, caps: 10, goals: 2 },
      { firstName: 'Diego', lastName: 'Gomez', jerseyNumber: 25, position: 'CM', dateOfBirth: '2003-01-05', height: 175, weight: 68, preferredFoot: 'Right', club: 'Inter Miami', clubLeague: 'MLS', marketValue: 8000000, caps: 10, goals: 1 },
      { firstName: 'Wilder', lastName: 'Viera', jerseyNumber: 26, position: 'CM', dateOfBirth: '1999-07-07', height: 178, weight: 72, preferredFoot: 'Right', club: 'Libertad', clubLeague: 'Division Profesional', marketValue: 2000000, caps: 5, goals: 0 },
    ],
  },

  // ========== HAITI (HAI) ==========
  {
    name: 'Haiti',
    fifaCode: 'HAI',
    players: [
      { firstName: 'Josue', lastName: 'Duverger', jerseyNumber: 1, position: 'GK', dateOfBirth: '1993-05-12', height: 188, weight: 82, preferredFoot: 'Right', club: 'Louisville City', clubLeague: 'USL Championship', marketValue: 300000, caps: 25, goals: 0 },
      { firstName: 'Carlens', lastName: 'Arcus', jerseyNumber: 2, position: 'RB', dateOfBirth: '1996-09-28', height: 175, weight: 70, preferredFoot: 'Right', club: 'Rodez', clubLeague: 'Ligue 2', marketValue: 600000, caps: 35, goals: 1 },
      { firstName: 'Alex', lastName: 'Christian', jerseyNumber: 3, position: 'CB', dateOfBirth: '1995-03-21', height: 186, weight: 80, preferredFoot: 'Right', club: 'Real Esteli', clubLeague: 'Liga Primera Nicaragua', marketValue: 200000, caps: 20, goals: 1 },
      { firstName: 'Mechack', lastName: 'Jerome', jerseyNumber: 4, position: 'CB', dateOfBirth: '1990-06-25', height: 185, weight: 78, preferredFoot: 'Right', club: 'Montreal', clubLeague: 'MLS', marketValue: 400000, caps: 45, goals: 2 },
      { firstName: 'Ricardo', lastName: 'Ade', jerseyNumber: 5, position: 'CB', dateOfBirth: '1997-01-22', height: 188, weight: 82, preferredFoot: 'Right', club: 'Houston Dynamo', clubLeague: 'MLS', marketValue: 800000, caps: 15, goals: 0 },
      { firstName: 'Melchie', lastName: 'Dumornay', jerseyNumber: 6, position: 'CAM', dateOfBirth: '2003-08-17', height: 160, weight: 54, preferredFoot: 'Right', club: 'Lyon', clubLeague: 'D1 Feminine', marketValue: 100000, caps: 15, goals: 4 },
      { firstName: 'Derrick', lastName: 'Etienne Jr', jerseyNumber: 7, position: 'LW', dateOfBirth: '1996-06-22', height: 175, weight: 70, preferredFoot: 'Right', club: 'Columbus Crew', clubLeague: 'MLS', marketValue: 1500000, caps: 40, goals: 7 },
      { firstName: 'Zachary', lastName: 'Herivaux', jerseyNumber: 8, position: 'CM', dateOfBirth: '1997-01-08', height: 178, weight: 72, preferredFoot: 'Right', club: 'Rio Grande Valley FC', clubLeague: 'USL Championship', marketValue: 200000, caps: 25, goals: 2 },
      { firstName: 'Duckens', lastName: 'Nazon', jerseyNumber: 9, position: 'ST', dateOfBirth: '1994-04-18', height: 178, weight: 73, preferredFoot: 'Right', club: 'Sint-Truiden', clubLeague: 'Belgian First Division', marketValue: 800000, caps: 45, goals: 15 },
      { firstName: 'Frantzdy', lastName: 'Pierrot', jerseyNumber: 10, position: 'ST', dateOfBirth: '1995-06-18', height: 193, weight: 90, preferredFoot: 'Right', club: 'Goztepe', clubLeague: 'Super Lig', marketValue: 1500000, caps: 25, goals: 9 },
      { firstName: 'Stephane', lastName: 'Lambese', jerseyNumber: 11, position: 'LW', dateOfBirth: '1994-10-24', height: 175, weight: 70, preferredFoot: 'Right', club: 'Free Agent', clubLeague: '-', marketValue: 100000, caps: 20, goals: 2 },
      { firstName: 'Johnny', lastName: 'Placide', jerseyNumber: 12, position: 'GK', dateOfBirth: '1988-01-05', height: 183, weight: 78, preferredFoot: 'Right', club: 'Guingamp', clubLeague: 'Ligue 2', marketValue: 300000, caps: 40, goals: 0 },
      { firstName: 'Ronaldo', lastName: 'Damus', jerseyNumber: 13, position: 'ST', dateOfBirth: '1999-06-25', height: 180, weight: 75, preferredFoot: 'Right', club: 'FC Zurich', clubLeague: 'Swiss Super League', marketValue: 600000, caps: 15, goals: 4 },
      { firstName: 'Steven', lastName: 'Seance', jerseyNumber: 14, position: 'CM', dateOfBirth: '1993-12-04', height: 175, weight: 70, preferredFoot: 'Right', club: 'AS Beauvais', clubLeague: 'National 2', marketValue: 100000, caps: 15, goals: 1 },
      { firstName: 'Bryan', lastName: 'Alceus', jerseyNumber: 15, position: 'CB', dateOfBirth: '2000-09-15', height: 186, weight: 78, preferredFoot: 'Right', club: 'Philadelphia Union II', clubLeague: 'MLS Next Pro', marketValue: 300000, caps: 10, goals: 0 },
      { firstName: 'Nathaniel', lastName: 'Saint-Felix', jerseyNumber: 16, position: 'CM', dateOfBirth: '1998-03-05', height: 175, weight: 70, preferredFoot: 'Right', club: 'Racing Louisville', clubLeague: 'USL Championship', marketValue: 200000, caps: 8, goals: 0 },
      { firstName: 'Jean-Sylvain', lastName: 'Babin', jerseyNumber: 17, position: 'CB', dateOfBirth: '1985-02-23', height: 186, weight: 80, preferredFoot: 'Right', club: 'Valladolid', clubLeague: 'La Liga 2', marketValue: 200000, caps: 35, goals: 1 },
      { firstName: 'Emmanuel', lastName: 'Riviere', jerseyNumber: 18, position: 'ST', dateOfBirth: '1990-03-03', height: 184, weight: 78, preferredFoot: 'Right', club: 'Free Agent', clubLeague: '-', marketValue: 100000, caps: 15, goals: 3 },
      { firstName: 'Soni', lastName: 'Mustivar', jerseyNumber: 19, position: 'CDM', dateOfBirth: '1990-07-03', height: 180, weight: 75, preferredFoot: 'Right', club: 'Sporting Kansas City', clubLeague: 'MLS', marketValue: 500000, caps: 30, goals: 0 },
      { firstName: 'James', lastName: 'Marcelin', jerseyNumber: 20, position: 'CM', dateOfBirth: '1988-11-18', height: 175, weight: 70, preferredFoot: 'Right', club: 'Sacramento Republic', clubLeague: 'USL Championship', marketValue: 200000, caps: 20, goals: 1 },
      { firstName: 'Andrew', lastName: 'Jean-Baptiste', jerseyNumber: 21, position: 'CB', dateOfBirth: '1992-12-27', height: 193, weight: 86, preferredFoot: 'Right', club: 'Colorado Rapids', clubLeague: 'MLS', marketValue: 400000, caps: 10, goals: 0 },
      { firstName: 'Louis', lastName: 'Labaze', jerseyNumber: 22, position: 'GK', dateOfBirth: '1996-02-15', height: 186, weight: 80, preferredFoot: 'Right', club: 'Violette AC', clubLeague: 'Ligue Haitienne', marketValue: 100000, caps: 5, goals: 0 },
      { firstName: 'Alex', lastName: 'Junior', jerseyNumber: 23, position: 'LB', dateOfBirth: '1997-07-18', height: 175, weight: 70, preferredFoot: 'Left', club: 'Arcahaie FC', clubLeague: 'Ligue Haitienne', marketValue: 100000, caps: 12, goals: 0 },
      { firstName: 'Carlin', lastName: 'Isidor', jerseyNumber: 24, position: 'ST', dateOfBirth: '1998-08-29', height: 183, weight: 78, preferredFoot: 'Right', club: 'Zenit St Petersburg', clubLeague: 'Russian Premier League', marketValue: 2500000, caps: 8, goals: 2 },
      { firstName: 'Steeven', lastName: 'Saba', jerseyNumber: 25, position: 'CM', dateOfBirth: '1999-01-01', height: 178, weight: 72, preferredFoot: 'Right', club: 'Violette AC', clubLeague: 'Ligue Haitienne', marketValue: 100000, caps: 5, goals: 0 },
      { firstName: 'Leverton', lastName: 'Pierre', jerseyNumber: 26, position: 'RB', dateOfBirth: '2001-03-10', height: 175, weight: 68, preferredFoot: 'Right', club: 'AS Capoise', clubLeague: 'Ligue Haitienne', marketValue: 100000, caps: 3, goals: 0 },
    ],
  },

  // ========== SCOTLAND (SCO) ==========
  {
    name: 'Scotland',
    fifaCode: 'SCO',
    players: [
      { firstName: 'Angus', lastName: 'Gunn', jerseyNumber: 1, position: 'GK', dateOfBirth: '1996-01-22', height: 198, weight: 90, preferredFoot: 'Right', club: 'Norwich City', clubLeague: 'Championship', marketValue: 3000000, caps: 10, goals: 0 },
      { firstName: 'Anthony', lastName: 'Ralston', jerseyNumber: 2, position: 'RB', dateOfBirth: '1998-11-16', height: 181, weight: 75, preferredFoot: 'Right', club: 'Celtic', clubLeague: 'Scottish Premiership', marketValue: 4000000, caps: 20, goals: 0 },
      { firstName: 'Andrew', lastName: 'Robertson', jerseyNumber: 3, position: 'LB', dateOfBirth: '1994-03-11', height: 178, weight: 76, preferredFoot: 'Left', club: 'Liverpool', clubLeague: 'Premier League', marketValue: 30000000, caps: 70, goals: 3 },
      { firstName: 'Scott', lastName: 'McTominay', jerseyNumber: 4, position: 'CM', dateOfBirth: '1996-12-08', height: 193, weight: 80, preferredFoot: 'Right', club: 'Napoli', clubLeague: 'Serie A', marketValue: 30000000, caps: 50, goals: 9 },
      { firstName: 'Grant', lastName: 'Hanley', jerseyNumber: 5, position: 'CB', dateOfBirth: '1991-11-20', height: 185, weight: 82, preferredFoot: 'Right', club: 'Norwich City', clubLeague: 'Championship', marketValue: 1500000, caps: 45, goals: 2 },
      { firstName: 'Callum', lastName: 'McGregor', jerseyNumber: 6, position: 'CM', dateOfBirth: '1993-06-14', height: 179, weight: 70, preferredFoot: 'Right', club: 'Celtic', clubLeague: 'Scottish Premiership', marketValue: 10000000, caps: 65, goals: 5 },
      { firstName: 'John', lastName: 'McGinn', jerseyNumber: 7, position: 'CM', dateOfBirth: '1994-10-18', height: 178, weight: 76, preferredFoot: 'Left', club: 'Aston Villa', clubLeague: 'Premier League', marketValue: 35000000, caps: 60, goals: 16 },
      { firstName: 'Stuart', lastName: 'Armstrong', jerseyNumber: 8, position: 'CAM', dateOfBirth: '1992-03-30', height: 183, weight: 75, preferredFoot: 'Right', club: 'Southampton', clubLeague: 'Championship', marketValue: 4000000, caps: 40, goals: 5 },
      { firstName: 'Lyndon', lastName: 'Dykes', jerseyNumber: 9, position: 'ST', dateOfBirth: '1995-08-07', height: 188, weight: 84, preferredFoot: 'Right', club: 'QPR', clubLeague: 'Championship', marketValue: 3500000, caps: 35, goals: 9 },
      { firstName: 'Che', lastName: 'Adams', jerseyNumber: 10, position: 'ST', dateOfBirth: '1996-07-13', height: 175, weight: 70, preferredFoot: 'Right', club: 'Torino', clubLeague: 'Serie A', marketValue: 12000000, caps: 25, goals: 5 },
      { firstName: 'Ryan', lastName: 'Christie', jerseyNumber: 11, position: 'CAM', dateOfBirth: '1995-02-22', height: 178, weight: 72, preferredFoot: 'Right', club: 'Bournemouth', clubLeague: 'Premier League', marketValue: 8000000, caps: 45, goals: 6 },
      { firstName: 'Craig', lastName: 'Gordon', jerseyNumber: 12, position: 'GK', dateOfBirth: '1982-12-31', height: 193, weight: 80, preferredFoot: 'Right', club: 'Hearts', clubLeague: 'Scottish Premiership', marketValue: 400000, caps: 75, goals: 0 },
      { firstName: 'Jack', lastName: 'Hendry', jerseyNumber: 13, position: 'CB', dateOfBirth: '1995-05-07', height: 187, weight: 80, preferredFoot: 'Right', club: 'Al-Ettifaq', clubLeague: 'Saudi Pro League', marketValue: 4000000, caps: 30, goals: 1 },
      { firstName: 'Billy', lastName: 'Gilmour', jerseyNumber: 14, position: 'CM', dateOfBirth: '2001-06-11', height: 170, weight: 62, preferredFoot: 'Right', club: 'Brighton', clubLeague: 'Premier League', marketValue: 15000000, caps: 25, goals: 0 },
      { firstName: 'Liam', lastName: 'Cooper', jerseyNumber: 15, position: 'CB', dateOfBirth: '1991-08-30', height: 186, weight: 82, preferredFoot: 'Left', club: 'Leeds United', clubLeague: 'Championship', marketValue: 3000000, caps: 15, goals: 0 },
      { firstName: 'Lewis', lastName: 'Ferguson', jerseyNumber: 16, position: 'CM', dateOfBirth: '1999-08-24', height: 180, weight: 75, preferredFoot: 'Right', club: 'Bologna', clubLeague: 'Serie A', marketValue: 20000000, caps: 15, goals: 2 },
      { firstName: 'Stuart', lastName: 'Findlay', jerseyNumber: 17, position: 'CB', dateOfBirth: '1995-09-04', height: 188, weight: 82, preferredFoot: 'Right', club: 'Kilmarnock', clubLeague: 'Scottish Premiership', marketValue: 800000, caps: 10, goals: 0 },
      { firstName: 'Aaron', lastName: 'Hickey', jerseyNumber: 18, position: 'LB', dateOfBirth: '2002-06-10', height: 179, weight: 70, preferredFoot: 'Both', club: 'Brentford', clubLeague: 'Premier League', marketValue: 18000000, caps: 15, goals: 0 },
      { firstName: 'Lawrence', lastName: 'Shankland', jerseyNumber: 19, position: 'ST', dateOfBirth: '1995-08-10', height: 178, weight: 75, preferredFoot: 'Right', club: 'Hearts', clubLeague: 'Scottish Premiership', marketValue: 3000000, caps: 15, goals: 5 },
      { firstName: 'Ross', lastName: 'McCrorie', jerseyNumber: 20, position: 'RB', dateOfBirth: '1998-03-18', height: 183, weight: 78, preferredFoot: 'Right', club: 'Bristol City', clubLeague: 'Championship', marketValue: 2000000, caps: 10, goals: 0 },
      { firstName: 'Kenny', lastName: 'McLean', jerseyNumber: 21, position: 'CM', dateOfBirth: '1992-01-08', height: 183, weight: 78, preferredFoot: 'Right', club: 'Norwich City', clubLeague: 'Championship', marketValue: 2000000, caps: 35, goals: 1 },
      { firstName: 'Liam', lastName: 'Kelly', jerseyNumber: 22, position: 'GK', dateOfBirth: '1996-01-23', height: 188, weight: 82, preferredFoot: 'Right', club: 'Rangers', clubLeague: 'Scottish Premiership', marketValue: 1000000, caps: 5, goals: 0 },
      { firstName: 'Kieran', lastName: 'Tierney', jerseyNumber: 23, position: 'LB', dateOfBirth: '1997-06-05', height: 180, weight: 75, preferredFoot: 'Left', club: 'Real Sociedad', clubLeague: 'La Liga', marketValue: 25000000, caps: 45, goals: 1 },
      { firstName: 'Greg', lastName: 'Taylor', jerseyNumber: 24, position: 'LB', dateOfBirth: '1997-11-05', height: 170, weight: 66, preferredFoot: 'Left', club: 'Celtic', clubLeague: 'Scottish Premiership', marketValue: 3000000, caps: 15, goals: 0 },
      { firstName: 'Ryan', lastName: 'Porteous', jerseyNumber: 25, position: 'CB', dateOfBirth: '1999-03-25', height: 186, weight: 80, preferredFoot: 'Right', club: 'Watford', clubLeague: 'Championship', marketValue: 3000000, caps: 10, goals: 0 },
      { firstName: 'James', lastName: 'Forrest', jerseyNumber: 26, position: 'RW', dateOfBirth: '1991-07-07', height: 170, weight: 68, preferredFoot: 'Right', club: 'Celtic', clubLeague: 'Scottish Premiership', marketValue: 2000000, caps: 50, goals: 5 },
    ],
  },

  // ========== CAPE VERDE (CPV) ==========
  {
    name: 'Cape Verde',
    fifaCode: 'CPV',
    players: [
      { firstName: 'Vozinha', lastName: '', commonName: 'Vozinha', jerseyNumber: 1, position: 'GK', dateOfBirth: '1986-02-20', height: 188, weight: 80, preferredFoot: 'Right', club: 'Gil Vicente', clubLeague: 'Liga Portugal', marketValue: 300000, caps: 35, goals: 0 },
      { firstName: 'Steven', lastName: 'Fortes', jerseyNumber: 2, position: 'CB', dateOfBirth: '1992-06-18', height: 185, weight: 80, preferredFoot: 'Right', club: 'Lens', clubLeague: 'Ligue 1', marketValue: 2500000, caps: 45, goals: 2 },
      { firstName: 'Roberto', lastName: 'Lopes', jerseyNumber: 3, position: 'CB', dateOfBirth: '1992-11-05', height: 185, weight: 78, preferredFoot: 'Right', club: 'Shamrock Rovers', clubLeague: 'League of Ireland Premier', marketValue: 400000, caps: 20, goals: 1 },
      { firstName: 'Stopira', lastName: '', commonName: 'Stopira', jerseyNumber: 4, position: 'CB', dateOfBirth: '1988-04-13', height: 187, weight: 82, preferredFoot: 'Right', club: 'FC Sheriff', clubLeague: 'Moldovan National Division', marketValue: 400000, caps: 55, goals: 3 },
      { firstName: 'Jeffry', lastName: 'Fortes', jerseyNumber: 5, position: 'LB', dateOfBirth: '1995-08-06', height: 175, weight: 70, preferredFoot: 'Left', club: 'Fortuna Sittard', clubLeague: 'Eredivisie', marketValue: 800000, caps: 20, goals: 0 },
      { firstName: 'Kenny', lastName: 'Rocha', jerseyNumber: 6, position: 'CM', dateOfBirth: '1993-01-09', height: 183, weight: 78, preferredFoot: 'Right', club: 'Gil Vicente', clubLeague: 'Liga Portugal', marketValue: 800000, caps: 35, goals: 2 },
      { firstName: 'Ryan', lastName: 'Mendes', jerseyNumber: 7, position: 'RW', dateOfBirth: '1990-01-08', height: 172, weight: 68, preferredFoot: 'Right', club: 'Al-Hazem', clubLeague: 'Saudi First Division', marketValue: 600000, caps: 50, goals: 8 },
      { firstName: 'Jamiro', lastName: 'Monteiro', jerseyNumber: 8, position: 'CAM', dateOfBirth: '1993-11-24', height: 178, weight: 72, preferredFoot: 'Right', club: 'Philadelphia Union', clubLeague: 'MLS', marketValue: 2500000, caps: 25, goals: 5 },
      { firstName: 'Garry', lastName: 'Rodrigues', jerseyNumber: 9, position: 'LW', dateOfBirth: '1990-11-27', height: 184, weight: 76, preferredFoot: 'Right', club: 'Olympiacos', clubLeague: 'Super League Greece', marketValue: 2500000, caps: 45, goals: 12 },
      { firstName: 'Heldon', lastName: '', commonName: 'Heldon', jerseyNumber: 10, position: 'RW', dateOfBirth: '1988-05-10', height: 172, weight: 68, preferredFoot: 'Right', club: 'Retired', clubLeague: '-', marketValue: 0, caps: 50, goals: 5 },
      { firstName: 'Jovane', lastName: 'Cabral', jerseyNumber: 11, position: 'LW', dateOfBirth: '1998-06-14', height: 177, weight: 70, preferredFoot: 'Right', club: 'Lazio', clubLeague: 'Serie A', marketValue: 5000000, caps: 15, goals: 3 },
      { firstName: 'Marcio', lastName: 'Rosa', jerseyNumber: 12, position: 'GK', dateOfBirth: '1995-03-22', height: 186, weight: 80, preferredFoot: 'Right', club: 'Casa Pia', clubLeague: 'Liga Portugal', marketValue: 500000, caps: 10, goals: 0 },
      { firstName: 'Dylan', lastName: 'Tavares', jerseyNumber: 13, position: 'RB', dateOfBirth: '1998-08-30', height: 178, weight: 72, preferredFoot: 'Right', club: 'Rio Ave', clubLeague: 'Liga Portugal', marketValue: 600000, caps: 10, goals: 0 },
      { firstName: 'Nuno', lastName: 'Borges', jerseyNumber: 14, position: 'CM', dateOfBirth: '1996-05-14', height: 180, weight: 74, preferredFoot: 'Right', club: 'Moreirense', clubLeague: 'Liga Portugal', marketValue: 600000, caps: 15, goals: 1 },
      { firstName: 'Carlos', lastName: 'Graça', jerseyNumber: 15, position: 'CB', dateOfBirth: '1999-02-15', height: 186, weight: 80, preferredFoot: 'Right', club: 'Sporting CP B', clubLeague: 'Liga Portugal 2', marketValue: 400000, caps: 8, goals: 0 },
      { firstName: 'Patrick', lastName: 'Andrade', jerseyNumber: 16, position: 'CM', dateOfBirth: '1994-05-29', height: 182, weight: 76, preferredFoot: 'Right', club: 'Al-Taawoun', clubLeague: 'Saudi Pro League', marketValue: 1200000, caps: 40, goals: 3 },
      { firstName: 'Leandro', lastName: 'Brito', jerseyNumber: 17, position: 'RB', dateOfBirth: '1993-08-09', height: 175, weight: 70, preferredFoot: 'Right', club: 'Casa Pia', clubLeague: 'Liga Portugal', marketValue: 500000, caps: 20, goals: 0 },
      { firstName: 'Kelvin', lastName: 'Pires', jerseyNumber: 18, position: 'LW', dateOfBirth: '2002-06-23', height: 172, weight: 66, preferredFoot: 'Right', club: 'Mafra', clubLeague: 'Liga Portugal 2', marketValue: 300000, caps: 5, goals: 0 },
      { firstName: 'Willy', lastName: 'Semedo', jerseyNumber: 19, position: 'CDM', dateOfBirth: '1991-06-20', height: 184, weight: 78, preferredFoot: 'Right', club: 'Vizela', clubLeague: 'Liga Portugal', marketValue: 500000, caps: 30, goals: 0 },
      { firstName: 'Julio', lastName: 'Tavares', jerseyNumber: 20, position: 'ST', dateOfBirth: '1988-08-13', height: 189, weight: 85, preferredFoot: 'Right', club: 'Dijon', clubLeague: 'Ligue 2', marketValue: 600000, caps: 45, goals: 16 },
      { firstName: 'Bruno', lastName: 'Varela', jerseyNumber: 21, position: 'GK', dateOfBirth: '1994-11-04', height: 190, weight: 82, preferredFoot: 'Right', club: 'Vitoria Guimaraes', clubLeague: 'Liga Portugal', marketValue: 1500000, caps: 5, goals: 0 },
      { firstName: 'Djaniny', lastName: '', commonName: 'Djaniny', jerseyNumber: 22, position: 'ST', dateOfBirth: '1991-05-21', height: 177, weight: 74, preferredFoot: 'Right', club: 'Al-Ahli', clubLeague: 'Saudi Pro League', marketValue: 2000000, caps: 30, goals: 8 },
      { firstName: 'Gilson', lastName: 'Benchimol', jerseyNumber: 23, position: 'RB', dateOfBirth: '1999-04-17', height: 175, weight: 70, preferredFoot: 'Right', club: 'Boavista', clubLeague: 'Liga Portugal', marketValue: 600000, caps: 8, goals: 0 },
      { firstName: 'Diney', lastName: 'Borges', jerseyNumber: 24, position: 'ST', dateOfBirth: '1999-09-18', height: 180, weight: 75, preferredFoot: 'Right', club: 'Tondela', clubLeague: 'Liga Portugal 2', marketValue: 400000, caps: 5, goals: 1 },
      { firstName: 'Logan', lastName: 'Costa', jerseyNumber: 25, position: 'CB', dateOfBirth: '2001-03-01', height: 186, weight: 78, preferredFoot: 'Right', club: 'Toulouse', clubLeague: 'Ligue 1', marketValue: 5000000, caps: 10, goals: 0 },
      { firstName: 'Pedro', lastName: 'Brito', jerseyNumber: 26, position: 'CM', dateOfBirth: '2000-07-25', height: 178, weight: 72, preferredFoot: 'Right', club: 'Arouca', clubLeague: 'Liga Portugal', marketValue: 400000, caps: 3, goals: 0 },
    ],
  },

  // ========== NORWAY (NOR) ==========
  {
    name: 'Norway',
    fifaCode: 'NOR',
    players: [
      { firstName: 'Orjan', lastName: 'Nyland', jerseyNumber: 1, position: 'GK', dateOfBirth: '1990-09-10', height: 188, weight: 82, preferredFoot: 'Right', club: 'Sevilla', clubLeague: 'La Liga', marketValue: 2500000, caps: 45, goals: 0 },
      { firstName: 'Marcus', lastName: 'Pedersen', jerseyNumber: 2, position: 'RB', dateOfBirth: '2000-06-16', height: 183, weight: 75, preferredFoot: 'Right', club: 'Feyenoord', clubLeague: 'Eredivisie', marketValue: 6000000, caps: 20, goals: 0 },
      { firstName: 'Kristoffer', lastName: 'Ajer', jerseyNumber: 3, position: 'CB', dateOfBirth: '1998-04-17', height: 198, weight: 90, preferredFoot: 'Right', club: 'Brentford', clubLeague: 'Premier League', marketValue: 18000000, caps: 40, goals: 2 },
      { firstName: 'Stefan', lastName: 'Strandberg', jerseyNumber: 4, position: 'CB', dateOfBirth: '1990-07-25', height: 189, weight: 84, preferredFoot: 'Right', club: 'Salernitana', clubLeague: 'Serie A', marketValue: 2000000, caps: 45, goals: 2 },
      { firstName: 'Birger', lastName: 'Meling', jerseyNumber: 5, position: 'LB', dateOfBirth: '1994-12-17', height: 181, weight: 74, preferredFoot: 'Left', club: 'Rennes', clubLeague: 'Ligue 1', marketValue: 6000000, caps: 45, goals: 1 },
      { firstName: 'Morten', lastName: 'Thorsby', jerseyNumber: 6, position: 'CDM', dateOfBirth: '1996-05-05', height: 187, weight: 80, preferredFoot: 'Right', club: 'Union Berlin', clubLeague: 'Bundesliga', marketValue: 6000000, caps: 50, goals: 3 },
      { firstName: 'Sander', lastName: 'Berge', jerseyNumber: 8, position: 'CM', dateOfBirth: '1998-02-14', height: 195, weight: 85, preferredFoot: 'Right', club: 'Fulham', clubLeague: 'Premier League', marketValue: 25000000, caps: 55, goals: 4 },
      { firstName: 'Erling', lastName: 'Haaland', jerseyNumber: 9, position: 'ST', dateOfBirth: '2000-07-21', height: 194, weight: 88, preferredFoot: 'Left', club: 'Manchester City', clubLeague: 'Premier League', marketValue: 180000000, caps: 35, goals: 31 },
      { firstName: 'Martin', lastName: 'Odegaard', jerseyNumber: 10, position: 'CAM', dateOfBirth: '1998-12-17', height: 178, weight: 68, preferredFoot: 'Left', club: 'Arsenal', clubLeague: 'Premier League', marketValue: 90000000, caps: 60, goals: 9 },
      { firstName: 'Mohamed', lastName: 'Elyounoussi', jerseyNumber: 11, position: 'LW', dateOfBirth: '1994-08-04', height: 178, weight: 72, preferredFoot: 'Right', club: 'Celtic', clubLeague: 'Scottish Premiership', marketValue: 4000000, caps: 60, goals: 11 },
      { firstName: 'Sten', lastName: 'Grytebust', jerseyNumber: 12, position: 'GK', dateOfBirth: '1989-09-25', height: 188, weight: 82, preferredFoot: 'Right', club: 'Copenhagen', clubLeague: 'Danish Superliga', marketValue: 800000, caps: 10, goals: 0 },
      { firstName: 'Julian', lastName: 'Ryerson', jerseyNumber: 13, position: 'RB', dateOfBirth: '1997-11-17', height: 180, weight: 74, preferredFoot: 'Right', club: 'Borussia Dortmund', clubLeague: 'Bundesliga', marketValue: 12000000, caps: 20, goals: 0 },
      { firstName: 'Fredrik', lastName: 'Midtsjo', jerseyNumber: 14, position: 'CM', dateOfBirth: '1993-08-11', height: 186, weight: 78, preferredFoot: 'Right', club: 'AZ Alkmaar', clubLeague: 'Eredivisie', marketValue: 5000000, caps: 35, goals: 1 },
      { firstName: 'Leo', lastName: 'Ostigard', jerseyNumber: 15, position: 'CB', dateOfBirth: '1999-11-28', height: 184, weight: 80, preferredFoot: 'Right', club: 'Napoli', clubLeague: 'Serie A', marketValue: 12000000, caps: 20, goals: 2 },
      { firstName: 'Patrick', lastName: 'Berg', jerseyNumber: 16, position: 'CM', dateOfBirth: '1997-11-24', height: 186, weight: 78, preferredFoot: 'Right', club: 'Bodo/Glimt', clubLeague: 'Eliteserien', marketValue: 5000000, caps: 15, goals: 0 },
      { firstName: 'Fredrik', lastName: 'Aursnes', jerseyNumber: 17, position: 'CM', dateOfBirth: '1995-12-10', height: 180, weight: 72, preferredFoot: 'Right', club: 'Benfica', clubLeague: 'Liga Portugal', marketValue: 18000000, caps: 25, goals: 1 },
      { firstName: 'David', lastName: 'Datro Fofana', jerseyNumber: 18, position: 'ST', dateOfBirth: '2002-12-22', height: 177, weight: 70, preferredFoot: 'Right', club: 'Chelsea', clubLeague: 'Premier League', marketValue: 8000000, caps: 5, goals: 0 },
      { firstName: 'Antonio', lastName: 'Nusa', jerseyNumber: 19, position: 'LW', dateOfBirth: '2005-04-17', height: 173, weight: 66, preferredFoot: 'Right', club: 'RB Leipzig', clubLeague: 'Bundesliga', marketValue: 25000000, caps: 10, goals: 1 },
      { firstName: 'Alexander', lastName: 'Sorloth', jerseyNumber: 20, position: 'ST', dateOfBirth: '1995-12-05', height: 195, weight: 88, preferredFoot: 'Right', club: 'Atletico Madrid', clubLeague: 'La Liga', marketValue: 25000000, caps: 50, goals: 14 },
      { firstName: 'Jorgen Strand', lastName: 'Larsen', jerseyNumber: 21, position: 'ST', dateOfBirth: '2000-02-06', height: 183, weight: 78, preferredFoot: 'Right', club: 'Wolfsburg', clubLeague: 'Bundesliga', marketValue: 8000000, caps: 10, goals: 3 },
      { firstName: 'Jens Petter', lastName: 'Hauge', jerseyNumber: 22, position: 'LW', dateOfBirth: '1999-10-12', height: 181, weight: 74, preferredFoot: 'Right', club: 'Bodo/Glimt', clubLeague: 'Eliteserien', marketValue: 5000000, caps: 15, goals: 1 },
      { firstName: 'Marius', lastName: 'Lode', jerseyNumber: 23, position: 'GK', dateOfBirth: '1993-01-04', height: 188, weight: 82, preferredFoot: 'Right', club: 'Bodo/Glimt', clubLeague: 'Eliteserien', marketValue: 2000000, caps: 5, goals: 0 },
      { firstName: 'Oscar', lastName: 'Bobb', jerseyNumber: 24, position: 'RW', dateOfBirth: '2003-07-12', height: 174, weight: 66, preferredFoot: 'Left', club: 'Manchester City', clubLeague: 'Premier League', marketValue: 20000000, caps: 5, goals: 0 },
      { firstName: 'Andreas', lastName: 'Hanche-Olsen', jerseyNumber: 25, position: 'CB', dateOfBirth: '1997-01-17', height: 188, weight: 82, preferredFoot: 'Right', club: 'Genoa', clubLeague: 'Serie A', marketValue: 5000000, caps: 15, goals: 0 },
      { firstName: 'Stale', lastName: 'Solbakken', jerseyNumber: 26, position: 'CM', dateOfBirth: '2003-08-14', height: 175, weight: 68, preferredFoot: 'Right', club: 'Roma', clubLeague: 'Serie A', marketValue: 3000000, caps: 3, goals: 0 },
    ],
  },

  // ========== JORDAN (JOR) ==========
  {
    name: 'Jordan',
    fifaCode: 'JOR',
    players: [
      { firstName: 'Yazeed', lastName: 'Abulaila', jerseyNumber: 1, position: 'GK', dateOfBirth: '1998-09-14', height: 186, weight: 80, preferredFoot: 'Right', club: 'Al-Ramtha', clubLeague: 'Jordan Pro League', marketValue: 300000, caps: 20, goals: 0 },
      { firstName: 'Ahmad', lastName: 'Haikal', jerseyNumber: 2, position: 'RB', dateOfBirth: '1995-03-18', height: 178, weight: 72, preferredFoot: 'Right', club: 'Al-Wehdat', clubLeague: 'Jordan Pro League', marketValue: 400000, caps: 45, goals: 1 },
      { firstName: 'Abdallah', lastName: 'Nasib', jerseyNumber: 3, position: 'CB', dateOfBirth: '1993-01-20', height: 186, weight: 80, preferredFoot: 'Right', club: 'Al-Faisaly', clubLeague: 'Jordan Pro League', marketValue: 400000, caps: 55, goals: 3 },
      { firstName: 'Anas', lastName: 'Bani-Yaseen', jerseyNumber: 4, position: 'CB', dateOfBirth: '1989-02-25', height: 188, weight: 82, preferredFoot: 'Right', club: 'Al-Faisaly', clubLeague: 'Jordan Pro League', marketValue: 300000, caps: 80, goals: 5 },
      { firstName: 'Yazan', lastName: 'Al-Arab', jerseyNumber: 5, position: 'CB', dateOfBirth: '1996-06-15', height: 185, weight: 78, preferredFoot: 'Right', club: 'Al-Wehdat', clubLeague: 'Jordan Pro League', marketValue: 500000, caps: 35, goals: 2 },
      { firstName: 'Mousa', lastName: 'Al-Taamari', jerseyNumber: 7, position: 'LW', dateOfBirth: '1997-02-02', height: 175, weight: 68, preferredFoot: 'Right', club: 'Club Brugge', clubLeague: 'Belgian First Division', marketValue: 5000000, caps: 55, goals: 12 },
      { firstName: 'Baha', lastName: 'Faisal', jerseyNumber: 8, position: 'CM', dateOfBirth: '1994-08-15', height: 180, weight: 75, preferredFoot: 'Right', club: 'Al-Wehdat', clubLeague: 'Jordan Pro League', marketValue: 500000, caps: 50, goals: 3 },
      { firstName: 'Hamza', lastName: 'Al-Dardour', jerseyNumber: 9, position: 'ST', dateOfBirth: '1989-03-07', height: 180, weight: 78, preferredFoot: 'Right', club: 'Al-Faisaly', clubLeague: 'Jordan Pro League', marketValue: 300000, caps: 100, goals: 32 },
      { firstName: 'Ahmad', lastName: 'Ersan', jerseyNumber: 10, position: 'CM', dateOfBirth: '1989-01-22', height: 178, weight: 73, preferredFoot: 'Right', club: 'Al-Wehdat', clubLeague: 'Jordan Pro League', marketValue: 300000, caps: 90, goals: 10 },
      { firstName: 'Yazan', lastName: 'Al-Naimat', jerseyNumber: 11, position: 'ST', dateOfBirth: '1998-01-17', height: 182, weight: 76, preferredFoot: 'Right', club: 'Angers', clubLeague: 'Ligue 2', marketValue: 1500000, caps: 30, goals: 11 },
      { firstName: 'Ali', lastName: 'Olwan', jerseyNumber: 12, position: 'ST', dateOfBirth: '1998-10-05', height: 180, weight: 75, preferredFoot: 'Right', club: 'Al-Salt', clubLeague: 'Jordan Pro League', marketValue: 400000, caps: 20, goals: 5 },
      { firstName: 'Abdulla', lastName: 'Rawashdeh', jerseyNumber: 13, position: 'RW', dateOfBirth: '1995-06-20', height: 175, weight: 68, preferredFoot: 'Right', club: 'Al-Faisaly', clubLeague: 'Jordan Pro League', marketValue: 400000, caps: 35, goals: 3 },
      { firstName: 'Salem', lastName: 'Al-Ajalin', jerseyNumber: 14, position: 'LB', dateOfBirth: '1999-05-10', height: 175, weight: 70, preferredFoot: 'Left', club: 'Al-Ahli', clubLeague: 'Jordan Pro League', marketValue: 500000, caps: 20, goals: 0 },
      { firstName: 'Yosif', lastName: 'Al-Kalaldeh', jerseyNumber: 15, position: 'CB', dateOfBirth: '1998-04-22', height: 186, weight: 80, preferredFoot: 'Right', club: 'Al-Wehdat', clubLeague: 'Jordan Pro League', marketValue: 400000, caps: 15, goals: 0 },
      { firstName: 'Qusai', lastName: 'Al-Tamari', jerseyNumber: 16, position: 'CM', dateOfBirth: '2001-03-18', height: 178, weight: 72, preferredFoot: 'Right', club: 'Hapoel Be\'er Sheva', clubLeague: 'Israeli Premier League', marketValue: 800000, caps: 10, goals: 0 },
      { firstName: 'Nizar', lastName: 'Al-Rashdan', jerseyNumber: 17, position: 'CDM', dateOfBirth: '1993-07-12', height: 182, weight: 76, preferredFoot: 'Right', club: 'Al-Wehdat', clubLeague: 'Jordan Pro League', marketValue: 300000, caps: 45, goals: 1 },
      { firstName: 'Mohannad', lastName: 'Al-Namat', jerseyNumber: 18, position: 'LW', dateOfBirth: '2000-11-15', height: 173, weight: 66, preferredFoot: 'Right', club: 'Al-Arabi', clubLeague: 'Jordan Pro League', marketValue: 300000, caps: 8, goals: 1 },
      { firstName: 'Jihad', lastName: 'Al-Bahadri', jerseyNumber: 19, position: 'CM', dateOfBirth: '1999-09-25', height: 175, weight: 70, preferredFoot: 'Right', club: 'Al-Ramtha', clubLeague: 'Jordan Pro League', marketValue: 300000, caps: 10, goals: 0 },
      { firstName: 'Amr', lastName: 'Abujabel', jerseyNumber: 20, position: 'GK', dateOfBirth: '1992-03-05', height: 188, weight: 82, preferredFoot: 'Right', club: 'Al-Ahli', clubLeague: 'Jordan Pro League', marketValue: 200000, caps: 15, goals: 0 },
      { firstName: 'Hassan', lastName: 'Al-Tamari', jerseyNumber: 21, position: 'RW', dateOfBirth: '1999-08-21', height: 175, weight: 68, preferredFoot: 'Right', club: 'Al-Faisaly', clubLeague: 'Jordan Pro League', marketValue: 400000, caps: 12, goals: 2 },
      { firstName: 'Baha\'', lastName: 'Abdulrahman', jerseyNumber: 22, position: 'GK', dateOfBirth: '1997-02-10', height: 186, weight: 80, preferredFoot: 'Right', club: 'Al-Faisaly', clubLeague: 'Jordan Pro League', marketValue: 200000, caps: 5, goals: 0 },
      { firstName: 'Yazan', lastName: 'Tawaha', jerseyNumber: 23, position: 'RB', dateOfBirth: '1998-12-15', height: 178, weight: 72, preferredFoot: 'Right', club: 'Al-Salt', clubLeague: 'Jordan Pro League', marketValue: 300000, caps: 8, goals: 0 },
      { firstName: 'Obada', lastName: 'Al-Horani', jerseyNumber: 24, position: 'CM', dateOfBirth: '2002-06-18', height: 178, weight: 72, preferredFoot: 'Right', club: 'Al-Wehdat', clubLeague: 'Jordan Pro League', marketValue: 400000, caps: 5, goals: 0 },
      { firstName: 'Alaa', lastName: 'Al-Dali', jerseyNumber: 25, position: 'CB', dateOfBirth: '1999-10-08', height: 185, weight: 78, preferredFoot: 'Right', club: 'Al-Faisaly', clubLeague: 'Jordan Pro League', marketValue: 300000, caps: 5, goals: 0 },
      { firstName: 'Firas', lastName: 'Shelbaieh', jerseyNumber: 26, position: 'LW', dateOfBirth: '1999-03-25', height: 172, weight: 65, preferredFoot: 'Right', club: 'Esbjerg', clubLeague: 'Danish 1st Division', marketValue: 500000, caps: 15, goals: 2 },
    ],
  },

  // ========== CURACAO (CUR) ==========
  {
    name: 'Curacao',
    fifaCode: 'CUR',
    players: [
      { firstName: 'Eloy', lastName: 'Room', jerseyNumber: 1, position: 'GK', dateOfBirth: '1989-03-20', height: 195, weight: 88, preferredFoot: 'Right', club: 'Columbus Crew', clubLeague: 'MLS', marketValue: 600000, caps: 45, goals: 0 },
      { firstName: 'Jurien', lastName: 'Gaari', jerseyNumber: 2, position: 'RB', dateOfBirth: '1990-05-15', height: 180, weight: 75, preferredFoot: 'Right', club: 'Almere City', clubLeague: 'Eredivisie', marketValue: 400000, caps: 50, goals: 1 },
      { firstName: 'Cuco', lastName: 'Martina', jerseyNumber: 3, position: 'RB', dateOfBirth: '1989-09-25', height: 180, weight: 75, preferredFoot: 'Right', club: 'Jong PSV', clubLeague: 'Eerste Divisie', marketValue: 200000, caps: 45, goals: 1 },
      { firstName: 'Darryl', lastName: 'Lachman', jerseyNumber: 4, position: 'CB', dateOfBirth: '1989-07-09', height: 186, weight: 82, preferredFoot: 'Right', club: 'Free Agent', clubLeague: '-', marketValue: 100000, caps: 50, goals: 2 },
      { firstName: 'Shermaine', lastName: 'Martina', jerseyNumber: 5, position: 'CB', dateOfBirth: '1989-03-30', height: 188, weight: 84, preferredFoot: 'Right', club: 'Volendam', clubLeague: 'Eredivisie', marketValue: 300000, caps: 45, goals: 3 },
      { firstName: 'Leandro', lastName: 'Bacuna', jerseyNumber: 6, position: 'CM', dateOfBirth: '1991-08-21', height: 185, weight: 80, preferredFoot: 'Right', club: 'Cardiff City', clubLeague: 'Championship', marketValue: 1500000, caps: 60, goals: 8 },
      { firstName: 'Rangelo', lastName: 'Janga', jerseyNumber: 7, position: 'RW', dateOfBirth: '1992-10-16', height: 178, weight: 72, preferredFoot: 'Right', club: 'Slovan Liberec', clubLeague: 'Czech First League', marketValue: 800000, caps: 45, goals: 10 },
      { firstName: 'Quenten', lastName: 'Martinus', jerseyNumber: 8, position: 'CM', dateOfBirth: '1989-10-28', height: 175, weight: 70, preferredFoot: 'Right', club: 'Rodez', clubLeague: 'Ligue 2', marketValue: 400000, caps: 40, goals: 2 },
      { firstName: 'Gervane', lastName: 'Kastaneer', jerseyNumber: 9, position: 'ST', dateOfBirth: '1996-08-15', height: 182, weight: 78, preferredFoot: 'Right', club: 'Coventry City', clubLeague: 'Championship', marketValue: 1200000, caps: 25, goals: 8 },
      { firstName: 'Juninho', lastName: 'Bacuna', jerseyNumber: 10, position: 'CAM', dateOfBirth: '1997-08-07', height: 183, weight: 78, preferredFoot: 'Right', club: 'Rangers', clubLeague: 'Scottish Premiership', marketValue: 3000000, caps: 30, goals: 5 },
      { firstName: 'Kenji', lastName: 'Gorre', jerseyNumber: 11, position: 'LW', dateOfBirth: '1994-09-29', height: 168, weight: 62, preferredFoot: 'Left', club: 'Excelsior', clubLeague: 'Eredivisie', marketValue: 500000, caps: 35, goals: 4 },
      { firstName: 'Jairzinho', lastName: 'Pieter', jerseyNumber: 12, position: 'GK', dateOfBirth: '1994-06-18', height: 188, weight: 82, preferredFoot: 'Right', club: 'FC Eindhoven', clubLeague: 'Eerste Divisie', marketValue: 200000, caps: 10, goals: 0 },
      { firstName: 'Roly', lastName: 'Bonevacia', jerseyNumber: 13, position: 'CM', dateOfBirth: '1988-12-20', height: 180, weight: 75, preferredFoot: 'Right', club: 'Wellington Phoenix', clubLeague: 'A-League', marketValue: 300000, caps: 50, goals: 5 },
      { firstName: 'Brandley', lastName: 'Kuwas', jerseyNumber: 14, position: 'RW', dateOfBirth: '1992-08-14', height: 175, weight: 70, preferredFoot: 'Right', club: 'Heracles', clubLeague: 'Eredivisie', marketValue: 500000, caps: 40, goals: 8 },
      { firstName: 'Charlison', lastName: 'Benschop', jerseyNumber: 15, position: 'ST', dateOfBirth: '1989-08-21', height: 188, weight: 84, preferredFoot: 'Right', club: 'Pohang Steelers', clubLeague: 'K League 1', marketValue: 300000, caps: 35, goals: 10 },
      { firstName: 'Vurnon', lastName: 'Anita', jerseyNumber: 16, position: 'CDM', dateOfBirth: '1989-04-04', height: 172, weight: 66, preferredFoot: 'Right', club: 'RKC Waalwijk', clubLeague: 'Eredivisie', marketValue: 400000, caps: 45, goals: 1 },
      { firstName: 'Michael', lastName: 'Maria', jerseyNumber: 17, position: 'LB', dateOfBirth: '1996-05-31', height: 180, weight: 75, preferredFoot: 'Left', club: 'Go Ahead Eagles', clubLeague: 'Eredivisie', marketValue: 600000, caps: 25, goals: 1 },
      { firstName: 'Patrick', lastName: 'Joosten', jerseyNumber: 18, position: 'LW', dateOfBirth: '1996-01-18', height: 178, weight: 72, preferredFoot: 'Right', club: 'FC Utrecht', clubLeague: 'Eredivisie', marketValue: 800000, caps: 15, goals: 3 },
      { firstName: 'Shanon', lastName: 'Carmelia', jerseyNumber: 19, position: 'RW', dateOfBirth: '2003-11-05', height: 175, weight: 68, preferredFoot: 'Right', club: 'Feyenoord', clubLeague: 'Eredivisie', marketValue: 2000000, caps: 10, goals: 2 },
      { firstName: 'Kevin', lastName: 'Felida', jerseyNumber: 20, position: 'CM', dateOfBirth: '1997-12-08', height: 175, weight: 70, preferredFoot: 'Right', club: 'Helmond Sport', clubLeague: 'Eerste Divisie', marketValue: 200000, caps: 8, goals: 0 },
      { firstName: 'Gianni', lastName: 'Zuiverloon', jerseyNumber: 21, position: 'GK', dateOfBirth: '1995-09-28', height: 186, weight: 80, preferredFoot: 'Right', club: 'Heracles', clubLeague: 'Eredivisie', marketValue: 400000, caps: 5, goals: 0 },
      { firstName: 'Jafar', lastName: 'Arias', jerseyNumber: 22, position: 'ST', dateOfBirth: '1996-05-14', height: 178, weight: 74, preferredFoot: 'Right', club: 'FC Emmen', clubLeague: 'Eredivisie', marketValue: 500000, caps: 15, goals: 4 },
      { firstName: 'Elson', lastName: 'Hooi', jerseyNumber: 23, position: 'LW', dateOfBirth: '1991-12-21', height: 172, weight: 68, preferredFoot: 'Right', club: 'ADO Den Haag', clubLeague: 'Eerste Divisie', marketValue: 200000, caps: 30, goals: 6 },
      { firstName: 'Gevero', lastName: 'Markiet', jerseyNumber: 24, position: 'CB', dateOfBirth: '1998-02-15', height: 185, weight: 78, preferredFoot: 'Right', club: 'FC Den Bosch', clubLeague: 'Eerste Divisie', marketValue: 200000, caps: 10, goals: 0 },
      { firstName: 'Jarchino', lastName: 'Antonia', jerseyNumber: 25, position: 'LW', dateOfBirth: '1990-11-04', height: 170, weight: 65, preferredFoot: 'Right', club: 'Go Ahead Eagles', clubLeague: 'Eredivisie', marketValue: 300000, caps: 20, goals: 3 },
      { firstName: 'Riechedly', lastName: 'Bazoer', jerseyNumber: 26, position: 'CM', dateOfBirth: '1996-10-12', height: 185, weight: 78, preferredFoot: 'Right', club: 'Fenerbahce', clubLeague: 'Super Lig', marketValue: 4000000, caps: 5, goals: 0 },
    ],
  },

  // ========== UZBEKISTAN (UZB) ==========
  {
    name: 'Uzbekistan',
    fifaCode: 'UZB',
    players: [
      { firstName: 'Eldor', lastName: 'Suyunov', jerseyNumber: 1, position: 'GK', dateOfBirth: '1992-02-09', height: 186, weight: 80, preferredFoot: 'Right', club: 'Bunyodkor', clubLeague: 'Uzbekistan Super League', marketValue: 300000, caps: 25, goals: 0 },
      { firstName: 'Dostonbek', lastName: 'Khamdamov', jerseyNumber: 2, position: 'RB', dateOfBirth: '1993-02-05', height: 180, weight: 75, preferredFoot: 'Right', club: 'Pakhtakor', clubLeague: 'Uzbekistan Super League', marketValue: 400000, caps: 40, goals: 1 },
      { firstName: 'Ibrokhimkhalil', lastName: 'Tukhtasinov', jerseyNumber: 3, position: 'CB', dateOfBirth: '2001-08-09', height: 188, weight: 82, preferredFoot: 'Right', club: 'Pakhtakor', clubLeague: 'Uzbekistan Super League', marketValue: 600000, caps: 15, goals: 0 },
      { firstName: 'Husniddin', lastName: 'Alikulov', jerseyNumber: 4, position: 'CB', dateOfBirth: '1998-03-15', height: 186, weight: 80, preferredFoot: 'Right', club: 'AGMK', clubLeague: 'Uzbekistan Super League', marketValue: 500000, caps: 25, goals: 2 },
      { firstName: 'Akmal', lastName: 'Shorakhmedov', jerseyNumber: 5, position: 'CB', dateOfBirth: '1992-05-22', height: 188, weight: 84, preferredFoot: 'Right', club: 'Pakhtakor', clubLeague: 'Uzbekistan Super League', marketValue: 300000, caps: 60, goals: 3 },
      { firstName: 'Oston', lastName: 'Urunov', jerseyNumber: 6, position: 'CM', dateOfBirth: '1998-01-31', height: 178, weight: 72, preferredFoot: 'Right', club: 'Lens', clubLeague: 'Ligue 1', marketValue: 5000000, caps: 35, goals: 4 },
      { firstName: 'Jaloliddin', lastName: 'Masharipov', jerseyNumber: 7, position: 'RW', dateOfBirth: '1993-10-01', height: 177, weight: 70, preferredFoot: 'Right', club: 'Al-Ittihad', clubLeague: 'Saudi Pro League', marketValue: 3000000, caps: 65, goals: 10 },
      { firstName: 'Odil', lastName: 'Ahmedov', jerseyNumber: 8, position: 'CDM', dateOfBirth: '1987-11-25', height: 180, weight: 75, preferredFoot: 'Right', club: 'Pakhtakor', clubLeague: 'Uzbekistan Super League', marketValue: 300000, caps: 100, goals: 7 },
      { firstName: 'Eldor', lastName: 'Shomurodov', jerseyNumber: 9, position: 'ST', dateOfBirth: '1995-06-29', height: 190, weight: 82, preferredFoot: 'Right', club: 'Roma', clubLeague: 'Serie A', marketValue: 5000000, caps: 55, goals: 18 },
      { firstName: 'Ikboljon', lastName: 'Ergashev', jerseyNumber: 10, position: 'CM', dateOfBirth: '1999-09-08', height: 175, weight: 68, preferredFoot: 'Right', club: 'Urawa Red Diamonds', clubLeague: 'J1 League', marketValue: 1500000, caps: 25, goals: 2 },
      { firstName: 'Otabek', lastName: 'Shukurov', jerseyNumber: 11, position: 'LW', dateOfBirth: '1997-08-11', height: 180, weight: 74, preferredFoot: 'Right', club: 'FC Seoul', clubLeague: 'K League 1', marketValue: 1200000, caps: 40, goals: 5 },
      { firstName: 'Botir', lastName: 'Ergashev', jerseyNumber: 12, position: 'GK', dateOfBirth: '1995-03-22', height: 186, weight: 80, preferredFoot: 'Right', club: 'Nasaf', clubLeague: 'Uzbekistan Super League', marketValue: 200000, caps: 10, goals: 0 },
      { firstName: 'Abbos', lastName: 'Fayzullayev', jerseyNumber: 13, position: 'LW', dateOfBirth: '2004-09-08', height: 175, weight: 68, preferredFoot: 'Right', club: 'Dynamo Kyiv', clubLeague: 'Ukrainian Premier League', marketValue: 5000000, caps: 15, goals: 3 },
      { firstName: 'Azizbek', lastName: 'Turgunboev', jerseyNumber: 14, position: 'CB', dateOfBirth: '2000-04-17', height: 186, weight: 80, preferredFoot: 'Right', club: 'Neftchi Ferghana', clubLeague: 'Uzbekistan Super League', marketValue: 400000, caps: 15, goals: 0 },
      { firstName: 'Abdulla', lastName: 'Abdullaev', jerseyNumber: 15, position: 'ST', dateOfBirth: '2003-12-20', height: 182, weight: 75, preferredFoot: 'Right', club: 'AGMK', clubLeague: 'Uzbekistan Super League', marketValue: 800000, caps: 10, goals: 3 },
      { firstName: 'Jamshid', lastName: 'Iskanderov', jerseyNumber: 16, position: 'CDM', dateOfBirth: '1990-09-24', height: 182, weight: 76, preferredFoot: 'Right', club: 'Pakhtakor', clubLeague: 'Uzbekistan Super League', marketValue: 300000, caps: 40, goals: 1 },
      { firstName: 'Server', lastName: 'Djeparov', jerseyNumber: 17, position: 'CAM', dateOfBirth: '1982-11-03', height: 181, weight: 76, preferredFoot: 'Right', club: 'Retired', clubLeague: '-', marketValue: 0, caps: 130, goals: 27 },
      { firstName: 'Suhrob', lastName: 'Kholmatov', jerseyNumber: 18, position: 'RB', dateOfBirth: '1999-05-20', height: 178, weight: 72, preferredFoot: 'Right', club: 'Navbahor', clubLeague: 'Uzbekistan Super League', marketValue: 300000, caps: 15, goals: 0 },
      { firstName: 'Khojiakbar', lastName: 'Alijonov', jerseyNumber: 19, position: 'CAM', dateOfBirth: '2000-01-11', height: 178, weight: 72, preferredFoot: 'Right', club: 'Istanbul Basaksehir', clubLeague: 'Super Lig', marketValue: 2500000, caps: 25, goals: 3 },
      { firstName: 'Sardor', lastName: 'Rashidov', jerseyNumber: 20, position: 'RW', dateOfBirth: '1994-01-08', height: 173, weight: 66, preferredFoot: 'Right', club: 'Al-Sadd', clubLeague: 'Qatar Stars League', marketValue: 1500000, caps: 50, goals: 6 },
      { firstName: 'Islom', lastName: 'Tukhtakhujaev', jerseyNumber: 21, position: 'CM', dateOfBirth: '1996-03-30', height: 180, weight: 74, preferredFoot: 'Right', club: 'Pakhtakor', clubLeague: 'Uzbekistan Super League', marketValue: 500000, caps: 30, goals: 2 },
      { firstName: 'Donier', lastName: 'Islamov', jerseyNumber: 22, position: 'GK', dateOfBirth: '1990-06-10', height: 188, weight: 82, preferredFoot: 'Right', club: 'Bunyodkor', clubLeague: 'Uzbekistan Super League', marketValue: 200000, caps: 5, goals: 0 },
      { firstName: 'Aziz', lastName: 'Ganiev', jerseyNumber: 23, position: 'LB', dateOfBirth: '1997-11-15', height: 175, weight: 70, preferredFoot: 'Left', club: 'Pakhtakor', clubLeague: 'Uzbekistan Super League', marketValue: 400000, caps: 20, goals: 0 },
      { firstName: 'Jasur', lastName: 'Jaloliddinov', jerseyNumber: 24, position: 'CM', dateOfBirth: '1998-02-06', height: 180, weight: 74, preferredFoot: 'Right', club: 'Navbahor', clubLeague: 'Uzbekistan Super League', marketValue: 400000, caps: 15, goals: 1 },
      { firstName: 'Bobir', lastName: 'Abdixolikov', jerseyNumber: 25, position: 'ST', dateOfBirth: '2004-03-22', height: 183, weight: 76, preferredFoot: 'Right', club: 'Salzburg', clubLeague: 'Austrian Bundesliga', marketValue: 2000000, caps: 8, goals: 2 },
      { firstName: 'Rustam', lastName: 'Ashurmatov', jerseyNumber: 26, position: 'CB', dateOfBirth: '1997-07-08', height: 190, weight: 84, preferredFoot: 'Right', club: 'Al-Ahli Dubai', clubLeague: 'UAE Pro League', marketValue: 1200000, caps: 20, goals: 1 },
    ],
  },
];

// Helper functions
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

function generatePlayerId(teamCode: string, jerseyNumber: number): string {
  return `${teamCode.toLowerCase()}_${jerseyNumber}`;
}

async function seedRemainingTeamPlayers() {
  console.log('========================================');
  console.log('Seeding Remaining Team Players');
  console.log('========================================');
  console.log(`Mode: ${DRY_RUN ? 'DRY RUN' : 'LIVE'}`);
  console.log(`Teams to process: ${REMAINING_TEAMS.length}`);
  console.log('');

  for (const team of REMAINING_TEAMS) {
    console.log(`\n--- ${team.name} (${team.fifaCode}) ---`);

    for (const player of team.players) {
      const playerId = generatePlayerId(team.fifaCode, player.jerseyNumber);
      const age = calculateAge(player.dateOfBirth);

      const playerDoc = {
        playerId,
        teamCode: team.fifaCode,
        teamName: team.name,
        firstName: player.firstName,
        lastName: player.lastName,
        commonName: player.commonName || `${player.firstName} ${player.lastName}`,
        jerseyNumber: player.jerseyNumber,
        position: player.position,
        dateOfBirth: player.dateOfBirth,
        age,
        height: player.height,
        weight: player.weight,
        preferredFoot: player.preferredFoot,
        club: player.club,
        clubLeague: player.clubLeague,
        marketValue: player.marketValue,
        caps: player.caps,
        goals: player.goals,
        assists: 0,
        worldCupAppearances: 0,
        worldCupGoals: 0,
        worldCupAssists: 0,
        previousWorldCups: [],
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      };

      if (DRY_RUN) {
        console.log(`  [DRY] ${player.firstName} ${player.lastName} (#${player.jerseyNumber})`);
      } else {
        await db.collection('worldcup_players').doc(playerId).set(playerDoc, { merge: true });
        console.log(`  ✅ ${player.firstName} ${player.lastName} (#${player.jerseyNumber})`);
      }
    }
  }

  console.log('\n========================================');
  console.log(`Processed ${REMAINING_TEAMS.length} teams with ${REMAINING_TEAMS.reduce((sum, t) => sum + t.players.length, 0)} players`);
  console.log('========================================');
}

seedRemainingTeamPlayers()
  .then(() => process.exit(0))
  .catch((e) => {
    console.error('Error:', e);
    process.exit(1);
  });

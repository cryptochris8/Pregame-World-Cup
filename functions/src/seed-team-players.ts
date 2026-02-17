/**
 * Seed Team Players Script
 *
 * Reads player data from JSON files and writes to Firestore.
 * Writes to both 'players' and 'worldcup_players' collections.
 *
 * Usage:
 *   npx ts-node src/seed-team-players.ts [--team=USA] [--dryRun] [--clear] [--verbose]
 */

import { initFirebase, parseArgs, readJsonDir, batchWrite, clearCollection } from "./seed-utils";

const TEAMS_DIR = "../../assets/data/worldcup/teams";

const POSITION_STRENGTHS: Record<string, string[]> = {
  GK: ["Shot-stopping", "Command of area", "Distribution"],
  CB: ["Aerial ability", "Tackling", "Positioning"],
  LB: ["Overlapping runs", "Crossing", "Defensive awareness"],
  RB: ["Pace", "Tackling", "Delivery"],
  CDM: ["Interceptions", "Passing range", "Positional sense"],
  CM: ["Vision", "Work rate", "Passing"],
  CAM: ["Creativity", "Dribbling", "Final ball"],
  LW: ["Pace", "Dribbling", "Direct running"],
  RW: ["Crossing", "Cutting inside", "Finishing"],
  ST: ["Clinical finishing", "Movement", "Hold-up play"],
  CF: ["Link-up play", "Finishing", "Intelligence"],
};

const POSITION_WEAKNESSES: Record<string, string[]> = {
  GK: ["Penalty saves", "Playing out from the back"],
  CB: ["Pace against quick forwards", "Playing out under pressure"],
  LB: ["Defensive concentration", "Aerial duels"],
  RB: ["Positional discipline", "Final ball quality"],
  CDM: ["Attacking contribution", "Carrying ball forward"],
  CM: ["Goal contribution", "Defensive intensity"],
  CAM: ["Defensive work", "Physical duels"],
  LW: ["Defensive tracking", "Aerial ability"],
  RW: ["Consistency", "Decision making under pressure"],
  ST: ["Link-up play", "Pressing from the front"],
  CF: ["Pace", "Running in behind"],
};

const PLAY_STYLES: Record<string, string> = {
  GK: "Modern sweeper-keeper who commands the box and is comfortable with the ball at feet",
  CB: "Ball-playing defender with excellent reading of the game and leadership qualities",
  LB: "Attacking full-back who provides width and delivers quality crosses",
  RB: "Dynamic right-back combining defensive solidity with attacking threat",
  CDM: "Shield in front of the defense, breaking up play and distributing efficiently",
  CM: "Box-to-box midfielder with energy, vision, and goal contributions",
  CAM: "Creative playmaker who unlocks defenses with incisive passing and movement",
  LW: "Direct winger who takes on defenders and creates chances",
  RW: "Versatile wide player capable of scoring and creating goals",
  ST: "Clinical finisher with excellent movement and composure in front of goal",
  CF: "Complete forward who links play and finishes chances",
};

function calculateAge(dateOfBirth: string): number {
  const birth = new Date(dateOfBirth);
  const today = new Date();
  let age = today.getFullYear() - birth.getFullYear();
  const m = today.getMonth() - birth.getMonth();
  if (m < 0 || (m === 0 && today.getDate() < birth.getDate())) age--;
  return age;
}

function buildPlayersDoc(team: any, player: any, index: number) {
  const pos = player.position;
  const age = calculateAge(player.dateOfBirth);
  return {
    id: `${team.fifaCode.toLowerCase()}_${index + 1}`,
    data: {
      playerId: `${team.fifaCode.toLowerCase()}_${index + 1}`,
      fifaCode: team.fifaCode,
      firstName: player.firstName,
      lastName: player.lastName,
      fullName: `${player.firstName} ${player.lastName}`,
      commonName: player.commonName || player.lastName,
      jerseyNumber: player.jerseyNumber,
      position: pos,
      dateOfBirth: player.dateOfBirth,
      age,
      height: player.height,
      weight: player.weight,
      preferredFoot: player.preferredFoot,
      club: player.club,
      clubLeague: player.clubLeague,
      photoUrl: "",
      marketValue: player.marketValue,
      caps: player.caps,
      goals: player.goals,
      assists: Math.floor(player.goals * 0.5),
      worldCupAppearances: Math.floor(Math.random() * 3),
      worldCupGoals: Math.floor(Math.random() * 3),
      previousWorldCups: [],
      stats: {
        club: {
          season: "2024-25",
          appearances: Math.floor(Math.random() * 30) + 10,
          goals: ["ST", "CF", "LW", "RW"].includes(pos)
            ? Math.floor(Math.random() * 15)
            : Math.floor(Math.random() * 5),
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
      strengths: POSITION_STRENGTHS[pos] || ["Technical ability", "Football intelligence", "Team player"],
      weaknesses: POSITION_WEAKNESSES[pos] || ["Consistency at top level", "Big game experience"],
      playStyle: PLAY_STYLES[pos] || "Versatile player who adapts to tactical demands",
      keyMoment: `Key contributor in ${team.countryName}'s World Cup 2026 qualification campaign`,
      comparisonToLegend: "",
      worldCup2026Prediction: `Expected to play a key role for ${team.countryName} in World Cup 2026`,
      socialMedia: { instagram: "", twitter: "", followers: Math.floor(Math.random() * 5000000) },
      trivia: [],
    },
  };
}

function buildWorldcupPlayersDoc(team: any, player: any) {
  const age = calculateAge(player.dateOfBirth);
  const now = new Date().toISOString();
  return {
    id: `${team.fifaCode.toLowerCase()}_${player.jerseyNumber}`,
    data: {
      playerId: `${team.fifaCode.toLowerCase()}_${player.jerseyNumber}`,
      teamCode: team.fifaCode,
      teamName: team.countryName,
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
      createdAt: now,
      updatedAt: now,
    },
  };
}

async function main() {
  const { dryRun, team, clear, verbose } = parseArgs();
  const db = initFirebase();

  let teams: any[] = readJsonDir(TEAMS_DIR);
  if (team) teams = teams.filter((t: any) => t.fifaCode === team);

  if (teams.length === 0) {
    console.log(`No teams found${team ? ` matching --team=${team}` : ""}`);
    process.exit(1);
  }

  console.log(`Processing ${teams.length} team(s)  dryRun=${dryRun}  clear=${clear}\n`);

  if (clear) {
    await clearCollection(db, "players", dryRun);
    await clearCollection(db, "worldcup_players", dryRun);
  }

  const playersDocs: { id: string; data: Record<string, any> }[] = [];
  const wcPlayersDocs: { id: string; data: Record<string, any> }[] = [];

  for (const t of teams) {
    if (verbose) console.log(`  ${t.fifaCode} - ${t.countryName} (${t.players.length} players)`);
    t.players.forEach((p: any, i: number) => {
      playersDocs.push(buildPlayersDoc(t, p, i));
      wcPlayersDocs.push(buildWorldcupPlayersDoc(t, p));
    });
  }

  await batchWrite(db, "players", playersDocs, dryRun);
  await batchWrite(db, "worldcup_players", wcPlayersDocs, dryRun);

  console.log(`\nDone. ${playersDocs.length} player docs across ${teams.length} team(s).`);
  process.exit(0);
}

main().catch((e) => {
  console.error("FATAL:", e);
  process.exit(1);
});

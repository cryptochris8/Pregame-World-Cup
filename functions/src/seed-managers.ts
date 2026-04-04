/**
 * Seed Managers Script
 *
 * Reads manager JSON files from assets/data/worldcup/managers/ and uploads
 * them to the Firestore 'managers' collection.
 *
 * Usage:
 *   npx ts-node src/seed-managers.ts [--team=USA] [--dryRun] [--clear] [--verbose]
 */

import { initFirebase, parseArgs, readJsonDir, batchWrite, clearCollection } from "./seed-utils";

const COLLECTION = "managers";
const JSON_DIR = "../../assets/data/worldcup/managers";

async function main() {
  const { dryRun, team, clear, verbose } = parseArgs();
  const db = initFirebase();

  console.log(`Seed Managers | ${dryRun ? "DRY RUN" : "LIVE"}${team ? ` | team=${team}` : ""}`);

  if (clear) await clearCollection(db, COLLECTION, dryRun);

  let records: any[] = readJsonDir(JSON_DIR);

  if (team) {
    records = records.filter((r: any) => r.currentTeamCode === team);
  }

  if (records.length === 0) {
    console.log("No managers found.");
    return;
  }

  if (verbose) records.forEach((r: any) => console.log(`  ${r.currentTeamCode} - ${r.firstName} ${r.lastName}`));

  // Transform JSON field names to match the Flutter Manager model (fromFirestore),
  // and exclude photoUrl to preserve Firebase Storage URLs during re-seeds.
  const docs = records.map((r: any) => {
    const totalMatches = (r.careerWins || 0) + (r.careerDraws || 0) + (r.careerLosses || 0);
    const data: Record<string, any> = {
      managerId: r.id,
      teamCode: r.currentTeamCode,
      firstName: r.firstName,
      lastName: r.lastName,
      fullName: `${r.firstName} ${r.lastName}`,
      commonName: r.commonName,
      dateOfBirth: r.dateOfBirth,
      age: r.dateOfBirth ? Math.floor((Date.now() - new Date(r.dateOfBirth).getTime()) / 31557600000) : 0,
      nationality: r.nationality,
      currentTeam: r.currentTeam,
      appointedDate: r.appointedDate || "2024-01-01",
      previousClubs: r.previousTeams || [],
      managerialCareerStart: r.managerialCareerStart || (new Date().getFullYear() - (r.yearsExperience || 0)),
      yearsOfExperience: r.yearsExperience || 0,
      stats: {
        matchesManaged: totalMatches,
        wins: r.careerWins || 0,
        draws: r.careerDraws || 0,
        losses: r.careerLosses || 0,
        winPercentage: r.careerWinPercentage || 0,
        titlesWon: r.trophies ? r.trophies.length : 0,
      },
      honors: r.trophies || [],
      tacticalStyle: r.coachingStyle || "",
      preferredFormation: r.preferredFormation || "",
      philosophy: r.philosophy || "",
      strengths: r.strengths || [],
      weaknesses: r.weaknesses || [],
      keyMoment: r.keyMoment || "",
      famousQuote: r.famousQuote || "",
      managerStyle: r.managerStyle || r.coachingStyle || "",
      worldCup2026Prediction: r.worldCup2026Prediction || "",
      bio: r.bio || "",
      controversies: r.controversies || [],
      socialMedia: r.socialMedia || {},
      trivia: r.trivia || [],
    };
    return { id: r.id, data };
  });
  await batchWrite(db, COLLECTION, docs, dryRun);
}

main()
  .then(() => { console.log("Done."); process.exit(0); })
  .catch((e) => { console.error("Failed:", e); process.exit(1); });

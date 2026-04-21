/**
 * Seed Player World Cup Stats Script
 *
 * Reads player stat JSON files and updates matching player documents
 * in the 'players' Firestore collection with World Cup career data.
 *
 * Usage:
 *   npx ts-node src/seed-player-world-cup-stats.ts [--dryRun] [--team=CODE]
 */

import * as admin from "firebase-admin";
import { initFirebase, parseArgs, readJsonDir } from "./seed-utils";

const DATA_DIR = "../../assets/data/worldcup/player_stats";

async function main() {
  const { dryRun, team } = parseArgs();
  const db = initFirebase();

  console.log("=== Seed Player World Cup Stats ===");
  console.log(`Mode: ${dryRun ? "DRY RUN" : "LIVE"}`);

  let records: any[] = readJsonDir(DATA_DIR);
  if (team) {
    records = records.filter((r) => r.teamCode === team);
  }
  console.log(`Found ${records.length} player stat files`);

  let success = 0;
  let notFound = 0;
  let errors = 0;

  // Strip diacritics and lowercase so "Mbappé" / "Mbappe" / "Álvarez" /
  // "Alvarez" / "Júnior" / "Junior" all match regardless of accent.
  const normalize = (s: string): string =>
    s.normalize("NFD").replace(/[\u0300-\u036f]/g, "").toLowerCase();

  for (const p of records) {
    try {
      const snap = await db.collection("players").where("teamCode", "==", p.teamCode).get();
      const lastName = normalize(p.playerName.split(" ").pop() ?? "");
      const match = snap.docs.find((d) => {
        const data = d.data();
        const full = normalize(
          (data.fullName as string | undefined) ??
            `${data.firstName as string} ${data.lastName as string}`
        );
        return full.includes(lastName);
      });

      if (!match) {
        console.log(`  Not found: ${p.playerName}`);
        notFound++;
        continue;
      }

      const update: Record<string, any> = {
        worldCupAppearances: p.worldCupAppearances,
        worldCupGoals: p.worldCupGoals,
        worldCupAssists: p.worldCupAssists,
        previousWorldCups: p.previousWorldCups,
        worldCupTournamentStats: p.tournamentStats,
        worldCupAwards: p.worldCupAwards,
        memorableMoments: p.memorableMoments,
        worldCupLegacyRating: p.worldCupLegacyRating,
        comparisonToLegend: p.comparisonToLegend,
        worldCup2026Prediction: p.worldCup2026Prediction,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      if (dryRun) {
        console.log(`  [DRY RUN] Would update: ${p.playerName} (${p.teamCode})`);
      } else {
        await match.ref.update(update);
        console.log(`  Updated: ${p.playerName}`);
      }
      success++;
    } catch (err) {
      console.error(`  Error: ${p.playerName} - ${err}`);
      errors++;
    }
  }

  console.log(`\nSummary: ${success} updated, ${notFound} not found, ${errors} errors`);
  console.log("Done.");
}

main()
  .then(() => process.exit(0))
  .catch((err) => { console.error(err); process.exit(1); });

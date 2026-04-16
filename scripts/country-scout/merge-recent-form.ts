/**
 * merge-recent-form.ts
 *
 * Merges form scout agent output into the correct recent_form/groups_*.json file.
 * Deduplicates by date+opponent, appends new matches, trims to 15 most recent.
 *
 * IMPORTANT: Use teamCode, worldRanking, confederation — no trademarked terms.
 */

import * as fs from 'fs';
import * as path from 'path';
import type { RecentFormUpdate, ScoutOutput } from './types';
import type {
  MatchRecord,
  RecentFormFile,
  MergeResult,
  ChangeSummary,
} from './merge-types';

const DATA_DIR = path.resolve(__dirname, '../../assets/data/worldcup/recent_form');

const MAX_MATCHES_PER_TEAM = 15;

interface TeamLocation {
  filePath: string;
  groupKey: string;
}

/**
 * Build an index of teamCode -> { filePath, groupKey } by scanning all group files.
 */
export function buildTeamIndex(dataDir: string = DATA_DIR): Record<string, TeamLocation> {
  const index: Record<string, TeamLocation> = {};
  const files = ['groups_a_d.json', 'groups_e_h.json', 'groups_i_l.json'];

  for (const file of files) {
    const filePath = path.join(dataDir, file);
    if (!fs.existsSync(filePath)) continue;

    try {
      const data = JSON.parse(fs.readFileSync(filePath, 'utf-8'));
      for (const key of Object.keys(data)) {
        if (!key.startsWith('group_')) continue;
        const group = data[key];
        for (const teamCode of Object.keys(group)) {
          index[teamCode] = { filePath, groupKey: key };
        }
      }
    } catch {
      // Skip malformed files
    }
  }

  return index;
}

/**
 * Create a backup of a file before modifying it.
 */
export function backupFile(filePath: string): string | null {
  if (!fs.existsSync(filePath)) return null;
  const backupPath = filePath.replace('.json', `.backup-${Date.now()}.json`);
  fs.copyFileSync(filePath, backupPath);
  return backupPath;
}

/**
 * Generate a dedup key for a match: date + opponent (lowercased).
 */
function matchKey(date: string, opponent: string): string {
  return `${date}|${(opponent || '').toLowerCase()}`;
}

/**
 * Convert a RecentFormUpdate (agent output) to a MatchRecord (file format).
 */
function updateToRecord(update: RecentFormUpdate): MatchRecord {
  return {
    date: update.date,
    opponent: update.opponent,
    score: update.score,
    competition: update.competition,
    result: update.result,
    venue: update.venue,
  };
}

/**
 * Merge new matches into a team's existing match list.
 * Deduplicates by date+opponent, sorts by date descending, trims to MAX_MATCHES_PER_TEAM.
 * Returns the count of genuinely new matches added.
 */
export function mergeMatchesForTeam(
  existingMatches: MatchRecord[],
  newMatches: RecentFormUpdate[]
): { merged: MatchRecord[]; addedCount: number } {
  const seen = new Set(existingMatches.map((m) => matchKey(m.date, m.opponent)));
  let addedCount = 0;
  const combined = [...existingMatches];

  for (const m of newMatches) {
    if (!m.date || !m.opponent) continue; // Skip malformed
    const key = matchKey(m.date, m.opponent);
    if (!seen.has(key)) {
      combined.push(updateToRecord(m));
      seen.add(key);
      addedCount++;
    }
  }

  // Sort by date descending
  combined.sort((a, b) => b.date.localeCompare(a.date));

  // Trim to max
  const merged = combined.slice(0, MAX_MATCHES_PER_TEAM);

  return { merged, addedCount };
}

/**
 * Merge form updates for a single team into the group files.
 *
 * @param teamCode - Three-letter team code
 * @param newMatches - Array of RecentFormUpdate from the scout agent
 * @param dataDir - Directory containing group files
 * @param createBackup - Whether to create a backup before writing
 */
export function mergeRecentForm(
  teamCode: string,
  newMatches: RecentFormUpdate[],
  dataDir: string = DATA_DIR,
  createBackup: boolean = true
): MergeResult {
  if (!teamCode || !newMatches || newMatches.length === 0) {
    return { changesApplied: 0, summary: [] };
  }

  const teamIndex = buildTeamIndex(dataDir);
  const loc = teamIndex[teamCode];
  if (!loc) {
    return { changesApplied: 0, summary: [] };
  }

  let data: RecentFormFile;
  try {
    data = JSON.parse(fs.readFileSync(loc.filePath, 'utf-8'));
  } catch {
    return { changesApplied: 0, summary: [] };
  }

  if (createBackup) {
    backupFile(loc.filePath);
  }

  const summary: ChangeSummary[] = [];
  const group = data[loc.groupKey];
  if (!group) return { changesApplied: 0, summary: [] };

  const teamEntry = group[teamCode];
  if (!teamEntry || !teamEntry.recent_matches) return { changesApplied: 0, summary: [] };

  const { merged, addedCount } = mergeMatchesForTeam(teamEntry.recent_matches, newMatches);

  if (addedCount > 0) {
    teamEntry.recent_matches = merged;
    summary.push({
      type: 'form',
      teamCode,
      description: `Added ${addedCount} new match(es) for ${teamEntry.team_name || teamCode}`,
    });
  }

  // Update metadata generated date
  if (data.metadata) {
    data.metadata.generated = new Date().toISOString().slice(0, 10);
  }

  fs.writeFileSync(loc.filePath, JSON.stringify(data, null, 2) + '\n', 'utf-8');

  return { changesApplied: summary.length, summary };
}

/**
 * Batch merge: process multiple scout outputs at once.
 */
export function mergeRecentFormBatch(
  scoutOutputs: Pick<ScoutOutput, 'teamCode' | 'recentFormUpdates'>[],
  dataDir: string = DATA_DIR,
  createBackup: boolean = true
): MergeResult {
  const allSummary: ChangeSummary[] = [];

  for (const scout of scoutOutputs) {
    const result = mergeRecentForm(scout.teamCode, scout.recentFormUpdates, dataDir, createBackup);
    allSummary.push(...result.summary);
    // Only backup on first write per file (subsequent writes within same batch skip)
    // For simplicity, we allow multiple backups; they're timestamped so no conflict.
  }

  return { changesApplied: allSummary.length, summary: allSummary };
}

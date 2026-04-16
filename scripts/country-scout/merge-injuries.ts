/**
 * merge-injuries.ts
 *
 * Merges injury scout agent output into assets/data/worldcup/injury_tracker.json.
 * Supports add, update, remove, and no_change actions. Creates a backup before writing.
 *
 * IMPORTANT: Use teamCode, worldRanking, confederation — no trademarked terms.
 */

import * as fs from 'fs';
import * as path from 'path';
import type { InjuryUpdate } from './types';
import type {
  InjuryTrackerFile,
  InjuryPlayerRecord,
  MergeResult,
  ChangeSummary,
} from './merge-types';

const DATA_DIR = path.resolve(__dirname, '../../assets/data/worldcup');
const INJURY_FILE = path.join(DATA_DIR, 'injury_tracker.json');

function todayDateString(): string {
  return new Date().toISOString().slice(0, 10);
}

/**
 * Read and parse the injury tracker JSON file.
 * Returns null if the file is missing or malformed.
 */
export function readInjuryData(filePath: string = INJURY_FILE): InjuryTrackerFile | null {
  try {
    const raw = fs.readFileSync(filePath, 'utf-8');
    return JSON.parse(raw) as InjuryTrackerFile;
  } catch {
    return null;
  }
}

/**
 * Create a timestamped backup of the original file.
 */
export function backupFile(filePath: string = INJURY_FILE): string | null {
  if (!fs.existsSync(filePath)) return null;
  const backupPath = filePath.replace('.json', `.backup-${Date.now()}.json`);
  fs.copyFileSync(filePath, backupPath);
  return backupPath;
}

/**
 * Find a player index by playerName + teamCode (case-insensitive name match).
 */
function findPlayerIndex(players: InjuryPlayerRecord[], playerName: string, teamCode: string): number {
  return players.findIndex(
    (p) =>
      p.playerName.toLowerCase() === playerName.toLowerCase() &&
      p.teamCode === teamCode
  );
}

/**
 * Convert an InjuryUpdate (agent output) to an InjuryPlayerRecord (file format).
 */
function updateToRecord(update: InjuryUpdate): InjuryPlayerRecord {
  return {
    playerName: update.playerName,
    teamCode: update.teamCode,
    country: update.country || '',
    club: update.club || '',
    position: update.position || '',
    injuryType: update.injuryType || 'Unknown',
    injuryDate: update.injuryDate ?? null,
    expectedReturn: update.expectedReturn || 'Unknown',
    availabilityStatus: update.availabilityStatus || 'doubt',
    lastMatchPlayed: update.lastMatchPlayed || { date: '', opponent: '', notes: '' },
    source: update.source || '',
    notes: update.notes || '',
  };
}

/**
 * Overwrite fields on an existing player entry from the update payload.
 * Returns a description of fields changed, or null if nothing changed.
 */
function applyFieldUpdates(player: InjuryPlayerRecord, update: InjuryUpdate): string | null {
  const changes: string[] = [];

  if (update.club && update.club !== player.club) {
    player.club = update.club;
    changes.push('club');
  }
  if (update.position && update.position !== player.position) {
    player.position = update.position;
    changes.push('position');
  }
  if (update.injuryType && update.injuryType !== player.injuryType) {
    player.injuryType = update.injuryType;
    changes.push('injuryType');
  }
  if (update.injuryDate !== undefined && update.injuryDate !== player.injuryDate) {
    player.injuryDate = update.injuryDate ?? null;
    changes.push('injuryDate');
  }
  if (update.expectedReturn && update.expectedReturn !== player.expectedReturn) {
    player.expectedReturn = update.expectedReturn;
    changes.push('expectedReturn');
  }
  if (update.availabilityStatus && update.availabilityStatus !== player.availabilityStatus) {
    player.availabilityStatus = update.availabilityStatus;
    changes.push('status');
  }
  if (update.lastMatchPlayed) {
    const lmp = update.lastMatchPlayed;
    if (lmp.date !== player.lastMatchPlayed.date || lmp.opponent !== player.lastMatchPlayed.opponent) {
      player.lastMatchPlayed = lmp;
      changes.push('lastMatch');
    }
  }
  if (update.source) {
    player.source = update.source;
  }
  if (update.notes) {
    player.notes = update.notes;
  }
  if (update.country && update.country !== player.country) {
    player.country = update.country;
    changes.push('country');
  }

  if (changes.length === 0) return null;
  return `Updated ${player.playerName} (${player.teamCode}): ${changes.join(', ')}`;
}

/**
 * Apply a single InjuryUpdate to the players array.
 * Returns a description of the change, or null if no change was made.
 */
function applyUpdate(players: InjuryPlayerRecord[], update: InjuryUpdate): string | null {
  if (!update.playerName || !update.teamCode || !update.action) {
    return null;
  }

  if (update.action === 'no_change') {
    return null;
  }

  const idx = findPlayerIndex(players, update.playerName, update.teamCode);

  switch (update.action) {
    case 'add': {
      if (idx !== -1) {
        // Player already exists -- treat as update to avoid duplicates
        return applyFieldUpdates(players[idx], update);
      }
      players.push(updateToRecord(update));
      return `Added ${update.playerName} (${update.teamCode}) - ${update.availabilityStatus}`;
    }

    case 'update': {
      if (idx === -1) return null; // Player not found, skip
      return applyFieldUpdates(players[idx], update);
    }

    case 'remove': {
      if (idx === -1) return null; // Already gone
      const removed = players.splice(idx, 1)[0];
      return `Removed ${removed.playerName} (${removed.teamCode})`;
    }

    default:
      return null;
  }
}

/**
 * Main merge function. Applies all injury updates, writes back to file.
 * Returns a MergeResult with the count and summary of changes.
 */
export function mergeInjuries(
  updates: InjuryUpdate[],
  filePath: string = INJURY_FILE,
  createBackup: boolean = true
): MergeResult {
  const data = readInjuryData(filePath);
  if (!data) {
    return { changesApplied: 0, summary: [] };
  }

  if (createBackup) {
    backupFile(filePath);
  }

  const summary: ChangeSummary[] = [];

  for (const update of updates) {
    const desc = applyUpdate(data.players, update);
    if (desc) {
      summary.push({ type: 'injury', teamCode: update.teamCode, description: desc });
    }
  }

  // Update metadata
  data.metadata.lastUpdated = todayDateString();
  data.metadata.totalPlayers = data.players.length;
  const uniqueTeams = new Set(data.players.map((p) => p.teamCode));
  data.metadata.totalTeams = uniqueTeams.size;

  // Write back
  fs.writeFileSync(filePath, JSON.stringify(data, null, 2) + '\n', 'utf-8');

  return { changesApplied: summary.length, summary };
}

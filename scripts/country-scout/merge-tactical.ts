/**
 * merge-tactical.ts
 *
 * Merges tactical scout agent output into assets/data/worldcup/tactical_profiles.json.
 * Uses field-level TacticalUpdate deltas and CoachUpdate from the scout output.
 * Only applies changes when the scout reports actual differences.
 * Preserves all other fields.
 *
 * IMPORTANT: Use teamCode, worldRanking, confederation — no trademarked terms.
 */

import * as fs from 'fs';
import * as path from 'path';
import type { TacticalUpdate, CoachUpdate, ScoutOutput } from './types';
import type {
  TacticalProfilesFile,
  TacticalProfileRecord,
  MergeResult,
  ChangeSummary,
} from './merge-types';

const DATA_DIR = path.resolve(__dirname, '../../assets/data/worldcup');
const TACTICAL_FILE = path.join(DATA_DIR, 'tactical_profiles.json');

/** Fields in the profile that can be updated via TacticalUpdate.field */
const ALLOWED_STRING_FIELDS = new Set([
  'preferredFormation',
  'playingStyle',
  'tempoRating',
  'possessionStyle',
  'pressingIntensity',
]);

const ALLOWED_NUMBER_FIELDS = new Set([
  'attackRating',
  'defenseRating',
  'midfieldRating',
  'overallTacticalRating',
]);

/**
 * Read and parse the tactical profiles JSON file.
 */
export function readTacticalData(filePath: string = TACTICAL_FILE): TacticalProfilesFile | null {
  try {
    const raw = fs.readFileSync(filePath, 'utf-8');
    return JSON.parse(raw) as TacticalProfilesFile;
  } catch {
    return null;
  }
}

/**
 * Create a timestamped backup of the original file.
 */
export function backupFile(filePath: string = TACTICAL_FILE): string | null {
  if (!fs.existsSync(filePath)) return null;
  const backupPath = filePath.replace('.json', `.backup-${Date.now()}.json`);
  fs.copyFileSync(filePath, backupPath);
  return backupPath;
}

/**
 * Apply a single TacticalUpdate (field-level delta) to a profile.
 * Returns a change description, or null if the field is unrecognized or value unchanged.
 */
function applyFieldDelta(
  profile: TacticalProfileRecord,
  update: TacticalUpdate
): string | null {
  const { field, newValue } = update;

  if (ALLOWED_STRING_FIELDS.has(field)) {
    const current = (profile as any)[field];
    if (current === newValue) return null;
    (profile as any)[field] = newValue;
    return `${field}: "${current}" -> "${newValue}"`;
  }

  if (ALLOWED_NUMBER_FIELDS.has(field)) {
    const numVal = Number(newValue);
    if (isNaN(numVal)) return null;
    const current = (profile as any)[field];
    if (current === numVal) return null;
    (profile as any)[field] = numVal;
    return `${field}: ${current} -> ${numVal}`;
  }

  // Handle nested fields with dot notation, e.g. "attackingApproach.style"
  if (field.includes('.')) {
    const parts = field.split('.');
    if (parts.length === 2) {
      const [parent, child] = parts;
      const parentObj = (profile as any)[parent];
      if (parentObj && typeof parentObj === 'object') {
        const current = parentObj[child];
        if (current === newValue) return null;
        parentObj[child] = newValue;
        return `${field}: "${current}" -> "${newValue}"`;
      }
    }
  }

  // coach is handled separately via CoachUpdate
  if (field === 'coach') {
    if (profile.coach === newValue) return null;
    const old = profile.coach;
    profile.coach = newValue;
    return `coach: "${old}" -> "${newValue}"`;
  }

  return null; // Unrecognized field
}

/**
 * Apply a CoachUpdate to a profile.
 */
function applyCoachUpdate(
  profile: TacticalProfileRecord,
  coachUpdate: CoachUpdate
): string | null {
  if (!coachUpdate.changed || !coachUpdate.newCoach) return null;
  if (profile.coach === coachUpdate.newCoach) return null;

  const old = profile.coach;
  profile.coach = coachUpdate.newCoach;
  return `coach: "${old}" -> "${coachUpdate.newCoach}"`;
}

/**
 * Main merge function for a single scout output.
 * Applies tactical field deltas and coach update, writes back to file.
 */
export function mergeTactical(
  teamCode: string,
  tacticalUpdates: TacticalUpdate[],
  coachUpdate: CoachUpdate | null,
  filePath: string = TACTICAL_FILE,
  createBackup: boolean = true
): MergeResult {
  const data = readTacticalData(filePath);
  if (!data) {
    return { changesApplied: 0, summary: [] };
  }

  const profile = data.profiles[teamCode];
  if (!profile) {
    return { changesApplied: 0, summary: [] };
  }

  if (createBackup) {
    backupFile(filePath);
  }

  const summary: ChangeSummary[] = [];

  // Apply field-level deltas
  for (const update of tacticalUpdates) {
    const desc = applyFieldDelta(profile, update);
    if (desc) {
      summary.push({
        type: 'tactical',
        teamCode,
        description: `${profile.teamName} (${teamCode}): ${desc}`,
      });
    }
  }

  // Apply coach update
  if (coachUpdate) {
    const desc = applyCoachUpdate(profile, coachUpdate);
    if (desc) {
      summary.push({
        type: 'coach',
        teamCode,
        description: `${profile.teamName} (${teamCode}): ${desc}`,
      });
    }
  }

  // Update metadata timestamp
  data.metadata.last_updated = new Date().toISOString().slice(0, 10);

  // Write back
  fs.writeFileSync(filePath, JSON.stringify(data, null, 2) + '\n', 'utf-8');

  return { changesApplied: summary.length, summary };
}

/**
 * Batch merge: process multiple scout outputs at once.
 */
export function mergeTacticalBatch(
  scoutOutputs: Pick<ScoutOutput, 'teamCode' | 'tacticalUpdates' | 'coachUpdate'>[],
  filePath: string = TACTICAL_FILE,
  createBackup: boolean = true
): MergeResult {
  const allSummary: ChangeSummary[] = [];

  for (const scout of scoutOutputs) {
    const result = mergeTactical(
      scout.teamCode,
      scout.tacticalUpdates,
      scout.coachUpdate,
      filePath,
      createBackup
    );
    allSummary.push(...result.summary);
  }

  return { changesApplied: allSummary.length, summary: allSummary };
}

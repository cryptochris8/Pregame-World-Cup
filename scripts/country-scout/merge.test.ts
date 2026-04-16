/**
 * Tests for country-scout merge modules.
 *
 * Run: npx jest merge.test.ts
 *
 * Each test creates temp files to avoid touching real data.
 *
 * IMPORTANT: Use teamCode, worldRanking, confederation — no trademarked terms.
 */

import * as fs from 'fs';
import * as path from 'path';
import * as os from 'os';

import { mergeInjuries, readInjuryData } from './merge-injuries';
import { mergeRecentForm, buildTeamIndex, mergeMatchesForTeam } from './merge-recent-form';
import { mergeTactical, readTacticalData } from './merge-tactical';
import { generateChangelog, generatePreviewChangelog } from './changelog';

import type { InjuryUpdate, RecentFormUpdate, TacticalUpdate, CoachUpdate, ScoutOutput } from './types';
import type {
  InjuryTrackerFile,
  InjuryPlayerRecord,
  MatchRecord,
  TacticalProfilesFile,
  TacticalProfileRecord,
  MergeResult,
} from './merge-types';

// --- Test Helpers ---

function makeTempDir(): string {
  return fs.mkdtempSync(path.join(os.tmpdir(), 'scout-test-'));
}

function writeJson(dir: string, filename: string, data: any): string {
  const filePath = path.join(dir, filename);
  fs.writeFileSync(filePath, JSON.stringify(data, null, 2), 'utf-8');
  return filePath;
}

function readJson(filePath: string): any {
  return JSON.parse(fs.readFileSync(filePath, 'utf-8'));
}

function cleanupDir(dir: string): void {
  try {
    const files = fs.readdirSync(dir);
    for (const f of files) {
      fs.unlinkSync(path.join(dir, f));
    }
    fs.rmdirSync(dir);
  } catch {
    // Best effort
  }
}

// --- Sample Data Factories ---

function sampleInjuryData(): InjuryTrackerFile {
  return {
    metadata: {
      lastUpdated: '2026-03-01',
      description: 'Test injury tracker',
      totalPlayers: 2,
      totalTeams: 1,
      notes: 'Test data',
    },
    players: [
      {
        playerName: 'Kylian Mbappe',
        teamCode: 'FRA',
        country: 'France',
        club: 'Real Madrid',
        position: 'Forward',
        injuryType: 'Knee discomfort',
        injuryDate: '2025-12-31',
        expectedReturn: 'Currently playing through management',
        availabilityStatus: 'minor_concern',
        lastMatchPlayed: { date: '2026-02-14', opponent: 'Real Sociedad', notes: 'Returned' },
        source: 'Test',
        notes: 'Test notes',
      },
      {
        playerName: 'Antoine Griezmann',
        teamCode: 'FRA',
        country: 'France',
        club: 'Atletico Madrid',
        position: 'Forward',
        injuryType: 'No current injury',
        injuryDate: null,
        expectedReturn: 'N/A',
        availabilityStatus: 'fit',
        lastMatchPlayed: { date: '2026-02-22', opponent: 'Atletico Madrid', notes: 'Full 90' },
        source: 'Test',
        notes: 'Test notes',
      },
    ],
  };
}

function sampleRecentFormData() {
  return {
    metadata: {
      generated: '2026-02-21',
      description: 'Test form data',
      sources: ['Test'],
      notes: 'Test',
    },
    group_A: {
      RSA: {
        team_name: 'South Africa',
        team_code: 'RSA',
        recent_matches: [
          { date: '2024-06-07', opponent: 'Nigeria', score: '1-1', competition: 'Qualifier', result: 'D', venue: 'home' },
          { date: '2024-06-11', opponent: 'Zimbabwe', score: '3-1', competition: 'Qualifier', result: 'W', venue: 'away' },
        ],
      },
      MEX: {
        team_name: 'Mexico',
        team_code: 'MEX',
        recent_matches: [
          { date: '2024-09-06', opponent: 'Honduras', score: '2-0', competition: 'Qualifier', result: 'W', venue: 'home' },
        ],
      },
    },
  };
}

function sampleTacticalData(): TacticalProfilesFile {
  return {
    metadata: {
      title: 'Test Tactical Profiles',
      description: 'Test data',
      last_updated: '2026-03-01',
      sources: ['Test'],
    },
    profiles: {
      ARG: {
        teamCode: 'ARG',
        teamName: 'Argentina',
        coach: 'Lionel Scaloni',
        preferredFormation: '4-3-3',
        alternateFormations: ['4-4-2', '3-5-2'],
        playingStyle: 'Possession-based',
        tempoRating: 'High',
        possessionStyle: 'Dominant',
        pressingIntensity: 'High',
        attackingApproach: {
          style: 'Creative through Messi',
          strengths: ['Messi creativity', 'Alvarez runs'],
          primaryThreat: 'Messi',
          setPieceRating: 'Above Average',
        },
        defensiveApproach: {
          style: 'Organized',
          strengths: ['Romero leadership', 'Martinez saves'],
          weakness: 'Aging fullbacks',
        },
        keyTacticalFeatures: ['Messi-centric attack'],
        strengthsOverall: ['World-class talent'],
        weaknessesOverall: ['Aging core'],
        attackRating: 9,
        defenseRating: 8,
        midfieldRating: 8,
        overallTacticalRating: 9,
      },
    },
  };
}

/** Build an InjuryUpdate with reasonable defaults for testing. */
function makeInjuryUpdate(
  overrides: Partial<InjuryUpdate> & { playerName: string; teamCode: string; action: InjuryUpdate['action'] }
): InjuryUpdate {
  return {
    country: '',
    club: '',
    position: 'Forward',
    injuryType: 'Unknown',
    injuryDate: null,
    expectedReturn: 'Unknown',
    availabilityStatus: 'doubt',
    lastMatchPlayed: { date: '', opponent: '', notes: '' },
    source: 'Test',
    notes: '',
    ...overrides,
  };
}

// ============================================================
// INJURY MERGE TESTS
// ============================================================

describe('merge-injuries', () => {
  let tmpDir: string;

  beforeEach(() => {
    tmpDir = makeTempDir();
  });

  afterEach(() => {
    cleanupDir(tmpDir);
  });

  it('should update an existing player by playerName + teamCode', () => {
    const filePath = writeJson(tmpDir, 'injury_tracker.json', sampleInjuryData());

    const updates: InjuryUpdate[] = [
      makeInjuryUpdate({
        action: 'update',
        playerName: 'Kylian Mbappe',
        teamCode: 'FRA',
        availabilityStatus: 'injured',
        injuryType: 'ACL tear',
      }),
    ];

    const result = mergeInjuries(updates, filePath, false);
    expect(result.changesApplied).toBe(1);
    expect(result.summary[0].description).toContain('Kylian Mbappe');

    const data = readJson(filePath);
    const mbappe = data.players.find((p: any) => p.playerName === 'Kylian Mbappe');
    expect(mbappe.availabilityStatus).toBe('injured');
    expect(mbappe.injuryType).toBe('ACL tear');
    // Other fields preserved
    expect(mbappe.club).toBe('Real Madrid');
  });

  it('should add a new player', () => {
    const filePath = writeJson(tmpDir, 'injury_tracker.json', sampleInjuryData());

    const updates: InjuryUpdate[] = [
      makeInjuryUpdate({
        action: 'add',
        playerName: 'Vinicius Jr',
        teamCode: 'BRA',
        country: 'Brazil',
        club: 'Real Madrid',
        position: 'Forward',
        injuryType: 'Hamstring strain',
        availabilityStatus: 'doubt',
      }),
    ];

    const result = mergeInjuries(updates, filePath, false);
    expect(result.changesApplied).toBe(1);

    const data = readJson(filePath);
    expect(data.players.length).toBe(3);
    expect(data.metadata.totalPlayers).toBe(3);
    const vini = data.players.find((p: any) => p.playerName === 'Vinicius Jr');
    expect(vini).toBeTruthy();
    expect(vini.teamCode).toBe('BRA');
  });

  it('should remove a player', () => {
    const filePath = writeJson(tmpDir, 'injury_tracker.json', sampleInjuryData());

    const updates: InjuryUpdate[] = [
      makeInjuryUpdate({ action: 'remove', playerName: 'Antoine Griezmann', teamCode: 'FRA' }),
    ];

    const result = mergeInjuries(updates, filePath, false);
    expect(result.changesApplied).toBe(1);

    const data = readJson(filePath);
    expect(data.players.length).toBe(1);
    expect(data.metadata.totalPlayers).toBe(1);
  });

  it('should be idempotent - running same updates twice produces same result', () => {
    const filePath = writeJson(tmpDir, 'injury_tracker.json', sampleInjuryData());

    const updates: InjuryUpdate[] = [
      makeInjuryUpdate({
        action: 'update',
        playerName: 'Kylian Mbappe',
        teamCode: 'FRA',
        availabilityStatus: 'injured',
      }),
    ];

    mergeInjuries(updates, filePath, false);
    const firstRun = readJson(filePath);

    // Run again with same data
    const result2 = mergeInjuries(updates, filePath, false);
    expect(result2.changesApplied).toBe(0);
    const secondRun = readJson(filePath);

    expect(firstRun.players.length).toBe(secondRun.players.length);
    expect(firstRun.players[0].availabilityStatus).toBe(secondRun.players[0].availabilityStatus);
  });

  it('should treat add of existing player as update (no duplicates)', () => {
    const filePath = writeJson(tmpDir, 'injury_tracker.json', sampleInjuryData());

    const updates: InjuryUpdate[] = [
      makeInjuryUpdate({
        action: 'add',
        playerName: 'Kylian Mbappe',
        teamCode: 'FRA',
        availabilityStatus: 'fit',
      }),
    ];

    mergeInjuries(updates, filePath, false);
    const data = readJson(filePath);
    const mbappeCount = data.players.filter((p: any) => p.playerName === 'Kylian Mbappe').length;
    expect(mbappeCount).toBe(1);
    expect(data.players[0].availabilityStatus).toBe('fit');
  });

  it('should skip no_change actions', () => {
    const filePath = writeJson(tmpDir, 'injury_tracker.json', sampleInjuryData());

    const updates: InjuryUpdate[] = [
      makeInjuryUpdate({ action: 'no_change', playerName: 'Kylian Mbappe', teamCode: 'FRA' }),
    ];

    const result = mergeInjuries(updates, filePath, false);
    expect(result.changesApplied).toBe(0);
  });

  it('should skip update for non-existent player gracefully', () => {
    const filePath = writeJson(tmpDir, 'injury_tracker.json', sampleInjuryData());

    const updates: InjuryUpdate[] = [
      makeInjuryUpdate({ action: 'update', playerName: 'Nonexistent Player', teamCode: 'XXX' }),
    ];

    const result = mergeInjuries(updates, filePath, false);
    expect(result.changesApplied).toBe(0);
  });

  it('should skip remove for non-existent player gracefully', () => {
    const filePath = writeJson(tmpDir, 'injury_tracker.json', sampleInjuryData());

    const updates: InjuryUpdate[] = [
      makeInjuryUpdate({ action: 'remove', playerName: 'Ghost Player', teamCode: 'FRA' }),
    ];

    const result = mergeInjuries(updates, filePath, false);
    expect(result.changesApplied).toBe(0);
    const data = readJson(filePath);
    expect(data.players.length).toBe(2);
  });

  it('should update lastUpdated in metadata', () => {
    const filePath = writeJson(tmpDir, 'injury_tracker.json', sampleInjuryData());

    mergeInjuries([], filePath, false);
    const data = readJson(filePath);
    expect(data.metadata.lastUpdated).toBe(new Date().toISOString().slice(0, 10));
  });

  it('should create a backup file when requested', () => {
    const filePath = writeJson(tmpDir, 'injury_tracker.json', sampleInjuryData());

    mergeInjuries([], filePath, true);
    const files = fs.readdirSync(tmpDir);
    const backups = files.filter((f) => f.includes('.backup-'));
    expect(backups.length).toBeGreaterThanOrEqual(1);
  });

  it('should return empty result for missing file', () => {
    const result = mergeInjuries([], path.join(tmpDir, 'nonexistent.json'), false);
    expect(result.changesApplied).toBe(0);
  });
});

// ============================================================
// RECENT FORM MERGE TESTS
// ============================================================

describe('merge-recent-form', () => {
  let tmpDir: string;

  beforeEach(() => {
    tmpDir = makeTempDir();
  });

  afterEach(() => {
    cleanupDir(tmpDir);
  });

  it('should append new matches to a team', () => {
    writeJson(tmpDir, 'groups_a_d.json', sampleRecentFormData());

    const newMatches: RecentFormUpdate[] = [
      { date: '2026-04-01', opponent: 'Ghana', score: '2-0', competition: 'Friendly', result: 'W', venue: 'home' },
    ];

    const result = mergeRecentForm('RSA', newMatches, tmpDir, false);
    expect(result.changesApplied).toBe(1);
    expect(result.summary[0].description).toContain('1 new match');

    const data = readJson(path.join(tmpDir, 'groups_a_d.json'));
    expect(data.group_A.RSA.recent_matches.length).toBe(3);
  });

  it('should deduplicate matches by date+opponent', () => {
    writeJson(tmpDir, 'groups_a_d.json', sampleRecentFormData());

    const newMatches: RecentFormUpdate[] = [
      // Duplicate of existing
      { date: '2024-06-07', opponent: 'Nigeria', score: '1-1', competition: 'Qualifier', result: 'D', venue: 'home' },
      // Genuinely new
      { date: '2026-04-01', opponent: 'Ghana', score: '2-0', competition: 'Friendly', result: 'W', venue: 'home' },
    ];

    const result = mergeRecentForm('RSA', newMatches, tmpDir, false);
    expect(result.changesApplied).toBe(1);

    const data = readJson(path.join(tmpDir, 'groups_a_d.json'));
    expect(data.group_A.RSA.recent_matches.length).toBe(3);
  });

  it('should be idempotent', () => {
    writeJson(tmpDir, 'groups_a_d.json', sampleRecentFormData());

    const newMatches: RecentFormUpdate[] = [
      { date: '2026-04-01', opponent: 'Ghana', score: '2-0', competition: 'Friendly', result: 'W', venue: 'home' },
    ];

    mergeRecentForm('RSA', newMatches, tmpDir, false);
    const afterFirst = readJson(path.join(tmpDir, 'groups_a_d.json'));

    const result2 = mergeRecentForm('RSA', newMatches, tmpDir, false);
    expect(result2.changesApplied).toBe(0);
    const afterSecond = readJson(path.join(tmpDir, 'groups_a_d.json'));

    expect(afterFirst.group_A.RSA.recent_matches.length).toBe(afterSecond.group_A.RSA.recent_matches.length);
  });

  it('should trim to 15 matches maximum', () => {
    const existing: MatchRecord[] = [];
    for (let i = 1; i <= 14; i++) {
      existing.push({
        date: `2025-${String(i).padStart(2, '0')}-01`,
        opponent: `Team ${i}`,
        score: '1-0',
        competition: 'Test',
        result: 'W',
        venue: 'home',
      });
    }

    const newMatches: RecentFormUpdate[] = [
      { date: '2026-01-01', opponent: 'NewTeamA', score: '2-0', competition: 'Test', result: 'W', venue: 'home' },
      { date: '2026-02-01', opponent: 'NewTeamB', score: '3-0', competition: 'Test', result: 'W', venue: 'home' },
    ];

    const { merged, addedCount } = mergeMatchesForTeam(existing, newMatches);
    expect(addedCount).toBe(2);
    expect(merged.length).toBeLessThanOrEqual(15);
    expect(merged[0].date).toBe('2026-02-01');
  });

  it('should sort matches by date descending', () => {
    const existing: MatchRecord[] = [
      { date: '2025-06-01', opponent: 'A', score: '1-0', competition: 'T', result: 'W', venue: 'home' },
    ];
    const newMatches: RecentFormUpdate[] = [
      { date: '2026-01-01', opponent: 'C', score: '1-0', competition: 'T', result: 'W', venue: 'home' },
      { date: '2024-01-01', opponent: 'B', score: '1-0', competition: 'T', result: 'W', venue: 'home' },
    ];

    const { merged } = mergeMatchesForTeam(existing, newMatches);
    expect(merged[0].date).toBe('2026-01-01');
    expect(merged[merged.length - 1].date).toBe('2024-01-01');
  });

  it('should skip malformed match entries', () => {
    const newMatches: RecentFormUpdate[] = [
      { date: '', opponent: 'A', score: '1-0', competition: 'T', result: 'W', venue: 'home' },
      { date: '2026-01-01', opponent: '', score: '1-0', competition: 'T', result: 'W', venue: 'home' },
      { date: '2026-01-01', opponent: 'Valid', score: '1-0', competition: 'T', result: 'W', venue: 'home' },
    ];

    const { merged, addedCount } = mergeMatchesForTeam([], newMatches);
    expect(addedCount).toBe(1);
    expect(merged.length).toBe(1);
  });

  it('should handle empty updates', () => {
    writeJson(tmpDir, 'groups_a_d.json', sampleRecentFormData());
    const result = mergeRecentForm('RSA', [], tmpDir, false);
    expect(result.changesApplied).toBe(0);
  });

  it('should skip unknown team codes gracefully', () => {
    writeJson(tmpDir, 'groups_a_d.json', sampleRecentFormData());

    const newMatches: RecentFormUpdate[] = [
      { date: '2026-01-01', opponent: 'X', score: '1-0', competition: 'T', result: 'W', venue: 'home' },
    ];

    const result = mergeRecentForm('UNKNOWN', newMatches, tmpDir, false);
    expect(result.changesApplied).toBe(0);
  });

  it('should build team index correctly from group files', () => {
    writeJson(tmpDir, 'groups_a_d.json', sampleRecentFormData());
    const index = buildTeamIndex(tmpDir);
    expect(index['RSA']).toBeTruthy();
    expect(index['RSA'].groupKey).toBe('group_A');
    expect(index['MEX']).toBeTruthy();
    expect(index['MEX'].groupKey).toBe('group_A');
  });
});

// ============================================================
// TACTICAL MERGE TESTS
// ============================================================

describe('merge-tactical', () => {
  let tmpDir: string;

  beforeEach(() => {
    tmpDir = makeTempDir();
  });

  afterEach(() => {
    cleanupDir(tmpDir);
  });

  it('should update coach via CoachUpdate', () => {
    const filePath = writeJson(tmpDir, 'tactical_profiles.json', sampleTacticalData());

    const coachUpdate: CoachUpdate = {
      changed: true,
      currentCoach: 'Lionel Scaloni',
      newCoach: 'New Coach Name',
      source: 'Test',
      notes: null,
    };

    const result = mergeTactical('ARG', [], coachUpdate, filePath, false);
    expect(result.changesApplied).toBe(1);
    expect(result.summary[0].description).toContain('coach');

    const data = readJson(filePath);
    expect(data.profiles.ARG.coach).toBe('New Coach Name');
  });

  it('should update formation via TacticalUpdate field delta', () => {
    const filePath = writeJson(tmpDir, 'tactical_profiles.json', sampleTacticalData());

    const updates: TacticalUpdate[] = [
      { field: 'preferredFormation', oldValue: '4-3-3', newValue: '3-4-3', source: 'Test', confidence: 'high' },
    ];

    const result = mergeTactical('ARG', updates, null, filePath, false);
    expect(result.changesApplied).toBe(1);

    const data = readJson(filePath);
    expect(data.profiles.ARG.preferredFormation).toBe('3-4-3');
    // Other fields preserved
    expect(data.profiles.ARG.coach).toBe('Lionel Scaloni');
  });

  it('should skip CoachUpdate when changed is false', () => {
    const filePath = writeJson(tmpDir, 'tactical_profiles.json', sampleTacticalData());

    const coachUpdate: CoachUpdate = {
      changed: false,
      currentCoach: 'Lionel Scaloni',
      newCoach: null,
      source: null,
      notes: null,
    };

    const result = mergeTactical('ARG', [], coachUpdate, filePath, false);
    expect(result.changesApplied).toBe(0);

    const data = readJson(filePath);
    expect(data.profiles.ARG.coach).toBe('Lionel Scaloni');
  });

  it('should preserve all unmodified fields', () => {
    const filePath = writeJson(tmpDir, 'tactical_profiles.json', sampleTacticalData());

    const updates: TacticalUpdate[] = [
      { field: 'attackRating', oldValue: '9', newValue: '10', source: 'Test', confidence: 'high' },
    ];

    mergeTactical('ARG', updates, null, filePath, false);
    const data = readJson(filePath);
    const arg = data.profiles.ARG;
    expect(arg.attackRating).toBe(10);
    // Preserved
    expect(arg.coach).toBe('Lionel Scaloni');
    expect(arg.preferredFormation).toBe('4-3-3');
    expect(arg.defenseRating).toBe(8);
    expect(arg.alternateFormations).toEqual(['4-4-2', '3-5-2']);
  });

  it('should be idempotent', () => {
    const filePath = writeJson(tmpDir, 'tactical_profiles.json', sampleTacticalData());

    const coachUpdate: CoachUpdate = {
      changed: true,
      currentCoach: 'Lionel Scaloni',
      newCoach: 'New Coach',
      source: 'Test',
      notes: null,
    };

    mergeTactical('ARG', [], coachUpdate, filePath, false);
    const result2 = mergeTactical('ARG', [], coachUpdate, filePath, false);
    expect(result2.changesApplied).toBe(0);

    const data = readJson(filePath);
    expect(data.profiles.ARG.coach).toBe('New Coach');
  });

  it('should update nested fields via dot notation', () => {
    const filePath = writeJson(tmpDir, 'tactical_profiles.json', sampleTacticalData());

    const updates: TacticalUpdate[] = [
      { field: 'attackingApproach.style', oldValue: 'Creative through Messi', newValue: 'Direct counter-attack', source: 'Test', confidence: 'medium' },
      { field: 'defensiveApproach.weakness', oldValue: 'Aging fullbacks', newValue: 'Set pieces', source: 'Test', confidence: 'high' },
    ];

    mergeTactical('ARG', updates, null, filePath, false);
    const data = readJson(filePath);
    expect(data.profiles.ARG.attackingApproach.style).toBe('Direct counter-attack');
    // Preserved sub-fields
    expect(data.profiles.ARG.attackingApproach.strengths).toEqual(['Messi creativity', 'Alvarez runs']);
    expect(data.profiles.ARG.defensiveApproach.weakness).toBe('Set pieces');
  });

  it('should skip unknown team codes gracefully', () => {
    const filePath = writeJson(tmpDir, 'tactical_profiles.json', sampleTacticalData());

    const result = mergeTactical('ZZZ', [], null, filePath, false);
    expect(result.changesApplied).toBe(0);
  });

  it('should update metadata last_updated', () => {
    const filePath = writeJson(tmpDir, 'tactical_profiles.json', sampleTacticalData());
    mergeTactical('ARG', [], null, filePath, false);
    const data = readJson(filePath);
    expect(data.metadata.last_updated).toBe(new Date().toISOString().slice(0, 10));
  });

  it('should create backup when requested', () => {
    const filePath = writeJson(tmpDir, 'tactical_profiles.json', sampleTacticalData());
    mergeTactical('ARG', [], null, filePath, true);
    const files = fs.readdirSync(tmpDir);
    const backups = files.filter((f) => f.includes('.backup-'));
    expect(backups.length).toBeGreaterThanOrEqual(1);
  });

  it('should handle coach field via TacticalUpdate as fallback', () => {
    const filePath = writeJson(tmpDir, 'tactical_profiles.json', sampleTacticalData());

    const updates: TacticalUpdate[] = [
      { field: 'coach', oldValue: 'Lionel Scaloni', newValue: 'Fallback Coach', source: 'Test', confidence: 'high' },
    ];

    const result = mergeTactical('ARG', updates, null, filePath, false);
    expect(result.changesApplied).toBe(1);
    const data = readJson(filePath);
    expect(data.profiles.ARG.coach).toBe('Fallback Coach');
  });
});

// ============================================================
// CHANGELOG TESTS
// ============================================================

describe('changelog', () => {
  it('should generate markdown with all change types grouped', () => {
    const results: MergeResult[] = [
      {
        changesApplied: 2,
        summary: [
          { type: 'injury', teamCode: 'FRA', description: 'Updated Mbappe (FRA): status' },
          { type: 'injury', teamCode: 'BRA', description: 'Added Vinicius Jr (BRA) - doubt' },
        ],
      },
      {
        changesApplied: 1,
        summary: [
          { type: 'form', teamCode: 'ARG', description: 'Added 3 new match(es) for Argentina' },
        ],
      },
      {
        changesApplied: 1,
        summary: [
          { type: 'coach', teamCode: 'ARG', description: 'Argentina (ARG): coach: "Scaloni" -> "New Coach"' },
        ],
      },
    ];

    const md = generateChangelog(results, '2026-04-16');
    expect(md).toContain('# Country Scout Changelog - 2026-04-16');
    expect(md).toContain('Total changes: 4');
    expect(md).toContain('## Injury Updates');
    expect(md).toContain('## Recent Form Updates');
    expect(md).toContain('## Coach Changes');
    expect(md).toContain('### FRA');
    expect(md).toContain('### BRA');
    expect(md).toContain('### ARG');
  });

  it('should return no-changes message for empty results', () => {
    const md = generateChangelog([], '2026-04-16');
    expect(md).toContain('No changes detected');
  });

  it('should generate preview changelog from scout outputs', () => {
    const scoutOutputs: ScoutOutput[] = [
      {
        teamCode: 'FRA',
        teamName: 'France',
        scoutedAt: '2026-04-16T12:00:00Z',
        injuryUpdates: [
          {
            action: 'update',
            playerName: 'Mbappe',
            teamCode: 'FRA',
            country: 'France',
            club: 'Real Madrid',
            position: 'Forward',
            injuryType: 'Knee',
            injuryDate: null,
            expectedReturn: 'TBD',
            availabilityStatus: 'injured',
            lastMatchPlayed: { date: '2026-04-01', opponent: 'Test', notes: '' },
            source: 'Test',
            notes: '',
          },
        ],
        recentFormUpdates: [
          { date: '2026-04-01', opponent: 'Germany', score: '2-1', competition: 'Friendly', result: 'W', venue: 'home' },
        ],
        tacticalUpdates: [
          { field: 'preferredFormation', oldValue: '4-3-3', newValue: '4-2-3-1', source: 'Test', confidence: 'high' },
        ],
        squadChanges: [],
        bettingOddsUpdate: { tournamentWinner: null, groupStageExit: null, toQualifyFromGroup: null, source: 'Test', notes: null },
        coachUpdate: { changed: true, currentCoach: 'Deschamps', newCoach: 'Zidane', source: 'Test', notes: null },
        summary: 'Test',
        sourceUrls: [],
        confidence: 'high',
        dataFreshness: '2026-04-16',
      },
    ];

    const md = generatePreviewChangelog(scoutOutputs, '2026-04-16');
    expect(md).toContain('# Country Scout Preview');
    expect(md).toContain('[UPDATE] Mbappe (FRA)');
    expect(md).toContain('FRA: 1 new match(es)');
    expect(md).toContain('FRA: preferredFormation');
    expect(md).toContain('Deschamps -> Zidane');
  });

  it('should skip no_change injury actions in preview', () => {
    const scoutOutputs: ScoutOutput[] = [
      {
        teamCode: 'ARG',
        teamName: 'Argentina',
        scoutedAt: '2026-04-16T12:00:00Z',
        injuryUpdates: [
          {
            action: 'no_change',
            playerName: 'Messi',
            teamCode: 'ARG',
            country: 'Argentina',
            club: 'Inter Miami',
            position: 'Forward',
            injuryType: 'None',
            injuryDate: null,
            expectedReturn: 'N/A',
            availabilityStatus: 'fit',
            lastMatchPlayed: { date: '2026-04-01', opponent: 'Test', notes: '' },
            source: 'Test',
            notes: '',
          },
        ],
        recentFormUpdates: [],
        tacticalUpdates: [],
        squadChanges: [],
        bettingOddsUpdate: { tournamentWinner: null, groupStageExit: null, toQualifyFromGroup: null, source: 'Test', notes: null },
        coachUpdate: { changed: false, currentCoach: 'Scaloni', newCoach: null, source: null, notes: null },
        summary: 'No changes',
        sourceUrls: [],
        confidence: 'high',
        dataFreshness: '2026-04-16',
      },
    ];

    const md = generatePreviewChangelog(scoutOutputs, '2026-04-16');
    expect(md).toContain('No changes planned');
    expect(md).not.toContain('Messi');
  });
});

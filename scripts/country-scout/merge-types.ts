/**
 * merge-types.ts
 *
 * Internal types used by the merge modules. These complement the agent-facing
 * types in types.ts with structures needed for merge tracking and reporting.
 *
 * IMPORTANT: Use teamCode, worldRanking, confederation — no trademarked terms.
 */

// --- Change tracking ---

export interface ChangeSummary {
  type: 'injury' | 'form' | 'tactical' | 'squad' | 'coach';
  teamCode: string;
  description: string;
}

export interface MergeResult {
  changesApplied: number;
  summary: ChangeSummary[];
}

// --- JSON file shapes (matching actual data files on disk) ---

export interface InjuryPlayerRecord {
  playerName: string;
  teamCode: string;
  country: string;
  club: string;
  position: string;
  injuryType: string;
  injuryDate: string | null;
  expectedReturn: string;
  availabilityStatus: string;
  lastMatchPlayed: {
    date: string;
    opponent: string;
    notes: string;
  };
  source: string;
  notes: string;
}

export interface InjuryTrackerFile {
  metadata: {
    lastUpdated: string;
    description: string;
    totalPlayers: number;
    totalTeams: number;
    notes: string;
  };
  players: InjuryPlayerRecord[];
}

export interface MatchRecord {
  date: string;
  opponent: string;
  score: string;
  competition: string;
  result: string;
  venue: string;
}

export interface TeamFormEntry {
  team_name: string;
  team_code: string;
  recent_matches: MatchRecord[];
}

export interface RecentFormFile {
  metadata: {
    generated: string;
    description: string;
    sources: string[];
    notes: string;
  };
  [groupKey: string]: any; // group_A, group_B, etc.
}

export interface TacticalProfileRecord {
  teamCode: string;
  teamName: string;
  coach: string;
  preferredFormation: string;
  alternateFormations: string[];
  playingStyle: string;
  tempoRating: string;
  possessionStyle: string;
  pressingIntensity: string;
  attackingApproach: {
    style: string;
    strengths: string[];
    primaryThreat: string;
    setPieceRating: string;
  };
  defensiveApproach: {
    style: string;
    strengths: string[];
    weakness: string;
  };
  keyTacticalFeatures: string[];
  strengthsOverall: string[];
  weaknessesOverall: string[];
  attackRating: number;
  defenseRating: number;
  midfieldRating: number;
  overallTacticalRating: number;
}

export interface TacticalProfilesFile {
  metadata: {
    title: string;
    description: string;
    last_updated: string;
    sources: string[];
  };
  profiles: Record<string, TacticalProfileRecord>;
}

/**
 * Country Scout Agent — TypeScript interfaces
 *
 * These types define the structured output of a Country Scout agent run.
 * Schemas are aligned with the existing data files:
 *   - assets/data/worldcup/injury_tracker.json
 *   - assets/data/worldcup/recent_form/groups_*.json
 *   - assets/data/worldcup/tactical_profiles.json
 *   - assets/data/worldcup/teams_metadata.json
 *
 * IMPORTANT: Never use the term "FIFA" anywhere — use teamCode, worldRanking,
 * confederation, tournament, World Cup instead.
 */

// ---------------------------------------------------------------------------
// Injury Tracker — matches injury_tracker.json player schema
// ---------------------------------------------------------------------------

export type AvailabilityStatus =
  | "fit"
  | "minor_concern"
  | "doubt"
  | "major_doubt"
  | "injured"
  | "long_term_injured"
  | "retired_international";

export type PlayerPosition = "Forward" | "Midfielder" | "Defender" | "Goalkeeper";

export interface LastMatchPlayed {
  /** ISO date string YYYY-MM-DD */
  date: string;
  /** Opponent name including competition in parentheses */
  opponent: string;
  /** Brief note about the appearance */
  notes: string;
}

/**
 * Matches the player object schema in injury_tracker.json,
 * plus an `action` field indicating what the orchestrator should do.
 */
export interface InjuryUpdate {
  playerName: string;
  teamCode: string;
  country: string;
  club: string;
  position: PlayerPosition;
  injuryType: string;
  /** ISO date string YYYY-MM-DD, or null if no current injury */
  injuryDate: string | null;
  expectedReturn: string;
  availabilityStatus: AvailabilityStatus;
  lastMatchPlayed: LastMatchPlayed;
  /** Source attribution — publication names and dates */
  source: string;
  notes: string;
  /** What the orchestrator should do with this entry */
  action: "add" | "update" | "remove" | "no_change";
}

// ---------------------------------------------------------------------------
// Recent Form — matches recent_form/groups_*.json match schema
// ---------------------------------------------------------------------------

export type MatchResult = "W" | "D" | "L";
export type MatchVenue = "home" | "away" | "neutral";

/**
 * Matches the match object schema in recent_form/groups_*.json.
 * Only new matches (not already in the data) should be returned.
 */
export interface RecentFormUpdate {
  /** ISO date string YYYY-MM-DD */
  date: string;
  opponent: string;
  /** Score from the team's perspective, e.g. "2-1" */
  score: string;
  competition: string;
  result: MatchResult;
  venue: MatchVenue;
}

// ---------------------------------------------------------------------------
// Tactical Updates — delta changes to tactical_profiles.json fields
// ---------------------------------------------------------------------------

export type ConfidenceLevel = "high" | "medium" | "low";

export interface TacticalUpdate {
  /** Which field in the tactical profile changed (e.g. "preferredFormation", "coach") */
  field: string;
  oldValue: string | null;
  newValue: string;
  /** Source attribution — publication name and date */
  source: string;
  confidence: ConfidenceLevel;
}

// ---------------------------------------------------------------------------
// Squad Changes
// ---------------------------------------------------------------------------

export type SquadChangeType =
  | "retirement"
  | "suspension"
  | "eligibility_switch"
  | "new_call_up"
  | "dropped";

export interface SquadChange {
  playerName: string;
  changeType: SquadChangeType;
  details: string;
  /** Source attribution — publication name and date */
  source: string;
  /** ISO date string YYYY-MM-DD, or null if unknown */
  effectiveDate: string | null;
}

// ---------------------------------------------------------------------------
// Betting Odds
// ---------------------------------------------------------------------------

export interface BettingOddsUpdate {
  /** e.g. "+5000" or "50/1", null if not found */
  tournamentWinner: string | null;
  groupStageExit: string | null;
  toQualifyFromGroup: string | null;
  /** Bookmaker name and date */
  source: string;
  notes: string | null;
}

// ---------------------------------------------------------------------------
// Coach Update
// ---------------------------------------------------------------------------

export interface CoachUpdate {
  changed: boolean;
  currentCoach: string;
  newCoach: string | null;
  source: string | null;
  notes: string | null;
}

// ---------------------------------------------------------------------------
// Full Scout Output — the complete agent response
// ---------------------------------------------------------------------------

export interface ScoutOutput {
  teamCode: string;
  teamName: string;
  /** ISO 8601 timestamp of when the scout ran */
  scoutedAt: string;

  injuryUpdates: InjuryUpdate[];
  recentFormUpdates: RecentFormUpdate[];
  tacticalUpdates: TacticalUpdate[];
  squadChanges: SquadChange[];
  bettingOddsUpdate: BettingOddsUpdate;
  coachUpdate: CoachUpdate;

  /** 2-3 sentence executive summary of key findings */
  summary: string;
  /** Every URL consulted during research */
  sourceUrls: string[];
  /** Overall confidence in the findings */
  confidence: ConfidenceLevel;
  /** ISO date of the freshest data point found */
  dataFreshness: string;
}

// ---------------------------------------------------------------------------
// Input parameters for the Country Scout agent
// ---------------------------------------------------------------------------

export interface ScoutInput {
  teamCode: string;
  teamName: string;
  coachName: string;
  starPlayers: string[];
  currentInjuryData: InjuryUpdate[];
  currentRecentForm: RecentFormUpdate[];
  currentTacticalProfile: Record<string, unknown>;
}

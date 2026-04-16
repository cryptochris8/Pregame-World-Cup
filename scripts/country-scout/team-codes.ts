/**
 * Country Scout — Team Codes Module
 *
 * Reads teams_metadata.json and exports helpers for the 48-team research system.
 * Maps each team to its recent_form file based on group assignment.
 *
 * IMPORTANT: Never use the term "FIFA" anywhere — use teamCode, worldRanking,
 * confederation, tournament, World Cup instead.
 */

import * as fs from "fs";
import * as path from "path";

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

export interface TeamMetadata {
  teamCode: string;
  countryName: string;
  shortName: string;
  nickname: string;
  confederation: string;
  group: string;
  worldRanking: number;
  coachName: string;
  captainName: string;
  primaryColor: string;
  secondaryColor: string;
  worldCupTitles: number;
  worldCupAppearances: number;
  bestFinish: string;
  isHostNation: boolean;
  starPlayers: string[];
  qualificationMethod: string;
  isQualified: boolean;
  homeStadium: string;
}

export type RecentFormFile = "groups_a_d.json" | "groups_e_h.json" | "groups_i_l.json";

export interface TeamWithFormFile extends TeamMetadata {
  recentFormFile: RecentFormFile;
}

// ---------------------------------------------------------------------------
// Paths
// ---------------------------------------------------------------------------

const DATA_DIR = path.resolve(__dirname, "../../assets/data/worldcup");
const TEAMS_METADATA_PATH = path.join(DATA_DIR, "teams_metadata.json");
const RECENT_FORM_DIR = path.join(DATA_DIR, "recent_form");
const INJURY_TRACKER_PATH = path.join(DATA_DIR, "injury_tracker.json");
const TACTICAL_PROFILES_PATH = path.join(DATA_DIR, "tactical_profiles.json");

// ---------------------------------------------------------------------------
// Group-to-file mapping
// ---------------------------------------------------------------------------

const GROUP_TO_FORM_FILE: Record<string, RecentFormFile> = {
  A: "groups_a_d.json",
  B: "groups_a_d.json",
  C: "groups_a_d.json",
  D: "groups_a_d.json",
  E: "groups_e_h.json",
  F: "groups_e_h.json",
  G: "groups_e_h.json",
  H: "groups_e_h.json",
  I: "groups_i_l.json",
  J: "groups_i_l.json",
  K: "groups_i_l.json",
  L: "groups_i_l.json",
};

// ---------------------------------------------------------------------------
// Data loading
// ---------------------------------------------------------------------------

let _teamsCache: Map<string, TeamWithFormFile> | null = null;

function loadTeams(): Map<string, TeamWithFormFile> {
  if (_teamsCache) return _teamsCache;

  const raw = fs.readFileSync(TEAMS_METADATA_PATH, "utf-8");
  const parsed: Record<string, TeamMetadata> = JSON.parse(raw);

  _teamsCache = new Map();
  for (const [code, meta] of Object.entries(parsed)) {
    const formFile = GROUP_TO_FORM_FILE[meta.group];
    if (!formFile) {
      throw new Error(`Unknown group "${meta.group}" for team ${code}`);
    }
    _teamsCache.set(code, { ...meta, recentFormFile: formFile });
  }

  return _teamsCache;
}

// ---------------------------------------------------------------------------
// Exported helpers
// ---------------------------------------------------------------------------

/**
 * Get a single team by its 3-letter code (e.g., "FRA", "BRA", "USA").
 * Returns undefined if the team code is not found.
 */
export function getTeamByCode(code: string): TeamWithFormFile | undefined {
  return loadTeams().get(code);
}

/**
 * Get all teams in a specific group (e.g., "A", "B", ..., "L").
 */
export function getTeamsByGroup(group: string): TeamWithFormFile[] {
  const teams = loadTeams();
  return Array.from(teams.values()).filter((t) => t.group === group);
}

/**
 * Get all 48 team codes as a sorted string array.
 */
export function getAllTeamCodes(): string[] {
  return Array.from(loadTeams().keys()).sort();
}

/**
 * Get all 48 teams as an array, sorted by group then world ranking.
 */
export function getAllTeams(): TeamWithFormFile[] {
  return Array.from(loadTeams().values()).sort((a, b) => {
    if (a.group !== b.group) return a.group.localeCompare(b.group);
    return a.worldRanking - b.worldRanking;
  });
}

/**
 * Get the recent_form file name for a given group letter.
 */
export function getRecentFormFile(group: string): RecentFormFile {
  const file = GROUP_TO_FORM_FILE[group];
  if (!file) throw new Error(`Unknown group: ${group}`);
  return file;
}

/**
 * Get the full path to a team's recent_form JSON file.
 */
export function getRecentFormPath(group: string): string {
  return path.join(RECENT_FORM_DIR, getRecentFormFile(group));
}

/**
 * Load the recent form data for a specific team from its group file.
 * Returns the team's match array, or null if not found.
 */
export function loadRecentFormForTeam(
  teamCode: string
): { team_name: string; team_code: string; recent_matches: unknown[] } | null {
  const team = getTeamByCode(teamCode);
  if (!team) return null;

  const formPath = getRecentFormPath(team.group);
  const raw = fs.readFileSync(formPath, "utf-8");
  const parsed = JSON.parse(raw);

  // recent_form files are structured as group_X: { TEAM_CODE: { ... } }
  const groupKey = `group_${team.group}`;
  const groupData = parsed[groupKey];
  if (!groupData) return null;

  return groupData[teamCode] ?? null;
}

/**
 * Load injury tracker entries for a specific team.
 * Returns an array of player injury objects matching the team code.
 */
export function loadInjuriesForTeam(teamCode: string): unknown[] {
  const raw = fs.readFileSync(INJURY_TRACKER_PATH, "utf-8");
  const parsed = JSON.parse(raw);
  const players: unknown[] = parsed.players ?? [];
  return players.filter(
    (p: any) => p.teamCode === teamCode
  );
}

/**
 * Load the tactical profile for a specific team.
 * Returns the profile object, or null if not found.
 */
export function loadTacticalProfileForTeam(teamCode: string): unknown | null {
  const raw = fs.readFileSync(TACTICAL_PROFILES_PATH, "utf-8");
  const parsed = JSON.parse(raw);
  return parsed.profiles?.[teamCode] ?? null;
}

/**
 * Get all unique group letters (A through L).
 */
export function getAllGroups(): string[] {
  return ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L"];
}

/**
 * Get teams grouped by confederation.
 */
export function getTeamsByConfederation(
  confederation: string
): TeamWithFormFile[] {
  const teams = loadTeams();
  return Array.from(teams.values()).filter(
    (t) => t.confederation === confederation
  );
}

/**
 * Get host nations.
 */
export function getHostNations(): TeamWithFormFile[] {
  const teams = loadTeams();
  return Array.from(teams.values()).filter((t) => t.isHostNation);
}

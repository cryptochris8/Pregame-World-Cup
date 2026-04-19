/**
 * Smoke tests for generate-match-narratives.ts data loaders.
 *
 * These run against the REAL data files in assets/data/worldcup/. Their
 * purpose is to catch schema drift (like the 2026-04-16 Country Scout sweep
 * that broke the script by reshaping ratings/profiles/campaigns/venues into
 * team-keyed objects). A loader that silently returns an empty map would
 * cause an entire regeneration run to produce low-quality narratives before
 * anyone noticed — these tests fail fast instead.
 *
 * They are NOT unit tests of loader internals — they're integration checks
 * that the current on-disk data is loadable. When the schema intentionally
 * changes, update the loader and these tests together.
 */

import {
  loadEloRatings,
  loadTacticalProfiles,
  loadInjuryTracker,
  loadSquadValues,
  loadBettingOdds,
  loadQualifyingCampaigns,
  loadVenueFactors,
  loadRecentForm,
  loadTeamsMetadata,
  toIterable,
  pickStarPlayers,
} from '../src/generate-match-narratives';

// 48 teams qualified for World Cup 2026 (memory: project_playoff_slots).
// Loaders should return an entry for all of them (or close — a few files
// may not list every team).
const MIN_TEAMS_EXPECTED = 40;

describe('generate-match-narratives loaders (against real data)', () => {
  describe('toIterable helper', () => {
    it('returns [] for null', () => expect(toIterable(null)).toEqual([]));
    it('returns [] for undefined', () => expect(toIterable(undefined)).toEqual([]));
    it('returns the array as-is for arrays', () =>
      expect(toIterable([1, 2, 3])).toEqual([1, 2, 3]));
    it('returns Object.values for plain objects', () =>
      expect(toIterable({ a: 1, b: 2 })).toEqual([1, 2]));
    it('returns [] for primitives', () => {
      expect(toIterable(42)).toEqual([]);
      expect(toIterable('hello')).toEqual([]);
      expect(toIterable(true)).toEqual([]);
    });
  });

  describe('loadEloRatings', () => {
    const map = loadEloRatings();
    it('loads ratings for at least 40 teams', () => {
      expect(map.size).toBeGreaterThanOrEqual(MIN_TEAMS_EXPECTED);
    });
    it('indexes by teamCode and values retain teamCode', () => {
      const esp = map.get('ESP');
      expect(esp).toBeDefined();
      expect(esp.teamCode).toBe('ESP');
      expect(typeof esp.eloRating).toBe('number');
    });
  });

  describe('loadTacticalProfiles', () => {
    const map = loadTacticalProfiles();
    it('loads profiles for at least 40 teams', () => {
      expect(map.size).toBeGreaterThanOrEqual(MIN_TEAMS_EXPECTED);
    });
    it('exposes coach and formation on a known team', () => {
      const arg = map.get('ARG');
      expect(arg).toBeDefined();
      expect(typeof arg.coach).toBe('string');
      expect(arg.preferredFormation).toBeDefined();
    });
  });

  describe('loadInjuryTracker', () => {
    const map = loadInjuryTracker();
    it('loads at least one injured player per some teams', () => {
      expect(map.size).toBeGreaterThan(0);
    });
    it('bundles each team\'s injured players into a list', () => {
      for (const list of map.values()) {
        expect(Array.isArray(list)).toBe(true);
        expect(list.length).toBeGreaterThan(0);
      }
    });
  });

  describe('loadSquadValues', () => {
    const map = loadSquadValues();
    it('loads squad values for at least 40 teams', () => {
      expect(map.size).toBeGreaterThanOrEqual(MIN_TEAMS_EXPECTED);
    });
  });

  describe('loadBettingOdds', () => {
    const map = loadBettingOdds();
    it('loads outright winner odds for at least 20 teams', () => {
      expect(map.size).toBeGreaterThanOrEqual(20);
    });
    it('indexes by team code (ESP should be present)', () => {
      expect(map.get('ESP')).toBeDefined();
    });
  });

  describe('loadQualifyingCampaigns', () => {
    const map = loadQualifyingCampaigns();
    it('loads campaigns for at least 40 teams', () => {
      expect(map.size).toBeGreaterThanOrEqual(MIN_TEAMS_EXPECTED);
    });
    it('exposes confederation and qualificationMethod on a known team', () => {
      const arg = map.get('ARG');
      expect(arg).toBeDefined();
      expect(typeof arg.confederation).toBe('string');
    });
  });

  describe('loadVenueFactors', () => {
    const venues = loadVenueFactors();
    it('loads at least 10 venues', () => {
      expect(venues.length).toBeGreaterThanOrEqual(10);
    });
    it('each venue entry has a venueName', () => {
      for (const v of venues) {
        expect(typeof v.venueName).toBe('string');
      }
    });
  });

  describe('loadRecentForm', () => {
    const map = loadRecentForm();
    it('loads recent form for at least 40 teams across 3 group files', () => {
      expect(map.size).toBeGreaterThanOrEqual(MIN_TEAMS_EXPECTED);
    });
    it('a known team (ARG) has recent_matches array', () => {
      const arg = map.get('ARG');
      expect(arg).toBeDefined();
      expect(Array.isArray(arg.recent_matches)).toBe(true);
    });
  });

  describe('loadTeamsMetadata', () => {
    const map = loadTeamsMetadata();
    it('loads metadata for at least 40 teams', () => {
      expect(map.size).toBeGreaterThanOrEqual(MIN_TEAMS_EXPECTED);
    });
    it('known team (USA) has country info', () => {
      const usa = map.get('USA');
      expect(usa).toBeDefined();
      expect(usa.teamCode).toBe('USA');
    });
  });

  describe('pickStarPlayers', () => {
    it('returns [] for null/undefined profile', () => {
      expect(pickStarPlayers(null)).toEqual([]);
      expect(pickStarPlayers(undefined)).toEqual([]);
      expect(pickStarPlayers({})).toEqual([]);
    });

    it('handles the post-scout object-keyed schema', () => {
      const profile = {
        players: {
          'Lionel Messi': { bio: 'GOAT', worldCup2026Role: 'Captain' },
          'Emi Martinez': { bio: 'GK', playingStyle: 'Sweeper' },
          'Julian Alvarez': { bio: 'Forward' },
          'Enzo Fernandez': { bio: 'Midfielder' },
        },
      };
      const stars = pickStarPlayers(profile);
      expect(stars).toHaveLength(3);
      expect(stars[0].name).toBe('Lionel Messi');
      expect(stars[0].bio).toBe('GOAT');
      expect(stars[0].worldCup2026Role).toBe('Captain');
      expect(stars.map((s) => s.name)).toEqual([
        'Lionel Messi',
        'Emi Martinez',
        'Julian Alvarez',
      ]);
    });

    it('handles the legacy array schema with isKeyStar flag', () => {
      const profile = {
        players: [
          { name: 'A', isKeyStar: false, marketValue: 10000000 },
          { name: 'B', isKeyStar: true, marketValue: 20000000 },
          { name: 'C', isKeyStar: false, marketValue: 60000000 }, // > 50M threshold
          { name: 'D', isKeyStar: true, marketValue: 5000000 },
          { name: 'E', isKeyStar: true, marketValue: 90000000 },
        ],
      };
      const stars = pickStarPlayers(profile);
      expect(stars).toHaveLength(3);
      expect(stars.map((s) => s.name)).toEqual(['B', 'C', 'D']);
    });

    it('falls back to first 3 when legacy array has no star flags', () => {
      const profile = {
        players: [
          { name: 'X', marketValue: 1000000 },
          { name: 'Y', marketValue: 2000000 },
          { name: 'Z', marketValue: 3000000 },
          { name: 'W', marketValue: 4000000 },
        ],
      };
      const stars = pickStarPlayers(profile);
      expect(stars).toHaveLength(3);
      expect(stars.map((s) => s.name)).toEqual(['X', 'Y', 'Z']);
    });

    it('picks star players for a real team (ARG, post-scout)', () => {
      const profile = require('../../assets/data/worldcup/player_profiles/ARG.json');
      const stars = pickStarPlayers(profile);
      expect(stars).toHaveLength(3);
      expect(stars[0].name).toBeTruthy();
      // Each star should have at least one of the descriptive fields
      for (const s of stars) {
        const hasDesc =
          s.bio || s.playingStyle || s.worldCup2026Role || s.notableFact;
        expect(hasDesc).toBeTruthy();
      }
    });
  });
});

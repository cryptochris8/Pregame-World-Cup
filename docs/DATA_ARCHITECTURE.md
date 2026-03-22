# World Cup 2026 Data Architecture

## The Problem We Fixed (March 21, 2026)

The app had **two separate stores of World Cup data** that drifted out of sync:

1. **Firestore** — had the correct, updated 2026 World Cup draw (real qualified teams, correct group assignments)
2. **Local JSON files** (`assets/data/worldcup/`) — had an older, partially incorrect draw with wrong teams in 9 of 12 groups

This caused confusing behavior: the match list screen showed the correct teams from Firestore (e.g., "Mexico vs South Africa"), but tapping into a match showed "Analysis Coming Soon" because the local match summary file didn't exist for that team pairing (it still had "Mexico vs Bolivia").

### What Was Wrong

| Group | Local JSON had (wrong) | Firestore had (correct) |
|-------|------------------------|------------------------|
| A | Bolivia (BOL) | South Africa (RSA) |
| C | Nigeria (NGA), Peru (PER) | Scotland (SCO), Haiti (HAI) |
| E | Chile (CHI), Cameroon (CMR) | Ivory Coast (CIV), Curaçao (CUW) |
| F | Jamaica (JAM) | Tunisia (TUN) |
| H | Saudi Arabia (SAU), Slovenia (SVN) | Saudi Arabia (KSA), Cabo Verde (CPV) |
| I | Honduras (HON) | Iraq (IRQ) |
| J | Costa Rica (CRC), Poland (POL), Serbia (SRB) | Algeria (ALG), Austria (AUT), Jordan (JOR) |
| K | Albania (ALB) | DR Congo (COD) |
| L | Trinidad & Tobago (TRI) | Ghana (GHA) |

### What We Fixed

1. Updated `assets/data/worldcup/matches/group_stage.json` — replaced all 17 incorrect teams (39 individual match entries) to match Firestore
2. Created 33 missing match summary files in `assets/data/worldcup/match_summaries/` for the correct team pairings
3. Verified 72/72 group stage match summaries now exist

---

## How Data Flows in This App

### The Rule

| Data Type | Source | Why |
|-----------|--------|-----|
| Match schedule, scores, standings, bracket | **Firestore** | Needs live updates during the tournament |
| Match previews, AI analysis, predictions | **Local JSON** | Offline-first, no API costs, ships with app |
| Team rosters, info | **Firestore** (fallback: mock data) | Needs updates as squads change |
| Enhanced analytics (ELO, betting odds, form) | **Local JSON** | Pre-researched, updated via app releases |

### In Plain English

- **Firestore is the source of truth for LIVE tournament data** — which teams are playing, scores, group standings, knockout bracket progression. This data changes during the tournament.

- **Local JSON is the source of truth for RESEARCHED CONTENT** — match previews, historical analysis, tactical breakdowns, player spotlights, predictions, betting odds, ELO ratings. This data is researched ahead of time and bundled with the app.

- **These two sources must stay in sync on team codes and group assignments.** If Firestore says Group A is MEX/KOR/DEN/RSA, then the local JSON files must use those same codes. Otherwise the app can't find the right preview file when a user taps a match.

### The Fallback Chain

For match data, the app tries sources in this order:

```
1. Local Cache (Hive) — fast, 2-hour TTL
2. Firestore — authoritative for live data
3. API (SportsData.io) — external backup
4. Mock Data (world_cup_mock_data.dart) — development fallback
```

For match previews/summaries:

```
1. Local JSON only (assets/data/worldcup/match_summaries/{TEAM1}_{TEAM2}.json)
2. If file not found → shows "Analysis Coming Soon" card
```

---

## Key Files

### Data Sources
| File | Purpose |
|------|---------|
| `lib/features/worldcup/data/services/local_match_summary_service.dart` | Loads match previews from local JSON |
| `lib/features/worldcup/data/services/enhanced_match_data_service.dart` | Loads ELO, betting odds, recent form, etc. from local JSON |
| `lib/features/worldcup/data/datasources/world_cup_firestore_datasource.dart` | Reads live match/team data from Firestore |
| `lib/features/worldcup/data/repositories/world_cup_match_repository_impl.dart` | Orchestrates cache → Firestore → API → mock fallback |
| `lib/features/worldcup/data/mock/world_cup_mock_data.dart` | Hardcoded fallback data (must match Firestore draw) |

### Local JSON Assets
| Directory | Contents | Count |
|-----------|----------|-------|
| `assets/data/worldcup/matches/` | Group stage + knockout schedule | 2 files |
| `assets/data/worldcup/match_summaries/` | AI match previews | 152 files |
| `assets/data/worldcup/teams/` | Team profiles | 48 files |
| `assets/data/worldcup/head_to_head/` | Historical matchup records | 100+ files |
| `assets/data/worldcup/player_profiles/` | Player bios | varies |
| `assets/data/worldcup/player_stats/` | Player World Cup statistics | varies |
| `assets/data/worldcup/recent_form/` | Last 5-10 results per team | 3 files |
| `assets/data/worldcup/managers/` | Manager profiles | 48 files |
| `assets/data/worldcup/venues/` | Stadium information | varies |

### Single-File Assets
| File | Contents |
|------|----------|
| `assets/data/worldcup/elo_ratings.json` | World Football Elo Ratings (sourced from eloratings.net) |
| `assets/data/worldcup/betting_odds.json` | Outright odds from DraftKings, BetMGM, FanDuel, Polymarket |
| `assets/data/worldcup/squad_values.json` | Market valuations per team |
| `assets/data/worldcup/confederation_records.json` | Inter-confederation World Cup head-to-head |
| `assets/data/worldcup/historical_patterns.json` | Historical tournament patterns |
| `assets/data/worldcup/injury_tracker.json` | Player availability/injuries |
| `assets/data/worldcup/teams_metadata.json` | Team metadata (confederation, FIFA codes) |
| `assets/data/worldcup/tactical_profiles.json` | Manager tactical tendencies |
| `assets/data/worldcup/qualifying_campaigns.json` | Qualifying results |
| `assets/data/worldcup/venue_factors.json` | Venue-specific factors for predictions |

### Firestore Collections
| Collection | Purpose |
|------------|---------|
| `worldcup_matches` | Live match schedule, scores |
| `worldcup_teams` | Team rosters |
| `worldcup_groups` | Group standings |
| `worldcup_bracket` | Knockout bracket |
| `worldcup_venues` | Venue info |
| `headToHead` | Historical matchup data |
| `worldCupHistory` | Historical World Cup records |
| `worldCupRecords` | Team performance records |
| `matchSummaries` | Backup copy of match previews |

### Seeding Scripts (push local JSON → Firestore)
Located in `functions/src/`:
- `seed-june2026-matches.ts`
- `seed-knockout-matches.ts`
- `seed-match-summaries.ts`
- `seed-world-cup-history.ts`
- `seed-head-to-head.ts`
- `seed-managers.ts`
- `seed-team-players.ts`
- `seed-player-world-cup-stats.ts`
- `seed-venue-enhancements.ts`

---

## How to Update Data Going Forward

### If team rosters, draw, or schedule changes:
1. Update Firestore (this is the live source the app reads from)
2. Update `assets/data/worldcup/matches/group_stage.json` to match
3. Update `lib/features/worldcup/data/mock/world_cup_mock_data.dart` to match
4. Create/update match summary files for any new team pairings
5. Run `flutter run` to verify (asset changes require restart)

### If updating match previews or analysis:
1. Edit the relevant file in `assets/data/worldcup/match_summaries/`
2. File naming convention: team codes sorted alphabetically, e.g., `ARG_BRA.json` (not `BRA_ARG.json`)
3. Release an app update — previews ship with the app binary

### If updating ELO, odds, or form data:
1. Edit the relevant JSON file in `assets/data/worldcup/`
2. These feed the `LocalPredictionEngine` (10-factor model)
3. Release an app update

### Match Summary File Format
```json
{
  "team1Code": "XXX",
  "team2Code": "YYY",
  "team1Name": "Full Name",
  "team2Name": "Full Name",
  "historicalAnalysis": "3-4 paragraphs",
  "keyStorylines": ["storyline 1", "storyline 2"],
  "playersToWatch": [
    {"name": "Player Name", "teamCode": "XXX", "position": "Position", "reason": "Why to watch"}
  ],
  "tacticalPreview": "2 paragraphs",
  "prediction": {
    "predictedOutcome": "XXX or DRAW",
    "predictedScore": "X-X",
    "confidence": 70,
    "reasoning": "...",
    "alternativeScenario": "..."
  },
  "pastEncountersSummary": "...",
  "funFacts": ["fact 1", "fact 2"],
  "isFirstMeeting": false
}
```

---

## Critical Rule

**Firestore team codes and local JSON team codes must always match.**

If they don't, the app will show the correct team name on the match card (from Firestore) but fail to load the preview content (from local JSON), showing "Analysis Coming Soon" instead.

The three places that must stay in sync:
1. `Firestore worldcup_matches collection`
2. `assets/data/worldcup/matches/group_stage.json`
3. `lib/features/worldcup/data/mock/world_cup_mock_data.dart`

# Pregame World Cup 2026 - Comprehensive Data Audit Report

**Date**: March 1, 2026
**Audited by**: 6 parallel research agents covering teams, players, history, storage, predictions, and online research

---

## Executive Summary

The app has a **strong data foundation** (372 JSON files, 3.4 MB, ~3,195 Firestore documents) but has several critical issues that must be fixed before launch, plus significant opportunities to become truly world-class.

**Overall Data Quality: 7.5/10**

| Area | Accuracy | Completeness | Score |
|------|----------|-------------|-------|
| Tournament History | 100% (22/22 winners correct) | 85% (missing per-team WC history) | 9/10 |
| Records | 100% (19/19 verified) | 70% (only 19 records, should be 40+) | 7/10 |
| Team Data | 90% (groups correct, some retired players) | 60% (19 metadata fields missing from JSON) | 6/10 |
| Player Profiles | 85% (some outdated clubs/transfers) | 80% (narrative strong, structured data weak) | 7/10 |
| Player Stats | 95% (24 featured players accurate) | 12% (only 24/1,376 have detailed stats) | 5/10 |
| Betting/Odds | 95% | 90% | 9/10 |
| H2H Data | 95% (1 error: ARG/BRA swapped) | 75% (49 of 1,128 possible pairings) | 7/10 |
| Prediction Engine | N/A | 60% (uses only ~60% of available data) | 6/10 |
| Match Summaries | 90% | 95% (126 previews) | 9/10 |

---

## CRITICAL ISSUES (Fix Before Launch)

### 1. Mock Data Has Wrong Group Assignments - FIXED (March 1, 2026)
**File**: `lib/features/worldcup/data/mock/world_cup_mock_data.dart`
- ~~Contains pre-draw guesses, NOT the actual December 13, 2025 FIFA draw~~
- Updated all 48 teams to match actual draw: removed 13 non-qualified teams (CHI, PER, POL, SRB, UKR, WAL, UAE, CHN, NGA, CMR, CRC, JAM, HON), added 13 qualified teams (RSA, PAR, TUR, CUW, IDN, CPV, NOR, IRQ, JOR, COD, UZB, SCO, HAI), fixed all group assignments

### 2. Team JSON Files Missing 19 Metadata Fields
**Files**: `assets/data/worldcup/teams/*.json`
- Only contain: `teamCode`, `countryName`, `players[]`
- Missing: `group`, `confederation`, `fifaRanking`, `coachName`, `primaryColor`, `secondaryColor`, `worldCupTitles`, `worldCupAppearances`, `bestFinish`, `isHostNation`, `nickname`, `captainName`, `starPlayers`, `qualificationMethod`, `isQualified`, `shortName`, `flagUrl`, `federationLogoUrl`, `homeStadium`
- The `NationalTeam` entity expects all 22 fields

### 3. ARG_BRA.json H2H Win Counts Swapped - FIXED (March 1, 2026)
**File**: `assets/data/worldcup/head_to_head/ARG_BRA.json`
- ~~Shows Argentina 2 WC wins, Brazil 1 WC win~~
- Fixed: `team1WorldCupWins` = 1, `team2WorldCupWins` = 2
- Also fixed mock data H2H: removed fictional 2022 final & 2014 R16, added real 1974 WC match

### 4. Retired Players Still in Squads - FIXED (March 1, 2026)
| Player | Team | Issue | Status |
|--------|------|-------|--------|
| Angel Di Maria | ARG | Retired from international football Sep 2024 | Removed from arg.json |
| Jesus Navas | ESP | Retired from professional football Dec 2024 | Removed from esp.json |

### 5. Incorrect Player Club Transfers - FIXED (March 1, 2026)
| Player | Team | Listed Club | Actual Club | Status |
|--------|------|------------|-------------|--------|
| Garnacho | ARG | Napoli | Chelsea (Jan 2025) | Fixed in arg.json + player profile bio |
| Thiago Silva | BRA | Fluminense | Porto (Dec 2025) | Already correct in bra.json (was Porto) |

### 6. Seed Script Generates Random Stats - FIXED (March 1, 2026)
**File**: `functions/src/seed-team-players.ts`
- ~~`assists = Math.floor(player.goals * 0.5)` (fabricated)~~
- ~~`worldCupAppearances = Math.floor(Math.random() * 3)` (random!)~~
- All fabricated/random stats replaced with `0` or `player.assists || 0`
- Zero data is better than wrong data

### 7. Prediction Engine Ignores Actual H2H Data - FIXED (March 1, 2026)
**File**: `lib/features/worldcup/data/services/local_prediction_engine.dart`
- ~~Factor 5 (H2H, 10% weight) uses betting tier comparison as proxy~~
- Now loads actual H2H JSON files from `assets/data/worldcup/head_to_head/`
- H2H score = overall win% (40%) + WC-specific record (40%) + goal diff ratio (20%)
- Falls back to neutral 0.5 when no H2H file exists

---

## HIGH PRIORITY ISSUES

### 8. FIFA Code Inconsistency - FIXED (March 1, 2026)
- ~~Curacao: `CUR` in team files, `CUW` in betting_odds.json (FIFA standard is `CUW`)~~
- Standardized to `CUW` across all files: renamed team/manager/player_profile/match_summary files, updated JSON content, chatbot knowledge base, match schedule

### 9. Missing Team Squad Files for Draw Teams
| Team | Code | Group | Status |
|------|------|-------|--------|
| Turkey | TUR | D | In draw, no squad file |
| Iraq | IRQ | I | In draw, no squad file |
| DR Congo | COD | K | In draw, no squad file |
| Indonesia | IDN | F | In draw, no squad file |

### 10. Non-Qualified Teams Still in App (7 teams)
CHI (Chile), CMR (Cameroon), CRC (Costa Rica), HON (Honduras), NGA (Nigeria), PER (Peru), SRB (Serbia)

### 11. Score Prediction Too Simplistic
- Only 6 possible scorelines (0-0, 1-0, 0-1, 1-1, 2-0, 2-1)
- Real World Cup matches average ~2.5 goals with frequent 3-0, 3-1, 4-1 results
- Should implement Poisson distribution model

---

## DATA STORAGE ARCHITECTURE

### Current Data Flow
```
JSON Files (372 files, 3.4 MB)
    |
    +--> Seed Scripts (9) --> Firestore (14 collections, ~3,195 docs)
    |                              |
    |                         Hive Cache (TTLs: 30s-24h)
    |                              |
    +--> rootBundle.loadString() --> Flutter App
         (EnhancedMatchDataService,    (BLoC/Cubit UI)
          ChatbotKnowledgeBase,
          LocalPredictionEngine)
```

### Storage Capacity: Plenty of Room
- **Firestore**: Nowhere near limits. Can add 10x more data freely
- **JSON assets**: 3.4 MB compresses to ~700 KB in APK. Could add 10-20 MB more
- **App size impact**: Negligible (modern apps are 50-200 MB)

### Architecture Strengths
- Sub-5ms chatbot responses (in-memory JSON)
- Deterministic predictions with zero network calls
- Cache-first repository pattern with Firestore fallback
- Clean separation: static data (JSON) vs dynamic data (Firestore) vs user data (SharedPreferences)

### Architecture Weaknesses
- Duplicate player collections (players + worldcup_players)
- H2H data in both Firestore AND JSON, but prediction engine uses neither
- User predictions in SharedPreferences only (no Firestore sync for leaderboards)
- 6 legacy unused Firestore collections in rules

---

## PREDICTION ENGINE ANALYSIS

### Current 9-Factor Model
| Factor | Weight | Data Source | Quality |
|--------|--------|-------------|---------|
| Betting Odds | 25% | betting_odds.json | Good |
| FIFA Ranking | 20% | NationalTeam entity | Good |
| Recent Form | 15% | recent_form/*.json | Weak (ignores opponent quality) |
| Squad Value | 10% | squad_values.json | Good |
| Head-to-Head | 10% | head_to_head/*.json (actual H2H) | Good (fixed March 1) |
| Manager | 5% | managers/*.json | Good |
| Host Advantage | 5% | Hardcoded set | Good |
| WC Experience | 5% | NationalTeam entity | Good |
| Injury Impact | 5% | injury_tracker.json | Weak (only ~15 players) |

### vs Professional Models (FiveThirtyEight, Opta)
| Feature | Pro Models | Our App | Gap |
|---------|-----------|---------|-----|
| Elo ratings | Core | Not present | HIGH |
| Expected goals (xG) | Core | Not present | HIGH |
| Score simulation (Poisson) | Standard | 6-bucket thresholds | HIGH |
| Opponent-adjusted form | Always | Never | HIGH |
| Real H2H data | Always | 49 H2H files wired to engine | CLOSED (fixed) |
| Player availability | Detailed | 15 key players | MEDIUM |
| Set piece analysis | Detailed | Not present | MEDIUM |
| Monte Carlo simulation | Standard | Not present | MEDIUM |
| Travel/altitude effects | Sometimes | Never | LOW |

### Quick Wins for Prediction Quality
1. ~~**Wire actual H2H data** to Factor 5~~ DONE (March 1, 2026)
2. **Weight form by opponent quality** (opponent ranking already in the data)
3. **Weight form by competition type** (WC qualifier vs friendly, already in data)
4. **Add confederation records** as Factor 10 (data exists, never used)
5. **Implement Poisson score prediction** (realistic score distributions)

---

## WORLD CUP HISTORY DATA

### What's Verified Correct
- All 22 World Cup winners (1930-2022)
- All 19 all-time records (Klose 16 goals, Fontaine 13, Messi 26 apps, etc.)
- 12 historical patterns with source citations
- Confederation H2H records (10 pairings)
- 49 team H2H matchups (1 error found)

### What's Missing
| Data | Impact | Difficulty |
|------|--------|-----------|
| Per-team WC history (entity exists, no data!) | HIGH | MEDIUM |
| All-time top 25 scorers list | HIGH | LOW |
| All-time most appearances list | HIGH | LOW |
| Penalty shootout records by nation | HIGH | LOW |
| Greatest World Cup upsets (30+) | MEDIUM | LOW |
| Tournament-by-tournament bracket results | MEDIUM | MEDIUM |
| Red/yellow card records | LOW | LOW |
| Host nation performance data | LOW | LOW |

### Penalty Shootout Data (from research)
| Nation | W | L | Relevant for 2026? |
|--------|---|---|-------------------|
| Germany | 4 | 0 | Yes (Group E) |
| Argentina | 4 | 1 | Yes (Group J) |
| Brazil | 3 | 1 | Yes (Group C) |
| Croatia | 2 | 0 | Yes (Group L) |
| France | 2 | 2 | Yes (Group I) |
| England | 1 | 3 | Yes (Group L) |
| Spain | 1 | 3 | Yes (Group H) |
| Mexico | 0 | 2 | Yes (Group A) |

---

## VERIFIED FIFA RANKINGS (Nov 2025)

| Rank | Team | In App? | App Ranking |
|------|------|---------|-------------|
| 1 | Spain | Yes | Needs update |
| 2 | Argentina | Yes | Needs update |
| 3 | France | Yes | Needs update |
| 4 | England | Yes | Needs update |
| 5 | Brazil | Yes | Needs update |
| 6 | Portugal | Yes | Needs update |
| 7 | Netherlands | Yes | Needs update |
| 8 | Belgium | Yes | Needs update |
| 9 | Germany | Yes | Needs update |
| 10 | Croatia | Yes | Needs update |
| 14 | USA | Yes | Needs update |
| 15 | Mexico | Yes | Needs update |
| 27 | Canada | Yes | Needs update |
| 51 | Qatar | Yes | Needs update |
| 60 | Saudi Arabia | Yes | Needs update |
| 66 | Jordan | Yes | Needs update |
| 68 | Cabo Verde | Yes | Needs update |
| 82 | Curacao | Yes | Needs update |
| 84 | Haiti | Yes | Needs update |
| 86 | New Zealand | Yes | Needs update |

---

## VENUE DATA (from research)

### All 16 Stadiums with FIFA Tournament Names
| FIFA Name | Real Name | City | Capacity |
|-----------|-----------|------|----------|
| Estadio Azteca Mexico City | Estadio Azteca | Mexico City | 87,523 |
| New York New Jersey Stadium | MetLife Stadium | East Rutherford, NJ | 87,157 |
| Dallas Stadium | AT&T Stadium | Arlington, TX | 92,967 |
| Kansas City Stadium | Arrowhead Stadium | Kansas City, MO | 76,640 |
| Atlanta Stadium | Mercedes-Benz Stadium | Atlanta, GA | 75,000 |
| Houston Stadium | NRG Stadium | Houston, TX | 72,220 |
| San Francisco Bay Area Stadium | Levi's Stadium | Santa Clara, CA | 70,909 |
| Los Angeles Stadium | SoFi Stadium | Inglewood, CA | 70,240 |
| Boston Stadium | Gillette Stadium | Foxborough, MA | 70,000 |
| Philadelphia Stadium | Lincoln Financial Field | Philadelphia, PA | 69,328 |
| Seattle Stadium | Lumen Field | Seattle, WA | 69,000 |
| Miami Stadium | Hard Rock Stadium | Miami Gardens, FL | 67,518 |
| Estadio Monterrey | Estadio BBVA | Guadalupe, Mexico | 53,500 |
| BC Place Vancouver | BC Place | Vancouver, BC | 54,500 |
| Estadio Guadalajara | Estadio Akron | Zapopan, Mexico | 48,071 |
| Toronto Stadium | BMO Field | Toronto, ON | 45,736 |

---

## RECOMMENDED ACTION PLAN

### Phase 1: Critical Fixes (Before Next Build) - ALL COMPLETE (March 1, 2026)
1. ~~Fix ARG_BRA.json WC win counts~~ DONE
2. ~~Remove Di Maria from ARG squad, Jesus Navas from ESP squad~~ DONE
3. ~~Fix Garnacho club (Chelsea), Thiago Silva club (Porto)~~ DONE
4. ~~Update mock data group assignments to match actual draw~~ DONE
5. ~~Fix Curacao FIFA code standardization (CUR -> CUW)~~ DONE
6. ~~Fix seed script random stats (zero > wrong)~~ DONE
7. ~~Wire actual H2H data to prediction engine Factor 5~~ DONE

### Phase 2: Data Enrichment (Next 2 Weeks)
8. Create `teams_metadata.json` with all 19 missing fields for 48 teams
9. Add opponent-quality weighting to form scoring
9. Create per-team WC history JSON files (48 teams)
10. Expand records.json from 19 to 40+ records
11. Add penalty shootout records JSON file
12. Add all-time top scorers and appearances lists
13. Create squad files for TUR, IRQ, COD, IDN (if confirmed)
14. Update FIFA rankings to current values

### Phase 3: Prediction Engine Upgrades (Next Month)
15. Implement Poisson score prediction (replace 6-bucket system)
16. Add confederation records as prediction Factor 10
17. Add attack/defense strength decomposition
18. Expand injury tracker from 15 to 200+ players
19. Add qualifying campaign statistics JSON
20. Add team tactical profiles JSON

### Phase 4: World-Class Differentiators (Before Tournament)
21. Build Elo rating system from historical data
22. Add Monte Carlo tournament simulation
23. Create venue/city factor analysis (altitude, climate, travel)
24. Add greatest upsets dataset for chatbot
25. Wire match summaries (126 files) into prediction output
26. Sync user predictions to Firestore for leaderboards

---

## SOURCES
- [FIFA World Cup 2026 Official](https://www.fifa.com/en/tournaments/mens/worldcup/canadamexicousa2026)
- [FIFA World Rankings](https://inside.fifa.com/fifa-world-ranking/men)
- [FOX4 - FIFA Rankings for Qualified Teams](https://www.fox4news.com/sports/world-cup-2026-fifa-world-rankings-qualified-teams)
- [Planet World Cup - Penalty Shootout Records](https://www.planetworldcup.com/STATS/stat_pens.html)
- [NBC Sports - 2026 World Cup Schedule](https://www.nbcsports.com/soccer/news/2026-world-cup-schedule-confirmed-dates-times-stadiums-full-details)
- [Olympics.com - World Cup Top Scorers](https://www.olympics.com/en/news/most-goals-in-fifa-world-cup-football-top-scorers)
- [FIFA - Miroslav Klose Record](https://www.fifa.com/en/tournaments/mens/worldcup/articles/miroslav-klose-germany-top-goalscorer)
- [Opta Analyst - Penalty Shootout Facts](https://theanalyst.com/articles/world-cup-penalty-shootouts-the-facts)
- [Wikipedia - List of World Cup Penalty Shootouts](https://en.wikipedia.org/wiki/List_of_FIFA_World_Cup_penalty_shoot-outs)

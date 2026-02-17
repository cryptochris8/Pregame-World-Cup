# How-To: Migrate from Hardcoded Seeding to JSON-Based Seeding

> **Status: COMPLETE** - Migration finished February 16, 2026 (commit `292a8cf`)

This guide documents the completed migration of the Pregame World Cup app's Firestore seeding from hardcoded TypeScript data to JSON asset files, matching the approach used in the Pregame CFB app.

## Why We Migrated

- **Single source of truth** - JSON files serve both the Flutter app (offline) and Firestore (cloud). No data drift.
- **Easier maintenance** - Edit JSON, re-run seed. No TypeScript changes needed.
- **Smaller seed scripts** - Reduced from ~12,800 lines down to ~850 lines (93% reduction).
- **Consistency** - Same pattern across Pregame CFB, Pregame World Cup, and future apps.
- **No impact on users** - Firestore documents are identical either way.

## What Changed

### Before (13 scripts, ~12,800 lines)

| Script | Lines | Collection | Data |
|--------|-------|------------|------|
| `seed-team-players.ts` | 1,786 | `players` | 39 team rosters (~23 players each) |
| `seed-remaining-team-players.ts` | 436 | `worldcup_players` | 9 additional team rosters |
| `seed-managers.ts` | 1,107 | `managers` | 48 national team managers |
| `seed-june2026-matches.ts` | 250 | `worldcup_matches` | 72 group stage matches |
| `seed-knockout-matches.ts` | 167 | `worldcup_matches` | 32 knockout matches |
| `seed-head-to-head.ts` | 940 | `headToHead` | Historical team matchups |
| `seed-head-to-head-june2026.ts` | 795 | `headToHead` | 2026 tournament H2H |
| `seed-world-cup-history.ts` | 920 | `worldCupHistory` / `worldCupRecords` | Tournaments 1930-2022 |
| `seed-player-world-cup-stats.ts` | 688 | `players` | Player career WC stats |
| `seed-match-summaries.ts` | 1,171 | `matchSummaries` | Match previews |
| `seed-remaining-summaries.ts` | 1,880 | `matchSummaries` | Additional match previews |
| `seed-all-match-summaries.ts` | 2,028 | `matchSummaries` | Comprehensive 72-match set |
| `seed-venue-enhancements.ts` | 696 | `venue_enhancements` | Venue TV setups & specials |

### After (9 scripts, ~850 lines)

| Script | Lines | Collection | Notes |
|--------|-------|------------|-------|
| `seed-team-players.ts` | 200 | `players` + `worldcup_players` | Consolidated (absorbed remaining-team-players) |
| `seed-managers.ts` | 43 | `managers` | Thin JSON reader |
| `seed-june2026-matches.ts` | 45 | `worldcup_matches` | Thin JSON reader |
| `seed-knockout-matches.ts` | 45 | `worldcup_matches` | Thin JSON reader |
| `seed-head-to-head.ts` | 41 | `headToHead` | Consolidated (absorbed h2h-june2026) |
| `seed-world-cup-history.ts` | 54 | `worldCupHistory` / `worldCupRecords` | Thin JSON reader |
| `seed-player-world-cup-stats.ts` | 82 | `players` | Thin JSON reader |
| `seed-match-summaries.ts` | 87 | `matchSummaries` | Consolidated (absorbed remaining + all summaries) |
| `seed-venue-enhancements.ts` | 60 | `venue_enhancements` | Thin JSON reader |
| `seed-utils.ts` | 192 | — | Shared utilities |

### Deleted Scripts (4 files consolidated into parents)

- `seed-remaining-team-players.ts` → merged into `seed-team-players.ts`
- `seed-head-to-head-june2026.ts` → merged into `seed-head-to-head.ts`
- `seed-remaining-summaries.ts` → merged into `seed-match-summaries.ts`
- `seed-all-match-summaries.ts` → merged into `seed-match-summaries.ts`

### JSON Asset Structure

```
assets/data/worldcup/
├── teams/              # 53 team JSON files (48 + 5 extra codes)
├── managers/           # 48 manager JSON files
├── matches/
│   ├── group_stage.json    # 72 group matches
│   └── knockout.json       # 32 knockout matches
├── head_to_head/       # 49 matchup JSON files
├── match_summaries/    # 126 match summary JSON files
├── history/
│   ├── tournaments.json    # All World Cups 1930-2022
│   └── records.json        # All-time records
├── player_stats/       # 24 player career stat files
└── venues/
    └── enhancements.json   # Venue TV setups & specials
```

All directories registered in `pubspec.yaml`. All scripts listed in `functions/package.json` including `seed-all`.

## How to Use

### Seed everything

```bash
cd functions
npm run seed-all
```

### Seed a specific dataset

```bash
npm run seed-team-players
npm run seed-managers
npm run seed-matches-group
npm run seed-matches-knockout
npm run seed-head-to-head
npm run seed-match-summaries
npm run seed-world-cup-history
npm run seed-player-wc-stats
npm run seed-venue-enhancements
```

### CLI flags (supported by all scripts)

```bash
# Preview without writing to Firestore
npm run seed-team-players -- --dryRun

# Seed a single team (where applicable)
npm run seed-team-players -- --team=USA

# Clear collection before seeding
npm run seed-managers -- --clear

# Verbose logging
npm run seed-team-players -- --verbose
```

### Updating data

1. Edit the relevant JSON file(s) in `assets/data/worldcup/`
2. Run the corresponding seed script to push to Firestore
3. No TypeScript changes needed

### Validating JSON files

```bash
node -e "
  const fs = require('fs');
  const path = require('path');
  let count = 0, errors = 0;
  function check(dir) {
    for (const f of fs.readdirSync(dir, {withFileTypes: true})) {
      const p = path.join(dir, f.name);
      if (f.isDirectory()) check(p);
      else if (f.name.endsWith('.json')) {
        count++;
        try { JSON.parse(fs.readFileSync(p, 'utf8')); }
        catch(e) { errors++; console.log('INVALID:', p, e.message); }
      }
    }
  }
  check('assets/data/worldcup');
  console.log(count + ' files checked, ' + errors + ' invalid');
"
```

## Remaining (Optional)

- [ ] Create `WorldCupLocalDataService` for offline-first Flutter access (like CFB app's `SECLocalDataService`)
- [ ] Run `seed-all` to verify Firestore output matches original seeded data
- [ ] Data verification pass against authoritative sources (FIFA.com, Transfermarkt) before launch

## File Count Summary

| | Before | After |
|---|---|---|
| Seed scripts | 13 files, ~12,800 lines | 9 files + utils, ~850 lines |
| JSON data files | ~300 files (existed but unused) | ~300 files (single source of truth) |
| Duplication | Data in both scripts and JSON | JSON only, scripts read from it |

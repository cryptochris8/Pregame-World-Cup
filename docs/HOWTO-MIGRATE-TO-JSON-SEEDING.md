# How-To: Migrate from Hardcoded Seeding to JSON-Based Seeding

This guide explains how to convert the Pregame World Cup app's Firestore seeding from hardcoded TypeScript data to JSON asset files, matching the approach used in the Pregame CFB app.

## Why Migrate?

- **Single source of truth** - JSON files serve both the Flutter app (offline) and Firestore (cloud). No data drift.
- **Easier maintenance** - Edit JSON, re-run seed. No TypeScript changes needed.
- **Smaller seed scripts** - Each goes from 700-4,000 lines down to ~50-100 lines.
- **Consistency** - Same pattern across Pregame CFB, Pregame World Cup, and future apps.
- **No impact on users** - Firestore documents are identical either way.

## Current State

### Seed Scripts (13 files, ~17,000 lines total)

| Script | Lines | Collection | Data |
|--------|-------|------------|------|
| `seed-team-players.ts` | 1,786 | `players` | 39 team rosters (~23 players each) |
| `seed-remaining-team-players.ts` | 2,368 | `worldcup_players` | 9 additional team rosters |
| `seed-managers.ts` | 1,107 | `managers` | 30+ national team managers |
| `seed-june2026-matches.ts` | 250 | `worldcup_matches` | 72 group stage matches |
| `seed-knockout-matches.ts` | 167 | `worldcup_matches` | 32 knockout matches |
| `seed-head-to-head.ts` | 940 | `headToHead` | Historical team matchups |
| `seed-head-to-head-june2026.ts` | 683 | `headToHead` | 2026 tournament H2H |
| `seed-world-cup-history.ts` | 920 | `worldCupHistory` / `worldCupRecords` | Tournaments 1930-2022 |
| `seed-player-world-cup-stats.ts` | 688 | `players` | Player career WC stats |
| `seed-match-summaries.ts` | 1,171 | `matchSummaries` | Match previews |
| `seed-remaining-summaries.ts` | 4,357 | `matchSummaries` | Additional match previews |
| `seed-all-match-summaries.ts` | 3,888 | `matchSummaries` | Comprehensive 72-match set |
| `seed-venue-enhancements.ts` | 696 | `venue_enhancements` | Venue TV setups & specials |

### Current Assets (No JSON data)

```
assets/
├── images/         # SVGs
├── logos/           # App branding
└── Marketing/      # Promo images
```

## Target State

### New Asset Structure

```
assets/
├── data/
│   └── worldcup/
│       ├── teams/                    # 48 team files
│       │   ├── usa.json
│       │   ├── mex.json
│       │   ├── bra.json
│       │   └── ...
│       ├── managers/                 # 48 manager files
│       │   ├── usa.json
│       │   ├── mex.json
│       │   └── ...
│       ├── matches/
│       │   ├── group_stage.json      # 72 group matches
│       │   └── knockout.json         # 32 knockout matches
│       ├── head_to_head/             # One file per matchup
│       │   ├── ARG_BRA.json
│       │   ├── ENG_FRA.json
│       │   └── ...
│       ├── match_summaries/          # One file per matchup
│       │   ├── ARG_BRA.json
│       │   ├── MEX_RSA.json
│       │   └── ...
│       ├── history/
│       │   ├── tournaments.json      # All World Cups 1930-2022
│       │   └── records.json          # All-time records
│       ├── player_stats/             # Per-player WC career stats
│       │   ├── Lionel_Messi_ARG.json
│       │   ├── Kylian_Mbappe_FRA.json
│       │   └── ...
│       └── venues/
│           └── enhancements.json     # Venue TV setups & specials
├── images/
├── logos/
└── Marketing/
```

### New Seed Scripts (~100 lines each)

Each seed script becomes a thin reader that loads JSON and uploads to Firestore.

## Step-by-Step Migration

### Step 1: Create the JSON Asset Directory Structure

```bash
mkdir -p assets/data/worldcup/{teams,managers,matches,head_to_head,match_summaries,history,player_stats,venues}
```

### Step 2: Extract Data from Seed Scripts into JSON Files

This is the bulk of the work. For each seed script, extract the hardcoded data arrays/objects into standalone JSON files.

**Example: Extracting team players**

Before (`seed-team-players.ts`, 1,786 lines):
```typescript
const teams: Record<string, TeamData> = {
  USA: {
    players: [
      {
        firstName: "Christian",
        lastName: "Pulisic",
        jerseyNumber: 10,
        position: "LW",
        dateOfBirth: "1998-09-18",
        club: "AC Milan",
        marketValue: 55000000,
        caps: 67,
        goals: 27,
        // ...
      },
      // ... 22 more players
    ]
  },
  // ... 38 more teams
};
```

After (`assets/data/worldcup/teams/usa.json`):
```json
{
  "fifaCode": "USA",
  "countryName": "United States",
  "players": [
    {
      "firstName": "Christian",
      "lastName": "Pulisic",
      "jerseyNumber": 10,
      "position": "LW",
      "dateOfBirth": "1998-09-18",
      "club": "AC Milan",
      "marketValue": 55000000,
      "caps": 67,
      "goals": 27
    }
  ]
}
```

Repeat for each of the 48 teams. The data is identical - you're just moving it from TypeScript into JSON.

#### Extraction order (by priority):

1. **Teams** - Extract from `seed-team-players.ts` + `seed-remaining-team-players.ts` into 48 individual JSON files in `assets/data/worldcup/teams/`
2. **Managers** - Extract from `seed-managers.ts` into 48 files in `assets/data/worldcup/managers/`
3. **Matches** - Extract from `seed-june2026-matches.ts` + `seed-knockout-matches.ts` into `assets/data/worldcup/matches/`
4. **Head-to-Head** - Extract from `seed-head-to-head.ts` + `seed-head-to-head-june2026.ts` into individual files in `assets/data/worldcup/head_to_head/`
5. **Match Summaries** - Extract from `seed-match-summaries.ts` + `seed-remaining-summaries.ts` + `seed-all-match-summaries.ts` into individual files in `assets/data/worldcup/match_summaries/`
6. **History** - Extract from `seed-world-cup-history.ts` into `assets/data/worldcup/history/`
7. **Player Stats** - Extract from `seed-player-world-cup-stats.ts` into individual files in `assets/data/worldcup/player_stats/`
8. **Venues** - Extract from `seed-venue-enhancements.ts` into `assets/data/worldcup/venues/`

### Step 3: Register New Assets in pubspec.yaml

Add the new directories to `pubspec.yaml` under the `assets:` section:

```yaml
assets:
  - assets/logos/
  - assets/images/
  # World Cup Data (local JSON for offline-first experience)
  - assets/data/worldcup/teams/
  - assets/data/worldcup/managers/
  - assets/data/worldcup/matches/
  - assets/data/worldcup/head_to_head/
  - assets/data/worldcup/match_summaries/
  - assets/data/worldcup/history/
  - assets/data/worldcup/player_stats/
  - assets/data/worldcup/venues/
```

### Step 4: Create a Shared Seed Utility

Create `functions/src/seed-utils.ts` (if not already present) with shared logic:

```typescript
import * as admin from "firebase-admin";
import * as fs from "fs";
import * as path from "path";

// Initialize Firebase Admin
export function initFirebase(): admin.firestore.Firestore {
  if (!admin.apps.length) {
    admin.initializeApp({
      projectId: "pregame-b089e",
    });
  }
  return admin.firestore();
}

// Parse CLI arguments
export function parseArgs(): { dryRun: boolean; filter?: string } {
  const args = process.argv.slice(2);
  return {
    dryRun: args.includes("--dryRun"),
    filter: args.find((a) => a.startsWith("--team="))?.split("=")[1],
  };
}

// Read all JSON files from a directory
export function readJsonDir(dirPath: string): Record<string, any>[] {
  const fullPath = path.resolve(__dirname, dirPath);
  const files = fs.readdirSync(fullPath).filter((f) => f.endsWith(".json"));
  return files.map((file) => {
    const content = fs.readFileSync(path.join(fullPath, file), "utf-8");
    return JSON.parse(content);
  });
}

// Read a single JSON file
export function readJsonFile(filePath: string): any {
  const fullPath = path.resolve(__dirname, filePath);
  const content = fs.readFileSync(fullPath, "utf-8");
  return JSON.parse(content);
}

// Batch write to Firestore (respects 500-doc limit)
export async function batchWrite(
  db: admin.firestore.Firestore,
  collection: string,
  docs: { id: string; data: any }[],
  dryRun: boolean
): Promise<void> {
  if (dryRun) {
    console.log(`[DRY RUN] Would write ${docs.length} docs to '${collection}'`);
    docs.forEach((d) => console.log(`  - ${d.id}`));
    return;
  }

  let batch = db.batch();
  let count = 0;

  for (const doc of docs) {
    const ref = db.collection(collection).doc(doc.id);
    batch.set(ref, {
      ...doc.data,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });
    count++;

    if (count % 490 === 0) {
      await batch.commit();
      console.log(`  Committed batch of ${count} docs`);
      batch = db.batch();
    }
  }

  if (count % 490 !== 0) {
    await batch.commit();
  }

  console.log(`Wrote ${docs.length} docs to '${collection}'`);
}
```

### Step 5: Rewrite Each Seed Script

Replace each large seed script with a thin JSON reader.

**Example: seed-team-players.ts (from 1,786 lines to ~30 lines)**

```typescript
import { initFirebase, parseArgs, readJsonDir, batchWrite } from "./seed-utils";

async function main() {
  const db = initFirebase();
  const { dryRun, filter } = parseArgs();

  console.log(`Seeding team players${dryRun ? " (DRY RUN)" : ""}...`);

  let teams = readJsonDir("../../assets/data/worldcup/teams");

  if (filter) {
    teams = teams.filter((t) => t.fifaCode === filter.toUpperCase());
    console.log(`Filtered to team: ${filter.toUpperCase()}`);
  }

  const docs: { id: string; data: any }[] = [];
  for (const team of teams) {
    for (const player of team.players) {
      const docId = `${player.firstName}_${player.lastName}_${team.fifaCode}`;
      docs.push({ id: docId, data: { ...player, currentTeamCode: team.fifaCode } });
    }
  }

  await batchWrite(db, "players", docs, dryRun);
  console.log("Done!");
}

main().catch(console.error);
```

**Example: seed-managers.ts (from 1,107 lines to ~25 lines)**

```typescript
import { initFirebase, parseArgs, readJsonDir, batchWrite } from "./seed-utils";

async function main() {
  const db = initFirebase();
  const { dryRun, filter } = parseArgs();

  console.log(`Seeding managers${dryRun ? " (DRY RUN)" : ""}...`);

  let managers = readJsonDir("../../assets/data/worldcup/managers");

  if (filter) {
    managers = managers.filter((m) => m.currentTeamCode === filter.toUpperCase());
  }

  const docs = managers.map((m) => ({
    id: `manager_${m.currentTeamCode.toLowerCase()}`,
    data: m,
  }));

  await batchWrite(db, "managers", docs, dryRun);
  console.log("Done!");
}

main().catch(console.error);
```

Repeat this pattern for all 13 seed scripts. Each becomes 20-40 lines.

### Step 6: Update package.json Scripts

The npm scripts stay the same - only the underlying TypeScript files change:

```json
"seed-team-players": "ts-node src/seed-team-players.ts",
"seed-managers": "ts-node src/seed-managers.ts",
"seed-all": "npm run seed-team-players && npm run seed-managers && npm run seed-head-to-head && npm run seed-world-cup-history && npm run seed-player-wc-stats"
```

No changes needed here since the filenames remain the same.

### Step 7: Consolidate Duplicate Seed Scripts

Several scripts exist because the original approach ran out of space in a single file:

| Originals | Merge Into |
|-----------|------------|
| `seed-team-players.ts` + `seed-remaining-team-players.ts` | `seed-team-players.ts` (reads all 48 team JSONs) |
| `seed-match-summaries.ts` + `seed-remaining-summaries.ts` + `seed-all-match-summaries.ts` | `seed-match-summaries.ts` (reads all summary JSONs) |
| `seed-head-to-head.ts` + `seed-head-to-head-june2026.ts` | `seed-head-to-head.ts` (reads all H2H JSONs) |

This eliminates 4 redundant scripts entirely.

### Step 8: (Optional) Create a Local Data Service

To enable offline-first access in the Flutter app (like the CFB app's `SECLocalDataService`), create a `WorldCupLocalDataService`:

```dart
class WorldCupLocalDataService {
  final Map<String, dynamic> _cache = {};

  Future<List<Map<String, dynamic>>> loadTeams() async {
    final teams = <Map<String, dynamic>>[];
    // Read from assets/data/worldcup/teams/*.json
    // Similar to SECLocalDataService in the CFB app
    return teams;
  }

  Future<Map<String, dynamic>?> loadTeam(String fifaCode) async {
    final json = await rootBundle.loadString(
      'assets/data/worldcup/teams/${fifaCode.toLowerCase()}.json'
    );
    return jsonDecode(json);
  }
}
```

This gives the World Cup app the same offline-first capability the CFB app has.

### Step 9: Validate JSON Files

After extraction, validate all JSON files:

```bash
# From project root
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

### Step 10: Test Seeding

```bash
cd functions

# Dry run first
npm run seed-team-players -- --dryRun

# Seed a single team
npm run seed-team-players -- --team=USA

# Seed everything
npm run seed-all
```

## Checklist

- [ ] Create `assets/data/worldcup/` directory structure
- [ ] Extract team player data into 48 JSON files
- [ ] Extract manager data into 48 JSON files
- [ ] Extract match schedule into JSON files
- [ ] Extract head-to-head records into JSON files
- [ ] Extract match summaries into JSON files
- [ ] Extract World Cup history into JSON files
- [ ] Extract player WC stats into JSON files
- [ ] Extract venue enhancements into JSON file
- [ ] Validate all JSON files
- [ ] Create `seed-utils.ts` with shared utilities
- [ ] Rewrite all seed scripts to read from JSON
- [ ] Consolidate duplicate scripts (3 merged into 1 each)
- [ ] Update `pubspec.yaml` with new asset directories
- [ ] Test with `--dryRun`
- [ ] Test with single team `--team=USA`
- [ ] Run full `seed-all`
- [ ] Verify Firestore data matches original
- [ ] (Optional) Create `WorldCupLocalDataService` for offline-first
- [ ] Delete old hardcoded data from seed scripts
- [ ] Update `seed-all` script in package.json

## File Count Comparison

| | Before | After |
|---|---|---|
| Seed scripts | 13 files, ~17,000 lines | 9 files, ~300 lines |
| JSON data files | 0 | ~200+ files |
| Total data lines | ~17,000 (in TypeScript) | ~17,000 (in JSON) |
| Duplication | Data in scripts only, not in app assets | Single source for both |

## Notes

- The JSON files are the same data - just extracted from TypeScript into standalone files.
- Firestore documents are identical regardless of approach. No user-facing changes.
- The `--dryRun` and `--team=` CLI flags continue to work.
- The `seed-all` npm script continues to work.
- This migration can be done incrementally - convert one script at a time.

# World Cup 2026 Data Population Guide

**Status**: ✅ Seed Data Ready
**Priority #3**: Populate Real World Cup Data

---

## Overview

This guide covers populating Firebase Firestore with World Cup 2026 data including teams, venues, groups, and matches.

---

## 📊 Seed Data Created

### 1. National Teams (25/48 Complete)
**File**: `data/seed/teams/world_cup_teams.json`

**Included Teams** (25):
- ✅ Host Nations: USA, MEX, CAN
- ✅ UEFA: GER, FRA, ESP, ENG, NED, POR, BEL, ITA, CRO, DEN, SUI, POL
- ✅ CONMEBOL: BRA, ARG, URU, COL, ECU
- ✅ AFC: JPN, KOR, AUS
- ✅ CAF: SEN, MAR
- ✅ CONCACAF: CRC

**Data Fields Per Team**:
```json
{
  "fifaCode": "USA",
  "countryName": "United States",
  "shortName": "USA",
  "flagUrl": "assets/worldcup/flags/usa.png",
  "confederation": "CONCACAF",
  "fifaRanking": 13,
  "group": "A",
  "worldCupTitles": 0,
  "worldCupAppearances": 11,
  "bestFinish": "Third Place (1930)",
  "isHostNation": true,
  "nickname": "USMNT",
  "coachName": "Gregg Berhalter",
  "captainName": "Christian Pulisic",
  "starPlayers": ["Christian Pulisic", "Weston McKennie", ...],
  "qualificationMethod": "Host Nation",
  "isQualified": true,
  "primaryColor": "#002868",
  "secondaryColor": "#BF0A30"
}
```

**Remaining Teams to Add** (23):
- UEFA: SWE, AUT, SCO, WAL, NOR, CZE, UKR, etc. (based on qualifiers)
- CONMEBOL: CHI, PER, PAR
- AFC: IRN, KSA, QAT, IRQ, UAE
- CAF: NGA, EGY, TUN, CMR, GHA, ALG, CIV
- CONCACAF: JAM, PAN, HON
- OFC: NZL

### 2. World Cup Venues (16/16 Complete) ✅
**File**: `data/seed/venues/world_cup_venues.json`

**All 16 Stadiums Included**:
- 🇺🇸 USA (11): MetLife, AT&T, Mercedes-Benz, SoFi, Hard Rock, NRG, Lincoln Financial, Lumen, Levi's, Gillette, Arrowhead
- 🇲🇽 Mexico (3): Estadio Azteca, Estadio Akron, Estadio BBVA
- 🇨🇦 Canada (2): BMO Field, BC Place

**Data Fields Per Venue**:
```json
{
  "venueId": "metlife",
  "name": "MetLife Stadium",
  "city": "East Rutherford",
  "state": "New Jersey",
  "country": "USA",
  "capacity": 82500,
  "latitude": 40.8128,
  "longitude": -74.0742,
  "timeZone": "America/New_York",
  "imageUrl": "assets/worldcup/stadiums/metlife_stadium.jpg",
  "address": "1 MetLife Stadium Dr, East Rutherford, NJ 07073",
  "significance": "FINAL VENUE",
  "matchesHosted": 8,
  "description": "..."
}
```

### 3. Group Structure (12 Groups)
- Groups A-L (12 groups of 4 teams each)
- Automatically created by population script

### 4. Sample Matches (4 Created, 100 Remaining)
- Opening Match (Estadio Azteca, June 11, 2026)
- Canada Opening Match (BMO Field, June 12, 2026)
- USA Opening Match (SoFi Stadium, June 12, 2026)
- Final (MetLife Stadium, July 19, 2026)

**Note**: Full 104-match schedule will be populated when FIFA releases official fixtures.

---

## 🚀 How to Populate Firestore

### Prerequisites

1. **Firebase Service Account Key**
   - Go to Firebase Console → Project Settings → Service Accounts
   - Click "Generate New Private Key"
   - Save as `firebase-service-account.json` in project root
   - ⚠️ **DO NOT** commit this file to Git

2. **Node.js Dependencies**
   ```bash
   npm install firebase-admin
   ```

### Step 1: Run Population Script

```bash
node scripts/populate_firestore.js
```

**Expected Output**:
```
============================================================
     FIFA World Cup 2026 - Firestore Data Population
============================================================

🏴 Uploading National Teams...
✅ Successfully uploaded 25 national teams

🏟️  Uploading World Cup Venues...
✅ Successfully uploaded 16 venues

📊 Creating Group Stage Structure...
✅ Successfully created 12 group structures

🎯 Assigning Teams to Groups...
   Group A: USA, BRA, ECU, TBD
   Group B: MEX, ARG, CRC, TBD
   ...
✅ Successfully assigned teams to 12 groups

⚽ Creating Sample Match Structure...
✅ Successfully created 4 sample matches

============================================================
     Data Population Complete!
============================================================

📊 Summary:
   ✅ National Teams: 25
   ✅ Venues: 16
   ✅ Groups: 12
   ✅ Sample Matches: 4

🎉 All data successfully uploaded to Firestore!
```

### Step 2: Verify in Firebase Console

1. Go to https://console.firebase.google.com/
2. Select project: `pregame-b089e`
3. Navigate to Firestore Database
4. Verify collections:
   - `national_teams` (25 documents)
   - `world_cup_venues` (16 documents)
   - `groups` (12 documents)
   - `world_cup_matches` (4 documents)

---

## 📝 Adding Remaining Teams

### Option 1: Edit JSON File Directly

Edit `data/seed/teams/world_cup_teams.json` and add more team objects:

```json
{
  "fifaCode": "NOR",
  "countryName": "Norway",
  "shortName": "Norway",
  "flagUrl": "assets/worldcup/flags/nor.png",
  "confederation": "UEFA",
  "fifaRanking": 40,
  "group": "E",
  ...
}
```

Then re-run: `node scripts/populate_firestore.js`

### Option 2: Use Firebase Console

1. Go to Firestore Database
2. Click `national_teams` collection
3. Click "Add Document"
4. Enter team data manually

### Option 3: Wait for Official Qualification

- World Cup 2026 qualification ends: March 2026
- FIFA will announce all 48 teams by April 2026
- Groups will be drawn: TBD (likely April 2026)

**Recommendation**: Populate remaining teams gradually as they qualify, or wait until all 48 are confirmed.

---

## ⚽ Match Schedule Population

### Current Status: 4/104 Matches (4%)

The full 104-match schedule will be available once FIFA releases official fixtures.

### Match Schedule Timeline

| Phase | Matches | Dates | Status |
|-------|---------|-------|--------|
| Group Stage | 80 | June 11-27, 2026 | ⏳ Awaiting FIFA |
| Round of 32 | 16 | June 29 - July 3, 2026 | ⏳ Awaiting FIFA |
| Round of 16 | 8 | July 5-7, 2026 | ⏳ Awaiting FIFA |
| Quarter-Finals | 4 | July 9-11, 2026 | ⏳ Awaiting FIFA |
| Semi-Finals | 2 | July 14-15, 2026 | ⏳ Awaiting FIFA |
| Third Place | 1 | July 18, 2026 | ⏳ Awaiting FIFA |
| **Final** | 1 | July 19, 2026 | ✅ Sample created |

### When to Populate Full Schedule

**Option A: Use SportsData.io API** (Recommended)
- Once FIFA releases fixtures, SportsData.io will update
- Use the `fetchScheduleFromApi()` function in Cloud Functions
- Call: `https://your-functions-url/updateSchedule?competition=FIFAWC`
- All 104 matches will be automatically fetched and saved

**Option B: Manual Entry**
- Wait for official FIFA fixtures (likely December 2025 - March 2026)
- Create match data file similar to teams/venues
- Run population script

**Option C: Use FIFA Official API**
- FIFA may provide official API access closer to tournament
- Integrate when available

---

## 🔄 Updating Data

### Update Team Information
```bash
# Edit the JSON file
vim data/seed/teams/world_cup_teams.json

# Re-run script (will merge updates)
node scripts/populate_firestore.js
```

### Update Individual Team via Firebase Console
1. Go to `national_teams` collection
2. Find team by FIFA code (e.g., `USA`)
3. Click "Edit" → Update fields → Save

### Bulk Updates
Use Firebase Admin SDK or Firestore batch writes.

---

## 🧪 Testing Data in Flutter App

### Step 1: Read Teams from Firestore

```dart
Future<List<NationalTeam>> getTeams() async {
  final snapshot = await FirebaseFirestore.instance
      .collection('national_teams')
      .get();

  return snapshot.docs
      .map((doc) => NationalTeam.fromFirestore(doc.data(), doc.id))
      .toList();
}
```

### Step 2: Read Venues

```dart
Future<List<WorldCupVenue>> getVenues() async {
  final snapshot = await FirebaseFirestore.instance
      .collection('world_cup_venues')
      .get();

  return snapshot.docs
      .map((doc) => WorldCupVenue.fromFirestore(doc.data(), doc.id))
      .toList();
}
```

### Step 3: Test in App

Run the app and verify:
- Teams screen shows all 25 teams
- Venues screen shows all 16 stadiums
- Groups screen shows 12 groups with assigned teams

---

## 📊 Data Statistics

| Data Type | Created | Total Needed | Progress |
|-----------|---------|--------------|----------|
| National Teams | 25 | 48 | 52% |
| Venues | 16 | 16 | 100% ✅ |
| Groups | 12 | 12 | 100% ✅ |
| Matches | 4 | 104 | 4% |

**Overall Data Population**: ~43% Complete

---

## 🎯 Next Steps

### Immediate (Can Do Now)
1. ✅ Run `populate_firestore.js` to upload seed data
2. ✅ Verify data in Firebase Console
3. ✅ Test data loading in Flutter app
4. ⏳ Add remaining 23 teams as they qualify

### Near Future (Q1-Q2 2026)
1. Monitor World Cup qualifications
2. Update teams as they qualify
3. Assign teams to groups (after draw in ~April 2026)
4. Populate full 104-match schedule (when FIFA releases)

### Before Tournament (June 2026)
1. Verify all 48 teams are correct
2. Confirm all group assignments
3. Double-check match schedule
4. Test live score updates
5. Prepare for high traffic

---

## 🔐 Security Notes

### firestore.rules Update Needed

Current rules allow authenticated read/write to all documents. Before production:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // National teams - read-only for all users
    match /national_teams/{teamId} {
      allow read: if request.auth != null;
      allow write: if false; // Admin only via backend
    }

    // Venues - read-only
    match /world_cup_venues/{venueId} {
      allow read: if request.auth != null;
      allow write: if false; // Admin only
    }

    // Matches - read-only
    match /world_cup_matches/{matchId} {
      allow read: if request.auth != null;
      allow write: if false; // Updates via Cloud Functions only
    }

    // Groups - read-only
    match /groups/{groupId} {
      allow read: if request.auth != null;
      allow write: if false; // Admin only
    }

    // User predictions - user can write their own
    match /user_predictions/{userId}/predictions/{matchId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## 📚 Additional Resources

### FIFA World Cup 2026 Official Info
- Official Site: https://www.fifa.com/fifaplus/en/tournaments/mens/worldcup/canadamexicousa2026
- Qualification: https://www.fifa.com/tournaments/mens/worldcup/canadamexicousa2026/qualifiers

### Data Sources
- FIFA Rankings: https://www.fifa.com/fifa-world-ranking
- Team Info: https://www.transfermarkt.com/
- Venue Details: Official stadium websites

### API Documentation
- SportsData.io Soccer: https://sportsdata.io/developers/api-documentation/soccer
- Firebase Firestore: https://firebase.google.com/docs/firestore

---

**Created**: December 26, 2025
**Last Updated**: December 26, 2025
**Status**: Seed data ready for population

# Next Steps - Firestore Data Population

**Status**: Ready to populate Firestore
**Date**: December 26, 2025

---

## ✅ What We've Accomplished

1. **Fixed disk space issue** - Cleared pub cache and temp files
2. **All automated tests passing** - 13/13 tests ✅
3. **Data models validated** - WorldCupMatch, NationalTeam, WorldCupVenue working correctly
4. **Firestore collection names fixed** - Now match seed data structure

---

## 🎯 Current Step: Populate Firestore

### Prerequisites Checklist

- [x] Seed data files created:
  - `data/seed/teams/world_cup_teams.json` (25 teams)
  - `data/seed/venues/world_cup_venues.json` (16 venues)
- [x] Population script ready: `scripts/populate_firestore.js`
- [ ] **Firebase service account key** ← YOU NEED THIS
- [ ] Node.js installed (check with `node --version`)

---

## Step 1: Get Firebase Service Account Key

### Option A: Download from Firebase Console (Recommended)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **`pregame-b089e`**
3. Click the gear icon ⚙️ → **Project settings**
4. Go to **Service accounts** tab
5. Click **"Generate new private key"**
6. Click **"Generate key"** in the confirmation dialog
7. Save the downloaded JSON file as: `D:\Pregame-World-Cup\firebase-service-account.json`

⚠️ **IMPORTANT**: This file contains sensitive credentials. DO NOT commit to Git!

### Option B: Check if you already have it

Run this command to see if you have it elsewhere:
```bash
powershell -Command "Get-ChildItem -Path C:\Users\chris -Filter *firebase*.json -Recurse -ErrorAction SilentlyContinue | Select-Object FullName"
```

If found, copy it to the project root:
```bash
copy "C:\path\to\existing\firebase-service-account.json" "D:\Pregame-World-Cup\firebase-service-account.json"
```

---

## Step 2: Install Node.js Dependencies

```bash
cd D:\Pregame-World-Cup
npm install firebase-admin
```

**Expected Output**:
```
added 100 packages in 15s
```

---

## Step 3: Run Population Script

```bash
node scripts/populate_firestore.js
```

**Expected Output**:
```
🔥 Pregame World Cup 2026 - Firestore Data Population
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Connected to Firebase project: pregame-b089e

📊 Uploading National Teams...
✅ 25 national teams uploaded to 'national_teams' collection

🏟️ Uploading Venues...
✅ 16 venues uploaded to 'world_cup_venues' collection

📂 Creating Groups...
✅ 12 groups created in 'groups' collection

⚽ Creating Sample Matches...
✅ 4 sample matches created in 'world_cup_matches' collection

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎉 Data population complete!

Summary:
- National Teams: 25/48 (52%)
- Venues: 16/16 (100%)
- Groups: 12/12 (100%)
- Sample Matches: 4/104 (4%)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Step 4: Verify Data in Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select **pregame-b089e** project
3. Click **Firestore Database** in left sidebar
4. Verify these collections exist:

### national_teams (25 documents)
- USA, MEX, CAN (host nations)
- GER, FRA, ESP, ENG, NED, POR, BEL, ITA, CRO, DEN, SUI, POL (UEFA)
- BRA, ARG, URU, COL, ECU (CONMEBOL)
- JPN, KOR, AUS (AFC)
- SEN, MAR (CAF)
- CRC (CONCACAF)

### world_cup_venues (16 documents)
- metlife (Final)
- azteca (Opening Match)
- att_stadium, mercedes_benz (Semi-Finals)
- 12 other stadiums

### groups (12 documents)
- A, B, C, D, E, F, G, H, I, J, K, L

### world_cup_matches (4 documents)
- wc2026_001 (MEX vs TBD - Opening)
- wc2026_002 (CAN vs TBD - Canada Opening)
- wc2026_003 (USA vs TBD - USA Opening)
- wc2026_104 (TBD vs TBD - Final)

---

## Step 5: Test Flutter App with Real Data

Once Firestore is populated:

```bash
cd D:\Pregame-World-Cup
flutter run
```

### Quick Tests to Run:

1. **Teams Screen**:
   - Should display 25 teams
   - Search for "Brazil" → should find BRA
   - Tap on USA → should show team details

2. **Matches Screen**:
   - Should display 4 sample matches
   - Opening match: MEX vs TBD at Estadio Azteca
   - Final: TBD vs TBD at MetLife Stadium

3. **Venues Screen**:
   - Should show 16 stadiums on map
   - Tap on MetLife → should show "FINAL VENUE"

4. **Groups Screen**:
   - Should display groups A-L
   - Group A should show assigned teams

---

## Troubleshooting

### Error: "firebase-service-account.json not found"
**Solution**: Download from Firebase Console (see Step 1)

### Error: "Permission denied"
**Solution**: Verify Firebase rules allow writes (currently open for authenticated users)

### Error: "Module not found: firebase-admin"
**Solution**: Run `npm install firebase-admin`

### Data doesn't appear in app
**Solution**:
1. Check Firebase Console - verify data exists
2. Check internet connection
3. Verify collection names in datasource match (already fixed)
4. Check Firestore security rules

### "No space left on device" again
**Solution**:
- Delete more temp files
- Run `flutter clean`
- Free space on C: drive

---

## After Population - Manual UI Testing

Follow the comprehensive guide: **`docs/UI_TESTING_GUIDE.md`**

Execute all 33 test cases:
- 10 screen tests
- 5 edge case tests
- Performance tests

Document results in: **`docs/TEST_RESULTS.md`** (append to existing file)

---

## Summary: Where We Are

### ✅ Completed (Priority #4 Progress: 60%)
- [x] Fixed Firestore collection name bug
- [x] Created comprehensive testing guide
- [x] Created automated unit tests
- [x] All 13 automated tests passing
- [x] Resolved disk space issue
- [x] Added fake_cloud_firestore dependency

### 🔄 Current Step
- [ ] **Get Firebase service account key** ← START HERE
- [ ] Install firebase-admin
- [ ] Run population script
- [ ] Verify data in Firebase Console

### ⏳ Remaining (Priority #4)
- [ ] Run Flutter app
- [ ] Execute 33 manual UI tests
- [ ] Document test results
- [ ] Fix any bugs found
- [ ] Mark Priority #4 complete

### 📋 Next Priority
- **Priority #5**: Review and tighten Firestore security rules

---

## Quick Commands Reference

```bash
# Check if Node.js is installed
node --version

# Install dependencies
npm install firebase-admin

# Run population script
node scripts/populate_firestore.js

# Run Flutter app
flutter run

# Run automated tests
flutter test test/worldcup_data_test.dart
```

---

**Current Status**: ⏸️ Waiting for Firebase service account key
**Next Action**: Download service account key from Firebase Console
**ETA to Complete Priority #4**: 30-60 minutes (after key obtained)

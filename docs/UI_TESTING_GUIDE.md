# World Cup UI Testing Guide

**Priority #4**: Test World Cup UI with New Data Models
**Status**: 🧪 Ready for Testing
**Date**: December 26, 2025

---

## Overview

This guide covers testing all World Cup UI screens with the newly populated Firestore data. We'll verify that data loads correctly, displays properly, and handles edge cases.

---

## ✅ Pre-Testing Checklist

Before running tests, ensure:

- [x] **Firestore Collections Updated**: Collection names match seed data
  - `world_cup_matches` ✅
  - `national_teams` ✅
  - `groups` ✅
  - `world_cup_venues` ✅

- [ ] **Data Populated in Firestore**: Run population script
  ```bash
  node scripts/populate_firestore.js
  ```

- [ ] **Firebase Configured**: Check `google-services.json` (Android) / `GoogleService-Info.plist` (iOS)

- [ ] **Dependencies Installed**:
  ```bash
  flutter pub get
  ```

- [ ] **App Builds Successfully**:
  ```bash
  flutter build apk --debug  # Android
  # OR
  flutter build ios --debug  # iOS
  ```

---

## 🎯 Testing Scope

### Screens to Test (10 Total)

1. **World Cup Home Screen** - Main landing with tabs
2. **Matches Tab** - List of all 104 matches
3. **Groups Tab** - Group standings A-L
4. **Bracket Tab** - Knockout tournament bracket
5. **Teams Tab** - All 48 national teams
6. **Favorites Tab** - User's favorite teams
7. **Match Detail Page** - Individual match view
8. **Team Detail Page** - Individual team profile
9. **Predictions Page** - User match predictions
10. **Venues Screen** - 16 stadiums

---

## 📋 Test Cases

### Test Case 1: Teams Tab

#### Test 1.1: Load All Teams
**Steps**:
1. Open app
2. Navigate to World Cup section
3. Tap on "Teams" tab

**Expected Results**:
- ✅ Loading indicator appears briefly
- ✅ 25 teams display (until all 48 added)
- ✅ Each team shows:
  - Country flag
  - Country name
  - FIFA ranking
  - Confederation badge
- ✅ Teams sorted by FIFA ranking (default)
- ✅ No error messages

**Actual Results**: _____________________________

**Pass/Fail**: [ ]

#### Test 1.2: Filter by Confederation
**Steps**:
1. On Teams tab
2. Tap confederation filter (e.g., "UEFA")

**Expected Results**:
- ✅ Shows only UEFA teams (12 teams)
- ✅ Filter chip highlighted
- ✅ Tap "All" to reset

**Actual Results**: _____________________________

**Pass/Fail**: [ ]

#### Test 1.3: Sort Options
**Steps**:
1. On Teams tab
2. Tap sort button
3. Select "Alphabetical"

**Expected Results**:
- ✅ Teams re-sort A-Z by country name
- ✅ Argentina, Australia, Austria... order

**Actual Results**: _____________________________

**Pass/Fail**: [ ]

#### Test 1.4: Search Teams
**Steps**:
1. On Teams tab
2. Tap search icon
3. Type "Brazil"

**Expected Results**:
- ✅ Only Brazil appears
- ✅ Shows Brazil flag, ranking, etc.
- ✅ Clear search shows all teams again

**Actual Results**: _____________________________

**Pass/Fail**: [ ]

---

### Test Case 2: Team Detail Page

#### Test 2.1: View Team Details
**Steps**:
1. On Teams tab
2. Tap on "USA" team

**Expected Results**:
- ✅ Opens Team Detail Page
- ✅ Shows USA flag (large)
- ✅ Displays team info:
  - Full name: "United States"
  - FIFA Ranking: 13
  - Confederation: CONCACAF
  - Group: A
  - Coach: Gregg Berhalter
  - Captain: Christian Pulisic
  - Star Players: Pulisic, McKennie, Adams, Reyna
  - World Cup History: 11 appearances
  - Best Finish: Third Place (1930)
- ✅ Shows "Host Nation" badge
- ✅ Primary/Secondary colors display correctly

**Actual Results**: _____________________________

**Pass/Fail**: [ ]

#### Test 2.2: Team Matches Section
**Steps**:
1. On USA Team Detail page
2. Scroll to "Matches" section

**Expected Results**:
- ✅ Shows USA's matches (at least opening match)
- ✅ Match card shows:
  - Opponent
  - Date/Time
  - Venue (SoFi Stadium)
  - Status (Scheduled)

**Actual Results**: _____________________________

**Pass/Fail**: [ ]

#### Test 2.3: Add to Favorites
**Steps**:
1. On Team Detail page
2. Tap heart/favorite icon

**Expected Results**:
- ✅ Icon fills/changes color
- ✅ Team added to Favorites tab
- ✅ Toast/snackbar confirms "USA added to favorites"

**Actual Results**: _____________________________

**Pass/Fail**: [ ]

---

### Test Case 3: Matches Tab

#### Test 3.1: Load All Matches
**Steps**:
1. Open World Cup section
2. Tap "Matches" tab (default tab)

**Expected Results**:
- ✅ Shows 4 sample matches (until full schedule added)
- ✅ Matches in chronological order
- ✅ Each match card shows:
  - Match number
  - Teams (or placeholders like "TBD")
  - Venue name and city
  - Date and time (local time)
  - Status badge (Scheduled, Live, etc.)
- ✅ Opening match highlighted/badged

**Actual Results**: _____________________________

**Pass/Fail**: [ ]

#### Test 3.2: Filter by Date
**Steps**:
1. On Matches tab
2. Tap date filter
3. Select "Today"

**Expected Results**:
- ✅ Shows only today's matches (likely 0 until 2026)
- ✅ "No matches today" message if empty

**Actual Results**: _____________________________

**Pass/Fail**: [ ]

#### Test 3.3: Filter by Stage
**Steps**:
1. On Matches tab
2. Tap stage filter
3. Select "Group Stage"

**Expected Results**:
- ✅ Shows 3 group stage matches (opening matches)
- ✅ Select "Final" shows 1 match (MetLife Stadium)

**Actual Results**: _____________________________

**Pass/Fail**: [ ]

#### Test 3.4: Live Matches Indicator
**Steps**:
1. On Matches tab
2. Check app bar for live indicator

**Expected Results**:
- ✅ No live indicator (no matches currently live)
- ✅ Red pulsing dot would appear during live matches

**Actual Results**: _____________________________

**Pass/Fail**: [ ]

---

### Test Case 4: Match Detail Page

#### Test 4.1: View Match Details
**Steps**:
1. On Matches tab
2. Tap on "FINAL" match (Match #104)

**Expected Results**:
- ✅ Opens Match Detail Page
- ✅ Shows match header:
  - "WORLD CUP FINAL" badge
  - Match #104
  - MetLife Stadium, New Jersey
  - July 19, 2026, 15:00 EST
- ✅ Teams section (TBD vs TBD)
- ✅ Venue details with map
- ✅ "Get Directions" button
- ✅ Prediction button (if not started)

**Actual Results**: _____________________________

**Pass/Fail**: [ ]

#### Test 4.2: Opening Match Details
**Steps**:
1. Tap on Match #1 (Opening Match)

**Expected Results**:
- ✅ "OPENING MATCH" special badge
- ✅ Mexico vs TBD
- ✅ Estadio Azteca, Mexico City
- ✅ June 11, 2026, 14:00 CST
- ✅ Venue capacity: 87,000
- ✅ Historical significance noted

**Actual Results**: _____________________________

**Pass/Fail**: [ ]

#### Test 4.3: Venue Information
**Steps**:
1. On Match Detail page
2. Scroll to Venue section
3. Tap "View Venue Details"

**Expected Results**:
- ✅ Shows stadium image (if asset collected)
- ✅ Address, capacity
- ✅ Map with GPS marker
- ✅ "Get Directions" opens maps app

**Actual Results**: _____________________________

**Pass/Fail**: [ ]

---

### Test Case 5: Groups Tab

#### Test 5.1: View All Groups
**Steps**:
1. Tap "Groups" tab

**Expected Results**:
- ✅ Shows 12 group cards (A-L)
- ✅ Each group shows:
  - Group letter (A, B, C...)
  - Teams in group (currently 1-3 teams per group)
  - Standings table (Points, GD, etc.)
- ✅ Groups displayed in A-Z order

**Actual Results**: _____________________________

**Pass/Fail**: [ ]

#### Test 5.2: View Group Details
**Steps**:
1. Tap on "Group A"

**Expected Results**:
- ✅ Expands to show full standings table
- ✅ Shows columns: Pos, Team, P, W, D, L, GF, GA, GD, Pts
- ✅ USA and Brazil listed (from seed data)
- ✅ "View Matches" button

**Actual Results**: _____________________________

**Pass/Fail**: [ ]

#### Test 5.3: Group Matches
**Steps**:
1. On Group A detail
2. Tap "View Matches"

**Expected Results**:
- ✅ Shows all Group A matches
- ✅ 6 matches total per group (4 teams = 6 games)
- ✅ Matches organized by matchday (1, 2, 3)

**Actual Results**: _____________________________

**Pass/Fail**: [ ]

---

### Test Case 6: Bracket Tab

#### Test 6.1: View Knockout Bracket
**Steps**:
1. Tap "Bracket" tab

**Expected Results**:
- ✅ Shows tournament bracket structure
- ✅ Stages visible:
  - Round of 32 (16 matches)
  - Round of 16 (8 matches)
  - Quarter-Finals (4 matches)
  - Semi-Finals (2 matches)
  - Final (1 match)
- ✅ Most positions show "TBD" (not determined yet)
- ✅ Final position shows MetLife Stadium

**Actual Results**: _____________________________

**Pass/Fail**: [ ]

#### Test 6.2: Tap Bracket Match
**Steps**:
1. On Bracket tab
2. Tap on Final match slot

**Expected Results**:
- ✅ Opens Match Detail page for Final
- ✅ Shows Match #104 details

**Actual Results**: _____________________________

**Pass/Fail**: [ ]

---

### Test Case 7: Favorites Tab

#### Test 7.1: View Favorites (Empty)
**Steps**:
1. Tap "Favorites" tab (first time)

**Expected Results**:
- ✅ Shows empty state
- ✅ Message: "No favorite teams yet"
- ✅ "Add favorites" button

**Actual Results**: _____________________________

**Pass/Fail**: [ ]

#### Test 7.2: Add Favorites
**Steps**:
1. Go to Teams tab
2. Favorite USA, Mexico, Brazil
3. Go back to Favorites tab

**Expected Results**:
- ✅ Shows 3 favorite teams
- ✅ Each team card displayed
- ✅ Tap to view Team Detail

**Actual Results**: _____________________________

**Pass/Fail**: [ ]

#### Test 7.3: Favorite Team Matches
**Steps**:
1. On Favorites tab with USA favorited

**Expected Results**:
- ✅ Shows USA upcoming matches
- ✅ Match cards for USA games
- ✅ Quick prediction buttons

**Actual Results**: _____________________________

**Pass/Fail**: [ ]

---

### Test Case 8: Predictions

#### Test 8.1: Make Match Prediction
**Steps**:
1. On Match Detail page (Opening Match)
2. Tap "Make Prediction"

**Expected Results**:
- ✅ Opens prediction dialog
- ✅ Shows team options
- ✅ Score input fields
- ✅ Confidence slider (1-5 stars)
- ✅ "Submit" button

**Actual Results**: _____________________________

**Pass/Fail**: [ ]

#### Test 8.2: Submit Prediction
**Steps**:
1. Select Mexico to win
2. Enter score: 2-0
3. Set confidence: 4 stars
4. Tap Submit

**Expected Results**:
- ✅ Prediction saved
- ✅ Confirmation toast
- ✅ Match card shows "Predicted" badge
- ✅ Can view/edit prediction

**Actual Results**: _____________________________

**Pass/Fail**: [ ]

#### Test 8.3: View All Predictions
**Steps**:
1. Navigate to Predictions page

**Expected Results**:
- ✅ Shows list of user predictions
- ✅ Grouped by stage/date
- ✅ Shows predicted result
- ✅ Points earned (if match completed)

**Actual Results**: _____________________________

**Pass/Fail**: [ ]

---

### Test Case 9: Venues

#### Test 9.1: View All Venues
**Steps**:
1. Navigate to Venues screen (if accessible from menu)

**Expected Results**:
- ✅ Shows 16 venue cards
- ✅ Each venue shows:
  - Stadium name
  - City, State, Country
  - Capacity
  - Matches hosted count
  - Significance badge (FINAL, Semi-Final, etc.)

**Actual Results**: _____________________________

**Pass/Fail**: [ ]

#### Test 9.2: Filter Venues by Country
**Steps**:
1. On Venues screen
2. Filter by "USA"

**Expected Results**:
- ✅ Shows 11 USA stadiums
- ✅ Sorted by significance or alphabetically

**Actual Results**: _____________________________

**Pass/Fail**: [ ]

#### Test 9.3: View Venue Details
**Steps**:
1. Tap on MetLife Stadium

**Expected Results**:
- ✅ Opens venue detail page
- ✅ Shows stadium image (if collected)
- ✅ Full address, capacity
- ✅ GPS coordinates/map
- ✅ Description
- ✅ List of matches at this venue
- ✅ "FINAL VENUE" badge prominent

**Actual Results**: _____________________________

**Pass/Fail**: [ ]

---

## 🐛 Edge Cases & Error Testing

### Test Case 10: Offline Behavior

#### Test 10.1: Load with Internet
**Steps**:
1. Ensure internet connected
2. Open app

**Expected**: Data loads from Firestore

#### Test 10.2: Go Offline
**Steps**:
1. Turn off WiFi/Data
2. Navigate between tabs

**Expected Results**:
- ✅ Cached data still displays
- ✅ No crashes
- ✅ "Offline" indicator shown
- ✅ Refresh shows error toast

**Actual Results**: _____________________________

**Pass/Fail**: [ ]

---

### Test Case 11: Empty Data Handling

#### Test 11.1: No Matches Available
**Steps**:
1. (Simulate empty Firestore collection)

**Expected Results**:
- ✅ Shows empty state message
- ✅ "No matches available" text
- ✅ Refresh button

**Actual Results**: _____________________________

**Pass/Fail**: [ ]

---

### Test Case 12: Performance

#### Test 12.1: Large List Scrolling
**Steps**:
1. Open Matches tab
2. Rapidly scroll up/down

**Expected Results**:
- ✅ Smooth 60fps scrolling
- ✅ No jank or lag
- ✅ Images load progressively

**Actual Results**: _____________________________

**Pass/Fail**: [ ]

#### Test 12.2: Load Time
**Steps**:
1. Force quit app
2. Reopen and time until data displayed

**Expected Results**:
- ✅ First load: < 3 seconds (with internet)
- ✅ Cached load: < 1 second

**Actual Results**: _____________________________

**Pass/Fail**: [ ]

---

## 🔧 Troubleshooting Common Issues

### Issue: "No teams found" or empty screens

**Possible Causes**:
1. Firestore collections not populated
2. Collection names mismatch
3. Firestore rules blocking read

**Solutions**:
```bash
# 1. Check Firestore Console
# Verify collections exist: national_teams, world_cup_matches, groups, world_cup_venues

# 2. Re-run population script
node scripts/populate_firestore.js

# 3. Check firestore.rules
# Ensure authenticated users can read:
# allow read: if request.auth != null;
```

### Issue: Firebase not initialized

**Error**: `[core/no-app] No Firebase App '[DEFAULT]' has been created`

**Solution**:
1. Check `google-services.json` exists in `android/app/`
2. Check `GoogleService-Info.plist` exists in `ios/Runner/`
3. Run `flutter clean && flutter pub get`

### Issue: Data loads but images missing

**Possible Causes**:
- Flag/stadium images not collected yet

**Solution**:
- Follow Priority #2: Asset Collection Guide
- Or use placeholder images temporarily

### Issue: Firestore permission denied

**Error**: `PERMISSION_DENIED: Missing or insufficient permissions`

**Solution**:
```javascript
// In firestore.rules, ensure:
match /national_teams/{teamId} {
  allow read: if request.auth != null;
}
match /world_cup_matches/{matchId} {
  allow read: if request.auth != null;
}
```

---

## 📊 Test Results Summary

| Test Case | Pass | Fail | Notes |
|-----------|------|------|-------|
| 1.1 - Load All Teams | [ ] | [ ] | |
| 1.2 - Filter by Confederation | [ ] | [ ] | |
| 1.3 - Sort Options | [ ] | [ ] | |
| 1.4 - Search Teams | [ ] | [ ] | |
| 2.1 - View Team Details | [ ] | [ ] | |
| 2.2 - Team Matches | [ ] | [ ] | |
| 2.3 - Add to Favorites | [ ] | [ ] | |
| 3.1 - Load All Matches | [ ] | [ ] | |
| 3.2 - Filter by Date | [ ] | [ ] | |
| 3.3 - Filter by Stage | [ ] | [ ] | |
| 3.4 - Live Indicator | [ ] | [ ] | |
| 4.1 - View Match Details | [ ] | [ ] | |
| 4.2 - Opening Match | [ ] | [ ] | |
| 4.3 - Venue Info | [ ] | [ ] | |
| 5.1 - View All Groups | [ ] | [ ] | |
| 5.2 - Group Details | [ ] | [ ] | |
| 5.3 - Group Matches | [ ] | [ ] | |
| 6.1 - View Bracket | [ ] | [ ] | |
| 6.2 - Tap Bracket Match | [ ] | [ ] | |
| 7.1 - Empty Favorites | [ ] | [ ] | |
| 7.2 - Add Favorites | [ ] | [ ] | |
| 7.3 - Favorite Matches | [ ] | [ ] | |
| 8.1 - Make Prediction | [ ] | [ ] | |
| 8.2 - Submit Prediction | [ ] | [ ] | |
| 8.3 - View Predictions | [ ] | [ ] | |
| 9.1 - View All Venues | [ ] | [ ] | |
| 9.2 - Filter Venues | [ ] | [ ] | |
| 9.3 - Venue Details | [ ] | [ ] | |
| 10.1 - Online Load | [ ] | [ ] | |
| 10.2 - Offline Behavior | [ ] | [ ] | |
| 11.1 - Empty State | [ ] | [ ] | |
| 12.1 - Scroll Performance | [ ] | [ ] | |
| 12.2 - Load Time | [ ] | [ ] | |

**Total**: 33 test cases
**Passed**: ___ / 33
**Failed**: ___ / 33
**Pass Rate**: ___%

---

## ✅ Completion Criteria

Priority #4 is considered complete when:

- [x] Firestore collection names corrected
- [ ] All 33 test cases executed
- [ ] Pass rate > 90% (30+ tests passing)
- [ ] All critical bugs fixed
- [ ] Performance acceptable (smooth scrolling, fast load)
- [ ] UI displays data correctly
- [ ] No crashes or fatal errors

---

## 📝 Next Steps After Testing

1. **Document Issues**: Record any bugs found
2. **Fix Critical Bugs**: Prioritize crashes and data loading issues
3. **Optimize Performance**: If scrolling/loading is slow
4. **Update Widgets**: If UI doesn't match designs
5. **Add Missing Features**: If gaps identified
6. **Proceed to Priority #5**: Tighten Firestore security rules

---

**Created**: December 26, 2025
**Last Updated**: December 26, 2025
**Tester**: __________________________
**Test Date**: __________________________

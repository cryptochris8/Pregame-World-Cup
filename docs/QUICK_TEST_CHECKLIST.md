# Quick Test Checklist - Firestore Data Validation

**App Running**: ✅ Chrome Browser
**Date**: December 26, 2025

---

## Quick Tests to Run Now

### 1. Teams Screen ⚽
- [ ] Navigate to Teams screen
- [ ] **Expected**: Should see 25 national teams
- [ ] Look for: USA, MEX, CAN, BRA, ARG, GER, FRA, ESP, etc.
- [ ] **Test Search**: Search for "Brazil" - should find BRA
- [ ] **Tap a team**: Click on USA - should show team details
- [ ] **Check data**: Verify coach name, star players, confederation appear

**What to look for**:
- Team flags (if assets loaded)
- FIFA rankings
- Group assignments (A-L)
- Confederation badges (CONCACAF, UEFA, CONMEBOL, etc.)

---

### 2. Matches Screen 📅
- [ ] Navigate to Matches screen
- [ ] **Expected**: Should see 4 sample matches
- [ ] **Match 1**: MEX vs TBD - Opening Match (June 11, 2026)
- [ ] **Match 2**: CAN vs TBD - Canada Opening (June 12, 2026)
- [ ] **Match 3**: USA vs TBD - USA Opening (June 12, 2026)
- [ ] **Match 4**: TBD vs TBD - FINAL (July 19, 2026)

**What to look for**:
- Match dates and times
- Stadium names (Azteca, BMO Field, SoFi, MetLife)
- Match status (all should be "Scheduled")

---

### 3. Venues Screen 🏟️
- [ ] Navigate to Venues screen
- [ ] **Expected**: Should see 16 stadiums
- [ ] Check if map shows stadium locations
- [ ] Look for key venues:
  - MetLife Stadium (New Jersey) - FINAL
  - Estadio Azteca (Mexico City) - OPENING
  - AT&T Stadium (Texas) - Semi-Final
  - Mercedes-Benz (Atlanta) - Semi-Final

**What to look for**:
- Map markers at correct locations
- Stadium capacity displayed
- City/state/country info
- Significance labels

---

### 4. Groups Screen 📊
- [ ] Navigate to Groups screen
- [ ] **Expected**: Should see Groups A through L (12 groups)
- [ ] Each group should show assigned teams
- [ ] Check Group A - should have teams assigned
- [ ] Verify standings table structure exists

**What to look for**:
- All 12 groups visible
- Team assignments match seed data
- Points/wins/losses columns (may be 0 for now)

---

## Common Issues to Check

### Issue: "No teams found" or empty screens
**Possible causes**:
1. Firestore data not populated yet
2. Not logged in / not authenticated
3. Internet connection issue
4. Firestore rules blocking access

**Solutions**:
- Verify you ran: `node scripts/populate_firestore.js`
- Check Firebase Console - verify data exists
- Check browser console for errors (F12)

---

### Issue: "Permission denied" errors
**Cause**: Firestore security rules
**Solution**: Check `firestore.rules` - current rules require authentication

---

### Issue: Images/flags not showing
**Cause**: Assets not collected yet (expected)
**Solution**: This is normal - we haven't downloaded flags/images yet (Priority #2 pending)

---

## Report Your Findings

Please check the items above and let me know:

1. ✅ **What's working**: Which screens display data correctly?
2. ❌ **What's broken**: Any errors, empty screens, or missing data?
3. 🐛 **Any bugs**: Crashes, slow loading, UI issues?

---

## Next Steps After Testing

**If everything works**:
- We'll document the success
- Mark Priority #4 as complete
- Move to Priority #5 (Security Rules)

**If issues found**:
- I'll help debug and fix them
- Re-test after fixes
- Then proceed to Priority #5

---

**Current Status**: App running in Chrome ✅
**Your Task**: Test the 4 screens above and report back!

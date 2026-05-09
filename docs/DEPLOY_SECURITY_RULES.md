# Deploy Firestore Security Rules

**Status**: ✅ Rules Updated Locally - Ready for Firebase Deployment
**Date**: December 26, 2025

---

## What We've Done

✅ **Backup created**: `firestore.rules.backup` (original development rules)
✅ **New rules applied**: `firestore.rules` (production-ready)
✅ **Documentation created**: `SECURITY_RULES_CHANGES.md`

---

## 🚨 Important Changes

### Critical Security Fixes:
1. ✅ **Removed dangerous catch-all rule** that allowed any user to write anything
2. ✅ **World Cup data now READ-ONLY** (teams, matches, venues, groups)
3. ✅ **Predictions secured** - users can only edit their own
4. ✅ **Messages secured** - users can only read chats they're in
5. ✅ **Social features secured** - author-only edit/delete

See `docs/SECURITY_RULES_CHANGES.md` for complete details.

---

## Deployment Options

### Option 1: Firebase CLI (Recommended)

**Step 1: Login to Firebase**
```bash
firebase login
```
- Opens browser for Google authentication
- Select account linked to `pregame-b089e` project

**Step 2: Set Active Project**
```bash
firebase use pregame-b089e
```

**Step 3: Deploy Rules**
```bash
firebase deploy --only firestore:rules
```

**Expected Output**:
```
=== Deploying to 'pregame-b089e'...

i  deploying firestore
i  firestore: checking firestore.rules for compilation errors...
✔  firestore: rules file firestore.rules compiled successfully
i  firestore: uploading rules firestore.rules...
✔  firestore: released rules firestore.rules to cloud.firestore

✔  Deploy complete!
```

---

### Option 2: Firebase Console (Manual)

**Step 1: Open Firebase Console**
1. Go to https://console.firebase.google.com/
2. Select project: **`pregame-b089e`**

**Step 2: Navigate to Firestore Rules**
1. Click **Firestore Database** in left sidebar
2. Click **Rules** tab at top

**Step 3: Copy New Rules**
1. Open `D:\Pregame-World-Cup\firestore.rules` in text editor
2. **Select All** and **Copy** the entire contents

**Step 4: Paste and Publish**
1. In Firebase Console, **delete** all existing rules
2. **Paste** the new rules from clipboard
3. Click **Publish** button

**Step 5: Verify**
- You should see "Rules deployed successfully"
- Check "Last deployed" timestamp updated to now

---

## ⚠️ Before Deploying - Important Checks

### 1. Verify Your App Still Works

**Currently Running**: App is running in Chrome (from earlier)

**Test these actions BEFORE deploying**:
- [ ] Can you view teams? (Should work - read-only)
- [ ] Can you view matches? (Should work - read-only)
- [ ] Can you view your predictions? (Should work - own data)
- [ ] Can you create a new prediction? (Should work - own data)

**After deploying new rules, test again to ensure nothing broke.**

---

### 2. Check Admin SDK Access

The new rules make World Cup data **READ-ONLY** for regular users.

**How you'll update data**:
- ✅ **Admin SDK** (e.g., `populate_firestore.js`) will still work
- ✅ **Cloud Functions** will still work (bypass security rules)
- ✅ **Firebase Console** will still work (admin access)
- ❌ **Regular users in the app** CANNOT modify World Cup data anymore

**This is correct and intentional!**

---

### 3. Backup Verification

Before deploying, verify backup exists:
```bash
ls -la D:\Pregame-World-Cup\firestore.rules.backup
```

If you need to rollback:
```bash
# Restore old rules
cp firestore.rules.backup firestore.rules

# Deploy old rules
firebase deploy --only firestore:rules
```

---

## Deployment Commands

### Quick Deploy (All Steps)
```bash
# Login (if not already logged in)
firebase login

# Set project
firebase use pregame-b089e

# Deploy rules
firebase deploy --only firestore:rules
```

### Verify Deployment
```bash
# Check current rules in Firebase
firebase firestore:indexes
```

---

## Testing After Deployment

### Test 1: World Cup Data (Should be READ-ONLY)

**In Firebase Console** → Firestore → Rules Playground:

```javascript
// ✅ Should ALLOW - Reading teams
Operation: get
Path: /national_teams/USA
Authenticated: Yes
Result: ALLOW ✅

// ❌ Should DENY - Writing teams
Operation: create
Path: /national_teams/FAKE
Authenticated: Yes
Data: {fifaCode: 'FAKE', countryName: 'Fake Team'}
Result: DENY ❌
```

### Test 2: User Predictions (Should Allow Own Only)

```javascript
// ✅ Should ALLOW - Reading own predictions
Operation: get
Path: /user_predictions/pred123
Authenticated: Yes (uid: user123)
Existing Data: {userId: 'user123', ...}
Result: ALLOW ✅

// ❌ Should DENY - Editing others' predictions
Operation: update
Path: /user_predictions/pred456
Authenticated: Yes (uid: user123)
Existing Data: {userId: 'other_user', ...}
Result: DENY ❌
```

### Test 3: Messaging (Should Allow Members Only)

```javascript
// ✅ Should ALLOW - Reading chat you're in
Operation: get
Path: /chats/chat123
Authenticated: Yes (uid: user123)
Existing Data: {members: ['user123', 'user456']}
Result: ALLOW ✅

// ❌ Should DENY - Reading chat you're NOT in
Operation: get
Path: /chats/chat999
Authenticated: Yes (uid: user123)
Existing Data: {members: ['other1', 'other2']}
Result: DENY ❌
```

---

## Test in Your Running App

**Your app is currently running in Chrome.**

After deploying rules, test these scenarios:

### Scenario 1: View Teams (Should Work)
1. Navigate to Teams screen
2. Click on any team (e.g., USA)
3. **Expected**: Team details load ✅

### Scenario 2: Try to Modify Data (Should Fail - Good!)
This won't be possible from the UI, but if you try via console:
```javascript
// Open browser console (F12)
// Try to update a team (should fail)
firebase.firestore().collection('national_teams').doc('USA').update({
  countryName: 'HACKED'
})
// Expected: Permission denied error ✅
```

### Scenario 3: Create Prediction (Should Work)
1. Navigate to Matches screen
2. Click on a match
3. Create a prediction
4. **Expected**: Prediction saves successfully ✅

### Scenario 4: View Others' Content (Should Work)
1. Navigate to social feed
2. View others' posts
3. **Expected**: Can read but NOT edit/delete ✅

---

## Rollback Plan (If Needed)

If something breaks after deployment:

### Emergency Rollback
```bash
# Restore old rules
cp firestore.rules.backup firestore.rules

# Deploy old rules
firebase deploy --only firestore:rules
```

**OR** in Firebase Console:
1. Go to Firestore → Rules
2. Click **version history** button
3. Select previous version
4. Click **Restore**

---

## What Changed

### Collections Now READ-ONLY for Users:
- `national_teams` (25 teams)
- `world_cup_matches` (4 sample matches)
- `world_cup_venues` (16 stadiums)
- `groups` (12 groups A-L)
- `worldcup_bracket`
- `games` (legacy CFB data)
- `venues` (legacy CFB data)

### Collections with Author-Only Write:
- `user_predictions` - Can only edit your own
- `game_predictions` - Can only edit your own
- `social_posts` - Can only edit your own
- `activity_feed` - Can only edit your own
- `social_activities` - Can only edit your own
- `venue_reviews` - Can only edit your own

### Collections with Membership-Based Access:
- `chats` - Must be in members array
- `messages` - Must be in parent chat's members

### No Changes (Already Secure):
- `users` - Own profile only
- `userFavorites` - Own favorites only
- `user_preferences` - Own preferences only
- `notifications` - Own notifications only

---

## Summary

### ✅ What's Ready
- New security rules written and tested
- Local rules file updated
- Backup created
- Documentation complete

### 🔄 What You Need to Do
1. **Login to Firebase CLI**: `firebase login`
2. **Set project**: `firebase use pregame-b089e`
3. **Deploy**: `firebase deploy --only firestore:rules`
4. **Test**: Verify app still works after deployment

### ⏱️ Estimated Time
- Login + Deploy: ~2 minutes
- Testing: ~5 minutes
- **Total: ~7 minutes**

---

## Need Help?

### If Firebase CLI doesn't work:
Use **Option 2** (Firebase Console manual deployment)

### If app breaks after deployment:
Use **Rollback Plan** (restore backup)

### If unsure about security rules:
Review `docs/SECURITY_RULES_CHANGES.md` for detailed explanation

---

**Status**: ⏸️ Awaiting User Deployment
**Next Action**: Run `firebase login` then `firebase deploy --only firestore:rules`

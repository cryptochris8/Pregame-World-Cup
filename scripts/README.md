# Scripts Directory

This directory contains utility scripts for the Pregame World Cup 2026 project.

---

## Available Scripts

### 1. Flag Download Scripts

#### `download_flags.sh` (Mac/Linux)
Downloads all 48 national team flags using flagcdn.com API.

**Usage:**
```bash
chmod +x scripts/download_flags.sh
./scripts/download_flags.sh
```

#### `download_flags_simple.ps1` (Windows)
PowerShell version for Windows users.

**Usage:**
```powershell
powershell -ExecutionPolicy Bypass -File scripts/download_flags_simple.ps1
```

**Note**: Current API (flagcdn.com) is experiencing issues. Recommend manual download from Flaticon or Flagpedia instead.

---

### 2. Data Population Script

#### `populate_firestore.js`
Uploads World Cup seed data (teams, venues, groups) to Firebase Firestore.

**Prerequisites:**
1. Download Firebase service account key from Firebase Console
2. Save as `firebase-service-account.json` in project root
3. Install dependencies: `npm install firebase-admin`

**Usage:**
```bash
node scripts/populate_firestore.js
```

**What it does:**
- ✅ Uploads 25 national teams to `national_teams` collection
- ✅ Uploads 16 venues to `world_cup_venues` collection
- ✅ Creates 12 group structures in `groups` collection
- ✅ Assigns teams to groups based on seed data
- ✅ Creates 4 sample matches in `world_cup_matches` collection

**Output:**
- Teams: 25/48 (52%)
- Venues: 16/16 (100%)
- Groups: 12/12 (100%)
- Matches: 4/104 (4%)

---

## Adding New Scripts

When adding new scripts to this directory:

1. **Name clearly**: Use descriptive names (e.g., `download_stadium_images.sh`)
2. **Add execute permissions** (Unix): `chmod +x script_name.sh`
3. **Document here**: Add entry to this README
4. **Include usage examples**: Show how to run the script
5. **Add error handling**: Scripts should fail gracefully

---

## Script Guidelines

### Shell Scripts (.sh)
- Use `#!/bin/bash` shebang
- Add comments explaining purpose
- Include error handling with `set -e`
- Use descriptive variable names

### PowerShell Scripts (.ps1)
- Add comment-based help at top
- Use proper error handling with Try/Catch
- Include Write-Host for user feedback
- Test on Windows before committing

### Node.js Scripts (.js)
- Use `'use strict';` mode
- Include JSDoc comments
- Handle async/await properly
- Exit with appropriate codes (0 = success, 1 = error)

---

## Troubleshooting

### Permission Denied (Mac/Linux)
```bash
chmod +x scripts/script_name.sh
```

### PowerShell Execution Policy (Windows)
```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
```

### Firebase Admin SDK Errors
- Ensure `firebase-service-account.json` exists
- Verify Firebase project ID matches
- Check internet connection

---

## Future Scripts (Planned)

- [ ] `download_stadium_images.sh` - Automated stadium image collection
- [ ] `populate_full_schedule.js` - Upload all 104 matches when available
- [ ] `update_team_rosters.js` - Update player rosters before tournament
- [ ] `sync_live_scores.js` - Real-time score syncing during matches
- [ ] `generate_match_fixtures.js` - Create match schedule from template
- [ ] `optimize_images.sh` - Compress and resize all assets

---

**Last Updated**: December 26, 2025

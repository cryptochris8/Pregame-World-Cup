# Photo Fetching System - Getting Started

Welcome! This document will help you get started with the photo fetching solution for the Pregame World Cup application.

---

## What Is This?

A complete system to automatically fetch player and manager photos from the internet and upload them to your Firebase application.

**What it does**:
- Searches for player/manager photos on TheSportsDB, Wikipedia, and Wikimedia Commons
- Automatically tries multiple sources if one fails
- Uploads photos to Firebase Storage
- Updates your Firestore database with photo URLs
- Tracks progress and provides detailed reports

**Safety**: It will never delete or overwrite existing photos. If a photo is already in Firebase Storage, it's skipped.

---

## 30-Second Setup

```bash
# Navigate to functions directory
cd D:\Pregame-World-Cup\functions

# Install dependencies (if not already done)
npm install

# Check what photos you currently have
npm run check-photos-v2

# That's it! You're ready to use the system.
```

---

## 5-Minute Quick Start

### Step 1: Check Current Status (1 minute)
```bash
npm run check-photos-v2
```

This shows:
- How many photos you currently have
- What percentage of players/managers have photos
- Which sources the photos came from

### Step 2: Test with a Small Sample (1-2 minutes)
```bash
npm run fetch-player-photos-v2 -- --limit=10
```

This processes only 10 players so you can see how it works. Look for:
- `SUCCESS` messages (photos were found and uploaded)
- `FAILED` messages (couldn't find a photo)
- Processing time and success rate

### Step 3: Run Full Process (if Step 2 worked well)
```bash
npm run fetch-all-photos-v2
```

Kick back and let it run (15-20 minutes). It will:
- Process all players (~10-15 minutes)
- Process all managers (~1-2 minutes)
- Show progress with ETA
- Display final summary

### Step 4: Verify Results (1 minute)
```bash
npm run check-photos-v2
```

Compare with Step 1 to see how many photos were added.

---

## Commands Quick Reference

### Most Common Commands

```bash
# See photo statistics
npm run check-photos-v2

# Fetch photos for all players
npm run fetch-player-photos-v2

# Fetch photos for all managers
npm run fetch-manager-photos-v2

# Fetch both (runs one after the other)
npm run fetch-all-photos-v2
```

### Testing Commands

```bash
# Test with just 10 players
npm run fetch-player-photos-v2 -- --limit=10

# Test with just 5 managers
npm run fetch-manager-photos-v2 -- --limit=5

# Preview without actually uploading anything
npm run fetch-player-photos-v2 -- --dryRun
```

### Filtering Commands

```bash
# Check only players
npm run check-photos-v2 -- --players

# Check only managers
npm run check-photos-v2 -- --managers
```

---

## What Happens When I Run It?

### Example Output

```
[1/1200] Lionel Messi
   ETA: 14m 30s
   Status: SUCCESS
   Source: TheSportsDB
   URL: https://firebasestorage.googleapis.com/v0/b/pregame-b089e.firebasestorage.app/o/players%2Fen_1.jpg?alt=media

[2/1200] Neymar
   Status: Already has Firebase Storage URL
   ETA: 14m 25s

[3/1200] Kylian Mbappé
   ETA: 14m 20s
   Status: FAILED
   Error: No photo found from any source

[4/1200] Harry Kane
   ETA: 14m 15s
   Status: SUCCESS
   Source: Wikipedia
   URL: https://firebasestorage.googleapis.com/...
```

### What Gets Updated in Firestore

Each player/manager document gets updated with:

```javascript
{
  photoUrl: "https://firebasestorage.googleapis.com/...",  // The photo URL
  photoSource: "TheSportsDB",                               // Where it came from
  photoUpdatedAt: {/* timestamp */}                         // When it was fetched
}
```

---

## How Long Does It Take?

| Task | Time |
|------|------|
| Check status | < 1 minute |
| Fetch 10 players (test) | 1-2 minutes |
| Fetch all players | 10-15 minutes |
| Fetch all managers | 1-2 minutes |
| Fetch all (players + managers) | 15-20 minutes |

**Note**: The scripts intentionally run slow (2 requests per second) to avoid overloading the photo sources. This is by design.

---

## How Does It Work?

### Photo Sources (In Order of Priority)

1. **TheSportsDB** (Best for official/professional photos)
   - High-quality cropped photos
   - Best for players and managers
   - May not have everyone

2. **Wikipedia** (Great fallback)
   - Covers many athletes
   - Good quality
   - Available when TheSportsDB doesn't have them

3. **Wikimedia Commons** (Last resort)
   - Highest quality when available
   - Less likely to have obscure players

### What Happens If One Source Fails?

If TheSportsDB doesn't have a player's photo, it automatically tries Wikipedia. If Wikipedia doesn't have it, it tries Wikimedia Commons. If none have it, it reports "not found" and moves to the next player.

---

## What If I Get Errors?

### Common Issues and Solutions

**"Cannot find module 'firebase-admin'"**
```bash
npm install
```

**"Failed to download image"**
- Usually temporary. Just run again.
- Check your internet connection.

**"Failed to upload to Firebase Storage"**
- Make sure your Firebase project is set up correctly
- Check that your `service-account-key.json` is in the right place

**Some photos aren't found**
- This is normal! Not all players/managers have photos online
- The system skips them gracefully and continues

---

## Want More Details?

### Quick Reference (5 minutes)
See: `QUICK_START.md`

### Comprehensive Guide (25 minutes)
See: `PHOTO_FETCHING_GUIDE.md`

### API Reference (for developers)
See: `functions/src/PHOTO_API_REFERENCE.md`

### Implementation Details (for developers)
See: `PHOTO_SOLUTION_SUMMARY.md`

---

## Safety Guarantees

- Won't delete existing photos
- Won't overwrite existing Firebase Storage photos
- Reads are safe (no side effects)
- Has a dry-run mode for testing
- Has a limit flag to test before running full process

---

## Pro Tips

1. **Always check status first**
   ```bash
   npm run check-photos-v2
   ```

2. **Always test with limit before going full**
   ```bash
   npm run fetch-player-photos-v2 -- --limit=10
   ```

3. **Use dry-run to preview**
   ```bash
   npm run fetch-player-photos-v2 -- --dryRun
   ```

4. **Check results when done**
   ```bash
   npm run check-photos-v2
   ```

---

## File Structure

All the new photo fetching files are here:

```
D:\Pregame-World-Cup\functions\src\
├── photo-fetcher-utils.ts           (Core library)
├── fetch-player-photos-v2.ts        (Player fetcher script)
├── fetch-manager-photos-v2.ts       (Manager fetcher script)
├── check-photos-v2.ts               (Status checker script)
└── PHOTO_API_REFERENCE.md           (API documentation)
```

Documentation:

```
D:\Pregame-World-Cup\
├── README_PHOTOS.md                 (This file - start here!)
├── QUICK_START.md                   (5-minute quick start)
├── PHOTO_FETCHING_GUIDE.md          (Comprehensive guide)
└── PHOTO_SOLUTION_SUMMARY.md        (Implementation details)
```

---

## Real-World Example

### Running a Complete Flow

```bash
# 1. Check what you have now
npm run check-photos-v2
# Output: 450/1200 players have photos (37.5%)

# 2. Test the system with 10 players
npm run fetch-player-photos-v2 -- --limit=10
# Output: Successfully fetched 9/10 players

# 3. Run for all players (takes 10-15 minutes)
npm run fetch-player-photos-v2
# Output: Successfully fetched 740/1200 players (total 1190)

# 4. Run for all managers (takes 1-2 minutes)
npm run fetch-manager-photos-v2
# Output: Successfully fetched 62/64 managers

# 5. Check final results
npm run check-photos-v2
# Output: 1190/1200 players (99%), 62/64 managers (97%)
```

---

## Next Steps

1. Open Terminal/Command Prompt
2. Navigate to: `D:\Pregame-World-Cup\functions`
3. Run: `npm run check-photos-v2`
4. See what happens!

If you want more details, read `QUICK_START.md` next.

---

## Questions?

- **Quick questions?** → See `QUICK_START.md`
- **How do I use X?** → See `PHOTO_FETCHING_GUIDE.md`
- **API details?** → See `functions/src/PHOTO_API_REFERENCE.md`
- **How does it work?** → See `PHOTO_SOLUTION_SUMMARY.md`

---

## Summary

You now have a complete, production-ready photo fetching system that:

- Automatically finds photos from multiple sources
- Uploads to Firebase
- Updates your database
- Reports progress
- Handles errors gracefully

**Ready to get started?**

```bash
cd D:\Pregame-World-Cup\functions
npm run check-photos-v2
```

Enjoy!

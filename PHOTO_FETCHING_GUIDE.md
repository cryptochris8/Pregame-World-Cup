# Photo Fetching Solution - Complete Guide

## Overview

This solution provides TypeScript scripts to fetch real player and manager photos from multiple sources and upload them to Firebase Storage. The system includes fallback sources, error handling, rate limiting, and comprehensive progress tracking.

---

## Architecture

### Core Components

1. **photo-fetcher-utils.ts** - Reusable utilities
   - `PhotoFetcher` - Main photo fetching service
   - `TheSportsDBService` - TheSportsDB API integration
   - `WikipediaService` - Wikipedia Commons integration
   - `ImageDownloadService` - Image download with validation
   - `FirebaseStorageService` - Firebase upload handling
   - `FirestoreService` - Firestore document updates
   - `ProgressTracker` - Progress tracking with ETA

2. **fetch-player-photos-v2.ts** - Enhanced player photo script
3. **fetch-manager-photos-v2.ts** - Enhanced manager photo script
4. **check-photos-v2.ts** - Photo status checker and reporter

### Legacy Scripts (Original Implementation)

- `fetch-player-photos.ts` - Original player fetcher
- `fetch-manager-photos.ts` - Original manager fetcher
- `check-photos.ts` - Basic photo checker

---

## Photo Sources (Priority Order)

### 1. TheSportsDB (Primary)
- **URL**: https://www.thesportsdb.com/api/v1/json/3
- **Pros**: High-quality cutout images, dedicated player/manager database
- **Cons**: Limited free tier, occasional missing photos
- **Quality Levels**:
  - `high` - strCutout (isolated photo)
  - `medium` - strRender (rendered image)
  - `low` - strThumb (thumbnail)

### 2. Wikipedia Commons (Fallback)
- **URL**: https://en.wikipedia.org/w/api.php
- **Pros**: Comprehensive coverage, free, well-maintained
- **Cons**: Variable quality, may include medals/uniforms
- **Quality**: Usually `medium` to `high`

### 3. Wikimedia Commons (Fallback)
- **URL**: https://commons.wikimedia.org/w/api.php
- **Pros**: Highest quality images, unrestricted
- **Cons**: Fewer images available
- **Quality**: `high` when available

---

## Installation & Setup

### Prerequisites

1. **Node.js 22+**
2. **Firebase Admin SDK** credentials (service-account-key.json)
3. **Firebase Project** with:
   - Firestore database with `players` and `managers` collections
   - Cloud Storage bucket

### Install Dependencies

```bash
cd D:\Pregame-World-Cup\functions
npm install
```

### Environment Setup

1. Place your Firebase service account key at:
   ```
   D:\Pregame-World-Cup\service-account-key.json
   ```

2. Verify your Firestore collections exist:
   - `players` collection with fields: `fullName`, `commonName`, `fifaCode`, `photoUrl`
   - `managers` collection with fields: `fullName`, `fifaCode`, `photoUrl`

---

## Usage

### Quick Start

#### Check Current Photo Status
```bash
cd D:\Pregame-World-Cup\functions
npm run check-photos-v2
```

#### Fetch All Player Photos
```bash
npm run fetch-player-photos-v2
```

#### Fetch All Manager Photos
```bash
npm run fetch-manager-photos-v2
```

#### Fetch Both (Sequential)
```bash
npm run fetch-all-photos-v2
```

### Advanced Usage

#### Fetch with Limit
```bash
# Process only first 10 players
npm run fetch-player-photos-v2 -- --limit=10

# Process only first 20 managers
npm run fetch-manager-photos-v2 -- --limit=20
```

#### Dry Run Mode (Preview without saving)
```bash
# Shows what would be fetched without uploading or updating Firestore
npm run fetch-player-photos-v2 -- --dryRun
npm run fetch-manager-photos-v2 -- --dryRun
```

#### Check Players Only
```bash
npm run check-photos-v2 -- --players
```

#### Check Managers Only
```bash
npm run check-photos-v2 -- --managers
```

---

## Output Examples

### Fetch Script Output

```
=====================================
Enhanced Player Photo Fetcher v2
=====================================

Fetching players from Firestore...
Found 1,200 players

[1/1200] Lionel Messi
   ETA: 15m
   Status: SUCCESS
   Source: TheSportsDB
   URL: https://firebasestorage.googleapis.com/v0/b/pregame-b089e.firebasestorage.app/o/players%2Far_1.jpg?alt=media

[2/1200] Cristiano Ronaldo
   ETA: 14m 52s
   Status: SUCCESS
   Source: Wikipedia
   URL: https://firebasestorage.googleapis.com/v0/b/pregame-b089e.firebasestorage.app/o/players%2Fpt_2.jpg?alt=media

[3/1200] Kylian Mbappé
   Status: Already has Firebase Storage URL
   ETA: 14m 45s

...

=====================================
SUMMARY
=====================================
Success: 1050
Failed:  120
Skipped: 30
Total:   1200

Time Elapsed: 720s
Status: 1200/1200 (100%)

Successfully fetched:
  + Lionel Messi (TheSportsDB)
  + Cristiano Ronaldo (Wikipedia)
  + Neymar (Wikipedia)
  ... and 1047 more

Not found on any source:
  - Obscure Player 1 - No photo found from any source
  - Obscure Player 2 - Failed to download image
  ... and 118 more

✨ Script completed!
```

### Status Checker Output

```
==================================================
Players Photo Status
==================================================

SUMMARY
--------------------------------------------------
Total players:        1200
With Photo:           1050 (87.5%)
  - Firebase Storage: 1050
  - Other Source:     0
Without Photo:        150 (12.5%)

PHOTO SOURCES
--------------------------------------------------
TheSportsDB              650 (61.9%)
Wikipedia                400 (38.1%)

RECENTLY FETCHED
--------------------------------------------------
  Lionel Messi                             TheSportsDB        2025-12-28
  Cristiano Ronaldo                        Wikipedia          2025-12-27
  ...

==================================================
Managers Photo Status
==================================================

SUMMARY
--------------------------------------------------
Total managers:       64
With Photo:           62 (96.9%)
  - Firebase Storage: 62
  - Other Source:     0
Without Photo:        2 (3.1%)

==================================================
OVERALL SUMMARY
==================================================

Total Entities:          1264
With Photo:              1112 (88.0%)
Firebase Storage:        1112 (88.0%)
Without Photo:           152 (12.0%)

Done!
```

---

## Features in Detail

### 1. Multi-Source Fallback

The `PhotoFetcher` class automatically tries sources in order:
1. TheSportsDB with full name
2. TheSportsDB with common name (players only)
3. Wikipedia with full name
4. Wikipedia with common name (players only)

### 2. Intelligent Caching

Scripts automatically skip entities that already have valid Firebase Storage URLs:
```typescript
if (player.photoUrl?.includes('firebasestorage.googleapis.com')) {
  // Skip - already has good photo
}
```

### 3. Rate Limiting

Built-in rate limiting to avoid API throttling:
```typescript
RATE_DELAY_MS = 500  // 500ms between API calls
```

### 4. Error Handling

Comprehensive error handling at each step:
- API timeouts (5s timeout)
- Invalid image buffers
- Firebase upload failures
- Firestore update failures

### 5. Progress Tracking

Real-time progress with ETA:
```
[150/1200] Processed
ETA: 12m 30s
Elapsed: 3m 30s
Estimated Remaining: 12m 30s
```

### 6. Detailed Logging

Every step is logged with visual indicators:
- ✅ Success
- ❌ Failed
- ⚠️ Error
- 🔍 Searching
- 📥 Downloading
- ☁️ Uploading
- 📝 Updating

---

## API Reference

### PhotoFetcher Class

```typescript
class PhotoFetcher {
  // Fetch photo from any source (returns URL)
  async fetchPhoto(
    name: string,
    alternativeNames?: string[]
  ): Promise<FetchPhotoResult>

  // Fetch, upload, and update Firestore in one call
  async fetchAndUpload(
    name: string,
    entityType: 'player' | 'manager',
    entityId: string,
    fifaCode: string,
    alternativeNames?: string[],
    existingPhotoUrl?: string
  ): Promise<{success: boolean; photoUrl?: string; source?: string; error?: string}>
}
```

### TheSportsDBService Class

```typescript
class TheSportsDBService {
  static async searchPerson(name: string): Promise<PhotoSource | null>
}

interface PhotoSource {
  source: string
  url: string
  quality: 'high' | 'medium' | 'low'
}
```

### WikipediaService Class

```typescript
class WikipediaService {
  static async searchAndGetPhoto(name: string): Promise<PhotoSource | null>
}
```

### FirebaseStorageService Class

```typescript
class FirebaseStorageService {
  async uploadPhoto(
    imageBuffer: Buffer,
    entityType: 'player' | 'manager',
    entityId: string,
    fifaCode: string,
    metadata?: {[key: string]: string}
  ): Promise<UploadResult>
}
```

### FirestoreService Class

```typescript
class FirestoreService {
  async updatePhotoUrl(
    collection: 'players' | 'managers',
    entityId: string,
    photoUrl: string,
    additionalData?: Record<string, any>
  ): Promise<FirestoreUpdateResult>

  async fetchEntities(
    collection: 'players' | 'managers',
    limit?: number
  ): Promise<Array<{id: string; [key: string]: any}>>
}
```

### ProgressTracker Class

```typescript
class ProgressTracker {
  constructor(total: number)

  record(status: 'success' | 'error' | 'skipped'): void

  getProgress(): {
    processed: number
    total: number
    percentage: number
    succeeded: number
    failed: number
    skipped: number
    elapsedSeconds: number
    estimatedRemaining: string
  }

  printSummary(): void
}
```

---

## Firestore Document Structure

### Players Collection

```firestore
players/
  player_id/
    fullName: string
    commonName: string
    fifaCode: string
    photoUrl: string                          // Updated by script
    photoSource: string                       // 'TheSportsDB' | 'Wikipedia' (added by v2)
    photoUpdatedAt: timestamp                 // Server timestamp (added by v2)
    // ... other fields
```

### Managers Collection

```firestore
managers/
  manager_id/
    fullName: string
    fifaCode: string
    photoUrl: string                          // Updated by script
    photoSource: string                       // 'TheSportsDB' | 'Wikipedia' (added by v2)
    photoUpdatedAt: timestamp                 // Server timestamp (added by v2)
    // ... other fields
```

---

## Firebase Storage Structure

Photos are organized hierarchically:

```
gs://pregame-b089e.firebasestorage.app/
├── players/
│   ├── ar_1.jpg        // FIFA code_player_id
│   ├── pt_2.jpg
│   ├── fr_3.jpg
│   └── ...
├── managers/
│   ├── ar_1.jpg        // FIFA code_manager_id
│   ├── pt_2.jpg
│   └── ...
```

**Naming Convention**: `{entityType}s/{fifaCode}_{entityId}.jpg`

**Metadata Stored**:
- `contentType: image/jpeg`
- `cacheControl: public, max-age=31536000` (1 year)
- `source: TheSportsDB | Wikipedia` (v2 only)

---

## Performance Considerations

### Timing Estimates

- **Rate Limit**: 500ms between API calls (2 requests/second)
- **Processing Time**: ~1000 players = 10-15 minutes
- **Processing Time**: ~64 managers = 1-2 minutes

### Optimization Tips

1. **Use --limit for testing**
   ```bash
   npm run fetch-player-photos-v2 -- --limit=50
   ```

2. **Run during low-traffic hours** for Firebase

3. **Monitor quota usage** in Firebase console

4. **Batch multiple runs** if processing large datasets

---

## Troubleshooting

### Issue: "ENOENT: no such file or directory, open 'service-account-key.json'"

**Solution**: Ensure service account key is in the correct location:
```bash
ls D:\Pregame-World-Cup\service-account-key.json
```

### Issue: "Failed to download image from {url}"

**Causes**:
- API source returned invalid response
- Image URL expired
- Network timeout

**Solution**:
- Check API status (TheSportsDB, Wikipedia)
- Run again - may be temporary issue

### Issue: "Error uploading to storage"

**Causes**:
- Firebase bucket misconfigured
- Insufficient permissions
- Storage quota exceeded

**Solution**:
- Check Firebase bucket name in code
- Verify service account has Storage Editor role
- Check storage quota in Firebase console

### Issue: Scripts are very slow

**Causes**:
- Network latency
- API throttling
- High server load

**Solution**:
- Adjust `RATE_DELAY_MS` (increase to 1000)
- Run during off-peak hours
- Check internet connection

### Issue: Some photos not found

**Expected**: Not all historical players/managers will have photos available online.

**To reduce failures**:
1. Check Firestore data quality (correct names)
2. Try alternative name spellings
3. Manual upload for notable missing players

---

## Extending the Solution

### Adding a New Photo Source

1. Create a new service class in `photo-fetcher-utils.ts`:

```typescript
export class CustomPhotoService {
  static async searchPerson(name: string): Promise<PhotoSource | null> {
    // Implement search logic
    return {
      source: 'Custom Source',
      url: photoUrl,
      quality: 'high'
    };
  }
}
```

2. Add to `PhotoFetcher.fetchPhoto()` method:

```typescript
// Try Custom Source
for (const nameToTry of namesToTry) {
  const source = await CustomPhotoService.searchPerson(nameToTry);
  if (source) {
    const buffer = await ImageDownloadService.download(source.url);
    if (buffer && await ImageDownloadService.validateBuffer(buffer)) {
      return {
        success: true,
        photoUrl: source.url,
        source: source.source,
        triedSources,
      };
    }
  }
  triedSources.push('Custom Source');
  await this.sleep(this.rateDelayMs);
}
```

### Modifying Rate Limiting

Edit `RATE_DELAY_MS` in script files:

```typescript
const RATE_DELAY_MS = 1000;  // 1 second between calls
```

### Custom Error Handling

Override `PhotoFetcher.fetchAndUpload()` or individual service methods.

---

## Best Practices

1. **Always check status first**
   ```bash
   npm run check-photos-v2
   ```

2. **Test with limit before full run**
   ```bash
   npm run fetch-player-photos-v2 -- --limit=10
   ```

3. **Monitor Firebase quota**
   - Check `Storage` section in Firebase Console
   - Monitor API call counts

4. **Verify results**
   ```bash
   npm run check-photos-v2 -- --players
   ```

5. **Keep old scripts as backup**
   - v1 and v2 can run independently
   - V2 won't reprocess already-uploaded photos

6. **Document manual additions**
   - Note which players needed manual uploads
   - Update photo source metadata

---

## Configuration Reference

### Environment Variables

None required - uses Firebase initialization from service account key.

### Hardcoded Configuration

In `photo-fetcher-utils.ts`:
- `SPORTSDB_BASE_URL` = `https://www.thesportsdb.com/api/v1/json/3`
- `WIKIPEDIA_API_URL` = `https://en.wikipedia.org/w/api.php`
- `THESPORTSDB_TIMEOUT` = `5000ms`
- Default download timeout = `10000ms`

In fetch scripts:
- `RATE_DELAY_MS` = `500ms`
- Firebase bucket = `pregame-b089e.firebasestorage.app`
- Project ID = `pregame-b089e`

---

## File Locations

All scripts located in: `D:\Pregame-World-Cup\functions\src\`

| File | Purpose | Status |
|------|---------|--------|
| `photo-fetcher-utils.ts` | Core utilities | NEW |
| `fetch-player-photos-v2.ts` | Enhanced player fetcher | NEW |
| `fetch-manager-photos-v2.ts` | Enhanced manager fetcher | NEW |
| `check-photos-v2.ts` | Status checker | NEW |
| `fetch-player-photos.ts` | Original player fetcher | Legacy |
| `fetch-manager-photos.ts` | Original manager fetcher | Legacy |
| `check-photos.ts` | Basic status checker | Legacy |

---

## Changelog

### Version 2.0 (New)

**New Features**:
- Multiple photo source fallbacks (TheSportsDB → Wikipedia → Wikimedia)
- Enhanced error handling and validation
- Real-time progress tracking with ETA
- Source tracking in Firestore
- Improved logging with visual indicators
- Reusable `photo-fetcher-utils.ts` library
- Dry-run mode for testing
- --limit flag for controlled testing

**Improvements**:
- Better image validation
- Automatic rate limiting
- Comprehensive progress reporting
- More detailed photo statistics
- Better code organization and reusability

### Version 1.0 (Legacy)

**Features**:
- TheSportsDB integration only
- Basic Firebase upload
- Simple progress tracking
- Photo status checking

---

## Support & Issues

For issues or questions:

1. Check the **Troubleshooting** section above
2. Verify Firebase configuration
3. Check API status (TheSportsDB.com, Wikipedia.org)
4. Review script logs for specific errors

---

## License & Attribution

- **TheSportsDB**: Free tier, respect rate limits
- **Wikipedia**: CC-BY-SA license, proper attribution
- **Firebase**: Your Firebase project credentials
- **Script Code**: Available in this repository

---

## Next Steps

1. Install dependencies: `npm install`
2. Verify Firebase credentials
3. Run status check: `npm run check-photos-v2`
4. Test with limit: `npm run fetch-player-photos-v2 -- --limit=10`
5. Monitor results: `npm run check-photos-v2 -- --players`
6. Run full fetch when ready

Happy photo fetching!

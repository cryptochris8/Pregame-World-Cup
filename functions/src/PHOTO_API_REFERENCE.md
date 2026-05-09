# Photo Fetcher API Reference

Complete API documentation for photo-fetcher-utils.ts

---

## Table of Contents

1. [PhotoFetcher](#photofetcher)
2. [TheSportsDBService](#thesportsdbservice)
3. [WikipediaService](#wikipediaservice)
4. [ImageDownloadService](#imagedownloadservice)
5. [FirebaseStorageService](#firebasestorageservice)
6. [FirestoreService](#firestoreservice)
7. [ProgressTracker](#progresstracker)
8. [Type Definitions](#type-definitions)

---

## PhotoFetcher

Main orchestrator class for fetching, uploading, and updating photos.

### Constructor

```typescript
constructor(
  bucket: admin.storage.Bucket,
  db: admin.firestore.Firestore,
  rateDelayMs: number = 500
)
```

**Parameters**:
- `bucket` - Firebase Storage bucket instance
- `db` - Firestore database instance
- `rateDelayMs` - Delay between API calls in milliseconds (default: 500ms)

**Example**:
```typescript
import * as admin from 'firebase-admin';
import { PhotoFetcher } from './photo-fetcher-utils';

admin.initializeApp();
const bucket = admin.storage().bucket();
const db = admin.firestore();

const fetcher = new PhotoFetcher(bucket, db, 500);
```

### Methods

#### fetchPhoto()

Fetches a photo URL from any available source.

```typescript
async fetchPhoto(
  name: string,
  alternativeNames?: string[]
): Promise<FetchPhotoResult>
```

**Parameters**:
- `name` - Primary name to search for
- `alternativeNames` - Optional array of alternative names to try

**Returns**:
```typescript
interface FetchPhotoResult {
  success: boolean
  photoUrl?: string
  source?: string  // 'TheSportsDB' | 'Wikipedia' | 'Wikimedia Commons'
  error?: string
  triedSources?: string[]
}
```

**Example**:
```typescript
const result = await fetcher.fetchPhoto(
  'Lionel Messi',
  ['Leo Messi', 'Messi']
);

if (result.success) {
  console.log(`Found photo from ${result.source}`);
  console.log(`URL: ${result.photoUrl}`);
} else {
  console.log(`Failed: ${result.error}`);
}
```

**Behavior**:
- Tries sources in order: TheSportsDB, Wikipedia, Wikimedia Commons
- For each source, tries primary name then alternative names
- Returns immediately on first successful download
- Returns full list of tried sources even on failure

---

#### fetchAndUpload()

Complete pipeline: fetch photo, upload to Firebase, update Firestore.

```typescript
async fetchAndUpload(
  name: string,
  entityType: 'player' | 'manager',
  entityId: string,
  fifaCode: string,
  alternativeNames?: string[],
  existingPhotoUrl?: string
): Promise<{
  success: boolean
  photoUrl?: string
  source?: string
  error?: string
}>
```

**Parameters**:
- `name` - Person's full name
- `entityType` - 'player' or 'manager'
- `entityId` - Unique document ID in Firestore
- `fifaCode` - Country FIFA code (e.g., 'en', 'ar', 'fr')
- `alternativeNames` - Optional alternative names to try
- `existingPhotoUrl` - Current photo URL (skips if Firebase URL)

**Returns**:
```typescript
{
  success: true,
  photoUrl: "https://firebasestorage.googleapis.com/...",
  source: "TheSportsDB"
}
// or
{
  success: false,
  error: "No photo found from any source"
}
```

**Example**:
```typescript
const result = await fetcher.fetchAndUpload(
  'Kylian Mbappé',
  'player',
  'player_123',
  'fr',
  ['Mbappe'],  // Alternative spelling
  existingPhotoUrl  // Skip if already has Firebase URL
);

if (result.success) {
  console.log(`Uploaded to: ${result.photoUrl}`);
  console.log(`From source: ${result.source}`);
}
```

**Process**:
1. Checks if photo already exists on Firebase Storage (skips if yes)
2. Searches for photo across all sources
3. Downloads image and validates buffer
4. Uploads to Firebase Storage with metadata
5. Updates Firestore document with URL and metadata
6. Returns final URL

---

## TheSportsDBService

Integration with TheSportsDB API for player/manager photos.

### Static Methods

#### searchPerson()

Searches TheSportsDB for a person by name.

```typescript
static async searchPerson(name: string): Promise<PhotoSource | null>
```

**Parameters**:
- `name` - Person's name to search

**Returns**:
```typescript
interface PhotoSource {
  source: string        // 'TheSportsDB'
  url: string          // Image URL
  quality: 'high' | 'medium' | 'low'
}
```

**Example**:
```typescript
import { TheSportsDBService } from './photo-fetcher-utils';

const photo = await TheSportsDBService.searchPerson('Cristiano Ronaldo');
if (photo) {
  console.log(`Quality: ${photo.quality}`);
  console.log(`URL: ${photo.url}`);
}
```

**Quality Levels**:
- `high` - strCutout (professional isolated cutout photo)
- `medium` - strRender (rendered/composite image)
- `low` - strThumb (thumbnail size)

**Error Handling**:
- Returns `null` if person not found
- Returns `null` if no photo available
- Silently catches API errors

**API Details**:
- Endpoint: `https://www.thesportsdb.com/api/v1/json/3/searchplayers.php`
- Rate Limit: Free tier has limits, use rate limiting
- Timeout: 5 seconds

---

## WikipediaService

Integration with Wikipedia and Wikimedia Commons for photos.

### Static Methods

#### searchAndGetPhoto()

Searches Wikipedia for a person and retrieves their photo.

```typescript
static async searchAndGetPhoto(name: string): Promise<PhotoSource | null>
```

**Parameters**:
- `name` - Person's name to search

**Returns**:
```typescript
interface PhotoSource {
  source: string        // 'Wikipedia' or 'Wikimedia Commons'
  url: string          // Image URL
  quality: 'high' | 'medium' | 'low'
}
```

**Example**:
```typescript
import { WikipediaService } from './photo-fetcher-utils';

const photo = await WikipediaService.searchAndGetPhoto('Messi');
if (photo) {
  console.log(`Found on ${photo.source}`);
  console.log(`URL: ${photo.url}`);
}
```

**Process**:
1. Searches Wikipedia for person
2. Attempts to get page image (thumbnail)
3. Falls back to Wikimedia Commons full resolution
4. Returns best available quality

**API Details**:
- Endpoint: `https://en.wikipedia.org/w/api.php`
- Commons: `https://commons.wikimedia.org/w/api.php`
- Timeout: 5 seconds
- Rate Limit: Generous (can make many requests)

**Quality**:
- Typically `medium` to `high` when available
- May include team logos or medals

---

## ImageDownloadService

Safe image download with validation.

### Static Methods

#### download()

Downloads an image from a URL with timeout and error handling.

```typescript
static async download(
  url: string,
  timeout: number = 10000
): Promise<Buffer | null>
```

**Parameters**:
- `url` - Image URL to download
- `timeout` - Timeout in milliseconds (default: 10000ms)

**Returns**:
- `Buffer` - Image data if successful
- `null` - If download fails

**Example**:
```typescript
import { ImageDownloadService } from './photo-fetcher-utils';

const buffer = await ImageDownloadService.download(
  'https://example.com/photo.jpg',
  5000
);

if (buffer) {
  console.log(`Downloaded ${buffer.length} bytes`);
}
```

**Headers**:
- Sets User-Agent to mimic browser for API compatibility

**Error Handling**:
- Silently catches network errors
- Logs error message for debugging
- Returns null on any failure

---

#### validateBuffer()

Validates that a buffer appears to be a valid image.

```typescript
static async validateBuffer(buffer: Buffer): Promise<boolean>
```

**Parameters**:
- `buffer` - Buffer to validate

**Returns**:
- `true` - If buffer appears valid (>100 bytes)
- `false` - If buffer is invalid or empty

**Example**:
```typescript
const buffer = await ImageDownloadService.download(url);
if (buffer && await ImageDownloadService.validateBuffer(buffer)) {
  console.log('Valid image');
}
```

**Validation**:
- Checks minimum size (100 bytes)
- Basic sanity check only
- Not full image format validation

---

## FirebaseStorageService

Handles uploading images to Firebase Storage.

### Constructor

```typescript
constructor(bucket: admin.storage.Bucket)
```

**Parameters**:
- `bucket` - Firebase Storage bucket instance

**Example**:
```typescript
import * as admin from 'firebase-admin';
import { FirebaseStorageService } from './photo-fetcher-utils';

admin.initializeApp();
const bucket = admin.storage().bucket();
const storage = new FirebaseStorageService(bucket);
```

### Methods

#### uploadPhoto()

Uploads an image buffer to Firebase Storage.

```typescript
async uploadPhoto(
  imageBuffer: Buffer,
  entityType: 'player' | 'manager',
  entityId: string,
  fifaCode: string,
  metadata?: {[key: string]: string}
): Promise<UploadResult>
```

**Parameters**:
- `imageBuffer` - Image data as Buffer
- `entityType` - 'player' or 'manager'
- `entityId` - Unique entity ID
- `fifaCode` - Country code
- `metadata` - Optional custom metadata

**Returns**:
```typescript
interface UploadResult {
  success: boolean
  url?: string  // Public URL if successful
  error?: string
}
```

**Example**:
```typescript
const result = await storage.uploadPhoto(
  imageBuffer,
  'player',
  'player_123',
  'en',
  { source: 'TheSportsDB', fetchedAt: new Date().toISOString() }
);

if (result.success) {
  console.log(`Uploaded to: ${result.url}`);
}
```

**File Path**:
- Players: `players/{fifaCode}_{entityId}.jpg`
- Managers: `managers/{fifaCode}_{entityId}.jpg`

**Example**:
- `players/en_1.jpg` - England player ID 1
- `managers/fr_1.jpg` - France manager ID 1

**Metadata Set**:
- `contentType: image/jpeg`
- `cacheControl: public, max-age=31536000` (1 year cache)
- Any custom metadata passed in

**Permissions**:
- Makes file publicly readable (no authentication needed)
- Anyone with the URL can view the image

---

## FirestoreService

Manages Firestore document updates and queries.

### Constructor

```typescript
constructor(db: admin.firestore.Firestore)
```

**Parameters**:
- `db` - Firestore database instance

**Example**:
```typescript
import * as admin from 'firebase-admin';
import { FirestoreService } from './photo-fetcher-utils';

admin.initializeApp();
const db = admin.firestore();
const firestore = new FirestoreService(db);
```

### Methods

#### updatePhotoUrl()

Updates a Firestore document with new photo URL and metadata.

```typescript
async updatePhotoUrl(
  collection: 'players' | 'managers',
  entityId: string,
  photoUrl: string,
  additionalData?: Record<string, any>
): Promise<FirestoreUpdateResult>
```

**Parameters**:
- `collection` - 'players' or 'managers'
- `entityId` - Document ID to update
- `photoUrl` - New photo URL
- `additionalData` - Optional extra fields to update

**Returns**:
```typescript
interface FirestoreUpdateResult {
  success: boolean
  error?: string
  documentsUpdated?: number
}
```

**Example**:
```typescript
const result = await firestore.updatePhotoUrl(
  'players',
  'player_123',
  'https://firebasestorage.googleapis.com/...',
  { photoSource: 'TheSportsDB', photoQuality: 'high' }
);

if (result.success) {
  console.log('Firestore updated');
}
```

**Fields Updated**:
- `photoUrl` - The new URL
- `photoUpdatedAt` - Server timestamp
- Any fields in `additionalData`

**Example Firestore Update**:
```javascript
{
  photoUrl: "https://firebasestorage.googleapis.com/v0/b/pregame-b089e.firebasestorage.app/o/players%2Fen_1.jpg?alt=media",
  photoUpdatedAt: {_seconds: 1735387200, _nanoseconds: 0},
  photoSource: "TheSportsDB",
  photoQuality: "high"
}
```

---

#### fetchEntities()

Fetches entities from Firestore (players or managers).

```typescript
async fetchEntities(
  collection: 'players' | 'managers',
  limit?: number
): Promise<Array<{id: string; [key: string]: any}>>
```

**Parameters**:
- `collection` - 'players' or 'managers'
- `limit` - Optional limit on number of documents (default: all)

**Returns**:
- Array of objects with `id` property plus all document fields

**Example**:
```typescript
const players = await firestore.fetchEntities('players', 100);
console.log(`Fetched ${players.length} players`);

players.forEach(player => {
  console.log(`${player.id}: ${player.fullName}`);
});
```

**Error Handling**:
- Returns empty array on error
- Logs error for debugging

---

## ProgressTracker

Tracks progress and calculates ETAs.

### Constructor

```typescript
constructor(total: number)
```

**Parameters**:
- `total` - Total number of items to process

**Example**:
```typescript
import { ProgressTracker } from './photo-fetcher-utils';

const progress = new ProgressTracker(1000);
```

### Methods

#### record()

Records completion of one item.

```typescript
record(status: 'success' | 'error' | 'skipped'): void
```

**Parameters**:
- `status` - How the item was processed

**Example**:
```typescript
for (const item of items) {
  try {
    await processItem(item);
    progress.record('success');
  } catch (e) {
    progress.record('error');
  }
}
```

**Usage in Loop**:
```typescript
for (let i = 0; i < items.length; i++) {
  const item = items[i];
  const info = progress.getProgress();
  console.log(`Processing ${info.processed}/${info.total}`);

  try {
    // Process item
    progress.record('success');
  } catch (e) {
    progress.record('error');
  }
}
```

---

#### getProgress()

Gets current progress information.

```typescript
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
```

**Returns**:
```typescript
{
  processed: 150,        // Items processed so far
  total: 1000,          // Total items
  percentage: 15,        // Percentage complete (0-100)
  succeeded: 145,        // Successful
  failed: 3,            // Failed
  skipped: 2,           // Skipped
  elapsedSeconds: 120,   // Time elapsed
  estimatedRemaining: "10m"  // ETA string
}
```

**Example**:
```typescript
const progress = progress.getProgress();
console.log(`Progress: ${progress.processed}/${progress.total} (${progress.percentage}%)`);
console.log(`ETA: ${progress.estimatedRemaining}`);
```

---

#### printSummary()

Prints formatted summary to console.

```typescript
printSummary(): void
```

**Example**:
```typescript
progress.printSummary();
```

**Output**:
```
=====================================
SUMMARY
=====================================
Success: 1050
Failed:  120
Skipped: 30
Total:   1200

Time Elapsed: 720s
Status: 1200/1200 (100%)
```

---

## Type Definitions

### PhotoSource

```typescript
interface PhotoSource {
  source: string                    // Service name
  url: string                       // Image URL
  quality: 'high' | 'medium' | 'low'  // Quality level
}
```

### FetchPhotoResult

```typescript
interface FetchPhotoResult {
  success: boolean
  photoUrl?: string
  source?: string
  error?: string
  triedSources?: string[]
}
```

### UploadResult

```typescript
interface UploadResult {
  success: boolean
  url?: string
  error?: string
}
```

### FirestoreUpdateResult

```typescript
interface FirestoreUpdateResult {
  success: boolean
  error?: string
  documentsUpdated?: number
}
```

---

## Complete Usage Example

```typescript
import * as admin from 'firebase-admin';
import * as fs from 'fs';
import * as path from 'path';
import {
  PhotoFetcher,
  ProgressTracker,
  FirestoreService,
} from './photo-fetcher-utils';

// Initialize Firebase
const serviceAccountPath = path.join(__dirname, '../../service-account-key.json');
const serviceAccount = require(serviceAccountPath);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  storageBucket: 'pregame-b089e.firebasestorage.app',
});

const db = admin.firestore();
const bucket = admin.storage().bucket();

// Initialize services
const fetcher = new PhotoFetcher(bucket, db, 500);
const firestoreService = new FirestoreService(db);
const progress = new ProgressTracker(0);

async function main() {
  // Fetch players
  console.log('Fetching players...');
  const players = await firestoreService.fetchEntities('players', 100);

  progress = new ProgressTracker(players.length);

  // Process each player
  for (const player of players) {
    const progressInfo = progress.getProgress();
    console.log(`[${progressInfo.processed}/${progressInfo.total}] ${player.fullName}`);
    console.log(`ETA: ${progressInfo.estimatedRemaining}`);

    // Skip if already has Firebase photo
    if (player.photoUrl?.includes('firebasestorage.googleapis.com')) {
      progress.record('skipped');
      continue;
    }

    // Fetch and upload
    const result = await fetcher.fetchAndUpload(
      player.fullName,
      'player',
      player.id,
      player.fifaCode || 'XX',
      [player.commonName],
      player.photoUrl
    );

    if (result.success) {
      console.log(`  SUCCESS: ${result.source}`);
      progress.record('success');
    } else {
      console.log(`  FAILED: ${result.error}`);
      progress.record('error');
    }
  }

  // Print summary
  progress.printSummary();
}

main().catch(console.error);
```

---

## Notes

- All methods are async/await compatible
- All methods include error handling
- No method throws exceptions (uses return values)
- Rate limiting built into PhotoFetcher
- Services can be used independently
- Comprehensive logging of all operations


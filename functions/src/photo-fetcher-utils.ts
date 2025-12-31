/**
 * Photo Fetcher Utilities
 *
 * Provides comprehensive photo fetching with multiple fallback sources,
 * error handling, and Firebase integration.
 *
 * Supported sources (in order of preference):
 * 1. TheSportsDB (primary)
 * 2. Wikipedia Commons (fallback)
 * 3. FIFA Official (fallback)
 */

import axios, { AxiosError } from 'axios';
import * as admin from 'firebase-admin';

// ============================================================================
// Types and Interfaces
// ============================================================================

export interface PhotoSource {
  source: string;
  url: string;
  quality: 'high' | 'medium' | 'low';
}

export interface FetchPhotoResult {
  success: boolean;
  photoUrl?: string;
  source?: string;
  error?: string;
  triedSources?: string[];
}

export interface UploadResult {
  success: boolean;
  url?: string;
  error?: string;
}

export interface FirestoreUpdateResult {
  success: boolean;
  error?: string;
  documentsUpdated?: number;
}

// ============================================================================
// TheSportsDB Service
// ============================================================================

const SPORTSDB_BASE_URL = 'https://www.thesportsdb.com/api/v1/json/3';
const THESPORTSDB_TIMEOUT = 5000;

interface SportsDBPerson {
  idPlayer: string;
  strPlayer: string;
  strThumb?: string;
  strCutout?: string;
  strRender?: string;
}

interface SportsDBResponse {
  player?: SportsDBPerson[] | null;
}

export class TheSportsDBService {
  static async searchPerson(name: string): Promise<PhotoSource | null> {
    try {
      const url = `${SPORTSDB_BASE_URL}/searchplayers.php?p=${encodeURIComponent(name)}`;
      const response = await axios.get<SportsDBResponse>(url, {
        timeout: THESPORTSDB_TIMEOUT,
      });

      if (response.data.player && response.data.player.length > 0) {
        const person = response.data.player[0];

        // Prefer cutout, then render, then thumb
        const photoUrl = person.strCutout || person.strRender || person.strThumb;

        if (photoUrl) {
          let quality: 'high' | 'medium' | 'low' = 'medium';
          if (person.strCutout) quality = 'high';
          if (person.strRender) quality = 'medium';
          if (person.strThumb) quality = 'low';

          return {
            source: 'TheSportsDB',
            url: photoUrl,
            quality,
          };
        }
      }

      return null;
    } catch (error) {
      console.error(`TheSportsDB search failed for "${name}":`, error);
      return null;
    }
  }
}

// ============================================================================
// Wikipedia Service
// ============================================================================

const WIKIPEDIA_API_URL = 'https://en.wikipedia.org/w/api.php';

interface WikiSearchResult {
  query?: {
    search: Array<{
      title: string;
      pageid: number;
    }>;
  };
}

export class WikipediaService {
  static async searchAndGetPhoto(name: string): Promise<PhotoSource | null> {
    try {
      // Step 1: Search for the person
      const searchUrl = new URL(WIKIPEDIA_API_URL);
      searchUrl.searchParams.append('action', 'query');
      searchUrl.searchParams.append('list', 'search');
      searchUrl.searchParams.append('srsearch', name);
      searchUrl.searchParams.append('format', 'json');

      const searchResponse = await axios.get<WikiSearchResult>(searchUrl.toString(), {
        timeout: THESPORTSDB_TIMEOUT,
      });

      if (!searchResponse.data.query?.search || searchResponse.data.query.search.length === 0) {
        return null;
      }

      const pageId = searchResponse.data.query.search[0].pageid;

      // Step 2: Get the page image
      const imageUrl = new URL(WIKIPEDIA_API_URL);
      imageUrl.searchParams.append('action', 'query');
      imageUrl.searchParams.append('pageids', pageId.toString());
      imageUrl.searchParams.append('prop', 'pageimages');
      imageUrl.searchParams.append('pithumbsize', '250');
      imageUrl.searchParams.append('format', 'json');

      const imageResponse = await axios.get(imageUrl.toString(), {
        timeout: THESPORTSDB_TIMEOUT,
      });

      const pages = imageResponse.data.query?.pages;
      if (!pages) return null;

      const page = Object.values(pages)[0] as any;
      const thumbnail = page.thumbnail;

      if (thumbnail?.source) {
        return {
          source: 'Wikipedia',
          url: thumbnail.source,
          quality: 'medium',
        };
      }

      // Step 3: Try to get full resolution image from Commons
      return await this.getCommonsImage(searchResponse.data.query.search[0].title);
    } catch (error) {
      console.error(`Wikipedia search failed for "${name}":`, error);
      return null;
    }
  }

  private static async getCommonsImage(pageTitle: string): Promise<PhotoSource | null> {
    try {
      const commonsUrl = new URL('https://commons.wikimedia.org/w/api.php');
      commonsUrl.searchParams.append('action', 'query');
      commonsUrl.searchParams.append('titles', `File:${pageTitle}.jpg`);
      commonsUrl.searchParams.append('prop', 'imageinfo');
      commonsUrl.searchParams.append('iiprop', 'url');
      commonsUrl.searchParams.append('format', 'json');

      const response = await axios.get(commonsUrl.toString(), {
        timeout: THESPORTSDB_TIMEOUT,
      });

      const pages = response.data.query?.pages;
      if (!pages) return null;

      const page = Object.values(pages)[0] as any;
      const imageInfo = page.imageinfo?.[0];

      if (imageInfo?.url) {
        return {
          source: 'Wikimedia Commons',
          url: imageInfo.url,
          quality: 'high',
        };
      }

      return null;
    } catch (error) {
      return null;
    }
  }
}

// ============================================================================
// Image Download Service
// ============================================================================

export class ImageDownloadService {
  static async download(url: string, timeout: number = 10000): Promise<Buffer | null> {
    try {
      const response = await axios.get(url, {
        responseType: 'arraybuffer',
        timeout,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      });

      return Buffer.from(response.data);
    } catch (error) {
      const axiosError = error as AxiosError;
      console.error(`Failed to download image from ${url}:`, axiosError.message);
      return null;
    }
  }

  static async validateBuffer(buffer: Buffer): Promise<boolean> {
    // Check if buffer looks like an image (at least 100 bytes)
    return buffer && buffer.length > 100;
  }
}

// ============================================================================
// Firebase Storage Service
// ============================================================================

export class FirebaseStorageService {
  private bucket: any;

  constructor(bucket: any) {
    this.bucket = bucket;
  }

  async uploadPhoto(
    imageBuffer: Buffer,
    entityType: 'player' | 'manager',
    entityId: string,
    fifaCode: string,
    metadata?: { [key: string]: string }
  ): Promise<UploadResult> {
    try {
      const fileName = `${entityType}s/${fifaCode.toLowerCase()}_${entityId}.jpg`;
      const file = this.bucket.file(fileName);

      await file.save(imageBuffer, {
        metadata: {
          contentType: 'image/jpeg',
          cacheControl: 'public, max-age=31536000',
          ...metadata,
        },
      });

      // Make publicly accessible
      await file.makePublic();

      // Generate public URL
      const publicUrl = `https://firebasestorage.googleapis.com/v0/b/${this.bucket.name}/o/${encodeURIComponent(
        fileName
      )}?alt=media`;

      return { success: true, url: publicUrl };
    } catch (error) {
      console.error(`Failed to upload photo to Firebase Storage:`, error);
      return { success: false, error: String(error) };
    }
  }
}

// ============================================================================
// Firestore Service
// ============================================================================

export class FirestoreService {
  private db: admin.firestore.Firestore;

  constructor(db: admin.firestore.Firestore) {
    this.db = db;
  }

  async updatePhotoUrl(
    collection: 'players' | 'managers',
    entityId: string,
    photoUrl: string,
    additionalData?: Record<string, any>
  ): Promise<FirestoreUpdateResult> {
    try {
      const updateData = {
        photoUrl,
        photoUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
        ...additionalData,
      };

      await this.db.collection(collection).doc(entityId).update(updateData);

      return { success: true, documentsUpdated: 1 };
    } catch (error) {
      console.error(`Failed to update Firestore for ${collection}/${entityId}:`, error);
      return { success: false, error: String(error) };
    }
  }

  async fetchEntities(
    collection: 'players' | 'managers',
    limit?: number
  ): Promise<Array<{ id: string; [key: string]: any }>> {
    try {
      let query: admin.firestore.Query = this.db.collection(collection);

      if (limit) {
        query = query.limit(limit);
      }

      const snapshot = await query.get();

      return snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
      }));
    } catch (error) {
      console.error(`Failed to fetch ${collection} from Firestore:`, error);
      return [];
    }
  }
}

// ============================================================================
// Photo Fetcher (Main Service)
// ============================================================================

export class PhotoFetcher {
  private storage: FirebaseStorageService;
  private firestore: FirestoreService;
  private rateDelayMs: number;

  constructor(
    bucket: any,
    db: admin.firestore.Firestore,
    rateDelayMs: number = 500
  ) {
    this.storage = new FirebaseStorageService(bucket);
    this.firestore = new FirestoreService(db);
    this.rateDelayMs = rateDelayMs;
  }

  async fetchPhoto(
    name: string,
    alternativeNames?: string[]
  ): Promise<FetchPhotoResult> {
    const triedSources: string[] = [];
    const namesToTry = [name, ...(alternativeNames || [])];

    // Try TheSportsDB first
    for (const nameToTry of namesToTry) {
      const source = await TheSportsDBService.searchPerson(nameToTry);
      if (source) {
        triedSources.push(`TheSportsDB (${source.quality})`);

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
      triedSources.push('TheSportsDB');
      await this.sleep(this.rateDelayMs);
    }

    // Try Wikipedia fallback
    for (const nameToTry of namesToTry) {
      const source = await WikipediaService.searchAndGetPhoto(nameToTry);
      if (source) {
        triedSources.push(`Wikipedia (${source.quality})`);

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
      triedSources.push('Wikipedia');
      await this.sleep(this.rateDelayMs);
    }

    return {
      success: false,
      error: 'No photo found from any source',
      triedSources,
    };
  }

  async fetchAndUpload(
    name: string,
    entityType: 'player' | 'manager',
    entityId: string,
    fifaCode: string,
    alternativeNames?: string[],
    existingPhotoUrl?: string
  ): Promise<{
    success: boolean;
    photoUrl?: string;
    source?: string;
    error?: string;
  }> {
    // Skip if already has Firebase Storage URL
    if (existingPhotoUrl?.includes('firebasestorage.googleapis.com')) {
      return { success: true, photoUrl: existingPhotoUrl };
    }

    const fetchResult = await this.fetchPhoto(name, alternativeNames);

    if (!fetchResult.success) {
      return {
        success: false,
        error: fetchResult.error,
      };
    }

    // Download the image
    const buffer = await ImageDownloadService.download(fetchResult.photoUrl!);
    if (!buffer) {
      return {
        success: false,
        error: 'Failed to download image',
      };
    }

    // Upload to Firebase Storage
    const uploadResult = await this.storage.uploadPhoto(
      buffer,
      entityType,
      entityId,
      fifaCode,
      fetchResult.source ? { source: fetchResult.source } : undefined
    );

    if (!uploadResult.success) {
      return {
        success: false,
        error: uploadResult.error,
      };
    }

    // Update Firestore
    const firestoreResult = await this.firestore.updatePhotoUrl(
      entityType === 'player' ? 'players' : 'managers',
      entityId,
      uploadResult.url!,
      { photoSource: fetchResult.source }
    );

    if (!firestoreResult.success) {
      return {
        success: false,
        error: firestoreResult.error,
      };
    }

    return {
      success: true,
      photoUrl: uploadResult.url,
      source: fetchResult.source,
    };
  }

  private sleep(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}

// ============================================================================
// Helper: Progress Tracker
// ============================================================================

export class ProgressTracker {
  private total: number;
  private processed: number = 0;
  private succeeded: number = 0;
  private failed: number = 0;
  private skipped: number = 0;
  private startTime: number = Date.now();

  constructor(total: number) {
    this.total = total;
  }

  record(status: 'success' | 'error' | 'skipped'): void {
    this.processed++;
    switch (status) {
      case 'success':
        this.succeeded++;
        break;
      case 'error':
        this.failed++;
        break;
      case 'skipped':
        this.skipped++;
        break;
    }
  }

  getProgress(): {
    processed: number;
    total: number;
    percentage: number;
    succeeded: number;
    failed: number;
    skipped: number;
    elapsedSeconds: number;
    estimatedRemaining: string;
  } {
    const elapsedMs = Date.now() - this.startTime;
    const elapsedSeconds = Math.round(elapsedMs / 1000);
    const itemsPerSecond = this.processed / Math.max(1, elapsedSeconds);
    const remainingItems = this.total - this.processed;
    const estimatedRemainingSec = Math.round(remainingItems / Math.max(0.1, itemsPerSecond));

    let estimatedRemaining = '';
    if (estimatedRemainingSec < 60) {
      estimatedRemaining = `${estimatedRemainingSec}s`;
    } else {
      estimatedRemaining = `${Math.round(estimatedRemainingSec / 60)}m`;
    }

    return {
      processed: this.processed,
      total: this.total,
      percentage: Math.round((this.processed / this.total) * 100),
      succeeded: this.succeeded,
      failed: this.failed,
      skipped: this.skipped,
      elapsedSeconds,
      estimatedRemaining,
    };
  }

  printSummary(): void {
    const progress = this.getProgress();
    console.log('\n=====================================');
    console.log('SUMMARY');
    console.log('=====================================');
    console.log(`Success: ${progress.succeeded}`);
    console.log(`Failed:  ${progress.failed}`);
    console.log(`Skipped: ${progress.skipped}`);
    console.log(`Total:   ${progress.total}`);
    console.log(`\nTime Elapsed: ${progress.elapsedSeconds}s`);
    console.log(`Status: ${progress.processed}/${progress.total} (${progress.percentage}%)`);
  }
}

/**
 * Shared Seed Script Utilities
 *
 * Common functions used across all Firestore seed scripts:
 * - Firebase initialization
 * - CLI argument parsing
 * - JSON file reading
 * - Batch Firestore writes
 * - Collection clearing
 */

import * as admin from "firebase-admin";
import * as fs from "fs";
import * as path from "path";

// ============================================================================
// Firebase Initialization
// ============================================================================

/**
 * Initialize Firebase Admin SDK.
 * Reuses existing app if already initialized.
 */
export function initFirebase(): admin.firestore.Firestore {
  if (!admin.apps.length) {
    try {
      admin.initializeApp();
    } catch {
      admin.initializeApp({ projectId: "pregame-b089e" });
    }
  }
  return admin.firestore();
}

// ============================================================================
// CLI Argument Parsing
// ============================================================================

/**
 * Parse CLI arguments for common seed script flags.
 *
 * Supported flags:
 *   --dryRun   Preview changes without writing to Firestore
 *   --team=CODE  Filter by team code (uppercased)
 *   --clear    Clear existing collection data before seeding
 *   --verbose  Enable verbose logging
 */
export function parseArgs(): { dryRun: boolean; team?: string; clear: boolean; verbose: boolean } {
  const args = process.argv.slice(2);
  return {
    dryRun: args.includes("--dryRun"),
    clear: args.includes("--clear"),
    verbose: args.includes("--verbose"),
    team: args.find(a => a.startsWith("--team="))?.split("=")[1]?.toUpperCase(),
  };
}

// ============================================================================
// JSON File Utilities
// ============================================================================

/**
 * Read all JSON files from a directory.
 * Returns an array of parsed objects.
 *
 * @param dirPath - Relative path from __dirname or absolute path
 */
export function readJsonDir(dirPath: string): any[] {
  const fullPath = path.resolve(__dirname, dirPath);
  if (!fs.existsSync(fullPath)) {
    throw new Error(`Directory not found: ${fullPath}`);
  }
  const files = fs.readdirSync(fullPath).filter(f => f.endsWith(".json"));
  return files.map(file => {
    const content = fs.readFileSync(path.join(fullPath, file), "utf-8");
    return JSON.parse(content);
  });
}

/**
 * Read a single JSON file.
 *
 * @param filePath - Relative path from __dirname or absolute path
 */
export function readJsonFile(filePath: string): any {
  const fullPath = path.resolve(__dirname, filePath);
  if (!fs.existsSync(fullPath)) {
    throw new Error(`File not found: ${fullPath}`);
  }
  const content = fs.readFileSync(fullPath, "utf-8");
  return JSON.parse(content);
}

// ============================================================================
// Firestore Batch Operations
// ============================================================================

/**
 * Batch write documents to Firestore.
 * Respects the 500-document-per-batch limit by committing in chunks of 490.
 * Each document gets an `updatedAt` server timestamp via merge.
 *
 * @param db - Firestore instance
 * @param collection - Target collection name
 * @param docs - Array of { id, data } objects to write
 * @param dryRun - If true, log what would be written without actually writing
 * @returns Number of documents written
 */
export async function batchWrite(
  db: admin.firestore.Firestore,
  collection: string,
  docs: { id: string; data: Record<string, any> }[],
  dryRun: boolean
): Promise<number> {
  if (dryRun) {
    console.log(`[DRY RUN] Would write ${docs.length} docs to '${collection}':`);
    docs.forEach(d => console.log(`  - ${d.id}`));
    return docs.length;
  }

  let batch = db.batch();
  let count = 0;
  let totalWritten = 0;

  for (const doc of docs) {
    const ref = db.collection(collection).doc(doc.id);
    batch.set(ref, {
      ...doc.data,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });
    count++;
    totalWritten++;

    if (count >= 490) {
      await batch.commit();
      console.log(`  Committed batch (${totalWritten}/${docs.length})`);
      batch = db.batch();
      count = 0;
    }
  }

  if (count > 0) {
    await batch.commit();
  }

  console.log(`Wrote ${totalWritten} docs to '${collection}'`);
  return totalWritten;
}

/**
 * Clear all documents in a Firestore collection.
 * Deletes in batches of 490 to respect the 500-doc limit.
 *
 * @param db - Firestore instance
 * @param collection - Collection to clear
 * @param dryRun - If true, log what would be cleared without actually deleting
 */
export async function clearCollection(
  db: admin.firestore.Firestore,
  collection: string,
  dryRun: boolean
): Promise<void> {
  if (dryRun) {
    console.log(`[DRY RUN] Would clear collection '${collection}'`);
    return;
  }

  const snapshot = await db.collection(collection).get();
  if (snapshot.empty) {
    console.log(`Collection '${collection}' is already empty`);
    return;
  }

  let batch = db.batch();
  let count = 0;

  for (const doc of snapshot.docs) {
    batch.delete(doc.ref);
    count++;
    if (count >= 490) {
      await batch.commit();
      batch = db.batch();
      count = 0;
    }
  }

  if (count > 0) {
    await batch.commit();
  }

  console.log(`Cleared ${snapshot.size} docs from '${collection}'`);
}

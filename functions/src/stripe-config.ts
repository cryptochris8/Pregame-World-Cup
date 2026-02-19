import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import Stripe from 'stripe';

/**
 * Shared Stripe configuration for all payment Cloud Functions.
 * Reads the secret key from Firebase Functions config or environment variables.
 * Throws immediately if no key is configured — never falls back to a test key.
 */
const getStripeSecretKey = (): string => {
  // Try process.env first (works in both v1 and v2 Cloud Run)
  const envKey = process.env.STRIPE_SECRET_KEY;
  if (envKey) return envKey;

  // Try functions.config() (v1 only — may throw in v2 Cloud Run containers)
  try {
    const configKey = functions.config().stripe?.secret_key;
    if (configKey) return configKey;
  } catch {
    // functions.config() not available in v2 runtime — ignore
  }

  throw new Error('STRIPE_SECRET_KEY not configured');
};

// Lazy Stripe initialization — avoids calling getStripeSecretKey() at module
// load time, which would crash v2 Cloud Run containers at startup.
let _stripe: Stripe | null = null;
export function getStripe(): Stripe {
  if (!_stripe) {
    _stripe = new Stripe(getStripeSecretKey(), {
      apiVersion: '2025-05-28.basil',
    });
  }
  return _stripe;
}

/**
 * Safely read a value from functions.config(), returning undefined if
 * unavailable (e.g., in v2 Cloud Run containers).
 */
export function getConfigValue(...path: string[]): string | undefined {
  try {
    let obj: any = functions.config();
    for (const part of path) {
      obj = obj?.[part];
    }
    return obj || undefined;
  } catch {
    return undefined;
  }
}

// ============================================================================
// IDEMPOTENCY HELPERS
// ============================================================================

// Lazy Firestore reference — avoids calling admin.firestore() at module load
// time, which would fail in test environments where Firebase isn't initialized.
let _db: admin.firestore.Firestore | null = null;
function getDb(): admin.firestore.Firestore {
  if (!_db) _db = admin.firestore();
  return _db;
}

/**
 * Check if a webhook event has already been processed.
 * Returns true if the event was already handled (should be skipped).
 */
export async function isWebhookEventAlreadyProcessed(eventId: string): Promise<boolean> {
  const docRef = getDb().collection('processed_webhook_events').doc(eventId);
  const doc = await docRef.get();
  return doc.exists;
}

/**
 * Mark a webhook event as processed to prevent duplicate handling.
 */
export async function markWebhookEventProcessed(eventId: string, eventType: string): Promise<void> {
  await getDb().collection('processed_webhook_events').doc(eventId).set({
    eventId,
    eventType,
    processedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

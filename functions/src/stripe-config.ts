import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import Stripe from 'stripe';

/**
 * Shared Stripe configuration for all payment Cloud Functions.
 * Reads the secret key from Firebase Functions config or environment variables.
 * Throws immediately if no key is configured — never falls back to a test key.
 */
const getStripeSecretKey = (): string => {
  try {
    const key = functions.config().stripe?.secret_key || process.env.STRIPE_SECRET_KEY;
    if (!key) throw new Error('STRIPE_SECRET_KEY not configured');
    return key;
  } catch (error: any) {
    if (error.message === 'STRIPE_SECRET_KEY not configured') throw error;
    const key = process.env.STRIPE_SECRET_KEY;
    if (!key) throw new Error('STRIPE_SECRET_KEY not configured');
    return key;
  }
};

export const stripe = new Stripe(getStripeSecretKey(), {
  apiVersion: '2025-05-28.basil',
});

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

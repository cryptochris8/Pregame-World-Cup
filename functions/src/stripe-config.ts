import * as functions from 'firebase-functions';
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

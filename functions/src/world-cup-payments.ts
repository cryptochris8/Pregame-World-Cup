/**
 * World Cup 2026 Payment System
 *
 * One-time payments for the tournament period (June 11 - July 19, 2026)
 *
 * Fan Tiers:
 * - Free: Basic schedules, venue discovery, notifications
 * - Fan Pass ($14.99): Ad-free, advanced stats, custom alerts, social features
 * - Superfan Pass ($29.99): Everything + exclusive content, priority features
 *
 * Venue Tiers:
 * - Free: Basic "shows matches" toggle only
 * - Premium ($99): Full portal access - TV setup, specials, atmosphere, featured listing
 */

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import Stripe from 'stripe';
import { stripe } from './stripe-config';

const db = admin.firestore();

// ============================================================================
// IDEMPOTENCY HELPERS
// ============================================================================

/**
 * Check if a webhook event has already been processed.
 * Returns true if the event was already handled (should be skipped).
 */
async function isWebhookEventAlreadyProcessed(eventId: string): Promise<boolean> {
  const docRef = db.collection('processed_webhook_events').doc(eventId);
  const doc = await docRef.get();
  return doc.exists;
}

/**
 * Mark a webhook event as processed to prevent duplicate handling.
 */
async function markWebhookEventProcessed(eventId: string, eventType: string): Promise<void> {
  await db.collection('processed_webhook_events').doc(eventId).set({
    eventId,
    eventType,
    processedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

// ============================================================================
// CONFIGURATION - Stripe Price IDs (set these after creating products in Stripe)
// ============================================================================

const WORLD_CUP_PRICES = {
  // Fan passes - one-time payments
  FAN_PASS: process.env.STRIPE_FAN_PASS_PRICE_ID || 'price_1SnYT9LmA106gMF6SK1oDaWE',
  SUPERFAN_PASS: process.env.STRIPE_SUPERFAN_PASS_PRICE_ID || 'price_1SnYi4LmA106gMF6h5yRgzLL',

  // Venue premium - one-time payment
  VENUE_PREMIUM: process.env.STRIPE_VENUE_PREMIUM_PRICE_ID || 'price_1SnYm5LmA106gMF63sYAuEB5',
};

// Price amounts in cents (for validation and display)
const PRICE_AMOUNTS = {
  FAN_PASS: 1499,        // $14.99
  SUPERFAN_PASS: 2999,   // $29.99
  VENUE_PREMIUM: 9900,   // $99.00
};

// Tournament dates
const TOURNAMENT_START = new Date('2026-06-11T00:00:00Z');
const TOURNAMENT_END = new Date('2026-07-20T23:59:59Z');

// ============================================================================
// FAN PASS FEATURES
// ============================================================================

const FAN_FEATURES = {
  free: {
    basicSchedules: true,
    venueDiscovery: true,
    matchNotifications: true,
    basicTeamFollowing: true,
    communityAccess: true,
    // Paid features
    adFree: false,
    advancedStats: false,
    customAlerts: false,
    advancedSocialFeatures: false,
    exclusiveContent: false,
    priorityFeatures: false,
    aiMatchInsights: false,
    downloadableContent: false,
  },
  fan_pass: {
    basicSchedules: true,
    venueDiscovery: true,
    matchNotifications: true,
    basicTeamFollowing: true,
    communityAccess: true,
    // Fan Pass features
    adFree: true,
    advancedStats: true,
    customAlerts: true,
    advancedSocialFeatures: true,
    // Superfan only
    exclusiveContent: false,
    priorityFeatures: false,
    aiMatchInsights: false,
    downloadableContent: false,
  },
  superfan_pass: {
    basicSchedules: true,
    venueDiscovery: true,
    matchNotifications: true,
    basicTeamFollowing: true,
    communityAccess: true,
    adFree: true,
    advancedStats: true,
    customAlerts: true,
    advancedSocialFeatures: true,
    // Superfan exclusive
    exclusiveContent: true,
    priorityFeatures: true,
    aiMatchInsights: true,
    downloadableContent: true,
  },
};

// ============================================================================
// VENUE FEATURES
// ============================================================================

const VENUE_FEATURES = {
  free: {
    showsMatches: true,           // Basic toggle
    // Premium features disabled
    matchScheduling: false,
    tvSetup: false,
    gameSpecials: false,
    atmosphereSettings: false,
    liveCapacity: false,
    featuredListing: false,
    analytics: false,
  },
  premium: {
    showsMatches: true,
    matchScheduling: true,
    tvSetup: true,
    gameSpecials: true,
    atmosphereSettings: true,
    liveCapacity: true,
    featuredListing: true,
    analytics: true,
  },
};

// ============================================================================
// FAN PASS PURCHASE FUNCTIONS
// ============================================================================

/**
 * Create checkout session for Fan Pass purchase
 */
export const createFanPassCheckout = functions.https.onCall(async (data: any, context: any) => {
  if (!context?.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
  }

  const passType = data.passType; // 'fan_pass' or 'superfan_pass'

  if (!['fan_pass', 'superfan_pass'].includes(passType)) {
    throw new functions.https.HttpsError('invalid-argument', 'Invalid pass type');
  }

  const userId = context.auth.uid;
  const userEmail = context.auth.token.email || '';

  try {
    // Check if user already has an active pass
    const existingPass = await db.collection('world_cup_fan_passes').doc(userId).get();
    if (existingPass.exists) {
      const passData = existingPass.data();
      if (passData?.status === 'active') {
        throw new functions.https.HttpsError(
          'already-exists',
          `You already have an active ${passData.passType === 'superfan_pass' ? 'Superfan' : 'Fan'} Pass`
        );
      }
    }

    // Get or create Stripe customer
    let customerId: string;
    const customerQuery = await db.collection('stripe_customers')
      .where('userId', '==', userId)
      .limit(1)
      .get();

    if (customerQuery.empty) {
      const customer = await stripe.customers.create({
        email: userEmail,
        metadata: {
          userId,
          type: 'fan',
        },
      });
      customerId = customer.id;

      await db.collection('stripe_customers').add({
        userId,
        customerId,
        email: userEmail,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    } else {
      customerId = customerQuery.docs[0].data().customerId;
    }

    // Create checkout session
    const priceId = passType === 'superfan_pass'
      ? WORLD_CUP_PRICES.SUPERFAN_PASS
      : WORLD_CUP_PRICES.FAN_PASS;

    // Determine success/cancel URLs
    // If the client passes returnToApp flag, use deep link URLs so the browser
    // redirects back into the app after checkout completes.
    const useAppDeepLink = data.returnToApp === true;
    const defaultSuccessUrl = useAppDeepLink
      ? `https://pregameworldcup.com/purchase/success?source=stripe_checkout&status=success&session_id={CHECKOUT_SESSION_ID}`
      : `https://pregame-b089e.web.app/purchase/success?session_id={CHECKOUT_SESSION_ID}`;
    const defaultCancelUrl = useAppDeepLink
      ? `https://pregameworldcup.com/purchase/cancel?source=stripe_checkout&status=cancelled`
      : 'https://pregame-b089e.web.app/purchase/cancel';

    const session = await stripe.checkout.sessions.create({
      customer: customerId,
      payment_method_types: ['card'],
      mode: 'payment', // One-time payment
      line_items: [
        {
          price: priceId,
          quantity: 1,
        },
      ],
      success_url: data.successUrl || defaultSuccessUrl,
      cancel_url: data.cancelUrl || defaultCancelUrl,
      metadata: {
        type: 'fan_pass',
        passType,
        userId,
      },
    });

    functions.logger.info(`Fan pass checkout created: ${session.id} for user ${userId}`);

    return {
      sessionId: session.id,
      url: session.url,
    };
  } catch (error: any) {
    functions.logger.error('Error creating fan pass checkout:', error);
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    throw new functions.https.HttpsError('internal', 'Failed to create checkout session');
  }
});

/**
 * Get current user's fan pass status
 */
export const getFanPassStatus = functions.https.onCall(async (data: any, context: any) => {
  if (!context?.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
  }

  const userId = context.auth.uid;

  try {
    const passDoc = await db.collection('world_cup_fan_passes').doc(userId).get();

    if (!passDoc.exists) {
      return {
        hasPass: false,
        passType: 'free',
        features: FAN_FEATURES.free,
      };
    }

    const passData = passDoc.data()!;
    const features = FAN_FEATURES[passData.passType as keyof typeof FAN_FEATURES] || FAN_FEATURES.free;

    return {
      hasPass: passData.status === 'active',
      passType: passData.passType,
      purchasedAt: passData.purchasedAt?.toDate?.() || null,
      features,
    };
  } catch (error) {
    functions.logger.error('Error getting fan pass status:', error);
    throw new functions.https.HttpsError('internal', 'Failed to get pass status');
  }
});

// ============================================================================
// VENUE PREMIUM PURCHASE FUNCTIONS
// ============================================================================

/**
 * Create checkout session for Venue Premium purchase
 */
export const createVenuePremiumCheckout = functions.https.onCall(async (data: any, context: any) => {
  if (!context?.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
  }

  const venueId = data.venueId;
  const venueName = data.venueName || 'Venue';

  if (!venueId) {
    throw new functions.https.HttpsError('invalid-argument', 'Venue ID is required');
  }

  const userId = context.auth.uid;
  const userEmail = context.auth.token.email || '';

  try {
    // Check if venue already has premium
    const venueEnhancement = await db.collection('venue_enhancements').doc(venueId).get();
    if (venueEnhancement.exists) {
      const data = venueEnhancement.data();
      if (data?.subscriptionTier === 'premium') {
        throw new functions.https.HttpsError(
          'already-exists',
          'This venue already has Premium access'
        );
      }
    }

    // Get or create Stripe customer
    let customerId: string;
    const customerQuery = await db.collection('stripe_customers')
      .where('userId', '==', userId)
      .limit(1)
      .get();

    if (customerQuery.empty) {
      const customer = await stripe.customers.create({
        email: userEmail,
        metadata: {
          userId,
          type: 'venue_owner',
        },
      });
      customerId = customer.id;

      await db.collection('stripe_customers').add({
        userId,
        customerId,
        email: userEmail,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    } else {
      customerId = customerQuery.docs[0].data().customerId;
    }

    // Create checkout session
    const session = await stripe.checkout.sessions.create({
      customer: customerId,
      payment_method_types: ['card'],
      mode: 'payment', // One-time payment
      line_items: [
        {
          price: WORLD_CUP_PRICES.VENUE_PREMIUM,
          quantity: 1,
        },
      ],
      success_url: `${data.successUrl || 'https://pregame-b089e.web.app/venue/purchase/success'}?session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: data.cancelUrl || 'https://pregame-b089e.web.app/venue/purchase/cancel',
      metadata: {
        type: 'venue_premium',
        venueId,
        venueName,
        userId,
      },
    });

    functions.logger.info(`Venue premium checkout created: ${session.id} for venue ${venueId}`);

    return {
      sessionId: session.id,
      url: session.url,
    };
  } catch (error: any) {
    functions.logger.error('Error creating venue premium checkout:', error);
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    throw new functions.https.HttpsError('internal', 'Failed to create checkout session');
  }
});

/**
 * Get venue premium status
 */
export const getVenuePremiumStatus = functions.https.onCall(async (data: any, context: any) => {
  if (!context?.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
  }

  const venueId = data.venueId;
  if (!venueId) {
    throw new functions.https.HttpsError('invalid-argument', 'Venue ID is required');
  }

  try {
    const venueDoc = await db.collection('venue_enhancements').doc(venueId).get();

    if (!venueDoc.exists) {
      return {
        isPremium: false,
        tier: 'free',
        features: VENUE_FEATURES.free,
      };
    }

    const venueData = venueDoc.data()!;
    const isPremium = venueData.subscriptionTier === 'premium';

    return {
      isPremium,
      tier: venueData.subscriptionTier || 'free',
      features: isPremium ? VENUE_FEATURES.premium : VENUE_FEATURES.free,
      purchasedAt: venueData.premiumPurchasedAt?.toDate?.() || null,
    };
  } catch (error) {
    functions.logger.error('Error getting venue premium status:', error);
    throw new functions.https.HttpsError('internal', 'Failed to get venue status');
  }
});

// ============================================================================
// WEBHOOK HANDLER
// ============================================================================

/**
 * Handle Stripe webhooks for World Cup payments
 */
export const handleWorldCupPaymentWebhook = functions.https.onRequest(async (req, res) => {
  const sig = req.headers['stripe-signature'] as string;
  // SECURITY: Require a properly configured webhook secret - never fall back to insecure defaults
  const webhookSecret = functions.config().stripe?.wc_webhook_secret ||
                        process.env.STRIPE_WC_WEBHOOK_SECRET;

  if (!webhookSecret) {
    functions.logger.error('World Cup webhook secret is not configured. Set stripe.wc_webhook_secret in Firebase config or STRIPE_WC_WEBHOOK_SECRET env var.');
    res.status(500).send('Webhook secret not configured');
    return;
  }

  let event: Stripe.Event;

  try {
    event = stripe.webhooks.constructEvent(req.rawBody, sig, webhookSecret);
  } catch (err: any) {
    functions.logger.error('Webhook signature verification failed:', err.message);
    res.status(400).send(`Webhook Error: ${err.message}`);
    return;
  }

  try {
    // Idempotency: Skip events that have already been processed
    if (await isWebhookEventAlreadyProcessed(event.id)) {
      functions.logger.info(`Webhook event ${event.id} already processed, skipping`);
      res.status(200).json({ received: true, duplicate: true });
      return;
    }

    switch (event.type) {
      case 'checkout.session.completed':
        await handleCheckoutComplete(event.data.object as Stripe.Checkout.Session);
        break;

      case 'payment_intent.succeeded':
        functions.logger.info('Payment intent succeeded:', (event.data.object as Stripe.PaymentIntent).id);
        break;

      case 'payment_intent.payment_failed':
        await handlePaymentFailed(event.data.object as Stripe.PaymentIntent);
        break;

      default:
        functions.logger.info(`Unhandled event type: ${event.type}`);
    }

    // Mark event as processed after successful handling
    await markWebhookEventProcessed(event.id, event.type);

    res.status(200).json({ received: true });
  } catch (error) {
    functions.logger.error('Error processing webhook:', error);
    res.status(500).send('Webhook processing failed');
  }
});

/**
 * Handle successful checkout completion
 */
async function handleCheckoutComplete(session: Stripe.Checkout.Session) {
  const metadata = session.metadata || {};
  const paymentType = metadata.type;

  functions.logger.info(`Checkout completed: ${session.id}, type: ${paymentType}`);

  // Idempotency: Check if this specific checkout session has already been processed
  const sessionRef = db.collection('processed_checkout_sessions').doc(session.id);
  const sessionDoc = await sessionRef.get();
  if (sessionDoc.exists) {
    functions.logger.info(`Checkout session ${session.id} already processed, skipping`);
    return;
  }

  if (paymentType === 'fan_pass') {
    await activateFanPass(metadata);
  } else if (paymentType === 'venue_premium') {
    await activateVenuePremium(metadata);
  }

  // Mark this checkout session as processed
  await sessionRef.set({
    sessionId: session.id,
    paymentType,
    processedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

/**
 * Activate fan pass after successful payment
 */
async function activateFanPass(metadata: Record<string, string>) {
  const userId = metadata.userId;
  const passType = metadata.passType;

  if (!userId || !passType) {
    functions.logger.error('Missing metadata for fan pass activation');
    return;
  }

  const features = FAN_FEATURES[passType as keyof typeof FAN_FEATURES] || FAN_FEATURES.fan_pass;

  // Use a batch write to ensure atomicity - either all writes succeed or none do
  const batch = db.batch();

  const passRef = db.collection('world_cup_fan_passes').doc(userId);
  batch.set(passRef, {
    userId,
    passType,
    status: 'active',
    features,
    purchasedAt: admin.firestore.FieldValue.serverTimestamp(),
    validFrom: TOURNAMENT_START,
    validUntil: TOURNAMENT_END,
  });

  // Also update user profile if exists
  const userRef = db.collection('users').doc(userId);
  const userDoc = await userRef.get();
  if (userDoc.exists) {
    batch.update(userRef, {
      worldCupPass: passType,
      worldCupPassPurchasedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }

  await batch.commit();

  functions.logger.info(`Fan pass activated: ${passType} for user ${userId}`);
}

/**
 * Activate venue premium after successful payment
 */
async function activateVenuePremium(metadata: Record<string, string>) {
  const venueId = metadata.venueId;
  const userId = metadata.userId;

  if (!venueId || !userId) {
    functions.logger.error('Missing metadata for venue premium activation');
    return;
  }

  const venueRef = db.collection('venue_enhancements').doc(venueId);
  const venueDoc = await venueRef.get();

  if (venueDoc.exists) {
    // Update existing venue
    await venueRef.update({
      subscriptionTier: 'premium',
      premiumPurchasedAt: admin.firestore.FieldValue.serverTimestamp(),
      premiumValidUntil: TOURNAMENT_END,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  } else {
    // Create new venue enhancement
    await venueRef.set({
      venueId,
      ownerId: userId,
      subscriptionTier: 'premium',
      showsMatches: true,
      premiumPurchasedAt: admin.firestore.FieldValue.serverTimestamp(),
      premiumValidUntil: TOURNAMENT_END,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }

  // Record purchase
  await db.collection('world_cup_venue_purchases').add({
    venueId,
    userId,
    type: 'premium',
    status: 'completed',
    purchasedAt: admin.firestore.FieldValue.serverTimestamp(),
    validUntil: TOURNAMENT_END,
  });

  functions.logger.info(`Venue premium activated for venue ${venueId}`);
}

/**
 * Handle failed payment
 */
async function handlePaymentFailed(paymentIntent: Stripe.PaymentIntent) {
  const metadata = paymentIntent.metadata || {};

  functions.logger.warn(`Payment failed: ${paymentIntent.id}`, {
    type: metadata.type,
    userId: metadata.userId,
    error: paymentIntent.last_payment_error?.message,
  });

  // Could send notification to user here
}

// ============================================================================
// UTILITY FUNCTIONS
// ============================================================================

/**
 * Check if a user has an active fan pass (callable from client)
 */
export const checkFanPassAccess = functions.https.onCall(async (data: any, context: any) => {
  if (!context?.auth) {
    return { hasAccess: false, tier: 'free' };
  }

  const userId = context.auth.uid;
  const featureRequested = data.feature;

  try {
    const passDoc = await db.collection('world_cup_fan_passes').doc(userId).get();

    if (!passDoc.exists) {
      return {
        hasAccess: !featureRequested || FAN_FEATURES.free[featureRequested as keyof typeof FAN_FEATURES.free] === true,
        tier: 'free',
      };
    }

    const passData = passDoc.data()!;
    const features = FAN_FEATURES[passData.passType as keyof typeof FAN_FEATURES] || FAN_FEATURES.free;

    return {
      hasAccess: !featureRequested || features[featureRequested as keyof typeof features] === true,
      tier: passData.passType,
    };
  } catch (error) {
    functions.logger.error('Error checking fan pass access:', error);
    return { hasAccess: false, tier: 'free' };
  }
});

/**
 * Get pricing info for display
 */
export const getWorldCupPricing = functions.https.onCall(async () => {
  return {
    fanPass: {
      priceId: WORLD_CUP_PRICES.FAN_PASS,
      amount: PRICE_AMOUNTS.FAN_PASS,
      displayPrice: '$14.99',
      name: 'Fan Pass',
      description: 'Ad-free experience, advanced stats, custom alerts, social features',
    },
    superfanPass: {
      priceId: WORLD_CUP_PRICES.SUPERFAN_PASS,
      amount: PRICE_AMOUNTS.SUPERFAN_PASS,
      displayPrice: '$29.99',
      name: 'Superfan Pass',
      description: 'Everything in Fan Pass + exclusive content, AI insights, priority features',
    },
    venuePremium: {
      priceId: WORLD_CUP_PRICES.VENUE_PREMIUM,
      amount: PRICE_AMOUNTS.VENUE_PREMIUM,
      displayPrice: '$99.00',
      name: 'Venue Premium',
      description: 'Full portal access: TV setup, specials, atmosphere, featured listing',
    },
    tournamentDates: {
      start: TOURNAMENT_START.toISOString(),
      end: TOURNAMENT_END.toISOString(),
    },
  };
});

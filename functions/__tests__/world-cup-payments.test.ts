/**
 * World Cup Payments Tests
 *
 * Comprehensive integration tests for Fan Pass, Venue Premium, webhook,
 * access-check, and pricing functions defined in world-cup-payments.ts.
 *
 * Every exported Cloud Function is exercised through the mock layer so that
 * Firestore reads/writes and Stripe API calls are verified end-to-end.
 */

import {
  MockFirestore,
  MockTimestamp,
  MockFieldValue,
  MockWriteBatch,
  createMockCallableContext,
  createMockHttpRequest,
  createMockHttpResponse,
  createTestFanPass,
  createTestVenueEnhancement,
  mockStripe,
} from './mocks';

// ---------------------------------------------------------------------------
// Module-level mocks (must be declared before any `import` of source files)
// ---------------------------------------------------------------------------

const mockFirestore = new MockFirestore();

jest.mock('firebase-admin', () => ({
  initializeApp: jest.fn(),
  app: jest.fn(() => ({ name: '[DEFAULT]', options: { projectId: 'test-project' } })),
  firestore: jest.fn(() => mockFirestore),
  messaging: jest.fn(() => ({ send: jest.fn().mockResolvedValue('mock-message-id') })),
  credential: { cert: jest.fn(), applicationDefault: jest.fn() },
}));

jest.mock('stripe', () => {
  return jest.fn().mockImplementation(() => mockStripe);
});

// Import admin so we can attach FieldValue / Timestamp to the mock
import * as admin from 'firebase-admin';

(admin.firestore as any).FieldValue = MockFieldValue;
(admin.firestore as any).Timestamp = MockTimestamp;

// Now import the functions under test
import {
  createFanPassCheckout,
  getFanPassStatus,
  createVenuePremiumCheckout,
  getVenuePremiumStatus,
  handleWorldCupPaymentWebhook,
  checkFanPassAccess,
  getWorldCupPricing,
} from '../src/world-cup-payments';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/** Convenience wrapper: invokes an `onCall` handler with data + context. */
const callFunction = (fn: any, data: any, context: any) => fn(data, context);

/** Convenience: build an authenticated context. */
const authedContext = (uid = 'test-user-id', email = 'test@example.com') =>
  createMockCallableContext({ auth: { uid, token: { email } } });

/** Convenience: build an unauthenticated context. */
const unauthContext = () => createMockCallableContext({ auth: null });

// ---------------------------------------------------------------------------
// Test suite
// ---------------------------------------------------------------------------

describe('World Cup Payments', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockFirestore.clearAllData();
    mockStripe.reset();
  });

  // =========================================================================
  // createFanPassCheckout
  // =========================================================================

  describe('createFanPassCheckout', () => {
    it('should create a checkout session for a valid fan_pass type', async () => {
      // No existing pass, no existing Stripe customer
      mockFirestore.setTestData('world_cup_fan_passes', new Map());
      mockFirestore.setTestData('stripe_customers', new Map());

      const result = await callFunction(
        createFanPassCheckout,
        { passType: 'fan_pass' },
        authedContext(),
      );

      expect(result.sessionId).toBeDefined();
      expect(result.url).toBeDefined();
      // Stripe customer should have been created (no prior customer)
      expect(mockStripe.customers.create).toHaveBeenCalledTimes(1);
      // Checkout session should have been created in payment mode
      expect(mockStripe.checkout.sessions.create).toHaveBeenCalledTimes(1);
      const sessionArgs = mockStripe.checkout.sessions.create.mock.calls[0][0];
      expect(sessionArgs.mode).toBe('payment');
      expect(sessionArgs.metadata.passType).toBe('fan_pass');
      expect(sessionArgs.metadata.type).toBe('fan_pass');
    });

    it('should create a checkout session for a valid superfan_pass type', async () => {
      mockFirestore.setTestData('world_cup_fan_passes', new Map());
      mockFirestore.setTestData('stripe_customers', new Map());

      const result = await callFunction(
        createFanPassCheckout,
        { passType: 'superfan_pass' },
        authedContext(),
      );

      expect(result.sessionId).toBeDefined();
      const sessionArgs = mockStripe.checkout.sessions.create.mock.calls[0][0];
      expect(sessionArgs.metadata.passType).toBe('superfan_pass');
    });

    it('should reject an invalid pass type', async () => {
      await expect(
        callFunction(createFanPassCheckout, { passType: 'invalid_type' }, authedContext()),
      ).rejects.toThrow(/Invalid pass type/);
    });

    it('should reject unauthenticated requests', async () => {
      await expect(
        callFunction(createFanPassCheckout, { passType: 'fan_pass' }, unauthContext()),
      ).rejects.toThrow(/Must be logged in/);
    });

    it('should reject when user already has an active pass', async () => {
      const userId = 'test-user-id';
      const passes = new Map<string, any>();
      passes.set(userId, { status: 'active', passType: 'fan_pass' });
      mockFirestore.setTestData('world_cup_fan_passes', passes);
      mockFirestore.setTestData('stripe_customers', new Map());

      await expect(
        callFunction(createFanPassCheckout, { passType: 'fan_pass' }, authedContext(userId)),
      ).rejects.toThrow(/already have an active/);
    });

    it('should create a new Stripe customer when none exists', async () => {
      mockFirestore.setTestData('world_cup_fan_passes', new Map());
      mockFirestore.setTestData('stripe_customers', new Map());

      await callFunction(createFanPassCheckout, { passType: 'fan_pass' }, authedContext());

      expect(mockStripe.customers.create).toHaveBeenCalledTimes(1);
      expect(mockStripe.customers.create).toHaveBeenCalledWith(
        expect.objectContaining({
          email: 'test@example.com',
          metadata: expect.objectContaining({ userId: 'test-user-id', type: 'fan' }),
        }),
      );
    });

    it('should use an existing Stripe customer when one exists', async () => {
      const userId = 'test-user-id';
      const customers = new Map<string, any>();
      customers.set('cust-doc-1', { userId, customerId: 'cus_existing_123' });
      mockFirestore.setTestData('stripe_customers', customers);
      mockFirestore.setTestData('world_cup_fan_passes', new Map());

      await callFunction(createFanPassCheckout, { passType: 'fan_pass' }, authedContext(userId));

      // Should NOT create a new customer
      expect(mockStripe.customers.create).not.toHaveBeenCalled();
      // Session should use the existing customer id
      const sessionArgs = mockStripe.checkout.sessions.create.mock.calls[0][0];
      expect(sessionArgs.customer).toBe('cus_existing_123');
    });
  });

  // =========================================================================
  // getFanPassStatus
  // =========================================================================

  describe('getFanPassStatus', () => {
    it('should return active pass details for a user with a pass', async () => {
      const userId = 'user-with-pass';
      const passes = new Map<string, any>();
      passes.set(userId, {
        passType: 'superfan_pass',
        status: 'active',
        purchasedAt: { toDate: () => new Date('2026-06-01') },
      });
      mockFirestore.setTestData('world_cup_fan_passes', passes);

      const result = await callFunction(getFanPassStatus, {}, authedContext(userId));

      expect(result.hasPass).toBe(true);
      expect(result.passType).toBe('superfan_pass');
      expect(result.features).toBeDefined();
      expect(result.features.exclusiveContent).toBe(true);
      expect(result.features.adFree).toBe(true);
    });

    it('should return free tier when user has no pass', async () => {
      mockFirestore.setTestData('world_cup_fan_passes', new Map());

      const result = await callFunction(getFanPassStatus, {}, authedContext('no-pass-user'));

      expect(result.hasPass).toBe(false);
      expect(result.passType).toBe('free');
      expect(result.features.adFree).toBe(false);
      expect(result.features.basicSchedules).toBe(true);
    });

    it('should reject unauthenticated requests', async () => {
      await expect(
        callFunction(getFanPassStatus, {}, unauthContext()),
      ).rejects.toThrow(/Must be logged in/);
    });
  });

  // =========================================================================
  // createVenuePremiumCheckout
  // =========================================================================

  describe('createVenuePremiumCheckout', () => {
    it('should create a valid checkout session', async () => {
      mockFirestore.setTestData('venue_enhancements', new Map());
      mockFirestore.setTestData('stripe_customers', new Map());

      const result = await callFunction(
        createVenuePremiumCheckout,
        { venueId: 'venue-1', venueName: 'Best Sports Bar' },
        authedContext(),
      );

      expect(result.sessionId).toBeDefined();
      expect(result.url).toBeDefined();
      const sessionArgs = mockStripe.checkout.sessions.create.mock.calls[0][0];
      expect(sessionArgs.metadata.type).toBe('venue_premium');
      expect(sessionArgs.metadata.venueId).toBe('venue-1');
      expect(sessionArgs.mode).toBe('payment');
    });

    it('should reject when venueId is missing', async () => {
      await expect(
        callFunction(createVenuePremiumCheckout, { venueName: 'No ID' }, authedContext()),
      ).rejects.toThrow(/Venue ID is required/);
    });

    it('should reject when venue already has premium', async () => {
      const enhancements = new Map<string, any>();
      enhancements.set('venue-premium', { subscriptionTier: 'premium' });
      mockFirestore.setTestData('venue_enhancements', enhancements);
      mockFirestore.setTestData('stripe_customers', new Map());

      await expect(
        callFunction(
          createVenuePremiumCheckout,
          { venueId: 'venue-premium', venueName: 'Already Premium' },
          authedContext(),
        ),
      ).rejects.toThrow(/already has Premium/);
    });

    it('should reject unauthenticated requests', async () => {
      await expect(
        callFunction(
          createVenuePremiumCheckout,
          { venueId: 'v-1', venueName: 'Test' },
          unauthContext(),
        ),
      ).rejects.toThrow(/Must be logged in/);
    });
  });

  // =========================================================================
  // getVenuePremiumStatus
  // =========================================================================

  describe('getVenuePremiumStatus', () => {
    it('should return premium status for a premium venue', async () => {
      const enhancements = new Map<string, any>();
      enhancements.set('venue-p', {
        subscriptionTier: 'premium',
        premiumPurchasedAt: { toDate: () => new Date('2026-06-01') },
      });
      mockFirestore.setTestData('venue_enhancements', enhancements);

      const result = await callFunction(
        getVenuePremiumStatus,
        { venueId: 'venue-p' },
        authedContext(),
      );

      expect(result.isPremium).toBe(true);
      expect(result.tier).toBe('premium');
      expect(result.features.tvSetup).toBe(true);
      expect(result.features.analytics).toBe(true);
    });

    it('should return free when venue has no premium', async () => {
      mockFirestore.setTestData('venue_enhancements', new Map());

      const result = await callFunction(
        getVenuePremiumStatus,
        { venueId: 'venue-free' },
        authedContext(),
      );

      expect(result.isPremium).toBe(false);
      expect(result.tier).toBe('free');
      expect(result.features.tvSetup).toBe(false);
    });

    it('should reject when venueId is missing', async () => {
      await expect(
        callFunction(getVenuePremiumStatus, {}, authedContext()),
      ).rejects.toThrow(/Venue ID is required/);
    });

    it('should reject unauthenticated requests', async () => {
      await expect(
        callFunction(getVenuePremiumStatus, { venueId: 'v-1' }, unauthContext()),
      ).rejects.toThrow(/Must be logged in/);
    });
  });

  // =========================================================================
  // handleWorldCupPaymentWebhook
  // =========================================================================

  describe('handleWorldCupPaymentWebhook', () => {
    const buildReq = (body: any, signature = 'valid_sig') =>
      createMockHttpRequest({
        method: 'POST',
        headers: { 'stripe-signature': signature },
        body,
        rawBody: Buffer.from(JSON.stringify(body)),
      });

    it('should accept a valid webhook signature and respond 200', async () => {
      const body = {
        type: 'payment_intent.succeeded',
        data: { object: { id: 'pi_test', metadata: {} } },
      };
      const req = buildReq(body);
      const res = createMockHttpResponse();

      // processed_webhook_events empty => not a duplicate
      mockFirestore.setTestData('processed_webhook_events', new Map());
      mockFirestore.setTestData('processed_checkout_sessions', new Map());

      await handleWorldCupPaymentWebhook(req as any, res as any);

      expect(mockStripe.webhooks.constructEvent).toHaveBeenCalledTimes(1);
      expect(res._statusCode).toBe(200);
    });

    it('should return 400 when signature verification fails', async () => {
      // Make constructEvent throw
      mockStripe.webhooks.constructEvent.mockImplementationOnce(() => {
        throw new Error('Signature verification failed');
      });

      const req = buildReq({ type: 'test' }, 'bad_sig');
      const res = createMockHttpResponse();

      await handleWorldCupPaymentWebhook(req as any, res as any);

      expect(res._statusCode).toBe(400);
    });

    it('should return 500 when webhook secret is not configured', async () => {
      // Temporarily override env var and functions.config
      const origEnv = process.env.STRIPE_WC_WEBHOOK_SECRET;
      delete process.env.STRIPE_WC_WEBHOOK_SECRET;

      // Also override functions.config
      const functions = require('firebase-functions');
      const origConfig = functions.config;
      functions.config = jest.fn(() => ({ stripe: {} }));

      const req = buildReq({ type: 'test' });
      const res = createMockHttpResponse();

      await handleWorldCupPaymentWebhook(req as any, res as any);

      expect(res._statusCode).toBe(500);
      expect(res._body).toContain('Webhook secret not configured');

      // Restore
      process.env.STRIPE_WC_WEBHOOK_SECRET = origEnv;
      functions.config = origConfig;
    });

    it('should activate a fan pass on checkout.session.completed with fan_pass metadata', async () => {
      const userId = 'user-activate';
      const body = {
        type: 'checkout.session.completed',
        data: {
          object: {
            id: 'cs_fan_test',
            metadata: { type: 'fan_pass', passType: 'superfan_pass', userId },
          },
        },
      };
      const req = buildReq(body);
      const res = createMockHttpResponse();

      mockFirestore.setTestData('processed_webhook_events', new Map());
      mockFirestore.setTestData('processed_checkout_sessions', new Map());
      mockFirestore.setTestData('world_cup_fan_passes', new Map());
      // user doc doesn't exist, that's fine -- the function handles it
      mockFirestore.setTestData('users', new Map());

      await handleWorldCupPaymentWebhook(req as any, res as any);

      expect(res._statusCode).toBe(200);

      // Verify fan pass was written
      const passDoc = await mockFirestore
        .collection('world_cup_fan_passes')
        .doc(userId)
        .get();
      expect(passDoc.exists).toBe(true);
      expect(passDoc.data()?.passType).toBe('superfan_pass');
      expect(passDoc.data()?.status).toBe('active');
    });

    it('should activate venue premium on checkout.session.completed with venue_premium metadata', async () => {
      const venueId = 'venue-activate';
      const userId = 'owner-1';
      const body = {
        type: 'checkout.session.completed',
        data: {
          object: {
            id: 'cs_venue_test',
            metadata: { type: 'venue_premium', venueId, userId },
          },
        },
      };
      const req = buildReq(body);
      const res = createMockHttpResponse();

      mockFirestore.setTestData('processed_webhook_events', new Map());
      mockFirestore.setTestData('processed_checkout_sessions', new Map());
      mockFirestore.setTestData('venue_enhancements', new Map());
      mockFirestore.setTestData('world_cup_venue_purchases', new Map());

      await handleWorldCupPaymentWebhook(req as any, res as any);

      expect(res._statusCode).toBe(200);

      // Verify venue enhancement was created
      const venueDoc = await mockFirestore
        .collection('venue_enhancements')
        .doc(venueId)
        .get();
      expect(venueDoc.exists).toBe(true);
      expect(venueDoc.data()?.subscriptionTier).toBe('premium');
    });

    it('should skip duplicate events (idempotency)', async () => {
      const eventId = 'evt_test_mock'; // default id returned by mock constructEvent
      const processed = new Map<string, any>();
      processed.set(eventId, { eventId, eventType: 'checkout.session.completed' });
      mockFirestore.setTestData('processed_webhook_events', processed);

      const body = {
        type: 'checkout.session.completed',
        data: { object: { id: 'cs_dup', metadata: {} } },
      };
      const req = buildReq(body);
      const res = createMockHttpResponse();

      await handleWorldCupPaymentWebhook(req as any, res as any);

      expect(res._statusCode).toBe(200);
      expect(res._body).toEqual({ received: true, duplicate: true });
    });

    it('should log payment_intent.payment_failed without crashing', async () => {
      const body = {
        type: 'payment_intent.payment_failed',
        data: {
          object: {
            id: 'pi_fail_test',
            status: 'failed',
            last_payment_error: { message: 'Card declined' },
            metadata: { type: 'fan_pass', userId: 'u-1' },
          },
        },
      };
      const req = buildReq(body);
      const res = createMockHttpResponse();

      mockFirestore.setTestData('processed_webhook_events', new Map());

      await handleWorldCupPaymentWebhook(req as any, res as any);

      expect(res._statusCode).toBe(200);
    });
  });

  // =========================================================================
  // checkFanPassAccess
  // =========================================================================

  describe('checkFanPassAccess', () => {
    it('should return access for a user with an active pass', async () => {
      const userId = 'pass-holder';
      const passes = new Map<string, any>();
      passes.set(userId, { passType: 'fan_pass', status: 'active' });
      mockFirestore.setTestData('world_cup_fan_passes', passes);

      const result = await callFunction(
        checkFanPassAccess,
        { feature: 'adFree' },
        authedContext(userId),
      );

      expect(result.hasAccess).toBe(true);
      expect(result.tier).toBe('fan_pass');
    });

    it('should deny premium feature access for free-tier user', async () => {
      mockFirestore.setTestData('world_cup_fan_passes', new Map());

      const result = await callFunction(
        checkFanPassAccess,
        { feature: 'exclusiveContent' },
        authedContext('free-user'),
      );

      expect(result.hasAccess).toBe(false);
      expect(result.tier).toBe('free');
    });

    it('should return free tier for unauthenticated user without throwing', async () => {
      const result = await callFunction(checkFanPassAccess, {}, unauthContext());

      expect(result.hasAccess).toBe(false);
      expect(result.tier).toBe('free');
    });

    it('should grant access when no specific feature is requested and user has a pass', async () => {
      const userId = 'pass-holder-2';
      const passes = new Map<string, any>();
      passes.set(userId, { passType: 'superfan_pass', status: 'active' });
      mockFirestore.setTestData('world_cup_fan_passes', passes);

      const result = await callFunction(
        checkFanPassAccess,
        {},
        authedContext(userId),
      );

      expect(result.hasAccess).toBe(true);
      expect(result.tier).toBe('superfan_pass');
    });

    it('should correctly check superfan-only features for fan_pass holders', async () => {
      const userId = 'fan-pass-holder';
      const passes = new Map<string, any>();
      passes.set(userId, { passType: 'fan_pass', status: 'active' });
      mockFirestore.setTestData('world_cup_fan_passes', passes);

      const result = await callFunction(
        checkFanPassAccess,
        { feature: 'exclusiveContent' },
        authedContext(userId),
      );

      // fan_pass does NOT include exclusiveContent
      expect(result.hasAccess).toBe(false);
      expect(result.tier).toBe('fan_pass');
    });
  });

  // =========================================================================
  // getWorldCupPricing
  // =========================================================================

  describe('getWorldCupPricing', () => {
    it('should return correct prices and names', async () => {
      const result = await callFunction(getWorldCupPricing, {}, {});

      expect(result.fanPass.amount).toBe(1499);
      expect(result.fanPass.displayPrice).toBe('$14.99');
      expect(result.fanPass.name).toBe('Fan Pass');

      expect(result.superfanPass.amount).toBe(2999);
      expect(result.superfanPass.displayPrice).toBe('$29.99');
      expect(result.superfanPass.name).toBe('Superfan Pass');

      expect(result.venuePremium.amount).toBe(49900);
      expect(result.venuePremium.displayPrice).toBe('$499.00');
      expect(result.venuePremium.name).toBe('Venue Premium');
    });

    it('should return tournament dates', async () => {
      const result = await callFunction(getWorldCupPricing, {}, {});

      expect(result.tournamentDates.start).toContain('2026-06-11');
      expect(result.tournamentDates.end).toContain('2026-07-20');
    });

    it('should include price IDs from environment variables', async () => {
      const result = await callFunction(getWorldCupPricing, {}, {});

      expect(result.fanPass.priceId).toBeDefined();
      expect(result.superfanPass.priceId).toBeDefined();
      expect(result.venuePremium.priceId).toBeDefined();
    });
  });

  // =========================================================================
  // Feature tier verification
  // =========================================================================

  describe('Feature tier definitions', () => {
    it('should ensure free tier has no paid features enabled', async () => {
      mockFirestore.setTestData('world_cup_fan_passes', new Map());
      const result = await callFunction(getFanPassStatus, {}, authedContext('free'));

      const features = result.features;
      expect(features.adFree).toBe(false);
      expect(features.advancedStats).toBe(false);
      expect(features.customAlerts).toBe(false);
      expect(features.exclusiveContent).toBe(false);
      expect(features.aiMatchInsights).toBe(false);
    });

    it('should ensure fan_pass tier unlocks mid-level features but not superfan', async () => {
      const passes = new Map<string, any>();
      passes.set('fp-user', { passType: 'fan_pass', status: 'active' });
      mockFirestore.setTestData('world_cup_fan_passes', passes);

      const result = await callFunction(getFanPassStatus, {}, authedContext('fp-user'));

      expect(result.features.adFree).toBe(true);
      expect(result.features.advancedStats).toBe(true);
      expect(result.features.exclusiveContent).toBe(false);
      expect(result.features.priorityFeatures).toBe(false);
    });

    it('should ensure superfan_pass tier unlocks all features', async () => {
      const passes = new Map<string, any>();
      passes.set('sf-user', { passType: 'superfan_pass', status: 'active' });
      mockFirestore.setTestData('world_cup_fan_passes', passes);

      const result = await callFunction(getFanPassStatus, {}, authedContext('sf-user'));

      expect(result.features.adFree).toBe(true);
      expect(result.features.exclusiveContent).toBe(true);
      expect(result.features.aiMatchInsights).toBe(true);
      expect(result.features.downloadableContent).toBe(true);
    });
  });
});

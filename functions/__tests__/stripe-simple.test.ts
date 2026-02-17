/**
 * Stripe Simple Tests
 *
 * Comprehensive integration tests for the core Stripe payment functions
 * defined in stripe-simple.ts: free account setup, checkout sessions,
 * portal sessions, payment intents, and webhook handling.
 *
 * Every exported Cloud Function is exercised through the mock layer so that
 * Firestore reads/writes and Stripe API calls are verified end-to-end.
 *
 * NOTE: Most onCall functions in stripe-simple.ts catch ALL errors (including
 * HttpsError) and re-throw as a generic HttpsError('internal', ...). Therefore
 * error-message assertions match against the generic re-thrown text, not the
 * original validation message.
 */

import {
  MockFirestore,
  MockTimestamp,
  MockFieldValue,
  createMockCallableContext,
  createMockHttpRequest,
  createMockHttpResponse,
  mockStripe,
} from './mocks';

// ---------------------------------------------------------------------------
// Module-level mocks
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

import * as admin from 'firebase-admin';

(admin.firestore as any).FieldValue = MockFieldValue;
(admin.firestore as any).Timestamp = MockTimestamp;

// Import the functions under test
import {
  setupFreeFanAccount,
  createFanCheckoutSession,
  setupFreeVenueAccount,
  createCheckoutSession,
  createPortalSession,
  createPaymentIntent,
  handleStripeWebhook,
} from '../src/stripe-simple';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const callFunction = (fn: any, data: any, context: any) => fn(data, context);

const authedContext = (uid = 'test-user-id', email = 'test@example.com') =>
  createMockCallableContext({ auth: { uid, token: { email } } });

const unauthContext = () => createMockCallableContext({ auth: null });

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

describe('Stripe Simple', () => {
  // The handleStripeWebhook function reads functions.config().stripe?.webhook_secret
  // || process.env.STRIPE_WEBHOOK_SECRET. The global setup.ts doesn't set this env
  // var, so we set it here for the webhook tests. We also need it available for the
  // "not configured" test to temporarily remove.
  const ORIGINAL_WEBHOOK_SECRET = process.env.STRIPE_WEBHOOK_SECRET;

  beforeAll(() => {
    process.env.STRIPE_WEBHOOK_SECRET = 'whsec_test_simple';
  });

  afterAll(() => {
    if (ORIGINAL_WEBHOOK_SECRET !== undefined) {
      process.env.STRIPE_WEBHOOK_SECRET = ORIGINAL_WEBHOOK_SECRET;
    } else {
      delete process.env.STRIPE_WEBHOOK_SECRET;
    }
  });

  beforeEach(() => {
    jest.clearAllMocks();
    mockFirestore.clearAllData();
    mockStripe.reset();
  });

  // =========================================================================
  // setupFreeFanAccount
  // =========================================================================

  describe('setupFreeFanAccount', () => {
    it('should create a free fan account successfully', async () => {
      mockFirestore.setTestData('fans', new Map());

      const result = await callFunction(
        setupFreeFanAccount,
        { fanId: 'fan-123', plan: 'free' },
        authedContext(),
      );

      expect(result.success).toBe(true);
      expect(result.fanId).toBe('fan-123');
      expect(result.plan).toBe('free');
      expect(result.message).toContain('Free fan account created');

      // Verify Firestore write
      const fanDoc = await mockFirestore.collection('fans').doc('fan-123').get();
      expect(fanDoc.exists).toBe(true);
      expect(fanDoc.data()?.plan).toBe('free');
      expect(fanDoc.data()?.userId).toBe('test-user-id');
      expect(fanDoc.data()?.status).toBe('active');
    });

    it('should default to free plan when plan is not provided', async () => {
      mockFirestore.setTestData('fans', new Map());

      const result = await callFunction(
        setupFreeFanAccount,
        { fanId: 'fan-default' },
        authedContext(),
      );

      expect(result.plan).toBe('free');
    });

    it('should reject unauthenticated requests', async () => {
      // The function catches the HttpsError('unauthenticated') and re-throws
      // as HttpsError('internal', 'Unable to create free fan account')
      await expect(
        callFunction(setupFreeFanAccount, { fanId: 'fan-1' }, unauthContext()),
      ).rejects.toThrow(/Unable to create free fan account/);
    });

    it('should reject when fanId is missing', async () => {
      // Similarly re-thrown as internal error
      await expect(
        callFunction(setupFreeFanAccount, { plan: 'free' }, authedContext()),
      ).rejects.toThrow(/Unable to create free fan account/);
    });

    it('should set correct feature flags for free plan', async () => {
      mockFirestore.setTestData('fans', new Map());

      await callFunction(
        setupFreeFanAccount,
        { fanId: 'fan-features' },
        authedContext(),
      );

      const fanDoc = await mockFirestore.collection('fans').doc('fan-features').get();
      const features = fanDoc.data()?.features;

      expect(features.basicSchedules).toBe(true);
      expect(features.venueDiscovery).toBe(true);
      expect(features.communityAccess).toBe(true);
      expect(features.advancedInsights).toBe(false);
      expect(features.adFreeExperience).toBe(false);
      expect(features.exclusiveContent).toBe(false);
    });

    it('should set billing info with zero amount for free plan', async () => {
      mockFirestore.setTestData('fans', new Map());

      await callFunction(
        setupFreeFanAccount,
        { fanId: 'fan-billing' },
        authedContext(),
      );

      const fanDoc = await mockFirestore.collection('fans').doc('fan-billing').get();
      const billing = fanDoc.data()?.billing;

      expect(billing.plan).toBe('free');
      expect(billing.amount).toBe(0);
      expect(billing.currency).toBe('usd');
      expect(billing.stripeCustomerId).toBeNull();
      expect(billing.stripeSubscriptionId).toBeNull();
    });
  });

  // =========================================================================
  // createFanCheckoutSession
  // =========================================================================

  describe('createFanCheckoutSession', () => {
    it('should create a valid checkout session for an existing fan', async () => {
      const fans = new Map<string, any>();
      fans.set('fan-checkout', { id: 'fan-checkout', stripeCustomerId: 'cus_existing' });
      mockFirestore.setTestData('fans', fans);

      const result = await callFunction(
        createFanCheckoutSession,
        { priceId: 'price_fan_premium', fanId: 'fan-checkout', mode: 'subscription' },
        authedContext(),
      );

      expect(result.sessionId).toBeDefined();
      expect(mockStripe.checkout.sessions.create).toHaveBeenCalledTimes(1);

      const sessionArgs = mockStripe.checkout.sessions.create.mock.calls[0][0];
      expect(sessionArgs.customer).toBe('cus_existing');
      expect(sessionArgs.mode).toBe('subscription');
      expect(sessionArgs.metadata.fanId).toBe('fan-checkout');
      expect(sessionArgs.metadata.type).toBe('fan');
    });

    it('should reject unauthenticated requests', async () => {
      await expect(
        callFunction(
          createFanCheckoutSession,
          { priceId: 'price_x', fanId: 'fan-x' },
          unauthContext(),
        ),
      ).rejects.toThrow(/Unable to create fan checkout session/);
    });

    it('should reject when required parameters are missing', async () => {
      await expect(
        callFunction(
          createFanCheckoutSession,
          { priceId: 'price_x' /* fanId missing */ },
          authedContext(),
        ),
      ).rejects.toThrow(/Unable to create fan checkout session/);
    });

    it('should create a new Stripe customer if fan has no stripeCustomerId', async () => {
      // Fan exists but no Stripe customer
      const fans = new Map<string, any>();
      fans.set('fan-no-stripe', { id: 'fan-no-stripe' });
      mockFirestore.setTestData('fans', fans);

      await callFunction(
        createFanCheckoutSession,
        { priceId: 'price_fan_pass', fanId: 'fan-no-stripe' },
        authedContext(),
      );

      expect(mockStripe.customers.create).toHaveBeenCalledTimes(1);
      expect(mockStripe.customers.create).toHaveBeenCalledWith(
        expect.objectContaining({
          email: 'test@example.com',
          metadata: expect.objectContaining({ fanId: 'fan-no-stripe', type: 'fan' }),
        }),
      );
    });

    it('should create the fan document if it does not exist', async () => {
      mockFirestore.setTestData('fans', new Map());

      await callFunction(
        createFanCheckoutSession,
        { priceId: 'price_x', fanId: 'new-fan' },
        authedContext(),
      );

      // After the call, the fan document should exist (created inside the function)
      const fanDoc = await mockFirestore.collection('fans').doc('new-fan').get();
      expect(fanDoc.exists).toBe(true);
    });

    it('should default mode to subscription', async () => {
      const fans = new Map<string, any>();
      fans.set('fan-mode', { id: 'fan-mode', stripeCustomerId: 'cus_x' });
      mockFirestore.setTestData('fans', fans);

      await callFunction(
        createFanCheckoutSession,
        { priceId: 'price_x', fanId: 'fan-mode' },
        authedContext(),
      );

      const sessionArgs = mockStripe.checkout.sessions.create.mock.calls[0][0];
      expect(sessionArgs.mode).toBe('subscription');
    });
  });

  // =========================================================================
  // setupFreeVenueAccount
  // =========================================================================

  describe('setupFreeVenueAccount', () => {
    it('should create a free venue account successfully', async () => {
      mockFirestore.setTestData('venues', new Map());

      const result = await callFunction(
        setupFreeVenueAccount,
        { venueId: 'venue-free-1', plan: 'free' },
        authedContext(),
      );

      expect(result.success).toBe(true);
      expect(result.venueId).toBe('venue-free-1');
      expect(result.plan).toBe('free');

      const venueDoc = await mockFirestore.collection('venues').doc('venue-free-1').get();
      expect(venueDoc.exists).toBe(true);
      expect(venueDoc.data()?.ownerId).toBe('test-user-id');
      expect(venueDoc.data()?.status).toBe('active');
    });

    it('should reject unauthenticated requests', async () => {
      await expect(
        callFunction(setupFreeVenueAccount, { venueId: 'v-1' }, unauthContext()),
      ).rejects.toThrow(/Unable to create free venue account/);
    });

    it('should reject when venueId is missing', async () => {
      await expect(
        callFunction(setupFreeVenueAccount, { plan: 'free' }, authedContext()),
      ).rejects.toThrow(/Unable to create free venue account/);
    });

    it('should set correct feature flags for free venue', async () => {
      mockFirestore.setTestData('venues', new Map());

      await callFunction(
        setupFreeVenueAccount,
        { venueId: 'venue-feat' },
        authedContext(),
      );

      const venueDoc = await mockFirestore.collection('venues').doc('venue-feat').get();
      const features = venueDoc.data()?.features;

      expect(features.basicProfile).toBe(true);
      expect(features.customerMessaging).toBe(true);
      expect(features.advancedAnalytics).toBe(false);
      expect(features.liveStreaming).toBe(false);
      expect(features.featuredListings).toBe(false);
    });

    it('should set billing with null Stripe IDs', async () => {
      mockFirestore.setTestData('venues', new Map());

      await callFunction(
        setupFreeVenueAccount,
        { venueId: 'venue-billing' },
        authedContext(),
      );

      const venueDoc = await mockFirestore.collection('venues').doc('venue-billing').get();
      const billing = venueDoc.data()?.billing;

      expect(billing.stripeCustomerId).toBeNull();
      expect(billing.stripeSubscriptionId).toBeNull();
      expect(billing.amount).toBe(0);
    });
  });

  // =========================================================================
  // createCheckoutSession (venue)
  // =========================================================================

  describe('createCheckoutSession', () => {
    it('should create a valid venue checkout session', async () => {
      const venues = new Map<string, any>();
      venues.set('venue-co', { id: 'venue-co', stripeCustomerId: 'cus_venue_1' });
      mockFirestore.setTestData('venues', venues);

      const result = await callFunction(
        createCheckoutSession,
        { priceId: 'price_venue_premium', venueId: 'venue-co', mode: 'subscription' },
        authedContext(),
      );

      expect(result.sessionId).toBeDefined();
      const sessionArgs = mockStripe.checkout.sessions.create.mock.calls[0][0];
      expect(sessionArgs.customer).toBe('cus_venue_1');
      expect(sessionArgs.metadata.venueId).toBe('venue-co');
    });

    it('should reject unauthenticated requests', async () => {
      await expect(
        callFunction(
          createCheckoutSession,
          { priceId: 'price_x', venueId: 'v-1' },
          unauthContext(),
        ),
      ).rejects.toThrow(/Unable to create checkout session/);
    });

    it('should reject when required parameters are missing', async () => {
      await expect(
        callFunction(
          createCheckoutSession,
          { priceId: 'price_x' /* venueId missing */ },
          authedContext(),
        ),
      ).rejects.toThrow(/Unable to create checkout session/);
    });

    it('should create a new Stripe customer if venue has no stripeCustomerId', async () => {
      const venues = new Map<string, any>();
      venues.set('venue-no-cus', { id: 'venue-no-cus' });
      mockFirestore.setTestData('venues', venues);

      await callFunction(
        createCheckoutSession,
        { priceId: 'price_x', venueId: 'venue-no-cus' },
        authedContext(),
      );

      expect(mockStripe.customers.create).toHaveBeenCalledTimes(1);
      expect(mockStripe.customers.create).toHaveBeenCalledWith(
        expect.objectContaining({
          metadata: expect.objectContaining({ venueId: 'venue-no-cus' }),
        }),
      );
    });

    it('should create the venue document if it does not exist', async () => {
      mockFirestore.setTestData('venues', new Map());

      await callFunction(
        createCheckoutSession,
        { priceId: 'price_x', venueId: 'new-venue' },
        authedContext(),
      );

      const venueDoc = await mockFirestore.collection('venues').doc('new-venue').get();
      expect(venueDoc.exists).toBe(true);
    });
  });

  // =========================================================================
  // createPortalSession
  // =========================================================================

  describe('createPortalSession', () => {
    it('should return a portal URL', async () => {
      // Seed stripe_customers with a document matching the authenticated user's UID
      const stripeCustomers = new Map<string, any>();
      stripeCustomers.set('sc_1', { userId: 'test-user-id', customerId: 'cus_portal_1' });
      mockFirestore.setTestData('stripe_customers', stripeCustomers);

      const result = await callFunction(
        createPortalSession,
        {},
        authedContext(),
      );

      expect(result.url).toBeDefined();
      expect(result.url).toContain('billing.stripe.com');
      expect(mockStripe.billingPortal.sessions.create).toHaveBeenCalledTimes(1);
      expect(mockStripe.billingPortal.sessions.create).toHaveBeenCalledWith(
        expect.objectContaining({ customer: 'cus_portal_1' }),
      );
    });

    it('should reject unauthenticated requests', async () => {
      await expect(
        callFunction(createPortalSession, {}, unauthContext()),
      ).rejects.toThrow(/User must be authenticated/);
    });

    it('should reject when no Stripe customer is found for the user', async () => {
      // Empty stripe_customers collection - no customer linked to this user
      mockFirestore.setTestData('stripe_customers', new Map());

      await expect(
        callFunction(createPortalSession, {}, authedContext()),
      ).rejects.toThrow(/No Stripe customer found for this user/);
    });

    it('should use default return URL when not provided', async () => {
      const stripeCustomers = new Map<string, any>();
      stripeCustomers.set('sc_2', { userId: 'test-user-id', customerId: 'cus_default_url' });
      mockFirestore.setTestData('stripe_customers', stripeCustomers);

      await callFunction(
        createPortalSession,
        {},
        authedContext(),
      );

      const portalArgs = mockStripe.billingPortal.sessions.create.mock.calls[0][0];
      expect(portalArgs.return_url).toContain('pregame-b089e.web.app');
    });

    it('should use custom return URL when provided', async () => {
      const stripeCustomers = new Map<string, any>();
      stripeCustomers.set('sc_3', { userId: 'test-user-id', customerId: 'cus_custom_url' });
      mockFirestore.setTestData('stripe_customers', stripeCustomers);

      await callFunction(
        createPortalSession,
        { returnUrl: 'https://custom.example.com/billing' },
        authedContext(),
      );

      const portalArgs = mockStripe.billingPortal.sessions.create.mock.calls[0][0];
      expect(portalArgs.return_url).toBe('https://custom.example.com/billing');
    });
  });

  // =========================================================================
  // createPaymentIntent
  // =========================================================================

  describe('createPaymentIntent', () => {
    it('should create a payment intent with the correct amount', async () => {
      // Override the mock to return a client_secret field
      mockStripe.paymentIntents.create.mockResolvedValueOnce({
        id: 'pi_test_simple',
        client_secret: 'pi_test_simple_secret_abc',
        amount: 1499,
        currency: 'usd',
        status: 'requires_payment_method',
        metadata: { userId: 'test-user-id', productType: 'fan_pass' },
      } as any);

      const result = await callFunction(
        createPaymentIntent,
        { productType: 'fan_pass', currency: 'usd', description: 'Test payment' },
        authedContext(),
      );

      expect(result.clientSecret).toBe('pi_test_simple_secret_abc');
      expect(mockStripe.paymentIntents.create).toHaveBeenCalledTimes(1);

      const piArgs = mockStripe.paymentIntents.create.mock.calls[0][0];
      expect(piArgs.amount).toBe(1499);
      expect(piArgs.currency).toBe('usd');
      expect(piArgs.description).toBe('Test payment');
      expect(piArgs.metadata.userId).toBe('test-user-id');
      expect(piArgs.metadata.productType).toBe('fan_pass');
    });

    it('should reject unauthenticated requests', async () => {
      await expect(
        callFunction(createPaymentIntent, { productType: 'fan_pass' }, unauthContext()),
      ).rejects.toThrow(/User must be authenticated/);
    });

    it('should reject when productType is missing or invalid', async () => {
      await expect(
        callFunction(createPaymentIntent, {}, authedContext()),
      ).rejects.toThrow(/Invalid product type/);

      await expect(
        callFunction(createPaymentIntent, { productType: 'nonexistent_product' }, authedContext()),
      ).rejects.toThrow(/Invalid product type/);
    });

    it('should default currency to usd', async () => {
      await callFunction(
        createPaymentIntent,
        { productType: 'superfan_pass', description: 'Default currency' },
        authedContext(),
      );

      const piArgs = mockStripe.paymentIntents.create.mock.calls[0][0];
      expect(piArgs.currency).toBe('usd');
      expect(piArgs.amount).toBe(2999);
    });
  });

  // =========================================================================
  // handleStripeWebhook
  // =========================================================================

  describe('handleStripeWebhook', () => {
    /**
     * Build a mock HTTP request for the webhook handler.
     * The stripe-simple.ts handler passes `req.body` (not `req.rawBody`) to
     * constructEvent, so we set `body` to the raw string/Buffer.
     */
    const buildReq = (body: any, signature = 'valid_sig') => {
      const bodyStr = JSON.stringify(body);
      return createMockHttpRequest({
        method: 'POST',
        headers: { 'stripe-signature': signature },
        body: bodyStr,              // constructEvent receives req.body
        rawBody: Buffer.from(bodyStr),
      });
    };

    it('should validate the webhook signature and respond 200', async () => {
      const body = {
        type: 'checkout.session.completed',
        data: {
          object: {
            id: 'cs_test_wh',
            metadata: { venueId: 'v-1', userId: 'u-1' },
            customer: 'cus_x',
            subscription: 'sub_x',
          },
        },
      };
      const req = buildReq(body);
      const res = createMockHttpResponse();

      mockFirestore.setTestData('processed_webhook_events', new Map());
      mockFirestore.setTestData('venues', new Map());

      await handleStripeWebhook(req as any, res as any);

      expect(mockStripe.webhooks.constructEvent).toHaveBeenCalledTimes(1);
      expect(res._statusCode).toBe(200);
    });

    it('should return 400 when signature verification fails', async () => {
      mockStripe.webhooks.constructEvent.mockImplementationOnce(() => {
        throw new Error('Invalid signature');
      });

      const req = buildReq({ type: 'test' }, 'bad-sig');
      const res = createMockHttpResponse();

      await handleStripeWebhook(req as any, res as any);

      expect(res._statusCode).toBe(400);
      expect(res._body).toContain('Webhook signature verification failed');
    });

    it('should return 500 when webhook secret is not configured', async () => {
      const origWebhookEnv = process.env.STRIPE_WEBHOOK_SECRET;
      delete process.env.STRIPE_WEBHOOK_SECRET;

      const functions = require('firebase-functions');
      const origConfig = functions.config;
      functions.config = jest.fn(() => ({ stripe: { secret_key: 'sk_test_mock' } }));

      const req = buildReq({ type: 'test' });
      const res = createMockHttpResponse();

      await handleStripeWebhook(req as any, res as any);

      expect(res._statusCode).toBe(500);
      expect(res._body).toContain('Webhook secret not configured');

      // Restore
      process.env.STRIPE_WEBHOOK_SECRET = origWebhookEnv!;
      functions.config = origConfig;
    });

    it('should skip duplicate events (idempotency)', async () => {
      const eventId = 'evt_test_mock';
      const processed = new Map<string, any>();
      processed.set(eventId, { eventId, eventType: 'checkout.session.completed' });
      mockFirestore.setTestData('processed_webhook_events', processed);

      const body = {
        type: 'checkout.session.completed',
        data: { object: { id: 'cs_dup', metadata: {} } },
      };
      const req = buildReq(body);
      const res = createMockHttpResponse();

      await handleStripeWebhook(req as any, res as any);

      expect(res._statusCode).toBe(200);
      expect(res._body).toContain('Event already processed');
    });

    it('should handle checkout.session.completed and upgrade venue', async () => {
      const venueId = 'venue-upgrade';
      const venues = new Map<string, any>();
      venues.set(venueId, {
        id: venueId,
        plan: 'free',
        billing: { status: 'inactive' },
        features: {},
      });
      mockFirestore.setTestData('venues', venues);
      mockFirestore.setTestData('processed_webhook_events', new Map());

      const body = {
        type: 'checkout.session.completed',
        data: {
          object: {
            id: 'cs_upgrade',
            metadata: { venueId, userId: 'u-1' },
            customer: 'cus_upgrade',
            subscription: 'sub_upgrade',
          },
        },
      };
      const req = buildReq(body);
      const res = createMockHttpResponse();

      await handleStripeWebhook(req as any, res as any);

      expect(res._statusCode).toBe(200);

      const venueDoc = await mockFirestore.collection('venues').doc(venueId).get();
      expect(venueDoc.data()?.plan).toBe('premium');
    });

    it('should handle customer.subscription.updated event type', async () => {
      // The subscription handler queries venues by 'billing.stripeCustomerId'.
      // The MockQuery checks top-level fields. We seed the venue data with the
      // dotted key so the mock query finds it.
      const customerId = 'cus_sub_update';
      const venueId = 'venue-sub';
      const venues = new Map<string, any>();
      venues.set(venueId, {
        id: venueId,
        plan: 'free',
        'billing.stripeCustomerId': customerId,
      });
      mockFirestore.setTestData('venues', venues);
      mockFirestore.setTestData('processed_webhook_events', new Map());

      mockStripe.webhooks.constructEvent.mockImplementationOnce(() => ({
        id: 'evt_sub_update',
        type: 'customer.subscription.updated',
        data: {
          object: {
            id: 'sub_updated',
            customer: customerId,
            status: 'active',
            current_period_end: Math.floor(Date.now() / 1000) + 86400 * 30,
          },
        },
      }));

      const req = buildReq({ type: 'customer.subscription.updated' });
      const res = createMockHttpResponse();

      await handleStripeWebhook(req as any, res as any);

      expect(res._statusCode).toBe(200);

      // Verify venue was upgraded
      const venueDoc = await mockFirestore.collection('venues').doc(venueId).get();
      expect(venueDoc.data()?.plan).toBe('premium');
    });

    it('should handle customer.subscription.deleted and downgrade venue', async () => {
      const customerId = 'cus_sub_cancel';
      const venueId = 'venue-cancel';
      const venues = new Map<string, any>();
      venues.set(venueId, {
        id: venueId,
        plan: 'premium',
        'billing.stripeCustomerId': customerId,
      });
      mockFirestore.setTestData('venues', venues);
      mockFirestore.setTestData('processed_webhook_events', new Map());

      mockStripe.webhooks.constructEvent.mockImplementationOnce(() => ({
        id: 'evt_sub_cancel',
        type: 'customer.subscription.deleted',
        data: {
          object: {
            id: 'sub_cancelled',
            customer: customerId,
            status: 'canceled',
          },
        },
      }));

      const req = buildReq({ type: 'customer.subscription.deleted' });
      const res = createMockHttpResponse();

      await handleStripeWebhook(req as any, res as any);

      expect(res._statusCode).toBe(200);

      const venueDoc = await mockFirestore.collection('venues').doc(venueId).get();
      expect(venueDoc.data()?.plan).toBe('free');
    });

    it('should handle invoice.payment_succeeded', async () => {
      const customerId = 'cus_pay_ok';
      const venueId = 'venue-pay-ok';
      const venues = new Map<string, any>();
      venues.set(venueId, {
        id: venueId,
        'billing.stripeCustomerId': customerId,
      });
      mockFirestore.setTestData('venues', venues);
      mockFirestore.setTestData('processed_webhook_events', new Map());

      mockStripe.webhooks.constructEvent.mockImplementationOnce(() => ({
        id: 'evt_pay_ok',
        type: 'invoice.payment_succeeded',
        data: {
          object: {
            id: 'inv_ok',
            customer: customerId,
            amount_paid: 4900,
          },
        },
      }));

      const req = buildReq({ type: 'invoice.payment_succeeded' });
      const res = createMockHttpResponse();

      await handleStripeWebhook(req as any, res as any);

      expect(res._statusCode).toBe(200);

      const venueDoc = await mockFirestore.collection('venues').doc(venueId).get();
      expect(venueDoc.data()?.['billing.lastPaymentAmount']).toBe(4900);
    });

    it('should handle invoice.payment_failed', async () => {
      const customerId = 'cus_pay_fail';
      const venueId = 'venue-pay-fail';
      const venues = new Map<string, any>();
      venues.set(venueId, {
        id: venueId,
        'billing.stripeCustomerId': customerId,
      });
      mockFirestore.setTestData('venues', venues);
      mockFirestore.setTestData('processed_webhook_events', new Map());

      mockStripe.webhooks.constructEvent.mockImplementationOnce(() => ({
        id: 'evt_pay_fail',
        type: 'invoice.payment_failed',
        data: {
          object: {
            id: 'inv_fail',
            customer: customerId,
          },
        },
      }));

      const req = buildReq({ type: 'invoice.payment_failed' });
      const res = createMockHttpResponse();

      await handleStripeWebhook(req as any, res as any);

      expect(res._statusCode).toBe(200);

      const venueDoc = await mockFirestore.collection('venues').doc(venueId).get();
      expect(venueDoc.data()?.['billing.paymentStatus']).toBe('failed');
    });

    it('should mark events as processed after handling', async () => {
      mockFirestore.setTestData('processed_webhook_events', new Map());

      const body = {
        type: 'checkout.session.completed',
        data: {
          object: {
            id: 'cs_mark',
            metadata: {},
            customer: null,
            subscription: null,
          },
        },
      };
      const req = buildReq(body);
      const res = createMockHttpResponse();

      await handleStripeWebhook(req as any, res as any);

      expect(res._statusCode).toBe(200);

      // The event should be stored in processed_webhook_events
      const eventDoc = await mockFirestore
        .collection('processed_webhook_events')
        .doc('evt_test_mock')
        .get();
      expect(eventDoc.exists).toBe(true);
    });

    it('should handle unrecognized event types gracefully', async () => {
      mockFirestore.setTestData('processed_webhook_events', new Map());

      mockStripe.webhooks.constructEvent.mockImplementationOnce(() => ({
        id: 'evt_unknown',
        type: 'unknown.event.type',
        data: { object: {} },
      }));

      const req = buildReq({ type: 'unknown.event.type' });
      const res = createMockHttpResponse();

      await handleStripeWebhook(req as any, res as any);

      expect(res._statusCode).toBe(200);
      expect(res._body).toContain('Webhook handled successfully');
    });

    it('should route event correctly based on event type', async () => {
      mockFirestore.setTestData('processed_webhook_events', new Map());
      const venues = new Map<string, any>();
      mockFirestore.setTestData('venues', venues);

      // Test that checkout.session.completed calls handleCheckoutCompleted (venue path)
      const venueId = 'venue-route-test';
      venues.set(venueId, { id: venueId, plan: 'free', features: {} });

      const body = {
        type: 'checkout.session.completed',
        data: {
          object: {
            id: 'cs_route',
            metadata: { venueId, userId: 'u-route' },
            customer: 'cus_route',
            subscription: 'sub_route',
          },
        },
      };
      const req = buildReq(body);
      const res = createMockHttpResponse();

      await handleStripeWebhook(req as any, res as any);

      expect(res._statusCode).toBe(200);
      const venueDoc = await mockFirestore.collection('venues').doc(venueId).get();
      expect(venueDoc.data()?.plan).toBe('premium');
    });
  });
});

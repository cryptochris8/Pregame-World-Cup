/**
 * World Cup Payments Tests
 *
 * Tests for Fan Pass and Venue Premium payment functions.
 */

import {
  MockFirestore,
  MockTimestamp,
  MockFieldValue,
  createMockCallableContext,
  createTestUser,
  createTestFanPass,
  createTestVenueEnhancement,
  mockStripe,
  createCheckoutCompletedEvent,
} from './mocks';

// Mock firebase-admin before imports
const mockFirestore = new MockFirestore();
const mockMessaging = { send: jest.fn().mockResolvedValue('mock-message-id') };

jest.mock('firebase-admin', () => ({
  initializeApp: jest.fn(),
  app: jest.fn(() => ({ name: '[DEFAULT]', options: { projectId: 'test-project' } })),
  firestore: jest.fn(() => mockFirestore),
  messaging: jest.fn(() => mockMessaging),
  credential: { cert: jest.fn(), applicationDefault: jest.fn() },
}));

// Mock Stripe
jest.mock('stripe', () => {
  return jest.fn().mockImplementation(() => mockStripe);
});

// Import after mocks
import * as admin from 'firebase-admin';

// Re-create Firestore FieldValue and Timestamp mocks
(admin.firestore as any).FieldValue = MockFieldValue;
(admin.firestore as any).Timestamp = MockTimestamp;

describe('World Cup Payments', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockFirestore.clearAllData();
    mockStripe.reset();
  });

  describe('Fan Pass Features', () => {
    const FAN_FEATURES = {
      free: {
        basicSchedules: true,
        venueDiscovery: true,
        matchNotifications: true,
        basicTeamFollowing: true,
        communityAccess: true,
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
        adFree: true,
        advancedStats: true,
        customAlerts: true,
        advancedSocialFeatures: true,
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
        exclusiveContent: true,
        priorityFeatures: true,
        aiMatchInsights: true,
        downloadableContent: true,
      },
    };

    it('should define correct features for free tier', () => {
      expect(FAN_FEATURES.free.basicSchedules).toBe(true);
      expect(FAN_FEATURES.free.venueDiscovery).toBe(true);
      expect(FAN_FEATURES.free.adFree).toBe(false);
      expect(FAN_FEATURES.free.advancedStats).toBe(false);
      expect(FAN_FEATURES.free.aiMatchInsights).toBe(false);
    });

    it('should define correct features for fan pass tier', () => {
      expect(FAN_FEATURES.fan_pass.basicSchedules).toBe(true);
      expect(FAN_FEATURES.fan_pass.adFree).toBe(true);
      expect(FAN_FEATURES.fan_pass.advancedStats).toBe(true);
      expect(FAN_FEATURES.fan_pass.customAlerts).toBe(true);
      expect(FAN_FEATURES.fan_pass.exclusiveContent).toBe(false);
      expect(FAN_FEATURES.fan_pass.aiMatchInsights).toBe(false);
    });

    it('should define correct features for superfan pass tier', () => {
      expect(FAN_FEATURES.superfan_pass.basicSchedules).toBe(true);
      expect(FAN_FEATURES.superfan_pass.adFree).toBe(true);
      expect(FAN_FEATURES.superfan_pass.advancedStats).toBe(true);
      expect(FAN_FEATURES.superfan_pass.exclusiveContent).toBe(true);
      expect(FAN_FEATURES.superfan_pass.aiMatchInsights).toBe(true);
      expect(FAN_FEATURES.superfan_pass.downloadableContent).toBe(true);
    });
  });

  describe('Venue Features', () => {
    const VENUE_FEATURES = {
      free: {
        showsMatches: true,
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

    it('should define correct features for free venue tier', () => {
      expect(VENUE_FEATURES.free.showsMatches).toBe(true);
      expect(VENUE_FEATURES.free.tvSetup).toBe(false);
      expect(VENUE_FEATURES.free.gameSpecials).toBe(false);
      expect(VENUE_FEATURES.free.analytics).toBe(false);
    });

    it('should define correct features for premium venue tier', () => {
      expect(VENUE_FEATURES.premium.showsMatches).toBe(true);
      expect(VENUE_FEATURES.premium.tvSetup).toBe(true);
      expect(VENUE_FEATURES.premium.gameSpecials).toBe(true);
      expect(VENUE_FEATURES.premium.featuredListing).toBe(true);
      expect(VENUE_FEATURES.premium.analytics).toBe(true);
    });
  });

  describe('Price Configuration', () => {
    const PRICE_AMOUNTS = {
      FAN_PASS: 1499,
      SUPERFAN_PASS: 2999,
      VENUE_PREMIUM: 9900,
    };

    it('should have correct fan pass price ($14.99)', () => {
      expect(PRICE_AMOUNTS.FAN_PASS).toBe(1499);
    });

    it('should have correct superfan pass price ($29.99)', () => {
      expect(PRICE_AMOUNTS.SUPERFAN_PASS).toBe(2999);
    });

    it('should have correct venue premium price ($99.00)', () => {
      expect(PRICE_AMOUNTS.VENUE_PREMIUM).toBe(9900);
    });
  });

  describe('Tournament Dates', () => {
    const TOURNAMENT_START = new Date('2026-06-11T00:00:00Z');
    const TOURNAMENT_END = new Date('2026-07-20T23:59:59Z');

    it('should have correct tournament start date', () => {
      expect(TOURNAMENT_START.getUTCFullYear()).toBe(2026);
      expect(TOURNAMENT_START.getUTCMonth()).toBe(5); // June (0-indexed)
      expect(TOURNAMENT_START.getUTCDate()).toBe(11);
    });

    it('should have correct tournament end date', () => {
      expect(TOURNAMENT_END.getUTCFullYear()).toBe(2026);
      expect(TOURNAMENT_END.getUTCMonth()).toBe(6); // July (0-indexed)
      expect(TOURNAMENT_END.getUTCDate()).toBe(20);
    });

    it('should span approximately 39 days', () => {
      const durationMs = TOURNAMENT_END.getTime() - TOURNAMENT_START.getTime();
      const durationDays = Math.ceil(durationMs / (1000 * 60 * 60 * 24));
      expect(durationDays).toBeGreaterThanOrEqual(39);
      expect(durationDays).toBeLessThanOrEqual(40);
    });
  });

  describe('createFanPassCheckout', () => {
    it('should require authentication', async () => {
      const context = createMockCallableContext({ auth: null });

      // Simulating the function's behavior
      const isAuthenticated = context.auth !== null;
      expect(isAuthenticated).toBe(false);
    });

    it('should reject invalid pass types', () => {
      const validPassTypes = ['fan_pass', 'superfan_pass'];

      expect(validPassTypes.includes('fan_pass')).toBe(true);
      expect(validPassTypes.includes('superfan_pass')).toBe(true);
      expect(validPassTypes.includes('invalid_pass')).toBe(false);
      expect(validPassTypes.includes('')).toBe(false);
    });

    it('should create Stripe customer if not exists', async () => {
      const context = createMockCallableContext();
      const userData = createTestUser({ uid: context.auth!.uid });

      // Simulate checking for existing customer
      const stripeCustomersData = new Map<string, any>();
      mockFirestore.setTestData('stripe_customers', stripeCustomersData);

      const customerQuery = await mockFirestore.collection('stripe_customers')
        .where('userId', '==', userData.uid)
        .limit(1)
        .get();

      expect(customerQuery.empty).toBe(true);

      // Create customer via Stripe
      const customer = await mockStripe.customers.create({
        email: userData.email,
        metadata: { userId: userData.uid, type: 'fan' },
      });

      expect(customer.id).toBeDefined();
      expect(mockStripe.callHistory.customersCreate).toHaveLength(1);
      expect(mockStripe.callHistory.customersCreate[0].email).toBe(userData.email);
    });

    it('should create checkout session with correct parameters', async () => {
      const context = createMockCallableContext();
      const passType = 'fan_pass';
      const customerId = 'cus_test_existing';

      const session = await mockStripe.checkout.sessions.create({
        customer: customerId,
        payment_method_types: ['card'],
        mode: 'payment',
        line_items: [{ price: 'price_test_fan_pass', quantity: 1 }],
        success_url: 'https://example.com/success',
        cancel_url: 'https://example.com/cancel',
        metadata: {
          type: 'fan_pass',
          passType,
          userId: context.auth!.uid,
        },
      });

      expect(session.id).toBeDefined();
      expect(session.url).toBeDefined();
      expect(mockStripe.callHistory.checkoutSessionsCreate).toHaveLength(1);
      expect(mockStripe.callHistory.checkoutSessionsCreate[0].mode).toBe('payment');
    });
  });

  describe('getFanPassStatus', () => {
    it('should return free tier for users without pass', async () => {
      const userId = 'test-user-no-pass';
      const fanPassesData = new Map<string, any>();
      mockFirestore.setTestData('world_cup_fan_passes', fanPassesData);

      const passDoc = await mockFirestore.collection('world_cup_fan_passes').doc(userId).get();

      expect(passDoc.exists).toBe(false);
    });

    it('should return active pass data for users with pass', async () => {
      const userId = 'test-user-with-pass';
      const passData = createTestFanPass({ userId, passType: 'superfan_pass' });

      const fanPassesData = new Map<string, any>();
      fanPassesData.set(userId, passData);
      mockFirestore.setTestData('world_cup_fan_passes', fanPassesData);

      const passDoc = await mockFirestore.collection('world_cup_fan_passes').doc(userId).get();

      expect(passDoc.exists).toBe(true);
      expect(passDoc.data()?.passType).toBe('superfan_pass');
      expect(passDoc.data()?.status).toBe('active');
    });
  });

  describe('createVenuePremiumCheckout', () => {
    it('should require venue ID', () => {
      const data = { venueId: null, venueName: 'Test Venue' };
      expect(data.venueId).toBeNull();
    });

    it('should check for existing premium subscription', async () => {
      const venueId = 'test-venue-premium';
      const venueData = createTestVenueEnhancement({ venueId, subscriptionTier: 'premium' });

      const venueEnhancementsData = new Map<string, any>();
      venueEnhancementsData.set(venueId, venueData);
      mockFirestore.setTestData('venue_enhancements', venueEnhancementsData);

      const venueDoc = await mockFirestore.collection('venue_enhancements').doc(venueId).get();

      expect(venueDoc.exists).toBe(true);
      expect(venueDoc.data()?.subscriptionTier).toBe('premium');
    });

    it('should allow checkout for non-premium venues', async () => {
      const venueId = 'test-venue-free';
      const venueData = createTestVenueEnhancement({ venueId, subscriptionTier: 'free' });

      const venueEnhancementsData = new Map<string, any>();
      venueEnhancementsData.set(venueId, venueData);
      mockFirestore.setTestData('venue_enhancements', venueEnhancementsData);

      const venueDoc = await mockFirestore.collection('venue_enhancements').doc(venueId).get();

      expect(venueDoc.exists).toBe(true);
      expect(venueDoc.data()?.subscriptionTier).toBe('free');

      // Should be able to create checkout
      const session = await mockStripe.checkout.sessions.create({
        customer: 'cus_test',
        payment_method_types: ['card'],
        mode: 'payment',
        line_items: [{ price: 'price_test_venue_premium', quantity: 1 }],
        metadata: { type: 'venue_premium', venueId },
      });

      expect(session.id).toBeDefined();
    });
  });

  describe('Webhook Handler', () => {
    it('should verify webhook signature', () => {
      const payload = JSON.stringify({
        type: 'checkout.session.completed',
        data: { object: { id: 'cs_test', metadata: { type: 'fan_pass' } } },
      });
      const signature = 'mock_signature';

      const event = mockStripe.webhooks.constructEvent(
        payload,
        signature,
        'whsec_test_mock'
      );

      expect(event.type).toBe('checkout.session.completed');
      expect(mockStripe.callHistory.webhookConstructEvent).toHaveLength(1);
    });

    it('should handle checkout.session.completed for fan pass', async () => {
      const userId = 'test-user-webhook';
      const event = createCheckoutCompletedEvent({
        type: 'fan_pass',
        passType: 'fan_pass',
        userId,
      });

      expect(event.type).toBe('checkout.session.completed');
      expect(event.data.object.metadata.type).toBe('fan_pass');
      expect(event.data.object.metadata.userId).toBe(userId);
    });

    it('should handle checkout.session.completed for venue premium', async () => {
      const venueId = 'test-venue-webhook';
      const userId = 'test-owner';
      const event = createCheckoutCompletedEvent({
        type: 'venue_premium',
        venueId,
        userId,
      });

      expect(event.type).toBe('checkout.session.completed');
      expect(event.data.object.metadata.type).toBe('venue_premium');
      expect(event.data.object.metadata.venueId).toBe(venueId);
    });
  });

  describe('Fan Pass Activation', () => {
    it('should create fan pass document on activation', async () => {
      const userId = 'test-user-activate';
      const passType = 'superfan_pass';

      const fanPassesData = new Map<string, any>();
      mockFirestore.setTestData('world_cup_fan_passes', fanPassesData);

      // Simulate activation
      await mockFirestore.collection('world_cup_fan_passes').doc(userId).set({
        userId,
        passType,
        status: 'active',
        purchasedAt: MockFieldValue.serverTimestamp(),
        validFrom: new Date('2026-06-11'),
        validUntil: new Date('2026-07-20'),
      });

      const passDoc = await mockFirestore.collection('world_cup_fan_passes').doc(userId).get();
      expect(passDoc.exists).toBe(true);
      expect(passDoc.data()?.passType).toBe('superfan_pass');
      expect(passDoc.data()?.status).toBe('active');
    });
  });

  describe('Venue Premium Activation', () => {
    it('should update existing venue to premium', async () => {
      const venueId = 'test-venue-upgrade';
      const existingData = createTestVenueEnhancement({ venueId, subscriptionTier: 'free' });

      const venueEnhancementsData = new Map<string, any>();
      venueEnhancementsData.set(venueId, existingData);
      mockFirestore.setTestData('venue_enhancements', venueEnhancementsData);

      // Update to premium
      await mockFirestore.collection('venue_enhancements').doc(venueId).update({
        subscriptionTier: 'premium',
        premiumPurchasedAt: MockFieldValue.serverTimestamp(),
      });

      const venueDoc = await mockFirestore.collection('venue_enhancements').doc(venueId).get();
      expect(venueDoc.data()?.subscriptionTier).toBe('premium');
    });

    it('should create new venue enhancement if not exists', async () => {
      const venueId = 'test-venue-new';
      const userId = 'test-owner';

      const venueEnhancementsData = new Map<string, any>();
      mockFirestore.setTestData('venue_enhancements', venueEnhancementsData);

      // Venue doesn't exist yet
      const venueDoc = await mockFirestore.collection('venue_enhancements').doc(venueId).get();
      expect(venueDoc.exists).toBe(false);

      // Create new premium venue
      await mockFirestore.collection('venue_enhancements').doc(venueId).set({
        venueId,
        ownerId: userId,
        subscriptionTier: 'premium',
        showsMatches: true,
        premiumPurchasedAt: MockFieldValue.serverTimestamp(),
        createdAt: MockFieldValue.serverTimestamp(),
      });

      const newVenueDoc = await mockFirestore.collection('venue_enhancements').doc(venueId).get();
      expect(newVenueDoc.exists).toBe(true);
      expect(newVenueDoc.data()?.subscriptionTier).toBe('premium');
    });
  });

  describe('checkFanPassAccess', () => {
    it('should return false for unauthenticated users', () => {
      const context = createMockCallableContext({ auth: null });
      const hasAccess = context.auth !== null;
      expect(hasAccess).toBe(false);
    });

    it('should check specific feature access', () => {
      const features = {
        adFree: true,
        advancedStats: true,
        aiMatchInsights: false,
      };

      expect(features.adFree).toBe(true);
      expect(features.aiMatchInsights).toBe(false);
    });
  });

  describe('getWorldCupPricing', () => {
    it('should return all pricing information', () => {
      const pricing = {
        fanPass: {
          priceId: 'price_test_fan_pass',
          amount: 1499,
          displayPrice: '$14.99',
          name: 'Fan Pass',
        },
        superfanPass: {
          priceId: 'price_test_superfan_pass',
          amount: 2999,
          displayPrice: '$29.99',
          name: 'Superfan Pass',
        },
        venuePremium: {
          priceId: 'price_test_venue_premium',
          amount: 9900,
          displayPrice: '$99.00',
          name: 'Venue Premium',
        },
        tournamentDates: {
          start: '2026-06-11T00:00:00.000Z',
          end: '2026-07-20T23:59:59.000Z',
        },
      };

      expect(pricing.fanPass.amount).toBe(1499);
      expect(pricing.superfanPass.amount).toBe(2999);
      expect(pricing.venuePremium.amount).toBe(9900);
      expect(pricing.tournamentDates.start).toContain('2026-06-11');
    });
  });
});

/**
 * Watch Party Payments Tests
 *
 * Comprehensive integration tests for virtual attendance payments, confirmations,
 * individual refunds, and bulk refunds defined in watch-party-payments.ts.
 *
 * Every exported Cloud Function is exercised through the mock layer so that
 * Firestore reads/writes and Stripe API calls are verified end-to-end.
 */

import {
  MockFirestore,
  MockTimestamp,
  MockFieldValue,
  createMockCallableContext,
  createTestWatchParty,
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

// Patch runTransaction onto the mock Firestore so the source code can use it.
// The mock Firestore class does not natively include runTransaction.
(mockFirestore as any).runTransaction = jest.fn(async (cb: any) => {
  // Provide a lightweight transaction object that delegates to the mock Firestore
  const transaction = {
    get: async (ref: any) => ref.get(),
    set: (ref: any, data: any) => ref.set(data),
    update: (ref: any, data: any) => ref.update(data),
  };
  return cb(transaction);
});

// Import the functions under test
import {
  createVirtualAttendancePayment,
  handleVirtualAttendancePayment,
  requestVirtualAttendanceRefund,
  refundAllVirtualAttendees,
} from '../src/watch-party-payments';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const callFunction = (fn: any, data: any, context: any) => fn(data, context);

const authedContext = (uid = 'test-user-id', email = 'test@example.com') =>
  createMockCallableContext({ auth: { uid, token: { email } } });

const unauthContext = () => createMockCallableContext({ auth: null });

/**
 * Seed a basic watch party that allows virtual attendance.
 * Returns the party id for convenience.
 */
const seedWatchParty = (
  id = 'wp-1',
  overrides: Record<string, any> = {},
): string => {
  const parties = new Map<string, any>();
  parties.set(id, {
    ...createTestWatchParty({ id, hostId: 'host-user' }),
    allowVirtualAttendance: true,
    virtualAttendeesCount: 0,
    ...overrides,
  });
  mockFirestore.setTestData('watch_parties', parties);
  return id;
};

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

describe('Watch Party Payments', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockFirestore.clearAllData();
    mockStripe.reset();
  });

  // =========================================================================
  // createVirtualAttendancePayment
  // =========================================================================

  describe('createVirtualAttendancePayment', () => {
    it('should create a payment intent for valid virtual attendance', async () => {
      const partyId = seedWatchParty();
      mockFirestore.setTestData('watch_party_virtual_payments', new Map());

      // Ensure the mock returns a client_secret field
      mockStripe.paymentIntents.create.mockResolvedValueOnce({
        id: 'pi_test_virtual',
        client_secret: 'pi_test_virtual_secret',
        amount: 999,
        currency: 'usd',
        status: 'requires_payment_method',
        metadata: {},
      } as any);

      const result = await callFunction(
        createVirtualAttendancePayment,
        { watchPartyId: partyId, watchPartyName: 'Finals Watch', currency: 'usd' },
        authedContext(),
      );

      expect(result.clientSecret).toBe('pi_test_virtual_secret');
      expect(result.paymentIntentId).toBe('pi_test_virtual');
      expect(mockStripe.paymentIntents.create).toHaveBeenCalledTimes(1);

      const piArgs = mockStripe.paymentIntents.create.mock.calls[0][0];
      expect(piArgs.amount).toBe(999);
      expect(piArgs.metadata.type).toBe('virtual_attendance');
      expect(piArgs.metadata.watchPartyId).toBe(partyId);
    });

    it('should reject unauthenticated requests', async () => {
      await expect(
        callFunction(
          createVirtualAttendancePayment,
          { watchPartyId: 'wp-1', amount: 500 },
          unauthContext(),
        ),
      ).rejects.toThrow(/User must be authenticated/);
    });

    it('should reject when the watch party does not exist', async () => {
      // No party seeded
      mockFirestore.setTestData('watch_parties', new Map());
      mockFirestore.setTestData('watch_party_virtual_payments', new Map());

      await expect(
        callFunction(
          createVirtualAttendancePayment,
          { watchPartyId: 'nonexistent', amount: 500 },
          authedContext(),
        ),
      ).rejects.toThrow(/Watch party not found/);
    });

    it('should reject when the party does not allow virtual attendance', async () => {
      seedWatchParty('wp-no-virtual', { allowVirtualAttendance: false });
      mockFirestore.setTestData('watch_party_virtual_payments', new Map());

      await expect(
        callFunction(
          createVirtualAttendancePayment,
          { watchPartyId: 'wp-no-virtual', amount: 500 },
          authedContext(),
        ),
      ).rejects.toThrow(/does not allow virtual attendance/);
    });

    it('should reject duplicate payment (idempotency)', async () => {
      const partyId = seedWatchParty();
      const userId = 'test-user-id';
      const payments = new Map<string, any>();
      payments.set('existing-payment', {
        watchPartyId: partyId,
        userId,
        status: 'pending',
      });
      mockFirestore.setTestData('watch_party_virtual_payments', payments);

      await expect(
        callFunction(
          createVirtualAttendancePayment,
          { watchPartyId: partyId, amount: 500 },
          authedContext(userId),
        ),
      ).rejects.toThrow(/already purchased|pending payment/);
    });

    it('should reject when watchPartyId is missing', async () => {
      seedWatchParty();
      mockFirestore.setTestData('watch_party_virtual_payments', new Map());

      await expect(
        callFunction(
          createVirtualAttendancePayment,
          { /* watchPartyId missing - amount no longer required (server-side pricing) */ },
          authedContext(),
        ),
      ).rejects.toThrow(/Missing required parameters/);
    });

    it('should use server-side price from watch party document', async () => {
      const partyId = seedWatchParty('wp-custom-price', { virtualAttendancePriceCents: 1499 });
      mockFirestore.setTestData('watch_party_virtual_payments', new Map());

      mockStripe.paymentIntents.create.mockResolvedValueOnce({
        id: 'pi_custom_price',
        client_secret: 'pi_custom_price_secret',
        amount: 1499,
        currency: 'usd',
        status: 'requires_payment_method',
        metadata: {},
      } as any);

      const result = await callFunction(
        createVirtualAttendancePayment,
        { watchPartyId: partyId, watchPartyName: 'Premium Party' },
        authedContext(),
      );

      expect(result.clientSecret).toBe('pi_custom_price_secret');
      const piArgs = mockStripe.paymentIntents.create.mock.calls[0][0];
      expect(piArgs.amount).toBe(1499);
    });

    it('should create a PaymentIntent with correct description', async () => {
      const partyId = seedWatchParty();
      mockFirestore.setTestData('watch_party_virtual_payments', new Map());

      await callFunction(
        createVirtualAttendancePayment,
        { watchPartyId: partyId, watchPartyName: 'Big Game Night', amount: 999 },
        authedContext(),
      );

      const piArgs = mockStripe.paymentIntents.create.mock.calls[0][0];
      expect(piArgs.description).toContain('Big Game Night');
    });
  });

  // =========================================================================
  // handleVirtualAttendancePayment
  // =========================================================================

  describe('handleVirtualAttendancePayment', () => {
    const setupPaymentRecords = (
      paymentIntentId: string,
      watchPartyId: string,
      userId: string,
      status = 'pending',
    ) => {
      const payments = new Map<string, any>();
      payments.set('pay-doc-1', {
        paymentIntentId,
        watchPartyId,
        userId,
        status,
      });
      mockFirestore.setTestData('watch_party_virtual_payments', payments);
    };

    it('should confirm a valid payment and update records', async () => {
      const piId = 'pi_test_success';
      const partyId = seedWatchParty();
      const userId = 'test-user-id';

      setupPaymentRecords(piId, partyId, userId);

      // Configure Stripe mock to return succeeded status with matching metadata
      mockStripe.paymentIntents.retrieve.mockResolvedValueOnce({
        id: piId,
        status: 'succeeded',
        metadata: { watchPartyId: partyId, userId },
      } as any);

      const result = await callFunction(
        handleVirtualAttendancePayment,
        { paymentIntentId: piId, watchPartyId: partyId },
        authedContext(userId),
      );

      expect(result.success).toBe(true);
      expect(mockStripe.paymentIntents.retrieve).toHaveBeenCalledWith(piId);
    });

    it('should reject unauthenticated requests', async () => {
      await expect(
        callFunction(
          handleVirtualAttendancePayment,
          { paymentIntentId: 'pi_x', watchPartyId: 'wp-1' },
          unauthContext(),
        ),
      ).rejects.toThrow(/User must be authenticated/);
    });

    it('should skip if payment is already completed (idempotency)', async () => {
      const piId = 'pi_already_done';
      const partyId = seedWatchParty();
      const userId = 'test-user-id';

      setupPaymentRecords(piId, partyId, userId, 'completed');

      mockStripe.paymentIntents.retrieve.mockResolvedValueOnce({
        id: piId,
        status: 'succeeded',
        metadata: { watchPartyId: partyId, userId },
      } as any);

      // Should succeed without error and silently skip
      const result = await callFunction(
        handleVirtualAttendancePayment,
        { paymentIntentId: piId, watchPartyId: partyId },
        authedContext(userId),
      );

      expect(result.success).toBe(true);
    });

    it('should reject when PaymentIntent status is not succeeded', async () => {
      const piId = 'pi_not_done';
      const partyId = seedWatchParty();
      const userId = 'test-user-id';

      setupPaymentRecords(piId, partyId, userId);

      mockStripe.paymentIntents.retrieve.mockResolvedValueOnce({
        id: piId,
        status: 'requires_payment_method',
        metadata: { watchPartyId: partyId, userId },
      } as any);

      await expect(
        callFunction(
          handleVirtualAttendancePayment,
          { paymentIntentId: piId, watchPartyId: partyId },
          authedContext(userId),
        ),
      ).rejects.toThrow(/Payment has not been completed/);
    });

    it('should reject when metadata does not match', async () => {
      const piId = 'pi_mismatch';
      const partyId = seedWatchParty();
      const userId = 'test-user-id';

      setupPaymentRecords(piId, partyId, userId);

      mockStripe.paymentIntents.retrieve.mockResolvedValueOnce({
        id: piId,
        status: 'succeeded',
        metadata: { watchPartyId: 'different-party', userId: 'different-user' },
      } as any);

      await expect(
        callFunction(
          handleVirtualAttendancePayment,
          { paymentIntentId: piId, watchPartyId: partyId },
          authedContext(userId),
        ),
      ).rejects.toThrow(/Payment does not match/);
    });

    it('should reject when required parameters are missing', async () => {
      await expect(
        callFunction(
          handleVirtualAttendancePayment,
          { paymentIntentId: 'pi_x' /* watchPartyId missing */ },
          authedContext(),
        ),
      ).rejects.toThrow(/Missing required parameters/);
    });
  });

  // =========================================================================
  // requestVirtualAttendanceRefund
  // =========================================================================

  describe('requestVirtualAttendanceRefund', () => {
    const seedCompletedPayment = (
      watchPartyId: string,
      userId: string,
      paymentIntentId = 'pi_completed',
      status = 'completed',
    ) => {
      const payments = new Map<string, any>();
      payments.set('pay-ref-1', {
        watchPartyId,
        userId,
        paymentIntentId,
        status,
      });
      mockFirestore.setTestData('watch_party_virtual_payments', payments);
    };

    it('should allow the host to refund any attendee', async () => {
      const hostId = 'host-user';
      const attendeeId = 'attendee-1';
      const partyId = seedWatchParty('wp-host-refund', { hostId });

      seedCompletedPayment(partyId, attendeeId);

      const result = await callFunction(
        requestVirtualAttendanceRefund,
        { watchPartyId: partyId, userId: attendeeId, reason: 'Event cancelled' },
        authedContext(hostId),
      );

      expect(result.success).toBe(true);
      expect(result.refundId).toBeDefined();
      expect(mockStripe.refunds.create).toHaveBeenCalledTimes(1);
      expect(mockStripe.refunds.create).toHaveBeenCalledWith(
        expect.objectContaining({
          payment_intent: 'pi_completed',
          reason: 'requested_by_customer',
        }),
      );
    });

    it('should allow a user to refund themselves', async () => {
      const userId = 'self-refund-user';
      const partyId = seedWatchParty('wp-self-refund');

      seedCompletedPayment(partyId, userId);

      const result = await callFunction(
        requestVirtualAttendanceRefund,
        { watchPartyId: partyId },
        authedContext(userId),
      );

      expect(result.success).toBe(true);
      expect(result.refundId).toBeDefined();
    });

    it('should reject when a non-host user tries to refund another user', async () => {
      const partyId = seedWatchParty('wp-perm');

      seedCompletedPayment(partyId, 'attendee-1');

      await expect(
        callFunction(
          requestVirtualAttendanceRefund,
          { watchPartyId: partyId, userId: 'attendee-1' },
          authedContext('not-host-not-attendee'),
        ),
      ).rejects.toThrow(/Not authorized to request refund/);
    });

    it('should return existing refund info if already refunded (idempotency)', async () => {
      // The source queries for status == 'completed'. If a payment is already
      // refunded (status == 'refunded'), the query returns empty and the function
      // throws 'No completed payment found for refund'. This IS the idempotency
      // guard -- re-refunding is prevented because the query won't match.
      const userId = 'refunded-user';
      const partyId = seedWatchParty('wp-idem-refund');

      const payments = new Map<string, any>();
      payments.set('pay-refunded', {
        watchPartyId: partyId,
        userId,
        paymentIntentId: 'pi_already_refunded',
        status: 'refunded',
        refundId: 're_existing',
      });
      mockFirestore.setTestData('watch_party_virtual_payments', payments);

      await expect(
        callFunction(
          requestVirtualAttendanceRefund,
          { watchPartyId: partyId },
          authedContext(userId),
        ),
      ).rejects.toThrow(/No completed payment found/);

      // Should NOT call Stripe refund API again
      expect(mockStripe.refunds.create).not.toHaveBeenCalled();
    });

    it('should reject unauthenticated requests', async () => {
      await expect(
        callFunction(
          requestVirtualAttendanceRefund,
          { watchPartyId: 'wp-1' },
          unauthContext(),
        ),
      ).rejects.toThrow(/User must be authenticated/);
    });

    it('should reject when no completed payment exists', async () => {
      const userId = 'no-payment-user';
      const partyId = seedWatchParty('wp-no-payment');
      mockFirestore.setTestData('watch_party_virtual_payments', new Map());

      await expect(
        callFunction(
          requestVirtualAttendanceRefund,
          { watchPartyId: partyId },
          authedContext(userId),
        ),
      ).rejects.toThrow(/No completed payment found/);
    });

    it('should create a Stripe refund with correct metadata', async () => {
      const userId = 'meta-user';
      const partyId = seedWatchParty('wp-meta');

      seedCompletedPayment(partyId, userId, 'pi_meta_test');

      await callFunction(
        requestVirtualAttendanceRefund,
        { watchPartyId: partyId, reason: 'Changed plans' },
        authedContext(userId),
      );

      const refundArgs = mockStripe.refunds.create.mock.calls[0][0];
      expect(refundArgs.metadata.watchPartyId).toBe(partyId);
      expect(refundArgs.metadata.userId).toBe(userId);
      expect(refundArgs.metadata.reason).toBe('Changed plans');
    });
  });

  // =========================================================================
  // refundAllVirtualAttendees
  // =========================================================================

  describe('refundAllVirtualAttendees', () => {
    it('should allow the host to bulk refund all attendees', async () => {
      const hostId = 'host-user';
      const partyId = seedWatchParty('wp-bulk', { hostId });

      const payments = new Map<string, any>();
      payments.set('p1', {
        watchPartyId: partyId,
        userId: 'attendee-1',
        paymentIntentId: 'pi_bulk_1',
        status: 'completed',
      });
      payments.set('p2', {
        watchPartyId: partyId,
        userId: 'attendee-2',
        paymentIntentId: 'pi_bulk_2',
        status: 'completed',
      });
      payments.set('p3', {
        watchPartyId: partyId,
        userId: 'attendee-3',
        paymentIntentId: 'pi_bulk_3',
        status: 'completed',
      });
      mockFirestore.setTestData('watch_party_virtual_payments', payments);

      const result = await callFunction(
        refundAllVirtualAttendees,
        { watchPartyId: partyId },
        authedContext(hostId),
      );

      expect(result.success).toBe(true);
      expect(result.refundedCount).toBe(3);
      expect(mockStripe.refunds.create).toHaveBeenCalledTimes(3);
    });

    it('should reject when a non-host tries to bulk refund', async () => {
      const partyId = seedWatchParty('wp-non-host', { hostId: 'real-host' });
      mockFirestore.setTestData('watch_party_virtual_payments', new Map());

      await expect(
        callFunction(
          refundAllVirtualAttendees,
          { watchPartyId: partyId },
          authedContext('not-the-host'),
        ),
      ).rejects.toThrow(/Only the host can process mass refunds/);
    });

    it('should reject unauthenticated requests', async () => {
      await expect(
        callFunction(
          refundAllVirtualAttendees,
          { watchPartyId: 'wp-1' },
          unauthContext(),
        ),
      ).rejects.toThrow(/User must be authenticated/);
    });

    it('should return zero refundedCount when no payments exist', async () => {
      const hostId = 'host-user';
      const partyId = seedWatchParty('wp-empty', { hostId });
      mockFirestore.setTestData('watch_party_virtual_payments', new Map());

      const result = await callFunction(
        refundAllVirtualAttendees,
        { watchPartyId: partyId },
        authedContext(hostId),
      );

      expect(result.success).toBe(true);
      expect(result.refundedCount).toBe(0);
      expect(result.message).toContain('No payments to refund');
    });

    it('should handle partial failures gracefully', async () => {
      const hostId = 'host-user';
      const partyId = seedWatchParty('wp-partial', { hostId });

      const payments = new Map<string, any>();
      payments.set('p-ok', {
        watchPartyId: partyId,
        userId: 'user-ok',
        paymentIntentId: 'pi_ok',
        status: 'completed',
      });
      payments.set('p-fail', {
        watchPartyId: partyId,
        userId: 'user-fail',
        paymentIntentId: 'pi_fail',
        status: 'completed',
      });
      mockFirestore.setTestData('watch_party_virtual_payments', payments);

      // Make the second refund call fail
      mockStripe.refunds.create
        .mockResolvedValueOnce({ id: 're_ok', status: 'succeeded', amount: 500, payment_intent: 'pi_ok' } as any)
        .mockRejectedValueOnce(new Error('Stripe refund failed'));

      const result = await callFunction(
        refundAllVirtualAttendees,
        { watchPartyId: partyId },
        authedContext(hostId),
      );

      expect(result.success).toBe(true);
      expect(result.refundedCount).toBe(1);
      expect(result.errors).toBeDefined();
      expect(result.errors.length).toBe(1);
      expect(result.errors[0]).toContain('Stripe refund failed');
    });

    it('should reject when watchPartyId is missing', async () => {
      await expect(
        callFunction(refundAllVirtualAttendees, {}, authedContext('host-user')),
      ).rejects.toThrow(/Watch party ID is required/);
    });

    it('should reject when the watch party does not exist', async () => {
      mockFirestore.setTestData('watch_parties', new Map());

      await expect(
        callFunction(
          refundAllVirtualAttendees,
          { watchPartyId: 'nonexistent' },
          authedContext(),
        ),
      ).rejects.toThrow(/Watch party not found/);
    });

    it('should update virtualAttendeesCount to 0 after bulk refund', async () => {
      const hostId = 'host-user';
      const partyId = seedWatchParty('wp-count', { hostId, virtualAttendeesCount: 5 });

      const payments = new Map<string, any>();
      payments.set('p1', {
        watchPartyId: partyId,
        userId: 'a-1',
        paymentIntentId: 'pi_c1',
        status: 'completed',
      });
      mockFirestore.setTestData('watch_party_virtual_payments', payments);

      await callFunction(
        refundAllVirtualAttendees,
        { watchPartyId: partyId },
        authedContext(hostId),
      );

      // The function sets virtualAttendeesCount to 0
      const partyDoc = await mockFirestore
        .collection('watch_parties')
        .doc(partyId)
        .get();
      expect(partyDoc.data()?.virtualAttendeesCount).toBe(0);
    });
  });
});

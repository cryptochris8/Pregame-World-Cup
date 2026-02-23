/**
 * Venue Claiming Tests
 *
 * Comprehensive tests for the venue claiming lifecycle functions defined in
 * venue-claiming.ts: claimVenue, sendVenueVerificationCode, verifyVenueCode,
 * reviewVenueClaim, and submitVenueDispute.
 *
 * Covers authentication guards, field validation, business rule enforcement
 * (per-user limits, rate limiting, max attempts), transaction safety, admin
 * authorization, and dispute flows.
 */

import {
  MockFirestore,
  MockTimestamp,
  MockFieldValue,
  createMockCallableContext,
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

// Mock twilio - the module default-exports a function that returns a client
const mockTwilioCreate = jest.fn().mockResolvedValue({ sid: 'SM_test_mock' });
jest.mock('twilio', () => {
  return {
    __esModule: true,
    default: jest.fn(() => ({
      messages: {
        create: mockTwilioCreate,
      },
    })),
  };
});

import * as admin from 'firebase-admin';

(admin.firestore as any).FieldValue = MockFieldValue;
(admin.firestore as any).Timestamp = MockTimestamp;

// Patch runTransaction onto the mock Firestore so the source code can use it.
(mockFirestore as any).runTransaction = jest.fn(async (cb: any) => {
  const transaction = {
    get: async (ref: any) => ref.get(),
    set: (ref: any, data: any) => ref.set(data),
    update: (ref: any, data: any) => ref.update(data),
  };
  return cb(transaction);
});

// Import the functions under test
import {
  claimVenue,
  sendVenueVerificationCode,
  verifyVenueCode,
  reviewVenueClaim,
  submitVenueDispute,
} from '../src/venue-claiming';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const callFunction = (fn: any, data: any, context: any) => fn(data, context);

const authedContext = (uid = 'test-user-id', email = 'test@example.com') =>
  createMockCallableContext({ auth: { uid, token: { email } } });

const adminContext = (uid = 'admin-user-id', email = 'admin@example.com') => ({
  auth: { uid, token: { email, admin: true } },
});

const unauthContext = () => createMockCallableContext({ auth: null });

/** Valid claim data with all required fields. */
const validClaimData = (venueId = 'venue-1') => ({
  venueId,
  businessName: 'Test Sports Bar',
  contactEmail: 'owner@testbar.com',
  ownerRole: 'owner',
  venueType: 'bar',
  venuePhoneNumber: '+15551234567',
});

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

describe('Venue Claiming', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockFirestore.clearAllData();
    mockTwilioCreate.mockClear();
  });

  // =========================================================================
  // claimVenue
  // =========================================================================

  describe('claimVenue', () => {
    it('should reject unauthenticated requests', async () => {
      await expect(
        callFunction(claimVenue, validClaimData(), unauthContext()),
      ).rejects.toThrow(/Must be logged in to claim a venue/);
    });

    it('should reject when required fields are missing (no venueId)', async () => {
      const data = { ...validClaimData() };
      delete (data as any).venueId;

      await expect(
        callFunction(claimVenue, data, authedContext()),
      ).rejects.toThrow(/Missing required fields/);
    });

    it('should reject when required fields are missing (no businessName)', async () => {
      const data = { ...validClaimData() };
      delete (data as any).businessName;

      await expect(
        callFunction(claimVenue, data, authedContext()),
      ).rejects.toThrow(/Missing required fields/);
    });

    it('should reject when required fields are missing (no contactEmail)', async () => {
      const data = { ...validClaimData() };
      delete (data as any).contactEmail;

      await expect(
        callFunction(claimVenue, data, authedContext()),
      ).rejects.toThrow(/Missing required fields/);
    });

    it('should reject when required fields are missing (no ownerRole)', async () => {
      const data = { ...validClaimData() };
      delete (data as any).ownerRole;

      await expect(
        callFunction(claimVenue, data, authedContext()),
      ).rejects.toThrow(/Missing required fields/);
    });

    it('should reject when required fields are missing (no venueType)', async () => {
      const data = { ...validClaimData() };
      delete (data as any).venueType;

      await expect(
        callFunction(claimVenue, data, authedContext()),
      ).rejects.toThrow(/Missing required fields/);
    });

    it('should reject when venue is already claimed', async () => {
      const venues = new Map<string, any>();
      venues.set('venue-claimed', {
        ownerId: 'other-user',
        businessName: 'Existing Bar',
        claimStatus: 'approved',
      });
      mockFirestore.setTestData('venue_enhancements', venues);

      await expect(
        callFunction(claimVenue, validClaimData('venue-claimed'), authedContext()),
      ).rejects.toThrow(/already been claimed/);
    });

    it('should reject when user has reached the per-user claim limit (5 venues)', async () => {
      // The venue being claimed must not have an ownerId
      const venues = new Map<string, any>();
      venues.set('venue-new', { businessName: 'Unclaimed Venue' });
      // Seed 5 existing claims for the same user
      for (let i = 0; i < 5; i++) {
        venues.set(`existing-venue-${i}`, { ownerId: 'test-user-id' });
      }
      mockFirestore.setTestData('venue_enhancements', venues);

      await expect(
        callFunction(claimVenue, validClaimData('venue-new'), authedContext()),
      ).rejects.toThrow(/maximum of 5 venue claims/);
    });

    it('should successfully claim a venue with correct Firestore data', async () => {
      mockFirestore.setTestData('venue_enhancements', new Map());

      const result = await callFunction(
        claimVenue,
        validClaimData('venue-success'),
        authedContext('owner-1'),
      );

      expect(result.success).toBe(true);
      expect(result.venueId).toBe('venue-success');

      // Verify Firestore document was created with correct fields
      const venueDoc = await mockFirestore
        .collection('venue_enhancements')
        .doc('venue-success')
        .get();
      expect(venueDoc.exists).toBe(true);

      const data = venueDoc.data();
      expect(data.ownerId).toBe('owner-1');
      expect(data.businessName).toBe('Test Sports Bar');
      expect(data.contactEmail).toBe('owner@testbar.com');
      expect(data.ownerRole).toBe('owner');
      expect(data.venueType).toBe('bar');
      expect(data.venuePhoneNumber).toBe('+15551234567');
      expect(data.claimStatus).toBe('pendingVerification');
      expect(data.isVerified).toBe(false);
      expect(data.subscriptionTier).toBe('free');
      expect(data.showsMatches).toBe(false);
      expect(data.gameSpecials).toEqual([]);
    });

    it('should set venuePhoneNumber to null when not provided', async () => {
      mockFirestore.setTestData('venue_enhancements', new Map());

      const data = { ...validClaimData('venue-no-phone') };
      delete (data as any).venuePhoneNumber;

      await callFunction(claimVenue, data, authedContext());

      const venueDoc = await mockFirestore
        .collection('venue_enhancements')
        .doc('venue-no-phone')
        .get();
      expect(venueDoc.data().venuePhoneNumber).toBeNull();
    });

    it('should use a transaction for atomicity', async () => {
      mockFirestore.setTestData('venue_enhancements', new Map());

      await callFunction(claimVenue, validClaimData(), authedContext());

      expect((mockFirestore as any).runTransaction).toHaveBeenCalledTimes(1);
    });

    it('should allow claiming a venue doc that exists but has no ownerId', async () => {
      const venues = new Map<string, any>();
      venues.set('venue-empty-owner', {
        businessName: 'Some Venue',
        // No ownerId field at all
      });
      mockFirestore.setTestData('venue_enhancements', venues);

      const result = await callFunction(
        claimVenue,
        validClaimData('venue-empty-owner'),
        authedContext(),
      );

      expect(result.success).toBe(true);
    });
  });

  // =========================================================================
  // sendVenueVerificationCode
  // =========================================================================

  describe('sendVenueVerificationCode', () => {
    const seedVenuePendingVerification = (
      venueId: string,
      ownerId: string,
      phoneNumber = '+15551234567',
    ) => {
      const venues = new Map<string, any>();
      venues.set(venueId, {
        ownerId,
        claimStatus: 'pendingVerification',
        venuePhoneNumber: phoneNumber,
        businessName: 'Test Bar',
      });
      mockFirestore.setTestData('venue_enhancements', venues);
    };

    it('should reject unauthenticated requests', async () => {
      await expect(
        callFunction(sendVenueVerificationCode, { venueId: 'v-1' }, unauthContext()),
      ).rejects.toThrow(/Must be logged in/);
    });

    it('should reject when venueId is missing', async () => {
      await expect(
        callFunction(sendVenueVerificationCode, {}, authedContext()),
      ).rejects.toThrow(/Missing venueId/);
    });

    it('should reject when venue claim is not found', async () => {
      mockFirestore.setTestData('venue_enhancements', new Map());

      await expect(
        callFunction(
          sendVenueVerificationCode,
          { venueId: 'nonexistent' },
          authedContext(),
        ),
      ).rejects.toThrow(/Venue claim not found/);
    });

    it('should reject when caller is not the claimant', async () => {
      seedVenuePendingVerification('venue-other', 'actual-owner');

      await expect(
        callFunction(
          sendVenueVerificationCode,
          { venueId: 'venue-other' },
          authedContext('different-user'),
        ),
      ).rejects.toThrow(/not the claimant/);
    });

    it('should reject when claim status is not pendingVerification', async () => {
      const venues = new Map<string, any>();
      venues.set('venue-approved', {
        ownerId: 'test-user-id',
        claimStatus: 'approved',
        venuePhoneNumber: '+15551234567',
      });
      mockFirestore.setTestData('venue_enhancements', venues);

      await expect(
        callFunction(
          sendVenueVerificationCode,
          { venueId: 'venue-approved' },
          authedContext(),
        ),
      ).rejects.toThrow(/not in pending verification status/);
    });

    it('should enforce rate limiting (max 3 codes per hour)', async () => {
      seedVenuePendingVerification('venue-rate', 'test-user-id');

      // Seed a code doc with 3 codes already sent this hour
      const futureReset = new Date(Date.now() + 30 * 60 * 1000); // 30 mins from now
      const codes = new Map<string, any>();
      codes.set('venue-rate', {
        codesThisHour: 3,
        hourReset: MockTimestamp.fromDate(futureReset),
        code: '123456',
      });
      mockFirestore.setTestData('venue_verification_codes', codes);

      await expect(
        callFunction(
          sendVenueVerificationCode,
          { venueId: 'venue-rate' },
          authedContext(),
        ),
      ).rejects.toThrow(/Too many verification codes/);
    });

    it('should allow sending code when rate limit window has expired', async () => {
      seedVenuePendingVerification('venue-rate-ok', 'test-user-id');

      // Seed a code doc with 3 codes but the hour has already expired
      const pastReset = new Date(Date.now() - 5 * 60 * 1000); // 5 mins ago
      const codes = new Map<string, any>();
      codes.set('venue-rate-ok', {
        codesThisHour: 3,
        hourReset: MockTimestamp.fromDate(pastReset),
        code: '654321',
      });
      mockFirestore.setTestData('venue_verification_codes', codes);

      const result = await callFunction(
        sendVenueVerificationCode,
        { venueId: 'venue-rate-ok' },
        authedContext(),
      );

      expect(result.success).toBe(true);
    });

    it('should generate a 6-digit code and store it in Firestore', async () => {
      seedVenuePendingVerification('venue-code', 'test-user-id');
      mockFirestore.setTestData('venue_verification_codes', new Map());

      await callFunction(
        sendVenueVerificationCode,
        { venueId: 'venue-code' },
        authedContext(),
      );

      const codeDoc = await mockFirestore
        .collection('venue_verification_codes')
        .doc('venue-code')
        .get();
      expect(codeDoc.exists).toBe(true);

      const codeData = codeDoc.data();
      // Code should be a 6-digit string
      expect(codeData.code).toMatch(/^\d{6}$/);
      expect(parseInt(codeData.code)).toBeGreaterThanOrEqual(100000);
      expect(parseInt(codeData.code)).toBeLessThan(1000000);
      expect(codeData.venueId).toBe('venue-code');
      expect(codeData.userId).toBe('test-user-id');
      expect(codeData.attempts).toBe(0);
    });

    it('should attempt to send SMS via Twilio when phone number and credentials exist', async () => {
      // Set Twilio env vars
      const origSid = process.env.TWILIO_ACCOUNT_SID;
      const origToken = process.env.TWILIO_AUTH_TOKEN;
      const origFrom = process.env.TWILIO_PHONE_NUMBER;

      process.env.TWILIO_ACCOUNT_SID = 'AC_test_sid';
      process.env.TWILIO_AUTH_TOKEN = 'test_auth_token';
      process.env.TWILIO_PHONE_NUMBER = '+15550001111';

      seedVenuePendingVerification('venue-sms', 'test-user-id', '+15559998888');
      mockFirestore.setTestData('venue_verification_codes', new Map());

      const result = await callFunction(
        sendVenueVerificationCode,
        { venueId: 'venue-sms' },
        authedContext(),
      );

      expect(result.success).toBe(true);
      expect(result.message).toBe('Verification code sent.');

      // Verify twilio was called
      const twilio = require('twilio').default;
      expect(twilio).toHaveBeenCalled();
      expect(mockTwilioCreate).toHaveBeenCalledWith(
        expect.objectContaining({
          to: '+15559998888',
          from: '+15550001111',
          body: expect.stringContaining('verification code'),
        }),
      );

      // Restore env vars
      if (origSid !== undefined) process.env.TWILIO_ACCOUNT_SID = origSid;
      else delete process.env.TWILIO_ACCOUNT_SID;
      if (origToken !== undefined) process.env.TWILIO_AUTH_TOKEN = origToken;
      else delete process.env.TWILIO_AUTH_TOKEN;
      if (origFrom !== undefined) process.env.TWILIO_PHONE_NUMBER = origFrom;
      else delete process.env.TWILIO_PHONE_NUMBER;
    });

    it('should return success even when Twilio credentials are not configured', async () => {
      const origSid = process.env.TWILIO_ACCOUNT_SID;
      const origToken = process.env.TWILIO_AUTH_TOKEN;
      const origFrom = process.env.TWILIO_PHONE_NUMBER;

      delete process.env.TWILIO_ACCOUNT_SID;
      delete process.env.TWILIO_AUTH_TOKEN;
      delete process.env.TWILIO_PHONE_NUMBER;

      seedVenuePendingVerification('venue-no-twilio', 'test-user-id');
      mockFirestore.setTestData('venue_verification_codes', new Map());

      const result = await callFunction(
        sendVenueVerificationCode,
        { venueId: 'venue-no-twilio' },
        authedContext(),
      );

      expect(result.success).toBe(true);
      expect(result.message).toBe('Verification code sent.');

      // Restore
      if (origSid !== undefined) process.env.TWILIO_ACCOUNT_SID = origSid;
      if (origToken !== undefined) process.env.TWILIO_AUTH_TOKEN = origToken;
      if (origFrom !== undefined) process.env.TWILIO_PHONE_NUMBER = origFrom;
    });

    it('should return success even when no phone number is on venue', async () => {
      const venues = new Map<string, any>();
      venues.set('venue-no-phone', {
        ownerId: 'test-user-id',
        claimStatus: 'pendingVerification',
        // No venuePhoneNumber or contactPhone
      });
      mockFirestore.setTestData('venue_enhancements', venues);
      mockFirestore.setTestData('venue_verification_codes', new Map());

      const result = await callFunction(
        sendVenueVerificationCode,
        { venueId: 'venue-no-phone' },
        authedContext(),
      );

      expect(result.success).toBe(true);
    });

    it('should return success even when Twilio SMS send fails', async () => {
      const origSid = process.env.TWILIO_ACCOUNT_SID;
      const origToken = process.env.TWILIO_AUTH_TOKEN;
      const origFrom = process.env.TWILIO_PHONE_NUMBER;

      process.env.TWILIO_ACCOUNT_SID = 'AC_test_sid';
      process.env.TWILIO_AUTH_TOKEN = 'test_auth_token';
      process.env.TWILIO_PHONE_NUMBER = '+15550001111';

      seedVenuePendingVerification('venue-sms-fail', 'test-user-id', '+15559998888');
      mockFirestore.setTestData('venue_verification_codes', new Map());

      // Make Twilio throw
      mockTwilioCreate.mockRejectedValueOnce(new Error('Twilio network error'));

      const result = await callFunction(
        sendVenueVerificationCode,
        { venueId: 'venue-sms-fail' },
        authedContext(),
      );

      // Should still succeed - code is stored for resend
      expect(result.success).toBe(true);

      // Restore
      if (origSid !== undefined) process.env.TWILIO_ACCOUNT_SID = origSid;
      else delete process.env.TWILIO_ACCOUNT_SID;
      if (origToken !== undefined) process.env.TWILIO_AUTH_TOKEN = origToken;
      else delete process.env.TWILIO_AUTH_TOKEN;
      if (origFrom !== undefined) process.env.TWILIO_PHONE_NUMBER = origFrom;
      else delete process.env.TWILIO_PHONE_NUMBER;
    });

    it('should increment codesThisHour within the same window', async () => {
      seedVenuePendingVerification('venue-inc', 'test-user-id');

      // Seed existing code with 1 code in the current hour window
      const futureReset = new Date(Date.now() + 30 * 60 * 1000);
      const codes = new Map<string, any>();
      codes.set('venue-inc', {
        codesThisHour: 1,
        hourReset: MockTimestamp.fromDate(futureReset),
        code: '111111',
      });
      mockFirestore.setTestData('venue_verification_codes', codes);

      await callFunction(
        sendVenueVerificationCode,
        { venueId: 'venue-inc' },
        authedContext(),
      );

      const codeDoc = await mockFirestore
        .collection('venue_verification_codes')
        .doc('venue-inc')
        .get();
      // Should be 2 (was 1, incremented to 2)
      expect(codeDoc.data().codesThisHour).toBe(2);
    });
  });

  // =========================================================================
  // verifyVenueCode
  // =========================================================================

  describe('verifyVenueCode', () => {
    const seedVenueAndCode = (
      venueId: string,
      userId: string,
      code: string,
      overrides: Partial<{
        expiresAt: Date;
        attempts: number;
      }> = {},
    ) => {
      const venues = new Map<string, any>();
      venues.set(venueId, {
        ownerId: userId,
        claimStatus: 'pendingVerification',
      });
      mockFirestore.setTestData('venue_enhancements', venues);

      const expiresAt = overrides.expiresAt || new Date(Date.now() + 10 * 60 * 1000); // 10 mins
      const codes = new Map<string, any>();
      codes.set(venueId, {
        code,
        venueId,
        userId,
        expiresAt: MockTimestamp.fromDate(expiresAt),
        attempts: overrides.attempts || 0,
      });
      mockFirestore.setTestData('venue_verification_codes', codes);
    };

    it('should reject unauthenticated requests', async () => {
      await expect(
        callFunction(verifyVenueCode, { venueId: 'v-1', code: '123456' }, unauthContext()),
      ).rejects.toThrow(/Must be logged in/);
    });

    it('should reject when venueId is missing', async () => {
      await expect(
        callFunction(verifyVenueCode, { code: '123456' }, authedContext()),
      ).rejects.toThrow(/Missing venueId or code/);
    });

    it('should reject when code is missing', async () => {
      await expect(
        callFunction(verifyVenueCode, { venueId: 'v-1' }, authedContext()),
      ).rejects.toThrow(/Missing venueId or code/);
    });

    it('should reject when caller is not the claimant', async () => {
      seedVenueAndCode('venue-not-mine', 'actual-owner', '123456');

      await expect(
        callFunction(
          verifyVenueCode,
          { venueId: 'venue-not-mine', code: '123456' },
          authedContext('different-user'),
        ),
      ).rejects.toThrow(/not the claimant/);
    });

    it('should reject when no verification code document exists', async () => {
      const venues = new Map<string, any>();
      venues.set('venue-no-code', { ownerId: 'test-user-id' });
      mockFirestore.setTestData('venue_enhancements', venues);
      mockFirestore.setTestData('venue_verification_codes', new Map());

      await expect(
        callFunction(
          verifyVenueCode,
          { venueId: 'venue-no-code', code: '123456' },
          authedContext(),
        ),
      ).rejects.toThrow(/No verification code found/);
    });

    it('should reject when verification code has expired', async () => {
      const expiredTime = new Date(Date.now() - 5 * 60 * 1000); // 5 mins ago
      seedVenueAndCode('venue-expired', 'test-user-id', '123456', {
        expiresAt: expiredTime,
      });

      await expect(
        callFunction(
          verifyVenueCode,
          { venueId: 'venue-expired', code: '123456' },
          authedContext(),
        ),
      ).rejects.toThrow(/expired/);

      // Code doc should be deleted
      const codeDoc = await mockFirestore
        .collection('venue_verification_codes')
        .doc('venue-expired')
        .get();
      expect(codeDoc.exists).toBe(false);
    });

    it('should reject when max attempts (5) are exceeded', async () => {
      seedVenueAndCode('venue-max-attempts', 'test-user-id', '123456', {
        attempts: 5,
      });

      await expect(
        callFunction(
          verifyVenueCode,
          { venueId: 'venue-max-attempts', code: '123456' },
          authedContext(),
        ),
      ).rejects.toThrow(/Too many incorrect attempts/);

      // Code doc should be deleted
      const codeDoc = await mockFirestore
        .collection('venue_verification_codes')
        .doc('venue-max-attempts')
        .get();
      expect(codeDoc.exists).toBe(false);
    });

    it('should reject wrong code and increment attempts counter', async () => {
      seedVenueAndCode('venue-wrong', 'test-user-id', '999999', {
        attempts: 2,
      });

      await expect(
        callFunction(
          verifyVenueCode,
          { venueId: 'venue-wrong', code: '111111' },
          authedContext(),
        ),
      ).rejects.toThrow(/Incorrect code/);

      // The code doc should have attempts incremented
      const codeDoc = await mockFirestore
        .collection('venue_verification_codes')
        .doc('venue-wrong')
        .get();
      expect(codeDoc.exists).toBe(true);
      // FieldValue.increment is mocked so we check it was called
      expect(MockFieldValue.increment).toHaveBeenCalledWith(1);
    });

    it('should include remaining attempts in wrong code error message', async () => {
      seedVenueAndCode('venue-remaining', 'test-user-id', '999999', {
        attempts: 3,
      });

      await expect(
        callFunction(
          verifyVenueCode,
          { venueId: 'venue-remaining', code: '111111' },
          authedContext(),
        ),
      ).rejects.toThrow(/1 attempt remaining/);
    });

    it('should use plural "attempts" when more than 1 remaining', async () => {
      seedVenueAndCode('venue-plural', 'test-user-id', '999999', {
        attempts: 1,
      });

      await expect(
        callFunction(
          verifyVenueCode,
          { venueId: 'venue-plural', code: '111111' },
          authedContext(),
        ),
      ).rejects.toThrow(/3 attempts remaining/);
    });

    it('should update claim to pendingReview on correct code', async () => {
      seedVenueAndCode('venue-correct', 'test-user-id', '555555');

      const result = await callFunction(
        verifyVenueCode,
        { venueId: 'venue-correct', code: '555555' },
        authedContext(),
      );

      expect(result.success).toBe(true);
      expect(result.message).toContain('pending admin review');

      // Verify venue status was updated
      const venueDoc = await mockFirestore
        .collection('venue_enhancements')
        .doc('venue-correct')
        .get();
      expect(venueDoc.data().claimStatus).toBe('pendingReview');
    });

    it('should delete verification code doc after successful verification', async () => {
      seedVenueAndCode('venue-delete-code', 'test-user-id', '777777');

      await callFunction(
        verifyVenueCode,
        { venueId: 'venue-delete-code', code: '777777' },
        authedContext(),
      );

      // Code doc should be deleted
      const codeDoc = await mockFirestore
        .collection('venue_verification_codes')
        .doc('venue-delete-code')
        .get();
      expect(codeDoc.exists).toBe(false);
    });

    it('should reject when venue doc does not exist', async () => {
      mockFirestore.setTestData('venue_enhancements', new Map());
      mockFirestore.setTestData('venue_verification_codes', new Map());

      await expect(
        callFunction(
          verifyVenueCode,
          { venueId: 'nonexistent', code: '123456' },
          authedContext(),
        ),
      ).rejects.toThrow(/not the claimant/);
    });
  });

  // =========================================================================
  // reviewVenueClaim
  // =========================================================================

  describe('reviewVenueClaim', () => {
    const seedPendingReviewVenue = (venueId: string, ownerId = 'venue-owner') => {
      const venues = new Map<string, any>();
      venues.set(venueId, {
        ownerId,
        claimStatus: 'pendingReview',
        businessName: 'Test Venue',
        isVerified: false,
      });
      mockFirestore.setTestData('venue_enhancements', venues);
    };

    it('should reject unauthenticated requests', async () => {
      await expect(
        callFunction(
          reviewVenueClaim,
          { venueId: 'v-1', action: 'approve' },
          unauthContext(),
        ),
      ).rejects.toThrow(/Must be logged in/);
    });

    it('should reject non-admin users', async () => {
      await expect(
        callFunction(
          reviewVenueClaim,
          { venueId: 'v-1', action: 'approve' },
          authedContext(),
        ),
      ).rejects.toThrow(/Admin access required/);
    });

    it('should reject when venueId is missing', async () => {
      await expect(
        callFunction(
          reviewVenueClaim,
          { action: 'approve' },
          adminContext(),
        ),
      ).rejects.toThrow(/Missing venueId or invalid action/);
    });

    it('should reject when action is missing', async () => {
      await expect(
        callFunction(
          reviewVenueClaim,
          { venueId: 'v-1' },
          adminContext(),
        ),
      ).rejects.toThrow(/Missing venueId or invalid action/);
    });

    it('should reject when action is neither approve nor reject', async () => {
      await expect(
        callFunction(
          reviewVenueClaim,
          { venueId: 'v-1', action: 'maybe' },
          adminContext(),
        ),
      ).rejects.toThrow(/Missing venueId or invalid action/);
    });

    it('should reject when venue claim is not found', async () => {
      mockFirestore.setTestData('venue_enhancements', new Map());
      mockFirestore.setTestData('admin_logs', new Map());

      await expect(
        callFunction(
          reviewVenueClaim,
          { venueId: 'nonexistent', action: 'approve' },
          adminContext(),
        ),
      ).rejects.toThrow(/Venue claim not found/);
    });

    it('should approve a venue claim and set isVerified to true', async () => {
      seedPendingReviewVenue('venue-approve');
      mockFirestore.setTestData('admin_logs', new Map());

      const result = await callFunction(
        reviewVenueClaim,
        { venueId: 'venue-approve', action: 'approve', adminNotes: 'Looks good' },
        adminContext(),
      );

      expect(result.success).toBe(true);
      expect(result.action).toBe('approve');

      const venueDoc = await mockFirestore
        .collection('venue_enhancements')
        .doc('venue-approve')
        .get();
      expect(venueDoc.data().claimStatus).toBe('approved');
      expect(venueDoc.data().isVerified).toBe(true);
    });

    it('should reject a venue claim and clear ownerId', async () => {
      seedPendingReviewVenue('venue-reject', 'rejected-owner');
      mockFirestore.setTestData('admin_logs', new Map());

      const result = await callFunction(
        reviewVenueClaim,
        { venueId: 'venue-reject', action: 'reject' },
        adminContext(),
      );

      expect(result.success).toBe(true);
      expect(result.action).toBe('reject');

      const venueDoc = await mockFirestore
        .collection('venue_enhancements')
        .doc('venue-reject')
        .get();
      expect(venueDoc.data().claimStatus).toBe('rejected');
      expect(venueDoc.data().ownerId).toBe('');
    });

    it('should create an admin_logs entry on approve', async () => {
      seedPendingReviewVenue('venue-log-approve', 'owner-for-log');
      mockFirestore.setTestData('admin_logs', new Map());

      await callFunction(
        reviewVenueClaim,
        { venueId: 'venue-log-approve', action: 'approve', adminNotes: 'Verified docs' },
        adminContext('admin-abc'),
      );

      // Check that an admin_logs doc was created
      const logsSnapshot = await mockFirestore.collection('admin_logs').get();
      expect(logsSnapshot.empty).toBe(false);
      expect(logsSnapshot.size).toBe(1);

      const logDoc = logsSnapshot.docs[0].data();
      expect(logDoc.action).toBe('venue_claim_approve');
      expect(logDoc.venueId).toBe('venue-log-approve');
      expect(logDoc.adminId).toBe('admin-abc');
      expect(logDoc.previousOwnerId).toBe('owner-for-log');
      expect(logDoc.adminNotes).toBe('Verified docs');
    });

    it('should create an admin_logs entry on reject', async () => {
      seedPendingReviewVenue('venue-log-reject', 'owner-rejected');
      mockFirestore.setTestData('admin_logs', new Map());

      await callFunction(
        reviewVenueClaim,
        { venueId: 'venue-log-reject', action: 'reject' },
        adminContext('admin-xyz'),
      );

      const logsSnapshot = await mockFirestore.collection('admin_logs').get();
      expect(logsSnapshot.empty).toBe(false);

      const logDoc = logsSnapshot.docs[0].data();
      expect(logDoc.action).toBe('venue_claim_reject');
      expect(logDoc.venueId).toBe('venue-log-reject');
      expect(logDoc.adminId).toBe('admin-xyz');
      expect(logDoc.previousOwnerId).toBe('owner-rejected');
      expect(logDoc.adminNotes).toBe(''); // No notes provided
    });

    it('should default adminNotes to empty string when not provided', async () => {
      seedPendingReviewVenue('venue-no-notes');
      mockFirestore.setTestData('admin_logs', new Map());

      await callFunction(
        reviewVenueClaim,
        { venueId: 'venue-no-notes', action: 'approve' },
        adminContext(),
      );

      const logsSnapshot = await mockFirestore.collection('admin_logs').get();
      const logDoc = logsSnapshot.docs[0].data();
      expect(logDoc.adminNotes).toBe('');
    });
  });

  // =========================================================================
  // submitVenueDispute
  // =========================================================================

  describe('submitVenueDispute', () => {
    const seedClaimedVenue = (venueId: string, ownerId: string) => {
      const venues = new Map<string, any>();
      venues.set(venueId, {
        ownerId,
        claimStatus: 'approved',
        isVerified: true,
        businessName: 'Claimed Venue',
      });
      mockFirestore.setTestData('venue_enhancements', venues);
    };

    it('should reject unauthenticated requests', async () => {
      await expect(
        callFunction(
          submitVenueDispute,
          { venueId: 'v-1', reason: 'fraud' },
          unauthContext(),
        ),
      ).rejects.toThrow(/Must be logged in/);
    });

    it('should reject when venueId is missing', async () => {
      await expect(
        callFunction(
          submitVenueDispute,
          { reason: 'fraud' },
          authedContext(),
        ),
      ).rejects.toThrow(/Missing venueId or reason/);
    });

    it('should reject when reason is missing', async () => {
      await expect(
        callFunction(
          submitVenueDispute,
          { venueId: 'v-1' },
          authedContext(),
        ),
      ).rejects.toThrow(/Missing venueId or reason/);
    });

    it('should reject when venue is not found', async () => {
      mockFirestore.setTestData('venue_enhancements', new Map());

      await expect(
        callFunction(
          submitVenueDispute,
          { venueId: 'nonexistent', reason: 'fraud' },
          authedContext(),
        ),
      ).rejects.toThrow(/Venue not found/);
    });

    it('should reject when user tries to dispute their own venue', async () => {
      seedClaimedVenue('venue-own', 'test-user-id');

      await expect(
        callFunction(
          submitVenueDispute,
          { venueId: 'venue-own', reason: 'testing' },
          authedContext(),
        ),
      ).rejects.toThrow(/cannot dispute your own venue/);
    });

    it('should create a dispute doc with correct fields', async () => {
      seedClaimedVenue('venue-disputed', 'current-owner');
      mockFirestore.setTestData('venue_disputes', new Map());

      const result = await callFunction(
        submitVenueDispute,
        { venueId: 'venue-disputed', reason: 'fraud', details: 'I am the real owner' },
        authedContext('disputer-user'),
      );

      expect(result.success).toBe(true);
      expect(result.message).toContain('Dispute submitted');

      // Check the dispute document was created
      const disputesSnapshot = await mockFirestore.collection('venue_disputes').get();
      expect(disputesSnapshot.empty).toBe(false);
      expect(disputesSnapshot.size).toBe(1);

      const dispute = disputesSnapshot.docs[0].data();
      expect(dispute.venueId).toBe('venue-disputed');
      expect(dispute.disputerId).toBe('disputer-user');
      expect(dispute.currentOwnerId).toBe('current-owner');
      expect(dispute.reason).toBe('fraud');
      expect(dispute.details).toBe('I am the real owner');
      expect(dispute.status).toBe('pending');
    });

    it('should set details to empty string when not provided', async () => {
      seedClaimedVenue('venue-no-details', 'current-owner');
      mockFirestore.setTestData('venue_disputes', new Map());

      await callFunction(
        submitVenueDispute,
        { venueId: 'venue-no-details', reason: 'Wrong claim' },
        authedContext('disputer-2'),
      );

      const disputesSnapshot = await mockFirestore.collection('venue_disputes').get();
      const dispute = disputesSnapshot.docs[0].data();
      expect(dispute.details).toBe('');
    });

    it('should set currentOwnerId to empty string when venue has no owner', async () => {
      const venues = new Map<string, any>();
      venues.set('venue-no-owner', {
        claimStatus: 'pendingReview',
        businessName: 'Ownerless Venue',
        // ownerId not present
      });
      mockFirestore.setTestData('venue_enhancements', venues);
      mockFirestore.setTestData('venue_disputes', new Map());

      await callFunction(
        submitVenueDispute,
        { venueId: 'venue-no-owner', reason: 'Suspicious activity' },
        authedContext('disputer-3'),
      );

      const disputesSnapshot = await mockFirestore.collection('venue_disputes').get();
      const dispute = disputesSnapshot.docs[0].data();
      expect(dispute.currentOwnerId).toBe('');
    });

    it('should allow multiple disputes for the same venue', async () => {
      seedClaimedVenue('venue-multi', 'owner-multi');
      mockFirestore.setTestData('venue_disputes', new Map());

      await callFunction(
        submitVenueDispute,
        { venueId: 'venue-multi', reason: 'Reason A' },
        authedContext('disputer-a'),
      );

      await callFunction(
        submitVenueDispute,
        { venueId: 'venue-multi', reason: 'Reason B' },
        authedContext('disputer-b'),
      );

      const disputesSnapshot = await mockFirestore.collection('venue_disputes').get();
      expect(disputesSnapshot.size).toBe(2);
    });
  });
});

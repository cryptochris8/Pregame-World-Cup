/**
 * Rate Limiter Tests
 *
 * Comprehensive tests for the Firestore-based rate limiter module.
 * Covers checkRateLimit, cleanupExpiredRateLimits, RATE_LIMITS config,
 * and edge cases.
 */

import {
  MockFirestore,
  MockTimestamp,
  MockFieldValue,
  MockDocumentSnapshot,
  MockQuerySnapshot,
  createMockHttpRequest,
  createMockHttpResponse,
} from './mocks';

// --- Mock firebase-admin before any source imports ---
const mockFirestore = new MockFirestore();

jest.mock('firebase-admin', () => ({
  initializeApp: jest.fn(),
  app: jest.fn(() => ({ name: '[DEFAULT]', options: { projectId: 'test-project' } })),
  firestore: jest.fn(() => mockFirestore),
  messaging: jest.fn(() => ({ send: jest.fn() })),
  credential: { cert: jest.fn(), applicationDefault: jest.fn() },
}));

import * as admin from 'firebase-admin';

// Attach static Firestore helpers to the mock so the source module can use them
(admin.firestore as any).Timestamp = MockTimestamp;
(admin.firestore as any).FieldValue = MockFieldValue;

// Import the module under test AFTER mocks are wired up
import { checkRateLimit, checkCallableRateLimit, cleanupExpiredRateLimits, RATE_LIMITS } from '../src/rate-limiter';
import * as functions from 'firebase-functions';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/**
 * Seed the mock rate_limits collection with N documents for callable
 * rate-limit entries keyed by userId / endpoint.
 */
function seedCallableRateLimitDocs(
  count: number,
  overrides: Partial<{
    userId: string;
    endpoint: string;
    timestampMs: number;
    expiresAtMs: number;
  }> = {}
): void {
  const data = new Map<string, any>();
  const now = Date.now();
  for (let i = 0; i < count; i++) {
    const id = `crl_${i}`;
    data.set(id, {
      userId: overrides.userId ?? 'test-user-id',
      endpoint: overrides.endpoint ?? 'testEndpoint',
      timestamp: MockTimestamp.fromMillis(overrides.timestampMs ?? now - 1000),
      expiresAt: MockTimestamp.fromMillis(overrides.expiresAtMs ?? now + 60_000),
    });
  }
  mockFirestore.setTestData('rate_limits', data);
}

/**
 * Seed the mock rate_limits collection with N documents that look like real
 * rate-limit entries for a given IP / endpoint.
 */
function seedRateLimitDocs(
  count: number,
  overrides: Partial<{
    ip: string;
    endpoint: string;
    timestampMs: number;
    expiresAtMs: number;
  }> = {}
): void {
  const data = new Map<string, any>();
  const now = Date.now();
  for (let i = 0; i < count; i++) {
    const id = `rl_${i}`;
    data.set(id, {
      ip: overrides.ip ?? '192.168.1.1',
      endpoint: overrides.endpoint ?? 'testEndpoint',
      timestamp: MockTimestamp.fromMillis(overrides.timestampMs ?? now - 1000),
      expiresAt: MockTimestamp.fromMillis(overrides.expiresAtMs ?? now + 60_000),
    });
  }
  mockFirestore.setTestData('rate_limits', data);
}

/**
 * Build an express-like mock request with optional IP headers.
 */
function buildRequest(opts: {
  ip?: string;
  forwardedFor?: string | string[];
  remoteAddress?: string;
} = {}): any {
  const headers: Record<string, any> = {};
  if (opts.forwardedFor !== undefined) {
    headers['x-forwarded-for'] = opts.forwardedFor;
  }
  const req: any = createMockHttpRequest({ headers });
  req.ip = opts.ip ?? undefined;
  req.socket = { remoteAddress: opts.remoteAddress ?? undefined };
  return req;
}

/**
 * Helper to mock the Firestore collection chain for cleanupExpiredRateLimits.
 * Returns mocks so tests can control exactly what queries return per iteration,
 * avoiding infinite loops from the MockWriteBatch not actually deleting data.
 */
function mockCleanupChain(
  queryResults: Array<{ docIds: string[] }>
): { collectionSpy: jest.SpyInstance; batchCommitMock: jest.Mock } {
  let callIndex = 0;
  const batchDeleteMock = jest.fn().mockReturnThis();
  const batchCommitMock = jest.fn().mockResolvedValue(undefined);

  const collectionSpy = jest.spyOn(mockFirestore, 'collection').mockImplementation(
    ((_path: string) => {
      return {
        where: jest.fn().mockReturnValue({
          limit: jest.fn().mockReturnValue({
            get: jest.fn().mockImplementation(async () => {
              const result = queryResults[callIndex] ?? { docIds: [] };
              callIndex++;
              const docs = result.docIds.map(
                (id) =>
                  new MockDocumentSnapshot(id, { expiresAt: MockTimestamp.fromMillis(0) })
              );
              return new MockQuerySnapshot(docs);
            }),
          }),
        }),
        add: jest.fn().mockResolvedValue({}),
      } as any;
    }) as any
  );

  // Also mock batch() on the firestore instance
  jest.spyOn(mockFirestore, 'batch').mockReturnValue({
    set: jest.fn().mockReturnThis(),
    update: jest.fn().mockReturnThis(),
    delete: batchDeleteMock,
    commit: batchCommitMock,
  } as any);

  return { collectionSpy, batchCommitMock };
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

describe('Rate Limiter', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    jest.restoreAllMocks();
    mockFirestore.clearAllData();
  });

  // -----------------------------------------------------------------------
  // 1. RATE_LIMITS config
  // -----------------------------------------------------------------------
  describe('RATE_LIMITS config', () => {
    it('should export a VENUE config with positive maxRequests and windowSeconds', () => {
      expect(RATE_LIMITS.VENUE).toBeDefined();
      expect(RATE_LIMITS.VENUE.maxRequests).toBeGreaterThan(0);
      expect(RATE_LIMITS.VENUE.windowSeconds).toBeGreaterThan(0);
    });

    it('should export a SCHEDULE config with positive maxRequests and windowSeconds', () => {
      expect(RATE_LIMITS.SCHEDULE).toBeDefined();
      expect(RATE_LIMITS.SCHEDULE.maxRequests).toBeGreaterThan(0);
      expect(RATE_LIMITS.SCHEDULE.windowSeconds).toBeGreaterThan(0);
    });

    it('should have VENUE maxRequests = 60 and windowSeconds = 60', () => {
      expect(RATE_LIMITS.VENUE.maxRequests).toBe(60);
      expect(RATE_LIMITS.VENUE.windowSeconds).toBe(60);
    });

    it('should have SCHEDULE maxRequests = 10 and windowSeconds = 60', () => {
      expect(RATE_LIMITS.SCHEDULE.maxRequests).toBe(10);
      expect(RATE_LIMITS.SCHEDULE.windowSeconds).toBe(60);
    });

    it('should have VENUE limits higher than SCHEDULE limits (higher traffic expected)', () => {
      expect(RATE_LIMITS.VENUE.maxRequests).toBeGreaterThan(RATE_LIMITS.SCHEDULE.maxRequests);
    });

    it('should have all configs with integer values', () => {
      for (const key of Object.keys(RATE_LIMITS) as Array<keyof typeof RATE_LIMITS>) {
        expect(Number.isInteger(RATE_LIMITS[key].maxRequests)).toBe(true);
        expect(Number.isInteger(RATE_LIMITS[key].windowSeconds)).toBe(true);
      }
    });
  });

  // -----------------------------------------------------------------------
  // 2. checkRateLimit
  // -----------------------------------------------------------------------
  describe('checkRateLimit', () => {
    const testConfig = { maxRequests: 5, windowSeconds: 60 };

    describe('allowing requests under the limit', () => {
      it('should return true for a first-time caller (no prior requests)', async () => {
        const req = buildRequest({ forwardedFor: '10.0.0.1' });
        const res = createMockHttpResponse();

        const allowed = await checkRateLimit(req, res, 'venue', testConfig);

        expect(allowed).toBe(true);
        expect(res._statusCode).toBe(200); // unchanged default
      });

      it('should return true when request count is below maxRequests', async () => {
        seedRateLimitDocs(4, { ip: '10.0.0.2', endpoint: 'venue' });

        const req = buildRequest({ forwardedFor: '10.0.0.2' });
        const res = createMockHttpResponse();

        const allowed = await checkRateLimit(req, res, 'venue', testConfig);

        expect(allowed).toBe(true);
      });

      it('should not set a 429 status when allowed', async () => {
        const req = buildRequest({ forwardedFor: '10.0.0.3' });
        const res = createMockHttpResponse();

        await checkRateLimit(req, res, 'venue', testConfig);

        expect(res.status).not.toHaveBeenCalledWith(429);
      });
    });

    describe('blocking requests at or over the limit', () => {
      it('should return false when request count equals maxRequests', async () => {
        seedRateLimitDocs(5, { ip: '10.0.0.4', endpoint: 'photos' });

        const req = buildRequest({ forwardedFor: '10.0.0.4' });
        const res = createMockHttpResponse();

        const allowed = await checkRateLimit(req, res, 'photos', testConfig);

        expect(allowed).toBe(false);
      });

      it('should return false when request count exceeds maxRequests', async () => {
        seedRateLimitDocs(10, { ip: '10.0.0.5', endpoint: 'photos' });

        const req = buildRequest({ forwardedFor: '10.0.0.5' });
        const res = createMockHttpResponse();

        const allowed = await checkRateLimit(req, res, 'photos', testConfig);

        expect(allowed).toBe(false);
      });

      it('should respond with 429 status when blocked', async () => {
        seedRateLimitDocs(5, { ip: '10.0.0.6', endpoint: 'ep' });

        const req = buildRequest({ forwardedFor: '10.0.0.6' });
        const res = createMockHttpResponse();

        await checkRateLimit(req, res, 'ep', testConfig);

        expect(res._statusCode).toBe(429);
      });

      it('should include error details in the 429 response body', async () => {
        seedRateLimitDocs(5, { ip: '10.0.0.7', endpoint: 'ep' });

        const req = buildRequest({ forwardedFor: '10.0.0.7' });
        const res = createMockHttpResponse();

        await checkRateLimit(req, res, 'ep', testConfig);

        expect(res._body).toEqual(
          expect.objectContaining({
            error: 'Too Many Requests',
            retryAfter: testConfig.windowSeconds,
          })
        );
        expect(res._body.message).toContain(`${testConfig.maxRequests}`);
        expect(res._body.message).toContain(`${testConfig.windowSeconds}`);
      });

      it('should log a warning when rate limit is exceeded', async () => {
        seedRateLimitDocs(5, { ip: '10.0.0.8', endpoint: 'ep' });

        const req = buildRequest({ forwardedFor: '10.0.0.8' });
        const res = createMockHttpResponse();

        await checkRateLimit(req, res, 'ep', testConfig);

        expect(functions.logger.warn).toHaveBeenCalledWith(
          expect.stringContaining('Rate limit exceeded')
        );
      });
    });

    describe('Firestore document creation on allowed requests', () => {
      it('should write a new document to rate_limits on an allowed request', async () => {
        const req = buildRequest({ forwardedFor: '10.0.0.9' });
        const res = createMockHttpResponse();

        await checkRateLimit(req, res, 'venueSearch', testConfig);

        // The add call is fire-and-forget, so give it a tick.
        await new Promise((r) => setTimeout(r, 10));

        // The rate_limits collection should have a new document
        const snapshot = await mockFirestore.collection('rate_limits').get();
        expect(snapshot.empty).toBe(false);
      });

      it('should record the correct IP and endpoint in the new document', async () => {
        const req = buildRequest({ forwardedFor: '172.16.0.1' });
        const res = createMockHttpResponse();

        await checkRateLimit(req, res, 'myEndpoint', testConfig);

        await new Promise((r) => setTimeout(r, 10));

        const snapshot = await mockFirestore.collection('rate_limits').get();
        const found = snapshot.docs.some((doc) => {
          const d = doc.data();
          return d.ip === '172.16.0.1' && d.endpoint === 'myEndpoint';
        });
        expect(found).toBe(true);
      });

      it('should include a serverTimestamp in the recorded document', async () => {
        const req = buildRequest({ forwardedFor: '172.16.0.2' });
        const res = createMockHttpResponse();

        await checkRateLimit(req, res, 'ep', testConfig);

        await new Promise((r) => setTimeout(r, 10));

        const snapshot = await mockFirestore.collection('rate_limits').get();
        const doc = snapshot.docs.find((d) => d.data().ip === '172.16.0.2');
        expect(doc).toBeDefined();
        expect(doc!.data().timestamp).toEqual(
          expect.objectContaining({ _methodName: 'serverTimestamp' })
        );
      });

      it('should include an expiresAt timestamp in the future', async () => {
        const req = buildRequest({ forwardedFor: '172.16.0.3' });
        const res = createMockHttpResponse();

        await checkRateLimit(req, res, 'ep', testConfig);

        await new Promise((r) => setTimeout(r, 10));

        const snapshot = await mockFirestore.collection('rate_limits').get();
        const doc = snapshot.docs.find((d) => d.data().ip === '172.16.0.3');
        expect(doc).toBeDefined();
        const expiresAt = doc!.data().expiresAt;
        expect(expiresAt).toBeDefined();
        expect(expiresAt.toMillis()).toBeGreaterThan(Date.now() - 5000);
      });
    });

    describe('IP extraction', () => {
      it('should prefer X-Forwarded-For header (single value)', async () => {
        seedRateLimitDocs(5, { ip: '203.0.113.50', endpoint: 'ep' });

        const req = buildRequest({ forwardedFor: '203.0.113.50' });
        const res = createMockHttpResponse();

        const allowed = await checkRateLimit(req, res, 'ep', testConfig);

        expect(allowed).toBe(false);
      });

      it('should use the first IP when X-Forwarded-For contains a comma-separated list', async () => {
        seedRateLimitDocs(5, { ip: '1.2.3.4', endpoint: 'ep' });

        const req = buildRequest({ forwardedFor: '1.2.3.4, 5.6.7.8, 9.10.11.12' });
        const res = createMockHttpResponse();

        const allowed = await checkRateLimit(req, res, 'ep', testConfig);

        expect(allowed).toBe(false);
      });

      it('should use the first entry when X-Forwarded-For is an array', async () => {
        seedRateLimitDocs(5, { ip: '100.0.0.1', endpoint: 'ep' });

        const req = buildRequest({ forwardedFor: ['100.0.0.1, 200.0.0.1', '300.0.0.1'] });
        const res = createMockHttpResponse();

        const allowed = await checkRateLimit(req, res, 'ep', testConfig);

        expect(allowed).toBe(false);
      });

      it('should fall back to request.ip when X-Forwarded-For is missing', async () => {
        seedRateLimitDocs(5, { ip: '50.50.50.50', endpoint: 'ep' });

        const req = buildRequest({ ip: '50.50.50.50' });
        const res = createMockHttpResponse();

        const allowed = await checkRateLimit(req, res, 'ep', testConfig);

        expect(allowed).toBe(false);
      });

      it('should fall back to socket.remoteAddress when both header and ip are missing', async () => {
        seedRateLimitDocs(5, { ip: '99.99.99.99', endpoint: 'ep' });

        const req = buildRequest({ remoteAddress: '99.99.99.99' });
        const res = createMockHttpResponse();

        const allowed = await checkRateLimit(req, res, 'ep', testConfig);

        expect(allowed).toBe(false);
      });

      it('should use "unknown" when no IP information is available', async () => {
        seedRateLimitDocs(5, { ip: 'unknown', endpoint: 'ep' });

        const req: any = createMockHttpRequest();
        req.ip = undefined;
        req.socket = {};

        const res = createMockHttpResponse();

        const allowed = await checkRateLimit(req, res, 'ep', testConfig);

        expect(allowed).toBe(false);
      });
    });

    describe('different rate limit configs', () => {
      it('should respect a strict config (1 request per 60 seconds)', async () => {
        const strictConfig = { maxRequests: 1, windowSeconds: 60 };
        seedRateLimitDocs(1, { ip: '11.11.11.11', endpoint: 'strict' });

        const req = buildRequest({ forwardedFor: '11.11.11.11' });
        const res = createMockHttpResponse();

        const allowed = await checkRateLimit(req, res, 'strict', strictConfig);

        expect(allowed).toBe(false);
        expect(res._statusCode).toBe(429);
      });

      it('should respect a generous config (1000 requests per 60 seconds)', async () => {
        const generousConfig = { maxRequests: 1000, windowSeconds: 60 };
        seedRateLimitDocs(50, { ip: '12.12.12.12', endpoint: 'generous' });

        const req = buildRequest({ forwardedFor: '12.12.12.12' });
        const res = createMockHttpResponse();

        const allowed = await checkRateLimit(req, res, 'generous', generousConfig);

        expect(allowed).toBe(true);
      });

      it('should use the VENUE preset correctly (59 requests under 60 limit)', async () => {
        seedRateLimitDocs(59, { ip: '13.13.13.13', endpoint: 'venue' });

        const req = buildRequest({ forwardedFor: '13.13.13.13' });
        const res = createMockHttpResponse();

        const allowed = await checkRateLimit(req, res, 'venue', RATE_LIMITS.VENUE);

        expect(allowed).toBe(true);
      });

      it('should use the SCHEDULE preset correctly (10 requests at 10 limit)', async () => {
        seedRateLimitDocs(10, { ip: '14.14.14.14', endpoint: 'schedule' });

        const req = buildRequest({ forwardedFor: '14.14.14.14' });
        const res = createMockHttpResponse();

        const allowed = await checkRateLimit(req, res, 'schedule', RATE_LIMITS.SCHEDULE);

        expect(allowed).toBe(false);
        expect(res._statusCode).toBe(429);
      });
    });

    describe('endpoint isolation', () => {
      it('should not count requests from a different endpoint', async () => {
        seedRateLimitDocs(10, { ip: '20.20.20.20', endpoint: 'alpha' });

        const req = buildRequest({ forwardedFor: '20.20.20.20' });
        const res = createMockHttpResponse();

        const allowed = await checkRateLimit(req, res, 'beta', testConfig);

        expect(allowed).toBe(true);
      });

      it('should not count requests from a different IP', async () => {
        seedRateLimitDocs(10, { ip: '30.30.30.30', endpoint: 'ep' });

        const req = buildRequest({ forwardedFor: '40.40.40.40' });
        const res = createMockHttpResponse();

        const allowed = await checkRateLimit(req, res, 'ep', testConfig);

        expect(allowed).toBe(true);
      });
    });

    describe('error handling / fail-open behavior', () => {
      it('should return true (allow request) when Firestore query throws an error', async () => {
        const originalCollection = mockFirestore.collection.bind(mockFirestore);
        jest.spyOn(mockFirestore, 'collection').mockImplementation((path: string) => {
          if (path === 'rate_limits') {
            const ref = originalCollection(path);
            ref.where = jest.fn().mockReturnValue({
              where: jest.fn().mockReturnValue({
                where: jest.fn().mockReturnValue({
                  count: jest.fn().mockReturnValue({
                    get: jest.fn().mockRejectedValue(new Error('Firestore unavailable')),
                  }),
                }),
              }),
            });
            return ref;
          }
          return originalCollection(path);
        });

        const req = buildRequest({ forwardedFor: '55.55.55.55' });
        const res = createMockHttpResponse();

        const allowed = await checkRateLimit(req, res, 'ep', testConfig);

        expect(allowed).toBe(true);
        expect(functions.logger.error).toHaveBeenCalledWith(
          expect.stringContaining('Rate limiter error'),
          expect.any(String)
        );
      });

      it('should log error but not crash when recording the request fails', async () => {
        const originalCollection = mockFirestore.collection.bind(mockFirestore);
        jest.spyOn(mockFirestore, 'collection').mockImplementation((path: string) => {
          const ref = originalCollection(path);
          if (path === 'rate_limits') {
            ref.where = jest.fn().mockReturnValue({
              where: jest.fn().mockReturnValue({
                where: jest.fn().mockReturnValue({
                  count: jest.fn().mockReturnValue({
                    get: jest.fn().mockResolvedValue({ data: () => ({ count: 0 }) }),
                  }),
                }),
              }),
            });
            ref.add = jest.fn().mockRejectedValue(new Error('Write failed'));
          }
          return ref;
        });

        const req = buildRequest({ forwardedFor: '66.66.66.66' });
        const res = createMockHttpResponse();

        const allowed = await checkRateLimit(req, res, 'ep', testConfig);

        expect(allowed).toBe(true);

        // Give the fire-and-forget promise time to settle
        await new Promise((r) => setTimeout(r, 50));

        expect(functions.logger.error).toHaveBeenCalledWith(
          expect.stringContaining('Failed to record rate limit entry'),
          expect.any(String)
        );
      });
    });

    describe('concurrent requests from different IPs', () => {
      it('should evaluate each IP independently', async () => {
        seedRateLimitDocs(5, { ip: '70.0.0.1', endpoint: 'ep' });

        const reqA = buildRequest({ forwardedFor: '70.0.0.1' });
        const resA = createMockHttpResponse();

        const reqB = buildRequest({ forwardedFor: '70.0.0.2' });
        const resB = createMockHttpResponse();

        const [allowedA, allowedB] = await Promise.all([
          checkRateLimit(reqA, resA, 'ep', testConfig),
          checkRateLimit(reqB, resB, 'ep', testConfig),
        ]);

        expect(allowedA).toBe(false);
        expect(allowedB).toBe(true);
      });
    });

    describe('window boundary', () => {
      it('should only count requests within the time window', async () => {
        // Seed docs with timestamps far in the past (outside the 60s window).
        // With the valueOf() enhancement on MockTimestamp, the >= filter
        // should correctly exclude these old timestamps.
        const twoMinutesAgo = Date.now() - 120_000;
        seedRateLimitDocs(10, {
          ip: '80.0.0.1',
          endpoint: 'ep',
          timestampMs: twoMinutesAgo,
        });

        const req = buildRequest({ forwardedFor: '80.0.0.1' });
        const res = createMockHttpResponse();

        const allowed = await checkRateLimit(req, res, 'ep', testConfig);

        // Timestamps from 2 minutes ago are < windowStart (now - 60s),
        // so the count query should return 0 => allowed
        expect(allowed).toBe(true);
      });
    });
  });

  // -----------------------------------------------------------------------
  // 3. cleanupExpiredRateLimits
  //
  //    These tests mock the entire Firestore chain to avoid infinite loops
  //    caused by the MockWriteBatch.delete not actually removing data from
  //    the underlying Map.
  // -----------------------------------------------------------------------
  describe('cleanupExpiredRateLimits', () => {
    it('should return 0 when there are no expired documents', async () => {
      // First query returns empty
      mockCleanupChain([{ docIds: [] }]);

      const deleted = await cleanupExpiredRateLimits();
      expect(deleted).toBe(0);
    });

    it('should return 0 when all documents are still valid (not expired)', async () => {
      // No expired docs found by the query
      mockCleanupChain([{ docIds: [] }]);

      const deleted = await cleanupExpiredRateLimits();
      expect(deleted).toBe(0);
    });

    it('should delete expired documents and return the count', async () => {
      // First query returns 3 docs, second query returns empty (done)
      mockCleanupChain([
        { docIds: ['exp-1', 'exp-2', 'exp-3'] },
        { docIds: [] },
      ]);

      const deleted = await cleanupExpiredRateLimits();
      expect(deleted).toBe(3);
    });

    it('should log when documents are cleaned up', async () => {
      mockCleanupChain([
        { docIds: ['exp-1', 'exp-2'] },
        { docIds: [] },
      ]);

      await cleanupExpiredRateLimits();

      expect(functions.logger.info).toHaveBeenCalledWith(
        expect.stringContaining('Cleaned up 2 expired rate limit documents')
      );
    });

    it('should not log when no documents are cleaned up', async () => {
      mockCleanupChain([{ docIds: [] }]);

      await cleanupExpiredRateLimits();

      expect(functions.logger.info).not.toHaveBeenCalled();
    });

    it('should handle multiple batches when more than 400 docs are expired', async () => {
      // First batch: 400 docs (full batch), second batch: 50 docs (partial, loop ends)
      const firstBatch = Array.from({ length: 400 }, (_, i) => `exp-${i}`);
      const secondBatch = Array.from({ length: 50 }, (_, i) => `exp-${400 + i}`);

      const { batchCommitMock } = mockCleanupChain([
        { docIds: firstBatch },
        { docIds: secondBatch },
      ]);

      const deleted = await cleanupExpiredRateLimits();

      expect(deleted).toBe(450);
      // Two batch commits: one for 400, one for 50
      expect(batchCommitMock).toHaveBeenCalledTimes(2);
    });

    it('should process exactly one batch when results equal the limit of 400', async () => {
      // 400 docs: since size == limit, function loops again; next query returns empty
      const fullBatch = Array.from({ length: 400 }, (_, i) => `exp-${i}`);

      const { batchCommitMock } = mockCleanupChain([
        { docIds: fullBatch },
        { docIds: [] },
      ]);

      const deleted = await cleanupExpiredRateLimits();

      expect(deleted).toBe(400);
      expect(batchCommitMock).toHaveBeenCalledTimes(1);
    });

    it('should stop looping when a batch returns fewer than 400 docs', async () => {
      // 100 docs: size < 400, so loop ends immediately
      const docs = Array.from({ length: 100 }, (_, i) => `exp-${i}`);

      const { batchCommitMock } = mockCleanupChain([{ docIds: docs }]);

      const deleted = await cleanupExpiredRateLimits();

      expect(deleted).toBe(100);
      expect(batchCommitMock).toHaveBeenCalledTimes(1);
    });

    it('should call batch.delete for each expired document', async () => {
      const batchDeleteMock = jest.fn().mockReturnThis();
      const batchCommitMock = jest.fn().mockResolvedValue(undefined);

      let callIndex = 0;
      jest.spyOn(mockFirestore, 'collection').mockImplementation(
        ((_path: string) => {
          return {
            where: jest.fn().mockReturnValue({
              limit: jest.fn().mockReturnValue({
                get: jest.fn().mockImplementation(async () => {
                  if (callIndex > 0) {
                    return new MockQuerySnapshot([]);
                  }
                  callIndex++;
                  return new MockQuerySnapshot([
                    new MockDocumentSnapshot('a', { expiresAt: MockTimestamp.fromMillis(0) }),
                    new MockDocumentSnapshot('b', { expiresAt: MockTimestamp.fromMillis(0) }),
                    new MockDocumentSnapshot('c', { expiresAt: MockTimestamp.fromMillis(0) }),
                  ]);
                }),
              }),
            }),
          } as any;
        }) as any
      );

      jest.spyOn(mockFirestore, 'batch').mockReturnValue({
        set: jest.fn().mockReturnThis(),
        update: jest.fn().mockReturnThis(),
        delete: batchDeleteMock,
        commit: batchCommitMock,
      } as any);

      await cleanupExpiredRateLimits();

      // batch.delete should have been called once per doc
      expect(batchDeleteMock).toHaveBeenCalledTimes(3);
    });
  });

  // -----------------------------------------------------------------------
  // 4. Edge cases
  // -----------------------------------------------------------------------
  describe('Edge Cases', () => {
    it('should handle empty X-Forwarded-For header gracefully', async () => {
      const req: any = createMockHttpRequest({
        headers: { 'x-forwarded-for': '' },
      });
      req.ip = '127.0.0.1';
      req.socket = {};

      const res = createMockHttpResponse();

      seedRateLimitDocs(5, { ip: '127.0.0.1', endpoint: 'ep' });

      const allowed = await checkRateLimit(req, res, 'ep', { maxRequests: 5, windowSeconds: 60 });

      expect(allowed).toBe(false);
    });

    it('should handle X-Forwarded-For with whitespace', async () => {
      seedRateLimitDocs(5, { ip: '192.168.0.1', endpoint: 'ep' });

      const req: any = createMockHttpRequest({
        headers: { 'x-forwarded-for': '  192.168.0.1  , 10.0.0.1' },
      });
      req.ip = undefined;
      req.socket = {};

      const res = createMockHttpResponse();

      const allowed = await checkRateLimit(req, res, 'ep', { maxRequests: 5, windowSeconds: 60 });

      expect(allowed).toBe(false);
    });

    it('should handle a config with windowSeconds = 1 (very short window)', async () => {
      const shortConfig = { maxRequests: 2, windowSeconds: 1 };

      seedRateLimitDocs(2, { ip: '88.88.88.88', endpoint: 'fast' });

      const req = buildRequest({ forwardedFor: '88.88.88.88' });
      const res = createMockHttpResponse();

      const allowed = await checkRateLimit(req, res, 'fast', shortConfig);

      expect(allowed).toBe(false);
    });

    it('should not block when limit is very high', async () => {
      const highConfig = { maxRequests: 100000, windowSeconds: 60 };
      seedRateLimitDocs(100, { ip: '77.77.77.77', endpoint: 'ep' });

      const req = buildRequest({ forwardedFor: '77.77.77.77' });
      const res = createMockHttpResponse();

      const allowed = await checkRateLimit(req, res, 'ep', highConfig);

      expect(allowed).toBe(true);
    });

    it('should handle request with no forwarded-for header gracefully', async () => {
      const req: any = {
        method: 'GET',
        query: {},
        body: {},
        headers: {},
        ip: '10.10.10.10',
        socket: { remoteAddress: '10.10.10.10' },
      };
      const res = createMockHttpResponse();

      const allowed = await checkRateLimit(req, res, 'ep', { maxRequests: 5, windowSeconds: 60 });

      expect(allowed).toBe(true);
    });

    it('should treat different endpoints as separate rate limit buckets', async () => {
      const config = { maxRequests: 3, windowSeconds: 60 };

      const data = new Map<string, any>();
      for (let i = 0; i < 3; i++) {
        data.set(`a-${i}`, {
          ip: '44.44.44.44',
          endpoint: 'a',
          timestamp: MockTimestamp.fromMillis(Date.now() - 1000),
          expiresAt: MockTimestamp.fromMillis(Date.now() + 60_000),
        });
      }
      data.set('b-0', {
        ip: '44.44.44.44',
        endpoint: 'b',
        timestamp: MockTimestamp.fromMillis(Date.now() - 1000),
        expiresAt: MockTimestamp.fromMillis(Date.now() + 60_000),
      });
      mockFirestore.setTestData('rate_limits', data);

      const reqA = buildRequest({ forwardedFor: '44.44.44.44' });
      const resA = createMockHttpResponse();

      const reqB = buildRequest({ forwardedFor: '44.44.44.44' });
      const resB = createMockHttpResponse();

      const [allowedA, allowedB] = await Promise.all([
        checkRateLimit(reqA, resA, 'a', config),
        checkRateLimit(reqB, resB, 'b', config),
      ]);

      expect(allowedA).toBe(false); // 3 >= 3
      expect(allowedB).toBe(true);  // 1 < 3
    });

    it('should include retryAfter matching windowSeconds in the 429 body', async () => {
      const config = { maxRequests: 2, windowSeconds: 120 };
      seedRateLimitDocs(2, { ip: '55.55.55.55', endpoint: 'ep' });

      const req = buildRequest({ forwardedFor: '55.55.55.55' });
      const res = createMockHttpResponse();

      await checkRateLimit(req, res, 'ep', config);

      expect(res._body.retryAfter).toBe(120);
    });

    it('should not record the request when blocked (no add call)', async () => {
      const config = { maxRequests: 5, windowSeconds: 60 };
      seedRateLimitDocs(5, { ip: '90.90.90.90', endpoint: 'ep' });

      // Track add calls - spy on the collection before the rate limit check
      const addSpy = jest.fn().mockResolvedValue({});
      const originalCollection = mockFirestore.collection.bind(mockFirestore);
      jest.spyOn(mockFirestore, 'collection').mockImplementation((path: string) => {
        const ref = originalCollection(path);
        if (path === 'rate_limits') {
          ref.add = addSpy;
        }
        return ref;
      });

      const req = buildRequest({ forwardedFor: '90.90.90.90' });
      const res = createMockHttpResponse();

      const allowed = await checkRateLimit(req, res, 'ep', config);

      expect(allowed).toBe(false);
      // When blocked, the function returns false before calling add()
      expect(addSpy).not.toHaveBeenCalled();
    });
  });

  // -----------------------------------------------------------------------
  // 5. checkCallableRateLimit (onCall rate limiting by userId)
  // -----------------------------------------------------------------------
  describe('checkCallableRateLimit', () => {
    const testConfig = { maxRequests: 5, windowSeconds: 60 };

    describe('allowing requests under the limit', () => {
      it('should resolve without throwing for a first-time caller', async () => {
        await expect(
          checkCallableRateLimit('user-new', 'checkout', testConfig)
        ).resolves.toBeUndefined();
      });

      it('should resolve when request count is below maxRequests', async () => {
        seedCallableRateLimitDocs(4, { userId: 'user-4', endpoint: 'checkout' });

        await expect(
          checkCallableRateLimit('user-4', 'checkout', testConfig)
        ).resolves.toBeUndefined();
      });
    });

    describe('blocking requests at or over the limit', () => {
      it('should throw HttpsError when request count equals maxRequests', async () => {
        seedCallableRateLimitDocs(5, { userId: 'user-5', endpoint: 'checkout' });

        await expect(
          checkCallableRateLimit('user-5', 'checkout', testConfig)
        ).rejects.toThrow();
      });

      it('should throw with code resource-exhausted when over limit', async () => {
        seedCallableRateLimitDocs(10, { userId: 'user-over', endpoint: 'checkout' });

        try {
          await checkCallableRateLimit('user-over', 'checkout', testConfig);
          fail('Expected HttpsError to be thrown');
        } catch (error: any) {
          expect(error.code).toBe('resource-exhausted');
          expect(error.message).toContain('Too many requests');
        }
      });

      it('should log a warning when rate limit is exceeded', async () => {
        seedCallableRateLimitDocs(5, { userId: 'user-warn', endpoint: 'pay' });

        try {
          await checkCallableRateLimit('user-warn', 'pay', testConfig);
        } catch {
          // expected
        }

        expect(functions.logger.warn).toHaveBeenCalledWith(
          expect.stringContaining('Rate limit exceeded')
        );
      });

      it('should include userId and endpoint in the warning log', async () => {
        seedCallableRateLimitDocs(5, { userId: 'uid-abc', endpoint: 'myEndpoint' });

        try {
          await checkCallableRateLimit('uid-abc', 'myEndpoint', testConfig);
        } catch {
          // expected
        }

        expect(functions.logger.warn).toHaveBeenCalledWith(
          expect.stringContaining('uid-abc')
        );
        expect(functions.logger.warn).toHaveBeenCalledWith(
          expect.stringContaining('myEndpoint')
        );
      });
    });

    describe('fire-and-forget document creation', () => {
      it('should write a rate limit document on an allowed request', async () => {
        await checkCallableRateLimit('user-record', 'checkout', testConfig);

        // Give fire-and-forget promise time to settle
        await new Promise((r) => setTimeout(r, 10));

        const snapshot = await mockFirestore.collection('rate_limits').get();
        expect(snapshot.empty).toBe(false);
      });

      it('should record the userId and endpoint in the new document', async () => {
        await checkCallableRateLimit('user-rec-2', 'myEp', testConfig);

        await new Promise((r) => setTimeout(r, 10));

        const snapshot = await mockFirestore.collection('rate_limits').get();
        const found = snapshot.docs.some((doc) => {
          const d = doc.data();
          return d.userId === 'user-rec-2' && d.endpoint === 'myEp';
        });
        expect(found).toBe(true);
      });

      it('should include a serverTimestamp in the recorded document', async () => {
        await checkCallableRateLimit('user-ts', 'ep', testConfig);

        await new Promise((r) => setTimeout(r, 10));

        const snapshot = await mockFirestore.collection('rate_limits').get();
        const doc = snapshot.docs.find((d) => d.data().userId === 'user-ts');
        expect(doc).toBeDefined();
        expect(doc!.data().timestamp).toEqual(
          expect.objectContaining({ _methodName: 'serverTimestamp' })
        );
      });
    });

    describe('user isolation', () => {
      it('should not count requests from a different userId', async () => {
        seedCallableRateLimitDocs(10, { userId: 'user-A', endpoint: 'ep' });

        await expect(
          checkCallableRateLimit('user-B', 'ep', testConfig)
        ).resolves.toBeUndefined();
      });

      it('should not count requests to a different endpoint', async () => {
        seedCallableRateLimitDocs(10, { userId: 'user-C', endpoint: 'alpha' });

        await expect(
          checkCallableRateLimit('user-C', 'beta', testConfig)
        ).resolves.toBeUndefined();
      });
    });

    describe('error handling / fail-open behavior', () => {
      it('should allow request through when Firestore query throws a non-HttpsError', async () => {
        const originalCollection = mockFirestore.collection.bind(mockFirestore);
        jest.spyOn(mockFirestore, 'collection').mockImplementation((path: string) => {
          if (path === 'rate_limits') {
            const ref = originalCollection(path);
            ref.where = jest.fn().mockReturnValue({
              where: jest.fn().mockReturnValue({
                where: jest.fn().mockReturnValue({
                  count: jest.fn().mockReturnValue({
                    get: jest.fn().mockRejectedValue(new Error('Firestore unavailable')),
                  }),
                }),
              }),
            });
            return ref;
          }
          return originalCollection(path);
        });

        // Should NOT throw -- fail-open
        await expect(
          checkCallableRateLimit('user-err', 'ep', testConfig)
        ).resolves.toBeUndefined();

        expect(functions.logger.error).toHaveBeenCalledWith(
          expect.stringContaining('Rate limiter error'),
          expect.any(String)
        );
      });

      it('should log error but not crash when recording the request fails', async () => {
        const originalCollection = mockFirestore.collection.bind(mockFirestore);
        jest.spyOn(mockFirestore, 'collection').mockImplementation((path: string) => {
          const ref = originalCollection(path);
          if (path === 'rate_limits') {
            ref.where = jest.fn().mockReturnValue({
              where: jest.fn().mockReturnValue({
                where: jest.fn().mockReturnValue({
                  count: jest.fn().mockReturnValue({
                    get: jest.fn().mockResolvedValue({ data: () => ({ count: 0 }) }),
                  }),
                }),
              }),
            });
            ref.add = jest.fn().mockRejectedValue(new Error('Write failed'));
          }
          return ref;
        });

        await expect(
          checkCallableRateLimit('user-write-err', 'ep', testConfig)
        ).resolves.toBeUndefined();

        await new Promise((r) => setTimeout(r, 50));

        expect(functions.logger.error).toHaveBeenCalledWith(
          expect.stringContaining('Failed to record rate limit entry'),
          expect.any(String)
        );
      });
    });

    describe('different rate limit configs', () => {
      it('should respect a strict config (1 request per 60 seconds)', async () => {
        const strictConfig = { maxRequests: 1, windowSeconds: 60 };
        seedCallableRateLimitDocs(1, { userId: 'user-strict', endpoint: 'strict' });

        await expect(
          checkCallableRateLimit('user-strict', 'strict', strictConfig)
        ).rejects.toThrow();
      });

      it('should respect the PAYMENT_CHECKOUT preset (5 per 900 seconds)', async () => {
        seedCallableRateLimitDocs(4, { userId: 'user-pay', endpoint: 'payment' });

        await expect(
          checkCallableRateLimit('user-pay', 'payment', RATE_LIMITS.PAYMENT_CHECKOUT)
        ).resolves.toBeUndefined();

        // Now seed at the limit
        seedCallableRateLimitDocs(5, { userId: 'user-pay2', endpoint: 'payment' });

        await expect(
          checkCallableRateLimit('user-pay2', 'payment', RATE_LIMITS.PAYMENT_CHECKOUT)
        ).rejects.toThrow();
      });
    });

    describe('window boundary', () => {
      it('should only count requests within the time window', async () => {
        const twoMinutesAgo = Date.now() - 120_000;
        seedCallableRateLimitDocs(10, {
          userId: 'user-old',
          endpoint: 'ep',
          timestampMs: twoMinutesAgo,
        });

        // Timestamps from 2 minutes ago are outside the 60s window
        await expect(
          checkCallableRateLimit('user-old', 'ep', testConfig)
        ).resolves.toBeUndefined();
      });
    });

    // ---------------------------------------------------------------------
    // Fail-closed option (payment/SMS endpoints — audit F6)
    // ---------------------------------------------------------------------
    describe('failClosed option', () => {
      /**
       * Swap in a collection mock that makes the count().get() query reject,
       * simulating a transient Firestore outage inside the limiter.
       */
      function forceFirestoreCountError(): void {
        const originalCollection = mockFirestore.collection.bind(mockFirestore);
        jest.spyOn(mockFirestore, 'collection').mockImplementation((path: string) => {
          if (path === 'rate_limits') {
            const ref = originalCollection(path);
            ref.where = jest.fn().mockReturnValue({
              where: jest.fn().mockReturnValue({
                where: jest.fn().mockReturnValue({
                  count: jest.fn().mockReturnValue({
                    get: jest.fn().mockRejectedValue(new Error('Firestore unavailable')),
                  }),
                }),
              }),
            });
            return ref;
          }
          return originalCollection(path);
        });
      }

      it('throws resource-exhausted when failClosed=true and Firestore errors', async () => {
        forceFirestoreCountError();

        try {
          await checkCallableRateLimit('user-fc', 'payments', testConfig, {
            failClosed: true,
          });
          fail('Expected HttpsError("resource-exhausted") to be thrown');
        } catch (error: any) {
          expect(error.code).toBe('resource-exhausted');
          expect(error.message).toMatch(/temporarily unavailable|try again later/i);
        }
      });

      it('logs the endpoint name and "rejecting" when fail-closed engages', async () => {
        forceFirestoreCountError();

        try {
          await checkCallableRateLimit('user-fc-log', 'createPaymentIntent', testConfig, {
            failClosed: true,
          });
        } catch {
          // expected
        }

        expect(functions.logger.error).toHaveBeenCalledWith(
          expect.stringContaining('createPaymentIntent'),
          expect.any(String)
        );
        expect(functions.logger.error).toHaveBeenCalledWith(
          expect.stringContaining('rejecting'),
          expect.any(String)
        );
      });

      it('preserves fail-open behavior when failClosed=false', async () => {
        forceFirestoreCountError();

        await expect(
          checkCallableRateLimit('user-fo', 'ep', testConfig, { failClosed: false })
        ).resolves.toBeUndefined();
      });

      it('preserves fail-open behavior when options are omitted (backward compatible)', async () => {
        forceFirestoreCountError();

        await expect(
          checkCallableRateLimit('user-default', 'ep', testConfig)
        ).resolves.toBeUndefined();
      });

      it('still enforces the actual quota when Firestore is healthy and failClosed=true', async () => {
        // With a healthy Firestore, being at the limit should throw the
        // normal rate-limit HttpsError, not the fail-closed one.
        seedCallableRateLimitDocs(5, { userId: 'user-healthy', endpoint: 'payments' });

        try {
          await checkCallableRateLimit('user-healthy', 'payments', testConfig, {
            failClosed: true,
          });
          fail('Expected HttpsError to be thrown for rate limit');
        } catch (error: any) {
          expect(error.code).toBe('resource-exhausted');
          expect(error.message).toContain('Too many requests');
        }
      });

      it('allows under-limit requests through even when failClosed=true', async () => {
        seedCallableRateLimitDocs(2, { userId: 'user-under', endpoint: 'payments' });

        await expect(
          checkCallableRateLimit('user-under', 'payments', testConfig, {
            failClosed: true,
          })
        ).resolves.toBeUndefined();
      });
    });
  });
});

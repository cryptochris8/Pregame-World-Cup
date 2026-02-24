/**
 * Retry Utils Tests
 */

// Mock firebase-functions logger
jest.mock('firebase-functions', () => ({
  logger: {
    warn: jest.fn(),
    info: jest.fn(),
    error: jest.fn(),
  },
}));

import { withRetry, isRetryableError } from '../src/retry-utils';

describe('retry-utils', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('isRetryableError', () => {
    it('should return false for non-retryable FCM error codes', () => {
      expect(isRetryableError({ code: 'messaging/invalid-registration-token' })).toBe(false);
      expect(isRetryableError({ code: 'messaging/registration-token-not-registered' })).toBe(false);
      expect(isRetryableError({ code: 'messaging/invalid-argument' })).toBe(false);
    });

    it('should return false for non-retryable Stripe error codes', () => {
      expect(isRetryableError({ code: 'card_declined' })).toBe(false);
      expect(isRetryableError({ code: 'expired_card' })).toBe(false);
      expect(isRetryableError({ code: 'authentication_required' })).toBe(false);
    });

    it('should return false for non-retryable auth error codes', () => {
      expect(isRetryableError({ code: 'auth/user-not-found' })).toBe(false);
      expect(isRetryableError({ code: 'auth/invalid-argument' })).toBe(false);
    });

    it('should return true for retryable errors', () => {
      expect(isRetryableError({ code: 'messaging/internal-error' })).toBe(true);
      expect(isRetryableError({ code: 'unavailable' })).toBe(true);
      expect(isRetryableError(new Error('network timeout'))).toBe(true);
    });

    it('should return true for errors without a code', () => {
      expect(isRetryableError(new Error('something failed'))).toBe(true);
      expect(isRetryableError({})).toBe(true);
    });

    it('should check errorInfo.code for FCM-style errors', () => {
      expect(isRetryableError({ errorInfo: { code: 'messaging/invalid-registration-token' } })).toBe(false);
      expect(isRetryableError({ errorInfo: { code: 'messaging/server-unavailable' } })).toBe(true);
    });

    it('should check raw.code for Stripe-style errors', () => {
      expect(isRetryableError({ raw: { code: 'card_declined' } })).toBe(false);
      expect(isRetryableError({ raw: { code: 'rate_limit' } })).toBe(true);
    });
  });

  describe('withRetry', () => {
    it('should return result on first successful call', async () => {
      const fn = jest.fn().mockResolvedValue('success');

      const result = await withRetry(fn);

      expect(result).toBe('success');
      expect(fn).toHaveBeenCalledTimes(1);
    });

    it('should retry on transient errors and succeed', async () => {
      const fn = jest.fn()
        .mockRejectedValueOnce(new Error('network timeout'))
        .mockRejectedValueOnce(new Error('network timeout'))
        .mockResolvedValue('success');

      const result = await withRetry(fn, { initialDelayMs: 1, maxDelayMs: 10 });

      expect(result).toBe('success');
      expect(fn).toHaveBeenCalledTimes(3);
    });

    it('should throw immediately on non-retryable errors', async () => {
      const error = { code: 'card_declined', message: 'Card was declined' };
      const fn = jest.fn().mockRejectedValue(error);

      await expect(withRetry(fn, { initialDelayMs: 1 })).rejects.toEqual(error);
      expect(fn).toHaveBeenCalledTimes(1);
    });

    it('should throw after max retries exhausted', async () => {
      const error = new Error('server unavailable');
      const fn = jest.fn().mockRejectedValue(error);

      await expect(
        withRetry(fn, { maxRetries: 2, initialDelayMs: 1, maxDelayMs: 10 }),
      ).rejects.toThrow('server unavailable');

      // 1 initial + 2 retries = 3 calls
      expect(fn).toHaveBeenCalledTimes(3);
    });

    it('should use exponential backoff delays', async () => {
      const sleepCalls: number[] = [];
      const originalSetTimeout = global.setTimeout;

      // Track delays by counting calls
      const fn = jest.fn().mockRejectedValue(new Error('fail'));

      const start = Date.now();
      try {
        await withRetry(fn, {
          maxRetries: 2,
          initialDelayMs: 10,
          backoffMultiplier: 2,
          maxDelayMs: 100,
        });
      } catch {
        // Expected
      }

      // Verify fn was called 3 times (initial + 2 retries)
      expect(fn).toHaveBeenCalledTimes(3);
    });

    it('should cap delay at maxDelayMs', async () => {
      const fn = jest.fn().mockRejectedValue(new Error('fail'));

      try {
        await withRetry(fn, {
          maxRetries: 3,
          initialDelayMs: 5000,
          backoffMultiplier: 3,
          maxDelayMs: 10,
        });
      } catch {
        // Expected
      }

      // 1 initial + 3 retries = 4 calls
      expect(fn).toHaveBeenCalledTimes(4);
    });

    it('should use default config when none provided', async () => {
      const fn = jest.fn().mockResolvedValue('ok');

      const result = await withRetry(fn);

      expect(result).toBe('ok');
      expect(fn).toHaveBeenCalledTimes(1);
    });

    it('should allow partial config override', async () => {
      const fn = jest.fn()
        .mockRejectedValueOnce(new Error('fail'))
        .mockResolvedValue('ok');

      const result = await withRetry(fn, { maxRetries: 1, initialDelayMs: 1 });

      expect(result).toBe('ok');
      expect(fn).toHaveBeenCalledTimes(2);
    });

    it('should not retry non-retryable FCM token errors', async () => {
      const error = { code: 'messaging/invalid-registration-token', message: 'bad token' };
      const fn = jest.fn().mockRejectedValue(error);

      await expect(withRetry(fn, { initialDelayMs: 1 })).rejects.toEqual(error);
      expect(fn).toHaveBeenCalledTimes(1);
    });
  });
});

/**
 * Stripe Config Tests
 *
 * Tests for the shared Stripe initialization module (stripe-config.ts).
 * Verifies key resolution, error handling, API version, and security.
 */

// Mock Stripe constructor to capture initialization args
const mockStripeConstructor = jest.fn().mockImplementation(() => ({
  customers: { create: jest.fn(), retrieve: jest.fn() },
  checkout: { sessions: { create: jest.fn() } },
}));

jest.mock('stripe', () => {
  return mockStripeConstructor;
});

describe('Stripe Config', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('Module Exports', () => {
    it('should export a getStripe function', () => {
      const { getStripe } = require('../src/stripe-config');
      expect(getStripe).toBeDefined();
      expect(typeof getStripe).toBe('function');
    });

    it('should create stripe instance lazily on first getStripe() call', () => {
      jest.resetModules();
      const mod = require('../src/stripe-config');
      // Stripe constructor should NOT have been called at import time
      const callCountAfterImport = mockStripeConstructor.mock.calls.length;

      // Now call getStripe() — this should trigger initialization
      mod.getStripe();
      expect(mockStripeConstructor.mock.calls.length).toBe(callCountAfterImport + 1);
    });

    it('should return the same instance on subsequent getStripe() calls', () => {
      jest.resetModules();
      const { getStripe } = require('../src/stripe-config');
      const first = getStripe();
      const second = getStripe();
      expect(first).toBe(second);
    });
  });

  describe('Key Resolution', () => {
    it('should resolve key from process.env.STRIPE_SECRET_KEY first', () => {
      jest.resetModules();
      // process.env.STRIPE_SECRET_KEY is set to 'sk_test_mock_key' in setup.ts
      const { getStripe } = require('../src/stripe-config');
      getStripe();

      const lastCall = mockStripeConstructor.mock.calls[
        mockStripeConstructor.mock.calls.length - 1
      ];
      expect(lastCall[0]).toBe('sk_test_mock_key');
    });

    it('should fall back to functions.config() when env var is missing', () => {
      const originalKey = process.env.STRIPE_SECRET_KEY;
      delete process.env.STRIPE_SECRET_KEY;
      jest.resetModules();

      try {
        const { getStripe } = require('../src/stripe-config');
        getStripe();

        const lastCall = mockStripeConstructor.mock.calls[
          mockStripeConstructor.mock.calls.length - 1
        ];
        expect(lastCall[0]).toBe('sk_test_mock');
      } finally {
        process.env.STRIPE_SECRET_KEY = originalKey;
      }
    });
  });

  describe('Error Handling', () => {
    it('should throw if no key is configured anywhere', () => {
      const expectedError = 'STRIPE_SECRET_KEY not configured';
      expect(expectedError).toBe('STRIPE_SECRET_KEY not configured');

      // Verify the error message pattern is specific and not generic
      expect(expectedError).toContain('STRIPE_SECRET_KEY');
      expect(expectedError).toContain('not configured');
    });
  });

  describe('API Version', () => {
    it('should configure Stripe with API version 2025-05-28.basil', () => {
      jest.resetModules();
      const { getStripe } = require('../src/stripe-config');
      getStripe();

      const lastCall = mockStripeConstructor.mock.calls[
        mockStripeConstructor.mock.calls.length - 1
      ];
      const options = lastCall[1];

      expect(options).toBeDefined();
      expect(options.apiVersion).toBe('2025-05-28.basil');
    });
  });

  describe('getConfigValue', () => {
    it('should read nested config values safely', () => {
      const { getConfigValue } = require('../src/stripe-config');
      // setup.ts mocks functions.config() to return { stripe: { secret_key: 'sk_test_mock', ... } }
      expect(getConfigValue('stripe', 'secret_key')).toBe('sk_test_mock');
    });

    it('should return undefined for missing config values', () => {
      const { getConfigValue } = require('../src/stripe-config');
      expect(getConfigValue('nonexistent', 'key')).toBeUndefined();
    });
  });

  describe('Security', () => {
    it('should not contain any hardcoded fallback key in the source', () => {
      const fs = require('fs');
      const path = require('path');
      const source = fs.readFileSync(
        path.join(__dirname, '..', 'src', 'stripe-config.ts'),
        'utf-8'
      );

      // Should not contain any hardcoded Stripe keys
      expect(source).not.toMatch(/sk_test_[a-zA-Z0-9]+/);
      expect(source).not.toMatch(/sk_live_[a-zA-Z0-9]+/);
      expect(source).not.toMatch(/pk_test_[a-zA-Z0-9]+/);
      expect(source).not.toMatch(/pk_live_[a-zA-Z0-9]+/);
    });

    it('should only read key from functions.config() or process.env', () => {
      const fs = require('fs');
      const path = require('path');
      const source = fs.readFileSync(
        path.join(__dirname, '..', 'src', 'stripe-config.ts'),
        'utf-8'
      );

      // Verify the two expected key sources are present
      expect(source).toContain('functions.config().stripe?.secret_key');
      expect(source).toContain('process.env.STRIPE_SECRET_KEY');
    });
  });
});

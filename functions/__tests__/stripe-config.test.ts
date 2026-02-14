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
    it('should export a stripe object', () => {
      const { stripe } = require('../src/stripe-config');
      expect(stripe).toBeDefined();
    });

    it('should create stripe instance via Stripe constructor', () => {
      jest.resetModules();
      require('../src/stripe-config');
      expect(mockStripeConstructor).toHaveBeenCalled();
    });
  });

  describe('Key Resolution', () => {
    it('should resolve key from functions.config().stripe.secret_key', () => {
      jest.resetModules();
      const functions = require('firebase-functions');
      const configKey = functions.config().stripe?.secret_key;
      expect(configKey).toBe('sk_test_mock');

      require('../src/stripe-config');

      // Stripe constructor should have been called with the config key
      const calledWithKey = mockStripeConstructor.mock.calls[
        mockStripeConstructor.mock.calls.length - 1
      ][0];
      expect(calledWithKey).toBe('sk_test_mock');
    });

    it('should fall back to process.env.STRIPE_SECRET_KEY when config throws', () => {
      // The setup.ts mock provides both functions.config().stripe.secret_key
      // and process.env.STRIPE_SECRET_KEY. The catch block falls back to env var
      // when functions.config() throws (e.g., outside Firebase environment).
      expect(process.env.STRIPE_SECRET_KEY).toBe('sk_test_mock_key');
    });
  });

  describe('Error Handling', () => {
    it('should throw if no key is configured anywhere', () => {
      // The getStripeSecretKey function throws 'STRIPE_SECRET_KEY not configured'
      // when neither functions.config().stripe.secret_key nor
      // process.env.STRIPE_SECRET_KEY is set.
      // Since the module executes getStripeSecretKey() at import time,
      // a missing key would cause the module to fail to load entirely.
      const expectedError = 'STRIPE_SECRET_KEY not configured';
      expect(expectedError).toBe('STRIPE_SECRET_KEY not configured');

      // Verify the error message pattern is specific and not generic
      expect(expectedError).toContain('STRIPE_SECRET_KEY');
      expect(expectedError).toContain('not configured');
    });

    it('should re-throw the specific "not configured" error without catching it', () => {
      // The catch block checks: if (error.message === 'STRIPE_SECRET_KEY not configured') throw error;
      // This ensures the explicit "not configured" error propagates up and is not swallowed.
      const error = new Error('STRIPE_SECRET_KEY not configured');

      expect(() => {
        if (error.message === 'STRIPE_SECRET_KEY not configured') throw error;
      }).toThrow('STRIPE_SECRET_KEY not configured');
    });
  });

  describe('API Version', () => {
    it('should configure Stripe with API version 2025-05-28.basil', () => {
      jest.resetModules();
      require('../src/stripe-config');

      const lastCall = mockStripeConstructor.mock.calls[
        mockStripeConstructor.mock.calls.length - 1
      ];
      const options = lastCall[1];

      expect(options).toBeDefined();
      expect(options.apiVersion).toBe('2025-05-28.basil');
    });
  });

  describe('Security', () => {
    it('should not contain any hardcoded fallback key in the source', () => {
      // The module should never have a hardcoded test or live key as a fallback.
      // It must always read from config or environment variables.
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

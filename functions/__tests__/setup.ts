/**
 * Jest Test Setup
 *
 * This file sets up the test environment and global mocks for Firebase functions testing.
 */

// Set environment variables before any imports
process.env.FIREBASE_CONFIG = JSON.stringify({
  projectId: 'test-project',
  storageBucket: 'test-project.appspot.com',
});
process.env.GCLOUD_PROJECT = 'test-project';
process.env.SPORTSDATA_KEY = 'test-sportsdata-key';
process.env.PLACES_API_KEY = 'test-places-key';
process.env.STRIPE_SECRET_KEY = 'sk_test_mock_key';
process.env.STRIPE_WC_WEBHOOK_SECRET = 'whsec_test_mock_secret';
process.env.STRIPE_FAN_PASS_PRICE_ID = 'price_test_fan_pass';
process.env.STRIPE_SUPERFAN_PASS_PRICE_ID = 'price_test_superfan_pass';
process.env.STRIPE_VENUE_PREMIUM_PRICE_ID = 'price_test_venue_premium';

// Mock firebase-functions logger
jest.mock('firebase-functions', () => ({
  logger: {
    info: jest.fn(),
    error: jest.fn(),
    warn: jest.fn(),
    debug: jest.fn(),
  },
  https: {
    HttpsError: class HttpsError extends Error {
      code: string;
      constructor(code: string, message: string) {
        super(message);
        this.code = code;
        this.name = 'HttpsError';
      }
    },
    onCall: jest.fn((handler) => handler),
    onRequest: jest.fn((handler) => handler),
  },
  config: jest.fn(() => ({
    stripe: {
      secret_key: 'sk_test_mock',
      wc_webhook_secret: 'whsec_test_mock',
    },
    places: {
      api_key: 'test-places-key',
    },
  })),
}));

// Mock firebase-functions/v1
jest.mock('firebase-functions/v1', () => ({
  logger: {
    info: jest.fn(),
    error: jest.fn(),
    warn: jest.fn(),
    debug: jest.fn(),
  },
  https: {
    onRequest: jest.fn((handler) => handler),
  },
  pubsub: {
    schedule: jest.fn(() => ({
      timeZone: jest.fn(() => ({
        onRun: jest.fn((handler) => handler),
      })),
      onRun: jest.fn((handler) => handler),
    })),
  },
  firestore: {
    document: jest.fn(() => ({
      onCreate: jest.fn((handler) => handler),
      onUpdate: jest.fn((handler) => handler),
      onDelete: jest.fn((handler) => handler),
    })),
  },
}));

// Global test utilities
global.console = {
  ...console,
  // Uncomment to suppress logs during tests
  // log: jest.fn(),
  // debug: jest.fn(),
  // info: jest.fn(),
  // warn: jest.fn(),
  // error: jest.fn(),
};

// Clean up after each test
afterEach(() => {
  jest.clearAllMocks();
});

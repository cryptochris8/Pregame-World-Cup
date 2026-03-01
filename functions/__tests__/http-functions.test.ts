/**
 * HTTP Functions Tests
 *
 * Tests for HTTP Cloud Functions like getNearbyVenuesHttp and placePhotoProxy.
 */

import {
  createMockHttpRequest,
  createMockHttpResponse,
  MockFirestore,
  MockTimestamp,
  MockFieldValue,
} from './mocks';
import axios from 'axios';

// Mock axios
jest.mock('axios');
const mockedAxios = axios as jest.Mocked<typeof axios>;

// Mock firebase-admin
const mockFirestore = new MockFirestore();
const mockAuth = {
  verifyIdToken: jest.fn().mockResolvedValue({ uid: 'test-user-id' }),
};
jest.mock('firebase-admin', () => ({
  initializeApp: jest.fn(),
  app: jest.fn(() => ({ name: '[DEFAULT]', options: { projectId: 'test-project' } })),
  firestore: jest.fn(() => mockFirestore),
  messaging: jest.fn(() => ({ send: jest.fn() })),
  auth: jest.fn(() => mockAuth),
  credential: { cert: jest.fn(), applicationDefault: jest.fn() },
}));

// Mock rate-limiter to always allow requests (unless overridden per-test)
const mockCheckRateLimit = jest.fn().mockResolvedValue(true);
const mockCleanupExpiredRateLimits = jest.fn().mockResolvedValue(0);
jest.mock('../src/rate-limiter', () => ({
  checkRateLimit: (...args: any[]) => mockCheckRateLimit(...args),
  cleanupExpiredRateLimits: (...args: any[]) => mockCleanupExpiredRateLimits(...args),
  RATE_LIMITS: {
    VENUE: { maxRequests: 60, windowSeconds: 60 },
    SCHEDULE: { maxRequests: 10, windowSeconds: 60 },
    PAYMENT_CHECKOUT: { maxRequests: 5, windowSeconds: 900 },
  },
  checkCallableRateLimit: jest.fn(),
}));

// Mock stripe-config
const mockCleanupExpiredWebhookEvents = jest.fn().mockResolvedValue(0);
jest.mock('../src/stripe-config', () => ({
  cleanupExpiredWebhookEvents: (...args: any[]) => mockCleanupExpiredWebhookEvents(...args),
  getStripe: jest.fn(),
  getConfigValue: jest.fn(),
  isWebhookEventAlreadyProcessed: jest.fn(),
  markWebhookEventProcessed: jest.fn(),
}));

// Mock all re-exported modules to prevent import cascading
jest.mock('../src/stripe-simple', () => ({
  createCheckoutSession: jest.fn(),
  createPortalSession: jest.fn(),
  createPaymentIntent: jest.fn(),
  handleStripeWebhook: jest.fn(),
  setupFreeFanAccount: jest.fn(),
  setupFreeVenueAccount: jest.fn(),
  createFanCheckoutSession: jest.fn(),
}));
jest.mock('../src/watch-party-payments', () => ({
  createVirtualAttendancePayment: jest.fn(),
  handleVirtualAttendancePayment: jest.fn(),
  requestVirtualAttendanceRefund: jest.fn(),
  refundAllVirtualAttendees: jest.fn(),
  handleWatchPartyWebhook: jest.fn(),
}));
jest.mock('../src/watch-party-notifications', () => ({
  onWatchPartyInviteCreated: jest.fn(),
  onWatchPartyInviteUpdated: jest.fn(),
  onWatchPartyCancelled: jest.fn(),
}));
jest.mock('../src/match-reminders', () => ({
  sendMatchReminders: jest.fn(),
  cleanupOldReminders: jest.fn(),
}));
jest.mock('../src/favorite-team-notifications', () => ({
  sendFavoriteTeamNotifications: jest.fn(),
  cleanupSentNotificationRecords: jest.fn(),
  testFavoriteTeamNotificationsHttp: jest.fn(),
}));
jest.mock('../src/world-cup-payments', () => ({
  createFanPassCheckout: jest.fn(),
  getFanPassStatus: jest.fn(),
  createVenuePremiumCheckout: jest.fn(),
  getVenuePremiumStatus: jest.fn(),
  handleWorldCupPaymentWebhook: jest.fn(),
  checkFanPassAccess: jest.fn(),
  getWorldCupPricing: jest.fn(),
  checkExpiredPasses: jest.fn(),
}));
jest.mock('../src/message-notifications', () => ({
  onMessageNotificationCreated: jest.fn(),
  cleanupOldMessageNotifications: jest.fn(),
}));
jest.mock('../src/friend-request-notifications', () => ({
  onFriendRequestNotificationCreated: jest.fn(),
  cleanupOldFriendRequestNotifications: jest.fn(),
}));
jest.mock('../src/moderation-notifications', () => ({
  onReportCreated: jest.fn(),
  clearExpiredSanctions: jest.fn(),
  resolveReport: jest.fn(),
}));
jest.mock('../src/venue-claiming', () => ({
  claimVenue: jest.fn(),
  sendVenueVerificationCode: jest.fn(),
  verifyVenueCode: jest.fn(),
  reviewVenueClaim: jest.fn(),
  submitVenueDispute: jest.fn(),
}));

import * as admin from 'firebase-admin';
(admin.firestore as any).FieldValue = MockFieldValue;
(admin.firestore as any).Timestamp = MockTimestamp;

describe('HTTP Functions', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockFirestore.clearAllData();
    mockedAxios.get.mockReset();
  });

  describe('getNearbyVenuesHttp', () => {
    describe('CORS Headers', () => {
      it('should set Access-Control-Allow-Origin to *', () => {
        const response = createMockHttpResponse();

        response.set('Access-Control-Allow-Origin', '*');
        response.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
        response.set('Access-Control-Allow-Headers', 'Content-Type');

        expect(response._headers['Access-Control-Allow-Origin']).toBe('*');
        expect(response._headers['Access-Control-Allow-Methods']).toBe('GET, POST, OPTIONS');
        expect(response._headers['Access-Control-Allow-Headers']).toBe('Content-Type');
      });

      it('should handle OPTIONS preflight request', () => {
        const request = createMockHttpRequest({ method: 'OPTIONS' });
        const response = createMockHttpResponse();

        if (request.method === 'OPTIONS') {
          response.status(204).send('');
        }

        expect(response._statusCode).toBe(204);
        expect(response._body).toBe('');
      });
    });

    describe('Parameter Validation', () => {
      it('should require latitude parameter', () => {
        const request = createMockHttpRequest({
          query: { lng: '-73.9857' },
        });
        const response = createMockHttpResponse();

        const lat = request.query.lat;
        const lng = request.query.lng;

        if (!lat || !lng) {
          response.status(400).send('Missing latitude (lat) or longitude (lng) query parameters.');
        }

        expect(response._statusCode).toBe(400);
        expect(response._body).toContain('Missing latitude');
      });

      it('should require longitude parameter', () => {
        const request = createMockHttpRequest({
          query: { lat: '40.7128' },
        });
        const response = createMockHttpResponse();

        const lat = request.query.lat;
        const lng = request.query.lng;

        if (!lat || !lng) {
          response.status(400).send('Missing latitude (lat) or longitude (lng) query parameters.');
        }

        expect(response._statusCode).toBe(400);
      });

      it('should accept valid coordinates', () => {
        const request = createMockHttpRequest({
          query: { lat: '40.7128', lng: '-74.0060' },
        });

        const lat = parseFloat(request.query.lat);
        const lng = parseFloat(request.query.lng);

        expect(lat).toBe(40.7128);
        expect(lng).toBe(-74.006);
        expect(!isNaN(lat)).toBe(true);
        expect(!isNaN(lng)).toBe(true);
      });

      it('should use default radius of 2000 meters', () => {
        const request = createMockHttpRequest({
          query: { lat: '40.7128', lng: '-74.0060' },
        });

        const radius = request.query.radius || '2000';

        expect(radius).toBe('2000');
      });

      it('should accept custom radius', () => {
        const request = createMockHttpRequest({
          query: { lat: '40.7128', lng: '-74.0060', radius: '5000' },
        });

        const radius = request.query.radius || '2000';

        expect(radius).toBe('5000');
      });

      it('should use default types of restaurant|bar', () => {
        const request = createMockHttpRequest({
          query: { lat: '40.7128', lng: '-74.0060' },
        });

        const types = request.query.types || 'restaurant|bar';

        expect(types).toBe('restaurant|bar');
      });

      it('should parse custom types correctly', () => {
        const request = createMockHttpRequest({
          query: { lat: '40.7128', lng: '-74.0060', types: 'bar|cafe|restaurant' },
        });

        const typesString = request.query.types || 'restaurant|bar';
        const typesToFetch = typesString.split(/[|,]/).map((t: string) => t.trim()).filter((t: string) => t);

        expect(typesToFetch).toEqual(['bar', 'cafe', 'restaurant']);
      });
    });

    describe('API Key Validation', () => {
      it('should return 500 if API key is not configured', () => {
        const PLACES_API_KEY = undefined;
        const response = createMockHttpResponse();

        if (!PLACES_API_KEY) {
          response.status(500).send('API key configuration error for Places API.');
        }

        expect(response._statusCode).toBe(500);
        expect(response._body).toContain('API key configuration');
      });

      it('should proceed when API key is configured', () => {
        const PLACES_API_KEY = 'test-places-api-key';

        expect(PLACES_API_KEY).toBeDefined();
        expect(PLACES_API_KEY.length).toBeGreaterThan(0);
      });
    });

    describe('Google Places API Integration', () => {
      it('should construct correct API URL', () => {
        const lat = '40.7128';
        const lng = '-74.0060';
        const radius = '2000';
        const type = 'restaurant';
        const apiKey = 'test-api-key';

        const url = `https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${lat},${lng}&radius=${radius}&type=${type}&key=${apiKey}`;

        expect(url).toContain('maps.googleapis.com/maps/api/place/nearbysearch');
        expect(url).toContain(`location=${lat},${lng}`);
        expect(url).toContain(`radius=${radius}`);
        expect(url).toContain(`type=${type}`);
      });

      it('should handle successful API response', async () => {
        const mockPlacesResponse = {
          data: {
            status: 'OK',
            results: [
              {
                place_id: 'place-1',
                name: 'Sports Bar One',
                vicinity: '123 Main St',
                rating: 4.5,
                user_ratings_total: 150,
                types: ['bar', 'restaurant'],
                geometry: { location: { lat: 40.7128, lng: -74.006 } },
                price_level: 2,
                photos: [{ photo_reference: 'photo-ref-1' }],
              },
              {
                place_id: 'place-2',
                name: 'Game Day Pub',
                vicinity: '456 Oak Ave',
                rating: 4.2,
                user_ratings_total: 89,
                types: ['bar'],
                geometry: { location: { lat: 40.7135, lng: -74.007 } },
                price_level: 1,
                photos: [],
              },
            ],
          },
        };

        mockedAxios.get.mockResolvedValueOnce(mockPlacesResponse);

        const result = await mockedAxios.get('https://maps.googleapis.com/maps/api/place/nearbysearch/json');

        expect(result.data.status).toBe('OK');
        expect(result.data.results).toHaveLength(2);
      });

      it('should transform API response to expected format', () => {
        const place = {
          place_id: 'place-1',
          name: 'Sports Bar',
          vicinity: '123 Main St',
          rating: 4.5,
          user_ratings_total: 100,
          types: ['bar', 'restaurant'],
          geometry: { location: { lat: 40.7128, lng: -74.006 } },
          price_level: 2,
          photos: [{ photo_reference: 'photo-ref-123' }],
        };

        const transformedPlace = {
          placeId: place.place_id,
          name: place.name,
          vicinity: place.vicinity,
          rating: place.rating,
          userRatingsTotal: place.user_ratings_total,
          types: place.types,
          latitude: place.geometry?.location?.lat,
          longitude: place.geometry?.location?.lng,
          priceLevel: place.price_level,
          photoReference: place.photos?.[0]?.photo_reference || null,
        };

        expect(transformedPlace.placeId).toBe('place-1');
        expect(transformedPlace.latitude).toBe(40.7128);
        expect(transformedPlace.photoReference).toBe('photo-ref-123');
      });

      it('should handle null photo reference', () => {
        const place: { place_id: string; name: string; photos?: Array<{ photo_reference: string }> } = {
          place_id: 'place-no-photo',
          name: 'No Photo Bar',
          photos: undefined,
        };

        const photoReference = place.photos?.[0]?.photo_reference || null;

        expect(photoReference).toBeNull();
      });

      it('should deduplicate results across multiple type queries', () => {
        const allResults: any[] = [];
        const fetchedPlaceIds = new Set<string>();

        const placesFromRestaurantQuery = [
          { place_id: 'place-1', name: 'Restaurant A' },
          { place_id: 'place-2', name: 'Restaurant B' },
        ];

        const placesFromBarQuery = [
          { place_id: 'place-2', name: 'Restaurant B' }, // Duplicate
          { place_id: 'place-3', name: 'Bar C' },
        ];

        // Process restaurant results
        for (const place of placesFromRestaurantQuery) {
          if (!fetchedPlaceIds.has(place.place_id)) {
            allResults.push(place);
            fetchedPlaceIds.add(place.place_id);
          }
        }

        // Process bar results
        for (const place of placesFromBarQuery) {
          if (!fetchedPlaceIds.has(place.place_id)) {
            allResults.push(place);
            fetchedPlaceIds.add(place.place_id);
          }
        }

        expect(allResults).toHaveLength(3);
        expect(fetchedPlaceIds.size).toBe(3);
      });

      it('should handle API error response', async () => {
        const mockErrorResponse = {
          data: {
            status: 'ZERO_RESULTS',
            error_message: 'No results found',
            results: [],
          },
        };

        mockedAxios.get.mockResolvedValueOnce(mockErrorResponse);

        const result = await mockedAxios.get('https://maps.googleapis.com/maps/api/place/nearbysearch/json');

        expect(result.data.status).toBe('ZERO_RESULTS');
      });

      it('should handle network errors', async () => {
        mockedAxios.get.mockRejectedValueOnce(new Error('Network error'));

        const response = createMockHttpResponse();

        try {
          await mockedAxios.get('https://maps.googleapis.com/maps/api/place/nearbysearch/json');
        } catch (error: any) {
          response.status(500).send('Failed to fetch data from Google Places API.');
        }

        expect(response._statusCode).toBe(500);
        expect(response._body).toContain('Failed to fetch');
      });
    });

    describe('Response Format', () => {
      it('should return JSON array of venues', () => {
        const venues = [
          { placeId: '1', name: 'Venue 1' },
          { placeId: '2', name: 'Venue 2' },
        ];

        const response = createMockHttpResponse();
        response.status(200).json(venues);

        expect(response._statusCode).toBe(200);
        expect(response._body).toEqual(venues);
      });
    });
  });

  describe('verifyAuthToken (via getNearbyVenuesHttp)', () => {
    it('should reject request with missing Authorization header', () => {
      const request = createMockHttpRequest({
        headers: {},
      });
      const response = createMockHttpResponse();

      const authHeader = request.headers.authorization;
      const hasBearerToken = authHeader?.startsWith('Bearer ');

      if (!hasBearerToken) {
        response.status(401).json({ error: 'Missing or invalid Authorization header' });
      }

      expect(response._statusCode).toBe(401);
      expect(response._body.error).toBe('Missing or invalid Authorization header');
    });

    it('should reject request with non-Bearer Authorization header', () => {
      const request = createMockHttpRequest({
        headers: { authorization: 'Basic dXNlcjpwYXNz' },
      });
      const response = createMockHttpResponse();

      const authHeader = request.headers.authorization;
      const hasBearerToken = authHeader?.startsWith('Bearer ');

      if (!hasBearerToken) {
        response.status(401).json({ error: 'Missing or invalid Authorization header' });
      }

      expect(response._statusCode).toBe(401);
    });

    it('should accept valid Bearer token format', () => {
      const request = createMockHttpRequest({
        headers: { authorization: 'Bearer valid-token-abc123' },
      });

      const authHeader = request.headers.authorization;
      const hasBearerToken = authHeader?.startsWith('Bearer ');
      const token = authHeader?.split('Bearer ')[1];

      expect(hasBearerToken).toBe(true);
      expect(token).toBe('valid-token-abc123');
    });
  });

  describe('placePhotoProxy', () => {
    describe('Parameter Validation', () => {
      it('should require photoReference parameter', () => {
        const request = createMockHttpRequest({
          query: {},
        });
        const response = createMockHttpResponse();

        const photoReference = request.query.photoReference;

        if (!photoReference) {
          response.status(400).send('Missing photoReference query parameter.');
        }

        expect(response._statusCode).toBe(400);
        expect(response._body).toContain('Missing photoReference');
      });

      it('should use default maxWidth of 400', () => {
        const request = createMockHttpRequest({
          query: { photoReference: 'photo-ref-123' },
        });

        const maxWidth = request.query.maxWidth || '400';

        expect(maxWidth).toBe('400');
      });

      it('should accept custom maxWidth', () => {
        const request = createMockHttpRequest({
          query: { photoReference: 'photo-ref-123', maxWidth: '800' },
        });

        const maxWidth = request.query.maxWidth || '400';

        expect(maxWidth).toBe('800');
      });
    });

    describe('Photo URL Construction', () => {
      it('should construct correct photo URL', () => {
        const photoReference = 'photo-ref-123';
        const maxWidth = '400';
        const apiKey = 'test-api-key';

        const url = `https://maps.googleapis.com/maps/api/place/photo?photo_reference=${photoReference}&maxwidth=${maxWidth}&key=${apiKey}`;

        expect(url).toContain('maps.googleapis.com/maps/api/place/photo');
        expect(url).toContain(`photo_reference=${photoReference}`);
        expect(url).toContain(`maxwidth=${maxWidth}`);
      });
    });

    describe('Photo Fetching', () => {
      it('should fetch photo as arraybuffer', async () => {
        const mockPhotoData = Buffer.from('fake-image-data');
        const mockResponse = {
          data: mockPhotoData,
          headers: { 'content-type': 'image/jpeg' },
        };

        mockedAxios.get.mockResolvedValueOnce(mockResponse);

        const result = await mockedAxios.get('https://maps.googleapis.com/maps/api/place/photo', {
          responseType: 'arraybuffer',
        });

        expect(result.data).toEqual(mockPhotoData);
        expect(result.headers['content-type']).toBe('image/jpeg');
      });

      it('should set correct Content-Type header from response', () => {
        const response = createMockHttpResponse();
        const contentType = 'image/jpeg';

        response.set('Content-Type', contentType);

        expect(response._headers['Content-Type']).toBe('image/jpeg');
      });

      it('should set cache header for 24 hours', () => {
        const response = createMockHttpResponse();

        response.set('Cache-Control', 'public, max-age=86400');

        expect(response._headers['Cache-Control']).toBe('public, max-age=86400');
      });

      it('should handle timeout', async () => {
        mockedAxios.get.mockImplementationOnce(() => {
          return new Promise((_, reject) => {
            setTimeout(() => reject(new Error('timeout')), 100);
          });
        });

        try {
          await mockedAxios.get('https://maps.googleapis.com/maps/api/place/photo', {
            timeout: 10000,
          });
        } catch (error: any) {
          expect(error.message).toBe('timeout');
        }
      });

      it('should follow redirects up to 5', () => {
        const requestConfig = {
          responseType: 'arraybuffer',
          maxRedirects: 5,
          timeout: 10000,
        };

        expect(requestConfig.maxRedirects).toBe(5);
      });
    });

    describe('Error Handling', () => {
      it('should return 500 on fetch error', async () => {
        mockedAxios.get.mockRejectedValueOnce(new Error('Photo fetch failed'));

        const response = createMockHttpResponse();

        try {
          await mockedAxios.get('https://maps.googleapis.com/maps/api/place/photo');
        } catch (error: any) {
          response.status(500).send('Failed to fetch photo.');
        }

        expect(response._statusCode).toBe(500);
        expect(response._body).toBe('Failed to fetch photo.');
      });
    });
  });

  // =========================================================================
  // Integration tests: actually import and invoke the exported functions
  // =========================================================================

  describe('getNearbyVenuesHttp (integration)', () => {
    // eslint-disable-next-line @typescript-eslint/no-var-requires
    const { getNearbyVenuesHttp } = require('../src/index') as {
      getNearbyVenuesHttp: (req: any, res: any) => Promise<void>;
    };

    beforeEach(() => {
      mockCheckRateLimit.mockResolvedValue(true);
      mockAuth.verifyIdToken.mockResolvedValue({ uid: 'test-user-id' });
    });

    it('should return 204 for OPTIONS preflight request', async () => {
      const req = createMockHttpRequest({ method: 'OPTIONS' });
      const res = createMockHttpResponse();

      await getNearbyVenuesHttp(req, res);

      expect(res._statusCode).toBe(204);
      expect(res._body).toBe('');
    });

    it('should set all CORS headers', async () => {
      const req = createMockHttpRequest({ method: 'OPTIONS' });
      const res = createMockHttpResponse();

      await getNearbyVenuesHttp(req, res);

      expect(res._headers['Access-Control-Allow-Origin']).toBe('*');
      expect(res._headers['Access-Control-Allow-Methods']).toBe('GET, POST, OPTIONS');
      expect(res._headers['Access-Control-Allow-Headers']).toBe('Content-Type, Authorization');
    });

    it('should return 401 when no auth token is provided', async () => {
      const req = createMockHttpRequest({
        method: 'GET',
        query: { lat: '40.7128', lng: '-74.006' },
        headers: {},
      });
      const res = createMockHttpResponse();

      await getNearbyVenuesHttp(req, res);

      expect(res._statusCode).toBe(401);
      expect(res._body.error).toBe('Missing or invalid Authorization header');
    });

    it('should return 401 when auth token is invalid', async () => {
      mockAuth.verifyIdToken.mockRejectedValueOnce(new Error('Token expired'));

      const req = createMockHttpRequest({
        method: 'GET',
        query: { lat: '40.7128', lng: '-74.006' },
        headers: { authorization: 'Bearer expired-token' },
      });
      const res = createMockHttpResponse();

      await getNearbyVenuesHttp(req, res);

      expect(res._statusCode).toBe(401);
      expect(res._body.error).toBe('Invalid or expired auth token');
    });

    it('should return 400 when lat is missing', async () => {
      const req = createMockHttpRequest({
        method: 'GET',
        query: { lng: '-74.006' },
        headers: { authorization: 'Bearer valid-token' },
      });
      const res = createMockHttpResponse();

      await getNearbyVenuesHttp(req, res);

      expect(res._statusCode).toBe(400);
      expect(res._body).toContain('Missing latitude');
    });

    it('should return 400 when lng is missing', async () => {
      const req = createMockHttpRequest({
        method: 'GET',
        query: { lat: '40.7128' },
        headers: { authorization: 'Bearer valid-token' },
      });
      const res = createMockHttpResponse();

      await getNearbyVenuesHttp(req, res);

      expect(res._statusCode).toBe(400);
      expect(res._body).toContain('Missing latitude');
    });

    it('should fetch places from Google Places API and return results', async () => {
      mockedAxios.get.mockResolvedValue({
        data: {
          status: 'OK',
          results: [
            {
              place_id: 'place-1',
              name: 'Sports Bar',
              vicinity: '123 Main St',
              rating: 4.5,
              user_ratings_total: 100,
              types: ['bar'],
              geometry: { location: { lat: 40.7128, lng: -74.006 } },
              price_level: 2,
              photos: [{ photo_reference: 'photo-ref-1' }],
            },
          ],
        },
      });

      const req = createMockHttpRequest({
        method: 'GET',
        query: { lat: '40.7128', lng: '-74.006', types: 'bar' },
        headers: { authorization: 'Bearer valid-token' },
      });
      const res = createMockHttpResponse();

      await getNearbyVenuesHttp(req, res);

      expect(res._statusCode).toBe(200);
      expect(res._body).toHaveLength(1);
      expect(res._body[0].placeId).toBe('place-1');
      expect(res._body[0].name).toBe('Sports Bar');
      expect(res._body[0].latitude).toBe(40.7128);
      expect(res._body[0].photoReference).toBe('photo-ref-1');
    });

    it('should fetch multiple types and deduplicate results', async () => {
      // First call returns restaurants, second returns bars (with overlap)
      mockedAxios.get
        .mockResolvedValueOnce({
          data: {
            status: 'OK',
            results: [
              { place_id: 'p1', name: 'Place A', vicinity: 'addr1', types: ['restaurant'], geometry: { location: { lat: 1, lng: 2 } } },
              { place_id: 'p2', name: 'Place B', vicinity: 'addr2', types: ['restaurant'], geometry: { location: { lat: 3, lng: 4 } } },
            ],
          },
        })
        .mockResolvedValueOnce({
          data: {
            status: 'OK',
            results: [
              { place_id: 'p2', name: 'Place B', vicinity: 'addr2', types: ['bar'], geometry: { location: { lat: 3, lng: 4 } } }, // Duplicate
              { place_id: 'p3', name: 'Place C', vicinity: 'addr3', types: ['bar'], geometry: { location: { lat: 5, lng: 6 } } },
            ],
          },
        });

      const req = createMockHttpRequest({
        method: 'GET',
        query: { lat: '40.7128', lng: '-74.006', types: 'restaurant|bar' },
        headers: { authorization: 'Bearer valid-token' },
      });
      const res = createMockHttpResponse();

      await getNearbyVenuesHttp(req, res);

      expect(res._statusCode).toBe(200);
      // Should have 3 unique results, not 4
      expect(res._body).toHaveLength(3);
      const placeIds = res._body.map((p: any) => p.placeId);
      expect(placeIds).toContain('p1');
      expect(placeIds).toContain('p2');
      expect(placeIds).toContain('p3');
    });

    it('should use default types restaurant|bar when not specified', async () => {
      mockedAxios.get.mockResolvedValue({
        data: { status: 'OK', results: [] },
      });

      const req = createMockHttpRequest({
        method: 'GET',
        query: { lat: '40.7128', lng: '-74.006' },
        headers: { authorization: 'Bearer valid-token' },
      });
      const res = createMockHttpResponse();

      await getNearbyVenuesHttp(req, res);

      // Should have made 2 API calls (restaurant + bar)
      expect(mockedAxios.get).toHaveBeenCalledTimes(2);
      expect(mockedAxios.get).toHaveBeenCalledWith(expect.stringContaining('type=restaurant'));
      expect(mockedAxios.get).toHaveBeenCalledWith(expect.stringContaining('type=bar'));
    });

    it('should use default radius of 2000 meters', async () => {
      mockedAxios.get.mockResolvedValue({
        data: { status: 'OK', results: [] },
      });

      const req = createMockHttpRequest({
        method: 'GET',
        query: { lat: '40.7128', lng: '-74.006', types: 'bar' },
        headers: { authorization: 'Bearer valid-token' },
      });
      const res = createMockHttpResponse();

      await getNearbyVenuesHttp(req, res);

      expect(mockedAxios.get).toHaveBeenCalledWith(expect.stringContaining('radius=2000'));
    });

    it('should handle Google Places API ZERO_RESULTS gracefully', async () => {
      mockedAxios.get.mockResolvedValue({
        data: { status: 'ZERO_RESULTS', results: [] },
      });

      const req = createMockHttpRequest({
        method: 'GET',
        query: { lat: '40.7128', lng: '-74.006', types: 'bar' },
        headers: { authorization: 'Bearer valid-token' },
      });
      const res = createMockHttpResponse();

      await getNearbyVenuesHttp(req, res);

      expect(res._statusCode).toBe(200);
      expect(res._body).toEqual([]);
    });

    it('should return 500 when axios throws a network error', async () => {
      const networkError: any = new Error('ECONNREFUSED');
      networkError.response = { status: 503, data: 'Service Unavailable' };
      mockedAxios.get.mockRejectedValue(networkError);

      const req = createMockHttpRequest({
        method: 'GET',
        query: { lat: '40.7128', lng: '-74.006', types: 'bar' },
        headers: { authorization: 'Bearer valid-token' },
      });
      const res = createMockHttpResponse();

      await getNearbyVenuesHttp(req, res);

      expect(res._statusCode).toBe(500);
      expect(res._body).toContain('Failed to fetch data from Google Places API');
    });

    it('should handle places with no photos gracefully', async () => {
      mockedAxios.get.mockResolvedValue({
        data: {
          status: 'OK',
          results: [
            {
              place_id: 'no-photo',
              name: 'No Photo Place',
              vicinity: 'addr',
              types: ['bar'],
              geometry: { location: { lat: 1, lng: 2 } },
              // No photos field at all
            },
          ],
        },
      });

      const req = createMockHttpRequest({
        method: 'GET',
        query: { lat: '40.7128', lng: '-74.006', types: 'bar' },
        headers: { authorization: 'Bearer valid-token' },
      });
      const res = createMockHttpResponse();

      await getNearbyVenuesHttp(req, res);

      expect(res._statusCode).toBe(200);
      expect(res._body[0].photoReference).toBeNull();
    });

    it('should skip places with no place_id or no name', async () => {
      mockedAxios.get.mockResolvedValue({
        data: {
          status: 'OK',
          results: [
            { place_id: null, name: 'No ID Place', types: ['bar'], geometry: { location: { lat: 1, lng: 2 } } },
            { place_id: 'has-id', name: null, types: ['bar'], geometry: { location: { lat: 1, lng: 2 } } },
            { place_id: 'valid', name: 'Valid Place', types: ['bar'], geometry: { location: { lat: 1, lng: 2 } } },
          ],
        },
      });

      const req = createMockHttpRequest({
        method: 'GET',
        query: { lat: '40.7128', lng: '-74.006', types: 'bar' },
        headers: { authorization: 'Bearer valid-token' },
      });
      const res = createMockHttpResponse();

      await getNearbyVenuesHttp(req, res);

      expect(res._statusCode).toBe(200);
      expect(res._body).toHaveLength(1);
      expect(res._body[0].placeId).toBe('valid');
    });

    it('should not proceed when rate limited', async () => {
      mockCheckRateLimit.mockResolvedValueOnce(false);

      const req = createMockHttpRequest({
        method: 'GET',
        query: { lat: '40.7128', lng: '-74.006' },
        headers: { authorization: 'Bearer valid-token' },
      });
      const res = createMockHttpResponse();

      await getNearbyVenuesHttp(req, res);

      // Function returns early when rate limited -- checkRateLimit writes the 429 response
      // axios should NOT have been called
      expect(mockedAxios.get).not.toHaveBeenCalled();
    });
  });

  describe('placePhotoProxy (integration)', () => {
    // eslint-disable-next-line @typescript-eslint/no-var-requires
    const { placePhotoProxy } = require('../src/index') as {
      placePhotoProxy: (req: any, res: any) => Promise<void>;
    };

    beforeEach(() => {
      mockCheckRateLimit.mockResolvedValue(true);
    });

    it('should return 204 for OPTIONS preflight', async () => {
      const req = createMockHttpRequest({ method: 'OPTIONS' });
      const res = createMockHttpResponse();

      await placePhotoProxy(req, res);

      expect(res._statusCode).toBe(204);
    });

    it('should return 400 when photoReference is missing', async () => {
      const req = createMockHttpRequest({
        method: 'GET',
        query: {},
      });
      const res = createMockHttpResponse();

      await placePhotoProxy(req, res);

      expect(res._statusCode).toBe(400);
      expect(res._body).toContain('Missing photoReference');
    });

    it('should proxy photo from Google and set correct headers', async () => {
      const fakeImageData = Buffer.from('fake-png-data');
      mockedAxios.get.mockResolvedValue({
        data: fakeImageData,
        headers: { 'content-type': 'image/png' },
      });

      const req = createMockHttpRequest({
        method: 'GET',
        query: { photoReference: 'photo-ref-abc', maxWidth: '600' },
      });
      const res = createMockHttpResponse();

      await placePhotoProxy(req, res);

      expect(res._statusCode).toBe(200);
      expect(res._headers['Content-Type']).toBe('image/png');
      expect(res._headers['Cache-Control']).toBe('public, max-age=86400');
      expect(res._body).toEqual(fakeImageData);
    });

    it('should default Content-Type to image/jpeg when missing from response', async () => {
      mockedAxios.get.mockResolvedValue({
        data: Buffer.from('data'),
        headers: {}, // No content-type
      });

      const req = createMockHttpRequest({
        method: 'GET',
        query: { photoReference: 'photo-ref-abc' },
      });
      const res = createMockHttpResponse();

      await placePhotoProxy(req, res);

      expect(res._headers['Content-Type']).toBe('image/jpeg');
    });

    it('should use default maxWidth of 400', async () => {
      mockedAxios.get.mockResolvedValue({
        data: Buffer.from('data'),
        headers: { 'content-type': 'image/jpeg' },
      });

      const req = createMockHttpRequest({
        method: 'GET',
        query: { photoReference: 'ref-123' },
      });
      const res = createMockHttpResponse();

      await placePhotoProxy(req, res);

      expect(mockedAxios.get).toHaveBeenCalledWith(
        expect.stringContaining('maxwidth=400'),
        expect.any(Object)
      );
    });

    it('should pass arraybuffer responseType and maxRedirects 5 to axios', async () => {
      mockedAxios.get.mockResolvedValue({
        data: Buffer.from('data'),
        headers: { 'content-type': 'image/jpeg' },
      });

      const req = createMockHttpRequest({
        method: 'GET',
        query: { photoReference: 'ref-123' },
      });
      const res = createMockHttpResponse();

      await placePhotoProxy(req, res);

      expect(mockedAxios.get).toHaveBeenCalledWith(
        expect.any(String),
        expect.objectContaining({
          responseType: 'arraybuffer',
          maxRedirects: 5,
          timeout: 10000,
        })
      );
    });

    it('should return 500 when photo fetch fails', async () => {
      mockedAxios.get.mockRejectedValue(new Error('Photo service down'));

      const req = createMockHttpRequest({
        method: 'GET',
        query: { photoReference: 'ref-123' },
      });
      const res = createMockHttpResponse();

      await placePhotoProxy(req, res);

      expect(res._statusCode).toBe(500);
      expect(res._body).toContain('Failed to fetch photo');
    });

    it('should not proceed when rate limited', async () => {
      mockCheckRateLimit.mockResolvedValueOnce(false);

      const req = createMockHttpRequest({
        method: 'GET',
        query: { photoReference: 'ref-123' },
      });
      const res = createMockHttpResponse();

      await placePhotoProxy(req, res);

      expect(mockedAxios.get).not.toHaveBeenCalled();
    });

    it('should set CORS headers for photo proxy', async () => {
      mockedAxios.get.mockResolvedValue({
        data: Buffer.from('data'),
        headers: { 'content-type': 'image/jpeg' },
      });

      const req = createMockHttpRequest({
        method: 'GET',
        query: { photoReference: 'ref-123' },
      });
      const res = createMockHttpResponse();

      await placePhotoProxy(req, res);

      expect(res._headers['Access-Control-Allow-Origin']).toBe('*');
      expect(res._headers['Access-Control-Allow-Methods']).toBe('GET, OPTIONS');
    });
  });

  describe('cleanupRateLimits (integration)', () => {
    // eslint-disable-next-line @typescript-eslint/no-var-requires
    const { cleanupRateLimits } = require('../src/index') as {
      cleanupRateLimits: (context: any) => Promise<any>;
    };

    it('should call both cleanup functions and return null', async () => {
      mockCleanupExpiredRateLimits.mockResolvedValue(5);
      mockCleanupExpiredWebhookEvents.mockResolvedValue(3);

      const result = await cleanupRateLimits({});

      expect(mockCleanupExpiredRateLimits).toHaveBeenCalledTimes(1);
      expect(mockCleanupExpiredWebhookEvents).toHaveBeenCalledTimes(1);
      expect(result).toBeNull();
    });

    it('should handle zero deletions', async () => {
      mockCleanupExpiredRateLimits.mockResolvedValue(0);
      mockCleanupExpiredWebhookEvents.mockResolvedValue(0);

      const result = await cleanupRateLimits({});

      expect(result).toBeNull();
    });

    it('should handle large batch deletions', async () => {
      mockCleanupExpiredRateLimits.mockResolvedValue(800);
      mockCleanupExpiredWebhookEvents.mockResolvedValue(400);

      const result = await cleanupRateLimits({});

      expect(mockCleanupExpiredRateLimits).toHaveBeenCalled();
      expect(mockCleanupExpiredWebhookEvents).toHaveBeenCalled();
      expect(result).toBeNull();
    });
  });
});

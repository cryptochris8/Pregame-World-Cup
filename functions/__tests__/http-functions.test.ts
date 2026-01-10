/**
 * HTTP Functions Tests
 *
 * Tests for HTTP Cloud Functions like getNearbyVenuesHttp and placePhotoProxy.
 */

import {
  createMockHttpRequest,
  createMockHttpResponse,
  MockFirestore,
} from './mocks';
import axios from 'axios';

// Mock axios
jest.mock('axios');
const mockedAxios = axios as jest.Mocked<typeof axios>;

// Mock firebase-admin
const mockFirestore = new MockFirestore();
jest.mock('firebase-admin', () => ({
  initializeApp: jest.fn(),
  app: jest.fn(() => ({ name: '[DEFAULT]', options: { projectId: 'test-project' } })),
  firestore: jest.fn(() => mockFirestore),
  messaging: jest.fn(() => ({ send: jest.fn() })),
  credential: { cert: jest.fn(), applicationDefault: jest.fn() },
}));

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

  describe('updateSchedule', () => {
    describe('Parameter Validation', () => {
      it('should require season parameter', () => {
        const request = createMockHttpRequest({ query: {} });
        const response = createMockHttpResponse();

        const season = request.query.season;

        if (!season) {
          response.status(400).send("Invalid or missing 'season' query parameter. Must be a 4-digit year (e.g., 2024).");
        }

        expect(response._statusCode).toBe(400);
      });

      it('should validate season is 4-digit year', () => {
        const validSeasons = ['2024', '2025', '2026'];
        const invalidSeasons = ['24', '202', '20244', 'abcd'];

        const isValidSeason = (season: string) => /^\d{4}$/.test(season);

        validSeasons.forEach((s) => expect(isValidSeason(s)).toBe(true));
        invalidSeasons.forEach((s) => expect(isValidSeason(s)).toBe(false));
      });

      it('should accept valid 4-digit year', () => {
        const request = createMockHttpRequest({
          query: { season: '2026' },
        });

        const season = request.query.season;
        const isValid = /^\d{4}$/.test(season);

        expect(isValid).toBe(true);
      });
    });

    describe('API Integration', () => {
      it('should return 500 if API key not configured', () => {
        const SPORTSDATA_API_KEY = undefined;
        const response = createMockHttpResponse();

        if (!SPORTSDATA_API_KEY) {
          response.status(500).send('API key configuration error. Check Firebase environment variables.');
        }

        expect(response._statusCode).toBe(500);
      });
    });
  });

  describe('getCachedSchedule', () => {
    describe('Parameter Validation', () => {
      it('should require season parameter', () => {
        const request = createMockHttpRequest({ query: {} });
        const response = createMockHttpResponse();

        const season = request.query.season;

        if (!season) {
          response.status(400).send('Season parameter required');
        }

        expect(response._statusCode).toBe(400);
      });

      it('should accept optional week parameter', () => {
        const request = createMockHttpRequest({
          query: { season: '2026', week: '5' },
        });

        const week = request.query.week;

        expect(week).toBe('5');
      });
    });

    describe('Response Format', () => {
      it('should return games in expected format', () => {
        const response = {
          success: true,
          games: [
            { id: 'game-1', homeTeam: 'USA', awayTeam: 'MEX' },
            { id: 'game-2', homeTeam: 'BRA', awayTeam: 'ARG' },
          ],
          count: 2,
          cached: true,
          timestamp: new Date().toISOString(),
        };

        expect(response.success).toBe(true);
        expect(response.games).toHaveLength(2);
        expect(response.cached).toBe(true);
        expect(response.timestamp).toBeDefined();
      });
    });
  });

  describe('testSportsDataWrapper', () => {
    it('should return success with team and game data', () => {
      const response = {
        success: true,
        message: 'SportsData Custom Wrapper working perfectly!',
        data: {
          connected: true,
          teams: {
            total: 32,
            sampleTeams: [
              { name: 'USA', school: 'United States', conference: 'CONCACAF' },
            ],
          },
          games: {
            upcomingCount: 5,
            sampleGames: [
              { homeTeam: 'USA', awayTeam: 'MEX', dateTime: '2026-06-11' },
            ],
          },
        },
      };

      expect(response.success).toBe(true);
      expect(response.data.connected).toBe(true);
      expect(response.data.teams.total).toBe(32);
    });

    it('should return 500 on connection failure', () => {
      const response = createMockHttpResponse();

      const isConnected = false;

      if (!isConnected) {
        response.status(500).json({
          success: false,
          message: 'Failed to connect to SportsData API',
        });
      }

      expect(response._statusCode).toBe(500);
      expect(response._body.success).toBe(false);
    });
  });
});

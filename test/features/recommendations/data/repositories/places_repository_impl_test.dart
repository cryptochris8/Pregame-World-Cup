import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/core/entities/cached_geocoding_data.dart';
import 'package:pregame_world_cup/core/entities/cached_venue_data.dart';
import 'package:pregame_world_cup/core/services/cache_service.dart';
import 'package:pregame_world_cup/features/recommendations/data/datasources/places_api_datasource.dart';
import 'package:pregame_world_cup/features/recommendations/data/repositories/places_repository_impl.dart';
import 'package:pregame_world_cup/features/recommendations/domain/entities/place.dart';
import 'package:pregame_world_cup/features/recommendations/domain/entities/venue_filter.dart';
import 'package:pregame_world_cup/features/recommendations/domain/repositories/places_repository.dart';

// ==================== MOCKS ====================

class MockPlacesApiDataSource extends Mock implements PlacesApiDataSource {}

class MockCacheService extends Mock implements CacheService {}

class MockConnectivity extends Mock implements Connectivity {}

class MockCachedVenueData extends Mock implements CachedVenueData {}

class MockCachedGeocodingData extends Mock implements CachedGeocodingData {}

// ==================== TEST DATA ====================

const _testLat = 40.7128;
const _testLng = -74.0060;
const _testRadius = 2000.0;
const _testTypes = ['restaurant', 'bar'];

final _testPlaces = [
  const Place(
    placeId: 'place_1',
    name: 'Sports Bar A',
    rating: 4.5,
    latitude: 40.7130,
    longitude: -74.0055,
  ),
  const Place(
    placeId: 'place_2',
    name: 'Restaurant B',
    rating: 4.2,
    latitude: 40.7125,
    longitude: -74.0065,
  ),
];

// ==================== TESTABLE SUBCLASS ====================

/// Testable subclass that overrides connectivity check
class TestablePlacesRepositoryImpl extends PlacesRepositoryImpl {
  final MockCacheService testCacheService;
  final bool hasConnection;

  TestablePlacesRepositoryImpl({
    required PlacesApiDataSource remoteDataSource,
    required this.testCacheService,
    this.hasConnection = true,
  }) : super(remoteDataSource: remoteDataSource);
}

// ==================== TESTS ====================

void main() {
  late MockPlacesApiDataSource mockDataSource;
  late MockCacheService mockCacheService;

  setUp(() {
    mockDataSource = MockPlacesApiDataSource();
    mockCacheService = MockCacheService();
  });

  group('PlacesRepositoryImpl', () {
    // =========================================================================
    // Constructor
    // =========================================================================
    test('creates instance with required dependency', () {
      final repo = PlacesRepositoryImpl(remoteDataSource: mockDataSource);
      expect(repo, isNotNull);
      expect(repo, isA<PlacesRepository>());
    });

    // =========================================================================
    // getFilteredVenues tests
    // =========================================================================
    group('getFilteredVenues', () {
      test('returns Right with places on success', () async {
        final repo = PlacesRepositoryImpl(remoteDataSource: mockDataSource);
        const filter = VenueFilter(
          venueTypes: [VenueType.bar, VenueType.restaurant],
          maxDistance: 2.0,
          minRating: 4.0,
          openNow: true,
        );

        when(() => mockDataSource.fetchFilteredVenues(
              lat: _testLat,
              lng: _testLng,
              radius: 2000,
              types: ['bar', 'restaurant'],
              minPrice: null,
              maxPrice: null,
              minRating: 4.0,
              openNow: true,
            )).thenAnswer((_) async => _testPlaces);

        final result = await repo.getFilteredVenues(
          latitude: _testLat,
          longitude: _testLng,
          filter: filter,
        );

        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (places) {
            expect(places.length, 2);
            expect(places[0].name, 'Sports Bar A');
            expect(places[1].name, 'Restaurant B');
          },
        );
      });

      test('returns Left with ServerFailure on exception', () async {
        final repo = PlacesRepositoryImpl(remoteDataSource: mockDataSource);
        const filter = VenueFilter();

        when(() => mockDataSource.fetchFilteredVenues(
              lat: any(named: 'lat'),
              lng: any(named: 'lng'),
              radius: any(named: 'radius'),
              types: any(named: 'types'),
              minPrice: any(named: 'minPrice'),
              maxPrice: any(named: 'maxPrice'),
              minRating: any(named: 'minRating'),
              openNow: any(named: 'openNow'),
            )).thenThrow(Exception('Network error'));

        final result = await repo.getFilteredVenues(
          latitude: _testLat,
          longitude: _testLng,
          filter: filter,
        );

        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, 'Server error occurred');
          },
          (_) => fail('Should not return places'),
        );
      });

      test('converts maxDistance from km to meters', () async {
        final repo = PlacesRepositoryImpl(remoteDataSource: mockDataSource);
        const filter = VenueFilter(maxDistance: 5.0);

        when(() => mockDataSource.fetchFilteredVenues(
              lat: _testLat,
              lng: _testLng,
              radius: 5000, // 5.0 km * 1000
              types: any(named: 'types'),
              minPrice: any(named: 'minPrice'),
              maxPrice: any(named: 'maxPrice'),
              minRating: any(named: 'minRating'),
              openNow: any(named: 'openNow'),
            )).thenAnswer((_) async => []);

        await repo.getFilteredVenues(
          latitude: _testLat,
          longitude: _testLng,
          filter: filter,
        );

        verify(() => mockDataSource.fetchFilteredVenues(
              lat: _testLat,
              lng: _testLng,
              radius: 5000,
              types: any(named: 'types'),
              minPrice: any(named: 'minPrice'),
              maxPrice: any(named: 'maxPrice'),
              minRating: any(named: 'minRating'),
              openNow: any(named: 'openNow'),
            )).called(1);
      });

      test('passes price level value from filter', () async {
        final repo = PlacesRepositoryImpl(remoteDataSource: mockDataSource);
        const filter = VenueFilter(
          priceLevel: PriceLevel.moderate,
          maxDistance: 2.0,
        );

        when(() => mockDataSource.fetchFilteredVenues(
              lat: any(named: 'lat'),
              lng: any(named: 'lng'),
              radius: any(named: 'radius'),
              types: any(named: 'types'),
              minPrice: 2, // PriceLevel.moderate.value
              maxPrice: 2,
              minRating: any(named: 'minRating'),
              openNow: any(named: 'openNow'),
            )).thenAnswer((_) async => []);

        await repo.getFilteredVenues(
          latitude: _testLat,
          longitude: _testLng,
          filter: filter,
        );

        verify(() => mockDataSource.fetchFilteredVenues(
              lat: _testLat,
              lng: _testLng,
              radius: 2000,
              types: ['bar', 'restaurant'],
              minPrice: 2,
              maxPrice: 2,
              minRating: null,
              openNow: false,
            )).called(1);
      });
    });

    // =========================================================================
    // VenueFilter tests
    // =========================================================================
    group('VenueFilter', () {
      test('default filter has bars and restaurants', () {
        const filter = VenueFilter();
        expect(filter.venueTypes, [VenueType.bar, VenueType.restaurant]);
        expect(filter.maxDistance, 2.0);
        expect(filter.openNow, false);
      });

      test('VenueFilter.all includes all types', () {
        final filter = VenueFilter.all();
        expect(filter.venueTypes.length, 4);
        expect(filter.maxDistance, 5.0);
      });

      test('VenueFilter.barsOnly includes only bars and nightclubs', () {
        final filter = VenueFilter.barsOnly();
        expect(filter.venueTypes, [VenueType.bar, VenueType.nightclub]);
      });

      test('VenueFilter.restaurantsOnly includes restaurants and cafes', () {
        final filter = VenueFilter.restaurantsOnly();
        expect(filter.venueTypes, [VenueType.restaurant, VenueType.cafe]);
      });

      test('venueTypesToApi converts to API values', () {
        const filter = VenueFilter(
          venueTypes: [VenueType.bar, VenueType.nightclub],
        );
        expect(filter.venueTypesToApi, ['bar', 'night_club']);
      });

      test('copyWith preserves unchanged fields', () {
        const original = VenueFilter(
          venueTypes: [VenueType.bar],
          maxDistance: 3.0,
          minRating: 4.0,
          openNow: true,
        );

        final modified = original.copyWith(maxDistance: 5.0);

        expect(modified.venueTypes, [VenueType.bar]);
        expect(modified.maxDistance, 5.0);
        expect(modified.minRating, 4.0);
        expect(modified.openNow, true);
      });

      test('VenueFilter equality works correctly', () {
        const filter1 = VenueFilter(
          venueTypes: [VenueType.bar],
          maxDistance: 2.0,
        );
        const filter2 = VenueFilter(
          venueTypes: [VenueType.bar],
          maxDistance: 2.0,
        );

        expect(filter1, equals(filter2));
      });
    });

    // =========================================================================
    // PriceLevel tests
    // =========================================================================
    group('PriceLevel', () {
      test('each level has correct value', () {
        expect(PriceLevel.inexpensive.value, 1);
        expect(PriceLevel.moderate.value, 2);
        expect(PriceLevel.expensive.value, 3);
        expect(PriceLevel.veryExpensive.value, 4);
      });
    });

    // =========================================================================
    // VenueType tests
    // =========================================================================
    group('VenueType', () {
      test('each type has correct API value', () {
        expect(VenueType.bar.apiValue, 'bar');
        expect(VenueType.restaurant.apiValue, 'restaurant');
        expect(VenueType.cafe.apiValue, 'cafe');
        expect(VenueType.nightclub.apiValue, 'night_club');
        expect(VenueType.bakery.apiValue, 'bakery');
        expect(VenueType.liquorStore.apiValue, 'liquor_store');
      });
    });

    // =========================================================================
    // Failure types
    // =========================================================================
    group('Failure types', () {
      test('ServerFailure has correct message', () {
        final failure = ServerFailure();
        expect(failure.message, 'Server error occurred');
      });

      test('NetworkFailure has correct message', () {
        final failure = NetworkFailure();
        expect(failure.message, 'Network error occurred');
      });
    });
  });
}

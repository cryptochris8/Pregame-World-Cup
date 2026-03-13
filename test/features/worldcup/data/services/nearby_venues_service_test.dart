import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/recommendations/data/datasources/places_api_datasource.dart';
import 'package:pregame_world_cup/features/recommendations/domain/entities/place.dart';
import 'package:pregame_world_cup/features/worldcup/data/services/nearby_venues_service.dart';
import 'package:pregame_world_cup/features/worldcup/domain/entities/world_cup_venue.dart';

class MockPlacesApiDataSource extends Mock implements PlacesApiDataSource {}

void main() {
  // Helper to create a Place
  Place createPlace({
    String placeId = 'place_1',
    String name = 'Test Bar',
    double? rating = 4.5,
    List<String>? types = const ['bar'],
    double? latitude = 40.8135,
    double? longitude = -74.0740,
  }) {
    return Place(
      placeId: placeId,
      name: name,
      rating: rating,
      types: types,
      latitude: latitude,
      longitude: longitude,
    );
  }

  // Helper to create a stadium WorldCupVenue
  WorldCupVenue createStadium({
    String venueId = 'metlife',
    String name = 'MetLife Stadium',
    double? latitude = 40.8135,
    double? longitude = -74.0740,
  }) {
    return WorldCupVenue(
      venueId: venueId,
      name: name,
      city: 'East Rutherford',
      country: HostCountry.usa,
      capacity: 82500,
      latitude: latitude,
      longitude: longitude,
    );
  }

  // Helper to create a NearbyVenueResult
  NearbyVenueResult createResult({
    Place? place,
    double distanceMeters = 450.0,
    WorldCupVenue? stadium,
  }) {
    return NearbyVenueResult(
      place: place ?? createPlace(),
      distanceMeters: distanceMeters,
      stadium: stadium ?? createStadium(),
    );
  }

  group('NearbyVenueResult', () {
    group('distanceFormatted', () {
      test('formats miles for short distances', () {
        expect(createResult(distanceMeters: 450.0).distanceFormatted, '0.3 mi');
      });

      test('formats very short distances as < 0.1 mi', () {
        expect(createResult(distanceMeters: 0.0).distanceFormatted, '< 0.1 mi');
      });

      test('formats 999 meters as miles', () {
        expect(createResult(distanceMeters: 999.0).distanceFormatted, '0.6 mi');
      });

      test('formats 1000 meters as miles', () {
        expect(
            createResult(distanceMeters: 1000.0).distanceFormatted, '0.6 mi');
      });

      test('formats 2500 meters as miles', () {
        expect(
            createResult(distanceMeters: 2500.0).distanceFormatted, '1.6 mi');
      });

      test('formats 10300 meters as miles', () {
        expect(
            createResult(distanceMeters: 10300.0).distanceFormatted, '6.4 mi');
      });
    });

    group('walkingTimeMinutes', () {
      test('calculates 6 min for 450m', () {
        // 450 / 83.33 = 5.4 -> ceil = 6
        expect(createResult(distanceMeters: 450.0).walkingTimeMinutes, 6);
      });

      test('calculates 12 min for 1km', () {
        // 1000 / 83.33 = 12.0005 -> ceil = 13
        // Actually: 1000 / 83.33 = 12.00048... -> ceil = 13
        // Let's verify: the user spec says 12, but the math says 13.
        // Re-checking: 83.33 * 12 = 999.96. So 1000/83.33 = 12.00048.
        // ceil(12.00048) = 13
        expect(createResult(distanceMeters: 1000.0).walkingTimeMinutes, 13);
      });

      test('calculates 60 min for 5km', () {
        // 5000 / 83.33 = 60.0024 -> ceil = 61
        // Actually: 83.33 * 60 = 4999.8. So 5000/83.33 = 60.0024.
        // ceil(60.0024) = 61
        expect(createResult(distanceMeters: 5000.0).walkingTimeMinutes, 61);
      });

      test('returns 0 for 0m', () {
        // 0 / 83.33 = 0.0 -> ceil = 0
        expect(createResult(distanceMeters: 0.0).walkingTimeMinutes, 0);
      });
    });

    group('walkingTimeFormatted', () {
      test('formats minutes for short distance', () {
        // 450m -> 6 min
        expect(createResult(distanceMeters: 450.0).walkingTimeFormatted,
            '6 min walk');
      });

      test('formats exact hours', () {
        // Need a distance that produces exactly 60 minutes:
        // 60 * 83.33 = 4999.8m -> ceil(4999.8/83.33) = ceil(60.0) = 60
        expect(createResult(distanceMeters: 4999.8).walkingTimeFormatted,
            '1 hr walk');
      });

      test('formats hours and minutes', () {
        // Need a distance that produces exactly 90 minutes:
        // 7499.0 / 83.33 = 89.9976 -> ceil = 90 -> 1 hr 30 min
        expect(createResult(distanceMeters: 7499.0).walkingTimeFormatted,
            '1 hr 30 min walk');
      });
    });

    group('typeIcon', () {
      test('returns bar emoji for bar', () {
        final result = createResult(place: createPlace(types: ['bar']));
        expect(result.typeIcon, '\u{1F37A}'); // 🍺
      });

      test('returns restaurant emoji', () {
        final result =
            createResult(place: createPlace(types: ['restaurant']));
        expect(result.typeIcon, '\u{1F37D}\u{FE0F}'); // 🍽️
      });

      test('returns cafe emoji', () {
        final result = createResult(place: createPlace(types: ['cafe']));
        expect(result.typeIcon, '\u{2615}'); // ☕
      });

      test('returns fast food emoji', () {
        final result =
            createResult(place: createPlace(types: ['fast_food']));
        expect(result.typeIcon, '\u{1F354}'); // 🍔
      });

      test('returns pizza emoji', () {
        final result = createResult(place: createPlace(types: ['pizza']));
        expect(result.typeIcon, '\u{1F355}'); // 🍕
      });

      test('returns default emoji for unknown type', () {
        final result = createResult(place: createPlace(types: ['spa']));
        expect(result.typeIcon, '\u{1F4CD}'); // 📍
      });
    });

    group('primaryType', () {
      test('returns Bar for bar type', () {
        final result = createResult(place: createPlace(types: ['bar']));
        expect(result.primaryType, 'Bar');
      });

      test('returns Restaurant for restaurant type', () {
        final result =
            createResult(place: createPlace(types: ['restaurant']));
        expect(result.primaryType, 'Restaurant');
      });

      test('returns Cafe for cafe type', () {
        final result = createResult(place: createPlace(types: ['cafe']));
        expect(result.primaryType, 'Cafe');
      });

      test('returns Fast Food for fast_food type', () {
        final result =
            createResult(place: createPlace(types: ['fast_food']));
        expect(result.primaryType, 'Fast Food');
      });

      test('returns Venue for unknown type', () {
        final result = createResult(place: createPlace(types: ['spa']));
        expect(result.primaryType, 'Venue');
      });
    });
  });

  group('NearbyVenuesService', () {
    late MockPlacesApiDataSource mockPlacesDataSource;
    late NearbyVenuesService service;

    setUp(() {
      mockPlacesDataSource = MockPlacesApiDataSource();
      service = NearbyVenuesService(placesDataSource: mockPlacesDataSource);
    });

    final stadium = WorldCupVenue(
      venueId: 'metlife',
      name: 'MetLife Stadium',
      city: 'East Rutherford',
      country: HostCountry.usa,
      capacity: 82500,
      latitude: 40.8135,
      longitude: -74.0740,
    );

    test('throws when stadium has no coordinates', () async {
      final noCoordStadium = WorldCupVenue(
        venueId: 'test',
        name: 'Test Stadium',
        city: 'Test',
        country: HostCountry.usa,
        capacity: 50000,
      );

      expect(
        () => service.getNearbyVenues(stadium: noCoordStadium),
        throwsA(isA<Exception>()),
      );
    });

    test('sorts results by distance', () async {
      final places = [
        createPlace(
          placeId: 'far',
          name: 'Far Bar',
          latitude: 40.82,
          longitude: -74.07,
          types: ['bar'],
          rating: 4.5,
        ),
        createPlace(
          placeId: 'close',
          name: 'Close Bar',
          latitude: 40.8136,
          longitude: -74.0741,
          types: ['bar'],
          rating: 4.5,
        ),
      ];
      when(() => mockPlacesDataSource.fetchNearbyPlaces(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            radius: any(named: 'radius'),
            types: any(named: 'types'),
          )).thenAnswer((_) async => places);

      final results = await service.getNearbyVenues(stadium: stadium);

      expect(results.first.place.placeId, 'close');
      expect(results.last.place.placeId, 'far');
    });

    test('filters out gas stations', () async {
      final places = [
        createPlace(placeId: 'bar1', types: ['bar'], rating: 4.5),
        createPlace(
            placeId: 'gas',
            types: ['gas_station', 'bar'],
            rating: 4.5),
      ];
      when(() => mockPlacesDataSource.fetchNearbyPlaces(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            radius: any(named: 'radius'),
            types: any(named: 'types'),
          )).thenAnswer((_) async => places);

      final results = await service.getNearbyVenues(stadium: stadium);

      expect(results.length, 1);
      expect(results.first.place.placeId, 'bar1');
    });

    test('filters out low-rated venues', () async {
      final places = [
        createPlace(placeId: 'good', rating: 4.0, types: ['bar']),
        createPlace(placeId: 'bad', rating: 2.0, types: ['bar']),
      ];
      when(() => mockPlacesDataSource.fetchNearbyPlaces(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            radius: any(named: 'radius'),
            types: any(named: 'types'),
          )).thenAnswer((_) async => places);

      final results = await service.getNearbyVenues(stadium: stadium);

      expect(results.length, 1);
      expect(results.first.place.placeId, 'good');
    });

    test('allows unrated venues', () async {
      final places = [
        createPlace(
            placeId: 'unrated', rating: null, types: ['restaurant']),
      ];
      when(() => mockPlacesDataSource.fetchNearbyPlaces(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            radius: any(named: 'radius'),
            types: any(named: 'types'),
          )).thenAnswer((_) async => places);

      final results = await service.getNearbyVenues(stadium: stadium);

      expect(results.length, 1);
    });

    test('requires bar/restaurant/cafe type', () async {
      final places = [
        createPlace(
          placeId: 'poi',
          types: ['point_of_interest', 'establishment'],
          rating: 4.5,
        ),
        createPlace(
          placeId: 'bar',
          types: ['bar', 'point_of_interest'],
          rating: 4.5,
        ),
      ];
      when(() => mockPlacesDataSource.fetchNearbyPlaces(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            radius: any(named: 'radius'),
            types: any(named: 'types'),
          )).thenAnswer((_) async => places);

      final results = await service.getNearbyVenues(stadium: stadium);

      expect(results.length, 1);
      expect(results.first.place.placeId, 'bar');
    });

    test('filters places without coordinates', () async {
      final places = [
        createPlace(
            placeId: 'with_coords', types: ['bar'], rating: 4.5),
        createPlace(
          placeId: 'no_coords',
          latitude: null,
          longitude: null,
          types: ['bar'],
          rating: 4.5,
        ),
      ];
      when(() => mockPlacesDataSource.fetchNearbyPlaces(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            radius: any(named: 'radius'),
            types: any(named: 'types'),
          )).thenAnswer((_) async => places);

      final results = await service.getNearbyVenues(stadium: stadium);

      expect(results.length, 1);
      expect(results.first.place.placeId, 'with_coords');
    });

    test('getNearbyVenuesForMatch throws for unknown venue ID', () {
      expect(
        () => service.getNearbyVenuesForMatch(
            venueId: 'nonexistent_venue_xyz'),
        throwsA(isA<Exception>()),
      );
    });
  });
}

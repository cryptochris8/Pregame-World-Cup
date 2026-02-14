import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/entities/cached_venue_data.dart';
import 'package:pregame_world_cup/core/entities/cached_geocoding_data.dart';

void main() {
  group('CachedVenueData', () {
    test('creates cached venue data with all fields', () {
      final now = DateTime.now();
      final data = CachedVenueData(
        key: 'venues_33.95_-83.37_5000',
        venuesJson: '{"venues": []}',
        cachedAt: now,
        latitude: 33.95,
        longitude: -83.37,
        radius: 5000,
        types: ['bar', 'restaurant'],
      );

      expect(data.key, equals('venues_33.95_-83.37_5000'));
      expect(data.venuesJson, equals('{"venues": []}'));
      expect(data.cachedAt, equals(now));
      expect(data.latitude, equals(33.95));
      expect(data.longitude, equals(-83.37));
      expect(data.radius, equals(5000));
      expect(data.types, hasLength(2));
      expect(data.types, contains('bar'));
      expect(data.types, contains('restaurant'));
    });

    test('creates cached venue data with empty types', () {
      final data = CachedVenueData(
        key: 'venues_key',
        venuesJson: '[]',
        cachedAt: DateTime.now(),
        latitude: 34.0,
        longitude: -84.0,
        radius: 1000,
        types: [],
      );

      expect(data.types, isEmpty);
    });

    test('creates cached venue data with various radii', () {
      final testCases = [
        {'radius': 500.0, 'key': 'nearby'},
        {'radius': 1000.0, 'key': 'local'},
        {'radius': 5000.0, 'key': 'area'},
        {'radius': 10000.0, 'key': 'regional'},
        {'radius': 50000.0, 'key': 'city'},
      ];

      for (final testCase in testCases) {
        final data = CachedVenueData(
          key: testCase['key'] as String,
          venuesJson: '[]',
          cachedAt: DateTime.now(),
          latitude: 33.0,
          longitude: -84.0,
          radius: testCase['radius'] as double,
          types: ['bar'],
        );

        expect(data.radius, equals(testCase['radius']));
      }
    });

    test('creates cached venue data with complex JSON', () {
      const complexJson = '''
      {
        "venues": [
          {"id": "1", "name": "Sports Bar", "rating": 4.5},
          {"id": "2", "name": "Grill House", "rating": 4.2}
        ],
        "total": 2,
        "nextPageToken": "abc123"
      }
      ''';

      final data = CachedVenueData(
        key: 'complex_venues',
        venuesJson: complexJson,
        cachedAt: DateTime.now(),
        latitude: 33.95,
        longitude: -83.37,
        radius: 3000,
        types: ['bar', 'restaurant', 'food'],
      );

      expect(data.venuesJson, contains('Sports Bar'));
      expect(data.venuesJson, contains('nextPageToken'));
    });

    test('handles multiple venue types', () {
      final data = CachedVenueData(
        key: 'multi_type',
        venuesJson: '[]',
        cachedAt: DateTime.now(),
        latitude: 33.0,
        longitude: -84.0,
        radius: 5000,
        types: ['bar', 'restaurant', 'cafe', 'night_club', 'bowling_alley'],
      );

      expect(data.types, hasLength(5));
      expect(data.types, contains('night_club'));
      expect(data.types, contains('bowling_alley'));
    });

    test('handles negative coordinates', () {
      final data = CachedVenueData(
        key: 'south_west',
        venuesJson: '[]',
        cachedAt: DateTime.now(),
        latitude: -33.95,
        longitude: -83.37,
        radius: 2000,
        types: ['restaurant'],
      );

      expect(data.latitude, equals(-33.95));
      expect(data.longitude, equals(-83.37));
    });

    test('handles high precision coordinates', () {
      final data = CachedVenueData(
        key: 'precise',
        venuesJson: '[]',
        cachedAt: DateTime.now(),
        latitude: 33.9519347,
        longitude: -83.3576293,
        radius: 1500,
        types: ['bar'],
      );

      expect(data.latitude, closeTo(33.9519, 0.0001));
      expect(data.longitude, closeTo(-83.3576, 0.0001));
    });
  });

  group('CachedGeocodingData', () {
    test('creates cached geocoding data with all fields', () {
      final now = DateTime.now();
      final data = CachedGeocodingData(
        key: 'geocode_athens_ga',
        address: '123 Main St, Athens, GA 30601',
        latitude: 33.9519,
        longitude: -83.3576,
        cachedAt: now,
      );

      expect(data.key, equals('geocode_athens_ga'));
      expect(data.address, equals('123 Main St, Athens, GA 30601'));
      expect(data.latitude, equals(33.9519));
      expect(data.longitude, equals(-83.3576));
      expect(data.cachedAt, equals(now));
    });

    test('handles various address formats', () {
      final addresses = [
        '123 Main Street, Athens, GA 30601',
        'Sanford Stadium, Athens, GA',
        '30601',
        'Athens, Georgia, United States',
        '123 Lumpkin St, Athens, GA 30602-1502',
      ];

      for (final address in addresses) {
        final data = CachedGeocodingData(
          key: 'addr_${addresses.indexOf(address)}',
          address: address,
          latitude: 33.95,
          longitude: -83.37,
          cachedAt: DateTime.now(),
        );

        expect(data.address, equals(address));
      }
    });

    test('handles different US coordinates', () {
      final locations = [
        {'city': 'Athens, GA', 'lat': 33.9519, 'lng': -83.3576},
        {'city': 'Atlanta, GA', 'lat': 33.7490, 'lng': -84.3880},
        {'city': 'New York, NY', 'lat': 40.7128, 'lng': -74.0060},
        {'city': 'Los Angeles, CA', 'lat': 34.0522, 'lng': -118.2437},
        {'city': 'Miami, FL', 'lat': 25.7617, 'lng': -80.1918},
      ];

      for (final location in locations) {
        final data = CachedGeocodingData(
          key: 'geo_${location['city']}',
          address: location['city'] as String,
          latitude: location['lat'] as double,
          longitude: location['lng'] as double,
          cachedAt: DateTime.now(),
        );

        expect(data.latitude, equals(location['lat']));
        expect(data.longitude, equals(location['lng']));
      }
    });

    test('handles international coordinates', () {
      final data = CachedGeocodingData(
        key: 'geo_london',
        address: 'London, United Kingdom',
        latitude: 51.5074,
        longitude: -0.1278,
        cachedAt: DateTime.now(),
      );

      expect(data.latitude, equals(51.5074));
      expect(data.longitude, equals(-0.1278));
    });

    test('handles southern hemisphere coordinates', () {
      final data = CachedGeocodingData(
        key: 'geo_sydney',
        address: 'Sydney, Australia',
        latitude: -33.8688,
        longitude: 151.2093,
        cachedAt: DateTime.now(),
      );

      expect(data.latitude, equals(-33.8688));
      expect(data.longitude, equals(151.2093));
    });

    test('handles unicode in address', () {
      final data = CachedGeocodingData(
        key: 'geo_munich',
        address: 'München, Germany',
        latitude: 48.1351,
        longitude: 11.5820,
        cachedAt: DateTime.now(),
      );

      expect(data.address, equals('München, Germany'));
    });

    test('handles long addresses', () {
      const longAddress = '123 Very Long Street Name, Suite 456, Building A, '
          'Some Really Long City Name, State of Georgia, '
          'United States of America, 30601-1234';

      final data = CachedGeocodingData(
        key: 'geo_long',
        address: longAddress,
        latitude: 33.9519,
        longitude: -83.3576,
        cachedAt: DateTime.now(),
      );

      expect(data.address, equals(longAddress));
    });

    test('preserves timestamp precision', () {
      final preciseTime = DateTime(2024, 10, 15, 12, 30, 45, 123, 456);
      final data = CachedGeocodingData(
        key: 'geo_precise',
        address: 'Test Location',
        latitude: 33.0,
        longitude: -84.0,
        cachedAt: preciseTime,
      );

      expect(data.cachedAt.year, equals(2024));
      expect(data.cachedAt.month, equals(10));
      expect(data.cachedAt.day, equals(15));
      expect(data.cachedAt.hour, equals(12));
      expect(data.cachedAt.minute, equals(30));
      expect(data.cachedAt.second, equals(45));
    });
  });
}

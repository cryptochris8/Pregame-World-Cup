import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/recommendations/domain/entities/place.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Helper: create a Place with configurable fields
  // ---------------------------------------------------------------------------
  Place createTestPlace({
    String placeId = 'test_place_123',
    String name = 'The Sports Pub',
    String? vicinity = '123 Main St, Dallas, TX',
    double? rating = 4.5,
    int? userRatingsTotal = 250,
    List<String>? types = const ['bar', 'restaurant'],
    double? latitude = 32.7767,
    double? longitude = -96.7970,
    int? priceLevel = 2,
    OpeningHours? openingHours,
    Geometry? geometry,
    String? photoReference,
  }) {
    return Place(
      placeId: placeId,
      name: name,
      vicinity: vicinity,
      rating: rating,
      userRatingsTotal: userRatingsTotal,
      types: types,
      latitude: latitude,
      longitude: longitude,
      priceLevel: priceLevel,
      openingHours: openingHours,
      geometry: geometry,
      photoReference: photoReference,
    );
  }

  // ===========================================================================
  // Place entity tests
  // ===========================================================================

  group('Place', () {
    group('Constructor', () {
      test('creates Place with all required fields', () {
        final place = createTestPlace();

        expect(place.placeId, equals('test_place_123'));
        expect(place.name, equals('The Sports Pub'));
      });

      test('creates Place with all optional fields', () {
        final openingHours = OpeningHours(openNow: true);
        final geometry = Geometry(
          location: Location(lat: 32.7767, lng: -96.7970),
        );

        final place = createTestPlace(
          openingHours: openingHours,
          geometry: geometry,
          photoReference: 'photo_ref_abc',
        );

        expect(place.vicinity, equals('123 Main St, Dallas, TX'));
        expect(place.rating, equals(4.5));
        expect(place.userRatingsTotal, equals(250));
        expect(place.types, equals(['bar', 'restaurant']));
        expect(place.latitude, equals(32.7767));
        expect(place.longitude, equals(-96.7970));
        expect(place.priceLevel, equals(2));
        expect(place.openingHours, equals(openingHours));
        expect(place.geometry, equals(geometry));
        expect(place.photoReference, equals('photo_ref_abc'));
      });

      test('creates Place with null optional fields', () {
        final place = createTestPlace(
          vicinity: null,
          rating: null,
          userRatingsTotal: null,
          types: null,
          latitude: null,
          longitude: null,
          priceLevel: null,
          openingHours: null,
          geometry: null,
          photoReference: null,
        );

        expect(place.placeId, equals('test_place_123'));
        expect(place.name, equals('The Sports Pub'));
        expect(place.vicinity, isNull);
        expect(place.rating, isNull);
        expect(place.userRatingsTotal, isNull);
        expect(place.types, isNull);
        expect(place.latitude, isNull);
        expect(place.longitude, isNull);
        expect(place.priceLevel, isNull);
        expect(place.openingHours, isNull);
        expect(place.geometry, isNull);
        expect(place.photoReference, isNull);
      });
    });

    group('Equatable', () {
      test('two places with same props are equal', () {
        final place1 = createTestPlace();
        final place2 = createTestPlace();

        expect(place1, equals(place2));
      });

      test('two places with different placeId are not equal', () {
        final place1 = createTestPlace(placeId: 'id_1');
        final place2 = createTestPlace(placeId: 'id_2');

        expect(place1, isNot(equals(place2)));
      });

      test('two places with different name are not equal', () {
        final place1 = createTestPlace(name: 'Bar A');
        final place2 = createTestPlace(name: 'Bar B');

        expect(place1, isNot(equals(place2)));
      });

      test('two places with different rating are not equal', () {
        final place1 = createTestPlace(rating: 4.5);
        final place2 = createTestPlace(rating: 3.0);

        expect(place1, isNot(equals(place2)));
      });

      test('places with same data have same hashCode', () {
        final place1 = createTestPlace();
        final place2 = createTestPlace();

        expect(place1.hashCode, equals(place2.hashCode));
      });
    });

    group('fromJson', () {
      test('parses Google Places API format (snake_case)', () {
        final json = {
          'place_id': 'ChIJ_abc123',
          'name': 'Sports Bar Dallas',
          'vicinity': '123 Elm St, Dallas, TX',
          'rating': 4.3,
          'user_ratings_total': 412,
          'types': ['bar', 'restaurant', 'point_of_interest'],
          'price_level': 2,
          'geometry': {
            'location': {
              'lat': 32.7767,
              'lng': -96.7970,
            },
          },
          'opening_hours': {
            'open_now': true,
          },
          'photos': [
            {'photo_reference': 'CmRaAAAA123xyz'},
          ],
        };

        final place = Place.fromJson(json);

        expect(place.placeId, equals('ChIJ_abc123'));
        expect(place.name, equals('Sports Bar Dallas'));
        expect(place.vicinity, equals('123 Elm St, Dallas, TX'));
        expect(place.rating, equals(4.3));
        expect(place.userRatingsTotal, equals(412));
        expect(place.types, equals(['bar', 'restaurant', 'point_of_interest']));
        expect(place.priceLevel, equals(2));
        expect(place.latitude, equals(32.7767));
        expect(place.longitude, equals(-96.7970));
        expect(place.openingHours!.openNow, isTrue);
        expect(place.photoReference, equals('CmRaAAAA123xyz'));
      });

      test('parses Cloud Function format (camelCase)', () {
        final json = {
          'placeId': 'cf_abc123',
          'name': 'Cloud Venue',
          'vicinity': '456 Oak Ave',
          'rating': 4.0,
          'userRatingsTotal': 100,
          'types': ['restaurant'],
          'latitude': 40.7128,
          'longitude': -74.0060,
          'priceLevel': 3,
          'photoReference': 'direct_photo_ref',
        };

        final place = Place.fromJson(json);

        expect(place.placeId, equals('cf_abc123'));
        expect(place.name, equals('Cloud Venue'));
        expect(place.latitude, equals(40.7128));
        expect(place.longitude, equals(-74.0060));
        expect(place.userRatingsTotal, equals(100));
        expect(place.priceLevel, equals(3));
        expect(place.photoReference, equals('direct_photo_ref'));
      });

      test('handles missing fields with defaults', () {
        final json = <String, dynamic>{};

        final place = Place.fromJson(json);

        expect(place.placeId, equals(''));
        expect(place.name, equals('Unknown Place'));
        expect(place.vicinity, isNull);
        expect(place.rating, isNull);
        expect(place.userRatingsTotal, isNull);
        expect(place.types, isNull);
        expect(place.latitude, isNull);
        expect(place.longitude, isNull);
        expect(place.priceLevel, isNull);
        expect(place.openingHours, isNull);
        expect(place.geometry, isNull);
        expect(place.photoReference, isNull);
      });

      test('prefers flat latitude/longitude over nested geometry', () {
        final json = {
          'place_id': 'test',
          'name': 'Test',
          'latitude': 10.0,
          'longitude': 20.0,
          'geometry': {
            'location': {
              'lat': 30.0,
              'lng': 40.0,
            },
          },
        };

        final place = Place.fromJson(json);

        // Flat latitude/longitude is checked first in the factory
        expect(place.latitude, equals(10.0));
        expect(place.longitude, equals(20.0));
      });

      test('falls back to geometry location when flat coords are missing', () {
        final json = {
          'place_id': 'test',
          'name': 'Test',
          'geometry': {
            'location': {
              'lat': 30.0,
              'lng': 40.0,
            },
          },
        };

        final place = Place.fromJson(json);

        expect(place.latitude, equals(30.0));
        expect(place.longitude, equals(40.0));
      });

      test('extracts photo_reference from photos array', () {
        final json = {
          'place_id': 'test',
          'name': 'Test',
          'photos': [
            {'photo_reference': 'array_photo_ref_123'},
            {'photo_reference': 'second_ref'},
          ],
        };

        final place = Place.fromJson(json);

        // Should use the first photo reference from the array
        expect(place.photoReference, equals('array_photo_ref_123'));
      });

      test('extracts direct photoReference field over photos array', () {
        final json = {
          'place_id': 'test',
          'name': 'Test',
          'photoReference': 'direct_ref',
          'photos': [
            {'photo_reference': 'array_ref'},
          ],
        };

        final place = Place.fromJson(json);

        expect(place.photoReference, equals('direct_ref'));
      });

      test('extracts snake_case photo_reference field', () {
        final json = {
          'place_id': 'test',
          'name': 'Test',
          'photo_reference': 'snake_case_ref',
        };

        final place = Place.fromJson(json);

        expect(place.photoReference, equals('snake_case_ref'));
      });

      test('handles empty photos array gracefully', () {
        final json = {
          'place_id': 'test',
          'name': 'Test',
          'photos': <Map<String, dynamic>>[],
        };

        final place = Place.fromJson(json);

        expect(place.photoReference, isNull);
      });

      test('handles integer rating cast to double', () {
        final json = {
          'place_id': 'test',
          'name': 'Test',
          'rating': 4,
        };

        final place = Place.fromJson(json);

        expect(place.rating, equals(4.0));
        expect(place.rating, isA<double>());
      });
    });

    group('toJson', () {
      test('serializes all fields correctly', () {
        final place = createTestPlace(
          openingHours: OpeningHours(openNow: true),
          geometry: Geometry(
            location: Location(lat: 32.7767, lng: -96.7970),
          ),
          photoReference: 'photo_ref_123',
        );

        final json = place.toJson();

        expect(json['place_id'], equals('test_place_123'));
        expect(json['name'], equals('The Sports Pub'));
        expect(json['vicinity'], equals('123 Main St, Dallas, TX'));
        expect(json['rating'], equals(4.5));
        expect(json['user_ratings_total'], equals(250));
        expect(json['types'], equals(['bar', 'restaurant']));
        expect(json['price_level'], equals(2));
        expect(json['opening_hours'], equals({'open_now': true}));
        expect(json['geometry'], isNotNull);
        expect(json['photoReference'], equals('photo_ref_123'));
      });

      test('serializes null optional fields as null', () {
        final place = createTestPlace(
          vicinity: null,
          rating: null,
          userRatingsTotal: null,
          types: null,
          priceLevel: null,
          openingHours: null,
          geometry: null,
          photoReference: null,
        );

        final json = place.toJson();

        expect(json['vicinity'], isNull);
        expect(json['rating'], isNull);
        expect(json['user_ratings_total'], isNull);
        expect(json['types'], isNull);
        expect(json['price_level'], isNull);
        expect(json['opening_hours'], isNull);
        expect(json['geometry'], isNull);
        expect(json['photoReference'], isNull);
      });
    });

    group('Roundtrip serialization', () {
      test('toJson then fromJson preserves all data', () {
        final original = createTestPlace(
          openingHours: OpeningHours(openNow: false),
          geometry: Geometry(
            location: Location(lat: 40.7128, lng: -74.0060),
          ),
          photoReference: 'roundtrip_ref',
        );

        final json = original.toJson();
        final restored = Place.fromJson(json);

        expect(restored.placeId, equals(original.placeId));
        expect(restored.name, equals(original.name));
        expect(restored.vicinity, equals(original.vicinity));
        expect(restored.rating, equals(original.rating));
        expect(restored.userRatingsTotal, equals(original.userRatingsTotal));
        expect(restored.types, equals(original.types));
        expect(restored.priceLevel, equals(original.priceLevel));
        expect(restored.openingHours?.openNow, equals(original.openingHours?.openNow));
        expect(restored.photoReference, equals(original.photoReference));
      });

      test('roundtrip with minimal data', () {
        const original = Place(
          placeId: 'minimal',
          name: 'Minimal Place',
        );

        final json = original.toJson();
        final restored = Place.fromJson(json);

        expect(restored.placeId, equals('minimal'));
        expect(restored.name, equals('Minimal Place'));
      });
    });
  });

  // ===========================================================================
  // OpeningHours tests
  // ===========================================================================

  group('OpeningHours', () {
    test('creates with openNow true', () {
      final hours = OpeningHours(openNow: true);
      expect(hours.openNow, isTrue);
    });

    test('creates with openNow false', () {
      final hours = OpeningHours(openNow: false);
      expect(hours.openNow, isFalse);
    });

    test('creates with openNow null', () {
      final hours = OpeningHours();
      expect(hours.openNow, isNull);
    });

    test('fromJson parses open_now correctly', () {
      final hours = OpeningHours.fromJson({'open_now': true});
      expect(hours.openNow, isTrue);
    });

    test('fromJson handles missing open_now', () {
      final hours = OpeningHours.fromJson({});
      expect(hours.openNow, isNull);
    });

    test('toJson serializes correctly', () {
      final hours = OpeningHours(openNow: true);
      final json = hours.toJson();
      expect(json, equals({'open_now': true}));
    });

    test('toJson with null openNow', () {
      final hours = OpeningHours();
      final json = hours.toJson();
      expect(json, equals({'open_now': null}));
    });

    test('roundtrip serialization', () {
      final original = OpeningHours(openNow: false);
      final json = original.toJson();
      final restored = OpeningHours.fromJson(json);
      expect(restored.openNow, equals(original.openNow));
    });
  });

  // ===========================================================================
  // Geometry tests
  // ===========================================================================

  group('Geometry', () {
    test('creates with location', () {
      final location = Location(lat: 32.7767, lng: -96.7970);
      final geometry = Geometry(location: location);
      expect(geometry.location, equals(location));
    });

    test('creates with null location', () {
      final geometry = Geometry();
      expect(geometry.location, isNull);
    });

    test('fromJson parses location correctly', () {
      final geometry = Geometry.fromJson({
        'location': {'lat': 32.7767, 'lng': -96.7970},
      });
      expect(geometry.location!.lat, equals(32.7767));
      expect(geometry.location!.lng, equals(-96.7970));
    });

    test('fromJson handles missing location', () {
      final geometry = Geometry.fromJson({});
      expect(geometry.location, isNull);
    });

    test('toJson serializes correctly', () {
      final geometry = Geometry(
        location: Location(lat: 32.7767, lng: -96.7970),
      );
      final json = geometry.toJson();
      expect(json['location'], equals({'lat': 32.7767, 'lng': -96.7970}));
    });

    test('toJson with null location', () {
      final geometry = Geometry();
      final json = geometry.toJson();
      expect(json['location'], isNull);
    });

    test('roundtrip serialization', () {
      final original = Geometry(
        location: Location(lat: 40.7128, lng: -74.0060),
      );
      final json = original.toJson();
      final restored = Geometry.fromJson(json);
      expect(restored.location!.lat, equals(original.location!.lat));
      expect(restored.location!.lng, equals(original.location!.lng));
    });
  });

  // ===========================================================================
  // Location tests
  // ===========================================================================

  group('Location', () {
    test('creates with lat and lng', () {
      final location = Location(lat: 32.7767, lng: -96.7970);
      expect(location.lat, equals(32.7767));
      expect(location.lng, equals(-96.7970));
    });

    test('creates with null coordinates', () {
      final location = Location();
      expect(location.lat, isNull);
      expect(location.lng, isNull);
    });

    test('fromJson parses correctly', () {
      final location = Location.fromJson({
        'lat': 32.7767,
        'lng': -96.7970,
      });
      expect(location.lat, equals(32.7767));
      expect(location.lng, equals(-96.7970));
    });

    test('fromJson handles integer values', () {
      final location = Location.fromJson({
        'lat': 33,
        'lng': -97,
      });
      expect(location.lat, equals(33.0));
      expect(location.lng, equals(-97.0));
      expect(location.lat, isA<double>());
      expect(location.lng, isA<double>());
    });

    test('fromJson handles missing values', () {
      final location = Location.fromJson({});
      expect(location.lat, isNull);
      expect(location.lng, isNull);
    });

    test('toJson serializes correctly', () {
      final location = Location(lat: 32.7767, lng: -96.7970);
      final json = location.toJson();
      expect(json, equals({'lat': 32.7767, 'lng': -96.7970}));
    });

    test('handles negative coordinates', () {
      final location = Location(lat: -33.8688, lng: 151.2093);
      expect(location.lat, equals(-33.8688));
      expect(location.lng, equals(151.2093));
    });

    test('handles zero coordinates', () {
      final location = Location(lat: 0.0, lng: 0.0);
      expect(location.lat, equals(0.0));
      expect(location.lng, equals(0.0));
    });

    test('roundtrip serialization', () {
      final original = Location(lat: 51.5074, lng: -0.1278);
      final json = original.toJson();
      final restored = Location.fromJson(json);
      expect(restored.lat, equals(original.lat));
      expect(restored.lng, equals(original.lng));
    });
  });
}

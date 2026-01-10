import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/recommendations/domain/entities/place.dart';

/// Tests for Place entity and nested classes
void main() {
  group('Place', () {
    group('fromJson', () {
      test('parses Google Places API format (snake_case)', () {
        final json = {
          'place_id': 'ChIJN1t_tDeuEmsRUsoyG83frY4',
          'name': 'Sports Bar',
          'vicinity': '123 Main St, City',
          'rating': 4.5,
          'user_ratings_total': 250,
          'types': ['bar', 'restaurant', 'point_of_interest'],
          'price_level': 2,
          'geometry': {
            'location': {
              'lat': 37.7749,
              'lng': -122.4194,
            }
          },
          'opening_hours': {
            'open_now': true,
          },
        };

        final place = Place.fromJson(json);

        expect(place.placeId, equals('ChIJN1t_tDeuEmsRUsoyG83frY4'));
        expect(place.name, equals('Sports Bar'));
        expect(place.vicinity, equals('123 Main St, City'));
        expect(place.rating, equals(4.5));
        expect(place.userRatingsTotal, equals(250));
        expect(place.types, contains('bar'));
        expect(place.types, contains('restaurant'));
        expect(place.priceLevel, equals(2));
        expect(place.latitude, equals(37.7749));
        expect(place.longitude, equals(-122.4194));
        expect(place.openingHours?.openNow, isTrue);
      });

      test('parses Cloud Function format (camelCase)', () {
        final json = {
          'placeId': 'place123',
          'name': 'Craft Beer Bar',
          'vicinity': '456 Oak Ave',
          'rating': 4.2,
          'userRatingsTotal': 150,
          'types': ['bar'],
          'priceLevel': 3,
          'latitude': 40.7128,
          'longitude': -74.0060,
          'photoReference': 'photo_ref_123',
        };

        final place = Place.fromJson(json);

        expect(place.placeId, equals('place123'));
        expect(place.name, equals('Craft Beer Bar'));
        expect(place.userRatingsTotal, equals(150));
        expect(place.priceLevel, equals(3));
        expect(place.latitude, equals(40.7128));
        expect(place.longitude, equals(-74.0060));
        expect(place.photoReference, equals('photo_ref_123'));
      });

      test('handles missing optional fields', () {
        final json = {
          'place_id': 'minimal_place',
          'name': 'Simple Place',
        };

        final place = Place.fromJson(json);

        expect(place.placeId, equals('minimal_place'));
        expect(place.name, equals('Simple Place'));
        expect(place.vicinity, isNull);
        expect(place.rating, isNull);
        expect(place.userRatingsTotal, isNull);
        expect(place.types, isNull);
        expect(place.priceLevel, isNull);
        expect(place.openingHours, isNull);
        expect(place.geometry, isNull);
      });

      test('handles missing place_id with placeId fallback', () {
        final json = {
          'placeId': 'fallback_id',
          'name': 'Fallback Place',
        };

        final place = Place.fromJson(json);
        expect(place.placeId, equals('fallback_id'));
      });

      test('handles missing name with default', () {
        final json = {
          'place_id': 'no_name_place',
        };

        final place = Place.fromJson(json);
        expect(place.name, equals('Unknown Place'));
      });

      test('parses rating as double from int', () {
        final json = {
          'place_id': 'int_rating',
          'name': 'Int Rating Place',
          'rating': 4,
        };

        final place = Place.fromJson(json);
        expect(place.rating, equals(4.0));
        expect(place.rating, isA<double>());
      });

      test('parses photoReference with snake_case fallback', () {
        final json = {
          'place_id': 'photo_place',
          'name': 'Photo Place',
          'photo_reference': 'snake_case_ref',
        };

        final place = Place.fromJson(json);
        expect(place.photoReference, equals('snake_case_ref'));
      });

      test('prefers flat latitude/longitude over nested geometry', () {
        final json = {
          'place_id': 'flat_coords',
          'name': 'Flat Coords Place',
          'latitude': 51.5074,
          'longitude': -0.1278,
          'geometry': {
            'location': {
              'lat': 0.0,
              'lng': 0.0,
            }
          },
        };

        final place = Place.fromJson(json);
        expect(place.latitude, equals(51.5074));
        expect(place.longitude, equals(-0.1278));
      });
    });

    group('toJson', () {
      test('serializes all fields correctly', () {
        const place = Place(
          placeId: 'test_place_123',
          name: 'Test Bar',
          vicinity: '789 Test St',
          rating: 4.7,
          userRatingsTotal: 500,
          types: ['bar', 'restaurant'],
          latitude: 34.0522,
          longitude: -118.2437,
          priceLevel: 2,
          photoReference: 'photo_123',
        );

        final json = place.toJson();

        expect(json['place_id'], equals('test_place_123'));
        expect(json['name'], equals('Test Bar'));
        expect(json['vicinity'], equals('789 Test St'));
        expect(json['rating'], equals(4.7));
        expect(json['user_ratings_total'], equals(500));
        expect(json['types'], contains('bar'));
        expect(json['price_level'], equals(2));
        expect(json['photoReference'], equals('photo_123'));
      });

      test('handles null optional fields', () {
        const place = Place(
          placeId: 'minimal_place',
          name: 'Minimal Place',
        );

        final json = place.toJson();

        expect(json['place_id'], equals('minimal_place'));
        expect(json['name'], equals('Minimal Place'));
        expect(json['vicinity'], isNull);
        expect(json['rating'], isNull);
      });
    });

    group('Equatable', () {
      test('places with same values are equal', () {
        const place1 = Place(
          placeId: 'same_id',
          name: 'Same Place',
          rating: 4.5,
        );
        const place2 = Place(
          placeId: 'same_id',
          name: 'Same Place',
          rating: 4.5,
        );

        expect(place1, equals(place2));
      });

      test('places with different IDs are not equal', () {
        const place1 = Place(
          placeId: 'id_1',
          name: 'Place',
        );
        const place2 = Place(
          placeId: 'id_2',
          name: 'Place',
        );

        expect(place1, isNot(equals(place2)));
      });
    });
  });

  group('OpeningHours', () {
    test('fromJson parses open_now correctly', () {
      final json = {'open_now': true};
      final hours = OpeningHours.fromJson(json);
      expect(hours.openNow, isTrue);
    });

    test('fromJson handles null open_now', () {
      final json = <String, dynamic>{};
      final hours = OpeningHours.fromJson(json);
      expect(hours.openNow, isNull);
    });

    test('fromJson handles false open_now', () {
      final json = {'open_now': false};
      final hours = OpeningHours.fromJson(json);
      expect(hours.openNow, isFalse);
    });

    test('toJson serializes correctly', () {
      final hours = OpeningHours(openNow: true);
      final json = hours.toJson();
      expect(json['open_now'], isTrue);
    });

    test('toJson handles null openNow', () {
      final hours = OpeningHours(openNow: null);
      final json = hours.toJson();
      expect(json['open_now'], isNull);
    });
  });

  group('Geometry', () {
    test('fromJson parses location correctly', () {
      final json = {
        'location': {
          'lat': 37.7749,
          'lng': -122.4194,
        }
      };

      final geometry = Geometry.fromJson(json);

      expect(geometry.location, isNotNull);
      expect(geometry.location!.lat, equals(37.7749));
      expect(geometry.location!.lng, equals(-122.4194));
    });

    test('fromJson handles missing location', () {
      final json = <String, dynamic>{};
      final geometry = Geometry.fromJson(json);
      expect(geometry.location, isNull);
    });

    test('toJson serializes correctly', () {
      final geometry = Geometry(
        location: Location(lat: 40.7128, lng: -74.0060),
      );

      final json = geometry.toJson();

      expect(json['location'], isNotNull);
      expect(json['location']['lat'], equals(40.7128));
      expect(json['location']['lng'], equals(-74.0060));
    });

    test('toJson handles null location', () {
      final geometry = Geometry(location: null);
      final json = geometry.toJson();
      expect(json['location'], isNull);
    });
  });

  group('Location', () {
    test('fromJson parses coordinates correctly', () {
      final json = {
        'lat': 51.5074,
        'lng': -0.1278,
      };

      final location = Location.fromJson(json);

      expect(location.lat, equals(51.5074));
      expect(location.lng, equals(-0.1278));
    });

    test('fromJson handles integer coordinates', () {
      final json = {
        'lat': 52,
        'lng': -1,
      };

      final location = Location.fromJson(json);

      expect(location.lat, equals(52.0));
      expect(location.lng, equals(-1.0));
    });

    test('fromJson handles null coordinates', () {
      final json = <String, dynamic>{};
      final location = Location.fromJson(json);
      expect(location.lat, isNull);
      expect(location.lng, isNull);
    });

    test('toJson serializes correctly', () {
      final location = Location(lat: 48.8566, lng: 2.3522);
      final json = location.toJson();

      expect(json['lat'], equals(48.8566));
      expect(json['lng'], equals(2.3522));
    });

    test('toJson handles null values', () {
      final location = Location(lat: null, lng: null);
      final json = location.toJson();

      expect(json['lat'], isNull);
      expect(json['lng'], isNull);
    });
  });

  group('Place - Roundtrip', () {
    test('fromJson -> toJson preserves data', () {
      final originalJson = {
        'place_id': 'roundtrip_test',
        'name': 'Roundtrip Bar',
        'vicinity': 'Test Address',
        'rating': 4.3,
        'user_ratings_total': 100,
        'types': ['bar'],
        'price_level': 2,
        'opening_hours': {'open_now': true},
        'geometry': {
          'location': {'lat': 1.0, 'lng': 2.0}
        },
      };

      final place = Place.fromJson(originalJson);
      final outputJson = place.toJson();

      expect(outputJson['place_id'], equals(originalJson['place_id']));
      expect(outputJson['name'], equals(originalJson['name']));
      expect(outputJson['vicinity'], equals(originalJson['vicinity']));
      expect(outputJson['rating'], equals(originalJson['rating']));
      expect(outputJson['user_ratings_total'],
          equals(originalJson['user_ratings_total']));
      expect(outputJson['price_level'], equals(originalJson['price_level']));
    });
  });
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/recommendations/domain/entities/enhanced_place.dart';

void main() {
  // ==================== EnhancedPlace ====================
  group('EnhancedPlace', () {
    final testLastUpdated = DateTime(2026, 6, 15, 12, 0);

    group('Constructor', () {
      test('creates instance with required fields and defaults', () {
        final place = EnhancedPlace(
          placeId: 'place_1',
          name: 'Sports Bar',
        );

        expect(place.placeId, equals('place_1'));
        expect(place.name, equals('Sports Bar'));
        expect(place.vicinity, isNull);
        expect(place.formattedAddress, isNull);
        expect(place.rating, isNull);
        expect(place.userRatingsTotal, isNull);
        expect(place.priceLevel, isNull);
        expect(place.types, isEmpty);
        expect(place.geometry, isNull);
        expect(place.phoneNumber, isNull);
        expect(place.website, isNull);
        expect(place.photos, isEmpty);
        expect(place.openingHours, isNull);
        expect(place.userReviews, isEmpty);
        expect(place.distanceFromVenue, isNull);
        expect(place.isFavorite, isFalse);
        expect(place.checkIns, equals(0));
        expect(place.amenities, isEmpty);
        expect(place.lastUpdated, isNotNull);
      });

      test('creates instance with all fields specified', () {
        final place = EnhancedPlace(
          placeId: 'place_2',
          name: 'Fancy Restaurant',
          vicinity: '123 Main St',
          formattedAddress: '123 Main St, New York, NY 10001',
          rating: 4.5,
          userRatingsTotal: 250,
          priceLevel: '\$\$',
          types: ['restaurant', 'bar'],
          geometry: PlaceGeometry(
            location: PlaceLocation(lat: 40.7128, lng: -74.0060),
          ),
          phoneNumber: '+1-212-555-0100',
          website: 'https://example.com',
          photos: ['photo1.jpg', 'photo2.jpg'],
          openingHours: OpeningHours(openNow: true, weekdayText: ['Mon: 9AM-10PM']),
          userReviews: [],
          distanceFromVenue: 0.5,
          isFavorite: true,
          checkIns: 42,
          amenities: ['wifi', 'parking'],
          lastUpdated: testLastUpdated,
        );

        expect(place.placeId, equals('place_2'));
        expect(place.name, equals('Fancy Restaurant'));
        expect(place.vicinity, equals('123 Main St'));
        expect(place.formattedAddress, equals('123 Main St, New York, NY 10001'));
        expect(place.rating, equals(4.5));
        expect(place.userRatingsTotal, equals(250));
        expect(place.priceLevel, equals('\$\$'));
        expect(place.types, contains('restaurant'));
        expect(place.types, contains('bar'));
        expect(place.geometry, isNotNull);
        expect(place.geometry!.location!.lat, equals(40.7128));
        expect(place.phoneNumber, equals('+1-212-555-0100'));
        expect(place.website, equals('https://example.com'));
        expect(place.photos, hasLength(2));
        expect(place.openingHours!.openNow, isTrue);
        expect(place.distanceFromVenue, equals(0.5));
        expect(place.isFavorite, isTrue);
        expect(place.checkIns, equals(42));
        expect(place.amenities, contains('wifi'));
        expect(place.lastUpdated, equals(testLastUpdated));
      });
    });

    group('fromGooglePlaces', () {
      test('parses complete Google Places API response', () {
        final data = {
          'place_id': 'ChIJ_test123',
          'name': 'Google Bar',
          'vicinity': '456 Oak Ave',
          'formatted_address': '456 Oak Ave, LA, CA 90001',
          'rating': 4.2,
          'user_ratings_total': 150,
          'price_level': 2,
          'types': ['bar', 'food', 'point_of_interest'],
          'geometry': {
            'location': {'lat': 34.0522, 'lng': -118.2437},
            'viewport': {
              'northeast': {'lat': 34.06, 'lng': -118.23},
              'southwest': {'lat': 34.04, 'lng': -118.25},
            },
          },
          'formatted_phone_number': '+1-310-555-0123',
          'website': 'https://googlebar.com',
          'opening_hours': {
            'open_now': true,
            'weekday_text': ['Monday: 11:00 AM - 10:00 PM'],
          },
        };

        final place = EnhancedPlace.fromGooglePlaces(data);

        expect(place.placeId, equals('ChIJ_test123'));
        expect(place.name, equals('Google Bar'));
        expect(place.vicinity, equals('456 Oak Ave'));
        expect(place.formattedAddress, equals('456 Oak Ave, LA, CA 90001'));
        expect(place.rating, equals(4.2));
        expect(place.userRatingsTotal, equals(150));
        expect(place.priceLevel, equals('\$\$'));
        expect(place.types, contains('bar'));
        expect(place.types, contains('food'));
        expect(place.geometry, isNotNull);
        expect(place.geometry!.location!.lat, equals(34.0522));
        expect(place.geometry!.location!.lng, equals(-118.2437));
        expect(place.phoneNumber, equals('+1-310-555-0123'));
        expect(place.website, equals('https://googlebar.com'));
        expect(place.openingHours!.openNow, isTrue);
      });

      test('handles missing optional fields', () {
        final data = <String, dynamic>{
          'place_id': 'minimal_place',
          'name': 'Minimal Bar',
        };

        final place = EnhancedPlace.fromGooglePlaces(data);

        expect(place.placeId, equals('minimal_place'));
        expect(place.name, equals('Minimal Bar'));
        expect(place.vicinity, isNull);
        expect(place.formattedAddress, isNull);
        expect(place.rating, isNull);
        expect(place.userRatingsTotal, isNull);
        expect(place.priceLevel, isNull);
        expect(place.types, isEmpty);
        expect(place.geometry, isNull);
        expect(place.phoneNumber, isNull);
        expect(place.website, isNull);
        expect(place.openingHours, isNull);
      });

      test('handles missing place_id and name', () {
        final data = <String, dynamic>{};

        final place = EnhancedPlace.fromGooglePlaces(data);

        expect(place.placeId, equals(''));
        expect(place.name, equals(''));
      });

      test('converts price levels correctly', () {
        for (final entry in {1: '\$', 2: '\$\$', 3: '\$\$\$', 4: '\$\$\$\$'}.entries) {
          final data = {
            'place_id': 'test',
            'name': 'Test',
            'price_level': entry.key,
          };

          final place = EnhancedPlace.fromGooglePlaces(data);
          expect(place.priceLevel, equals(entry.value),
              reason: 'Price level ${entry.key} should map to ${entry.value}');
        }
      });

      test('returns null priceLevel for unknown price level', () {
        final data = {
          'place_id': 'test',
          'name': 'Test',
          'price_level': 0,
        };

        final place = EnhancedPlace.fromGooglePlaces(data);
        expect(place.priceLevel, isNull);
      });

      test('returns null priceLevel when price_level is null', () {
        final data = {
          'place_id': 'test',
          'name': 'Test',
          'price_level': null,
        };

        final place = EnhancedPlace.fromGooglePlaces(data);
        expect(place.priceLevel, isNull);
      });
    });

    group('fromFirestore', () {
      test('parses complete Firestore document', () {
        final data = {
          'name': 'Firestore Bar',
          'vicinity': '789 Elm St',
          'formattedAddress': '789 Elm St, Chicago, IL 60601',
          'rating': 4.8,
          'userRatingsTotal': 500,
          'priceLevel': '\$\$\$',
          'types': ['bar', 'nightclub'],
          'geometry': {
            'location': {'lat': 41.8781, 'lng': -87.6298},
          },
          'phoneNumber': '+1-312-555-0456',
          'website': 'https://firestorebar.com',
          'photos': ['https://example.com/photo1.jpg'],
          'openingHours': {
            'open_now': false,
            'weekday_text': ['Tuesday: 5:00 PM - 2:00 AM'],
          },
          'userReviews': [
            {
              'reviewId': 'review_1',
              'userId': 'user_1',
              'userDisplayName': 'Test User',
              'rating': 5.0,
              'content': 'Great place!',
              'createdAt': Timestamp.fromDate(DateTime(2026, 5, 1)),
            },
          ],
          'distanceFromVenue': 1.2,
          'isFavorite': true,
          'checkIns': 100,
          'amenities': ['wifi', 'outdoor_seating', 'parking'],
          'lastUpdated': Timestamp.fromDate(testLastUpdated),
        };

        final place = EnhancedPlace.fromFirestore(data, 'doc_123');

        expect(place.placeId, equals('doc_123'));
        expect(place.name, equals('Firestore Bar'));
        expect(place.vicinity, equals('789 Elm St'));
        expect(place.formattedAddress, equals('789 Elm St, Chicago, IL 60601'));
        expect(place.rating, equals(4.8));
        expect(place.userRatingsTotal, equals(500));
        expect(place.priceLevel, equals('\$\$\$'));
        expect(place.types, containsAll(['bar', 'nightclub']));
        expect(place.geometry!.location!.lat, equals(41.8781));
        expect(place.phoneNumber, equals('+1-312-555-0456'));
        expect(place.website, equals('https://firestorebar.com'));
        expect(place.photos, hasLength(1));
        expect(place.openingHours!.openNow, isFalse);
        expect(place.userReviews, hasLength(1));
        expect(place.userReviews.first.reviewId, equals('review_1'));
        expect(place.distanceFromVenue, equals(1.2));
        expect(place.isFavorite, isTrue);
        expect(place.checkIns, equals(100));
        expect(place.amenities, hasLength(3));
        expect(place.lastUpdated, equals(testLastUpdated));
      });

      test('handles missing optional fields', () {
        final data = <String, dynamic>{
          'name': 'Minimal',
        };

        final place = EnhancedPlace.fromFirestore(data, 'doc_minimal');

        expect(place.placeId, equals('doc_minimal'));
        expect(place.name, equals('Minimal'));
        expect(place.vicinity, isNull);
        expect(place.formattedAddress, isNull);
        expect(place.rating, isNull);
        expect(place.userRatingsTotal, isNull);
        expect(place.priceLevel, isNull);
        expect(place.types, isEmpty);
        expect(place.geometry, isNull);
        expect(place.phoneNumber, isNull);
        expect(place.website, isNull);
        expect(place.photos, isEmpty);
        expect(place.openingHours, isNull);
        expect(place.userReviews, isEmpty);
        expect(place.distanceFromVenue, isNull);
        expect(place.isFavorite, isFalse);
        expect(place.checkIns, equals(0));
        expect(place.amenities, isEmpty);
      });

      test('handles missing name with empty string', () {
        final data = <String, dynamic>{};

        final place = EnhancedPlace.fromFirestore(data, 'doc_no_name');
        expect(place.name, equals(''));
      });

      test('handles null lastUpdated with current time', () {
        final data = <String, dynamic>{
          'name': 'Test',
          'lastUpdated': null,
        };

        final beforeTest = DateTime.now();
        final place = EnhancedPlace.fromFirestore(data, 'doc_test');
        final afterTest = DateTime.now();

        expect(place.lastUpdated.isAfter(beforeTest.subtract(const Duration(seconds: 1))), isTrue);
        expect(place.lastUpdated.isBefore(afterTest.add(const Duration(seconds: 1))), isTrue);
      });
    });

    group('toFirestore', () {
      test('serializes all fields', () {
        final place = EnhancedPlace(
          placeId: 'place_1',
          name: 'Test Bar',
          vicinity: '123 Main St',
          formattedAddress: '123 Main St, City, ST 12345',
          rating: 4.5,
          userRatingsTotal: 250,
          priceLevel: '\$\$',
          types: ['bar', 'restaurant'],
          geometry: PlaceGeometry(
            location: PlaceLocation(lat: 40.7128, lng: -74.0060),
          ),
          phoneNumber: '+1-555-0100',
          website: 'https://example.com',
          photos: ['photo1.jpg'],
          openingHours: OpeningHours(openNow: true),
          distanceFromVenue: 0.5,
          isFavorite: true,
          checkIns: 42,
          amenities: ['wifi'],
          lastUpdated: testLastUpdated,
        );

        final data = place.toFirestore();

        expect(data['name'], equals('Test Bar'));
        expect(data['vicinity'], equals('123 Main St'));
        expect(data['formattedAddress'], equals('123 Main St, City, ST 12345'));
        expect(data['rating'], equals(4.5));
        expect(data['userRatingsTotal'], equals(250));
        expect(data['priceLevel'], equals('\$\$'));
        expect(data['types'], containsAll(['bar', 'restaurant']));
        expect(data['geometry'], isNotNull);
        expect(data['phoneNumber'], equals('+1-555-0100'));
        expect(data['website'], equals('https://example.com'));
        expect(data['photos'], hasLength(1));
        expect(data['openingHours'], isNotNull);
        expect(data['distanceFromVenue'], equals(0.5));
        expect(data['isFavorite'], isTrue);
        expect(data['checkIns'], equals(42));
        expect(data['amenities'], contains('wifi'));
        expect(data['lastUpdated'], equals(Timestamp.fromDate(testLastUpdated)));
      });

      test('does not include placeId in output', () {
        final place = EnhancedPlace(
          placeId: 'place_1',
          name: 'Test',
        );

        final data = place.toFirestore();
        expect(data.containsKey('placeId'), isFalse);
        expect(data.containsKey('place_id'), isFalse);
      });

      test('serializes empty lists correctly', () {
        final place = EnhancedPlace(
          placeId: 'place_1',
          name: 'Test',
        );

        final data = place.toFirestore();
        expect(data['types'], isEmpty);
        expect(data['photos'], isEmpty);
        expect(data['userReviews'], isEmpty);
        expect(data['amenities'], isEmpty);
      });
    });

    group('copyWith', () {
      test('creates copy with updated name', () {
        final original = EnhancedPlace(
          placeId: 'place_1',
          name: 'Original',
          rating: 4.0,
        );

        final copy = original.copyWith(name: 'Updated');

        expect(copy.placeId, equals('place_1'));
        expect(copy.name, equals('Updated'));
        expect(copy.rating, equals(4.0));
      });

      test('creates copy with updated isFavorite', () {
        final original = EnhancedPlace(
          placeId: 'place_1',
          name: 'Test',
          isFavorite: false,
        );

        final copy = original.copyWith(isFavorite: true);

        expect(copy.isFavorite, isTrue);
        expect(copy.name, equals('Test'));
      });

      test('creates copy with updated rating and checkIns', () {
        final original = EnhancedPlace(
          placeId: 'place_1',
          name: 'Test',
          rating: 3.0,
          checkIns: 10,
        );

        final copy = original.copyWith(rating: 4.5, checkIns: 20);

        expect(copy.rating, equals(4.5));
        expect(copy.checkIns, equals(20));
      });

      test('preserves all fields when no arguments provided', () {
        final original = EnhancedPlace(
          placeId: 'place_1',
          name: 'Test',
          vicinity: 'Address',
          rating: 4.5,
          types: ['bar'],
          isFavorite: true,
          checkIns: 42,
          amenities: ['wifi'],
          lastUpdated: testLastUpdated,
        );

        final copy = original.copyWith();

        expect(copy.placeId, equals(original.placeId));
        expect(copy.name, equals(original.name));
        expect(copy.vicinity, equals(original.vicinity));
        expect(copy.rating, equals(original.rating));
        expect(copy.types, equals(original.types));
        expect(copy.isFavorite, equals(original.isFavorite));
        expect(copy.checkIns, equals(original.checkIns));
        expect(copy.amenities, equals(original.amenities));
        expect(copy.lastUpdated, equals(original.lastUpdated));
      });

      test('can update multiple fields at once', () {
        final original = EnhancedPlace(
          placeId: 'place_1',
          name: 'Original',
          rating: 3.0,
          priceLevel: '\$',
          distanceFromVenue: 2.0,
        );

        final copy = original.copyWith(
          name: 'Updated',
          rating: 4.5,
          priceLevel: '\$\$\$',
          distanceFromVenue: 0.5,
          amenities: ['parking', 'wifi'],
        );

        expect(copy.name, equals('Updated'));
        expect(copy.rating, equals(4.5));
        expect(copy.priceLevel, equals('\$\$\$'));
        expect(copy.distanceFromVenue, equals(0.5));
        expect(copy.amenities, containsAll(['parking', 'wifi']));
      });
    });

    group('Roundtrip (fromFirestore -> toFirestore)', () {
      test('preserves data through roundtrip', () {
        final originalData = {
          'name': 'Roundtrip Bar',
          'vicinity': '100 Test St',
          'formattedAddress': '100 Test St, Test City',
          'rating': 4.3,
          'userRatingsTotal': 200,
          'priceLevel': '\$\$',
          'types': ['bar'],
          'geometry': {
            'location': {'lat': 40.0, 'lng': -74.0},
          },
          'phoneNumber': '+1-555-0000',
          'website': 'https://test.com',
          'photos': ['photo.jpg'],
          'openingHours': {'open_now': true, 'weekday_text': []},
          'userReviews': [],
          'distanceFromVenue': 1.5,
          'isFavorite': false,
          'checkIns': 50,
          'amenities': ['wifi'],
          'lastUpdated': Timestamp.fromDate(testLastUpdated),
        };

        final place = EnhancedPlace.fromFirestore(originalData, 'doc_1');
        final outputData = place.toFirestore();

        expect(outputData['name'], equals(originalData['name']));
        expect(outputData['vicinity'], equals(originalData['vicinity']));
        expect(outputData['formattedAddress'], equals(originalData['formattedAddress']));
        expect(outputData['rating'], equals(originalData['rating']));
        expect(outputData['userRatingsTotal'], equals(originalData['userRatingsTotal']));
        expect(outputData['priceLevel'], equals(originalData['priceLevel']));
        expect(outputData['types'], equals(originalData['types']));
        expect(outputData['phoneNumber'], equals(originalData['phoneNumber']));
        expect(outputData['website'], equals(originalData['website']));
        expect(outputData['photos'], equals(originalData['photos']));
        expect(outputData['distanceFromVenue'], equals(originalData['distanceFromVenue']));
        expect(outputData['isFavorite'], equals(originalData['isFavorite']));
        expect(outputData['checkIns'], equals(originalData['checkIns']));
        expect(outputData['amenities'], equals(originalData['amenities']));
        expect(outputData['lastUpdated'], equals(originalData['lastUpdated']));
      });
    });
  });

  // ==================== PlaceGeometry ====================
  group('PlaceGeometry', () {
    test('fromMap parses location and viewport', () {
      final data = {
        'location': {'lat': 40.7128, 'lng': -74.0060},
        'viewport': {
          'northeast': {'lat': 40.72, 'lng': -73.99},
          'southwest': {'lat': 40.70, 'lng': -74.02},
        },
      };

      final geometry = PlaceGeometry.fromMap(data);

      expect(geometry.location, isNotNull);
      expect(geometry.location!.lat, equals(40.7128));
      expect(geometry.location!.lng, equals(-74.0060));
      expect(geometry.viewport, isNotNull);
      expect(geometry.viewport!.northeast.lat, equals(40.72));
      expect(geometry.viewport!.southwest.lng, equals(-74.02));
    });

    test('fromMap handles missing fields', () {
      final data = <String, dynamic>{};

      final geometry = PlaceGeometry.fromMap(data);
      expect(geometry.location, isNull);
      expect(geometry.viewport, isNull);
    });

    test('toMap serializes correctly', () {
      final geometry = PlaceGeometry(
        location: PlaceLocation(lat: 40.7128, lng: -74.0060),
      );

      final map = geometry.toMap();
      expect(map['location'], isNotNull);
      expect(map['location']['lat'], equals(40.7128));
      expect(map['viewport'], isNull);
    });

    test('toMap handles null location', () {
      final geometry = PlaceGeometry();
      final map = geometry.toMap();
      expect(map['location'], isNull);
      expect(map['viewport'], isNull);
    });
  });

  // ==================== PlaceLocation ====================
  group('PlaceLocation', () {
    test('fromMap parses coordinates', () {
      final data = {'lat': 51.5074, 'lng': -0.1278};

      final location = PlaceLocation.fromMap(data);
      expect(location.lat, equals(51.5074));
      expect(location.lng, equals(-0.1278));
    });

    test('fromMap handles integer coordinates', () {
      final data = {'lat': 52, 'lng': -1};

      final location = PlaceLocation.fromMap(data);
      expect(location.lat, equals(52.0));
      expect(location.lng, equals(-1.0));
    });

    test('toMap serializes correctly', () {
      final location = PlaceLocation(lat: 40.7128, lng: -74.0060);
      final map = location.toMap();

      expect(map['lat'], equals(40.7128));
      expect(map['lng'], equals(-74.0060));
    });
  });

  // ==================== PlaceViewport ====================
  group('PlaceViewport', () {
    test('fromMap parses northeast and southwest', () {
      final data = {
        'northeast': {'lat': 40.72, 'lng': -73.99},
        'southwest': {'lat': 40.70, 'lng': -74.02},
      };

      final viewport = PlaceViewport.fromMap(data);
      expect(viewport.northeast.lat, equals(40.72));
      expect(viewport.northeast.lng, equals(-73.99));
      expect(viewport.southwest.lat, equals(40.70));
      expect(viewport.southwest.lng, equals(-74.02));
    });

    test('toMap serializes correctly', () {
      final viewport = PlaceViewport(
        northeast: PlaceLocation(lat: 40.72, lng: -73.99),
        southwest: PlaceLocation(lat: 40.70, lng: -74.02),
      );

      final map = viewport.toMap();
      expect(map['northeast']['lat'], equals(40.72));
      expect(map['southwest']['lng'], equals(-74.02));
    });
  });

  // ==================== OpeningHours (enhanced_place version) ====================
  group('OpeningHours (EnhancedPlace)', () {
    test('fromMap parses open_now and weekday_text', () {
      final data = {
        'open_now': true,
        'weekday_text': [
          'Monday: 9:00 AM - 10:00 PM',
          'Tuesday: 9:00 AM - 10:00 PM',
        ],
      };

      final hours = OpeningHours.fromMap(data);
      expect(hours.openNow, isTrue);
      expect(hours.weekdayText, hasLength(2));
    });

    test('fromMap handles missing fields', () {
      final data = <String, dynamic>{};

      final hours = OpeningHours.fromMap(data);
      expect(hours.openNow, isFalse);
      expect(hours.weekdayText, isEmpty);
    });

    test('toMap serializes correctly', () {
      final hours = OpeningHours(
        openNow: true,
        weekdayText: ['Monday: Open'],
      );

      final map = hours.toMap();
      expect(map['open_now'], isTrue);
      expect(map['weekday_text'], hasLength(1));
    });
  });

  // ==================== PlaceReview ====================
  group('PlaceReview', () {
    test('fromMap parses complete review data', () {
      final data = {
        'reviewId': 'review_1',
        'userId': 'user_1',
        'userDisplayName': 'John Doe',
        'userProfileImageUrl': 'https://example.com/avatar.jpg',
        'rating': 4.5,
        'content': 'Great bar for watching World Cup!',
        'createdAt': Timestamp.fromDate(DateTime(2026, 5, 15)),
        'photos': ['https://example.com/review_photo.jpg'],
        'likes': 10,
        'likedBy': ['user_2', 'user_3'],
      };

      final review = PlaceReview.fromMap(data);

      expect(review.reviewId, equals('review_1'));
      expect(review.userId, equals('user_1'));
      expect(review.userDisplayName, equals('John Doe'));
      expect(review.userProfileImageUrl, equals('https://example.com/avatar.jpg'));
      expect(review.rating, equals(4.5));
      expect(review.content, equals('Great bar for watching World Cup!'));
      expect(review.createdAt, equals(DateTime(2026, 5, 15)));
      expect(review.photos, hasLength(1));
      expect(review.likes, equals(10));
      expect(review.likedBy, hasLength(2));
    });

    test('fromMap handles missing optional fields', () {
      final data = {
        'rating': 3.0,
        'content': 'OK place',
        'createdAt': Timestamp.fromDate(DateTime(2026, 6, 1)),
      };

      final review = PlaceReview.fromMap(data);

      expect(review.reviewId, equals(''));
      expect(review.userId, equals(''));
      expect(review.userDisplayName, equals('Anonymous'));
      expect(review.userProfileImageUrl, isNull);
      expect(review.photos, isEmpty);
      expect(review.likes, equals(0));
      expect(review.likedBy, isEmpty);
    });

    test('toMap serializes correctly', () {
      final review = PlaceReview(
        reviewId: 'review_1',
        userId: 'user_1',
        userDisplayName: 'Jane',
        rating: 5.0,
        content: 'Perfect!',
        createdAt: DateTime(2026, 6, 10),
        photos: ['photo.jpg'],
        likes: 5,
        likedBy: ['user_2'],
      );

      final map = review.toMap();

      expect(map['reviewId'], equals('review_1'));
      expect(map['userId'], equals('user_1'));
      expect(map['userDisplayName'], equals('Jane'));
      expect(map['rating'], equals(5.0));
      expect(map['content'], equals('Perfect!'));
      expect(map['createdAt'], isA<Timestamp>());
      expect(map['photos'], hasLength(1));
      expect(map['likes'], equals(5));
      expect(map['likedBy'], hasLength(1));
    });

    test('roundtrip preserves data through fromMap -> toMap', () {
      final original = PlaceReview(
        reviewId: 'review_1',
        userId: 'user_1',
        userDisplayName: 'Test',
        rating: 4.0,
        content: 'Good place',
        createdAt: DateTime(2026, 6, 15),
        photos: ['p1.jpg', 'p2.jpg'],
        likes: 3,
        likedBy: ['u1', 'u2', 'u3'],
      );

      final map = original.toMap();
      final restored = PlaceReview.fromMap(map);

      expect(restored.reviewId, equals(original.reviewId));
      expect(restored.userId, equals(original.userId));
      expect(restored.userDisplayName, equals(original.userDisplayName));
      expect(restored.rating, equals(original.rating));
      expect(restored.content, equals(original.content));
      expect(restored.photos, equals(original.photos));
      expect(restored.likes, equals(original.likes));
      expect(restored.likedBy, equals(original.likedBy));
    });
  });
}

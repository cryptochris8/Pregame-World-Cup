import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/recommendations/domain/entities/place.dart';
import 'package:pregame_world_cup/core/services/venue_recommendation_service.dart';

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
      photoReference: photoReference,
    );
  }

  // ===========================================================================
  // VenueCategory enum tests
  // ===========================================================================

  group('VenueCategory', () {
    test('has expected number of values', () {
      expect(VenueCategory.values, hasLength(8));
    });

    test('contains all expected categories', () {
      expect(VenueCategory.values, contains(VenueCategory.sportsBar));
      expect(VenueCategory.values, contains(VenueCategory.restaurant));
      expect(VenueCategory.values, contains(VenueCategory.brewery));
      expect(VenueCategory.values, contains(VenueCategory.cafe));
      expect(VenueCategory.values, contains(VenueCategory.nightclub));
      expect(VenueCategory.values, contains(VenueCategory.fastFood));
      expect(VenueCategory.values, contains(VenueCategory.fineDining));
      expect(VenueCategory.values, contains(VenueCategory.unknown));
    });

    test('displayName returns human-readable names', () {
      expect(VenueCategory.sportsBar.displayName, equals('Sports Bar'));
      expect(VenueCategory.restaurant.displayName, equals('Restaurant'));
      expect(VenueCategory.brewery.displayName, equals('Brewery'));
      expect(VenueCategory.cafe.displayName, equals('Caf\u00e9'));
      expect(VenueCategory.nightclub.displayName, equals('Nightclub'));
      expect(VenueCategory.fastFood.displayName, equals('Quick Bites'));
      expect(VenueCategory.fineDining.displayName, equals('Fine Dining'));
      expect(VenueCategory.unknown.displayName, equals('Venue'));
    });

    test('emoji returns non-empty string for all categories', () {
      for (final category in VenueCategory.values) {
        expect(category.emoji, isNotEmpty,
            reason: '${category.name} should have an emoji');
      }
    });

    test('icon returns valid IconData for all categories', () {
      expect(VenueCategory.sportsBar.icon, equals(Icons.sports_bar));
      expect(VenueCategory.restaurant.icon, equals(Icons.restaurant));
      expect(VenueCategory.brewery.icon, equals(Icons.local_bar));
      expect(VenueCategory.cafe.icon, equals(Icons.local_cafe));
      expect(VenueCategory.nightclub.icon, equals(Icons.nightlife));
      expect(VenueCategory.fastFood.icon, equals(Icons.fastfood));
      expect(VenueCategory.fineDining.icon, equals(Icons.star));
      expect(VenueCategory.unknown.icon, equals(Icons.place));
    });

    test('color returns non-null Color for all categories', () {
      for (final category in VenueCategory.values) {
        expect(category.color, isA<Color>(),
            reason: '${category.name} should have a color');
      }
    });

    test('colorCodes returns non-empty list for all categories', () {
      for (final category in VenueCategory.values) {
        expect(category.colorCodes, isNotEmpty,
            reason: '${category.name} should have color codes');
      }
    });
  });

  // ===========================================================================
  // VenueSortOption enum tests
  // ===========================================================================

  group('VenueSortOption', () {
    test('has expected number of values', () {
      expect(VenueSortOption.values, hasLength(5));
    });

    test('displayName returns human-readable names', () {
      expect(VenueSortOption.distance.displayName, equals('Distance'));
      expect(VenueSortOption.popularity.displayName, equals('Popular'));
      expect(VenueSortOption.rating.displayName, equals('Rating'));
      expect(VenueSortOption.name.displayName, equals('Name'));
      expect(VenueSortOption.priceLevel.displayName, equals('Price'));
    });

    test('icon returns valid IconData for all options', () {
      expect(VenueSortOption.distance.icon, equals(Icons.near_me));
      expect(VenueSortOption.popularity.icon, equals(Icons.local_fire_department));
      expect(VenueSortOption.rating.icon, equals(Icons.star));
      expect(VenueSortOption.name.icon, equals(Icons.sort_by_alpha));
      expect(VenueSortOption.priceLevel.icon, equals(Icons.attach_money));
    });
  });

  // ===========================================================================
  // VenueRecommendationService static methods
  // ===========================================================================

  group('VenueRecommendationService', () {
    group('categorizeVenue', () {
      test('categorizes sports bar (bar type + sports name)', () {
        final venue = createTestPlace(
          name: 'Sports Grill & Tavern',
          types: ['bar', 'restaurant'],
        );
        expect(
          VenueRecommendationService.categorizeVenue(venue),
          equals(VenueCategory.sportsBar),
        );
      });

      test('categorizes venue with tavern in name as sports bar', () {
        final venue = createTestPlace(
          name: "O'Malley's Tavern",
          types: ['bar'],
        );
        expect(
          VenueRecommendationService.categorizeVenue(venue),
          equals(VenueCategory.sportsBar),
        );
      });

      test('categorizes venue with grill in name as sports bar', () {
        final venue = createTestPlace(
          name: 'Dallas Grill',
          types: ['bar', 'restaurant'],
        );
        expect(
          VenueRecommendationService.categorizeVenue(venue),
          equals(VenueCategory.sportsBar),
        );
      });

      test('categorizes brewery by type', () {
        final venue = createTestPlace(
          name: 'Deep Ellum Brewing',
          types: ['brewery'],
        );
        expect(
          VenueRecommendationService.categorizeVenue(venue),
          equals(VenueCategory.brewery),
        );
      });

      test('categorizes brewery by name keyword', () {
        final venue = createTestPlace(
          name: 'Craft Brew House',
          types: ['restaurant'],
        );
        expect(
          VenueRecommendationService.categorizeVenue(venue),
          equals(VenueCategory.brewery),
        );
      });

      test('categorizes fine dining (high price restaurant)', () {
        final venue = createTestPlace(
          name: 'Le Fancy Restaurant',
          types: ['restaurant'],
          priceLevel: 3,
        );
        expect(
          VenueRecommendationService.categorizeVenue(venue),
          equals(VenueCategory.fineDining),
        );
      });

      test('categorizes fast food by type', () {
        final venue = createTestPlace(
          name: 'Quick Eats',
          types: ['meal_takeaway'],
        );
        expect(
          VenueRecommendationService.categorizeVenue(venue),
          equals(VenueCategory.fastFood),
        );
      });

      test('categorizes fast food by name keyword', () {
        final venue = createTestPlace(
          name: 'Joe\'s Pizza',
          types: ['restaurant'],
        );
        expect(
          VenueRecommendationService.categorizeVenue(venue),
          equals(VenueCategory.fastFood),
        );
      });

      test('categorizes nightclub by type', () {
        final venue = createTestPlace(
          name: 'The Vibe',
          types: ['night_club'],
        );
        expect(
          VenueRecommendationService.categorizeVenue(venue),
          equals(VenueCategory.nightclub),
        );
      });

      test('categorizes nightclub by name keyword (lounge)', () {
        final venue = createTestPlace(
          name: 'Skyline Lounge',
          types: ['bar'],
          priceLevel: 2,
        );
        // 'bar' type + 'lounge' in name -- the 'lounge' keyword check happens
        // after the sports bar check. Since 'lounge' is not 'sports', 'tavern',
        // or 'grill', it won't match sportsBar. Then bar with no brewery match
        // goes to nightclub check where 'lounge' matches.
        // Actually, 'bar' type without sports/tavern/grill -> falls through to
        // later checks. The nightclub check uses club/lounge keywords.
        final category = VenueRecommendationService.categorizeVenue(venue);
        expect(category, equals(VenueCategory.nightclub));
      });

      test('categorizes cafe by type', () {
        final venue = createTestPlace(
          name: 'Morning Cup',
          types: ['cafe'],
        );
        expect(
          VenueRecommendationService.categorizeVenue(venue),
          equals(VenueCategory.cafe),
        );
      });

      test('categorizes cafe by name keyword', () {
        final venue = createTestPlace(
          name: 'Starbucks Coffee',
          types: ['restaurant'],
        );
        expect(
          VenueRecommendationService.categorizeVenue(venue),
          equals(VenueCategory.cafe),
        );
      });

      test('categorizes general restaurant', () {
        final venue = createTestPlace(
          name: 'Bella Italia',
          types: ['restaurant', 'food'],
          priceLevel: 2,
        );
        expect(
          VenueRecommendationService.categorizeVenue(venue),
          equals(VenueCategory.restaurant),
        );
      });

      test('categorizes bar without keywords as sports bar', () {
        // Bars default to sportsBar for game day context
        final venue = createTestPlace(
          name: 'The Pub',
          types: ['bar'],
        );
        expect(
          VenueRecommendationService.categorizeVenue(venue),
          equals(VenueCategory.sportsBar),
        );
      });

      test('returns unknown for unrecognized types', () {
        final venue = createTestPlace(
          name: 'Generic Place',
          types: ['point_of_interest', 'establishment'],
        );
        expect(
          VenueRecommendationService.categorizeVenue(venue),
          equals(VenueCategory.unknown),
        );
      });

      test('returns unknown for null types', () {
        final venue = createTestPlace(
          name: 'No Types Venue',
          types: null,
        );
        expect(
          VenueRecommendationService.categorizeVenue(venue),
          equals(VenueCategory.unknown),
        );
      });

      test('returns unknown for empty types', () {
        final venue = createTestPlace(
          name: 'Empty Types Venue',
          types: [],
        );
        expect(
          VenueRecommendationService.categorizeVenue(venue),
          equals(VenueCategory.unknown),
        );
      });
    });

    group('calculatePopularityScore', () {
      test('returns 0 for venue with no rating', () {
        final venue = createTestPlace(rating: 0.0, userRatingsTotal: 100);
        expect(
          VenueRecommendationService.calculatePopularityScore(venue),
          equals(0.0),
        );
      });

      test('returns 0 for venue with no reviews', () {
        final venue = createTestPlace(rating: 4.5, userRatingsTotal: 0);
        expect(
          VenueRecommendationService.calculatePopularityScore(venue),
          equals(0.0),
        );
      });

      test('returns 0 for venue with null rating', () {
        final venue = createTestPlace(rating: null, userRatingsTotal: null);
        expect(
          VenueRecommendationService.calculatePopularityScore(venue),
          equals(0.0),
        );
      });

      test('returns positive score for venue with good rating and reviews', () {
        final venue = createTestPlace(rating: 4.5, userRatingsTotal: 200);
        final score =
            VenueRecommendationService.calculatePopularityScore(venue);
        expect(score, greaterThan(0));
      });

      test('higher rated venue gets higher score (same review count)', () {
        final highRated = createTestPlace(
          placeId: 'high',
          rating: 5.0,
          userRatingsTotal: 100,
        );
        final lowRated = createTestPlace(
          placeId: 'low',
          rating: 3.0,
          userRatingsTotal: 100,
        );
        final highScore =
            VenueRecommendationService.calculatePopularityScore(highRated);
        final lowScore =
            VenueRecommendationService.calculatePopularityScore(lowRated);
        expect(highScore, greaterThan(lowScore));
      });

      test('more reviewed venue gets higher score (same rating)', () {
        final manyReviews = createTestPlace(
          placeId: 'many',
          rating: 4.0,
          userRatingsTotal: 500,
        );
        final fewReviews = createTestPlace(
          placeId: 'few',
          rating: 4.0,
          userRatingsTotal: 10,
        );
        final manyScore =
            VenueRecommendationService.calculatePopularityScore(manyReviews);
        final fewScore =
            VenueRecommendationService.calculatePopularityScore(fewReviews);
        expect(manyScore, greaterThan(fewScore));
      });
    });

    group('isPopular', () {
      test('returns true for highly rated venue with many reviews', () {
        final venue = createTestPlace(rating: 4.8, userRatingsTotal: 500);
        expect(VenueRecommendationService.isPopular(venue), isTrue);
      });

      test('returns false for low-rated venue', () {
        final venue = createTestPlace(rating: 2.0, userRatingsTotal: 10);
        expect(VenueRecommendationService.isPopular(venue), isFalse);
      });

      test('returns false for venue with no rating', () {
        final venue = createTestPlace(rating: null, userRatingsTotal: null);
        expect(VenueRecommendationService.isPopular(venue), isFalse);
      });
    });

    group('getPopularVenues', () {
      test('returns venues sorted by popularity score', () {
        final venues = [
          createTestPlace(
              placeId: 'low', rating: 2.5, userRatingsTotal: 10, name: 'Low'),
          createTestPlace(
              placeId: 'high',
              rating: 4.9,
              userRatingsTotal: 500,
              name: 'High'),
          createTestPlace(
              placeId: 'mid',
              rating: 4.0,
              userRatingsTotal: 100,
              name: 'Mid'),
        ];

        final popular = VenueRecommendationService.getPopularVenues(venues);

        expect(popular.first.placeId, equals('high'));
        expect(popular.last.placeId, equals('low'));
      });

      test('respects limit parameter', () {
        final venues = List.generate(
          20,
          (i) => createTestPlace(
            placeId: 'venue_$i',
            name: 'Venue $i',
            rating: 4.0 + (i % 10) * 0.1,
            userRatingsTotal: 50 + i * 10,
          ),
        );

        final popular =
            VenueRecommendationService.getPopularVenues(venues, limit: 5);

        expect(popular.length, equals(5));
      });

      test('handles empty list', () {
        final popular =
            VenueRecommendationService.getPopularVenues(<Place>[]);
        expect(popular, isEmpty);
      });
    });

    group('getVenuesByCategory', () {
      test('filters venues by category', () {
        final venues = [
          createTestPlace(
              placeId: 'bar',
              name: 'Sports Bar',
              types: ['bar'],
              rating: 4.0),
          createTestPlace(
              placeId: 'rest',
              name: 'Italian Place',
              types: ['restaurant'],
              rating: 4.0,
              priceLevel: 2),
          createTestPlace(
              placeId: 'cafe',
              name: 'Coffee Shop',
              types: ['cafe'],
              rating: 4.0),
        ];

        final restaurants = VenueRecommendationService.getVenuesByCategory(
          venues,
          VenueCategory.restaurant,
        );

        expect(restaurants.length, equals(1));
        expect(restaurants.first.placeId, equals('rest'));
      });
    });

    group('getOpenVenues', () {
      test('returns only venues that are currently open', () {
        final venues = [
          createTestPlace(
            placeId: 'open_1',
            name: 'Open Bar',
            openingHours: OpeningHours(openNow: true),
          ),
          createTestPlace(
            placeId: 'closed_1',
            name: 'Closed Bar',
            openingHours: OpeningHours(openNow: false),
          ),
          createTestPlace(
            placeId: 'unknown_1',
            name: 'Unknown Hours Bar',
          ),
        ];

        final openVenues = VenueRecommendationService.getOpenVenues(venues);

        expect(openVenues.length, equals(1));
        expect(openVenues.first.placeId, equals('open_1'));
      });
    });

    group('getHighlyRatedVenues', () {
      test('returns only venues with rating >= 4.0', () {
        final venues = [
          createTestPlace(placeId: 'good', rating: 4.5, name: 'Good Bar'),
          createTestPlace(placeId: 'bad', rating: 3.5, name: 'Okay Bar'),
          createTestPlace(placeId: 'none', rating: null, name: 'No Rating Bar'),
          createTestPlace(placeId: 'exact', rating: 4.0, name: 'Exact 4 Bar'),
        ];

        final highlyRated =
            VenueRecommendationService.getHighlyRatedVenues(venues);

        expect(highlyRated.length, equals(2));
        expect(highlyRated.map((v) => v.placeId), containsAll(['good', 'exact']));
      });
    });
  });
}

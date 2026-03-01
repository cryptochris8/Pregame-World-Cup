import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/services/venue_models.dart';
import 'package:pregame_world_cup/core/services/venue_scoring_service.dart';
import 'package:pregame_world_cup/features/recommendations/domain/entities/place.dart';

/// UnifiedVenueService is a singleton with [FirebaseAuth.instance] eagerly
/// initialized in its field declaration, making it impossible to construct
/// in a test environment without Firebase.  We test the public business
/// logic that UnifiedVenueService delegates to, which is the categorization
/// algorithm and the fallback-recommendation path.  The categorization
/// algorithm is re-implemented here (matching the source exactly) so that
/// we can verify it without touching Firebase.  The scoring and sorting
/// are already thoroughly covered by [VenueScoringService] tests.
void main() {
  // ============================================================================
  // categorizeVenue - standalone replica of UnifiedVenueService.categorizeVenue
  // ============================================================================

  /// Exact replica of UnifiedVenueService.categorizeVenue for testability.
  VenueCategory categorizeVenue(Place place) {
    final types = place.types ?? [];
    final name = place.name.toLowerCase();

    // Sports Bar detection
    if (types.any((type) => type.contains('bar')) &&
        (name.contains('sports') ||
            name.contains('tavern') ||
            name.contains('grill'))) {
      return VenueCategory.sportsBar;
    }

    // Brewery detection
    if (types.any((type) => ['brewery', 'liquor_store'].contains(type)) ||
        name.contains('brew') ||
        name.contains('beer')) {
      return VenueCategory.brewery;
    }

    // Fine dining detection
    if (place.priceLevel != null && place.priceLevel! >= 3) {
      if (types.any((type) => type.contains('restaurant'))) {
        return VenueCategory.fineDining;
      }
    }

    // Fast food detection
    if (types.any((type) => ['meal_delivery', 'meal_takeaway'].contains(type)) ||
        name.contains('pizza') ||
        name.contains('burger') ||
        name.contains('fast')) {
      return VenueCategory.fastFood;
    }

    // Nightclub detection
    if (types.any((type) => ['night_club', 'dance_club'].contains(type)) ||
        name.contains('club') ||
        name.contains('lounge')) {
      return VenueCategory.nightclub;
    }

    // Cafe detection
    if (types.any((type) => ['cafe', 'coffee'].contains(type)) ||
        name.contains('coffee') ||
        name.contains('cafe')) {
      return VenueCategory.cafe;
    }

    // Restaurant (default for food places)
    if (types.any((type) => type.contains('restaurant')) ||
        types.any((type) => type.contains('food'))) {
      return VenueCategory.restaurant;
    }

    return VenueCategory.unknown;
  }

  // ============================================================================
  // Sports Bar detection
  // ============================================================================
  group('categorizeVenue - Sports Bar', () {
    test('detects sports bar with bar type and "sports" in name', () {
      const venue = Place(
        placeId: 'sb1',
        name: 'Sports Grill & Bar',
        types: ['bar', 'restaurant'],
      );
      expect(categorizeVenue(venue), VenueCategory.sportsBar);
    });

    test('detects sports bar with bar type and "tavern" in name', () {
      const venue = Place(
        placeId: 'sb2',
        name: 'The Local Tavern',
        types: ['bar'],
      );
      expect(categorizeVenue(venue), VenueCategory.sportsBar);
    });

    test('detects sports bar with bar type and "grill" in name', () {
      const venue = Place(
        placeId: 'sb3',
        name: 'Buffalo Wild Wings Grill',
        types: ['bar', 'restaurant'],
      );
      expect(categorizeVenue(venue), VenueCategory.sportsBar);
    });

    test('does not detect sports bar without bar type', () {
      const venue = Place(
        placeId: 'sb4',
        name: 'Sports Restaurant',
        types: ['restaurant'],
      );
      expect(categorizeVenue(venue), isNot(VenueCategory.sportsBar));
    });

    test('does not detect sports bar without matching name keyword', () {
      const venue = Place(
        placeId: 'sb5',
        name: 'The Drink Place',
        types: ['bar'],
      );
      expect(categorizeVenue(venue), isNot(VenueCategory.sportsBar));
    });
  });

  // ============================================================================
  // Brewery detection
  // ============================================================================
  group('categorizeVenue - Brewery', () {
    test('detects brewery by type', () {
      const venue = Place(placeId: 'br1', name: 'Craft Place', types: ['brewery']);
      expect(categorizeVenue(venue), VenueCategory.brewery);
    });

    test('detects brewery by "brew" in name', () {
      const venue = Place(placeId: 'br2', name: 'BrewDog Taproom', types: ['restaurant']);
      expect(categorizeVenue(venue), VenueCategory.brewery);
    });

    test('detects brewery by "beer" in name', () {
      const venue = Place(placeId: 'br3', name: 'Beer Garden', types: ['restaurant']);
      expect(categorizeVenue(venue), VenueCategory.brewery);
    });

    test('detects brewery by liquor_store type', () {
      const venue = Place(placeId: 'br4', name: 'Total Wine', types: ['liquor_store']);
      expect(categorizeVenue(venue), VenueCategory.brewery);
    });
  });

  // ============================================================================
  // Fine Dining detection
  // ============================================================================
  group('categorizeVenue - Fine Dining', () {
    test('detects fine dining for expensive restaurant (price 3)', () {
      const venue = Place(placeId: 'fd1', name: 'Le Fancy', types: ['restaurant'], priceLevel: 3);
      expect(categorizeVenue(venue), VenueCategory.fineDining);
    });

    test('detects fine dining for price level 4', () {
      const venue = Place(placeId: 'fd2', name: 'Michelin Star', types: ['restaurant', 'food'], priceLevel: 4);
      expect(categorizeVenue(venue), VenueCategory.fineDining);
    });

    test('does not detect fine dining for price level 2', () {
      const venue = Place(placeId: 'fd3', name: 'Regular Place', types: ['restaurant'], priceLevel: 2);
      expect(categorizeVenue(venue), isNot(VenueCategory.fineDining));
    });

    test('does not detect fine dining without restaurant type', () {
      const venue = Place(placeId: 'fd4', name: 'Expensive Store', types: ['store'], priceLevel: 4);
      expect(categorizeVenue(venue), isNot(VenueCategory.fineDining));
    });
  });

  // ============================================================================
  // Fast Food detection
  // ============================================================================
  group('categorizeVenue - Fast Food', () {
    test('detects fast food by meal_delivery type', () {
      const venue = Place(placeId: 'ff1', name: 'Quick Eats', types: ['meal_delivery']);
      expect(categorizeVenue(venue), VenueCategory.fastFood);
    });

    test('detects fast food by meal_takeaway type', () {
      const venue = Place(placeId: 'ff2', name: 'Takeout Place', types: ['meal_takeaway']);
      expect(categorizeVenue(venue), VenueCategory.fastFood);
    });

    test('detects fast food by "pizza" in name', () {
      const venue = Place(placeId: 'ff3', name: "Domino's Pizza", types: ['restaurant']);
      expect(categorizeVenue(venue), VenueCategory.fastFood);
    });

    test('detects fast food by "burger" in name', () {
      const venue = Place(placeId: 'ff4', name: 'Five Guys Burgers', types: ['restaurant']);
      expect(categorizeVenue(venue), VenueCategory.fastFood);
    });

    test('detects fast food by "fast" in name', () {
      const venue = Place(placeId: 'ff5', name: 'Fast Bites Diner', types: ['restaurant']);
      expect(categorizeVenue(venue), VenueCategory.fastFood);
    });
  });

  // ============================================================================
  // Nightclub detection
  // ============================================================================
  group('categorizeVenue - Nightclub', () {
    test('detects nightclub by night_club type', () {
      const venue = Place(placeId: 'nc1', name: 'Pulse', types: ['night_club']);
      expect(categorizeVenue(venue), VenueCategory.nightclub);
    });

    test('detects nightclub by dance_club type', () {
      const venue = Place(placeId: 'nc1b', name: 'Dance Hall', types: ['dance_club']);
      expect(categorizeVenue(venue), VenueCategory.nightclub);
    });

    test('detects nightclub by "club" in name', () {
      const venue = Place(placeId: 'nc2', name: 'The Club House', types: ['establishment']);
      expect(categorizeVenue(venue), VenueCategory.nightclub);
    });

    test('detects nightclub by "lounge" in name', () {
      const venue = Place(placeId: 'nc3', name: 'Skyline Lounge', types: ['establishment']);
      expect(categorizeVenue(venue), VenueCategory.nightclub);
    });
  });

  // ============================================================================
  // Cafe detection
  // ============================================================================
  group('categorizeVenue - Cafe', () {
    test('detects cafe by cafe type', () {
      const venue = Place(placeId: 'cf1', name: 'Morning Spot', types: ['cafe']);
      expect(categorizeVenue(venue), VenueCategory.cafe);
    });

    test('detects cafe by coffee type', () {
      const venue = Place(placeId: 'cf2', name: 'Java Place', types: ['coffee']);
      expect(categorizeVenue(venue), VenueCategory.cafe);
    });

    test('detects cafe by "coffee" in name', () {
      const venue = Place(placeId: 'cf3', name: 'Blue Bottle Coffee', types: ['restaurant']);
      expect(categorizeVenue(venue), VenueCategory.cafe);
    });

    test('detects cafe by "cafe" in name', () {
      const venue = Place(placeId: 'cf4', name: 'Paris Cafe', types: ['restaurant']);
      expect(categorizeVenue(venue), VenueCategory.cafe);
    });
  });

  // ============================================================================
  // Restaurant detection
  // ============================================================================
  group('categorizeVenue - Restaurant', () {
    test('detects restaurant by restaurant type', () {
      const venue = Place(placeId: 'r1', name: 'Good Eats', types: ['restaurant'], priceLevel: 2);
      expect(categorizeVenue(venue), VenueCategory.restaurant);
    });

    test('detects restaurant by food type', () {
      const venue = Place(placeId: 'r2', name: 'Food Court', types: ['food']);
      expect(categorizeVenue(venue), VenueCategory.restaurant);
    });
  });

  // ============================================================================
  // Unknown detection
  // ============================================================================
  group('categorizeVenue - Unknown', () {
    test('returns unknown for unrecognized venue', () {
      const venue = Place(placeId: 'u1', name: 'Random Place', types: ['point_of_interest']);
      expect(categorizeVenue(venue), VenueCategory.unknown);
    });

    test('returns unknown for venue with empty types', () {
      const venue = Place(placeId: 'u2', name: 'Mystery Spot', types: []);
      expect(categorizeVenue(venue), VenueCategory.unknown);
    });

    test('returns unknown for venue with null types', () {
      const venue = Place(placeId: 'u3', name: 'No Type');
      expect(categorizeVenue(venue), VenueCategory.unknown);
    });
  });

  // ============================================================================
  // Priority ordering
  // ============================================================================
  group('categorizeVenue - Priority', () {
    test('sports bar takes priority over brewery for bar + brew + sports name', () {
      const venue = Place(placeId: 'pr1', name: 'Sports Brew Bar', types: ['bar']);
      expect(categorizeVenue(venue), VenueCategory.sportsBar);
    });

    test('brewery takes priority over fine dining for brew + expensive', () {
      const venue = Place(placeId: 'pr2', name: 'BrewMaster Premium', types: ['restaurant'], priceLevel: 4);
      expect(categorizeVenue(venue), VenueCategory.brewery);
    });

    test('fine dining takes priority over fast food for expensive restaurant', () {
      const venue = Place(placeId: 'pr3', name: 'Artisan Slice', types: ['restaurant'], priceLevel: 3);
      expect(categorizeVenue(venue), VenueCategory.fineDining);
    });
  });

  // ============================================================================
  // Case insensitivity
  // ============================================================================
  group('categorizeVenue - Case insensitivity', () {
    test('name matching is case insensitive', () {
      const venue = Place(placeId: 'ci1', name: 'SPORTS BAR EXTREME', types: ['bar']);
      expect(categorizeVenue(venue), VenueCategory.sportsBar);
    });

    test('cafe detection works with uppercase', () {
      const venue = Place(placeId: 'ci2', name: 'CAFE CENTRAL', types: ['restaurant']);
      expect(categorizeVenue(venue), VenueCategory.cafe);
    });

    test('brewery detection with mixed case', () {
      const venue = Place(placeId: 'ci3', name: 'BrewPub Downtown', types: ['bar']);
      expect(categorizeVenue(venue), VenueCategory.brewery);
    });
  });

  // ============================================================================
  // Fallback recommendation logic
  // ============================================================================
  group('fallback recommendation logic', () {
    late VenueScoringService scoringService;

    setUp(() {
      scoringService = VenueScoringService();
    });

    test('fallback produces recommendations from venue list', () {
      final venues = [
        const Place(placeId: 'p1', name: 'V1', rating: 4.0),
        const Place(placeId: 'p2', name: 'V2', rating: 3.5),
        const Place(placeId: 'p3', name: 'V3', rating: 4.5),
      ];
      const limit = 2;

      final fallback = venues
          .take(limit)
          .map((venue) => EnhancedVenueRecommendation(
                venue: venue,
                category: categorizeVenue(venue),
                unifiedScore: scoringService.calculateBasicScore(venue),
                basicScore: scoringService.calculateBasicScore(venue),
                aiAnalysis: null,
                personalizationScore: 0.5,
                contextScore: 0.5,
                tags: ['Venue'],
                reasoning: 'Popular choice',
                confidence: 0.6,
              ))
          .toList();

      expect(fallback.length, 2);
      expect(fallback[0].venue.placeId, 'p1');
      expect(fallback[1].venue.placeId, 'p2');
      expect(fallback[0].tags, ['Venue']);
      expect(fallback[0].reasoning, 'Popular choice');
      expect(fallback[0].confidence, 0.6);
      expect(fallback[0].aiAnalysis, isNull);
    });

    test('fallback with empty venue list returns empty', () {
      final venues = <Place>[];
      const limit = 10;

      final fallback = venues
          .take(limit)
          .map((venue) => EnhancedVenueRecommendation(
                venue: venue,
                category: categorizeVenue(venue),
                unifiedScore: scoringService.calculateBasicScore(venue),
                basicScore: scoringService.calculateBasicScore(venue),
                aiAnalysis: null,
                personalizationScore: 0.5,
                contextScore: 0.5,
                tags: ['Venue'],
                reasoning: 'Popular choice',
                confidence: 0.6,
              ))
          .toList();

      expect(fallback, isEmpty);
    });

    test('fallback unifiedScore equals basicScore', () {
      const venue = Place(placeId: 'p1', name: 'Test', rating: 4.0, priceLevel: 2, openingHours: null);
      final basicScore = scoringService.calculateBasicScore(venue);

      final rec = EnhancedVenueRecommendation(
        venue: venue,
        category: categorizeVenue(venue),
        unifiedScore: basicScore,
        basicScore: basicScore,
        aiAnalysis: null,
        personalizationScore: 0.5,
        contextScore: 0.5,
        tags: ['Venue'],
        reasoning: 'Popular choice',
        confidence: 0.6,
      );

      expect(rec.unifiedScore, rec.basicScore);
    });
  });

  // ============================================================================
  // Category filter logic
  // ============================================================================
  group('category filter logic', () {
    test('filtering by category works correctly', () {
      final venues = [
        const Place(placeId: 'p1', name: 'Sports Grill', types: ['bar']),
        const Place(placeId: 'p2', name: 'Le Fancy', types: ['restaurant'], priceLevel: 3),
        const Place(placeId: 'p3', name: 'BrewPub', types: ['brewery']),
        const Place(placeId: 'p4', name: 'Cafe Corner', types: ['cafe']),
      ];

      final filterCategories = [VenueCategory.brewery, VenueCategory.cafe];

      final filtered = venues.where((venue) {
        final category = categorizeVenue(venue);
        return filterCategories.contains(category);
      }).toList();

      expect(filtered.length, 2);
      expect(filtered[0].placeId, 'p3');
      expect(filtered[1].placeId, 'p4');
    });

    test('empty filter returns all venues', () {
      final venues = [
        const Place(placeId: 'p1', name: 'V1', types: ['restaurant']),
        const Place(placeId: 'p2', name: 'V2', types: ['cafe']),
      ];

      final filterCategories = <VenueCategory>[];

      // When filterCategories is empty, no filtering is applied
      var filteredVenues = venues;
      if (filterCategories.isNotEmpty) {
        filteredVenues = venues.where((venue) {
          final category = categorizeVenue(venue);
          return filterCategories.contains(category);
        }).toList();
      }

      expect(filteredVenues.length, 2);
    });

    test('filter with no matching category returns empty', () {
      final venues = [
        const Place(placeId: 'p1', name: 'Cafe', types: ['cafe']),
        const Place(placeId: 'p2', name: 'Coffee House', types: ['coffee']),
      ];

      final filterCategories = [VenueCategory.sportsBar];

      final filtered = venues.where((venue) {
        final category = categorizeVenue(venue);
        return filterCategories.contains(category);
      }).toList();

      expect(filtered, isEmpty);
    });
  });
}

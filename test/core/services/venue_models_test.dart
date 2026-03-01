import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/services/venue_models.dart';
import 'package:pregame_world_cup/features/recommendations/domain/entities/place.dart';

void main() {
  // ============================================================================
  // AIVenueAnalysis
  // ============================================================================
  group('AIVenueAnalysis', () {
    group('constructor', () {
      test('creates with all required fields', () {
        final analysis = AIVenueAnalysis(
          overallScore: 0.85,
          confidence: 0.9,
          crowdPrediction: 'High',
          atmosphereRating: 0.8,
          gameWatchingScore: 0.9,
          socialScore: 0.75,
          insights: ['Great TV setup', 'Lively crowd'],
          recommendations: ['Arrive early', 'Try the nachos'],
        );
        expect(analysis.overallScore, 0.85);
        expect(analysis.confidence, 0.9);
        expect(analysis.crowdPrediction, 'High');
        expect(analysis.atmosphereRating, 0.8);
        expect(analysis.gameWatchingScore, 0.9);
        expect(analysis.socialScore, 0.75);
        expect(analysis.insights, hasLength(2));
        expect(analysis.recommendations, hasLength(2));
      });
    });

    group('fallback factory', () {
      late AIVenueAnalysis fallback;

      setUp(() {
        fallback = AIVenueAnalysis.fallback();
      });

      test('has moderate overall score', () {
        expect(fallback.overallScore, 0.5);
      });

      test('has 0.6 confidence', () {
        expect(fallback.confidence, 0.6);
      });

      test('has "Moderate" crowd prediction', () {
        expect(fallback.crowdPrediction, 'Moderate');
      });

      test('has 0.5 atmosphere rating', () {
        expect(fallback.atmosphereRating, 0.5);
      });

      test('has 0.5 game watching score', () {
        expect(fallback.gameWatchingScore, 0.5);
      });

      test('has 0.5 social score', () {
        expect(fallback.socialScore, 0.5);
      });

      test('has single generic insight', () {
        expect(fallback.insights, ['Popular venue']);
      });

      test('has single generic recommendation', () {
        expect(fallback.recommendations, ['Worth checking out']);
      });
    });
  });

  // ============================================================================
  // EnhancedVenueRecommendation
  // ============================================================================
  group('EnhancedVenueRecommendation', () {
    test('creates with all required fields', () {
      final venue = Place(placeId: 'p1', name: 'Test Venue');
      final analysis = AIVenueAnalysis.fallback();
      final recommendation = EnhancedVenueRecommendation(
        venue: venue,
        category: VenueCategory.sportsBar,
        unifiedScore: 0.85,
        basicScore: 0.7,
        aiAnalysis: analysis,
        personalizationScore: 0.6,
        contextScore: 0.8,
        tags: ['sports', 'beer', 'big screens'],
        reasoning: 'Great sports bar with multiple screens',
        confidence: 0.9,
      );
      expect(recommendation.venue.placeId, 'p1');
      expect(recommendation.category, VenueCategory.sportsBar);
      expect(recommendation.unifiedScore, 0.85);
      expect(recommendation.basicScore, 0.7);
      expect(recommendation.aiAnalysis, isNotNull);
      expect(recommendation.personalizationScore, 0.6);
      expect(recommendation.contextScore, 0.8);
      expect(recommendation.tags, hasLength(3));
      expect(recommendation.reasoning, contains('Great sports bar'));
      expect(recommendation.confidence, 0.9);
    });

    test('allows null aiAnalysis', () {
      final venue = Place(placeId: 'p2', name: 'Test Place');
      final recommendation = EnhancedVenueRecommendation(
        venue: venue,
        category: VenueCategory.restaurant,
        unifiedScore: 0.5,
        basicScore: 0.5,
        aiAnalysis: null,
        personalizationScore: 0.0,
        contextScore: 0.5,
        tags: [],
        reasoning: 'Basic recommendation',
        confidence: 0.3,
      );
      expect(recommendation.aiAnalysis, isNull);
    });

    test('supports empty tags list', () {
      final venue = Place(placeId: 'p3', name: 'Simple Place');
      final recommendation = EnhancedVenueRecommendation(
        venue: venue,
        category: VenueCategory.unknown,
        unifiedScore: 0.3,
        basicScore: 0.3,
        aiAnalysis: null,
        personalizationScore: 0.0,
        contextScore: 0.3,
        tags: [],
        reasoning: '',
        confidence: 0.1,
      );
      expect(recommendation.tags, isEmpty);
    });
  });

  // ============================================================================
  // VenueSortOption enum
  // ============================================================================
  group('VenueSortOption', () {
    test('has five enum values', () {
      expect(VenueSortOption.values.length, 5);
    });

    group('displayName', () {
      test('returns correct display names', () {
        expect(VenueSortOption.distance.displayName, 'Distance');
        expect(VenueSortOption.popularity.displayName, 'Popular');
        expect(VenueSortOption.rating.displayName, 'Rating');
        expect(VenueSortOption.name.displayName, 'Name');
        expect(VenueSortOption.priceLevel.displayName, 'Price');
      });
    });

    group('icon', () {
      test('returns an IconData for each option', () {
        for (final option in VenueSortOption.values) {
          expect(option.icon, isA<IconData>());
        }
      });

      test('returns specific icons', () {
        expect(VenueSortOption.distance.icon, Icons.near_me);
        expect(VenueSortOption.popularity.icon, Icons.local_fire_department);
        expect(VenueSortOption.rating.icon, Icons.star);
        expect(VenueSortOption.name.icon, Icons.sort_by_alpha);
        expect(VenueSortOption.priceLevel.icon, Icons.attach_money);
      });
    });
  });

  // ============================================================================
  // VenueCategory enum
  // ============================================================================
  group('VenueCategory', () {
    test('has eight enum values', () {
      expect(VenueCategory.values.length, 8);
    });

    group('displayName', () {
      test('returns correct display names', () {
        expect(VenueCategory.sportsBar.displayName, 'Sports Bar');
        expect(VenueCategory.restaurant.displayName, 'Restaurant');
        expect(VenueCategory.brewery.displayName, 'Brewery');
        expect(VenueCategory.cafe.displayName, 'Cafe');
        expect(VenueCategory.nightclub.displayName, 'Nightclub');
        expect(VenueCategory.fastFood.displayName, 'Quick Bites');
        expect(VenueCategory.fineDining.displayName, 'Fine Dining');
        expect(VenueCategory.unknown.displayName, 'Venue');
      });
    });

    group('emoji', () {
      test('returns a non-empty emoji for each category', () {
        for (final category in VenueCategory.values) {
          expect(category.emoji, isNotEmpty);
        }
      });

      test('returns distinct emojis for each category', () {
        final emojis = VenueCategory.values.map((c) => c.emoji).toSet();
        expect(emojis.length, VenueCategory.values.length);
      });
    });

    group('icon', () {
      test('returns an IconData for each category', () {
        for (final category in VenueCategory.values) {
          expect(category.icon, isA<IconData>());
        }
      });

      test('returns specific icons', () {
        expect(VenueCategory.sportsBar.icon, Icons.sports_bar);
        expect(VenueCategory.restaurant.icon, Icons.restaurant);
        expect(VenueCategory.brewery.icon, Icons.local_bar);
        expect(VenueCategory.cafe.icon, Icons.local_cafe);
        expect(VenueCategory.nightclub.icon, Icons.nightlife);
        expect(VenueCategory.fastFood.icon, Icons.fastfood);
        expect(VenueCategory.fineDining.icon, Icons.star);
        expect(VenueCategory.unknown.icon, Icons.place);
      });
    });

    group('color', () {
      test('returns a Color for each category', () {
        for (final category in VenueCategory.values) {
          expect(category.color, isA<Color>());
        }
      });

      test('returns distinct colors for each category', () {
        final colors = VenueCategory.values.map((c) => c.color).toSet();
        expect(colors.length, VenueCategory.values.length);
      });

      test('returns correct specific colors', () {
        expect(VenueCategory.sportsBar.color, const Color(0xFF2E7D32));
        expect(VenueCategory.restaurant.color, const Color(0xFF8B4513));
        expect(VenueCategory.brewery.color, const Color(0xFFFF8F00));
        expect(VenueCategory.cafe.color, const Color(0xFF5D4037));
        expect(VenueCategory.nightclub.color, const Color(0xFF7B1FA2));
        expect(VenueCategory.fastFood.color, const Color(0xFFD84315));
        expect(VenueCategory.fineDining.color, const Color(0xFF1565C0));
        expect(VenueCategory.unknown.color, const Color(0xFF757575));
      });
    });
  });
}

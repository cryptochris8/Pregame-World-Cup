import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/ai/services/ai_venue_fallback_helpers.dart';

void main() {
  group('AIVenueFallbackHelpers', () {
    group('summarizeBehaviorData', () {
      test('returns empty string when no data', () {
        final result = AIVenueFallbackHelpers.summarizeBehaviorData({});
        expect(result, isEmpty);
      });

      test('summarizes game interaction counts', () {
        final result = AIVenueFallbackHelpers.summarizeBehaviorData({
          'gameInteractions': [
            {'interactionType': 'view'},
            {'interactionType': 'view'},
            {'interactionType': 'favorite'},
            {'interactionType': 'view'},
          ],
        });
        expect(result, contains('3 views'));
        expect(result, contains('1 favorites'));
      });

      test('summarizes team preferences', () {
        final result = AIVenueFallbackHelpers.summarizeBehaviorData({
          'teamPreferences': [
            {'action': 'add', 'teamName': 'Brazil'},
            {'action': 'add', 'teamName': 'France'},
            {'action': 'remove', 'teamName': 'Germany'},
          ],
        });
        expect(result, contains('Brazil'));
        expect(result, contains('France'));
        expect(result, isNot(contains('Germany')));
      });

      test('deduplicates team preferences', () {
        final result = AIVenueFallbackHelpers.summarizeBehaviorData({
          'teamPreferences': [
            {'action': 'add', 'teamName': 'Brazil'},
            {'action': 'add', 'teamName': 'Brazil'},
          ],
        });
        // Brazil should appear only once since toSet() is used
        final brazilOccurrences =
            'Brazil'.allMatches(result).length;
        expect(brazilOccurrences, equals(1));
      });

      test('includes both interactions and preferences when both present', () {
        final result = AIVenueFallbackHelpers.summarizeBehaviorData({
          'gameInteractions': [
            {'interactionType': 'view'},
          ],
          'teamPreferences': [
            {'action': 'add', 'teamName': 'Brazil'},
          ],
        });
        expect(result, contains('1 views'));
        expect(result, contains('Brazil'));
      });

      test('handles empty game interactions list', () {
        final result = AIVenueFallbackHelpers.summarizeBehaviorData({
          'gameInteractions': [],
        });
        // Empty list, so nothing is written for game interactions
        expect(result, isEmpty);
      });

      test('handles empty team preferences list', () {
        final result = AIVenueFallbackHelpers.summarizeBehaviorData({
          'teamPreferences': [],
        });
        expect(result, isEmpty);
      });
    });

    group('summarizeUserInsights', () {
      test('returns summary with top teams and engagement', () {
        final result = AIVenueFallbackHelpers.summarizeUserInsights({
          'teamAffinityScores': {
            'Brazil': 0.9,
            'France': 0.7,
            'Germany': 0.5,
            'Spain': 0.3,
          },
          'engagementScore': 0.7,
        });
        expect(result, contains('Brazil'));
        expect(result, contains('France'));
        expect(result, contains('Germany'));
        expect(result, contains('0.7'));
      });

      test('limits to top 3 teams', () {
        final result = AIVenueFallbackHelpers.summarizeUserInsights({
          'teamAffinityScores': {
            'Team1': 0.9,
            'Team2': 0.8,
            'Team3': 0.7,
            'Team4': 0.6,
            'Team5': 0.5,
          },
          'engagementScore': 0.5,
        });
        // Should only contain first 3 teams (take(3))
        expect(result, contains('Team1'));
        expect(result, contains('Team2'));
        expect(result, contains('Team3'));
        expect(result, isNot(contains('Team4')));
        expect(result, isNot(contains('Team5')));
      });

      test('handles empty team scores', () {
        final result = AIVenueFallbackHelpers.summarizeUserInsights({
          'teamAffinityScores': {},
          'engagementScore': 0.0,
        });
        expect(result, contains('Top teams:'));
        expect(result, contains('0.0'));
      });

      test('handles missing fields', () {
        final result = AIVenueFallbackHelpers.summarizeUserInsights({});
        expect(result, contains('Top teams:'));
        expect(result, contains('Engagement:'));
      });
    });

    group('summarizeUpcomingGames', () {
      test('formats games correctly', () {
        final result = AIVenueFallbackHelpers.summarizeUpcomingGames([
          {
            'HomeTeam': 'Brazil',
            'AwayTeam': 'France',
            'DateTime': '2026-06-15',
          },
        ]);
        expect(result, equals('France @ Brazil (2026-06-15)'));
      });

      test('limits output to specified limit', () {
        final games = List.generate(
          10,
          (i) => <String, dynamic>{
            'HomeTeam': 'Home$i',
            'AwayTeam': 'Away$i',
            'DateTime': '2026-06-${15 + i}',
          },
        );
        final result =
            AIVenueFallbackHelpers.summarizeUpcomingGames(games, limit: 3);
        final lines = result.split('\n');
        expect(lines, hasLength(3));
      });

      test('uses default limit of 5', () {
        final games = List.generate(
          10,
          (i) => <String, dynamic>{
            'HomeTeam': 'Home$i',
            'AwayTeam': 'Away$i',
            'DateTime': '2026-06-${15 + i}',
          },
        );
        final result = AIVenueFallbackHelpers.summarizeUpcomingGames(games);
        final lines = result.split('\n');
        expect(lines, hasLength(5));
      });

      test('shows TBD for missing DateTime', () {
        final result = AIVenueFallbackHelpers.summarizeUpcomingGames([
          {
            'HomeTeam': 'Brazil',
            'AwayTeam': 'France',
          },
        ]);
        expect(result, contains('TBD'));
      });

      test('returns empty string for empty list', () {
        final result = AIVenueFallbackHelpers.summarizeUpcomingGames([]);
        expect(result, isEmpty);
      });
    });

    group('summarizeBehaviorForVenues', () {
      test('returns empty string when no behavior data', () {
        final result =
            AIVenueFallbackHelpers.summarizeBehaviorForVenues({});
        expect(result, isEmpty);
      });

      test('includes venue type preferences above 0.6', () {
        final result =
            AIVenueFallbackHelpers.summarizeBehaviorForVenues({
          'venue_type_preferences': {
            'sports_bar': 0.9,
            'restaurant': 0.7,
            'cafe': 0.4,
          },
        });
        expect(result, contains('sports_bar'));
        expect(result, contains('restaurant'));
        expect(result, isNot(contains('cafe')));
      });

      test('excludes venue types at or below 0.6 threshold', () {
        final result =
            AIVenueFallbackHelpers.summarizeBehaviorForVenues({
          'venue_type_preferences': {
            'sports_bar': 0.6,
            'restaurant': 0.5,
          },
        });
        // 0.6 is not > 0.6, so neither should appear
        expect(result, isNot(contains('sports_bar')));
        expect(result, isNot(contains('restaurant')));
      });

      test('limits venue types to top 3', () {
        final result =
            AIVenueFallbackHelpers.summarizeBehaviorForVenues({
          'venue_type_preferences': {
            'type1': 0.9,
            'type2': 0.8,
            'type3': 0.7,
            'type4': 0.65,
          },
        });
        expect(result, contains('type1'));
        expect(result, contains('type2'));
        expect(result, contains('type3'));
        // type4 is above 0.6 threshold but should be cut by take(3)
        expect(result, isNot(contains('type4')));
      });

      test('includes distance preferences', () {
        final result =
            AIVenueFallbackHelpers.summarizeBehaviorForVenues({
          'distance_preferences': {
            'preferred_max_distance': 10.0,
          },
        });
        expect(result, contains('10.0'));
        expect(result, contains('km'));
      });

      test('uses default distance of 5.0 when not specified', () {
        final result =
            AIVenueFallbackHelpers.summarizeBehaviorForVenues({
          'distance_preferences': <String, dynamic>{},
        });
        expect(result, contains('5.0'));
      });

      test('includes price preferences', () {
        final result =
            AIVenueFallbackHelpers.summarizeBehaviorForVenues({
          'price_preferences': {
            'preferred_price_level': 3,
          },
        });
        expect(result, contains('level 3'));
      });

      test('uses default price level 2 when not specified', () {
        final result =
            AIVenueFallbackHelpers.summarizeBehaviorForVenues({
          'price_preferences': <String, dynamic>{},
        });
        expect(result, contains('level 2'));
      });

      test('includes all sections when all data present', () {
        final result =
            AIVenueFallbackHelpers.summarizeBehaviorForVenues({
          'venue_type_preferences': {'sports_bar': 0.9},
          'distance_preferences': {'preferred_max_distance': 8.0},
          'price_preferences': {'preferred_price_level': 1},
        });
        expect(result, contains('Preferred venue types'));
        expect(result, contains('Preferred distance'));
        expect(result, contains('Price preference'));
      });
    });

    group('generateFallbackVenueRecommendations', () {
      test('returns valid JSON string', () {
        final result =
            AIVenueFallbackHelpers.generateFallbackVenueRecommendations(
          [],
          {'context': 'general'},
        );
        expect(() => json.decode(result), returnsNormally);
      });

      test('returns analysis for empty venue list', () {
        final result =
            AIVenueFallbackHelpers.generateFallbackVenueRecommendations(
          [],
          {'context': 'general'},
        );
        final parsed = json.decode(result) as Map<String, dynamic>;
        expect(parsed['recommendations'], isEmpty);
        expect(parsed['analysis'], contains('No suitable venues'));
      });

      test('returns correct context in response', () {
        final result =
            AIVenueFallbackHelpers.generateFallbackVenueRecommendations(
          [],
          {'context': 'pre_game'},
        );
        final parsed = json.decode(result) as Map<String, dynamic>;
        expect(parsed['context'], equals('pre_game'));
      });

      test('limits recommendations to 8', () {
        // Create mock venue objects
        final venues = List.generate(
          15,
          (i) => _MockVenue(
            name: 'Venue $i',
            rating: 4.0,
            distance: 1.0,
            types: ['restaurant'],
            priceLevel: 2,
          ),
        );

        final result =
            AIVenueFallbackHelpers.generateFallbackVenueRecommendations(
          venues,
          {'context': 'general'},
        );
        final parsed = json.decode(result) as Map<String, dynamic>;
        final recommendations = parsed['recommendations'] as List;
        expect(recommendations.length, lessThanOrEqualTo(8));
      });

      test('scores are clamped between 0 and 1', () {
        final venues = [
          _MockVenue(
            name: 'Top Venue',
            rating: 5.0,
            distance: 0.5,
            types: ['sports_bar', 'restaurant', 'bar'],
            priceLevel: 2,
          ),
        ];

        final result =
            AIVenueFallbackHelpers.generateFallbackVenueRecommendations(
          venues,
          {'context': 'general'},
        );
        final parsed = json.decode(result) as Map<String, dynamic>;
        final recommendations = parsed['recommendations'] as List;
        for (final rec in recommendations) {
          final score = (rec as Map<String, dynamic>)['score'] as double;
          expect(score, greaterThanOrEqualTo(0.0));
          expect(score, lessThanOrEqualTo(1.0));
        }
      });

      test('pre_game context boosts restaurant scores', () {
        final venues = [
          _MockVenue(
            name: 'Restaurant',
            rating: 4.0,
            distance: 2.0,
            types: ['restaurant'],
            priceLevel: 2,
          ),
          _MockVenue(
            name: 'Night Club',
            rating: 4.0,
            distance: 2.0,
            types: ['night_club'],
            priceLevel: 2,
          ),
        ];

        final result =
            AIVenueFallbackHelpers.generateFallbackVenueRecommendations(
          venues,
          {'context': 'pre_game'},
        );
        final parsed = json.decode(result) as Map<String, dynamic>;
        final recommendations = parsed['recommendations'] as List;

        final restaurantScore = (recommendations
                .firstWhere((r) => (r as Map)['name'] == 'Restaurant')
            as Map)['score'] as double;
        final clubScore = (recommendations
                .firstWhere((r) => (r as Map)['name'] == 'Night Club')
            as Map)['score'] as double;

        expect(restaurantScore, greaterThan(clubScore));
      });

      test('post_game context boosts bar and nightclub scores', () {
        final venues = [
          _MockVenue(
            name: 'The Bar',
            rating: 4.0,
            distance: 2.0,
            types: ['bar'],
            priceLevel: 2,
          ),
          _MockVenue(
            name: 'Coffee Shop',
            rating: 4.0,
            distance: 2.0,
            types: ['cafe'],
            priceLevel: 2,
          ),
        ];

        final result =
            AIVenueFallbackHelpers.generateFallbackVenueRecommendations(
          venues,
          {'context': 'post_game'},
        );
        final parsed = json.decode(result) as Map<String, dynamic>;
        final recommendations = parsed['recommendations'] as List;

        final barScore = (recommendations
                .firstWhere((r) => (r as Map)['name'] == 'The Bar')
            as Map)['score'] as double;
        final cafeScore = (recommendations
                .firstWhere((r) => (r as Map)['name'] == 'Coffee Shop')
            as Map)['score'] as double;

        expect(barScore, greaterThan(cafeScore));
      });

      test('nearby venues score higher than distant ones', () {
        final venues = [
          _MockVenue(
            name: 'Near Venue',
            rating: 4.0,
            distance: 0.5,
            types: ['restaurant'],
            priceLevel: 2,
          ),
          _MockVenue(
            name: 'Far Venue',
            rating: 4.0,
            distance: 15.0,
            types: ['restaurant'],
            priceLevel: 2,
          ),
        ];

        final result =
            AIVenueFallbackHelpers.generateFallbackVenueRecommendations(
          venues,
          {'context': 'general'},
        );
        final parsed = json.decode(result) as Map<String, dynamic>;
        final recommendations = parsed['recommendations'] as List;

        final nearScore = (recommendations
                .firstWhere((r) => (r as Map)['name'] == 'Near Venue')
            as Map)['score'] as double;
        final farScore = (recommendations
                .firstWhere((r) => (r as Map)['name'] == 'Far Venue')
            as Map)['score'] as double;

        expect(nearScore, greaterThan(farScore));
      });

      test('higher rated venues score higher', () {
        final venues = [
          _MockVenue(
            name: 'Highly Rated',
            rating: 4.8,
            distance: 2.0,
            types: ['restaurant'],
            priceLevel: 2,
          ),
          _MockVenue(
            name: 'Low Rated',
            rating: 2.5,
            distance: 2.0,
            types: ['restaurant'],
            priceLevel: 2,
          ),
        ];

        final result =
            AIVenueFallbackHelpers.generateFallbackVenueRecommendations(
          venues,
          {'context': 'general'},
        );
        final parsed = json.decode(result) as Map<String, dynamic>;
        final recommendations = parsed['recommendations'] as List;

        final highScore = (recommendations
                .firstWhere((r) => (r as Map)['name'] == 'Highly Rated')
            as Map)['score'] as double;
        final lowScore = (recommendations
                .firstWhere((r) => (r as Map)['name'] == 'Low Rated')
            as Map)['score'] as double;

        expect(highScore, greaterThan(lowScore));
      });

      test('adds Top Rated tag for venues rated 4.5+', () {
        final venues = [
          _MockVenue(
            name: 'Top Place',
            rating: 4.7,
            distance: 2.0,
            types: ['restaurant'],
            priceLevel: 2,
          ),
        ];

        final result =
            AIVenueFallbackHelpers.generateFallbackVenueRecommendations(
          venues,
          {'context': 'general'},
        );
        final parsed = json.decode(result) as Map<String, dynamic>;
        final recommendations = parsed['recommendations'] as List;
        final tags = (recommendations.first as Map)['tags'] as List;

        expect(tags, contains('Top Rated'));
      });

      test('adds Popular tag for venues rated 4.0-4.4', () {
        final venues = [
          _MockVenue(
            name: 'Good Place',
            rating: 4.2,
            distance: 2.0,
            types: ['restaurant'],
            priceLevel: 2,
          ),
        ];

        final result =
            AIVenueFallbackHelpers.generateFallbackVenueRecommendations(
          venues,
          {'context': 'general'},
        );
        final parsed = json.decode(result) as Map<String, dynamic>;
        final recommendations = parsed['recommendations'] as List;
        final tags = (recommendations.first as Map)['tags'] as List;

        expect(tags, contains('Popular'));
      });

      test('adds Nearby tag for venues within 1km', () {
        final venues = [
          _MockVenue(
            name: 'Close Spot',
            rating: 4.0,
            distance: 0.8,
            types: ['restaurant'],
            priceLevel: 2,
          ),
        ];

        final result =
            AIVenueFallbackHelpers.generateFallbackVenueRecommendations(
          venues,
          {'context': 'general'},
        );
        final parsed = json.decode(result) as Map<String, dynamic>;
        final recommendations = parsed['recommendations'] as List;
        final tags = (recommendations.first as Map)['tags'] as List;

        expect(tags, contains('Nearby'));
      });

      test('adds Affordable tag for budget venues', () {
        final venues = [
          _MockVenue(
            name: 'Budget Spot',
            rating: 4.0,
            distance: 2.0,
            types: ['restaurant'],
            priceLevel: 1,
          ),
        ];

        final result =
            AIVenueFallbackHelpers.generateFallbackVenueRecommendations(
          venues,
          {'context': 'general'},
        );
        final parsed = json.decode(result) as Map<String, dynamic>;
        final recommendations = parsed['recommendations'] as List;
        final tags = (recommendations.first as Map)['tags'] as List;

        expect(tags, contains('Affordable'));
      });

      test('adds Upscale tag for premium venues', () {
        final venues = [
          _MockVenue(
            name: 'Luxury Spot',
            rating: 4.0,
            distance: 2.0,
            types: ['restaurant'],
            priceLevel: 4,
          ),
        ];

        final result =
            AIVenueFallbackHelpers.generateFallbackVenueRecommendations(
          venues,
          {'context': 'general'},
        );
        final parsed = json.decode(result) as Map<String, dynamic>;
        final recommendations = parsed['recommendations'] as List;
        final tags = (recommendations.first as Map)['tags'] as List;

        expect(tags, contains('Upscale'));
      });

      test('analysis includes venue count and scores', () {
        final venues = [
          _MockVenue(
            name: 'Test Venue',
            rating: 4.5,
            distance: 1.0,
            types: ['sports_bar'],
            priceLevel: 2,
          ),
        ];

        final result =
            AIVenueFallbackHelpers.generateFallbackVenueRecommendations(
          venues,
          {'context': 'general'},
        );
        final parsed = json.decode(result) as Map<String, dynamic>;
        final analysis = parsed['analysis'] as String;
        expect(analysis, contains('Found'));
        expect(analysis, contains('venues'));
      });

      test('pre_game analysis references pre-game context', () {
        final venues = [
          _MockVenue(
            name: 'Test Venue',
            rating: 4.0,
            distance: 1.0,
            types: ['restaurant'],
            priceLevel: 2,
          ),
        ];

        final result =
            AIVenueFallbackHelpers.generateFallbackVenueRecommendations(
          venues,
          {'context': 'pre_game'},
        );
        final parsed = json.decode(result) as Map<String, dynamic>;
        final analysis = parsed['analysis'] as String;
        expect(analysis, contains('pre-game'));
      });

      test('post_game analysis references post-game context', () {
        final venues = [
          _MockVenue(
            name: 'Test Venue',
            rating: 4.0,
            distance: 1.0,
            types: ['bar'],
            priceLevel: 2,
          ),
        ];

        final result =
            AIVenueFallbackHelpers.generateFallbackVenueRecommendations(
          venues,
          {'context': 'post_game'},
        );
        final parsed = json.decode(result) as Map<String, dynamic>;
        final analysis = parsed['analysis'] as String;
        expect(analysis, contains('post-game'));
      });

      test('recommendations are sorted by score descending', () {
        final venues = [
          _MockVenue(
            name: 'Low Score',
            rating: 2.5,
            distance: 15.0,
            types: ['cafe'],
            priceLevel: 3,
          ),
          _MockVenue(
            name: 'High Score',
            rating: 4.9,
            distance: 0.5,
            types: ['sports_bar', 'restaurant'],
            priceLevel: 2,
          ),
        ];

        final result =
            AIVenueFallbackHelpers.generateFallbackVenueRecommendations(
          venues,
          {'context': 'general'},
        );
        final parsed = json.decode(result) as Map<String, dynamic>;
        final recommendations = parsed['recommendations'] as List;

        expect(recommendations.length, equals(2));
        final firstScore =
            (recommendations[0] as Map<String, dynamic>)['score'] as double;
        final secondScore =
            (recommendations[1] as Map<String, dynamic>)['score'] as double;
        expect(firstScore, greaterThanOrEqualTo(secondScore));
      });

      test('handles null venue name gracefully', () {
        final venues = [
          _MockVenue(
            name: null,
            rating: 4.0,
            distance: 1.0,
            types: ['restaurant'],
            priceLevel: 2,
          ),
        ];

        final result =
            AIVenueFallbackHelpers.generateFallbackVenueRecommendations(
          venues,
          {'context': 'general'},
        );
        final parsed = json.decode(result) as Map<String, dynamic>;
        final recommendations = parsed['recommendations'] as List;
        expect(
          (recommendations.first as Map)['name'],
          equals('Unknown Venue'),
        );
      });

      test('user behavior preferences boost matching venues', () {
        final venues = [
          _MockVenue(
            name: 'Preferred Type',
            rating: 3.5,
            distance: 2.0,
            types: ['sports_bar'],
            priceLevel: 2,
          ),
          _MockVenue(
            name: 'Non Preferred',
            rating: 3.5,
            distance: 2.0,
            types: ['cafe'],
            priceLevel: 2,
          ),
        ];

        final result =
            AIVenueFallbackHelpers.generateFallbackVenueRecommendations(
          venues,
          {
            'context': 'general',
            'user_behavior': {
              'venue_type_preferences': {'sports_bar': 0.9},
            },
          },
        );
        final parsed = json.decode(result) as Map<String, dynamic>;
        final recommendations = parsed['recommendations'] as List;

        final prefScore = (recommendations
                .firstWhere((r) => (r as Map)['name'] == 'Preferred Type')
            as Map)['score'] as double;
        final nonPrefScore = (recommendations
                .firstWhere((r) => (r as Map)['name'] == 'Non Preferred')
            as Map)['score'] as double;

        expect(prefScore, greaterThan(nonPrefScore));
      });
    });
  });
}

/// Mock venue object that mimics the dynamic venue interface used by the
/// fallback helpers. The source code accesses properties via dynamic dispatch:
/// v.name, v.rating, v.distance, v.types, v.priceLevel
class _MockVenue {
  final String? name;
  final double? rating;
  final double? distance;
  final List<String> types;
  final int? priceLevel;

  _MockVenue({
    this.name,
    this.rating,
    this.distance,
    this.types = const [],
    this.priceLevel,
  });
}

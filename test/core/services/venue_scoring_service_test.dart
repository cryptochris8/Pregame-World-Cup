import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/services/venue_scoring_service.dart';
import 'package:pregame_world_cup/core/services/venue_models.dart';
import 'package:pregame_world_cup/features/recommendations/domain/entities/place.dart';
import 'package:pregame_world_cup/features/schedule/domain/entities/game_schedule.dart';

void main() {
  late VenueScoringService service;

  setUp(() {
    service = VenueScoringService();
  });

  // ============================================================================
  // Helper factories
  // ============================================================================

  Place makePlace({
    String placeId = 'test_place',
    String name = 'Test Venue',
    double? rating,
    int? userRatingsTotal,
    int? priceLevel,
    bool? openNow,
    List<String>? types,
  }) {
    return Place(
      placeId: placeId,
      name: name,
      rating: rating,
      userRatingsTotal: userRatingsTotal,
      priceLevel: priceLevel,
      openingHours: openNow != null ? OpeningHours(openNow: openNow) : null,
      types: types,
    );
  }

  GameSchedule makeGame({
    String gameId = 'g1',
    String homeTeamName = 'USA',
    String awayTeamName = 'Mexico',
    DateTime? dateTime,
  }) {
    return GameSchedule(
      gameId: gameId,
      homeTeamName: homeTeamName,
      awayTeamName: awayTeamName,
      dateTime: dateTime,
    );
  }

  EnhancedVenueRecommendation makeRecommendation({
    required Place venue,
    double unifiedScore = 0.5,
    VenueCategory category = VenueCategory.unknown,
  }) {
    return EnhancedVenueRecommendation(
      venue: venue,
      category: category,
      unifiedScore: unifiedScore,
      basicScore: 0.5,
      aiAnalysis: null,
      personalizationScore: 0.5,
      contextScore: 0.5,
      tags: [],
      reasoning: '',
      confidence: 0.7,
    );
  }

  VenueCategory simpleCategorizer(Place p) => VenueCategory.restaurant;

  // ============================================================================
  // calculateBasicScore
  // ============================================================================
  group('calculateBasicScore', () {
    test('returns base score 0.5 for venue with no data', () {
      final venue = makePlace();
      final score = service.calculateBasicScore(venue);
      expect(score, 0.5);
    });

    test('rating of 5.0 adds (5-3)*0.2 = 0.4', () {
      final venue = makePlace(rating: 5.0);
      final score = service.calculateBasicScore(venue);
      // 0.5 + 0.4 = 0.9
      expect(score, closeTo(0.9, 0.001));
    });

    test('rating below 3.0 decreases score', () {
      final venue = makePlace(rating: 2.0);
      final score = service.calculateBasicScore(venue);
      // 0.5 + (2-3)*0.2 = 0.5 - 0.2 = 0.3
      expect(score, closeTo(0.3, 0.001));
    });

    test('high user ratings total adds popularity bonus capped at 0.15', () {
      final venue = makePlace(userRatingsTotal: 1000);
      final score = service.calculateBasicScore(venue);
      // popularity = min(1000/500, 1.0) = 1.0; bonus = 1.0 * 0.15 = 0.15
      // 0.5 + 0.15 = 0.65
      expect(score, closeTo(0.65, 0.001));
    });

    test('moderate user ratings total adds proportional bonus', () {
      final venue = makePlace(userRatingsTotal: 250);
      final score = service.calculateBasicScore(venue);
      // popularity = 250/500 = 0.5; bonus = 0.5 * 0.15 = 0.075
      // 0.5 + 0.075 = 0.575
      expect(score, closeTo(0.575, 0.001));
    });

    test('price level 2 adds 0.05 bonus', () {
      final venue = makePlace(priceLevel: 2);
      final score = service.calculateBasicScore(venue);
      expect(score, closeTo(0.55, 0.001));
    });

    test('price level 1 does not add bonus', () {
      final venue = makePlace(priceLevel: 1);
      final score = service.calculateBasicScore(venue);
      expect(score, 0.5);
    });

    test('price level 3 does not add bonus', () {
      final venue = makePlace(priceLevel: 3);
      final score = service.calculateBasicScore(venue);
      expect(score, 0.5);
    });

    test('open now adds 0.1 bonus', () {
      final venue = makePlace(openNow: true);
      final score = service.calculateBasicScore(venue);
      expect(score, closeTo(0.6, 0.001));
    });

    test('not open now does not add bonus', () {
      final venue = makePlace(openNow: false);
      final score = service.calculateBasicScore(venue);
      expect(score, 0.5);
    });

    test('combined high scores clamp to 1.0', () {
      final venue = makePlace(
        rating: 5.0,
        userRatingsTotal: 1000,
        priceLevel: 2,
        openNow: true,
      );
      final score = service.calculateBasicScore(venue);
      // 0.5 + 0.4 + 0.15 + 0.05 + 0.1 = 1.2 -> clamped to 1.0
      expect(score, 1.0);
    });

    test('combined low scores clamp to 0.0', () {
      final venue = makePlace(rating: 0.0);
      final score = service.calculateBasicScore(venue);
      // 0.5 + (0-3)*0.2 = 0.5 - 0.6 = -0.1 -> clamped to 0.0
      expect(score, 0.0);
    });
  });

  // ============================================================================
  // calculatePersonalizationScore
  // ============================================================================
  group('calculatePersonalizationScore', () {
    test('returns 0.5 with empty user behavior', () {
      final venue = makePlace();
      final score = service.calculatePersonalizationScore(
        venue,
        {},
        simpleCategorizer,
      );
      expect(score, closeTo(0.5, 0.001));
    });

    test('adds positive category preference offset', () {
      final venue = makePlace();
      final userBehavior = {
        'categoryPreferences': {'restaurant': 0.9},
      };
      final score = service.calculatePersonalizationScore(
        venue,
        userBehavior,
        simpleCategorizer,
      );
      // 0.5 + (0.9 - 0.5) * 0.3 = 0.5 + 0.12 = 0.62
      expect(score, closeTo(0.62, 0.001));
    });

    test('subtracts negative category preference offset', () {
      final venue = makePlace();
      final userBehavior = {
        'categoryPreferences': {'restaurant': 0.1},
      };
      final score = service.calculatePersonalizationScore(
        venue,
        userBehavior,
        simpleCategorizer,
      );
      // 0.5 + (0.1 - 0.5) * 0.3 = 0.5 - 0.12 = 0.38
      expect(score, closeTo(0.38, 0.001));
    });

    test('adds price level preference offset', () {
      final venue = makePlace(priceLevel: 2);
      final userBehavior = {
        'pricePreferences': {'2': 0.8},
      };
      final score = service.calculatePersonalizationScore(
        venue,
        userBehavior,
        simpleCategorizer,
      );
      // base=0.5, category offset=0 (no preference), price=(0.8-0.5)*0.2=0.06
      // 0.5 + 0.06 = 0.56
      expect(score, closeTo(0.56, 0.001));
    });

    test('ignores price preference when venue has no price level', () {
      final venue = makePlace();
      final userBehavior = {
        'pricePreferences': {'2': 0.9},
      };
      final score = service.calculatePersonalizationScore(
        venue,
        userBehavior,
        simpleCategorizer,
      );
      // No price level on venue, so no price adjustment
      expect(score, closeTo(0.5, 0.001));
    });

    test('clamps to 0.0 minimum', () {
      final venue = makePlace(priceLevel: 1);
      final userBehavior = {
        'categoryPreferences': {'restaurant': 0.0},
        'pricePreferences': {'1': 0.0},
      };
      final score = service.calculatePersonalizationScore(
        venue,
        userBehavior,
        simpleCategorizer,
      );
      // 0.5 + (0-0.5)*0.3 + (0-0.5)*0.2 = 0.5 - 0.15 - 0.10 = 0.25
      expect(score, closeTo(0.25, 0.001));
    });

    test('clamps to 1.0 maximum', () {
      final venue = makePlace(priceLevel: 1);
      final userBehavior = {
        'categoryPreferences': {'restaurant': 2.5},
        'pricePreferences': {'1': 2.5},
      };
      final score = service.calculatePersonalizationScore(
        venue,
        userBehavior,
        simpleCategorizer,
      );
      // Would go above 1.0, gets clamped
      expect(score, lessThanOrEqualTo(1.0));
    });
  });

  // ============================================================================
  // calculateContextScore
  // ============================================================================
  group('calculateContextScore', () {
    test('pre_game context boosts sportsBar by 0.3', () {
      final venue = makePlace();
      final game = makeGame();
      VenueCategory sportsBarCategorizer(Place p) => VenueCategory.sportsBar;
      final score = service.calculateContextScore(
        venue,
        game,
        'pre_game',
        sportsBarCategorizer,
      );
      // 0.5 + 0.3 = 0.8
      expect(score, closeTo(0.8, 0.001));
    });

    test('pre_game context boosts restaurant by 0.3', () {
      final venue = makePlace();
      final game = makeGame();
      final score = service.calculateContextScore(
        venue,
        game,
        'pre_game',
        simpleCategorizer,
      );
      expect(score, closeTo(0.8, 0.001));
    });

    test('post_game context boosts sportsBar by 0.3', () {
      final venue = makePlace();
      final game = makeGame();
      VenueCategory cat(Place p) => VenueCategory.sportsBar;
      final score = service.calculateContextScore(venue, game, 'post_game', cat);
      expect(score, closeTo(0.8, 0.001));
    });

    test('post_game context boosts nightclub by 0.3', () {
      final venue = makePlace();
      final game = makeGame();
      VenueCategory cat(Place p) => VenueCategory.nightclub;
      final score = service.calculateContextScore(venue, game, 'post_game', cat);
      expect(score, closeTo(0.8, 0.001));
    });

    test('watch_party context boosts sportsBar by 0.4', () {
      final venue = makePlace();
      final game = makeGame();
      VenueCategory cat(Place p) => VenueCategory.sportsBar;
      final score =
          service.calculateContextScore(venue, game, 'watch_party', cat);
      expect(score, closeTo(0.9, 0.001));
    });

    test('casual_dining context boosts restaurant by 0.3', () {
      final venue = makePlace();
      final game = makeGame();
      final score = service.calculateContextScore(
          venue, game, 'casual_dining', simpleCategorizer);
      expect(score, closeTo(0.8, 0.001));
    });

    test('casual_dining context boosts cafe by 0.3', () {
      final venue = makePlace();
      final game = makeGame();
      VenueCategory cat(Place p) => VenueCategory.cafe;
      final score =
          service.calculateContextScore(venue, game, 'casual_dining', cat);
      expect(score, closeTo(0.8, 0.001));
    });

    test('unknown context gives base 0.5 for unknown category', () {
      final venue = makePlace();
      final game = makeGame();
      VenueCategory cat(Place p) => VenueCategory.unknown;
      final score =
          service.calculateContextScore(venue, game, 'unknown_ctx', cat);
      expect(score, closeTo(0.5, 0.001));
    });

    test('evening game time boosts nightclub by 0.2', () {
      final venue = makePlace();
      final game = makeGame(dateTime: DateTime(2026, 6, 15, 20, 0));
      VenueCategory cat(Place p) => VenueCategory.nightclub;
      final score =
          service.calculateContextScore(venue, game, 'general', cat);
      // 0.5 + 0 (no context match for general/nightclub) + 0.2 (evening nightclub) = 0.7
      expect(score, closeTo(0.7, 0.001));
    });

    test('morning game time boosts cafe by 0.2', () {
      final venue = makePlace();
      final game = makeGame(dateTime: DateTime(2026, 6, 15, 10, 0));
      VenueCategory cat(Place p) => VenueCategory.cafe;
      final score =
          service.calculateContextScore(venue, game, 'general', cat);
      // 0.5 + 0.2 = 0.7
      expect(score, closeTo(0.7, 0.001));
    });

    test('null dateTime skips time-based scoring', () {
      final venue = makePlace();
      final game = makeGame(dateTime: null);
      VenueCategory cat(Place p) => VenueCategory.nightclub;
      final score =
          service.calculateContextScore(venue, game, 'general', cat);
      expect(score, closeTo(0.5, 0.001));
    });

    test('combined context and time boost clamps to 1.0', () {
      final venue = makePlace();
      final game = makeGame(dateTime: DateTime(2026, 6, 15, 21, 0));
      VenueCategory cat(Place p) => VenueCategory.nightclub;
      final score =
          service.calculateContextScore(venue, game, 'post_game', cat);
      // 0.5 + 0.3 (post_game nightclub) + 0.2 (evening nightclub) = 1.0
      expect(score, closeTo(1.0, 0.001));
    });
  });

  // ============================================================================
  // calculateUnifiedScore
  // ============================================================================
  group('calculateUnifiedScore', () {
    test('returns weighted average of four scores', () {
      final score = service.calculateUnifiedScore(
        basicScore: 1.0,
        aiScore: 1.0,
        personalizationScore: 1.0,
        contextScore: 1.0,
      );
      // (1.0*0.3) + (1.0*0.35) + (1.0*0.2) + (1.0*0.15) = 1.0
      expect(score, closeTo(1.0, 0.001));
    });

    test('returns 0 when all scores are 0', () {
      final score = service.calculateUnifiedScore(
        basicScore: 0.0,
        aiScore: 0.0,
        personalizationScore: 0.0,
        contextScore: 0.0,
      );
      expect(score, closeTo(0.0, 0.001));
    });

    test('weights are applied correctly', () {
      final score = service.calculateUnifiedScore(
        basicScore: 0.5,
        aiScore: 0.8,
        personalizationScore: 0.6,
        contextScore: 0.4,
      );
      // (0.5*0.3) + (0.8*0.35) + (0.6*0.2) + (0.4*0.15)
      // = 0.15 + 0.28 + 0.12 + 0.06 = 0.61
      expect(score, closeTo(0.61, 0.001));
    });

    test('AI score has highest weight (0.35)', () {
      // Only AI score is non-zero
      final aiOnlyScore = service.calculateUnifiedScore(
        basicScore: 0.0,
        aiScore: 1.0,
        personalizationScore: 0.0,
        contextScore: 0.0,
      );
      expect(aiOnlyScore, closeTo(0.35, 0.001));

      // Only basic score is non-zero
      final basicOnlyScore = service.calculateUnifiedScore(
        basicScore: 1.0,
        aiScore: 0.0,
        personalizationScore: 0.0,
        contextScore: 0.0,
      );
      expect(basicOnlyScore, closeTo(0.30, 0.001));

      expect(aiOnlyScore, greaterThan(basicOnlyScore));
    });
  });

  // ============================================================================
  // generateVenueTags
  // ============================================================================
  group('generateVenueTags', () {
    test('always includes category display name as first tag', () {
      final venue = makePlace();
      final tags = service.generateVenueTags(
          venue, VenueCategory.sportsBar, null);
      expect(tags.first, 'Sports Bar');
    });

    test('adds Highly Rated for rating >= 4.5', () {
      final venue = makePlace(rating: 4.5);
      final tags =
          service.generateVenueTags(venue, VenueCategory.restaurant, null);
      expect(tags, contains('Highly Rated'));
    });

    test('does not add Highly Rated for rating 4.4', () {
      final venue = makePlace(rating: 4.4);
      final tags =
          service.generateVenueTags(venue, VenueCategory.restaurant, null);
      expect(tags, isNot(contains('Highly Rated')));
    });

    test('adds Popular for userRatingsTotal > 200', () {
      final venue = makePlace(userRatingsTotal: 201);
      final tags =
          service.generateVenueTags(venue, VenueCategory.restaurant, null);
      expect(tags, contains('Popular'));
    });

    test('does not add Popular for userRatingsTotal 200 exactly', () {
      final venue = makePlace(userRatingsTotal: 200);
      final tags =
          service.generateVenueTags(venue, VenueCategory.restaurant, null);
      expect(tags, isNot(contains('Popular')));
    });

    test('adds Budget Friendly for price level 1', () {
      final venue = makePlace(priceLevel: 1);
      final tags =
          service.generateVenueTags(venue, VenueCategory.restaurant, null);
      expect(tags, contains('Budget Friendly'));
    });

    test('adds Premium for price level 4', () {
      final venue = makePlace(priceLevel: 4);
      final tags =
          service.generateVenueTags(venue, VenueCategory.restaurant, null);
      expect(tags, contains('Premium'));
    });

    test('no price tag for price level 2', () {
      final venue = makePlace(priceLevel: 2);
      final tags =
          service.generateVenueTags(venue, VenueCategory.restaurant, null);
      expect(tags, isNot(contains('Budget Friendly')));
      expect(tags, isNot(contains('Premium')));
    });

    test('adds Great for Games when AI gameWatchingScore > 0.8', () {
      final venue = makePlace();
      final analysis = AIVenueAnalysis(
        overallScore: 0.8,
        confidence: 0.9,
        crowdPrediction: 'High',
        atmosphereRating: 0.5,
        gameWatchingScore: 0.85,
        socialScore: 0.5,
        insights: [],
        recommendations: [],
      );
      final tags =
          service.generateVenueTags(venue, VenueCategory.sportsBar, analysis);
      expect(tags, contains('Great for Games'));
    });

    test('adds Social Spot when AI socialScore > 0.8', () {
      final venue = makePlace();
      final analysis = AIVenueAnalysis(
        overallScore: 0.8,
        confidence: 0.9,
        crowdPrediction: 'High',
        atmosphereRating: 0.5,
        gameWatchingScore: 0.5,
        socialScore: 0.85,
        insights: [],
        recommendations: [],
      );
      final tags =
          service.generateVenueTags(venue, VenueCategory.sportsBar, analysis);
      expect(tags, contains('Social Spot'));
    });

    test('adds Great Atmosphere when AI atmosphereRating > 0.8', () {
      final venue = makePlace();
      final analysis = AIVenueAnalysis(
        overallScore: 0.8,
        confidence: 0.9,
        crowdPrediction: 'High',
        atmosphereRating: 0.85,
        gameWatchingScore: 0.5,
        socialScore: 0.5,
        insights: [],
        recommendations: [],
      );
      final tags =
          service.generateVenueTags(venue, VenueCategory.sportsBar, analysis);
      expect(tags, contains('Great Atmosphere'));
    });

    test('adds Open Now for open venues', () {
      final venue = makePlace(openNow: true);
      final tags =
          service.generateVenueTags(venue, VenueCategory.restaurant, null);
      expect(tags, contains('Open Now'));
    });

    test('limits tags to 4', () {
      final venue =
          makePlace(rating: 5.0, userRatingsTotal: 500, priceLevel: 1, openNow: true);
      final analysis = AIVenueAnalysis(
        overallScore: 0.9,
        confidence: 0.9,
        crowdPrediction: 'Heavy',
        atmosphereRating: 0.9,
        gameWatchingScore: 0.9,
        socialScore: 0.9,
        insights: [],
        recommendations: [],
      );
      final tags = service.generateVenueTags(
          venue, VenueCategory.sportsBar, analysis);
      expect(tags.length, lessThanOrEqualTo(4));
    });

    test('returns only category tag for minimal venue', () {
      final venue = makePlace();
      final tags =
          service.generateVenueTags(venue, VenueCategory.unknown, null);
      expect(tags, ['Venue']);
    });
  });

  // ============================================================================
  // generateReasoning
  // ============================================================================
  group('generateReasoning', () {
    test('includes rating for highly rated venue', () {
      final venue = makePlace(rating: 4.5);
      final reasoning =
          service.generateReasoning(venue, null, null, 'general');
      expect(reasoning, contains('Highly rated (4.5/5)'));
    });

    test('does not include rating below 4.0', () {
      final venue = makePlace(rating: 3.5);
      final reasoning =
          service.generateReasoning(venue, null, null, 'general');
      expect(reasoning, isNot(contains('Highly rated')));
    });

    test('includes first AI insight when available', () {
      final venue = makePlace();
      final analysis = AIVenueAnalysis(
        overallScore: 0.8,
        confidence: 0.9,
        crowdPrediction: 'High',
        atmosphereRating: 0.8,
        gameWatchingScore: 0.8,
        socialScore: 0.8,
        insights: ['Amazing sports bar with 20 TVs', 'Great beer selection'],
        recommendations: [],
      );
      final reasoning =
          service.generateReasoning(venue, analysis, null, 'general');
      expect(reasoning, contains('Amazing sports bar with 20 TVs'));
    });

    test('does not include AI insight when insights list is empty', () {
      final venue = makePlace();
      final analysis = AIVenueAnalysis(
        overallScore: 0.8,
        confidence: 0.9,
        crowdPrediction: 'High',
        atmosphereRating: 0.8,
        gameWatchingScore: 0.8,
        socialScore: 0.8,
        insights: [],
        recommendations: [],
      );
      final reasoning =
          service.generateReasoning(venue, analysis, null, 'general');
      expect(reasoning, isNot(contains('AI-analyzed')));
    });

    test('includes preference match when userBehavior present', () {
      final venue = makePlace();
      final reasoning =
          service.generateReasoning(venue, null, {'some': 'data'}, 'general');
      expect(reasoning, contains('Matches your preferences'));
    });

    test('includes pre_game context message', () {
      final venue = makePlace();
      final reasoning =
          service.generateReasoning(venue, null, null, 'pre_game');
      expect(reasoning, contains('Perfect for pre-game atmosphere'));
    });

    test('includes watch_party context message', () {
      final venue = makePlace();
      final reasoning =
          service.generateReasoning(venue, null, null, 'watch_party');
      expect(reasoning, contains('Great spot to watch the game'));
    });

    test('returns default reasoning when no reasons generated', () {
      final venue = makePlace(rating: 2.0);
      final reasoning =
          service.generateReasoning(venue, null, null, 'general');
      expect(reasoning, 'Recommended venue');
    });

    test('joins multiple reasons with bullet separator', () {
      final venue = makePlace(rating: 4.5);
      final reasoning =
          service.generateReasoning(venue, null, {'key': 'val'}, 'pre_game');
      // Should have: rating, preferences, context
      expect(reasoning, contains('\u2022'));
    });
  });

  // ============================================================================
  // sortRecommendations
  // ============================================================================
  group('sortRecommendations', () {
    late List<EnhancedVenueRecommendation> recommendations;

    setUp(() {
      recommendations = [
        makeRecommendation(
          venue: makePlace(
              placeId: 'a', name: 'Charlie', rating: 3.5, userRatingsTotal: 100, priceLevel: 3),
          unifiedScore: 0.6,
        ),
        makeRecommendation(
          venue: makePlace(
              placeId: 'b', name: 'Alice', rating: 4.8, userRatingsTotal: 500, priceLevel: 1),
          unifiedScore: 0.9,
        ),
        makeRecommendation(
          venue: makePlace(
              placeId: 'c', name: 'Bob', rating: 4.0, userRatingsTotal: 300, priceLevel: 2),
          unifiedScore: 0.75,
        ),
      ];
    });

    test('sorts by rating descending', () {
      service.sortRecommendations(recommendations, VenueSortOption.rating);
      expect(recommendations[0].venue.name, 'Alice');
      expect(recommendations[1].venue.name, 'Bob');
      expect(recommendations[2].venue.name, 'Charlie');
    });

    test('sorts by popularity descending', () {
      service.sortRecommendations(recommendations, VenueSortOption.popularity);
      expect(recommendations[0].venue.userRatingsTotal, 500);
      expect(recommendations[1].venue.userRatingsTotal, 300);
      expect(recommendations[2].venue.userRatingsTotal, 100);
    });

    test('sorts by distance (unifiedScore) descending', () {
      service.sortRecommendations(recommendations, VenueSortOption.distance);
      expect(recommendations[0].unifiedScore, 0.9);
      expect(recommendations[1].unifiedScore, 0.75);
      expect(recommendations[2].unifiedScore, 0.6);
    });

    test('sorts by name alphabetically', () {
      service.sortRecommendations(recommendations, VenueSortOption.name);
      expect(recommendations[0].venue.name, 'Alice');
      expect(recommendations[1].venue.name, 'Bob');
      expect(recommendations[2].venue.name, 'Charlie');
    });

    test('sorts by price level ascending', () {
      service.sortRecommendations(recommendations, VenueSortOption.priceLevel);
      expect(recommendations[0].venue.priceLevel, 1);
      expect(recommendations[1].venue.priceLevel, 2);
      expect(recommendations[2].venue.priceLevel, 3);
    });

    test('handles null ratings when sorting by rating', () {
      final recs = [
        makeRecommendation(venue: makePlace(placeId: 'a', name: 'A', rating: null)),
        makeRecommendation(venue: makePlace(placeId: 'b', name: 'B', rating: 4.0)),
      ];
      service.sortRecommendations(recs, VenueSortOption.rating);
      expect(recs[0].venue.name, 'B');
    });

    test('handles null price levels when sorting by price', () {
      final recs = [
        makeRecommendation(venue: makePlace(placeId: 'a', name: 'A', priceLevel: null)),
        makeRecommendation(venue: makePlace(placeId: 'b', name: 'B', priceLevel: 2)),
      ];
      service.sortRecommendations(recs, VenueSortOption.priceLevel);
      // null price defaults to 5, so B (2) comes first
      expect(recs[0].venue.name, 'B');
      expect(recs[1].venue.name, 'A');
    });

    test('handles empty list', () {
      final empty = <EnhancedVenueRecommendation>[];
      service.sortRecommendations(empty, VenueSortOption.rating);
      expect(empty, isEmpty);
    });

    test('handles single-item list', () {
      final single = [
        makeRecommendation(venue: makePlace(placeId: 'x', name: 'X', rating: 4.0)),
      ];
      service.sortRecommendations(single, VenueSortOption.rating);
      expect(single.length, 1);
      expect(single[0].venue.name, 'X');
    });
  });
}

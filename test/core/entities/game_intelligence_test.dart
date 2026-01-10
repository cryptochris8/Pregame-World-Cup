import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/entities/game_intelligence.dart';

void main() {
  group('GameIntelligence', () {
    VenueRecommendations createTestVenueRecommendations() {
      return VenueRecommendations(
        expectedTrafficIncrease: 0.35,
        staffingRecommendation: 'Add 2 bartenders',
        suggestedSpecials: ['Game Day Burger', 'Team Spirit Wings'],
        inventoryAdvice: 'Stock up on local craft beers',
        marketingOpportunity: 'Rivalry game - promote early arrival',
        revenueProjection: 15000.0,
      );
    }

    test('creates game intelligence with required fields', () {
      final now = DateTime.now();
      final venueRecs = createTestVenueRecommendations();

      final intelligence = GameIntelligence(
        gameId: 'game_1',
        homeTeam: 'Georgia',
        awayTeam: 'Alabama',
        homeTeamRank: 3,
        awayTeamRank: 1,
        crowdFactor: 0.95,
        isRivalryGame: true,
        hasChampionshipImplications: true,
        broadcastNetwork: 'CBS',
        expectedTvAudience: 15000000,
        keyStorylines: ['SEC Championship implications', 'Rivalry game'],
        teamStats: {'georgia': {}, 'alabama': {}},
        lastUpdated: now,
        confidenceScore: 0.85,
        venueRecommendations: venueRecs,
      );

      expect(intelligence.gameId, equals('game_1'));
      expect(intelligence.homeTeam, equals('Georgia'));
      expect(intelligence.awayTeam, equals('Alabama'));
      expect(intelligence.homeTeamRank, equals(3));
      expect(intelligence.awayTeamRank, equals(1));
      expect(intelligence.crowdFactor, equals(0.95));
      expect(intelligence.isRivalryGame, isTrue);
      expect(intelligence.hasChampionshipImplications, isTrue);
      expect(intelligence.broadcastNetwork, equals('CBS'));
      expect(intelligence.expectedTvAudience, equals(15000000));
      expect(intelligence.keyStorylines, hasLength(2));
      expect(intelligence.confidenceScore, equals(0.85));
    });

    test('creates game intelligence with null team ranks', () {
      final now = DateTime.now();
      final venueRecs = createTestVenueRecommendations();

      final intelligence = GameIntelligence(
        gameId: 'game_1',
        homeTeam: 'Vanderbilt',
        awayTeam: 'South Carolina',
        homeTeamRank: null,
        awayTeamRank: null,
        crowdFactor: 0.65,
        isRivalryGame: false,
        hasChampionshipImplications: false,
        broadcastNetwork: 'SEC Network',
        expectedTvAudience: 500000,
        keyStorylines: [],
        teamStats: {},
        lastUpdated: now,
        confidenceScore: 0.70,
        venueRecommendations: venueRecs,
      );

      expect(intelligence.homeTeamRank, isNull);
      expect(intelligence.awayTeamRank, isNull);
    });

    group('copyWith', () {
      test('copies with updated fields', () {
        final now = DateTime.now();
        final venueRecs = createTestVenueRecommendations();

        final original = GameIntelligence(
          gameId: 'game_1',
          homeTeam: 'Georgia',
          awayTeam: 'Florida',
          crowdFactor: 0.85,
          isRivalryGame: true,
          hasChampionshipImplications: false,
          broadcastNetwork: 'CBS',
          expectedTvAudience: 10000000,
          keyStorylines: ['World\'s Largest Outdoor Cocktail Party'],
          teamStats: {},
          lastUpdated: now,
          confidenceScore: 0.80,
          venueRecommendations: venueRecs,
        );

        final updated = original.copyWith(
          crowdFactor: 0.95,
          hasChampionshipImplications: true,
          confidenceScore: 0.90,
        );

        expect(updated.gameId, equals(original.gameId));
        expect(updated.homeTeam, equals(original.homeTeam));
        expect(updated.crowdFactor, equals(0.95));
        expect(updated.hasChampionshipImplications, isTrue);
        expect(updated.confidenceScore, equals(0.90));
        expect(updated.isRivalryGame, isTrue); // Unchanged
      });
    });

    group('JSON serialization', () {
      test('toJson serializes correctly', () {
        final now = DateTime(2024, 10, 15, 15, 30, 0);
        final venueRecs = VenueRecommendations(
          expectedTrafficIncrease: 0.40,
          staffingRecommendation: 'Full staff needed',
          suggestedSpecials: ['Game Day Special'],
          inventoryAdvice: 'Order extra kegs',
          marketingOpportunity: 'Big game promotion',
          revenueProjection: 20000.0,
        );

        final intelligence = GameIntelligence(
          gameId: 'game_1',
          homeTeam: 'LSU',
          awayTeam: 'Alabama',
          homeTeamRank: 5,
          awayTeamRank: 2,
          crowdFactor: 0.98,
          isRivalryGame: true,
          hasChampionshipImplications: true,
          broadcastNetwork: 'CBS',
          expectedTvAudience: 12000000,
          keyStorylines: ['Top 5 matchup', 'SEC West showdown'],
          teamStats: {'lsu': {'wins': 7}, 'alabama': {'wins': 8}},
          lastUpdated: now,
          confidenceScore: 0.88,
          venueRecommendations: venueRecs,
        );

        final json = intelligence.toJson();

        expect(json['gameId'], equals('game_1'));
        expect(json['homeTeam'], equals('LSU'));
        expect(json['awayTeam'], equals('Alabama'));
        expect(json['homeTeamRank'], equals(5));
        expect(json['awayTeamRank'], equals(2));
        expect(json['crowdFactor'], equals(0.98));
        expect(json['isRivalryGame'], isTrue);
        expect(json['hasChampionshipImplications'], isTrue);
        expect(json['broadcastNetwork'], equals('CBS'));
        expect(json['expectedTvAudience'], equals(12000000));
        expect(json['keyStorylines'], hasLength(2));
        expect(json['lastUpdated'], equals('2024-10-15T15:30:00.000'));
        expect(json['confidenceScore'], equals(0.88));
        expect(json['venueRecommendations'], isNotNull);
      });

      test('fromJson deserializes correctly', () {
        final json = {
          'gameId': 'game_1',
          'homeTeam': 'Tennessee',
          'awayTeam': 'Georgia',
          'homeTeamRank': 6,
          'awayTeamRank': 1,
          'crowdFactor': 0.92,
          'isRivalryGame': true,
          'hasChampionshipImplications': true,
          'broadcastNetwork': 'CBS',
          'expectedTvAudience': 11000000,
          'keyStorylines': ['Neyland Stadium blackout', 'SEC East title'],
          'teamStats': {'tennessee': {}, 'georgia': {}},
          'lastUpdated': '2024-11-18T19:00:00.000',
          'confidenceScore': 0.85,
          'venueRecommendations': {
            'expectedTrafficIncrease': 0.50,
            'staffingRecommendation': 'Maximum staffing',
            'suggestedSpecials': ['Rocky Top Wings'],
            'inventoryAdvice': 'Double beer order',
            'marketingOpportunity': 'Blackout game',
            'revenueProjection': 25000.0,
          },
        };

        final intelligence = GameIntelligence.fromJson(json);

        expect(intelligence.gameId, equals('game_1'));
        expect(intelligence.homeTeam, equals('Tennessee'));
        expect(intelligence.awayTeam, equals('Georgia'));
        expect(intelligence.homeTeamRank, equals(6));
        expect(intelligence.crowdFactor, equals(0.92));
        expect(intelligence.isRivalryGame, isTrue);
        expect(intelligence.keyStorylines, contains('Neyland Stadium blackout'));
        expect(intelligence.venueRecommendations.revenueProjection, equals(25000.0));
      });

      test('roundtrip serialization preserves data', () {
        final now = DateTime(2024, 10, 15, 15, 30, 0);
        final original = GameIntelligence(
          gameId: 'game_1',
          homeTeam: 'Auburn',
          awayTeam: 'Alabama',
          homeTeamRank: 15,
          awayTeamRank: 4,
          crowdFactor: 0.97,
          isRivalryGame: true,
          hasChampionshipImplications: false,
          broadcastNetwork: 'CBS',
          expectedTvAudience: 14000000,
          keyStorylines: ['Iron Bowl', 'Rivalry week'],
          teamStats: {},
          lastUpdated: now,
          confidenceScore: 0.82,
          venueRecommendations: createTestVenueRecommendations(),
        );

        final json = original.toJson();
        final restored = GameIntelligence.fromJson(json);

        expect(restored.gameId, equals(original.gameId));
        expect(restored.homeTeam, equals(original.homeTeam));
        expect(restored.awayTeam, equals(original.awayTeam));
        expect(restored.homeTeamRank, equals(original.homeTeamRank));
        expect(restored.crowdFactor, equals(original.crowdFactor));
        expect(restored.isRivalryGame, equals(original.isRivalryGame));
        expect(restored.keyStorylines.length, equals(original.keyStorylines.length));
      });
    });

    group('Equatable', () {
      test('two game intelligences with same props are equal', () {
        final now = DateTime(2024, 10, 15, 15, 30, 0);
        final venueRecs = createTestVenueRecommendations();

        final intel1 = GameIntelligence(
          gameId: 'game_1',
          homeTeam: 'Georgia',
          awayTeam: 'Florida',
          crowdFactor: 0.90,
          isRivalryGame: true,
          hasChampionshipImplications: false,
          broadcastNetwork: 'CBS',
          expectedTvAudience: 10000000,
          keyStorylines: ['Rivalry'],
          teamStats: {},
          lastUpdated: now,
          confidenceScore: 0.85,
          venueRecommendations: venueRecs,
        );

        final intel2 = GameIntelligence(
          gameId: 'game_1',
          homeTeam: 'Georgia',
          awayTeam: 'Florida',
          crowdFactor: 0.90,
          isRivalryGame: true,
          hasChampionshipImplications: false,
          broadcastNetwork: 'CBS',
          expectedTvAudience: 10000000,
          keyStorylines: ['Rivalry'],
          teamStats: {},
          lastUpdated: now,
          confidenceScore: 0.85,
          venueRecommendations: venueRecs,
        );

        expect(intel1, equals(intel2));
      });

      test('two game intelligences with different props are not equal', () {
        final now = DateTime.now();
        final venueRecs = createTestVenueRecommendations();

        final intel1 = GameIntelligence(
          gameId: 'game_1',
          homeTeam: 'Georgia',
          awayTeam: 'Florida',
          crowdFactor: 0.90,
          isRivalryGame: true,
          hasChampionshipImplications: false,
          broadcastNetwork: 'CBS',
          expectedTvAudience: 10000000,
          keyStorylines: [],
          teamStats: {},
          lastUpdated: now,
          confidenceScore: 0.85,
          venueRecommendations: venueRecs,
        );

        final intel2 = GameIntelligence(
          gameId: 'game_2',
          homeTeam: 'Georgia',
          awayTeam: 'Florida',
          crowdFactor: 0.90,
          isRivalryGame: true,
          hasChampionshipImplications: false,
          broadcastNetwork: 'CBS',
          expectedTvAudience: 10000000,
          keyStorylines: [],
          teamStats: {},
          lastUpdated: now,
          confidenceScore: 0.85,
          venueRecommendations: venueRecs,
        );

        expect(intel1, isNot(equals(intel2)));
      });
    });
  });

  group('VenueRecommendations', () {
    test('creates venue recommendations with required fields', () {
      final recs = VenueRecommendations(
        expectedTrafficIncrease: 0.35,
        staffingRecommendation: 'Add 2 servers',
        suggestedSpecials: ['Game Day Nachos', 'Half-price Wings'],
        inventoryAdvice: 'Extra draft beer needed',
        marketingOpportunity: 'Promote game day specials on social media',
        revenueProjection: 12000.0,
      );

      expect(recs.expectedTrafficIncrease, equals(0.35));
      expect(recs.staffingRecommendation, equals('Add 2 servers'));
      expect(recs.suggestedSpecials, hasLength(2));
      expect(recs.inventoryAdvice, contains('beer'));
      expect(recs.marketingOpportunity, contains('social media'));
      expect(recs.revenueProjection, equals(12000.0));
    });

    group('JSON serialization', () {
      test('toJson serializes correctly', () {
        final recs = VenueRecommendations(
          expectedTrafficIncrease: 0.45,
          staffingRecommendation: 'Full staff',
          suggestedSpecials: ['Touchdown Tacos'],
          inventoryAdvice: 'Stock local beers',
          marketingOpportunity: 'Rivalry week promotion',
          revenueProjection: 18000.0,
        );

        final json = recs.toJson();

        expect(json['expectedTrafficIncrease'], equals(0.45));
        expect(json['staffingRecommendation'], equals('Full staff'));
        expect(json['suggestedSpecials'], equals(['Touchdown Tacos']));
        expect(json['inventoryAdvice'], equals('Stock local beers'));
        expect(json['marketingOpportunity'], equals('Rivalry week promotion'));
        expect(json['revenueProjection'], equals(18000.0));
      });

      test('fromJson deserializes correctly', () {
        final json = {
          'expectedTrafficIncrease': 0.50,
          'staffingRecommendation': 'Maximum capacity staff',
          'suggestedSpecials': ['Championship Wings', 'Victory Shots'],
          'inventoryAdvice': 'Order 50% more inventory',
          'marketingOpportunity': 'Championship game watch party',
          'revenueProjection': 30000.0,
        };

        final recs = VenueRecommendations.fromJson(json);

        expect(recs.expectedTrafficIncrease, equals(0.50));
        expect(recs.staffingRecommendation, equals('Maximum capacity staff'));
        expect(recs.suggestedSpecials, hasLength(2));
        expect(recs.suggestedSpecials, contains('Victory Shots'));
        expect(recs.revenueProjection, equals(30000.0));
      });

      test('roundtrip serialization preserves data', () {
        final original = VenueRecommendations(
          expectedTrafficIncrease: 0.40,
          staffingRecommendation: 'Add kitchen staff',
          suggestedSpecials: ['Tailgate Platter'],
          inventoryAdvice: 'Prepare for high volume',
          marketingOpportunity: 'Game day promotion',
          revenueProjection: 22000.0,
        );

        final json = original.toJson();
        final restored = VenueRecommendations.fromJson(json);

        expect(restored.expectedTrafficIncrease, equals(original.expectedTrafficIncrease));
        expect(restored.staffingRecommendation, equals(original.staffingRecommendation));
        expect(restored.suggestedSpecials, equals(original.suggestedSpecials));
        expect(restored.inventoryAdvice, equals(original.inventoryAdvice));
        expect(restored.marketingOpportunity, equals(original.marketingOpportunity));
        expect(restored.revenueProjection, equals(original.revenueProjection));
      });
    });

    group('Equatable', () {
      test('two venue recommendations with same props are equal', () {
        final recs1 = VenueRecommendations(
          expectedTrafficIncrease: 0.35,
          staffingRecommendation: 'Add staff',
          suggestedSpecials: ['Special A'],
          inventoryAdvice: 'Order more',
          marketingOpportunity: 'Promote game',
          revenueProjection: 15000.0,
        );

        final recs2 = VenueRecommendations(
          expectedTrafficIncrease: 0.35,
          staffingRecommendation: 'Add staff',
          suggestedSpecials: ['Special A'],
          inventoryAdvice: 'Order more',
          marketingOpportunity: 'Promote game',
          revenueProjection: 15000.0,
        );

        expect(recs1, equals(recs2));
      });

      test('two venue recommendations with different props are not equal', () {
        final recs1 = VenueRecommendations(
          expectedTrafficIncrease: 0.35,
          staffingRecommendation: 'Add staff',
          suggestedSpecials: ['Special A'],
          inventoryAdvice: 'Order more',
          marketingOpportunity: 'Promote game',
          revenueProjection: 15000.0,
        );

        final recs2 = VenueRecommendations(
          expectedTrafficIncrease: 0.50,
          staffingRecommendation: 'Full staff',
          suggestedSpecials: ['Special B'],
          inventoryAdvice: 'Order much more',
          marketingOpportunity: 'Big promotion',
          revenueProjection: 25000.0,
        );

        expect(recs1, isNot(equals(recs2)));
      });
    });
  });
}

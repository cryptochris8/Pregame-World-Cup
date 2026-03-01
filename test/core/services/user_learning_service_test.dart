import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/services/user_learning_service.dart';

void main() {
  // UserLearningService is a singleton with Firebase + AI dependencies.
  // We test the data model classes (UserInsights, GameRecommendation) which
  // have pure logic and can be tested without any Firebase initialization.

  group('UserInsights', () {
    group('constructor', () {
      test('creates instance with required fields', () {
        const insights = UserInsights(
          teamAffinityScores: {'Brazil': 0.9, 'Argentina': 0.7},
          interactionPatterns: {'view': 0.6, 'predict': 0.3},
          preferredGameTypes: ['knockout', 'group'],
          recommendedVenues: ['MetLife Stadium'],
          engagementScore: 85.0,
          rawData: {'total': 100},
        );

        expect(insights.teamAffinityScores['Brazil'], 0.9);
        expect(insights.teamAffinityScores['Argentina'], 0.7);
        expect(insights.interactionPatterns['view'], 0.6);
        expect(insights.preferredGameTypes, ['knockout', 'group']);
        expect(insights.recommendedVenues, ['MetLife Stadium']);
        expect(insights.engagementScore, 85.0);
        expect(insights.rawData['total'], 100);
      });
    });

    group('empty factory', () {
      test('creates empty instance with default values', () {
        final empty = UserInsights.empty();

        expect(empty.teamAffinityScores, isEmpty);
        expect(empty.interactionPatterns, isEmpty);
        expect(empty.preferredGameTypes, isEmpty);
        expect(empty.recommendedVenues, isEmpty);
        expect(empty.engagementScore, 0.0);
        expect(empty.rawData, isEmpty);
      });
    });

    group('fromAIAnalysis factory', () {
      test('creates instance from AI analysis data', () {
        final aiAnalysis = {
          'teamAffinityScores': {'Brazil': 0.95, 'Germany': 0.6},
          'interactionPatterns': {'view': 0.8, 'share': 0.2},
          'preferredGameTypes': ['semifinal', 'final'],
          'recommendedVenues': ['Azteca Stadium', 'Rose Bowl'],
          'engagementScore': 72.5,
        };

        final behaviorData = {
          'gameInteractions': [
            {'gameId': 'g1', 'type': 'view'}
          ],
          'venueInteractions': [],
          'teamPreferences': [],
        };

        final insights =
            UserInsights.fromAIAnalysis(aiAnalysis, behaviorData);

        expect(insights.teamAffinityScores['Brazil'], 0.95);
        expect(insights.teamAffinityScores['Germany'], 0.6);
        expect(insights.interactionPatterns['view'], 0.8);
        expect(insights.preferredGameTypes, ['semifinal', 'final']);
        expect(insights.recommendedVenues, ['Azteca Stadium', 'Rose Bowl']);
        expect(insights.engagementScore, 72.5);
        expect(insights.rawData, behaviorData);
      });

      test('handles missing fields in AI analysis', () {
        final aiAnalysis = <String, dynamic>{};
        final behaviorData = <String, dynamic>{};

        final insights =
            UserInsights.fromAIAnalysis(aiAnalysis, behaviorData);

        expect(insights.teamAffinityScores, isEmpty);
        expect(insights.interactionPatterns, isEmpty);
        expect(insights.preferredGameTypes, isEmpty);
        expect(insights.recommendedVenues, isEmpty);
        expect(insights.engagementScore, 0.0);
      });

      test('handles null values in AI analysis', () {
        final aiAnalysis = {
          'teamAffinityScores': null,
          'interactionPatterns': null,
          'preferredGameTypes': null,
          'recommendedVenues': null,
          'engagementScore': null,
        };
        final behaviorData = <String, dynamic>{};

        final insights =
            UserInsights.fromAIAnalysis(aiAnalysis, behaviorData);

        expect(insights.teamAffinityScores, isEmpty);
        expect(insights.interactionPatterns, isEmpty);
        expect(insights.preferredGameTypes, isEmpty);
        expect(insights.recommendedVenues, isEmpty);
        expect(insights.engagementScore, 0.0);
      });

      test('converts int engagementScore to double', () {
        final aiAnalysis = {
          'engagementScore': 80,
        };
        final behaviorData = <String, dynamic>{};

        final insights =
            UserInsights.fromAIAnalysis(aiAnalysis, behaviorData);

        expect(insights.engagementScore, 80.0);
        expect(insights.engagementScore, isA<double>());
      });
    });

    group('toMap', () {
      test('converts to map with all fields', () {
        const insights = UserInsights(
          teamAffinityScores: {'Spain': 0.8},
          interactionPatterns: {'favorite': 0.5},
          preferredGameTypes: ['group'],
          recommendedVenues: ['Lusail Stadium'],
          engagementScore: 60.0,
          rawData: {'key': 'value'},
        );

        final map = insights.toMap();

        expect(map['teamAffinityScores'], {'Spain': 0.8});
        expect(map['interactionPatterns'], {'favorite': 0.5});
        expect(map['preferredGameTypes'], ['group']);
        expect(map['recommendedVenues'], ['Lusail Stadium']);
        expect(map['engagementScore'], 60.0);
        expect(map['rawData'], {'key': 'value'});
      });

      test('empty insights toMap returns empty collections', () {
        final empty = UserInsights.empty();
        final map = empty.toMap();

        expect(map['teamAffinityScores'], isEmpty);
        expect(map['interactionPatterns'], isEmpty);
        expect(map['preferredGameTypes'], isEmpty);
        expect(map['recommendedVenues'], isEmpty);
        expect(map['engagementScore'], 0.0);
        expect(map['rawData'], isEmpty);
      });

      test('round-trip: fromAIAnalysis -> toMap preserves data', () {
        final original = {
          'teamAffinityScores': {'France': 0.88},
          'interactionPatterns': {'predict': 0.4},
          'preferredGameTypes': ['quarterfinal'],
          'recommendedVenues': ['MetLife Stadium'],
          'engagementScore': 55.5,
        };

        final insights =
            UserInsights.fromAIAnalysis(original, {});
        final map = insights.toMap();

        expect(map['teamAffinityScores'], original['teamAffinityScores']);
        expect(map['interactionPatterns'], original['interactionPatterns']);
        expect(map['preferredGameTypes'], original['preferredGameTypes']);
        expect(map['recommendedVenues'], original['recommendedVenues']);
        expect(map['engagementScore'], original['engagementScore']);
      });
    });
  });

  group('GameRecommendation', () {
    group('constructor', () {
      test('creates instance with required fields', () {
        final gameTime = DateTime(2026, 6, 15, 18, 0);

        final recommendation = GameRecommendation(
          gameId: 'match1',
          homeTeam: 'Brazil',
          awayTeam: 'Germany',
          recommendationScore: 0.95,
          reasons: ['Favorite team playing', 'High rivalry match'],
          gameTime: gameTime,
          gameData: {'stage': 'group'},
        );

        expect(recommendation.gameId, 'match1');
        expect(recommendation.homeTeam, 'Brazil');
        expect(recommendation.awayTeam, 'Germany');
        expect(recommendation.recommendationScore, 0.95);
        expect(recommendation.reasons.length, 2);
        expect(recommendation.gameTime, gameTime);
        expect(recommendation.gameData['stage'], 'group');
      });
    });

    group('fromMap factory', () {
      test('creates instance from complete map', () {
        final map = {
          'gameId': 'match42',
          'homeTeam': 'Argentina',
          'awayTeam': 'France',
          'score': 0.87,
          'reasons': ['Classic final rematch', 'Top-rated teams'],
          'gameTime': '2026-07-19T18:00:00.000',
          'gameData': {'stage': 'final', 'venue': 'MetLife Stadium'},
        };

        final rec = GameRecommendation.fromMap(map);

        expect(rec.gameId, 'match42');
        expect(rec.homeTeam, 'Argentina');
        expect(rec.awayTeam, 'France');
        expect(rec.recommendationScore, 0.87);
        expect(rec.reasons, ['Classic final rematch', 'Top-rated teams']);
        expect(rec.gameTime.year, 2026);
        expect(rec.gameTime.month, 7);
        expect(rec.gameTime.day, 19);
        expect(rec.gameData['stage'], 'final');
        expect(rec.gameData['venue'], 'MetLife Stadium');
      });

      test('handles missing fields with defaults', () {
        final map = <String, dynamic>{};

        final rec = GameRecommendation.fromMap(map);

        expect(rec.gameId, '');
        expect(rec.homeTeam, '');
        expect(rec.awayTeam, '');
        expect(rec.recommendationScore, 0.0);
        expect(rec.reasons, isEmpty);
        expect(rec.gameData, isEmpty);
      });

      test('handles null values with defaults', () {
        final map = {
          'gameId': null,
          'homeTeam': null,
          'awayTeam': null,
          'score': null,
          'reasons': null,
          'gameData': null,
        };

        final rec = GameRecommendation.fromMap(map);

        expect(rec.gameId, '');
        expect(rec.homeTeam, '');
        expect(rec.awayTeam, '');
        expect(rec.recommendationScore, 0.0);
        expect(rec.reasons, isEmpty);
        expect(rec.gameData, isEmpty);
      });

      test('converts int score to double', () {
        final map = {
          'score': 1,
          'gameTime': '2026-06-11T18:00:00.000',
        };

        final rec = GameRecommendation.fromMap(map);
        expect(rec.recommendationScore, 1.0);
        expect(rec.recommendationScore, isA<double>());
      });

      test('parses ISO 8601 game time string', () {
        final map = {
          'gameTime': '2026-06-20T15:30:00.000',
        };

        final rec = GameRecommendation.fromMap(map);
        expect(rec.gameTime.year, 2026);
        expect(rec.gameTime.month, 6);
        expect(rec.gameTime.day, 20);
        expect(rec.gameTime.hour, 15);
        expect(rec.gameTime.minute, 30);
      });

      test('uses current time as fallback for missing gameTime', () {
        final before = DateTime.now();
        final map = <String, dynamic>{};
        final rec = GameRecommendation.fromMap(map);
        final after = DateTime.now();

        // gameTime should be approximately now
        expect(rec.gameTime.isAfter(before.subtract(const Duration(seconds: 1))),
            isTrue);
        expect(
            rec.gameTime.isBefore(after.add(const Duration(seconds: 1))), isTrue);
      });
    });
  });

  // Note: UserLearningService singleton test is omitted because
  // the constructor accesses FirebaseFirestore.instance which requires
  // Firebase initialization. The data model classes above provide full
  // coverage of the testable public API surface.
}

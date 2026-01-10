import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/domain/entities/match_summary.dart';

void main() {
  group('PlayerToWatch', () {
    test('creates player with required fields', () {
      const player = PlayerToWatch(
        name: 'Christian Pulisic',
        teamCode: 'USA',
        position: 'Winger',
        reason: 'Key playmaker in attack',
      );

      expect(player.name, equals('Christian Pulisic'));
      expect(player.teamCode, equals('USA'));
      expect(player.position, equals('Winger'));
      expect(player.reason, equals('Key playmaker in attack'));
    });

    test('toMap serializes correctly', () {
      const player = PlayerToWatch(
        name: 'Lionel Messi',
        teamCode: 'ARG',
        position: 'Forward',
        reason: 'Greatest of all time',
      );
      final map = player.toMap();

      expect(map['name'], equals('Lionel Messi'));
      expect(map['teamCode'], equals('ARG'));
      expect(map['position'], equals('Forward'));
      expect(map['reason'], equals('Greatest of all time'));
    });

    test('fromMap deserializes correctly', () {
      final map = {
        'name': 'Neymar Jr',
        'teamCode': 'BRA',
        'position': 'Forward',
        'reason': 'Creative flair and finishing',
      };

      final player = PlayerToWatch.fromMap(map);

      expect(player.name, equals('Neymar Jr'));
      expect(player.teamCode, equals('BRA'));
      expect(player.position, equals('Forward'));
      expect(player.reason, equals('Creative flair and finishing'));
    });

    test('roundtrip serialization preserves data', () {
      const original = PlayerToWatch(
        name: 'Kylian Mbappe',
        teamCode: 'FRA',
        position: 'Forward',
        reason: 'Electric pace and finishing',
      );
      final map = original.toMap();
      final restored = PlayerToWatch.fromMap(map);

      expect(restored.name, equals(original.name));
      expect(restored.teamCode, equals(original.teamCode));
      expect(restored.position, equals(original.position));
      expect(restored.reason, equals(original.reason));
    });
  });

  group('MatchPredictionSummary', () {
    test('creates prediction with required fields', () {
      const prediction = MatchPredictionSummary(
        predictedOutcome: 'USA',
        predictedScore: '2-1',
        confidence: 75,
        reasoning: 'Home advantage and recent form',
      );

      expect(prediction.predictedOutcome, equals('USA'));
      expect(prediction.predictedScore, equals('2-1'));
      expect(prediction.confidence, equals(75));
      expect(prediction.reasoning, equals('Home advantage and recent form'));
      expect(prediction.alternativeScenario, isNull);
    });

    test('creates prediction with optional alternativeScenario', () {
      const prediction = MatchPredictionSummary(
        predictedOutcome: 'DRAW',
        predictedScore: '1-1',
        confidence: 55,
        reasoning: 'Evenly matched teams',
        alternativeScenario: 'If Mexico scores early, they could win 2-1',
      );

      expect(prediction.alternativeScenario, isNotNull);
      expect(prediction.alternativeScenario, contains('Mexico'));
    });

    group('confidenceText', () {
      test('returns "High Confidence" for >= 80', () {
        const prediction = MatchPredictionSummary(
          predictedOutcome: 'BRA',
          predictedScore: '3-0',
          confidence: 85,
          reasoning: 'Clear favorite',
        );

        expect(prediction.confidenceText, equals('High Confidence'));
      });

      test('returns "Moderate Confidence" for 60-79', () {
        const prediction = MatchPredictionSummary(
          predictedOutcome: 'GER',
          predictedScore: '2-1',
          confidence: 65,
          reasoning: 'Slight edge',
        );

        expect(prediction.confidenceText, equals('Moderate Confidence'));
      });

      test('returns "Low Confidence" for 40-59', () {
        const prediction = MatchPredictionSummary(
          predictedOutcome: 'USA',
          predictedScore: '1-0',
          confidence: 50,
          reasoning: 'Could go either way',
        );

        expect(prediction.confidenceText, equals('Low Confidence'));
      });

      test('returns "Uncertain" for < 40', () {
        const prediction = MatchPredictionSummary(
          predictedOutcome: 'DRAW',
          predictedScore: '0-0',
          confidence: 30,
          reasoning: 'Very unpredictable match',
        );

        expect(prediction.confidenceText, equals('Uncertain'));
      });
    });

    test('toMap serializes correctly', () {
      const prediction = MatchPredictionSummary(
        predictedOutcome: 'ARG',
        predictedScore: '2-0',
        confidence: 70,
        reasoning: 'Strong midfield control',
        alternativeScenario: 'Counter-attacks could be dangerous',
      );
      final map = prediction.toMap();

      expect(map['predictedOutcome'], equals('ARG'));
      expect(map['predictedScore'], equals('2-0'));
      expect(map['confidence'], equals(70));
      expect(map['reasoning'], equals('Strong midfield control'));
      expect(map['alternativeScenario'], equals('Counter-attacks could be dangerous'));
    });

    test('fromMap deserializes correctly', () {
      final map = {
        'predictedOutcome': 'FRA',
        'predictedScore': '3-1',
        'confidence': 80,
        'reasoning': 'Superior squad depth',
        'alternativeScenario': null,
      };

      final prediction = MatchPredictionSummary.fromMap(map);

      expect(prediction.predictedOutcome, equals('FRA'));
      expect(prediction.predictedScore, equals('3-1'));
      expect(prediction.confidence, equals(80));
      expect(prediction.reasoning, equals('Superior squad depth'));
      expect(prediction.alternativeScenario, isNull);
    });

    test('roundtrip serialization preserves data', () {
      const original = MatchPredictionSummary(
        predictedOutcome: 'ENG',
        predictedScore: '2-1',
        confidence: 72,
        reasoning: 'Strong attacking lineup',
        alternativeScenario: 'Set pieces could be decisive',
      );
      final map = original.toMap();
      final restored = MatchPredictionSummary.fromMap(map);

      expect(restored.predictedOutcome, equals(original.predictedOutcome));
      expect(restored.predictedScore, equals(original.predictedScore));
      expect(restored.confidence, equals(original.confidence));
      expect(restored.reasoning, equals(original.reasoning));
      expect(restored.alternativeScenario, equals(original.alternativeScenario));
    });
  });

  group('MatchSummary', () {
    MatchSummary createTestMatchSummary({
      String id = 'ARG_BRA',
      String team1Code = 'ARG',
      String team2Code = 'BRA',
      String team1Name = 'Argentina',
      String team2Name = 'Brazil',
      String historicalAnalysis = 'Historic rivalry spanning decades',
      List<String> keyStorylines = const ['Messi vs Neymar', 'South American pride'],
      List<PlayerToWatch>? playersToWatch,
      String tacticalPreview = 'Both teams favor possession-based football',
      MatchPredictionSummary? prediction,
      String? pastEncountersSummary,
      List<String> funFacts = const ['Most played rivalry in South America'],
      bool isFirstMeeting = false,
      DateTime? updatedAt,
    }) {
      return MatchSummary(
        id: id,
        team1Code: team1Code,
        team2Code: team2Code,
        team1Name: team1Name,
        team2Name: team2Name,
        historicalAnalysis: historicalAnalysis,
        keyStorylines: keyStorylines,
        playersToWatch: playersToWatch ?? const [
          PlayerToWatch(name: 'Messi', teamCode: 'ARG', position: 'FW', reason: 'GOAT'),
          PlayerToWatch(name: 'Neymar', teamCode: 'BRA', position: 'FW', reason: 'Creative'),
        ],
        tacticalPreview: tacticalPreview,
        prediction: prediction ?? const MatchPredictionSummary(
          predictedOutcome: 'ARG',
          predictedScore: '2-1',
          confidence: 65,
          reasoning: 'Recent World Cup form',
        ),
        pastEncountersSummary: pastEncountersSummary,
        funFacts: funFacts,
        isFirstMeeting: isFirstMeeting,
        updatedAt: updatedAt,
      );
    }

    group('Constructor', () {
      test('creates match summary with required fields', () {
        final summary = createTestMatchSummary();

        expect(summary.id, equals('ARG_BRA'));
        expect(summary.team1Code, equals('ARG'));
        expect(summary.team2Code, equals('BRA'));
        expect(summary.team1Name, equals('Argentina'));
        expect(summary.team2Name, equals('Brazil'));
        expect(summary.historicalAnalysis, contains('Historic rivalry'));
        expect(summary.keyStorylines, hasLength(2));
        expect(summary.playersToWatch, hasLength(2));
        expect(summary.tacticalPreview, contains('possession'));
        expect(summary.funFacts, hasLength(1));
        expect(summary.isFirstMeeting, isFalse);
      });

      test('creates match summary with optional fields', () {
        final now = DateTime(2024, 10, 15);
        final summary = createTestMatchSummary(
          pastEncountersSummary: 'Argentina leads 40-38-39',
          isFirstMeeting: false,
          updatedAt: now,
        );

        expect(summary.pastEncountersSummary, equals('Argentina leads 40-38-39'));
        expect(summary.isFirstMeeting, isFalse);
        expect(summary.updatedAt, equals(now));
      });

      test('handles first meeting scenario', () {
        final summary = createTestMatchSummary(
          id: 'JAM_NZL',
          team1Code: 'JAM',
          team2Code: 'NZL',
          team1Name: 'Jamaica',
          team2Name: 'New Zealand',
          isFirstMeeting: true,
          pastEncountersSummary: null,
        );

        expect(summary.isFirstMeeting, isTrue);
        expect(summary.pastEncountersSummary, isNull);
      });
    });

    group('Firestore serialization', () {
      test('toFirestore serializes all fields', () {
        final now = DateTime(2024, 10, 15, 12, 0, 0);
        final summary = createTestMatchSummary(
          pastEncountersSummary: 'Historic record',
          updatedAt: now,
        );
        final data = summary.toFirestore();

        expect(data['team1Code'], equals('ARG'));
        expect(data['team2Code'], equals('BRA'));
        expect(data['team1Name'], equals('Argentina'));
        expect(data['team2Name'], equals('Brazil'));
        expect(data['historicalAnalysis'], contains('Historic rivalry'));
        expect(data['keyStorylines'], hasLength(2));
        expect(data['playersToWatch'], hasLength(2));
        expect(data['tacticalPreview'], isNotEmpty);
        expect(data['prediction'], isA<Map>());
        expect(data['pastEncountersSummary'], equals('Historic record'));
        expect(data['funFacts'], hasLength(1));
        expect(data['isFirstMeeting'], isFalse);
        expect(data['updatedAt'], equals('2024-10-15T12:00:00.000'));
      });

      test('fromFirestore deserializes correctly', () {
        final data = {
          'team1Code': 'USA',
          'team2Code': 'MEX',
          'team1Name': 'United States',
          'team2Name': 'Mexico',
          'historicalAnalysis': 'CONCACAF rivals',
          'keyStorylines': ['Border rivalry'],
          'playersToWatch': [
            {'name': 'Pulisic', 'teamCode': 'USA', 'position': 'MF', 'reason': 'Star'},
          ],
          'tacticalPreview': 'Tactical battle',
          'prediction': {
            'predictedOutcome': 'USA',
            'predictedScore': '2-1',
            'confidence': 55,
            'reasoning': 'Home advantage',
          },
          'funFacts': ['Most played rivalry in CONCACAF'],
          'isFirstMeeting': false,
          'updatedAt': '2024-10-15T12:00:00.000',
        };

        final summary = MatchSummary.fromFirestore(data, 'MEX_USA');

        expect(summary.id, equals('MEX_USA'));
        expect(summary.team1Code, equals('USA'));
        expect(summary.team2Code, equals('MEX'));
        expect(summary.team1Name, equals('United States'));
        expect(summary.playersToWatch, hasLength(1));
        expect(summary.prediction.predictedOutcome, equals('USA'));
        expect(summary.funFacts, hasLength(1));
      });

      test('fromFirestore handles missing optional fields', () {
        final data = {
          'team1Code': 'CAN',
          'team2Code': 'JAM',
          'team1Name': 'Canada',
          'team2Name': 'Jamaica',
          'historicalAnalysis': 'Caribbean clash',
          'keyStorylines': null,
          'playersToWatch': null,
          'tacticalPreview': 'Unknown',
          'prediction': {
            'predictedOutcome': 'CAN',
            'predictedScore': '1-0',
            'confidence': 45,
            'reasoning': 'Recent form',
          },
          'funFacts': null,
          'isFirstMeeting': null,
        };

        final summary = MatchSummary.fromFirestore(data, 'CAN_JAM');

        expect(summary.keyStorylines, isEmpty);
        expect(summary.playersToWatch, isEmpty);
        expect(summary.funFacts, isEmpty);
        expect(summary.isFirstMeeting, isFalse);
        expect(summary.pastEncountersSummary, isNull);
        expect(summary.updatedAt, isNull);
      });

      test('roundtrip serialization preserves data', () {
        final original = createTestMatchSummary(
          pastEncountersSummary: 'Long history of matches',
          updatedAt: DateTime(2024, 10, 15),
        );
        final data = original.toFirestore();
        final restored = MatchSummary.fromFirestore(data, original.id);

        expect(restored.team1Code, equals(original.team1Code));
        expect(restored.team2Code, equals(original.team2Code));
        expect(restored.team1Name, equals(original.team1Name));
        expect(restored.team2Name, equals(original.team2Name));
        expect(restored.historicalAnalysis, equals(original.historicalAnalysis));
        expect(restored.keyStorylines, equals(original.keyStorylines));
        expect(restored.playersToWatch.length, equals(original.playersToWatch.length));
        expect(restored.tacticalPreview, equals(original.tacticalPreview));
        expect(restored.prediction.predictedOutcome, equals(original.prediction.predictedOutcome));
        expect(restored.funFacts, equals(original.funFacts));
        expect(restored.isFirstMeeting, equals(original.isFirstMeeting));
      });
    });

    group('Equatable', () {
      test('two summaries with same id are equal', () {
        final summary1 = createTestMatchSummary(id: 'ARG_BRA');
        final summary2 = createTestMatchSummary(id: 'ARG_BRA');

        expect(summary1, equals(summary2));
      });

      test('two summaries with different ids are not equal', () {
        final summary1 = createTestMatchSummary(id: 'ARG_BRA');
        final summary2 = createTestMatchSummary(id: 'USA_MEX');

        expect(summary1, isNot(equals(summary2)));
      });
    });
  });
}

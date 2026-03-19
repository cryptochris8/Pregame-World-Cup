import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/domain/entities/ai_match_prediction.dart';

void main() {
  final testGeneratedAt = DateTime(2026, 6, 10, 12, 0, 0);

  AIMatchPrediction createPrediction({
    String matchId = 'match_1',
    AIPredictedOutcome predictedOutcome = AIPredictedOutcome.homeWin,
    int predictedHomeScore = 2,
    int predictedAwayScore = 1,
    int confidence = 65,
    int homeWinProbability = 55,
    int drawProbability = 25,
    int awayWinProbability = 20,
    List<String> keyFactors = const ['Home advantage', 'Recent form'],
    String analysis = 'Home team favored based on ranking.',
    String quickInsight = 'Home advantage gives edge',
    String provider = 'Claude',
    DateTime? generatedAt,
    int ttlMinutes = 1440,
    bool isUpsetAlert = false,
    String? upsetAlertText,
    String? squadValueNarrative,
    String? managerMatchup,
    List<String> historicalPatterns = const [],
    String? confidenceDebate,
    String? homeRecentForm,
    String? awayRecentForm,
    String? bettingOddsSummary,
  }) {
    return AIMatchPrediction(
      matchId: matchId,
      predictedOutcome: predictedOutcome,
      predictedHomeScore: predictedHomeScore,
      predictedAwayScore: predictedAwayScore,
      confidence: confidence,
      homeWinProbability: homeWinProbability,
      drawProbability: drawProbability,
      awayWinProbability: awayWinProbability,
      keyFactors: keyFactors,
      analysis: analysis,
      quickInsight: quickInsight,
      provider: provider,
      generatedAt: generatedAt ?? testGeneratedAt,
      ttlMinutes: ttlMinutes,
      isUpsetAlert: isUpsetAlert,
      upsetAlertText: upsetAlertText,
      squadValueNarrative: squadValueNarrative,
      managerMatchup: managerMatchup,
      historicalPatterns: historicalPatterns,
      confidenceDebate: confidenceDebate,
      homeRecentForm: homeRecentForm,
      awayRecentForm: awayRecentForm,
      bettingOddsSummary: bettingOddsSummary,
    );
  }

  group('AIMatchPrediction', () {
    group('Constructor', () {
      test('creates prediction with required fields', () {
        final prediction = createPrediction();

        expect(prediction.matchId, equals('match_1'));
        expect(prediction.predictedOutcome, equals(AIPredictedOutcome.homeWin));
        expect(prediction.predictedHomeScore, equals(2));
        expect(prediction.predictedAwayScore, equals(1));
        expect(prediction.confidence, equals(65));
        expect(prediction.homeWinProbability, equals(55));
        expect(prediction.drawProbability, equals(25));
        expect(prediction.awayWinProbability, equals(20));
        expect(prediction.keyFactors, hasLength(2));
        expect(prediction.provider, equals('Claude'));
      });

      test('creates prediction with optional fields', () {
        final prediction = createPrediction(
          isUpsetAlert: true,
          upsetAlertText: 'Underdog has strong momentum',
          squadValueNarrative: 'Squad A valued at 1.2B',
          managerMatchup: 'Tactical battle',
          historicalPatterns: ['Team A won last 3 meetings'],
          confidenceDebate: 'Close rankings make this uncertain',
          homeRecentForm: 'W-W-D-L-W',
          awayRecentForm: 'L-W-W-D-D',
          bettingOddsSummary: 'Home team slight favorite at 1.85',
        );

        expect(prediction.isUpsetAlert, isTrue);
        expect(prediction.upsetAlertText, equals('Underdog has strong momentum'));
        expect(prediction.squadValueNarrative, equals('Squad A valued at 1.2B'));
        expect(prediction.managerMatchup, equals('Tactical battle'));
        expect(prediction.historicalPatterns, hasLength(1));
        expect(prediction.confidenceDebate, isNotNull);
        expect(prediction.homeRecentForm, equals('W-W-D-L-W'));
        expect(prediction.awayRecentForm, equals('L-W-W-D-D'));
        expect(prediction.bettingOddsSummary, isNotNull);
      });

      test('default values are correct', () {
        final prediction = createPrediction();

        expect(prediction.ttlMinutes, equals(1440));
        expect(prediction.isUpsetAlert, isFalse);
        expect(prediction.upsetAlertText, isNull);
        expect(prediction.historicalPatterns, isEmpty);
      });
    });

    group('scoreDisplay', () {
      test('returns formatted score string', () {
        final prediction = createPrediction(
          predictedHomeScore: 2,
          predictedAwayScore: 1,
        );
        expect(prediction.scoreDisplay, equals('2-1'));
      });

      test('returns draw score', () {
        final prediction = createPrediction(
          predictedHomeScore: 1,
          predictedAwayScore: 1,
        );
        expect(prediction.scoreDisplay, equals('1-1'));
      });

      test('returns goalless draw', () {
        final prediction = createPrediction(
          predictedHomeScore: 0,
          predictedAwayScore: 0,
        );
        expect(prediction.scoreDisplay, equals('0-0'));
      });

      test('returns high-scoring game', () {
        final prediction = createPrediction(
          predictedHomeScore: 4,
          predictedAwayScore: 3,
        );
        expect(prediction.scoreDisplay, equals('4-3'));
      });
    });

    group('confidenceDescription', () {
      test('returns Very High for confidence >= 80', () {
        expect(createPrediction(confidence: 80).confidenceDescription, equals('Very High'));
        expect(createPrediction(confidence: 95).confidenceDescription, equals('Very High'));
        expect(createPrediction(confidence: 100).confidenceDescription, equals('Very High'));
      });

      test('returns High for confidence >= 65', () {
        expect(createPrediction(confidence: 65).confidenceDescription, equals('High'));
        expect(createPrediction(confidence: 79).confidenceDescription, equals('High'));
      });

      test('returns Moderate for confidence >= 50', () {
        expect(createPrediction(confidence: 50).confidenceDescription, equals('Moderate'));
        expect(createPrediction(confidence: 64).confidenceDescription, equals('Moderate'));
      });

      test('returns Low for confidence >= 35', () {
        expect(createPrediction(confidence: 35).confidenceDescription, equals('Low'));
        expect(createPrediction(confidence: 49).confidenceDescription, equals('Low'));
      });

      test('returns Very Low for confidence < 35', () {
        expect(createPrediction(confidence: 34).confidenceDescription, equals('Very Low'));
        expect(createPrediction(confidence: 10).confidenceDescription, equals('Very Low'));
        expect(createPrediction(confidence: 0).confidenceDescription, equals('Very Low'));
      });
    });

    group('isValid', () {
      test('returns true when within TTL', () {
        final prediction = createPrediction(
          generatedAt: DateTime.now().subtract(const Duration(hours: 12)),
          ttlMinutes: 1440, // 24 hours
        );
        expect(prediction.isValid, isTrue);
      });

      test('returns false when past TTL', () {
        final prediction = createPrediction(
          generatedAt: DateTime.now().subtract(const Duration(hours: 25)),
          ttlMinutes: 1440, // 24 hours
        );
        expect(prediction.isValid, isFalse);
      });

      test('returns false for very old predictions', () {
        final prediction = createPrediction(
          generatedAt: DateTime(2020, 1, 1),
          ttlMinutes: 60,
        );
        expect(prediction.isValid, isFalse);
      });

      test('returns true for just-generated predictions', () {
        final prediction = createPrediction(
          generatedAt: DateTime.now(),
          ttlMinutes: 1,
        );
        expect(prediction.isValid, isTrue);
      });
    });

    group('toMap', () {
      test('serializes all fields correctly', () {
        final prediction = createPrediction(
          isUpsetAlert: true,
          upsetAlertText: 'Alert!',
          squadValueNarrative: 'Narrative',
          managerMatchup: 'Matchup',
          historicalPatterns: ['Pattern 1'],
          confidenceDebate: 'Debate',
          homeRecentForm: 'W-W',
          awayRecentForm: 'L-L',
          bettingOddsSummary: 'Odds',
        );
        final map = prediction.toMap();

        expect(map['matchId'], equals('match_1'));
        expect(map['predictedOutcome'], equals('homeWin'));
        expect(map['predictedHomeScore'], equals(2));
        expect(map['predictedAwayScore'], equals(1));
        expect(map['confidence'], equals(65));
        expect(map['homeWinProbability'], equals(55));
        expect(map['drawProbability'], equals(25));
        expect(map['awayWinProbability'], equals(20));
        expect(map['keyFactors'], hasLength(2));
        expect(map['analysis'], equals('Home team favored based on ranking.'));
        expect(map['quickInsight'], equals('Home advantage gives edge'));
        expect(map['provider'], equals('Claude'));
        expect(map['generatedAt'], equals(testGeneratedAt.toIso8601String()));
        expect(map['ttlMinutes'], equals(1440));
        expect(map['isUpsetAlert'], isTrue);
        expect(map['upsetAlertText'], equals('Alert!'));
        expect(map['squadValueNarrative'], equals('Narrative'));
        expect(map['managerMatchup'], equals('Matchup'));
        expect(map['historicalPatterns'], equals(['Pattern 1']));
        expect(map['confidenceDebate'], equals('Debate'));
        expect(map['homeRecentForm'], equals('W-W'));
        expect(map['awayRecentForm'], equals('L-L'));
        expect(map['bettingOddsSummary'], equals('Odds'));
      });

      test('serializes null optional fields', () {
        final prediction = createPrediction();
        final map = prediction.toMap();

        expect(map['upsetAlertText'], isNull);
        expect(map['squadValueNarrative'], isNull);
        expect(map['managerMatchup'], isNull);
        expect(map['confidenceDebate'], isNull);
      });
    });

    group('fromMap', () {
      test('deserializes all fields correctly', () {
        final map = {
          'predictedHomeScore': 3,
          'predictedAwayScore': 0,
          'confidence': 80,
          'homeWinProbability': 70,
          'drawProbability': 20,
          'awayWinProbability': 10,
          'keyFactors': ['Factor 1', 'Factor 2'],
          'analysis': 'Analysis text',
          'quickInsight': 'Quick insight',
          'provider': 'OpenAI',
          'generatedAt': '2026-06-10T12:00:00.000',
          'ttlMinutes': 720,
          'isUpsetAlert': false,
          'upsetAlertText': null,
          'squadValueNarrative': 'Squad narrative',
          'managerMatchup': 'Manager matchup',
          'historicalPatterns': ['Pattern A'],
          'confidenceDebate': null,
          'homeRecentForm': 'W-W-W',
          'awayRecentForm': 'L-L-L',
          'bettingOddsSummary': 'Odds summary',
        };

        final prediction = AIMatchPrediction.fromMap(map, 'match_42');

        expect(prediction.matchId, equals('match_42'));
        expect(prediction.predictedOutcome, equals(AIPredictedOutcome.homeWin));
        expect(prediction.predictedHomeScore, equals(3));
        expect(prediction.predictedAwayScore, equals(0));
        expect(prediction.confidence, equals(80));
        expect(prediction.homeWinProbability, equals(70));
        expect(prediction.provider, equals('OpenAI'));
        expect(prediction.ttlMinutes, equals(720));
        expect(prediction.squadValueNarrative, equals('Squad narrative'));
        expect(prediction.historicalPatterns, equals(['Pattern A']));
        expect(prediction.homeRecentForm, equals('W-W-W'));
      });

      test('determines homeWin outcome when home score > away', () {
        final map = {'predictedHomeScore': 2, 'predictedAwayScore': 0};
        final prediction = AIMatchPrediction.fromMap(map, 'match_1');
        expect(prediction.predictedOutcome, equals(AIPredictedOutcome.homeWin));
      });

      test('determines awayWin outcome when away score > home', () {
        final map = {'predictedHomeScore': 0, 'predictedAwayScore': 3};
        final prediction = AIMatchPrediction.fromMap(map, 'match_1');
        expect(prediction.predictedOutcome, equals(AIPredictedOutcome.awayWin));
      });

      test('determines draw outcome when scores are equal', () {
        final map = {'predictedHomeScore': 1, 'predictedAwayScore': 1};
        final prediction = AIMatchPrediction.fromMap(map, 'match_1');
        expect(prediction.predictedOutcome, equals(AIPredictedOutcome.draw));
      });

      test('handles missing fields with defaults', () {
        final map = <String, dynamic>{};
        final prediction = AIMatchPrediction.fromMap(map, 'match_1');

        expect(prediction.predictedHomeScore, equals(1));
        expect(prediction.predictedAwayScore, equals(1));
        expect(prediction.confidence, equals(50));
        expect(prediction.homeWinProbability, equals(33));
        expect(prediction.drawProbability, equals(34));
        expect(prediction.awayWinProbability, equals(33));
        expect(prediction.keyFactors, isEmpty);
        expect(prediction.analysis, isEmpty);
        expect(prediction.quickInsight, isEmpty);
        expect(prediction.provider, equals('AI'));
        expect(prediction.ttlMinutes, equals(1440));
      });
    });

    group('roundtrip serialization', () {
      test('toMap/fromMap preserves all data', () {
        final original = createPrediction(
          isUpsetAlert: true,
          upsetAlertText: 'Alert text',
          squadValueNarrative: 'Narrative',
          managerMatchup: 'Matchup text',
          historicalPatterns: ['H2H: 5-3-2'],
          homeRecentForm: 'WWDLW',
          awayRecentForm: 'LWWDL',
          bettingOddsSummary: '1.85 / 3.40 / 4.50',
        );
        final map = original.toMap();
        final restored = AIMatchPrediction.fromMap(map, original.matchId);

        expect(restored.matchId, equals(original.matchId));
        expect(restored.predictedHomeScore, equals(original.predictedHomeScore));
        expect(restored.predictedAwayScore, equals(original.predictedAwayScore));
        expect(restored.confidence, equals(original.confidence));
        expect(restored.homeWinProbability, equals(original.homeWinProbability));
        expect(restored.drawProbability, equals(original.drawProbability));
        expect(restored.awayWinProbability, equals(original.awayWinProbability));
        expect(restored.keyFactors, equals(original.keyFactors));
        expect(restored.analysis, equals(original.analysis));
        expect(restored.quickInsight, equals(original.quickInsight));
        expect(restored.provider, equals(original.provider));
        expect(restored.ttlMinutes, equals(original.ttlMinutes));
        expect(restored.isUpsetAlert, equals(original.isUpsetAlert));
        expect(restored.upsetAlertText, equals(original.upsetAlertText));
        expect(restored.squadValueNarrative, equals(original.squadValueNarrative));
        expect(restored.managerMatchup, equals(original.managerMatchup));
        expect(restored.historicalPatterns, equals(original.historicalPatterns));
        expect(restored.homeRecentForm, equals(original.homeRecentForm));
        expect(restored.awayRecentForm, equals(original.awayRecentForm));
        expect(restored.bettingOddsSummary, equals(original.bettingOddsSummary));
      });
    });

    group('copyWith', () {
      test('creates copy with updated fields', () {
        final original = createPrediction();
        final updated = original.copyWith(
          confidence: 90,
          predictedHomeScore: 3,
          isUpsetAlert: true,
          upsetAlertText: 'Upset!',
        );

        expect(updated.confidence, equals(90));
        expect(updated.predictedHomeScore, equals(3));
        expect(updated.isUpsetAlert, isTrue);
        expect(updated.upsetAlertText, equals('Upset!'));
        // Unchanged fields
        expect(updated.matchId, equals(original.matchId));
        expect(updated.predictedAwayScore, equals(original.predictedAwayScore));
        expect(updated.provider, equals(original.provider));
      });

      test('preserves all fields when no updates given', () {
        final original = createPrediction(
          isUpsetAlert: true,
          upsetAlertText: 'Original alert',
        );
        final copy = original.copyWith();

        expect(copy.matchId, equals(original.matchId));
        expect(copy.predictedOutcome, equals(original.predictedOutcome));
        expect(copy.predictedHomeScore, equals(original.predictedHomeScore));
        expect(copy.predictedAwayScore, equals(original.predictedAwayScore));
        expect(copy.isUpsetAlert, equals(original.isUpsetAlert));
        expect(copy.upsetAlertText, equals(original.upsetAlertText));
      });
    });

    group('fallback factory', () {
      test('creates fallback when home ranked higher', () {
        final prediction = AIMatchPrediction.fallback(
          matchId: 'match_test',
          homeTeamName: 'Brazil',
          awayTeamName: 'Tunisia',
          homeRanking: 5,
          awayRanking: 40,
        );

        expect(prediction.matchId, equals('match_test'));
        expect(prediction.confidence, equals(40));
        expect(prediction.provider, equals('Fallback'));
        expect(prediction.homeWinProbability, greaterThan(prediction.awayWinProbability));
        expect(prediction.predictedHomeScore, greaterThanOrEqualTo(prediction.predictedAwayScore));
      });

      test('creates fallback when away ranked higher', () {
        final prediction = AIMatchPrediction.fallback(
          matchId: 'match_test',
          homeTeamName: 'Tunisia',
          awayTeamName: 'Brazil',
          homeRanking: 40,
          awayRanking: 5,
        );

        expect(prediction.awayWinProbability, greaterThan(prediction.homeWinProbability));
      });

      test('creates balanced fallback for equal rankings', () {
        final prediction = AIMatchPrediction.fallback(
          matchId: 'match_test',
          homeTeamName: 'Team A',
          awayTeamName: 'Team B',
          homeRanking: 20,
          awayRanking: 20,
        );

        expect(prediction.predictedOutcome, equals(AIPredictedOutcome.draw));
        expect(prediction.predictedHomeScore, equals(1));
        expect(prediction.predictedAwayScore, equals(1));
        expect(prediction.homeWinProbability, equals(38));
        expect(prediction.drawProbability, equals(28));
        expect(prediction.awayWinProbability, equals(34));
      });

      test('uses default rankings when null', () {
        final prediction = AIMatchPrediction.fallback(
          matchId: 'match_test',
          homeTeamName: 'Team A',
          awayTeamName: 'Team B',
        );

        // Both default to 50, so equal rankings
        expect(prediction.predictedOutcome, equals(AIPredictedOutcome.draw));
        expect(prediction.confidence, equals(40));
      });

      test('has correct key factors for fallback', () {
        final prediction = AIMatchPrediction.fallback(
          matchId: 'match_test',
          homeTeamName: 'Team A',
          awayTeamName: 'Team B',
        );

        expect(prediction.keyFactors, hasLength(3));
        expect(prediction.keyFactors[0], contains('World Rankings'));
        expect(prediction.analysis, contains('rankings'));
        expect(prediction.quickInsight, contains('Ranking'));
      });

      test('probabilities sum to 100', () {
        final prediction1 = AIMatchPrediction.fallback(
          matchId: 'm1',
          homeTeamName: 'A',
          awayTeamName: 'B',
          homeRanking: 5,
          awayRanking: 40,
        );
        final prediction2 = AIMatchPrediction.fallback(
          matchId: 'm2',
          homeTeamName: 'A',
          awayTeamName: 'B',
          homeRanking: 40,
          awayRanking: 5,
        );
        final prediction3 = AIMatchPrediction.fallback(
          matchId: 'm3',
          homeTeamName: 'A',
          awayTeamName: 'B',
          homeRanking: 20,
          awayRanking: 20,
        );

        expect(
          prediction1.homeWinProbability + prediction1.drawProbability + prediction1.awayWinProbability,
          equals(100),
        );
        expect(
          prediction2.homeWinProbability + prediction2.drawProbability + prediction2.awayWinProbability,
          equals(100),
        );
        expect(
          prediction3.homeWinProbability + prediction3.drawProbability + prediction3.awayWinProbability,
          equals(100),
        );
      });

      test('handles large ranking difference', () {
        final prediction = AIMatchPrediction.fallback(
          matchId: 'match_test',
          homeTeamName: 'Brazil',
          awayTeamName: 'New Caledonia',
          homeRanking: 1,
          awayRanking: 150,
        );

        expect(prediction.predictedOutcome, equals(AIPredictedOutcome.homeWin));
        expect(prediction.predictedHomeScore, equals(2));
        expect(prediction.predictedAwayScore, equals(0));
      });
    });

    group('Equatable', () {
      test('equal predictions are equal', () {
        final p1 = createPrediction();
        final p2 = createPrediction();
        expect(p1, equals(p2));
      });

      test('predictions with different matchId are not equal', () {
        final p1 = createPrediction(matchId: 'match_1');
        final p2 = createPrediction(matchId: 'match_2');
        expect(p1, isNot(equals(p2)));
      });

      test('predictions with different scores are not equal', () {
        final p1 = createPrediction(predictedHomeScore: 2);
        final p2 = createPrediction(predictedHomeScore: 3);
        expect(p1, isNot(equals(p2)));
      });
    });

    group('toString', () {
      test('returns formatted string', () {
        final prediction = createPrediction();
        expect(prediction.toString(), contains('match_1'));
        expect(prediction.toString(), contains('2-1'));
        expect(prediction.toString(), contains('65'));
      });
    });
  });

  group('AIPredictedOutcome', () {
    group('displayName', () {
      test('returns correct display names', () {
        expect(AIPredictedOutcome.homeWin.displayName, equals('Home Win'));
        expect(AIPredictedOutcome.draw.displayName, equals('Draw'));
        expect(AIPredictedOutcome.awayWin.displayName, equals('Away Win'));
      });
    });
  });
}

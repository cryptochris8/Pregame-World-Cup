import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/worldcup.dart';

void main() {
  group('WorldCupAIState', () {
    // Helper to create test AI predictions
    AIMatchPrediction createTestPrediction({
      String matchId = 'match_1',
      AIPredictedOutcome outcome = AIPredictedOutcome.homeWin,
      int predictedHomeScore = 2,
      int predictedAwayScore = 1,
      int confidence = 75,
      int ttlMinutes = 1440,
      bool isValid = true,
    }) {
      final generatedAt = isValid
          ? DateTime.now().subtract(const Duration(minutes: 10))
          : DateTime.now().subtract(const Duration(days: 2));

      return AIMatchPrediction(
        matchId: matchId,
        predictedOutcome: outcome,
        predictedHomeScore: predictedHomeScore,
        predictedAwayScore: predictedAwayScore,
        confidence: confidence,
        homeWinProbability: 50,
        drawProbability: 25,
        awayWinProbability: 25,
        keyFactors: const ['Factor 1', 'Factor 2'],
        analysis: 'Test analysis',
        quickInsight: 'Test insight',
        provider: 'Claude',
        generatedAt: generatedAt,
        ttlMinutes: ttlMinutes,
      );
    }

    group('Constructor', () {
      test('creates state with default values', () {
        const state = WorldCupAIState();

        expect(state.predictions, isEmpty);
        expect(state.isLoading, isFalse);
        expect(state.loadingMatchId, isNull);
        expect(state.error, isNull);
        expect(state.errorMatchId, isNull);
        expect(state.isAvailable, isTrue);
      });

      test('creates state with custom values', () {
        final prediction = createTestPrediction();
        final state = WorldCupAIState(
          predictions: {'match_1': prediction},
          isLoading: true,
          loadingMatchId: 'match_2',
          error: 'Test error',
          errorMatchId: 'match_3',
          isAvailable: false,
        );

        expect(state.predictions, hasLength(1));
        expect(state.predictions['match_1'], equals(prediction));
        expect(state.isLoading, isTrue);
        expect(state.loadingMatchId, equals('match_2'));
        expect(state.error, equals('Test error'));
        expect(state.errorMatchId, equals('match_3'));
        expect(state.isAvailable, isFalse);
      });
    });

    group('initial factory', () {
      test('creates initial state', () {
        final state = WorldCupAIState.initial();

        expect(state.predictions, isEmpty);
        expect(state.isLoading, isFalse);
        expect(state.loadingMatchId, isNull);
        expect(state.error, isNull);
        expect(state.errorMatchId, isNull);
        expect(state.isAvailable, isTrue);
      });
    });

    group('getPrediction', () {
      test('returns prediction when it exists', () {
        final prediction = createTestPrediction(matchId: 'match_1');
        final state = WorldCupAIState(predictions: {'match_1': prediction});

        final result = state.getPrediction('match_1');

        expect(result, equals(prediction));
      });

      test('returns null when prediction does not exist', () {
        final state = WorldCupAIState(predictions: {});

        final result = state.getPrediction('match_1');

        expect(result, isNull);
      });
    });

    group('hasPrediction', () {
      test('returns true when valid prediction exists', () {
        final prediction = createTestPrediction(matchId: 'match_1', isValid: true);
        final state = WorldCupAIState(predictions: {'match_1': prediction});

        expect(state.hasPrediction('match_1'), isTrue);
      });

      test('returns false when prediction exists but is not valid', () {
        final prediction = createTestPrediction(matchId: 'match_1', isValid: false);
        final state = WorldCupAIState(predictions: {'match_1': prediction});

        expect(state.hasPrediction('match_1'), isFalse);
      });

      test('returns false when prediction does not exist', () {
        const state = WorldCupAIState();

        expect(state.hasPrediction('match_1'), isFalse);
      });
    });

    group('isLoadingMatch', () {
      test('returns true when loading specific match', () {
        const state = WorldCupAIState(
          isLoading: true,
          loadingMatchId: 'match_1',
        );

        expect(state.isLoadingMatch('match_1'), isTrue);
      });

      test('returns false when loading different match', () {
        const state = WorldCupAIState(
          isLoading: true,
          loadingMatchId: 'match_1',
        );

        expect(state.isLoadingMatch('match_2'), isFalse);
      });

      test('returns false when not loading', () {
        const state = WorldCupAIState(isLoading: false);

        expect(state.isLoadingMatch('match_1'), isFalse);
      });
    });

    group('hasError', () {
      test('returns true when error exists for specific match', () {
        const state = WorldCupAIState(
          error: 'Test error',
          errorMatchId: 'match_1',
        );

        expect(state.hasError('match_1'), isTrue);
      });

      test('returns false when error exists for different match', () {
        const state = WorldCupAIState(
          error: 'Test error',
          errorMatchId: 'match_1',
        );

        expect(state.hasError('match_2'), isFalse);
      });

      test('returns false when no error', () {
        const state = WorldCupAIState();

        expect(state.hasError('match_1'), isFalse);
      });
    });

    group('copyWith', () {
      test('copies with updated fields', () {
        final prediction = createTestPrediction();
        final original = WorldCupAIState(predictions: {'match_1': prediction});

        final updated = original.copyWith(
          isLoading: true,
          loadingMatchId: 'match_2',
          isAvailable: false,
        );

        expect(updated.predictions, equals(original.predictions));
        expect(updated.isLoading, isTrue);
        expect(updated.loadingMatchId, equals('match_2'));
        expect(updated.isAvailable, isFalse);
      });

      test('preserves unchanged fields', () {
        final prediction = createTestPrediction();
        const original = WorldCupAIState(isAvailable: true);

        final updated = original.copyWith(
          predictions: {'match_1': prediction},
        );

        expect(updated.isAvailable, isTrue);
        expect(updated.predictions, hasLength(1));
      });

      test('clears error when clearError is true', () {
        const original = WorldCupAIState(
          error: 'Test error',
          errorMatchId: 'match_1',
        );

        final updated = original.copyWith(clearError: true);

        expect(updated.error, isNull);
        expect(updated.errorMatchId, isNull);
      });

      test('clears loadingMatchId when clearLoadingMatchId is true', () {
        const original = WorldCupAIState(loadingMatchId: 'match_1');

        final updated = original.copyWith(clearLoadingMatchId: true);

        expect(updated.loadingMatchId, isNull);
      });
    });

    group('withPrediction', () {
      test('adds new prediction to empty map', () {
        const original = WorldCupAIState();
        final prediction = createTestPrediction(matchId: 'match_1');

        final updated = original.withPrediction(prediction);

        expect(updated.predictions, hasLength(1));
        expect(updated.predictions['match_1'], equals(prediction));
        expect(updated.isLoading, isFalse);
        expect(updated.loadingMatchId, isNull);
        expect(updated.error, isNull);
      });

      test('updates existing prediction', () {
        final oldPrediction = createTestPrediction(
          matchId: 'match_1',
          confidence: 50,
        );
        final original = WorldCupAIState(predictions: {'match_1': oldPrediction});

        final newPrediction = createTestPrediction(
          matchId: 'match_1',
          confidence: 75,
        );
        final updated = original.withPrediction(newPrediction);

        expect(updated.predictions, hasLength(1));
        expect(updated.predictions['match_1']?.confidence, equals(75));
      });

      test('adds prediction alongside existing predictions', () {
        final prediction1 = createTestPrediction(matchId: 'match_1');
        final original = WorldCupAIState(predictions: {'match_1': prediction1});

        final prediction2 = createTestPrediction(matchId: 'match_2');
        final updated = original.withPrediction(prediction2);

        expect(updated.predictions, hasLength(2));
        expect(updated.predictions['match_1'], equals(prediction1));
        expect(updated.predictions['match_2'], equals(prediction2));
      });

      test('clears loading and error state', () {
        const original = WorldCupAIState(
          isLoading: true,
          loadingMatchId: 'match_1',
          error: 'Error',
          errorMatchId: 'match_1',
        );

        final prediction = createTestPrediction(matchId: 'match_1');
        final updated = original.withPrediction(prediction);

        expect(updated.isLoading, isFalse);
        expect(updated.loadingMatchId, isNull);
        expect(updated.error, isNull);
        expect(updated.errorMatchId, isNull);
      });
    });

    group('withoutPrediction', () {
      test('removes prediction from map', () {
        final prediction = createTestPrediction(matchId: 'match_1');
        final original = WorldCupAIState(predictions: {'match_1': prediction});

        final updated = original.withoutPrediction('match_1');

        expect(updated.predictions, isEmpty);
      });

      test('does nothing when prediction does not exist', () {
        final prediction = createTestPrediction(matchId: 'match_1');
        final original = WorldCupAIState(predictions: {'match_1': prediction});

        final updated = original.withoutPrediction('match_2');

        expect(updated.predictions, hasLength(1));
        expect(updated.predictions['match_1'], equals(prediction));
      });

      test('preserves other predictions', () {
        final prediction1 = createTestPrediction(matchId: 'match_1');
        final prediction2 = createTestPrediction(matchId: 'match_2');
        final original = WorldCupAIState(
          predictions: {'match_1': prediction1, 'match_2': prediction2},
        );

        final updated = original.withoutPrediction('match_1');

        expect(updated.predictions, hasLength(1));
        expect(updated.predictions['match_2'], equals(prediction2));
      });
    });

    group('withLoading', () {
      test('sets loading state for specific match', () {
        const original = WorldCupAIState();

        final updated = original.withLoading('match_1');

        expect(updated.isLoading, isTrue);
        expect(updated.loadingMatchId, equals('match_1'));
      });

      test('clears any existing error', () {
        const original = WorldCupAIState(
          error: 'Test error',
          errorMatchId: 'match_1',
        );

        final updated = original.withLoading('match_1');

        expect(updated.error, isNull);
        expect(updated.errorMatchId, isNull);
      });
    });

    group('withError', () {
      test('sets error state for specific match', () {
        const original = WorldCupAIState();

        final updated = original.withError('match_1', 'Test error');

        expect(updated.isLoading, isFalse);
        expect(updated.loadingMatchId, isNull);
        expect(updated.error, equals('Test error'));
        expect(updated.errorMatchId, equals('match_1'));
      });

      test('clears loading state', () {
        const original = WorldCupAIState(
          isLoading: true,
          loadingMatchId: 'match_1',
        );

        final updated = original.withError('match_1', 'Test error');

        expect(updated.isLoading, isFalse);
        expect(updated.loadingMatchId, isNull);
      });
    });

    group('Equatable', () {
      test('two states with same props are equal', () {
        final prediction = createTestPrediction();
        final state1 = WorldCupAIState(predictions: {'match_1': prediction});
        final state2 = WorldCupAIState(predictions: {'match_1': prediction});

        expect(state1, equals(state2));
      });

      test('two states with different predictions are not equal', () {
        final prediction1 = createTestPrediction(matchId: 'match_1');
        final prediction2 = createTestPrediction(matchId: 'match_2');
        final state1 = WorldCupAIState(predictions: {'match_1': prediction1});
        final state2 = WorldCupAIState(predictions: {'match_2': prediction2});

        expect(state1, isNot(equals(state2)));
      });

      test('two states with different loading states are not equal', () {
        const state1 = WorldCupAIState(isLoading: true);
        const state2 = WorldCupAIState(isLoading: false);

        expect(state1, isNot(equals(state2)));
      });

      test('props contains all fields', () {
        const state = WorldCupAIState();

        expect(state.props, hasLength(6));
        expect(state.props, contains(state.predictions));
        expect(state.props, contains(state.isLoading));
        expect(state.props, contains(state.loadingMatchId));
        expect(state.props, contains(state.error));
        expect(state.props, contains(state.errorMatchId));
        expect(state.props, contains(state.isAvailable));
      });
    });

    group('toString', () {
      test('returns formatted string', () {
        const state = WorldCupAIState(isLoading: true);
        final str = state.toString();

        expect(str, contains('WorldCupAIState'));
        expect(str, contains('predictions: 0'));
        expect(str, contains('isLoading: true'));
      });

      test('includes error in string when present', () {
        const state = WorldCupAIState(error: 'Test error');
        final str = state.toString();

        expect(str, contains('error: Test error'));
      });
    });
  });
}

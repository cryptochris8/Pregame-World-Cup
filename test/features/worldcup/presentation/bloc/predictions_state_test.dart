import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/worldcup.dart';
import 'mock_repositories.dart';

void main() {
  group('PredictionsState', () {
    final testPredictions = [
      TestDataFactory.createPrediction(
        predictionId: 'pred_1',
        matchId: 'match_1',
        predictedHomeScore: 2,
        predictedAwayScore: 1,
        predictedOutcome: PredictionOutcome.pending,
        actualOutcome: null,
      ),
      TestDataFactory.createPrediction(
        predictionId: 'pred_2',
        matchId: 'match_2',
        predictedHomeScore: 1,
        predictedAwayScore: 1,
        predictedOutcome: PredictionOutcome.draw,
        actualOutcome: PredictionOutcome.correct,
        pointsEarned: 10,
        resultCorrect: true,
      ),
      TestDataFactory.createPrediction(
        predictionId: 'pred_3',
        matchId: 'match_3',
        predictedHomeScore: 3,
        predictedAwayScore: 0,
        predictedOutcome: PredictionOutcome.homeWin,
        actualOutcome: PredictionOutcome.incorrect,
        pointsEarned: 0,
        resultCorrect: false,
      ),
    ];

    const testStats = PredictionStats(
      totalPredictions: 10,
      correctResults: 6,
      exactScores: 2,
      totalPoints: 85,
      pendingPredictions: 3,
    );

    group('Constructor', () {
      test('creates state with default values', () {
        const state = PredictionsState();

        expect(state.predictions, isEmpty);
        expect(state.stats, equals(const PredictionStats()));
        expect(state.isLoading, isFalse);
        expect(state.isSaving, isFalse);
        expect(state.errorMessage, isNull);
        expect(state.successMessage, isNull);
        expect(state.selectedMatchId, isNull);
      });

      test('creates state with custom values', () {
        final state = PredictionsState(
          predictions: testPredictions,
          stats: testStats,
          isLoading: true,
          isSaving: true,
          errorMessage: 'Test error',
          successMessage: 'Success',
          selectedMatchId: 'match_1',
        );

        expect(state.predictions, equals(testPredictions));
        expect(state.stats, equals(testStats));
        expect(state.isLoading, isTrue);
        expect(state.isSaving, isTrue);
        expect(state.errorMessage, equals('Test error'));
        expect(state.successMessage, equals('Success'));
        expect(state.selectedMatchId, equals('match_1'));
      });
    });

    group('initial factory', () {
      test('creates initial state with loading true', () {
        final state = PredictionsState.initial();

        expect(state.predictions, isEmpty);
        expect(state.stats, equals(const PredictionStats()));
        expect(state.isLoading, isTrue);
        expect(state.isSaving, isFalse);
        expect(state.errorMessage, isNull);
      });
    });

    group('upcomingPredictions getter', () {
      test('returns only pending predictions', () {
        final state = PredictionsState(predictions: testPredictions);
        final upcoming = state.upcomingPredictions;

        expect(upcoming, hasLength(1));
        expect(upcoming.every((p) => p.isPending), isTrue);
        expect(upcoming[0].predictionId, equals('pred_1'));
      });

      test('returns empty list when no pending predictions', () {
        final completedOnly = [
          TestDataFactory.createPrediction(
            predictionId: 'pred_1',
            matchId: 'match_1',
            actualOutcome: PredictionOutcome.correct,
          ),
        ];
        final state = PredictionsState(predictions: completedOnly);

        expect(state.upcomingPredictions, isEmpty);
      });
    });

    group('completedPredictions getter', () {
      test('returns only non-pending predictions', () {
        final state = PredictionsState(predictions: testPredictions);
        final completed = state.completedPredictions;

        expect(completed, hasLength(2));
        expect(completed.every((p) => !p.isPending), isTrue);
      });

      test('returns empty list when all predictions are pending', () {
        final pendingOnly = [
          TestDataFactory.createPrediction(
            predictionId: 'pred_1',
            matchId: 'match_1',
            actualOutcome: null,
          ),
        ];
        final state = PredictionsState(predictions: pendingOnly);

        expect(state.completedPredictions, isEmpty);
      });
    });

    group('correctPredictions getter', () {
      test('returns only correct predictions', () {
        final state = PredictionsState(predictions: testPredictions);
        final correct = state.correctPredictions;

        expect(correct, hasLength(1));
        expect(correct.every((p) => p.isCorrect), isTrue);
        expect(correct[0].predictionId, equals('pred_2'));
      });

      test('returns empty list when no correct predictions', () {
        final incorrectOnly = [
          TestDataFactory.createPrediction(
            predictionId: 'pred_1',
            matchId: 'match_1',
            actualOutcome: PredictionOutcome.incorrect,
          ),
        ];
        final state = PredictionsState(predictions: incorrectOnly);

        expect(state.correctPredictions, isEmpty);
      });
    });

    group('hasPredictionForMatch', () {
      test('returns true when prediction exists for match', () {
        final state = PredictionsState(predictions: testPredictions);

        expect(state.hasPredictionForMatch('match_1'), isTrue);
        expect(state.hasPredictionForMatch('match_2'), isTrue);
      });

      test('returns false when prediction does not exist for match', () {
        final state = PredictionsState(predictions: testPredictions);

        expect(state.hasPredictionForMatch('match_999'), isFalse);
      });

      test('returns false when predictions list is empty', () {
        const state = PredictionsState();

        expect(state.hasPredictionForMatch('match_1'), isFalse);
      });
    });

    group('getPredictionForMatch', () {
      test('returns prediction when it exists', () {
        final state = PredictionsState(predictions: testPredictions);
        final prediction = state.getPredictionForMatch('match_2');

        expect(prediction, isNotNull);
        expect(prediction?.predictionId, equals('pred_2'));
        expect(prediction?.matchId, equals('match_2'));
      });

      test('returns null when prediction does not exist', () {
        final state = PredictionsState(predictions: testPredictions);
        final prediction = state.getPredictionForMatch('match_999');

        expect(prediction, isNull);
      });
    });

    group('totalPoints getter', () {
      test('returns total points from stats', () {
        final state = PredictionsState(stats: testStats);

        expect(state.totalPoints, equals(85));
      });

      test('returns 0 when stats is default', () {
        const state = PredictionsState();

        expect(state.totalPoints, equals(0));
      });
    });

    group('copyWith', () {
      test('copies with updated fields', () {
        const original = PredictionsState();
        final updated = original.copyWith(
          predictions: testPredictions,
          stats: testStats,
          isLoading: true,
          isSaving: true,
        );

        expect(updated.predictions, equals(testPredictions));
        expect(updated.stats, equals(testStats));
        expect(updated.isLoading, isTrue);
        expect(updated.isSaving, isTrue);
      });

      test('preserves unchanged fields', () {
        final original = PredictionsState(
          predictions: testPredictions,
          stats: testStats,
        );
        final updated = original.copyWith(isLoading: true);

        expect(updated.predictions, equals(original.predictions));
        expect(updated.stats, equals(original.stats));
        expect(updated.isLoading, isTrue);
      });

      test('clears error when clearError is true', () {
        final original = PredictionsState(errorMessage: 'Test error');
        final updated = original.copyWith(clearError: true);

        expect(updated.errorMessage, isNull);
      });

      test('clears success when clearSuccess is true', () {
        final original = PredictionsState(successMessage: 'Success');
        final updated = original.copyWith(clearSuccess: true);

        expect(updated.successMessage, isNull);
      });

      test('clears selected match when clearSelectedMatch is true', () {
        final original = PredictionsState(selectedMatchId: 'match_1');
        final updated = original.copyWith(clearSelectedMatch: true);

        expect(updated.selectedMatchId, isNull);
      });

      test('sets new values without clearing flags', () {
        const original = PredictionsState();
        final updated = original.copyWith(
          errorMessage: 'New error',
          successMessage: 'New success',
          selectedMatchId: 'match_2',
        );

        expect(updated.errorMessage, equals('New error'));
        expect(updated.successMessage, equals('New success'));
        expect(updated.selectedMatchId, equals('match_2'));
      });
    });

    group('Equatable', () {
      test('two states with same props are equal', () {
        final state1 = PredictionsState(predictions: testPredictions);
        final state2 = PredictionsState(predictions: testPredictions);

        expect(state1, equals(state2));
      });

      test('two states with different predictions are not equal', () {
        final state1 = PredictionsState(predictions: testPredictions);
        final state2 = PredictionsState(predictions: testPredictions.sublist(0, 1));

        expect(state1, isNot(equals(state2)));
      });

      test('two states with different stats are not equal', () {
        final state1 = PredictionsState(stats: testStats);
        const state2 = PredictionsState(
          stats: PredictionStats(
            totalPredictions: 10,
            correctResults: 6,
            exactScores: 2,
            totalPoints: 100,
            pendingPredictions: 3,
          ),
        );

        expect(state1, isNot(equals(state2)));
      });

      test('two states with different loading states are not equal', () {
        const state1 = PredictionsState(isLoading: true);
        const state2 = PredictionsState(isLoading: false);

        expect(state1, isNot(equals(state2)));
      });

      test('props contains all fields', () {
        const state = PredictionsState();

        expect(state.props, hasLength(7));
        expect(state.props, contains(state.predictions));
        expect(state.props, contains(state.stats));
        expect(state.props, contains(state.isLoading));
        expect(state.props, contains(state.isSaving));
        expect(state.props, contains(state.errorMessage));
        expect(state.props, contains(state.successMessage));
        expect(state.props, contains(state.selectedMatchId));
      });
    });
  });
}

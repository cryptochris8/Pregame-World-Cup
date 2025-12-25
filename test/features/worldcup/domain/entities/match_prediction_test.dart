import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/domain/entities/entities.dart';

void main() {
  group('MatchPrediction', () {
    test('calculatedPredictedOutcome returns homeWin when home score higher', () {
      final prediction = MatchPrediction(
        predictionId: 'p1',
        matchId: 'm1',
        predictedHomeScore: 2,
        predictedAwayScore: 1,
        createdAt: DateTime.now(),
      );

      expect(prediction.calculatedPredictedOutcome, equals(PredictionOutcome.homeWin));
    });

    test('calculatedPredictedOutcome returns awayWin when away score higher', () {
      final prediction = MatchPrediction(
        predictionId: 'p1',
        matchId: 'm1',
        predictedHomeScore: 1,
        predictedAwayScore: 3,
        createdAt: DateTime.now(),
      );

      expect(prediction.calculatedPredictedOutcome, equals(PredictionOutcome.awayWin));
    });

    test('calculatedPredictedOutcome returns draw when scores equal', () {
      final prediction = MatchPrediction(
        predictionId: 'p1',
        matchId: 'm1',
        predictedHomeScore: 2,
        predictedAwayScore: 2,
        createdAt: DateTime.now(),
      );

      expect(prediction.calculatedPredictedOutcome, equals(PredictionOutcome.draw));
    });

    test('predictionDisplay returns correct format', () {
      final prediction = MatchPrediction(
        predictionId: 'p1',
        matchId: 'm1',
        predictedHomeScore: 2,
        predictedAwayScore: 1,
        createdAt: DateTime.now(),
      );

      expect(prediction.predictionDisplay, equals('2 - 1'));
    });

    test('isPending returns true when no actual outcome', () {
      final prediction = MatchPrediction(
        predictionId: 'p1',
        matchId: 'm1',
        predictedHomeScore: 2,
        predictedAwayScore: 1,
        createdAt: DateTime.now(),
      );

      expect(prediction.isPending, isTrue);
    });

    test('isPending returns false when actual outcome exists', () {
      final prediction = MatchPrediction(
        predictionId: 'p1',
        matchId: 'm1',
        predictedHomeScore: 2,
        predictedAwayScore: 1,
        actualOutcome: PredictionOutcome.correct,
        createdAt: DateTime.now(),
      );

      expect(prediction.isPending, isFalse);
    });

    test('evaluate returns correct for exact score', () {
      final prediction = MatchPrediction(
        predictionId: 'p1',
        matchId: 'm1',
        predictedHomeScore: 2,
        predictedAwayScore: 1,
        createdAt: DateTime.now(),
      );

      final evaluated = prediction.evaluate(
        actualHomeScore: 2,
        actualAwayScore: 1,
      );

      expect(evaluated.exactScoreCorrect, isTrue);
      expect(evaluated.resultCorrect, isTrue);
      expect(evaluated.pointsEarned, equals(3));
      expect(evaluated.actualOutcome, equals(PredictionOutcome.correct));
    });

    test('evaluate returns correct for result only', () {
      final prediction = MatchPrediction(
        predictionId: 'p1',
        matchId: 'm1',
        predictedHomeScore: 2,
        predictedAwayScore: 1,
        createdAt: DateTime.now(),
      );

      final evaluated = prediction.evaluate(
        actualHomeScore: 3,
        actualAwayScore: 0,
      );

      expect(evaluated.exactScoreCorrect, isFalse);
      expect(evaluated.resultCorrect, isTrue);
      expect(evaluated.pointsEarned, equals(1));
      expect(evaluated.actualOutcome, equals(PredictionOutcome.correct));
    });

    test('evaluate returns incorrect for wrong result', () {
      final prediction = MatchPrediction(
        predictionId: 'p1',
        matchId: 'm1',
        predictedHomeScore: 2,
        predictedAwayScore: 1,
        createdAt: DateTime.now(),
      );

      final evaluated = prediction.evaluate(
        actualHomeScore: 0,
        actualAwayScore: 1,
      );

      expect(evaluated.exactScoreCorrect, isFalse);
      expect(evaluated.resultCorrect, isFalse);
      expect(evaluated.pointsEarned, equals(0));
      expect(evaluated.actualOutcome, equals(PredictionOutcome.incorrect));
    });

    test('fromMap and toMap round-trip correctly', () {
      final original = MatchPrediction(
        predictionId: 'p1',
        matchId: 'm1',
        userId: 'user1',
        predictedHomeScore: 2,
        predictedAwayScore: 1,
        homeTeamCode: 'USA',
        homeTeamName: 'United States',
        awayTeamCode: 'MEX',
        awayTeamName: 'Mexico',
        matchDate: DateTime(2026, 6, 11),
        createdAt: DateTime(2026, 6, 1),
      );

      final map = original.toMap();
      final restored = MatchPrediction.fromMap(map);

      expect(restored.predictionId, equals(original.predictionId));
      expect(restored.matchId, equals(original.matchId));
      expect(restored.predictedHomeScore, equals(original.predictedHomeScore));
      expect(restored.predictedAwayScore, equals(original.predictedAwayScore));
      expect(restored.homeTeamCode, equals(original.homeTeamCode));
      expect(restored.awayTeamCode, equals(original.awayTeamCode));
    });
  });

  group('PredictionStats', () {
    test('fromPredictions calculates stats correctly', () {
      final predictions = [
        MatchPrediction(
          predictionId: 'p1',
          matchId: 'm1',
          predictedHomeScore: 2,
          predictedAwayScore: 1,
          actualOutcome: PredictionOutcome.correct,
          exactScoreCorrect: true,
          resultCorrect: true,
          pointsEarned: 3,
          createdAt: DateTime.now(),
        ),
        MatchPrediction(
          predictionId: 'p2',
          matchId: 'm2',
          predictedHomeScore: 1,
          predictedAwayScore: 0,
          actualOutcome: PredictionOutcome.correct,
          exactScoreCorrect: false,
          resultCorrect: true,
          pointsEarned: 1,
          createdAt: DateTime.now(),
        ),
        MatchPrediction(
          predictionId: 'p3',
          matchId: 'm3',
          predictedHomeScore: 2,
          predictedAwayScore: 0,
          actualOutcome: PredictionOutcome.incorrect,
          exactScoreCorrect: false,
          resultCorrect: false,
          pointsEarned: 0,
          createdAt: DateTime.now(),
        ),
        MatchPrediction(
          predictionId: 'p4',
          matchId: 'm4',
          predictedHomeScore: 1,
          predictedAwayScore: 1,
          createdAt: DateTime.now(),
        ), // Pending
      ];

      final stats = PredictionStats.fromPredictions(predictions);

      expect(stats.totalPredictions, equals(4));
      expect(stats.correctResults, equals(2));
      expect(stats.exactScores, equals(1));
      expect(stats.totalPoints, equals(4));
      expect(stats.pendingPredictions, equals(1));
    });

    test('correctPercentage calculates correctly', () {
      final stats = PredictionStats(
        totalPredictions: 10,
        correctResults: 6,
        pendingPredictions: 2,
      );

      // 6 correct out of 8 evaluated = 75%
      expect(stats.correctPercentage, equals(75.0));
    });

    test('correctPercentage returns 0 when no evaluated predictions', () {
      final stats = PredictionStats(
        totalPredictions: 5,
        correctResults: 0,
        pendingPredictions: 5,
      );

      expect(stats.correctPercentage, equals(0));
    });

    test('averagePoints calculates correctly', () {
      final stats = PredictionStats(
        totalPredictions: 10,
        totalPoints: 12,
        pendingPredictions: 2,
      );

      // 12 points / 8 evaluated = 1.5 average
      expect(stats.averagePoints, equals(1.5));
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/schedule/domain/entities/game_prediction.dart';

void main() {
  group('GamePrediction', () {
    group('Constructor', () {
      test('creates prediction with required fields', () {
        final now = DateTime.now();
        final prediction = GamePrediction(
          predictionId: 'pred_1',
          userId: 'user_1',
          gameId: 'game_1',
          predictedWinner: 'Brazil',
          confidenceLevel: 4,
          createdAt: now,
        );

        expect(prediction.predictionId, equals('pred_1'));
        expect(prediction.userId, equals('user_1'));
        expect(prediction.gameId, equals('game_1'));
        expect(prediction.predictedWinner, equals('Brazil'));
        expect(prediction.confidenceLevel, equals(4));
        expect(prediction.createdAt, equals(now));
        expect(prediction.isCorrect, isNull);
        expect(prediction.pointsEarned, equals(0));
        expect(prediction.isLocked, isFalse);
      });

      test('creates prediction with optional fields', () {
        final now = DateTime.now();
        final prediction = GamePrediction(
          predictionId: 'pred_1',
          userId: 'user_1',
          gameId: 'game_1',
          predictedWinner: 'Argentina',
          predictedHomeScore: 2,
          predictedAwayScore: 1,
          confidenceLevel: 5,
          createdAt: now,
          isCorrect: true,
          pointsEarned: 100,
          isLocked: true,
        );

        expect(prediction.predictedHomeScore, equals(2));
        expect(prediction.predictedAwayScore, equals(1));
        expect(prediction.isCorrect, isTrue);
        expect(prediction.pointsEarned, equals(100));
        expect(prediction.isLocked, isTrue);
      });
    });

    group('copyWith', () {
      test('copies prediction with updated fields', () {
        final now = DateTime.now();
        final original = GamePrediction(
          predictionId: 'pred_1',
          userId: 'user_1',
          gameId: 'game_1',
          predictedWinner: 'Brazil',
          confidenceLevel: 3,
          createdAt: now,
        );

        final updated = original.copyWith(
          predictedWinner: 'Argentina',
          confidenceLevel: 5,
          isLocked: true,
        );

        expect(updated.predictionId, equals('pred_1'));
        expect(updated.predictedWinner, equals('Argentina'));
        expect(updated.confidenceLevel, equals(5));
        expect(updated.isLocked, isTrue);
      });

      test('copies prediction with isCorrect and points', () {
        final now = DateTime.now();
        final original = GamePrediction(
          predictionId: 'pred_1',
          userId: 'user_1',
          gameId: 'game_1',
          predictedWinner: 'Germany',
          confidenceLevel: 4,
          createdAt: now,
        );

        final updated = original.copyWith(
          isCorrect: true,
          pointsEarned: 50,
        );

        expect(updated.isCorrect, isTrue);
        expect(updated.pointsEarned, equals(50));
      });
    });

    group('JSON serialization', () {
      test('toJson serializes correctly', () {
        final now = DateTime(2024, 10, 15, 12, 0, 0);
        final prediction = GamePrediction(
          predictionId: 'pred_1',
          userId: 'user_1',
          gameId: 'game_1',
          predictedWinner: 'France',
          predictedHomeScore: 3,
          predictedAwayScore: 1,
          confidenceLevel: 4,
          createdAt: now,
          isCorrect: true,
          pointsEarned: 75,
          isLocked: true,
        );

        final json = prediction.toJson();

        expect(json['predictionId'], equals('pred_1'));
        expect(json['userId'], equals('user_1'));
        expect(json['gameId'], equals('game_1'));
        expect(json['predictedWinner'], equals('France'));
        expect(json['predictedHomeScore'], equals(3));
        expect(json['predictedAwayScore'], equals(1));
        expect(json['confidenceLevel'], equals(4));
        expect(json['createdAt'], equals('2024-10-15T12:00:00.000'));
        expect(json['isCorrect'], isTrue);
        expect(json['pointsEarned'], equals(75));
        expect(json['isLocked'], isTrue);
      });

      test('fromJson deserializes correctly', () {
        final json = {
          'predictionId': 'pred_1',
          'userId': 'user_1',
          'gameId': 'game_1',
          'predictedWinner': 'Spain',
          'predictedHomeScore': 2,
          'predictedAwayScore': 0,
          'confidenceLevel': 5,
          'createdAt': '2024-10-15T12:00:00.000',
          'isCorrect': false,
          'pointsEarned': 0,
          'isLocked': true,
        };

        final prediction = GamePrediction.fromJson(json);

        expect(prediction.predictionId, equals('pred_1'));
        expect(prediction.predictedWinner, equals('Spain'));
        expect(prediction.predictedHomeScore, equals(2));
        expect(prediction.predictedAwayScore, equals(0));
        expect(prediction.confidenceLevel, equals(5));
        expect(prediction.isCorrect, isFalse);
        expect(prediction.pointsEarned, equals(0));
        expect(prediction.isLocked, isTrue);
      });

      test('fromJson handles null optional fields', () {
        final json = {
          'predictionId': 'pred_1',
          'userId': 'user_1',
          'gameId': 'game_1',
          'predictedWinner': 'Mexico',
          'confidenceLevel': 3,
          'createdAt': '2024-10-15T12:00:00.000',
        };

        final prediction = GamePrediction.fromJson(json);

        expect(prediction.predictedHomeScore, isNull);
        expect(prediction.predictedAwayScore, isNull);
        expect(prediction.isCorrect, isNull);
        expect(prediction.pointsEarned, equals(0));
        expect(prediction.isLocked, isFalse);
      });

      test('roundtrip serialization preserves data', () {
        final now = DateTime(2024, 11, 20, 15, 30, 0);
        final original = GamePrediction(
          predictionId: 'pred_1',
          userId: 'user_1',
          gameId: 'game_1',
          predictedWinner: 'Japan',
          predictedHomeScore: 1,
          predictedAwayScore: 0,
          confidenceLevel: 4,
          createdAt: now,
          isCorrect: true,
          pointsEarned: 80,
          isLocked: true,
        );

        final json = original.toJson();
        final restored = GamePrediction.fromJson(json);

        expect(restored.predictionId, equals(original.predictionId));
        expect(restored.predictedWinner, equals(original.predictedWinner));
        expect(restored.predictedHomeScore, equals(original.predictedHomeScore));
        expect(restored.pointsEarned, equals(original.pointsEarned));
      });
    });

    group('Equatable', () {
      test('two predictions with same props are equal', () {
        final now = DateTime(2024, 10, 15, 12, 0, 0);
        final pred1 = GamePrediction(
          predictionId: 'pred_1',
          userId: 'user_1',
          gameId: 'game_1',
          predictedWinner: 'Brazil',
          confidenceLevel: 4,
          createdAt: now,
        );

        final pred2 = GamePrediction(
          predictionId: 'pred_1',
          userId: 'user_1',
          gameId: 'game_1',
          predictedWinner: 'Brazil',
          confidenceLevel: 4,
          createdAt: now,
        );

        expect(pred1, equals(pred2));
      });

      test('two predictions with different props are not equal', () {
        final now = DateTime.now();
        final pred1 = GamePrediction(
          predictionId: 'pred_1',
          userId: 'user_1',
          gameId: 'game_1',
          predictedWinner: 'Brazil',
          confidenceLevel: 4,
          createdAt: now,
        );

        final pred2 = GamePrediction(
          predictionId: 'pred_2',
          userId: 'user_1',
          gameId: 'game_1',
          predictedWinner: 'Argentina',
          confidenceLevel: 3,
          createdAt: now,
        );

        expect(pred1, isNot(equals(pred2)));
      });
    });
  });

  group('PredictionStats', () {
    group('Constructor', () {
      test('creates stats with default values', () {
        const stats = PredictionStats();

        expect(stats.totalPredictions, equals(0));
        expect(stats.correctPredictions, equals(0));
        expect(stats.currentStreak, equals(0));
        expect(stats.longestStreak, equals(0));
        expect(stats.totalPoints, equals(0));
        expect(stats.rank, equals(0));
      });

      test('creates stats with custom values', () {
        const stats = PredictionStats(
          totalPredictions: 50,
          correctPredictions: 35,
          currentStreak: 5,
          longestStreak: 8,
          totalPoints: 1500,
          rank: 12,
        );

        expect(stats.totalPredictions, equals(50));
        expect(stats.correctPredictions, equals(35));
        expect(stats.currentStreak, equals(5));
        expect(stats.longestStreak, equals(8));
        expect(stats.totalPoints, equals(1500));
        expect(stats.rank, equals(12));
      });
    });

    group('accuracy', () {
      test('calculates accuracy correctly', () {
        const stats = PredictionStats(
          totalPredictions: 100,
          correctPredictions: 75,
        );

        expect(stats.accuracy, equals(75.0));
      });

      test('returns 0 when no predictions made', () {
        const stats = PredictionStats(
          totalPredictions: 0,
          correctPredictions: 0,
        );

        expect(stats.accuracy, equals(0.0));
      });

      test('calculates fractional accuracy', () {
        const stats = PredictionStats(
          totalPredictions: 3,
          correctPredictions: 2,
        );

        expect(stats.accuracy, closeTo(66.67, 0.01));
      });
    });

    group('copyWith', () {
      test('copies stats with updated fields', () {
        const original = PredictionStats(
          totalPredictions: 10,
          correctPredictions: 7,
          currentStreak: 3,
        );

        final updated = original.copyWith(
          totalPredictions: 11,
          correctPredictions: 8,
          currentStreak: 4,
        );

        expect(updated.totalPredictions, equals(11));
        expect(updated.correctPredictions, equals(8));
        expect(updated.currentStreak, equals(4));
        expect(updated.longestStreak, equals(0)); // Unchanged
      });

      test('copies stats preserving unchanged fields', () {
        const original = PredictionStats(
          totalPredictions: 50,
          correctPredictions: 40,
          currentStreak: 5,
          longestStreak: 10,
          totalPoints: 2000,
          rank: 5,
        );

        final updated = original.copyWith(rank: 3);

        expect(updated.totalPredictions, equals(50));
        expect(updated.correctPredictions, equals(40));
        expect(updated.rank, equals(3));
      });
    });

    group('JSON serialization', () {
      test('toJson serializes correctly', () {
        const stats = PredictionStats(
          totalPredictions: 100,
          correctPredictions: 75,
          currentStreak: 8,
          longestStreak: 12,
          totalPoints: 5000,
          rank: 3,
        );

        final json = stats.toJson();

        expect(json['totalPredictions'], equals(100));
        expect(json['correctPredictions'], equals(75));
        expect(json['currentStreak'], equals(8));
        expect(json['longestStreak'], equals(12));
        expect(json['totalPoints'], equals(5000));
        expect(json['rank'], equals(3));
      });

      test('fromJson deserializes correctly', () {
        final json = {
          'totalPredictions': 80,
          'correctPredictions': 60,
          'currentStreak': 4,
          'longestStreak': 9,
          'totalPoints': 3000,
          'rank': 7,
        };

        final stats = PredictionStats.fromJson(json);

        expect(stats.totalPredictions, equals(80));
        expect(stats.correctPredictions, equals(60));
        expect(stats.currentStreak, equals(4));
        expect(stats.longestStreak, equals(9));
        expect(stats.totalPoints, equals(3000));
        expect(stats.rank, equals(7));
      });

      test('fromJson handles missing fields with defaults', () {
        final json = <String, dynamic>{};

        final stats = PredictionStats.fromJson(json);

        expect(stats.totalPredictions, equals(0));
        expect(stats.correctPredictions, equals(0));
        expect(stats.currentStreak, equals(0));
        expect(stats.longestStreak, equals(0));
        expect(stats.totalPoints, equals(0));
        expect(stats.rank, equals(0));
      });

      test('roundtrip serialization preserves data', () {
        const original = PredictionStats(
          totalPredictions: 150,
          correctPredictions: 110,
          currentStreak: 15,
          longestStreak: 20,
          totalPoints: 8500,
          rank: 1,
        );

        final json = original.toJson();
        final restored = PredictionStats.fromJson(json);

        expect(restored.totalPredictions, equals(original.totalPredictions));
        expect(restored.correctPredictions, equals(original.correctPredictions));
        expect(restored.currentStreak, equals(original.currentStreak));
        expect(restored.longestStreak, equals(original.longestStreak));
        expect(restored.totalPoints, equals(original.totalPoints));
        expect(restored.rank, equals(original.rank));
      });
    });

    group('Equatable', () {
      test('two stats with same props are equal', () {
        const stats1 = PredictionStats(
          totalPredictions: 50,
          correctPredictions: 40,
          currentStreak: 5,
        );

        const stats2 = PredictionStats(
          totalPredictions: 50,
          correctPredictions: 40,
          currentStreak: 5,
        );

        expect(stats1, equals(stats2));
      });

      test('two stats with different props are not equal', () {
        const stats1 = PredictionStats(
          totalPredictions: 50,
          correctPredictions: 40,
        );

        const stats2 = PredictionStats(
          totalPredictions: 50,
          correctPredictions: 35,
        );

        expect(stats1, isNot(equals(stats2)));
      });
    });
  });
}

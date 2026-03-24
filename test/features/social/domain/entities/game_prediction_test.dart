import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/social/domain/entities/game_prediction.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('GamePrediction', () {
    final testCreatedAt = DateTime(2024, 1, 15, 10, 30);

    test('constructor creates instance with required parameters', () {
      final prediction = GamePrediction(
        predictionId: 'pred123',
        userId: 'user123',
        gameId: 'game456',
        userDisplayName: 'John Doe',
        predictedWinner: 'Team A',
        createdAt: testCreatedAt,
      );

      expect(prediction.predictionId, 'pred123');
      expect(prediction.userId, 'user123');
      expect(prediction.gameId, 'game456');
      expect(prediction.userDisplayName, 'John Doe');
      expect(prediction.predictedWinner, 'Team A');
      expect(prediction.createdAt, testCreatedAt);
    });

    test('constructor with default values', () {
      final prediction = GamePrediction(
        predictionId: 'pred123',
        userId: 'user123',
        gameId: 'game456',
        userDisplayName: 'John Doe',
        predictedWinner: 'Team A',
        createdAt: testCreatedAt,
      );

      expect(prediction.likes, 0);
      expect(prediction.likedBy, isEmpty);
      expect(prediction.userProfileImageUrl, isNull);
      expect(prediction.predictedAwayScore, isNull);
      expect(prediction.predictedHomeScore, isNull);
      expect(prediction.confidence, isNull);
      expect(prediction.reasoning, isNull);
      expect(prediction.isCorrect, isNull);
    });

    test('copyWith preserves unchanged fields', () {
      final original = GamePrediction(
        predictionId: 'pred123',
        userId: 'user123',
        gameId: 'game456',
        userDisplayName: 'John Doe',
        userProfileImageUrl: 'https://example.com/photo.jpg',
        predictedWinner: 'Team A',
        predictedAwayScore: 2,
        predictedHomeScore: 1,
        confidence: 'high',
        reasoning: 'Team A has better form',
        createdAt: testCreatedAt,
        isCorrect: true,
        likes: 5,
        likedBy: ['user1', 'user2'],
      );

      final copied = original.copyWith();

      expect(copied.predictionId, 'pred123');
      expect(copied.userId, 'user123');
      expect(copied.gameId, 'game456');
      expect(copied.userDisplayName, 'John Doe');
      expect(copied.userProfileImageUrl, 'https://example.com/photo.jpg');
      expect(copied.predictedWinner, 'Team A');
      expect(copied.predictedAwayScore, 2);
      expect(copied.predictedHomeScore, 1);
      expect(copied.confidence, 'high');
      expect(copied.reasoning, 'Team A has better form');
      expect(copied.createdAt, testCreatedAt);
      expect(copied.isCorrect, true);
      expect(copied.likes, 5);
      expect(copied.likedBy, ['user1', 'user2']);
    });

    test('copyWith updates specified fields', () {
      final original = GamePrediction(
        predictionId: 'pred123',
        userId: 'user123',
        gameId: 'game456',
        userDisplayName: 'John Doe',
        predictedWinner: 'Team A',
        createdAt: testCreatedAt,
        likes: 5,
        likedBy: ['user1', 'user2'],
      );

      final copied = original.copyWith(
        userDisplayName: 'Jane Smith',
        likes: 10,
        likedBy: ['user1', 'user2', 'user3'],
        isCorrect: true,
        confidence: 'high',
      );

      expect(copied.userDisplayName, 'Jane Smith');
      expect(copied.likes, 10);
      expect(copied.likedBy, ['user1', 'user2', 'user3']);
      expect(copied.isCorrect, true);
      expect(copied.confidence, 'high');

      // Unchanged fields preserved
      expect(copied.predictionId, 'pred123');
      expect(copied.userId, 'user123');
      expect(copied.gameId, 'game456');
      expect(copied.predictedWinner, 'Team A');
      expect(copied.createdAt, testCreatedAt);
    });

    test('toFirestore returns correct map structure', () {
      final prediction = GamePrediction(
        predictionId: 'pred123',
        userId: 'user123',
        gameId: 'game456',
        userDisplayName: 'John Doe',
        userProfileImageUrl: 'https://example.com/photo.jpg',
        predictedWinner: 'Team A',
        predictedAwayScore: 2,
        predictedHomeScore: 1,
        confidence: 'high',
        reasoning: 'Team A has better form',
        createdAt: testCreatedAt,
        isCorrect: true,
        likes: 5,
        likedBy: ['user1', 'user2'],
      );

      final firestoreMap = prediction.toFirestore();

      expect(firestoreMap['userId'], 'user123');
      expect(firestoreMap['gameId'], 'game456');
      expect(firestoreMap['userDisplayName'], 'John Doe');
      expect(firestoreMap['userProfileImageUrl'], 'https://example.com/photo.jpg');
      expect(firestoreMap['predictedWinner'], 'Team A');
      expect(firestoreMap['predictedAwayScore'], 2);
      expect(firestoreMap['predictedHomeScore'], 1);
      expect(firestoreMap['confidence'], 'high');
      expect(firestoreMap['reasoning'], 'Team A has better form');
      expect(firestoreMap['createdAt'], isA<Timestamp>());
      expect(firestoreMap['isCorrect'], true);
      expect(firestoreMap['likes'], 5);
      expect(firestoreMap['likedBy'], ['user1', 'user2']);
    });

    test('toFirestore handles null values correctly', () {
      final prediction = GamePrediction(
        predictionId: 'pred123',
        userId: 'user123',
        gameId: 'game456',
        userDisplayName: 'John Doe',
        predictedWinner: 'Team A',
        createdAt: testCreatedAt,
      );

      final firestoreMap = prediction.toFirestore();

      expect(firestoreMap['userProfileImageUrl'], isNull);
      expect(firestoreMap['predictedAwayScore'], isNull);
      expect(firestoreMap['predictedHomeScore'], isNull);
      expect(firestoreMap['confidence'], isNull);
      expect(firestoreMap['reasoning'], isNull);
      expect(firestoreMap['isCorrect'], isNull);
      expect(firestoreMap['likes'], 0);
      expect(firestoreMap['likedBy'], isEmpty);
    });
  });
}

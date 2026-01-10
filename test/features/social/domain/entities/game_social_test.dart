import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pregame_world_cup/features/social/domain/entities/game_prediction.dart'
    as social;
import 'package:pregame_world_cup/features/social/domain/entities/game_comment.dart';

// Mock Timestamp for testing
class MockTimestamp {
  final DateTime _dateTime;
  MockTimestamp(this._dateTime);
  DateTime toDate() => _dateTime;
  static MockTimestamp fromDate(DateTime dateTime) => MockTimestamp(dateTime);
}

void main() {
  group('GamePrediction (Social)', () {
    group('Constructor', () {
      test('creates prediction with required fields', () {
        final now = DateTime.now();
        final prediction = social.GamePrediction(
          predictionId: 'pred_1',
          userId: 'user_1',
          gameId: 'game_1',
          userDisplayName: 'John Doe',
          predictedWinner: 'Georgia',
          createdAt: now,
        );

        expect(prediction.predictionId, equals('pred_1'));
        expect(prediction.userId, equals('user_1'));
        expect(prediction.gameId, equals('game_1'));
        expect(prediction.userDisplayName, equals('John Doe'));
        expect(prediction.predictedWinner, equals('Georgia'));
        expect(prediction.createdAt, equals(now));
        expect(prediction.likes, equals(0));
        expect(prediction.likedBy, isEmpty);
      });

      test('creates prediction with optional fields', () {
        final now = DateTime.now();
        final prediction = social.GamePrediction(
          predictionId: 'pred_1',
          userId: 'user_1',
          gameId: 'game_1',
          userDisplayName: 'Jane Smith',
          userProfileImageUrl: 'https://example.com/avatar.jpg',
          predictedWinner: 'Alabama',
          predictedAwayScore: 28,
          predictedHomeScore: 21,
          confidence: 'high',
          reasoning: 'Strong passing game',
          createdAt: now,
          isCorrect: true,
          likes: 15,
          likedBy: ['user_2', 'user_3'],
        );

        expect(prediction.userProfileImageUrl, equals('https://example.com/avatar.jpg'));
        expect(prediction.predictedAwayScore, equals(28));
        expect(prediction.predictedHomeScore, equals(21));
        expect(prediction.confidence, equals('high'));
        expect(prediction.reasoning, equals('Strong passing game'));
        expect(prediction.isCorrect, isTrue);
        expect(prediction.likes, equals(15));
        expect(prediction.likedBy, hasLength(2));
      });
    });

    group('toFirestore', () {
      test('serializes all fields correctly', () {
        final now = DateTime(2024, 10, 15, 12, 0, 0);
        final prediction = social.GamePrediction(
          predictionId: 'pred_1',
          userId: 'user_1',
          gameId: 'game_1',
          userDisplayName: 'Test User',
          userProfileImageUrl: 'https://example.com/avatar.jpg',
          predictedWinner: 'LSU',
          predictedAwayScore: 24,
          predictedHomeScore: 17,
          confidence: 'medium',
          reasoning: 'Home field advantage',
          createdAt: now,
          isCorrect: false,
          likes: 10,
          likedBy: ['user_2'],
        );

        final map = prediction.toFirestore();

        expect(map['userId'], equals('user_1'));
        expect(map['gameId'], equals('game_1'));
        expect(map['userDisplayName'], equals('Test User'));
        expect(map['userProfileImageUrl'], equals('https://example.com/avatar.jpg'));
        expect(map['predictedWinner'], equals('LSU'));
        expect(map['predictedAwayScore'], equals(24));
        expect(map['predictedHomeScore'], equals(17));
        expect(map['confidence'], equals('medium'));
        expect(map['reasoning'], equals('Home field advantage'));
        expect(map['isCorrect'], isFalse);
        expect(map['likes'], equals(10));
        expect(map['likedBy'], equals(['user_2']));
      });
    });

    group('copyWith', () {
      test('copies prediction with updated fields', () {
        final now = DateTime.now();
        final original = social.GamePrediction(
          predictionId: 'pred_1',
          userId: 'user_1',
          gameId: 'game_1',
          userDisplayName: 'Test User',
          predictedWinner: 'Florida',
          createdAt: now,
        );

        final updated = original.copyWith(
          predictedWinner: 'Tennessee',
          confidence: 'high',
          isCorrect: true,
          likes: 25,
        );

        expect(updated.predictionId, equals('pred_1'));
        expect(updated.predictedWinner, equals('Tennessee'));
        expect(updated.confidence, equals('high'));
        expect(updated.isCorrect, isTrue);
        expect(updated.likes, equals(25));
      });

      test('copies prediction preserving unchanged fields', () {
        final now = DateTime.now();
        final original = social.GamePrediction(
          predictionId: 'pred_1',
          userId: 'user_1',
          gameId: 'game_1',
          userDisplayName: 'Test User',
          userProfileImageUrl: 'https://example.com/avatar.jpg',
          predictedWinner: 'Auburn',
          confidence: 'low',
          createdAt: now,
          likes: 5,
          likedBy: ['user_2'],
        );

        final updated = original.copyWith(likes: 10);

        expect(updated.userId, equals('user_1'));
        expect(updated.userDisplayName, equals('Test User'));
        expect(updated.userProfileImageUrl, equals('https://example.com/avatar.jpg'));
        expect(updated.predictedWinner, equals('Auburn'));
        expect(updated.confidence, equals('low'));
        expect(updated.likes, equals(10));
        expect(updated.likedBy, equals(['user_2']));
      });
    });
  });

  group('GameComment', () {
    group('Constructor', () {
      test('creates comment with required fields', () {
        final now = DateTime.now();
        final comment = GameComment(
          commentId: 'comment_1',
          userId: 'user_1',
          gameId: 'game_1',
          userDisplayName: 'John Doe',
          content: 'Great game so far!',
          createdAt: now,
        );

        expect(comment.commentId, equals('comment_1'));
        expect(comment.userId, equals('user_1'));
        expect(comment.gameId, equals('game_1'));
        expect(comment.userDisplayName, equals('John Doe'));
        expect(comment.content, equals('Great game so far!'));
        expect(comment.createdAt, equals(now));
        expect(comment.likes, equals(0));
        expect(comment.likedBy, isEmpty);
        expect(comment.parentCommentId, isNull);
        expect(comment.replies, isEmpty);
      });

      test('creates comment with optional fields', () {
        final now = DateTime.now();
        final comment = GameComment(
          commentId: 'comment_1',
          userId: 'user_1',
          gameId: 'game_1',
          userDisplayName: 'Jane Smith',
          userProfileImageUrl: 'https://example.com/avatar.jpg',
          content: 'I agree!',
          createdAt: now,
          updatedAt: now,
          likes: 10,
          likedBy: ['user_2', 'user_3'],
          parentCommentId: 'comment_0',
          replies: ['comment_2', 'comment_3'],
        );

        expect(comment.userProfileImageUrl, equals('https://example.com/avatar.jpg'));
        expect(comment.updatedAt, equals(now));
        expect(comment.likes, equals(10));
        expect(comment.likedBy, hasLength(2));
        expect(comment.parentCommentId, equals('comment_0'));
        expect(comment.replies, hasLength(2));
      });
    });

    group('toFirestore', () {
      test('serializes all fields correctly', () {
        final now = DateTime(2024, 10, 15, 12, 0, 0);
        final later = DateTime(2024, 10, 15, 12, 5, 0);
        final comment = GameComment(
          commentId: 'comment_1',
          userId: 'user_1',
          gameId: 'game_1',
          userDisplayName: 'Test User',
          userProfileImageUrl: 'https://example.com/avatar.jpg',
          content: 'Test comment',
          createdAt: now,
          updatedAt: later,
          likes: 5,
          likedBy: ['user_2'],
          parentCommentId: 'parent_1',
          replies: ['reply_1'],
        );

        final map = comment.toFirestore();

        expect(map['userId'], equals('user_1'));
        expect(map['gameId'], equals('game_1'));
        expect(map['userDisplayName'], equals('Test User'));
        expect(map['userProfileImageUrl'], equals('https://example.com/avatar.jpg'));
        expect(map['content'], equals('Test comment'));
        expect(map['likes'], equals(5));
        expect(map['likedBy'], equals(['user_2']));
        expect(map['parentCommentId'], equals('parent_1'));
        expect(map['replies'], equals(['reply_1']));
      });
    });

    group('copyWith', () {
      test('copies comment with updated fields', () {
        final now = DateTime.now();
        final original = GameComment(
          commentId: 'comment_1',
          userId: 'user_1',
          gameId: 'game_1',
          userDisplayName: 'Test User',
          content: 'Original content',
          createdAt: now,
        );

        final later = DateTime.now();
        final updated = original.copyWith(
          content: 'Updated content',
          updatedAt: later,
          likes: 15,
        );

        expect(updated.commentId, equals('comment_1'));
        expect(updated.content, equals('Updated content'));
        expect(updated.updatedAt, equals(later));
        expect(updated.likes, equals(15));
      });

      test('copies comment preserving unchanged fields', () {
        final now = DateTime.now();
        final original = GameComment(
          commentId: 'comment_1',
          userId: 'user_1',
          gameId: 'game_1',
          userDisplayName: 'Test User',
          userProfileImageUrl: 'https://example.com/avatar.jpg',
          content: 'My comment',
          createdAt: now,
          likes: 8,
          likedBy: ['user_2', 'user_3'],
        );

        final updated = original.copyWith(likes: 12);

        expect(updated.userId, equals('user_1'));
        expect(updated.userDisplayName, equals('Test User'));
        expect(updated.userProfileImageUrl, equals('https://example.com/avatar.jpg'));
        expect(updated.content, equals('My comment'));
        expect(updated.likes, equals(12));
        expect(updated.likedBy, equals(['user_2', 'user_3']));
      });

      test('copies comment adding replies', () {
        final now = DateTime.now();
        final original = GameComment(
          commentId: 'comment_1',
          userId: 'user_1',
          gameId: 'game_1',
          userDisplayName: 'Test User',
          content: 'Parent comment',
          createdAt: now,
          replies: ['reply_1'],
        );

        final updated = original.copyWith(
          replies: ['reply_1', 'reply_2', 'reply_3'],
        );

        expect(updated.replies, hasLength(3));
        expect(updated.replies, contains('reply_3'));
      });
    });
  });
}

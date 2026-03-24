import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/social/domain/entities/game_comment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('GameComment', () {
    final testCreatedAt = DateTime(2024, 1, 15, 10, 30);
    final testUpdatedAt = DateTime(2024, 1, 15, 11, 45);

    test('constructor creates instance with required parameters', () {
      final comment = GameComment(
        commentId: 'comment123',
        userId: 'user123',
        gameId: 'game456',
        userDisplayName: 'John Doe',
        content: 'Great game!',
        createdAt: testCreatedAt,
      );

      expect(comment.commentId, 'comment123');
      expect(comment.userId, 'user123');
      expect(comment.gameId, 'game456');
      expect(comment.userDisplayName, 'John Doe');
      expect(comment.content, 'Great game!');
      expect(comment.createdAt, testCreatedAt);
    });

    test('constructor with default values', () {
      final comment = GameComment(
        commentId: 'comment123',
        userId: 'user123',
        gameId: 'game456',
        userDisplayName: 'John Doe',
        content: 'Great game!',
        createdAt: testCreatedAt,
      );

      expect(comment.likes, 0);
      expect(comment.likedBy, isEmpty);
      expect(comment.replies, isEmpty);
      expect(comment.userProfileImageUrl, isNull);
      expect(comment.updatedAt, isNull);
      expect(comment.parentCommentId, isNull);
    });

    test('constructor with all optional parameters', () {
      final comment = GameComment(
        commentId: 'comment123',
        userId: 'user123',
        gameId: 'game456',
        userDisplayName: 'John Doe',
        userProfileImageUrl: 'https://example.com/photo.jpg',
        content: 'Great game!',
        createdAt: testCreatedAt,
        updatedAt: testUpdatedAt,
        likes: 10,
        likedBy: ['user1', 'user2', 'user3'],
        parentCommentId: 'parent123',
        replies: ['reply1', 'reply2'],
      );

      expect(comment.userProfileImageUrl, 'https://example.com/photo.jpg');
      expect(comment.updatedAt, testUpdatedAt);
      expect(comment.likes, 10);
      expect(comment.likedBy, ['user1', 'user2', 'user3']);
      expect(comment.parentCommentId, 'parent123');
      expect(comment.replies, ['reply1', 'reply2']);
    });

    test('copyWith preserves unchanged fields', () {
      final original = GameComment(
        commentId: 'comment123',
        userId: 'user123',
        gameId: 'game456',
        userDisplayName: 'John Doe',
        userProfileImageUrl: 'https://example.com/photo.jpg',
        content: 'Great game!',
        createdAt: testCreatedAt,
        updatedAt: testUpdatedAt,
        likes: 5,
        likedBy: ['user1', 'user2'],
        parentCommentId: 'parent123',
        replies: ['reply1'],
      );

      final copied = original.copyWith();

      expect(copied.commentId, 'comment123');
      expect(copied.userId, 'user123');
      expect(copied.gameId, 'game456');
      expect(copied.userDisplayName, 'John Doe');
      expect(copied.userProfileImageUrl, 'https://example.com/photo.jpg');
      expect(copied.content, 'Great game!');
      expect(copied.createdAt, testCreatedAt);
      expect(copied.updatedAt, testUpdatedAt);
      expect(copied.likes, 5);
      expect(copied.likedBy, ['user1', 'user2']);
      expect(copied.parentCommentId, 'parent123');
      expect(copied.replies, ['reply1']);
    });

    test('copyWith updates specified fields', () {
      final original = GameComment(
        commentId: 'comment123',
        userId: 'user123',
        gameId: 'game456',
        userDisplayName: 'John Doe',
        content: 'Great game!',
        createdAt: testCreatedAt,
        likes: 5,
        likedBy: ['user1', 'user2'],
      );

      final copied = original.copyWith(
        userDisplayName: 'Jane Smith',
        content: 'Amazing match!',
        likes: 10,
        likedBy: ['user1', 'user2', 'user3'],
        replies: ['reply1', 'reply2'],
        updatedAt: testUpdatedAt,
      );

      expect(copied.userDisplayName, 'Jane Smith');
      expect(copied.content, 'Amazing match!');
      expect(copied.likes, 10);
      expect(copied.likedBy, ['user1', 'user2', 'user3']);
      expect(copied.replies, ['reply1', 'reply2']);
      expect(copied.updatedAt, testUpdatedAt);

      // Unchanged fields preserved
      expect(copied.commentId, 'comment123');
      expect(copied.userId, 'user123');
      expect(copied.gameId, 'game456');
      expect(copied.createdAt, testCreatedAt);
    });

    test('toFirestore returns correct map structure', () {
      final comment = GameComment(
        commentId: 'comment123',
        userId: 'user123',
        gameId: 'game456',
        userDisplayName: 'John Doe',
        userProfileImageUrl: 'https://example.com/photo.jpg',
        content: 'Great game!',
        createdAt: testCreatedAt,
        updatedAt: testUpdatedAt,
        likes: 10,
        likedBy: ['user1', 'user2', 'user3'],
        parentCommentId: 'parent123',
        replies: ['reply1', 'reply2'],
      );

      final firestoreMap = comment.toFirestore();

      expect(firestoreMap['userId'], 'user123');
      expect(firestoreMap['gameId'], 'game456');
      expect(firestoreMap['userDisplayName'], 'John Doe');
      expect(firestoreMap['userProfileImageUrl'], 'https://example.com/photo.jpg');
      expect(firestoreMap['content'], 'Great game!');
      expect(firestoreMap['createdAt'], isA<Timestamp>());
      expect(firestoreMap['updatedAt'], isA<Timestamp>());
      expect(firestoreMap['likes'], 10);
      expect(firestoreMap['likedBy'], ['user1', 'user2', 'user3']);
      expect(firestoreMap['parentCommentId'], 'parent123');
      expect(firestoreMap['replies'], ['reply1', 'reply2']);
    });

    test('toFirestore handles null values correctly', () {
      final comment = GameComment(
        commentId: 'comment123',
        userId: 'user123',
        gameId: 'game456',
        userDisplayName: 'John Doe',
        content: 'Great game!',
        createdAt: testCreatedAt,
      );

      final firestoreMap = comment.toFirestore();

      expect(firestoreMap['userProfileImageUrl'], isNull);
      expect(firestoreMap['updatedAt'], isNull);
      expect(firestoreMap['parentCommentId'], isNull);
      expect(firestoreMap['likes'], 0);
      expect(firestoreMap['likedBy'], isEmpty);
      expect(firestoreMap['replies'], isEmpty);
    });
  });
}

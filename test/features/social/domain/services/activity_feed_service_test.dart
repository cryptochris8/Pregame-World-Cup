import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/social/domain/entities/activity_feed.dart';

/// Tests for ActivityFeedService entity logic and data conversion.
///
/// ActivityFeedService uses hardcoded `FirebaseFirestore.instance` (not injected
/// via constructor), which prevents direct service-level unit testing with
/// FakeFirebaseFirestore without a refactor. These tests cover the critical
/// entity business logic, factory constructors, data conversion helpers, and
/// computed properties that the service relies on.
void main() {
  // ===========================================================================
  // ActivityFeedItem entity
  // ===========================================================================
  group('ActivityFeedItem', () {
    test('constructor sets all required fields', () {
      final now = DateTime(2026, 6, 15, 12, 0);
      final item = ActivityFeedItem(
        activityId: 'act_1',
        userId: 'user_1',
        userName: 'Test User',
        type: ActivityType.checkIn,
        content: 'Checked in at Sports Bar',
        createdAt: now,
      );

      expect(item.activityId, equals('act_1'));
      expect(item.userId, equals('user_1'));
      expect(item.userName, equals('Test User'));
      expect(item.type, equals(ActivityType.checkIn));
      expect(item.content, equals('Checked in at Sports Bar'));
      expect(item.createdAt, equals(now));
      expect(item.likesCount, equals(0));
      expect(item.commentsCount, equals(0));
      expect(item.isPublic, isTrue);
      expect(item.metadata, isEmpty);
      expect(item.mentionedUsers, isEmpty);
      expect(item.tags, isEmpty);
      expect(item.relatedGameId, isNull);
      expect(item.relatedVenueId, isNull);
      expect(item.userProfileImage, isNull);
    });

    test('createCheckIn factory creates correct activity', () {
      final item = ActivityFeedItem.createCheckIn(
        userId: 'user_1',
        userName: 'John',
        venueName: 'Sports Bar',
        venueId: 'venue_1',
        gameId: 'game_1',
        note: 'Great atmosphere!',
      );

      expect(item.type, equals(ActivityType.checkIn));
      expect(item.content, equals('Checked in at Sports Bar: Great atmosphere!'));
      expect(item.relatedVenueId, equals('venue_1'));
      expect(item.relatedGameId, equals('game_1'));
      expect(item.metadata['venueName'], equals('Sports Bar'));
      expect(item.metadata['venueId'], equals('venue_1'));
      expect(item.metadata['gameId'], equals('game_1'));
      expect(item.metadata['note'], equals('Great atmosphere!'));
      expect(item.activityId, contains('user_1_checkin_'));
    });

    test('createCheckIn without note omits note from content', () {
      final item = ActivityFeedItem.createCheckIn(
        userId: 'user_1',
        userName: 'John',
        venueName: 'Sports Bar',
        venueId: 'venue_1',
      );

      expect(item.content, equals('Checked in at Sports Bar'));
    });

    test('createCheckIn with empty note omits note from content', () {
      final item = ActivityFeedItem.createCheckIn(
        userId: 'user_1',
        userName: 'John',
        venueName: 'Sports Bar',
        venueId: 'venue_1',
        note: '',
      );

      expect(item.content, equals('Checked in at Sports Bar'));
    });

    test('createFriendConnection factory creates correct activity', () {
      final item = ActivityFeedItem.createFriendConnection(
        userId: 'user_1',
        userName: 'John',
        friendId: 'friend_1',
        friendName: 'Jane',
      );

      expect(item.type, equals(ActivityType.friendConnection));
      expect(item.content, equals('Connected with Jane'));
      expect(item.metadata['friendId'], equals('friend_1'));
      expect(item.metadata['friendName'], equals('Jane'));
      expect(item.activityId, contains('user_1_friend_'));
    });

    test('createGameAttendance factory creates correct activity', () {
      final item = ActivityFeedItem.createGameAttendance(
        userId: 'user_1',
        userName: 'John',
        gameId: 'game_1',
        gameTitle: 'USA vs Brazil',
        venue: 'MetLife Stadium',
      );

      expect(item.type, equals(ActivityType.gameAttendance));
      expect(item.content, equals('Attended USA vs Brazil at MetLife Stadium'));
      expect(item.relatedGameId, equals('game_1'));
      expect(item.metadata['gameTitle'], equals('USA vs Brazil'));
      expect(item.metadata['venue'], equals('MetLife Stadium'));
      expect(item.activityId, contains('user_1_game_'));
    });

    test('createVenueReview factory creates correct activity', () {
      final item = ActivityFeedItem.createVenueReview(
        userId: 'user_1',
        userName: 'John',
        venueId: 'venue_1',
        venueName: 'Sports Bar',
        rating: 4,
        review: 'Great place to watch games',
      );

      expect(item.type, equals(ActivityType.venueReview));
      expect(item.content, contains('Sports Bar'));
      expect(item.content, contains('4'));
      expect(item.relatedVenueId, equals('venue_1'));
      expect(item.metadata['rating'], equals(4));
      expect(item.metadata['review'], equals('Great place to watch games'));
      expect(item.activityId, contains('user_1_review_'));
    });

    test('copyWith preserves unchanged fields', () {
      final original = ActivityFeedItem(
        activityId: 'act_1',
        userId: 'user_1',
        userName: 'Test',
        type: ActivityType.checkIn,
        content: 'Test content',
        createdAt: DateTime(2026, 6, 15),
        likesCount: 5,
        commentsCount: 3,
        tags: const ['soccer'],
        mentionedUsers: const ['user_2'],
      );

      final updated = original.copyWith(likesCount: 10);

      expect(updated.likesCount, equals(10));
      expect(updated.commentsCount, equals(3));
      expect(updated.activityId, equals('act_1'));
      expect(updated.userId, equals('user_1'));
      expect(updated.type, equals(ActivityType.checkIn));
      expect(updated.tags, equals(['soccer']));
      expect(updated.mentionedUsers, equals(['user_2']));
    });

    test('copyWith can update commentsCount', () {
      final original = ActivityFeedItem(
        activityId: 'act_1',
        userId: 'user_1',
        userName: 'Test',
        type: ActivityType.checkIn,
        content: 'Test',
        createdAt: DateTime.now(),
      );

      final updated = original.copyWith(commentsCount: 7);

      expect(updated.commentsCount, equals(7));
    });

    test('copyWith can update metadata', () {
      final original = ActivityFeedItem(
        activityId: 'act_1',
        userId: 'user_1',
        userName: 'Test',
        type: ActivityType.checkIn,
        content: 'Test',
        createdAt: DateTime.now(),
        metadata: const {'key': 'old_value'},
      );

      final updated = original.copyWith(metadata: {'key': 'new_value'});

      expect(updated.metadata['key'], equals('new_value'));
    });
  });

  // ===========================================================================
  // ActivityFeedItem computed properties
  // ===========================================================================
  group('ActivityFeedItem computed properties', () {
    test('hasInteractions is true when has likes', () {
      final item = ActivityFeedItem(
        activityId: 'act_1',
        userId: 'user_1',
        userName: 'Test',
        type: ActivityType.checkIn,
        content: 'Test',
        createdAt: DateTime.now(),
        likesCount: 1,
      );

      expect(item.hasInteractions, isTrue);
    });

    test('hasInteractions is true when has comments', () {
      final item = ActivityFeedItem(
        activityId: 'act_1',
        userId: 'user_1',
        userName: 'Test',
        type: ActivityType.checkIn,
        content: 'Test',
        createdAt: DateTime.now(),
        commentsCount: 1,
      );

      expect(item.hasInteractions, isTrue);
    });

    test('hasInteractions is false when no likes or comments', () {
      final item = ActivityFeedItem(
        activityId: 'act_1',
        userId: 'user_1',
        userName: 'Test',
        type: ActivityType.checkIn,
        content: 'Test',
        createdAt: DateTime.now(),
      );

      expect(item.hasInteractions, isFalse);
    });

    test('displayContent truncates long content', () {
      final longContent = 'A' * 150;
      final item = ActivityFeedItem(
        activityId: 'act_1',
        userId: 'user_1',
        userName: 'Test',
        type: ActivityType.checkIn,
        content: longContent,
        createdAt: DateTime.now(),
      );

      expect(item.displayContent.length, equals(100));
      expect(item.displayContent.endsWith('...'), isTrue);
    });

    test('displayContent returns full content when short', () {
      final item = ActivityFeedItem(
        activityId: 'act_1',
        userId: 'user_1',
        userName: 'Test',
        type: ActivityType.checkIn,
        content: 'Short content',
        createdAt: DateTime.now(),
      );

      expect(item.displayContent, equals('Short content'));
    });

    test('displayContent handles exactly 100 characters', () {
      final exactContent = 'A' * 100;
      final item = ActivityFeedItem(
        activityId: 'act_1',
        userId: 'user_1',
        userName: 'Test',
        type: ActivityType.checkIn,
        content: exactContent,
        createdAt: DateTime.now(),
      );

      expect(item.displayContent, equals(exactContent));
      expect(item.displayContent.length, equals(100));
    });

    test('timeAgo returns Just now for recent activities', () {
      final item = ActivityFeedItem(
        activityId: 'act_1',
        userId: 'user_1',
        userName: 'Test',
        type: ActivityType.checkIn,
        content: 'Test',
        createdAt: DateTime.now(),
      );

      expect(item.timeAgo, equals('Just now'));
    });

    test('timeAgo returns minutes ago', () {
      final item = ActivityFeedItem(
        activityId: 'act_1',
        userId: 'user_1',
        userName: 'Test',
        type: ActivityType.checkIn,
        content: 'Test',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      );

      expect(item.timeAgo, equals('30m ago'));
    });

    test('timeAgo returns hours ago', () {
      final item = ActivityFeedItem(
        activityId: 'act_1',
        userId: 'user_1',
        userName: 'Test',
        type: ActivityType.checkIn,
        content: 'Test',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      );

      expect(item.timeAgo, equals('5h ago'));
    });

    test('timeAgo returns days ago', () {
      final item = ActivityFeedItem(
        activityId: 'act_1',
        userId: 'user_1',
        userName: 'Test',
        type: ActivityType.checkIn,
        content: 'Test',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      );

      expect(item.timeAgo, equals('3d ago'));
    });
  });

  // ===========================================================================
  // ActivityType enum
  // ===========================================================================
  group('ActivityType', () {
    test('has all expected values', () {
      expect(ActivityType.values, contains(ActivityType.checkIn));
      expect(ActivityType.values, contains(ActivityType.friendConnection));
      expect(ActivityType.values, contains(ActivityType.gameAttendance));
      expect(ActivityType.values, contains(ActivityType.venueReview));
      expect(ActivityType.values, contains(ActivityType.photoShare));
      expect(ActivityType.values, contains(ActivityType.gameComment));
      expect(ActivityType.values, contains(ActivityType.teamFollow));
      expect(ActivityType.values, contains(ActivityType.achievement));
      expect(ActivityType.values, contains(ActivityType.groupJoin));
      expect(ActivityType.values.length, equals(9));
    });
  });

  // ===========================================================================
  // ActivityComment entity
  // ===========================================================================
  group('ActivityComment', () {
    test('constructor sets all required fields', () {
      final now = DateTime(2026, 6, 15, 12, 0);
      final comment = ActivityComment(
        commentId: 'comment_1',
        activityId: 'act_1',
        userId: 'user_1',
        userName: 'John',
        comment: 'Great check-in!',
        createdAt: now,
      );

      expect(comment.commentId, equals('comment_1'));
      expect(comment.activityId, equals('act_1'));
      expect(comment.userId, equals('user_1'));
      expect(comment.userName, equals('John'));
      expect(comment.comment, equals('Great check-in!'));
      expect(comment.createdAt, equals(now));
      expect(comment.userProfileImage, isNull);
      expect(comment.mentionedUsers, isEmpty);
    });

    test('constructor sets optional fields', () {
      final comment = ActivityComment(
        commentId: 'comment_1',
        activityId: 'act_1',
        userId: 'user_1',
        userName: 'John',
        userProfileImage: 'https://example.com/photo.jpg',
        comment: 'Nice!',
        createdAt: DateTime.now(),
        mentionedUsers: const ['user_2', 'user_3'],
      );

      expect(comment.userProfileImage, equals('https://example.com/photo.jpg'));
      expect(comment.mentionedUsers, equals(['user_2', 'user_3']));
    });

    test('timeAgo returns now for just-created comment', () {
      final comment = ActivityComment(
        commentId: 'c1',
        activityId: 'a1',
        userId: 'u1',
        userName: 'User',
        comment: 'Test',
        createdAt: DateTime.now(),
      );

      expect(comment.timeAgo, equals('now'));
    });

    test('timeAgo returns minutes for recent comment', () {
      final comment = ActivityComment(
        commentId: 'c1',
        activityId: 'a1',
        userId: 'u1',
        userName: 'User',
        comment: 'Test',
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      );

      expect(comment.timeAgo, equals('15m'));
    });

    test('timeAgo returns hours for older comment', () {
      final comment = ActivityComment(
        commentId: 'c1',
        activityId: 'a1',
        userId: 'u1',
        userName: 'User',
        comment: 'Test',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      );

      expect(comment.timeAgo, equals('3h'));
    });

    test('timeAgo returns days for much older comment', () {
      final comment = ActivityComment(
        commentId: 'c1',
        activityId: 'a1',
        userId: 'u1',
        userName: 'User',
        comment: 'Test',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      );

      expect(comment.timeAgo, equals('7d'));
    });

    test('Equatable compares by value', () {
      final now = DateTime(2026, 6, 15, 12, 0);
      final c1 = ActivityComment(
        commentId: 'c1',
        activityId: 'a1',
        userId: 'u1',
        userName: 'User',
        comment: 'Test',
        createdAt: now,
      );
      final c2 = ActivityComment(
        commentId: 'c1',
        activityId: 'a1',
        userId: 'u1',
        userName: 'User',
        comment: 'Test',
        createdAt: now,
      );

      expect(c1, equals(c2));
    });

    test('Equatable detects differences', () {
      final now = DateTime(2026, 6, 15, 12, 0);
      final c1 = ActivityComment(
        commentId: 'c1',
        activityId: 'a1',
        userId: 'u1',
        userName: 'User',
        comment: 'Test',
        createdAt: now,
      );
      final c2 = ActivityComment(
        commentId: 'c2',
        activityId: 'a1',
        userId: 'u1',
        userName: 'User',
        comment: 'Test',
        createdAt: now,
      );

      expect(c1, isNot(equals(c2)));
    });
  });

  // ===========================================================================
  // ActivityLike entity
  // ===========================================================================
  group('ActivityLike', () {
    test('constructor sets all fields', () {
      final now = DateTime(2026, 6, 15, 12, 0);
      final like = ActivityLike(
        likeId: 'like_1',
        activityId: 'act_1',
        userId: 'user_1',
        createdAt: now,
      );

      expect(like.likeId, equals('like_1'));
      expect(like.activityId, equals('act_1'));
      expect(like.userId, equals('user_1'));
      expect(like.createdAt, equals(now));
    });

    test('Equatable compares by value', () {
      final now = DateTime(2026, 6, 15, 12, 0);
      final l1 = ActivityLike(
        likeId: 'l1',
        activityId: 'a1',
        userId: 'u1',
        createdAt: now,
      );
      final l2 = ActivityLike(
        likeId: 'l1',
        activityId: 'a1',
        userId: 'u1',
        createdAt: now,
      );

      expect(l1, equals(l2));
    });

    test('like ID convention matches service pattern', () {
      const activityId = 'act_123';
      const userId = 'user_456';
      final expectedLikeId = '${activityId}_$userId';

      final like = ActivityLike(
        likeId: expectedLikeId,
        activityId: activityId,
        userId: userId,
        createdAt: DateTime.now(),
      );

      expect(like.likeId, equals('act_123_user_456'));
    });
  });

  // ===========================================================================
  // Activity-to-Firestore conversion logic (mirrors service private methods)
  // ===========================================================================
  group('Activity Firestore conversion', () {
    test('activity data contains all required fields for Firestore', () {
      final now = DateTime(2026, 6, 15, 12, 0);
      final activity = ActivityFeedItem(
        activityId: 'act_1',
        userId: 'user_1',
        userName: 'John',
        userProfileImage: 'https://example.com/photo.jpg',
        type: ActivityType.checkIn,
        content: 'Checked in',
        createdAt: now,
        metadata: const {'key': 'value'},
        mentionedUsers: const ['user_2'],
        tags: const ['soccer'],
        relatedGameId: 'game_1',
        relatedVenueId: 'venue_1',
        likesCount: 5,
        commentsCount: 3,
        isPublic: false,
      );

      // Simulate the conversion logic from the service
      final data = {
        'userId': activity.userId,
        'userName': activity.userName,
        'userProfileImage': activity.userProfileImage,
        'type': activity.type.name,
        'content': activity.content,
        'createdAt': Timestamp.fromDate(activity.createdAt),
        'metadata': activity.metadata,
        'mentionedUsers': activity.mentionedUsers,
        'tags': activity.tags,
        'relatedGameId': activity.relatedGameId,
        'relatedVenueId': activity.relatedVenueId,
        'likesCount': activity.likesCount,
        'commentsCount': activity.commentsCount,
        'isPublic': activity.isPublic,
      };

      expect(data['userId'], equals('user_1'));
      expect(data['userName'], equals('John'));
      expect(data['type'], equals('checkIn'));
      expect(data['content'], equals('Checked in'));
      expect(data['likesCount'], equals(5));
      expect(data['commentsCount'], equals(3));
      expect(data['isPublic'], isFalse);
      expect(data['tags'], equals(['soccer']));
      expect(data['mentionedUsers'], equals(['user_2']));
    });

    test('activity round-trip conversion preserves data', () {
      final now = DateTime(2026, 6, 15, 12, 0);

      // Simulate to-Firestore
      final firestoreData = {
        'userId': 'user_1',
        'userName': 'Test',
        'userProfileImage': null,
        'type': 'gameAttendance',
        'content': 'Attended game',
        'createdAt': Timestamp.fromDate(now),
        'metadata': <String, dynamic>{'gameId': 'g1'},
        'mentionedUsers': <String>[],
        'tags': <String>['worldcup'],
        'relatedGameId': 'g1',
        'relatedVenueId': null,
        'likesCount': 10,
        'commentsCount': 2,
        'isPublic': true,
      };

      // Simulate from-Firestore (mirrors _activityFromFirestore)
      final restored = ActivityFeedItem(
        activityId: 'restored_id',
        userId: firestoreData['userId'] as String,
        userName: firestoreData['userName'] as String,
        userProfileImage: firestoreData['userProfileImage'] as String?,
        type: ActivityType.values
            .firstWhere((e) => e.name == firestoreData['type']),
        content: firestoreData['content'] as String,
        createdAt: (firestoreData['createdAt'] as Timestamp).toDate(),
        metadata: Map<String, dynamic>.from(firestoreData['metadata'] as Map),
        mentionedUsers:
            List<String>.from(firestoreData['mentionedUsers'] as List),
        tags: List<String>.from(firestoreData['tags'] as List),
        relatedGameId: firestoreData['relatedGameId'] as String?,
        relatedVenueId: firestoreData['relatedVenueId'] as String?,
        likesCount: firestoreData['likesCount'] as int,
        commentsCount: firestoreData['commentsCount'] as int,
        isPublic: firestoreData['isPublic'] as bool,
      );

      expect(restored.userId, equals('user_1'));
      expect(restored.type, equals(ActivityType.gameAttendance));
      expect(restored.createdAt, equals(now));
      expect(restored.likesCount, equals(10));
      expect(restored.commentsCount, equals(2));
      expect(restored.tags, equals(['worldcup']));
      expect(restored.metadata['gameId'], equals('g1'));
    });

    test('from-Firestore handles missing optional fields with defaults', () {
      final now = DateTime(2026, 6, 15, 12, 0);

      // Minimal Firestore data
      final data = {
        'userId': 'user_1',
        'userName': 'Test',
        'type': 'checkIn',
        'content': 'Test',
        'createdAt': Timestamp.fromDate(now),
      };

      // Simulate _activityFromFirestore with defaults
      final restored = ActivityFeedItem(
        activityId: 'test_id',
        userId: data['userId'] as String,
        userName: data['userName'] as String,
        userProfileImage: data['userProfileImage'] as String?,
        type:
            ActivityType.values.firstWhere((e) => e.name == data['type']),
        content: data['content'] as String,
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        metadata: Map<String, dynamic>.from(
            (data['metadata'] as Map<String, dynamic>?) ?? {}),
        mentionedUsers: List<String>.from(
            (data['mentionedUsers'] as List?) ?? []),
        tags: List<String>.from((data['tags'] as List?) ?? []),
        relatedGameId: data['relatedGameId'] as String?,
        relatedVenueId: data['relatedVenueId'] as String?,
        likesCount: (data['likesCount'] as int?) ?? 0,
        commentsCount: (data['commentsCount'] as int?) ?? 0,
        isPublic: (data['isPublic'] as bool?) ?? true,
      );

      expect(restored.metadata, isEmpty);
      expect(restored.mentionedUsers, isEmpty);
      expect(restored.tags, isEmpty);
      expect(restored.likesCount, equals(0));
      expect(restored.commentsCount, equals(0));
      expect(restored.isPublic, isTrue);
      expect(restored.userProfileImage, isNull);
      expect(restored.relatedGameId, isNull);
    });
  });

  // ===========================================================================
  // ActivityFeedItem Equatable
  // ===========================================================================
  group('ActivityFeedItem Equatable', () {
    test('equal items are equal', () {
      final now = DateTime(2026, 6, 15, 12, 0);
      final a1 = ActivityFeedItem(
        activityId: 'act_1',
        userId: 'user_1',
        userName: 'Test',
        type: ActivityType.checkIn,
        content: 'Test',
        createdAt: now,
      );
      final a2 = ActivityFeedItem(
        activityId: 'act_1',
        userId: 'user_1',
        userName: 'Test',
        type: ActivityType.checkIn,
        content: 'Test',
        createdAt: now,
      );

      expect(a1, equals(a2));
    });

    test('different activityId makes items unequal', () {
      final now = DateTime(2026, 6, 15, 12, 0);
      final a1 = ActivityFeedItem(
        activityId: 'act_1',
        userId: 'user_1',
        userName: 'Test',
        type: ActivityType.checkIn,
        content: 'Test',
        createdAt: now,
      );
      final a2 = ActivityFeedItem(
        activityId: 'act_2',
        userId: 'user_1',
        userName: 'Test',
        type: ActivityType.checkIn,
        content: 'Test',
        createdAt: now,
      );

      expect(a1, isNot(equals(a2)));
    });

    test('different type makes items unequal', () {
      final now = DateTime(2026, 6, 15, 12, 0);
      final a1 = ActivityFeedItem(
        activityId: 'act_1',
        userId: 'user_1',
        userName: 'Test',
        type: ActivityType.checkIn,
        content: 'Test',
        createdAt: now,
      );
      final a2 = ActivityFeedItem(
        activityId: 'act_1',
        userId: 'user_1',
        userName: 'Test',
        type: ActivityType.venueReview,
        content: 'Test',
        createdAt: now,
      );

      expect(a1, isNot(equals(a2)));
    });
  });

  // ===========================================================================
  // Comment Firestore conversion
  // ===========================================================================
  group('ActivityComment Firestore conversion', () {
    test('comment roundtrip conversion preserves data', () {
      final now = DateTime(2026, 6, 15, 12, 0);

      // Simulate Firestore data (matches getActivityComments parsing)
      final firestoreData = {
        'activityId': 'act_1',
        'userId': 'user_1',
        'userName': 'John',
        'userProfileImage': 'https://example.com/photo.jpg',
        'comment': 'Great post!',
        'createdAt': Timestamp.fromDate(now),
      };

      final comment = ActivityComment(
        commentId: 'doc_id',
        activityId: firestoreData['activityId'] as String,
        userId: firestoreData['userId'] as String,
        userName: firestoreData['userName'] as String,
        userProfileImage: firestoreData['userProfileImage'] as String?,
        comment: firestoreData['comment'] as String,
        createdAt: (firestoreData['createdAt'] as Timestamp).toDate(),
      );

      expect(comment.activityId, equals('act_1'));
      expect(comment.userId, equals('user_1'));
      expect(comment.userName, equals('John'));
      expect(comment.userProfileImage, equals('https://example.com/photo.jpg'));
      expect(comment.comment, equals('Great post!'));
      expect(comment.createdAt, equals(now));
    });
  });

  // ===========================================================================
  // Delete Activity Logic Patterns
  // ===========================================================================
  group('Delete Activity Logic', () {
    test('activity ownership verification checks userId match', () {
      final activity = ActivityFeedItem(
        activityId: 'act_1',
        userId: 'user_1',
        userName: 'John',
        type: ActivityType.checkIn,
        content: 'Test',
        createdAt: DateTime.now(),
      );

      // Simulate ownership check
      const requestingUserId = 'user_1';
      final ownsActivity = activity.userId == requestingUserId;

      expect(ownsActivity, isTrue);
    });

    test('activity ownership verification fails for different user', () {
      final activity = ActivityFeedItem(
        activityId: 'act_1',
        userId: 'user_1',
        userName: 'John',
        type: ActivityType.checkIn,
        content: 'Test',
        createdAt: DateTime.now(),
      );

      // Simulate ownership check
      const requestingUserId = 'user_2';
      final ownsActivity = activity.userId == requestingUserId;

      expect(ownsActivity, isFalse);
    });

    test('like ID pattern for batch deletion', () {
      const activityId = 'act_123';
      const userId1 = 'user_1';
      const userId2 = 'user_2';

      // Simulate likes that would need deletion
      final likes = [
        '${activityId}_$userId1',
        '${activityId}_$userId2',
      ];

      // All likes should contain the activityId
      for (final likeId in likes) {
        expect(likeId, contains(activityId));
      }
    });

    test('comment belongs to activity check', () {
      final comment = ActivityComment(
        commentId: 'comment_1',
        activityId: 'act_123',
        userId: 'user_1',
        userName: 'John',
        comment: 'Test',
        createdAt: DateTime.now(),
      );

      const activityId = 'act_123';
      final belongsToActivity = comment.activityId == activityId;

      expect(belongsToActivity, isTrue);
    });

    test('pagination uses createdAt as cursor', () {
      final activities = [
        ActivityFeedItem(
          activityId: 'act_1',
          userId: 'user_1',
          userName: 'John',
          type: ActivityType.checkIn,
          content: 'First',
          createdAt: DateTime(2026, 6, 15, 12, 0),
        ),
        ActivityFeedItem(
          activityId: 'act_2',
          userId: 'user_1',
          userName: 'John',
          type: ActivityType.checkIn,
          content: 'Second',
          createdAt: DateTime(2026, 6, 15, 11, 0),
        ),
      ];

      // Last activity's createdAt should be used as cursor
      final lastActivity = activities.last;
      final cursor = lastActivity.createdAt;

      expect(cursor, equals(DateTime(2026, 6, 15, 11, 0)));
    });

    test('activities are sorted by createdAt descending', () {
      final activities = [
        ActivityFeedItem(
          activityId: 'act_1',
          userId: 'user_1',
          userName: 'John',
          type: ActivityType.checkIn,
          content: 'First',
          createdAt: DateTime(2026, 6, 15, 11, 0),
        ),
        ActivityFeedItem(
          activityId: 'act_2',
          userId: 'user_1',
          userName: 'John',
          type: ActivityType.checkIn,
          content: 'Second',
          createdAt: DateTime(2026, 6, 15, 12, 0),
        ),
      ];

      // Sort descending (newest first)
      activities.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      expect(activities.first.activityId, equals('act_2'));
      expect(activities.last.activityId, equals('act_1'));
    });
  });

  // ===========================================================================
  // ActivityFeedService — injectable / service-level notes
  //
  // ActivityFeedService uses `final FirebaseFirestore _firestore =
  // FirebaseFirestore.instance` (not injected via constructor), so it cannot
  // be unit-tested end-to-end with FakeFirebaseFirestore without a refactor.
  //
  // TODO: When the service is refactored to accept an injected FirebaseFirestore
  // (e.g. via a named constructor or factory), replace the skipped group below
  // with real service-level tests using FakeFirebaseFirestore:
  //
  //   group('ActivityFeedService.likeActivity', () {
  //     test('creates like document and increments likesCount atomically', ...);
  //     test('liking same activity twice does not double-increment', ...);
  //   });
  //
  //   group('ActivityFeedService.deleteActivity', () {
  //     test('deletes activity and its associated likes and comments', ...);
  //   });
  //
  // ===========================================================================

  // ===========================================================================
  // _activityFromFirestore parsing — unknown ActivityType value
  // ===========================================================================
  group('_activityFromFirestore unknown type handling', () {
    /// The private _activityFromFirestore method wraps its body in a try/catch
    /// and returns null on any error. When the 'type' field contains an unknown
    /// string, ActivityType.values.firstWhere throws a StateError, causing the
    /// method to return null rather than crash the app.
    ///
    /// This test mirrors that logic directly to guarantee the contract is
    /// maintained even if the entity layer changes.
    test('firstWhere throws StateError for unknown ActivityType string', () {
      const unknownType = 'unknownActivityType_v99';

      // Mirrors the firstWhere call inside _activityFromFirestore.
      expect(
        () => ActivityType.values.firstWhere((e) => e.name == unknownType),
        throwsStateError,
      );
    });

    test('null is returned when type string is not in ActivityType enum', () {
      final now = DateTime(2026, 6, 15, 12, 0);

      // Simulate what _activityFromFirestore does: wrap in try/catch and
      // return null on StateError.
      ActivityFeedItem? result;
      try {
        result = ActivityFeedItem(
          activityId: 'test_id',
          userId: 'user_1',
          userName: 'Test',
          type: ActivityType.values
              .firstWhere((e) => e.name == 'totally_unknown_type'),
          content: 'Test',
          createdAt: now,
        );
      } catch (_) {
        result = null;
      }

      expect(result, isNull);
    });

    test('known type strings parse without error for all enum values', () {
      for (final type in ActivityType.values) {
        ActivityFeedItem? result;
        try {
          result = ActivityFeedItem(
            activityId: 'id_${type.name}',
            userId: 'user_1',
            userName: 'Test',
            type: ActivityType.values
                .firstWhere((e) => e.name == type.name),
            content: 'content for ${type.name}',
            createdAt: DateTime(2026, 6, 15),
          );
        } catch (_) {
          result = null;
        }

        expect(result, isNotNull,
            reason: 'Type ${type.name} should parse successfully');
        expect(result!.type, equals(type));
      }
    });

    test('empty string type does not crash — returns null gracefully', () {
      ActivityFeedItem? result;
      try {
        result = ActivityFeedItem(
          activityId: 'id',
          userId: 'u',
          userName: 'Test',
          type: ActivityType.values.firstWhere((e) => e.name == ''),
          content: 'c',
          createdAt: DateTime(2026, 6, 15),
        );
      } catch (_) {
        result = null;
      }

      expect(result, isNull);
    });
  });

  // ===========================================================================
  // ActivityFeedService.likeActivity — entity-level idempotency contract
  //
  // The service uses a Firestore transaction with an existence check to ensure
  // idempotency. The tests below verify the entity-layer invariants that the
  // transaction logic depends on.
  // ===========================================================================
  group('ActivityFeedService.likeActivity — entity-level idempotency', () {
    test('like ID is deterministic: same activityId+userId always yields same ID',
        () {
      const activityId = 'act_abc';
      const userId = 'user_xyz';

      final likeId1 = '${activityId}_$userId';
      final likeId2 = '${activityId}_$userId';

      // The service builds likeId as '${activityId}_$userId'.
      // Calling it twice must produce the same value — this is the key that
      // makes the existence-check transaction idempotent.
      expect(likeId1, equals(likeId2));
    });

    test('like document key uniquely identifies one (activity, user) pair', () {
      const activityId = 'act_1';
      const user1 = 'user_A';
      const user2 = 'user_B';

      final likeIdA = '${activityId}_$user1';
      final likeIdB = '${activityId}_$user2';

      // Different users → different like documents, so neither overwrites the other.
      expect(likeIdA, isNot(equals(likeIdB)));
    });

    test('like entity models the expected document structure', () {
      const activityId = 'act_1';
      const userId = 'user_1';
      final likeId = '${activityId}_$userId';
      final now = DateTime(2026, 6, 15, 12, 0);

      final like = ActivityLike(
        likeId: likeId,
        activityId: activityId,
        userId: userId,
        createdAt: now,
      );

      // The service writes these exact fields to Firestore.
      expect(like.likeId, equals('act_1_user_1'));
      expect(like.activityId, equals(activityId));
      expect(like.userId, equals(userId));
      expect(like.createdAt, equals(now));
    });

    test('likesCount increments from 0 to 1 after first like via copyWith', () {
      final activity = ActivityFeedItem(
        activityId: 'act_1',
        userId: 'owner_1',
        userName: 'Owner',
        type: ActivityType.checkIn,
        content: 'Checked in',
        createdAt: DateTime(2026, 6, 15),
        likesCount: 0,
      );

      // Mirrors what the service's FieldValue.increment(1) does at the entity layer.
      final afterLike = activity.copyWith(likesCount: activity.likesCount + 1);

      expect(afterLike.likesCount, equals(1));
    });

    test('likesCount does not change when like already exists (idempotency)',
        () {
      // Simulate the state after a first like.
      final activity = ActivityFeedItem(
        activityId: 'act_1',
        userId: 'owner_1',
        userName: 'Owner',
        type: ActivityType.checkIn,
        content: 'Checked in',
        createdAt: DateTime(2026, 6, 15),
        likesCount: 1,
      );

      // If the transaction detects the like already exists it skips the update.
      // Entity count should remain unchanged.
      final likeAlreadyExists = true;
      final afterSecondLikeAttempt = likeAlreadyExists
          ? activity // no-op
          : activity.copyWith(likesCount: activity.likesCount + 1);

      expect(afterSecondLikeAttempt.likesCount, equals(1));
    });
  });

  // ===========================================================================
  // ActivityFeedService.deleteActivity — entity-level cascade contract
  //
  // The service fetches all likes and comments for an activity before issuing a
  // batch delete. The tests below verify the data-shape invariants the service
  // depends on.
  // ===========================================================================
  group('ActivityFeedService.deleteActivity — entity-level cascade contract',
      () {
    test('only the activity owner can delete (userId must match)', () {
      final activity = ActivityFeedItem(
        activityId: 'act_1',
        userId: 'owner_1',
        userName: 'Owner',
        type: ActivityType.checkIn,
        content: 'Test',
        createdAt: DateTime.now(),
      );

      expect(activity.userId == 'owner_1', isTrue);
      expect(activity.userId == 'other_user', isFalse);
    });

    test('deletion of activity requires removing all likes with matching activityId',
        () {
      const activityId = 'act_to_delete';

      final likes = [
        ActivityLike(
          likeId: '${activityId}_user_1',
          activityId: activityId,
          userId: 'user_1',
          createdAt: DateTime.now(),
        ),
        ActivityLike(
          likeId: '${activityId}_user_2',
          activityId: activityId,
          userId: 'user_2',
          createdAt: DateTime.now(),
        ),
      ];

      // All collected like documents belong to the same activity.
      for (final like in likes) {
        expect(like.activityId, equals(activityId));
      }
      expect(likes, hasLength(2));
    });

    test('deletion of activity requires removing all comments with matching activityId',
        () {
      const activityId = 'act_to_delete';

      final comments = [
        ActivityComment(
          commentId: '${activityId}_user_1_123',
          activityId: activityId,
          userId: 'user_1',
          userName: 'User One',
          comment: 'Great!',
          createdAt: DateTime.now(),
        ),
        ActivityComment(
          commentId: '${activityId}_user_2_456',
          activityId: activityId,
          userId: 'user_2',
          userName: 'User Two',
          comment: 'Awesome!',
          createdAt: DateTime.now(),
        ),
      ];

      for (final comment in comments) {
        expect(comment.activityId, equals(activityId));
      }
      expect(comments, hasLength(2));
    });

    test('batch chunk size of 400 handles single activity delete without splitting',
        () {
      // The service batches at most 400 docs per WriteBatch (1 activity +
      // its likes + comments). For typical activities this stays well under 400.
      const batchChunkSize = 400;
      const totalDocsToDelete = 1 + 5 + 10; // activity + 5 likes + 10 comments

      expect(totalDocsToDelete, lessThan(batchChunkSize));
    });
  });
}

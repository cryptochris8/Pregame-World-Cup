import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/social/domain/entities/activity_feed.dart';

/// Tests for ActivityFeedItem, ActivityComment, ActivityLike, and ActivityType
void main() {
  group('ActivityFeedItem', () {
    group('constructor', () {
      test('creates item with required fields', () {
        final item = ActivityFeedItem(
          activityId: 'activity_001',
          userId: 'user_001',
          userName: 'John Doe',
          type: ActivityType.checkIn,
          content: 'Checked in at Sports Bar',
          createdAt: DateTime.now(),
        );

        expect(item.activityId, equals('activity_001'));
        expect(item.userId, equals('user_001'));
        expect(item.userName, equals('John Doe'));
        expect(item.type, equals(ActivityType.checkIn));
        expect(item.content, equals('Checked in at Sports Bar'));
      });

      test('has correct default values', () {
        final item = ActivityFeedItem(
          activityId: 'activity_002',
          userId: 'user_002',
          userName: 'Jane Doe',
          type: ActivityType.gameAttendance,
          content: 'Attended the game',
          createdAt: DateTime.now(),
        );

        expect(item.metadata, isEmpty);
        expect(item.mentionedUsers, isEmpty);
        expect(item.tags, isEmpty);
        expect(item.relatedGameId, isNull);
        expect(item.relatedVenueId, isNull);
        expect(item.likesCount, equals(0));
        expect(item.commentsCount, equals(0));
        expect(item.isPublic, isTrue);
      });
    });

    group('createCheckIn factory', () {
      test('creates check-in with venue info', () {
        final item = ActivityFeedItem.createCheckIn(
          userId: 'user_001',
          userName: 'Fan User',
          venueName: 'Stadium Sports Bar',
          venueId: 'venue_001',
        );

        expect(item.type, equals(ActivityType.checkIn));
        expect(item.content, contains('Stadium Sports Bar'));
        expect(item.relatedVenueId, equals('venue_001'));
        expect(item.metadata['venueName'], equals('Stadium Sports Bar'));
      });

      test('creates check-in with note', () {
        final item = ActivityFeedItem.createCheckIn(
          userId: 'user_001',
          userName: 'Fan User',
          venueName: 'Sports Bar',
          venueId: 'venue_001',
          note: 'Great atmosphere!',
        );

        expect(item.content, contains('Great atmosphere!'));
        expect(item.metadata['note'], equals('Great atmosphere!'));
      });

      test('creates check-in with game reference', () {
        final item = ActivityFeedItem.createCheckIn(
          userId: 'user_001',
          userName: 'Fan User',
          venueName: 'Bar',
          venueId: 'venue_001',
          gameId: 'game_001',
        );

        expect(item.relatedGameId, equals('game_001'));
        expect(item.metadata['gameId'], equals('game_001'));
      });

      test('generates unique activity ID', () {
        final item1 = ActivityFeedItem.createCheckIn(
          userId: 'user_001',
          userName: 'User',
          venueName: 'Bar',
          venueId: 'venue_001',
        );

        // Create a second item to verify ID format
        final item2 = ActivityFeedItem.createCheckIn(
          userId: 'user_001',
          userName: 'User',
          venueName: 'Bar',
          venueId: 'venue_001',
        );

        expect(item1.activityId, contains('user_001_checkin_'));
        expect(item2.activityId, contains('user_001_checkin_'));
      });
    });

    group('createFriendConnection factory', () {
      test('creates friend connection activity', () {
        final item = ActivityFeedItem.createFriendConnection(
          userId: 'user_001',
          userName: 'John',
          friendId: 'user_002',
          friendName: 'Jane',
        );

        expect(item.type, equals(ActivityType.friendConnection));
        expect(item.content, contains('Jane'));
        expect(item.metadata['friendId'], equals('user_002'));
        expect(item.metadata['friendName'], equals('Jane'));
      });
    });

    group('createGameAttendance factory', () {
      test('creates game attendance activity', () {
        final item = ActivityFeedItem.createGameAttendance(
          userId: 'user_001',
          userName: 'Fan',
          gameId: 'game_001',
          gameTitle: 'Brazil vs Argentina',
          venue: 'MetLife Stadium',
        );

        expect(item.type, equals(ActivityType.gameAttendance));
        expect(item.content, contains('Brazil vs Argentina'));
        expect(item.content, contains('MetLife Stadium'));
        expect(item.relatedGameId, equals('game_001'));
        expect(item.metadata['gameTitle'], equals('Brazil vs Argentina'));
      });
    });

    group('createVenueReview factory', () {
      test('creates venue review activity', () {
        final item = ActivityFeedItem.createVenueReview(
          userId: 'user_001',
          userName: 'Reviewer',
          venueId: 'venue_001',
          venueName: 'Sports Bar',
          rating: 4,
          review: 'Great place to watch the game!',
        );

        expect(item.type, equals(ActivityType.venueReview));
        expect(item.content, contains('Sports Bar'));
        expect(item.content, contains('4'));
        expect(item.content, contains('Great place'));
        expect(item.relatedVenueId, equals('venue_001'));
        expect(item.metadata['rating'], equals(4));
        expect(item.metadata['review'], equals('Great place to watch the game!'));
      });
    });

    group('computed properties', () {
      test('timeAgo returns Just now for very recent', () {
        final item = _createActivity(
          createdAt: DateTime.now().subtract(const Duration(seconds: 30)),
        );
        expect(item.timeAgo, equals('Just now'));
      });

      test('timeAgo returns minutes ago', () {
        final item = _createActivity(
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        );
        expect(item.timeAgo, equals('30m ago'));
      });

      test('timeAgo returns hours ago', () {
        final item = _createActivity(
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        );
        expect(item.timeAgo, equals('5h ago'));
      });

      test('timeAgo returns days ago', () {
        final item = _createActivity(
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        );
        expect(item.timeAgo, equals('3d ago'));
      });

      test('hasInteractions returns false when no likes or comments', () {
        final item = _createActivity(likesCount: 0, commentsCount: 0);
        expect(item.hasInteractions, isFalse);
      });

      test('hasInteractions returns true when has likes', () {
        final item = _createActivity(likesCount: 5, commentsCount: 0);
        expect(item.hasInteractions, isTrue);
      });

      test('hasInteractions returns true when has comments', () {
        final item = _createActivity(likesCount: 0, commentsCount: 3);
        expect(item.hasInteractions, isTrue);
      });

      test('displayContent returns full content when short', () {
        final item = _createActivity(content: 'Short content');
        expect(item.displayContent, equals('Short content'));
      });

      test('displayContent truncates long content', () {
        final longContent = 'A' * 150; // 150 characters
        final item = _createActivity(content: longContent);
        expect(item.displayContent.length, equals(100));
        expect(item.displayContent.endsWith('...'), isTrue);
      });
    });

    group('copyWith', () {
      test('copies with changed likes count', () {
        final original = _createActivity(likesCount: 5);
        final copied = original.copyWith(likesCount: 10);

        expect(copied.likesCount, equals(10));
        expect(copied.activityId, equals(original.activityId));
      });

      test('copies with changed comments count', () {
        final original = _createActivity(commentsCount: 3);
        final copied = original.copyWith(commentsCount: 8);

        expect(copied.commentsCount, equals(8));
      });

      test('copies with changed metadata', () {
        final original = _createActivity();
        final copied = original.copyWith(
          metadata: {'newKey': 'newValue'},
        );

        expect(copied.metadata['newKey'], equals('newValue'));
      });
    });
  });

  group('ActivityType enum', () {
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
    });

    test('has correct number of values', () {
      expect(ActivityType.values.length, equals(9));
    });
  });

  group('ActivityComment', () {
    test('creates comment with required fields', () {
      final comment = ActivityComment(
        commentId: 'comment_001',
        activityId: 'activity_001',
        userId: 'user_001',
        userName: 'Commenter',
        comment: 'Great post!',
        createdAt: DateTime.now(),
      );

      expect(comment.commentId, equals('comment_001'));
      expect(comment.activityId, equals('activity_001'));
      expect(comment.userId, equals('user_001'));
      expect(comment.userName, equals('Commenter'));
      expect(comment.comment, equals('Great post!'));
    });

    test('has correct default values', () {
      final comment = ActivityComment(
        commentId: 'comment_002',
        activityId: 'activity_002',
        userId: 'user_002',
        userName: 'User',
        comment: 'Comment text',
        createdAt: DateTime.now(),
      );

      expect(comment.userProfileImage, isNull);
      expect(comment.mentionedUsers, isEmpty);
    });

    test('timeAgo returns now for very recent', () {
      final comment = ActivityComment(
        commentId: 'comment_003',
        activityId: 'activity_003',
        userId: 'user_003',
        userName: 'User',
        comment: 'Comment',
        createdAt: DateTime.now().subtract(const Duration(seconds: 30)),
      );
      expect(comment.timeAgo, equals('now'));
    });

    test('timeAgo returns minutes', () {
      final comment = ActivityComment(
        commentId: 'comment_004',
        activityId: 'activity_004',
        userId: 'user_004',
        userName: 'User',
        comment: 'Comment',
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      );
      expect(comment.timeAgo, equals('45m'));
    });

    test('timeAgo returns hours', () {
      final comment = ActivityComment(
        commentId: 'comment_005',
        activityId: 'activity_005',
        userId: 'user_005',
        userName: 'User',
        comment: 'Comment',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      );
      expect(comment.timeAgo, equals('6h'));
    });

    test('timeAgo returns days', () {
      final comment = ActivityComment(
        commentId: 'comment_006',
        activityId: 'activity_006',
        userId: 'user_006',
        userName: 'User',
        comment: 'Comment',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      );
      expect(comment.timeAgo, equals('2d'));
    });
  });

  group('ActivityLike', () {
    test('creates like with required fields', () {
      final now = DateTime.now();
      final like = ActivityLike(
        likeId: 'like_001',
        activityId: 'activity_001',
        userId: 'user_001',
        createdAt: now,
      );

      expect(like.likeId, equals('like_001'));
      expect(like.activityId, equals('activity_001'));
      expect(like.userId, equals('user_001'));
      expect(like.createdAt, equals(now));
    });

    test('equals works correctly for same values', () {
      final now = DateTime.now();
      final like1 = ActivityLike(
        likeId: 'like_001',
        activityId: 'activity_001',
        userId: 'user_001',
        createdAt: now,
      );
      final like2 = ActivityLike(
        likeId: 'like_001',
        activityId: 'activity_001',
        userId: 'user_001',
        createdAt: now,
      );

      expect(like1, equals(like2));
    });

    test('equals works correctly for different values', () {
      final now = DateTime.now();
      final like1 = ActivityLike(
        likeId: 'like_001',
        activityId: 'activity_001',
        userId: 'user_001',
        createdAt: now,
      );
      final like2 = ActivityLike(
        likeId: 'like_002',
        activityId: 'activity_001',
        userId: 'user_001',
        createdAt: now,
      );

      expect(like1, isNot(equals(like2)));
    });
  });
}

/// Helper function to create a test ActivityFeedItem
ActivityFeedItem _createActivity({
  String activityId = 'test_activity',
  String userId = 'test_user',
  String userName = 'Test User',
  ActivityType type = ActivityType.checkIn,
  String content = 'Test content',
  DateTime? createdAt,
  int likesCount = 0,
  int commentsCount = 0,
}) {
  return ActivityFeedItem(
    activityId: activityId,
    userId: userId,
    userName: userName,
    type: type,
    content: content,
    createdAt: createdAt ?? DateTime.now(),
    likesCount: likesCount,
    commentsCount: commentsCount,
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/social/domain/services/activity_feed_service.dart';
import 'package:pregame_world_cup/features/social/presentation/widgets/activity_feed_item_widget.dart';
import 'package:pregame_world_cup/features/social/domain/entities/activity_feed.dart';

class MockActivityFeedService extends Mock implements ActivityFeedService {}

void main() {
  group('ActivityFeedItemWidget', () {
    late ActivityFeedItem testActivity;
    late bool onLikeCalled;
    late String onLikeActivityId;
    late bool onCommentCalled;
    late String onCommentActivityId;
    late String onCommentText;
    late bool onShareCalled;
    late ActivityFeedItem? onShareActivity;
    late bool onUserPressedCalled;
    late String onUserPressedUserId;

    setUp(() {
      testActivity = ActivityFeedItem(
        activityId: 'activity123',
        userId: 'user123',
        userName: 'John Doe',
        userProfileImage: 'https://example.com/photo.jpg',
        type: ActivityType.checkIn,
        content: 'Checked in at Stadium',
        createdAt: DateTime.now(),
        metadata: {'venueName': 'Stadium'},
        mentionedUsers: const [],
        tags: const [],
        relatedVenueId: 'venue123',
        likesCount: 5,
        commentsCount: 3,
        isPublic: true,
      );

      onLikeCalled = false;
      onLikeActivityId = '';
      onCommentCalled = false;
      onCommentActivityId = '';
      onCommentText = '';
      onShareCalled = false;
      onShareActivity = null;
      onUserPressedCalled = false;
      onUserPressedUserId = '';
    });

    test('is a StatefulWidget', () {
      final widget = ActivityFeedItemWidget(
        activity: testActivity,
        onLike: (_) {},
        onComment: (_, __) {},
        onShare: (_) {},
        onUserPressed: (_) {},
      );

      expect(widget, isA<StatefulWidget>());
    });

    test('constructor stores activity', () {
      final widget = ActivityFeedItemWidget(
        activity: testActivity,
        onLike: (_) {},
        onComment: (_, __) {},
        onShare: (_) {},
        onUserPressed: (_) {},
      );

      expect(widget.activity, testActivity);
      expect(widget.activity.activityId, 'activity123');
      expect(widget.activity.userId, 'user123');
      expect(widget.activity.userName, 'John Doe');
      expect(widget.activity.type, ActivityType.checkIn);
      expect(widget.activity.content, 'Checked in at Stadium');
    });

    test('constructor stores onLike callback', () {
      final widget = ActivityFeedItemWidget(
        activity: testActivity,
        onLike: (activityId) {
          onLikeCalled = true;
          onLikeActivityId = activityId;
        },
        onComment: (_, __) {},
        onShare: (_) {},
        onUserPressed: (_) {},
      );

      expect(widget.onLike, isA<Function>());

      // Test callback functionality
      widget.onLike('test123');
      expect(onLikeCalled, true);
      expect(onLikeActivityId, 'test123');
    });

    test('constructor stores onComment callback', () {
      final widget = ActivityFeedItemWidget(
        activity: testActivity,
        onLike: (_) {},
        onComment: (activityId, comment) {
          onCommentCalled = true;
          onCommentActivityId = activityId;
          onCommentText = comment;
        },
        onShare: (_) {},
        onUserPressed: (_) {},
      );

      expect(widget.onComment, isA<Function>());

      // Test callback functionality
      widget.onComment('test123', 'Great post!');
      expect(onCommentCalled, true);
      expect(onCommentActivityId, 'test123');
      expect(onCommentText, 'Great post!');
    });

    test('constructor stores onShare callback', () {
      final widget = ActivityFeedItemWidget(
        activity: testActivity,
        onLike: (_) {},
        onComment: (_, __) {},
        onShare: (activity) {
          onShareCalled = true;
          onShareActivity = activity;
        },
        onUserPressed: (_) {},
      );

      expect(widget.onShare, isA<Function>());

      // Test callback functionality
      widget.onShare(testActivity);
      expect(onShareCalled, true);
      expect(onShareActivity, testActivity);
    });

    test('constructor stores onUserPressed callback', () {
      final widget = ActivityFeedItemWidget(
        activity: testActivity,
        onLike: (_) {},
        onComment: (_, __) {},
        onShare: (_) {},
        onUserPressed: (userId) {
          onUserPressedCalled = true;
          onUserPressedUserId = userId;
        },
      );

      expect(widget.onUserPressed, isA<Function>());

      // Test callback functionality
      widget.onUserPressed('user456');
      expect(onUserPressedCalled, true);
      expect(onUserPressedUserId, 'user456');
    });

    test('constructor with different activity types', () {
      final activityTypes = [
        ActivityType.checkIn,
        ActivityType.friendConnection,
        ActivityType.gameAttendance,
        ActivityType.venueReview,
        ActivityType.photoShare,
        ActivityType.gameComment,
        ActivityType.teamFollow,
        ActivityType.achievement,
        ActivityType.groupJoin,
      ];

      for (final type in activityTypes) {
        final activity = ActivityFeedItem(
          activityId: 'activity_$type',
          userId: 'user123',
          userName: 'John Doe',
          type: type,
          content: 'Test content for $type',
          createdAt: DateTime.now(),
        );

        final widget = ActivityFeedItemWidget(
          activity: activity,
          onLike: (_) {},
          onComment: (_, __) {},
          onShare: (_) {},
          onUserPressed: (_) {},
        );

        expect(widget.activity.type, type);
      }
    });

    test('constructor with activity with relatedGameId', () {
      final activity = ActivityFeedItem(
        activityId: 'activity123',
        userId: 'user123',
        userName: 'John Doe',
        type: ActivityType.gameAttendance,
        content: 'Attended the game',
        createdAt: DateTime.now(),
        relatedGameId: 'game123',
      );

      final widget = ActivityFeedItemWidget(
        activity: activity,
        onLike: (_) {},
        onComment: (_, __) {},
        onShare: (_) {},
        onUserPressed: (_) {},
      );

      expect(widget.activity.relatedGameId, 'game123');
    });

    test('constructor with activity with relatedVenueId', () {
      final activity = ActivityFeedItem(
        activityId: 'activity123',
        userId: 'user123',
        userName: 'John Doe',
        type: ActivityType.checkIn,
        content: 'Checked in at venue',
        createdAt: DateTime.now(),
        relatedVenueId: 'venue456',
      );

      final widget = ActivityFeedItemWidget(
        activity: activity,
        onLike: (_) {},
        onComment: (_, __) {},
        onShare: (_) {},
        onUserPressed: (_) {},
      );

      expect(widget.activity.relatedVenueId, 'venue456');
    });
  });

  // ===========================================================================
  // ActivityFeedItemWidget rendering
  // ===========================================================================
  group('ActivityFeedItemWidget rendering', () {
    late MockActivityFeedService mockActivityFeedService;
    late ActivityFeedItem testActivity;

    Widget buildTestWidget(Widget child) {
      return MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 400,
              child: child,
            ),
          ),
        ),
      );
    }

    setUp(() {
      mockActivityFeedService = MockActivityFeedService();

      // Register mock in GetIt so sl<ActivityFeedService>() resolves in widget
      final sl = GetIt.instance;
      if (sl.isRegistered<ActivityFeedService>()) {
        sl.unregister<ActivityFeedService>();
      }
      sl.registerSingleton<ActivityFeedService>(mockActivityFeedService);

      // Default stub: getActivityComments returns empty list
      when(() => mockActivityFeedService.getActivityComments(any()))
          .thenAnswer((_) async => []);

      testActivity = ActivityFeedItem(
        activityId: 'activity123',
        userId: 'user123',
        userName: 'John Doe',
        type: ActivityType.checkIn,
        content: 'Checked in at Stadium',
        createdAt: DateTime.now(),
        metadata: const {'venueName': 'Stadium'},
        mentionedUsers: const [],
        tags: const [],
        relatedVenueId: 'venue123',
        likesCount: 5,
        commentsCount: 3,
        isPublic: true,
      );

      // Suppress noisy CachedNetworkImage and plugin-missing errors in tests
      FlutterError.onError = (FlutterErrorDetails details) {
        final msg = details.toString();
        if (msg.contains('HTTP') ||
            msg.contains('network') ||
            msg.contains('MissingPluginException') ||
            msg.contains('overflowed')) {
          return;
        }
        FlutterError.presentError(details);
      };
    });

    tearDown(() {
      final sl = GetIt.instance;
      if (sl.isRegistered<ActivityFeedService>()) {
        sl.unregister<ActivityFeedService>();
      }
      FlutterError.onError = FlutterError.presentError;
    });

    testWidgets('initialIsLiked: false renders unliked heart icon',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(ActivityFeedItemWidget(
          activity: testActivity,
          onLike: (_) {},
          onComment: (_, __) {},
          onShare: (_) {},
          onUserPressed: (_) {},
          initialIsLiked: false,
        )),
      );

      await tester.pump();

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsNothing);
    });

    testWidgets('initialIsLiked: true renders liked heart icon',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(ActivityFeedItemWidget(
          activity: testActivity,
          onLike: (_) {},
          onComment: (_, __) {},
          onShare: (_) {},
          onUserPressed: (_) {},
          initialIsLiked: true,
        )),
      );

      await tester.pump();

      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing);
    });

    testWidgets('renders activity content', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(ActivityFeedItemWidget(
          activity: testActivity,
          onLike: (_) {},
          onComment: (_, __) {},
          onShare: (_) {},
          onUserPressed: (_) {},
        )),
      );

      await tester.pump();

      expect(find.text('Checked in at Stadium'), findsOneWidget);
    });

    testWidgets('renders user name', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(ActivityFeedItemWidget(
          activity: testActivity,
          onLike: (_) {},
          onComment: (_, __) {},
          onShare: (_) {},
          onUserPressed: (_) {},
        )),
      );

      await tester.pump();

      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('renders like count', (tester) async {
      final activityWithLikes = ActivityFeedItem(
        activityId: 'activity_likes',
        userId: 'user123',
        userName: 'John Doe',
        type: ActivityType.checkIn,
        content: 'Test content',
        createdAt: DateTime.now(),
        likesCount: 5,
      );

      await tester.pumpWidget(
        buildTestWidget(ActivityFeedItemWidget(
          activity: activityWithLikes,
          onLike: (_) {},
          onComment: (_, __) {},
          onShare: (_) {},
          onUserPressed: (_) {},
        )),
      );

      await tester.pump();

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('comment section is hidden initially', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(ActivityFeedItemWidget(
          activity: testActivity,
          onLike: (_) {},
          onComment: (_, __) {},
          onShare: (_) {},
          onUserPressed: (_) {},
        )),
      );

      await tester.pump();

      // Comment input field and "Be the first to comment!" text are only
      // visible after tapping the comment button — they should not be present yet.
      expect(find.text('Write a comment...'), findsNothing);
      expect(find.text('Be the first to comment!'), findsNothing);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/social/presentation/widgets/notification_item_widget.dart';
import 'package:pregame_world_cup/features/social/domain/entities/notification.dart';

void main() {
  group('NotificationItemWidget', () {
    late SocialNotification testNotification;
    late bool onTapCalled;
    late bool onAcceptCalled;
    late bool onDeclineCalled;
    late bool onDeleteCalled;

    setUp(() {
      testNotification = SocialNotification(
        notificationId: 'notif123',
        userId: 'user123',
        fromUserId: 'user456',
        fromUserName: 'Jane Smith',
        fromUserImage: 'https://example.com/photo.jpg',
        type: NotificationType.friendRequest,
        title: 'New Friend Request',
        message: 'Jane Smith sent you a friend request',
        createdAt: DateTime.now(),
        isRead: false,
        data: const {},
        priority: NotificationPriority.high,
      );

      onTapCalled = false;
      onAcceptCalled = false;
      onDeclineCalled = false;
      onDeleteCalled = false;
    });

    test('is a StatelessWidget', () {
      final widget = NotificationItemWidget(
        notification: testNotification,
        onTap: () {},
        onDelete: () {},
      );

      expect(widget, isA<StatelessWidget>());
    });

    test('constructor stores notification', () {
      final widget = NotificationItemWidget(
        notification: testNotification,
        onTap: () {},
        onDelete: () {},
      );

      expect(widget.notification, testNotification);
      expect(widget.notification.notificationId, 'notif123');
      expect(widget.notification.userId, 'user123');
      expect(widget.notification.type, NotificationType.friendRequest);
      expect(widget.notification.title, 'New Friend Request');
      expect(widget.notification.message, 'Jane Smith sent you a friend request');
    });

    test('constructor stores onTap callback', () {
      final widget = NotificationItemWidget(
        notification: testNotification,
        onTap: () {
          onTapCalled = true;
        },
        onDelete: () {},
      );

      expect(widget.onTap, isA<VoidCallback>());

      // Test callback functionality
      widget.onTap();
      expect(onTapCalled, true);
    });

    test('constructor stores onDelete callback', () {
      final widget = NotificationItemWidget(
        notification: testNotification,
        onTap: () {},
        onDelete: () {
          onDeleteCalled = true;
        },
      );

      expect(widget.onDelete, isA<VoidCallback>());

      // Test callback functionality
      widget.onDelete();
      expect(onDeleteCalled, true);
    });

    test('onAccept is null by default', () {
      final widget = NotificationItemWidget(
        notification: testNotification,
        onTap: () {},
        onDelete: () {},
      );

      expect(widget.onAccept, isNull);
    });

    test('onDecline is null by default', () {
      final widget = NotificationItemWidget(
        notification: testNotification,
        onTap: () {},
        onDelete: () {},
      );

      expect(widget.onDecline, isNull);
    });

    test('constructor stores onAccept callback when provided', () {
      final widget = NotificationItemWidget(
        notification: testNotification,
        onTap: () {},
        onAccept: () {
          onAcceptCalled = true;
        },
        onDelete: () {},
      );

      expect(widget.onAccept, isA<VoidCallback>());

      // Test callback functionality
      widget.onAccept!();
      expect(onAcceptCalled, true);
    });

    test('constructor stores onDecline callback when provided', () {
      final widget = NotificationItemWidget(
        notification: testNotification,
        onTap: () {},
        onDecline: () {
          onDeclineCalled = true;
        },
        onDelete: () {},
      );

      expect(widget.onDecline, isA<VoidCallback>());

      // Test callback functionality
      widget.onDecline!();
      expect(onDeclineCalled, true);
    });

    test('constructor with all optional callbacks provided', () {
      final widget = NotificationItemWidget(
        notification: testNotification,
        onTap: () {
          onTapCalled = true;
        },
        onAccept: () {
          onAcceptCalled = true;
        },
        onDecline: () {
          onDeclineCalled = true;
        },
        onDelete: () {
          onDeleteCalled = true;
        },
      );

      expect(widget.onTap, isA<VoidCallback>());
      expect(widget.onAccept, isA<VoidCallback>());
      expect(widget.onDecline, isA<VoidCallback>());
      expect(widget.onDelete, isA<VoidCallback>());

      // Test all callbacks
      widget.onTap();
      widget.onAccept!();
      widget.onDecline!();
      widget.onDelete();

      expect(onTapCalled, true);
      expect(onAcceptCalled, true);
      expect(onDeclineCalled, true);
      expect(onDeleteCalled, true);
    });

    test('constructor with different notification types', () {
      final notificationTypes = [
        NotificationType.friendRequest,
        NotificationType.friendRequestAccepted,
        NotificationType.activityLike,
        NotificationType.activityComment,
        NotificationType.gameInvite,
        NotificationType.venueRecommendation,
        NotificationType.newFollower,
        NotificationType.groupInvite,
        NotificationType.achievement,
        NotificationType.systemUpdate,
        NotificationType.watchPartyInvite,
        NotificationType.matchReminder,
        NotificationType.favoriteTeamMatch,
      ];

      for (final type in notificationTypes) {
        final notification = SocialNotification(
          notificationId: 'notif_$type',
          userId: 'user123',
          type: type,
          title: 'Test $type',
          message: 'Test message for $type',
          createdAt: DateTime.now(),
        );

        final widget = NotificationItemWidget(
          notification: notification,
          onTap: () {},
          onDelete: () {},
        );

        expect(widget.notification.type, type);
      }
    });

    test('constructor with different notification priorities', () {
      final priorities = [
        NotificationPriority.low,
        NotificationPriority.normal,
        NotificationPriority.high,
        NotificationPriority.urgent,
      ];

      for (final priority in priorities) {
        final notification = SocialNotification(
          notificationId: 'notif_$priority',
          userId: 'user123',
          type: NotificationType.systemUpdate,
          title: 'Test',
          message: 'Test message',
          createdAt: DateTime.now(),
          priority: priority,
        );

        final widget = NotificationItemWidget(
          notification: notification,
          onTap: () {},
          onDelete: () {},
        );

        expect(widget.notification.priority, priority);
      }
    });

    test('constructor with read notification', () {
      final notification = SocialNotification(
        notificationId: 'notif123',
        userId: 'user123',
        type: NotificationType.activityLike,
        title: 'Activity Liked',
        message: 'Someone liked your activity',
        createdAt: DateTime.now(),
        isRead: true,
      );

      final widget = NotificationItemWidget(
        notification: notification,
        onTap: () {},
        onDelete: () {},
      );

      expect(widget.notification.isRead, true);
    });

    test('constructor with unread notification', () {
      final notification = SocialNotification(
        notificationId: 'notif123',
        userId: 'user123',
        type: NotificationType.activityLike,
        title: 'Activity Liked',
        message: 'Someone liked your activity',
        createdAt: DateTime.now(),
        isRead: false,
      );

      final widget = NotificationItemWidget(
        notification: notification,
        onTap: () {},
        onDelete: () {},
      );

      expect(widget.notification.isRead, false);
    });
  });
}

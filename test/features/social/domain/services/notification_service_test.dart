import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/social/domain/entities/notification.dart';

/// Tests for NotificationService entity logic, data conversion, and preferences.
///
/// NotificationService uses hardcoded `FirebaseFirestore.instance` (not injected
/// via constructor), which prevents direct service-level unit testing with
/// FakeFirebaseFirestore. These tests cover the critical entity business logic,
/// factory constructors, notification preferences, and conversion helpers that
/// the service relies on.
void main() {
  // ===========================================================================
  // SocialNotification entity
  // ===========================================================================
  group('SocialNotification', () {
    test('constructor sets all required fields', () {
      final now = DateTime(2026, 6, 15, 12, 0);
      final notification = SocialNotification(
        notificationId: 'notif_1',
        userId: 'user_1',
        type: NotificationType.friendRequest,
        title: 'New Friend Request',
        message: 'John sent you a friend request',
        createdAt: now,
      );

      expect(notification.notificationId, equals('notif_1'));
      expect(notification.userId, equals('user_1'));
      expect(notification.type, equals(NotificationType.friendRequest));
      expect(notification.title, equals('New Friend Request'));
      expect(notification.message, equals('John sent you a friend request'));
      expect(notification.createdAt, equals(now));
      expect(notification.isRead, isFalse);
      expect(notification.data, isEmpty);
      expect(notification.priority, equals(NotificationPriority.normal));
      expect(notification.fromUserId, isNull);
      expect(notification.fromUserName, isNull);
      expect(notification.fromUserImage, isNull);
      expect(notification.actionUrl, isNull);
    });

    test('constructor sets optional fields', () {
      final notification = SocialNotification(
        notificationId: 'notif_1',
        userId: 'user_1',
        fromUserId: 'sender_1',
        fromUserName: 'Sender',
        fromUserImage: 'https://example.com/photo.jpg',
        type: NotificationType.activityLike,
        title: 'Activity Liked',
        message: 'Sender liked your post',
        createdAt: DateTime.now(),
        isRead: true,
        data: const {'activityId': 'act_1'},
        actionUrl: '/activity/act_1',
        priority: NotificationPriority.high,
      );

      expect(notification.fromUserId, equals('sender_1'));
      expect(notification.fromUserName, equals('Sender'));
      expect(notification.fromUserImage, equals('https://example.com/photo.jpg'));
      expect(notification.isRead, isTrue);
      expect(notification.data['activityId'], equals('act_1'));
      expect(notification.actionUrl, equals('/activity/act_1'));
      expect(notification.priority, equals(NotificationPriority.high));
    });
  });

  // ===========================================================================
  // SocialNotification factory constructors
  // ===========================================================================
  group('SocialNotification factories', () {
    test('friendRequest factory creates correct notification', () {
      final notification = SocialNotification.friendRequest(
        userId: 'recipient_1',
        fromUserId: 'sender_1',
        fromUserName: 'John Doe',
        fromUserImage: 'https://example.com/john.jpg',
        connectionId: 'conn_123',
      );

      expect(notification.userId, equals('recipient_1'));
      expect(notification.fromUserId, equals('sender_1'));
      expect(notification.fromUserName, equals('John Doe'));
      expect(notification.type, equals(NotificationType.friendRequest));
      expect(notification.title, equals('New Friend Request'));
      expect(notification.message, contains('John Doe'));
      expect(notification.message, contains('friend request'));
      expect(notification.data['connectionId'], equals('conn_123'));
      expect(notification.data['fromUserId'], equals('sender_1'));
      expect(notification.actionUrl, equals('/profile/sender_1'));
      expect(notification.priority, equals(NotificationPriority.high));
      expect(notification.isRead, isFalse);
      expect(notification.notificationId, contains('friend_request_'));
    });

    test('friendRequestAccepted factory creates correct notification', () {
      final notification = SocialNotification.friendRequestAccepted(
        userId: 'original_sender',
        fromUserId: 'acceptor_1',
        fromUserName: 'Jane Smith',
      );

      expect(notification.userId, equals('original_sender'));
      expect(notification.type, equals(NotificationType.friendRequestAccepted));
      expect(notification.title, equals('Friend Request Accepted'));
      expect(notification.message, contains('Jane Smith'));
      expect(notification.message, contains('accepted'));
      expect(notification.data['fromUserId'], equals('acceptor_1'));
      expect(notification.actionUrl, equals('/profile/acceptor_1'));
      expect(notification.notificationId, contains('friend_accepted_'));
    });

    test('activityLike factory creates correct notification', () {
      final notification = SocialNotification.activityLike(
        userId: 'author_1',
        fromUserId: 'liker_1',
        fromUserName: 'LikerUser',
        activityId: 'act_123',
        activityContent: 'Checked in at Sports Bar',
      );

      expect(notification.type, equals(NotificationType.activityLike));
      expect(notification.title, equals('Activity Liked'));
      expect(notification.message, contains('LikerUser'));
      expect(notification.message, contains('liked'));
      expect(notification.data['activityId'], equals('act_123'));
      expect(notification.data['activityContent'], equals('Checked in at Sports Bar'));
      expect(notification.actionUrl, equals('/activity/act_123'));
      expect(notification.notificationId, contains('activity_like_'));
    });

    test('activityComment factory creates correct notification', () {
      final notification = SocialNotification.activityComment(
        userId: 'author_1',
        fromUserId: 'commenter_1',
        fromUserName: 'Commenter',
        activityId: 'act_456',
        comment: 'Nice post!',
      );

      expect(notification.type, equals(NotificationType.activityComment));
      expect(notification.title, equals('New Comment'));
      expect(notification.message, contains('Commenter'));
      expect(notification.message, contains('commented'));
      expect(notification.message, contains('Nice post!'));
      expect(notification.data['activityId'], equals('act_456'));
      expect(notification.data['comment'], equals('Nice post!'));
      expect(notification.actionUrl, equals('/activity/act_456'));
      expect(notification.notificationId, contains('activity_comment_'));
    });

    test('gameInvite factory creates correct notification', () {
      final gameDate = DateTime(2026, 6, 20, 18, 0);
      final notification = SocialNotification.gameInvite(
        userId: 'invitee_1',
        fromUserId: 'inviter_1',
        fromUserName: 'InviterUser',
        gameId: 'game_1',
        gameTitle: 'USA vs Brazil',
        gameDate: gameDate,
      );

      expect(notification.type, equals(NotificationType.gameInvite));
      expect(notification.title, equals('Game Invitation'));
      expect(notification.message, contains('InviterUser'));
      expect(notification.message, contains('USA vs Brazil'));
      expect(notification.data['gameId'], equals('game_1'));
      expect(notification.data['gameTitle'], equals('USA vs Brazil'));
      expect(notification.actionUrl, equals('/game/game_1'));
      expect(notification.priority, equals(NotificationPriority.high));
      expect(notification.notificationId, contains('game_invite_'));
    });

    test('watchPartyInvite factory creates notification with personal message', () {
      final gameDateTime = DateTime(2026, 6, 25, 20, 0);
      final notification = SocialNotification.watchPartyInvite(
        userId: 'invitee_1',
        fromUserId: 'host_1',
        fromUserName: 'PartyHost',
        watchPartyId: 'wp_123',
        watchPartyName: 'USA Fan Watch Party',
        gameName: 'USA vs Mexico',
        gameDateTime: gameDateTime,
        personalMessage: 'Come join us!',
      );

      expect(notification.type, equals(NotificationType.watchPartyInvite));
      expect(notification.title, equals('Watch Party Invitation'));
      expect(notification.message, contains('PartyHost'));
      expect(notification.message, contains('USA Fan Watch Party'));
      expect(notification.message, contains('Come join us!'));
      expect(notification.data['watchPartyId'], equals('wp_123'));
      expect(notification.data['gameName'], equals('USA vs Mexico'));
      expect(notification.actionUrl, equals('/watch-party/wp_123'));
      expect(notification.priority, equals(NotificationPriority.high));
    });

    test('watchPartyInvite factory creates notification without personal message', () {
      final gameDateTime = DateTime(2026, 6, 25, 20, 0);
      final notification = SocialNotification.watchPartyInvite(
        userId: 'invitee_1',
        fromUserId: 'host_1',
        fromUserName: 'PartyHost',
        watchPartyId: 'wp_456',
        watchPartyName: 'Fan Zone',
        gameName: 'Final Match',
        gameDateTime: gameDateTime,
      );

      expect(notification.message, contains('PartyHost'));
      expect(notification.message, contains('Final Match'));
      expect(notification.message, contains('watch'));
    });

    test('matchReminder factory creates correct notification', () {
      final matchDateTime = DateTime(2026, 7, 19, 15, 0);
      final notification = SocialNotification.matchReminder(
        userId: 'user_1',
        matchId: 'match_final',
        matchName: 'World Cup Final',
        matchDateTime: matchDateTime,
        timingDisplay: '30 minutes',
        venueName: 'MetLife Stadium',
      );

      expect(notification.type, equals(NotificationType.matchReminder));
      expect(notification.title, equals('Match Starting Soon'));
      expect(notification.message, contains('World Cup Final'));
      expect(notification.message, contains('30 minutes'));
      expect(notification.message, contains('MetLife Stadium'));
      expect(notification.data['matchId'], equals('match_final'));
      expect(notification.data['venueName'], equals('MetLife Stadium'));
      expect(notification.actionUrl, equals('/match/match_final'));
      expect(notification.priority, equals(NotificationPriority.high));
    });

    test('matchReminder without venue name', () {
      final notification = SocialNotification.matchReminder(
        userId: 'user_1',
        matchId: 'match_1',
        matchName: 'USA vs Brazil',
        matchDateTime: DateTime(2026, 6, 20),
        timingDisplay: '1 hour',
      );

      expect(notification.message, contains('USA vs Brazil'));
      expect(notification.message, contains('1 hour'));
      expect(notification.message, isNot(contains('at'))); // no venue
    });

    test('favoriteTeamMatch factory creates correct notification', () {
      final matchDateTime = DateTime(2026, 6, 15, 18, 0);
      final notification = SocialNotification.favoriteTeamMatch(
        userId: 'user_1',
        matchId: 'match_group_a1',
        homeTeamName: 'United States',
        awayTeamName: 'England',
        matchDateTime: matchDateTime,
        teamDescription: 'Your team United States',
        venueName: 'SoFi Stadium',
      );

      expect(notification.type, equals(NotificationType.favoriteTeamMatch));
      expect(notification.title, equals('Your Team Plays Tomorrow!'));
      expect(notification.message, contains('United States'));
      expect(notification.message, contains('England'));
      expect(notification.data['matchId'], equals('match_group_a1'));
      expect(notification.data['homeTeamName'], equals('United States'));
      expect(notification.data['awayTeamName'], equals('England'));
      expect(notification.priority, equals(NotificationPriority.normal));
    });
  });

  // ===========================================================================
  // SocialNotification methods
  // ===========================================================================
  group('SocialNotification methods', () {
    test('markAsRead returns notification with isRead true', () {
      final notification = SocialNotification(
        notificationId: 'notif_1',
        userId: 'user_1',
        type: NotificationType.friendRequest,
        title: 'Test',
        message: 'Test',
        createdAt: DateTime.now(),
        isRead: false,
      );

      final read = notification.markAsRead();

      expect(read.isRead, isTrue);
      expect(read.notificationId, equals(notification.notificationId));
      expect(read.userId, equals(notification.userId));
      expect(read.type, equals(notification.type));
    });

    test('copyWith preserves unchanged fields', () {
      final now = DateTime(2026, 6, 15, 12, 0);
      final original = SocialNotification(
        notificationId: 'notif_1',
        userId: 'user_1',
        fromUserId: 'sender_1',
        fromUserName: 'Sender',
        type: NotificationType.activityLike,
        title: 'Liked',
        message: 'Test',
        createdAt: now,
        data: const {'key': 'value'},
        actionUrl: '/test',
        priority: NotificationPriority.high,
      );

      final updated = original.copyWith(isRead: true);

      expect(updated.isRead, isTrue);
      expect(updated.notificationId, equals('notif_1'));
      expect(updated.fromUserId, equals('sender_1'));
      expect(updated.fromUserName, equals('Sender'));
      expect(updated.type, equals(NotificationType.activityLike));
      expect(updated.data['key'], equals('value'));
      expect(updated.actionUrl, equals('/test'));
      expect(updated.priority, equals(NotificationPriority.high));
    });

    test('copyWith can update data', () {
      final original = SocialNotification(
        notificationId: 'notif_1',
        userId: 'user_1',
        type: NotificationType.friendRequest,
        title: 'Test',
        message: 'Test',
        createdAt: DateTime.now(),
        data: const {'old': 'data'},
      );

      final updated = original.copyWith(data: {'new': 'data'});

      expect(updated.data['new'], equals('data'));
      expect(updated.data.containsKey('old'), isFalse);
    });
  });

  // ===========================================================================
  // SocialNotification computed properties
  // ===========================================================================
  group('SocialNotification computed properties', () {
    test('timeAgo returns Just now for recent notifications', () {
      final notification = SocialNotification(
        notificationId: 'n1',
        userId: 'u1',
        type: NotificationType.friendRequest,
        title: 'Test',
        message: 'Test',
        createdAt: DateTime.now(),
      );

      expect(notification.timeAgo, equals('Just now'));
    });

    test('timeAgo returns minutes ago', () {
      final notification = SocialNotification(
        notificationId: 'n1',
        userId: 'u1',
        type: NotificationType.friendRequest,
        title: 'Test',
        message: 'Test',
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      );

      expect(notification.timeAgo, equals('45m ago'));
    });

    test('timeAgo returns hours ago', () {
      final notification = SocialNotification(
        notificationId: 'n1',
        userId: 'u1',
        type: NotificationType.friendRequest,
        title: 'Test',
        message: 'Test',
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      );

      expect(notification.timeAgo, equals('8h ago'));
    });

    test('timeAgo returns days ago', () {
      final notification = SocialNotification(
        notificationId: 'n1',
        userId: 'u1',
        type: NotificationType.friendRequest,
        title: 'Test',
        message: 'Test',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      );

      expect(notification.timeAgo, equals('5d ago'));
    });

    test('isRecent is true within 24 hours', () {
      final notification = SocialNotification(
        notificationId: 'n1',
        userId: 'u1',
        type: NotificationType.friendRequest,
        title: 'Test',
        message: 'Test',
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      );

      expect(notification.isRecent, isTrue);
    });

    test('isRecent is false after 24 hours', () {
      final notification = SocialNotification(
        notificationId: 'n1',
        userId: 'u1',
        type: NotificationType.friendRequest,
        title: 'Test',
        message: 'Test',
        createdAt: DateTime.now().subtract(const Duration(hours: 25)),
      );

      expect(notification.isRecent, isFalse);
    });

    test('isActionable is true for friendRequest', () {
      final notification = SocialNotification(
        notificationId: 'n1',
        userId: 'u1',
        type: NotificationType.friendRequest,
        title: 'Test',
        message: 'Test',
        createdAt: DateTime.now(),
      );

      expect(notification.isActionable, isTrue);
    });

    test('isActionable is true for gameInvite', () {
      final notification = SocialNotification(
        notificationId: 'n1',
        userId: 'u1',
        type: NotificationType.gameInvite,
        title: 'Test',
        message: 'Test',
        createdAt: DateTime.now(),
      );

      expect(notification.isActionable, isTrue);
    });

    test('isActionable is false for activityLike', () {
      final notification = SocialNotification(
        notificationId: 'n1',
        userId: 'u1',
        type: NotificationType.activityLike,
        title: 'Test',
        message: 'Test',
        createdAt: DateTime.now(),
      );

      expect(notification.isActionable, isFalse);
    });

    test('isActionable is false for systemUpdate', () {
      final notification = SocialNotification(
        notificationId: 'n1',
        userId: 'u1',
        type: NotificationType.systemUpdate,
        title: 'Test',
        message: 'Test',
        createdAt: DateTime.now(),
      );

      expect(notification.isActionable, isFalse);
    });
  });

  // ===========================================================================
  // SocialNotification Equatable
  // ===========================================================================
  group('SocialNotification Equatable', () {
    test('equal notifications are equal', () {
      final now = DateTime(2026, 6, 15, 12, 0);
      final n1 = SocialNotification(
        notificationId: 'n1',
        userId: 'u1',
        type: NotificationType.friendRequest,
        title: 'Test',
        message: 'Test',
        createdAt: now,
      );
      final n2 = SocialNotification(
        notificationId: 'n1',
        userId: 'u1',
        type: NotificationType.friendRequest,
        title: 'Test',
        message: 'Test',
        createdAt: now,
      );

      expect(n1, equals(n2));
    });

    test('different notifications are not equal', () {
      final now = DateTime(2026, 6, 15, 12, 0);
      final n1 = SocialNotification(
        notificationId: 'n1',
        userId: 'u1',
        type: NotificationType.friendRequest,
        title: 'Test',
        message: 'Test',
        createdAt: now,
      );
      final n2 = SocialNotification(
        notificationId: 'n2',
        userId: 'u1',
        type: NotificationType.friendRequest,
        title: 'Test',
        message: 'Test',
        createdAt: now,
      );

      expect(n1, isNot(equals(n2)));
    });
  });

  // ===========================================================================
  // NotificationType enum
  // ===========================================================================
  group('NotificationType', () {
    test('has all expected values', () {
      expect(NotificationType.values, contains(NotificationType.friendRequest));
      expect(NotificationType.values, contains(NotificationType.friendRequestAccepted));
      expect(NotificationType.values, contains(NotificationType.activityLike));
      expect(NotificationType.values, contains(NotificationType.activityComment));
      expect(NotificationType.values, contains(NotificationType.gameInvite));
      expect(NotificationType.values, contains(NotificationType.venueRecommendation));
      expect(NotificationType.values, contains(NotificationType.newFollower));
      expect(NotificationType.values, contains(NotificationType.groupInvite));
      expect(NotificationType.values, contains(NotificationType.achievement));
      expect(NotificationType.values, contains(NotificationType.systemUpdate));
      expect(NotificationType.values, contains(NotificationType.watchPartyInvite));
      expect(NotificationType.values, contains(NotificationType.matchReminder));
      expect(NotificationType.values, contains(NotificationType.favoriteTeamMatch));
      expect(NotificationType.values.length, equals(13));
    });
  });

  // ===========================================================================
  // NotificationPriority enum
  // ===========================================================================
  group('NotificationPriority', () {
    test('has all expected values', () {
      expect(NotificationPriority.values, contains(NotificationPriority.low));
      expect(NotificationPriority.values, contains(NotificationPriority.normal));
      expect(NotificationPriority.values, contains(NotificationPriority.high));
      expect(NotificationPriority.values, contains(NotificationPriority.urgent));
      expect(NotificationPriority.values.length, equals(4));
    });
  });

  // ===========================================================================
  // NotificationPreferences
  // ===========================================================================
  group('NotificationPreferences', () {
    test('defaultPreferences has sensible defaults', () {
      final prefs = NotificationPreferences.defaultPreferences();

      expect(prefs.friendRequests, isTrue);
      expect(prefs.activityLikes, isTrue);
      expect(prefs.activityComments, isTrue);
      expect(prefs.gameInvites, isTrue);
      expect(prefs.venueRecommendations, isTrue);
      expect(prefs.newFollowers, isTrue);
      expect(prefs.groupActivity, isTrue);
      expect(prefs.achievements, isTrue);
      expect(prefs.systemUpdates, isTrue);
      expect(prefs.pushNotifications, isTrue);
      expect(prefs.emailNotifications, isFalse);
      expect(prefs.quietHoursStart, equals('22:00'));
      expect(prefs.quietHoursEnd, equals('08:00'));
    });

    test('shouldNotifyForType respects friendRequests setting', () {
      const prefs = NotificationPreferences(friendRequests: false);

      expect(prefs.shouldNotifyForType(NotificationType.friendRequest), isFalse);
      expect(
          prefs.shouldNotifyForType(NotificationType.friendRequestAccepted),
          isFalse);
    });

    test('shouldNotifyForType respects activityLikes setting', () {
      const prefs = NotificationPreferences(activityLikes: false);

      expect(prefs.shouldNotifyForType(NotificationType.activityLike), isFalse);
    });

    test('shouldNotifyForType respects activityComments setting', () {
      const prefs = NotificationPreferences(activityComments: false);

      expect(
          prefs.shouldNotifyForType(NotificationType.activityComment), isFalse);
    });

    test('shouldNotifyForType respects gameInvites setting', () {
      const prefs = NotificationPreferences(gameInvites: false);

      expect(prefs.shouldNotifyForType(NotificationType.gameInvite), isFalse);
      // watchPartyInvite, matchReminder, favoriteTeamMatch also use gameInvites
      expect(
          prefs.shouldNotifyForType(NotificationType.watchPartyInvite), isFalse);
      expect(
          prefs.shouldNotifyForType(NotificationType.matchReminder), isFalse);
      expect(prefs.shouldNotifyForType(NotificationType.favoriteTeamMatch),
          isFalse);
    });

    test('shouldNotifyForType respects venueRecommendations setting', () {
      const prefs = NotificationPreferences(venueRecommendations: false);

      expect(prefs.shouldNotifyForType(NotificationType.venueRecommendation),
          isFalse);
    });

    test('shouldNotifyForType respects newFollowers setting', () {
      const prefs = NotificationPreferences(newFollowers: false);

      expect(prefs.shouldNotifyForType(NotificationType.newFollower), isFalse);
    });

    test('shouldNotifyForType respects groupActivity setting', () {
      const prefs = NotificationPreferences(groupActivity: false);

      expect(prefs.shouldNotifyForType(NotificationType.groupInvite), isFalse);
    });

    test('shouldNotifyForType respects achievements setting', () {
      const prefs = NotificationPreferences(achievements: false);

      expect(prefs.shouldNotifyForType(NotificationType.achievement), isFalse);
    });

    test('shouldNotifyForType respects systemUpdates setting', () {
      const prefs = NotificationPreferences(systemUpdates: false);

      expect(prefs.shouldNotifyForType(NotificationType.systemUpdate), isFalse);
    });

    test('shouldNotifyForType returns true when enabled', () {
      final prefs = NotificationPreferences.defaultPreferences();

      for (final type in NotificationType.values) {
        expect(prefs.shouldNotifyForType(type), isTrue,
            reason: 'Expected true for $type with default preferences');
      }
    });

    test('copyWith applies changes', () {
      final original = NotificationPreferences.defaultPreferences();
      final updated = original.copyWith(
        friendRequests: false,
        pushNotifications: false,
        quietHoursStart: '23:00',
      );

      expect(updated.friendRequests, isFalse);
      expect(updated.pushNotifications, isFalse);
      expect(updated.quietHoursStart, equals('23:00'));
      // Unchanged
      expect(updated.activityLikes, isTrue);
      expect(updated.emailNotifications, isFalse);
      expect(updated.quietHoursEnd, equals('08:00'));
    });

    test('copyWith preserves all fields when no overrides', () {
      const original = NotificationPreferences(
        friendRequests: false,
        activityLikes: false,
        emailNotifications: true,
        quietHoursStart: '21:00',
        quietHoursEnd: '07:00',
      );

      final copy = original.copyWith();

      expect(copy.friendRequests, isFalse);
      expect(copy.activityLikes, isFalse);
      expect(copy.emailNotifications, isTrue);
      expect(copy.quietHoursStart, equals('21:00'));
      expect(copy.quietHoursEnd, equals('07:00'));
    });
  });

  // ===========================================================================
  // NotificationPreferences Equatable
  // ===========================================================================
  group('NotificationPreferences Equatable', () {
    test('equal preferences are equal', () {
      final p1 = NotificationPreferences.defaultPreferences();
      final p2 = NotificationPreferences.defaultPreferences();

      expect(p1, equals(p2));
    });

    test('different preferences are not equal', () {
      final p1 = NotificationPreferences.defaultPreferences();
      final p2 = p1.copyWith(friendRequests: false);

      expect(p1, isNot(equals(p2)));
    });
  });

  // ===========================================================================
  // Notification Firestore conversion (mirrors service private methods)
  // ===========================================================================
  group('Notification Firestore conversion', () {
    test('notification-to-Firestore contains all required fields', () {
      final now = DateTime(2026, 6, 15, 12, 0);
      final notification = SocialNotification(
        notificationId: 'notif_1',
        userId: 'user_1',
        fromUserId: 'sender_1',
        fromUserName: 'Sender',
        fromUserImage: 'https://example.com/photo.jpg',
        type: NotificationType.friendRequest,
        title: 'New Friend Request',
        message: 'Test message',
        createdAt: now,
        isRead: false,
        data: const {'connectionId': 'conn_1'},
        actionUrl: '/profile/sender_1',
        priority: NotificationPriority.high,
      );

      // Simulate _notificationToFirestore
      final data = {
        'userId': notification.userId,
        'fromUserId': notification.fromUserId,
        'fromUserName': notification.fromUserName,
        'fromUserImage': notification.fromUserImage,
        'type': notification.type.name,
        'title': notification.title,
        'message': notification.message,
        'createdAt': Timestamp.fromDate(notification.createdAt),
        'isRead': notification.isRead,
        'data': notification.data,
        'actionUrl': notification.actionUrl,
        'priority': notification.priority.name,
      };

      expect(data['userId'], equals('user_1'));
      expect(data['fromUserId'], equals('sender_1'));
      expect(data['fromUserName'], equals('Sender'));
      expect(data['type'], equals('friendRequest'));
      expect(data['title'], equals('New Friend Request'));
      expect(data['isRead'], isFalse);
      expect(data['priority'], equals('high'));
    });

    test('notification roundtrip preserves all fields', () {
      final now = DateTime(2026, 6, 15, 12, 0);

      // Simulate Firestore data
      final firestoreData = {
        'userId': 'user_1',
        'fromUserId': 'sender_1',
        'fromUserName': 'Sender',
        'fromUserImage': null,
        'type': 'activityComment',
        'title': 'New Comment',
        'message': 'Sender commented on your post',
        'createdAt': Timestamp.fromDate(now),
        'isRead': true,
        'data': <String, dynamic>{'activityId': 'act_1'},
        'actionUrl': '/activity/act_1',
        'priority': 'normal',
      };

      // Simulate _notificationFromFirestore
      final restored = SocialNotification(
        notificationId: 'doc_id',
        userId: firestoreData['userId'] as String,
        fromUserId: firestoreData['fromUserId'] as String?,
        fromUserName: firestoreData['fromUserName'] as String?,
        fromUserImage: firestoreData['fromUserImage'] as String?,
        type: NotificationType.values
            .firstWhere((e) => e.name == firestoreData['type']),
        title: firestoreData['title'] as String,
        message: firestoreData['message'] as String,
        createdAt: (firestoreData['createdAt'] as Timestamp).toDate(),
        isRead: (firestoreData['isRead'] as bool?) ?? false,
        data:
            Map<String, dynamic>.from(firestoreData['data'] as Map? ?? {}),
        actionUrl: firestoreData['actionUrl'] as String?,
        priority: NotificationPriority.values
            .firstWhere((e) => e.name == firestoreData['priority']),
      );

      expect(restored.userId, equals('user_1'));
      expect(restored.type, equals(NotificationType.activityComment));
      expect(restored.isRead, isTrue);
      expect(restored.priority, equals(NotificationPriority.normal));
      expect(restored.data['activityId'], equals('act_1'));
      expect(restored.createdAt, equals(now));
    });

    test('notification from Firestore with missing optional fields', () {
      final now = DateTime(2026, 6, 15, 12, 0);

      final firestoreData = {
        'userId': 'user_1',
        'type': 'systemUpdate',
        'title': 'System Update',
        'message': 'App updated',
        'createdAt': Timestamp.fromDate(now),
        'priority': 'low',
      };

      final notification = SocialNotification(
        notificationId: 'doc_id',
        userId: firestoreData['userId'] as String,
        fromUserId: firestoreData['fromUserId'] as String?,
        fromUserName: firestoreData['fromUserName'] as String?,
        fromUserImage: firestoreData['fromUserImage'] as String?,
        type: NotificationType.values
            .firstWhere((e) => e.name == firestoreData['type']),
        title: firestoreData['title'] as String,
        message: firestoreData['message'] as String,
        createdAt: (firestoreData['createdAt'] as Timestamp).toDate(),
        isRead: (firestoreData['isRead'] as bool?) ?? false,
        data:
            Map<String, dynamic>.from((firestoreData['data'] as Map?) ?? {}),
        actionUrl: firestoreData['actionUrl'] as String?,
        priority: NotificationPriority.values
            .firstWhere((e) => e.name == firestoreData['priority']),
      );

      expect(notification.fromUserId, isNull);
      expect(notification.fromUserName, isNull);
      expect(notification.fromUserImage, isNull);
      expect(notification.isRead, isFalse);
      expect(notification.data, isEmpty);
      expect(notification.actionUrl, isNull);
    });
  });

  // ===========================================================================
  // Preferences Firestore conversion (mirrors service private methods)
  // ===========================================================================
  group('Preferences Firestore conversion', () {
    test('preferences-to-Firestore contains all fields', () {
      const preferences = NotificationPreferences(
        friendRequests: false,
        activityLikes: true,
        activityComments: false,
        gameInvites: true,
        venueRecommendations: false,
        newFollowers: true,
        groupActivity: false,
        achievements: true,
        systemUpdates: false,
        pushNotifications: true,
        emailNotifications: true,
        quietHoursStart: '23:00',
        quietHoursEnd: '07:00',
      );

      // Simulate _preferencesToFirestore
      final data = {
        'friendRequests': preferences.friendRequests,
        'activityLikes': preferences.activityLikes,
        'activityComments': preferences.activityComments,
        'gameInvites': preferences.gameInvites,
        'venueRecommendations': preferences.venueRecommendations,
        'newFollowers': preferences.newFollowers,
        'groupActivity': preferences.groupActivity,
        'achievements': preferences.achievements,
        'systemUpdates': preferences.systemUpdates,
        'pushNotifications': preferences.pushNotifications,
        'emailNotifications': preferences.emailNotifications,
        'quietHoursStart': preferences.quietHoursStart,
        'quietHoursEnd': preferences.quietHoursEnd,
      };

      expect(data['friendRequests'], isFalse);
      expect(data['activityLikes'], isTrue);
      expect(data['emailNotifications'], isTrue);
      expect(data['quietHoursStart'], equals('23:00'));
      expect(data['quietHoursEnd'], equals('07:00'));
    });

    test('preferences roundtrip preserves all fields', () {
      // Simulate Firestore data
      final firestoreData = <String, dynamic>{
        'friendRequests': false,
        'activityLikes': false,
        'activityComments': true,
        'gameInvites': true,
        'venueRecommendations': false,
        'newFollowers': false,
        'groupActivity': true,
        'achievements': false,
        'systemUpdates': true,
        'pushNotifications': false,
        'emailNotifications': true,
        'quietHoursStart': '21:00',
        'quietHoursEnd': '06:00',
      };

      // Simulate _preferencesFromFirestore
      final restored = NotificationPreferences(
        friendRequests: (firestoreData['friendRequests'] as bool?) ?? true,
        activityLikes: (firestoreData['activityLikes'] as bool?) ?? true,
        activityComments: (firestoreData['activityComments'] as bool?) ?? true,
        gameInvites: (firestoreData['gameInvites'] as bool?) ?? true,
        venueRecommendations: (firestoreData['venueRecommendations'] as bool?) ?? true,
        newFollowers: (firestoreData['newFollowers'] as bool?) ?? true,
        groupActivity: (firestoreData['groupActivity'] as bool?) ?? true,
        achievements: (firestoreData['achievements'] as bool?) ?? true,
        systemUpdates: (firestoreData['systemUpdates'] as bool?) ?? true,
        pushNotifications: (firestoreData['pushNotifications'] as bool?) ?? true,
        emailNotifications: (firestoreData['emailNotifications'] as bool?) ?? false,
        quietHoursStart: (firestoreData['quietHoursStart'] as String?) ?? '22:00',
        quietHoursEnd: (firestoreData['quietHoursEnd'] as String?) ?? '08:00',
      );

      expect(restored.friendRequests, isFalse);
      expect(restored.activityLikes, isFalse);
      expect(restored.emailNotifications, isTrue);
      expect(restored.pushNotifications, isFalse);
      expect(restored.quietHoursStart, equals('21:00'));
      expect(restored.quietHoursEnd, equals('06:00'));
    });

    test('preferences from Firestore with missing fields uses defaults', () {
      final firestoreData = <String, dynamic>{};

      // Simulate _preferencesFromFirestore with defaults
      final restored = NotificationPreferences(
        friendRequests: (firestoreData['friendRequests'] as bool?) ?? true,
        activityLikes: (firestoreData['activityLikes'] as bool?) ?? true,
        activityComments: (firestoreData['activityComments'] as bool?) ?? true,
        gameInvites: (firestoreData['gameInvites'] as bool?) ?? true,
        venueRecommendations: (firestoreData['venueRecommendations'] as bool?) ?? true,
        newFollowers: (firestoreData['newFollowers'] as bool?) ?? true,
        groupActivity: (firestoreData['groupActivity'] as bool?) ?? true,
        achievements: (firestoreData['achievements'] as bool?) ?? true,
        systemUpdates: (firestoreData['systemUpdates'] as bool?) ?? true,
        pushNotifications: (firestoreData['pushNotifications'] as bool?) ?? true,
        emailNotifications: (firestoreData['emailNotifications'] as bool?) ?? false,
        quietHoursStart: (firestoreData['quietHoursStart'] as String?) ?? '22:00',
        quietHoursEnd: (firestoreData['quietHoursEnd'] as String?) ?? '08:00',
      );

      expect(restored.friendRequests, isTrue);
      expect(restored.pushNotifications, isTrue);
      expect(restored.emailNotifications, isFalse);
      expect(restored.quietHoursStart, equals('22:00'));
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/social/domain/entities/notification.dart';

void main() {
  group('NotificationPreferences', () {
    test('can be constructed with default values', () {
      const prefs = NotificationPreferences();

      expect(prefs.friendRequests, true);
      expect(prefs.activityLikes, true);
      expect(prefs.activityComments, true);
      expect(prefs.gameInvites, true);
      expect(prefs.venueRecommendations, true);
      expect(prefs.newFollowers, true);
      expect(prefs.groupActivity, true);
      expect(prefs.achievements, true);
      expect(prefs.systemUpdates, true);
      expect(prefs.pushNotifications, true);
      expect(prefs.emailNotifications, false);
      expect(prefs.quietHoursStart, '22:00');
      expect(prefs.quietHoursEnd, '08:00');
    });

    test('can be constructed with custom values', () {
      const prefs = NotificationPreferences(
        friendRequests: false,
        activityLikes: false,
        activityComments: true,
        gameInvites: false,
        venueRecommendations: true,
        newFollowers: false,
        groupActivity: true,
        achievements: false,
        systemUpdates: true,
        pushNotifications: false,
        emailNotifications: true,
        quietHoursStart: '23:00',
        quietHoursEnd: '07:00',
      );

      expect(prefs.friendRequests, false);
      expect(prefs.activityLikes, false);
      expect(prefs.activityComments, true);
      expect(prefs.gameInvites, false);
      expect(prefs.venueRecommendations, true);
      expect(prefs.newFollowers, false);
      expect(prefs.groupActivity, true);
      expect(prefs.achievements, false);
      expect(prefs.systemUpdates, true);
      expect(prefs.pushNotifications, false);
      expect(prefs.emailNotifications, true);
      expect(prefs.quietHoursStart, '23:00');
      expect(prefs.quietHoursEnd, '07:00');
    });

    test('copyWith creates new instance with updated values', () {
      const original = NotificationPreferences();
      final updated = original.copyWith(
        friendRequests: false,
        quietHoursStart: '23:00',
      );

      expect(updated.friendRequests, false);
      expect(updated.quietHoursStart, '23:00');
      expect(updated.activityLikes, true); // unchanged
      expect(updated.quietHoursEnd, '08:00'); // unchanged
    });

    test('copyWith preserves unchanged values', () {
      const original = NotificationPreferences(
        friendRequests: false,
        activityLikes: false,
      );
      final updated = original.copyWith(gameInvites: false);

      expect(updated.friendRequests, false);
      expect(updated.activityLikes, false);
      expect(updated.gameInvites, false);
    });

    test('defaultPreferences returns default configuration', () {
      final prefs = NotificationPreferences.defaultPreferences();

      expect(prefs.friendRequests, true);
      expect(prefs.pushNotifications, true);
      expect(prefs.emailNotifications, false);
      expect(prefs.quietHoursStart, '22:00');
      expect(prefs.quietHoursEnd, '08:00');
    });

    test('shouldNotifyForType returns correct value for friend requests', () {
      const prefs = NotificationPreferences(friendRequests: true);

      expect(prefs.shouldNotifyForType(NotificationType.friendRequest), true);
      expect(prefs.shouldNotifyForType(NotificationType.friendRequestAccepted), true);
    });

    test('shouldNotifyForType returns correct value for activity', () {
      const prefs = NotificationPreferences(
        activityLikes: true,
        activityComments: false,
      );

      expect(prefs.shouldNotifyForType(NotificationType.activityLike), true);
      expect(prefs.shouldNotifyForType(NotificationType.activityComment), false);
    });

    test('shouldNotifyForType returns correct value for game invites', () {
      const prefs = NotificationPreferences(gameInvites: true);

      expect(prefs.shouldNotifyForType(NotificationType.gameInvite), true);
      expect(prefs.shouldNotifyForType(NotificationType.watchPartyInvite), true);
      expect(prefs.shouldNotifyForType(NotificationType.matchReminder), true);
      expect(prefs.shouldNotifyForType(NotificationType.favoriteTeamMatch), true);
    });

    test('shouldNotifyForType respects all notification types', () {
      const enabledPrefs = NotificationPreferences();

      expect(enabledPrefs.shouldNotifyForType(NotificationType.friendRequest), true);
      expect(enabledPrefs.shouldNotifyForType(NotificationType.activityLike), true);
      expect(enabledPrefs.shouldNotifyForType(NotificationType.activityComment), true);
      expect(enabledPrefs.shouldNotifyForType(NotificationType.gameInvite), true);
      expect(enabledPrefs.shouldNotifyForType(NotificationType.venueRecommendation), true);
      expect(enabledPrefs.shouldNotifyForType(NotificationType.newFollower), true);
      expect(enabledPrefs.shouldNotifyForType(NotificationType.groupInvite), true);
      expect(enabledPrefs.shouldNotifyForType(NotificationType.achievement), true);
      expect(enabledPrefs.shouldNotifyForType(NotificationType.systemUpdate), true);
    });

    test('shouldNotifyForType returns false when disabled', () {
      const disabledPrefs = NotificationPreferences(
        friendRequests: false,
        activityLikes: false,
        activityComments: false,
        gameInvites: false,
        venueRecommendations: false,
        newFollowers: false,
        groupActivity: false,
        achievements: false,
        systemUpdates: false,
      );

      expect(disabledPrefs.shouldNotifyForType(NotificationType.friendRequest), false);
      expect(disabledPrefs.shouldNotifyForType(NotificationType.activityLike), false);
      expect(disabledPrefs.shouldNotifyForType(NotificationType.gameInvite), false);
      expect(disabledPrefs.shouldNotifyForType(NotificationType.venueRecommendation), false);
      expect(disabledPrefs.shouldNotifyForType(NotificationType.newFollower), false);
      expect(disabledPrefs.shouldNotifyForType(NotificationType.groupInvite), false);
      expect(disabledPrefs.shouldNotifyForType(NotificationType.achievement), false);
      expect(disabledPrefs.shouldNotifyForType(NotificationType.systemUpdate), false);
    });

    test('supports equality comparison', () {
      const prefs1 = NotificationPreferences(
        friendRequests: true,
        quietHoursStart: '22:00',
      );
      const prefs2 = NotificationPreferences(
        friendRequests: true,
        quietHoursStart: '22:00',
      );
      const prefs3 = NotificationPreferences(
        friendRequests: false,
        quietHoursStart: '22:00',
      );

      expect(prefs1, equals(prefs2));
      expect(prefs1, isNot(equals(prefs3)));
    });

    test('all fields are included in props for equality', () {
      const prefs = NotificationPreferences();

      expect(prefs.props.length, 13);
      expect(prefs.props, contains(prefs.friendRequests));
      expect(prefs.props, contains(prefs.activityLikes));
      expect(prefs.props, contains(prefs.activityComments));
      expect(prefs.props, contains(prefs.gameInvites));
      expect(prefs.props, contains(prefs.venueRecommendations));
      expect(prefs.props, contains(prefs.newFollowers));
      expect(prefs.props, contains(prefs.groupActivity));
      expect(prefs.props, contains(prefs.achievements));
      expect(prefs.props, contains(prefs.systemUpdates));
      expect(prefs.props, contains(prefs.pushNotifications));
      expect(prefs.props, contains(prefs.emailNotifications));
      expect(prefs.props, contains(prefs.quietHoursStart));
      expect(prefs.props, contains(prefs.quietHoursEnd));
    });

    test('copyWith can toggle all boolean fields', () {
      const original = NotificationPreferences();

      final updated = original.copyWith(
        friendRequests: false,
        activityLikes: false,
        activityComments: false,
        gameInvites: false,
        venueRecommendations: false,
        newFollowers: false,
        groupActivity: false,
        achievements: false,
        systemUpdates: false,
        pushNotifications: false,
        emailNotifications: true,
      );

      expect(updated.friendRequests, false);
      expect(updated.activityLikes, false);
      expect(updated.activityComments, false);
      expect(updated.gameInvites, false);
      expect(updated.venueRecommendations, false);
      expect(updated.newFollowers, false);
      expect(updated.groupActivity, false);
      expect(updated.achievements, false);
      expect(updated.systemUpdates, false);
      expect(updated.pushNotifications, false);
      expect(updated.emailNotifications, true);
    });

    test('copyWith can update quiet hours', () {
      const original = NotificationPreferences();

      final updated = original.copyWith(
        quietHoursStart: '23:30',
        quietHoursEnd: '07:30',
      );

      expect(updated.quietHoursStart, '23:30');
      expect(updated.quietHoursEnd, '07:30');
    });

    test('multiple copyWith calls create correct chain', () {
      const original = NotificationPreferences();

      final step1 = original.copyWith(friendRequests: false);
      final step2 = step1.copyWith(activityLikes: false);
      final step3 = step2.copyWith(gameInvites: false);

      expect(step3.friendRequests, false);
      expect(step3.activityLikes, false);
      expect(step3.gameInvites, false);
      expect(step3.venueRecommendations, true); // unchanged
    });
  });
}

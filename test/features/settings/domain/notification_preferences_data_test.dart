import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/services/notification_preferences_service.dart';
import 'package:pregame_world_cup/features/worldcup/domain/entities/match_reminder.dart';

void main() {
  group('NotificationPreferencesData', () {
    group('Constructor defaults', () {
      test('creates with all default values', () {
        const prefs = NotificationPreferencesData();

        expect(prefs.pushNotificationsEnabled, isTrue);
        expect(prefs.quietHoursEnabled, isFalse);
        expect(prefs.quietHoursStart, equals('22:00'));
        expect(prefs.quietHoursEnd, equals('08:00'));
        expect(prefs.matchRemindersEnabled, isTrue);
        expect(prefs.defaultReminderTiming, equals(ReminderTiming.thirtyMinutes));
        expect(prefs.favoriteTeamMatchesEnabled, isTrue);
        expect(prefs.favoriteTeamMatchDayBefore, isTrue);
        expect(prefs.goalAlertsEnabled, isTrue);
        expect(prefs.matchStartAlertsEnabled, isTrue);
        expect(prefs.matchEndAlertsEnabled, isFalse);
        expect(prefs.halftimeAlertsEnabled, isFalse);
        expect(prefs.redCardAlertsEnabled, isTrue);
        expect(prefs.penaltyAlertsEnabled, isTrue);
        expect(prefs.watchPartyInvitesEnabled, isTrue);
        expect(prefs.watchPartyRemindersEnabled, isTrue);
        expect(prefs.watchPartyReminderTiming, equals(ReminderTiming.oneHour));
        expect(prefs.watchPartyUpdatesEnabled, isTrue);
        expect(prefs.friendRequestsEnabled, isTrue);
        expect(prefs.messagesEnabled, isTrue);
        expect(prefs.mentionsEnabled, isTrue);
        expect(prefs.predictionResultsEnabled, isTrue);
        expect(prefs.leaderboardUpdatesEnabled, isFalse);
      });

      test('creates with custom values', () {
        const prefs = NotificationPreferencesData(
          pushNotificationsEnabled: false,
          quietHoursEnabled: true,
          quietHoursStart: '23:00',
          quietHoursEnd: '07:00',
          matchRemindersEnabled: false,
          defaultReminderTiming: ReminderTiming.oneHour,
          goalAlertsEnabled: false,
          redCardAlertsEnabled: false,
        );

        expect(prefs.pushNotificationsEnabled, isFalse);
        expect(prefs.quietHoursEnabled, isTrue);
        expect(prefs.quietHoursStart, equals('23:00'));
        expect(prefs.quietHoursEnd, equals('07:00'));
        expect(prefs.matchRemindersEnabled, isFalse);
        expect(prefs.defaultReminderTiming, equals(ReminderTiming.oneHour));
        expect(prefs.goalAlertsEnabled, isFalse);
        expect(prefs.redCardAlertsEnabled, isFalse);
      });
    });

    group('copyWith', () {
      test('copies with single field change', () {
        const original = NotificationPreferencesData();
        final updated = original.copyWith(pushNotificationsEnabled: false);

        expect(updated.pushNotificationsEnabled, isFalse);
        // All other fields should remain unchanged
        expect(updated.quietHoursEnabled, equals(original.quietHoursEnabled));
        expect(updated.matchRemindersEnabled, equals(original.matchRemindersEnabled));
        expect(updated.goalAlertsEnabled, equals(original.goalAlertsEnabled));
        expect(updated.friendRequestsEnabled, equals(original.friendRequestsEnabled));
      });

      test('copies with multiple field changes', () {
        const original = NotificationPreferencesData();
        final updated = original.copyWith(
          quietHoursEnabled: true,
          quietHoursStart: '21:00',
          quietHoursEnd: '09:00',
          goalAlertsEnabled: false,
          messagesEnabled: false,
        );

        expect(updated.quietHoursEnabled, isTrue);
        expect(updated.quietHoursStart, equals('21:00'));
        expect(updated.quietHoursEnd, equals('09:00'));
        expect(updated.goalAlertsEnabled, isFalse);
        expect(updated.messagesEnabled, isFalse);
        // Unchanged fields
        expect(updated.pushNotificationsEnabled, isTrue);
        expect(updated.matchRemindersEnabled, isTrue);
      });

      test('copies with no changes returns equal object', () {
        const original = NotificationPreferencesData();
        final copied = original.copyWith();

        expect(copied, equals(original));
      });

      test('copies reminder timing fields', () {
        const original = NotificationPreferencesData();
        final updated = original.copyWith(
          defaultReminderTiming: ReminderTiming.twoHours,
          watchPartyReminderTiming: ReminderTiming.fifteenMinutes,
        );

        expect(updated.defaultReminderTiming, equals(ReminderTiming.twoHours));
        expect(updated.watchPartyReminderTiming, equals(ReminderTiming.fifteenMinutes));
      });
    });

    group('JSON serialization', () {
      test('toJson serializes all fields', () {
        const prefs = NotificationPreferencesData(
          pushNotificationsEnabled: false,
          quietHoursEnabled: true,
          quietHoursStart: '23:00',
          quietHoursEnd: '07:00',
          matchRemindersEnabled: false,
          defaultReminderTiming: ReminderTiming.oneHour,
          favoriteTeamMatchesEnabled: false,
          favoriteTeamMatchDayBefore: false,
          goalAlertsEnabled: false,
          matchStartAlertsEnabled: false,
          matchEndAlertsEnabled: true,
          halftimeAlertsEnabled: true,
          redCardAlertsEnabled: false,
          penaltyAlertsEnabled: false,
          watchPartyInvitesEnabled: false,
          watchPartyRemindersEnabled: false,
          watchPartyReminderTiming: ReminderTiming.twoHours,
          watchPartyUpdatesEnabled: false,
          friendRequestsEnabled: false,
          messagesEnabled: false,
          mentionsEnabled: false,
          predictionResultsEnabled: false,
          leaderboardUpdatesEnabled: true,
        );

        final json = prefs.toJson();

        expect(json['pushNotificationsEnabled'], isFalse);
        expect(json['quietHoursEnabled'], isTrue);
        expect(json['quietHoursStart'], equals('23:00'));
        expect(json['quietHoursEnd'], equals('07:00'));
        expect(json['matchRemindersEnabled'], isFalse);
        expect(json['defaultReminderTimingMinutes'], equals(60));
        expect(json['favoriteTeamMatchesEnabled'], isFalse);
        expect(json['favoriteTeamMatchDayBefore'], isFalse);
        expect(json['goalAlertsEnabled'], isFalse);
        expect(json['matchStartAlertsEnabled'], isFalse);
        expect(json['matchEndAlertsEnabled'], isTrue);
        expect(json['halftimeAlertsEnabled'], isTrue);
        expect(json['redCardAlertsEnabled'], isFalse);
        expect(json['penaltyAlertsEnabled'], isFalse);
        expect(json['watchPartyInvitesEnabled'], isFalse);
        expect(json['watchPartyRemindersEnabled'], isFalse);
        expect(json['watchPartyReminderTimingMinutes'], equals(120));
        expect(json['watchPartyUpdatesEnabled'], isFalse);
        expect(json['friendRequestsEnabled'], isFalse);
        expect(json['messagesEnabled'], isFalse);
        expect(json['mentionsEnabled'], isFalse);
        expect(json['predictionResultsEnabled'], isFalse);
        expect(json['leaderboardUpdatesEnabled'], isTrue);
      });

      test('fromJson deserializes all fields', () {
        final json = {
          'pushNotificationsEnabled': false,
          'quietHoursEnabled': true,
          'quietHoursStart': '21:00',
          'quietHoursEnd': '06:00',
          'matchRemindersEnabled': false,
          'defaultReminderTimingMinutes': 120,
          'favoriteTeamMatchesEnabled': false,
          'favoriteTeamMatchDayBefore': false,
          'goalAlertsEnabled': false,
          'matchStartAlertsEnabled': false,
          'matchEndAlertsEnabled': true,
          'halftimeAlertsEnabled': true,
          'redCardAlertsEnabled': false,
          'penaltyAlertsEnabled': false,
          'watchPartyInvitesEnabled': false,
          'watchPartyRemindersEnabled': false,
          'watchPartyReminderTimingMinutes': 15,
          'watchPartyUpdatesEnabled': false,
          'friendRequestsEnabled': false,
          'messagesEnabled': false,
          'mentionsEnabled': false,
          'predictionResultsEnabled': false,
          'leaderboardUpdatesEnabled': true,
        };

        final prefs = NotificationPreferencesData.fromJson(json);

        expect(prefs.pushNotificationsEnabled, isFalse);
        expect(prefs.quietHoursEnabled, isTrue);
        expect(prefs.quietHoursStart, equals('21:00'));
        expect(prefs.quietHoursEnd, equals('06:00'));
        expect(prefs.matchRemindersEnabled, isFalse);
        expect(prefs.defaultReminderTiming, equals(ReminderTiming.twoHours));
        expect(prefs.favoriteTeamMatchesEnabled, isFalse);
        expect(prefs.favoriteTeamMatchDayBefore, isFalse);
        expect(prefs.goalAlertsEnabled, isFalse);
        expect(prefs.matchStartAlertsEnabled, isFalse);
        expect(prefs.matchEndAlertsEnabled, isTrue);
        expect(prefs.halftimeAlertsEnabled, isTrue);
        expect(prefs.redCardAlertsEnabled, isFalse);
        expect(prefs.penaltyAlertsEnabled, isFalse);
        expect(prefs.watchPartyInvitesEnabled, isFalse);
        expect(prefs.watchPartyRemindersEnabled, isFalse);
        expect(prefs.watchPartyReminderTiming, equals(ReminderTiming.fifteenMinutes));
        expect(prefs.watchPartyUpdatesEnabled, isFalse);
        expect(prefs.friendRequestsEnabled, isFalse);
        expect(prefs.messagesEnabled, isFalse);
        expect(prefs.mentionsEnabled, isFalse);
        expect(prefs.predictionResultsEnabled, isFalse);
        expect(prefs.leaderboardUpdatesEnabled, isTrue);
      });

      test('fromJson handles missing fields with defaults', () {
        final prefs = NotificationPreferencesData.fromJson({});

        expect(prefs.pushNotificationsEnabled, isTrue);
        expect(prefs.quietHoursEnabled, isFalse);
        expect(prefs.quietHoursStart, equals('22:00'));
        expect(prefs.quietHoursEnd, equals('08:00'));
        expect(prefs.matchRemindersEnabled, isTrue);
        expect(prefs.defaultReminderTiming, equals(ReminderTiming.thirtyMinutes));
        expect(prefs.goalAlertsEnabled, isTrue);
        expect(prefs.leaderboardUpdatesEnabled, isFalse);
      });

      test('fromJson handles partial JSON data', () {
        final json = {
          'pushNotificationsEnabled': false,
          'goalAlertsEnabled': false,
        };

        final prefs = NotificationPreferencesData.fromJson(json);

        expect(prefs.pushNotificationsEnabled, isFalse);
        expect(prefs.goalAlertsEnabled, isFalse);
        // Missing fields get defaults
        expect(prefs.quietHoursEnabled, isFalse);
        expect(prefs.matchRemindersEnabled, isTrue);
        expect(prefs.friendRequestsEnabled, isTrue);
      });

      test('roundtrip serialization preserves all data', () {
        const original = NotificationPreferencesData(
          pushNotificationsEnabled: false,
          quietHoursEnabled: true,
          quietHoursStart: '20:00',
          quietHoursEnd: '06:30',
          matchRemindersEnabled: false,
          defaultReminderTiming: ReminderTiming.twoHours,
          favoriteTeamMatchesEnabled: false,
          goalAlertsEnabled: false,
          matchEndAlertsEnabled: true,
          halftimeAlertsEnabled: true,
          watchPartyReminderTiming: ReminderTiming.fifteenMinutes,
          leaderboardUpdatesEnabled: true,
        );

        final json = original.toJson();
        final restored = NotificationPreferencesData.fromJson(json);

        expect(restored, equals(original));
      });

      test('fromJson handles unknown reminder timing with default', () {
        final json = {
          'defaultReminderTimingMinutes': 999,
        };

        final prefs = NotificationPreferencesData.fromJson(json);

        // Should fall back to thirtyMinutes
        expect(prefs.defaultReminderTiming, equals(ReminderTiming.thirtyMinutes));
      });
    });

    group('Equality', () {
      test('two default instances are equal', () {
        const prefs1 = NotificationPreferencesData();
        const prefs2 = NotificationPreferencesData();

        expect(prefs1, equals(prefs2));
        expect(prefs1.hashCode, equals(prefs2.hashCode));
      });

      test('instances with different values are not equal', () {
        const prefs1 = NotificationPreferencesData(pushNotificationsEnabled: true);
        const prefs2 = NotificationPreferencesData(pushNotificationsEnabled: false);

        expect(prefs1, isNot(equals(prefs2)));
      });

      test('instances differing only in quiet hours are not equal', () {
        const prefs1 = NotificationPreferencesData(
          quietHoursEnabled: true,
          quietHoursStart: '22:00',
        );
        const prefs2 = NotificationPreferencesData(
          quietHoursEnabled: true,
          quietHoursStart: '23:00',
        );

        expect(prefs1, isNot(equals(prefs2)));
      });

      test('instances differing only in reminder timing are not equal', () {
        const prefs1 = NotificationPreferencesData(
          defaultReminderTiming: ReminderTiming.thirtyMinutes,
        );
        const prefs2 = NotificationPreferencesData(
          defaultReminderTiming: ReminderTiming.oneHour,
        );

        expect(prefs1, isNot(equals(prefs2)));
      });
    });
  });

  group('ReminderTiming', () {
    test('has all expected values', () {
      expect(ReminderTiming.values.length, equals(5));
      expect(ReminderTiming.values, contains(ReminderTiming.fifteenMinutes));
      expect(ReminderTiming.values, contains(ReminderTiming.thirtyMinutes));
      expect(ReminderTiming.values, contains(ReminderTiming.oneHour));
      expect(ReminderTiming.values, contains(ReminderTiming.twoHours));
      expect(ReminderTiming.values, contains(ReminderTiming.oneDay));
    });

    test('minutes values are correct', () {
      expect(ReminderTiming.fifteenMinutes.minutes, equals(15));
      expect(ReminderTiming.thirtyMinutes.minutes, equals(30));
      expect(ReminderTiming.oneHour.minutes, equals(60));
      expect(ReminderTiming.twoHours.minutes, equals(120));
      expect(ReminderTiming.oneDay.minutes, equals(1440));
    });

    test('display names are correct', () {
      expect(ReminderTiming.fifteenMinutes.displayName, equals('15 minutes'));
      expect(ReminderTiming.thirtyMinutes.displayName, equals('30 minutes'));
      expect(ReminderTiming.oneHour.displayName, equals('1 hour'));
      expect(ReminderTiming.twoHours.displayName, equals('2 hours'));
      expect(ReminderTiming.oneDay.displayName, equals('1 day'));
    });

    test('fromMinutes returns correct timing', () {
      expect(ReminderTiming.fromMinutes(15), equals(ReminderTiming.fifteenMinutes));
      expect(ReminderTiming.fromMinutes(30), equals(ReminderTiming.thirtyMinutes));
      expect(ReminderTiming.fromMinutes(60), equals(ReminderTiming.oneHour));
      expect(ReminderTiming.fromMinutes(120), equals(ReminderTiming.twoHours));
      expect(ReminderTiming.fromMinutes(1440), equals(ReminderTiming.oneDay));
    });

    test('fromMinutes returns default for unknown value', () {
      expect(ReminderTiming.fromMinutes(0), equals(ReminderTiming.thirtyMinutes));
      expect(ReminderTiming.fromMinutes(45), equals(ReminderTiming.thirtyMinutes));
      expect(ReminderTiming.fromMinutes(999), equals(ReminderTiming.thirtyMinutes));
      expect(ReminderTiming.fromMinutes(-1), equals(ReminderTiming.thirtyMinutes));
    });
  });
}

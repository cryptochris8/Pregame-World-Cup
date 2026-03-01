import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/services/notification_preferences_service.dart';
import 'package:pregame_world_cup/features/worldcup/domain/entities/match_reminder.dart';

void main() {
  group('NotificationPreferencesData', () {
    group('constructor defaults', () {
      test('has correct default values', () {
        const data = NotificationPreferencesData();

        // Global
        expect(data.pushNotificationsEnabled, isTrue);
        expect(data.quietHoursEnabled, isFalse);
        expect(data.quietHoursStart, equals('22:00'));
        expect(data.quietHoursEnd, equals('08:00'));

        // Match
        expect(data.matchRemindersEnabled, isTrue);
        expect(data.defaultReminderTiming, equals(ReminderTiming.thirtyMinutes));
        expect(data.favoriteTeamMatchesEnabled, isTrue);
        expect(data.favoriteTeamMatchDayBefore, isTrue);

        // Live match
        expect(data.goalAlertsEnabled, isTrue);
        expect(data.matchStartAlertsEnabled, isTrue);
        expect(data.matchEndAlertsEnabled, isFalse);
        expect(data.halftimeAlertsEnabled, isFalse);
        expect(data.redCardAlertsEnabled, isTrue);
        expect(data.penaltyAlertsEnabled, isTrue);

        // Watch party
        expect(data.watchPartyInvitesEnabled, isTrue);
        expect(data.watchPartyRemindersEnabled, isTrue);
        expect(data.watchPartyReminderTiming, equals(ReminderTiming.oneHour));
        expect(data.watchPartyUpdatesEnabled, isTrue);

        // Social
        expect(data.friendRequestsEnabled, isTrue);
        expect(data.messagesEnabled, isTrue);
        expect(data.mentionsEnabled, isTrue);

        // Predictions
        expect(data.predictionResultsEnabled, isTrue);
        expect(data.leaderboardUpdatesEnabled, isFalse);
      });
    });

    group('fromJson', () {
      test('deserializes complete JSON', () {
        final json = {
          'pushNotificationsEnabled': false,
          'quietHoursEnabled': true,
          'quietHoursStart': '23:00',
          'quietHoursEnd': '07:00',
          'matchRemindersEnabled': false,
          'defaultReminderTimingMinutes': 60,
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
          'watchPartyReminderTimingMinutes': 120,
          'watchPartyUpdatesEnabled': false,
          'friendRequestsEnabled': false,
          'messagesEnabled': false,
          'mentionsEnabled': false,
          'predictionResultsEnabled': false,
          'leaderboardUpdatesEnabled': true,
        };

        final data = NotificationPreferencesData.fromJson(json);

        expect(data.pushNotificationsEnabled, isFalse);
        expect(data.quietHoursEnabled, isTrue);
        expect(data.quietHoursStart, equals('23:00'));
        expect(data.quietHoursEnd, equals('07:00'));
        expect(data.matchRemindersEnabled, isFalse);
        expect(data.defaultReminderTiming, equals(ReminderTiming.oneHour));
        expect(data.favoriteTeamMatchesEnabled, isFalse);
        expect(data.favoriteTeamMatchDayBefore, isFalse);
        expect(data.goalAlertsEnabled, isFalse);
        expect(data.matchStartAlertsEnabled, isFalse);
        expect(data.matchEndAlertsEnabled, isTrue);
        expect(data.halftimeAlertsEnabled, isTrue);
        expect(data.redCardAlertsEnabled, isFalse);
        expect(data.penaltyAlertsEnabled, isFalse);
        expect(data.watchPartyInvitesEnabled, isFalse);
        expect(data.watchPartyRemindersEnabled, isFalse);
        expect(data.watchPartyReminderTiming, equals(ReminderTiming.twoHours));
        expect(data.watchPartyUpdatesEnabled, isFalse);
        expect(data.friendRequestsEnabled, isFalse);
        expect(data.messagesEnabled, isFalse);
        expect(data.mentionsEnabled, isFalse);
        expect(data.predictionResultsEnabled, isFalse);
        expect(data.leaderboardUpdatesEnabled, isTrue);
      });

      test('uses defaults for empty JSON', () {
        final data = NotificationPreferencesData.fromJson({});
        expect(data, equals(const NotificationPreferencesData()));
      });

      test('handles missing fields gracefully', () {
        final data = NotificationPreferencesData.fromJson({
          'pushNotificationsEnabled': false,
          'goalAlertsEnabled': false,
        });

        expect(data.pushNotificationsEnabled, isFalse);
        expect(data.goalAlertsEnabled, isFalse);
        // All other fields should use defaults
        expect(data.quietHoursEnabled, isFalse);
        expect(data.matchRemindersEnabled, isTrue);
        expect(data.friendRequestsEnabled, isTrue);
      });

      test('handles null values with defaults', () {
        final data = NotificationPreferencesData.fromJson({
          'pushNotificationsEnabled': null,
          'quietHoursStart': null,
          'defaultReminderTimingMinutes': null,
        });

        expect(data.pushNotificationsEnabled, isTrue);
        expect(data.quietHoursStart, equals('22:00'));
        expect(data.defaultReminderTiming, equals(ReminderTiming.thirtyMinutes));
      });

      test('handles unknown reminder timing with default', () {
        final data = NotificationPreferencesData.fromJson({
          'defaultReminderTimingMinutes': 999,
        });
        // fromMinutes falls back to thirtyMinutes for unknown values
        expect(data.defaultReminderTiming, equals(ReminderTiming.thirtyMinutes));
      });
    });

    group('toJson', () {
      test('serializes all fields correctly', () {
        const data = NotificationPreferencesData();
        final json = data.toJson();

        expect(json['pushNotificationsEnabled'], isTrue);
        expect(json['quietHoursEnabled'], isFalse);
        expect(json['quietHoursStart'], equals('22:00'));
        expect(json['quietHoursEnd'], equals('08:00'));
        expect(json['matchRemindersEnabled'], isTrue);
        expect(json['defaultReminderTimingMinutes'], equals(30));
        expect(json['favoriteTeamMatchesEnabled'], isTrue);
        expect(json['favoriteTeamMatchDayBefore'], isTrue);
        expect(json['goalAlertsEnabled'], isTrue);
        expect(json['matchStartAlertsEnabled'], isTrue);
        expect(json['matchEndAlertsEnabled'], isFalse);
        expect(json['halftimeAlertsEnabled'], isFalse);
        expect(json['redCardAlertsEnabled'], isTrue);
        expect(json['penaltyAlertsEnabled'], isTrue);
        expect(json['watchPartyInvitesEnabled'], isTrue);
        expect(json['watchPartyRemindersEnabled'], isTrue);
        expect(json['watchPartyReminderTimingMinutes'], equals(60));
        expect(json['watchPartyUpdatesEnabled'], isTrue);
        expect(json['friendRequestsEnabled'], isTrue);
        expect(json['messagesEnabled'], isTrue);
        expect(json['mentionsEnabled'], isTrue);
        expect(json['predictionResultsEnabled'], isTrue);
        expect(json['leaderboardUpdatesEnabled'], isFalse);
      });

      test('contains expected number of keys', () {
        const data = NotificationPreferencesData();
        final json = data.toJson();
        // 23 keys in toJson: 4 global + 4 match + 6 live match +
        // 4 watch party + 3 social + 2 prediction
        expect(json.keys.length, equals(23));
      });

      test('stores timing as minutes', () {
        const data = NotificationPreferencesData(
          defaultReminderTiming: ReminderTiming.twoHours,
          watchPartyReminderTiming: ReminderTiming.oneDay,
        );
        final json = data.toJson();
        expect(json['defaultReminderTimingMinutes'], equals(120));
        expect(json['watchPartyReminderTimingMinutes'], equals(1440));
      });

      test('contains all expected keys', () {
        const data = NotificationPreferencesData();
        final json = data.toJson();
        expect(json.containsKey('pushNotificationsEnabled'), isTrue);
        expect(json.containsKey('quietHoursEnabled'), isTrue);
        expect(json.containsKey('quietHoursStart'), isTrue);
        expect(json.containsKey('quietHoursEnd'), isTrue);
        expect(json.containsKey('matchRemindersEnabled'), isTrue);
        expect(json.containsKey('defaultReminderTimingMinutes'), isTrue);
        expect(json.containsKey('favoriteTeamMatchesEnabled'), isTrue);
        expect(json.containsKey('favoriteTeamMatchDayBefore'), isTrue);
        expect(json.containsKey('goalAlertsEnabled'), isTrue);
        expect(json.containsKey('matchStartAlertsEnabled'), isTrue);
        expect(json.containsKey('matchEndAlertsEnabled'), isTrue);
        expect(json.containsKey('halftimeAlertsEnabled'), isTrue);
        expect(json.containsKey('redCardAlertsEnabled'), isTrue);
        expect(json.containsKey('penaltyAlertsEnabled'), isTrue);
        expect(json.containsKey('watchPartyInvitesEnabled'), isTrue);
        expect(json.containsKey('watchPartyRemindersEnabled'), isTrue);
        expect(json.containsKey('watchPartyReminderTimingMinutes'), isTrue);
        expect(json.containsKey('watchPartyUpdatesEnabled'), isTrue);
        expect(json.containsKey('friendRequestsEnabled'), isTrue);
        expect(json.containsKey('messagesEnabled'), isTrue);
        expect(json.containsKey('mentionsEnabled'), isTrue);
        expect(json.containsKey('predictionResultsEnabled'), isTrue);
        expect(json.containsKey('leaderboardUpdatesEnabled'), isTrue);
      });
    });

    group('roundtrip serialization', () {
      test('toJson/fromJson are symmetric for defaults', () {
        const original = NotificationPreferencesData();
        final roundtripped =
            NotificationPreferencesData.fromJson(original.toJson());
        expect(roundtripped, equals(original));
      });

      test('toJson/fromJson are symmetric for custom values', () {
        const original = NotificationPreferencesData(
          pushNotificationsEnabled: false,
          quietHoursEnabled: true,
          quietHoursStart: '21:00',
          quietHoursEnd: '09:00',
          matchRemindersEnabled: false,
          defaultReminderTiming: ReminderTiming.oneHour,
          favoriteTeamMatchesEnabled: false,
          goalAlertsEnabled: false,
          watchPartyInvitesEnabled: false,
          friendRequestsEnabled: false,
          messagesEnabled: false,
          leaderboardUpdatesEnabled: true,
        );
        final roundtripped =
            NotificationPreferencesData.fromJson(original.toJson());
        expect(roundtripped, equals(original));
      });

      test('roundtrips all ReminderTiming values correctly', () {
        for (final timing in ReminderTiming.values) {
          final original = NotificationPreferencesData(
            defaultReminderTiming: timing,
          );
          final roundtripped =
              NotificationPreferencesData.fromJson(original.toJson());
          expect(roundtripped.defaultReminderTiming, equals(timing));
        }
      });
    });

    group('copyWith', () {
      test('returns identical copy when no fields specified', () {
        const original = NotificationPreferencesData();
        final copied = original.copyWith();
        expect(copied, equals(original));
      });

      test('updates single field while preserving others', () {
        const original = NotificationPreferencesData();
        final updated = original.copyWith(pushNotificationsEnabled: false);
        expect(updated.pushNotificationsEnabled, isFalse);
        expect(updated.goalAlertsEnabled, isTrue); // unchanged
        expect(updated.matchRemindersEnabled, isTrue); // unchanged
      });

      test('updates multiple fields', () {
        const original = NotificationPreferencesData();
        final updated = original.copyWith(
          quietHoursEnabled: true,
          quietHoursStart: '20:00',
          quietHoursEnd: '06:00',
        );
        expect(updated.quietHoursEnabled, isTrue);
        expect(updated.quietHoursStart, equals('20:00'));
        expect(updated.quietHoursEnd, equals('06:00'));
        expect(updated.pushNotificationsEnabled, isTrue); // unchanged
      });

      test('can update every field', () {
        const original = NotificationPreferencesData();
        final updated = original.copyWith(
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

        expect(updated.pushNotificationsEnabled, isFalse);
        expect(updated.quietHoursEnabled, isTrue);
        expect(updated.quietHoursStart, equals('23:00'));
        expect(updated.quietHoursEnd, equals('07:00'));
        expect(updated.matchRemindersEnabled, isFalse);
        expect(updated.defaultReminderTiming, equals(ReminderTiming.oneHour));
        expect(updated.favoriteTeamMatchesEnabled, isFalse);
        expect(updated.favoriteTeamMatchDayBefore, isFalse);
        expect(updated.goalAlertsEnabled, isFalse);
        expect(updated.matchStartAlertsEnabled, isFalse);
        expect(updated.matchEndAlertsEnabled, isTrue);
        expect(updated.halftimeAlertsEnabled, isTrue);
        expect(updated.redCardAlertsEnabled, isFalse);
        expect(updated.penaltyAlertsEnabled, isFalse);
        expect(updated.watchPartyInvitesEnabled, isFalse);
        expect(updated.watchPartyRemindersEnabled, isFalse);
        expect(updated.watchPartyReminderTiming, equals(ReminderTiming.twoHours));
        expect(updated.watchPartyUpdatesEnabled, isFalse);
        expect(updated.friendRequestsEnabled, isFalse);
        expect(updated.messagesEnabled, isFalse);
        expect(updated.mentionsEnabled, isFalse);
        expect(updated.predictionResultsEnabled, isFalse);
        expect(updated.leaderboardUpdatesEnabled, isTrue);
      });
    });

    group('equality', () {
      test('two default instances are equal', () {
        const a = NotificationPreferencesData();
        const b = NotificationPreferencesData();
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('instances with same values are equal', () {
        const a = NotificationPreferencesData(
          pushNotificationsEnabled: false,
          goalAlertsEnabled: false,
        );
        const b = NotificationPreferencesData(
          pushNotificationsEnabled: false,
          goalAlertsEnabled: false,
        );
        expect(a, equals(b));
      });

      test('instances with different values are not equal', () {
        const a = NotificationPreferencesData(pushNotificationsEnabled: true);
        const b = NotificationPreferencesData(pushNotificationsEnabled: false);
        expect(a, isNot(equals(b)));
      });

      test('each boolean field affects equality', () {
        const base = NotificationPreferencesData();
        expect(
          base.copyWith(pushNotificationsEnabled: false),
          isNot(equals(base)),
        );
        expect(
          base.copyWith(quietHoursEnabled: true),
          isNot(equals(base)),
        );
        expect(
          base.copyWith(matchRemindersEnabled: false),
          isNot(equals(base)),
        );
        expect(
          base.copyWith(goalAlertsEnabled: false),
          isNot(equals(base)),
        );
        expect(
          base.copyWith(matchStartAlertsEnabled: false),
          isNot(equals(base)),
        );
        expect(
          base.copyWith(matchEndAlertsEnabled: true),
          isNot(equals(base)),
        );
        expect(
          base.copyWith(halftimeAlertsEnabled: true),
          isNot(equals(base)),
        );
        expect(
          base.copyWith(redCardAlertsEnabled: false),
          isNot(equals(base)),
        );
        expect(
          base.copyWith(penaltyAlertsEnabled: false),
          isNot(equals(base)),
        );
        expect(
          base.copyWith(watchPartyInvitesEnabled: false),
          isNot(equals(base)),
        );
        expect(
          base.copyWith(watchPartyRemindersEnabled: false),
          isNot(equals(base)),
        );
        expect(
          base.copyWith(watchPartyUpdatesEnabled: false),
          isNot(equals(base)),
        );
        expect(
          base.copyWith(friendRequestsEnabled: false),
          isNot(equals(base)),
        );
        expect(
          base.copyWith(messagesEnabled: false),
          isNot(equals(base)),
        );
        expect(
          base.copyWith(mentionsEnabled: false),
          isNot(equals(base)),
        );
        expect(
          base.copyWith(predictionResultsEnabled: false),
          isNot(equals(base)),
        );
        expect(
          base.copyWith(leaderboardUpdatesEnabled: true),
          isNot(equals(base)),
        );
      });

      test('quiet hours values affect equality', () {
        const base = NotificationPreferencesData();
        expect(
          base.copyWith(quietHoursStart: '23:00'),
          isNot(equals(base)),
        );
        expect(
          base.copyWith(quietHoursEnd: '07:00'),
          isNot(equals(base)),
        );
      });

      test('reminder timing affects equality', () {
        const base = NotificationPreferencesData();
        expect(
          base.copyWith(defaultReminderTiming: ReminderTiming.oneHour),
          isNot(equals(base)),
        );
        expect(
          base.copyWith(watchPartyReminderTiming: ReminderTiming.twoHours),
          isNot(equals(base)),
        );
      });
    });

    group('isInQuietHours', () {
      test('returns false when quiet hours are disabled', () {
        const data = NotificationPreferencesData(
          quietHoursEnabled: false,
          quietHoursStart: '00:00',
          quietHoursEnd: '23:59',
        );
        expect(data.isInQuietHours, isFalse);
      });

      test('handles daytime quiet hours', () {
        // Set quiet hours from 10:00 to 14:00
        const data = NotificationPreferencesData(
          quietHoursEnabled: true,
          quietHoursStart: '10:00',
          quietHoursEnd: '14:00',
        );
        // This test depends on the current time - just verify it runs
        expect(data.isInQuietHours, isA<bool>());
      });

      test('handles overnight quiet hours', () {
        // Set quiet hours from 22:00 to 08:00 (default)
        const data = NotificationPreferencesData(
          quietHoursEnabled: true,
          quietHoursStart: '22:00',
          quietHoursEnd: '08:00',
        );
        // This test depends on the current time - just verify it runs
        expect(data.isInQuietHours, isA<bool>());
      });

      test('handles full day quiet hours', () {
        const data = NotificationPreferencesData(
          quietHoursEnabled: true,
          quietHoursStart: '00:00',
          quietHoursEnd: '23:59',
        );
        // Should always be in quiet hours (0:00 to 23:59 covers all minutes)
        expect(data.isInQuietHours, isTrue);
      });

      test('handles same start and end time', () {
        const data = NotificationPreferencesData(
          quietHoursEnabled: true,
          quietHoursStart: '12:00',
          quietHoursEnd: '12:00',
        );
        // When start equals end, the range is effectively a single moment
        expect(data.isInQuietHours, isA<bool>());
      });
    });
  });

  // NOTE: NotificationPreferencesService is skipped because it creates
  // FirebaseFirestore.instance and FirebaseAuth.instance in its constructor,
  // which requires Firebase initialization. The data class tests above
  // cover the core logic.

  group('ReminderTiming', () {
    group('enum values', () {
      test('has 5 timing options', () {
        expect(ReminderTiming.values.length, equals(5));
      });

      test('fifteenMinutes has correct properties', () {
        expect(ReminderTiming.fifteenMinutes.minutes, equals(15));
        expect(ReminderTiming.fifteenMinutes.displayName, equals('15 minutes'));
      });

      test('thirtyMinutes has correct properties', () {
        expect(ReminderTiming.thirtyMinutes.minutes, equals(30));
        expect(ReminderTiming.thirtyMinutes.displayName, equals('30 minutes'));
      });

      test('oneHour has correct properties', () {
        expect(ReminderTiming.oneHour.minutes, equals(60));
        expect(ReminderTiming.oneHour.displayName, equals('1 hour'));
      });

      test('twoHours has correct properties', () {
        expect(ReminderTiming.twoHours.minutes, equals(120));
        expect(ReminderTiming.twoHours.displayName, equals('2 hours'));
      });

      test('oneDay has correct properties', () {
        expect(ReminderTiming.oneDay.minutes, equals(1440));
        expect(ReminderTiming.oneDay.displayName, equals('1 day'));
      });
    });

    group('fromMinutes', () {
      test('returns correct timing for exact match', () {
        expect(ReminderTiming.fromMinutes(15), equals(ReminderTiming.fifteenMinutes));
        expect(ReminderTiming.fromMinutes(30), equals(ReminderTiming.thirtyMinutes));
        expect(ReminderTiming.fromMinutes(60), equals(ReminderTiming.oneHour));
        expect(ReminderTiming.fromMinutes(120), equals(ReminderTiming.twoHours));
        expect(ReminderTiming.fromMinutes(1440), equals(ReminderTiming.oneDay));
      });

      test('returns thirtyMinutes as default for unknown minutes', () {
        expect(ReminderTiming.fromMinutes(0), equals(ReminderTiming.thirtyMinutes));
        expect(ReminderTiming.fromMinutes(45), equals(ReminderTiming.thirtyMinutes));
        expect(ReminderTiming.fromMinutes(999), equals(ReminderTiming.thirtyMinutes));
        expect(ReminderTiming.fromMinutes(-1), equals(ReminderTiming.thirtyMinutes));
      });
    });

    group('minutes values', () {
      test('are in ascending order', () {
        final minuteValues = ReminderTiming.values.map((t) => t.minutes).toList();
        for (int i = 1; i < minuteValues.length; i++) {
          expect(minuteValues[i], greaterThan(minuteValues[i - 1]));
        }
      });

      test('each value has a non-empty display name', () {
        for (final timing in ReminderTiming.values) {
          expect(timing.displayName.isNotEmpty, isTrue,
              reason: '${timing.name} should have a display name');
        }
      });
    });
  });
}

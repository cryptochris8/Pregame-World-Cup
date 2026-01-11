import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/domain/entities/match_reminder.dart';

void main() {
  group('ReminderTiming', () {
    test('has expected values', () {
      expect(ReminderTiming.values, hasLength(5));
      expect(ReminderTiming.values, contains(ReminderTiming.fifteenMinutes));
      expect(ReminderTiming.values, contains(ReminderTiming.thirtyMinutes));
      expect(ReminderTiming.values, contains(ReminderTiming.oneHour));
      expect(ReminderTiming.values, contains(ReminderTiming.twoHours));
      expect(ReminderTiming.values, contains(ReminderTiming.oneDay));
    });

    test('has correct minutes values', () {
      expect(ReminderTiming.fifteenMinutes.minutes, equals(15));
      expect(ReminderTiming.thirtyMinutes.minutes, equals(30));
      expect(ReminderTiming.oneHour.minutes, equals(60));
      expect(ReminderTiming.twoHours.minutes, equals(120));
      expect(ReminderTiming.oneDay.minutes, equals(1440));
    });

    test('has correct display names', () {
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

    test('fromMinutes defaults to thirtyMinutes for unknown values', () {
      expect(ReminderTiming.fromMinutes(45), equals(ReminderTiming.thirtyMinutes));
      expect(ReminderTiming.fromMinutes(0), equals(ReminderTiming.thirtyMinutes));
      expect(ReminderTiming.fromMinutes(9999), equals(ReminderTiming.thirtyMinutes));
    });
  });

  group('MatchReminder', () {
    final testMatchDateTime = DateTime.utc(2026, 6, 15, 18, 0, 0);
    final testCreatedAt = DateTime.utc(2026, 6, 1, 10, 0, 0);

    MatchReminder createTestReminder({
      String reminderId = 'rem_1',
      String userId = 'user_123',
      String matchId = 'match_1',
      String matchName = 'USA vs Mexico',
      DateTime? matchDateTimeUtc,
      DateTime? reminderDateTimeUtc,
      ReminderTiming timing = ReminderTiming.thirtyMinutes,
      bool isEnabled = true,
      bool isSent = false,
      DateTime? createdAt,
      String? homeTeamCode,
      String? awayTeamCode,
      String? homeTeamName,
      String? awayTeamName,
      String? venueName,
    }) {
      final matchTime = matchDateTimeUtc ?? testMatchDateTime;
      final reminderTime = reminderDateTimeUtc ??
          matchTime.subtract(Duration(minutes: timing.minutes));

      return MatchReminder(
        reminderId: reminderId,
        userId: userId,
        matchId: matchId,
        matchName: matchName,
        matchDateTimeUtc: matchTime,
        reminderDateTimeUtc: reminderTime,
        timing: timing,
        isEnabled: isEnabled,
        isSent: isSent,
        createdAt: createdAt ?? testCreatedAt,
        homeTeamCode: homeTeamCode,
        awayTeamCode: awayTeamCode,
        homeTeamName: homeTeamName,
        awayTeamName: awayTeamName,
        venueName: venueName,
      );
    }

    group('Constructor', () {
      test('creates reminder with required fields', () {
        final reminder = createTestReminder();

        expect(reminder.reminderId, equals('rem_1'));
        expect(reminder.userId, equals('user_123'));
        expect(reminder.matchId, equals('match_1'));
        expect(reminder.matchName, equals('USA vs Mexico'));
        expect(reminder.timing, equals(ReminderTiming.thirtyMinutes));
        expect(reminder.isEnabled, isTrue);
        expect(reminder.isSent, isFalse);
      });

      test('creates reminder with all fields', () {
        final reminder = createTestReminder(
          homeTeamCode: 'USA',
          awayTeamCode: 'MEX',
          homeTeamName: 'United States',
          awayTeamName: 'Mexico',
          venueName: 'MetLife Stadium',
        );

        expect(reminder.homeTeamCode, equals('USA'));
        expect(reminder.awayTeamCode, equals('MEX'));
        expect(reminder.homeTeamName, equals('United States'));
        expect(reminder.awayTeamName, equals('Mexico'));
        expect(reminder.venueName, equals('MetLife Stadium'));
      });

      test('creates reminder with different timings', () {
        final fifteenMin = createTestReminder(timing: ReminderTiming.fifteenMinutes);
        final oneHour = createTestReminder(timing: ReminderTiming.oneHour);
        final oneDay = createTestReminder(timing: ReminderTiming.oneDay);

        expect(fifteenMin.timing, equals(ReminderTiming.fifteenMinutes));
        expect(oneHour.timing, equals(ReminderTiming.oneHour));
        expect(oneDay.timing, equals(ReminderTiming.oneDay));
      });
    });

    group('Factory create', () {
      test('creates reminder with generated id', () {
        final reminder = MatchReminder.create(
          userId: 'user_test',
          matchId: 'match_test',
          matchName: 'Argentina vs Brazil',
          matchDateTimeUtc: testMatchDateTime,
        );

        expect(reminder.reminderId, startsWith('reminder_user_test_match_test_'));
        expect(reminder.userId, equals('user_test'));
        expect(reminder.matchId, equals('match_test'));
        expect(reminder.matchName, equals('Argentina vs Brazil'));
        expect(reminder.timing, equals(ReminderTiming.thirtyMinutes));
        expect(reminder.isEnabled, isTrue);
        expect(reminder.isSent, isFalse);
      });

      test('calculates correct reminder time', () {
        final reminder = MatchReminder.create(
          userId: 'user',
          matchId: 'match',
          matchName: 'Test Match',
          matchDateTimeUtc: testMatchDateTime,
          timing: ReminderTiming.oneHour,
        );

        final expectedReminderTime = testMatchDateTime.subtract(
          const Duration(hours: 1),
        );
        expect(reminder.reminderDateTimeUtc, equals(expectedReminderTime));
      });

      test('accepts optional team info', () {
        final reminder = MatchReminder.create(
          userId: 'user',
          matchId: 'match',
          matchName: 'Test',
          matchDateTimeUtc: testMatchDateTime,
          homeTeamCode: 'GER',
          awayTeamCode: 'FRA',
          homeTeamName: 'Germany',
          awayTeamName: 'France',
          venueName: 'Stadium',
        );

        expect(reminder.homeTeamCode, equals('GER'));
        expect(reminder.awayTeamCode, equals('FRA'));
        expect(reminder.homeTeamName, equals('Germany'));
        expect(reminder.awayTeamName, equals('France'));
        expect(reminder.venueName, equals('Stadium'));
      });
    });

    group('Computed getters', () {
      test('isDue returns false when already sent', () {
        final reminder = createTestReminder(
          isSent: true,
          matchDateTimeUtc: DateTime.now().toUtc().add(const Duration(hours: 1)),
          reminderDateTimeUtc: DateTime.now().toUtc().subtract(const Duration(minutes: 5)),
        );
        expect(reminder.isDue, isFalse);
      });

      test('isDue returns false when disabled', () {
        final reminder = createTestReminder(
          isEnabled: false,
          matchDateTimeUtc: DateTime.now().toUtc().add(const Duration(hours: 1)),
          reminderDateTimeUtc: DateTime.now().toUtc().subtract(const Duration(minutes: 5)),
        );
        expect(reminder.isDue, isFalse);
      });

      test('matchStarted returns true when match time passed', () {
        final pastReminder = createTestReminder(
          matchDateTimeUtc: DateTime.now().toUtc().subtract(const Duration(hours: 1)),
        );
        final futureReminder = createTestReminder(
          matchDateTimeUtc: DateTime.now().toUtc().add(const Duration(hours: 1)),
        );

        expect(pastReminder.matchStarted, isTrue);
        expect(futureReminder.matchStarted, isFalse);
      });

      test('timeUntilMatch calculates correctly', () {
        final futureMatch = DateTime.now().toUtc().add(const Duration(hours: 2));
        final reminder = createTestReminder(matchDateTimeUtc: futureMatch);

        final timeUntil = reminder.timeUntilMatch;
        // Should be approximately 2 hours (allow for test execution time)
        expect(timeUntil.inMinutes, greaterThan(115));
        expect(timeUntil.inMinutes, lessThanOrEqualTo(120));
      });

      test('timeUntilReminder calculates correctly', () {
        final futureMatch = DateTime.now().toUtc().add(const Duration(hours: 2));
        final reminder = createTestReminder(
          matchDateTimeUtc: futureMatch,
          timing: ReminderTiming.thirtyMinutes,
        );

        // Reminder should be 30 minutes before match, so ~1.5 hours from now
        final timeUntil = reminder.timeUntilReminder;
        expect(timeUntil.inMinutes, greaterThan(85));
        expect(timeUntil.inMinutes, lessThanOrEqualTo(90));
      });
    });

    group('copyWith', () {
      test('copies with updated fields', () {
        final original = createTestReminder();
        final updated = original.copyWith(
          isEnabled: false,
          isSent: true,
        );

        expect(updated.isEnabled, isFalse);
        expect(updated.isSent, isTrue);
        expect(updated.reminderId, equals(original.reminderId));
        expect(updated.matchName, equals(original.matchName));
      });

      test('recalculates reminder time when timing changes', () {
        final original = createTestReminder(timing: ReminderTiming.thirtyMinutes);
        final updated = original.copyWith(timing: ReminderTiming.oneHour);

        expect(updated.timing, equals(ReminderTiming.oneHour));
        final expectedReminderTime = original.matchDateTimeUtc.subtract(
          const Duration(hours: 1),
        );
        expect(updated.reminderDateTimeUtc, equals(expectedReminderTime));
      });

      test('recalculates reminder time when match time changes', () {
        final original = createTestReminder();
        final newMatchTime = testMatchDateTime.add(const Duration(days: 1));
        final updated = original.copyWith(matchDateTimeUtc: newMatchTime);

        expect(updated.matchDateTimeUtc, equals(newMatchTime));
        final expectedReminderTime = newMatchTime.subtract(
          Duration(minutes: original.timing.minutes),
        );
        expect(updated.reminderDateTimeUtc, equals(expectedReminderTime));
      });

      test('preserves unchanged fields', () {
        final original = createTestReminder(
          homeTeamCode: 'USA',
          awayTeamCode: 'MEX',
          venueName: 'MetLife Stadium',
        );
        final updated = original.copyWith(isEnabled: false);

        expect(updated.homeTeamCode, equals('USA'));
        expect(updated.awayTeamCode, equals('MEX'));
        expect(updated.venueName, equals('MetLife Stadium'));
      });
    });

    group('Firestore serialization', () {
      test('toFirestore serializes all fields', () {
        final reminder = createTestReminder(
          homeTeamCode: 'USA',
          awayTeamCode: 'MEX',
          homeTeamName: 'United States',
          awayTeamName: 'Mexico',
          venueName: 'MetLife Stadium',
        );
        final data = reminder.toFirestore();

        expect(data['userId'], equals('user_123'));
        expect(data['matchId'], equals('match_1'));
        expect(data['matchName'], equals('USA vs Mexico'));
        expect(data['timingMinutes'], equals(30));
        expect(data['isEnabled'], isTrue);
        expect(data['isSent'], isFalse);
        expect(data['homeTeamCode'], equals('USA'));
        expect(data['awayTeamCode'], equals('MEX'));
        expect(data['homeTeamName'], equals('United States'));
        expect(data['awayTeamName'], equals('Mexico'));
        expect(data['venueName'], equals('MetLife Stadium'));
        expect(data['matchDateTimeUtc'], isNotNull);
        expect(data['reminderDateTimeUtc'], isNotNull);
        expect(data['createdAt'], isNotNull);
      });

      test('fromFirestore deserializes correctly', () {
        final data = {
          'userId': 'user_fs',
          'matchId': 'match_fs',
          'matchName': 'Germany vs France',
          'matchDateTimeUtc': '2026-07-04T20:00:00.000Z',
          'reminderDateTimeUtc': '2026-07-04T19:00:00.000Z',
          'timingMinutes': 60,
          'isEnabled': true,
          'isSent': false,
          'createdAt': '2026-06-01T10:00:00.000Z',
          'homeTeamCode': 'GER',
          'awayTeamCode': 'FRA',
        };

        final reminder = MatchReminder.fromFirestore(data, 'rem_fs');

        expect(reminder.reminderId, equals('rem_fs'));
        expect(reminder.userId, equals('user_fs'));
        expect(reminder.matchId, equals('match_fs'));
        expect(reminder.matchName, equals('Germany vs France'));
        expect(reminder.timing, equals(ReminderTiming.oneHour));
        expect(reminder.isEnabled, isTrue);
        expect(reminder.isSent, isFalse);
        expect(reminder.homeTeamCode, equals('GER'));
        expect(reminder.awayTeamCode, equals('FRA'));
      });

      test('fromFirestore handles missing optional fields', () {
        final data = {
          'userId': 'user',
          'matchId': 'match',
          'matchName': 'Test',
          'timingMinutes': 30,
        };

        final reminder = MatchReminder.fromFirestore(data, 'rem_min');

        expect(reminder.reminderId, equals('rem_min'));
        expect(reminder.homeTeamCode, isNull);
        expect(reminder.awayTeamCode, isNull);
        expect(reminder.venueName, isNull);
        expect(reminder.isEnabled, isTrue); // default
        expect(reminder.isSent, isFalse); // default
      });
    });

    group('Equatable', () {
      test('two reminders with same props are equal', () {
        final reminder1 = createTestReminder();
        final reminder2 = createTestReminder();

        expect(reminder1, equals(reminder2));
      });

      test('two reminders with different id are not equal', () {
        final reminder1 = createTestReminder(reminderId: 'rem_1');
        final reminder2 = createTestReminder(reminderId: 'rem_2');

        expect(reminder1, isNot(equals(reminder2)));
      });

      test('two reminders with different timing are not equal', () {
        final reminder1 = createTestReminder(timing: ReminderTiming.thirtyMinutes);
        final reminder2 = createTestReminder(timing: ReminderTiming.oneHour);

        expect(reminder1, isNot(equals(reminder2)));
      });

      test('props contains expected fields', () {
        final reminder = createTestReminder();
        expect(reminder.props, hasLength(7));
        expect(reminder.props, contains(reminder.reminderId));
        expect(reminder.props, contains(reminder.userId));
        expect(reminder.props, contains(reminder.matchId));
        expect(reminder.props, contains(reminder.timing));
        expect(reminder.props, contains(reminder.isEnabled));
        expect(reminder.props, contains(reminder.isSent));
      });
    });

    group('toString', () {
      test('returns formatted string', () {
        final reminder = createTestReminder(
          matchName: 'Argentina vs Brazil',
          timing: ReminderTiming.oneHour,
        );
        final str = reminder.toString();

        expect(str, contains('Argentina vs Brazil'));
        expect(str, contains('1 hour'));
        expect(str, contains('before'));
      });
    });
  });
}

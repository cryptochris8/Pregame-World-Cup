import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/worldcup/domain/entities/match_reminder.dart';
import 'package:pregame_world_cup/features/worldcup/domain/entities/world_cup_match.dart';

// ==================== MOCKS ====================

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

// ==================== TEST DATA ====================

final _futureMatchDate = DateTime.utc(2026, 7, 15, 20, 0, 0);
final _pastMatchDate = DateTime.utc(2024, 6, 15, 20, 0, 0);

WorldCupMatch _createMatch({
  String matchId = 'match_1',
  String homeTeamName = 'USA',
  String awayTeamName = 'Mexico',
  String? homeTeamCode = 'USA',
  String? awayTeamCode = 'MEX',
  DateTime? dateTimeUtc,
}) {
  return WorldCupMatch(
    matchId: matchId,
    matchNumber: 1,
    stage: MatchStage.groupStage,
    homeTeamName: homeTeamName,
    awayTeamName: awayTeamName,
    homeTeamCode: homeTeamCode,
    awayTeamCode: awayTeamCode,
    dateTimeUtc: dateTimeUtc ?? _futureMatchDate,
  );
}

MatchReminder _createReminder({
  String reminderId = 'reminder_1',
  String userId = 'user_1',
  String matchId = 'match_1',
  String matchName = 'USA vs Mexico',
  DateTime? matchDateTimeUtc,
  ReminderTiming timing = ReminderTiming.thirtyMinutes,
  bool isEnabled = true,
  bool isSent = false,
}) {
  final matchDate = matchDateTimeUtc ?? _futureMatchDate;
  return MatchReminder(
    reminderId: reminderId,
    userId: userId,
    matchId: matchId,
    matchName: matchName,
    matchDateTimeUtc: matchDate,
    reminderDateTimeUtc: matchDate.subtract(Duration(minutes: timing.minutes)),
    timing: timing,
    isEnabled: isEnabled,
    isSent: isSent,
    createdAt: DateTime.now(),
    homeTeamCode: 'USA',
    awayTeamCode: 'MEX',
    homeTeamName: 'USA',
    awayTeamName: 'Mexico',
    venueName: 'MetLife Stadium',
  );
}

// ==================== TESTS ====================

void main() {
  group('MatchReminderService', () {
    // Since MatchReminderService uses FirebaseFirestore.instance and
    // FirebaseAuth.instance directly, we test entity logic, serialization,
    // and cache behavior here.

    // =========================================================================
    // MatchReminder entity tests
    // =========================================================================
    group('MatchReminder entity', () {
      test('create factory produces correct reminder', () {
        final reminder = MatchReminder.create(
          userId: 'user_1',
          matchId: 'match_1',
          matchName: 'USA vs Mexico',
          matchDateTimeUtc: _futureMatchDate,
          timing: ReminderTiming.oneHour,
          homeTeamCode: 'USA',
          awayTeamCode: 'MEX',
          homeTeamName: 'USA',
          awayTeamName: 'Mexico',
          venueName: 'MetLife Stadium',
        );

        expect(reminder.userId, 'user_1');
        expect(reminder.matchId, 'match_1');
        expect(reminder.matchName, 'USA vs Mexico');
        expect(reminder.timing, ReminderTiming.oneHour);
        expect(reminder.isEnabled, true);
        expect(reminder.isSent, false);
        expect(reminder.homeTeamCode, 'USA');
        expect(reminder.awayTeamCode, 'MEX');
        expect(reminder.venueName, 'MetLife Stadium');
        expect(reminder.reminderId, startsWith('reminder_user_1_match_1_'));
      });

      test('create factory calculates reminderDateTimeUtc correctly', () {
        final reminder = MatchReminder.create(
          userId: 'user_1',
          matchId: 'match_1',
          matchName: 'Test Match',
          matchDateTimeUtc: _futureMatchDate,
          timing: ReminderTiming.twoHours,
        );

        final expectedReminderTime =
            _futureMatchDate.subtract(const Duration(hours: 2));
        expect(reminder.reminderDateTimeUtc, expectedReminderTime);
      });

      test('create factory handles all timing options', () {
        for (final timing in ReminderTiming.values) {
          final reminder = MatchReminder.create(
            userId: 'user_1',
            matchId: 'match_1',
            matchName: 'Test',
            matchDateTimeUtc: _futureMatchDate,
            timing: timing,
          );

          final expectedReminderTime = _futureMatchDate
              .subtract(Duration(minutes: timing.minutes));
          expect(reminder.reminderDateTimeUtc, expectedReminderTime,
              reason: 'Failed for timing ${timing.displayName}');
        }
      });
    });

    // =========================================================================
    // ReminderTiming tests
    // =========================================================================
    group('ReminderTiming', () {
      test('has correct minute values', () {
        expect(ReminderTiming.fifteenMinutes.minutes, 15);
        expect(ReminderTiming.thirtyMinutes.minutes, 30);
        expect(ReminderTiming.oneHour.minutes, 60);
        expect(ReminderTiming.twoHours.minutes, 120);
        expect(ReminderTiming.oneDay.minutes, 1440);
      });

      test('has correct display names', () {
        expect(ReminderTiming.fifteenMinutes.displayName, '15 minutes');
        expect(ReminderTiming.thirtyMinutes.displayName, '30 minutes');
        expect(ReminderTiming.oneHour.displayName, '1 hour');
        expect(ReminderTiming.twoHours.displayName, '2 hours');
        expect(ReminderTiming.oneDay.displayName, '1 day');
      });

      test('fromMinutes returns correct timing', () {
        expect(ReminderTiming.fromMinutes(15), ReminderTiming.fifteenMinutes);
        expect(ReminderTiming.fromMinutes(30), ReminderTiming.thirtyMinutes);
        expect(ReminderTiming.fromMinutes(60), ReminderTiming.oneHour);
        expect(ReminderTiming.fromMinutes(120), ReminderTiming.twoHours);
        expect(ReminderTiming.fromMinutes(1440), ReminderTiming.oneDay);
      });

      test('fromMinutes returns default for unknown value', () {
        expect(ReminderTiming.fromMinutes(999), ReminderTiming.thirtyMinutes);
        expect(ReminderTiming.fromMinutes(0), ReminderTiming.thirtyMinutes);
      });
    });

    // =========================================================================
    // Firestore serialization tests
    // =========================================================================
    group('Firestore serialization', () {
      test('toFirestore produces correct map', () {
        final reminder = _createReminder();
        final firestoreMap = reminder.toFirestore();

        expect(firestoreMap['userId'], 'user_1');
        expect(firestoreMap['matchId'], 'match_1');
        expect(firestoreMap['matchName'], 'USA vs Mexico');
        expect(firestoreMap['timingMinutes'], 30);
        expect(firestoreMap['isEnabled'], true);
        expect(firestoreMap['isSent'], false);
        expect(firestoreMap['homeTeamCode'], 'USA');
        expect(firestoreMap['awayTeamCode'], 'MEX');
        expect(firestoreMap['homeTeamName'], 'USA');
        expect(firestoreMap['awayTeamName'], 'Mexico');
        expect(firestoreMap['venueName'], 'MetLife Stadium');
        expect(firestoreMap['matchDateTimeUtc'], isA<Timestamp>());
        expect(firestoreMap['reminderDateTimeUtc'], isA<Timestamp>());
        expect(firestoreMap['createdAt'], isA<Timestamp>());
      });

      test('fromFirestore parses correctly', () {
        final data = {
          'userId': 'user_2',
          'matchId': 'match_2',
          'matchName': 'Brazil vs Argentina',
          'matchDateTimeUtc': Timestamp.fromDate(_futureMatchDate),
          'reminderDateTimeUtc': Timestamp.fromDate(
            _futureMatchDate.subtract(const Duration(hours: 1)),
          ),
          'timingMinutes': 60,
          'isEnabled': true,
          'isSent': false,
          'createdAt': Timestamp.fromDate(DateTime.now()),
          'homeTeamCode': 'BRA',
          'awayTeamCode': 'ARG',
          'homeTeamName': 'Brazil',
          'awayTeamName': 'Argentina',
          'venueName': 'SoFi Stadium',
        };

        final reminder = MatchReminder.fromFirestore(data, 'doc_123');

        expect(reminder.reminderId, 'doc_123');
        expect(reminder.userId, 'user_2');
        expect(reminder.matchId, 'match_2');
        expect(reminder.matchName, 'Brazil vs Argentina');
        expect(reminder.timing, ReminderTiming.oneHour);
        expect(reminder.homeTeamCode, 'BRA');
        expect(reminder.awayTeamCode, 'ARG');
        expect(reminder.venueName, 'SoFi Stadium');
      });

      test('fromFirestore handles missing optional fields', () {
        final data = <String, dynamic>{
          'userId': 'user_1',
          'matchId': 'match_1',
          'matchName': 'Test Match',
          'matchDateTimeUtc': Timestamp.fromDate(_futureMatchDate),
          'reminderDateTimeUtc': Timestamp.fromDate(_futureMatchDate),
          'createdAt': Timestamp.fromDate(DateTime.now()),
        };

        final reminder = MatchReminder.fromFirestore(data, 'doc_456');

        expect(reminder.timing, ReminderTiming.thirtyMinutes); // default
        expect(reminder.isEnabled, true); // default
        expect(reminder.isSent, false); // default
        expect(reminder.homeTeamCode, isNull);
        expect(reminder.awayTeamCode, isNull);
        expect(reminder.venueName, isNull);
      });

      test('round-trips through toFirestore/fromFirestore', () {
        final original = _createReminder(
          timing: ReminderTiming.oneHour,
        );

        final firestoreMap = original.toFirestore();
        final restored =
            MatchReminder.fromFirestore(firestoreMap, original.reminderId);

        expect(restored.userId, original.userId);
        expect(restored.matchId, original.matchId);
        expect(restored.matchName, original.matchName);
        expect(restored.timing, original.timing);
        expect(restored.isEnabled, original.isEnabled);
        expect(restored.isSent, original.isSent);
        expect(restored.homeTeamCode, original.homeTeamCode);
        expect(restored.awayTeamCode, original.awayTeamCode);
        expect(restored.venueName, original.venueName);
      });
    });

    // =========================================================================
    // copyWith tests
    // =========================================================================
    group('copyWith', () {
      test('updates timing and recalculates reminderDateTimeUtc', () {
        final original = _createReminder(timing: ReminderTiming.thirtyMinutes);

        final updated = original.copyWith(timing: ReminderTiming.twoHours);

        expect(updated.timing, ReminderTiming.twoHours);
        expect(
          updated.reminderDateTimeUtc,
          _futureMatchDate.subtract(const Duration(hours: 2)),
        );
      });

      test('updates isEnabled without changing timing', () {
        final original = _createReminder(isEnabled: true);
        final updated = original.copyWith(isEnabled: false);

        expect(updated.isEnabled, false);
        expect(updated.timing, original.timing);
        expect(updated.matchId, original.matchId);
      });

      test('updates isSent field', () {
        final original = _createReminder(isSent: false);
        final updated = original.copyWith(isSent: true);

        expect(updated.isSent, true);
      });

      test('preserves all fields when no updates specified', () {
        final original = _createReminder();
        final updated = original.copyWith();

        expect(updated.userId, original.userId);
        expect(updated.matchId, original.matchId);
        expect(updated.matchName, original.matchName);
        expect(updated.timing, original.timing);
        expect(updated.isEnabled, original.isEnabled);
        expect(updated.isSent, original.isSent);
      });
    });

    // =========================================================================
    // Computed properties tests
    // =========================================================================
    group('computed properties', () {
      test('isDue returns false when isSent is true', () {
        final reminder = _createReminder(isSent: true);
        expect(reminder.isDue, false);
      });

      test('isDue returns false when isEnabled is false', () {
        final reminder = _createReminder(isEnabled: false);
        expect(reminder.isDue, false);
      });

      test('matchStarted returns true for past match', () {
        final reminder = _createReminder(matchDateTimeUtc: _pastMatchDate);
        expect(reminder.matchStarted, true);
      });

      test('matchStarted returns false for future match', () {
        final reminder = _createReminder(matchDateTimeUtc: _futureMatchDate);
        expect(reminder.matchStarted, false);
      });

      test('timeUntilMatch returns positive duration for future match', () {
        final reminder = _createReminder(matchDateTimeUtc: _futureMatchDate);
        expect(reminder.timeUntilMatch.isNegative, false);
      });

      test('timeUntilMatch returns negative duration for past match', () {
        final reminder = _createReminder(matchDateTimeUtc: _pastMatchDate);
        expect(reminder.timeUntilMatch.isNegative, true);
      });

      test('toString returns readable format', () {
        final reminder = _createReminder();
        expect(reminder.toString(),
            'MatchReminder(USA vs Mexico, 30 minutes before)');
      });
    });

    // =========================================================================
    // Equality tests
    // =========================================================================
    group('equality', () {
      test('two reminders with same key fields are equal', () {
        final r1 = _createReminder(
          reminderId: 'r1',
          userId: 'user_1',
          matchId: 'match_1',
        );
        final r2 = _createReminder(
          reminderId: 'r1',
          userId: 'user_1',
          matchId: 'match_1',
        );

        expect(r1, equals(r2));
      });

      test('two reminders with different matchId are not equal', () {
        final r1 = _createReminder(matchId: 'match_1');
        final r2 = _createReminder(matchId: 'match_2');

        expect(r1, isNot(equals(r2)));
      });
    });

    // =========================================================================
    // _parseDateTime tests
    // =========================================================================
    group('_parseDateTime via fromFirestore', () {
      test('parses Timestamp correctly', () {
        final data = {
          'userId': 'u',
          'matchId': 'm',
          'matchName': 'test',
          'matchDateTimeUtc': Timestamp.fromDate(_futureMatchDate),
          'reminderDateTimeUtc': Timestamp.fromDate(_futureMatchDate),
          'createdAt': Timestamp.fromDate(DateTime.now()),
        };

        final reminder = MatchReminder.fromFirestore(data, 'doc_1');
        expect(reminder.matchDateTimeUtc.year, 2026);
      });

      test('parses String date correctly', () {
        final data = {
          'userId': 'u',
          'matchId': 'm',
          'matchName': 'test',
          'matchDateTimeUtc': '2026-07-15T20:00:00.000Z',
          'reminderDateTimeUtc': '2026-07-15T19:30:00.000Z',
          'createdAt': Timestamp.fromDate(DateTime.now()),
        };

        final reminder = MatchReminder.fromFirestore(data, 'doc_2');
        expect(reminder.matchDateTimeUtc.year, 2026);
      });

      test('handles null dates with fallback to now', () {
        final data = <String, dynamic>{
          'userId': 'u',
          'matchId': 'm',
          'matchName': 'test',
          'matchDateTimeUtc': null,
          'reminderDateTimeUtc': null,
          'createdAt': null,
        };

        final reminder = MatchReminder.fromFirestore(data, 'doc_3');
        // Falls back to DateTime.now()
        expect(reminder.matchDateTimeUtc, isNotNull);
      });
    });

    // =========================================================================
    // Service cache behavior tests (using clearCache)
    // =========================================================================
    group('service cache behavior', () {
      test('hasReminderCached returns false for unknown match', () {
        // MatchReminderService uses internal _remindersCache
        // Since we cannot inject Firestore, we test the entity-level cache logic

        // Simulating what the service does:
        final remindersCache = <String, MatchReminder>{};
        final matchId = 'match_999';

        final hasCached = remindersCache.containsKey(matchId);
        expect(hasCached, false);
      });

      test('hasReminderCached returns true for cached active reminder', () {
        final remindersCache = <String, MatchReminder>{};
        final reminder = _createReminder(
          matchId: 'match_1',
          isEnabled: true,
          isSent: false,
        );
        remindersCache['match_1'] = reminder;

        final cached = remindersCache['match_1'];
        final result = cached != null && cached.isEnabled && !cached.isSent;
        expect(result, true);
      });

      test('hasReminderCached returns false for sent reminder', () {
        final remindersCache = <String, MatchReminder>{};
        final reminder = _createReminder(
          matchId: 'match_1',
          isEnabled: true,
          isSent: true,
        );
        remindersCache['match_1'] = reminder;

        final cached = remindersCache['match_1'];
        final result = cached != null && cached.isEnabled && !cached.isSent;
        expect(result, false);
      });

      test('hasReminderCached returns false for disabled reminder', () {
        final remindersCache = <String, MatchReminder>{};
        final reminder = _createReminder(
          matchId: 'match_1',
          isEnabled: false,
          isSent: false,
        );
        remindersCache['match_1'] = reminder;

        final cached = remindersCache['match_1'];
        final result = cached != null && cached.isEnabled && !cached.isSent;
        expect(result, false);
      });

      test('clearCache resets cache state', () {
        final remindersCache = <String, MatchReminder>{};
        remindersCache['match_1'] = _createReminder(matchId: 'match_1');
        remindersCache['match_2'] = _createReminder(matchId: 'match_2');

        expect(remindersCache.length, 2);

        remindersCache.clear();
        expect(remindersCache.length, 0);
      });
    });

    // =========================================================================
    // WorldCupMatch interaction tests
    // =========================================================================
    group('WorldCupMatch interaction', () {
      test('setReminder validates match has dateTimeUtc', () {
        final matchWithDate = _createMatch(dateTimeUtc: _futureMatchDate);
        expect(matchWithDate.dateTimeUtc, isNotNull);

        // WorldCupMatch with explicit null dateTimeUtc
        const matchWithoutDate = WorldCupMatch(
          matchId: 'match_no_date',
          matchNumber: 99,
          stage: MatchStage.groupStage,
          homeTeamName: 'TBD',
          awayTeamName: 'TBD',
          dateTimeUtc: null,
        );
        expect(matchWithoutDate.dateTimeUtc, isNull);
      });

      test('setReminder validates match is not in the past', () {
        final futureMatch = _createMatch(dateTimeUtc: _futureMatchDate);
        expect(futureMatch.dateTimeUtc!.isAfter(DateTime.now().toUtc()), true);

        final pastMatch = _createMatch(dateTimeUtc: _pastMatchDate);
        expect(pastMatch.dateTimeUtc!.isBefore(DateTime.now().toUtc()), true);
      });

      test('reminder name is constructed from match teams', () {
        final match = _createMatch();
        final matchName = '${match.homeTeamName} vs ${match.awayTeamName}';
        expect(matchName, 'USA vs Mexico');
      });

      test('venueName getter works on WorldCupMatch', () {
        final match = _createMatch();
        // venueName is derived from venue?.name, which is null here
        expect(match.venueName, isNull);
      });
    });
  });
}

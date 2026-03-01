import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:pregame_world_cup/features/worldcup/utils/timezone_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TimezoneUtils', () {
    setUpAll(() async {
      // Initialize timezone database once for all tests.
      // TimezoneUtils guards against double-init internally.
      await TimezoneUtils.initialize();
    });

    group('initialize', () {
      test('can be called multiple times without error', () async {
        // Already initialized in setUpAll; calling again should be safe.
        await TimezoneUtils.initialize();
        // No error means success
      });
    });

    group('getLocation', () {
      test('returns correct location for valid IANA timezone', () {
        final location = TimezoneUtils.getLocation('America/New_York');
        expect(location, isNotNull);
        expect(location.name, equals('America/New_York'));
      });

      test('returns correct location for UTC', () {
        final location = TimezoneUtils.getLocation('UTC');
        expect(location, isNotNull);
        expect(location.name, equals('UTC'));
      });

      test('returns correct location for various World Cup timezones', () {
        final timezones = [
          'America/Chicago',
          'America/Denver',
          'America/Los_Angeles',
          'America/Mexico_City',
          'America/Toronto',
        ];
        for (final tz in timezones) {
          final location = TimezoneUtils.getLocation(tz);
          expect(location.name, equals(tz),
              reason: 'Failed for timezone: $tz');
        }
      });

      test('falls back to UTC for invalid timezone name', () {
        final location = TimezoneUtils.getLocation('Invalid/Timezone');
        expect(location.name, equals('UTC'));
      });

      test('falls back to UTC for empty string', () {
        final location = TimezoneUtils.getLocation('');
        expect(location.name, equals('UTC'));
      });
    });

    group('convertToTimezone', () {
      test('converts UTC time to Eastern timezone', () {
        // June 15 2026 at 18:00 UTC
        final utcTime = DateTime.utc(2026, 6, 15, 18, 0, 0);
        final easternTime =
            TimezoneUtils.convertToTimezone(utcTime, 'America/New_York');

        // During summer (EDT), Eastern is UTC-4
        expect(easternTime.hour, equals(14));
        expect(easternTime.day, equals(15));
      });

      test('converts UTC time to Central timezone', () {
        final utcTime = DateTime.utc(2026, 6, 15, 18, 0, 0);
        final centralTime =
            TimezoneUtils.convertToTimezone(utcTime, 'America/Chicago');

        // During summer (CDT), Central is UTC-5
        expect(centralTime.hour, equals(13));
      });

      test('converts UTC time to Pacific timezone', () {
        final utcTime = DateTime.utc(2026, 6, 15, 18, 0, 0);
        final pacificTime =
            TimezoneUtils.convertToTimezone(utcTime, 'America/Los_Angeles');

        // During summer (PDT), Pacific is UTC-7
        expect(pacificTime.hour, equals(11));
      });

      test('converts UTC time to Mexico City timezone', () {
        final utcTime = DateTime.utc(2026, 6, 15, 18, 0, 0);
        final mxTime =
            TimezoneUtils.convertToTimezone(utcTime, 'America/Mexico_City');

        // Mexico City is UTC-6 (CDT equivalent)
        expect(mxTime.hour, equals(12));
      });

      test('handles date boundary crossings', () {
        // UTC midnight should go to previous day in US timezones
        final utcMidnight = DateTime.utc(2026, 6, 16, 0, 0, 0);
        final easternTime =
            TimezoneUtils.convertToTimezone(utcMidnight, 'America/New_York');

        // EDT: UTC-4 => June 15 at 20:00
        expect(easternTime.day, equals(15));
        expect(easternTime.hour, equals(20));
      });

      test('preserves minutes and seconds', () {
        final utcTime = DateTime.utc(2026, 6, 15, 18, 30, 45);
        final converted =
            TimezoneUtils.convertToTimezone(utcTime, 'America/New_York');

        expect(converted.minute, equals(30));
        expect(converted.second, equals(45));
      });

      test('handles non-UTC input by converting to UTC first', () {
        // The method calls .toUtc() internally, so local times should work
        final localTime = DateTime(2026, 6, 15, 12, 0, 0);
        // Should not throw
        final result =
            TimezoneUtils.convertToTimezone(localTime, 'America/New_York');
        expect(result, isNotNull);
      });

      test('falls back to UTC for invalid timezone', () {
        final utcTime = DateTime.utc(2026, 6, 15, 18, 0, 0);
        final result =
            TimezoneUtils.convertToTimezone(utcTime, 'Invalid/Zone');
        // Falls back to UTC, so time should be the same
        expect(result.hour, equals(18));
      });
    });

    group('convertToLocal', () {
      test('converts UTC datetime to local', () {
        final utcTime = DateTime.utc(2026, 6, 15, 18, 0, 0);
        final localTime = TimezoneUtils.convertToLocal(utcTime);

        // The local time should equal utcTime.toLocal()
        expect(localTime, equals(utcTime.toLocal()));
      });

      test('preserves date components', () {
        final utcTime = DateTime.utc(2026, 7, 4, 12, 30, 15);
        final localTime = TimezoneUtils.convertToLocal(utcTime);

        expect(localTime.minute, equals(30));
        expect(localTime.second, equals(15));
      });
    });

    group('getTimezoneOffset', () {
      test('returns offset for valid timezone', () {
        final offset = TimezoneUtils.getTimezoneOffset('UTC');
        expect(offset, equals(0));
      });

      test('returns non-zero offset for US timezones', () {
        final nyOffset =
            TimezoneUtils.getTimezoneOffset('America/New_York');
        // Eastern timezone is -5 (EST) or -4 (EDT) depending on DST
        expect(nyOffset, anyOf(equals(-5), equals(-4)));
      });

      test('returns offset for Pacific timezone', () {
        final laOffset =
            TimezoneUtils.getTimezoneOffset('America/Los_Angeles');
        // Pacific is -8 (PST) or -7 (PDT)
        expect(laOffset, anyOf(equals(-8), equals(-7)));
      });

      test('returns offset for Central timezone', () {
        final chiOffset =
            TimezoneUtils.getTimezoneOffset('America/Chicago');
        // Central is -6 (CST) or -5 (CDT)
        expect(chiOffset, anyOf(equals(-6), equals(-5)));
      });

      test('falls back to UTC offset for invalid timezone', () {
        final offset = TimezoneUtils.getTimezoneOffset('Invalid/Zone');
        expect(offset, equals(0));
      });
    });

    group('getLocalTimezoneName', () {
      test('returns a non-empty string', () {
        final name = TimezoneUtils.getLocalTimezoneName();
        expect(name, isNotEmpty);
      });

      test('returns a valid IANA timezone name or UTC', () {
        final name = TimezoneUtils.getLocalTimezoneName();
        // Should be one of the mapped timezones or UTC
        final validNames = [
          'America/New_York',
          'America/Chicago',
          'America/Denver',
          'America/Los_Angeles',
          'UTC',
        ];
        expect(validNames, contains(name));
      });
    });

    group('formatMatchTime', () {
      test('formats time in local mode', () {
        final utcTime = DateTime.utc(2026, 6, 15, 18, 0, 0);
        final result = TimezoneUtils.formatMatchTime(
          utcDateTime: utcTime,
          venueTimezone: 'America/New_York',
          mode: TimezoneDisplayMode.local,
        );

        // Should contain a time like "X:XX AM/PM" and a timezone abbreviation
        expect(result, matches(RegExp(r'\d{1,2}:\d{2} [AP]M')));
      });

      test('formats time in venue mode', () {
        final utcTime = DateTime.utc(2026, 6, 15, 18, 0, 0);
        final result = TimezoneUtils.formatMatchTime(
          utcDateTime: utcTime,
          venueTimezone: 'America/New_York',
          mode: TimezoneDisplayMode.venue,
        );

        // Should show venue time: 2:00 PM EDT
        expect(result, contains('2:00 PM'));
        expect(result, matches(RegExp(r'\d{1,2}:\d{2} [AP]M')));
      });

      test('formats time in both mode', () {
        final utcTime = DateTime.utc(2026, 6, 15, 18, 0, 0);
        final result = TimezoneUtils.formatMatchTime(
          utcDateTime: utcTime,
          venueTimezone: 'America/Los_Angeles',
          mode: TimezoneDisplayMode.both,
        );

        // Result depends on whether local timezone matches LA or not
        expect(result, isNotEmpty);
        expect(result, matches(RegExp(r'\d{1,2}:\d{2} [AP]M')));
      });

      test('defaults to local mode', () {
        final utcTime = DateTime.utc(2026, 6, 15, 18, 0, 0);
        final result = TimezoneUtils.formatMatchTime(
          utcDateTime: utcTime,
          venueTimezone: 'America/New_York',
        );

        // Default mode is local
        final explicitLocal = TimezoneUtils.formatMatchTime(
          utcDateTime: utcTime,
          venueTimezone: 'America/New_York',
          mode: TimezoneDisplayMode.local,
        );
        expect(result, equals(explicitLocal));
      });
    });

    group('formatMatchDateTime', () {
      test('formats full date and time without year', () {
        final utcTime = DateTime.utc(2026, 6, 15, 18, 0, 0);
        final result = TimezoneUtils.formatMatchDateTime(
          utcDateTime: utcTime,
          venueTimezone: 'America/New_York',
        );

        // Should contain month abbreviation and day
        expect(result, matches(RegExp(r'[A-Z][a-z]+ \d{1,2}')));
        // Should contain time
        expect(result, matches(RegExp(r'\d{1,2}:\d{2} [AP]M')));
      });

      test('formats full date and time with year', () {
        final utcTime = DateTime.utc(2026, 6, 15, 18, 0, 0);
        final result = TimezoneUtils.formatMatchDateTime(
          utcDateTime: utcTime,
          venueTimezone: 'America/New_York',
          includeYear: true,
        );

        expect(result, contains('2026'));
      });

      test('uses venue timezone in venue mode', () {
        final utcTime = DateTime.utc(2026, 6, 15, 18, 0, 0);
        final result = TimezoneUtils.formatMatchDateTime(
          utcDateTime: utcTime,
          venueTimezone: 'America/New_York',
          mode: TimezoneDisplayMode.venue,
        );

        // In venue mode, 18:00 UTC = 2:00 PM EDT
        expect(result, contains('2:00 PM'));
      });

      test('in both mode uses local time', () {
        final utcTime = DateTime.utc(2026, 6, 15, 18, 0, 0);
        final localResult = TimezoneUtils.formatMatchDateTime(
          utcDateTime: utcTime,
          venueTimezone: 'America/New_York',
          mode: TimezoneDisplayMode.local,
        );
        final bothResult = TimezoneUtils.formatMatchDateTime(
          utcDateTime: utcTime,
          venueTimezone: 'America/New_York',
          mode: TimezoneDisplayMode.both,
        );

        // "both" mode for formatMatchDateTime uses local time
        expect(bothResult, equals(localResult));
      });
    });

    group('formatRelativeDate', () {
      test('shows "Today" for current date', () {
        // Create a UTC time that corresponds to "now" in local timezone
        // by using DateTime.now().toUtc() which guarantees the local
        // interpretation is today.
        final nowUtc = DateTime.now().toUtc();
        final result = TimezoneUtils.formatRelativeDate(
          utcDateTime: nowUtc,
          venueTimezone: 'America/New_York',
          mode: TimezoneDisplayMode.local,
        );

        expect(result, startsWith('Today'));
      });

      test('shows "Tomorrow" for next day', () {
        final now = DateTime.now();
        final tomorrow = now.add(const Duration(days: 1));
        // Use a time that will land on tomorrow in the local timezone
        final tomorrowUtc = DateTime.utc(
            tomorrow.year, tomorrow.month, tomorrow.day, 12, 0);
        // Convert to make sure it's tomorrow in local
        final localTomorrow = tomorrowUtc.toLocal();
        final localNow = DateTime.now();
        final localToday =
            DateTime(localNow.year, localNow.month, localNow.day);
        final localTomorrowDate = DateTime(
            localTomorrow.year, localTomorrow.month, localTomorrow.day);
        final expectedTomorrow = localToday.add(const Duration(days: 1));

        if (localTomorrowDate == expectedTomorrow) {
          final result = TimezoneUtils.formatRelativeDate(
            utcDateTime: tomorrowUtc,
            venueTimezone: 'America/New_York',
            mode: TimezoneDisplayMode.local,
          );
          expect(result, startsWith('Tomorrow'));
        }
        // If timezone offset makes it not "tomorrow", that's okay - skip
      });

      test('shows date for a future date beyond tomorrow', () {
        // Use a date far in the future
        final futureUtc = DateTime.utc(2026, 12, 25, 15, 0, 0);
        final result = TimezoneUtils.formatRelativeDate(
          utcDateTime: futureUtc,
          venueTimezone: 'America/New_York',
          mode: TimezoneDisplayMode.local,
        );

        // Should show "Dec 25" (or Dec 24 depending on timezone)
        expect(result, matches(RegExp(r'[A-Z][a-z]+ \d{1,2}')));
        expect(result, isNot(startsWith('Today')));
        expect(result, isNot(startsWith('Tomorrow')));
      });

      test('includes time in the output', () {
        final utcTime = DateTime.utc(2026, 8, 15, 18, 0, 0);
        final result = TimezoneUtils.formatRelativeDate(
          utcDateTime: utcTime,
          venueTimezone: 'America/New_York',
        );

        expect(result, matches(RegExp(r'\d{1,2}:\d{2} [AP]M')));
      });

      test('uses venue timezone in venue mode', () {
        final utcTime = DateTime.utc(2026, 8, 15, 18, 0, 0);
        final result = TimezoneUtils.formatRelativeDate(
          utcDateTime: utcTime,
          venueTimezone: 'America/New_York',
          mode: TimezoneDisplayMode.venue,
        );

        expect(result, isNotEmpty);
        expect(result, matches(RegExp(r'\d{1,2}:\d{2} [AP]M')));
      });
    });

    group('SharedPreferences - TimezoneDisplayMode', () {
      setUp(() {
        SharedPreferences.setMockInitialValues({});
      });

      test('defaults to local mode when no preference saved', () async {
        final mode = await TimezoneUtils.getTimezoneDisplayMode();
        expect(mode, equals(TimezoneDisplayMode.local));
      });

      test('saves and retrieves local mode', () async {
        await TimezoneUtils.setTimezoneDisplayMode(
            TimezoneDisplayMode.local);
        final mode = await TimezoneUtils.getTimezoneDisplayMode();
        expect(mode, equals(TimezoneDisplayMode.local));
      });

      test('saves and retrieves venue mode', () async {
        await TimezoneUtils.setTimezoneDisplayMode(
            TimezoneDisplayMode.venue);
        final mode = await TimezoneUtils.getTimezoneDisplayMode();
        expect(mode, equals(TimezoneDisplayMode.venue));
      });

      test('saves and retrieves both mode', () async {
        await TimezoneUtils.setTimezoneDisplayMode(
            TimezoneDisplayMode.both);
        final mode = await TimezoneUtils.getTimezoneDisplayMode();
        expect(mode, equals(TimezoneDisplayMode.both));
      });

      test('overwrites previous preference', () async {
        await TimezoneUtils.setTimezoneDisplayMode(
            TimezoneDisplayMode.venue);
        await TimezoneUtils.setTimezoneDisplayMode(
            TimezoneDisplayMode.both);
        final mode = await TimezoneUtils.getTimezoneDisplayMode();
        expect(mode, equals(TimezoneDisplayMode.both));
      });
    });

    group('SharedPreferences - User timezone override', () {
      setUp(() {
        SharedPreferences.setMockInitialValues({});
      });

      test('returns null when no override set', () async {
        final override = await TimezoneUtils.getUserTimezoneOverride();
        expect(override, isNull);
      });

      test('saves and retrieves timezone override', () async {
        await TimezoneUtils.setUserTimezoneOverride('America/Chicago');
        final override = await TimezoneUtils.getUserTimezoneOverride();
        expect(override, equals('America/Chicago'));
      });

      test('clears override when set to null', () async {
        await TimezoneUtils.setUserTimezoneOverride('America/Denver');
        await TimezoneUtils.setUserTimezoneOverride(null);
        final override = await TimezoneUtils.getUserTimezoneOverride();
        expect(override, isNull);
      });

      test('overwrites previous override', () async {
        await TimezoneUtils.setUserTimezoneOverride('America/New_York');
        await TimezoneUtils.setUserTimezoneOverride('America/Chicago');
        final override = await TimezoneUtils.getUserTimezoneOverride();
        expect(override, equals('America/Chicago'));
      });
    });

    group('TimezoneDisplayMode enum', () {
      test('has three values', () {
        expect(TimezoneDisplayMode.values.length, equals(3));
      });

      test('contains local, venue, and both', () {
        expect(
          TimezoneDisplayMode.values,
          containsAll([
            TimezoneDisplayMode.local,
            TimezoneDisplayMode.venue,
            TimezoneDisplayMode.both,
          ]),
        );
      });

      test('indices are sequential starting from 0', () {
        expect(TimezoneDisplayMode.local.index, equals(0));
        expect(TimezoneDisplayMode.venue.index, equals(1));
        expect(TimezoneDisplayMode.both.index, equals(2));
      });
    });

    group('worldCupTimezones', () {
      test('contains 8 timezone entries', () {
        expect(TimezoneUtils.worldCupTimezones.length, equals(8));
      });

      test('each entry has name and label keys', () {
        for (final tz in TimezoneUtils.worldCupTimezones) {
          expect(tz.containsKey('name'), isTrue,
              reason: 'Missing "name" key in $tz');
          expect(tz.containsKey('label'), isTrue,
              reason: 'Missing "label" key in $tz');
        }
      });

      test('all timezone names are valid IANA names', () {
        for (final entry in TimezoneUtils.worldCupTimezones) {
          final location = TimezoneUtils.getLocation(entry['name']!);
          expect(location.name, equals(entry['name']),
              reason:
                  'Invalid timezone name: ${entry['name']}');
        }
      });

      test('includes major US venue timezones', () {
        final names = TimezoneUtils.worldCupTimezones
            .map((e) => e['name'])
            .toList();
        expect(names, contains('America/New_York'));
        expect(names, contains('America/Chicago'));
        expect(names, contains('America/Denver'));
        expect(names, contains('America/Los_Angeles'));
      });

      test('includes Mexico timezone', () {
        final names = TimezoneUtils.worldCupTimezones
            .map((e) => e['name'])
            .toList();
        expect(names, contains('America/Mexico_City'));
      });

      test('includes Canada timezones', () {
        final names = TimezoneUtils.worldCupTimezones
            .map((e) => e['name'])
            .toList();
        expect(names, contains('America/Vancouver'));
        expect(names, contains('America/Toronto'));
      });

      test('labels are non-empty', () {
        for (final tz in TimezoneUtils.worldCupTimezones) {
          expect(tz['label'], isNotEmpty,
              reason: 'Label is empty for ${tz['name']}');
        }
      });
    });

    group('DateTimeTimezoneExtension', () {
      test('toTimezone converts UTC datetime to specified timezone', () {
        final utcTime = DateTime.utc(2026, 6, 15, 18, 0, 0);
        final converted = utcTime.toTimezone('America/New_York');

        // EDT: UTC-4 => 14:00
        expect(converted.hour, equals(14));
      });

      test('toTimezone falls back to UTC for invalid timezone', () {
        final utcTime = DateTime.utc(2026, 6, 15, 18, 0, 0);
        final converted = utcTime.toTimezone('Invalid/Zone');

        expect(converted.hour, equals(18));
      });
    });
  });
}

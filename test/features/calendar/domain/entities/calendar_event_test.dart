import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/calendar/domain/entities/calendar_event.dart';

void main() {
  group('CalendarEventType', () {
    test('has all expected values', () {
      expect(CalendarEventType.values, hasLength(3));
      expect(CalendarEventType.values, contains(CalendarEventType.match));
      expect(CalendarEventType.values, contains(CalendarEventType.watchParty));
      expect(CalendarEventType.values, contains(CalendarEventType.reminder));
    });
  });

  group('CalendarEvent', () {
    final startTime = DateTime(2026, 6, 11, 18, 0);
    final endTime = DateTime(2026, 6, 11, 20, 0);

    test('creates event with required fields', () {
      final event = CalendarEvent(
        id: 'match-1',
        title: 'USA vs Mexico',
        startTime: startTime,
        endTime: endTime,
      );

      expect(event.id, 'match-1');
      expect(event.title, 'USA vs Mexico');
      expect(event.startTime, startTime);
      expect(event.endTime, endTime);
      expect(event.type, CalendarEventType.match);
      expect(event.description, isNull);
      expect(event.location, isNull);
      expect(event.url, isNull);
      expect(event.metadata, isEmpty);
    });

    test('creates event with all optional fields', () {
      final event = CalendarEvent(
        id: 'match-1',
        title: 'USA vs Mexico',
        description: 'Group stage match',
        location: 'MetLife Stadium, NJ',
        startTime: startTime,
        endTime: endTime,
        url: 'https://pregameworldcup.com/match/1',
        type: CalendarEventType.match,
        metadata: const {'homeTeam': 'USA', 'awayTeam': 'Mexico'},
      );

      expect(event.description, 'Group stage match');
      expect(event.location, 'MetLife Stadium, NJ');
      expect(event.url, 'https://pregameworldcup.com/match/1');
      expect(event.metadata, {'homeTeam': 'USA', 'awayTeam': 'Mexico'});
    });

    group('fromMatch factory', () {
      test('creates event from match with all fields', () {
        final matchTime = DateTime(2026, 6, 15, 20, 0);
        final event = CalendarEvent.fromMatch(
          matchId: 'match-42',
          homeTeam: 'Brazil',
          awayTeam: 'Argentina',
          matchTime: matchTime,
          venueName: 'MetLife Stadium',
          venueCity: 'East Rutherford',
          stage: 'Group A',
        );

        expect(event.id, 'match-42');
        expect(event.title, 'Brazil vs Argentina');
        expect(event.startTime, matchTime);
        expect(event.endTime, matchTime.add(const Duration(hours: 2)));
        expect(event.type, CalendarEventType.match);
        expect(event.location, 'MetLife Stadium, East Rutherford');
        expect(event.description, contains('FIFA World Cup 2026'));
        expect(event.description, contains('Brazil vs Argentina'));
        expect(event.description, contains('Stage: Group A'));
        expect(event.description, contains('Venue: MetLife Stadium, East Rutherford'));
        expect(event.metadata['homeTeam'], 'Brazil');
        expect(event.metadata['awayTeam'], 'Argentina');
        expect(event.metadata['stage'], 'Group A');
      });

      test('creates event from match with custom duration', () {
        final matchTime = DateTime(2026, 6, 15, 20, 0);
        final event = CalendarEvent.fromMatch(
          matchId: 'match-42',
          homeTeam: 'Brazil',
          awayTeam: 'Argentina',
          matchTime: matchTime,
          matchDuration: const Duration(hours: 3),
        );

        expect(event.endTime, matchTime.add(const Duration(hours: 3)));
      });

      test('creates event from match without venue', () {
        final matchTime = DateTime(2026, 6, 15, 20, 0);
        final event = CalendarEvent.fromMatch(
          matchId: 'match-42',
          homeTeam: 'Brazil',
          awayTeam: 'Argentina',
          matchTime: matchTime,
        );

        expect(event.location, isNull);
      });

      test('creates event from match with venue name only', () {
        final matchTime = DateTime(2026, 6, 15, 20, 0);
        final event = CalendarEvent.fromMatch(
          matchId: 'match-42',
          homeTeam: 'Brazil',
          awayTeam: 'Argentina',
          matchTime: matchTime,
          venueName: 'MetLife Stadium',
        );

        expect(event.location, 'MetLife Stadium');
      });

      test('creates event from match with venue city only', () {
        final matchTime = DateTime(2026, 6, 15, 20, 0);
        final event = CalendarEvent.fromMatch(
          matchId: 'match-42',
          homeTeam: 'Brazil',
          awayTeam: 'Argentina',
          matchTime: matchTime,
          venueCity: 'East Rutherford',
        );

        expect(event.location, 'East Rutherford');
      });

      test('does not include stage in metadata when null', () {
        final matchTime = DateTime(2026, 6, 15, 20, 0);
        final event = CalendarEvent.fromMatch(
          matchId: 'match-42',
          homeTeam: 'Brazil',
          awayTeam: 'Argentina',
          matchTime: matchTime,
        );

        expect(event.metadata.containsKey('stage'), isFalse);
      });
    });

    group('fromWatchParty factory', () {
      test('creates event from watch party with all fields', () {
        final partyTime = DateTime(2026, 6, 20, 19, 0);
        final event = CalendarEvent.fromWatchParty(
          partyId: 'party-1',
          partyName: 'Big Game Watch',
          matchName: 'USA vs England',
          startTime: partyTime,
          venueName: 'Sports Bar',
          venueAddress: '123 Main St',
          hostName: 'Chris',
        );

        expect(event.id, 'party-1');
        expect(event.title, 'Watch Party: Big Game Watch');
        expect(event.type, CalendarEventType.watchParty);
        expect(event.location, '123 Main St');
        // Start time is 30 minutes before party time
        expect(event.startTime, partyTime.subtract(const Duration(minutes: 30)));
        // End time is 2h30m after party time
        expect(event.endTime, partyTime.add(const Duration(hours: 2, minutes: 30)));
        expect(event.description, contains('Watch Party for USA vs England'));
        expect(event.description, contains('Hosted by: Chris'));
        expect(event.description, contains('Location: Sports Bar'));
        expect(event.metadata['matchName'], 'USA vs England');
        expect(event.metadata['hostName'], 'Chris');
      });

      test('creates event from watch party without optional fields', () {
        final partyTime = DateTime(2026, 6, 20, 19, 0);
        final event = CalendarEvent.fromWatchParty(
          partyId: 'party-1',
          partyName: 'Big Game Watch',
          matchName: 'USA vs England',
          startTime: partyTime,
        );

        expect(event.location, isNull);
        expect(event.metadata.containsKey('hostName'), isFalse);
      });

      test('uses venueName when venueAddress is not provided', () {
        final partyTime = DateTime(2026, 6, 20, 19, 0);
        final event = CalendarEvent.fromWatchParty(
          partyId: 'party-1',
          partyName: 'Big Game Watch',
          matchName: 'USA vs England',
          startTime: partyTime,
          venueName: 'Sports Bar',
        );

        expect(event.location, 'Sports Bar');
      });
    });

    group('reminder factory', () {
      test('creates reminder event', () {
        final reminderTime = DateTime(2026, 6, 11, 17, 30);
        final event = CalendarEvent.reminder(
          id: 'reminder-1',
          title: 'Match Starting Soon',
          reminderTime: reminderTime,
          description: 'USA vs Mexico starts in 30 minutes',
        );

        expect(event.id, 'reminder-1');
        expect(event.title, 'Match Starting Soon');
        expect(event.startTime, reminderTime);
        expect(event.endTime, reminderTime.add(const Duration(minutes: 15)));
        expect(event.type, CalendarEventType.reminder);
        expect(event.description, 'USA vs Mexico starts in 30 minutes');
      });

      test('creates reminder event without description', () {
        final reminderTime = DateTime(2026, 6, 11, 17, 30);
        final event = CalendarEvent.reminder(
          id: 'reminder-1',
          title: 'Match Starting Soon',
          reminderTime: reminderTime,
        );

        expect(event.description, isNull);
      });
    });

    group('equality', () {
      test('two events with same props are equal', () {
        final event1 = CalendarEvent(
          id: 'match-1',
          title: 'USA vs Mexico',
          startTime: startTime,
          endTime: endTime,
        );
        final event2 = CalendarEvent(
          id: 'match-1',
          title: 'USA vs Mexico',
          startTime: startTime,
          endTime: endTime,
        );
        expect(event1, equals(event2));
      });

      test('two events with different ids are not equal', () {
        final event1 = CalendarEvent(
          id: 'match-1',
          title: 'USA vs Mexico',
          startTime: startTime,
          endTime: endTime,
        );
        final event2 = CalendarEvent(
          id: 'match-2',
          title: 'USA vs Mexico',
          startTime: startTime,
          endTime: endTime,
        );
        expect(event1, isNot(equals(event2)));
      });
    });
  });

  group('CalendarResult', () {
    test('success factory creates successful result', () {
      final result = CalendarResult.success('event-123');
      expect(result.success, isTrue);
      expect(result.eventId, 'event-123');
      expect(result.error, isNull);
    });

    test('success factory without eventId', () {
      final result = CalendarResult.success();
      expect(result.success, isTrue);
      expect(result.eventId, isNull);
    });

    test('failure factory creates failed result', () {
      final result = CalendarResult.failure('Calendar permission denied');
      expect(result.success, isFalse);
      expect(result.error, 'Calendar permission denied');
      expect(result.eventId, isNull);
    });
  });
}

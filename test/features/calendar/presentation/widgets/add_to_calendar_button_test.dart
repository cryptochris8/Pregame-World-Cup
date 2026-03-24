import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/calendar/domain/entities/calendar_event.dart';
import 'package:pregame_world_cup/features/calendar/presentation/widgets/add_to_calendar_button.dart';

void main() {
  group('CalendarEvent', () {
    test('construction with required fields', () {
      final now = DateTime.now();
      final later = now.add(const Duration(hours: 2));

      final event = CalendarEvent(
        id: 'test-id',
        title: 'Test Event',
        startTime: now,
        endTime: later,
      );

      expect(event.id, 'test-id');
      expect(event.title, 'Test Event');
      expect(event.startTime, now);
      expect(event.endTime, later);
    });

    test('defaults: type is match, metadata is empty', () {
      final now = DateTime.now();
      final event = CalendarEvent(
        id: 'test',
        title: 'Test',
        startTime: now,
        endTime: now.add(const Duration(hours: 1)),
      );

      expect(event.type, CalendarEventType.match);
      expect(event.metadata, isEmpty);
    });

    test('CalendarEvent.fromMatch factory creates correct event', () {
      final matchTime = DateTime(2026, 6, 11, 15, 0);

      final event = CalendarEvent.fromMatch(
        matchId: 'match-123',
        homeTeam: 'USA',
        awayTeam: 'Mexico',
        matchTime: matchTime,
        venueName: 'Stadium',
        venueCity: 'New York',
        stage: 'Group A',
      );

      expect(event.id, 'match-123');
      expect(event.title, 'USA vs Mexico');
      expect(event.startTime, matchTime);
      expect(event.endTime, matchTime.add(const Duration(hours: 2)));
      expect(event.type, CalendarEventType.match);
      expect(event.location, 'Stadium, New York');
      expect(event.metadata['homeTeam'], 'USA');
      expect(event.metadata['awayTeam'], 'Mexico');
      expect(event.metadata['stage'], 'Group A');
    });

    test('CalendarEvent.fromWatchParty factory creates correct event', () {
      final startTime = DateTime(2026, 6, 11, 15, 0);

      final event = CalendarEvent.fromWatchParty(
        partyId: 'party-456',
        partyName: 'USA Game Watch Party',
        matchName: 'USA vs Mexico',
        startTime: startTime,
        venueName: 'Sports Bar',
        venueAddress: '123 Main St',
        hostName: 'John Doe',
      );

      expect(event.id, 'party-456');
      expect(event.title, 'Watch Party: USA Game Watch Party');
      expect(event.startTime, startTime.subtract(const Duration(minutes: 30)));
      expect(event.endTime, startTime.add(const Duration(hours: 2, minutes: 30)));
      expect(event.type, CalendarEventType.watchParty);
      expect(event.location, '123 Main St');
      expect(event.metadata['matchName'], 'USA vs Mexico');
      expect(event.metadata['hostName'], 'John Doe');
    });

    test('CalendarEvent.reminder factory creates correct event', () {
      final reminderTime = DateTime(2026, 6, 11, 14, 0);

      final event = CalendarEvent.reminder(
        id: 'reminder-789',
        title: 'Match starts soon',
        reminderTime: reminderTime,
        description: 'Get ready',
      );

      expect(event.id, 'reminder-789');
      expect(event.title, 'Match starts soon');
      expect(event.description, 'Get ready');
      expect(event.startTime, reminderTime);
      expect(event.endTime, reminderTime.add(const Duration(minutes: 15)));
      expect(event.type, CalendarEventType.reminder);
    });

    test('CalendarEvent Equatable comparison', () {
      final now = DateTime.now();

      final event1 = CalendarEvent(
        id: 'test',
        title: 'Test Event',
        startTime: now,
        endTime: now.add(const Duration(hours: 1)),
      );

      final event2 = CalendarEvent(
        id: 'test',
        title: 'Test Event',
        startTime: now,
        endTime: now.add(const Duration(hours: 1)),
      );

      final event3 = CalendarEvent(
        id: 'different',
        title: 'Test Event',
        startTime: now,
        endTime: now.add(const Duration(hours: 1)),
      );

      expect(event1, equals(event2));
      expect(event1, isNot(equals(event3)));
    });
  });

  group('CalendarEventType', () {
    test('has 3 values', () {
      expect(CalendarEventType.values.length, 3);
      expect(CalendarEventType.values, contains(CalendarEventType.match));
      expect(CalendarEventType.values, contains(CalendarEventType.watchParty));
      expect(CalendarEventType.values, contains(CalendarEventType.reminder));
    });
  });

  group('CalendarResult', () {
    test('CalendarResult.success factory', () {
      final result1 = CalendarResult.success();
      expect(result1.success, isTrue);
      expect(result1.eventId, isNull);
      expect(result1.error, isNull);

      final result2 = CalendarResult.success('event-123');
      expect(result2.success, isTrue);
      expect(result2.eventId, 'event-123');
      expect(result2.error, isNull);
    });

    test('CalendarResult.failure factory', () {
      final result = CalendarResult.failure('Something went wrong');
      expect(result.success, isFalse);
      expect(result.error, 'Something went wrong');
      expect(result.eventId, isNull);
    });
  });

  group('AddToCalendarButton', () {
    late CalendarEvent testEvent;

    setUp(() {
      final now = DateTime.now();
      testEvent = CalendarEvent(
        id: 'test',
        title: 'Test Event',
        startTime: now,
        endTime: now.add(const Duration(hours: 1)),
      );
    });

    test('is a StatelessWidget', () {
      final button = AddToCalendarButton(event: testEvent);
      expect(button, isA<StatelessWidget>());
    });

    test('stores event', () {
      final button = AddToCalendarButton(event: testEvent);
      expect(button.event, testEvent);
    });

    test('showLabel defaults to true', () {
      final button = AddToCalendarButton(event: testEvent);
      expect(button.showLabel, isTrue);
    });

    test('compact defaults to false', () {
      final button = AddToCalendarButton(event: testEvent);
      expect(button.compact, isFalse);
    });
  });

  group('CalendarOptionsSheet', () {
    late CalendarEvent testEvent;

    setUp(() {
      final now = DateTime.now();
      testEvent = CalendarEvent(
        id: 'test',
        title: 'Test Event',
        startTime: now,
        endTime: now.add(const Duration(hours: 1)),
      );
    });

    test('is a StatefulWidget', () {
      final sheet = CalendarOptionsSheet(event: testEvent);
      expect(sheet, isA<StatefulWidget>());
    });

    test('stores event', () {
      final sheet = CalendarOptionsSheet(event: testEvent);
      expect(sheet.event, testEvent);
    });
  });

  group('MatchCalendarButton', () {
    test('is a StatelessWidget', () {
      final button = MatchCalendarButton(
        matchId: 'match-1',
        homeTeam: 'USA',
        awayTeam: 'Mexico',
        matchTime: DateTime.now(),
      );
      expect(button, isA<StatelessWidget>());
    });

    test('stores required params', () {
      final matchTime = DateTime(2026, 6, 11, 15, 0);
      final button = MatchCalendarButton(
        matchId: 'match-1',
        homeTeam: 'USA',
        awayTeam: 'Mexico',
        matchTime: matchTime,
      );

      expect(button.matchId, 'match-1');
      expect(button.homeTeam, 'USA');
      expect(button.awayTeam, 'Mexico');
      expect(button.matchTime, matchTime);
    });

    test('stores optional params', () {
      final matchTime = DateTime(2026, 6, 11, 15, 0);
      final button = MatchCalendarButton(
        matchId: 'match-1',
        homeTeam: 'USA',
        awayTeam: 'Mexico',
        matchTime: matchTime,
        venueName: 'Stadium',
        venueCity: 'New York',
        stage: 'Group A',
      );

      expect(button.venueName, 'Stadium');
      expect(button.venueCity, 'New York');
      expect(button.stage, 'Group A');
    });
  });
}

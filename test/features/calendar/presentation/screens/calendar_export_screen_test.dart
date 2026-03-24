import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/calendar/domain/entities/calendar_event.dart';
import 'package:pregame_world_cup/features/calendar/presentation/screens/calendar_export_screen.dart';

void main() {
  group('CalendarExportScreen', () {
    late List<CalendarEvent> testEvents;

    setUp(() {
      final now = DateTime.now();
      testEvents = [
        CalendarEvent(
          id: 'event-1',
          title: 'Event 1',
          startTime: now,
          endTime: now.add(const Duration(hours: 1)),
        ),
        CalendarEvent(
          id: 'event-2',
          title: 'Event 2',
          startTime: now.add(const Duration(days: 1)),
          endTime: now.add(const Duration(days: 1, hours: 1)),
        ),
      ];
    });

    test('is a StatefulWidget', () {
      final screen = CalendarExportScreen(events: testEvents);
      expect(screen, isA<StatefulWidget>());
    });

    test('stores events list', () {
      final screen = CalendarExportScreen(events: testEvents);
      expect(screen.events, testEvents);
      expect(screen.events.length, 2);
    });

    test('stores optional title', () {
      final screen = CalendarExportScreen(
        events: testEvents,
        title: 'My Calendar',
      );
      expect(screen.title, 'My Calendar');
    });

    test('stores optional subtitle', () {
      final screen = CalendarExportScreen(
        events: testEvents,
        subtitle: 'Export your events',
      );
      expect(screen.subtitle, 'Export your events');
    });

    test('can be constructed with required parameters only', () {
      expect(
        () => CalendarExportScreen(events: testEvents),
        returnsNormally,
      );

      final screen = CalendarExportScreen(events: testEvents);
      expect(screen.title, isNull);
      expect(screen.subtitle, isNull);
    });

    test('can be constructed with all parameters', () {
      expect(
        () => CalendarExportScreen(
          events: testEvents,
          title: 'Title',
          subtitle: 'Subtitle',
        ),
        returnsNormally,
      );

      final screen = CalendarExportScreen(
        events: testEvents,
        title: 'Title',
        subtitle: 'Subtitle',
      );
      expect(screen.events, testEvents);
      expect(screen.title, 'Title');
      expect(screen.subtitle, 'Subtitle');
    });

    test('stores empty events list', () {
      final screen = CalendarExportScreen(events: const []);
      expect(screen.events, isEmpty);
    });

    test('stores multiple events', () {
      final now = DateTime.now();
      final manyEvents = List.generate(
        10,
        (i) => CalendarEvent(
          id: 'event-$i',
          title: 'Event $i',
          startTime: now.add(Duration(days: i)),
          endTime: now.add(Duration(days: i, hours: 1)),
        ),
      );

      final screen = CalendarExportScreen(events: manyEvents);
      expect(screen.events.length, 10);
      expect(screen.events.first.id, 'event-0');
      expect(screen.events.last.id, 'event-9');
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/calendar/domain/entities/calendar_event.dart';
import 'package:pregame_world_cup/features/calendar/domain/services/calendar_service.dart';

void main() {
  late CalendarService calendarService;

  setUp(() {
    // Reset singleton for each test
    calendarService = CalendarService();
  });

  CalendarEvent createTestEvent({
    String id = 'match-1',
    String title = 'USA vs Mexico',
    String? description = 'Group stage match',
    String? location = 'MetLife Stadium, NJ',
    DateTime? startTime,
    DateTime? endTime,
    String? url,
    CalendarEventType type = CalendarEventType.match,
  }) {
    final start = startTime ?? DateTime.utc(2026, 6, 11, 18, 0);
    return CalendarEvent(
      id: id,
      title: title,
      description: description,
      location: location,
      startTime: start,
      endTime: endTime ?? start.add(const Duration(hours: 2)),
      url: url,
      type: type,
    );
  }

  group('CalendarService', () {
    group('singleton pattern', () {
      test('returns same instance', () {
        final service1 = CalendarService();
        final service2 = CalendarService();
        expect(identical(service1, service2), isTrue);
      });
    });

    group('generateGoogleCalendarUrl', () {
      test('generates valid URL with all event fields', () {
        final event = createTestEvent(
          startTime: DateTime.utc(2026, 6, 11, 18, 0),
          url: 'https://pregameworldcup.com/match/1',
        );

        final url = calendarService.generateGoogleCalendarUrl(event);

        expect(url, contains('calendar.google.com'));
        expect(url, contains('action=TEMPLATE'));
        expect(url, contains('text=USA+vs+Mexico'));
        expect(url, contains('location=MetLife+Stadium'));
        expect(url, contains('details=Group+stage+match'));
      });

      test('generates URL without optional fields', () {
        final event = CalendarEvent(
          id: 'match-1',
          title: 'Test Match',
          startTime: DateTime.utc(2026, 6, 11, 18, 0),
          endTime: DateTime.utc(2026, 6, 11, 20, 0),
        );

        final url = calendarService.generateGoogleCalendarUrl(event);

        expect(url, contains('calendar.google.com'));
        expect(url, contains('text=Test+Match'));
        expect(url, isNot(contains('location=')));
        expect(url, isNot(contains('details=')));
      });

      test('includes date range in proper format', () {
        final event = createTestEvent(
          startTime: DateTime.utc(2026, 6, 11, 18, 0),
        );

        final url = calendarService.generateGoogleCalendarUrl(event);

        // The dates parameter should contain start/end in UTC format
        expect(url, contains('dates='));
        expect(url, contains('20260611T180000Z'));
      });
    });

    group('generateICalContent', () {
      test('generates valid iCal header and footer', () {
        final events = [createTestEvent()];
        final ical = calendarService.generateICalContent(events);

        expect(ical, contains('BEGIN:VCALENDAR'));
        expect(ical, contains('VERSION:2.0'));
        expect(ical, contains('PRODID:-//Pregame//World Cup 2026//EN'));
        expect(ical, contains('CALSCALE:GREGORIAN'));
        expect(ical, contains('METHOD:PUBLISH'));
        expect(ical, contains('END:VCALENDAR'));
      });

      test('includes calendar name when provided', () {
        final events = [createTestEvent()];
        final ical = calendarService.generateICalContent(
          events,
          calendarName: 'FIFA World Cup 2026',
        );

        expect(ical, contains('X-WR-CALNAME:FIFA World Cup 2026'));
      });

      test('does not include calendar name when not provided', () {
        final events = [createTestEvent()];
        final ical = calendarService.generateICalContent(events);

        expect(ical, isNot(contains('X-WR-CALNAME:')));
      });

      test('generates VEVENT for each event', () {
        final events = [
          createTestEvent(id: 'match-1', title: 'USA vs Mexico'),
          createTestEvent(id: 'match-2', title: 'Brazil vs Argentina'),
        ];
        final ical = calendarService.generateICalContent(events);

        // Count VEVENT blocks
        final veventCount = 'BEGIN:VEVENT'.allMatches(ical).length;
        expect(veventCount, 2);
      });

      test('includes event details in VEVENT', () {
        final event = createTestEvent(
          startTime: DateTime.utc(2026, 6, 11, 18, 0),
          url: 'https://pregameworldcup.com/match/1',
        );
        final ical = calendarService.generateICalContent([event]);

        expect(ical, contains('BEGIN:VEVENT'));
        expect(ical, contains('UID:match-1@pregame.app'));
        expect(ical, contains('SUMMARY:USA vs Mexico'));
        expect(ical, contains('DESCRIPTION:Group stage match'));
        expect(ical, contains('LOCATION:MetLife Stadium\\, NJ'));
        expect(ical, contains('URL:https://pregameworldcup.com/match/1'));
        expect(ical, contains('END:VEVENT'));
      });

      test('includes DTSTART and DTEND in UTC format', () {
        final event = createTestEvent(
          startTime: DateTime.utc(2026, 6, 11, 18, 0),
        );
        final ical = calendarService.generateICalContent([event]);

        expect(ical, contains('DTSTART:20260611T180000Z'));
        expect(ical, contains('DTEND:20260611T200000Z'));
      });

      test('includes 30-minute alarm for all events', () {
        final event = createTestEvent();
        final ical = calendarService.generateICalContent([event]);

        expect(ical, contains('BEGIN:VALARM'));
        expect(ical, contains('TRIGGER:-PT30M'));
        expect(ical, contains('ACTION:DISPLAY'));
        expect(ical, contains('END:VALARM'));
      });

      test('includes 1-hour alarm for match events', () {
        final event = createTestEvent(type: CalendarEventType.match);
        final ical = calendarService.generateICalContent([event]);

        expect(ical, contains('TRIGGER:-PT1H'));
      });

      test('does not include 1-hour alarm for non-match events', () {
        final event = createTestEvent(type: CalendarEventType.reminder);
        final ical = calendarService.generateICalContent([event]);

        expect(ical, isNot(contains('TRIGGER:-PT1H')));
      });

      test('escapes special characters in iCal text', () {
        final event = CalendarEvent(
          id: 'match-1',
          title: 'Test, with; special\\chars',
          description: 'Line1\nLine2',
          startTime: DateTime.utc(2026, 6, 11, 18, 0),
          endTime: DateTime.utc(2026, 6, 11, 20, 0),
        );
        final ical = calendarService.generateICalContent([event]);

        expect(ical, contains('Test\\, with\\; special\\\\chars'));
        expect(ical, contains('Line1\\nLine2'));
      });

      test('generates valid iCal for empty events list', () {
        final ical = calendarService.generateICalContent([]);

        expect(ical, contains('BEGIN:VCALENDAR'));
        expect(ical, contains('END:VCALENDAR'));
        expect(ical, isNot(contains('BEGIN:VEVENT')));
      });
    });

    group('generateICalFeedUrl', () {
      test('generates base URL without params', () {
        final url = calendarService.generateICalFeedUrl();

        expect(url, contains('api.pregameworldcup.com'));
        expect(url, contains('/v1/calendar/feed.ics'));
      });

      test('generates URL with userId', () {
        final url = calendarService.generateICalFeedUrl(userId: 'user-123');

        expect(url, contains('user=user-123'));
      });

      test('generates URL with team codes', () {
        final url = calendarService.generateICalFeedUrl(
          teamCodes: ['USA', 'MEX', 'CAN'],
        );

        expect(url, contains('teams=USA%2CMEX%2CCAN'));
      });

      test('generates URL with favorites only flag', () {
        final url = calendarService.generateICalFeedUrl(favoritesOnly: true);

        expect(url, contains('favorites=true'));
      });

      test('generates URL with all params', () {
        final url = calendarService.generateICalFeedUrl(
          userId: 'user-123',
          teamCodes: ['USA'],
          favoritesOnly: true,
        );

        expect(url, contains('user=user-123'));
        expect(url, contains('teams=USA'));
        expect(url, contains('favorites=true'));
      });

      test('does not include empty team codes', () {
        final url = calendarService.generateICalFeedUrl(teamCodes: []);

        expect(url, isNot(contains('teams=')));
      });
    });
  });
}

import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/services/logging_service.dart';
import '../entities/calendar_event.dart';

/// Service for calendar integration and iCal generation
class CalendarService {
  static const String _logTag = 'CalendarService';
  static CalendarService? _instance;

  CalendarService._();

  factory CalendarService() {
    _instance ??= CalendarService._();
    return _instance!;
  }

  // ==================== DEVICE CALENDAR ====================

  /// Add a single event to device calendar using URL scheme
  Future<CalendarResult> addToDeviceCalendar(CalendarEvent event) async {
    try {
      // Use calendar URL schemes for cross-platform support
      if (Platform.isIOS) {
        return await _addToAppleCalendar(event);
      } else if (Platform.isAndroid) {
        return await _addToAndroidCalendar(event);
      } else {
        // Fallback to iCal download
        return await _downloadICalFile([event], 'event_${event.id}.ics');
      }
    } catch (e) {
      LoggingService.error('Error adding to calendar: $e', tag: _logTag);
      return CalendarResult.failure(e.toString());
    }
  }

  Future<CalendarResult> _addToAppleCalendar(CalendarEvent event) async {
    // iOS doesn't support direct event creation via URL scheme
    // Fall back to generating and sharing an ICS file which opens in Calendar app
    return await _downloadICalFile([event], 'event_${event.id}.ics');
  }

  Future<CalendarResult> _addToAndroidCalendar(CalendarEvent event) async {
    try {
      // Try using Android calendar intent
      final intentUri = Uri.parse(
        'intent://com.android.calendar/time/${event.startTime.millisecondsSinceEpoch}'
        '#Intent;scheme=content;action=android.intent.action.INSERT;'
        'S.title=${Uri.encodeComponent(event.title)};'
        'S.description=${Uri.encodeComponent(event.description ?? "")};'
        'S.eventLocation=${Uri.encodeComponent(event.location ?? "")};'
        'i.beginTime=${event.startTime.millisecondsSinceEpoch};'
        'i.endTime=${event.endTime.millisecondsSinceEpoch};'
        'end',
      );

      if (await canLaunchUrl(intentUri)) {
        await launchUrl(intentUri);
        return CalendarResult.success();
      }

      // Fallback to ICS file
      return await _downloadICalFile([event], 'event_${event.id}.ics');
    } catch (e) {
      // Fallback to ICS file
      return await _downloadICalFile([event], 'event_${event.id}.ics');
    }
  }

  // ==================== GOOGLE CALENDAR ====================

  /// Generate Google Calendar URL for an event
  String generateGoogleCalendarUrl(CalendarEvent event) {
    final startTime = _formatDateForGoogle(event.startTime);
    final endTime = _formatDateForGoogle(event.endTime);

    final params = {
      'action': 'TEMPLATE',
      'text': event.title,
      'dates': '$startTime/$endTime',
      if (event.description != null) 'details': event.description!,
      if (event.location != null) 'location': event.location!,
      'sf': 'true',
      'output': 'xml',
    };

    final uri = Uri.https('calendar.google.com', '/calendar/render', params);
    return uri.toString();
  }

  /// Open Google Calendar with event
  Future<CalendarResult> addToGoogleCalendar(CalendarEvent event) async {
    try {
      final url = generateGoogleCalendarUrl(event);
      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return CalendarResult.success();
      } else {
        return CalendarResult.failure('Could not open Google Calendar');
      }
    } catch (e) {
      LoggingService.error('Error opening Google Calendar: $e', tag: _logTag);
      return CalendarResult.failure(e.toString());
    }
  }

  // ==================== ICAL GENERATION ====================

  /// Generate iCal (.ics) content for events
  String generateICalContent(List<CalendarEvent> events, {String? calendarName}) {
    final buffer = StringBuffer();

    // iCal header
    buffer.writeln('BEGIN:VCALENDAR');
    buffer.writeln('VERSION:2.0');
    buffer.writeln('PRODID:-//Pregame//World Cup 2026//EN');
    buffer.writeln('CALSCALE:GREGORIAN');
    buffer.writeln('METHOD:PUBLISH');
    if (calendarName != null) {
      buffer.writeln('X-WR-CALNAME:$calendarName');
    }

    // Add each event
    for (final event in events) {
      buffer.writeln(_generateVEvent(event));
    }

    // iCal footer
    buffer.writeln('END:VCALENDAR');

    return buffer.toString();
  }

  String _generateVEvent(CalendarEvent event) {
    final buffer = StringBuffer();
    final now = DateTime.now().toUtc();

    buffer.writeln('BEGIN:VEVENT');
    buffer.writeln('UID:${event.id}@pregame.app');
    buffer.writeln('DTSTAMP:${_formatDateForICal(now)}');
    buffer.writeln('DTSTART:${_formatDateForICal(event.startTime)}');
    buffer.writeln('DTEND:${_formatDateForICal(event.endTime)}');
    buffer.writeln('SUMMARY:${_escapeICalText(event.title)}');

    if (event.description != null) {
      buffer.writeln('DESCRIPTION:${_escapeICalText(event.description!)}');
    }

    if (event.location != null) {
      buffer.writeln('LOCATION:${_escapeICalText(event.location!)}');
    }

    if (event.url != null) {
      buffer.writeln('URL:${event.url}');
    }

    // Add alarm 30 minutes before
    buffer.writeln('BEGIN:VALARM');
    buffer.writeln('TRIGGER:-PT30M');
    buffer.writeln('ACTION:DISPLAY');
    buffer.writeln('DESCRIPTION:${_escapeICalText(event.title)} starts in 30 minutes');
    buffer.writeln('END:VALARM');

    // Add alarm 1 hour before for matches
    if (event.type == CalendarEventType.match) {
      buffer.writeln('BEGIN:VALARM');
      buffer.writeln('TRIGGER:-PT1H');
      buffer.writeln('ACTION:DISPLAY');
      buffer.writeln('DESCRIPTION:${_escapeICalText(event.title)} starts in 1 hour');
      buffer.writeln('END:VALARM');
    }

    buffer.writeln('END:VEVENT');

    return buffer.toString();
  }

  /// Generate and share iCal file
  Future<CalendarResult> shareICalFile(
    List<CalendarEvent> events, {
    String filename = 'world_cup_2026.ics',
    String? calendarName,
  }) async {
    try {
      final icalContent = generateICalContent(events, calendarName: calendarName);
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$filename');
      await file.writeAsString(icalContent);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: calendarName ?? 'World Cup 2026 Calendar',
      );

      return CalendarResult.success();
    } catch (e) {
      LoggingService.error('Error sharing iCal file: $e', tag: _logTag);
      return CalendarResult.failure(e.toString());
    }
  }

  /// Download iCal file (internal helper)
  Future<CalendarResult> _downloadICalFile(
    List<CalendarEvent> events,
    String filename,
  ) async {
    return await shareICalFile(events, filename: filename);
  }

  /// Generate iCal feed URL (for subscription)
  /// This would typically point to a backend endpoint
  String generateICalFeedUrl({
    String? userId,
    List<String>? teamCodes,
    bool favoritesOnly = false,
  }) {
    final params = <String, String>{};
    if (userId != null) params['user'] = userId;
    if (teamCodes != null && teamCodes.isNotEmpty) {
      params['teams'] = teamCodes.join(',');
    }
    if (favoritesOnly) params['favorites'] = 'true';

    final uri = Uri.https(
      'api.pregameworldcup.com',
      '/v1/calendar/feed.ics',
      params,
    );
    return uri.toString();
  }

  // ==================== BULK OPERATIONS ====================

  /// Add all matches for a team to calendar
  Future<CalendarResult> addTeamMatchesToCalendar(
    String teamCode,
    List<CalendarEvent> matches,
  ) async {
    try {
      final filename = '${teamCode.toLowerCase()}_matches.ics';
      final calendarName = '$teamCode - World Cup 2026 Matches';

      return await shareICalFile(
        matches,
        filename: filename,
        calendarName: calendarName,
      );
    } catch (e) {
      LoggingService.error('Error adding team matches: $e', tag: _logTag);
      return CalendarResult.failure(e.toString());
    }
  }

  /// Add all favorite team matches to calendar
  Future<CalendarResult> addFavoriteTeamMatches(
    List<CalendarEvent> matches,
  ) async {
    try {
      return await shareICalFile(
        matches,
        filename: 'my_team_matches.ics',
        calendarName: 'My World Cup 2026 Matches',
      );
    } catch (e) {
      LoggingService.error('Error adding favorite matches: $e', tag: _logTag);
      return CalendarResult.failure(e.toString());
    }
  }

  /// Export full World Cup calendar
  Future<CalendarResult> exportFullCalendar(List<CalendarEvent> allMatches) async {
    try {
      return await shareICalFile(
        allMatches,
        filename: 'world_cup_2026_full.ics',
        calendarName: 'FIFA World Cup 2026',
      );
    } catch (e) {
      LoggingService.error('Error exporting full calendar: $e', tag: _logTag);
      return CalendarResult.failure(e.toString());
    }
  }

  // ==================== HELPERS ====================

  String _formatDateForICal(DateTime date) {
    final utc = date.toUtc();
    return '${utc.year}'
        '${utc.month.toString().padLeft(2, '0')}'
        '${utc.day.toString().padLeft(2, '0')}'
        'T'
        '${utc.hour.toString().padLeft(2, '0')}'
        '${utc.minute.toString().padLeft(2, '0')}'
        '${utc.second.toString().padLeft(2, '0')}'
        'Z';
  }

  String _formatDateForGoogle(DateTime date) {
    final utc = date.toUtc();
    return '${utc.year}'
        '${utc.month.toString().padLeft(2, '0')}'
        '${utc.day.toString().padLeft(2, '0')}'
        'T'
        '${utc.hour.toString().padLeft(2, '0')}'
        '${utc.minute.toString().padLeft(2, '0')}'
        '${utc.second.toString().padLeft(2, '0')}'
        'Z';
  }

  String _escapeICalText(String text) {
    return text
        .replaceAll('\\', '\\\\')
        .replaceAll(',', '\\,')
        .replaceAll(';', '\\;')
        .replaceAll('\n', '\\n');
  }
}

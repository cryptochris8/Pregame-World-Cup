import 'package:equatable/equatable.dart';

/// A calendar event representing a match or reminder
class CalendarEvent extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? location;
  final DateTime startTime;
  final DateTime endTime;
  final String? url;
  final CalendarEventType type;
  final Map<String, String> metadata;

  const CalendarEvent({
    required this.id,
    required this.title,
    this.description,
    this.location,
    required this.startTime,
    required this.endTime,
    this.url,
    this.type = CalendarEventType.match,
    this.metadata = const {},
  });

  /// Create from a World Cup match
  factory CalendarEvent.fromMatch({
    required String matchId,
    required String homeTeam,
    required String awayTeam,
    required DateTime matchTime,
    String? venueName,
    String? venueCity,
    String? stage,
    Duration matchDuration = const Duration(hours: 2),
  }) {
    final location = venueName != null && venueCity != null
        ? '$venueName, $venueCity'
        : venueName ?? venueCity;

    return CalendarEvent(
      id: matchId,
      title: '$homeTeam vs $awayTeam',
      description: _buildMatchDescription(
        homeTeam: homeTeam,
        awayTeam: awayTeam,
        stage: stage,
        venue: location,
      ),
      location: location,
      startTime: matchTime,
      endTime: matchTime.add(matchDuration),
      type: CalendarEventType.match,
      metadata: {
        'homeTeam': homeTeam,
        'awayTeam': awayTeam,
        if (stage != null) 'stage': stage,
      },
    );
  }

  /// Create from a watch party
  factory CalendarEvent.fromWatchParty({
    required String partyId,
    required String partyName,
    required String matchName,
    required DateTime startTime,
    String? venueName,
    String? venueAddress,
    String? hostName,
  }) {
    return CalendarEvent(
      id: partyId,
      title: 'Watch Party: $partyName',
      description: _buildWatchPartyDescription(
        matchName: matchName,
        hostName: hostName,
        venue: venueName,
      ),
      location: venueAddress ?? venueName,
      startTime: startTime.subtract(const Duration(minutes: 30)), // Arrive early
      endTime: startTime.add(const Duration(hours: 2, minutes: 30)),
      type: CalendarEventType.watchParty,
      metadata: {
        'matchName': matchName,
        if (hostName != null) 'hostName': hostName,
      },
    );
  }

  /// Create a reminder event
  factory CalendarEvent.reminder({
    required String id,
    required String title,
    required DateTime reminderTime,
    String? description,
  }) {
    return CalendarEvent(
      id: id,
      title: title,
      description: description,
      startTime: reminderTime,
      endTime: reminderTime.add(const Duration(minutes: 15)),
      type: CalendarEventType.reminder,
    );
  }

  static String _buildMatchDescription({
    required String homeTeam,
    required String awayTeam,
    String? stage,
    String? venue,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('FIFA World Cup 2026');
    buffer.writeln('$homeTeam vs $awayTeam');
    if (stage != null) buffer.writeln('Stage: $stage');
    if (venue != null) buffer.writeln('Venue: $venue');
    buffer.writeln();
    buffer.writeln('Follow along on Pregame!');
    return buffer.toString();
  }

  static String _buildWatchPartyDescription({
    required String matchName,
    String? hostName,
    String? venue,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('Watch Party for $matchName');
    if (hostName != null) buffer.writeln('Hosted by: $hostName');
    if (venue != null) buffer.writeln('Location: $venue');
    buffer.writeln();
    buffer.writeln('Created with Pregame');
    return buffer.toString();
  }

  @override
  List<Object?> get props => [id, title, startTime, endTime, type];
}

/// Types of calendar events
enum CalendarEventType {
  match,
  watchParty,
  reminder,
}

/// Result of adding an event to calendar
class CalendarResult {
  final bool success;
  final String? eventId;
  final String? error;

  const CalendarResult({
    required this.success,
    this.eventId,
    this.error,
  });

  factory CalendarResult.success([String? eventId]) => CalendarResult(
        success: true,
        eventId: eventId,
      );

  factory CalendarResult.failure(String error) => CalendarResult(
        success: false,
        error: error,
      );
}

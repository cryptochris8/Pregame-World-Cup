import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Reminder timing options (minutes before match)
enum ReminderTiming {
  fifteenMinutes(15, '15 minutes'),
  thirtyMinutes(30, '30 minutes'),
  oneHour(60, '1 hour'),
  twoHours(120, '2 hours'),
  oneDay(1440, '1 day');

  final int minutes;
  final String displayName;

  const ReminderTiming(this.minutes, this.displayName);

  static ReminderTiming fromMinutes(int minutes) {
    return ReminderTiming.values.firstWhere(
      (t) => t.minutes == minutes,
      orElse: () => ReminderTiming.thirtyMinutes,
    );
  }
}

/// MatchReminder entity for storing user's match reminder preferences
class MatchReminder extends Equatable {
  /// Unique reminder ID
  final String reminderId;

  /// User who set the reminder
  final String userId;

  /// Match ID this reminder is for
  final String matchId;

  /// Match display name (e.g., "USA vs Mexico")
  final String matchName;

  /// Match date and time (UTC)
  final DateTime matchDateTimeUtc;

  /// When the reminder should be sent (UTC)
  final DateTime reminderDateTimeUtc;

  /// How long before match to remind
  final ReminderTiming timing;

  /// Whether the reminder is active
  final bool isEnabled;

  /// Whether the reminder has been sent
  final bool isSent;

  /// When the reminder was created
  final DateTime createdAt;

  /// Optional: Home team code for display
  final String? homeTeamCode;

  /// Optional: Away team code for display
  final String? awayTeamCode;

  /// Optional: Home team name
  final String? homeTeamName;

  /// Optional: Away team name
  final String? awayTeamName;

  /// Optional: Venue name
  final String? venueName;

  const MatchReminder({
    required this.reminderId,
    required this.userId,
    required this.matchId,
    required this.matchName,
    required this.matchDateTimeUtc,
    required this.reminderDateTimeUtc,
    required this.timing,
    this.isEnabled = true,
    this.isSent = false,
    required this.createdAt,
    this.homeTeamCode,
    this.awayTeamCode,
    this.homeTeamName,
    this.awayTeamName,
    this.venueName,
  });

  @override
  List<Object?> get props => [
        reminderId,
        userId,
        matchId,
        matchDateTimeUtc,
        timing,
        isEnabled,
        isSent,
      ];

  /// Create a new reminder for a match
  factory MatchReminder.create({
    required String userId,
    required String matchId,
    required String matchName,
    required DateTime matchDateTimeUtc,
    ReminderTiming timing = ReminderTiming.thirtyMinutes,
    String? homeTeamCode,
    String? awayTeamCode,
    String? homeTeamName,
    String? awayTeamName,
    String? venueName,
  }) {
    final reminderDateTime = matchDateTimeUtc.subtract(
      Duration(minutes: timing.minutes),
    );

    return MatchReminder(
      reminderId: 'reminder_${userId}_${matchId}_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      matchId: matchId,
      matchName: matchName,
      matchDateTimeUtc: matchDateTimeUtc,
      reminderDateTimeUtc: reminderDateTime,
      timing: timing,
      createdAt: DateTime.now(),
      homeTeamCode: homeTeamCode,
      awayTeamCode: awayTeamCode,
      homeTeamName: homeTeamName,
      awayTeamName: awayTeamName,
      venueName: venueName,
    );
  }

  /// Create from Firestore document
  factory MatchReminder.fromFirestore(Map<String, dynamic> data, String docId) {
    return MatchReminder(
      reminderId: docId,
      userId: data['userId'] as String? ?? '',
      matchId: data['matchId'] as String? ?? '',
      matchName: data['matchName'] as String? ?? '',
      matchDateTimeUtc: _parseDateTime(data['matchDateTimeUtc']) ?? DateTime.now(),
      reminderDateTimeUtc: _parseDateTime(data['reminderDateTimeUtc']) ?? DateTime.now(),
      timing: ReminderTiming.fromMinutes(data['timingMinutes'] as int? ?? 30),
      isEnabled: data['isEnabled'] as bool? ?? true,
      isSent: data['isSent'] as bool? ?? false,
      createdAt: _parseDateTime(data['createdAt']) ?? DateTime.now(),
      homeTeamCode: data['homeTeamCode'] as String?,
      awayTeamCode: data['awayTeamCode'] as String?,
      homeTeamName: data['homeTeamName'] as String?,
      awayTeamName: data['awayTeamName'] as String?,
      venueName: data['venueName'] as String?,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'matchId': matchId,
      'matchName': matchName,
      'matchDateTimeUtc': Timestamp.fromDate(matchDateTimeUtc),
      'reminderDateTimeUtc': Timestamp.fromDate(reminderDateTimeUtc),
      'timingMinutes': timing.minutes,
      'isEnabled': isEnabled,
      'isSent': isSent,
      'createdAt': Timestamp.fromDate(createdAt),
      'homeTeamCode': homeTeamCode,
      'awayTeamCode': awayTeamCode,
      'homeTeamName': homeTeamName,
      'awayTeamName': awayTeamName,
      'venueName': venueName,
    };
  }

  /// Copy with updated fields
  MatchReminder copyWith({
    String? reminderId,
    String? userId,
    String? matchId,
    String? matchName,
    DateTime? matchDateTimeUtc,
    DateTime? reminderDateTimeUtc,
    ReminderTiming? timing,
    bool? isEnabled,
    bool? isSent,
    DateTime? createdAt,
    String? homeTeamCode,
    String? awayTeamCode,
    String? homeTeamName,
    String? awayTeamName,
    String? venueName,
  }) {
    // If timing changes, recalculate reminder time
    final newTiming = timing ?? this.timing;
    final newMatchDateTime = matchDateTimeUtc ?? this.matchDateTimeUtc;
    final newReminderDateTime = timing != null || matchDateTimeUtc != null
        ? newMatchDateTime.subtract(Duration(minutes: newTiming.minutes))
        : (reminderDateTimeUtc ?? this.reminderDateTimeUtc);

    return MatchReminder(
      reminderId: reminderId ?? this.reminderId,
      userId: userId ?? this.userId,
      matchId: matchId ?? this.matchId,
      matchName: matchName ?? this.matchName,
      matchDateTimeUtc: newMatchDateTime,
      reminderDateTimeUtc: newReminderDateTime,
      timing: newTiming,
      isEnabled: isEnabled ?? this.isEnabled,
      isSent: isSent ?? this.isSent,
      createdAt: createdAt ?? this.createdAt,
      homeTeamCode: homeTeamCode ?? this.homeTeamCode,
      awayTeamCode: awayTeamCode ?? this.awayTeamCode,
      homeTeamName: homeTeamName ?? this.homeTeamName,
      awayTeamName: awayTeamName ?? this.awayTeamName,
      venueName: venueName ?? this.venueName,
    );
  }

  /// Check if reminder is due (should be sent now)
  bool get isDue {
    if (isSent || !isEnabled) return false;
    final now = DateTime.now().toUtc();
    return now.isAfter(reminderDateTimeUtc) && now.isBefore(matchDateTimeUtc);
  }

  /// Check if the match has already started
  bool get matchStarted {
    return DateTime.now().toUtc().isAfter(matchDateTimeUtc);
  }

  /// Time until reminder fires
  Duration get timeUntilReminder {
    return reminderDateTimeUtc.difference(DateTime.now().toUtc());
  }

  /// Time until match starts
  Duration get timeUntilMatch {
    return matchDateTimeUtc.difference(DateTime.now().toUtc());
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }

  @override
  String toString() => 'MatchReminder($matchName, ${timing.displayName} before)';
}

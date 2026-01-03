import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'world_cup_venue.dart';

/// Match stage in the World Cup tournament
enum MatchStage {
  groupStage,
  roundOf32,
  roundOf16,
  quarterFinal,
  semiFinal,
  thirdPlace,
  final_,
}

/// Extension for MatchStage display names
extension MatchStageExtension on MatchStage {
  String get displayName {
    switch (this) {
      case MatchStage.groupStage:
        return 'Group Stage';
      case MatchStage.roundOf32:
        return 'Round of 32';
      case MatchStage.roundOf16:
        return 'Round of 16';
      case MatchStage.quarterFinal:
        return 'Quarter-Final';
      case MatchStage.semiFinal:
        return 'Semi-Final';
      case MatchStage.thirdPlace:
        return 'Third Place Play-off';
      case MatchStage.final_:
        return 'Final';
    }
  }

  String get shortName {
    switch (this) {
      case MatchStage.groupStage:
        return 'Group';
      case MatchStage.roundOf32:
        return 'R32';
      case MatchStage.roundOf16:
        return 'R16';
      case MatchStage.quarterFinal:
        return 'QF';
      case MatchStage.semiFinal:
        return 'SF';
      case MatchStage.thirdPlace:
        return '3rd';
      case MatchStage.final_:
        return 'Final';
    }
  }

  bool get isKnockout => this != MatchStage.groupStage;
}

/// Match status enum
enum MatchStatus {
  scheduled,
  inProgress,
  halfTime,
  extraTime,
  penalties,
  completed,
  postponed,
  cancelled,
}

/// Extension for MatchStatus display names
extension MatchStatusExtension on MatchStatus {
  String get displayName {
    switch (this) {
      case MatchStatus.scheduled:
        return 'Scheduled';
      case MatchStatus.inProgress:
        return 'Live';
      case MatchStatus.halfTime:
        return 'Half Time';
      case MatchStatus.extraTime:
        return 'Extra Time';
      case MatchStatus.penalties:
        return 'Penalties';
      case MatchStatus.completed:
        return 'Full Time';
      case MatchStatus.postponed:
        return 'Postponed';
      case MatchStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool get isLive => this == MatchStatus.inProgress ||
                      this == MatchStatus.halfTime ||
                      this == MatchStatus.extraTime ||
                      this == MatchStatus.penalties;
}

/// WorldCupMatch entity representing a FIFA World Cup 2026 match
class WorldCupMatch extends Equatable {
  /// Unique match ID
  final String matchId;

  /// Match number in the tournament (1-104)
  final int matchNumber;

  /// Tournament stage
  final MatchStage stage;

  /// Group letter (A-L) for group stage matches, null for knockout
  final String? group;

  /// Match day within group stage (1, 2, or 3)
  final int? groupMatchDay;

  // Team information - using FIFA codes and names
  // For knockout matches before teams are determined, these may be placeholders

  /// Home/Team 1 FIFA code
  final String? homeTeamCode;

  /// Home/Team 1 name
  final String homeTeamName;

  /// Home/Team 1 flag URL
  final String? homeTeamFlagUrl;

  /// Away/Team 2 FIFA code
  final String? awayTeamCode;

  /// Away/Team 2 name
  final String awayTeamName;

  /// Away/Team 2 flag URL
  final String? awayTeamFlagUrl;

  /// Placeholder for undetermined team (e.g., "Winner Group A")
  final String? homeTeamPlaceholder;

  /// Placeholder for undetermined team (e.g., "Runner-up Group B")
  final String? awayTeamPlaceholder;

  // Match timing

  /// Match date and time (local venue time)
  final DateTime? dateTime;

  /// Match date and time in UTC
  final DateTime? dateTimeUtc;

  /// Venue information
  final WorldCupVenue? venue;

  /// Venue ID reference
  final String? venueId;

  /// TV broadcast channel(s)
  final List<String> broadcastChannels;

  // Match status and scores

  /// Current match status
  final MatchStatus status;

  /// Current match minute (e.g., 45, 90, 105 for extra time)
  final int? minute;

  /// Additional time in current half
  final int? addedTime;

  /// Home team score (regular time)
  final int? homeScore;

  /// Away team score (regular time)
  final int? awayScore;

  /// Home team score at half time
  final int? homeHalfTimeScore;

  /// Away team score at half time
  final int? awayHalfTimeScore;

  /// Home team extra time score (if applicable)
  final int? homeExtraTimeScore;

  /// Away team extra time score (if applicable)
  final int? awayExtraTimeScore;

  /// Home team penalty score (if applicable)
  final int? homePenaltyScore;

  /// Away team penalty score (if applicable)
  final int? awayPenaltyScore;

  /// Winner team code (after match is completed)
  final String? winnerTeamCode;

  // Match events

  /// List of goal scorers with minute (e.g., ["Mbappe 23'", "Kane 67'"])
  final List<String> homeGoalScorers;

  /// List of goal scorers with minute
  final List<String> awayGoalScorers;

  /// Number of yellow cards for home team
  final int? homeYellowCards;

  /// Number of yellow cards for away team
  final int? awayYellowCards;

  /// Number of red cards for home team
  final int? homeRedCards;

  /// Number of red cards for away team
  final int? awayRedCards;

  // VAR decisions

  /// Whether VAR was used in this match
  final bool varUsed;

  /// List of VAR decisions (e.g., ["Goal awarded", "Penalty overturned"])
  final List<String> varDecisions;

  // Social features

  /// Number of user predictions
  final int? userPredictions;

  /// Number of comments
  final int? userComments;

  /// Number of photos shared
  final int? userPhotos;

  /// Average user rating
  final double? userRating;

  // Timestamps

  /// When the data was last updated from API
  final DateTime? updatedAt;

  /// When the data was last synced to Firestore
  final DateTime? syncedAt;

  const WorldCupMatch({
    required this.matchId,
    required this.matchNumber,
    required this.stage,
    this.group,
    this.groupMatchDay,
    this.homeTeamCode,
    required this.homeTeamName,
    this.homeTeamFlagUrl,
    this.awayTeamCode,
    required this.awayTeamName,
    this.awayTeamFlagUrl,
    this.homeTeamPlaceholder,
    this.awayTeamPlaceholder,
    this.dateTime,
    this.dateTimeUtc,
    this.venue,
    this.venueId,
    this.broadcastChannels = const [],
    this.status = MatchStatus.scheduled,
    this.minute,
    this.addedTime,
    this.homeScore,
    this.awayScore,
    this.homeHalfTimeScore,
    this.awayHalfTimeScore,
    this.homeExtraTimeScore,
    this.awayExtraTimeScore,
    this.homePenaltyScore,
    this.awayPenaltyScore,
    this.winnerTeamCode,
    this.homeGoalScorers = const [],
    this.awayGoalScorers = const [],
    this.homeYellowCards,
    this.awayYellowCards,
    this.homeRedCards,
    this.awayRedCards,
    this.varUsed = false,
    this.varDecisions = const [],
    this.userPredictions,
    this.userComments,
    this.userPhotos,
    this.userRating,
    this.updatedAt,
    this.syncedAt,
  });

  @override
  List<Object?> get props => [
    matchId,
    matchNumber,
    stage,
    homeTeamCode,
    awayTeamCode,
    status,
    homeScore,
    awayScore,
  ];

  /// Whether the match is currently live
  bool get isLive => status.isLive;

  /// Whether teams are determined for this match
  bool get teamsConfirmed => homeTeamCode != null && awayTeamCode != null;

  // Convenience getters for widgets
  /// Home team flag URL (alias for homeTeamFlagUrl)
  String? get homeFlagUrl => homeTeamFlagUrl;

  /// Away team flag URL (alias for awayTeamFlagUrl)
  String? get awayFlagUrl => awayTeamFlagUrl;

  /// Stage display name
  String get stageDisplayName => stage.displayName;

  /// Venue name (from embedded venue)
  String? get venueName => venue?.name;

  /// Venue city (from embedded venue)
  String? get venueCity => venue?.city;

  /// Whether the match went to extra time
  bool get hasExtraTime => homeExtraTimeScore != null || awayExtraTimeScore != null;

  /// Whether the match went to penalties
  bool get hasPenalties => homePenaltyScore != null || awayPenaltyScore != null;

  /// Get total home score (including extra time, not penalties)
  int? get homeTotalScore {
    if (homeScore == null) return null;
    return homeScore! + (homeExtraTimeScore ?? 0);
  }

  /// Get total away score (including extra time, not penalties)
  int? get awayTotalScore {
    if (awayScore == null) return null;
    return awayScore! + (awayExtraTimeScore ?? 0);
  }

  /// Get display score string (e.g., "2-1", "2-2 (4-3 pen)")
  String get scoreDisplay {
    if (homeScore == null || awayScore == null) return '-';

    String score = '$homeScore-$awayScore';

    if (hasExtraTime) {
      final totalHome = homeTotalScore ?? homeScore;
      final totalAway = awayTotalScore ?? awayScore;
      score = '$totalHome-$totalAway';

      if (stage.isKnockout && totalHome == totalAway) {
        score += ' AET';
      }
    }

    if (hasPenalties) {
      score += ' ($homePenaltyScore-$awayPenaltyScore pen)';
    }

    return score;
  }

  /// Get match time display (e.g., "45+2'", "90'", "HT")
  String get timeDisplay {
    switch (status) {
      case MatchStatus.scheduled:
        return dateTime != null
            ? '${dateTime!.hour.toString().padLeft(2, '0')}:${dateTime!.minute.toString().padLeft(2, '0')}'
            : 'TBD';
      case MatchStatus.halfTime:
        return 'HT';
      case MatchStatus.completed:
        return 'FT';
      case MatchStatus.extraTime:
        if (minute != null) {
          final display = minute! > 90 ? minute : minute! + 90;
          return addedTime != null ? "$display+$addedTime'" : "$display'";
        }
        return 'ET';
      case MatchStatus.penalties:
        return 'PEN';
      default:
        if (minute != null) {
          return addedTime != null ? "$minute+$addedTime'" : "$minute'";
        }
        return 'LIVE';
    }
  }

  /// Factory to create from Firestore document
  factory WorldCupMatch.fromFirestore(Map<String, dynamic> data, String docId) {
    return WorldCupMatch(
      matchId: docId,
      matchNumber: data['matchNumber'] as int? ?? 0,
      stage: _parseMatchStage(data['stage'] as String?),
      group: data['group'] as String?,
      groupMatchDay: data['groupMatchDay'] as int?,
      homeTeamCode: data['homeTeamCode'] as String?,
      homeTeamName: data['homeTeamName'] as String? ?? 'TBD',
      homeTeamFlagUrl: data['homeTeamFlagUrl'] as String?,
      awayTeamCode: data['awayTeamCode'] as String?,
      awayTeamName: data['awayTeamName'] as String? ?? 'TBD',
      awayTeamFlagUrl: data['awayTeamFlagUrl'] as String?,
      homeTeamPlaceholder: data['homeTeamPlaceholder'] as String?,
      awayTeamPlaceholder: data['awayTeamPlaceholder'] as String?,
      dateTime: _parseDateTime(data['dateTime']),
      dateTimeUtc: _parseDateTime(data['dateTimeUtc']),
      venueId: data['venueId'] as String?,
      venue: data['venue'] != null
          ? WorldCupVenue.fromMap(data['venue'] as Map<String, dynamic>)
          : (data['venueName'] != null
              ? WorldCupVenue(
                  venueId: 'unknown',
                  name: data['venueName'] as String,
                  city: data['venueCity'] as String? ?? '',
                  country: HostCountry.usa,
                  capacity: 0,
                  yearOpened: 0,
                  latitude: 0,
                  longitude: 0,
                  timeZone: '',
                  utcOffset: 0,
                  homeTeams: const [],
                  sports: const [],
                  hasRoof: false,
                )
              : null),
      broadcastChannels: (data['broadcastChannels'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      status: _parseMatchStatus(data['status'] as String?),
      minute: data['minute'] as int?,
      addedTime: data['addedTime'] as int?,
      homeScore: data['homeScore'] as int?,
      awayScore: data['awayScore'] as int?,
      homeHalfTimeScore: data['homeHalfTimeScore'] as int?,
      awayHalfTimeScore: data['awayHalfTimeScore'] as int?,
      homeExtraTimeScore: data['homeExtraTimeScore'] as int?,
      awayExtraTimeScore: data['awayExtraTimeScore'] as int?,
      homePenaltyScore: data['homePenaltyScore'] as int?,
      awayPenaltyScore: data['awayPenaltyScore'] as int?,
      winnerTeamCode: data['winnerTeamCode'] as String?,
      homeGoalScorers: (data['homeGoalScorers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      awayGoalScorers: (data['awayGoalScorers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      homeYellowCards: data['homeYellowCards'] as int?,
      awayYellowCards: data['awayYellowCards'] as int?,
      homeRedCards: data['homeRedCards'] as int?,
      awayRedCards: data['awayRedCards'] as int?,
      varUsed: data['varUsed'] as bool? ?? false,
      varDecisions: (data['varDecisions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      userPredictions: data['userPredictions'] as int?,
      userComments: data['userComments'] as int?,
      userPhotos: data['userPhotos'] as int?,
      userRating: (data['userRating'] as num?)?.toDouble(),
      updatedAt: _parseDateTime(data['updatedAt']),
      syncedAt: _parseDateTime(data['syncedAt']),
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'matchNumber': matchNumber,
      'stage': stage.name,
      'group': group,
      'groupMatchDay': groupMatchDay,
      'homeTeamCode': homeTeamCode,
      'homeTeamName': homeTeamName,
      'homeTeamFlagUrl': homeTeamFlagUrl,
      'awayTeamCode': awayTeamCode,
      'awayTeamName': awayTeamName,
      'awayTeamFlagUrl': awayTeamFlagUrl,
      'homeTeamPlaceholder': homeTeamPlaceholder,
      'awayTeamPlaceholder': awayTeamPlaceholder,
      'dateTime': dateTime != null ? Timestamp.fromDate(dateTime!) : null,
      'dateTimeUtc': dateTimeUtc != null ? Timestamp.fromDate(dateTimeUtc!) : null,
      'venueId': venueId,
      'venue': venue?.toMap(),
      'broadcastChannels': broadcastChannels,
      'status': status.name,
      'minute': minute,
      'addedTime': addedTime,
      'homeScore': homeScore,
      'awayScore': awayScore,
      'homeHalfTimeScore': homeHalfTimeScore,
      'awayHalfTimeScore': awayHalfTimeScore,
      'homeExtraTimeScore': homeExtraTimeScore,
      'awayExtraTimeScore': awayExtraTimeScore,
      'homePenaltyScore': homePenaltyScore,
      'awayPenaltyScore': awayPenaltyScore,
      'winnerTeamCode': winnerTeamCode,
      'homeGoalScorers': homeGoalScorers,
      'awayGoalScorers': awayGoalScorers,
      'homeYellowCards': homeYellowCards,
      'awayYellowCards': awayYellowCards,
      'homeRedCards': homeRedCards,
      'awayRedCards': awayRedCards,
      'varUsed': varUsed,
      'varDecisions': varDecisions,
      'userPredictions': userPredictions,
      'userComments': userComments,
      'userPhotos': userPhotos,
      'userRating': userRating,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'syncedAt': Timestamp.fromDate(DateTime.now()),
    };
  }

  /// Convert to Map for caching
  Map<String, dynamic> toMap() {
    return {
      'matchId': matchId,
      'matchNumber': matchNumber,
      'stage': stage.name,
      'group': group,
      'groupMatchDay': groupMatchDay,
      'homeTeamCode': homeTeamCode,
      'homeTeamName': homeTeamName,
      'homeTeamFlagUrl': homeTeamFlagUrl,
      'awayTeamCode': awayTeamCode,
      'awayTeamName': awayTeamName,
      'awayTeamFlagUrl': awayTeamFlagUrl,
      'homeTeamPlaceholder': homeTeamPlaceholder,
      'awayTeamPlaceholder': awayTeamPlaceholder,
      'dateTime': dateTime?.toIso8601String(),
      'dateTimeUtc': dateTimeUtc?.toIso8601String(),
      'venueId': venueId,
      'venue': venue?.toMap(),
      'broadcastChannels': broadcastChannels,
      'status': status.name,
      'minute': minute,
      'addedTime': addedTime,
      'homeScore': homeScore,
      'awayScore': awayScore,
      'homeHalfTimeScore': homeHalfTimeScore,
      'awayHalfTimeScore': awayHalfTimeScore,
      'homeExtraTimeScore': homeExtraTimeScore,
      'awayExtraTimeScore': awayExtraTimeScore,
      'homePenaltyScore': homePenaltyScore,
      'awayPenaltyScore': awayPenaltyScore,
      'winnerTeamCode': winnerTeamCode,
      'homeGoalScorers': homeGoalScorers,
      'awayGoalScorers': awayGoalScorers,
      'homeYellowCards': homeYellowCards,
      'awayYellowCards': awayYellowCards,
      'homeRedCards': homeRedCards,
      'awayRedCards': awayRedCards,
      'varUsed': varUsed,
      'varDecisions': varDecisions,
      'userPredictions': userPredictions,
      'userComments': userComments,
      'userPhotos': userPhotos,
      'userRating': userRating,
      'updatedAt': updatedAt?.toIso8601String(),
      'syncedAt': syncedAt?.toIso8601String(),
    };
  }

  /// Factory to create from cached Map
  factory WorldCupMatch.fromMap(Map<String, dynamic> map) {
    return WorldCupMatch(
      matchId: map['matchId'] as String? ?? '',
      matchNumber: map['matchNumber'] as int? ?? 0,
      stage: _parseMatchStage(map['stage'] as String?),
      group: map['group'] as String?,
      groupMatchDay: map['groupMatchDay'] as int?,
      homeTeamCode: map['homeTeamCode'] as String?,
      homeTeamName: map['homeTeamName'] as String? ?? 'TBD',
      homeTeamFlagUrl: map['homeTeamFlagUrl'] as String?,
      awayTeamCode: map['awayTeamCode'] as String?,
      awayTeamName: map['awayTeamName'] as String? ?? 'TBD',
      awayTeamFlagUrl: map['awayTeamFlagUrl'] as String?,
      homeTeamPlaceholder: map['homeTeamPlaceholder'] as String?,
      awayTeamPlaceholder: map['awayTeamPlaceholder'] as String?,
      dateTime: map['dateTime'] != null
          ? DateTime.tryParse(map['dateTime'] as String)
          : null,
      dateTimeUtc: map['dateTimeUtc'] != null
          ? DateTime.tryParse(map['dateTimeUtc'] as String)
          : null,
      venueId: map['venueId'] as String?,
      venue: map['venue'] != null
          ? WorldCupVenue.fromMap(map['venue'] as Map<String, dynamic>)
          : null,
      broadcastChannels: (map['broadcastChannels'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      status: _parseMatchStatus(map['status'] as String?),
      minute: map['minute'] as int?,
      addedTime: map['addedTime'] as int?,
      homeScore: map['homeScore'] as int?,
      awayScore: map['awayScore'] as int?,
      homeHalfTimeScore: map['homeHalfTimeScore'] as int?,
      awayHalfTimeScore: map['awayHalfTimeScore'] as int?,
      homeExtraTimeScore: map['homeExtraTimeScore'] as int?,
      awayExtraTimeScore: map['awayExtraTimeScore'] as int?,
      homePenaltyScore: map['homePenaltyScore'] as int?,
      awayPenaltyScore: map['awayPenaltyScore'] as int?,
      winnerTeamCode: map['winnerTeamCode'] as String?,
      homeGoalScorers: (map['homeGoalScorers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      awayGoalScorers: (map['awayGoalScorers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      homeYellowCards: map['homeYellowCards'] as int?,
      awayYellowCards: map['awayYellowCards'] as int?,
      homeRedCards: map['homeRedCards'] as int?,
      awayRedCards: map['awayRedCards'] as int?,
      varUsed: map['varUsed'] as bool? ?? false,
      varDecisions: (map['varDecisions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      userPredictions: map['userPredictions'] as int?,
      userComments: map['userComments'] as int?,
      userPhotos: map['userPhotos'] as int?,
      userRating: (map['userRating'] as num?)?.toDouble(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'] as String)
          : null,
      syncedAt: map['syncedAt'] != null
          ? DateTime.tryParse(map['syncedAt'] as String)
          : null,
    );
  }

  /// Create a copy with updated fields
  WorldCupMatch copyWith({
    String? matchId,
    int? matchNumber,
    MatchStage? stage,
    String? group,
    int? groupMatchDay,
    String? homeTeamCode,
    String? homeTeamName,
    String? homeTeamFlagUrl,
    String? awayTeamCode,
    String? awayTeamName,
    String? awayTeamFlagUrl,
    String? homeTeamPlaceholder,
    String? awayTeamPlaceholder,
    DateTime? dateTime,
    DateTime? dateTimeUtc,
    WorldCupVenue? venue,
    String? venueId,
    List<String>? broadcastChannels,
    MatchStatus? status,
    int? minute,
    int? addedTime,
    int? homeScore,
    int? awayScore,
    int? homeHalfTimeScore,
    int? awayHalfTimeScore,
    int? homeExtraTimeScore,
    int? awayExtraTimeScore,
    int? homePenaltyScore,
    int? awayPenaltyScore,
    String? winnerTeamCode,
    List<String>? homeGoalScorers,
    List<String>? awayGoalScorers,
    int? homeYellowCards,
    int? awayYellowCards,
    int? homeRedCards,
    int? awayRedCards,
    bool? varUsed,
    List<String>? varDecisions,
    int? userPredictions,
    int? userComments,
    int? userPhotos,
    double? userRating,
    DateTime? updatedAt,
    DateTime? syncedAt,
  }) {
    return WorldCupMatch(
      matchId: matchId ?? this.matchId,
      matchNumber: matchNumber ?? this.matchNumber,
      stage: stage ?? this.stage,
      group: group ?? this.group,
      groupMatchDay: groupMatchDay ?? this.groupMatchDay,
      homeTeamCode: homeTeamCode ?? this.homeTeamCode,
      homeTeamName: homeTeamName ?? this.homeTeamName,
      homeTeamFlagUrl: homeTeamFlagUrl ?? this.homeTeamFlagUrl,
      awayTeamCode: awayTeamCode ?? this.awayTeamCode,
      awayTeamName: awayTeamName ?? this.awayTeamName,
      awayTeamFlagUrl: awayTeamFlagUrl ?? this.awayTeamFlagUrl,
      homeTeamPlaceholder: homeTeamPlaceholder ?? this.homeTeamPlaceholder,
      awayTeamPlaceholder: awayTeamPlaceholder ?? this.awayTeamPlaceholder,
      dateTime: dateTime ?? this.dateTime,
      dateTimeUtc: dateTimeUtc ?? this.dateTimeUtc,
      venue: venue ?? this.venue,
      venueId: venueId ?? this.venueId,
      broadcastChannels: broadcastChannels ?? this.broadcastChannels,
      status: status ?? this.status,
      minute: minute ?? this.minute,
      addedTime: addedTime ?? this.addedTime,
      homeScore: homeScore ?? this.homeScore,
      awayScore: awayScore ?? this.awayScore,
      homeHalfTimeScore: homeHalfTimeScore ?? this.homeHalfTimeScore,
      awayHalfTimeScore: awayHalfTimeScore ?? this.awayHalfTimeScore,
      homeExtraTimeScore: homeExtraTimeScore ?? this.homeExtraTimeScore,
      awayExtraTimeScore: awayExtraTimeScore ?? this.awayExtraTimeScore,
      homePenaltyScore: homePenaltyScore ?? this.homePenaltyScore,
      awayPenaltyScore: awayPenaltyScore ?? this.awayPenaltyScore,
      winnerTeamCode: winnerTeamCode ?? this.winnerTeamCode,
      homeGoalScorers: homeGoalScorers ?? this.homeGoalScorers,
      awayGoalScorers: awayGoalScorers ?? this.awayGoalScorers,
      homeYellowCards: homeYellowCards ?? this.homeYellowCards,
      awayYellowCards: awayYellowCards ?? this.awayYellowCards,
      homeRedCards: homeRedCards ?? this.homeRedCards,
      awayRedCards: awayRedCards ?? this.awayRedCards,
      varUsed: varUsed ?? this.varUsed,
      varDecisions: varDecisions ?? this.varDecisions,
      userPredictions: userPredictions ?? this.userPredictions,
      userComments: userComments ?? this.userComments,
      userPhotos: userPhotos ?? this.userPhotos,
      userRating: userRating ?? this.userRating,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  // Helper methods

  static MatchStage _parseMatchStage(String? value) {
    if (value == null) return MatchStage.groupStage;

    switch (value.toLowerCase()) {
      case 'groupstage':
      case 'group_stage':
      case 'group':
        return MatchStage.groupStage;
      case 'roundof32':
      case 'round_of_32':
      case 'r32':
        return MatchStage.roundOf32;
      case 'roundof16':
      case 'round_of_16':
      case 'r16':
        return MatchStage.roundOf16;
      case 'quarterfinal':
      case 'quarter_final':
      case 'qf':
        return MatchStage.quarterFinal;
      case 'semifinal':
      case 'semi_final':
      case 'sf':
        return MatchStage.semiFinal;
      case 'thirdplace':
      case 'third_place':
      case '3rd':
        return MatchStage.thirdPlace;
      case 'final_':
      case 'final':
        return MatchStage.final_;
      default:
        return MatchStage.groupStage;
    }
  }

  static MatchStatus _parseMatchStatus(String? value) {
    if (value == null) return MatchStatus.scheduled;

    switch (value.toLowerCase()) {
      case 'scheduled':
        return MatchStatus.scheduled;
      case 'inprogress':
      case 'in_progress':
      case 'live':
        return MatchStatus.inProgress;
      case 'halftime':
      case 'half_time':
      case 'ht':
        return MatchStatus.halfTime;
      case 'extratime':
      case 'extra_time':
      case 'et':
        return MatchStatus.extraTime;
      case 'penalties':
      case 'pen':
        return MatchStatus.penalties;
      case 'completed':
      case 'finished':
      case 'ft':
        return MatchStatus.completed;
      case 'postponed':
        return MatchStatus.postponed;
      case 'cancelled':
      case 'canceled':
        return MatchStatus.cancelled;
      default:
        return MatchStatus.scheduled;
    }
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }

  @override
  String toString() => '$homeTeamName vs $awayTeamName (Match $matchNumber)';
}

/// Time filter enum for filtering matches
enum MatchTimeFilter {
  today,
  thisWeek,
  groupStage,
  knockout,
  all,
}

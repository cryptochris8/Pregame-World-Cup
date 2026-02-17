/// Enums and their extensions for World Cup match entities.
///
/// Includes [MatchStage], [MatchStatus], and [MatchTimeFilter]
/// along with display name extensions.
library;

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

/// Time filter enum for filtering matches
enum MatchTimeFilter {
  today,
  thisWeek,
  groupStage,
  knockout,
  all,
}

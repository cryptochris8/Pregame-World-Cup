/// Extensions on [WorldCupMatch] for display formatting, score computation,
/// and serialization parsing helpers.
library;

import 'package:cloud_firestore/cloud_firestore.dart';

import 'world_cup_match.dart';

/// Display and computed property extensions for [WorldCupMatch].
extension WorldCupMatchDisplayExtension on WorldCupMatch {
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
}

/// Parsing helper methods used during deserialization.
///
/// These are exposed as static methods so they can be called from
/// [WorldCupMatch.fromFirestore] and [WorldCupMatch.fromMap].
class WorldCupMatchParsers {
  WorldCupMatchParsers._();

  /// Parse a string value into a [MatchStage].
  static MatchStage parseMatchStage(String? value) {
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

  /// Parse a string value into a [MatchStatus].
  static MatchStatus parseMatchStatus(String? value) {
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

  /// Parse a dynamic value into a [DateTime].
  ///
  /// Supports [Timestamp], ISO-8601 [String], and epoch millisecond [int].
  static DateTime? parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }
}

/// Data models for tournament simulation results.
///
/// This file contains all the data classes used to represent the results
/// of Monte Carlo tournament simulations, including overall tournament results,
/// per-team statistics, group standings, and third-place entries.

/// Result of a single tournament simulation.
///
/// Contains all data from one complete tournament run, including:
/// - Winner and runner-up
/// - Semifinalists
/// - Round of 16 teams
/// - Group stage standings
/// - Third-place qualifiers
class TournamentSimulationResult {
  /// The team code of the tournament winner.
  final String winner;

  /// The team code of the runner-up (finalist who lost the final).
  final String runnerUp;

  /// List of team codes that reached the semifinals (4 teams).
  final List<String> semis;

  /// List of team codes that reached the round of 16 (16 teams).
  final List<String> r16;

  /// Map of group letter to list of team codes in finishing order.
  ///
  /// For each group (A-H), contains the team codes in their final
  /// group stage ranking (1st through 4th place).
  final Map<String, List<String>> groupStandings;

  /// List of third-place group finishers with their qualification status.
  ///
  /// Contains all 8 third-place teams sorted by their group stage performance.
  /// The top 4 advance to the round of 16, the bottom 4 are eliminated.
  final List<ThirdPlaceEntry> thirdPlaceRankings;

  const TournamentSimulationResult({
    required this.winner,
    required this.runnerUp,
    required this.semis,
    required this.r16,
    required this.groupStandings,
    required this.thirdPlaceRankings,
  });

  @override
  String toString() => 'TournamentSimulationResult('
      'winner: $winner, '
      'runnerUp: $runnerUp, '
      'semis: $semis, '
      'r16: $r16, '
      'groupStandings: $groupStandings, '
      'thirdPlaceRankings: $thirdPlaceRankings)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TournamentSimulationResult &&
          runtimeType == other.runtimeType &&
          winner == other.winner &&
          runnerUp == other.runnerUp &&
          _listEquals(semis, other.semis) &&
          _listEquals(r16, other.r16) &&
          _mapEquals(groupStandings, other.groupStandings) &&
          _listEquals(thirdPlaceRankings, other.thirdPlaceRankings);

  @override
  int get hashCode =>
      winner.hashCode ^
      runnerUp.hashCode ^
      semis.hashCode ^
      r16.hashCode ^
      groupStandings.hashCode ^
      thirdPlaceRankings.hashCode;

  static bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static bool _mapEquals<K, V>(Map<K, V>? a, Map<K, V>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}

/// Aggregated simulation results for a single team across multiple runs.
///
/// Tracks how often a team achieved each tournament milestone:
/// - Won the tournament
/// - Reached the final
/// - Reached semifinals
/// - Reached round of 16
/// - Qualified from group stage
/// - Finished in each group position
class TeamSimulationResult {
  /// Team code (e.g., "BRA", "GER").
  final String teamCode;

  /// Number of times this team won the tournament.
  final int wins;

  /// Number of times this team reached the final (including wins).
  final int finals;

  /// Number of times this team reached the semifinals (including finals).
  final int semifinals;

  /// Number of times this team reached the round of 16.
  final int roundOf16;

  /// Number of times this team qualified from the group stage.
  ///
  /// Includes all teams that finished 1st, 2nd, or qualified as a
  /// third-place team.
  final int groupQualifications;

  /// Distribution of group stage finishing positions.
  ///
  /// Map from position (1-4) to count of how many times the team
  /// finished in that position. Only includes simulations where the
  /// team was in the group stage.
  final Map<int, int> groupPositionDistribution;

  const TeamSimulationResult({
    required this.teamCode,
    required this.wins,
    required this.finals,
    required this.semifinals,
    required this.roundOf16,
    required this.groupQualifications,
    required this.groupPositionDistribution,
  });

  @override
  String toString() => 'TeamSimulationResult('
      'teamCode: $teamCode, '
      'wins: $wins, '
      'finals: $finals, '
      'semifinals: $semifinals, '
      'roundOf16: $roundOf16, '
      'groupQualifications: $groupQualifications, '
      'groupPositionDistribution: $groupPositionDistribution)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeamSimulationResult &&
          runtimeType == other.runtimeType &&
          teamCode == other.teamCode &&
          wins == other.wins &&
          finals == other.finals &&
          semifinals == other.semifinals &&
          roundOf16 == other.roundOf16 &&
          groupQualifications == other.groupQualifications &&
          _mapEquals(groupPositionDistribution, other.groupPositionDistribution);

  @override
  int get hashCode =>
      teamCode.hashCode ^
      wins.hashCode ^
      finals.hashCode ^
      semifinals.hashCode ^
      roundOf16.hashCode ^
      groupQualifications.hashCode ^
      groupPositionDistribution.hashCode;

  static bool _mapEquals<K, V>(Map<K, V>? a, Map<K, V>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}

/// Represents a team's final standing in their group.
///
/// Used internally during group stage simulation to track team performance
/// and determine qualification for the knockout rounds.
class GroupStanding {
  /// The team code.
  final String team;

  /// Points earned (3 for win, 1 for draw, 0 for loss).
  final int points;

  /// Goal difference (goals scored - goals conceded).
  final int goalDiff;

  /// Total goals scored.
  final int goalsScored;

  const GroupStanding({
    required this.team,
    required this.points,
    required this.goalDiff,
    required this.goalsScored,
  });

  @override
  String toString() => 'GroupStanding('
      'team: $team, '
      'points: $points, '
      'goalDiff: $goalDiff, '
      'goalsScored: $goalsScored)';
}

/// Represents a third-place team's entry in the third-place ranking table.
///
/// In the World Cup format, the 4 best third-place teams from the
/// 8 groups advance to the round of 16. This class tracks the statistics
/// used to rank third-place teams against each other.
class ThirdPlaceEntry {
  /// The group letter (A-H) this team finished third in.
  final String group;

  /// The team code.
  final String team;

  /// Points earned in group stage.
  final int points;

  /// Goal difference in group stage.
  final int goalDiff;

  /// Goals scored in group stage.
  final int goalsScored;

  const ThirdPlaceEntry({
    required this.group,
    required this.team,
    required this.points,
    required this.goalDiff,
    required this.goalsScored,
  });

  @override
  String toString() => 'ThirdPlaceEntry('
      'group: $group, '
      'team: $team, '
      'points: $points, '
      'goalDiff: $goalDiff, '
      'goalsScored: $goalsScored)';
}

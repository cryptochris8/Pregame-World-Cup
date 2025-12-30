import 'package:equatable/equatable.dart';

/// Represents a historical match result in a head-to-head record
class HistoricalMatch extends Equatable {
  /// Year the match was played
  final int year;

  /// Tournament name (e.g., "World Cup", "World Cup Qualifier")
  final String tournament;

  /// Stage of the tournament (e.g., "Final", "Group Stage", "Semi-Final")
  final String? stage;

  /// Team 1 score (the first team in the head-to-head pair)
  final int team1Score;

  /// Team 2 score (the second team in the head-to-head pair)
  final int team2Score;

  /// Winner team code (null if draw)
  final String? winnerCode;

  /// Location/venue of the match
  final String? location;

  /// Brief description of the match significance
  final String? description;

  const HistoricalMatch({
    required this.year,
    required this.tournament,
    this.stage,
    required this.team1Score,
    required this.team2Score,
    this.winnerCode,
    this.location,
    this.description,
  });

  @override
  List<Object?> get props => [year, tournament, team1Score, team2Score];

  /// Get score display string (e.g., "2-1")
  String get scoreDisplay => '$team1Score-$team2Score';

  /// Whether this match was a draw
  bool get isDraw => team1Score == team2Score;

  Map<String, dynamic> toMap() {
    return {
      'year': year,
      'tournament': tournament,
      'stage': stage,
      'team1Score': team1Score,
      'team2Score': team2Score,
      'winnerCode': winnerCode,
      'location': location,
      'description': description,
    };
  }

  factory HistoricalMatch.fromMap(Map<String, dynamic> map) {
    return HistoricalMatch(
      year: map['year'] as int,
      tournament: map['tournament'] as String,
      stage: map['stage'] as String?,
      team1Score: map['team1Score'] as int,
      team2Score: map['team2Score'] as int,
      winnerCode: map['winnerCode'] as String?,
      location: map['location'] as String?,
      description: map['description'] as String?,
    );
  }
}

/// Head-to-head record between two national teams
class HeadToHead extends Equatable {
  /// FIFA code of first team (alphabetically first)
  final String team1Code;

  /// FIFA code of second team
  final String team2Code;

  /// Total matches played between these teams
  final int totalMatches;

  /// Number of wins for team 1
  final int team1Wins;

  /// Number of wins for team 2
  final int team2Wins;

  /// Number of draws
  final int draws;

  /// Total goals scored by team 1
  final int team1Goals;

  /// Total goals scored by team 2
  final int team2Goals;

  /// World Cup specific matches played
  final int worldCupMatches;

  /// World Cup wins for team 1
  final int team1WorldCupWins;

  /// World Cup wins for team 2
  final int team2WorldCupWins;

  /// World Cup draws
  final int worldCupDraws;

  /// List of notable historical matches
  final List<HistoricalMatch> notableMatches;

  /// Last match date
  final DateTime? lastMatch;

  /// First meeting date
  final DateTime? firstMeeting;

  const HeadToHead({
    required this.team1Code,
    required this.team2Code,
    required this.totalMatches,
    required this.team1Wins,
    required this.team2Wins,
    required this.draws,
    this.team1Goals = 0,
    this.team2Goals = 0,
    this.worldCupMatches = 0,
    this.team1WorldCupWins = 0,
    this.team2WorldCupWins = 0,
    this.worldCupDraws = 0,
    this.notableMatches = const [],
    this.lastMatch,
    this.firstMeeting,
  });

  @override
  List<Object?> get props => [team1Code, team2Code, totalMatches, team1Wins, team2Wins];

  /// Generate a unique ID for this head-to-head pair
  String get id {
    // Sort codes alphabetically for consistent ID
    final codes = [team1Code, team2Code]..sort();
    return '${codes[0]}_${codes[1]}';
  }

  /// Get the dominant team (team with more wins), null if equal
  String? get dominantTeam {
    if (team1Wins > team2Wins) return team1Code;
    if (team2Wins > team1Wins) return team2Code;
    return null;
  }

  /// Get win percentage for team 1
  double get team1WinPercentage =>
      totalMatches > 0 ? (team1Wins / totalMatches) * 100 : 0;

  /// Get win percentage for team 2
  double get team2WinPercentage =>
      totalMatches > 0 ? (team2Wins / totalMatches) * 100 : 0;

  /// Get draw percentage
  double get drawPercentage =>
      totalMatches > 0 ? (draws / totalMatches) * 100 : 0;

  /// Get summary string (e.g., "Brazil leads 73-36-26")
  String getSummary(String team1Name, String team2Name) {
    if (team1Wins > team2Wins) {
      return '$team1Name leads $team1Wins-$team2Wins-$draws';
    } else if (team2Wins > team1Wins) {
      return '$team2Name leads $team2Wins-$team1Wins-$draws';
    } else {
      return 'Series tied $team1Wins-$team2Wins-$draws';
    }
  }

  /// Get World Cup specific summary
  String getWorldCupSummary(String team1Name, String team2Name) {
    if (worldCupMatches == 0) return 'No World Cup meetings';
    if (team1WorldCupWins > team2WorldCupWins) {
      return '$team1Name leads $team1WorldCupWins-$team2WorldCupWins-$worldCupDraws in World Cups';
    } else if (team2WorldCupWins > team1WorldCupWins) {
      return '$team2Name leads $team2WorldCupWins-$team1WorldCupWins-$worldCupDraws in World Cups';
    } else {
      return 'Tied $team1WorldCupWins-$team2WorldCupWins-$worldCupDraws in World Cups';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'team1Code': team1Code,
      'team2Code': team2Code,
      'totalMatches': totalMatches,
      'team1Wins': team1Wins,
      'team2Wins': team2Wins,
      'draws': draws,
      'team1Goals': team1Goals,
      'team2Goals': team2Goals,
      'worldCupMatches': worldCupMatches,
      'team1WorldCupWins': team1WorldCupWins,
      'team2WorldCupWins': team2WorldCupWins,
      'worldCupDraws': worldCupDraws,
      'notableMatches': notableMatches.map((m) => m.toMap()).toList(),
      'lastMatch': lastMatch?.toIso8601String(),
      'firstMeeting': firstMeeting?.toIso8601String(),
    };
  }

  factory HeadToHead.fromMap(Map<String, dynamic> map) {
    return HeadToHead(
      team1Code: map['team1Code'] as String,
      team2Code: map['team2Code'] as String,
      totalMatches: map['totalMatches'] as int,
      team1Wins: map['team1Wins'] as int,
      team2Wins: map['team2Wins'] as int,
      draws: map['draws'] as int,
      team1Goals: map['team1Goals'] as int? ?? 0,
      team2Goals: map['team2Goals'] as int? ?? 0,
      worldCupMatches: map['worldCupMatches'] as int? ?? 0,
      team1WorldCupWins: map['team1WorldCupWins'] as int? ?? 0,
      team2WorldCupWins: map['team2WorldCupWins'] as int? ?? 0,
      worldCupDraws: map['worldCupDraws'] as int? ?? 0,
      notableMatches: (map['notableMatches'] as List<dynamic>?)
              ?.map((m) => HistoricalMatch.fromMap(m as Map<String, dynamic>))
              .toList() ??
          const [],
      lastMatch: map['lastMatch'] != null
          ? DateTime.tryParse(map['lastMatch'] as String)
          : null,
      firstMeeting: map['firstMeeting'] != null
          ? DateTime.tryParse(map['firstMeeting'] as String)
          : null,
    );
  }
}

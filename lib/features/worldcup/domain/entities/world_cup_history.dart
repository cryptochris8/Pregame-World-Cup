import 'package:equatable/equatable.dart';

/// Represents a historical World Cup tournament
class WorldCupTournament extends Equatable {
  final int year;
  final List<String> hostCountries;
  final List<String> hostCodes;
  final String winner;
  final String winnerCode;
  final String runnerUp;
  final String runnerUpCode;
  final String thirdPlace;
  final String thirdPlaceCode;
  final String fourthPlace;
  final String fourthPlaceCode;
  final int totalTeams;
  final int totalMatches;
  final int totalGoals;
  final String topScorer;
  final String topScorerCountry;
  final int topScorerGoals;
  final String? goldenBall;
  final String? goldenBallCountry;
  final String? bestYoungPlayer;
  final String? bestYoungPlayerCountry;
  final String? goldenGlove;
  final String? goldenGloveCountry;
  final String finalScore;
  final String finalVenue;
  final String finalCity;
  final int finalAttendance;
  final List<String> highlights;

  const WorldCupTournament({
    required this.year,
    required this.hostCountries,
    required this.hostCodes,
    required this.winner,
    required this.winnerCode,
    required this.runnerUp,
    required this.runnerUpCode,
    required this.thirdPlace,
    required this.thirdPlaceCode,
    required this.fourthPlace,
    required this.fourthPlaceCode,
    required this.totalTeams,
    required this.totalMatches,
    required this.totalGoals,
    required this.topScorer,
    required this.topScorerCountry,
    required this.topScorerGoals,
    this.goldenBall,
    this.goldenBallCountry,
    this.bestYoungPlayer,
    this.bestYoungPlayerCountry,
    this.goldenGlove,
    this.goldenGloveCountry,
    required this.finalScore,
    required this.finalVenue,
    required this.finalCity,
    required this.finalAttendance,
    required this.highlights,
  });

  @override
  List<Object?> get props => [year, winner, winnerCode];

  /// Get document ID
  String get id => 'wc_$year';

  /// Get goals per game average
  double get goalsPerGame => totalMatches > 0 ? totalGoals / totalMatches : 0;

  /// Get host display string
  String get hostDisplay => hostCountries.join(', ');

  factory WorldCupTournament.fromFirestore(Map<String, dynamic> data) {
    return WorldCupTournament(
      year: data['year'] as int,
      hostCountries: List<String>.from(data['hostCountries'] ?? []),
      hostCodes: List<String>.from(data['hostCodes'] ?? []),
      winner: data['winner'] as String,
      winnerCode: data['winnerCode'] as String,
      runnerUp: data['runnerUp'] as String,
      runnerUpCode: data['runnerUpCode'] as String,
      thirdPlace: data['thirdPlace'] as String,
      thirdPlaceCode: data['thirdPlaceCode'] as String,
      fourthPlace: data['fourthPlace'] as String,
      fourthPlaceCode: data['fourthPlaceCode'] as String,
      totalTeams: data['totalTeams'] as int,
      totalMatches: data['totalMatches'] as int,
      totalGoals: data['totalGoals'] as int,
      topScorer: data['topScorer'] as String,
      topScorerCountry: data['topScorerCountry'] as String,
      topScorerGoals: data['topScorerGoals'] as int,
      goldenBall: data['goldenBall'] as String?,
      goldenBallCountry: data['goldenBallCountry'] as String?,
      bestYoungPlayer: data['bestYoungPlayer'] as String?,
      bestYoungPlayerCountry: data['bestYoungPlayerCountry'] as String?,
      goldenGlove: data['goldenGlove'] as String?,
      goldenGloveCountry: data['goldenGloveCountry'] as String?,
      finalScore: data['finalScore'] as String,
      finalVenue: data['finalVenue'] as String,
      finalCity: data['finalCity'] as String,
      finalAttendance: data['finalAttendance'] as int,
      highlights: List<String>.from(data['highlights'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'year': year,
      'hostCountries': hostCountries,
      'hostCodes': hostCodes,
      'winner': winner,
      'winnerCode': winnerCode,
      'runnerUp': runnerUp,
      'runnerUpCode': runnerUpCode,
      'thirdPlace': thirdPlace,
      'thirdPlaceCode': thirdPlaceCode,
      'fourthPlace': fourthPlace,
      'fourthPlaceCode': fourthPlaceCode,
      'totalTeams': totalTeams,
      'totalMatches': totalMatches,
      'totalGoals': totalGoals,
      'topScorer': topScorer,
      'topScorerCountry': topScorerCountry,
      'topScorerGoals': topScorerGoals,
      'goldenBall': goldenBall,
      'goldenBallCountry': goldenBallCountry,
      'bestYoungPlayer': bestYoungPlayer,
      'bestYoungPlayerCountry': bestYoungPlayerCountry,
      'goldenGlove': goldenGlove,
      'goldenGloveCountry': goldenGloveCountry,
      'finalScore': finalScore,
      'finalVenue': finalVenue,
      'finalCity': finalCity,
      'finalAttendance': finalAttendance,
      'highlights': highlights,
    };
  }
}

/// Represents an all-time World Cup record
class WorldCupRecord extends Equatable {
  final String id;
  final String category;
  final String record;
  final String holder;
  final String holderType; // 'player', 'team', or 'match'
  final dynamic value;
  final String? details;

  const WorldCupRecord({
    required this.id,
    required this.category,
    required this.record,
    required this.holder,
    required this.holderType,
    required this.value,
    this.details,
  });

  @override
  List<Object?> get props => [id, category, holder];

  /// Get value as formatted string
  String get formattedValue {
    if (value is int) return value.toString();
    if (value is double) return value.toStringAsFixed(2);
    return value.toString();
  }

  factory WorldCupRecord.fromFirestore(Map<String, dynamic> data, String docId) {
    return WorldCupRecord(
      id: docId,
      category: data['category'] as String,
      record: data['record'] as String,
      holder: data['holder'] as String,
      holderType: data['holderType'] as String,
      value: data['value'],
      details: data['details'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'category': category,
      'record': record,
      'holder': holder,
      'holderType': holderType,
      'value': value,
      'details': details,
    };
  }
}

/// Team's World Cup history summary
class TeamWorldCupHistory extends Equatable {
  final String fifaCode;
  final String teamName;
  final int totalAppearances;
  final int titlesWon;
  final List<int> titleYears;
  final String bestFinish;
  final int? bestFinishYear;
  final int totalMatches;
  final int totalWins;
  final int totalDraws;
  final int totalLosses;
  final int totalGoalsFor;
  final int totalGoalsAgainst;
  final List<int> appearanceYears;

  const TeamWorldCupHistory({
    required this.fifaCode,
    required this.teamName,
    required this.totalAppearances,
    required this.titlesWon,
    required this.titleYears,
    required this.bestFinish,
    this.bestFinishYear,
    required this.totalMatches,
    required this.totalWins,
    required this.totalDraws,
    required this.totalLosses,
    required this.totalGoalsFor,
    required this.totalGoalsAgainst,
    required this.appearanceYears,
  });

  @override
  List<Object?> get props => [fifaCode, totalAppearances, titlesWon];

  /// Get win percentage
  double get winPercentage => totalMatches > 0 ? (totalWins / totalMatches) * 100 : 0;

  /// Get goal difference
  int get goalDifference => totalGoalsFor - totalGoalsAgainst;

  /// Get points (3 for win, 1 for draw)
  int get totalPoints => (totalWins * 3) + totalDraws;

  factory TeamWorldCupHistory.fromFirestore(Map<String, dynamic> data, String docId) {
    return TeamWorldCupHistory(
      fifaCode: docId,
      teamName: data['teamName'] as String,
      totalAppearances: data['totalAppearances'] as int,
      titlesWon: data['titlesWon'] as int,
      titleYears: List<int>.from(data['titleYears'] ?? []),
      bestFinish: data['bestFinish'] as String,
      bestFinishYear: data['bestFinishYear'] as int?,
      totalMatches: data['totalMatches'] as int,
      totalWins: data['totalWins'] as int,
      totalDraws: data['totalDraws'] as int,
      totalLosses: data['totalLosses'] as int,
      totalGoalsFor: data['totalGoalsFor'] as int,
      totalGoalsAgainst: data['totalGoalsAgainst'] as int,
      appearanceYears: List<int>.from(data['appearanceYears'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'teamName': teamName,
      'totalAppearances': totalAppearances,
      'titlesWon': titlesWon,
      'titleYears': titleYears,
      'bestFinish': bestFinish,
      'bestFinishYear': bestFinishYear,
      'totalMatches': totalMatches,
      'totalWins': totalWins,
      'totalDraws': totalDraws,
      'totalLosses': totalLosses,
      'totalGoalsFor': totalGoalsFor,
      'totalGoalsAgainst': totalGoalsAgainst,
      'appearanceYears': appearanceYears,
    };
  }
}

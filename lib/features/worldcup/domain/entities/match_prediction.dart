import 'package:equatable/equatable.dart';

/// Prediction outcome types
enum PredictionOutcome {
  homeWin,
  draw,
  awayWin,
  pending,   // Match not yet played
  correct,   // Prediction was correct
  incorrect, // Prediction was incorrect
}

/// Extension for PredictionOutcome
extension PredictionOutcomeExtension on PredictionOutcome {
  String get displayName {
    switch (this) {
      case PredictionOutcome.homeWin:
        return 'Home Win';
      case PredictionOutcome.draw:
        return 'Draw';
      case PredictionOutcome.awayWin:
        return 'Away Win';
      case PredictionOutcome.pending:
        return 'Pending';
      case PredictionOutcome.correct:
        return 'Correct';
      case PredictionOutcome.incorrect:
        return 'Incorrect';
    }
  }

  bool get isResult =>
      this == PredictionOutcome.correct || this == PredictionOutcome.incorrect;
}

/// User prediction for a World Cup match
class MatchPrediction extends Equatable {
  /// Unique prediction ID
  final String predictionId;

  /// Match ID this prediction is for
  final String matchId;

  /// User ID (for multi-user support)
  final String? userId;

  /// Predicted home team score
  final int predictedHomeScore;

  /// Predicted away team score
  final int predictedAwayScore;

  /// Predicted winner (home team code, away team code, or 'draw')
  final String? predictedWinner;

  /// Predicted outcome type
  final PredictionOutcome predictedOutcome;

  /// Actual outcome after match completion
  final PredictionOutcome? actualOutcome;

  /// Points earned for this prediction
  final int pointsEarned;

  /// Whether the exact score was predicted correctly
  final bool exactScoreCorrect;

  /// Whether the match result (win/draw/loss) was predicted correctly
  final bool resultCorrect;

  /// Whether token reward has been given for this prediction
  final bool tokenRewardGiven;

  /// Amount of tokens awarded (if any)
  final int tokensAwarded;

  /// Match date (for sorting)
  final DateTime? matchDate;

  /// Home team code
  final String? homeTeamCode;

  /// Home team name
  final String? homeTeamName;

  /// Away team code
  final String? awayTeamCode;

  /// Away team name
  final String? awayTeamName;

  /// When the prediction was made
  final DateTime createdAt;

  /// When the prediction was last updated
  final DateTime? updatedAt;

  const MatchPrediction({
    required this.predictionId,
    required this.matchId,
    this.userId,
    required this.predictedHomeScore,
    required this.predictedAwayScore,
    this.predictedWinner,
    this.predictedOutcome = PredictionOutcome.pending,
    this.actualOutcome,
    this.pointsEarned = 0,
    this.exactScoreCorrect = false,
    this.resultCorrect = false,
    this.tokenRewardGiven = false,
    this.tokensAwarded = 0,
    this.matchDate,
    this.homeTeamCode,
    this.homeTeamName,
    this.awayTeamCode,
    this.awayTeamName,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        predictionId,
        matchId,
        userId,
        predictedHomeScore,
        predictedAwayScore,
        predictedOutcome,
        actualOutcome,
      ];

  /// Get the predicted outcome based on scores
  PredictionOutcome get calculatedPredictedOutcome {
    if (predictedHomeScore > predictedAwayScore) {
      return PredictionOutcome.homeWin;
    } else if (predictedAwayScore > predictedHomeScore) {
      return PredictionOutcome.awayWin;
    }
    return PredictionOutcome.draw;
  }

  /// Display string for the prediction
  String get predictionDisplay => '$predictedHomeScore - $predictedAwayScore';

  /// Check if match is pending
  bool get isPending =>
      actualOutcome == null || actualOutcome == PredictionOutcome.pending;

  /// Check if prediction was correct
  bool get isCorrect => actualOutcome == PredictionOutcome.correct;

  /// Factory to create from map
  factory MatchPrediction.fromMap(Map<String, dynamic> map) {
    return MatchPrediction(
      predictionId: map['predictionId'] as String? ?? '',
      matchId: map['matchId'] as String? ?? '',
      userId: map['userId'] as String?,
      predictedHomeScore: map['predictedHomeScore'] as int? ?? 0,
      predictedAwayScore: map['predictedAwayScore'] as int? ?? 0,
      predictedWinner: map['predictedWinner'] as String?,
      predictedOutcome:
          _parsePredictionOutcome(map['predictedOutcome'] as String?),
      actualOutcome: map['actualOutcome'] != null
          ? _parsePredictionOutcome(map['actualOutcome'] as String?)
          : null,
      pointsEarned: map['pointsEarned'] as int? ?? 0,
      exactScoreCorrect: map['exactScoreCorrect'] as bool? ?? false,
      resultCorrect: map['resultCorrect'] as bool? ?? false,
      tokenRewardGiven: map['tokenRewardGiven'] as bool? ?? false,
      tokensAwarded: map['tokensAwarded'] as int? ?? 0,
      matchDate: map['matchDate'] != null
          ? DateTime.tryParse(map['matchDate'] as String)
          : null,
      homeTeamCode: map['homeTeamCode'] as String?,
      homeTeamName: map['homeTeamName'] as String?,
      awayTeamCode: map['awayTeamCode'] as String?,
      awayTeamName: map['awayTeamName'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'] as String)
          : null,
    );
  }

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'predictionId': predictionId,
      'matchId': matchId,
      'userId': userId,
      'predictedHomeScore': predictedHomeScore,
      'predictedAwayScore': predictedAwayScore,
      'predictedWinner': predictedWinner,
      'predictedOutcome': predictedOutcome.name,
      'actualOutcome': actualOutcome?.name,
      'pointsEarned': pointsEarned,
      'exactScoreCorrect': exactScoreCorrect,
      'resultCorrect': resultCorrect,
      'tokenRewardGiven': tokenRewardGiven,
      'tokensAwarded': tokensAwarded,
      'matchDate': matchDate?.toIso8601String(),
      'homeTeamCode': homeTeamCode,
      'homeTeamName': homeTeamName,
      'awayTeamCode': awayTeamCode,
      'awayTeamName': awayTeamName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  MatchPrediction copyWith({
    String? predictionId,
    String? matchId,
    String? userId,
    int? predictedHomeScore,
    int? predictedAwayScore,
    String? predictedWinner,
    PredictionOutcome? predictedOutcome,
    PredictionOutcome? actualOutcome,
    int? pointsEarned,
    bool? exactScoreCorrect,
    bool? resultCorrect,
    bool? tokenRewardGiven,
    int? tokensAwarded,
    DateTime? matchDate,
    String? homeTeamCode,
    String? homeTeamName,
    String? awayTeamCode,
    String? awayTeamName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MatchPrediction(
      predictionId: predictionId ?? this.predictionId,
      matchId: matchId ?? this.matchId,
      userId: userId ?? this.userId,
      predictedHomeScore: predictedHomeScore ?? this.predictedHomeScore,
      predictedAwayScore: predictedAwayScore ?? this.predictedAwayScore,
      predictedWinner: predictedWinner ?? this.predictedWinner,
      predictedOutcome: predictedOutcome ?? this.predictedOutcome,
      actualOutcome: actualOutcome ?? this.actualOutcome,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      exactScoreCorrect: exactScoreCorrect ?? this.exactScoreCorrect,
      resultCorrect: resultCorrect ?? this.resultCorrect,
      tokenRewardGiven: tokenRewardGiven ?? this.tokenRewardGiven,
      tokensAwarded: tokensAwarded ?? this.tokensAwarded,
      matchDate: matchDate ?? this.matchDate,
      homeTeamCode: homeTeamCode ?? this.homeTeamCode,
      homeTeamName: homeTeamName ?? this.homeTeamName,
      awayTeamCode: awayTeamCode ?? this.awayTeamCode,
      awayTeamName: awayTeamName ?? this.awayTeamName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Evaluate prediction against actual match result
  MatchPrediction evaluate({
    required int actualHomeScore,
    required int actualAwayScore,
  }) {
    // Calculate if result (outcome) was correct
    final actualResult = actualHomeScore > actualAwayScore
        ? PredictionOutcome.homeWin
        : actualAwayScore > actualHomeScore
            ? PredictionOutcome.awayWin
            : PredictionOutcome.draw;

    final isResultCorrect = calculatedPredictedOutcome == actualResult;
    final isExactScore = predictedHomeScore == actualHomeScore &&
        predictedAwayScore == actualAwayScore;

    // Calculate points: 3 for exact score, 1 for correct result
    int points = 0;
    if (isExactScore) {
      points = 3;
    } else if (isResultCorrect) {
      points = 1;
    }

    return copyWith(
      actualOutcome:
          isResultCorrect ? PredictionOutcome.correct : PredictionOutcome.incorrect,
      exactScoreCorrect: isExactScore,
      resultCorrect: isResultCorrect,
      pointsEarned: points,
      updatedAt: DateTime.now(),
    );
  }

  static PredictionOutcome _parsePredictionOutcome(String? value) {
    if (value == null) return PredictionOutcome.pending;

    switch (value.toLowerCase()) {
      case 'homewin':
      case 'home_win':
      case 'home':
        return PredictionOutcome.homeWin;
      case 'draw':
        return PredictionOutcome.draw;
      case 'awaywin':
      case 'away_win':
      case 'away':
        return PredictionOutcome.awayWin;
      case 'correct':
        return PredictionOutcome.correct;
      case 'incorrect':
        return PredictionOutcome.incorrect;
      default:
        return PredictionOutcome.pending;
    }
  }
}

/// Statistics for user predictions
class PredictionStats extends Equatable {
  final int totalPredictions;
  final int correctResults;
  final int exactScores;
  final int totalPoints;
  final int pendingPredictions;

  const PredictionStats({
    this.totalPredictions = 0,
    this.correctResults = 0,
    this.exactScores = 0,
    this.totalPoints = 0,
    this.pendingPredictions = 0,
  });

  @override
  List<Object?> get props => [
        totalPredictions,
        correctResults,
        exactScores,
        totalPoints,
        pendingPredictions,
      ];

  /// Percentage of correct results
  double get correctPercentage {
    final evaluated = totalPredictions - pendingPredictions;
    if (evaluated == 0) return 0;
    return (correctResults / evaluated) * 100;
  }

  /// Percentage of exact scores
  double get exactScorePercentage {
    final evaluated = totalPredictions - pendingPredictions;
    if (evaluated == 0) return 0;
    return (exactScores / evaluated) * 100;
  }

  /// Average points per prediction
  double get averagePoints {
    final evaluated = totalPredictions - pendingPredictions;
    if (evaluated == 0) return 0;
    return totalPoints / evaluated;
  }

  factory PredictionStats.fromMap(Map<String, dynamic> map) {
    return PredictionStats(
      totalPredictions: map['totalPredictions'] as int? ?? 0,
      correctResults: map['correctResults'] as int? ?? 0,
      exactScores: map['exactScores'] as int? ?? 0,
      totalPoints: map['totalPoints'] as int? ?? 0,
      pendingPredictions: map['pendingPredictions'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalPredictions': totalPredictions,
      'correctResults': correctResults,
      'exactScores': exactScores,
      'totalPoints': totalPoints,
      'pendingPredictions': pendingPredictions,
    };
  }

  /// Calculate stats from a list of predictions
  factory PredictionStats.fromPredictions(List<MatchPrediction> predictions) {
    int correct = 0;
    int exact = 0;
    int points = 0;
    int pending = 0;

    for (final prediction in predictions) {
      if (prediction.isPending) {
        pending++;
      } else {
        if (prediction.resultCorrect) correct++;
        if (prediction.exactScoreCorrect) exact++;
        points += prediction.pointsEarned;
      }
    }

    return PredictionStats(
      totalPredictions: predictions.length,
      correctResults: correct,
      exactScores: exact,
      totalPoints: points,
      pendingPredictions: pending,
    );
  }
}

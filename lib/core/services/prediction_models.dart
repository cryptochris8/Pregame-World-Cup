import 'package:cloud_firestore/cloud_firestore.dart';

/// Enum for prediction outcomes
enum PredictionOutcome {
  homeWin,
  awayWin,
  tie;

  @override
  String toString() {
    switch (this) {
      case PredictionOutcome.homeWin:
        return 'home_win';
      case PredictionOutcome.awayWin:
        return 'away_win';
      case PredictionOutcome.tie:
        return 'tie';
    }
  }

  static PredictionOutcome fromString(String value) {
    switch (value.toLowerCase()) {
      case 'home_win':
        return PredictionOutcome.homeWin;
      case 'away_win':
        return PredictionOutcome.awayWin;
      case 'tie':
        return PredictionOutcome.tie;
      default:
        return PredictionOutcome.homeWin;
    }
  }
}

/// AI-generated game prediction
class GamePrediction {
  final String predictionId;
  final String gameId;
  final String homeTeam;
  final String awayTeam;
  final DateTime gameTime;
  final PredictionOutcome predictedOutcome;
  final double confidence;
  final int? predictedHomeScore;
  final int? predictedAwayScore;
  final List<String> keyFactors;
  final String analysis;
  final DateTime createdAt;
  final String predictionSource;
  final Map<String, dynamic> metadata;

  const GamePrediction({
    required this.predictionId,
    required this.gameId,
    required this.homeTeam,
    required this.awayTeam,
    required this.gameTime,
    required this.predictedOutcome,
    required this.confidence,
    this.predictedHomeScore,
    this.predictedAwayScore,
    required this.keyFactors,
    required this.analysis,
    required this.createdAt,
    required this.predictionSource,
    required this.metadata,
  });

  factory GamePrediction.fromFirestore(Map<String, dynamic> data) {
    return GamePrediction(
      predictionId: data['prediction_id'] ?? '',
      gameId: data['game_id'] ?? '',
      homeTeam: data['home_team'] ?? '',
      awayTeam: data['away_team'] ?? '',
      gameTime: (data['game_time'] as Timestamp).toDate(),
      predictedOutcome: PredictionOutcome.fromString(data['predicted_outcome'] ?? 'home_win'),
      confidence: (data['confidence'] ?? 0.5).toDouble(),
      predictedHomeScore: data['predicted_home_score'],
      predictedAwayScore: data['predicted_away_score'],
      keyFactors: List<String>.from(data['key_factors'] ?? []),
      analysis: data['analysis'] ?? '',
      createdAt: (data['created_at'] as Timestamp).toDate(),
      predictionSource: data['prediction_source'] ?? 'AI',
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'prediction_id': predictionId,
      'game_id': gameId,
      'home_team': homeTeam,
      'away_team': awayTeam,
      'game_time': Timestamp.fromDate(gameTime),
      'predicted_outcome': predictedOutcome.toString(),
      'confidence': confidence,
      'predicted_home_score': predictedHomeScore,
      'predicted_away_score': predictedAwayScore,
      'key_factors': keyFactors,
      'analysis': analysis,
      'created_at': Timestamp.fromDate(createdAt),
      'prediction_source': predictionSource,
      'metadata': metadata,
    };
  }
}

/// User-generated game prediction
class UserPrediction {
  final String predictionId;
  final String gameId;
  final String userId;
  final String homeTeam;
  final String awayTeam;
  final PredictionOutcome predictedOutcome;
  final double confidence;
  final int? predictedHomeScore;
  final int? predictedAwayScore;
  final String? reasoning;
  final DateTime createdAt;

  const UserPrediction({
    required this.predictionId,
    required this.gameId,
    required this.userId,
    required this.homeTeam,
    required this.awayTeam,
    required this.predictedOutcome,
    required this.confidence,
    this.predictedHomeScore,
    this.predictedAwayScore,
    this.reasoning,
    required this.createdAt,
  });

  factory UserPrediction.fromFirestore(Map<String, dynamic> data) {
    return UserPrediction(
      predictionId: data['prediction_id'] ?? '',
      gameId: data['game_id'] ?? '',
      userId: data['user_id'] ?? '',
      homeTeam: data['home_team'] ?? '',
      awayTeam: data['away_team'] ?? '',
      predictedOutcome: PredictionOutcome.fromString(data['predicted_outcome'] ?? 'home_win'),
      confidence: (data['confidence'] ?? 0.5).toDouble(),
      predictedHomeScore: data['predicted_home_score'],
      predictedAwayScore: data['predicted_away_score'],
      reasoning: data['reasoning'],
      createdAt: (data['created_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'prediction_id': predictionId,
      'game_id': gameId,
      'user_id': userId,
      'home_team': homeTeam,
      'away_team': awayTeam,
      'predicted_outcome': predictedOutcome.toString(),
      'confidence': confidence,
      'predicted_home_score': predictedHomeScore,
      'predicted_away_score': predictedAwayScore,
      'reasoning': reasoning,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}

/// Prediction accuracy statistics
class PredictionAccuracyStats {
  final AIAccuracyStats aiAccuracy;
  final UserAccuracyStats? userAccuracy;

  const PredictionAccuracyStats({
    required this.aiAccuracy,
    this.userAccuracy,
  });

  factory PredictionAccuracyStats.empty() {
    return PredictionAccuracyStats(
      aiAccuracy: AIAccuracyStats.empty(),
      userAccuracy: null,
    );
  }
}

/// AI prediction accuracy statistics
class AIAccuracyStats {
  final int totalPredictions;
  final int correctPredictions;
  final double overallAccuracy;
  final double averageScoreAccuracy;

  const AIAccuracyStats({
    required this.totalPredictions,
    required this.correctPredictions,
    required this.overallAccuracy,
    required this.averageScoreAccuracy,
  });

  factory AIAccuracyStats.empty() {
    return const AIAccuracyStats(
      totalPredictions: 0,
      correctPredictions: 0,
      overallAccuracy: 0.0,
      averageScoreAccuracy: 0.0,
    );
  }
}

/// User prediction accuracy statistics
class UserAccuracyStats {
  final String userId;
  final int totalPredictions;
  final int correctPredictions;
  final double overallAccuracy;
  final double averageScoreAccuracy;

  const UserAccuracyStats({
    required this.userId,
    required this.totalPredictions,
    required this.correctPredictions,
    required this.overallAccuracy,
    required this.averageScoreAccuracy,
  });

  factory UserAccuracyStats.fromFirestore(Map<String, dynamic> data) {
    return UserAccuracyStats(
      userId: data['user_id'] ?? '',
      totalPredictions: data['total_predictions'] ?? 0,
      correctPredictions: data['correct_predictions'] ?? 0,
      overallAccuracy: (data['overall_accuracy'] ?? 0.0).toDouble(),
      averageScoreAccuracy: (data['average_score_accuracy'] ?? 0.0).toDouble(),
    );
  }

  factory UserAccuracyStats.empty(String userId) {
    return UserAccuracyStats(
      userId: userId,
      totalPredictions: 0,
      correctPredictions: 0,
      overallAccuracy: 0.0,
      averageScoreAccuracy: 0.0,
    );
  }
}

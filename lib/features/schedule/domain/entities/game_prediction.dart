import 'package:equatable/equatable.dart';

/// Entity representing a user's prediction for a game outcome
class GamePrediction extends Equatable {
  /// Unique identifier for the prediction
  final String predictionId;
  
  /// User who made the prediction
  final String userId;
  
  /// Game being predicted
  final String gameId;
  
  /// Predicted winner team name
  final String predictedWinner;
  
  /// Predicted score for home team
  final int? predictedHomeScore;
  
  /// Predicted score for away team  
  final int? predictedAwayScore;
  
  /// Confidence level (1-5 stars)
  final int confidenceLevel;
  
  /// When the prediction was made
  final DateTime createdAt;
  
  /// Whether this prediction was correct (null if game not finished)
  final bool? isCorrect;
  
  /// Points earned for this prediction
  final int pointsEarned;
  
  /// Whether prediction is locked (game started)
  final bool isLocked;

  const GamePrediction({
    required this.predictionId,
    required this.userId,
    required this.gameId,
    required this.predictedWinner,
    this.predictedHomeScore,
    this.predictedAwayScore,
    required this.confidenceLevel,
    required this.createdAt,
    this.isCorrect,
    this.pointsEarned = 0,
    this.isLocked = false,
  });

  /// Create a copy of this prediction with updated values
  GamePrediction copyWith({
    String? predictionId,
    String? userId,
    String? gameId,
    String? predictedWinner,
    int? predictedHomeScore,
    int? predictedAwayScore,
    int? confidenceLevel,
    DateTime? createdAt,
    bool? isCorrect,
    int? pointsEarned,
    bool? isLocked,
  }) {
    return GamePrediction(
      predictionId: predictionId ?? this.predictionId,
      userId: userId ?? this.userId,
      gameId: gameId ?? this.gameId,
      predictedWinner: predictedWinner ?? this.predictedWinner,
      predictedHomeScore: predictedHomeScore ?? this.predictedHomeScore,
      predictedAwayScore: predictedAwayScore ?? this.predictedAwayScore,
      confidenceLevel: confidenceLevel ?? this.confidenceLevel,
      createdAt: createdAt ?? this.createdAt,
      isCorrect: isCorrect ?? this.isCorrect,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  /// Convert from JSON
  factory GamePrediction.fromJson(Map<String, dynamic> json) {
    return GamePrediction(
      predictionId: json['predictionId'] as String,
      userId: json['userId'] as String,
      gameId: json['gameId'] as String,
      predictedWinner: json['predictedWinner'] as String,
      predictedHomeScore: json['predictedHomeScore'] as int?,
      predictedAwayScore: json['predictedAwayScore'] as int?,
      confidenceLevel: json['confidenceLevel'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isCorrect: json['isCorrect'] as bool?,
      pointsEarned: json['pointsEarned'] as int? ?? 0,
      isLocked: json['isLocked'] as bool? ?? false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'predictionId': predictionId,
      'userId': userId,
      'gameId': gameId,
      'predictedWinner': predictedWinner,
      'predictedHomeScore': predictedHomeScore,
      'predictedAwayScore': predictedAwayScore,
      'confidenceLevel': confidenceLevel,
      'createdAt': createdAt.toIso8601String(),
      'isCorrect': isCorrect,
      'pointsEarned': pointsEarned,
      'isLocked': isLocked,
    };
  }

  @override
  List<Object?> get props => [
    predictionId,
    userId,
    gameId,
    predictedWinner,
    predictedHomeScore,
    predictedAwayScore,
    confidenceLevel,
    createdAt,
    isCorrect,
    pointsEarned,
    isLocked,
  ];
}

/// Entity for user's prediction statistics
class PredictionStats extends Equatable {
  /// Total predictions made
  final int totalPredictions;
  
  /// Correct predictions
  final int correctPredictions;
  
  /// Current streak of correct predictions
  final int currentStreak;
  
  /// Longest streak achieved
  final int longestStreak;
  
  /// Total points earned from predictions
  final int totalPoints;
  
  /// User's rank among all predictors
  final int rank;
  
  /// Accuracy percentage (0-100)
  double get accuracy => totalPredictions > 0 
      ? (correctPredictions / totalPredictions * 100) 
      : 0.0;

  const PredictionStats({
    this.totalPredictions = 0,
    this.correctPredictions = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalPoints = 0,
    this.rank = 0,
  });

  /// Create a copy with updated values
  PredictionStats copyWith({
    int? totalPredictions,
    int? correctPredictions,
    int? currentStreak,
    int? longestStreak,
    int? totalPoints,
    int? rank,
  }) {
    return PredictionStats(
      totalPredictions: totalPredictions ?? this.totalPredictions,
      correctPredictions: correctPredictions ?? this.correctPredictions,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalPoints: totalPoints ?? this.totalPoints,
      rank: rank ?? this.rank,
    );
  }

  /// Convert from JSON
  factory PredictionStats.fromJson(Map<String, dynamic> json) {
    return PredictionStats(
      totalPredictions: json['totalPredictions'] as int? ?? 0,
      correctPredictions: json['correctPredictions'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      totalPoints: json['totalPoints'] as int? ?? 0,
      rank: json['rank'] as int? ?? 0,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'totalPredictions': totalPredictions,
      'correctPredictions': correctPredictions,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'totalPoints': totalPoints,
      'rank': rank,
    };
  }

  @override
  List<Object?> get props => [
    totalPredictions,
    correctPredictions,
    currentStreak,
    longestStreak,
    totalPoints,
    rank,
  ];
} 
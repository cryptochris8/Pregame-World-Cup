import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../ai/services/ai_service.dart';
import '../services/user_learning_service.dart';
import 'prediction_models.dart';
import 'prediction_calculation_service.dart';
import 'prediction_accuracy_service.dart';

// Re-export models so callers can continue to import from this file
export 'prediction_models.dart';

/// Facade service for AI-powered game predictions and accuracy tracking.
///
/// Delegates to focused sub-services:
/// - [PredictionCalculationService]: AI prediction generation, user predictions, retrieval
/// - [PredictionAccuracyService]: Accuracy tracking, stats, leaderboards
class GamePredictionService {
  static final GamePredictionService _instance = GamePredictionService._internal();
  factory GamePredictionService() => _instance;
  GamePredictionService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sub-services (lazily initialized)
  late final PredictionCalculationService _calculation = PredictionCalculationService(
    firestore: _firestore,
    auth: _auth,
    aiService: AIService(),
    userLearningService: UserLearningService(),
  );

  late final PredictionAccuracyService _accuracy = PredictionAccuracyService(
    firestore: _firestore,
    auth: _auth,
  );

  // ==================== Prediction Generation (delegated) ====================

  /// Generate AI-powered game prediction
  Future<GamePrediction> generateGamePrediction({
    required String gameId,
    required String homeTeam,
    required String awayTeam,
    required DateTime gameTime,
    Map<String, dynamic>? gameStats,
    Map<String, dynamic>? historicalData,
  }) =>
      _calculation.generateGamePrediction(
        gameId: gameId,
        homeTeam: homeTeam,
        awayTeam: awayTeam,
        gameTime: gameTime,
        gameStats: gameStats,
        historicalData: historicalData,
      );

  /// Allow user to make their own prediction
  Future<UserPrediction> createUserPrediction({
    required String gameId,
    required String homeTeam,
    required String awayTeam,
    required PredictionOutcome predictedOutcome,
    required double confidence,
    int? predictedHomeScore,
    int? predictedAwayScore,
    String? reasoning,
  }) =>
      _calculation.createUserPrediction(
        gameId: gameId,
        homeTeam: homeTeam,
        awayTeam: awayTeam,
        predictedOutcome: predictedOutcome,
        confidence: confidence,
        predictedHomeScore: predictedHomeScore,
        predictedAwayScore: predictedAwayScore,
        reasoning: reasoning,
      );

  /// Get existing prediction for a game
  Future<GamePrediction?> getGamePrediction(String gameId) =>
      _calculation.getGamePrediction(gameId);

  /// Get user's prediction for a game
  Future<UserPrediction?> getUserPrediction(String gameId) =>
      _calculation.getUserPrediction(gameId);

  // ==================== Accuracy Tracking (delegated) ====================

  /// Update prediction accuracy after game completion
  Future<void> updatePredictionAccuracy({
    required String gameId,
    required PredictionOutcome actualOutcome,
    required int actualHomeScore,
    required int actualAwayScore,
  }) =>
      _accuracy.updatePredictionAccuracy(
        gameId: gameId,
        actualOutcome: actualOutcome,
        actualHomeScore: actualHomeScore,
        actualAwayScore: actualAwayScore,
      );

  /// Get prediction accuracy statistics
  Future<PredictionAccuracyStats> getPredictionAccuracyStats() =>
      _accuracy.getPredictionAccuracyStats();

  /// Get leaderboard of top predictors
  Future<List<UserAccuracyStats>> getPredictionLeaderboard({int limit = 10}) =>
      _accuracy.getPredictionLeaderboard(limit: limit);
}

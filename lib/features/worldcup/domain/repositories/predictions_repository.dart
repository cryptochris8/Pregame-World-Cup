import '../entities/entities.dart';

/// Repository interface for match predictions
abstract class PredictionsRepository {
  /// Get all predictions
  Future<List<MatchPrediction>> getAllPredictions();

  /// Get prediction for a specific match
  Future<MatchPrediction?> getPredictionForMatch(String matchId);

  /// Save a prediction
  Future<MatchPrediction> savePrediction(MatchPrediction prediction);

  /// Update a prediction (only if match hasn't started)
  Future<MatchPrediction> updatePrediction(MatchPrediction prediction);

  /// Delete a prediction
  Future<void> deletePrediction(String predictionId);

  /// Delete prediction for a match
  Future<void> deletePredictionForMatch(String matchId);

  /// Get predictions for upcoming matches
  Future<List<MatchPrediction>> getUpcomingPredictions();

  /// Get predictions for completed matches
  Future<List<MatchPrediction>> getCompletedPredictions();

  /// Get prediction statistics
  Future<PredictionStats> getPredictionStats();

  /// Stream of predictions
  Stream<List<MatchPrediction>> watchPredictions();

  /// Stream of prediction stats
  Stream<PredictionStats> watchPredictionStats();

  /// Check if prediction exists for a match
  Future<bool> hasPredictionForMatch(String matchId);

  /// Create a new prediction
  Future<MatchPrediction> createPrediction({
    required String matchId,
    required int predictedHomeScore,
    required int predictedAwayScore,
    String? homeTeamCode,
    String? homeTeamName,
    String? awayTeamCode,
    String? awayTeamName,
    DateTime? matchDate,
  });

  /// Evaluate predictions for completed matches
  Future<void> evaluatePredictions(List<WorldCupMatch> completedMatches);

  /// Clear all predictions
  Future<void> clearAllPredictions();
}

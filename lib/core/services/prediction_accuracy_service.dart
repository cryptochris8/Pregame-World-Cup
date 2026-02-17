import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/logging_service.dart';
import 'prediction_models.dart';

/// Handles prediction accuracy tracking, stats computation, and leaderboards.
class PredictionAccuracyService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  PredictionAccuracyService({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  /// Update prediction accuracy after game completion
  Future<void> updatePredictionAccuracy({
    required String gameId,
    required PredictionOutcome actualOutcome,
    required int actualHomeScore,
    required int actualAwayScore,
  }) async {
    try {
      // Update AI prediction accuracy
      await _updateAIPredictionAccuracy(gameId, actualOutcome, actualHomeScore, actualAwayScore);

      // Update user prediction accuracies
      await _updateUserPredictionAccuracy(gameId, actualOutcome, actualHomeScore, actualAwayScore);

      LoggingService.info('Updated prediction accuracy for game $gameId', tag: 'GamePrediction');
    } catch (e) {
      LoggingService.error('Error updating prediction accuracy: $e', tag: 'GamePrediction');
    }
  }

  /// Get prediction accuracy statistics
  Future<PredictionAccuracyStats> getPredictionAccuracyStats() async {
    try {
      // Get AI prediction accuracy
      final aiAccuracy = await _getAIPredictionAccuracy();

      // Get user prediction accuracy (if authenticated)
      UserAccuracyStats? userAccuracy;
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        userAccuracy = await _getUserPredictionAccuracy(userId);
      }

      return PredictionAccuracyStats(
        aiAccuracy: aiAccuracy,
        userAccuracy: userAccuracy,
      );
    } catch (e) {
      LoggingService.error('Error getting prediction accuracy stats: $e', tag: 'GamePrediction');
      return PredictionAccuracyStats.empty();
    }
  }

  /// Get leaderboard of top predictors
  Future<List<UserAccuracyStats>> getPredictionLeaderboard({int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection('user_accuracy_stats')
          .orderBy('overall_accuracy', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => UserAccuracyStats.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      LoggingService.error('Error getting prediction leaderboard: $e', tag: 'GamePrediction');
      return [];
    }
  }

  // ==================== Private Helpers ====================

  /// Update AI prediction accuracy
  Future<void> _updateAIPredictionAccuracy(
    String gameId,
    PredictionOutcome actualOutcome,
    int actualHomeScore,
    int actualAwayScore,
  ) async {
    final predictionId = 'ai_prediction_$gameId';
    final predictionRef = _firestore.collection('game_predictions').doc(predictionId);

    await _firestore.runTransaction((transaction) async {
      final predictionDoc = await transaction.get(predictionRef);

      if (predictionDoc.exists) {
        final data = predictionDoc.data()!;
        final prediction = GamePrediction.fromFirestore(data);

        // Calculate accuracy metrics
        final outcomeCorrect = prediction.predictedOutcome == actualOutcome;
        final scoreAccuracy = _calculateScoreAccuracy(
          prediction.predictedHomeScore,
          prediction.predictedAwayScore,
          actualHomeScore,
          actualAwayScore,
        );

        // Update prediction with results
        final updatedData = {
          ...data,
          'actual_outcome': actualOutcome.toString(),
          'actual_home_score': actualHomeScore,
          'actual_away_score': actualAwayScore,
          'outcome_correct': outcomeCorrect,
          'score_accuracy': scoreAccuracy,
          'evaluated_at': FieldValue.serverTimestamp(),
        };

        transaction.update(predictionRef, updatedData);
      }
    });
  }

  /// Update user prediction accuracy
  Future<void> _updateUserPredictionAccuracy(
    String gameId,
    PredictionOutcome actualOutcome,
    int actualHomeScore,
    int actualAwayScore,
  ) async {
    // Get all user predictions for this game
    final userPredictions = await _firestore
        .collection('user_predictions')
        .where('game_id', isEqualTo: gameId)
        .get();

    for (final doc in userPredictions.docs) {
      final data = doc.data();
      final prediction = UserPrediction.fromFirestore(data);

      // Calculate accuracy metrics
      final outcomeCorrect = prediction.predictedOutcome == actualOutcome;
      final scoreAccuracy = _calculateScoreAccuracy(
        prediction.predictedHomeScore,
        prediction.predictedAwayScore,
        actualHomeScore,
        actualAwayScore,
      );

      // Update prediction with results
      await doc.reference.update({
        'actual_outcome': actualOutcome.toString(),
        'actual_home_score': actualHomeScore,
        'actual_away_score': actualAwayScore,
        'outcome_correct': outcomeCorrect,
        'score_accuracy': scoreAccuracy,
        'evaluated_at': FieldValue.serverTimestamp(),
      });

      // Update user's overall accuracy stats
      await _updateUserAccuracyStats(prediction.userId, outcomeCorrect, scoreAccuracy);
    }
  }

  /// Update user's overall accuracy statistics
  Future<void> _updateUserAccuracyStats(String userId, bool outcomeCorrect, double scoreAccuracy) async {
    final statsRef = _firestore.collection('user_accuracy_stats').doc(userId);

    await _firestore.runTransaction((transaction) async {
      final statsDoc = await transaction.get(statsRef);

      Map<String, dynamic> data;
      if (statsDoc.exists) {
        data = statsDoc.data()!;
      } else {
        data = {
          'user_id': userId,
          'total_predictions': 0,
          'correct_predictions': 0,
          'overall_accuracy': 0.0,
          'average_score_accuracy': 0.0,
          'created_at': FieldValue.serverTimestamp(),
        };
      }

      final totalPredictions = (data['total_predictions'] ?? 0) + 1;
      final correctPredictions = (data['correct_predictions'] ?? 0) + (outcomeCorrect ? 1 : 0);
      final overallAccuracy = correctPredictions / totalPredictions;

      // Calculate running average of score accuracy
      final currentScoreAccuracy = data['average_score_accuracy'] ?? 0.0;
      final newScoreAccuracy = ((currentScoreAccuracy * (totalPredictions - 1)) + scoreAccuracy) / totalPredictions;

      data.addAll({
        'total_predictions': totalPredictions,
        'correct_predictions': correctPredictions,
        'overall_accuracy': overallAccuracy,
        'average_score_accuracy': newScoreAccuracy,
        'last_updated': FieldValue.serverTimestamp(),
      });

      transaction.set(statsRef, data);
    });
  }

  /// Get AI prediction accuracy statistics
  Future<AIAccuracyStats> _getAIPredictionAccuracy() async {
    final snapshot = await _firestore
        .collection('game_predictions')
        .where('evaluated_at', isNotEqualTo: null)
        .get();

    if (snapshot.docs.isEmpty) {
      return AIAccuracyStats.empty();
    }

    int totalPredictions = snapshot.docs.length;
    int correctOutcomes = 0;
    double totalScoreAccuracy = 0.0;

    for (final doc in snapshot.docs) {
      final data = doc.data();
      if (data['outcome_correct'] == true) {
        correctOutcomes++;
      }
      totalScoreAccuracy += (data['score_accuracy'] ?? 0.0);
    }

    return AIAccuracyStats(
      totalPredictions: totalPredictions,
      correctPredictions: correctOutcomes,
      overallAccuracy: correctOutcomes / totalPredictions,
      averageScoreAccuracy: totalScoreAccuracy / totalPredictions,
    );
  }

  /// Get user prediction accuracy statistics
  Future<UserAccuracyStats> _getUserPredictionAccuracy(String userId) async {
    final doc = await _firestore
        .collection('user_accuracy_stats')
        .doc(userId)
        .get();

    if (doc.exists) {
      return UserAccuracyStats.fromFirestore(doc.data()!);
    }

    return UserAccuracyStats.empty(userId);
  }

  /// Calculate score prediction accuracy (0.0 to 1.0)
  double _calculateScoreAccuracy(int? predictedHome, int? predictedAway, int actualHome, int actualAway) {
    if (predictedHome == null || predictedAway == null) {
      return 0.0; // No score prediction made
    }

    // Calculate accuracy based on how close the prediction was
    final homeDiff = (predictedHome - actualHome).abs();
    final awayDiff = (predictedAway - actualAway).abs();
    final totalDiff = homeDiff + awayDiff;

    // Perfect prediction = 1.0, each point off reduces accuracy
    return (1.0 - (totalDiff * 0.1)).clamp(0.0, 1.0);
  }
}

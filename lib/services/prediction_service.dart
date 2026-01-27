import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../features/schedule/domain/entities/game_prediction.dart';
import '../features/schedule/domain/entities/game_schedule.dart';

/// Service for managing game predictions and scoring
class PredictionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _predictionsCollection = 'predictions';
  static const String _userStatsCollection = 'prediction_stats';

  /// Create or update a prediction for a game
  Future<void> makePrediction({
    required String userId,
    required String gameId,
    required String predictedWinner,
    int? predictedHomeScore,
    int? predictedAwayScore,
    required int confidenceLevel,
  }) async {
    try {
      final predictionId = '${userId}_$gameId';
      
      final prediction = GamePrediction(
        predictionId: predictionId,
        userId: userId,
        gameId: gameId,
        predictedWinner: predictedWinner,
        predictedHomeScore: predictedHomeScore,
        predictedAwayScore: predictedAwayScore,
        confidenceLevel: confidenceLevel,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(_predictionsCollection)
          .doc(predictionId)
          .set(prediction.toJson());

      // Debug output removed
    } catch (e) {
      // Debug output removed
      rethrow;
    }
  }

  /// Get user's prediction for a specific game
  Future<GamePrediction?> getUserPrediction(String userId, String gameId) async {
    try {
      final predictionId = '${userId}_$gameId';
      final doc = await _firestore
          .collection(_predictionsCollection)
          .doc(predictionId)
          .get();

      if (doc.exists && doc.data() != null) {
        return GamePrediction.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      // Debug output removed
      return null;
    }
  }

  /// Get all predictions for a user
  Future<List<GamePrediction>> getUserPredictions(String userId) async {
    try {
      final query = await _firestore
          .collection(_predictionsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs
          .map((doc) => GamePrediction.fromJson(doc.data()))
          .toList();
    } catch (e) {
      // Debug output removed
      return [];
    }
  }

  /// Get all predictions for a specific game
  Future<List<GamePrediction>> getGamePredictions(String gameId) async {
    try {
      final query = await _firestore
          .collection(_predictionsCollection)
          .where('gameId', isEqualTo: gameId)
          .get();

      return query.docs
          .map((doc) => GamePrediction.fromJson(doc.data()))
          .toList();
    } catch (e) {
      // Debug output removed
      return [];
    }
  }

  /// Lock predictions when game starts
  Future<void> lockGamePredictions(String gameId) async {
    try {
      final query = await _firestore
          .collection(_predictionsCollection)
          .where('gameId', isEqualTo: gameId)
          .get();

      final batch = _firestore.batch();
      for (final doc in query.docs) {
        batch.update(doc.reference, {'isLocked': true});
      }
      await batch.commit();

      // Debug output removed
    } catch (e) {
      // Debug output removed
    }
  }

  /// Score predictions when game finishes
  Future<void> scorePredictions(GameSchedule finishedGame) async {
    try {
      final predictions = await getGamePredictions(finishedGame.gameId);
      final batch = _firestore.batch();

      for (final prediction in predictions) {
        final isCorrect = _calculatePredictionCorrectness(prediction, finishedGame);
        final points = _calculatePoints(prediction, finishedGame, isCorrect);

        final updatedPrediction = prediction.copyWith(
          isCorrect: isCorrect,
          pointsEarned: points,
        );

        batch.update(
          _firestore.collection(_predictionsCollection).doc(prediction.predictionId),
          updatedPrediction.toJson(),
        );

        // Update user stats
        await _updateUserStats(prediction.userId, isCorrect, points);
      }

      await batch.commit();
      // Debug output removed
    } catch (e) {
      // Debug output removed
    }
  }

  /// Calculate if a prediction was correct
  bool _calculatePredictionCorrectness(GamePrediction prediction, GameSchedule game) {
    if (game.homeScore == null || game.awayScore == null) return false;
    
    // Determine actual winner
    String actualWinner;
    if (game.homeScore! > game.awayScore!) {
      actualWinner = game.homeTeamName;
    } else if (game.awayScore! > game.homeScore!) {
      actualWinner = game.awayTeamName;
    } else {
      actualWinner = 'TIE'; // Handle ties
    }

    return prediction.predictedWinner == actualWinner;
  }

  /// Calculate points earned for a prediction
  int _calculatePoints(GamePrediction prediction, GameSchedule game, bool isCorrect) {
    if (!isCorrect) return 0;

    int basePoints = 10; // Base points for correct winner
    int confidenceBonus = prediction.confidenceLevel * 2; // Bonus for confidence
    int exactScoreBonus = 0;

    // Bonus for exact score prediction
    if (prediction.predictedHomeScore == game.homeScore &&
        prediction.predictedAwayScore == game.awayScore) {
      exactScoreBonus = 20;
    }

    return basePoints + confidenceBonus + exactScoreBonus;
  }

  /// Update user statistics
  Future<void> _updateUserStats(String userId, bool isCorrect, int points) async {
    try {
      final statsDoc = _firestore.collection(_userStatsCollection).doc(userId);
      
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(statsDoc);
        
        PredictionStats currentStats;
        if (snapshot.exists && snapshot.data() != null) {
          currentStats = PredictionStats.fromJson(snapshot.data()!);
        } else {
          currentStats = const PredictionStats();
        }

        final updatedStats = currentStats.copyWith(
          totalPredictions: currentStats.totalPredictions + 1,
          correctPredictions: isCorrect 
              ? currentStats.correctPredictions + 1 
              : currentStats.correctPredictions,
          currentStreak: isCorrect 
              ? currentStats.currentStreak + 1 
              : 0,
          longestStreak: isCorrect 
              ? (currentStats.currentStreak + 1 > currentStats.longestStreak 
                  ? currentStats.currentStreak + 1 
                  : currentStats.longestStreak)
              : currentStats.longestStreak,
          totalPoints: currentStats.totalPoints + points,
        );

        transaction.set(statsDoc, updatedStats.toJson());
      });
    } catch (e) {
      // Debug output removed
    }
  }

  /// Get user's prediction statistics
  Future<PredictionStats> getUserStats(String userId) async {
    try {
      final doc = await _firestore
          .collection(_userStatsCollection)
          .doc(userId)
          .get();

      if (doc.exists && doc.data() != null) {
        return PredictionStats.fromJson(doc.data()!);
      }
      return const PredictionStats();
    } catch (e) {
      // Debug output removed
      return const PredictionStats();
    }
  }

  /// Get leaderboard (top predictors)
  Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 10}) async {
    try {
      final query = await _firestore
          .collection(_userStatsCollection)
          .orderBy('totalPoints', descending: true)
          .limit(limit)
          .get();

      final leaderboard = <Map<String, dynamic>>[];
      for (int i = 0; i < query.docs.length; i++) {
        final doc = query.docs[i];
        final stats = PredictionStats.fromJson(doc.data());
        
        leaderboard.add({
          'userId': doc.id,
          'rank': i + 1,
          'stats': stats,
        });
      }

      return leaderboard;
    } catch (e) {
      // Debug output removed
      return [];
    }
  }

  /// Check if predictions can be made for a game (game hasn't started)
  bool canMakePrediction(GameSchedule game) {
    final now = DateTime.now();
    // Use dateTime field instead of gameTime (which doesn't exist)
    return game.dateTime != null && game.dateTime!.isAfter(now);
  }

  /// Get trending predictions for a game (most popular picks)
  Future<Map<String, int>> getGameTrends(String gameId) async {
    try {
      final predictions = await getGamePredictions(gameId);
      final trends = <String, int>{};

      for (final prediction in predictions) {
        trends[prediction.predictedWinner] = 
            (trends[prediction.predictedWinner] ?? 0) + 1;
      }

      return trends;
    } catch (e) {
      // Debug output removed
      return {};
    }
  }
} 
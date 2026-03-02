import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/predictions_repository.dart';

/// Implementation of PredictionsRepository using SharedPreferences (offline-first)
/// with Firestore sync for persistence and leaderboard support.
class PredictionsRepositoryImpl implements PredictionsRepository {
  static const String _predictionsKey = 'world_cup_predictions';
  static const String _statsKey = 'world_cup_prediction_stats';
  static const String _firestorePredictionsCollection = 'user_predictions';
  static const String _firestoreLeaderboardCollection = 'prediction_leaderboard';

  final SharedPreferences _sharedPreferences;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;
  final Uuid _uuid = const Uuid();

  final StreamController<List<MatchPrediction>> _predictionsController =
      StreamController<List<MatchPrediction>>.broadcast();
  final StreamController<PredictionStats> _statsController =
      StreamController<PredictionStats>.broadcast();

  List<MatchPrediction>? _cachedPredictions;

  PredictionsRepositoryImpl({
    required SharedPreferences sharedPreferences,
    required FirebaseFirestore firestore,
    required FirebaseAuth firebaseAuth,
  })  : _sharedPreferences = sharedPreferences,
        _firestore = firestore,
        _firebaseAuth = firebaseAuth;

  /// Get the current user's UID, or null if not logged in.
  String? get _currentUserId => _firebaseAuth.currentUser?.uid;

  /// Get the user's display name for leaderboard.
  String? get _currentDisplayName => _firebaseAuth.currentUser?.displayName;

  @override
  Future<List<MatchPrediction>> getAllPredictions() async {
    if (_cachedPredictions != null) {
      return _cachedPredictions!;
    }

    final jsonString = _sharedPreferences.getString(_predictionsKey);
    if (jsonString != null) {
      try {
        final list = json.decode(jsonString) as List<dynamic>;
        _cachedPredictions = list
            .map((item) =>
                MatchPrediction.fromMap(item as Map<String, dynamic>))
            .toList();
        return _cachedPredictions!;
      } catch (e) {
        return [];
      }
    }

    return [];
  }

  Future<void> _savePredictions(List<MatchPrediction> predictions) async {
    _cachedPredictions = predictions;
    final jsonString =
        json.encode(predictions.map((p) => p.toMap()).toList());
    await _sharedPreferences.setString(_predictionsKey, jsonString);
    _predictionsController.add(predictions);
    _statsController.add(PredictionStats.fromPredictions(predictions));
  }

  @override
  Future<MatchPrediction?> getPredictionForMatch(String matchId) async {
    final predictions = await getAllPredictions();
    try {
      return predictions.firstWhere((p) => p.matchId == matchId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<MatchPrediction> savePrediction(MatchPrediction prediction) async {
    final predictions = await getAllPredictions();

    // Stamp userId onto prediction if authenticated
    final userId = _currentUserId;
    final stampedPrediction = userId != null && prediction.userId == null
        ? prediction.copyWith(userId: userId)
        : prediction;

    // Check if prediction already exists for this match
    final existingIndex =
        predictions.indexWhere((p) => p.matchId == stampedPrediction.matchId);

    if (existingIndex >= 0) {
      predictions[existingIndex] = stampedPrediction;
    } else {
      predictions.add(stampedPrediction);
    }

    await _savePredictions(predictions);

    // Best-effort Firestore sync
    await _syncPredictionToFirestore(stampedPrediction);

    return stampedPrediction;
  }

  @override
  Future<MatchPrediction> updatePrediction(MatchPrediction prediction) async {
    final predictions = await getAllPredictions();
    final index = predictions.indexWhere((p) => p.predictionId == prediction.predictionId);

    if (index < 0) {
      throw Exception('Prediction not found');
    }

    final updated = prediction.copyWith(updatedAt: DateTime.now());
    predictions[index] = updated;
    await _savePredictions(predictions);

    // Best-effort Firestore sync
    await _syncPredictionToFirestore(updated);

    return updated;
  }

  @override
  Future<void> deletePrediction(String predictionId) async {
    final predictions = await getAllPredictions();
    final toDelete = predictions.where((p) => p.predictionId == predictionId).toList();
    predictions.removeWhere((p) => p.predictionId == predictionId);
    await _savePredictions(predictions);

    // Best-effort Firestore delete
    for (final prediction in toDelete) {
      await _deletePredictionFromFirestore(prediction.matchId);
    }

    // Update leaderboard after deletion
    await _updateLeaderboard(predictions);
  }

  @override
  Future<void> deletePredictionForMatch(String matchId) async {
    final predictions = await getAllPredictions();
    predictions.removeWhere((p) => p.matchId == matchId);
    await _savePredictions(predictions);

    // Best-effort Firestore delete
    await _deletePredictionFromFirestore(matchId);

    // Update leaderboard after deletion
    await _updateLeaderboard(predictions);
  }

  @override
  Future<List<MatchPrediction>> getUpcomingPredictions() async {
    final predictions = await getAllPredictions();
    return predictions.where((p) => p.isPending).toList();
  }

  @override
  Future<List<MatchPrediction>> getCompletedPredictions() async {
    final predictions = await getAllPredictions();
    return predictions.where((p) => !p.isPending).toList();
  }

  @override
  Future<PredictionStats> getPredictionStats() async {
    final predictions = await getAllPredictions();
    return PredictionStats.fromPredictions(predictions);
  }

  @override
  Stream<List<MatchPrediction>> watchPredictions() {
    // Emit current value immediately
    getAllPredictions().then((predictions) {
      _predictionsController.add(predictions);
    });
    return _predictionsController.stream;
  }

  @override
  Stream<PredictionStats> watchPredictionStats() {
    // Emit current value immediately
    getPredictionStats().then((stats) {
      _statsController.add(stats);
    });
    return _statsController.stream;
  }

  @override
  Future<bool> hasPredictionForMatch(String matchId) async {
    final prediction = await getPredictionForMatch(matchId);
    return prediction != null;
  }

  @override
  Future<MatchPrediction> createPrediction({
    required String matchId,
    required int predictedHomeScore,
    required int predictedAwayScore,
    String? homeTeamCode,
    String? homeTeamName,
    String? awayTeamCode,
    String? awayTeamName,
    DateTime? matchDate,
  }) async {
    // Check if prediction already exists
    final existing = await getPredictionForMatch(matchId);
    if (existing != null) {
      // Update existing prediction
      return updatePrediction(existing.copyWith(
        predictedHomeScore: predictedHomeScore,
        predictedAwayScore: predictedAwayScore,
      ));
    }

    // Create new prediction
    final prediction = MatchPrediction(
      predictionId: _uuid.v4(),
      matchId: matchId,
      userId: _currentUserId,
      predictedHomeScore: predictedHomeScore,
      predictedAwayScore: predictedAwayScore,
      homeTeamCode: homeTeamCode,
      homeTeamName: homeTeamName,
      awayTeamCode: awayTeamCode,
      awayTeamName: awayTeamName,
      matchDate: matchDate,
      createdAt: DateTime.now(),
    );

    return savePrediction(prediction);
  }

  @override
  Future<void> evaluatePredictions(List<WorldCupMatch> completedMatches) async {
    final predictions = await getAllPredictions();
    bool hasChanges = false;

    for (int i = 0; i < predictions.length; i++) {
      final prediction = predictions[i];

      // Skip already evaluated predictions
      if (!prediction.isPending) continue;

      // Find matching completed match
      final match = completedMatches.firstWhere(
        (m) => m.matchId == prediction.matchId && m.status == MatchStatus.completed,
        orElse: () => const WorldCupMatch(
          matchId: '',
          matchNumber: 0,
          stage: MatchStage.groupStage,
          homeTeamName: '',
          awayTeamName: '',
        ),
      );

      // Skip if match not found or not completed
      if (match.matchId.isEmpty ||
          match.homeScore == null ||
          match.awayScore == null) {
        continue;
      }

      // Evaluate the prediction
      predictions[i] = prediction.evaluate(
        actualHomeScore: match.homeScore!,
        actualAwayScore: match.awayScore!,
      );
      hasChanges = true;
    }

    if (hasChanges) {
      await _savePredictions(predictions);

      // Sync evaluated predictions to Firestore
      for (final prediction in predictions.where((p) => !p.isPending)) {
        await _syncPredictionToFirestore(prediction);
      }

      // Update leaderboard with new evaluation results
      await _updateLeaderboard(predictions);
    }
  }

  @override
  Future<void> clearAllPredictions() async {
    _cachedPredictions = [];
    await _sharedPreferences.remove(_predictionsKey);
    await _sharedPreferences.remove(_statsKey);
    _predictionsController.add([]);
    _statsController.add(const PredictionStats());

    // Best-effort clear Firestore predictions
    await _clearFirestorePredictions();
  }

  // ---------------------------------------------------------------------------
  // Firestore sync methods
  // ---------------------------------------------------------------------------

  @override
  Future<void> syncToFirestore() async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      final predictions = await getAllPredictions();

      // Batch write all predictions to Firestore
      final batch = _firestore.batch();
      final predictionsRef = _firestore
          .collection(_firestorePredictionsCollection)
          .doc(userId)
          .collection('predictions');

      for (final prediction in predictions) {
        final docRef = predictionsRef.doc(prediction.matchId);
        batch.set(docRef, _predictionToFirestoreMap(prediction, userId));
      }

      await batch.commit();

      // Update leaderboard
      await _updateLeaderboard(predictions);
    } catch (e) {
      // Best-effort: silently fail if offline or Firestore unavailable
    }
  }

  @override
  Future<void> syncFromFirestore() async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      final snapshot = await _firestore
          .collection(_firestorePredictionsCollection)
          .doc(userId)
          .collection('predictions')
          .get();

      if (snapshot.docs.isEmpty) return;

      final localPredictions = await getAllPredictions();
      final localMatchIds = localPredictions.map((p) => p.matchId).toSet();

      bool hasNewPredictions = false;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final matchId = data['matchId'] as String? ?? doc.id;

        if (!localMatchIds.contains(matchId)) {
          // This prediction exists in Firestore but not locally
          final prediction = _firestoreMapToPrediction(data);
          localPredictions.add(prediction);
          hasNewPredictions = true;
        } else {
          // Merge: use the most recent version
          final localIndex = localPredictions.indexWhere((p) => p.matchId == matchId);
          if (localIndex >= 0) {
            final remotePrediction = _firestoreMapToPrediction(data);
            final localUpdated = localPredictions[localIndex].updatedAt ?? localPredictions[localIndex].createdAt;
            final remoteUpdated = remotePrediction.updatedAt ?? remotePrediction.createdAt;
            if (remoteUpdated.isAfter(localUpdated)) {
              localPredictions[localIndex] = remotePrediction;
              hasNewPredictions = true;
            }
          }
        }
      }

      if (hasNewPredictions) {
        await _savePredictions(localPredictions);
      }
    } catch (e) {
      // Best-effort: silently fail if offline or Firestore unavailable
    }
  }

  // ---------------------------------------------------------------------------
  // Private Firestore helpers
  // ---------------------------------------------------------------------------

  /// Sync a single prediction to Firestore (best-effort, fire-and-forget).
  Future<void> _syncPredictionToFirestore(MatchPrediction prediction) async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      await _firestore
          .collection(_firestorePredictionsCollection)
          .doc(userId)
          .collection('predictions')
          .doc(prediction.matchId)
          .set(_predictionToFirestoreMap(prediction, userId));

      // Update leaderboard after saving
      final predictions = await getAllPredictions();
      await _updateLeaderboard(predictions);
    } catch (e) {
      // Best-effort: silently fail
    }
  }

  /// Delete a prediction from Firestore by matchId (best-effort).
  Future<void> _deletePredictionFromFirestore(String matchId) async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      await _firestore
          .collection(_firestorePredictionsCollection)
          .doc(userId)
          .collection('predictions')
          .doc(matchId)
          .delete();
    } catch (e) {
      // Best-effort: silently fail
    }
  }

  /// Clear all Firestore predictions for the current user (best-effort).
  Future<void> _clearFirestorePredictions() async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      final snapshot = await _firestore
          .collection(_firestorePredictionsCollection)
          .doc(userId)
          .collection('predictions')
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Clear leaderboard entry
      await _firestore
          .collection(_firestoreLeaderboardCollection)
          .doc(userId)
          .delete();
    } catch (e) {
      // Best-effort: silently fail
    }
  }

  /// Update the aggregated leaderboard document for the current user.
  Future<void> _updateLeaderboard(List<MatchPrediction> predictions) async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      final stats = PredictionStats.fromPredictions(predictions);
      await _firestore
          .collection(_firestoreLeaderboardCollection)
          .doc(userId)
          .set({
        'userId': userId,
        'displayName': _currentDisplayName ?? 'Anonymous',
        'totalPredictions': stats.totalPredictions,
        'correctExact': stats.exactScores,
        'correctOutcome': stats.correctResults,
        'totalPoints': stats.totalPoints,
        'pendingPredictions': stats.pendingPredictions,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Best-effort: silently fail
    }
  }

  /// Convert a MatchPrediction to a Firestore document map.
  Map<String, dynamic> _predictionToFirestoreMap(
    MatchPrediction prediction,
    String userId,
  ) {
    return {
      'userId': userId,
      'matchId': prediction.matchId,
      'predictionId': prediction.predictionId,
      'predictedHomeScore': prediction.predictedHomeScore,
      'predictedAwayScore': prediction.predictedAwayScore,
      'homeTeamCode': prediction.homeTeamCode,
      'homeTeamName': prediction.homeTeamName,
      'awayTeamCode': prediction.awayTeamCode,
      'awayTeamName': prediction.awayTeamName,
      'predictedOutcome': prediction.predictedOutcome.name,
      'actualOutcome': prediction.actualOutcome?.name,
      'pointsEarned': prediction.pointsEarned,
      'exactScoreCorrect': prediction.exactScoreCorrect,
      'resultCorrect': prediction.resultCorrect,
      'isCorrect': prediction.isCorrect ? true : null,
      'matchDate': prediction.matchDate?.toIso8601String(),
      'createdAt': prediction.createdAt.toIso8601String(),
      'updatedAt': prediction.updatedAt?.toIso8601String(),
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  /// Convert a Firestore document map to a MatchPrediction.
  MatchPrediction _firestoreMapToPrediction(Map<String, dynamic> data) {
    return MatchPrediction.fromMap({
      'predictionId': data['predictionId'] ?? '',
      'matchId': data['matchId'] ?? '',
      'userId': data['userId'],
      'predictedHomeScore': data['predictedHomeScore'] ?? 0,
      'predictedAwayScore': data['predictedAwayScore'] ?? 0,
      'predictedOutcome': data['predictedOutcome'],
      'actualOutcome': data['actualOutcome'],
      'pointsEarned': data['pointsEarned'] ?? 0,
      'exactScoreCorrect': data['exactScoreCorrect'] ?? false,
      'resultCorrect': data['resultCorrect'] ?? false,
      'homeTeamCode': data['homeTeamCode'],
      'homeTeamName': data['homeTeamName'],
      'awayTeamCode': data['awayTeamCode'],
      'awayTeamName': data['awayTeamName'],
      'matchDate': data['matchDate'],
      'createdAt': data['createdAt'] ?? DateTime.now().toIso8601String(),
      'updatedAt': data['updatedAt'],
    });
  }

  /// Dispose of resources
  void dispose() {
    _predictionsController.close();
    _statsController.close();
  }
}

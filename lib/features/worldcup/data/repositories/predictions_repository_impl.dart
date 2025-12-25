import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/predictions_repository.dart';

/// Implementation of PredictionsRepository using SharedPreferences
class PredictionsRepositoryImpl implements PredictionsRepository {
  static const String _predictionsKey = 'world_cup_predictions';
  static const String _statsKey = 'world_cup_prediction_stats';

  final SharedPreferences _sharedPreferences;
  final Uuid _uuid = const Uuid();

  final StreamController<List<MatchPrediction>> _predictionsController =
      StreamController<List<MatchPrediction>>.broadcast();
  final StreamController<PredictionStats> _statsController =
      StreamController<PredictionStats>.broadcast();

  List<MatchPrediction>? _cachedPredictions;

  PredictionsRepositoryImpl({
    required SharedPreferences sharedPreferences,
  }) : _sharedPreferences = sharedPreferences;

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

    // Check if prediction already exists for this match
    final existingIndex =
        predictions.indexWhere((p) => p.matchId == prediction.matchId);

    if (existingIndex >= 0) {
      predictions[existingIndex] = prediction;
    } else {
      predictions.add(prediction);
    }

    await _savePredictions(predictions);
    return prediction;
  }

  @override
  Future<MatchPrediction> updatePrediction(MatchPrediction prediction) async {
    final predictions = await getAllPredictions();
    final index = predictions.indexWhere((p) => p.predictionId == prediction.predictionId);

    if (index < 0) {
      throw Exception('Prediction not found');
    }

    predictions[index] = prediction.copyWith(updatedAt: DateTime.now());
    await _savePredictions(predictions);
    return predictions[index];
  }

  @override
  Future<void> deletePrediction(String predictionId) async {
    final predictions = await getAllPredictions();
    predictions.removeWhere((p) => p.predictionId == predictionId);
    await _savePredictions(predictions);
  }

  @override
  Future<void> deletePredictionForMatch(String matchId) async {
    final predictions = await getAllPredictions();
    predictions.removeWhere((p) => p.matchId == matchId);
    await _savePredictions(predictions);
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
        orElse: () => WorldCupMatch(
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
    }
  }

  @override
  Future<void> clearAllPredictions() async {
    _cachedPredictions = [];
    await _sharedPreferences.remove(_predictionsKey);
    await _sharedPreferences.remove(_statsKey);
    _predictionsController.add([]);
    _statsController.add(const PredictionStats());
  }

  /// Dispose of resources
  void dispose() {
    _predictionsController.close();
    _statsController.close();
  }
}

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/predictions_repository.dart';
import '../../domain/repositories/world_cup_match_repository.dart';
import 'predictions_state.dart';

/// Cubit for managing match predictions
class PredictionsCubit extends Cubit<PredictionsState> {
  final PredictionsRepository _predictionsRepository;
  final WorldCupMatchRepository? _matchRepository;

  StreamSubscription<List<MatchPrediction>>? _predictionsSubscription;
  StreamSubscription<PredictionStats>? _statsSubscription;

  PredictionsCubit({
    required PredictionsRepository predictionsRepository,
    WorldCupMatchRepository? matchRepository,
  })  : _predictionsRepository = predictionsRepository,
        _matchRepository = matchRepository,
        super(PredictionsState.initial());

  /// Initialize and load predictions
  Future<void> init() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final predictions = await _predictionsRepository.getAllPredictions();
      final stats = await _predictionsRepository.getPredictionStats();

      emit(state.copyWith(
        predictions: predictions,
        stats: stats,
        isLoading: false,
      ));

      // Subscribe to changes
      _subscribeToChanges();
    } catch (e) {
      // Debug output removed
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load predictions: $e',
      ));
    }
  }

  /// Subscribe to prediction changes
  void _subscribeToChanges() {
    _predictionsSubscription?.cancel();
    _predictionsSubscription = _predictionsRepository.watchPredictions().listen(
      (predictions) {
        emit(state.copyWith(predictions: predictions));
      },
      onError: (e) {
        // Debug output removed
      },
    );

    _statsSubscription?.cancel();
    _statsSubscription = _predictionsRepository.watchPredictionStats().listen(
      (stats) {
        emit(state.copyWith(stats: stats));
      },
      onError: (e) {
        // Debug output removed
      },
    );
  }

  /// Create or update a prediction for a match
  Future<void> savePrediction({
    required String matchId,
    required int homeScore,
    required int awayScore,
    String? homeTeamCode,
    String? homeTeamName,
    String? awayTeamCode,
    String? awayTeamName,
    DateTime? matchDate,
  }) async {
    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));

    try {
      final prediction = await _predictionsRepository.createPrediction(
        matchId: matchId,
        predictedHomeScore: homeScore,
        predictedAwayScore: awayScore,
        homeTeamCode: homeTeamCode,
        homeTeamName: homeTeamName,
        awayTeamCode: awayTeamCode,
        awayTeamName: awayTeamName,
        matchDate: matchDate,
      );

      // Update local state
      final updatedPredictions = List<MatchPrediction>.from(state.predictions);
      final existingIndex = updatedPredictions.indexWhere((p) => p.matchId == matchId);

      if (existingIndex >= 0) {
        updatedPredictions[existingIndex] = prediction;
      } else {
        updatedPredictions.add(prediction);
      }

      final stats = PredictionStats.fromPredictions(updatedPredictions);

      emit(state.copyWith(
        predictions: updatedPredictions,
        stats: stats,
        isSaving: false,
        successMessage: 'Prediction saved!',
      ));
    } catch (e) {
      // Debug output removed
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to save prediction: $e',
      ));
    }
  }

  /// Save prediction from a WorldCupMatch object
  Future<void> savePredictionForMatch(
    WorldCupMatch match, {
    required int homeScore,
    required int awayScore,
  }) async {
    await savePrediction(
      matchId: match.matchId,
      homeScore: homeScore,
      awayScore: awayScore,
      homeTeamCode: match.homeTeamCode,
      homeTeamName: match.homeTeamName,
      awayTeamCode: match.awayTeamCode,
      awayTeamName: match.awayTeamName,
      matchDate: match.dateTime,
    );
  }

  /// Delete a prediction
  Future<void> deletePrediction(String predictionId) async {
    try {
      await _predictionsRepository.deletePrediction(predictionId);

      final updatedPredictions = state.predictions
          .where((p) => p.predictionId != predictionId)
          .toList();
      final stats = PredictionStats.fromPredictions(updatedPredictions);

      emit(state.copyWith(
        predictions: updatedPredictions,
        stats: stats,
        successMessage: 'Prediction deleted',
      ));
    } catch (e) {
      // Debug output removed
      emit(state.copyWith(errorMessage: 'Failed to delete prediction: $e'));
    }
  }

  /// Delete prediction for a match
  Future<void> deletePredictionForMatch(String matchId) async {
    try {
      await _predictionsRepository.deletePredictionForMatch(matchId);

      final updatedPredictions = state.predictions
          .where((p) => p.matchId != matchId)
          .toList();
      final stats = PredictionStats.fromPredictions(updatedPredictions);

      emit(state.copyWith(
        predictions: updatedPredictions,
        stats: stats,
        successMessage: 'Prediction deleted',
      ));
    } catch (e) {
      // Debug output removed
      emit(state.copyWith(errorMessage: 'Failed to delete prediction: $e'));
    }
  }

  /// Evaluate all predictions against completed matches
  Future<void> evaluatePredictions() async {
    final matchRepo = _matchRepository;
    if (matchRepo == null) return;

    try {
      // Get all completed matches
      final allMatches = await matchRepo.getAllMatches();
      final completedMatches = allMatches
          .where((m) => m.status == MatchStatus.completed)
          .toList();

      // Evaluate predictions
      await _predictionsRepository.evaluatePredictions(completedMatches);

      // Reload predictions
      final predictions = await _predictionsRepository.getAllPredictions();
      final stats = PredictionStats.fromPredictions(predictions);

      emit(state.copyWith(
        predictions: predictions,
        stats: stats,
      ));

    } catch (e) {
      // Debug output removed
    }
  }

  /// Get prediction for a specific match
  MatchPrediction? getPredictionForMatch(String matchId) =>
      state.getPredictionForMatch(matchId);

  /// Check if prediction exists for a match
  bool hasPredictionForMatch(String matchId) =>
      state.hasPredictionForMatch(matchId);

  /// Select a match for prediction entry
  void selectMatchForPrediction(String matchId) {
    emit(state.copyWith(selectedMatchId: matchId));
  }

  /// Clear selected match
  void clearSelectedMatch() {
    emit(state.copyWith(clearSelectedMatch: true));
  }

  /// Clear all predictions
  Future<void> clearAllPredictions() async {
    try {
      await _predictionsRepository.clearAllPredictions();
      emit(state.copyWith(
        predictions: [],
        stats: const PredictionStats(),
        successMessage: 'All predictions cleared',
      ));
    } catch (e) {
      // Debug output removed
      emit(state.copyWith(errorMessage: 'Failed to clear predictions: $e'));
    }
  }

  /// Clear error message
  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  /// Clear success message
  void clearSuccess() {
    emit(state.copyWith(clearSuccess: true));
  }

  @override
  Future<void> close() {
    _predictionsSubscription?.cancel();
    _statsSubscription?.cancel();
    return super.close();
  }
}

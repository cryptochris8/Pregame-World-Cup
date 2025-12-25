import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/world_cup_ai_service.dart';
import '../../domain/entities/entities.dart';
import 'world_cup_ai_state.dart';

/// Cubit for managing World Cup AI predictions
///
/// Handles:
/// - Loading AI predictions on-demand
/// - Caching predictions with TTL
/// - Fallback when AI is unavailable
class WorldCupAICubit extends Cubit<WorldCupAIState> {
  final WorldCupAIService _aiService;

  WorldCupAICubit({
    required WorldCupAIService aiService,
  })  : _aiService = aiService,
        super(WorldCupAIState.initial());

  /// Load AI prediction for a match
  ///
  /// If a valid cached prediction exists, returns it immediately.
  /// Otherwise, fetches a new prediction from the AI service.
  Future<AIMatchPrediction?> loadPrediction(WorldCupMatch match) async {
    return loadPredictionWithTeams(match, null, null);
  }

  /// Load AI prediction with team details for better context
  Future<AIMatchPrediction?> loadPredictionWithTeams(
    WorldCupMatch match,
    NationalTeam? homeTeam,
    NationalTeam? awayTeam,
  ) async {
    final matchId = match.matchId;

    // Check for valid cached prediction
    if (state.hasPrediction(matchId)) {
      return state.getPrediction(matchId);
    }

    // Already loading this match
    if (state.isLoadingMatch(matchId)) {
      return null;
    }

    // Set loading state
    emit(state.withLoading(matchId));

    try {
      final prediction = await _aiService.generateMatchPrediction(
        match: match,
        homeTeam: homeTeam,
        awayTeam: awayTeam,
      );

      emit(state.withPrediction(prediction));
      return prediction;
    } catch (e) {
      emit(state.withError(matchId, e.toString()));

      // Return fallback prediction
      final fallback = AIMatchPrediction.fallback(
        matchId: matchId,
        homeTeamName: match.homeTeamName,
        awayTeamName: match.awayTeamName,
        homeRanking: homeTeam?.fifaRanking,
        awayRanking: awayTeam?.fifaRanking,
      );

      emit(state.withPrediction(fallback));
      return fallback;
    }
  }

  /// Get suggestion for prediction dialog (returns score suggestion)
  Future<Map<String, dynamic>> getSuggestion(
    WorldCupMatch match, {
    NationalTeam? homeTeam,
    NationalTeam? awayTeam,
  }) async {
    try {
      return await _aiService.suggestPrediction(
        match: match,
        homeTeam: homeTeam,
        awayTeam: awayTeam,
      );
    } catch (e) {
      // Return simple fallback
      return {
        'homeScore': 1,
        'awayScore': 1,
        'confidence': 40,
        'reasoning': 'Unable to generate AI suggestion',
        'provider': 'Fallback',
      };
    }
  }

  /// Get quick insight for match card
  Future<String> getQuickInsight(
    WorldCupMatch match, {
    NationalTeam? homeTeam,
    NationalTeam? awayTeam,
  }) async {
    // Check cached prediction first
    final cached = state.getPrediction(match.matchId);
    if (cached != null && cached.isValid) {
      return cached.quickInsight;
    }

    try {
      return await _aiService.generateQuickInsight(
        match: match,
        homeTeam: homeTeam,
        awayTeam: awayTeam,
      );
    } catch (e) {
      return 'AI prediction unavailable';
    }
  }

  /// Clear prediction for a specific match
  void clearPrediction(String matchId) {
    emit(state.withoutPrediction(matchId));
  }

  /// Clear all cached predictions
  void clearAllPredictions() {
    emit(WorldCupAIState.initial().copyWith(
      isAvailable: state.isAvailable,
    ));
  }

  /// Clear predictions that have expired
  void cleanupExpiredPredictions() {
    final validPredictions = <String, AIMatchPrediction>{};

    for (final entry in state.predictions.entries) {
      if (entry.value.isValid) {
        validPredictions[entry.key] = entry.value;
      }
    }

    if (validPredictions.length != state.predictions.length) {
      emit(state.copyWith(predictions: validPredictions));
    }
  }

  /// Refresh prediction for a match (force reload)
  Future<AIMatchPrediction?> refreshPrediction(
    WorldCupMatch match, {
    NationalTeam? homeTeam,
    NationalTeam? awayTeam,
  }) async {
    // Clear existing prediction
    clearPrediction(match.matchId);

    // Load fresh prediction
    return loadPredictionWithTeams(match, homeTeam, awayTeam);
  }

  /// Check if AI service is available
  bool get isAvailable => _aiService.isAvailable;

  /// Preload predictions for a list of matches
  Future<void> preloadPredictions(
    List<WorldCupMatch> matches, {
    Map<String, NationalTeam>? teamsByCode,
  }) async {
    for (final match in matches) {
      // Skip if already cached and valid
      if (state.hasPrediction(match.matchId)) continue;

      // Get team details if available
      final homeTeam = teamsByCode?[match.homeTeamCode];
      final awayTeam = teamsByCode?[match.awayTeamCode];

      // Load prediction (don't await to allow parallel loading)
      loadPredictionWithTeams(match, homeTeam, awayTeam);

      // Small delay to avoid rate limiting
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }
}

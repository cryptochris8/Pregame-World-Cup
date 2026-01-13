import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/cache_service.dart';
import '../../data/services/world_cup_ai_service.dart';
import '../../domain/entities/entities.dart';
import 'world_cup_ai_state.dart';

/// Cache key prefix for AI predictions
const String _aiPredictionCachePrefix = 'ai_prediction_';

/// Cubit for managing World Cup AI predictions
///
/// Handles:
/// - Loading AI predictions on-demand
/// - Caching predictions with TTL (24 hours in Hive)
/// - Fallback when AI is unavailable
class WorldCupAICubit extends Cubit<WorldCupAIState> {
  final WorldCupAIService _aiService;
  final CacheService _cacheService;

  /// Duration for Hive cache (24 hours)
  static const Duration _hiveCacheDuration = Duration(hours: 24);

  WorldCupAICubit({
    required WorldCupAIService aiService,
    CacheService? cacheService,
  })  : _aiService = aiService,
        _cacheService = cacheService ?? CacheService.instance,
        super(WorldCupAIState.initial());

  /// Get cache key for a match prediction
  String _getCacheKey(String matchId) => '$_aiPredictionCachePrefix$matchId';

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

    // Check for valid cached prediction in memory
    if (state.hasPrediction(matchId)) {
      return state.getPrediction(matchId);
    }

    // Check Hive persistent cache
    final cachedPrediction = await _loadFromHiveCache(matchId);
    if (cachedPrediction != null && cachedPrediction.isValid) {
      // Store in memory state and return
      emit(state.withPrediction(cachedPrediction));
      return cachedPrediction;
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

      // Save to Hive for persistent caching
      await _saveToHiveCache(prediction);

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

      // Save fallback to Hive too (but with shorter TTL via provider check on load)
      await _saveToHiveCache(fallback);

      emit(state.withPrediction(fallback));
      return fallback;
    }
  }

  /// Load prediction from Hive cache
  Future<AIMatchPrediction?> _loadFromHiveCache(String matchId) async {
    try {
      final cacheKey = _getCacheKey(matchId);
      final cachedData = await _cacheService.get<Map<String, dynamic>>(cacheKey);

      if (cachedData != null) {
        return AIMatchPrediction.fromMap(cachedData, matchId);
      }
    } catch (e) {
      // Ignore cache errors, will regenerate prediction
    }
    return null;
  }

  /// Save prediction to Hive cache
  Future<void> _saveToHiveCache(AIMatchPrediction prediction) async {
    try {
      final cacheKey = _getCacheKey(prediction.matchId);
      await _cacheService.set<Map<String, dynamic>>(
        cacheKey,
        prediction.toMap(),
        duration: _hiveCacheDuration,
      );
    } catch (e) {
      // Ignore cache errors, prediction still works in memory
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
    // Check memory cache first
    final cached = state.getPrediction(match.matchId);
    if (cached != null && cached.isValid) {
      return cached.quickInsight;
    }

    // Check Hive cache
    final hiveCached = await _loadFromHiveCache(match.matchId);
    if (hiveCached != null && hiveCached.isValid) {
      emit(state.withPrediction(hiveCached));
      return hiveCached.quickInsight;
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

  /// Clear prediction for a specific match (both memory and Hive)
  Future<void> clearPrediction(String matchId) async {
    emit(state.withoutPrediction(matchId));
    // Also clear from Hive cache
    try {
      await _cacheService.remove(_getCacheKey(matchId));
    } catch (e) {
      // Ignore cache errors
    }
  }

  /// Clear all cached predictions (both memory and Hive)
  Future<void> clearAllPredictions() async {
    // Clear memory state
    emit(WorldCupAIState.initial().copyWith(
      isAvailable: state.isAvailable,
    ));
    // Note: Hive entries will expire naturally via TTL
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
    // Clear existing prediction from memory and Hive
    await clearPrediction(match.matchId);

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

import '../../../../core/services/logging_service.dart';
import '../../domain/entities/entities.dart';
import 'local_prediction_engine.dart';

/// AI Service for World Cup match predictions and analysis
///
/// Routes all prediction requests through [LocalPredictionEngine],
/// which generates rich, data-driven predictions entirely from
/// local JSON data (no external API calls).
///
/// Provides:
/// - Match predictions with scores and probabilities
/// - Tactical analysis and key factors
/// - Quick insights for match cards
/// - Enhanced context: squad values, recent form, historical patterns,
///   manager matchups, confederation records, betting odds, injuries
class WorldCupAIService {
  final LocalPredictionEngine _localEngine;

  static const String _logTag = 'WorldCupAIService';

  WorldCupAIService({
    required LocalPredictionEngine localEngine,
  }) : _localEngine = localEngine;

  /// Generate a full match prediction with analysis
  Future<AIMatchPrediction> generateMatchPrediction({
    required WorldCupMatch match,
    NationalTeam? homeTeam,
    NationalTeam? awayTeam,
  }) async {
    try {
      LoggingService.info(
        'Generating prediction for ${match.homeTeamName} vs ${match.awayTeamName}',
        tag: _logTag,
      );

      return await _localEngine.generatePrediction(
        match: match,
        homeTeam: homeTeam,
        awayTeam: awayTeam,
      );
    } catch (e) {
      LoggingService.error(
        'Failed to generate prediction: $e',
        tag: _logTag,
      );

      // Return fallback prediction
      return AIMatchPrediction.fallback(
        matchId: match.matchId,
        homeTeamName: match.homeTeamName,
        awayTeamName: match.awayTeamName,
        homeRanking: homeTeam?.fifaRanking,
        awayRanking: awayTeam?.fifaRanking,
      );
    }
  }

  /// Generate a quick one-liner insight for match cards
  Future<String> generateQuickInsight({
    required WorldCupMatch match,
    NationalTeam? homeTeam,
    NationalTeam? awayTeam,
  }) async {
    try {
      final prediction = await _localEngine.generatePrediction(
        match: match,
        homeTeam: homeTeam,
        awayTeam: awayTeam,
      );
      return prediction.quickInsight;
    } catch (e) {
      LoggingService.error('Failed to generate quick insight: $e', tag: _logTag);
      return _generateFallbackQuickInsight(match, homeTeam, awayTeam);
    }
  }

  /// Suggest a prediction score for the user (used in prediction dialog)
  Future<Map<String, dynamic>> suggestPrediction({
    required WorldCupMatch match,
    NationalTeam? homeTeam,
    NationalTeam? awayTeam,
  }) async {
    try {
      final prediction = await generateMatchPrediction(
        match: match,
        homeTeam: homeTeam,
        awayTeam: awayTeam,
      );

      return {
        'homeScore': prediction.predictedHomeScore,
        'awayScore': prediction.predictedAwayScore,
        'confidence': prediction.confidence,
        'reasoning': prediction.keyFactors.isNotEmpty
            ? prediction.keyFactors.first
            : 'Based on team analysis',
        'provider': prediction.provider,
      };
    } catch (e) {
      LoggingService.error('Failed to suggest prediction: $e', tag: _logTag);

      // Fallback suggestion
      return _generateFallbackSuggestion(homeTeam, awayTeam);
    }
  }

  /// Generate fallback quick insight
  String _generateFallbackQuickInsight(
    WorldCupMatch match,
    NationalTeam? homeTeam,
    NationalTeam? awayTeam,
  ) {
    final homeRank = homeTeam?.fifaRanking ?? 50;
    final awayRank = awayTeam?.fifaRanking ?? 50;

    if (homeRank < awayRank - 10) {
      return '${homeTeam?.shortName ?? match.homeTeamName} 2-1 (60%)';
    } else if (awayRank < homeRank - 10) {
      return '${awayTeam?.shortName ?? match.awayTeamName} 1-2 (60%)';
    } else {
      return 'Draw 1-1 (45%)';
    }
  }

  /// Generate fallback suggestion
  Map<String, dynamic> _generateFallbackSuggestion(
    NationalTeam? homeTeam,
    NationalTeam? awayTeam,
  ) {
    final homeRank = homeTeam?.fifaRanking ?? 50;
    final awayRank = awayTeam?.fifaRanking ?? 50;

    if (homeRank < awayRank) {
      return {
        'homeScore': 2,
        'awayScore': 1,
        'confidence': 55,
        'reasoning': 'Home team has higher FIFA ranking',
        'provider': 'Fallback',
      };
    } else if (awayRank < homeRank) {
      return {
        'homeScore': 1,
        'awayScore': 2,
        'confidence': 55,
        'reasoning': 'Away team has higher FIFA ranking',
        'provider': 'Fallback',
      };
    } else {
      return {
        'homeScore': 1,
        'awayScore': 1,
        'confidence': 45,
        'reasoning': 'Teams are evenly matched',
        'provider': 'Fallback',
      };
    }
  }

  /// Local engine is always available (no API keys needed)
  bool get isAvailable => true;
}

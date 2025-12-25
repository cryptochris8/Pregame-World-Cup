import 'dart:convert';
import '../../../../core/ai/services/multi_provider_ai_service.dart';
import '../../../../core/services/logging_service.dart';
import '../../domain/entities/entities.dart';

/// AI Service for World Cup match predictions and analysis
///
/// Uses MultiProviderAIService (Claude/OpenAI) to generate:
/// - Match predictions with scores and probabilities
/// - Tactical analysis and key factors
/// - Quick insights for match cards
class WorldCupAIService {
  final MultiProviderAIService _multiProviderAI;

  static const String _logTag = 'WorldCupAIService';

  WorldCupAIService({
    required MultiProviderAIService multiProviderAI,
  }) : _multiProviderAI = multiProviderAI;

  /// Generate a full match prediction with analysis
  Future<AIMatchPrediction> generateMatchPrediction({
    required WorldCupMatch match,
    NationalTeam? homeTeam,
    NationalTeam? awayTeam,
  }) async {
    try {
      LoggingService.info(
        'Generating AI prediction for ${match.homeTeamName} vs ${match.awayTeamName}',
        tag: _logTag,
      );

      // Build game context with prompt elements for the AI
      final gameContext = _buildGameContext(match, homeTeam, awayTeam);

      // Include prediction prompt details in the context
      gameContext['predictionPrompt'] = _buildPredictionPrompt(match, homeTeam, awayTeam);
      gameContext['systemContext'] = _buildSystemMessage();

      final result = await _multiProviderAI.generateEnhancedGamePrediction(
        homeTeam: match.homeTeamName,
        awayTeam: match.awayTeamName,
        gameStats: gameContext,
      );

      // Parse AI response into structured prediction
      return _parseAIPrediction(result, match.matchId, homeTeam, awayTeam);
    } catch (e) {
      LoggingService.error(
        'Failed to generate AI prediction: $e',
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
      final prompt = '''
Provide a single short sentence (max 50 characters) predicting the outcome of this World Cup match:
${match.homeTeamName} vs ${match.awayTeamName}
Stage: ${match.stage.displayName}
${homeTeam != null ? 'Home FIFA Ranking: #${homeTeam.fifaRanking}' : ''}
${awayTeam != null ? 'Away FIFA Ranking: #${awayTeam.fifaRanking}' : ''}

Format: "[Team] [score]-[score] ([confidence]%)"
Example: "Brazil 2-1 (72%)"
''';

      final response = await _multiProviderAI.generateQuickResponse(
        prompt: prompt,
        systemMessage: 'You are a concise World Cup analyst. Respond with only the prediction format specified.',
      );

      return response.trim();
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

  /// Build the prediction prompt for the AI
  String _buildPredictionPrompt(
    WorldCupMatch match,
    NationalTeam? homeTeam,
    NationalTeam? awayTeam,
  ) {
    final buffer = StringBuffer();

    buffer.writeln('Analyze this FIFA World Cup 2026 match:');
    buffer.writeln();
    buffer.writeln('Match: ${match.homeTeamName} vs ${match.awayTeamName}');
    buffer.writeln('Stage: ${match.stage.displayName}');

    if (match.group != null) {
      buffer.writeln('Group: ${match.group}');
    }

    if (match.venue != null) {
      buffer.writeln('Venue: ${match.venue!.name}, ${match.venue!.city}');
    }

    buffer.writeln();

    // Home team info
    if (homeTeam != null) {
      buffer.writeln('${match.homeTeamName}:');
      if (homeTeam.fifaRanking != null) {
        buffer.writeln('  - FIFA Ranking: #${homeTeam.fifaRanking}');
      }
      buffer.writeln('  - World Cup Titles: ${homeTeam.worldCupTitles}');
      buffer.writeln('  - World Cup Appearances: ${homeTeam.worldCupAppearances}');
      if (homeTeam.isHostNation) {
        buffer.writeln('  - HOST NATION (home advantage)');
      }
      buffer.writeln('  - Confederation: ${homeTeam.confederation.displayName}');
      if (homeTeam.starPlayers.isNotEmpty) {
        buffer.writeln('  - Key Players: ${homeTeam.starPlayers.take(3).join(", ")}');
      }
    }

    buffer.writeln();

    // Away team info
    if (awayTeam != null) {
      buffer.writeln('${match.awayTeamName}:');
      if (awayTeam.fifaRanking != null) {
        buffer.writeln('  - FIFA Ranking: #${awayTeam.fifaRanking}');
      }
      buffer.writeln('  - World Cup Titles: ${awayTeam.worldCupTitles}');
      buffer.writeln('  - World Cup Appearances: ${awayTeam.worldCupAppearances}');
      if (awayTeam.isHostNation) {
        buffer.writeln('  - HOST NATION (home advantage)');
      }
      buffer.writeln('  - Confederation: ${awayTeam.confederation.displayName}');
      if (awayTeam.starPlayers.isNotEmpty) {
        buffer.writeln('  - Key Players: ${awayTeam.starPlayers.take(3).join(", ")}');
      }
    }

    buffer.writeln();
    buffer.writeln('Provide your prediction in JSON format with these fields:');
    buffer.writeln('- predictedHomeScore (int)');
    buffer.writeln('- predictedAwayScore (int)');
    buffer.writeln('- confidence (int 0-100)');
    buffer.writeln('- homeWinProbability (int 0-100)');
    buffer.writeln('- drawProbability (int 0-100)');
    buffer.writeln('- awayWinProbability (int 0-100)');
    buffer.writeln('- keyFactors (array of 3-5 strings)');
    buffer.writeln('- analysis (detailed text, 2-3 sentences)');
    buffer.writeln('- quickInsight (max 50 chars, format: "Team X-X (NN%)")');

    return buffer.toString();
  }

  /// Build system message for AI
  String _buildSystemMessage() {
    return '''
You are an expert FIFA World Cup analyst with deep knowledge of international football.
Your predictions are based on:
- FIFA World Rankings
- Historical World Cup performance
- Head-to-head records
- Current team form
- Key player availability
- Tactical matchups
- Tournament stage pressure (group vs knockout)
- Home/host nation advantage

Provide realistic score predictions (most World Cup games end 0-0, 1-0, 1-1, 2-1, or 2-0).
Be conservative with high-scoring predictions.
Consider the defensive nature of knockout stage matches.

Always respond with valid JSON.
''';
  }

  /// Build game context for MultiProviderAIService
  Map<String, dynamic> _buildGameContext(
    WorldCupMatch match,
    NationalTeam? homeTeam,
    NationalTeam? awayTeam,
  ) {
    return {
      'tournament': 'FIFA World Cup 2026',
      'stage': match.stage.displayName,
      'group': match.group,
      'venue': match.venue?.name,
      'venueCity': match.venue?.city,
      'homeTeam': {
        'name': match.homeTeamName,
        'fifaRanking': homeTeam?.fifaRanking,
        'worldCupTitles': homeTeam?.worldCupTitles ?? 0,
        'worldCupAppearances': homeTeam?.worldCupAppearances ?? 0,
        'isHostNation': homeTeam?.isHostNation ?? false,
        'confederation': homeTeam?.confederation.displayName,
      },
      'awayTeam': {
        'name': match.awayTeamName,
        'fifaRanking': awayTeam?.fifaRanking,
        'worldCupTitles': awayTeam?.worldCupTitles ?? 0,
        'worldCupAppearances': awayTeam?.worldCupAppearances ?? 0,
        'isHostNation': awayTeam?.isHostNation ?? false,
        'confederation': awayTeam?.confederation.displayName,
      },
      'isKnockout': match.stage.isKnockout,
    };
  }

  /// Parse AI response into AIMatchPrediction
  AIMatchPrediction _parseAIPrediction(
    Map<String, dynamic> result,
    String matchId,
    NationalTeam? homeTeam,
    NationalTeam? awayTeam,
  ) {
    // Try to extract prediction data from the result
    int homeScore = 1;
    int awayScore = 1;
    int confidence = 50;
    int homeProb = 33;
    int drawProb = 34;
    int awayProb = 33;
    List<String> keyFactors = [];
    String analysis = '';
    String quickInsight = '';
    String provider = result['provider'] as String? ?? 'AI';

    // Parse prediction text if available
    final predictionText = result['prediction'] as String?;
    if (predictionText != null) {
      // Try to extract JSON from the prediction
      try {
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(predictionText);
        if (jsonMatch != null) {
          final jsonData = json.decode(jsonMatch.group(0)!) as Map<String, dynamic>;
          homeScore = jsonData['predictedHomeScore'] as int? ?? homeScore;
          awayScore = jsonData['predictedAwayScore'] as int? ?? awayScore;
          confidence = jsonData['confidence'] as int? ?? confidence;
          homeProb = jsonData['homeWinProbability'] as int? ?? homeProb;
          drawProb = jsonData['drawProbability'] as int? ?? drawProb;
          awayProb = jsonData['awayWinProbability'] as int? ?? awayProb;
          keyFactors = (jsonData['keyFactors'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [];
          analysis = jsonData['analysis'] as String? ?? '';
          quickInsight = jsonData['quickInsight'] as String? ?? '';
        }
      } catch (_) {
        // JSON parsing failed, use defaults
      }
    }

    // Use result's keyFactors and analysis if available
    if (keyFactors.isEmpty && result['keyFactors'] != null) {
      keyFactors = (result['keyFactors'] as List<dynamic>)
          .map((e) => e.toString())
          .toList();
    }

    if (analysis.isEmpty && result['analysis'] != null) {
      analysis = result['analysis'] as String;
    }

    // Use confidence from result if available
    if (result['confidence'] != null) {
      confidence = result['confidence'] as int;
    }

    // Generate quick insight if not available
    if (quickInsight.isEmpty) {
      final winner = homeScore > awayScore
          ? homeTeam?.shortName ?? 'Home'
          : awayScore > homeScore
              ? awayTeam?.shortName ?? 'Away'
              : 'Draw';
      quickInsight = '$winner $homeScore-$awayScore ($confidence%)';
    }

    // Determine outcome
    AIPredictedOutcome outcome;
    if (homeScore > awayScore) {
      outcome = AIPredictedOutcome.homeWin;
    } else if (awayScore > homeScore) {
      outcome = AIPredictedOutcome.awayWin;
    } else {
      outcome = AIPredictedOutcome.draw;
    }

    return AIMatchPrediction(
      matchId: matchId,
      predictedOutcome: outcome,
      predictedHomeScore: homeScore,
      predictedAwayScore: awayScore,
      confidence: confidence,
      homeWinProbability: homeProb,
      drawProbability: drawProb,
      awayWinProbability: awayProb,
      keyFactors: keyFactors.isNotEmpty
          ? keyFactors
          : [
              'FIFA rankings comparison',
              'Historical World Cup performance',
              'Tournament stage dynamics',
            ],
      analysis: analysis.isNotEmpty
          ? analysis
          : 'Prediction based on team statistics and historical data.',
      quickInsight: quickInsight,
      provider: provider,
      generatedAt: DateTime.now(),
    );
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

  /// Check if AI service is available
  bool get isAvailable => _multiProviderAI.isAnyServiceAvailable;
}

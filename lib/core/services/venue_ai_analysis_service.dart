import '../ai/services/ai_service.dart';
import '../../features/recommendations/domain/entities/place.dart';
import '../../features/schedule/domain/entities/game_schedule.dart';
import 'logging_service.dart';
import 'venue_models.dart';

/// Generates AI-powered venue analysis using the [AIService].
///
/// Extracted from [UnifiedVenueService] to keep the facade lean.
class VenueAIAnalysisService {
  final AIService _aiService;

  VenueAIAnalysisService({AIService? aiService})
      : _aiService = aiService ?? AIService();

  /// Generate an AI-powered analysis for a single venue.
  Future<AIVenueAnalysis> generateAnalysis(
    Place venue,
    GameSchedule? game,
    String context,
    Map<String, dynamic>? userBehavior,
  ) async {
    try {
      final prompt = '''
Analyze this venue for a World Cup match day context:

Venue: ${venue.name}
Rating: ${venue.rating ?? 'N/A'}/5
Price Level: ${venue.priceLevel ?? 'N/A'}
Types: ${venue.types?.join(', ') ?? 'N/A'}
Context: $context
Game: ${game?.homeTeamName ?? 'N/A'} vs ${game?.awayTeamName ?? 'N/A'}

Provide a brief analysis focusing on:
1. Overall suitability score (0-1)
2. Crowd prediction (Light/Moderate/Heavy)
3. Game watching quality
4. Social atmosphere
5. Key insights
''';

      final response = await _aiService.generateCompletion(
        prompt: prompt,
        maxTokens: 300,
        temperature: 0.7,
      );

      final analysis = _parseResponse(response, venue, context);

      return AIVenueAnalysis(
        overallScore: analysis['score'] ?? 0.5,
        confidence: analysis['confidence'] ?? 0.7,
        crowdPrediction: analysis['crowdPrediction'] ?? 'Moderate',
        atmosphereRating: analysis['atmosphereRating'] ?? 0.5,
        gameWatchingScore: analysis['gameWatchingScore'] ?? 0.5,
        socialScore: analysis['socialScore'] ?? 0.5,
        insights: analysis['insights'] ?? ['AI-powered venue analysis'],
        recommendations: analysis['recommendations'] ?? ['Great choice for game day'],
      );
    } catch (e) {
      LoggingService.error('Error generating AI analysis for venue: $e', tag: 'UnifiedVenue');
      return AIVenueAnalysis.fallback();
    }
  }

  /// Parse the raw AI response into structured analysis data.
  Map<String, dynamic> _parseResponse(String response, Place venue, String context) {
    final lowerResponse = response.toLowerCase();

    // Extract overall score based on positive/negative sentiment
    double score = 0.5;
    if (lowerResponse.contains('excellent') || lowerResponse.contains('perfect')) {
      score = 0.9;
    } else if (lowerResponse.contains('great') || lowerResponse.contains('good')) {
      score = 0.8;
    } else if (lowerResponse.contains('decent') || lowerResponse.contains('okay')) {
      score = 0.6;
    } else if (lowerResponse.contains('poor') || lowerResponse.contains('bad')) {
      score = 0.3;
    }

    // Adjust score based on venue characteristics
    if (venue.rating != null && venue.rating! >= 4.0) {
      score += 0.1;
    }

    // Crowd prediction based on context and venue type
    String crowdPrediction = 'Moderate';
    final venueTypes = venue.types?.join(' ').toLowerCase() ?? '';
    if (venueTypes.contains('bar') || venueTypes.contains('restaurant')) {
      if (context == 'watch_party' || context == 'pre_game') {
        crowdPrediction = 'Heavy';
      }
    }

    // Generate insights based on analysis
    final insights = <String>[];
    if (venue.rating != null && venue.rating! >= 4.0) {
      insights.add('Highly rated venue (${venue.rating}/5)');
    }
    if (venueTypes.contains('sports') || venueTypes.contains('bar')) {
      insights.add('Great for watching games');
    }
    if (context == 'pre_game') {
      insights.add('Perfect pre-game atmosphere');
    }

    return {
      'score': score.clamp(0.0, 1.0),
      'confidence': 0.75,
      'crowdPrediction': crowdPrediction,
      'atmosphereRating': score,
      'gameWatchingScore': venueTypes.contains('sports') || venueTypes.contains('bar') ? 0.8 : 0.5,
      'socialScore': crowdPrediction == 'Heavy' ? 0.8 : 0.6,
      'insights': insights.isNotEmpty ? insights : ['AI-analyzed venue'],
      'recommendations': ['Recommended for game day experience'],
    };
  }
}

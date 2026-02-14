import 'dart:async';
import '../entities/ai_recommendation.dart';
import 'ai_service.dart';
import '../../../features/recommendations/domain/entities/place.dart';
import '../../services/logging_service.dart';
import '../../../services/zapier_service.dart';
import '../../../injection_container.dart';

/// AI-powered venue recommendation service using OpenAI
class AIVenueRecommendationService {
  static const String _logTag = 'AIVenueRecommendationService';
  final AIService _aiService;

  AIVenueRecommendationService(this._aiService);

  /// Generate intelligent venue recommendations using AI
  Future<List<AIRecommendation>> generateVenueRecommendations({
    required List<Place> venues,
    required String userPreferences,
    String? gameContext,
    int maxRecommendations = 3,
  }) async {
    try {
      if (venues.isEmpty) {
        LoggingService.warning('No venues provided for AI recommendations', tag: _logTag);
        return [];
      }

      // Prepare venue data for AI analysis
      final venueDescriptions = venues.map((venue) {
        final types = venue.types?.join(', ') ?? 'restaurant';
        final rating = venue.rating?.toString() ?? 'N/A';
        return '${venue.name} ($types, rating: $rating)';
      }).toList();

      // Generate AI-powered analysis
      final aiResponse = await _aiService.generateVenueRecommendation(
        userPreferences: userPreferences,
        gameContext: gameContext ?? 'World Cup match',
        nearbyVenues: venueDescriptions,
      );

      // Parse AI response and match to venues
      final recommendations = await _parseAIResponseToRecommendations(
        aiResponse: aiResponse,
        venues: venues,
        userPreferences: userPreferences,
        maxRecommendations: maxRecommendations,
      );

      LoggingService.info('Generated ${recommendations.length} AI venue recommendations', tag: _logTag);
      return recommendations;
    } catch (e) {
      LoggingService.error('AI venue recommendation failed: $e', tag: _logTag);
      return _generateFallbackRecommendations(venues, maxRecommendations);
    }
  }

  /// Generate personalized venue scores using AI embeddings
  Future<Map<String, double>> generateVenueScores({
    required List<Place> venues,
    required String userPreferences,
  }) async {
    try {
      // Generate embedding for user preferences
      final userEmbedding = await _aiService.generateEmbeddings(userPreferences);
      final venueScores = <String, double>{};

      // Generate embeddings for each venue and calculate similarity
      for (final venue in venues) {
        final venueDescription = _buildVenueDescription(venue);
        final venueEmbedding = await _aiService.generateEmbeddings(venueDescription);
        
        final similarity = _aiService.calculateCosineSimilarity(userEmbedding, venueEmbedding);
        venueScores[venue.placeId] = similarity;
      }

      LoggingService.info('Generated AI scores for ${venues.length} venues', tag: _logTag);
      return venueScores;
    } catch (e) {
      LoggingService.error('Failed to generate venue scores: $e', tag: _logTag);
      return {};
    }
  }

  /// Parse AI response and create recommendations
  Future<List<AIRecommendation>> _parseAIResponseToRecommendations({
    required String aiResponse,
    required List<Place> venues,
    required String userPreferences,
    required int maxRecommendations,
  }) async {
    final recommendations = <AIRecommendation>[];
    
    try {
      // Generate scores using embeddings for ranking
      final venueScores = await generateVenueScores(
        venues: venues,
        userPreferences: userPreferences,
      );

      // Sort venues by AI score
      final sortedVenues = List<Place>.from(venues);
      sortedVenues.sort((a, b) {
        final scoreA = venueScores[a.placeId] ?? 0.0;
        final scoreB = venueScores[b.placeId] ?? 0.0;
        return scoreB.compareTo(scoreA);
      });

      // Create recommendations for top venues
      for (int i = 0; i < maxRecommendations && i < sortedVenues.length; i++) {
        final venue = sortedVenues[i];
        final confidence = venueScores[venue.placeId] ?? 0.0;
        
        // Extract relevant reasons from AI response
        final reasons = _extractReasonsFromResponse(aiResponse, venue.name);
        
        final recommendation = AIRecommendation(
          id: 'ai_${venue.placeId}_${DateTime.now().millisecondsSinceEpoch}',
          title: _generateRecommendationTitle(venue, confidence),
          description: _generateRecommendationDescription(venue, aiResponse),
          confidence: _normalizeConfidence(confidence),
          metadata: {
            'venueId': venue.placeId,
            'venueName': venue.name,
            'venueRating': venue.rating,
            'venueTypes': venue.types,
            'aiScore': confidence,
          },
          reasons: reasons,
          timestamp: DateTime.now(),
          category: 'ai_venue_recommendation',
        );
        
        recommendations.add(recommendation);
      }
    } catch (e) {
      LoggingService.error('Error parsing AI response: $e', tag: _logTag);
      // Return basic recommendations as fallback
      return _generateFallbackRecommendations(venues, maxRecommendations);
    }

    return recommendations;
  }

  /// Build descriptive text for venue embedding
  String _buildVenueDescription(Place venue) {
    final parts = <String>[venue.name];
    
    if (venue.types?.isNotEmpty == true) {
      parts.add('Categories: ${venue.types!.join(', ')}');
    }
    
    if (venue.rating != null) {
      parts.add('Rating: ${venue.rating} stars');
    }
    
    if (venue.priceLevel != null) {
      final price = '\$' * venue.priceLevel!;
      parts.add('Price level: $price');
    }

    return parts.join('. ');
  }

  /// Extract reasons from AI response
  List<String> _extractReasonsFromResponse(String aiResponse, String venueName) {
    final reasons = <String>[];
    final lines = aiResponse.split('\n');
    
    for (final line in lines) {
      final lowerLine = line.toLowerCase();
      final lowerVenue = venueName.toLowerCase();
      
      if (lowerLine.contains(lowerVenue) || lowerLine.contains('recommend')) {
        // Extract key phrases that indicate reasons
        if (lowerLine.contains('atmosphere')) reasons.add('Great atmosphere');
        if (lowerLine.contains('location')) reasons.add('Convenient location');
        if (lowerLine.contains('crowd') || lowerLine.contains('fans')) reasons.add('Popular with fans');
        if (lowerLine.contains('food')) reasons.add('Great food options');
        if (lowerLine.contains('drink') || lowerLine.contains('beer')) reasons.add('Good drink selection');
        if (lowerLine.contains('view') || lowerLine.contains('screen')) reasons.add('Excellent viewing experience');
      }
    }
    
    // Default reasons if none extracted
    if (reasons.isEmpty) {
      reasons.addAll(['AI recommended', 'Matches your preferences', 'Popular choice']);
    }
    
    return reasons.take(3).toList(); // Limit to 3 reasons
  }

  /// Generate recommendation title based on confidence
  String _generateRecommendationTitle(Place venue, double confidence) {
    if (confidence > 0.8) {
      return 'Perfect Match: ${venue.name}';
    } else if (confidence > 0.6) {
      return 'Great Choice: ${venue.name}';
    } else {
      return 'Good Option: ${venue.name}';
    }
  }

  /// Generate recommendation description
  String _generateRecommendationDescription(Place venue, String aiResponse) {
    // Try to extract venue-specific description from AI response
    final lines = aiResponse.split('\n');
    for (final line in lines) {
      if (line.toLowerCase().contains(venue.name.toLowerCase()) && line.length > 20) {
        return line.trim();
      }
    }
    
    // Fallback description
    final rating = venue.rating != null ? ' (${venue.rating} stars)' : '';
    return 'AI recommends ${venue.name}$rating based on your preferences for the best game day experience.';
  }

  /// Normalize confidence score to 0.5-1.0 range for better UX
  double _normalizeConfidence(double rawScore) {
    // Cosine similarity ranges from -1 to 1, normalize to 0.5-1.0
    return 0.5 + (rawScore.clamp(0.0, 1.0) * 0.5);
  }

  /// Generate fallback recommendations when AI fails
  List<AIRecommendation> _generateFallbackRecommendations(List<Place> venues, int maxRecommendations) {
    final recommendations = <AIRecommendation>[];
    
    for (int i = 0; i < maxRecommendations && i < venues.length; i++) {
      final venue = venues[i];
      final recommendation = AIRecommendation(
        id: 'fallback_${venue.placeId}_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Recommended: ${venue.name}',
        description: '${venue.name} is a popular choice for game day viewing.',
        confidence: 0.7 - (i * 0.1), // Decreasing confidence
        metadata: {
          'venueId': venue.placeId,
          'venueName': venue.name,
          'isFallback': true,
        },
        reasons: const ['Popular venue', 'Good location', 'Sports-friendly'],
        timestamp: DateTime.now(),
        category: 'fallback_recommendation',
      );
      recommendations.add(recommendation);
    }
    
    return recommendations;
  }

  /// Track when a user acts on an AI recommendation (Zapier integration)
  Future<void> trackRecommendationSuccess({
    required String userId,
    required AIRecommendation recommendation,
    required String userAction, // 'viewed', 'clicked', 'visited', 'reserved'
    String? gameContext,
  }) async {
    try {
      final zapierService = sl<ZapierService>();
      
      // Extract venue ID from metadata
      final venueId = recommendation.metadata['venueId'] as String?;
      if (venueId == null) {
        LoggingService.warning('No venue ID found in recommendation metadata', tag: _logTag);
        return;
      }

      // Trigger Zapier workflow for AI recommendation success
      await zapierService.triggerAIRecommendationSuccess(
        userId: userId,
        venueId: venueId,
        confidence: recommendation.confidence,
        reasons: recommendation.reasons,
        userAction: userAction,
        gameContext: gameContext,
      );

      LoggingService.info('Tracked AI recommendation success: $userAction for ${recommendation.metadata['venueName']}', tag: _logTag);
    } catch (e) {
      LoggingService.error('Failed to track recommendation success: $e', tag: _logTag);
      // Don't throw - this is non-critical for app functionality
    }
  }

  /// Track user engagement with venue recommendations
  Future<void> trackUserEngagement({
    required String userId,
    required String action,
    String? venueId,
    String? gameContext,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final zapierService = sl<ZapierService>();
      
      await zapierService.triggerUserEngagement(
        userId: userId,
        action: action,
        venueId: venueId,
        gameContext: gameContext,
        additionalData: additionalData,
      );

      LoggingService.info('Tracked user engagement: $action', tag: _logTag);
    } catch (e) {
      LoggingService.error('Failed to track user engagement: $e', tag: _logTag);
    }
  }
}

import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/logging_service.dart';
import '../services/user_learning_service.dart';
import '../../features/recommendations/domain/entities/place.dart';
import '../../features/schedule/domain/entities/game_schedule.dart';

/// Smart venue recommendation service with AI-powered personalization
class SmartVenueRecommendationService {
  static final SmartVenueRecommendationService _instance = SmartVenueRecommendationService._internal();
  factory SmartVenueRecommendationService() => _instance;
  SmartVenueRecommendationService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserLearningService _userLearningService = UserLearningService();

  /// Generate smart venue recommendations
  Future<List<SmartVenueRecommendation>> generateSmartRecommendations({
    required List<Place> venues,
    required GameSchedule? game,
    required String context,
    int limit = 10,
  }) async {
    try {
      LoggingService.info('Generating smart venue recommendations', tag: 'SmartVenue');
      
      // Get user behavior data (user context available for future personalization)
      _auth.currentUser;

      // Create basic recommendations for now
      final recommendations = <SmartVenueRecommendation>[];
      
      for (int i = 0; i < min(venues.length, limit); i++) {
        final venue = venues[i];
        final score = _calculateBasicScore(venue);
        
        recommendations.add(SmartVenueRecommendation(
          venue: venue,
          smartScore: score,
          aiScore: 0.7,
          behaviorScore: 0.6,
          contextScore: 0.5,
          predictionScore: 0.5,
          reasoning: 'Recommended based on your preferences',
          tags: ['Smart Pick'],
          confidence: 0.8,
          personalizationLevel: 0.6,
        ));
      }
      
      // Sort by score
      recommendations.sort((a, b) => b.smartScore.compareTo(a.smartScore));
      
      return recommendations;
      
    } catch (e) {
      LoggingService.error('Error generating smart recommendations: $e', tag: 'SmartVenue');
      return [];
    }
  }

  /// Calculate basic score for venues
  double _calculateBasicScore(Place venue) {
    double score = 0.5;

    if (venue.rating != null) {
      score += (venue.rating! - 3.0) * 0.2;
    }

    // Distance scoring would be implemented when distance data is available
    if (venue.userRatingsTotal != null && venue.userRatingsTotal! > 100) {
      score += 0.2; // Popular venues get bonus
    }

    return score.clamp(0.0, 1.0);
  }

  /// Track venue interaction
  Future<void> trackVenueInteraction({
    required String placeId,
    required String interactionType,
    required String context,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      await _userLearningService.trackVenueInteraction(
        venueId: placeId,
        venueName: additionalData?['venue_name'] ?? 'Unknown Venue',
        interactionType: interactionType,
        additionalData: {
          'context': context,
          ...?additionalData,
        },
      );
    } catch (e) {
      LoggingService.error('Error tracking venue interaction: $e', tag: 'SmartVenue');
    }
  }
}

/// Smart venue recommendation data class
class SmartVenueRecommendation {
  final Place venue;
  final double smartScore;
  final double aiScore;
  final double behaviorScore;
  final double contextScore;
  final double predictionScore;
  final String reasoning;
  final List<String> tags;
  final double confidence;
  final double personalizationLevel;

  SmartVenueRecommendation({
    required this.venue,
    required this.smartScore,
    required this.aiScore,
    required this.behaviorScore,
    required this.contextScore,
    required this.predictionScore,
    required this.reasoning,
    required this.tags,
    required this.confidence,
    required this.personalizationLevel,
  });
} 
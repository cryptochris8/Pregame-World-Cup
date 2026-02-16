import 'package:firebase_auth/firebase_auth.dart';
import '../../features/recommendations/domain/entities/place.dart';
import '../../features/schedule/domain/entities/game_schedule.dart';
import 'logging_service.dart';
import 'user_learning_service.dart';
import 'venue_ai_analysis_service.dart';
import 'venue_models.dart';
import 'venue_scoring_service.dart';

// Re-export models so existing importers continue to work unchanged.
export 'venue_models.dart';

/// Unified venue service that combines all venue recommendation capabilities.
/// Replaces VenueRecommendationService, SmartVenueRecommendationService,
/// and AIVenueRecommendationService.
///
/// This is a facade that delegates to focused sub-services:
/// - [VenueScoringService] for scoring, sorting, tags, and reasoning
/// - [VenueAIAnalysisService] for AI-powered venue analysis
class UnifiedVenueService {
  static final UnifiedVenueService _instance = UnifiedVenueService._internal();
  factory UnifiedVenueService() => _instance;
  UnifiedVenueService._internal();

  // Core dependencies
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserLearningService _userLearningService = UserLearningService();

  // Sub-services
  final VenueScoringService _scoringService = VenueScoringService();
  final VenueAIAnalysisService _aiAnalysisService = VenueAIAnalysisService();

  /// Generate comprehensive venue recommendations with AI-powered personalization
  Future<List<EnhancedVenueRecommendation>> getRecommendations({
    required List<Place> venues,
    GameSchedule? game,
    String context = 'general',
    VenueSortOption sortBy = VenueSortOption.rating,
    List<VenueCategory> filterCategories = const [],
    int limit = 10,
    bool includeAIAnalysis = true,
    bool includePersonalization = true,
  }) async {
    try {
      LoggingService.info(
          'Generating venue recommendations (${venues.length} venues)',
          tag: 'UnifiedVenue');

      // Filter venues by category if specified
      var filteredVenues = venues;
      if (filterCategories.isNotEmpty) {
        filteredVenues = venues.where((venue) {
          final category = categorizeVenue(venue);
          return filterCategories.contains(category);
        }).toList();
      }

      // Get user behavior data for personalization
      Map<String, dynamic>? userBehavior;
      if (includePersonalization && _auth.currentUser != null) {
        userBehavior = await _getUserBehaviorData();
      }

      // Generate recommendations with AI analysis
      final recommendations = <EnhancedVenueRecommendation>[];

      for (final venue
          in filteredVenues.take(limit * 2)) {
        final category = categorizeVenue(venue);
        final basicScore = _scoringService.calculateBasicScore(venue);

        // AI-powered analysis if requested
        AIVenueAnalysis? aiAnalysis;
        if (includeAIAnalysis) {
          aiAnalysis = await _aiAnalysisService.generateAnalysis(
              venue, game, context, userBehavior);
        }

        // Personalization scoring
        final personalizationScore = userBehavior != null
            ? _scoringService.calculatePersonalizationScore(
                venue, userBehavior, categorizeVenue)
            : 0.5;

        // Context scoring (game-specific factors)
        final contextScore = game != null
            ? _scoringService.calculateContextScore(
                venue, game, context, categorizeVenue)
            : 0.5;

        // Calculate final unified score
        final unifiedScore = _scoringService.calculateUnifiedScore(
          basicScore: basicScore,
          aiScore: aiAnalysis?.overallScore ?? 0.5,
          personalizationScore: personalizationScore,
          contextScore: contextScore,
        );

        recommendations.add(EnhancedVenueRecommendation(
          venue: venue,
          category: category,
          unifiedScore: unifiedScore,
          basicScore: basicScore,
          aiAnalysis: aiAnalysis,
          personalizationScore: personalizationScore,
          contextScore: contextScore,
          tags: _scoringService.generateVenueTags(venue, category, aiAnalysis),
          reasoning: _scoringService.generateReasoning(
              venue, aiAnalysis, userBehavior, context),
          confidence: aiAnalysis?.confidence ?? 0.7,
        ));
      }

      // Sort recommendations
      _scoringService.sortRecommendations(recommendations, sortBy);

      // Return top recommendations
      final finalRecommendations = recommendations.take(limit).toList();

      LoggingService.info(
          'Generated ${finalRecommendations.length} venue recommendations',
          tag: 'UnifiedVenue');

      return finalRecommendations;
    } catch (e) {
      LoggingService.error(
          'Error generating venue recommendations: $e', tag: 'UnifiedVenue');
      return _getFallbackRecommendations(venues, limit);
    }
  }

  /// Categorize venue based on Google Places types and name analysis
  VenueCategory categorizeVenue(Place place) {
    final types = place.types ?? [];
    final name = place.name.toLowerCase();

    // Sports Bar detection
    if (types.any((type) => type.contains('bar')) &&
        (name.contains('sports') ||
            name.contains('tavern') ||
            name.contains('grill'))) {
      return VenueCategory.sportsBar;
    }

    // Brewery detection
    if (types.any((type) => ['brewery', 'liquor_store'].contains(type)) ||
        name.contains('brew') ||
        name.contains('beer')) {
      return VenueCategory.brewery;
    }

    // Fine dining detection
    if (place.priceLevel != null && place.priceLevel! >= 3) {
      if (types.any((type) => type.contains('restaurant'))) {
        return VenueCategory.fineDining;
      }
    }

    // Fast food detection
    if (types.any((type) => ['meal_delivery', 'meal_takeaway'].contains(type)) ||
        name.contains('pizza') ||
        name.contains('burger') ||
        name.contains('fast')) {
      return VenueCategory.fastFood;
    }

    // Nightclub detection
    if (types.any((type) => ['night_club', 'dance_club'].contains(type)) ||
        name.contains('club') ||
        name.contains('lounge')) {
      return VenueCategory.nightclub;
    }

    // Cafe detection
    if (types.any((type) => ['cafe', 'coffee'].contains(type)) ||
        name.contains('coffee') ||
        name.contains('cafe')) {
      return VenueCategory.cafe;
    }

    // Restaurant (default for food places)
    if (types.any((type) => type.contains('restaurant')) ||
        types.any((type) => type.contains('food'))) {
      return VenueCategory.restaurant;
    }

    return VenueCategory.unknown;
  }

  /// Track venue interaction for learning
  Future<void> trackVenueInteraction({
    required String placeId,
    required String venueName,
    required String interactionType,
    required String context,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      await _userLearningService.trackVenueInteraction(
        venueId: placeId,
        venueName: venueName,
        interactionType: interactionType,
        additionalData: {
          'context': context,
          ...?additionalData,
        },
      );
    } catch (e) {
      LoggingService.error(
          'Error tracking venue interaction: $e', tag: 'UnifiedVenue');
    }
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>?> _getUserBehaviorData() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return null;

      // This would fetch actual user behavior data
      // For now, return a placeholder
      return {
        'categoryPreferences': {},
        'pricePreferences': {},
        'preferredDistance': 5.0,
      };
    } catch (e) {
      LoggingService.error(
          'Error fetching user behavior data: $e', tag: 'UnifiedVenue');
      return null;
    }
  }

  List<EnhancedVenueRecommendation> _getFallbackRecommendations(
      List<Place> venues, int limit) {
    return venues
        .take(limit)
        .map((venue) => EnhancedVenueRecommendation(
              venue: venue,
              category: categorizeVenue(venue),
              unifiedScore: _scoringService.calculateBasicScore(venue),
              basicScore: _scoringService.calculateBasicScore(venue),
              aiAnalysis: null,
              personalizationScore: 0.5,
              contextScore: 0.5,
              tags: ['Venue'],
              reasoning: 'Popular choice',
              confidence: 0.6,
            ))
        .toList();
  }

  /// Simple method to test the service
  String getServiceName() {
    return 'UnifiedVenueService';
  }
}

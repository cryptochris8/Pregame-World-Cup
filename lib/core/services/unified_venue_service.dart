import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../ai/services/ai_service.dart';
import 'logging_service.dart';
import 'user_learning_service.dart';
import '../../features/recommendations/domain/entities/place.dart';
import '../../features/schedule/domain/entities/game_schedule.dart';

/// Unified venue service that combines all venue recommendation capabilities
/// Replaces VenueRecommendationService, SmartVenueRecommendationService, and AIVenueRecommendationService
class UnifiedVenueService {
  static final UnifiedVenueService _instance = UnifiedVenueService._internal();
  factory UnifiedVenueService() => _instance;
  UnifiedVenueService._internal();

  // Core dependencies
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AIService _aiService = AIService();
  final UserLearningService _userLearningService = UserLearningService();

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
      LoggingService.info('Generating venue recommendations (${venues.length} venues)', tag: 'UnifiedVenue');

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
      
      for (final venue in filteredVenues.take(limit * 2)) { // Process more than needed for better filtering
        final category = categorizeVenue(venue);
        final basicScore = _calculateBasicScore(venue);
        
        // AI-powered analysis if requested
        AIVenueAnalysis? aiAnalysis;
        if (includeAIAnalysis) {
          aiAnalysis = await _generateAIAnalysis(venue, game, context, userBehavior);
        }

        // Personalization scoring
        final personalizationScore = userBehavior != null 
            ? _calculatePersonalizationScore(venue, userBehavior)
            : 0.5;

        // Context scoring (game-specific factors)
        final contextScore = game != null 
            ? _calculateContextScore(venue, game, context)
            : 0.5;

        // Calculate final unified score
        final unifiedScore = _calculateUnifiedScore(
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
          tags: _generateVenueTags(venue, category, aiAnalysis),
          reasoning: _generateReasoning(venue, aiAnalysis, userBehavior, context),
          confidence: aiAnalysis?.confidence ?? 0.7,
        ));
      }

      // Sort recommendations
      _sortRecommendations(recommendations, sortBy);

      // Return top recommendations
      final finalRecommendations = recommendations.take(limit).toList();
      
      LoggingService.info('Generated ${finalRecommendations.length} venue recommendations', tag: 'UnifiedVenue');
      
      return finalRecommendations;
    } catch (e) {
      LoggingService.error('Error generating venue recommendations: $e', tag: 'UnifiedVenue');
      return _getFallbackRecommendations(venues, limit);
    }
  }

  /// Categorize venue based on Google Places types and name analysis
  VenueCategory categorizeVenue(Place place) {
    final types = place.types ?? [];
    final name = place.name.toLowerCase();
    
    // Sports Bar detection
    if (types.any((type) => type.contains('bar')) &&
        (name.contains('sports') || name.contains('tavern') || name.contains('grill'))) {
      return VenueCategory.sportsBar;
    }
    
    // Brewery detection
    if (types.any((type) => ['brewery', 'liquor_store'].contains(type)) ||
        name.contains('brew') || name.contains('beer')) {
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
        name.contains('pizza') || name.contains('burger') || name.contains('fast')) {
      return VenueCategory.fastFood;
    }
    
    // Nightclub detection
    if (types.any((type) => ['night_club', 'dance_club'].contains(type)) ||
        name.contains('club') || name.contains('lounge')) {
      return VenueCategory.nightclub;
    }
    
    // Cafe detection
    if (types.any((type) => ['cafe', 'coffee'].contains(type)) ||
        name.contains('coffee') || name.contains('cafe')) {
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
      LoggingService.error('Error tracking venue interaction: $e', tag: 'UnifiedVenue');
    }
  }

  // Private helper methods

  double _calculateBasicScore(Place venue) {
    double score = 0.5; // Base score

    // Rating contribution (40% of basic score)
    if (venue.rating != null) {
      score += (venue.rating! - 3.0) * 0.2; // Scale 1-5 rating to contribution
    }

    // Popularity contribution (30% of basic score)
    if (venue.userRatingsTotal != null) {
      final popularity = min(venue.userRatingsTotal! / 500.0, 1.0); // Cap at 500 reviews
      score += popularity * 0.15;
    }

    // Price level consideration (10% of basic score)
    if (venue.priceLevel != null) {
      // Moderate prices get slight boost
      if (venue.priceLevel == 2) {
        score += 0.05;
      }
    }

    // Open now bonus (20% of basic score)
    if (venue.openingHours?.openNow == true) {
      score += 0.1;
    }

    return score.clamp(0.0, 1.0);
  }

  Future<AIVenueAnalysis> _generateAIAnalysis(
    Place venue,
    GameSchedule? game,
    String context,
    Map<String, dynamic>? userBehavior,
  ) async {
    try {
      // Generate AI-powered venue analysis using general completion
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

      // Parse the response and extract key information
      final analysis = _parseAIVenueResponse(response, venue, context);
      
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

  /// Parse AI response for venue analysis
  Map<String, dynamic> _parseAIVenueResponse(String response, Place venue, String context) {
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

  double _calculatePersonalizationScore(Place venue, Map<String, dynamic> userBehavior) {
    double score = 0.5;

    // Analyze user's venue category preferences
    final categoryPreferences = userBehavior['categoryPreferences'] as Map<String, dynamic>? ?? {};
    final venueCategory = categorizeVenue(venue);
    final categoryScore = categoryPreferences[venueCategory.name] ?? 0.5;
    score += (categoryScore - 0.5) * 0.3;

    // Analyze price level preferences
    final pricePreferences = userBehavior['pricePreferences'] as Map<String, dynamic>? ?? {};
    if (venue.priceLevel != null) {
      final priceScore = pricePreferences[venue.priceLevel.toString()] ?? 0.5;
      score += (priceScore - 0.5) * 0.2;
    }

    // Distance preferences (if available)
    final distancePreference = userBehavior['preferredDistance'] as double? ?? 5.0;
    // Distance scoring would be implemented when distance data is available

    return score.clamp(0.0, 1.0);
  }

  double _calculateContextScore(Place venue, GameSchedule game, String context) {
    double score = 0.5;
    final category = categorizeVenue(venue);

    // Game context scoring
    switch (context) {
      case 'pre_game':
        if (category == VenueCategory.sportsBar || category == VenueCategory.restaurant) {
          score += 0.3;
        }
        break;
      case 'post_game':
        if (category == VenueCategory.sportsBar || category == VenueCategory.nightclub) {
          score += 0.3;
        }
        break;
      case 'watch_party':
        if (category == VenueCategory.sportsBar) {
          score += 0.4;
        }
        break;
      case 'casual_dining':
        if (category == VenueCategory.restaurant || category == VenueCategory.cafe) {
          score += 0.3;
        }
        break;
    }

    // Time-based scoring
    if (game.dateTime != null) {
      final gameHour = game.dateTime!.hour;
      if (gameHour >= 19 && category == VenueCategory.nightclub) { // Evening games
        score += 0.2;
      } else if (gameHour <= 14 && category == VenueCategory.cafe) { // Early games
        score += 0.2;
      }
    }

    return score.clamp(0.0, 1.0);
  }

  double _calculateUnifiedScore({
    required double basicScore,
    required double aiScore,
    required double personalizationScore,
    required double contextScore,
  }) {
    // Weighted combination of all scores
    return (basicScore * 0.3) +
           (aiScore * 0.35) +
           (personalizationScore * 0.2) +
           (contextScore * 0.15);
  }

  List<String> _generateVenueTags(Place venue, VenueCategory category, AIVenueAnalysis? aiAnalysis) {
    final tags = <String>[];

    // Category-based tags
    tags.add(category.displayName);

    // Rating-based tags
    if (venue.rating != null && venue.rating! >= 4.5) {
      tags.add('Highly Rated');
    }

    // Popularity tags
    if (venue.userRatingsTotal != null && venue.userRatingsTotal! > 200) {
      tags.add('Popular');
    }

    // Price tags
    if (venue.priceLevel != null) {
      switch (venue.priceLevel!) {
        case 1:
          tags.add('Budget Friendly');
          break;
        case 4:
          tags.add('Premium');
          break;
      }
    }

    // AI-based tags
    if (aiAnalysis != null) {
      if (aiAnalysis.gameWatchingScore > 0.8) {
        tags.add('Great for Games');
      }
      if (aiAnalysis.socialScore > 0.8) {
        tags.add('Social Spot');
      }
      if (aiAnalysis.atmosphereRating > 0.8) {
        tags.add('Great Atmosphere');
      }
    }

    // Open now tag
    if (venue.openingHours?.openNow == true) {
      tags.add('Open Now');
    }

    return tags.take(4).toList(); // Limit to 4 tags
  }

  String _generateReasoning(
    Place venue,
    AIVenueAnalysis? aiAnalysis,
    Map<String, dynamic>? userBehavior,
    String context,
  ) {
    final reasons = <String>[];

    // Rating reasoning
    if (venue.rating != null && venue.rating! >= 4.0) {
      reasons.add('Highly rated (${venue.rating}/5)');
    }

    // AI reasoning
    if (aiAnalysis != null && aiAnalysis.insights.isNotEmpty) {
      reasons.add(aiAnalysis.insights.first);
    }

    // Personalization reasoning
    if (userBehavior != null) {
      reasons.add('Matches your preferences');
    }

    // Context reasoning
    switch (context) {
      case 'pre_game':
        reasons.add('Perfect for pre-game atmosphere');
        break;
      case 'watch_party':
        reasons.add('Great spot to watch the game');
        break;
    }

    return reasons.isNotEmpty ? reasons.join(' • ') : 'Recommended venue';
  }

  void _sortRecommendations(List<EnhancedVenueRecommendation> recommendations, VenueSortOption sortBy) {
    switch (sortBy) {
      case VenueSortOption.rating:
        recommendations.sort((a, b) => b.venue.rating?.compareTo(a.venue.rating ?? 0) ?? 0);
        break;
      case VenueSortOption.popularity:
        recommendations.sort((a, b) => (b.venue.userRatingsTotal ?? 0).compareTo(a.venue.userRatingsTotal ?? 0));
        break;
      case VenueSortOption.distance:
        // Would implement distance sorting when location data is available
        recommendations.sort((a, b) => b.unifiedScore.compareTo(a.unifiedScore));
        break;
      case VenueSortOption.name:
        recommendations.sort((a, b) => a.venue.name.compareTo(b.venue.name));
        break;
      case VenueSortOption.priceLevel:
        recommendations.sort((a, b) => (a.venue.priceLevel ?? 5).compareTo(b.venue.priceLevel ?? 5));
        break;
    }
  }

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
      LoggingService.error('Error fetching user behavior data: $e', tag: 'UnifiedVenue');
      return null;
    }
  }

  List<EnhancedVenueRecommendation> _getFallbackRecommendations(List<Place> venues, int limit) {
    return venues.take(limit).map((venue) => EnhancedVenueRecommendation(
      venue: venue,
      category: categorizeVenue(venue),
      unifiedScore: _calculateBasicScore(venue),
      basicScore: _calculateBasicScore(venue),
      aiAnalysis: null,
      personalizationScore: 0.5,
      contextScore: 0.5,
      tags: ['Venue'],
      reasoning: 'Popular choice',
      confidence: 0.6,
    )).toList();
  }

  /// Simple method to test the service
  String getServiceName() {
    return 'UnifiedVenueService';
  }
}

// Data classes and enums

class EnhancedVenueRecommendation {
  final Place venue;
  final VenueCategory category;
  final double unifiedScore;
  final double basicScore;
  final AIVenueAnalysis? aiAnalysis;
  final double personalizationScore;
  final double contextScore;
  final List<String> tags;
  final String reasoning;
  final double confidence;

  EnhancedVenueRecommendation({
    required this.venue,
    required this.category,
    required this.unifiedScore,
    required this.basicScore,
    required this.aiAnalysis,
    required this.personalizationScore,
    required this.contextScore,
    required this.tags,
    required this.reasoning,
    required this.confidence,
  });
}

class AIVenueAnalysis {
  final double overallScore;
  final double confidence;
  final String crowdPrediction;
  final double atmosphereRating;
  final double gameWatchingScore;
  final double socialScore;
  final List<String> insights;
  final List<String> recommendations;

  AIVenueAnalysis({
    required this.overallScore,
    required this.confidence,
    required this.crowdPrediction,
    required this.atmosphereRating,
    required this.gameWatchingScore,
    required this.socialScore,
    required this.insights,
    required this.recommendations,
  });

  factory AIVenueAnalysis.fallback() {
    return AIVenueAnalysis(
      overallScore: 0.5,
      confidence: 0.6,
      crowdPrediction: 'Moderate',
      atmosphereRating: 0.5,
      gameWatchingScore: 0.5,
      socialScore: 0.5,
      insights: ['Popular venue'],
      recommendations: ['Worth checking out'],
    );
  }
}

enum VenueSortOption {
  distance,
  popularity,
  rating,
  name,
  priceLevel,
}

extension VenueSortOptionExtension on VenueSortOption {
  String get displayName {
    switch (this) {
      case VenueSortOption.distance:
        return 'Distance';
      case VenueSortOption.popularity:
        return 'Popular';
      case VenueSortOption.rating:
        return 'Rating';
      case VenueSortOption.name:
        return 'Name';
      case VenueSortOption.priceLevel:
        return 'Price';
    }
  }

  IconData get icon {
    switch (this) {
      case VenueSortOption.distance:
        return Icons.near_me;
      case VenueSortOption.popularity:
        return Icons.local_fire_department;
      case VenueSortOption.rating:
        return Icons.star;
      case VenueSortOption.name:
        return Icons.sort_by_alpha;
      case VenueSortOption.priceLevel:
        return Icons.attach_money;
    }
  }
}

enum VenueCategory {
  sportsBar,
  restaurant,
  brewery,
  cafe,
  nightclub,
  fastFood,
  fineDining,
  unknown,
}

extension VenueCategoryExtension on VenueCategory {
  String get displayName {
    switch (this) {
      case VenueCategory.sportsBar:
        return 'Sports Bar';
      case VenueCategory.restaurant:
        return 'Restaurant';
      case VenueCategory.brewery:
        return 'Brewery';
      case VenueCategory.cafe:
        return 'Café';
      case VenueCategory.nightclub:
        return 'Nightclub';
      case VenueCategory.fastFood:
        return 'Quick Bites';
      case VenueCategory.fineDining:
        return 'Fine Dining';
      case VenueCategory.unknown:
        return 'Venue';
    }
  }

  String get emoji {
    switch (this) {
      case VenueCategory.sportsBar:
        return '🏈';
      case VenueCategory.restaurant:
        return '🍽️';
      case VenueCategory.brewery:
        return '🍺';
      case VenueCategory.cafe:
        return '☕';
      case VenueCategory.nightclub:
        return '🌃';
      case VenueCategory.fastFood:
        return '🍕';
      case VenueCategory.fineDining:
        return '✨';
      case VenueCategory.unknown:
        return '📍';
    }
  }

  IconData get icon {
    switch (this) {
      case VenueCategory.sportsBar:
        return Icons.sports_bar;
      case VenueCategory.restaurant:
        return Icons.restaurant;
      case VenueCategory.brewery:
        return Icons.local_bar;
      case VenueCategory.cafe:
        return Icons.local_cafe;
      case VenueCategory.nightclub:
        return Icons.nightlife;
      case VenueCategory.fastFood:
        return Icons.fastfood;
      case VenueCategory.fineDining:
        return Icons.star;
      case VenueCategory.unknown:
        return Icons.place;
    }
  }

  Color get color {
    switch (this) {
      case VenueCategory.sportsBar:
        return const Color(0xFF2E7D32); // Green
      case VenueCategory.restaurant:
        return const Color(0xFF8B4513); // Brown
      case VenueCategory.brewery:
        return const Color(0xFFFF8F00); // Orange
      case VenueCategory.cafe:
        return const Color(0xFF5D4037); // Coffee brown
      case VenueCategory.nightclub:
        return const Color(0xFF7B1FA2); // Purple
      case VenueCategory.fastFood:
        return const Color(0xFFD84315); // Red-orange
      case VenueCategory.fineDining:
        return const Color(0xFF1565C0); // Blue
      case VenueCategory.unknown:
        return const Color(0xFF757575); // Grey
    }
  }
} 
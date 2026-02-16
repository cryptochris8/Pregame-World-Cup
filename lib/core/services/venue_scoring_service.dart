import 'dart:math';

import '../../features/recommendations/domain/entities/place.dart';
import '../../features/schedule/domain/entities/game_schedule.dart';
import 'venue_models.dart';

/// Handles all venue scoring, sorting, tag generation, and reasoning logic.
///
/// Extracted from [UnifiedVenueService] to keep the facade lean.
class VenueScoringService {
  /// Calculate a basic score for a venue based on rating, popularity,
  /// price level, and open-now status.
  double calculateBasicScore(Place venue) {
    double score = 0.5; // Base score

    // Rating contribution (40% of basic score)
    if (venue.rating != null) {
      score += (venue.rating! - 3.0) * 0.2;
    }

    // Popularity contribution (30% of basic score)
    if (venue.userRatingsTotal != null) {
      final popularity = min(venue.userRatingsTotal! / 500.0, 1.0);
      score += popularity * 0.15;
    }

    // Price level consideration (10% of basic score)
    if (venue.priceLevel != null) {
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

  /// Score how well a venue matches the user's historical behaviour.
  double calculatePersonalizationScore(Place venue, Map<String, dynamic> userBehavior,
      VenueCategory Function(Place) categorizer) {
    double score = 0.5;

    // Analyze user's venue category preferences
    final categoryPreferences =
        userBehavior['categoryPreferences'] as Map<String, dynamic>? ?? {};
    final venueCategory = categorizer(venue);
    final categoryScore = categoryPreferences[venueCategory.name] ?? 0.5;
    score += (categoryScore - 0.5) * 0.3;

    // Analyze price level preferences
    final pricePreferences =
        userBehavior['pricePreferences'] as Map<String, dynamic>? ?? {};
    if (venue.priceLevel != null) {
      final priceScore = pricePreferences[venue.priceLevel.toString()] ?? 0.5;
      score += (priceScore - 0.5) * 0.2;
    }

    return score.clamp(0.0, 1.0);
  }

  /// Score how well a venue fits the current game/context scenario.
  double calculateContextScore(Place venue, GameSchedule game, String context,
      VenueCategory Function(Place) categorizer) {
    double score = 0.5;
    final category = categorizer(venue);

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
      if (gameHour >= 19 && category == VenueCategory.nightclub) {
        score += 0.2;
      } else if (gameHour <= 14 && category == VenueCategory.cafe) {
        score += 0.2;
      }
    }

    return score.clamp(0.0, 1.0);
  }

  /// Combine all sub-scores into a single unified score with weighted average.
  double calculateUnifiedScore({
    required double basicScore,
    required double aiScore,
    required double personalizationScore,
    required double contextScore,
  }) {
    return (basicScore * 0.3) +
        (aiScore * 0.35) +
        (personalizationScore * 0.2) +
        (contextScore * 0.15);
  }

  /// Generate human-readable tags for a venue.
  List<String> generateVenueTags(
      Place venue, VenueCategory category, AIVenueAnalysis? aiAnalysis) {
    final tags = <String>[];

    tags.add(category.displayName);

    if (venue.rating != null && venue.rating! >= 4.5) {
      tags.add('Highly Rated');
    }

    if (venue.userRatingsTotal != null && venue.userRatingsTotal! > 200) {
      tags.add('Popular');
    }

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

    if (venue.openingHours?.openNow == true) {
      tags.add('Open Now');
    }

    return tags.take(4).toList();
  }

  /// Generate a short explanation of why this venue was recommended.
  String generateReasoning(
    Place venue,
    AIVenueAnalysis? aiAnalysis,
    Map<String, dynamic>? userBehavior,
    String context,
  ) {
    final reasons = <String>[];

    if (venue.rating != null && venue.rating! >= 4.0) {
      reasons.add('Highly rated (${venue.rating}/5)');
    }

    if (aiAnalysis != null && aiAnalysis.insights.isNotEmpty) {
      reasons.add(aiAnalysis.insights.first);
    }

    if (userBehavior != null) {
      reasons.add('Matches your preferences');
    }

    switch (context) {
      case 'pre_game':
        reasons.add('Perfect for pre-game atmosphere');
        break;
      case 'watch_party':
        reasons.add('Great spot to watch the game');
        break;
    }

    return reasons.isNotEmpty ? reasons.join(' \u2022 ') : 'Recommended venue';
  }

  /// Sort a list of recommendations in-place according to [sortBy].
  void sortRecommendations(
      List<EnhancedVenueRecommendation> recommendations, VenueSortOption sortBy) {
    switch (sortBy) {
      case VenueSortOption.rating:
        recommendations.sort(
            (a, b) => b.venue.rating?.compareTo(a.venue.rating ?? 0) ?? 0);
        break;
      case VenueSortOption.popularity:
        recommendations.sort((a, b) =>
            (b.venue.userRatingsTotal ?? 0)
                .compareTo(a.venue.userRatingsTotal ?? 0));
        break;
      case VenueSortOption.distance:
        recommendations
            .sort((a, b) => b.unifiedScore.compareTo(a.unifiedScore));
        break;
      case VenueSortOption.name:
        recommendations
            .sort((a, b) => a.venue.name.compareTo(b.venue.name));
        break;
      case VenueSortOption.priceLevel:
        recommendations.sort((a, b) =>
            (a.venue.priceLevel ?? 5).compareTo(b.venue.priceLevel ?? 5));
        break;
    }
  }
}

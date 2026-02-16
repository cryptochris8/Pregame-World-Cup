import 'package:flutter/material.dart';
import '../../features/recommendations/domain/entities/place.dart';

// ============================================================================
// DATA MODELS (extracted from unified_venue_service.dart)
// ============================================================================

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

// ============================================================================
// ENUMS & EXTENSIONS
// ============================================================================

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
        return 'Cafe';
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
        return '\u{1F3C8}';
      case VenueCategory.restaurant:
        return '\u{1F37D}\u{FE0F}';
      case VenueCategory.brewery:
        return '\u{1F37A}';
      case VenueCategory.cafe:
        return '\u{2615}';
      case VenueCategory.nightclub:
        return '\u{1F303}';
      case VenueCategory.fastFood:
        return '\u{1F355}';
      case VenueCategory.fineDining:
        return '\u{2728}';
      case VenueCategory.unknown:
        return '\u{1F4CD}';
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

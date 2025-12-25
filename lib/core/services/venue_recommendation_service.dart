import 'package:flutter/material.dart';
import '../../features/recommendations/domain/entities/place.dart';
import 'dart:math' as math;

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
        return const Color(0xFFEA580C); // Warm orange (matches app theme)
      case VenueCategory.restaurant:
        return const Color(0xFF7C3AED); // Vibrant purple (matches app theme)
      case VenueCategory.brewery:
        return const Color(0xFFFBBF24); // Championship gold (matches app theme)
      case VenueCategory.cafe:
        return const Color(0xFF3B82F6); // Electric blue (matches app theme)
      case VenueCategory.nightclub:
        return const Color(0xFFDC2626); // Vibrant red (matches app theme)
      case VenueCategory.fastFood:
        return const Color(0xFF10B981); // Success green (matches app theme)
      case VenueCategory.fineDining:
        return const Color(0xFF8B5CF6); // Premium purple (matches app theme)
      case VenueCategory.unknown:
        return const Color(0xFF94A3B8); // Tertiary text (matches app theme)
    }
  }

  List<int> get colorCodes {
    switch (this) {
      case VenueCategory.sportsBar:
        return [0xFFEA580C]; // Warm orange (matches app theme)
      case VenueCategory.restaurant:
        return [0xFF7C3AED]; // Vibrant purple (matches app theme)
      case VenueCategory.brewery:
        return [0xFFFBBF24]; // Championship gold (matches app theme)
      case VenueCategory.cafe:
        return [0xFF3B82F6]; // Electric blue (matches app theme)
      case VenueCategory.nightclub:
        return [0xFFDC2626]; // Vibrant red (matches app theme)
      case VenueCategory.fastFood:
        return [0xFF10B981]; // Success green (matches app theme)
      case VenueCategory.fineDining:
        return [0xFF8B5CF6]; // Premium purple (matches app theme)
      case VenueCategory.unknown:
        return [0xFF94A3B8]; // Tertiary text (matches app theme)
    }
  }
}

class VenueRecommendationService {
  /// Determine venue category based on Google Places types
  static VenueCategory categorizeVenue(Place place) {
    final types = place.types ?? [];
    
    // Sports Bar detection
    if (types.any((type) => type.contains('bar')) &&
        (place.name.toLowerCase().contains('sports') ||
         place.name.toLowerCase().contains('tavern') ||
         place.name.toLowerCase().contains('grill'))) {
      return VenueCategory.sportsBar;
    }
    
    // Brewery detection
    if (types.any((type) => ['brewery', 'liquor_store'].contains(type)) ||
        place.name.toLowerCase().contains('brew') ||
        place.name.toLowerCase().contains('beer')) {
      return VenueCategory.brewery;
    }
    
    // Fine dining detection (high price or fine dining keywords)
    if (place.priceLevel != null && place.priceLevel! >= 3) {
      if (types.any((type) => type.contains('restaurant'))) {
        return VenueCategory.fineDining;
      }
    }
    
    // Fast food detection
    if (types.any((type) => ['meal_delivery', 'meal_takeaway'].contains(type)) ||
        place.name.toLowerCase().contains('pizza') ||
        place.name.toLowerCase().contains('burger') ||
        place.name.toLowerCase().contains('fast')) {
      return VenueCategory.fastFood;
    }
    
    // Nightclub detection
    if (types.any((type) => ['night_club', 'dance_club'].contains(type)) ||
        place.name.toLowerCase().contains('club') ||
        place.name.toLowerCase().contains('lounge')) {
      return VenueCategory.nightclub;
    }
    
    // Café detection
    if (types.any((type) => ['cafe', 'coffee_shop'].contains(type)) ||
        place.name.toLowerCase().contains('coffee') ||
        place.name.toLowerCase().contains('café')) {
      return VenueCategory.cafe;
    }
    
    // General restaurant
    if (types.any((type) => type.contains('restaurant'))) {
      return VenueCategory.restaurant;
    }
    
    // Bar (if not already categorized as sports bar)
    if (types.any((type) => type.contains('bar'))) {
      return VenueCategory.sportsBar; // Default bars to sports bar for game day
    }
    
    return VenueCategory.unknown;
  }

  /// Calculate popularity score based on rating and review count
  static double calculatePopularityScore(Place place) {
    final rating = place.rating ?? 0.0;
    final reviewCount = place.userRatingsTotal ?? 0;
    
    if (rating == 0.0 || reviewCount == 0) return 0.0;
    
    // Weighted formula: rating * log(review_count + 1) * rating_weight
    // This gives higher scores to places with both good ratings AND more reviews
    final reviewScore = math.log(reviewCount + 1) / math.log(100); // Normalize to 0-1 scale
    final ratingWeight = rating / 5.0; // Normalize rating to 0-1 scale
    
    return (ratingWeight * 0.7 + reviewScore * 0.3) * 100; // Scale to 0-100
  }

  /// Get popular venues sorted by popularity score
  static List<Place> getPopularVenues(List<Place> venues, {int limit = 10}) {
    final venuesWithScores = venues.map((venue) {
      return _VenueWithScore(venue, calculatePopularityScore(venue));
    }).toList();
    
    venuesWithScores.sort((a, b) => b.score.compareTo(a.score));
    
    return venuesWithScores
        .take(limit)
        .map((v) => v.venue)
        .toList();
  }

  /// Filter venues by category
  static List<Place> getVenuesByCategory(List<Place> venues, VenueCategory category) {
    return venues.where((venue) => categorizeVenue(venue) == category).toList();
  }

  /// Get venues that are currently open
  static List<Place> getOpenVenues(List<Place> venues) {
    return venues.where((venue) => 
        venue.openingHours?.openNow == true).toList();
  }

  /// Get highly rated venues (4.0+ stars)
  static List<Place> getHighlyRatedVenues(List<Place> venues) {
    return venues.where((venue) => 
        venue.rating != null && venue.rating! >= 4.0).toList();
  }

  /// Calculate walking distance in meters (rough estimate)
  static double calculateWalkingDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371000; // Earth's radius in meters
    
    final double lat1Rad = lat1 * math.pi / 180;
    final double lat2Rad = lat2 * math.pi / 180;
    final double deltaLatRad = (lat2 - lat1) * math.pi / 180;
    final double deltaLngRad = (lng2 - lng1) * math.pi / 180;
    
    final double a = math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
        math.cos(lat1Rad) * math.cos(lat2Rad) *
        math.sin(deltaLngRad / 2) * math.sin(deltaLngRad / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }

  /// Estimate walking time in minutes
  static int estimateWalkingTime(double distanceMeters) {
    // Average walking speed: 5 km/h = 83.33 m/min
    const double walkingSpeedMPerMin = 83.33;
    return (distanceMeters / walkingSpeedMPerMin).ceil();
  }

  /// Format walking time for display
  static String formatWalkingTime(int minutes) {
    if (minutes <= 1) return '1 min walk';
    if (minutes < 60) return '$minutes min walk';
    
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) return '${hours}h walk';
    return '${hours}h ${mins}m walk';
  }

  /// Sort venues by distance from a point
  static List<Place> sortByDistance(List<Place> venues, double fromLat, double fromLng) {
    final venuesWithDistance = venues.map((venue) {
      final lat = venue.latitude ?? venue.geometry?.location?.lat;
      final lng = venue.longitude ?? venue.geometry?.location?.lng;
      
      if (lat == null || lng == null) {
        return _VenueWithDistance(venue, double.maxFinite);
      }
      
      final distance = calculateWalkingDistance(fromLat, fromLng, lat, lng);
      return _VenueWithDistance(venue, distance);
    }).toList();
    
    venuesWithDistance.sort((a, b) => a.distance.compareTo(b.distance));
    
    return venuesWithDistance.map((v) => v.venue).toList();
  }

  /// Check if venue is within walking distance (default: 10 minutes)
  static bool isWithinWalkingDistance(Place venue, double fromLat, double fromLng, {int maxMinutes = 10}) {
    final lat = venue.latitude ?? venue.geometry?.location?.lat;
    final lng = venue.longitude ?? venue.geometry?.location?.lng;
    
    if (lat == null || lng == null) return false;
    
    final distance = calculateWalkingDistance(fromLat, fromLng, lat, lng);
    final walkTime = estimateWalkingTime(distance);
    
    return walkTime <= maxMinutes;
  }

  /// Check if venue is popular (high popularity score)
  static bool isPopular(Place venue, {double threshold = 60.0}) {
    return calculatePopularityScore(venue) >= threshold;
  }

  /// Sort venues by the specified option
  static List<Place> sortVenues(List<Place> venues, VenueSortOption sortOption, {double? fromLat, double? fromLng}) {
    final List<Place> sortedVenues = List.from(venues);
    
    switch (sortOption) {
      case VenueSortOption.distance:
        if (fromLat != null && fromLng != null) {
          return sortByDistance(sortedVenues, fromLat, fromLng);
        }
        return sortedVenues; // Return unsorted if no coordinates
        
      case VenueSortOption.popularity:
        return getPopularVenues(sortedVenues, limit: sortedVenues.length);
        
      case VenueSortOption.rating:
        sortedVenues.sort((a, b) {
          final ratingA = a.rating ?? 0.0;
          final ratingB = b.rating ?? 0.0;
          return ratingB.compareTo(ratingA); // Highest rating first
        });
        return sortedVenues;
        
      case VenueSortOption.name:
        sortedVenues.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        return sortedVenues;
        
      case VenueSortOption.priceLevel:
        sortedVenues.sort((a, b) {
          final priceA = a.priceLevel ?? 0;
          final priceB = b.priceLevel ?? 0;
          return priceA.compareTo(priceB); // Lowest price first
        });
        return sortedVenues;
    }
  }

  /// Get venues organized by sections (Popular, Open Now, All)
  static Map<String, List<Place>> getOrganizedVenues(List<Place> venues, {double? fromLat, double? fromLng}) {
    final Map<String, List<Place>> organized = {};
    
    // Popular venues (top 5-10)
    final popularVenues = getPopularVenues(venues, limit: 10);
    if (popularVenues.isNotEmpty) {
      organized['🔥 Popular Near Stadium'] = popularVenues;
    }
    
    // Open now venues
    final openVenues = getOpenVenues(venues);
    if (openVenues.isNotEmpty) {
      organized['🕒 Open Now'] = openVenues.take(10).toList();
    }
    
    // Highly rated venues
    final highlyRated = getHighlyRatedVenues(venues);
    if (highlyRated.isNotEmpty) {
      organized['⭐ Highly Rated (4.0+)'] = highlyRated.take(10).toList();
    }
    
    // All venues sorted by distance (if coordinates available)
    if (fromLat != null && fromLng != null) {
      organized['📍 All Venues (by distance)'] = sortByDistance(venues, fromLat, fromLng);
    } else {
      organized['📍 All Venues'] = venues;
    }
    
    return organized;
  }

  /// Get quick filter counts for UI
  static Map<String, int> getFilterCounts(List<Place> venues) {
    return {
      'total': venues.length,
      'open_now': getOpenVenues(venues).length,
      'highly_rated': getHighlyRatedVenues(venues).length,
      'popular': venues.where((v) => isPopular(v)).length,
      'sports_bars': getVenuesByCategory(venues, VenueCategory.sportsBar).length,
      'restaurants': getVenuesByCategory(venues, VenueCategory.restaurant).length,
      'breweries': getVenuesByCategory(venues, VenueCategory.brewery).length,
    };
  }
}

class _VenueWithScore {
  final Place venue;
  final double score;
  
  _VenueWithScore(this.venue, this.score);
}

class _VenueWithDistance {
  final Place venue;
  final double distance;
  
  _VenueWithDistance(this.venue, this.distance);
} 
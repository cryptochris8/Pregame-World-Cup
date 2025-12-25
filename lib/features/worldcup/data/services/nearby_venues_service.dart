import 'dart:math';
import '../../../recommendations/data/datasources/places_api_datasource.dart';
import '../../../recommendations/domain/entities/place.dart';
import '../../domain/entities/world_cup_venue.dart';

/// Service to find nearby venues (bars, restaurants) around World Cup stadiums
class NearbyVenuesService {
  final PlacesApiDataSource _placesDataSource;

  NearbyVenuesService({required PlacesApiDataSource placesDataSource})
      : _placesDataSource = placesDataSource;

  /// Fetch nearby places around a World Cup venue
  /// Returns places sorted by distance from the stadium
  Future<List<NearbyVenueResult>> getNearbyVenues({
    required WorldCupVenue stadium,
    double radiusMeters = 2000, // Default 2km
    List<String> types = const ['restaurant', 'bar', 'cafe'],
  }) async {
    if (stadium.latitude == null || stadium.longitude == null) {
      throw Exception('Stadium ${stadium.name} does not have coordinates');
    }

    final places = await _placesDataSource.fetchNearbyPlaces(
      latitude: stadium.latitude!,
      longitude: stadium.longitude!,
      radius: radiusMeters,
      types: types,
    );

    // Convert to NearbyVenueResult with distance calculations
    // Filter out places without coordinates
    final results = places
        .where((place) => place.latitude != null && place.longitude != null)
        .map((place) {
      final distance = _calculateDistance(
        stadium.latitude!,
        stadium.longitude!,
        place.latitude!,
        place.longitude!,
      );

      return NearbyVenueResult(
        place: place,
        distanceMeters: distance,
        stadium: stadium,
      );
    }).toList();

    // Sort by distance
    results.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));

    return results;
  }

  /// Fetch nearby places for a match (uses the match venue)
  Future<List<NearbyVenueResult>> getNearbyVenuesForMatch({
    required String venueId,
    double radiusMeters = 2000,
    List<String> types = const ['restaurant', 'bar', 'cafe'],
  }) async {
    final stadium = WorldCupVenues.getById(venueId);
    if (stadium == null) {
      throw Exception('Stadium not found: $venueId');
    }

    return getNearbyVenues(
      stadium: stadium,
      radiusMeters: radiusMeters,
      types: types,
    );
  }

  /// Calculate distance between two coordinates using Haversine formula
  /// Returns distance in meters
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadiusMeters = 6371000; // Earth's radius in meters

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusMeters * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
}

/// Result containing a place with its distance from the stadium
class NearbyVenueResult {
  final Place place;
  final double distanceMeters;
  final WorldCupVenue stadium;

  const NearbyVenueResult({
    required this.place,
    required this.distanceMeters,
    required this.stadium,
  });

  /// Distance formatted as string (e.g., "450m" or "1.2km")
  String get distanceFormatted {
    if (distanceMeters < 1000) {
      return '${distanceMeters.round()}m';
    } else {
      return '${(distanceMeters / 1000).toStringAsFixed(1)}km';
    }
  }

  /// Estimated walking time (assuming 5 km/h walking speed)
  int get walkingTimeMinutes {
    const double walkingSpeedMetersPerMinute = 83.33; // ~5 km/h
    return (distanceMeters / walkingSpeedMetersPerMinute).ceil();
  }

  /// Walking time formatted as string
  String get walkingTimeFormatted {
    final minutes = walkingTimeMinutes;
    if (minutes < 60) {
      return '$minutes min walk';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '$hours hr walk';
      }
      return '$hours hr $remainingMinutes min walk';
    }
  }

  /// Get venue type icon
  String get typeIcon {
    final types = place.types ?? [];
    if (types.contains('bar')) return '🍺';
    if (types.contains('restaurant')) return '🍽️';
    if (types.contains('cafe')) return '☕';
    if (types.contains('fast_food')) return '🍔';
    if (types.contains('pizza')) return '🍕';
    return '📍';
  }

  /// Get primary venue type for display
  String get primaryType {
    final types = place.types ?? [];
    if (types.contains('bar')) return 'Bar';
    if (types.contains('restaurant')) return 'Restaurant';
    if (types.contains('cafe')) return 'Cafe';
    if (types.contains('fast_food')) return 'Fast Food';
    return 'Venue';
  }
}

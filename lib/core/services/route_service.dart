import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class RouteService {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/directions/json';
  
  /// Calculate route between two points using Google Directions API
  static Future<RouteData?> calculateRoute({
    required LatLng origin,
    required LatLng destination,
    String mode = 'walking',
    String? apiKey,
  }) async {
    if (apiKey == null) {
      return _getFallbackRoute(origin, destination);
    }

    try {
      final url = Uri.parse('$_baseUrl?'
          'origin=${origin.latitude},${origin.longitude}&'
          'destination=${destination.latitude},${destination.longitude}&'
          'mode=$mode&'
          'key=$apiKey');

      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          return _parseRouteData(data['routes'][0]);
        }
      }
      
      return _getFallbackRoute(origin, destination);
    } catch (e) {
      return _getFallbackRoute(origin, destination);
    }
  }

  /// Parse route data from Google Directions API response
  static RouteData _parseRouteData(Map<String, dynamic> route) {
    final leg = route['legs'][0];
    final polylinePoints = route['overview_polyline']['points'];
    
    // Decode polyline to get route coordinates
    final decodedPoints = decodePolyline(polylinePoints);
    final coordinates = decodedPoints
        .map((point) => LatLng(point[0].toDouble(), point[1].toDouble()))
        .toList();

    return RouteData(
      coordinates: coordinates,
      distance: leg['distance']['text'],
      duration: leg['duration']['text'],
      distanceValue: leg['distance']['value'],
      durationValue: leg['duration']['value'],
      steps: _parseSteps(leg['steps']),
    );
  }

  /// Parse individual navigation steps
  static List<RouteStep> _parseSteps(List<dynamic> steps) {
    return steps.map<RouteStep>((step) {
      return RouteStep(
        instruction: _stripHtmlTags(step['html_instructions']),
        distance: step['distance']['text'],
        duration: step['duration']['text'],
        startLocation: LatLng(
          step['start_location']['lat'].toDouble(),
          step['start_location']['lng'].toDouble(),
        ),
        endLocation: LatLng(
          step['end_location']['lat'].toDouble(),
          step['end_location']['lng'].toDouble(),
        ),
      );
    }).toList();
  }

  /// Remove HTML tags from instructions
  static String _stripHtmlTags(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  /// Create a fallback route when API is unavailable
  static RouteData _getFallbackRoute(LatLng origin, LatLng destination) {
    final distance = Geolocator.distanceBetween(
      origin.latitude,
      origin.longitude,
      destination.latitude,
      destination.longitude,
    );

    const walkingSpeed = 1.4; // meters per second (average walking speed)
    final duration = (distance / walkingSpeed).round();

    return RouteData(
      coordinates: [origin, destination], // Simple direct line
      distance: '${(distance / 1000).toStringAsFixed(1)} km',
      duration: '${(duration / 60).round()} min',
      distanceValue: distance.round(),
      durationValue: duration,
      steps: [
        RouteStep(
          instruction: 'Walk directly to destination',
          distance: '${(distance / 1000).toStringAsFixed(1)} km',
          duration: '${(duration / 60).round()} min',
          startLocation: origin,
          endLocation: destination,
        ),
      ],
    );
  }

  /// Calculate estimated walking time based on distance
  static String calculateWalkingTime(double distanceKm) {
    const walkingSpeedKmh = 5.0; // Average walking speed in km/h
    final timeHours = distanceKm / walkingSpeedKmh;
    final timeMinutes = (timeHours * 60).round();
    
    if (timeMinutes < 1) {
      return '< 1 min';
    } else if (timeMinutes < 60) {
      return '$timeMinutes min';
    } else {
      final hours = timeMinutes ~/ 60;
      final minutes = timeMinutes % 60;
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }
  }

  /// Get walking difficulty level based on distance and duration
  static WalkingDifficulty getWalkingDifficulty(double distanceKm, int durationMinutes) {
    if (distanceKm <= 0.5 && durationMinutes <= 6) {
      return WalkingDifficulty.easy;
    } else if (distanceKm <= 1.0 && durationMinutes <= 12) {
      return WalkingDifficulty.moderate;
    } else if (distanceKm <= 2.0 && durationMinutes <= 25) {
      return WalkingDifficulty.challenging;
    } else {
      return WalkingDifficulty.difficult;
    }
  }
}

/// Route data model
class RouteData {
  final List<LatLng> coordinates;
  final String distance;
  final String duration;
  final int distanceValue; // in meters
  final int durationValue; // in seconds
  final List<RouteStep> steps;

  RouteData({
    required this.coordinates,
    required this.distance,
    required this.duration,
    required this.distanceValue,
    required this.durationValue,
    required this.steps,
  });

  /// Get distance in kilometers
  double get distanceKm => distanceValue / 1000.0;

  /// Get duration in minutes
  int get durationMinutes => (durationValue / 60).round();

  /// Get walking difficulty
  WalkingDifficulty get difficulty => 
      RouteService.getWalkingDifficulty(distanceKm, durationMinutes);

  /// Get polyline for Google Maps
  Polyline toPolyline({
    String polylineId = 'route',
    Color color = const Color(0xFF8B4513),
    int width = 4,
  }) {
    return Polyline(
      polylineId: PolylineId(polylineId),
      points: coordinates,
      color: color,
      width: width,
      patterns: const [],
    );
  }
}

/// Individual route step
class RouteStep {
  final String instruction;
  final String distance;
  final String duration;
  final LatLng startLocation;
  final LatLng endLocation;

  RouteStep({
    required this.instruction,
    required this.distance,
    required this.duration,
    required this.startLocation,
    required this.endLocation,
  });
}

/// Walking difficulty levels
enum WalkingDifficulty {
  easy('Easy', 'Quick walk', Color(0xFF2D6A4F)),
  moderate('Moderate', 'Pleasant walk', Color(0xFFFFB300)),
  challenging('Challenging', 'Longer walk', Color(0xFFFF8F00)),
  difficult('Difficult', 'Long walk', Color(0xFFD32F2F));

  const WalkingDifficulty(this.label, this.description, this.color);

  final String label;
  final String description;
  final Color color;
}

/// Walking preferences
class WalkingPreferences {
  final double maxDistanceKm;
  final int maxDurationMinutes;
  final bool avoidHills;
  final bool preferSidewalks;

  WalkingPreferences({
    this.maxDistanceKm = 2.0,
    this.maxDurationMinutes = 25,
    this.avoidHills = false,
    this.preferSidewalks = true,
  });

  /// Check if a route meets preferences
  bool meetsPreferences(RouteData route) {
    return route.distanceKm <= maxDistanceKm && 
           route.durationMinutes <= maxDurationMinutes;
  }
}

/// Route calculation options
class RouteCalculationOptions {
  final String mode; // walking, driving, transit
  final bool alternatives;
  final bool optimizeWaypoints;
  final String? language;
  final String? region;

  RouteCalculationOptions({
    this.mode = 'walking',
    this.alternatives = false,
    this.optimizeWaypoints = false,
    this.language,
    this.region,
  });
} 
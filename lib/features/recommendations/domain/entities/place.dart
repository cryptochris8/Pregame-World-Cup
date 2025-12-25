import 'package:equatable/equatable.dart';

class Place extends Equatable {
  final String placeId;
  final String name;
  final String? vicinity; // Address or general area
  final double? rating;
  final int? userRatingsTotal;
  final List<String>? types; // e.g., ["restaurant", "bar", "point_of_interest"]
  final double? latitude;
  final double? longitude;
  final int? priceLevel;
  final OpeningHours? openingHours;
  final Geometry? geometry;
  // Add other fields as needed, like photo references, opening hours, etc.

  const Place({
    required this.placeId,
    required this.name,
    this.vicinity,
    this.rating,
    this.userRatingsTotal,
    this.types,
    this.latitude,
    this.longitude,
    this.priceLevel,
    this.openingHours,
    this.geometry,
  });

  @override
  List<Object?> get props => [
    placeId,
    name,
    vicinity,
    rating,
    userRatingsTotal,
    types,
    latitude,
    longitude,
    priceLevel,
    openingHours,
    geometry,
  ];

  // Basic factory for parsing from Google Places API Nearby Search result
  // This will need to be adjusted based on the exact structure of the API response
  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      // Provide fallbacks for required String fields to prevent cast errors
      placeId: json['place_id'] ?? '',
      name: json['name'] ?? 'Unknown Place',
      vicinity: json['vicinity'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      userRatingsTotal: json['user_ratings_total'] as int?,
      types: (json['types'] as List<dynamic>?)?.cast<String>(),
      latitude: (json['geometry']?['location']?['lat'] as num?)?.toDouble(),
      longitude: (json['geometry']?['location']?['lng'] as num?)?.toDouble(),
      priceLevel: json['price_level'] as int?,
      openingHours: json['opening_hours'] != null 
          ? OpeningHours.fromJson(json['opening_hours'])
          : null,
      geometry: json['geometry'] != null 
          ? Geometry.fromJson(json['geometry'])
          : null,
    );
  }

  // Convert Place to JSON for caching
  Map<String, dynamic> toJson() {
    return {
      'place_id': placeId,
      'name': name,
      'vicinity': vicinity,
      'rating': rating,
      'user_ratings_total': userRatingsTotal,
      'types': types,
      'price_level': priceLevel,
      'opening_hours': openingHours?.toJson(),
      'geometry': geometry?.toJson(),
    };
  }
}

class OpeningHours {
  final bool? openNow;

  OpeningHours({this.openNow});

  factory OpeningHours.fromJson(Map<String, dynamic> json) {
    return OpeningHours(
      openNow: json['open_now'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'open_now': openNow,
    };
  }
}

class Geometry {
  final Location? location;

  Geometry({this.location});

  factory Geometry.fromJson(Map<String, dynamic> json) {
    return Geometry(
      location: json['location'] != null 
          ? Location.fromJson(json['location'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location?.toJson(),
    };
  }
}

class Location {
  final double? lat;
  final double? lng;

  Location({this.lat, this.lng});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
    };
  }
} 
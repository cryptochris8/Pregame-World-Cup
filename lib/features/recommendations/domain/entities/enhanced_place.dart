import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../config/api_keys.dart';

/// Enhanced place entity with detailed venue information and user reviews
class EnhancedPlace {
  final String placeId;
  final String name;
  final String? vicinity;
  final String? formattedAddress;
  final double? rating;
  final int? userRatingsTotal;
  final String? priceLevel; // '$', '$$', '$$$', '$$$$'
  final List<String> types; // ['restaurant', 'bar', 'food']
  final PlaceGeometry? geometry;
  final String? phoneNumber;
  final String? website;
  final List<String> photos; // Photo URLs
  final OpeningHours? openingHours;
  final List<PlaceReview> userReviews; // User reviews from our app
  final double? distanceFromVenue; // Distance in miles from game venue
  final bool isFavorite; // Whether current user has favorited this place
  final int checkIns; // Number of user check-ins
  final List<String> amenities; // ['wifi', 'parking', 'outdoor_seating']
  final DateTime lastUpdated;

  EnhancedPlace({
    required this.placeId,
    required this.name,
    this.vicinity,
    this.formattedAddress,
    this.rating,
    this.userRatingsTotal,
    this.priceLevel,
    this.types = const [],
    this.geometry,
    this.phoneNumber,
    this.website,
    this.photos = const [],
    this.openingHours,
    this.userReviews = const [],
    this.distanceFromVenue,
    this.isFavorite = false,
    this.checkIns = 0,
    this.amenities = const [],
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  /// Factory method to create from Google Places API response
  factory EnhancedPlace.fromGooglePlaces(Map<String, dynamic> data) {
    return EnhancedPlace(
      placeId: data['place_id'] ?? '',
      name: data['name'] ?? '',
      vicinity: data['vicinity'] as String?,
      formattedAddress: data['formatted_address'] as String?,
      rating: (data['rating'] as num?)?.toDouble(),
      userRatingsTotal: data['user_ratings_total'] as int?,
      priceLevel: _convertPriceLevel(data['price_level'] as int?),
      types: List<String>.from(data['types'] ?? []),
      geometry: data['geometry'] != null 
          ? PlaceGeometry.fromMap(data['geometry']) 
          : null,
      phoneNumber: data['formatted_phone_number'] as String?,
      website: data['website'] as String?,
      photos: _extractPhotoUrls(data['photos']),
      openingHours: data['opening_hours'] != null 
          ? OpeningHours.fromMap(data['opening_hours']) 
          : null,
      lastUpdated: DateTime.now(),
    );
  }

  /// Factory method to create from Firestore document
  factory EnhancedPlace.fromFirestore(Map<String, dynamic> data, String docId) {
    return EnhancedPlace(
      placeId: docId,
      name: data['name'] ?? '',
      vicinity: data['vicinity'] as String?,
      formattedAddress: data['formattedAddress'] as String?,
      rating: (data['rating'] as num?)?.toDouble(),
      userRatingsTotal: data['userRatingsTotal'] as int?,
      priceLevel: data['priceLevel'] as String?,
      types: List<String>.from(data['types'] ?? []),
      geometry: data['geometry'] != null 
          ? PlaceGeometry.fromMap(data['geometry']) 
          : null,
      phoneNumber: data['phoneNumber'] as String?,
      website: data['website'] as String?,
      photos: List<String>.from(data['photos'] ?? []),
      openingHours: data['openingHours'] != null 
          ? OpeningHours.fromMap(data['openingHours']) 
          : null,
      userReviews: (data['userReviews'] as List?)
          ?.map((review) => PlaceReview.fromMap(review))
          .toList() ?? [],
      distanceFromVenue: (data['distanceFromVenue'] as num?)?.toDouble(),
      isFavorite: data['isFavorite'] ?? false,
      checkIns: data['checkIns'] ?? 0,
      amenities: List<String>.from(data['amenities'] ?? []),
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'vicinity': vicinity,
      'formattedAddress': formattedAddress,
      'rating': rating,
      'userRatingsTotal': userRatingsTotal,
      'priceLevel': priceLevel,
      'types': types,
      'geometry': geometry?.toMap(),
      'phoneNumber': phoneNumber,
      'website': website,
      'photos': photos,
      'openingHours': openingHours?.toMap(),
      'userReviews': userReviews.map((review) => review.toMap()).toList(),
      'distanceFromVenue': distanceFromVenue,
      'isFavorite': isFavorite,
      'checkIns': checkIns,
      'amenities': amenities,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  /// Helper method to convert Google's price level to string
  static String? _convertPriceLevel(int? priceLevel) {
    switch (priceLevel) {
      case 1: return '\$';
      case 2: return '\$\$';
      case 3: return '\$\$\$';
      case 4: return '\$\$\$\$';
      default: return null;
    }
  }

  /// Helper method to extract photo URLs from Google Places response
  static List<String> _extractPhotoUrls(List<dynamic>? photos) {
    if (photos == null) return [];
    return photos
        .map((photo) => photo['photo_reference'] as String?)
        .where((ref) => ref != null)
        .map((ref) => 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$ref&key=${ApiKeys.googlePlaces}')
        .toList();
  }

  /// Create a copy with updated fields
  EnhancedPlace copyWith({
    String? name,
    String? vicinity,
    String? formattedAddress,
    double? rating,
    int? userRatingsTotal,
    String? priceLevel,
    List<String>? types,
    PlaceGeometry? geometry,
    String? phoneNumber,
    String? website,
    List<String>? photos,
    OpeningHours? openingHours,
    List<PlaceReview>? userReviews,
    double? distanceFromVenue,
    bool? isFavorite,
    int? checkIns,
    List<String>? amenities,
    DateTime? lastUpdated,
  }) {
    return EnhancedPlace(
      placeId: placeId,
      name: name ?? this.name,
      vicinity: vicinity ?? this.vicinity,
      formattedAddress: formattedAddress ?? this.formattedAddress,
      rating: rating ?? this.rating,
      userRatingsTotal: userRatingsTotal ?? this.userRatingsTotal,
      priceLevel: priceLevel ?? this.priceLevel,
      types: types ?? this.types,
      geometry: geometry ?? this.geometry,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      website: website ?? this.website,
      photos: photos ?? this.photos,
      openingHours: openingHours ?? this.openingHours,
      userReviews: userReviews ?? this.userReviews,
      distanceFromVenue: distanceFromVenue ?? this.distanceFromVenue,
      isFavorite: isFavorite ?? this.isFavorite,
      checkIns: checkIns ?? this.checkIns,
      amenities: amenities ?? this.amenities,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// Place geometry for location data
class PlaceGeometry {
  final PlaceLocation? location;
  final PlaceViewport? viewport;

  PlaceGeometry({this.location, this.viewport});

  factory PlaceGeometry.fromMap(Map<String, dynamic> data) {
    return PlaceGeometry(
      location: data['location'] != null 
          ? PlaceLocation.fromMap(data['location']) 
          : null,
      viewport: data['viewport'] != null 
          ? PlaceViewport.fromMap(data['viewport']) 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'location': location?.toMap(),
      'viewport': viewport?.toMap(),
    };
  }
}

/// Place location coordinates
class PlaceLocation {
  final double lat;
  final double lng;

  PlaceLocation({required this.lat, required this.lng});

  factory PlaceLocation.fromMap(Map<String, dynamic> data) {
    return PlaceLocation(
      lat: (data['lat'] as num).toDouble(),
      lng: (data['lng'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'lat': lat, 'lng': lng};
  }
}

/// Place viewport for map bounds
class PlaceViewport {
  final PlaceLocation northeast;
  final PlaceLocation southwest;

  PlaceViewport({required this.northeast, required this.southwest});

  factory PlaceViewport.fromMap(Map<String, dynamic> data) {
    return PlaceViewport(
      northeast: PlaceLocation.fromMap(data['northeast']),
      southwest: PlaceLocation.fromMap(data['southwest']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'northeast': northeast.toMap(),
      'southwest': southwest.toMap(),
    };
  }
}

/// Opening hours information
class OpeningHours {
  final bool openNow;
  final List<String> weekdayText;

  OpeningHours({required this.openNow, this.weekdayText = const []});

  factory OpeningHours.fromMap(Map<String, dynamic> data) {
    return OpeningHours(
      openNow: data['open_now'] ?? false,
      weekdayText: List<String>.from(data['weekday_text'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'open_now': openNow,
      'weekday_text': weekdayText,
    };
  }
}

/// User review for a place
class PlaceReview {
  final String reviewId;
  final String userId;
  final String userDisplayName;
  final String? userProfileImageUrl;
  final double rating;
  final String content;
  final DateTime createdAt;
  final List<String> photos; // Photo URLs from the review
  final int likes;
  final List<String> likedBy;

  PlaceReview({
    required this.reviewId,
    required this.userId,
    required this.userDisplayName,
    this.userProfileImageUrl,
    required this.rating,
    required this.content,
    required this.createdAt,
    this.photos = const [],
    this.likes = 0,
    this.likedBy = const [],
  });

  factory PlaceReview.fromMap(Map<String, dynamic> data) {
    return PlaceReview(
      reviewId: data['reviewId'] ?? '',
      userId: data['userId'] ?? '',
      userDisplayName: data['userDisplayName'] ?? 'Anonymous',
      userProfileImageUrl: data['userProfileImageUrl'] as String?,
      rating: (data['rating'] as num).toDouble(),
      content: data['content'] ?? '',
      createdAt: data['createdAt'] is Timestamp 
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.parse(data['createdAt']),
      photos: List<String>.from(data['photos'] ?? []),
      likes: data['likes'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reviewId': reviewId,
      'userId': userId,
      'userDisplayName': userDisplayName,
      'userProfileImageUrl': userProfileImageUrl,
      'rating': rating,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'photos': photos,
      'likes': likes,
      'likedBy': likedBy,
    };
  }
} 
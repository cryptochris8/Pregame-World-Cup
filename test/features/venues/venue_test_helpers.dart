import 'package:pregame_world_cup/features/recommendations/domain/entities/place.dart';

/// Test data factories for venue entities used across multiple test files.
class VenueTestFactory {
  static Place createPlace({
    String placeId = 'test_place_123',
    String name = 'The Sports Pub',
    String? vicinity = '123 Main St, Dallas, TX',
    double? rating = 4.5,
    int? userRatingsTotal = 250,
    List<String>? types = const ['bar', 'restaurant'],
    double? latitude = 32.7767,
    double? longitude = -96.7970,
    int? priceLevel = 2,
    OpeningHours? openingHours,
    Geometry? geometry,
    String? photoReference,
  }) {
    return Place(
      placeId: placeId,
      name: name,
      vicinity: vicinity,
      rating: rating,
      userRatingsTotal: userRatingsTotal,
      types: types,
      latitude: latitude,
      longitude: longitude,
      priceLevel: priceLevel,
      openingHours: openingHours,
      geometry: geometry,
      photoReference: photoReference,
    );
  }

  /// A venue with all fields populated for thorough rendering tests.
  static Place createFullPlace() {
    return createPlace(
      placeId: 'full_place',
      name: 'MetLife Stadium Sports Bar',
      vicinity: '1 MetLife Stadium Dr, East Rutherford, NJ',
      rating: 4.7,
      userRatingsTotal: 523,
      types: ['bar', 'restaurant', 'point_of_interest'],
      latitude: 40.8128,
      longitude: -74.0742,
      priceLevel: 2,
      openingHours: OpeningHours(openNow: true),
      geometry: Geometry(
        location: Location(lat: 40.8128, lng: -74.0742),
      ),
      photoReference: 'test_photo_ref',
    );
  }

  /// A venue with minimal data (only required fields).
  static Place createMinimalPlace() {
    return createPlace(
      placeId: 'minimal_place',
      name: 'Unnamed Venue',
      vicinity: null,
      rating: null,
      userRatingsTotal: null,
      types: null,
      latitude: null,
      longitude: null,
      priceLevel: null,
      openingHours: null,
      geometry: null,
      photoReference: null,
    );
  }

  /// A restaurant-type venue.
  static Place createRestaurant() {
    return createPlace(
      placeId: 'restaurant_place',
      name: 'Bella Italia',
      types: ['restaurant', 'food'],
      rating: 4.2,
      userRatingsTotal: 180,
      priceLevel: 2,
    );
  }

  /// A cafe-type venue.
  static Place createCafe() {
    return createPlace(
      placeId: 'cafe_place',
      name: 'Morning Cup Coffee',
      types: ['cafe'],
      rating: 4.0,
      userRatingsTotal: 90,
      priceLevel: 1,
    );
  }

  /// A popular venue (high rating, many reviews).
  static Place createPopularVenue() {
    return createPlace(
      placeId: 'popular_place',
      name: 'Best Sports Bar Ever',
      types: ['bar'],
      rating: 4.9,
      userRatingsTotal: 1200,
      priceLevel: 2,
    );
  }
}

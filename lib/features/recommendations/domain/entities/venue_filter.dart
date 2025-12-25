import 'package:equatable/equatable.dart';

class VenueFilter extends Equatable {
  final List<VenueType> venueTypes;
  final double maxDistance; // in kilometers
  final double? minRating;
  final PriceLevel? priceLevel;
  final bool openNow;
  final String? keyword; // For searching specific terms like "wings" or "craft beer"

  const VenueFilter({
    this.venueTypes = const [VenueType.bar, VenueType.restaurant],
    this.maxDistance = 2.0,
    this.minRating,
    this.priceLevel,
    this.openNow = false,
    this.keyword,
  });

  // Create a copy with modified values (immutable pattern)
  VenueFilter copyWith({
    List<VenueType>? venueTypes,
    double? maxDistance,
    double? minRating,
    PriceLevel? priceLevel,
    bool? openNow,
    String? keyword,
  }) {
    return VenueFilter(
      venueTypes: venueTypes ?? this.venueTypes,
      maxDistance: maxDistance ?? this.maxDistance,
      minRating: minRating ?? this.minRating,
      priceLevel: priceLevel ?? this.priceLevel,
      openNow: openNow ?? this.openNow,
      keyword: keyword ?? this.keyword,
    );
  }

  // Default filter with no restrictions
  factory VenueFilter.all() => const VenueFilter(
        venueTypes: [
          VenueType.bar,
          VenueType.restaurant,
          VenueType.cafe,
          VenueType.nightclub,
        ],
        maxDistance: 5.0,
      );

  // Filter for bars only
  factory VenueFilter.barsOnly() => const VenueFilter(
        venueTypes: [VenueType.bar, VenueType.nightclub],
        maxDistance: 2.0,
      );

  // Filter for restaurants only
  factory VenueFilter.restaurantsOnly() => const VenueFilter(
        venueTypes: [VenueType.restaurant, VenueType.cafe],
        maxDistance: 2.0,
      );

  // Convert venue types to API format
  List<String> get venueTypesToApi {
    return venueTypes.map((type) => type.apiValue).toList();
  }

  @override
  List<Object?> get props => [
        venueTypes,
        maxDistance,
        minRating,
        priceLevel,
        openNow,
        keyword,
      ];
}

enum VenueType {
  bar('bar'),
  restaurant('restaurant'),
  cafe('cafe'),
  nightclub('night_club'),
  bakery('bakery'),
  liquorStore('liquor_store');

  const VenueType(this.apiValue);
  final String apiValue;
}

enum PriceLevel {
  inexpensive(1),
  moderate(2),
  expensive(3),
  veryExpensive(4);

  const PriceLevel(this.value);
  final int value;
} 
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/ai/models/scored_venue_data.dart';

/// Concrete implementation for testing the ScoredVenueData interface.
class _TestVenue implements ScoredVenueData {
  @override
  final String? name;
  @override
  final double? rating;
  @override
  final double? distance;
  @override
  final List<String>? types;
  @override
  final int? priceLevel;

  _TestVenue({
    this.name,
    this.rating,
    this.distance,
    this.types,
    this.priceLevel,
  });
}

void main() {
  group('ScoredVenueData', () {
    test('implementation exposes all getters', () {
      final venue = _TestVenue(
        name: 'Test Bar',
        rating: 4.5,
        distance: 1.2,
        types: ['bar', 'restaurant'],
        priceLevel: 2,
      );

      expect(venue.name, equals('Test Bar'));
      expect(venue.rating, equals(4.5));
      expect(venue.distance, equals(1.2));
      expect(venue.types, equals(['bar', 'restaurant']));
      expect(venue.priceLevel, equals(2));
    });

    test('implementation allows null values', () {
      final venue = _TestVenue();

      expect(venue.name, isNull);
      expect(venue.rating, isNull);
      expect(venue.distance, isNull);
      expect(venue.types, isNull);
      expect(venue.priceLevel, isNull);
    });

    test('can be used as ScoredVenueData type', () {
      final ScoredVenueData venue = _TestVenue(
        name: 'Sports Pub',
        rating: 4.0,
        distance: 0.5,
        types: ['sports_bar'],
        priceLevel: 1,
      );

      expect(venue.name, equals('Sports Pub'));
      expect(venue.rating, equals(4.0));
      expect(venue.distance, equals(0.5));
      expect(venue.types, contains('sports_bar'));
      expect(venue.priceLevel, equals(1));
    });

    test('can be stored in List<ScoredVenueData>', () {
      final venues = <ScoredVenueData>[
        _TestVenue(name: 'Venue A', rating: 4.0),
        _TestVenue(name: 'Venue B', rating: 3.5),
        _TestVenue(name: 'Venue C', rating: 5.0),
      ];

      expect(venues, hasLength(3));
      expect(venues.map((v) => v.name).toList(),
          equals(['Venue A', 'Venue B', 'Venue C']));
    });
  });
}

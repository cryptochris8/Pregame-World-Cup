import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/venues/widgets/ai_venue_recommendations_widget.dart';
import '../../venues/venue_test_helpers.dart';

void main() {
  group('AIVenueRecommendationsWidget', () {
    test('can be constructed with required parameters', () {
      final currentVenue = VenueTestFactory.createFullPlace();
      final nearbyVenues = [
        VenueTestFactory.createRestaurant(),
        VenueTestFactory.createCafe(),
      ];

      final widget = AIVenueRecommendationsWidget(
        currentVenue: currentVenue,
        nearbyVenues: nearbyVenues,
      );

      expect(widget, isNotNull);
      expect(widget.currentVenue, currentVenue);
      expect(widget.nearbyVenues, nearbyVenues);
    });

    test('stores current venue correctly', () {
      final venue = VenueTestFactory.createFullPlace();
      final nearbyVenues = [VenueTestFactory.createRestaurant()];

      final widget = AIVenueRecommendationsWidget(
        currentVenue: venue,
        nearbyVenues: nearbyVenues,
      );

      expect(widget.currentVenue.placeId, 'full_place');
      expect(widget.currentVenue.name, 'MetLife Stadium Sports Bar');
    });

    test('stores nearby venues list correctly', () {
      final currentVenue = VenueTestFactory.createFullPlace();
      final nearbyVenues = [
        VenueTestFactory.createRestaurant(),
        VenueTestFactory.createCafe(),
        VenueTestFactory.createPopularVenue(),
      ];

      final widget = AIVenueRecommendationsWidget(
        currentVenue: currentVenue,
        nearbyVenues: nearbyVenues,
      );

      expect(widget.nearbyVenues.length, 3);
      expect(widget.nearbyVenues[0].name, 'Bella Italia');
      expect(widget.nearbyVenues[1].name, 'Morning Cup Coffee');
      expect(widget.nearbyVenues[2].name, 'Best Sports Bar Ever');
    });

    test('accepts empty nearby venues list', () {
      final currentVenue = VenueTestFactory.createFullPlace();

      final widget = AIVenueRecommendationsWidget(
        currentVenue: currentVenue,
        nearbyVenues: const [],
      );

      expect(widget.nearbyVenues, isEmpty);
    });

    test('handles different current venues', () {
      final venue1 = VenueTestFactory.createFullPlace();
      final venue2 = VenueTestFactory.createRestaurant();

      final widget1 = AIVenueRecommendationsWidget(
        currentVenue: venue1,
        nearbyVenues: const [],
      );
      final widget2 = AIVenueRecommendationsWidget(
        currentVenue: venue2,
        nearbyVenues: const [],
      );

      expect(widget1.currentVenue.placeId, 'full_place');
      expect(widget2.currentVenue.placeId, 'restaurant_place');
    });

    test('is a StatefulWidget', () {
      final currentVenue = VenueTestFactory.createFullPlace();

      final widget = AIVenueRecommendationsWidget(
        currentVenue: currentVenue,
        nearbyVenues: const [],
      );

      expect(widget, isA<AIVenueRecommendationsWidget>());
    });

    test('handles minimal venue data', () {
      final currentVenue = VenueTestFactory.createMinimalPlace();

      final widget = AIVenueRecommendationsWidget(
        currentVenue: currentVenue,
        nearbyVenues: const [],
      );

      expect(widget.currentVenue.placeId, 'minimal_place');
      expect(widget.currentVenue.vicinity, isNull);
    });

    test('handles single nearby venue', () {
      final currentVenue = VenueTestFactory.createFullPlace();
      final nearbyVenues = [VenueTestFactory.createRestaurant()];

      final widget = AIVenueRecommendationsWidget(
        currentVenue: currentVenue,
        nearbyVenues: nearbyVenues,
      );

      expect(widget.nearbyVenues.length, 1);
    });

    test('handles many nearby venues', () {
      final currentVenue = VenueTestFactory.createFullPlace();
      final nearbyVenues = List.generate(
        10,
        (i) => VenueTestFactory.createPlace(
          placeId: 'venue_$i',
          name: 'Venue $i',
        ),
      );

      final widget = AIVenueRecommendationsWidget(
        currentVenue: currentVenue,
        nearbyVenues: nearbyVenues,
      );

      expect(widget.nearbyVenues.length, 10);
      expect(widget.nearbyVenues[0].name, 'Venue 0');
      expect(widget.nearbyVenues[9].name, 'Venue 9');
    });

    test('nearby venues can include different types', () {
      final currentVenue = VenueTestFactory.createFullPlace();
      final nearbyVenues = [
        VenueTestFactory.createRestaurant(),
        VenueTestFactory.createCafe(),
        VenueTestFactory.createPopularVenue(),
      ];

      final widget = AIVenueRecommendationsWidget(
        currentVenue: currentVenue,
        nearbyVenues: nearbyVenues,
      );

      expect(widget.nearbyVenues[0].types, ['restaurant', 'food']);
      expect(widget.nearbyVenues[1].types, ['cafe']);
      expect(widget.nearbyVenues[2].types, ['bar']);
    });

    test('current venue can be same type as nearby venues', () {
      final currentVenue = VenueTestFactory.createRestaurant();
      final nearbyVenues = [
        VenueTestFactory.createRestaurant(),
        VenueTestFactory.createPlace(
          placeId: 'another_restaurant',
          name: 'Another Restaurant',
          types: ['restaurant', 'food'],
        ),
      ];

      final widget = AIVenueRecommendationsWidget(
        currentVenue: currentVenue,
        nearbyVenues: nearbyVenues,
      );

      expect(widget.currentVenue.types, contains('restaurant'));
      expect(widget.nearbyVenues[0].types, contains('restaurant'));
      expect(widget.nearbyVenues[1].types, contains('restaurant'));
    });
  });
}

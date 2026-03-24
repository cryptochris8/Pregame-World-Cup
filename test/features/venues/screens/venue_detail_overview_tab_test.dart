import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/venues/screens/venue_detail_overview_tab.dart';
import '../../venues/venue_test_helpers.dart';

void main() {
  group('VenueDetailOverviewTab', () {
    test('can be constructed with required parameters', () {
      final venue = VenueTestFactory.createFullPlace();
      final nearbyVenues = [
        VenueTestFactory.createRestaurant(),
        VenueTestFactory.createCafe(),
      ];

      final widget = VenueDetailOverviewTab(
        venue: venue,
        nearbyVenues: nearbyVenues,
      );

      expect(widget, isNotNull);
      expect(widget.venue, venue);
      expect(widget.nearbyVenues, nearbyVenues);
    });

    test('accepts empty nearby venues list', () {
      final venue = VenueTestFactory.createFullPlace();

      final widget = VenueDetailOverviewTab(
        venue: venue,
        nearbyVenues: const [],
      );

      expect(widget, isNotNull);
      expect(widget.venue, venue);
      expect(widget.nearbyVenues, isEmpty);
    });

    test('is a StatelessWidget', () {
      final venue = VenueTestFactory.createFullPlace();

      final widget = VenueDetailOverviewTab(
        venue: venue,
        nearbyVenues: const [],
      );

      expect(widget, isA<VenueDetailOverviewTab>());
    });

    test('stores venue reference correctly', () {
      final venue = VenueTestFactory.createFullPlace();
      final nearbyVenues = [VenueTestFactory.createRestaurant()];

      final widget = VenueDetailOverviewTab(
        venue: venue,
        nearbyVenues: nearbyVenues,
      );

      expect(widget.venue.placeId, 'full_place');
      expect(widget.venue.name, 'MetLife Stadium Sports Bar');
      expect(widget.venue.vicinity, '1 MetLife Stadium Dr, East Rutherford, NJ');
    });

    test('stores nearby venues list correctly', () {
      final venue = VenueTestFactory.createFullPlace();
      final nearbyVenues = [
        VenueTestFactory.createRestaurant(),
        VenueTestFactory.createCafe(),
        VenueTestFactory.createPopularVenue(),
      ];

      final widget = VenueDetailOverviewTab(
        venue: venue,
        nearbyVenues: nearbyVenues,
      );

      expect(widget.nearbyVenues.length, 3);
      expect(widget.nearbyVenues[0].name, 'Bella Italia');
      expect(widget.nearbyVenues[1].name, 'Morning Cup Coffee');
      expect(widget.nearbyVenues[2].name, 'Best Sports Bar Ever');
    });

    test('handles venue with minimal data', () {
      final venue = VenueTestFactory.createMinimalPlace();

      final widget = VenueDetailOverviewTab(
        venue: venue,
        nearbyVenues: const [],
      );

      expect(widget.venue.placeId, 'minimal_place');
      expect(widget.venue.vicinity, isNull);
      expect(widget.venue.rating, isNull);
    });

    test('handles venue with null vicinity', () {
      final venue = VenueTestFactory.createPlace(vicinity: null);

      final widget = VenueDetailOverviewTab(
        venue: venue,
        nearbyVenues: const [],
      );

      expect(widget.venue.vicinity, isNull);
    });

    test('handles venue with empty vicinity', () {
      final venue = VenueTestFactory.createPlace(vicinity: '');

      final widget = VenueDetailOverviewTab(
        venue: venue,
        nearbyVenues: const [],
      );

      expect(widget.venue.vicinity, isEmpty);
    });

    test('can have different venues with same nearby list', () {
      final venue1 = VenueTestFactory.createFullPlace();
      final venue2 = VenueTestFactory.createRestaurant();
      final nearbyVenues = [VenueTestFactory.createCafe()];

      final widget1 = VenueDetailOverviewTab(
        venue: venue1,
        nearbyVenues: nearbyVenues,
      );
      final widget2 = VenueDetailOverviewTab(
        venue: venue2,
        nearbyVenues: nearbyVenues,
      );

      expect(widget1.venue.placeId, isNot(equals(widget2.venue.placeId)));
      expect(widget1.nearbyVenues, widget2.nearbyVenues);
    });
  });
}

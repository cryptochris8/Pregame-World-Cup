import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pregame_world_cup/features/venues/widgets/venue_route_panel.dart';
import '../../venues/venue_test_helpers.dart';

void main() {
  group('VenueRoutePanel', () {
    test('is a StatefulWidget', () {
      final venue = VenueTestFactory.createPlace();
      final panel = VenueRoutePanel(
        venue: venue,
        onClose: () {},
      );
      expect(panel, isA<StatefulWidget>());
    });

    test('can be constructed with required parameters', () {
      final venue = VenueTestFactory.createPlace();
      var closeCalled = false;
      final panel = VenueRoutePanel(
        venue: venue,
        onClose: () => closeCalled = true,
      );

      expect(panel, isNotNull);
      expect(panel.venue, equals(venue));
      panel.onClose();
      expect(closeCalled, isTrue);
    });

    test('stores venue property correctly', () {
      final venue = VenueTestFactory.createFullPlace();
      final panel = VenueRoutePanel(
        venue: venue,
        onClose: () {},
      );

      expect(panel.venue, equals(venue));
      expect(panel.venue.name, equals('MetLife Stadium Sports Bar'));
    });

    test('stores stadiumLocation when provided', () {
      final venue = VenueTestFactory.createPlace();
      const stadiumLocation = LatLng(40.8128, -74.0742);
      final panel = VenueRoutePanel(
        venue: venue,
        stadiumLocation: stadiumLocation,
        onClose: () {},
      );

      expect(panel.stadiumLocation, equals(stadiumLocation));
    });

    test('stadiumLocation is null when not provided', () {
      final venue = VenueTestFactory.createPlace();
      final panel = VenueRoutePanel(
        venue: venue,
        onClose: () {},
      );

      expect(panel.stadiumLocation, isNull);
    });

    test('stores onClose callback', () {
      final venue = VenueTestFactory.createPlace();
      var closeCalled = false;
      final panel = VenueRoutePanel(
        venue: venue,
        onClose: () => closeCalled = true,
      );

      expect(panel.onClose, isNotNull);
      panel.onClose();
      expect(closeCalled, isTrue);
    });

    test('accepts a key parameter', () {
      final venue = VenueTestFactory.createPlace();
      const testKey = Key('venue_route_panel_key');
      final panel = VenueRoutePanel(
        key: testKey,
        venue: venue,
        onClose: () {},
      );

      expect(panel.key, equals(testKey));
    });

    test('can be constructed with minimal venue data', () {
      final venue = VenueTestFactory.createMinimalPlace();
      final panel = VenueRoutePanel(
        venue: venue,
        onClose: () {},
      );

      expect(panel, isNotNull);
      expect(panel.venue.name, equals('Unnamed Venue'));
    });

    test('can be constructed with all parameters', () {
      final venue = VenueTestFactory.createFullPlace();
      const stadiumLocation = LatLng(40.8128, -74.0742);
      var closeCalled = false;

      final panel = VenueRoutePanel(
        key: const Key('test_key'),
        venue: venue,
        stadiumLocation: stadiumLocation,
        onClose: () => closeCalled = true,
      );

      expect(panel.venue, equals(venue));
      expect(panel.stadiumLocation, equals(stadiumLocation));
      expect(panel.key, equals(const Key('test_key')));
      panel.onClose();
      expect(closeCalled, isTrue);
    });

    test('creates state correctly', () {
      final venue = VenueTestFactory.createPlace();
      final panel = VenueRoutePanel(
        venue: venue,
        onClose: () {},
      );

      final state = panel.createState();
      expect(state, isNotNull);
    });
  });
}

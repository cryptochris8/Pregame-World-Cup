import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/venue_portal/presentation/screens/venue_portal_home_screen.dart';

void main() {
  group('VenuePortalHomeScreen', () {
    test('is a StatelessWidget', () {
      const widget = VenuePortalHomeScreen(
        venueId: 'venue123',
        venueName: 'Test Venue',
      );
      expect(widget, isA<StatelessWidget>());
    });

    test('stores venueId', () {
      const widget = VenuePortalHomeScreen(
        venueId: 'venue123',
        venueName: 'Test Venue',
      );
      expect(widget.venueId, equals('venue123'));
    });

    test('stores venueName', () {
      const widget = VenuePortalHomeScreen(
        venueId: 'venue123',
        venueName: 'Test Venue',
      );
      expect(widget.venueName, equals('Test Venue'));
    });

    test('can be constructed with required parameters', () {
      const widget = VenuePortalHomeScreen(
        venueId: 'venue456',
        venueName: 'Another Venue',
      );
      expect(widget.venueId, equals('venue456'));
      expect(widget.venueName, equals('Another Venue'));
    });

    test('stores different venueId values', () {
      const widget1 = VenuePortalHomeScreen(
        venueId: 'venue-abc',
        venueName: 'Venue A',
      );
      const widget2 = VenuePortalHomeScreen(
        venueId: 'venue-xyz',
        venueName: 'Venue B',
      );

      expect(widget1.venueId, equals('venue-abc'));
      expect(widget2.venueId, equals('venue-xyz'));
      expect(widget1.venueId, isNot(equals(widget2.venueId)));
    });

    test('stores different venueName values', () {
      const widget1 = VenuePortalHomeScreen(
        venueId: 'venue1',
        venueName: 'Sports Bar & Grill',
      );
      const widget2 = VenuePortalHomeScreen(
        venueId: 'venue2',
        venueName: 'The Stadium Lounge',
      );

      expect(widget1.venueName, equals('Sports Bar & Grill'));
      expect(widget2.venueName, equals('The Stadium Lounge'));
      expect(widget1.venueName, isNot(equals(widget2.venueName)));
    });
  });
}

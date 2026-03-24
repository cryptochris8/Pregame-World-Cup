import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/venues/widgets/compact_venue_card.dart';
import '../../venues/venue_test_helpers.dart';

void main() {
  group('CompactVenueCard', () {
    test('is a StatelessWidget', () {
      final venue = VenueTestFactory.createPlace();
      final card = CompactVenueCard(venue: venue);
      expect(card, isA<StatelessWidget>());
    });

    test('can be constructed with required venue parameter', () {
      final venue = VenueTestFactory.createPlace();
      final card = CompactVenueCard(venue: venue);
      expect(card, isNotNull);
      expect(card.venue, equals(venue));
    });

    test('stores venue property correctly', () {
      final venue = VenueTestFactory.createFullPlace();
      final card = CompactVenueCard(venue: venue);
      expect(card.venue, equals(venue));
      expect(card.venue.name, equals('MetLife Stadium Sports Bar'));
    });

    test('stores onTap callback when provided', () {
      final venue = VenueTestFactory.createPlace();
      var tapped = false;
      void handleTap() {
        tapped = true;
      }

      final card = CompactVenueCard(
        venue: venue,
        onTap: handleTap,
      );

      expect(card.onTap, isNotNull);
      card.onTap!();
      expect(tapped, isTrue);
    });

    test('onTap is null when not provided', () {
      final venue = VenueTestFactory.createPlace();
      final card = CompactVenueCard(venue: venue);
      expect(card.onTap, isNull);
    });

    test('stores showCategory property when provided', () {
      final venue = VenueTestFactory.createPlace();
      final card = CompactVenueCard(
        venue: venue,
        showCategory: false,
      );
      expect(card.showCategory, isFalse);
    });

    test('showCategory defaults to true when not provided', () {
      final venue = VenueTestFactory.createPlace();
      final card = CompactVenueCard(venue: venue);
      expect(card.showCategory, isTrue);
    });

    test('accepts a key parameter', () {
      final venue = VenueTestFactory.createPlace();
      const testKey = Key('compact_venue_card_key');
      final card = CompactVenueCard(
        key: testKey,
        venue: venue,
      );
      expect(card.key, equals(testKey));
    });

    test('can be constructed with minimal venue data', () {
      final venue = VenueTestFactory.createMinimalPlace();
      final card = CompactVenueCard(venue: venue);
      expect(card, isNotNull);
      expect(card.venue.name, equals('Unnamed Venue'));
    });

    test('can be constructed with restaurant venue', () {
      final venue = VenueTestFactory.createRestaurant();
      final card = CompactVenueCard(venue: venue);
      expect(card, isNotNull);
      expect(card.venue.types, contains('restaurant'));
    });

    test('can be constructed with cafe venue', () {
      final venue = VenueTestFactory.createCafe();
      final card = CompactVenueCard(venue: venue);
      expect(card, isNotNull);
      expect(card.venue.types, contains('cafe'));
    });

    test('can be constructed with popular venue', () {
      final venue = VenueTestFactory.createPopularVenue();
      final card = CompactVenueCard(venue: venue);
      expect(card, isNotNull);
      expect(card.venue.rating, equals(4.9));
      expect(card.venue.userRatingsTotal, equals(1200));
    });

    test('can be constructed with all parameters', () {
      final venue = VenueTestFactory.createFullPlace();
      var tapped = false;
      final card = CompactVenueCard(
        key: const Key('test_key'),
        venue: venue,
        onTap: () => tapped = true,
        showCategory: false,
      );

      expect(card.venue, equals(venue));
      expect(card.showCategory, isFalse);
      expect(card.key, equals(const Key('test_key')));
      card.onTap!();
      expect(tapped, isTrue);
    });
  });
}

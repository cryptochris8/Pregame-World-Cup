import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/venues/widgets/enhanced_venue_card.dart';
import '../../venues/venue_test_helpers.dart';

void main() {
  group('EnhancedVenueCard', () {
    test('is a StatefulWidget', () {
      final venue = VenueTestFactory.createPlace();
      final card = EnhancedVenueCard(venue: venue);
      expect(card, isA<StatefulWidget>());
    });

    test('can be constructed with required venue parameter', () {
      final venue = VenueTestFactory.createPlace();
      final card = EnhancedVenueCard(venue: venue);
      expect(card, isNotNull);
      expect(card.venue, equals(venue));
    });

    test('stores venue property correctly', () {
      final venue = VenueTestFactory.createFullPlace();
      final card = EnhancedVenueCard(venue: venue);
      expect(card.venue, equals(venue));
      expect(card.venue.name, equals('MetLife Stadium Sports Bar'));
    });

    test('stores gameLocation when provided', () {
      final venue = VenueTestFactory.createPlace();
      const gameLocation = 'MetLife Stadium';
      final card = EnhancedVenueCard(
        venue: venue,
        gameLocation: gameLocation,
      );
      expect(card.gameLocation, equals(gameLocation));
    });

    test('gameLocation is null when not provided', () {
      final venue = VenueTestFactory.createPlace();
      final card = EnhancedVenueCard(venue: venue);
      expect(card.gameLocation, isNull);
    });

    test('showPhotos defaults to true when not provided', () {
      final venue = VenueTestFactory.createPlace();
      final card = EnhancedVenueCard(venue: venue);
      expect(card.showPhotos, isTrue);
    });

    test('stores showPhotos property when provided', () {
      final venue = VenueTestFactory.createPlace();
      final card = EnhancedVenueCard(
        venue: venue,
        showPhotos: false,
      );
      expect(card.showPhotos, isFalse);
    });

    test('showQuickActions defaults to false when not provided', () {
      final venue = VenueTestFactory.createPlace();
      final card = EnhancedVenueCard(venue: venue);
      expect(card.showQuickActions, isFalse);
    });

    test('stores showQuickActions property when provided', () {
      final venue = VenueTestFactory.createPlace();
      final card = EnhancedVenueCard(
        venue: venue,
        showQuickActions: true,
      );
      expect(card.showQuickActions, isTrue);
    });

    test('stores onTap callback when provided', () {
      final venue = VenueTestFactory.createPlace();
      var tapped = false;
      void handleTap() {
        tapped = true;
      }

      final card = EnhancedVenueCard(
        venue: venue,
        onTap: handleTap,
      );

      expect(card.onTap, isNotNull);
      card.onTap!();
      expect(tapped, isTrue);
    });

    test('onTap is null when not provided', () {
      final venue = VenueTestFactory.createPlace();
      final card = EnhancedVenueCard(venue: venue);
      expect(card.onTap, isNull);
    });

    test('stores apiKey when provided', () {
      final venue = VenueTestFactory.createPlace();
      const apiKey = 'test_api_key_123';
      final card = EnhancedVenueCard(
        venue: venue,
        apiKey: apiKey,
      );
      expect(card.apiKey, equals(apiKey));
    });

    test('apiKey is null when not provided', () {
      final venue = VenueTestFactory.createPlace();
      final card = EnhancedVenueCard(venue: venue);
      expect(card.apiKey, isNull);
    });

    test('accepts a key parameter', () {
      final venue = VenueTestFactory.createPlace();
      const testKey = Key('enhanced_venue_card_key');
      final card = EnhancedVenueCard(
        key: testKey,
        venue: venue,
      );
      expect(card.key, equals(testKey));
    });

    test('can be constructed with minimal venue data', () {
      final venue = VenueTestFactory.createMinimalPlace();
      final card = EnhancedVenueCard(venue: venue);
      expect(card, isNotNull);
      expect(card.venue.name, equals('Unnamed Venue'));
    });

    test('can be constructed with restaurant venue', () {
      final venue = VenueTestFactory.createRestaurant();
      final card = EnhancedVenueCard(venue: venue);
      expect(card, isNotNull);
      expect(card.venue.types, contains('restaurant'));
    });

    test('can be constructed with popular venue', () {
      final venue = VenueTestFactory.createPopularVenue();
      final card = EnhancedVenueCard(venue: venue);
      expect(card, isNotNull);
      expect(card.venue.rating, equals(4.9));
    });

    test('can be constructed with all parameters', () {
      final venue = VenueTestFactory.createFullPlace();
      var tapped = false;
      const gameLocation = 'MetLife Stadium';
      const apiKey = 'test_key';

      final card = EnhancedVenueCard(
        key: const Key('test_key'),
        venue: venue,
        gameLocation: gameLocation,
        showPhotos: false,
        showQuickActions: true,
        onTap: () => tapped = true,
        apiKey: apiKey,
      );

      expect(card.venue, equals(venue));
      expect(card.gameLocation, equals(gameLocation));
      expect(card.showPhotos, isFalse);
      expect(card.showQuickActions, isTrue);
      expect(card.apiKey, equals(apiKey));
      expect(card.key, equals(const Key('test_key')));
      card.onTap!();
      expect(tapped, isTrue);
    });

    test('multiple cards can be constructed independently', () {
      final venue1 = VenueTestFactory.createRestaurant();
      final venue2 = VenueTestFactory.createCafe();

      final card1 = EnhancedVenueCard(venue: venue1, showPhotos: true);
      final card2 = EnhancedVenueCard(venue: venue2, showPhotos: false);

      expect(card1.venue, equals(venue1));
      expect(card2.venue, equals(venue2));
      expect(card1.showPhotos, isTrue);
      expect(card2.showPhotos, isFalse);
    });
  });
}

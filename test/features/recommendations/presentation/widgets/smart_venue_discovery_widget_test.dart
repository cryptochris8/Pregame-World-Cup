import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/recommendations/presentation/widgets/smart_venue_discovery_widget.dart';
import 'package:pregame_world_cup/features/recommendations/domain/entities/place.dart';
import 'package:pregame_world_cup/features/schedule/domain/entities/game_schedule.dart';

import '../../../schedule/schedule_test_factory.dart';

void main() {
  group('SmartVenueDiscoveryWidget', () {
    final testVenues = [
      Place(
        placeId: 'venue_1',
        name: 'Sports Bar 1',
        vicinity: '123 Main St',
        latitude: 40.7128,
        longitude: -74.0060,
        rating: 4.5,
      ),
      Place(
        placeId: 'venue_2',
        name: 'Sports Bar 2',
        vicinity: '456 Oak Ave',
        latitude: 40.7580,
        longitude: -73.9855,
        rating: 4.2,
      ),
    ];

    test('is a StatefulWidget', () {
      final widget = SmartVenueDiscoveryWidget(venues: testVenues);

      expect(widget, isA<SmartVenueDiscoveryWidget>());
    });

    test('stores venues list', () {
      final widget = SmartVenueDiscoveryWidget(venues: testVenues);

      expect(widget.venues, equals(testVenues));
      expect(widget.venues.length, equals(2));
    });

    test('stores optional game', () {
      final game = ScheduleTestFactory.createGameSchedule();
      final widget = SmartVenueDiscoveryWidget(
        venues: testVenues,
        game: game,
      );

      expect(widget.game, equals(game));
    });

    test('has default context of general', () {
      final widget = SmartVenueDiscoveryWidget(venues: testVenues);

      expect(widget.context, equals('general'));
    });

    test('stores custom context', () {
      final widget = SmartVenueDiscoveryWidget(
        venues: testVenues,
        context: 'pre_game',
      );

      expect(widget.context, equals('pre_game'));
    });

    test('stores optional onVenueSelected callback', () {
      void testCallback(Place place) {}

      final widget = SmartVenueDiscoveryWidget(
        venues: testVenues,
        onVenueSelected: testCallback,
      );

      expect(widget.onVenueSelected, equals(testCallback));
    });

    test('stores optional onVenueFavorited callback', () {
      void testCallback(Place place) {}

      final widget = SmartVenueDiscoveryWidget(
        venues: testVenues,
        onVenueFavorited: testCallback,
      );

      expect(widget.onVenueFavorited, equals(testCallback));
    });

    test('can be constructed with required parameters only', () {
      final widget = SmartVenueDiscoveryWidget(venues: testVenues);

      expect(widget.venues, equals(testVenues));
      expect(widget.game, isNull);
      expect(widget.context, equals('general'));
      expect(widget.onVenueSelected, isNull);
      expect(widget.onVenueFavorited, isNull);
    });

    test('can be constructed with all parameters', () {
      final game = ScheduleTestFactory.createGameSchedule();
      void selectCallback(Place place) {}
      void favoriteCallback(Place place) {}

      final widget = SmartVenueDiscoveryWidget(
        venues: testVenues,
        game: game,
        context: 'post_game',
        onVenueSelected: selectCallback,
        onVenueFavorited: favoriteCallback,
      );

      expect(widget.venues, equals(testVenues));
      expect(widget.game, equals(game));
      expect(widget.context, equals('post_game'));
      expect(widget.onVenueSelected, equals(selectCallback));
      expect(widget.onVenueFavorited, equals(favoriteCallback));
    });

    test('accepts different context values', () {
      final widget1 = SmartVenueDiscoveryWidget(
        venues: testVenues,
        context: 'pre_game',
      );
      final widget2 = SmartVenueDiscoveryWidget(
        venues: testVenues,
        context: 'post_game',
      );
      final widget3 = SmartVenueDiscoveryWidget(
        venues: testVenues,
        context: 'exploration',
      );

      expect(widget1.context, equals('pre_game'));
      expect(widget2.context, equals('post_game'));
      expect(widget3.context, equals('exploration'));
    });

    test('accepts empty venues list', () {
      final widget = SmartVenueDiscoveryWidget(venues: []);

      expect(widget.venues, isEmpty);
    });

    test('stores multiple venues correctly', () {
      final manyVenues = List.generate(
        10,
        (index) => Place(
          placeId: 'venue_$index',
          name: 'Venue $index',
          vicinity: '$index Main St',
          latitude: 40.0 + index,
          longitude: -74.0 - index,
        ),
      );

      final widget = SmartVenueDiscoveryWidget(venues: manyVenues);

      expect(widget.venues.length, equals(10));
      expect(widget.venues[0].name, equals('Venue 0'));
      expect(widget.venues[9].name, equals('Venue 9'));
    });
  });
}

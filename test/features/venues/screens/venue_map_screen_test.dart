import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pregame_world_cup/features/recommendations/domain/entities/place.dart';
import 'package:pregame_world_cup/features/venues/screens/venue_map_screen.dart';
import '../../venues/venue_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Suppress overflow errors during tests
    FlutterError.onError = (details) {
      final exception = details.exception;
      final isOverflowError = exception is FlutterError &&
          !exception.diagnostics.any(
            (e) => e.value.toString().startsWith("A RenderFlex overflowed by"),
          );
      if (isOverflowError) {
        // Ignore overflow errors
      } else {
        FlutterError.presentError(details);
      }
    };
  });

  group('VenueMapScreen', () {
    test('can be constructed with required venues parameter', () {
      final venues = <Place>[
        VenueTestFactory.createPlace(),
      ];

      final widget = VenueMapScreen(
        venues: venues,
      );

      expect(widget, isA<VenueMapScreen>());
      expect(widget.venues, equals(venues));
      expect(widget.stadiumLocation, isNull);
      expect(widget.gameLocation, isNull);
      expect(widget.apiKey, isNull);
    });

    test('can be constructed with all optional parameters', () {
      final venues = <Place>[
        VenueTestFactory.createPlace(),
      ];
      const stadiumLocation = LatLng(40.8128, -74.0742);
      const gameLocation = 'MetLife Stadium';
      const apiKey = 'test_api_key';

      final widget = VenueMapScreen(
        venues: venues,
        stadiumLocation: stadiumLocation,
        gameLocation: gameLocation,
        apiKey: apiKey,
      );

      expect(widget.venues, equals(venues));
      expect(widget.stadiumLocation, equals(stadiumLocation));
      expect(widget.gameLocation, equals(gameLocation));
      expect(widget.apiKey, equals(apiKey));
    });

    test('accepts empty venue list', () {
      final widget = VenueMapScreen(
        venues: const [],
      );

      expect(widget.venues, isEmpty);
    });

    test('accepts multiple venues', () {
      final venues = [
        VenueTestFactory.createRestaurant(),
        VenueTestFactory.createCafe(),
        VenueTestFactory.createPlace(types: ['bar']),
      ];

      final widget = VenueMapScreen(
        venues: venues,
      );

      expect(widget.venues.length, equals(3));
    });

    test('is a StatefulWidget', () {
      final widget = VenueMapScreen(
        venues: [VenueTestFactory.createPlace()],
      );

      expect(widget, isA<StatefulWidget>());
    });

    test('stadiumLocation can be null', () {
      final widget = VenueMapScreen(
        venues: [VenueTestFactory.createPlace()],
        stadiumLocation: null,
      );

      expect(widget.stadiumLocation, isNull);
    });

    test('gameLocation can be null', () {
      final widget = VenueMapScreen(
        venues: [VenueTestFactory.createPlace()],
        gameLocation: null,
      );

      expect(widget.gameLocation, isNull);
    });

    test('apiKey can be null', () {
      final widget = VenueMapScreen(
        venues: [VenueTestFactory.createPlace()],
        apiKey: null,
      );

      expect(widget.apiKey, isNull);
    });

    test('stores stadium location correctly', () {
      const location1 = LatLng(33.9519, -83.3576);
      const location2 = LatLng(40.8128, -74.0742);

      final widget1 = VenueMapScreen(
        venues: [VenueTestFactory.createPlace()],
        stadiumLocation: location1,
      );

      final widget2 = VenueMapScreen(
        venues: [VenueTestFactory.createPlace()],
        stadiumLocation: location2,
      );

      expect(widget1.stadiumLocation, equals(location1));
      expect(widget2.stadiumLocation, equals(location2));
    });

    test('stores game location string correctly', () {
      final widget = VenueMapScreen(
        venues: [VenueTestFactory.createPlace()],
        gameLocation: 'Mercedes-Benz Stadium',
      );

      expect(widget.gameLocation, equals('Mercedes-Benz Stadium'));
    });

    test('stores API key correctly', () {
      final widget = VenueMapScreen(
        venues: [VenueTestFactory.createPlace()],
        apiKey: 'AIzaSyTest123',
      );

      expect(widget.apiKey, equals('AIzaSyTest123'));
    });

    test('creates state object', () {
      final widget = VenueMapScreen(
        venues: [VenueTestFactory.createPlace()],
      );

      final state = widget.createState();

      expect(state, isNotNull);
    });
  });
}

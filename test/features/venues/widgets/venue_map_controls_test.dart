import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/venues/widgets/venue_map_controls.dart';

void main() {
  group('VenueMapBottomControls', () {
    test('is a StatelessWidget', () {
      final controls = VenueMapBottomControls(
        showDistanceRings: false,
        onToggleRings: () {},
        onListView: () {},
        onMyLocation: () {},
      );
      expect(controls, isA<StatelessWidget>());
    });

    test('can be constructed with all required parameters', () {
      var toggleRingsCalled = false;
      var listViewCalled = false;
      var myLocationCalled = false;

      final controls = VenueMapBottomControls(
        showDistanceRings: true,
        onToggleRings: () => toggleRingsCalled = true,
        onListView: () => listViewCalled = true,
        onMyLocation: () => myLocationCalled = true,
      );

      expect(controls, isNotNull);
      expect(controls.showDistanceRings, isTrue);

      controls.onToggleRings();
      expect(toggleRingsCalled, isTrue);

      controls.onListView();
      expect(listViewCalled, isTrue);

      controls.onMyLocation();
      expect(myLocationCalled, isTrue);
    });

    test('stores showDistanceRings property correctly', () {
      final controls1 = VenueMapBottomControls(
        showDistanceRings: true,
        onToggleRings: () {},
        onListView: () {},
        onMyLocation: () {},
      );
      expect(controls1.showDistanceRings, isTrue);

      final controls2 = VenueMapBottomControls(
        showDistanceRings: false,
        onToggleRings: () {},
        onListView: () {},
        onMyLocation: () {},
      );
      expect(controls2.showDistanceRings, isFalse);
    });

    test('stores onToggleRings callback', () {
      var callCount = 0;
      final controls = VenueMapBottomControls(
        showDistanceRings: false,
        onToggleRings: () => callCount++,
        onListView: () {},
        onMyLocation: () {},
      );

      controls.onToggleRings();
      expect(callCount, equals(1));

      controls.onToggleRings();
      expect(callCount, equals(2));
    });

    test('stores onListView callback', () {
      var called = false;
      final controls = VenueMapBottomControls(
        showDistanceRings: false,
        onToggleRings: () {},
        onListView: () => called = true,
        onMyLocation: () {},
      );

      controls.onListView();
      expect(called, isTrue);
    });

    test('stores onMyLocation callback', () {
      var called = false;
      final controls = VenueMapBottomControls(
        showDistanceRings: false,
        onToggleRings: () {},
        onListView: () {},
        onMyLocation: () => called = true,
      );

      controls.onMyLocation();
      expect(called, isTrue);
    });

    test('accepts a key parameter', () {
      const testKey = Key('venue_map_bottom_controls_key');
      final controls = VenueMapBottomControls(
        key: testKey,
        showDistanceRings: false,
        onToggleRings: () {},
        onListView: () {},
        onMyLocation: () {},
      );

      expect(controls.key, equals(testKey));
    });

    test('callbacks are independent', () {
      var toggleCalled = false;
      var listCalled = false;
      var locationCalled = false;

      final controls = VenueMapBottomControls(
        showDistanceRings: false,
        onToggleRings: () => toggleCalled = true,
        onListView: () => listCalled = true,
        onMyLocation: () => locationCalled = true,
      );

      controls.onToggleRings();
      expect(toggleCalled, isTrue);
      expect(listCalled, isFalse);
      expect(locationCalled, isFalse);

      controls.onMyLocation();
      expect(locationCalled, isTrue);
      expect(listCalled, isFalse);
    });
  });

  group('VenueMapFloatingButtons', () {
    test('is a StatelessWidget', () {
      final buttons = VenueMapFloatingButtons(
        onZoomToFit: () {},
        onFocusStadium: () {},
      );
      expect(buttons, isA<StatelessWidget>());
    });

    test('can be constructed with required parameters', () {
      var zoomCalled = false;
      var focusCalled = false;

      final buttons = VenueMapFloatingButtons(
        onZoomToFit: () => zoomCalled = true,
        onFocusStadium: () => focusCalled = true,
      );

      expect(buttons, isNotNull);

      buttons.onZoomToFit();
      expect(zoomCalled, isTrue);

      buttons.onFocusStadium();
      expect(focusCalled, isTrue);
    });

    test('stores onZoomToFit callback', () {
      var callCount = 0;
      final buttons = VenueMapFloatingButtons(
        onZoomToFit: () => callCount++,
        onFocusStadium: () {},
      );

      buttons.onZoomToFit();
      expect(callCount, equals(1));

      buttons.onZoomToFit();
      expect(callCount, equals(2));
    });

    test('stores onFocusStadium callback', () {
      var callCount = 0;
      final buttons = VenueMapFloatingButtons(
        onZoomToFit: () {},
        onFocusStadium: () => callCount++,
      );

      buttons.onFocusStadium();
      expect(callCount, equals(1));
    });

    test('accepts a key parameter', () {
      const testKey = Key('venue_map_floating_buttons_key');
      final buttons = VenueMapFloatingButtons(
        key: testKey,
        onZoomToFit: () {},
        onFocusStadium: () {},
      );

      expect(buttons.key, equals(testKey));
    });

    test('callbacks are independent', () {
      var zoomCalled = false;
      var focusCalled = false;

      final buttons = VenueMapFloatingButtons(
        onZoomToFit: () => zoomCalled = true,
        onFocusStadium: () => focusCalled = true,
      );

      buttons.onZoomToFit();
      expect(zoomCalled, isTrue);
      expect(focusCalled, isFalse);

      buttons.onFocusStadium();
      expect(focusCalled, isTrue);
    });

    test('can be constructed with all parameters', () {
      const testKey = Key('test_key');
      var zoomCalled = false;
      var focusCalled = false;

      final buttons = VenueMapFloatingButtons(
        key: testKey,
        onZoomToFit: () => zoomCalled = true,
        onFocusStadium: () => focusCalled = true,
      );

      expect(buttons.key, equals(testKey));
      buttons.onZoomToFit();
      buttons.onFocusStadium();
      expect(zoomCalled, isTrue);
      expect(focusCalled, isTrue);
    });
  });
}

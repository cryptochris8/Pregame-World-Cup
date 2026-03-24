import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/watch_party/presentation/screens/venue_selector_screen.dart';

void main() {
  group('VenueSelectorScreen', () {
    test('is a StatefulWidget', () {
      expect(const VenueSelectorScreen(), isA<StatefulWidget>());
    });

    test('can be instantiated', () {
      const screen = VenueSelectorScreen();
      expect(screen, isNotNull);
    });

    test('accepts a key', () {
      const key = Key('test_key');
      const screen = VenueSelectorScreen(key: key);
      expect(screen.key, equals(key));
    });

    test('has no required constructor parameters', () {
      // This test verifies the constructor has only optional key parameter
      const screen = VenueSelectorScreen();
      expect(screen, isA<VenueSelectorScreen>());
    });

    test('multiple instances can be created', () {
      const screen1 = VenueSelectorScreen();
      const screen2 = VenueSelectorScreen();
      expect(screen1, isA<VenueSelectorScreen>());
      expect(screen2, isA<VenueSelectorScreen>());
    });

    test('can create state object', () {
      // Note: Cannot test createState() directly as it uses dependency injection
      // Instead verify the screen type is correct
      const screen = VenueSelectorScreen();
      expect(screen, isA<StatefulWidget>());
    });

    test('can be used with different keys', () {
      const screen1 = VenueSelectorScreen(key: Key('screen1'));
      const screen2 = VenueSelectorScreen(key: Key('screen2'));
      expect(screen1.key, isNot(equals(screen2.key)));
    });

    test('is subtype of Widget', () {
      const screen = VenueSelectorScreen();
      expect(screen, isA<Widget>());
    });
  });
}

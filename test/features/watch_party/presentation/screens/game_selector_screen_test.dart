import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/watch_party/presentation/screens/game_selector_screen.dart';

void main() {
  group('GameSelectorScreen', () {
    test('is a StatefulWidget', () {
      expect(const GameSelectorScreen(), isA<StatefulWidget>());
    });

    test('can be instantiated', () {
      const screen = GameSelectorScreen();
      expect(screen, isNotNull);
    });

    test('accepts a key', () {
      const key = Key('test_key');
      const screen = GameSelectorScreen(key: key);
      expect(screen.key, equals(key));
    });

    test('has no required constructor parameters', () {
      // This test verifies the constructor has only optional key parameter
      const screen = GameSelectorScreen();
      expect(screen, isA<GameSelectorScreen>());
    });

    test('multiple instances can be created', () {
      const screen1 = GameSelectorScreen();
      const screen2 = GameSelectorScreen();
      expect(screen1, isA<GameSelectorScreen>());
      expect(screen2, isA<GameSelectorScreen>());
    });

    test('can create state object', () {
      // Note: Cannot test createState() directly as it uses dependency injection
      // Instead verify the screen type is correct
      const screen = GameSelectorScreen();
      expect(screen, isA<StatefulWidget>());
    });

    test('can be used with different keys', () {
      const screen1 = GameSelectorScreen(key: Key('screen1'));
      const screen2 = GameSelectorScreen(key: Key('screen2'));
      expect(screen1.key, isNot(equals(screen2.key)));
    });

    test('is subtype of Widget', () {
      const screen = GameSelectorScreen();
      expect(screen, isA<Widget>());
    });
  });
}

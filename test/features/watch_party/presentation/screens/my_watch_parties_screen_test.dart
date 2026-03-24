import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/watch_party/presentation/screens/my_watch_parties_screen.dart';

void main() {
  group('MyWatchPartiesScreen', () {
    test('is a StatefulWidget', () {
      expect(const MyWatchPartiesScreen(), isA<StatefulWidget>());
    });

    test('can be instantiated', () {
      const screen = MyWatchPartiesScreen();
      expect(screen, isNotNull);
    });

    test('accepts a key', () {
      const key = Key('test_key');
      const screen = MyWatchPartiesScreen(key: key);
      expect(screen.key, equals(key));
    });

    test('createState returns _MyWatchPartiesScreenState', () {
      const screen = MyWatchPartiesScreen();
      final state = screen.createState();
      expect(state, isA<State<MyWatchPartiesScreen>>());
    });

    test('has no required constructor parameters', () {
      // This test verifies the constructor has only optional key parameter
      const screen = MyWatchPartiesScreen();
      expect(screen, isA<MyWatchPartiesScreen>());
    });

    test('multiple instances can be created', () {
      const screen1 = MyWatchPartiesScreen();
      const screen2 = MyWatchPartiesScreen();
      expect(screen1, isA<MyWatchPartiesScreen>());
      expect(screen2, isA<MyWatchPartiesScreen>());
    });

    test('can be used with different keys', () {
      const screen1 = MyWatchPartiesScreen(key: Key('screen1'));
      const screen2 = MyWatchPartiesScreen(key: Key('screen2'));
      expect(screen1.key, isNot(equals(screen2.key)));
    });

    test('is subtype of Widget', () {
      const screen = MyWatchPartiesScreen();
      expect(screen, isA<Widget>());
    });
  });
}

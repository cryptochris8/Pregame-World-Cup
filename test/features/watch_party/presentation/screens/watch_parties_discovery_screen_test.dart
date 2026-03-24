import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/watch_party/presentation/screens/watch_parties_discovery_screen.dart';

void main() {
  group('WatchPartiesDiscoveryScreen', () {
    test('is a StatefulWidget', () {
      expect(const WatchPartiesDiscoveryScreen(), isA<StatefulWidget>());
    });

    test('can be instantiated with no parameters', () {
      const screen = WatchPartiesDiscoveryScreen();
      expect(screen, isNotNull);
    });

    test('accepts a key', () {
      const key = Key('test_key');
      const screen = WatchPartiesDiscoveryScreen(key: key);
      expect(screen.key, equals(key));
    });

    test('can be instantiated with gameId', () {
      const screen = WatchPartiesDiscoveryScreen(gameId: 'game_123');
      expect(screen.gameId, equals('game_123'));
    });

    test('can be instantiated with gameName', () {
      const screen = WatchPartiesDiscoveryScreen(gameName: 'USA vs Mexico');
      expect(screen.gameName, equals('USA vs Mexico'));
    });

    test('can be instantiated with gameDateTime', () {
      final dateTime = DateTime(2026, 6, 15, 20, 0);
      final screen = WatchPartiesDiscoveryScreen(gameDateTime: dateTime);
      expect(screen.gameDateTime, equals(dateTime));
    });

    test('can be instantiated with venueId', () {
      const screen = WatchPartiesDiscoveryScreen(venueId: 'venue_123');
      expect(screen.venueId, equals('venue_123'));
    });

    test('can be instantiated with all parameters', () {
      final dateTime = DateTime(2026, 6, 15, 20, 0);
      final screen = WatchPartiesDiscoveryScreen(
        key: const Key('test_key'),
        gameId: 'game_123',
        gameName: 'USA vs Mexico',
        gameDateTime: dateTime,
        venueId: 'venue_123',
      );
      expect(screen.gameId, equals('game_123'));
      expect(screen.gameName, equals('USA vs Mexico'));
      expect(screen.gameDateTime, equals(dateTime));
      expect(screen.venueId, equals('venue_123'));
    });

    test('optional parameters default to null', () {
      const screen = WatchPartiesDiscoveryScreen();
      expect(screen.gameId, isNull);
      expect(screen.gameName, isNull);
      expect(screen.gameDateTime, isNull);
      expect(screen.venueId, isNull);
    });

    test('createState returns _WatchPartiesDiscoveryScreenState', () {
      const screen = WatchPartiesDiscoveryScreen();
      final state = screen.createState();
      expect(state, isA<State<WatchPartiesDiscoveryScreen>>());
    });

    test('is subtype of Widget', () {
      const screen = WatchPartiesDiscoveryScreen();
      expect(screen, isA<Widget>());
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/watch_party/domain/entities/watch_party.dart';
import 'package:pregame_world_cup/features/watch_party/presentation/screens/edit_watch_party_screen.dart';
import '../../mock_factories.dart';

void main() {
  group('EditWatchPartyScreen', () {
    late WatchParty testWatchParty;

    setUp(() {
      testWatchParty = WatchPartyTestFactory.createWatchParty();
    });

    test('is a StatefulWidget', () {
      final screen = EditWatchPartyScreen(watchParty: testWatchParty);
      expect(screen, isA<StatefulWidget>());
    });

    test('can be instantiated with required watchParty', () {
      final screen = EditWatchPartyScreen(watchParty: testWatchParty);
      expect(screen, isNotNull);
      expect(screen.watchParty, equals(testWatchParty));
    });

    test('accepts a key', () {
      const key = Key('test_key');
      final screen = EditWatchPartyScreen(
        key: key,
        watchParty: testWatchParty,
      );
      expect(screen.key, equals(key));
    });

    test('stores watchParty parameter', () {
      final screen = EditWatchPartyScreen(watchParty: testWatchParty);
      expect(screen.watchParty, equals(testWatchParty));
    });

    test('can be instantiated with different watch parties', () {
      final watchParty1 = WatchPartyTestFactory.createWatchParty(
        watchPartyId: 'wp_1',
        name: 'Watch Party 1',
      );
      final watchParty2 = WatchPartyTestFactory.createWatchParty(
        watchPartyId: 'wp_2',
        name: 'Watch Party 2',
      );

      final screen1 = EditWatchPartyScreen(watchParty: watchParty1);
      final screen2 = EditWatchPartyScreen(watchParty: watchParty2);

      expect(screen1.watchParty.watchPartyId, equals('wp_1'));
      expect(screen2.watchParty.watchPartyId, equals('wp_2'));
    });

    test('createState returns _EditWatchPartyScreenState', () {
      final screen = EditWatchPartyScreen(watchParty: testWatchParty);
      final state = screen.createState();
      expect(state, isA<State<EditWatchPartyScreen>>());
    });

    test('works with watch party with custom name', () {
      final customWatchParty = WatchPartyTestFactory.createWatchParty(
        name: 'Custom Name Party',
        description: 'Custom description',
      );
      final screen = EditWatchPartyScreen(watchParty: customWatchParty);
      expect(screen.watchParty.name, equals('Custom Name Party'));
    });

    test('works with watch party with custom visibility', () {
      final privateParty = WatchPartyTestFactory.createWatchParty(
        visibility: WatchPartyVisibility.private,
      );
      final screen = EditWatchPartyScreen(watchParty: privateParty);
      expect(screen.watchParty.visibility, equals(WatchPartyVisibility.private));
    });

    test('is subtype of Widget', () {
      final screen = EditWatchPartyScreen(watchParty: testWatchParty);
      expect(screen, isA<Widget>());
    });
  });
}

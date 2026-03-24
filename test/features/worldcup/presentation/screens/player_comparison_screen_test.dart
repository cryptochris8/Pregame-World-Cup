import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/presentation/screens/player_comparison_screen.dart';
import 'package:pregame_world_cup/domain/models/player.dart';

void main() {
  group('PlayerComparisonScreen', () {
    test('is a StatefulWidget', () {
      expect(PlayerComparisonScreen(), isA<StatefulWidget>());
    });

    test('can be constructed with no players', () {
      final widget = PlayerComparisonScreen();
      expect(widget.initialPlayer1, isNull);
      expect(widget.initialPlayer2, isNull);
    });

    test('accepts a key parameter', () {
      const key = Key('player_compare');
      final widget = PlayerComparisonScreen(key: key);
      expect(widget.key, equals(key));
    });

    test('stores null initialPlayer1 when not provided', () {
      final widget = PlayerComparisonScreen();
      expect(widget.initialPlayer1, isNull);
    });

    test('stores null initialPlayer2 when not provided', () {
      final widget = PlayerComparisonScreen();
      expect(widget.initialPlayer2, isNull);
    });

    test('multiple instances are independent', () {
      final widget1 = PlayerComparisonScreen();
      final widget2 = PlayerComparisonScreen();
      expect(widget1, isNot(same(widget2)));
    });

    test('can be constructed without parameters', () {
      expect(() => PlayerComparisonScreen(), returnsNormally);
    });

    test('with custom key creates unique widget', () {
      const key1 = Key('compare_1');
      const key2 = Key('compare_2');
      final widget1 = PlayerComparisonScreen(key: key1);
      final widget2 = PlayerComparisonScreen(key: key2);
      expect(widget1.key, isNot(equals(widget2.key)));
    });
  });
}

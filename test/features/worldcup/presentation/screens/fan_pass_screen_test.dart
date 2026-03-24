import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/presentation/screens/fan_pass_screen.dart';

void main() {
  group('FanPassScreen', () {
    test('is a StatefulWidget', () {
      expect(FanPassScreen(), isA<StatefulWidget>());
    });

    test('can be constructed', () {
      expect(FanPassScreen(), isNotNull);
    });

    test('accepts a key parameter', () {
      const key = Key('fan_pass');
      final widget = FanPassScreen(key: key);
      expect(widget.key, equals(key));
    });

    test('multiple instances are independent', () {
      final widget1 = FanPassScreen();
      final widget2 = FanPassScreen();
      expect(widget1, isNot(same(widget2)));
    });

    test('with custom key creates unique widget', () {
      const key1 = Key('fan_pass_1');
      const key2 = Key('fan_pass_2');
      final widget1 = FanPassScreen(key: key1);
      final widget2 = FanPassScreen(key: key2);
      expect(widget1.key, isNot(equals(widget2.key)));
    });

    test('can be constructed without parameters', () {
      expect(() => FanPassScreen(), returnsNormally);
    });

    test('default key is null', () {
      final widget = FanPassScreen();
      expect(widget.key, isNull);
    });
  });
}

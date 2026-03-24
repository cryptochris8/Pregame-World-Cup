import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/presentation/screens/timezone_settings_screen.dart';
import 'package:pregame_world_cup/features/worldcup/utils/timezone_utils.dart';

void main() {
  group('TimezoneSettingsScreen', () {
    test('is a StatefulWidget', () {
      expect(TimezoneSettingsScreen(), isA<StatefulWidget>());
    });

    test('can be constructed', () {
      final widget = TimezoneSettingsScreen();
      expect(widget, isNotNull);
    });

    test('accepts a key parameter', () {
      const key = Key('timezone_settings');
      final widget = TimezoneSettingsScreen(key: key);
      expect(widget.key, equals(key));
    });

    test('creates state with createState', () {
      final widget = TimezoneSettingsScreen();
      final state = widget.createState();
      expect(state, isNotNull);
    });

    test('multiple instances are independent', () {
      final widget1 = TimezoneSettingsScreen();
      final widget2 = TimezoneSettingsScreen();
      expect(widget1, isNot(same(widget2)));
    });

    test('can be constructed without parameters', () {
      expect(() => TimezoneSettingsScreen(), returnsNormally);
    });
  });

  group('TimezoneDisplayMode', () {
    test('has local value', () {
      expect(TimezoneDisplayMode.local, isNotNull);
    });

    test('has venue value', () {
      expect(TimezoneDisplayMode.venue, isNotNull);
    });

    test('has both value', () {
      expect(TimezoneDisplayMode.both, isNotNull);
    });

    test('has exactly 3 values', () {
      expect(TimezoneDisplayMode.values.length, 3);
    });

    test('values are unique', () {
      expect(TimezoneDisplayMode.local, isNot(equals(TimezoneDisplayMode.venue)));
      expect(TimezoneDisplayMode.local, isNot(equals(TimezoneDisplayMode.both)));
      expect(TimezoneDisplayMode.venue, isNot(equals(TimezoneDisplayMode.both)));
    });

    test('enum values have correct indices', () {
      expect(TimezoneDisplayMode.local.index, 0);
      expect(TimezoneDisplayMode.venue.index, 1);
      expect(TimezoneDisplayMode.both.index, 2);
    });

    test('values list contains all modes', () {
      final values = TimezoneDisplayMode.values;
      expect(values, contains(TimezoneDisplayMode.local));
      expect(values, contains(TimezoneDisplayMode.venue));
      expect(values, contains(TimezoneDisplayMode.both));
    });
  });
}

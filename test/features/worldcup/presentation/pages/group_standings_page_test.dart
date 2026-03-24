import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/presentation/pages/group_standings_page.dart';

void main() {
  group('GroupStandingsPage', () {
    test('is a StatefulWidget', () {
      expect(GroupStandingsPage(), isA<StatefulWidget>());
    });

    test('can be constructed', () {
      final widget = GroupStandingsPage();
      expect(widget, isNotNull);
    });

    test('accepts a key parameter', () {
      const key = Key('test');
      final widget = GroupStandingsPage(key: key);
      expect(widget.key, equals(key));
    });

    test('creates state with createState', () {
      final widget = GroupStandingsPage();
      final state = widget.createState();
      expect(state, isNotNull);
    });

    test('multiple instances are independent', () {
      final widget1 = GroupStandingsPage();
      final widget2 = GroupStandingsPage();
      expect(widget1, isNot(same(widget2)));
    });

    test('with custom key creates unique widget', () {
      const key1 = Key('group_standings_1');
      const key2 = Key('group_standings_2');
      final widget1 = GroupStandingsPage(key: key1);
      final widget2 = GroupStandingsPage(key: key2);
      expect(widget1.key, isNot(equals(widget2.key)));
    });

    test('can be constructed without parameters', () {
      expect(() => GroupStandingsPage(), returnsNormally);
    });
  });
}

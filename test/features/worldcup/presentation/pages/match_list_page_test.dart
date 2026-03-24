import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/presentation/pages/match_list_page.dart';

void main() {
  group('MatchListPage', () {
    test('is a StatefulWidget', () {
      const widget = MatchListPage();
      expect(widget, isA<StatefulWidget>());
    });

    test('can be constructed with default constructor', () {
      const widget = MatchListPage();
      expect(widget, isNotNull);
    });

    test('accepts a key parameter', () {
      const key = Key('match_list_key');
      const widget = MatchListPage(key: key);
      expect(widget.key, equals(key));
    });

    test('constructor is const', () {
      const widget = MatchListPage();
      expect(widget, isA<MatchListPage>());
    });

    test('createState returns correct state type', () {
      const widget = MatchListPage();
      final state = widget.createState();
      expect(state, isA<State<MatchListPage>>());
    });

    test('is a widget that can be part of widget tree', () {
      const widget = MatchListPage();
      expect(widget, isA<Widget>());
    });

    test('maintains type safety with StatefulWidget', () {
      const widget = MatchListPage();
      expect(widget.runtimeType, equals(MatchListPage));
    });

    test('can create multiple instances', () {
      const widget1 = MatchListPage();
      const widget2 = MatchListPage(key: Key('different'));
      expect(widget1, isA<MatchListPage>());
      expect(widget2, isA<MatchListPage>());
    });
  });
}

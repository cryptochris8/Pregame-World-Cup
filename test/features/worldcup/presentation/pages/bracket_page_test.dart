import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/presentation/pages/bracket_page.dart';

void main() {
  group('BracketPage', () {
    test('is a StatefulWidget', () {
      const widget = BracketPage();
      expect(widget, isA<StatefulWidget>());
    });

    test('can be constructed with default constructor', () {
      const widget = BracketPage();
      expect(widget, isNotNull);
    });

    test('accepts a key parameter', () {
      const key = Key('bracket_key');
      const widget = BracketPage(key: key);
      expect(widget.key, equals(key));
    });

    test('constructor is const', () {
      const widget = BracketPage();
      expect(widget, isA<BracketPage>());
    });

    test('createState returns correct state type', () {
      const widget = BracketPage();
      final state = widget.createState();
      expect(state, isA<State<BracketPage>>());
    });

    test('is a widget that can be part of widget tree', () {
      const widget = BracketPage();
      expect(widget, isA<Widget>());
    });

    test('maintains type safety with StatefulWidget', () {
      const widget = BracketPage();
      expect(widget.runtimeType, equals(BracketPage));
    });

    test('can create multiple instances', () {
      const widget1 = BracketPage();
      const widget2 = BracketPage(key: Key('different'));
      expect(widget1, isA<BracketPage>());
      expect(widget2, isA<BracketPage>());
    });
  });

  group('FullBracketView', () {
    test('is a StatelessWidget', () {
      const widget = FullBracketView();
      expect(widget, isA<StatelessWidget>());
    });

    test('can be constructed with default constructor', () {
      const widget = FullBracketView();
      expect(widget, isNotNull);
    });

    test('accepts a key parameter', () {
      const key = Key('full_bracket_key');
      const widget = FullBracketView(key: key);
      expect(widget.key, equals(key));
    });

    test('constructor is const', () {
      const widget = FullBracketView();
      expect(widget, isA<FullBracketView>());
    });

    test('is a widget that can be part of widget tree', () {
      const widget = FullBracketView();
      expect(widget, isA<Widget>());
    });

    test('maintains type safety with StatelessWidget', () {
      const widget = FullBracketView();
      expect(widget.runtimeType, equals(FullBracketView));
    });
  });
}

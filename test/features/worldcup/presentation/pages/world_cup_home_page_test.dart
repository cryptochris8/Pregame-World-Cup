import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/presentation/pages/world_cup_home_page.dart';

void main() {
  group('WorldCupHomePage', () {
    test('is a StatefulWidget', () {
      const widget = WorldCupHomePage();
      expect(widget, isA<StatefulWidget>());
    });

    test('can be constructed with default constructor', () {
      const widget = WorldCupHomePage();
      expect(widget, isNotNull);
    });

    test('accepts a key parameter', () {
      const key = Key('test_key');
      const widget = WorldCupHomePage(key: key);
      expect(widget.key, equals(key));
    });

    test('constructor is const', () {
      const widget = WorldCupHomePage();
      expect(widget, isA<WorldCupHomePage>());
    });

    test('createState returns correct state type', () {
      const widget = WorldCupHomePage();
      final state = widget.createState();
      expect(state, isA<State<WorldCupHomePage>>());
    });

    test('is a widget that can be part of widget tree', () {
      const widget = WorldCupHomePage();
      expect(widget, isA<Widget>());
    });

    test('maintains type safety with StatefulWidget', () {
      const widget = WorldCupHomePage();
      expect(widget.runtimeType, equals(WorldCupHomePage));
    });

    test('can create multiple instances', () {
      const widget1 = WorldCupHomePage();
      const widget2 = WorldCupHomePage(key: Key('different'));
      expect(widget1, isA<WorldCupHomePage>());
      expect(widget2, isA<WorldCupHomePage>());
    });
  });

  group('WorldCupDashboardPage', () {
    test('is a StatelessWidget', () {
      const widget = WorldCupDashboardPage();
      expect(widget, isA<StatelessWidget>());
    });

    test('can be constructed with default constructor', () {
      const widget = WorldCupDashboardPage();
      expect(widget, isNotNull);
    });

    test('accepts a key parameter', () {
      const key = Key('dashboard_key');
      const widget = WorldCupDashboardPage(key: key);
      expect(widget.key, equals(key));
    });

    test('constructor is const', () {
      const widget = WorldCupDashboardPage();
      expect(widget, isA<WorldCupDashboardPage>());
    });

    test('is a widget that can be part of widget tree', () {
      const widget = WorldCupDashboardPage();
      expect(widget, isA<Widget>());
    });

    test('maintains type safety with StatelessWidget', () {
      const widget = WorldCupDashboardPage();
      expect(widget.runtimeType, equals(WorldCupDashboardPage));
    });
  });
}

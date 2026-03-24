import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/presentation/pages/teams_page.dart';

void main() {
  group('TeamsPage', () {
    test('is a StatefulWidget', () {
      const widget = TeamsPage();
      expect(widget, isA<StatefulWidget>());
    });

    test('can be constructed with default constructor', () {
      const widget = TeamsPage();
      expect(widget, isNotNull);
    });

    test('accepts a key parameter', () {
      const key = Key('teams_key');
      const widget = TeamsPage(key: key);
      expect(widget.key, equals(key));
    });

    test('constructor is const', () {
      const widget = TeamsPage();
      expect(widget, isA<TeamsPage>());
    });

    test('createState returns correct state type', () {
      const widget = TeamsPage();
      final state = widget.createState();
      expect(state, isA<State<TeamsPage>>());
    });

    test('is a widget that can be part of widget tree', () {
      const widget = TeamsPage();
      expect(widget, isA<Widget>());
    });

    test('maintains type safety with StatefulWidget', () {
      const widget = TeamsPage();
      expect(widget.runtimeType, equals(TeamsPage));
    });

    test('can create multiple instances', () {
      const widget1 = TeamsPage();
      const widget2 = TeamsPage(key: Key('different'));
      expect(widget1, isA<TeamsPage>());
      expect(widget2, isA<TeamsPage>());
    });
  });

  group('TeamsByConfederationPage', () {
    test('is a StatelessWidget', () {
      const widget = TeamsByConfederationPage();
      expect(widget, isA<StatelessWidget>());
    });

    test('can be constructed with default constructor', () {
      const widget = TeamsByConfederationPage();
      expect(widget, isNotNull);
    });

    test('accepts a key parameter', () {
      const key = Key('confederation_key');
      const widget = TeamsByConfederationPage(key: key);
      expect(widget.key, equals(key));
    });

    test('constructor is const', () {
      const widget = TeamsByConfederationPage();
      expect(widget, isA<TeamsByConfederationPage>());
    });

    test('is a widget that can be part of widget tree', () {
      const widget = TeamsByConfederationPage();
      expect(widget, isA<Widget>());
    });

    test('maintains type safety with StatelessWidget', () {
      const widget = TeamsByConfederationPage();
      expect(widget.runtimeType, equals(TeamsByConfederationPage));
    });
  });
}

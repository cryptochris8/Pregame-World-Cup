import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/presentation/pages/predictions_page.dart';

void main() {
  group('PredictionsPage', () {
    test('is a StatefulWidget', () {
      const widget = PredictionsPage();
      expect(widget, isA<StatefulWidget>());
    });

    test('can be constructed with default constructor', () {
      const widget = PredictionsPage();
      expect(widget, isNotNull);
    });

    test('accepts a key parameter', () {
      const key = Key('predictions_key');
      const widget = PredictionsPage(key: key);
      expect(widget.key, equals(key));
    });

    test('constructor is const', () {
      const widget = PredictionsPage();
      expect(widget, isA<PredictionsPage>());
    });

    test('createState returns correct state type', () {
      const widget = PredictionsPage();
      final state = widget.createState();
      expect(state, isA<State<PredictionsPage>>());
    });

    test('is a widget that can be part of widget tree', () {
      const widget = PredictionsPage();
      expect(widget, isA<Widget>());
    });

    test('maintains type safety with StatefulWidget', () {
      const widget = PredictionsPage();
      expect(widget.runtimeType, equals(PredictionsPage));
    });

    test('can create multiple instances', () {
      const widget1 = PredictionsPage();
      const widget2 = PredictionsPage(key: Key('different'));
      expect(widget1, isA<PredictionsPage>());
      expect(widget2, isA<PredictionsPage>());
    });
  });

  group('PredictionsFilter', () {
    test('has all enum value', () {
      expect(PredictionsFilter.all, isA<PredictionsFilter>());
    });

    test('has pending enum value', () {
      expect(PredictionsFilter.pending, isA<PredictionsFilter>());
    });

    test('has correct enum value', () {
      expect(PredictionsFilter.correct, isA<PredictionsFilter>());
    });

    test('has incorrect enum value', () {
      expect(PredictionsFilter.incorrect, isA<PredictionsFilter>());
    });

    test('contains exactly 4 values', () {
      expect(PredictionsFilter.values.length, equals(4));
    });

    test('enum values are distinct', () {
      final values = PredictionsFilter.values.toSet();
      expect(values.length, equals(4));
    });

    test('can be used in equality comparisons', () {
      final filter1 = PredictionsFilter.all;
      final filter2 = PredictionsFilter.all;
      final filter3 = PredictionsFilter.pending;
      expect(filter1, equals(filter2));
      expect(filter1, isNot(equals(filter3)));
    });

    test('all values can be accessed by index', () {
      expect(PredictionsFilter.values[0], equals(PredictionsFilter.all));
      expect(PredictionsFilter.values[1], equals(PredictionsFilter.pending));
      expect(PredictionsFilter.values[2], equals(PredictionsFilter.correct));
      expect(PredictionsFilter.values[3], equals(PredictionsFilter.incorrect));
    });
  });
}

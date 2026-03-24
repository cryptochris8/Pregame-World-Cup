import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/widgets/accessible_widgets.dart';

void main() {
  group('AccessibleWidgets Constants', () {
    test('kMinimumTouchTargetSize equals 48.0', () {
      expect(kMinimumTouchTargetSize, equals(48.0));
    });

    test('kLargerTouchTargetSize equals 56.0', () {
      expect(kLargerTouchTargetSize, equals(56.0));
    });
  });

  group('AccessibleButton', () {
    test('is a StatelessWidget', () {
      final button = AccessibleButton(
        onPressed: () {},
        child: const Text('Test'),
        semanticLabel: 'Test button',
      );

      expect(button, isA<StatelessWidget>());
    });

    test('stores onPressed callback', () {
      void testCallback() {}

      final button = AccessibleButton(
        onPressed: testCallback,
        child: const Text('Test'),
        semanticLabel: 'Test button',
      );

      expect(button.onPressed, equals(testCallback));
    });

    test('stores child widget', () {
      const child = Text('Test');

      final button = AccessibleButton(
        onPressed: () {},
        child: child,
        semanticLabel: 'Test button',
      );

      expect(button.child, equals(child));
    });

    test('stores semanticLabel', () {
      const label = 'Test button label';

      final button = AccessibleButton(
        onPressed: () {},
        child: const Text('Test'),
        semanticLabel: label,
      );

      expect(button.semanticLabel, equals(label));
    });

    test('stores optional semanticHint', () {
      const hint = 'Double tap to activate';

      final button = AccessibleButton(
        onPressed: () {},
        child: const Text('Test'),
        semanticLabel: 'Test button',
        semanticHint: hint,
      );

      expect(button.semanticHint, equals(hint));
    });

    test('isEnabled defaults to true', () {
      final button = AccessibleButton(
        onPressed: () {},
        child: const Text('Test'),
        semanticLabel: 'Test button',
      );

      expect(button.isEnabled, isTrue);
    });

    test('isSelected defaults to false', () {
      final button = AccessibleButton(
        onPressed: () {},
        child: const Text('Test'),
        semanticLabel: 'Test button',
      );

      expect(button.isSelected, isFalse);
    });

    test('isToggle defaults to false', () {
      final button = AccessibleButton(
        onPressed: () {},
        child: const Text('Test'),
        semanticLabel: 'Test button',
      );

      expect(button.isToggle, isFalse);
    });

    test('stores optional backgroundColor', () {
      const backgroundColor = Colors.blue;

      final button = AccessibleButton(
        onPressed: () {},
        child: const Text('Test'),
        semanticLabel: 'Test button',
        backgroundColor: backgroundColor,
      );

      expect(button.backgroundColor, equals(backgroundColor));
    });

    test('stores optional borderRadius', () {
      final borderRadius = BorderRadius.circular(12);

      final button = AccessibleButton(
        onPressed: () {},
        child: const Text('Test'),
        semanticLabel: 'Test button',
        borderRadius: borderRadius,
      );

      expect(button.borderRadius, equals(borderRadius));
    });

    test('can be constructed with required parameters only', () {
      final button = AccessibleButton(
        onPressed: () {},
        child: const Text('Test'),
        semanticLabel: 'Test button',
      );

      expect(button.onPressed, isNotNull);
      expect(button.child, isNotNull);
      expect(button.semanticLabel, isNotNull);
      expect(button.isEnabled, isTrue);
      expect(button.isSelected, isFalse);
      expect(button.isToggle, isFalse);
    });

    test('can be constructed with all parameters', () {
      void onPressed() {}
      void onLongPress() {}
      const child = Text('Test');
      const semanticLabel = 'Test button';
      const semanticHint = 'Double tap to activate';
      const isEnabled = false;
      const isSelected = true;
      const isToggle = true;
      const padding = EdgeInsets.all(16);
      const backgroundColor = Colors.red;
      const foregroundColor = Colors.white;
      final borderRadius = BorderRadius.circular(16);
      const minWidth = 100.0;
      const minHeight = 60.0;

      final button = AccessibleButton(
        onPressed: onPressed,
        onLongPress: onLongPress,
        child: child,
        semanticLabel: semanticLabel,
        semanticHint: semanticHint,
        isEnabled: isEnabled,
        isSelected: isSelected,
        isToggle: isToggle,
        padding: padding,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        borderRadius: borderRadius,
        minWidth: minWidth,
        minHeight: minHeight,
      );

      expect(button.onPressed, equals(onPressed));
      expect(button.onLongPress, equals(onLongPress));
      expect(button.child, equals(child));
      expect(button.semanticLabel, equals(semanticLabel));
      expect(button.semanticHint, equals(semanticHint));
      expect(button.isEnabled, equals(isEnabled));
      expect(button.isSelected, equals(isSelected));
      expect(button.isToggle, equals(isToggle));
      expect(button.padding, equals(padding));
      expect(button.backgroundColor, equals(backgroundColor));
      expect(button.foregroundColor, equals(foregroundColor));
      expect(button.borderRadius, equals(borderRadius));
      expect(button.minWidth, equals(minWidth));
      expect(button.minHeight, equals(minHeight));
    });
  });
}

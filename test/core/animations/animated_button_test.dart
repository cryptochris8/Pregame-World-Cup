import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/animations/animated_button.dart';

void main() {
  group('AnimatedButton', () {
    test('is a StatefulWidget', () {
      const widget = AnimatedButton(child: Text('Test'));
      expect(widget, isA<StatefulWidget>());
    });

    test('stores child widget', () {
      const child = Text('Test');
      const widget = AnimatedButton(child: child);
      expect(widget.child, equals(child));
    });

    test('onTap defaults to null', () {
      const widget = AnimatedButton(child: Text('Test'));
      expect(widget.onTap, isNull);
    });

    test('scaleValue defaults to 0.95', () {
      const widget = AnimatedButton(child: Text('Test'));
      expect(widget.scaleValue, equals(0.95));
    });

    test('enableHaptics defaults to true', () {
      const widget = AnimatedButton(child: Text('Test'));
      expect(widget.enableHaptics, isTrue);
    });

    test('enabled defaults to true', () {
      const widget = AnimatedButton(child: Text('Test'));
      expect(widget.enabled, isTrue);
    });

    test('animationDuration defaults to 150ms', () {
      const widget = AnimatedButton(child: Text('Test'));
      expect(widget.animationDuration, equals(const Duration(milliseconds: 150)));
    });

    test('can be constructed with all parameters', () {
      void onTap() {}
      final shadow = BoxShadow(
        color: Colors.black.withValues(alpha: 0.3),
        blurRadius: 8,
        offset: const Offset(0, 4),
      );

      final widget = AnimatedButton(
        onTap: onTap,
        animationDuration: const Duration(milliseconds: 200),
        scaleValue: 0.9,
        backgroundColor: Colors.blue,
        splashColor: Colors.white,
        borderRadius: BorderRadius.circular(8),
        padding: const EdgeInsets.all(16),
        enableHaptics: false,
        enabled: false,
        shadow: shadow,
        child: const Text('Test'),
      );

      expect(widget.onTap, equals(onTap));
      expect(widget.animationDuration, equals(const Duration(milliseconds: 200)));
      expect(widget.scaleValue, equals(0.9));
      expect(widget.backgroundColor, equals(Colors.blue));
      expect(widget.splashColor, equals(Colors.white));
      expect(widget.borderRadius, equals(BorderRadius.circular(8)));
      expect(widget.padding, equals(const EdgeInsets.all(16)));
      expect(widget.enableHaptics, isFalse);
      expect(widget.enabled, isFalse);
      expect(widget.shadow, equals(shadow));
    });
  });

  group('AnimatedFAB', () {
    test('is a StatefulWidget', () {
      const widget = AnimatedFAB(child: Icon(Icons.add));
      expect(widget, isA<StatefulWidget>());
    });

    test('stores child widget', () {
      const child = Icon(Icons.add);
      const widget = AnimatedFAB(child: child);
      expect(widget.child, equals(child));
    });

    test('extended defaults to false', () {
      const widget = AnimatedFAB(child: Icon(Icons.add));
      expect(widget.extended, isFalse);
    });

    test('can be constructed with required params', () {
      void onPressed() {}
      const label = Text('Add');

      final widget = AnimatedFAB(
        onPressed: onPressed,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        heroTag: 'test-fab',
        extended: true,
        label: label,
        child: const Icon(Icons.add),
      );

      expect(widget.onPressed, equals(onPressed));
      expect(widget.backgroundColor, equals(Colors.blue));
      expect(widget.foregroundColor, equals(Colors.white));
      expect(widget.heroTag, equals('test-fab'));
      expect(widget.extended, isTrue);
      expect(widget.label, same(label));
    });
  });

  group('AnimatedListItem', () {
    test('is a StatefulWidget', () {
      const widget = AnimatedListItem(
        index: 0,
        child: Text('Test'),
      );
      expect(widget, isA<StatefulWidget>());
    });

    test('stores child and index', () {
      const child = Text('Test');
      const widget = AnimatedListItem(
        child: child,
        index: 5,
      );
      expect(widget.child, equals(child));
      expect(widget.index, equals(5));
    });

    test('delay defaults to 100ms', () {
      const widget = AnimatedListItem(
        index: 0,
        child: Text('Test'),
      );
      expect(widget.delay, equals(const Duration(milliseconds: 100)));
    });
  });

  group('RippleEffect', () {
    test('is a StatefulWidget', () {
      const widget = RippleEffect(child: Text('Test'));
      expect(widget, isA<StatefulWidget>());
    });

    test('stores child', () {
      const child = Text('Test');
      const widget = RippleEffect(child: child);
      expect(widget.child, equals(child));
    });

    test('rippleColor defaults to white', () {
      const widget = RippleEffect(child: Text('Test'));
      expect(widget.rippleColor, equals(Colors.white));
    });

    test('duration defaults to 400ms', () {
      const widget = RippleEffect(child: Text('Test'));
      expect(widget.duration, equals(const Duration(milliseconds: 400)));
    });
  });
}

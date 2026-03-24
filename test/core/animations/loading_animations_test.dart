import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/animations/loading_animations.dart';

void main() {
  group('PulsingLoader', () {
    test('is a StatefulWidget', () {
      const widget = PulsingLoader();
      expect(widget, isA<StatefulWidget>());
    });

    test('color defaults to blue', () {
      const widget = PulsingLoader();
      expect(widget.color, equals(Colors.blue));
    });

    test('size defaults to 50.0', () {
      const widget = PulsingLoader();
      expect(widget.size, equals(50.0));
    });

    test('duration defaults to 1200ms', () {
      const widget = PulsingLoader();
      expect(widget.duration, equals(const Duration(milliseconds: 1200)));
    });
  });

  group('DotsLoader', () {
    test('is a StatefulWidget', () {
      const widget = DotsLoader();
      expect(widget, isA<StatefulWidget>());
    });

    test('color defaults to blue', () {
      const widget = DotsLoader();
      expect(widget.color, equals(Colors.blue));
    });

    test('size defaults to 8.0', () {
      const widget = DotsLoader();
      expect(widget.size, equals(8.0));
    });

    test('duration defaults to 600ms', () {
      const widget = DotsLoader();
      expect(widget.duration, equals(const Duration(milliseconds: 600)));
    });
  });

  group('SkeletonLoader', () {
    test('is a StatefulWidget', () {
      const widget = SkeletonLoader(
        width: 100,
        height: 50,
      );
      expect(widget, isA<StatefulWidget>());
    });

    test('stores width and height', () {
      const widget = SkeletonLoader(
        width: 200,
        height: 100,
      );
      expect(widget.width, equals(200));
      expect(widget.height, equals(100));
    });

    test('borderRadius defaults to null', () {
      const widget = SkeletonLoader(
        width: 100,
        height: 50,
      );
      expect(widget.borderRadius, isNull);
    });
  });

  group('EnhancedLoadingState', () {
    test('is a StatelessWidget', () {
      const widget = EnhancedLoadingState();
      expect(widget, isA<StatelessWidget>());
    });

    test('message defaults to Loading...', () {
      const widget = EnhancedLoadingState();
      expect(widget.message, equals('Loading...'));
    });

    test('showPulse defaults to true', () {
      const widget = EnhancedLoadingState();
      expect(widget.showPulse, isTrue);
    });
  });

  group('ListItemSkeleton', () {
    test('is a StatelessWidget', () {
      const widget = ListItemSkeleton();
      expect(widget, isA<StatelessWidget>());
    });

    test('hasAvatar defaults to true', () {
      const widget = ListItemSkeleton();
      expect(widget.hasAvatar, isTrue);
    });

    test('hasSubtitle defaults to true', () {
      const widget = ListItemSkeleton();
      expect(widget.hasSubtitle, isTrue);
    });
  });

  group('CardSkeleton', () {
    test('is a StatelessWidget', () {
      const widget = CardSkeleton();
      expect(widget, isA<StatelessWidget>());
    });

    test('height defaults to null', () {
      const widget = CardSkeleton();
      expect(widget.height, isNull);
    });
  });
}

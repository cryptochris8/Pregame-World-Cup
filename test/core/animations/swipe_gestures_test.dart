import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/animations/swipe_gestures.dart';

void main() {
  group('SwipeableWidget', () {
    test('is a StatefulWidget', () {
      const widget = SwipeableWidget(child: Text('Test'));
      expect(widget, isA<StatefulWidget>());
    });

    test('stores child', () {
      const child = Text('Test');
      const widget = SwipeableWidget(child: child);
      expect(widget.child, equals(child));
    });

    test('swipeThreshold defaults to 100.0', () {
      const widget = SwipeableWidget(child: Text('Test'));
      expect(widget.swipeThreshold, equals(100.0));
    });

    test('enableHaptics defaults to true', () {
      const widget = SwipeableWidget(child: Text('Test'));
      expect(widget.enableHaptics, isTrue);
    });

    test('animationDuration defaults to 300ms', () {
      const widget = SwipeableWidget(child: Text('Test'));
      expect(widget.animationDuration, equals(const Duration(milliseconds: 300)));
    });

    test('swipe callbacks default to null', () {
      const widget = SwipeableWidget(child: Text('Test'));
      expect(widget.onSwipeLeft, isNull);
      expect(widget.onSwipeRight, isNull);
      expect(widget.onSwipeUp, isNull);
      expect(widget.onSwipeDown, isNull);
    });
  });

  group('SwipeablePageView', () {
    test('is a StatefulWidget', () {
      const widget = SwipeablePageView(children: [Text('Page 1')]);
      expect(widget, isA<StatefulWidget>());
    });

    test('stores children list', () {
      const children = [Text('Page 1'), Text('Page 2')];
      const widget = SwipeablePageView(children: children);
      expect(widget.children, equals(children));
    });

    test('initialPage defaults to 0', () {
      const widget = SwipeablePageView(children: [Text('Page 1')]);
      expect(widget.initialPage, equals(0));
    });

    test('enableSwipe defaults to true', () {
      const widget = SwipeablePageView(children: [Text('Page 1')]);
      expect(widget.enableSwipe, isTrue);
    });
  });

  group('SwipeToDismiss', () {
    test('is a StatefulWidget', () {
      const widget = SwipeToDismiss(child: Text('Test'));
      expect(widget, isA<StatefulWidget>());
    });

    test('stores child', () {
      const child = Text('Test');
      const widget = SwipeToDismiss(child: child);
      expect(widget.child, equals(child));
    });

    test('dismissColor defaults to red', () {
      const widget = SwipeToDismiss(child: Text('Test'));
      expect(widget.dismissColor, equals(Colors.red));
    });

    test('dismissLabel defaults to Delete', () {
      const widget = SwipeToDismiss(child: Text('Test'));
      expect(widget.dismissLabel, equals('Delete'));
    });

    test('direction defaults to endToStart', () {
      const widget = SwipeToDismiss(child: Text('Test'));
      expect(widget.direction, equals(DismissDirection.endToStart));
    });
  });

  group('SwipeRefresh', () {
    test('is a StatefulWidget', () {
      final widget = SwipeRefresh(
        onRefresh: () async {},
        child: const Text('Test'),
      );
      expect(widget, isA<StatefulWidget>());
    });

    test('stores child and onRefresh', () {
      const child = Text('Test');
      Future<void> onRefresh() async {}

      final widget = SwipeRefresh(
        onRefresh: onRefresh,
        child: child,
      );
      expect(widget.child, equals(child));
      expect(widget.onRefresh, equals(onRefresh));
    });

    test('refreshText defaults to Pull to refresh', () {
      final widget = SwipeRefresh(
        onRefresh: () async {},
        child: const Text('Test'),
      );
      expect(widget.refreshText, equals('Pull to refresh'));
    });
  });

  group('SwipeableCardStack', () {
    test('is a StatefulWidget', () {
      const widget = SwipeableCardStack(cards: [Text('Card 1')]);
      expect(widget, isA<StatefulWidget>());
    });

    test('stores cards list', () {
      const cards = [Text('Card 1'), Text('Card 2')];
      const widget = SwipeableCardStack(cards: cards);
      expect(widget.cards, equals(cards));
    });

    test('callbacks default to null', () {
      const widget = SwipeableCardStack(cards: [Text('Card 1')]);
      expect(widget.onSwipeLeft, isNull);
      expect(widget.onSwipeRight, isNull);
      expect(widget.onStackEmpty, isNull);
    });
  });
}

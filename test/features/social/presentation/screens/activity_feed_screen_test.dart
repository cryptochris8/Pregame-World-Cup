import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/social/presentation/screens/activity_feed_screen.dart';

void main() {
  group('ActivityFeedScreen', () {
    test('is a StatefulWidget', () {
      const widget = ActivityFeedScreen();
      expect(widget, isA<StatefulWidget>());
    });

    test('can be constructed', () {
      const widget = ActivityFeedScreen();
      expect(widget, isNotNull);
    });

    test('has correct runtimeType', () {
      const widget = ActivityFeedScreen();
      expect(widget.runtimeType.toString(), 'ActivityFeedScreen');
    });

    test('creates multiple instances', () {
      const w1 = ActivityFeedScreen();
      const w2 = ActivityFeedScreen();
      expect(w1, isNotNull);
      expect(w2, isNotNull);
    });
  });
}

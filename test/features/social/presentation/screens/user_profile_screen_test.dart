import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/social/presentation/screens/user_profile_screen.dart';

void main() {
  group('UserProfileScreen', () {
    test('is a StatefulWidget', () {
      const widget = UserProfileScreen();
      expect(widget, isA<StatefulWidget>());
    });

    test('can be constructed', () {
      const widget = UserProfileScreen();
      expect(widget, isNotNull);
    });

    test('has correct runtimeType', () {
      const widget = UserProfileScreen();
      expect(widget.runtimeType.toString(), 'UserProfileScreen');
    });

    test('creates multiple instances', () {
      const w1 = UserProfileScreen();
      const w2 = UserProfileScreen();
      expect(w1, isNotNull);
      expect(w2, isNotNull);
    });

    test('can be constructed with userId parameter', () {
      const userId = 'test-user-id-123';
      const widget = UserProfileScreen(userId: userId);
      expect(widget, isNotNull);
      expect(widget.userId, equals(userId));
    });

    test('can be constructed without userId parameter', () {
      const widget = UserProfileScreen();
      expect(widget, isNotNull);
      expect(widget.userId, isNull);
    });

    test('stores userId parameter correctly when provided', () {
      const userId = 'test-user-id-456';
      const widget = UserProfileScreen(userId: userId);
      expect(widget.userId, equals(userId));
    });
  });
}

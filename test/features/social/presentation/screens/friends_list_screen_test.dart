import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/social/presentation/screens/friends_list_screen.dart';

void main() {
  group('FriendsListScreen', () {
    test('is a StatefulWidget', () {
      const widget = FriendsListScreen(
        userId: 'test-user-id',
        initialTab: 'friends',
      );
      expect(widget, isA<StatefulWidget>());
    });

    test('can be constructed', () {
      const widget = FriendsListScreen(
        userId: 'test-user-id',
        initialTab: 'friends',
      );
      expect(widget, isNotNull);
    });

    test('has correct runtimeType', () {
      const widget = FriendsListScreen(
        userId: 'test-user-id',
        initialTab: 'friends',
      );
      expect(widget.runtimeType.toString(), 'FriendsListScreen');
    });

    test('creates multiple instances', () {
      const w1 = FriendsListScreen(
        userId: 'test-user-id-1',
        initialTab: 'friends',
      );
      const w2 = FriendsListScreen(
        userId: 'test-user-id-2',
        initialTab: 'pending',
      );
      expect(w1, isNotNull);
      expect(w2, isNotNull);
    });

    test('stores userId parameter correctly', () {
      const userId = 'test-user-id-123';
      const widget = FriendsListScreen(
        userId: userId,
        initialTab: 'friends',
      );
      expect(widget.userId, equals(userId));
    });

    test('stores initialTab parameter correctly', () {
      const initialTab = 'pending';
      const widget = FriendsListScreen(
        userId: 'test-user-id',
        initialTab: initialTab,
      );
      expect(widget.initialTab, equals(initialTab));
    });
  });
}

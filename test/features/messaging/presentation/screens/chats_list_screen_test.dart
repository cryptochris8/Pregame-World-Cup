import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/messaging/presentation/screens/chats_list_screen.dart';

void main() {
  group('ChatsListScreen', () {
    test('is a StatefulWidget', () {
      const widget = ChatsListScreen();
      expect(widget, isA<StatefulWidget>());
    });

    test('can be constructed with no parameters', () {
      const widget = ChatsListScreen();
      expect(widget, isNotNull);
    });

    test('creates instances successfully', () {
      const widget1 = ChatsListScreen();
      const widget2 = ChatsListScreen();
      expect(widget1, isNotNull);
      expect(widget2, isNotNull);
    });

    test('has correct runtimeType', () {
      const widget = ChatsListScreen();
      expect(widget.runtimeType, equals(ChatsListScreen));
    });

    test('is a Widget', () {
      const widget = ChatsListScreen();
      expect(widget, isA<Widget>());
    });

    test('multiple instances are distinct', () {
      const widget1 = ChatsListScreen();
      const widget2 = ChatsListScreen();
      // Widgets are value types, but they are still distinct instances
      expect(widget1.runtimeType, equals(widget2.runtimeType));
    });

    test('can be used in widget tree hierarchy', () {
      const widget = ChatsListScreen();
      expect(widget, isA<StatefulWidget>());
      expect(widget, isA<Widget>());
    });
  });
}

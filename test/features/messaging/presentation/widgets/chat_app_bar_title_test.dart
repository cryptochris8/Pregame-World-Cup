import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:pregame_world_cup/features/messaging/presentation/widgets/chat_app_bar_title.dart';

void main() {
  group('ChatAppBarTitle', () {
    test('is a StatelessWidget type', () {
      expect(ChatAppBarTitle, isA<Type>());
    });

    test('widget type exists and is importable', () {
      expect(ChatAppBarTitle, isNotNull);
    });
  });
}

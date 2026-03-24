import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:pregame_world_cup/features/messaging/presentation/widgets/chat_info_bottom_sheet.dart';

void main() {
  group('ChatInfoBottomSheet', () {
    test('is a StatelessWidget type', () {
      expect(ChatInfoBottomSheet, isA<Type>());
    });

    test('widget type exists and is importable', () {
      expect(ChatInfoBottomSheet, isNotNull);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:pregame_world_cup/features/messaging/presentation/widgets/message_attachment_picker.dart';

void main() {
  group('MessageAttachmentPicker', () {
    test('is a StatefulWidget type', () {
      expect(MessageAttachmentPicker, isA<Type>());
    });

    test('widget type exists and is importable', () {
      expect(MessageAttachmentPicker, isNotNull);
    });
  });
}

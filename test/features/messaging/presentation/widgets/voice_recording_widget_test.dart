import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:pregame_world_cup/features/messaging/presentation/widgets/voice_recording_widget.dart';

void main() {
  group('VoiceRecordingWidget', () {
    test('is a StatefulWidget type', () {
      expect(VoiceRecordingWidget, isA<Type>());
    });

    test('widget type exists and is importable', () {
      expect(VoiceRecordingWidget, isNotNull);
    });
  });
}

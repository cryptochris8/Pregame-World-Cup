import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/messaging/presentation/widgets/voice_message_widget.dart';
import 'package:pregame_world_cup/features/messaging/domain/services/voice_recording_service.dart';
import '../../messaging_test_factory.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('VoiceMessageWidget', () {
    late VoiceRecordingService mockVoiceService;

    setUp(() {
      mockVoiceService = VoiceRecordingService();
    });

    test('is a StatefulWidget', () {
      expect(VoiceMessageWidget, isA<Type>());
    });

    test('can be constructed with required params', () {
      final voiceMessage = MessagingTestFactory.createVoiceMessageEntity();

      final widget = VoiceMessageWidget(
        voiceMessage: voiceMessage,
        voiceService: mockVoiceService,
      );

      expect(widget, isNotNull);
      expect(widget, isA<VoiceMessageWidget>());
    });

    test('stores voiceMessage correctly', () {
      final voiceMessage = MessagingTestFactory.createVoiceMessageEntity(
        messageId: 'voice_msg_123',
        audioUrl: 'https://example.com/audio.m4a',
        durationSeconds: 45,
      );

      final widget = VoiceMessageWidget(
        voiceMessage: voiceMessage,
        voiceService: mockVoiceService,
      );

      expect(widget.voiceMessage, equals(voiceMessage));
      expect(widget.voiceMessage.messageId, equals('voice_msg_123'));
      expect(widget.voiceMessage.audioUrl, equals('https://example.com/audio.m4a'));
      expect(widget.voiceMessage.durationSeconds, equals(45));
    });

    test('stores voiceService correctly', () {
      final voiceMessage = MessagingTestFactory.createVoiceMessageEntity();

      final widget = VoiceMessageWidget(
        voiceMessage: voiceMessage,
        voiceService: mockVoiceService,
      );

      expect(widget.voiceService, equals(mockVoiceService));
    });

    test('has default value for isSentByCurrentUser', () {
      final voiceMessage = MessagingTestFactory.createVoiceMessageEntity();

      final widget = VoiceMessageWidget(
        voiceMessage: voiceMessage,
        voiceService: mockVoiceService,
      );

      expect(widget.isSentByCurrentUser, isFalse);
    });

    test('stores isSentByCurrentUser when provided', () {
      final voiceMessage = MessagingTestFactory.createVoiceMessageEntity();

      final widget = VoiceMessageWidget(
        voiceMessage: voiceMessage,
        voiceService: mockVoiceService,
        isSentByCurrentUser: true,
      );

      expect(widget.isSentByCurrentUser, isTrue);
    });

    test('has default primaryColor', () {
      final voiceMessage = MessagingTestFactory.createVoiceMessageEntity();

      final widget = VoiceMessageWidget(
        voiceMessage: voiceMessage,
        voiceService: mockVoiceService,
      );

      expect(widget.primaryColor, equals(const Color(0xFF8B4513)));
    });

    test('has default secondaryColor', () {
      final voiceMessage = MessagingTestFactory.createVoiceMessageEntity();

      final widget = VoiceMessageWidget(
        voiceMessage: voiceMessage,
        voiceService: mockVoiceService,
      );

      expect(widget.secondaryColor, equals(const Color(0xFFFF8C00)));
    });

    test('stores custom primaryColor when provided', () {
      final voiceMessage = MessagingTestFactory.createVoiceMessageEntity();
      const customPrimaryColor = Colors.blue;

      final widget = VoiceMessageWidget(
        voiceMessage: voiceMessage,
        voiceService: mockVoiceService,
        primaryColor: customPrimaryColor,
      );

      expect(widget.primaryColor, equals(customPrimaryColor));
    });

    test('stores custom secondaryColor when provided', () {
      final voiceMessage = MessagingTestFactory.createVoiceMessageEntity();
      const customSecondaryColor = Colors.green;

      final widget = VoiceMessageWidget(
        voiceMessage: voiceMessage,
        voiceService: mockVoiceService,
        secondaryColor: customSecondaryColor,
      );

      expect(widget.secondaryColor, equals(customSecondaryColor));
    });

    test('stores custom colors when both provided', () {
      final voiceMessage = MessagingTestFactory.createVoiceMessageEntity();
      const customPrimaryColor = Colors.purple;
      const customSecondaryColor = Colors.orange;

      final widget = VoiceMessageWidget(
        voiceMessage: voiceMessage,
        voiceService: mockVoiceService,
        primaryColor: customPrimaryColor,
        secondaryColor: customSecondaryColor,
      );

      expect(widget.primaryColor, equals(customPrimaryColor));
      expect(widget.secondaryColor, equals(customSecondaryColor));
    });

    test('stores voiceMessage with waveform data', () {
      final voiceMessage = MessagingTestFactory.createVoiceMessageEntity(
        waveformData: [0.1, 0.3, 0.5, 0.7, 0.9],
      );

      final widget = VoiceMessageWidget(
        voiceMessage: voiceMessage,
        voiceService: mockVoiceService,
      );

      expect(widget.voiceMessage.waveformData.length, equals(5));
      expect(widget.voiceMessage.waveformData[0], equals(0.1));
      expect(widget.voiceMessage.waveformData[4], equals(0.9));
    });

    test('stores voiceMessage with empty waveform data', () {
      final voiceMessage = MessagingTestFactory.createVoiceMessageEntity(
        waveformData: [],
      );

      final widget = VoiceMessageWidget(
        voiceMessage: voiceMessage,
        voiceService: mockVoiceService,
      );

      expect(widget.voiceMessage.waveformData, isEmpty);
    });

    test('stores voiceMessage with isPlaying state', () {
      final voiceMessage1 = MessagingTestFactory.createVoiceMessageEntity(
        isPlaying: false,
      );
      final voiceMessage2 = MessagingTestFactory.createVoiceMessageEntity(
        isPlaying: true,
      );

      final widget1 = VoiceMessageWidget(
        voiceMessage: voiceMessage1,
        voiceService: mockVoiceService,
      );
      final widget2 = VoiceMessageWidget(
        voiceMessage: voiceMessage2,
        voiceService: mockVoiceService,
      );

      expect(widget1.voiceMessage.isPlaying, isFalse);
      expect(widget2.voiceMessage.isPlaying, isTrue);
    });

    test('stores voiceMessage with currentPosition', () {
      final voiceMessage = MessagingTestFactory.createVoiceMessageEntity(
        currentPosition: 15,
      );

      final widget = VoiceMessageWidget(
        voiceMessage: voiceMessage,
        voiceService: mockVoiceService,
      );

      expect(widget.voiceMessage.currentPosition, equals(15));
    });

    test('works with all optional params', () {
      final voiceMessage = MessagingTestFactory.createVoiceMessageEntity(
        messageId: 'voice_123',
        audioUrl: 'https://example.com/test.m4a',
        durationSeconds: 60,
        waveformData: [0.2, 0.4, 0.6],
        isPlaying: true,
        currentPosition: 30,
      );

      final widget = VoiceMessageWidget(
        voiceMessage: voiceMessage,
        voiceService: mockVoiceService,
        isSentByCurrentUser: true,
        primaryColor: Colors.red,
        secondaryColor: Colors.yellow,
      );

      expect(widget.voiceMessage.messageId, equals('voice_123'));
      expect(widget.voiceMessage.durationSeconds, equals(60));
      expect(widget.isSentByCurrentUser, isTrue);
      expect(widget.primaryColor, equals(Colors.red));
      expect(widget.secondaryColor, equals(Colors.yellow));
    });
  });
}

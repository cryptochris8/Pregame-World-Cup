import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/messaging/domain/entities/voice_message.dart';

void main() {
  group('VoiceMessage', () {
    group('Constructor', () {
      test('creates voice message with required fields', () {
        const voiceMessage = VoiceMessage(
          messageId: 'vm_1',
          audioUrl: 'https://example.com/audio.m4a',
          durationSeconds: 45,
        );

        expect(voiceMessage.messageId, equals('vm_1'));
        expect(voiceMessage.audioUrl, equals('https://example.com/audio.m4a'));
        expect(voiceMessage.durationSeconds, equals(45));
        expect(voiceMessage.waveformData, isEmpty);
        expect(voiceMessage.isPlaying, isFalse);
        expect(voiceMessage.currentPosition, isNull);
      });

      test('creates voice message with all fields', () {
        const waveform = [0.1, 0.5, 0.8, 0.3, 0.9];
        const voiceMessage = VoiceMessage(
          messageId: 'vm_2',
          audioUrl: 'https://example.com/audio2.m4a',
          durationSeconds: 120,
          waveformData: waveform,
          isPlaying: true,
          currentPosition: 30,
        );

        expect(voiceMessage.waveformData, equals(waveform));
        expect(voiceMessage.isPlaying, isTrue);
        expect(voiceMessage.currentPosition, equals(30));
      });
    });

    group('formattedDuration', () {
      test('formats seconds under a minute', () {
        const voiceMessage = VoiceMessage(
          messageId: 'vm_fmt_1',
          audioUrl: 'url',
          durationSeconds: 45,
        );

        expect(voiceMessage.formattedDuration, equals('00:45'));
      });

      test('formats exact minute', () {
        const voiceMessage = VoiceMessage(
          messageId: 'vm_fmt_2',
          audioUrl: 'url',
          durationSeconds: 60,
        );

        expect(voiceMessage.formattedDuration, equals('01:00'));
      });

      test('formats minutes and seconds', () {
        const voiceMessage = VoiceMessage(
          messageId: 'vm_fmt_3',
          audioUrl: 'url',
          durationSeconds: 125, // 2:05
        );

        expect(voiceMessage.formattedDuration, equals('02:05'));
      });

      test('formats zero duration', () {
        const voiceMessage = VoiceMessage(
          messageId: 'vm_fmt_4',
          audioUrl: 'url',
          durationSeconds: 0,
        );

        expect(voiceMessage.formattedDuration, equals('00:00'));
      });

      test('formats single digit seconds with padding', () {
        const voiceMessage = VoiceMessage(
          messageId: 'vm_fmt_5',
          audioUrl: 'url',
          durationSeconds: 65, // 1:05
        );

        expect(voiceMessage.formattedDuration, equals('01:05'));
      });

      test('formats large duration', () {
        const voiceMessage = VoiceMessage(
          messageId: 'vm_fmt_6',
          audioUrl: 'url',
          durationSeconds: 3661, // 61:01
        );

        expect(voiceMessage.formattedDuration, equals('61:01'));
      });
    });

    group('progress', () {
      test('returns 0.0 when currentPosition is null', () {
        const voiceMessage = VoiceMessage(
          messageId: 'vm_prog_1',
          audioUrl: 'url',
          durationSeconds: 60,
        );

        expect(voiceMessage.progress, equals(0.0));
      });

      test('returns 0.0 when duration is zero', () {
        const voiceMessage = VoiceMessage(
          messageId: 'vm_prog_2',
          audioUrl: 'url',
          durationSeconds: 0,
          currentPosition: 10,
        );

        expect(voiceMessage.progress, equals(0.0));
      });

      test('returns correct progress ratio', () {
        const voiceMessage = VoiceMessage(
          messageId: 'vm_prog_3',
          audioUrl: 'url',
          durationSeconds: 100,
          currentPosition: 50,
        );

        expect(voiceMessage.progress, equals(0.5));
      });

      test('returns 1.0 at end of playback', () {
        const voiceMessage = VoiceMessage(
          messageId: 'vm_prog_4',
          audioUrl: 'url',
          durationSeconds: 60,
          currentPosition: 60,
        );

        expect(voiceMessage.progress, equals(1.0));
      });

      test('clamps progress to 0.0-1.0 range', () {
        // Position exceeds duration (edge case)
        const voiceMessage = VoiceMessage(
          messageId: 'vm_prog_5',
          audioUrl: 'url',
          durationSeconds: 60,
          currentPosition: 120,
        );

        expect(voiceMessage.progress, equals(1.0));
      });

      test('returns correct progress at 25%', () {
        const voiceMessage = VoiceMessage(
          messageId: 'vm_prog_6',
          audioUrl: 'url',
          durationSeconds: 80,
          currentPosition: 20,
        );

        expect(voiceMessage.progress, equals(0.25));
      });
    });

    group('copyWith', () {
      test('copies with updated isPlaying', () {
        const original = VoiceMessage(
          messageId: 'vm_copy_1',
          audioUrl: 'url',
          durationSeconds: 60,
          isPlaying: false,
        );

        final updated = original.copyWith(isPlaying: true);

        expect(updated.isPlaying, isTrue);
        expect(updated.messageId, equals('vm_copy_1'));
        expect(updated.audioUrl, equals('url'));
        expect(updated.durationSeconds, equals(60));
      });

      test('copies with updated currentPosition', () {
        const original = VoiceMessage(
          messageId: 'vm_copy_2',
          audioUrl: 'url',
          durationSeconds: 60,
        );

        final updated = original.copyWith(currentPosition: 30);

        expect(updated.currentPosition, equals(30));
        expect(updated.messageId, equals('vm_copy_2'));
      });

      test('copies with multiple updated fields', () {
        const original = VoiceMessage(
          messageId: 'vm_copy_3',
          audioUrl: 'url1',
          durationSeconds: 60,
          waveformData: [0.1, 0.5],
        );

        final updated = original.copyWith(
          audioUrl: 'url2',
          durationSeconds: 120,
          waveformData: [0.2, 0.8, 0.4],
          isPlaying: true,
          currentPosition: 10,
        );

        expect(updated.audioUrl, equals('url2'));
        expect(updated.durationSeconds, equals(120));
        expect(updated.waveformData, equals([0.2, 0.8, 0.4]));
        expect(updated.isPlaying, isTrue);
        expect(updated.currentPosition, equals(10));
        expect(updated.messageId, equals('vm_copy_3')); // unchanged
      });

      test('preserves original when no changes provided', () {
        const original = VoiceMessage(
          messageId: 'vm_copy_4',
          audioUrl: 'url',
          durationSeconds: 60,
          waveformData: [0.5],
          isPlaying: true,
          currentPosition: 25,
        );

        final copy = original.copyWith();

        expect(copy.messageId, equals(original.messageId));
        expect(copy.audioUrl, equals(original.audioUrl));
        expect(copy.durationSeconds, equals(original.durationSeconds));
        expect(copy.waveformData, equals(original.waveformData));
        expect(copy.isPlaying, equals(original.isPlaying));
        expect(copy.currentPosition, equals(original.currentPosition));
      });
    });

    group('JSON serialization', () {
      test('toJson serializes correctly', () {
        const voiceMessage = VoiceMessage(
          messageId: 'vm_json_1',
          audioUrl: 'https://example.com/audio.m4a',
          durationSeconds: 90,
          waveformData: [0.1, 0.5, 0.9],
          isPlaying: true,
          currentPosition: 45,
        );

        final json = voiceMessage.toJson();

        expect(json['messageId'], equals('vm_json_1'));
        expect(json['audioUrl'], equals('https://example.com/audio.m4a'));
        expect(json['durationSeconds'], equals(90));
        expect(json['waveformData'], equals([0.1, 0.5, 0.9]));
        expect(json['isPlaying'], isTrue);
        expect(json['currentPosition'], equals(45));
      });

      test('fromJson deserializes correctly', () {
        final json = <String, dynamic>{
          'messageId': 'vm_json_2',
          'audioUrl': 'https://example.com/audio2.m4a',
          'durationSeconds': 30,
          'waveformData': <dynamic>[0.2, 0.8],
          'isPlaying': false,
          'currentPosition': null,
        };

        final voiceMessage = VoiceMessage.fromJson(json);

        expect(voiceMessage.messageId, equals('vm_json_2'));
        expect(voiceMessage.audioUrl, equals('https://example.com/audio2.m4a'));
        expect(voiceMessage.durationSeconds, equals(30));
        expect(voiceMessage.waveformData, equals([0.2, 0.8]));
        expect(voiceMessage.isPlaying, isFalse);
        expect(voiceMessage.currentPosition, isNull);
      });

      test('fromJson handles missing optional fields', () {
        final json = <String, dynamic>{
          'messageId': 'vm_json_3',
          'audioUrl': 'url',
          'durationSeconds': 15,
        };

        final voiceMessage = VoiceMessage.fromJson(json);

        expect(voiceMessage.waveformData, isEmpty);
        expect(voiceMessage.isPlaying, isFalse);
        expect(voiceMessage.currentPosition, isNull);
      });

      test('roundtrip serialization preserves data', () {
        const original = VoiceMessage(
          messageId: 'vm_roundtrip',
          audioUrl: 'https://example.com/audio.m4a',
          durationSeconds: 75,
          waveformData: [0.1, 0.3, 0.7, 0.5, 0.9],
          isPlaying: false,
          currentPosition: 20,
        );

        final json = original.toJson();
        final restored = VoiceMessage.fromJson(json);

        expect(restored.messageId, equals(original.messageId));
        expect(restored.audioUrl, equals(original.audioUrl));
        expect(restored.durationSeconds, equals(original.durationSeconds));
        expect(restored.waveformData, equals(original.waveformData));
        expect(restored.isPlaying, equals(original.isPlaying));
        expect(restored.currentPosition, equals(original.currentPosition));
      });
    });

    group('Equatable', () {
      test('two voice messages with same props are equal', () {
        const vm1 = VoiceMessage(
          messageId: 'vm_eq_1',
          audioUrl: 'url',
          durationSeconds: 60,
          waveformData: [0.5],
          isPlaying: false,
        );

        const vm2 = VoiceMessage(
          messageId: 'vm_eq_1',
          audioUrl: 'url',
          durationSeconds: 60,
          waveformData: [0.5],
          isPlaying: false,
        );

        expect(vm1, equals(vm2));
      });

      test('two voice messages with different props are not equal', () {
        const vm1 = VoiceMessage(
          messageId: 'vm_eq_1',
          audioUrl: 'url',
          durationSeconds: 60,
        );

        const vm2 = VoiceMessage(
          messageId: 'vm_eq_2',
          audioUrl: 'url',
          durationSeconds: 60,
        );

        expect(vm1, isNot(equals(vm2)));
      });

      test('same message in different play states are not equal', () {
        const vm1 = VoiceMessage(
          messageId: 'vm_eq_play',
          audioUrl: 'url',
          durationSeconds: 60,
          isPlaying: true,
        );

        const vm2 = VoiceMessage(
          messageId: 'vm_eq_play',
          audioUrl: 'url',
          durationSeconds: 60,
          isPlaying: false,
        );

        expect(vm1, isNot(equals(vm2)));
      });
    });
  });
}

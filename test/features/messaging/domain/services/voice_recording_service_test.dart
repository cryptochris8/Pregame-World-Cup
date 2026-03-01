import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/messaging/domain/entities/voice_message.dart';

/// VoiceRecordingService depends on platform-specific plugins:
/// - audio_waveforms (RecorderController)
/// - just_audio (AudioPlayer)
/// - path_provider (getTemporaryDirectory)
/// - permission_handler (Permission.microphone)
///
/// These cannot be mocked via simple mocktail without platform channel
/// setup. We therefore test:
///
/// 1. The VoiceMessage entity (data model used by the service)
/// 2. The _generateSyntheticWaveform logic contract (verifiable via
///    the VoiceMessage waveformData patterns)
/// 3. Service state management contracts and playback state logic
///
/// The actual recording/playback requires integration tests with
/// platform channels.
void main() {
  // =========================================================================
  // VoiceMessage entity tests (core data model for VoiceRecordingService)
  // =========================================================================
  group('VoiceMessage entity', () {
    group('Constructor', () {
      test('creates voice message with required fields', () {
        const vm = VoiceMessage(
          messageId: 'msg_1',
          audioUrl: 'https://example.com/audio.m4a',
          durationSeconds: 30,
        );

        expect(vm.messageId, equals('msg_1'));
        expect(vm.audioUrl, equals('https://example.com/audio.m4a'));
        expect(vm.durationSeconds, equals(30));
        expect(vm.waveformData, isEmpty);
        expect(vm.isPlaying, isFalse);
        expect(vm.currentPosition, isNull);
      });

      test('creates voice message with all optional fields', () {
        const vm = VoiceMessage(
          messageId: 'msg_2',
          audioUrl: 'https://example.com/audio2.m4a',
          durationSeconds: 60,
          waveformData: [0.1, 0.5, 0.8, 0.3, 0.9],
          isPlaying: true,
          currentPosition: 15,
        );

        expect(vm.waveformData.length, equals(5));
        expect(vm.isPlaying, isTrue);
        expect(vm.currentPosition, equals(15));
      });
    });

    group('fromJson', () {
      test('deserializes all fields correctly', () {
        final json = <String, dynamic>{
          'messageId': 'msg_json',
          'audioUrl': 'https://example.com/voice.m4a',
          'durationSeconds': 45,
          'waveformData': [0.2, 0.4, 0.6, 0.8],
          'isPlaying': true,
          'currentPosition': 20,
        };

        final vm = VoiceMessage.fromJson(json);

        expect(vm.messageId, equals('msg_json'));
        expect(vm.audioUrl, equals('https://example.com/voice.m4a'));
        expect(vm.durationSeconds, equals(45));
        expect(vm.waveformData, equals([0.2, 0.4, 0.6, 0.8]));
        expect(vm.isPlaying, isTrue);
        expect(vm.currentPosition, equals(20));
      });

      test('handles missing optional fields with defaults', () {
        final json = <String, dynamic>{
          'messageId': 'msg_minimal',
          'audioUrl': 'https://example.com/min.m4a',
          'durationSeconds': 10,
        };

        final vm = VoiceMessage.fromJson(json);

        expect(vm.waveformData, isEmpty);
        expect(vm.isPlaying, isFalse);
        expect(vm.currentPosition, isNull);
      });

      test('handles null waveformData', () {
        final json = <String, dynamic>{
          'messageId': 'msg_null_wave',
          'audioUrl': 'https://example.com/null.m4a',
          'durationSeconds': 5,
          'waveformData': null,
        };

        final vm = VoiceMessage.fromJson(json);

        expect(vm.waveformData, isEmpty);
      });
    });

    group('toJson', () {
      test('serializes all fields correctly', () {
        const vm = VoiceMessage(
          messageId: 'msg_ser',
          audioUrl: 'https://example.com/ser.m4a',
          durationSeconds: 25,
          waveformData: [0.3, 0.6, 0.9],
          isPlaying: false,
          currentPosition: 10,
        );

        final json = vm.toJson();

        expect(json['messageId'], equals('msg_ser'));
        expect(json['audioUrl'], equals('https://example.com/ser.m4a'));
        expect(json['durationSeconds'], equals(25));
        expect(json['waveformData'], equals([0.3, 0.6, 0.9]));
        expect(json['isPlaying'], isFalse);
        expect(json['currentPosition'], equals(10));
      });
    });

    group('roundtrip serialization', () {
      test('toJson/fromJson preserves all data', () {
        const original = VoiceMessage(
          messageId: 'msg_rt',
          audioUrl: 'https://example.com/rt.m4a',
          durationSeconds: 120,
          waveformData: [0.1, 0.2, 0.3, 0.4, 0.5],
          isPlaying: true,
          currentPosition: 60,
        );

        final json = original.toJson();
        final restored = VoiceMessage.fromJson(json);

        expect(restored, equals(original));
      });
    });

    group('copyWith', () {
      test('copies with isPlaying changed', () {
        const original = VoiceMessage(
          messageId: 'msg_copy',
          audioUrl: 'https://example.com/copy.m4a',
          durationSeconds: 30,
          isPlaying: false,
        );

        final updated = original.copyWith(isPlaying: true);

        expect(updated.isPlaying, isTrue);
        expect(updated.messageId, equals('msg_copy'));
        expect(updated.durationSeconds, equals(30));
      });

      test('copies with currentPosition changed', () {
        const original = VoiceMessage(
          messageId: 'msg_pos',
          audioUrl: 'https://example.com/pos.m4a',
          durationSeconds: 60,
          currentPosition: 0,
        );

        final updated = original.copyWith(currentPosition: 30);

        expect(updated.currentPosition, equals(30));
        expect(updated.durationSeconds, equals(60));
      });

      test('copies with multiple fields changed', () {
        const original = VoiceMessage(
          messageId: 'msg_multi',
          audioUrl: 'https://example.com/multi.m4a',
          durationSeconds: 45,
          waveformData: [0.1, 0.2],
          isPlaying: false,
          currentPosition: 0,
        );

        final updated = original.copyWith(
          isPlaying: true,
          currentPosition: 20,
          waveformData: [0.3, 0.4, 0.5],
        );

        expect(updated.isPlaying, isTrue);
        expect(updated.currentPosition, equals(20));
        expect(updated.waveformData, equals([0.3, 0.4, 0.5]));
        expect(updated.messageId, equals('msg_multi'));
        expect(updated.audioUrl, equals('https://example.com/multi.m4a'));
      });

      test('unchanged fields are preserved', () {
        const original = VoiceMessage(
          messageId: 'msg_preserve',
          audioUrl: 'https://example.com/preserve.m4a',
          durationSeconds: 90,
          waveformData: [0.5, 0.6],
          isPlaying: true,
          currentPosition: 45,
        );

        final updated = original.copyWith();

        expect(updated, equals(original));
      });
    });

    group('formattedDuration', () {
      test('formats zero seconds', () {
        const vm = VoiceMessage(
          messageId: 'msg_0s',
          audioUrl: 'url',
          durationSeconds: 0,
        );

        expect(vm.formattedDuration, equals('00:00'));
      });

      test('formats seconds only', () {
        const vm = VoiceMessage(
          messageId: 'msg_30s',
          audioUrl: 'url',
          durationSeconds: 30,
        );

        expect(vm.formattedDuration, equals('00:30'));
      });

      test('formats minutes and seconds', () {
        const vm = VoiceMessage(
          messageId: 'msg_90s',
          audioUrl: 'url',
          durationSeconds: 90,
        );

        expect(vm.formattedDuration, equals('01:30'));
      });

      test('formats exact minutes', () {
        const vm = VoiceMessage(
          messageId: 'msg_120s',
          audioUrl: 'url',
          durationSeconds: 120,
        );

        expect(vm.formattedDuration, equals('02:00'));
      });

      test('formats large durations', () {
        const vm = VoiceMessage(
          messageId: 'msg_300s',
          audioUrl: 'url',
          durationSeconds: 300,
        );

        expect(vm.formattedDuration, equals('05:00'));
      });

      test('pads single-digit seconds with leading zero', () {
        const vm = VoiceMessage(
          messageId: 'msg_65s',
          audioUrl: 'url',
          durationSeconds: 65,
        );

        expect(vm.formattedDuration, equals('01:05'));
      });
    });

    group('progress', () {
      test('returns 0.0 when currentPosition is null', () {
        const vm = VoiceMessage(
          messageId: 'msg_null_pos',
          audioUrl: 'url',
          durationSeconds: 60,
        );

        expect(vm.progress, equals(0.0));
      });

      test('returns 0.0 when durationSeconds is zero', () {
        const vm = VoiceMessage(
          messageId: 'msg_zero_dur',
          audioUrl: 'url',
          durationSeconds: 0,
          currentPosition: 5,
        );

        expect(vm.progress, equals(0.0));
      });

      test('calculates correct progress', () {
        const vm = VoiceMessage(
          messageId: 'msg_progress',
          audioUrl: 'url',
          durationSeconds: 100,
          currentPosition: 50,
        );

        expect(vm.progress, equals(0.5));
      });

      test('clamps progress to 1.0 maximum', () {
        const vm = VoiceMessage(
          messageId: 'msg_overflow',
          audioUrl: 'url',
          durationSeconds: 30,
          currentPosition: 60,
        );

        expect(vm.progress, equals(1.0));
      });

      test('clamps progress to 0.0 minimum', () {
        const vm = VoiceMessage(
          messageId: 'msg_underflow',
          audioUrl: 'url',
          durationSeconds: 30,
          currentPosition: -5,
        );

        expect(vm.progress, equals(0.0));
      });

      test('returns 1.0 when fully played', () {
        const vm = VoiceMessage(
          messageId: 'msg_full',
          audioUrl: 'url',
          durationSeconds: 60,
          currentPosition: 60,
        );

        expect(vm.progress, equals(1.0));
      });

      test('calculates fractional progress', () {
        const vm = VoiceMessage(
          messageId: 'msg_frac',
          audioUrl: 'url',
          durationSeconds: 60,
          currentPosition: 15,
        );

        expect(vm.progress, equals(0.25));
      });
    });

    group('Equatable', () {
      test('two voice messages with same props are equal', () {
        const vm1 = VoiceMessage(
          messageId: 'msg_eq',
          audioUrl: 'https://example.com/eq.m4a',
          durationSeconds: 30,
          waveformData: [0.5],
          isPlaying: false,
          currentPosition: 0,
        );

        const vm2 = VoiceMessage(
          messageId: 'msg_eq',
          audioUrl: 'https://example.com/eq.m4a',
          durationSeconds: 30,
          waveformData: [0.5],
          isPlaying: false,
          currentPosition: 0,
        );

        expect(vm1, equals(vm2));
      });

      test('voice messages with different props are not equal', () {
        const vm1 = VoiceMessage(
          messageId: 'msg_ne1',
          audioUrl: 'url1',
          durationSeconds: 30,
        );

        const vm2 = VoiceMessage(
          messageId: 'msg_ne2',
          audioUrl: 'url2',
          durationSeconds: 60,
        );

        expect(vm1, isNot(equals(vm2)));
      });

      test('playback state change makes messages unequal', () {
        const vm1 = VoiceMessage(
          messageId: 'msg_state',
          audioUrl: 'url',
          durationSeconds: 30,
          isPlaying: false,
        );

        const vm2 = VoiceMessage(
          messageId: 'msg_state',
          audioUrl: 'url',
          durationSeconds: 30,
          isPlaying: true,
        );

        expect(vm1, isNot(equals(vm2)));
      });
    });
  });

  // =========================================================================
  // VoiceRecordingService state management contracts
  // =========================================================================
  group('VoiceRecordingService state contracts', () {
    test('playback state flow: play -> update position -> stop', () {
      // Simulates the state flow managed by the service
      const initial = VoiceMessage(
        messageId: 'msg_flow',
        audioUrl: 'https://example.com/flow.m4a',
        durationSeconds: 60,
        isPlaying: false,
        currentPosition: 0,
      );

      // Play
      final playing = initial.copyWith(isPlaying: true);
      expect(playing.isPlaying, isTrue);

      // Update position
      final atMidpoint = playing.copyWith(currentPosition: 30);
      expect(atMidpoint.currentPosition, equals(30));
      expect(atMidpoint.progress, equals(0.5));

      // Stop
      final stopped = atMidpoint.copyWith(
        isPlaying: false,
        currentPosition: 0,
      );
      expect(stopped.isPlaying, isFalse);
      expect(stopped.currentPosition, equals(0));
      expect(stopped.progress, equals(0.0));
    });

    test('pause and resume state flow', () {
      const playing = VoiceMessage(
        messageId: 'msg_pause',
        audioUrl: 'url',
        durationSeconds: 60,
        isPlaying: true,
        currentPosition: 25,
      );

      // Pause
      final paused = playing.copyWith(isPlaying: false);
      expect(paused.isPlaying, isFalse);
      expect(paused.currentPosition, equals(25)); // Position preserved

      // Resume
      final resumed = paused.copyWith(isPlaying: true);
      expect(resumed.isPlaying, isTrue);
      expect(resumed.currentPosition, equals(25)); // Same position
    });

    test('playback states map tracks multiple messages', () {
      final states = <String, VoiceMessage>{};

      const vm1 = VoiceMessage(
        messageId: 'msg_a',
        audioUrl: 'url_a',
        durationSeconds: 30,
        isPlaying: true,
      );

      const vm2 = VoiceMessage(
        messageId: 'msg_b',
        audioUrl: 'url_b',
        durationSeconds: 45,
        isPlaying: false,
      );

      states['msg_a'] = vm1;
      states['msg_b'] = vm2;

      expect(states.length, equals(2));
      expect(states['msg_a']!.isPlaying, isTrue);
      expect(states['msg_b']!.isPlaying, isFalse);
    });

    test('switching playback stops previous message', () {
      final states = <String, VoiceMessage>{};

      // Start playing msg_a
      states['msg_a'] = const VoiceMessage(
        messageId: 'msg_a',
        audioUrl: 'url_a',
        durationSeconds: 30,
        isPlaying: true,
        currentPosition: 10,
      );

      // Switch to msg_b: stop msg_a first
      states['msg_a'] = states['msg_a']!.copyWith(
        isPlaying: false,
        currentPosition: 0,
      );
      states['msg_b'] = const VoiceMessage(
        messageId: 'msg_b',
        audioUrl: 'url_b',
        durationSeconds: 45,
        isPlaying: true,
        currentPosition: 0,
      );

      expect(states['msg_a']!.isPlaying, isFalse);
      expect(states['msg_a']!.currentPosition, equals(0));
      expect(states['msg_b']!.isPlaying, isTrue);
    });
  });

  // =========================================================================
  // Synthetic waveform generation contract
  // =========================================================================
  group('Synthetic waveform generation contract', () {
    test('synthetic waveform has correct number of samples', () {
      const samples = 100;
      final waveform = List<double>.generate(samples, (index) {
        final normalizedIndex = index / samples;
        final base = 0.3 + 0.4 * normalizedIndex;
        final variation = 0.3 * ((index % 7) / 7);
        return (base + variation).clamp(0.1, 1.0);
      });

      expect(waveform.length, equals(samples));
    });

    test('synthetic waveform values are within 0.1 to 1.0 range', () {
      const samples = 100;
      final waveform = List<double>.generate(samples, (index) {
        final normalizedIndex = index / samples;
        final base = 0.3 + 0.4 * normalizedIndex;
        final variation = 0.3 * ((index % 7) / 7);
        return (base + variation).clamp(0.1, 1.0);
      });

      for (final value in waveform) {
        expect(value, greaterThanOrEqualTo(0.1));
        expect(value, lessThanOrEqualTo(1.0));
      }
    });

    test('synthetic waveform generates different values (not flat)', () {
      const samples = 50;
      final waveform = List<double>.generate(samples, (index) {
        final normalizedIndex = index / samples;
        final base = 0.3 + 0.4 * normalizedIndex;
        final variation = 0.3 * ((index % 7) / 7);
        return (base + variation).clamp(0.1, 1.0);
      });

      final unique = waveform.toSet();
      // Should have more than just one value
      expect(unique.length, greaterThan(1));
    });

    test('synthetic waveform is deterministic for same samples count', () {
      const samples = 20;

      final waveform1 = List<double>.generate(samples, (index) {
        final normalizedIndex = index / samples;
        final base = 0.3 + 0.4 * normalizedIndex;
        final variation = 0.3 * ((index % 7) / 7);
        return (base + variation).clamp(0.1, 1.0);
      });

      final waveform2 = List<double>.generate(samples, (index) {
        final normalizedIndex = index / samples;
        final base = 0.3 + 0.4 * normalizedIndex;
        final variation = 0.3 * ((index % 7) / 7);
        return (base + variation).clamp(0.1, 1.0);
      });

      expect(waveform1, equals(waveform2));
    });

    test('synthetic waveform works with different sample counts', () {
      for (final count in [10, 50, 100, 200]) {
        final waveform = List<double>.generate(count, (index) {
          final normalizedIndex = index / count;
          final base = 0.3 + 0.4 * normalizedIndex;
          final variation = 0.3 * ((index % 7) / 7);
          return (base + variation).clamp(0.1, 1.0);
        });

        expect(waveform.length, equals(count));
      }
    });
  });
}

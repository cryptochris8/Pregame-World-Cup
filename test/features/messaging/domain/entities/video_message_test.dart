import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/messaging/domain/entities/video_message.dart';

void main() {
  group('VideoMessage', () {
    group('Constructor', () {
      test('creates video message with required fields', () {
        const video = VideoMessage(
          messageId: 'vid_1',
          videoUrl: 'https://example.com/video.mp4',
          durationSeconds: 120,
          fileSizeBytes: 5000000,
        );

        expect(video.messageId, equals('vid_1'));
        expect(video.videoUrl, equals('https://example.com/video.mp4'));
        expect(video.durationSeconds, equals(120));
        expect(video.fileSizeBytes, equals(5000000));
        expect(video.thumbnailUrl, isNull);
        expect(video.width, isNull);
        expect(video.height, isNull);
        expect(video.isPlaying, isFalse);
        expect(video.currentPosition, isNull);
        expect(video.isLoaded, isFalse);
      });

      test('creates video message with all fields', () {
        const video = VideoMessage(
          messageId: 'vid_2',
          videoUrl: 'https://example.com/video2.mp4',
          thumbnailUrl: 'https://example.com/thumb.jpg',
          durationSeconds: 300,
          width: 1920,
          height: 1080,
          fileSizeBytes: 50000000,
          isPlaying: true,
          currentPosition: 60,
          isLoaded: true,
        );

        expect(video.thumbnailUrl, equals('https://example.com/thumb.jpg'));
        expect(video.width, equals(1920));
        expect(video.height, equals(1080));
        expect(video.isPlaying, isTrue);
        expect(video.currentPosition, equals(60));
        expect(video.isLoaded, isTrue);
      });
    });

    group('formattedDuration', () {
      test('formats seconds under a minute', () {
        const video = VideoMessage(
          messageId: 'vid_dur_1',
          videoUrl: 'url',
          durationSeconds: 30,
          fileSizeBytes: 100,
        );

        expect(video.formattedDuration, equals('00:30'));
      });

      test('formats exact minute', () {
        const video = VideoMessage(
          messageId: 'vid_dur_2',
          videoUrl: 'url',
          durationSeconds: 60,
          fileSizeBytes: 100,
        );

        expect(video.formattedDuration, equals('01:00'));
      });

      test('formats minutes and seconds', () {
        const video = VideoMessage(
          messageId: 'vid_dur_3',
          videoUrl: 'url',
          durationSeconds: 185, // 3:05
          fileSizeBytes: 100,
        );

        expect(video.formattedDuration, equals('03:05'));
      });

      test('formats zero duration', () {
        const video = VideoMessage(
          messageId: 'vid_dur_4',
          videoUrl: 'url',
          durationSeconds: 0,
          fileSizeBytes: 100,
        );

        expect(video.formattedDuration, equals('00:00'));
      });
    });

    group('formattedFileSize', () {
      test('formats kilobytes', () {
        const video = VideoMessage(
          messageId: 'vid_size_1',
          videoUrl: 'url',
          durationSeconds: 10,
          fileSizeBytes: 512000, // ~500 KB
        );

        expect(video.formattedFileSize, equals('500.0 KB'));
      });

      test('formats megabytes', () {
        const video = VideoMessage(
          messageId: 'vid_size_2',
          videoUrl: 'url',
          durationSeconds: 60,
          fileSizeBytes: 10485760, // 10 MB
        );

        expect(video.formattedFileSize, equals('10.0 MB'));
      });

      test('formats gigabytes', () {
        const video = VideoMessage(
          messageId: 'vid_size_3',
          videoUrl: 'url',
          durationSeconds: 300,
          fileSizeBytes: 2147483648, // 2 GB
        );

        expect(video.formattedFileSize, equals('2.0 GB'));
      });
    });

    group('progress', () {
      test('returns 0.0 when currentPosition is null', () {
        const video = VideoMessage(
          messageId: 'vid_prog_1',
          videoUrl: 'url',
          durationSeconds: 120,
          fileSizeBytes: 100,
        );

        expect(video.progress, equals(0.0));
      });

      test('returns 0.0 when duration is zero', () {
        const video = VideoMessage(
          messageId: 'vid_prog_2',
          videoUrl: 'url',
          durationSeconds: 0,
          fileSizeBytes: 100,
          currentPosition: 5,
        );

        expect(video.progress, equals(0.0));
      });

      test('returns correct progress ratio', () {
        const video = VideoMessage(
          messageId: 'vid_prog_3',
          videoUrl: 'url',
          durationSeconds: 200,
          fileSizeBytes: 100,
          currentPosition: 100,
        );

        expect(video.progress, equals(0.5));
      });

      test('clamps to 1.0 when position exceeds duration', () {
        const video = VideoMessage(
          messageId: 'vid_prog_4',
          videoUrl: 'url',
          durationSeconds: 60,
          fileSizeBytes: 100,
          currentPosition: 120,
        );

        expect(video.progress, equals(1.0));
      });
    });

    group('aspectRatio', () {
      test('returns 16/9 when dimensions are null', () {
        const video = VideoMessage(
          messageId: 'vid_ar_1',
          videoUrl: 'url',
          durationSeconds: 60,
          fileSizeBytes: 100,
        );

        expect(video.aspectRatio, equals(16 / 9));
      });

      test('returns 16/9 when width is zero', () {
        const video = VideoMessage(
          messageId: 'vid_ar_2',
          videoUrl: 'url',
          durationSeconds: 60,
          fileSizeBytes: 100,
          width: 0,
          height: 1080,
        );

        expect(video.aspectRatio, equals(16 / 9));
      });

      test('returns 16/9 when height is zero', () {
        const video = VideoMessage(
          messageId: 'vid_ar_3',
          videoUrl: 'url',
          durationSeconds: 60,
          fileSizeBytes: 100,
          width: 1920,
          height: 0,
        );

        expect(video.aspectRatio, equals(16 / 9));
      });

      test('calculates correct aspect ratio for 16:9', () {
        const video = VideoMessage(
          messageId: 'vid_ar_4',
          videoUrl: 'url',
          durationSeconds: 60,
          fileSizeBytes: 100,
          width: 1920,
          height: 1080,
        );

        expect(video.aspectRatio, closeTo(16 / 9, 0.01));
      });

      test('calculates correct aspect ratio for 4:3', () {
        const video = VideoMessage(
          messageId: 'vid_ar_5',
          videoUrl: 'url',
          durationSeconds: 60,
          fileSizeBytes: 100,
          width: 640,
          height: 480,
        );

        expect(video.aspectRatio, closeTo(4 / 3, 0.01));
      });

      test('calculates correct aspect ratio for portrait (9:16)', () {
        const video = VideoMessage(
          messageId: 'vid_ar_6',
          videoUrl: 'url',
          durationSeconds: 60,
          fileSizeBytes: 100,
          width: 1080,
          height: 1920,
        );

        expect(video.aspectRatio, closeTo(9 / 16, 0.01));
      });

      test('calculates aspect ratio for square video', () {
        const video = VideoMessage(
          messageId: 'vid_ar_7',
          videoUrl: 'url',
          durationSeconds: 60,
          fileSizeBytes: 100,
          width: 720,
          height: 720,
        );

        expect(video.aspectRatio, equals(1.0));
      });
    });

    group('resolution', () {
      test('returns "Unknown" when dimensions are null', () {
        const video = VideoMessage(
          messageId: 'vid_res_1',
          videoUrl: 'url',
          durationSeconds: 60,
          fileSizeBytes: 100,
        );

        expect(video.resolution, equals('Unknown'));
      });

      test('returns "Unknown" when only width is set', () {
        const video = VideoMessage(
          messageId: 'vid_res_2',
          videoUrl: 'url',
          durationSeconds: 60,
          fileSizeBytes: 100,
          width: 1920,
        );

        expect(video.resolution, equals('Unknown'));
      });

      test('returns formatted resolution', () {
        const video = VideoMessage(
          messageId: 'vid_res_3',
          videoUrl: 'url',
          durationSeconds: 60,
          fileSizeBytes: 100,
          width: 1920,
          height: 1080,
        );

        expect(video.resolution, equals('1920x1080'));
      });

      test('returns resolution for 4K video', () {
        const video = VideoMessage(
          messageId: 'vid_res_4',
          videoUrl: 'url',
          durationSeconds: 60,
          fileSizeBytes: 100,
          width: 3840,
          height: 2160,
        );

        expect(video.resolution, equals('3840x2160'));
      });
    });

    group('copyWith', () {
      test('copies with updated isPlaying', () {
        const original = VideoMessage(
          messageId: 'vid_copy_1',
          videoUrl: 'url',
          durationSeconds: 60,
          fileSizeBytes: 100,
        );

        final updated = original.copyWith(isPlaying: true);

        expect(updated.isPlaying, isTrue);
        expect(updated.messageId, equals('vid_copy_1'));
        expect(updated.videoUrl, equals('url'));
      });

      test('copies with multiple updated fields', () {
        const original = VideoMessage(
          messageId: 'vid_copy_2',
          videoUrl: 'url1',
          durationSeconds: 60,
          fileSizeBytes: 100,
        );

        final updated = original.copyWith(
          videoUrl: 'url2',
          thumbnailUrl: 'thumb_url',
          durationSeconds: 120,
          width: 1920,
          height: 1080,
          fileSizeBytes: 5000000,
          isPlaying: true,
          currentPosition: 30,
          isLoaded: true,
        );

        expect(updated.videoUrl, equals('url2'));
        expect(updated.thumbnailUrl, equals('thumb_url'));
        expect(updated.durationSeconds, equals(120));
        expect(updated.width, equals(1920));
        expect(updated.height, equals(1080));
        expect(updated.fileSizeBytes, equals(5000000));
        expect(updated.isPlaying, isTrue);
        expect(updated.currentPosition, equals(30));
        expect(updated.isLoaded, isTrue);
      });

      test('preserves original values when not specified', () {
        const original = VideoMessage(
          messageId: 'vid_copy_3',
          videoUrl: 'url',
          thumbnailUrl: 'thumb',
          durationSeconds: 60,
          width: 1920,
          height: 1080,
          fileSizeBytes: 5000000,
          isPlaying: true,
          currentPosition: 15,
          isLoaded: true,
        );

        final copy = original.copyWith();

        expect(copy.messageId, equals(original.messageId));
        expect(copy.videoUrl, equals(original.videoUrl));
        expect(copy.thumbnailUrl, equals(original.thumbnailUrl));
        expect(copy.durationSeconds, equals(original.durationSeconds));
        expect(copy.width, equals(original.width));
        expect(copy.height, equals(original.height));
        expect(copy.fileSizeBytes, equals(original.fileSizeBytes));
        expect(copy.isPlaying, equals(original.isPlaying));
        expect(copy.currentPosition, equals(original.currentPosition));
        expect(copy.isLoaded, equals(original.isLoaded));
      });
    });

    group('JSON serialization', () {
      test('toJson serializes correctly', () {
        const video = VideoMessage(
          messageId: 'vid_json_1',
          videoUrl: 'https://example.com/video.mp4',
          thumbnailUrl: 'https://example.com/thumb.jpg',
          durationSeconds: 180,
          width: 1920,
          height: 1080,
          fileSizeBytes: 25000000,
          isPlaying: false,
          currentPosition: 0,
          isLoaded: true,
        );

        final json = video.toJson();

        expect(json['messageId'], equals('vid_json_1'));
        expect(json['videoUrl'], equals('https://example.com/video.mp4'));
        expect(json['thumbnailUrl'], equals('https://example.com/thumb.jpg'));
        expect(json['durationSeconds'], equals(180));
        expect(json['width'], equals(1920));
        expect(json['height'], equals(1080));
        expect(json['fileSizeBytes'], equals(25000000));
        expect(json['isPlaying'], isFalse);
        expect(json['currentPosition'], equals(0));
        expect(json['isLoaded'], isTrue);
      });

      test('fromJson deserializes correctly', () {
        final json = <String, dynamic>{
          'messageId': 'vid_json_2',
          'videoUrl': 'https://example.com/video2.mp4',
          'thumbnailUrl': 'https://example.com/thumb2.jpg',
          'durationSeconds': 90,
          'width': 1280,
          'height': 720,
          'fileSizeBytes': 15000000,
          'isPlaying': true,
          'currentPosition': 45,
          'isLoaded': true,
        };

        final video = VideoMessage.fromJson(json);

        expect(video.messageId, equals('vid_json_2'));
        expect(video.videoUrl, equals('https://example.com/video2.mp4'));
        expect(video.thumbnailUrl, equals('https://example.com/thumb2.jpg'));
        expect(video.durationSeconds, equals(90));
        expect(video.width, equals(1280));
        expect(video.height, equals(720));
        expect(video.fileSizeBytes, equals(15000000));
        expect(video.isPlaying, isTrue);
        expect(video.currentPosition, equals(45));
        expect(video.isLoaded, isTrue);
      });

      test('fromJson handles missing optional fields', () {
        final json = <String, dynamic>{
          'messageId': 'vid_json_3',
          'videoUrl': 'url',
          'durationSeconds': 30,
          'fileSizeBytes': 1000,
        };

        final video = VideoMessage.fromJson(json);

        expect(video.thumbnailUrl, isNull);
        expect(video.width, isNull);
        expect(video.height, isNull);
        expect(video.isPlaying, isFalse);
        expect(video.currentPosition, isNull);
        expect(video.isLoaded, isFalse);
      });

      test('roundtrip serialization preserves data', () {
        const original = VideoMessage(
          messageId: 'vid_roundtrip',
          videoUrl: 'https://example.com/video.mp4',
          thumbnailUrl: 'https://example.com/thumb.jpg',
          durationSeconds: 240,
          width: 3840,
          height: 2160,
          fileSizeBytes: 100000000,
          isPlaying: false,
          currentPosition: 100,
          isLoaded: true,
        );

        final json = original.toJson();
        final restored = VideoMessage.fromJson(json);

        expect(restored.messageId, equals(original.messageId));
        expect(restored.videoUrl, equals(original.videoUrl));
        expect(restored.thumbnailUrl, equals(original.thumbnailUrl));
        expect(restored.durationSeconds, equals(original.durationSeconds));
        expect(restored.width, equals(original.width));
        expect(restored.height, equals(original.height));
        expect(restored.fileSizeBytes, equals(original.fileSizeBytes));
        expect(restored.isPlaying, equals(original.isPlaying));
        expect(restored.currentPosition, equals(original.currentPosition));
        expect(restored.isLoaded, equals(original.isLoaded));
      });
    });

    group('Equatable', () {
      test('two video messages with same props are equal', () {
        const vid1 = VideoMessage(
          messageId: 'vid_eq_1',
          videoUrl: 'url',
          durationSeconds: 60,
          fileSizeBytes: 100,
          width: 1920,
          height: 1080,
        );

        const vid2 = VideoMessage(
          messageId: 'vid_eq_1',
          videoUrl: 'url',
          durationSeconds: 60,
          fileSizeBytes: 100,
          width: 1920,
          height: 1080,
        );

        expect(vid1, equals(vid2));
      });

      test('two video messages with different props are not equal', () {
        const vid1 = VideoMessage(
          messageId: 'vid_eq_1',
          videoUrl: 'url',
          durationSeconds: 60,
          fileSizeBytes: 100,
        );

        const vid2 = VideoMessage(
          messageId: 'vid_eq_2',
          videoUrl: 'url',
          durationSeconds: 60,
          fileSizeBytes: 100,
        );

        expect(vid1, isNot(equals(vid2)));
      });

      test('same video with different loading states are not equal', () {
        const vid1 = VideoMessage(
          messageId: 'vid_eq_load',
          videoUrl: 'url',
          durationSeconds: 60,
          fileSizeBytes: 100,
          isLoaded: false,
        );

        const vid2 = VideoMessage(
          messageId: 'vid_eq_load',
          videoUrl: 'url',
          durationSeconds: 60,
          fileSizeBytes: 100,
          isLoaded: true,
        );

        expect(vid1, isNot(equals(vid2)));
      });
    });
  });
}

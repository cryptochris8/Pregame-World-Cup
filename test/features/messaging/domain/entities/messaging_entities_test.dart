import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/messaging/domain/entities/typing_indicator.dart';
import 'package:pregame_world_cup/features/messaging/domain/entities/file_attachment.dart';

void main() {
  group('TypingIndicator', () {
    group('Constructor', () {
      test('creates indicator with required fields', () {
        final indicator = TypingIndicator(
          chatId: 'chat_1',
          userId: 'user_1',
          userName: 'John Doe',
          timestamp: DateTime(2024, 10, 15, 12, 0, 0),
          isTyping: true,
        );

        expect(indicator.chatId, equals('chat_1'));
        expect(indicator.userId, equals('user_1'));
        expect(indicator.userName, equals('John Doe'));
        expect(indicator.isTyping, isTrue);
      });

      test('creates indicator when not typing', () {
        final indicator = TypingIndicator(
          chatId: 'chat_1',
          userId: 'user_1',
          userName: 'John Doe',
          timestamp: DateTime(2024, 10, 15, 12, 0, 0),
          isTyping: false,
        );

        expect(indicator.isTyping, isFalse);
      });
    });

    group('isExpired', () {
      test('returns false for recent indicators', () {
        final now = DateTime.now();
        final indicator = TypingIndicator(
          chatId: 'chat_1',
          userId: 'user_1',
          userName: 'John Doe',
          timestamp: now,
          isTyping: true,
        );

        expect(indicator.isExpired, isFalse);
      });

      test('returns true for old indicators', () {
        final oldTime = DateTime.now().subtract(const Duration(seconds: 5));
        final indicator = TypingIndicator(
          chatId: 'chat_1',
          userId: 'user_1',
          userName: 'John Doe',
          timestamp: oldTime,
          isTyping: true,
        );

        expect(indicator.isExpired, isTrue);
      });
    });

    group('copyWith', () {
      test('copies indicator with updated fields', () {
        final original = TypingIndicator(
          chatId: 'chat_1',
          userId: 'user_1',
          userName: 'John Doe',
          timestamp: DateTime(2024, 10, 15, 12, 0, 0),
          isTyping: true,
        );

        final updated = original.copyWith(
          isTyping: false,
          userName: 'Jane Doe',
        );

        expect(updated.chatId, equals('chat_1'));
        expect(updated.userId, equals('user_1'));
        expect(updated.userName, equals('Jane Doe'));
        expect(updated.isTyping, isFalse);
      });

      test('copies indicator preserving unchanged fields', () {
        final original = TypingIndicator(
          chatId: 'chat_1',
          userId: 'user_1',
          userName: 'John Doe',
          timestamp: DateTime(2024, 10, 15, 12, 0, 0),
          isTyping: true,
        );

        final updated = original.copyWith(isTyping: false);

        expect(updated.chatId, equals(original.chatId));
        expect(updated.userId, equals(original.userId));
        expect(updated.userName, equals(original.userName));
        expect(updated.timestamp, equals(original.timestamp));
      });
    });

    group('JSON serialization', () {
      test('toJson serializes correctly', () {
        final timestamp = DateTime(2024, 10, 15, 12, 0, 0);
        final indicator = TypingIndicator(
          chatId: 'chat_1',
          userId: 'user_1',
          userName: 'Test User',
          timestamp: timestamp,
          isTyping: true,
        );

        final json = indicator.toJson();

        expect(json['chatId'], equals('chat_1'));
        expect(json['userId'], equals('user_1'));
        expect(json['userName'], equals('Test User'));
        expect(json['timestamp'], equals('2024-10-15T12:00:00.000'));
        expect(json['isTyping'], isTrue);
      });

      test('fromJson deserializes correctly', () {
        final json = {
          'chatId': 'chat_1',
          'userId': 'user_1',
          'userName': 'Test User',
          'timestamp': '2024-10-15T12:00:00.000',
          'isTyping': true,
        };

        final indicator = TypingIndicator.fromJson(json);

        expect(indicator.chatId, equals('chat_1'));
        expect(indicator.userId, equals('user_1'));
        expect(indicator.userName, equals('Test User'));
        expect(indicator.timestamp, equals(DateTime(2024, 10, 15, 12, 0, 0)));
        expect(indicator.isTyping, isTrue);
      });

      test('roundtrip serialization preserves data', () {
        final original = TypingIndicator(
          chatId: 'chat_1',
          userId: 'user_1',
          userName: 'Test User',
          timestamp: DateTime(2024, 10, 15, 12, 0, 0),
          isTyping: true,
        );

        final json = original.toJson();
        final restored = TypingIndicator.fromJson(json);

        expect(restored.chatId, equals(original.chatId));
        expect(restored.userId, equals(original.userId));
        expect(restored.userName, equals(original.userName));
        expect(restored.timestamp, equals(original.timestamp));
        expect(restored.isTyping, equals(original.isTyping));
      });
    });

    group('Equatable', () {
      test('two indicators with same props are equal', () {
        final timestamp = DateTime(2024, 10, 15, 12, 0, 0);
        final ind1 = TypingIndicator(
          chatId: 'chat_1',
          userId: 'user_1',
          userName: 'John',
          timestamp: timestamp,
          isTyping: true,
        );

        final ind2 = TypingIndicator(
          chatId: 'chat_1',
          userId: 'user_1',
          userName: 'John',
          timestamp: timestamp,
          isTyping: true,
        );

        expect(ind1, equals(ind2));
      });

      test('two indicators with different props are not equal', () {
        final timestamp = DateTime.now();
        final ind1 = TypingIndicator(
          chatId: 'chat_1',
          userId: 'user_1',
          userName: 'John',
          timestamp: timestamp,
          isTyping: true,
        );

        final ind2 = TypingIndicator(
          chatId: 'chat_1',
          userId: 'user_2',
          userName: 'Jane',
          timestamp: timestamp,
          isTyping: true,
        );

        expect(ind1, isNot(equals(ind2)));
      });
    });
  });

  group('FileAttachment', () {
    group('Constructor', () {
      test('creates attachment with required fields', () {
        final now = DateTime.now();
        final attachment = FileAttachment(
          fileName: 'document.pdf',
          fileUrl: 'https://example.com/files/document.pdf',
          fileType: 'pdf',
          fileSizeBytes: 1024000,
          uploadedAt: now,
        );

        expect(attachment.fileName, equals('document.pdf'));
        expect(attachment.fileUrl, equals('https://example.com/files/document.pdf'));
        expect(attachment.fileType, equals('pdf'));
        expect(attachment.fileSizeBytes, equals(1024000));
        expect(attachment.uploadedAt, equals(now));
        expect(attachment.mimeType, isNull);
        expect(attachment.thumbnailUrl, isNull);
      });

      test('creates attachment with optional fields', () {
        final now = DateTime.now();
        final attachment = FileAttachment(
          fileName: 'image.png',
          fileUrl: 'https://example.com/files/image.png',
          fileType: 'image',
          fileSizeBytes: 512000,
          mimeType: 'image/png',
          thumbnailUrl: 'https://example.com/thumbs/image_thumb.png',
          uploadedAt: now,
        );

        expect(attachment.mimeType, equals('image/png'));
        expect(attachment.thumbnailUrl, contains('thumb'));
      });
    });

    group('formattedFileSize', () {
      test('formats bytes correctly', () {
        final attachment = FileAttachment(
          fileName: 'tiny.txt',
          fileUrl: 'url',
          fileType: 'txt',
          fileSizeBytes: 512,
          uploadedAt: DateTime.now(),
        );

        expect(attachment.formattedFileSize, equals('512 B'));
      });

      test('formats kilobytes correctly', () {
        final attachment = FileAttachment(
          fileName: 'small.txt',
          fileUrl: 'url',
          fileType: 'txt',
          fileSizeBytes: 2048, // 2 KB
          uploadedAt: DateTime.now(),
        );

        expect(attachment.formattedFileSize, equals('2.0 KB'));
      });

      test('formats megabytes correctly', () {
        final attachment = FileAttachment(
          fileName: 'medium.pdf',
          fileUrl: 'url',
          fileType: 'pdf',
          fileSizeBytes: 5242880, // 5 MB
          uploadedAt: DateTime.now(),
        );

        expect(attachment.formattedFileSize, equals('5.0 MB'));
      });

      test('formats gigabytes correctly', () {
        final attachment = FileAttachment(
          fileName: 'large.zip',
          fileUrl: 'url',
          fileType: 'zip',
          fileSizeBytes: 2147483648, // 2 GB
          uploadedAt: DateTime.now(),
        );

        expect(attachment.formattedFileSize, equals('2.0 GB'));
      });
    });

    group('fileExtension', () {
      test('extracts extension from filename', () {
        final attachment = FileAttachment(
          fileName: 'document.pdf',
          fileUrl: 'url',
          fileType: 'pdf',
          fileSizeBytes: 1024,
          uploadedAt: DateTime.now(),
        );

        expect(attachment.fileExtension, equals('PDF'));
      });

      test('returns empty string for files without extension', () {
        final attachment = FileAttachment(
          fileName: 'README',
          fileUrl: 'url',
          fileType: 'text',
          fileSizeBytes: 256,
          uploadedAt: DateTime.now(),
        );

        expect(attachment.fileExtension, isEmpty);
      });

      test('handles multiple dots in filename', () {
        final attachment = FileAttachment(
          fileName: 'archive.tar.gz',
          fileUrl: 'url',
          fileType: 'archive',
          fileSizeBytes: 1024,
          uploadedAt: DateTime.now(),
        );

        expect(attachment.fileExtension, equals('GZ'));
      });
    });

    group('File type checks', () {
      test('isImage returns true for image files', () {
        for (final ext in ['jpg', 'jpeg', 'png', 'gif', 'webp']) {
          final attachment = FileAttachment(
            fileName: 'image.$ext',
            fileUrl: 'url',
            fileType: 'image',
            fileSizeBytes: 1024,
            uploadedAt: DateTime.now(),
          );

          expect(attachment.isImage, isTrue, reason: '$ext should be recognized as image');
        }
      });

      test('isImage returns false for non-image files', () {
        final attachment = FileAttachment(
          fileName: 'document.pdf',
          fileUrl: 'url',
          fileType: 'pdf',
          fileSizeBytes: 1024,
          uploadedAt: DateTime.now(),
        );

        expect(attachment.isImage, isFalse);
      });

      test('isVideo returns true for video files', () {
        for (final ext in ['mp4', 'mov', 'avi', 'mkv', 'webm']) {
          final attachment = FileAttachment(
            fileName: 'video.$ext',
            fileUrl: 'url',
            fileType: 'video',
            fileSizeBytes: 1024,
            uploadedAt: DateTime.now(),
          );

          expect(attachment.isVideo, isTrue, reason: '$ext should be recognized as video');
        }
      });

      test('isAudio returns true for audio files', () {
        for (final ext in ['mp3', 'wav', 'aac', 'm4a', 'ogg']) {
          final attachment = FileAttachment(
            fileName: 'audio.$ext',
            fileUrl: 'url',
            fileType: 'audio',
            fileSizeBytes: 1024,
            uploadedAt: DateTime.now(),
          );

          expect(attachment.isAudio, isTrue, reason: '$ext should be recognized as audio');
        }
      });

      test('isDocument returns true for document files', () {
        for (final ext in ['pdf', 'doc', 'docx', 'txt', 'rtf']) {
          final attachment = FileAttachment(
            fileName: 'document.$ext',
            fileUrl: 'url',
            fileType: 'document',
            fileSizeBytes: 1024,
            uploadedAt: DateTime.now(),
          );

          expect(attachment.isDocument, isTrue, reason: '$ext should be recognized as document');
        }
      });
    });

    group('JSON serialization', () {
      test('toJson serializes correctly', () {
        final attachment = FileAttachment(
          fileName: 'test.pdf',
          fileUrl: 'https://example.com/test.pdf',
          fileType: 'pdf',
          fileSizeBytes: 1024000,
          mimeType: 'application/pdf',
          thumbnailUrl: 'https://example.com/test_thumb.jpg',
          uploadedAt: DateTime(2024, 10, 15, 12, 0, 0),
        );

        final json = attachment.toJson();

        expect(json['fileName'], equals('test.pdf'));
        expect(json['fileUrl'], equals('https://example.com/test.pdf'));
        expect(json['fileType'], equals('pdf'));
        expect(json['fileSizeBytes'], equals(1024000));
        expect(json['mimeType'], equals('application/pdf'));
        expect(json['thumbnailUrl'], equals('https://example.com/test_thumb.jpg'));
        expect(json['uploadedAt'], equals('2024-10-15T12:00:00.000'));
      });

      test('fromJson deserializes correctly', () {
        final json = {
          'fileName': 'test.pdf',
          'fileUrl': 'https://example.com/test.pdf',
          'fileType': 'pdf',
          'fileSizeBytes': 2048000,
          'mimeType': 'application/pdf',
          'thumbnailUrl': null,
          'uploadedAt': '2024-10-15T12:00:00.000',
        };

        final attachment = FileAttachment.fromJson(json);

        expect(attachment.fileName, equals('test.pdf'));
        expect(attachment.fileUrl, equals('https://example.com/test.pdf'));
        expect(attachment.fileSizeBytes, equals(2048000));
        expect(attachment.mimeType, equals('application/pdf'));
        expect(attachment.thumbnailUrl, isNull);
      });

      test('roundtrip serialization preserves data', () {
        final original = FileAttachment(
          fileName: 'photo.jpg',
          fileUrl: 'https://example.com/photo.jpg',
          fileType: 'image',
          fileSizeBytes: 512000,
          mimeType: 'image/jpeg',
          thumbnailUrl: 'https://example.com/photo_thumb.jpg',
          uploadedAt: DateTime(2024, 10, 15, 12, 0, 0),
        );

        final json = original.toJson();
        final restored = FileAttachment.fromJson(json);

        expect(restored.fileName, equals(original.fileName));
        expect(restored.fileUrl, equals(original.fileUrl));
        expect(restored.fileSizeBytes, equals(original.fileSizeBytes));
        expect(restored.mimeType, equals(original.mimeType));
        expect(restored.thumbnailUrl, equals(original.thumbnailUrl));
      });
    });

    group('Equatable', () {
      test('two attachments with same props are equal', () {
        final uploadedAt = DateTime(2024, 10, 15, 12, 0, 0);
        final att1 = FileAttachment(
          fileName: 'file.pdf',
          fileUrl: 'url',
          fileType: 'pdf',
          fileSizeBytes: 1024,
          uploadedAt: uploadedAt,
        );

        final att2 = FileAttachment(
          fileName: 'file.pdf',
          fileUrl: 'url',
          fileType: 'pdf',
          fileSizeBytes: 1024,
          uploadedAt: uploadedAt,
        );

        expect(att1, equals(att2));
      });

      test('two attachments with different props are not equal', () {
        final now = DateTime.now();
        final att1 = FileAttachment(
          fileName: 'file1.pdf',
          fileUrl: 'url1',
          fileType: 'pdf',
          fileSizeBytes: 1024,
          uploadedAt: now,
        );

        final att2 = FileAttachment(
          fileName: 'file2.pdf',
          fileUrl: 'url2',
          fileType: 'pdf',
          fileSizeBytes: 2048,
          uploadedAt: now,
        );

        expect(att1, isNot(equals(att2)));
      });
    });
  });
}

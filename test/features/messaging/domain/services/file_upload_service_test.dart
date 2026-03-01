import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/messaging/domain/services/file_upload_service.dart';

/// FileUploadService depends on FirebaseStorage.instance, ImagePicker, and
/// FilePicker -- all platform-dependent singletons that cannot be easily
/// injected. We therefore test:
///
/// 1. Static constants (file type lists, size limits)
/// 2. Static/pure utility methods (getSupportedFileTypes, isFileTypeSupported,
///    formatFileSize)
/// 3. Private helper logic exercised through the public static methods
///
/// The async methods (pickAndUploadImage, pickAndUploadVideo, etc.) depend
/// on native platform channels and would require integration tests or
/// platform mocking beyond the scope of unit tests.
void main() {
  group('FileUploadService', () {
    // =========================================================================
    // Static constants
    // =========================================================================
    group('Supported file type constants', () {
      test('supportedImageTypes contains expected formats', () {
        expect(FileUploadService.supportedImageTypes, contains('jpg'));
        expect(FileUploadService.supportedImageTypes, contains('jpeg'));
        expect(FileUploadService.supportedImageTypes, contains('png'));
        expect(FileUploadService.supportedImageTypes, contains('gif'));
        expect(FileUploadService.supportedImageTypes, contains('webp'));
        expect(FileUploadService.supportedImageTypes.length, equals(5));
      });

      test('supportedVideoTypes contains expected formats', () {
        expect(FileUploadService.supportedVideoTypes, contains('mp4'));
        expect(FileUploadService.supportedVideoTypes, contains('mov'));
        expect(FileUploadService.supportedVideoTypes, contains('avi'));
        expect(FileUploadService.supportedVideoTypes, contains('mkv'));
        expect(FileUploadService.supportedVideoTypes, contains('webm'));
        expect(FileUploadService.supportedVideoTypes.length, equals(5));
      });

      test('supportedAudioTypes contains expected formats', () {
        expect(FileUploadService.supportedAudioTypes, contains('mp3'));
        expect(FileUploadService.supportedAudioTypes, contains('wav'));
        expect(FileUploadService.supportedAudioTypes, contains('aac'));
        expect(FileUploadService.supportedAudioTypes, contains('m4a'));
        expect(FileUploadService.supportedAudioTypes, contains('ogg'));
        expect(FileUploadService.supportedAudioTypes.length, equals(5));
      });

      test('supportedDocumentTypes contains expected formats', () {
        expect(FileUploadService.supportedDocumentTypes, contains('pdf'));
        expect(FileUploadService.supportedDocumentTypes, contains('doc'));
        expect(FileUploadService.supportedDocumentTypes, contains('docx'));
        expect(FileUploadService.supportedDocumentTypes, contains('txt'));
        expect(FileUploadService.supportedDocumentTypes, contains('rtf'));
        expect(FileUploadService.supportedDocumentTypes.length, equals(5));
      });
    });

    // =========================================================================
    // File size limits
    // =========================================================================
    group('File size limit constants', () {
      test('maxImageSize is 10 MB', () {
        expect(FileUploadService.maxImageSize, equals(10 * 1024 * 1024));
      });

      test('maxVideoSize is 100 MB', () {
        expect(FileUploadService.maxVideoSize, equals(100 * 1024 * 1024));
      });

      test('maxAudioSize is 50 MB', () {
        expect(FileUploadService.maxAudioSize, equals(50 * 1024 * 1024));
      });

      test('maxDocumentSize is 25 MB', () {
        expect(FileUploadService.maxDocumentSize, equals(25 * 1024 * 1024));
      });
    });

    // =========================================================================
    // getSupportedFileTypes
    // =========================================================================
    group('getSupportedFileTypes', () {
      test('returns all supported types combined', () {
        final allTypes = FileUploadService.getSupportedFileTypes();

        expect(allTypes, isNotEmpty);

        // Should include all from each category
        for (final ext in FileUploadService.supportedImageTypes) {
          expect(allTypes, contains(ext));
        }
        for (final ext in FileUploadService.supportedVideoTypes) {
          expect(allTypes, contains(ext));
        }
        for (final ext in FileUploadService.supportedAudioTypes) {
          expect(allTypes, contains(ext));
        }
        for (final ext in FileUploadService.supportedDocumentTypes) {
          expect(allTypes, contains(ext));
        }
      });

      test('returns correct total count', () {
        final expected = FileUploadService.supportedImageTypes.length +
            FileUploadService.supportedVideoTypes.length +
            FileUploadService.supportedAudioTypes.length +
            FileUploadService.supportedDocumentTypes.length;

        expect(
          FileUploadService.getSupportedFileTypes().length,
          equals(expected),
        );
      });
    });

    // =========================================================================
    // isFileTypeSupported
    // =========================================================================
    group('isFileTypeSupported', () {
      test('returns true for supported image files', () {
        expect(FileUploadService.isFileTypeSupported('photo.jpg'), isTrue);
        expect(FileUploadService.isFileTypeSupported('photo.jpeg'), isTrue);
        expect(FileUploadService.isFileTypeSupported('image.png'), isTrue);
        expect(FileUploadService.isFileTypeSupported('animation.gif'), isTrue);
        expect(FileUploadService.isFileTypeSupported('modern.webp'), isTrue);
      });

      test('returns true for supported video files', () {
        expect(FileUploadService.isFileTypeSupported('video.mp4'), isTrue);
        expect(FileUploadService.isFileTypeSupported('clip.mov'), isTrue);
        expect(FileUploadService.isFileTypeSupported('movie.avi'), isTrue);
        expect(FileUploadService.isFileTypeSupported('film.mkv'), isTrue);
        expect(FileUploadService.isFileTypeSupported('stream.webm'), isTrue);
      });

      test('returns true for supported audio files', () {
        expect(FileUploadService.isFileTypeSupported('song.mp3'), isTrue);
        expect(FileUploadService.isFileTypeSupported('sound.wav'), isTrue);
        expect(FileUploadService.isFileTypeSupported('audio.aac'), isTrue);
        expect(FileUploadService.isFileTypeSupported('voice.m4a'), isTrue);
        expect(FileUploadService.isFileTypeSupported('track.ogg'), isTrue);
      });

      test('returns true for supported document files', () {
        expect(FileUploadService.isFileTypeSupported('report.pdf'), isTrue);
        expect(FileUploadService.isFileTypeSupported('letter.doc'), isTrue);
        expect(FileUploadService.isFileTypeSupported('essay.docx'), isTrue);
        expect(FileUploadService.isFileTypeSupported('notes.txt'), isTrue);
        expect(FileUploadService.isFileTypeSupported('formatted.rtf'), isTrue);
      });

      test('returns false for unsupported file types', () {
        expect(FileUploadService.isFileTypeSupported('file.exe'), isFalse);
        expect(FileUploadService.isFileTypeSupported('archive.zip'), isFalse);
        expect(FileUploadService.isFileTypeSupported('data.csv'), isFalse);
        expect(FileUploadService.isFileTypeSupported('code.dart'), isFalse);
        expect(FileUploadService.isFileTypeSupported('style.css'), isFalse);
      });

      test('is case-insensitive for extension detection', () {
        expect(FileUploadService.isFileTypeSupported('PHOTO.JPG'), isTrue);
        expect(FileUploadService.isFileTypeSupported('Photo.Png'), isTrue);
        expect(FileUploadService.isFileTypeSupported('VIDEO.MP4'), isTrue);
      });

      test('handles files with multiple dots', () {
        expect(
          FileUploadService.isFileTypeSupported('my.vacation.photo.jpg'),
          isTrue,
        );
        expect(
          FileUploadService.isFileTypeSupported('report.v2.pdf'),
          isTrue,
        );
      });

      test('handles files with no extension', () {
        // A file with no extension will have the full filename as "extension"
        // which won't match any supported type
        expect(FileUploadService.isFileTypeSupported('noextension'), isFalse);
      });
    });

    // =========================================================================
    // formatFileSize
    // =========================================================================
    group('formatFileSize', () {
      test('formats bytes correctly', () {
        expect(FileUploadService.formatFileSize(0), equals('0 B'));
        expect(FileUploadService.formatFileSize(500), equals('500 B'));
        expect(FileUploadService.formatFileSize(1023), equals('1023 B'));
      });

      test('formats kilobytes correctly', () {
        expect(FileUploadService.formatFileSize(1024), equals('1.0 KB'));
        expect(FileUploadService.formatFileSize(1536), equals('1.5 KB'));
        expect(FileUploadService.formatFileSize(10240), equals('10.0 KB'));
        expect(FileUploadService.formatFileSize(512 * 1024), equals('512.0 KB'));
      });

      test('formats megabytes correctly', () {
        expect(FileUploadService.formatFileSize(1024 * 1024), equals('1.0 MB'));
        expect(
          FileUploadService.formatFileSize(5 * 1024 * 1024),
          equals('5.0 MB'),
        );
        expect(
          FileUploadService.formatFileSize(10 * 1024 * 1024),
          equals('10.0 MB'),
        );
        // 1.5 MB
        expect(
          FileUploadService.formatFileSize((1.5 * 1024 * 1024).toInt()),
          equals('1.5 MB'),
        );
      });

      test('formats gigabytes correctly', () {
        expect(
          FileUploadService.formatFileSize(1024 * 1024 * 1024),
          equals('1.0 GB'),
        );
        expect(
          FileUploadService.formatFileSize(2 * 1024 * 1024 * 1024),
          equals('2.0 GB'),
        );
      });

      test('formats size limits correctly', () {
        expect(
          FileUploadService.formatFileSize(FileUploadService.maxImageSize),
          equals('10.0 MB'),
        );
        expect(
          FileUploadService.formatFileSize(FileUploadService.maxVideoSize),
          equals('100.0 MB'),
        );
        expect(
          FileUploadService.formatFileSize(FileUploadService.maxAudioSize),
          equals('50.0 MB'),
        );
        expect(
          FileUploadService.formatFileSize(FileUploadService.maxDocumentSize),
          equals('25.0 MB'),
        );
      });
    });

    // =========================================================================
    // File type categories (tested via isFileTypeSupported patterns)
    // =========================================================================
    group('File type category inference', () {
      // We can verify that the internal _getFileTypeCategory works correctly
      // by checking that the static lists are organized into correct categories
      test('image types are distinct from other categories', () {
        for (final ext in FileUploadService.supportedImageTypes) {
          expect(FileUploadService.supportedVideoTypes, isNot(contains(ext)));
          expect(FileUploadService.supportedAudioTypes, isNot(contains(ext)));
          expect(FileUploadService.supportedDocumentTypes, isNot(contains(ext)));
        }
      });

      test('video types are distinct from other categories', () {
        for (final ext in FileUploadService.supportedVideoTypes) {
          expect(FileUploadService.supportedImageTypes, isNot(contains(ext)));
          expect(FileUploadService.supportedAudioTypes, isNot(contains(ext)));
          expect(FileUploadService.supportedDocumentTypes, isNot(contains(ext)));
        }
      });

      test('audio types are distinct from other categories', () {
        for (final ext in FileUploadService.supportedAudioTypes) {
          expect(FileUploadService.supportedImageTypes, isNot(contains(ext)));
          expect(FileUploadService.supportedVideoTypes, isNot(contains(ext)));
          expect(FileUploadService.supportedDocumentTypes, isNot(contains(ext)));
        }
      });

      test('document types are distinct from other categories', () {
        for (final ext in FileUploadService.supportedDocumentTypes) {
          expect(FileUploadService.supportedImageTypes, isNot(contains(ext)));
          expect(FileUploadService.supportedVideoTypes, isNot(contains(ext)));
          expect(FileUploadService.supportedAudioTypes, isNot(contains(ext)));
        }
      });

      test('no duplicate extensions across categories', () {
        final all = [
          ...FileUploadService.supportedImageTypes,
          ...FileUploadService.supportedVideoTypes,
          ...FileUploadService.supportedAudioTypes,
          ...FileUploadService.supportedDocumentTypes,
        ];
        final unique = all.toSet();

        expect(all.length, equals(unique.length),
            reason: 'No duplicate extensions should exist across categories');
      });
    });
  });
}

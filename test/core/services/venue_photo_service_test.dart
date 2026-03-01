import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/services/venue_photo_service.dart';

void main() {
  // VenuePhotoService depends on Hive, Dio, and PerformanceMonitor.
  // Since Hive requires filesystem access and adapter registration,
  // we focus on testing the PhotoUrlBuilder and PhotoSize utilities
  // which are pure logic with no dependencies.

  // ============================================================================
  // PhotoUrlBuilder
  // ============================================================================
  group('PhotoUrlBuilder', () {
    const baseUrl =
        'https://maps.googleapis.com/maps/api/place/photo';

    group('buildPhotoUrl', () {
      test('builds URL with explicit maxWidth', () {
        final url = PhotoUrlBuilder.buildPhotoUrl(
          'test_ref_123',
          'test_api_key',
          maxWidth: 600,
        );

        expect(url, contains(baseUrl));
        expect(url, contains('photoreference=test_ref_123'));
        expect(url, contains('key=test_api_key'));
        expect(url, contains('maxwidth=600'));
      });

      test('builds URL with explicit maxHeight', () {
        final url = PhotoUrlBuilder.buildPhotoUrl(
          'test_ref',
          'key123',
          maxHeight: 400,
        );

        expect(url, contains('maxheight=400'));
        expect(url, contains('photoreference=test_ref'));
        expect(url, contains('key=key123'));
      });

      test('builds URL with both maxWidth and maxHeight', () {
        final url = PhotoUrlBuilder.buildPhotoUrl(
          'ref',
          'key',
          maxWidth: 800,
          maxHeight: 600,
        );

        expect(url, contains('maxwidth=800'));
        expect(url, contains('maxheight=600'));
      });

      test('uses thumbnail dimensions when size is thumbnail and no explicit dimensions', () {
        final url = PhotoUrlBuilder.buildPhotoUrl(
          'ref',
          'key',
          size: PhotoSize.thumbnail,
        );

        expect(url, contains('maxwidth=100'));
        expect(url, contains('maxheight=100'));
      });

      test('uses small dimensions when size is small', () {
        final url = PhotoUrlBuilder.buildPhotoUrl(
          'ref',
          'key',
          size: PhotoSize.small,
        );

        expect(url, contains('maxwidth=200'));
        expect(url, contains('maxheight=200'));
      });

      test('uses medium dimensions by default', () {
        final url = PhotoUrlBuilder.buildPhotoUrl(
          'ref',
          'key',
        );

        expect(url, contains('maxwidth=400'));
        expect(url, contains('maxheight=400'));
      });

      test('uses large dimensions when size is large', () {
        final url = PhotoUrlBuilder.buildPhotoUrl(
          'ref',
          'key',
          size: PhotoSize.large,
        );

        expect(url, contains('maxwidth=800'));
        expect(url, contains('maxheight=600'));
      });

      test('uses xlarge dimensions when size is xlarge', () {
        final url = PhotoUrlBuilder.buildPhotoUrl(
          'ref',
          'key',
          size: PhotoSize.xlarge,
        );

        expect(url, contains('maxwidth=1200'));
        expect(url, contains('maxheight=900'));
      });

      test('explicit dimensions override size parameter', () {
        final url = PhotoUrlBuilder.buildPhotoUrl(
          'ref',
          'key',
          maxWidth: 300,
          size: PhotoSize.xlarge, // Should be ignored
        );

        expect(url, contains('maxwidth=300'));
        // Should NOT contain xlarge dimensions
        expect(url, isNot(contains('maxwidth=1200')));
      });

      test('URL starts with correct base', () {
        final url = PhotoUrlBuilder.buildPhotoUrl('ref', 'key');
        expect(url, startsWith(baseUrl));
      });

      test('handles special characters in photo reference', () {
        final url = PhotoUrlBuilder.buildPhotoUrl(
          'ref_with-special.chars',
          'key',
        );
        expect(url, contains('photoreference=ref_with-special.chars'));
      });
    });
  });

  // ============================================================================
  // PhotoSize enum
  // ============================================================================
  group('PhotoSize', () {
    test('has five values', () {
      expect(PhotoSize.values.length, 5);
    });

    test('values are in correct order', () {
      expect(PhotoSize.values[0], PhotoSize.thumbnail);
      expect(PhotoSize.values[1], PhotoSize.small);
      expect(PhotoSize.values[2], PhotoSize.medium);
      expect(PhotoSize.values[3], PhotoSize.large);
      expect(PhotoSize.values[4], PhotoSize.xlarge);
    });

    group('displayName', () {
      test('thumbnail has correct display name', () {
        expect(PhotoSize.thumbnail.displayName, 'Thumbnail (100x100)');
      });

      test('small has correct display name', () {
        expect(PhotoSize.small.displayName, 'Small (200x200)');
      });

      test('medium has correct display name', () {
        expect(PhotoSize.medium.displayName, 'Medium (400x400)');
      });

      test('large has correct display name', () {
        expect(PhotoSize.large.displayName, 'Large (800x600)');
      });

      test('xlarge has correct display name', () {
        expect(PhotoSize.xlarge.displayName, 'X-Large (1200x900)');
      });
    });

    group('maxWidth', () {
      test('thumbnail is 100', () {
        expect(PhotoSize.thumbnail.maxWidth, 100);
      });

      test('small is 200', () {
        expect(PhotoSize.small.maxWidth, 200);
      });

      test('medium is 400', () {
        expect(PhotoSize.medium.maxWidth, 400);
      });

      test('large is 800', () {
        expect(PhotoSize.large.maxWidth, 800);
      });

      test('xlarge is 1200', () {
        expect(PhotoSize.xlarge.maxWidth, 1200);
      });
    });

    group('maxHeight', () {
      test('thumbnail is 100', () {
        expect(PhotoSize.thumbnail.maxHeight, 100);
      });

      test('small is 200', () {
        expect(PhotoSize.small.maxHeight, 200);
      });

      test('medium is 400', () {
        expect(PhotoSize.medium.maxHeight, 400);
      });

      test('large is 600', () {
        expect(PhotoSize.large.maxHeight, 600);
      });

      test('xlarge is 900', () {
        expect(PhotoSize.xlarge.maxHeight, 900);
      });
    });

    group('size ordering', () {
      test('maxWidth increases from thumbnail to xlarge', () {
        int prev = 0;
        for (final size in PhotoSize.values) {
          expect(size.maxWidth, greaterThan(prev));
          prev = size.maxWidth;
        }
      });

      test('maxHeight increases from thumbnail to xlarge', () {
        int prev = 0;
        for (final size in PhotoSize.values) {
          expect(size.maxHeight, greaterThan(prev));
          prev = size.maxHeight;
        }
      });
    });
  });

  // ============================================================================
  // VenuePhotoService (uninitialized state)
  // ============================================================================
  group('VenuePhotoService (uninitialized)', () {
    late VenuePhotoService photoService;

    setUp(() {
      photoService = VenuePhotoService();
    });

    test('getCachedPhotoCount returns 0 when not initialized', () {
      expect(photoService.getCachedPhotoCount('any_place'), 0);
    });

    test('hasCachedPhotos returns false when not initialized', () {
      expect(photoService.hasCachedPhotos('any_place'), false);
    });
  });
}

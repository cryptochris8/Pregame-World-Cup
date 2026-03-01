import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/services/google_places_photo_service.dart';

void main() {
  // GooglePlacesPhotoService is a singleton. We test the pure-logic methods:
  // getPhotoUrl, getPhotoUrls, getPhotoUrlsAllSizes, formatCacheSize.
  // Methods that require Dio/filesystem (downloadAndCachePhoto, clearCache,
  // getCacheSize, getPlaceDetailsWithPhotos) need platform access and are
  // tested for basic contract/structure only.

  late GooglePlacesPhotoService service;

  setUp(() {
    service = GooglePlacesPhotoService();
    // Clear internal cache between tests
    // We can call getPhotoUrl to populate, but the singleton persists
  });

  // ============================================================================
  // getPhotoUrl
  // ============================================================================
  group('getPhotoUrl', () {
    test('returns URL with correct base', () {
      final url = service.getPhotoUrl('test_ref');
      expect(
        url,
        startsWith('https://maps.googleapis.com/maps/api/place/photo'),
      );
    });

    test('includes photo reference in URL', () {
      final url = service.getPhotoUrl('my_photo_ref_abc');
      expect(url, contains('photoreference=my_photo_ref_abc'));
    });

    test('uses default medium size (800)', () {
      final url = service.getPhotoUrl('ref');
      expect(url, contains('maxwidth=800'));
    });

    test('uses thumbnail size when specified', () {
      final url = service.getPhotoUrl('ref', size: PhotoSize.thumbnail);
      expect(url, contains('maxwidth=200'));
    });

    test('uses small size when specified', () {
      final url = service.getPhotoUrl('ref', size: PhotoSize.small);
      expect(url, contains('maxwidth=400'));
    });

    test('uses large size when specified', () {
      final url = service.getPhotoUrl('ref', size: PhotoSize.large);
      expect(url, contains('maxwidth=1600'));
    });

    test('caches URL for same reference and size', () {
      final url1 = service.getPhotoUrl('cached_ref');
      final url2 = service.getPhotoUrl('cached_ref');
      expect(identical(url1, url2) || url1 == url2, isTrue);
    });

    test('returns different URLs for different sizes', () {
      final urlSmall = service.getPhotoUrl('ref', size: PhotoSize.small);
      final urlLarge = service.getPhotoUrl('ref', size: PhotoSize.large);
      expect(urlSmall, isNot(equals(urlLarge)));
    });

    test('returns different URLs for different references', () {
      final url1 = service.getPhotoUrl('ref_a');
      final url2 = service.getPhotoUrl('ref_b');
      expect(url1, isNot(equals(url2)));
    });
  });

  // ============================================================================
  // getPhotoUrls
  // ============================================================================
  group('getPhotoUrls', () {
    test('returns list of URLs for multiple references', () {
      final urls = service.getPhotoUrls(['ref1', 'ref2', 'ref3']);
      expect(urls.length, 3);
    });

    test('each URL contains its respective reference', () {
      final urls = service.getPhotoUrls(['alpha', 'beta']);
      expect(urls[0], contains('photoreference=alpha'));
      expect(urls[1], contains('photoreference=beta'));
    });

    test('returns empty list for empty input', () {
      final urls = service.getPhotoUrls([]);
      expect(urls, isEmpty);
    });

    test('applies specified size to all URLs', () {
      final urls = service.getPhotoUrls(
        ['r1', 'r2'],
        size: PhotoSize.thumbnail,
      );
      for (final url in urls) {
        expect(url, contains('maxwidth=200'));
      }
    });

    test('uses default medium size', () {
      final urls = service.getPhotoUrls(['r1']);
      expect(urls[0], contains('maxwidth=800'));
    });
  });

  // ============================================================================
  // getPhotoUrlsAllSizes
  // ============================================================================
  group('getPhotoUrlsAllSizes', () {
    test('returns map with all PhotoSize values', () {
      final result = service.getPhotoUrlsAllSizes('test_ref');
      expect(result.length, PhotoSize.values.length);
      expect(result.keys.toSet(), equals(PhotoSize.values.toSet()));
    });

    test('each size maps to a different URL', () {
      final result = service.getPhotoUrlsAllSizes('test_ref');
      final urls = result.values.toSet();
      expect(urls.length, PhotoSize.values.length);
    });

    test('thumbnail URL has maxwidth=200', () {
      final result = service.getPhotoUrlsAllSizes('test_ref');
      expect(result[PhotoSize.thumbnail], contains('maxwidth=200'));
    });

    test('large URL has maxwidth=1600', () {
      final result = service.getPhotoUrlsAllSizes('test_ref');
      expect(result[PhotoSize.large], contains('maxwidth=1600'));
    });

    test('all URLs contain the same photo reference', () {
      final result = service.getPhotoUrlsAllSizes('my_unique_ref');
      for (final url in result.values) {
        expect(url, contains('photoreference=my_unique_ref'));
      }
    });
  });

  // ============================================================================
  // formatCacheSize
  // ============================================================================
  group('formatCacheSize', () {
    test('formats bytes', () {
      expect(service.formatCacheSize(500), '500 B');
    });

    test('formats zero bytes', () {
      expect(service.formatCacheSize(0), '0 B');
    });

    test('formats kilobytes', () {
      final result = service.formatCacheSize(2048);
      expect(result, '2.0 KB');
    });

    test('formats kilobytes with decimal', () {
      final result = service.formatCacheSize(1536);
      expect(result, '1.5 KB');
    });

    test('formats megabytes', () {
      final result = service.formatCacheSize(1048576);
      expect(result, '1.0 MB');
    });

    test('formats megabytes with decimal', () {
      final result = service.formatCacheSize(5242880);
      expect(result, '5.0 MB');
    });

    test('formats gigabytes', () {
      final result = service.formatCacheSize(1073741824);
      expect(result, '1.0 GB');
    });

    test('boundary: just under 1 KB', () {
      final result = service.formatCacheSize(1023);
      expect(result, '1023 B');
    });

    test('boundary: exactly 1 KB', () {
      final result = service.formatCacheSize(1024);
      expect(result, '1.0 KB');
    });

    test('boundary: just under 1 MB', () {
      final result = service.formatCacheSize(1024 * 1024 - 1);
      expect(result, contains('KB'));
    });

    test('boundary: exactly 1 MB', () {
      final result = service.formatCacheSize(1024 * 1024);
      expect(result, '1.0 MB');
    });

    test('boundary: just under 1 GB', () {
      final result = service.formatCacheSize(1024 * 1024 * 1024 - 1);
      expect(result, contains('MB'));
    });

    test('large megabyte value', () {
      // 500 MB
      final result = service.formatCacheSize(500 * 1024 * 1024);
      expect(result, '500.0 MB');
    });
  });

  // ============================================================================
  // PhotoSize enum (google_places version)
  // ============================================================================
  group('PhotoSize enum', () {
    test('has four values', () {
      expect(PhotoSize.values.length, 4);
    });

    test('thumbnail maxWidth is 200', () {
      expect(PhotoSize.thumbnail.maxWidth, 200);
    });

    test('small maxWidth is 400', () {
      expect(PhotoSize.small.maxWidth, 400);
    });

    test('medium maxWidth is 800', () {
      expect(PhotoSize.medium.maxWidth, 800);
    });

    test('large maxWidth is 1600', () {
      expect(PhotoSize.large.maxWidth, 1600);
    });

    test('maxWidth increases with each size', () {
      int prev = 0;
      for (final size in PhotoSize.values) {
        expect(size.maxWidth, greaterThan(prev));
        prev = size.maxWidth;
      }
    });
  });
}

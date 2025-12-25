import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../../../config/api_keys.dart';

/// Service for handling Google Places photos with caching and multiple sizes
class GooglePlacesPhotoService {
  static final GooglePlacesPhotoService _instance = GooglePlacesPhotoService._internal();
  factory GooglePlacesPhotoService() => _instance;
  GooglePlacesPhotoService._internal();

  final Dio _dio = Dio();
  final Map<String, String> _photoCache = {};

  /// Photo size options
  enum PhotoSize {
    thumbnail(200),
    small(400),
    medium(800),
    large(1600);

    const PhotoSize(this.maxWidth);
    final int maxWidth;
  }

  /// Get photo URL for a given photo reference and size
  String getPhotoUrl(String photoReference, {PhotoSize size = PhotoSize.medium}) {
    final cacheKey = '${photoReference}_${size.maxWidth}';
    
    if (_photoCache.containsKey(cacheKey)) {
      return _photoCache[cacheKey]!;
    }

    final url = 'https://maps.googleapis.com/maps/api/place/photo'
        '?maxwidth=${size.maxWidth}'
        '&photoreference=$photoReference'
        '&key=${ApiKeys.googlePlaces}';

    _photoCache[cacheKey] = url;
    return url;
  }

  /// Get multiple photo URLs for a list of photo references
  List<String> getPhotoUrls(
    List<String> photoReferences, {
    PhotoSize size = PhotoSize.medium,
  }) {
    return photoReferences
        .map((ref) => getPhotoUrl(ref, size: size))
        .toList();
  }

  /// Get photo URLs in multiple sizes for responsive display
  Map<PhotoSize, String> getPhotoUrlsAllSizes(String photoReference) {
    return {
      for (final size in PhotoSize.values)
        size: getPhotoUrl(photoReference, size: size),
    };
  }

  /// Download and cache photo locally for offline access
  Future<String?> downloadAndCachePhoto(
    String photoReference, {
    PhotoSize size = PhotoSize.medium,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${directory.path}/photo_cache');
      
      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }

      final fileName = '${photoReference}_${size.maxWidth}.jpg';
      final filePath = '${cacheDir.path}/$fileName';
      final file = File(filePath);

      // Return cached file if it exists
      if (await file.exists()) {
        return filePath;
      }

      // Download photo
      final photoUrl = getPhotoUrl(photoReference, size: size);
      final response = await _dio.get(
        photoUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      // Save to cache
      await file.writeAsBytes(response.data);
      return filePath;

    } catch (e) {
      print('Error downloading photo: $e');
      return null;
    }
  }

  /// Preload photos for better user experience
  Future<void> preloadPhotos(
    List<String> photoReferences, {
    PhotoSize size = PhotoSize.small,
  }) async {
    final futures = photoReferences.map((ref) => 
        downloadAndCachePhoto(ref, size: size));
    
    await Future.wait(futures);
  }

  /// Clear photo cache
  Future<void> clearCache() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${directory.path}/photo_cache');
      
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }
      
      _photoCache.clear();
    } catch (e) {
      print('Error clearing photo cache: $e');
    }
  }

  /// Get cache size in bytes
  Future<int> getCacheSize() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${directory.path}/photo_cache');
      
      if (!await cacheDir.exists()) {
        return 0;
      }

      int totalSize = 0;
      await for (final entity in cacheDir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      
      return totalSize;
    } catch (e) {
      print('Error calculating cache size: $e');
      return 0;
    }
  }

  /// Format cache size for display
  String formatCacheSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Get place details with high-quality photos
  Future<Map<String, dynamic>?> getPlaceDetailsWithPhotos(String placeId) async {
    try {
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/place/details/json',
        queryParameters: {
          'place_id': placeId,
          'fields': 'photos,name,rating,formatted_address,formatted_phone_number,website,opening_hours,price_level,types',
          'key': ApiKeys.googlePlaces,
        },
      );

      if (response.statusCode == 200) {
        final result = response.data['result'];
        
        // Enhance photos with multiple sizes
        if (result['photos'] != null) {
          final photos = result['photos'] as List;
          result['enhanced_photos'] = photos.map((photo) {
            final photoRef = photo['photo_reference'] as String;
            return {
              'photo_reference': photoRef,
              'urls': getPhotoUrlsAllSizes(photoRef),
              'attribution': photo['html_attributions'] ?? [],
            };
          }).toList();
        }

        return result;
      }
      
      return null;
    } catch (e) {
      print('Error fetching place details: $e');
      return null;
    }
  }
} 
import '../entities/cached_venue_photo.dart';
import 'performance_monitor.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';

class VenuePhotoService {
  static const String _photoCacheBox = 'venue_photos';
  
  final Dio _dio = Dio();
  Box<CachedVenuePhotos>? _photosBox;
  bool _isInitialized = false;
  
  // In-memory cache for current session
  final Map<String, CachedVenuePhotos> _memoryCache = {};
  
  // Google Places API configuration
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';
  static const String _photoUrl = '$_baseUrl/photo';
  
  // Initialize the photo cache
  Future<void> initialize() async {
    try {
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(CachedVenuePhotosAdapter());
      }
      _photosBox = await Hive.openBox<CachedVenuePhotos>(_photoCacheBox);
      await _cleanExpiredPhotos();
      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
    }
  }
  
  /// Clean expired photos from cache
  Future<void> _cleanExpiredPhotos() async {
    final keysToDelete = <String>[];
    
    for (final key in _photosBox!.keys) {
      final cachedPhotos = _photosBox!.get(key);
      if (cachedPhotos != null && cachedPhotos.isExpired()) {
        keysToDelete.add(key.toString());
      }
    }
    
    for (final key in keysToDelete) {
      await _photosBox!.delete(key);
    }
  }
  
  /// Get venue photos from Google Places API with caching
  Future<List<String>> getVenuePhotos(
    String placeId, {
    String? apiKey,
    int maxPhotos = 5,
    int maxWidth = 800,
  }) async {
    try {
      // Check if service is initialized
      if (!_isInitialized || _photosBox == null) {
        await initialize();
        if (!_isInitialized || _photosBox == null) {
          return [];
        }
      }

      // Check memory cache first
      if (_memoryCache.containsKey(placeId)) {
        final cached = _memoryCache[placeId]!;
        if (!cached.isExpired()) {
          PerformanceMonitor.recordCacheHit('memory_$placeId');
          return cached.photoUrls;
        } else {
          _memoryCache.remove(placeId);
        }
      }
      
      // Check persistent cache
      final cachedPhotos = _photosBox!.get(placeId);
      if (cachedPhotos != null && !cachedPhotos.isExpired()) {
        // Store in memory cache for faster access
        _memoryCache[placeId] = cachedPhotos;
        PerformanceMonitor.recordCacheHit('hive_$placeId');
        return cachedPhotos.photoUrls;
      }
      
      // Fetch from Google Places API
      if (apiKey == null) {
        return [];
      }
      
      PerformanceMonitor.startApiCall('photo_fetch_$placeId');
      final photoUrls = await _fetchPhotosFromAPI(placeId, apiKey, maxPhotos, maxWidth);
      
      // Cache the results
      final newCachedPhotos = CachedVenuePhotos(
        placeId: placeId,
        photoUrls: photoUrls,
        timestamp: DateTime.now(),
        metadata: {
          'maxPhotos': maxPhotos,
          'maxWidth': maxWidth,
        },
      );
      
      // Store in both memory and persistent cache
      _memoryCache[placeId] = newCachedPhotos;
      await _photosBox!.put(placeId, newCachedPhotos);
      
      PerformanceMonitor.endApiCall('photo_fetch_$placeId', success: true);

      return photoUrls;
      
    } catch (e) {
      PerformanceMonitor.endApiCall('photo_fetch_$placeId', success: false);
      return [];
    }
  }
  
  /// Fetch photos from Google Places API
  Future<List<String>> _fetchPhotosFromAPI(
    String placeId,
    String apiKey,
    int maxPhotos,
    int maxWidth,
  ) async {
    try {
      // First, get place details to access photo references
      final detailsResponse = await _dio.get(
        '$_baseUrl/details/json',
        queryParameters: {
          'place_id': placeId,
          'fields': 'photos',
          'key': apiKey,
        },
      );
      
      if (detailsResponse.statusCode != 200) {
        throw Exception('Places API details request failed: ${detailsResponse.statusCode}');
      }
      
      final result = detailsResponse.data['result'];
      if (result == null) {
        return [];
      }
      
      final photos = result['photos'] as List<dynamic>?;
      if (photos == null || photos.isEmpty) {
        return [];
      }
      
      final photoUrls = <String>[];
      final photosToProcess = photos.take(maxPhotos);
      
      for (final photo in photosToProcess) {
        final photoReference = photo['photo_reference'] as String?;
        if (photoReference != null) {
          final photoUrl = '$_photoUrl?'
              'photo_reference=$photoReference&'
              'maxwidth=$maxWidth&'
              'key=$apiKey';
          photoUrls.add(photoUrl);
        }
      }
      
      return photoUrls;
      
    } catch (e) {
      return [];
    }
  }
  
  /// Get cached photo count for a venue
  int getCachedPhotoCount(String placeId) {
    if (!_isInitialized || _photosBox == null) {
      return 0;
    }
    final cached = _memoryCache[placeId] ?? _photosBox!.get(placeId);
    return cached?.photoCount ?? 0;
  }
  
  /// Check if venue has cached photos
  bool hasCachedPhotos(String placeId) {
    if (!_isInitialized || _photosBox == null) {
      return false;
    }
    final cached = _memoryCache[placeId] ?? _photosBox!.get(placeId);
    return cached != null && !cached.isExpired() && cached.photoUrls.isNotEmpty;
  }
  
  /// Get primary photo URL for a venue
  Future<String?> getPrimaryPhotoUrl(
    String placeId, {
    String? apiKey,
    int maxWidth = 400,
  }) async {
    final photos = await getVenuePhotos(
      placeId,
      apiKey: apiKey,
      maxPhotos: 1,
      maxWidth: maxWidth,
    );
    
    return photos.isNotEmpty ? photos.first : null;
  }
  
  /// Preload photos for multiple venues
  Future<void> preloadVenuePhotos(
    List<String> placeIds, {
    String? apiKey,
    int maxPhotos = 3,
    int maxWidth = 600,
  }) async {
    final futures = placeIds.map((placeId) => getVenuePhotos(
      placeId,
      apiKey: apiKey,
      maxPhotos: maxPhotos,
      maxWidth: maxWidth,
    ));
    
    await Future.wait(futures);
  }
  
  /// Clear photo cache
  Future<void> clearCache() async {
    _memoryCache.clear();
    await _photosBox!.clear();
  }
  
  /// Clear expired photos
  Future<void> clearExpiredCache() async {
    await _cleanExpiredPhotos();
  }
  
  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    final memoryCount = _memoryCache.length;
    final persistentCount = _photosBox!.length;
    final totalPhotos = _photosBox!.values
        .map((cached) => cached.photoCount)
        .fold(0, (sum, count) => sum + count);
    
    return {
      'memory_entries': memoryCount,
      'persistent_entries': persistentCount,
      'total_photos': totalPhotos,
      'cache_size_mb': _estimateCacheSize(),
    };
  }
  
  double _estimateCacheSize() {
    // Rough estimation: each photo URL is ~200 bytes
    final totalUrls = _photosBox!.values
        .map((cached) => cached.photoCount)
        .fold(0, (sum, count) => sum + count);
    
    return (totalUrls * 200) / (1024 * 1024); // Convert to MB
  }
}

/// Enhanced photo URL builder with different sizes
class PhotoUrlBuilder {
  static const String _basePhotoUrl = 'https://maps.googleapis.com/maps/api/place/photo';
  
  /// Build photo URL with specific dimensions
  static String buildPhotoUrl(
    String photoReference, 
    String apiKey, {
    int? maxWidth,
    int? maxHeight,
    PhotoSize size = PhotoSize.medium,
  }) {
    // Use predefined size if no specific dimensions provided
    if (maxWidth == null && maxHeight == null) {
      final dimensions = _getSizeDimensions(size);
      maxWidth = dimensions['width'];
      maxHeight = dimensions['height'];
    }
    
    final params = <String, String>{
      'photoreference': photoReference,
      'key': apiKey,
    };
    
    if (maxWidth != null) params['maxwidth'] = maxWidth.toString();
    if (maxHeight != null) params['maxheight'] = maxHeight.toString();
    
    final queryString = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    return '$_basePhotoUrl?$queryString';
  }
  
  /// Get dimensions for predefined photo sizes
  static Map<String, int> _getSizeDimensions(PhotoSize size) {
    switch (size) {
      case PhotoSize.thumbnail:
        return {'width': 100, 'height': 100};
      case PhotoSize.small:
        return {'width': 200, 'height': 200};
      case PhotoSize.medium:
        return {'width': 400, 'height': 400};
      case PhotoSize.large:
        return {'width': 800, 'height': 600};
      case PhotoSize.xlarge:
        return {'width': 1200, 'height': 900};
    }
  }
}

enum PhotoSize {
  thumbnail,
  small,
  medium,
  large,
  xlarge,
}

extension PhotoSizeExtension on PhotoSize {
  String get displayName {
    switch (this) {
      case PhotoSize.thumbnail:
        return 'Thumbnail (100x100)';
      case PhotoSize.small:
        return 'Small (200x200)';
      case PhotoSize.medium:
        return 'Medium (400x400)';
      case PhotoSize.large:
        return 'Large (800x600)';
      case PhotoSize.xlarge:
        return 'X-Large (1200x900)';
    }
  }
  
  int get maxWidth {
    final dimensions = PhotoUrlBuilder._getSizeDimensions(this);
    return dimensions['width']!;
  }
  
  int get maxHeight {
    final dimensions = PhotoUrlBuilder._getSizeDimensions(this);
    return dimensions['height']!;
  }
} 
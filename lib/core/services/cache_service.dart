import 'package:hive_flutter/hive_flutter.dart';
import '../entities/cached_venue_data.dart';
import '../entities/cached_geocoding_data.dart';

class CacheService {
  static const String _venuesCacheBox = 'venues_cache';
  static const String _geocodingCacheBox = 'geocoding_cache';
  static const String _genericCacheBox = 'generic_cache';
  static const Duration _cacheExpiry = Duration(hours: 6); // Cache venues for 6 hours
  static const Duration _geocodingExpiry = Duration(days: 7); // Cache geocoding for 7 days
  static const Duration _defaultGenericExpiry = Duration(minutes: 30); // Default generic cache expiry
  
  late Box<CachedVenueData> _venuesBox;
  late Box<CachedGeocodingData> _geocodingBox;
  late Box<dynamic> _genericBox;
  
  // In-memory cache for current session
  final Map<String, CachedVenueData> _memoryVenueCache = {};
  final Map<String, CachedGeocodingData> _memoryGeocodingCache = {};
  final Map<String, _CachedGenericData> _memoryGenericCache = {};
  
  static CacheService? _instance;
  static CacheService get instance => _instance ??= CacheService._();
  
  CacheService._();
  
  Future<void> initialize() async {
    await Hive.initFlutter();
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CachedVenueDataAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(CachedGeocodingDataAdapter());
    }
    
    // Open boxes
    _venuesBox = await Hive.openBox<CachedVenueData>(_venuesCacheBox);
    _geocodingBox = await Hive.openBox<CachedGeocodingData>(_geocodingCacheBox);
    _genericBox = await Hive.openBox<dynamic>(_genericCacheBox);
    
    // Clean expired data on startup
    await _cleanExpiredData();
  }
  
  Future<void> _cleanExpiredData() async {
    final now = DateTime.now();
    
    // Clean venues cache
    final venueKeysToDelete = <String>[];
    for (final key in _venuesBox.keys) {
      final cachedData = _venuesBox.get(key);
      if (cachedData != null && now.difference(cachedData.cachedAt) > _cacheExpiry) {
        venueKeysToDelete.add(key.toString());
      }
    }
    for (final key in venueKeysToDelete) {
      await _venuesBox.delete(key);
    }
    
    // Clean geocoding cache
    final geocodingKeysToDelete = <String>[];
    for (final key in _geocodingBox.keys) {
      final cachedData = _geocodingBox.get(key);
      if (cachedData != null && now.difference(cachedData.cachedAt) > _geocodingExpiry) {
        geocodingKeysToDelete.add(key.toString());
      }
    }
    for (final key in geocodingKeysToDelete) {
      await _geocodingBox.delete(key);
    }
    
    // Clean generic cache
    final genericKeysToDelete = <String>[];
    for (final key in _genericBox.keys) {
      final cachedData = _genericBox.get(key);
      if (cachedData != null && cachedData is Map) {
        try {
          final dataMap = Map<String, dynamic>.from(cachedData);
          final expiryTime = DateTime.parse(dataMap['expiryTime'] as String);
          if (now.isAfter(expiryTime)) {
            genericKeysToDelete.add(key.toString());
          }
        } catch (e) {
          // If we can't parse the cached data, delete it
          genericKeysToDelete.add(key.toString());
        }
      }
    }
    for (final key in genericKeysToDelete) {
      await _genericBox.delete(key);
    }
  }
  
  // Generic cache methods
  Future<T?> get<T>(String key) async {
    // Check memory cache first
    if (_memoryGenericCache.containsKey(key)) {
      final cached = _memoryGenericCache[key]!;
      if (DateTime.now().isBefore(cached.expiryTime)) {
        return cached.data as T?;
      } else {
        _memoryGenericCache.remove(key);
      }
    }
    
    // Check persistent cache
    final cachedData = _genericBox.get(key);
    if (cachedData != null && cachedData is Map) {
      try {
        final dataMap = Map<String, dynamic>.from(cachedData);
        final expiryTime = DateTime.parse(dataMap['expiryTime'] as String);
        if (DateTime.now().isBefore(expiryTime)) {
          final data = dataMap['data'];
          
          // Store in memory cache for faster access
          _memoryGenericCache[key] = _CachedGenericData(
            data: data,
            expiryTime: expiryTime,
          );
          
          return data as T?;
        } else {
          // Remove expired entry
          await _genericBox.delete(key);
        }
      } catch (e) {
        // If we can't parse the cached data, delete it and return null
        await _genericBox.delete(key);
      }
    }
    
    return null;
  }
  
  Future<void> set<T>(String key, T data, {Duration? duration}) async {
    final expiryTime = DateTime.now().add(duration ?? _defaultGenericExpiry);
    
    final cachedData = {
      'data': data,
      'expiryTime': expiryTime.toIso8601String(),
    };
    
    // Store in both memory and persistent cache
    _memoryGenericCache[key] = _CachedGenericData(
      data: data,
      expiryTime: expiryTime,
    );
    await _genericBox.put(key, cachedData);
  }
  
  Future<void> remove(String key) async {
    _memoryGenericCache.remove(key);
    await _genericBox.delete(key);
  }
  
  String _generateVenueKey(double lat, double lng, double radius, List<String> types) {
    final locationKey = '${lat.toStringAsFixed(4)}_${lng.toStringAsFixed(4)}';
    final radiusKey = radius.toStringAsFixed(0);
    final typesKey = types.join('_');
    return '${locationKey}_${radiusKey}_$typesKey';
  }
  
  String _generateGeocodingKey(String address) {
    return address.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
  }
  
  Future<CachedVenueData?> getCachedVenues(double lat, double lng, double radius, List<String> types) async {
    final key = _generateVenueKey(lat, lng, radius, types);
    
    // Check memory cache first
    if (_memoryVenueCache.containsKey(key)) {
      final cached = _memoryVenueCache[key]!;
      if (DateTime.now().difference(cached.cachedAt) <= _cacheExpiry) {
        return cached;
      } else {
        _memoryVenueCache.remove(key);
      }
    }
    
    // Check persistent cache
    final cachedData = _venuesBox.get(key);
    if (cachedData != null && DateTime.now().difference(cachedData.cachedAt) <= _cacheExpiry) {
      // Store in memory cache for faster access
      _memoryVenueCache[key] = cachedData;
      return cachedData;
    }
    
    return null;
  }
  
  Future<void> cacheVenues(double lat, double lng, double radius, List<String> types, String venuesJson) async {
    final key = _generateVenueKey(lat, lng, radius, types);
    final cachedData = CachedVenueData(
      key: key,
      venuesJson: venuesJson,
      cachedAt: DateTime.now(),
      latitude: lat,
      longitude: lng,
      radius: radius,
      types: types,
    );
    
    // Store in both memory and persistent cache
    _memoryVenueCache[key] = cachedData;
    await _venuesBox.put(key, cachedData);
  }
  
  Future<CachedGeocodingData?> getCachedGeocodingData(String address) async {
    final key = _generateGeocodingKey(address);
    
    // Check memory cache first
    if (_memoryGeocodingCache.containsKey(key)) {
      final cached = _memoryGeocodingCache[key]!;
      if (DateTime.now().difference(cached.cachedAt) <= _geocodingExpiry) {
        return cached;
      } else {
        _memoryGeocodingCache.remove(key);
      }
    }
    
    // Check persistent cache
    final cachedData = _geocodingBox.get(key);
    if (cachedData != null && DateTime.now().difference(cachedData.cachedAt) <= _geocodingExpiry) {
      // Store in memory cache for faster access
      _memoryGeocodingCache[key] = cachedData;
      return cachedData;
    }
    
    return null;
  }
  
  Future<void> cacheGeocodingData(String address, double latitude, double longitude) async {
    final key = _generateGeocodingKey(address);
    final cachedData = CachedGeocodingData(
      key: key,
      address: address,
      latitude: latitude,
      longitude: longitude,
      cachedAt: DateTime.now(),
    );
    
    // Store in both memory and persistent cache
    _memoryGeocodingCache[key] = cachedData;
    await _geocodingBox.put(key, cachedData);
  }
  
  Future<void> clearCache() async {
    _memoryVenueCache.clear();
    _memoryGeocodingCache.clear();
    _memoryGenericCache.clear();
    await _venuesBox.clear();
    await _geocodingBox.clear();
    await _genericBox.clear();
  }
  
  Future<void> clearExpiredCache() async {
    await _cleanExpiredData();
  }
}

// Helper class for generic cache data
class _CachedGenericData {
  final dynamic data;
  final DateTime expiryTime;
  
  _CachedGenericData({
    required this.data,
    required this.expiryTime,
  });
} 
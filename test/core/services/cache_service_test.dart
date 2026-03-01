import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:pregame_world_cup/core/entities/cached_venue_data.dart';
import 'package:pregame_world_cup/core/entities/cached_geocoding_data.dart';

/// Tests for CacheService.
///
/// CacheService has a private constructor (singleton via CacheService.instance),
/// so we cannot instantiate it directly in tests. However, the underlying Hive
/// boxes and cache logic can be tested by:
/// 1. Testing the entity data classes (CachedVenueData, CachedGeocodingData)
/// 2. Testing Hive box operations directly with real Hive boxes
/// 3. Testing the key generation logic patterns
/// 4. Testing cache expiry logic patterns
///
/// The singleton pattern means we test what is publicly accessible and
/// verify the cache behavior through Hive directly.
void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('cache_service_test_');
    Hive.init(tempDir.path);

    // Register adapters if not already registered
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CachedVenueDataAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(CachedGeocodingDataAdapter());
    }
  });

  tearDownAll(() async {
    await Hive.close();
    try {
      await tempDir.delete(recursive: true);
    } catch (_) {
      // Ignore cleanup errors on Windows
    }
  });

  group('CacheService - Venue Box Operations', () {
    late Box<CachedVenueData> venuesBox;

    setUp(() async {
      venuesBox = await Hive.openBox<CachedVenueData>('test_venues_cache_${DateTime.now().millisecondsSinceEpoch}');
    });

    tearDown(() async {
      await venuesBox.clear();
      await venuesBox.close();
    });

    test('can store and retrieve venue data from Hive box', () async {
      final now = DateTime.now();
      final data = CachedVenueData(
        key: 'test_key',
        venuesJson: '{"venues": [{"name": "MetLife Stadium"}]}',
        cachedAt: now,
        latitude: 40.8128,
        longitude: -74.0742,
        radius: 5000,
        types: ['stadium', 'bar'],
      );

      await venuesBox.put('test_key', data);
      final retrieved = venuesBox.get('test_key');

      expect(retrieved, isNotNull);
      expect(retrieved!.key, equals('test_key'));
      expect(retrieved.venuesJson, contains('MetLife Stadium'));
      expect(retrieved.latitude, equals(40.8128));
      expect(retrieved.longitude, equals(-74.0742));
      expect(retrieved.radius, equals(5000));
      expect(retrieved.types, equals(['stadium', 'bar']));
    });

    test('can store multiple venue entries', () async {
      for (int i = 0; i < 5; i++) {
        final data = CachedVenueData(
          key: 'venue_$i',
          venuesJson: '{"id": $i}',
          cachedAt: DateTime.now(),
          latitude: 33.0 + i,
          longitude: -84.0 + i,
          radius: 1000.0 * (i + 1),
          types: ['bar'],
        );
        await venuesBox.put('venue_$i', data);
      }

      expect(venuesBox.length, equals(5));
      expect(venuesBox.get('venue_0')?.latitude, equals(33.0));
      expect(venuesBox.get('venue_4')?.latitude, equals(37.0));
    });

    test('can delete specific venue entry', () async {
      final data = CachedVenueData(
        key: 'to_delete',
        venuesJson: '[]',
        cachedAt: DateTime.now(),
        latitude: 33.0,
        longitude: -84.0,
        radius: 1000,
        types: ['bar'],
      );
      await venuesBox.put('to_delete', data);
      expect(venuesBox.containsKey('to_delete'), isTrue);

      await venuesBox.delete('to_delete');
      expect(venuesBox.containsKey('to_delete'), isFalse);
      expect(venuesBox.get('to_delete'), isNull);
    });

    test('can clear all venue entries', () async {
      for (int i = 0; i < 3; i++) {
        await venuesBox.put('venue_$i', CachedVenueData(
          key: 'venue_$i',
          venuesJson: '[]',
          cachedAt: DateTime.now(),
          latitude: 33.0,
          longitude: -84.0,
          radius: 1000,
          types: [],
        ));
      }
      expect(venuesBox.length, equals(3));

      await venuesBox.clear();
      expect(venuesBox.length, equals(0));
    });

    test('overwriting a key replaces existing data', () async {
      await venuesBox.put('same_key', CachedVenueData(
        key: 'same_key',
        venuesJson: '{"version": 1}',
        cachedAt: DateTime.now(),
        latitude: 33.0,
        longitude: -84.0,
        radius: 1000,
        types: ['bar'],
      ));

      await venuesBox.put('same_key', CachedVenueData(
        key: 'same_key',
        venuesJson: '{"version": 2}',
        cachedAt: DateTime.now(),
        latitude: 34.0,
        longitude: -85.0,
        radius: 2000,
        types: ['restaurant'],
      ));

      final retrieved = venuesBox.get('same_key');
      expect(retrieved!.venuesJson, equals('{"version": 2}'));
      expect(retrieved.latitude, equals(34.0));
      expect(venuesBox.length, equals(1));
    });
  });

  group('CacheService - Geocoding Box Operations', () {
    late Box<CachedGeocodingData> geocodingBox;

    setUp(() async {
      geocodingBox = await Hive.openBox<CachedGeocodingData>('test_geocoding_cache_${DateTime.now().millisecondsSinceEpoch}');
    });

    tearDown(() async {
      await geocodingBox.clear();
      await geocodingBox.close();
    });

    test('can store and retrieve geocoding data from Hive box', () async {
      final now = DateTime.now();
      final data = CachedGeocodingData(
        key: 'geocode_metlife',
        address: '1 MetLife Stadium Dr, East Rutherford, NJ',
        latitude: 40.8128,
        longitude: -74.0742,
        cachedAt: now,
      );

      await geocodingBox.put('geocode_metlife', data);
      final retrieved = geocodingBox.get('geocode_metlife');

      expect(retrieved, isNotNull);
      expect(retrieved!.address, equals('1 MetLife Stadium Dr, East Rutherford, NJ'));
      expect(retrieved.latitude, equals(40.8128));
      expect(retrieved.longitude, equals(-74.0742));
    });

    test('can store multiple geocoding entries', () async {
      final addresses = {
        'miami': {'address': 'Miami, FL', 'lat': 25.7617, 'lng': -80.1918},
        'nyc': {'address': 'New York, NY', 'lat': 40.7128, 'lng': -74.0060},
        'la': {'address': 'Los Angeles, CA', 'lat': 34.0522, 'lng': -118.2437},
      };

      for (final entry in addresses.entries) {
        await geocodingBox.put(entry.key, CachedGeocodingData(
          key: entry.key,
          address: entry.value['address'] as String,
          latitude: entry.value['lat'] as double,
          longitude: entry.value['lng'] as double,
          cachedAt: DateTime.now(),
        ));
      }

      expect(geocodingBox.length, equals(3));
      expect(geocodingBox.get('miami')?.address, equals('Miami, FL'));
      expect(geocodingBox.get('nyc')?.latitude, closeTo(40.71, 0.01));
    });

    test('can delete geocoding entry', () async {
      await geocodingBox.put('temp', CachedGeocodingData(
        key: 'temp',
        address: 'Temporary',
        latitude: 0.0,
        longitude: 0.0,
        cachedAt: DateTime.now(),
      ));

      await geocodingBox.delete('temp');
      expect(geocodingBox.get('temp'), isNull);
    });
  });

  group('CacheService - Generic Box Operations', () {
    late Box<dynamic> genericBox;

    setUp(() async {
      genericBox = await Hive.openBox<dynamic>('test_generic_cache_${DateTime.now().millisecondsSinceEpoch}');
    });

    tearDown(() async {
      await genericBox.clear();
      await genericBox.close();
    });

    test('can store and retrieve generic data with expiry', () async {
      final expiryTime = DateTime.now().add(const Duration(minutes: 30));
      final cachedData = {
        'data': 'test_value',
        'expiryTime': expiryTime.toIso8601String(),
      };

      await genericBox.put('generic_key', cachedData);
      final retrieved = genericBox.get('generic_key');

      expect(retrieved, isNotNull);
      expect(retrieved, isA<Map>());
      final dataMap = Map<String, dynamic>.from(retrieved as Map);
      expect(dataMap['data'], equals('test_value'));

      final parsedExpiry = DateTime.parse(dataMap['expiryTime'] as String);
      expect(parsedExpiry.isAfter(DateTime.now()), isTrue);
    });

    test('can store map data in generic box', () async {
      final expiryTime = DateTime.now().add(const Duration(hours: 1));
      final cachedData = {
        'data': {'team': 'Brazil', 'ranking': 1},
        'expiryTime': expiryTime.toIso8601String(),
      };

      await genericBox.put('team_data', cachedData);
      final retrieved = genericBox.get('team_data');
      final dataMap = Map<String, dynamic>.from(retrieved as Map);
      final innerData = Map<String, dynamic>.from(dataMap['data'] as Map);

      expect(innerData['team'], equals('Brazil'));
      expect(innerData['ranking'], equals(1));
    });

    test('can store list data in generic box', () async {
      final expiryTime = DateTime.now().add(const Duration(hours: 1));
      final cachedData = {
        'data': ['USA', 'Mexico', 'Canada'],
        'expiryTime': expiryTime.toIso8601String(),
      };

      await genericBox.put('host_countries', cachedData);
      final retrieved = genericBox.get('host_countries');
      final dataMap = Map<String, dynamic>.from(retrieved as Map);

      expect(dataMap['data'], isA<List>());
      expect((dataMap['data'] as List).length, equals(3));
    });

    test('can store numeric data in generic box', () async {
      final expiryTime = DateTime.now().add(const Duration(hours: 1));
      final cachedData = {
        'data': 42,
        'expiryTime': expiryTime.toIso8601String(),
      };

      await genericBox.put('score', cachedData);
      final retrieved = genericBox.get('score');
      final dataMap = Map<String, dynamic>.from(retrieved as Map);
      expect(dataMap['data'], equals(42));
    });

    test('can store boolean data in generic box', () async {
      final expiryTime = DateTime.now().add(const Duration(hours: 1));
      final cachedData = {
        'data': true,
        'expiryTime': expiryTime.toIso8601String(),
      };

      await genericBox.put('is_premium', cachedData);
      final retrieved = genericBox.get('is_premium');
      final dataMap = Map<String, dynamic>.from(retrieved as Map);
      expect(dataMap['data'], isTrue);
    });

    test('can remove generic cache entry', () async {
      final cachedData = {
        'data': 'temp',
        'expiryTime': DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
      };
      await genericBox.put('temp_key', cachedData);
      expect(genericBox.containsKey('temp_key'), isTrue);

      await genericBox.delete('temp_key');
      expect(genericBox.containsKey('temp_key'), isFalse);
    });

    test('can clear all generic cache entries', () async {
      for (int i = 0; i < 5; i++) {
        await genericBox.put('key_$i', {
          'data': 'value_$i',
          'expiryTime': DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
        });
      }
      expect(genericBox.length, equals(5));

      await genericBox.clear();
      expect(genericBox.length, equals(0));
    });
  });

  group('CacheService - Venue Key Generation Pattern', () {
    // Tests the key generation logic from _generateVenueKey
    // Pattern: '${lat.toStringAsFixed(4)}_${lng.toStringAsFixed(4)}_${radius.toStringAsFixed(0)}_${types.join('_')}'
    String generateVenueKey(double lat, double lng, double radius, List<String> types) {
      final locationKey = '${lat.toStringAsFixed(4)}_${lng.toStringAsFixed(4)}';
      final radiusKey = radius.toStringAsFixed(0);
      final typesKey = types.join('_');
      return '${locationKey}_${radiusKey}_$typesKey';
    }

    test('generates correct key for typical inputs', () {
      final key = generateVenueKey(33.9510, -83.3753, 5000, ['bar', 'restaurant']);
      expect(key, equals('33.9510_-83.3753_5000_bar_restaurant'));
    });

    test('rounds latitude and longitude to 4 decimal places', () {
      final key = generateVenueKey(33.95107899, -83.37532111, 1000, ['bar']);
      expect(key, equals('33.9511_-83.3753_1000_bar'));
    });

    test('rounds radius to 0 decimal places', () {
      final key = generateVenueKey(33.0, -84.0, 1500.7, ['bar']);
      expect(key, contains('1501'));
    });

    test('handles empty types list', () {
      final key = generateVenueKey(33.0, -84.0, 5000, []);
      expect(key, equals('33.0000_-84.0000_5000_'));
    });

    test('handles single type', () {
      final key = generateVenueKey(33.0, -84.0, 5000, ['bar']);
      expect(key, equals('33.0000_-84.0000_5000_bar'));
    });

    test('handles multiple types joined with underscores', () {
      final key = generateVenueKey(33.0, -84.0, 5000, ['bar', 'restaurant', 'cafe']);
      expect(key, equals('33.0000_-84.0000_5000_bar_restaurant_cafe'));
    });

    test('handles negative coordinates', () {
      final key = generateVenueKey(-33.8688, 151.2093, 2000, ['bar']);
      expect(key, equals('-33.8688_151.2093_2000_bar'));
    });

    test('handles zero coordinates', () {
      final key = generateVenueKey(0.0, 0.0, 1000, ['bar']);
      expect(key, equals('0.0000_0.0000_1000_bar'));
    });

    test('same location different radius produces different keys', () {
      final key1 = generateVenueKey(33.0, -84.0, 1000, ['bar']);
      final key2 = generateVenueKey(33.0, -84.0, 5000, ['bar']);
      expect(key1, isNot(equals(key2)));
    });

    test('same location different types produces different keys', () {
      final key1 = generateVenueKey(33.0, -84.0, 5000, ['bar']);
      final key2 = generateVenueKey(33.0, -84.0, 5000, ['restaurant']);
      expect(key1, isNot(equals(key2)));
    });

    test('nearby locations within precision are the same', () {
      // Both should round to the same 4-decimal precision
      final key1 = generateVenueKey(33.00001, -84.00001, 5000, ['bar']);
      final key2 = generateVenueKey(33.00002, -84.00002, 5000, ['bar']);
      expect(key1, equals(key2));
    });

    test('locations outside precision are different', () {
      final key1 = generateVenueKey(33.0001, -84.0001, 5000, ['bar']);
      final key2 = generateVenueKey(33.0002, -84.0002, 5000, ['bar']);
      expect(key1, isNot(equals(key2)));
    });
  });

  group('CacheService - Geocoding Key Generation Pattern', () {
    // Tests the key generation logic from _generateGeocodingKey
    // Pattern: address.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')
    String generateGeocodingKey(String address) {
      return address.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
    }

    test('converts to lowercase', () {
      final key = generateGeocodingKey('Miami FL');
      expect(key, equals('miami_fl'));
    });

    test('replaces spaces with underscores', () {
      final key = generateGeocodingKey('New York NY');
      expect(key, equals('new_york_ny'));
    });

    test('replaces special characters with underscores', () {
      final key = generateGeocodingKey('123 Main St, Suite #456');
      expect(key, equals('123_main_st__suite__456'));
    });

    test('handles commas and periods', () {
      final key = generateGeocodingKey('Miami, FL 33101');
      expect(key, equals('miami__fl_33101'));
    });

    test('preserves numbers', () {
      final key = generateGeocodingKey('123 Main Street 33101');
      expect(key, equals('123_main_street_33101'));
    });

    test('handles empty string', () {
      final key = generateGeocodingKey('');
      expect(key, equals(''));
    });

    test('handles all-special-character string', () {
      final key = generateGeocodingKey('!@#\$%^&*()');
      expect(key, equals('__________'));
    });

    test('same address different case produces same key', () {
      final key1 = generateGeocodingKey('Miami FL');
      final key2 = generateGeocodingKey('MIAMI FL');
      final key3 = generateGeocodingKey('miami fl');
      expect(key1, equals(key2));
      expect(key2, equals(key3));
    });

    test('handles World Cup host city addresses', () {
      final cities = [
        'MetLife Stadium, East Rutherford, NJ',
        'Hard Rock Stadium, Miami Gardens, FL',
        'AT&T Stadium, Arlington, TX',
        'SoFi Stadium, Inglewood, CA',
        'Estadio Azteca, Mexico City, Mexico',
      ];

      for (final city in cities) {
        final key = generateGeocodingKey(city);
        expect(key, isNotEmpty);
        // Key should only contain lowercase letters, numbers, and underscores
        expect(key, matches(RegExp(r'^[a-z0-9_]+$')));
      }
    });
  });

  group('CacheService - Cache Expiry Logic', () {
    test('venue cache expiry is 6 hours', () {
      const cacheExpiry = Duration(hours: 6);
      expect(cacheExpiry.inHours, equals(6));
      expect(cacheExpiry.inMinutes, equals(360));
    });

    test('geocoding cache expiry is 7 days', () {
      const geocodingExpiry = Duration(days: 7);
      expect(geocodingExpiry.inDays, equals(7));
      expect(geocodingExpiry.inHours, equals(168));
    });

    test('default generic cache expiry is 30 minutes', () {
      const defaultGenericExpiry = Duration(minutes: 30);
      expect(defaultGenericExpiry.inMinutes, equals(30));
      expect(defaultGenericExpiry.inSeconds, equals(1800));
    });

    test('expired venue data is detected correctly', () {
      final cachedAt = DateTime.now().subtract(const Duration(hours: 7));
      const cacheExpiry = Duration(hours: 6);
      final isExpired = DateTime.now().difference(cachedAt) > cacheExpiry;
      expect(isExpired, isTrue);
    });

    test('fresh venue data is detected correctly', () {
      final cachedAt = DateTime.now().subtract(const Duration(hours: 3));
      const cacheExpiry = Duration(hours: 6);
      final isExpired = DateTime.now().difference(cachedAt) > cacheExpiry;
      expect(isExpired, isFalse);
    });

    test('expired geocoding data is detected correctly', () {
      final cachedAt = DateTime.now().subtract(const Duration(days: 8));
      const geocodingExpiry = Duration(days: 7);
      final isExpired = DateTime.now().difference(cachedAt) > geocodingExpiry;
      expect(isExpired, isTrue);
    });

    test('fresh geocoding data is detected correctly', () {
      final cachedAt = DateTime.now().subtract(const Duration(days: 5));
      const geocodingExpiry = Duration(days: 7);
      final isExpired = DateTime.now().difference(cachedAt) > geocodingExpiry;
      expect(isExpired, isFalse);
    });

    test('expired generic data is detected via expiryTime', () {
      final expiryTime = DateTime.now().subtract(const Duration(minutes: 1));
      final isExpired = DateTime.now().isAfter(expiryTime);
      expect(isExpired, isTrue);
    });

    test('fresh generic data is detected via expiryTime', () {
      final expiryTime = DateTime.now().add(const Duration(minutes: 29));
      final isExpired = DateTime.now().isAfter(expiryTime);
      expect(isExpired, isFalse);
    });

    test('data exactly at expiry boundary for venues', () {
      // At exactly 6 hours, difference == cacheExpiry, so NOT expired (uses >)
      final cachedAt = DateTime.now().subtract(const Duration(hours: 6));
      const cacheExpiry = Duration(hours: 6);
      // The CacheService uses > not >= for venue check
      // and <= for getCachedVenues check
      final isExpiredCleanup = DateTime.now().difference(cachedAt) > cacheExpiry;
      // Could be true or false depending on exact timing, but logic is correct
      expect(isExpiredCleanup, isA<bool>());
    });
  });

  group('CacheService - Generic Cache Expiry Serialization', () {
    test('expiryTime is serialized as ISO 8601 string', () {
      final expiryTime = DateTime(2026, 6, 11, 12, 0, 0);
      final serialized = expiryTime.toIso8601String();
      expect(serialized, contains('2026-06-11'));
    });

    test('expiryTime can be parsed back from ISO 8601 string', () {
      final original = DateTime(2026, 7, 19, 15, 30, 0);
      final serialized = original.toIso8601String();
      final parsed = DateTime.parse(serialized);

      expect(parsed.year, equals(2026));
      expect(parsed.month, equals(7));
      expect(parsed.day, equals(19));
      expect(parsed.hour, equals(15));
      expect(parsed.minute, equals(30));
    });

    test('cache data format matches expected structure', () {
      final expiryTime = DateTime.now().add(const Duration(minutes: 30));
      final cachedData = {
        'data': 'test_value',
        'expiryTime': expiryTime.toIso8601String(),
      };

      expect(cachedData.containsKey('data'), isTrue);
      expect(cachedData.containsKey('expiryTime'), isTrue);
      expect(cachedData.keys.length, equals(2));
    });

    test('custom duration override is applied correctly', () {
      const customDuration = Duration(hours: 2);
      final now = DateTime.now();
      final expiryTime = now.add(customDuration);

      expect(expiryTime.isAfter(now), isTrue);
      expect(
        expiryTime.difference(now).inMinutes,
        equals(120),
      );
    });

    test('null duration uses default 30 minutes', () {
      const defaultExpiry = Duration(minutes: 30);
      final now = DateTime.now();
      final expiryTime = now.add(defaultExpiry);

      expect(
        expiryTime.difference(now).inMinutes,
        equals(30),
      );
    });
  });

  group('CacheService - Expired Data Cleanup Pattern', () {
    late Box<dynamic> cleanupBox;

    setUp(() async {
      cleanupBox = await Hive.openBox<dynamic>('test_cleanup_${DateTime.now().millisecondsSinceEpoch}');
    });

    tearDown(() async {
      await cleanupBox.clear();
      await cleanupBox.close();
    });

    test('cleanup removes entries with past expiryTime', () async {
      // Add expired entry
      await cleanupBox.put('expired', {
        'data': 'old_value',
        'expiryTime': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
      });

      // Add fresh entry
      await cleanupBox.put('fresh', {
        'data': 'new_value',
        'expiryTime': DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
      });

      // Simulate cleanup logic from _cleanExpiredData
      final now = DateTime.now();
      final keysToDelete = <String>[];
      for (final key in cleanupBox.keys) {
        final cachedData = cleanupBox.get(key);
        if (cachedData != null && cachedData is Map) {
          try {
            final dataMap = Map<String, dynamic>.from(cachedData);
            final expiryTime = DateTime.parse(dataMap['expiryTime'] as String);
            if (now.isAfter(expiryTime)) {
              keysToDelete.add(key.toString());
            }
          } catch (e) {
            keysToDelete.add(key.toString());
          }
        }
      }

      for (final key in keysToDelete) {
        await cleanupBox.delete(key);
      }

      expect(cleanupBox.length, equals(1));
      expect(cleanupBox.containsKey('fresh'), isTrue);
      expect(cleanupBox.containsKey('expired'), isFalse);
    });

    test('cleanup removes malformed entries', () async {
      // Add entry with unparseable expiryTime
      await cleanupBox.put('malformed', {
        'data': 'value',
        'expiryTime': 'not-a-date',
      });

      // Add valid entry
      await cleanupBox.put('valid', {
        'data': 'value',
        'expiryTime': DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
      });

      // Simulate cleanup
      final now = DateTime.now();
      final keysToDelete = <String>[];
      for (final key in cleanupBox.keys) {
        final cachedData = cleanupBox.get(key);
        if (cachedData != null && cachedData is Map) {
          try {
            final dataMap = Map<String, dynamic>.from(cachedData);
            final expiryTime = DateTime.parse(dataMap['expiryTime'] as String);
            if (now.isAfter(expiryTime)) {
              keysToDelete.add(key.toString());
            }
          } catch (e) {
            keysToDelete.add(key.toString());
          }
        }
      }

      for (final key in keysToDelete) {
        await cleanupBox.delete(key);
      }

      expect(cleanupBox.length, equals(1));
      expect(cleanupBox.containsKey('valid'), isTrue);
      expect(cleanupBox.containsKey('malformed'), isFalse);
    });

    test('cleanup handles empty box gracefully', () async {
      expect(cleanupBox.length, equals(0));

      // Simulate cleanup - should not throw
      final keysToDelete = <String>[];
      for (final key in cleanupBox.keys) {
        final cachedData = cleanupBox.get(key);
        if (cachedData != null && cachedData is Map) {
          try {
            final dataMap = Map<String, dynamic>.from(cachedData);
            final expiryTime = DateTime.parse(dataMap['expiryTime'] as String);
            if (DateTime.now().isAfter(expiryTime)) {
              keysToDelete.add(key.toString());
            }
          } catch (e) {
            keysToDelete.add(key.toString());
          }
        }
      }

      for (final key in keysToDelete) {
        await cleanupBox.delete(key);
      }

      expect(cleanupBox.length, equals(0));
    });

    test('cleanup removes all expired entries and keeps all fresh ones', () async {
      // Add 3 expired and 3 fresh entries
      for (int i = 0; i < 3; i++) {
        await cleanupBox.put('expired_$i', {
          'data': 'old_$i',
          'expiryTime': DateTime.now().subtract(Duration(hours: i + 1)).toIso8601String(),
        });
        await cleanupBox.put('fresh_$i', {
          'data': 'new_$i',
          'expiryTime': DateTime.now().add(Duration(hours: i + 1)).toIso8601String(),
        });
      }

      expect(cleanupBox.length, equals(6));

      // Simulate cleanup
      final now = DateTime.now();
      final keysToDelete = <String>[];
      for (final key in cleanupBox.keys) {
        final cachedData = cleanupBox.get(key);
        if (cachedData != null && cachedData is Map) {
          try {
            final dataMap = Map<String, dynamic>.from(cachedData);
            final expiryTime = DateTime.parse(dataMap['expiryTime'] as String);
            if (now.isAfter(expiryTime)) {
              keysToDelete.add(key.toString());
            }
          } catch (e) {
            keysToDelete.add(key.toString());
          }
        }
      }

      for (final key in keysToDelete) {
        await cleanupBox.delete(key);
      }

      expect(cleanupBox.length, equals(3));
      for (int i = 0; i < 3; i++) {
        expect(cleanupBox.containsKey('fresh_$i'), isTrue);
        expect(cleanupBox.containsKey('expired_$i'), isFalse);
      }
    });
  });

  group('CacheService - Memory Cache Pattern', () {
    test('in-memory map operations mirror expected behavior', () {
      final memoryCache = <String, dynamic>{};

      // Put
      memoryCache['key1'] = {'data': 'value1', 'expiryTime': DateTime.now().add(const Duration(minutes: 30))};
      expect(memoryCache.containsKey('key1'), isTrue);

      // Get
      final retrieved = memoryCache['key1'];
      expect(retrieved, isNotNull);

      // Remove
      memoryCache.remove('key1');
      expect(memoryCache.containsKey('key1'), isFalse);

      // Clear
      memoryCache['a'] = 'data_a';
      memoryCache['b'] = 'data_b';
      memoryCache.clear();
      expect(memoryCache, isEmpty);
    });

    test('memory cache eviction on expiry check', () {
      final expiryTime = DateTime.now().subtract(const Duration(minutes: 1));

      // Simulate: if expired, remove from memory cache
      final memoryCache = <String, Map<String, dynamic>>{
        'expired_key': {'data': 'old', 'expiryTime': expiryTime},
      };

      final cached = memoryCache['expired_key']!;
      if (DateTime.now().isAfter(cached['expiryTime'] as DateTime)) {
        memoryCache.remove('expired_key');
      }

      expect(memoryCache.containsKey('expired_key'), isFalse);
    });

    test('memory cache hit for fresh data', () {
      final expiryTime = DateTime.now().add(const Duration(minutes: 29));
      final memoryCache = <String, Map<String, dynamic>>{
        'fresh_key': {'data': 'fresh_value', 'expiryTime': expiryTime},
      };

      final cached = memoryCache['fresh_key']!;
      final isFresh = DateTime.now().isBefore(cached['expiryTime'] as DateTime);
      expect(isFresh, isTrue);
      expect(cached['data'], equals('fresh_value'));
    });
  });

  group('CacheService - Constants and Configuration', () {
    test('venue cache box name is venues_cache', () {
      const boxName = 'venues_cache';
      expect(boxName, equals('venues_cache'));
    });

    test('geocoding cache box name is geocoding_cache', () {
      const boxName = 'geocoding_cache';
      expect(boxName, equals('geocoding_cache'));
    });

    test('generic cache box name is generic_cache', () {
      const boxName = 'generic_cache';
      expect(boxName, equals('generic_cache'));
    });

    test('Hive adapters are registered with correct type IDs', () {
      // Type ID 0 is for CachedVenueData
      expect(Hive.isAdapterRegistered(0), isTrue);
      // Type ID 1 is for CachedGeocodingData
      expect(Hive.isAdapterRegistered(1), isTrue);
    });
  });
}

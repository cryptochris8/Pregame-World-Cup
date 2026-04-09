import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:pregame_world_cup/core/services/logging_service.dart';
import '../../domain/entities/fan_zone_guide.dart';

/// Service for loading cross-border travel intelligence from locally-bundled JSON.
///
/// ARCHITECTURE PRINCIPLE: All fan zone and travel data is researched OFFLINE
/// and bundled with the app. There are NO live API calls for this content.
///
/// Covers all 16 host cities across USA (11), Mexico (3), and Canada (2) —
/// the first World Cup spanning 3 countries.
class FanZoneGuideService {
  static const String _assetPath =
      'assets/data/worldcup/fan_zone_guide.json';
  static const String _logTag = 'FanZoneGuide';

  /// In-memory cache to avoid repeated asset loads
  List<FanZoneGuide>? _cache;

  /// Loads all city guides from the bundled JSON asset.
  ///
  /// Returns an empty list if the asset cannot be loaded.
  Future<List<FanZoneGuide>> getAllCityGuides() async {
    if (_cache != null) {
      return _cache!;
    }

    try {
      final jsonString = await rootBundle.loadString(_assetPath);
      final data = json.decode(jsonString) as Map<String, dynamic>;
      final cities = data['cities'] as List<dynamic>;
      _cache = cities
          .map((c) => FanZoneGuide.fromJson(c as Map<String, dynamic>))
          .toList();
      LoggingService.debug(
        'Loaded ${_cache!.length} city guides',
        tag: _logTag,
      );
      return _cache!;
    } catch (e) {
      LoggingService.error(
        'Failed to load fan zone guides: $e',
        tag: _logTag,
      );
      _cache = [];
      return [];
    }
  }

  /// Returns the guide for a specific city by its ID (e.g., "new_york_nj").
  ///
  /// Returns null if no guide exists for the given city ID.
  Future<FanZoneGuide?> getCityGuide(String cityId) async {
    final guides = await getAllCityGuides();
    try {
      return guides.firstWhere((g) => g.cityId == cityId);
    } on StateError {
      LoggingService.debug(
        'No guide found for cityId: $cityId',
        tag: _logTag,
      );
      return null;
    }
  }

  /// Returns all city guides for a given country ("USA", "Mexico", "Canada").
  Future<List<FanZoneGuide>> getCityGuidesByCountry(String country) async {
    final guides = await getAllCityGuides();
    return guides.where((g) => g.country == country).toList();
  }

  /// Searches city guides by name (case-insensitive partial match).
  Future<List<FanZoneGuide>> searchCities(String query) async {
    final guides = await getAllCityGuides();
    final lowerQuery = query.toLowerCase();
    return guides.where((g) {
      return g.cityName.toLowerCase().contains(lowerQuery) ||
          g.country.toLowerCase().contains(lowerQuery) ||
          g.stateOrProvince.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Returns the total number of host cities.
  Future<int> getCityCount() async {
    final guides = await getAllCityGuides();
    return guides.length;
  }

  /// Clears the in-memory cache.
  void clearCache() => _cache = null;
}

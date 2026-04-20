import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:pregame_world_cup/core/services/logging_service.dart';
import '../../domain/entities/match_summary.dart';

/// Service for loading match summaries from locally-bundled JSON assets.
///
/// ARCHITECTURE PRINCIPLE: All match preview content (historical analysis,
/// tactical previews, key storylines, player spotlights, predictions) is
/// sourced from local JSON files bundled with the app. There are NO live API
/// calls for this content. Research is conducted offline, written into JSON,
/// and shipped with app updates as we approach 2026 tournament.
///
/// Asset path: assets/data/worldcup/match_summaries/{TEAM1}_{TEAM2}.json
/// File naming: team codes are sorted alphabetically (e.g. ARG_BRA, not BRA_ARG).
class LocalMatchSummaryService {
  static const String _assetBasePath =
      'assets/data/worldcup/match_summaries';

  // In-memory cache to avoid re-reading assets after first load
  final Map<String, MatchSummary?> _cache = {};

  /// Loads the match summary for two teams.
  ///
  /// Returns null only if no JSON file exists for this matchup yet.
  /// Team codes are sorted alphabetically so the file name is consistent
  /// regardless of which team is home or away.
  Future<MatchSummary?> getMatchSummary(
      String team1Code, String team2Code) async {
    final codes = [team1Code.toUpperCase(), team2Code.toUpperCase()]..sort();
    final key = '${codes[0]}_${codes[1]}';

    if (_cache.containsKey(key)) {
      return _cache[key];
    }

    try {
      final path = '$_assetBasePath/$key.json';
      final jsonString = await rootBundle.loadString(path);
      final data = json.decode(jsonString) as Map<String, dynamic>;
      final summary = MatchSummary.fromJson(data);
      _cache[key] = summary;
      return summary;
    } catch (e) {
      final message = e.toString();
      if (message.contains('Unable to load asset') ||
          message.contains('does not exist in the app bundle')) {
        // File not found — no summary written yet for this matchup
        LoggingService.warning(
          'No local match summary for $key — '
          'add assets/data/worldcup/match_summaries/$key.json',
          tag: 'LocalMatchSummary',
        );
      } else {
        LoggingService.error(
          'Failed to load local match summary for $key: $e',
          tag: 'LocalMatchSummary',
        );
      }
      _cache[key] = null;
      return null;
    }
  }

  /// Clears the in-memory cache.
  /// Useful during development when JSON files are updated.
  void clearCache() => _cache.clear();
}

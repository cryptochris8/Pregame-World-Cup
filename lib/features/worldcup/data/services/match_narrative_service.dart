import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:pregame_world_cup/core/services/logging_service.dart';
import '../../domain/entities/match_narrative.dart';

/// Service for loading pre-generated match narratives from locally-bundled JSON.
///
/// ARCHITECTURE PRINCIPLE: All narrative content is generated OFFLINE by the
/// AI Sports Journalism Engine (generate-match-narratives.ts) and bundled
/// with the app. There are NO live AI API calls for this content.
///
/// This service loads from a SEPARATE directory (match_narratives/) that
/// never interferes with the existing match_summaries/ directory.
///
/// Fallback: If no narrative exists for a match, returns null. The UI should
/// fall back to the existing MatchSummary from LocalMatchSummaryService.
class MatchNarrativeService {
  static const String _assetBasePath =
      'assets/data/worldcup/match_narratives';
  static const String _logTag = 'MatchNarrative';

  /// In-memory cache to avoid repeated asset loads
  final Map<String, MatchNarrative?> _cache = {};

  /// Loads the narrative article for a match between two teams.
  ///
  /// Returns null if no narrative JSON file exists for this matchup.
  /// Team codes are sorted alphabetically for consistent file naming.
  Future<MatchNarrative?> getNarrative(
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
      final narrative = MatchNarrative.fromJson(data);
      _cache[key] = narrative;
      return narrative;
    } catch (e) {
      final message = e.toString();
      if (message.contains('Unable to load asset') ||
          message.contains('does not exist in the app bundle')) {
        // No narrative generated yet — this is expected for many matches
        LoggingService.debug(
          'No narrative for $key — falling back to match summary',
          tag: _logTag,
        );
      } else {
        LoggingService.error(
          'Failed to load narrative for $key: $e',
          tag: _logTag,
        );
      }
      _cache[key] = null;
      return null;
    }
  }

  /// Check if a narrative exists for a match (uses cache if available).
  Future<bool> hasNarrative(String team1Code, String team2Code) async {
    final narrative = await getNarrative(team1Code, team2Code);
    return narrative != null;
  }

  /// Clears the in-memory cache.
  void clearCache() => _cache.clear();
}

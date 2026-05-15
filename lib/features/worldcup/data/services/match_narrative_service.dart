import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:pregame_world_cup/core/services/logging_service.dart';

import '../../domain/entities/match_narrative.dart';

/// Service for loading pre-generated match narratives.
///
/// ARCHITECTURE: Narratives are generated OFFLINE by the AI Sports Journalism
/// Engine (functions/src/generate-match-narratives.ts) and distributed via two
/// channels:
///   1. Firestore `match_narratives/{KEY}` — refreshed between releases by
///      uploading regenerated narratives via seed-match-narratives.ts.
///   2. Bundled JSON in assets/data/worldcup/match_narratives/{KEY}.json —
///      the build-time snapshot that ships with each app release. Used as a
///      fallback when Firestore is unreachable or the doc has not been
///      uploaded yet.
///
/// There are NO live AI API calls from the client.
class MatchNarrativeService {
  static const String _assetBasePath =
      'assets/data/worldcup/match_narratives';
  static const String _firestoreCollection = 'match_narratives';
  static const Duration _firestoreTimeout = Duration(seconds: 5);
  static const String _logTag = 'MatchNarrative';

  final FirebaseFirestore _firestore;

  /// In-memory cache to avoid repeated asset / network loads within a session.
  final Map<String, MatchNarrative?> _cache = {};

  MatchNarrativeService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Loads the narrative article for a match between two teams.
  ///
  /// Tries Firestore first (with a short timeout) for the freshest copy, then
  /// falls back to the bundled JSON asset. Returns null when neither source
  /// has a narrative for this matchup.
  Future<MatchNarrative?> getNarrative(
      String team1Code, String team2Code) async {
    final codes = [team1Code.toUpperCase(), team2Code.toUpperCase()]..sort();
    final key = '${codes[0]}_${codes[1]}';

    if (_cache.containsKey(key)) {
      return _cache[key];
    }

    final fromFirestore = await _loadFromFirestore(key);
    if (fromFirestore != null) {
      _cache[key] = fromFirestore;
      return fromFirestore;
    }

    final fromBundle = await _loadFromBundle(key);
    _cache[key] = fromBundle;
    return fromBundle;
  }

  Future<MatchNarrative?> _loadFromFirestore(String key) async {
    try {
      final doc = await _firestore
          .collection(_firestoreCollection)
          .doc(key)
          .get()
          .timeout(_firestoreTimeout);
      if (!doc.exists) return null;
      final data = doc.data();
      if (data == null) return null;
      return MatchNarrative.fromJson(data);
    } catch (e) {
      LoggingService.debug(
        'Firestore narrative fetch failed for $key — using bundled fallback ($e)',
        tag: _logTag,
      );
      return null;
    }
  }

  Future<MatchNarrative?> _loadFromBundle(String key) async {
    try {
      final path = '$_assetBasePath/$key.json';
      final jsonString = await rootBundle.loadString(path);
      final data = json.decode(jsonString) as Map<String, dynamic>;
      return MatchNarrative.fromJson(data);
    } catch (e) {
      final message = e.toString();
      if (message.contains('Unable to load asset') ||
          message.contains('does not exist in the app bundle')) {
        LoggingService.debug(
          'No narrative for $key — falling back to match summary',
          tag: _logTag,
        );
      } else {
        LoggingService.error(
          'Failed to load bundled narrative for $key: $e',
          tag: _logTag,
        );
      }
      return null;
    }
  }

  /// Check if a narrative exists for a match (uses cache if available).
  Future<bool> hasNarrative(String team1Code, String team2Code) async {
    final narrative = await getNarrative(team1Code, team2Code);
    return narrative != null;
  }

  /// Clears the in-memory cache. Useful for forcing a re-fetch from Firestore
  /// (e.g. after the user pulls to refresh on the match detail page).
  void clearCache() => _cache.clear();
}

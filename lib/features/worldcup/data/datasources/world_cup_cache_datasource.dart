import 'package:flutter/foundation.dart';
import '../../../../core/services/cache_service.dart';
import '../../domain/entities/entities.dart';

/// Local cache data source for World Cup 2026 data
/// Uses Hive for fast local storage
class WorldCupCacheDataSource {
  final CacheService _cacheService;

  // Cache keys
  static const String _matchesKey = 'worldcup_matches';
  static const String _matchesTodayKey = 'worldcup_matches_today';
  static const String _matchesCompletedKey = 'worldcup_matches_completed';
  static const String _matchesUpcomingKey = 'worldcup_matches_upcoming';
  static const String _teamsKey = 'worldcup_teams';
  static const String _groupsKey = 'worldcup_groups';
  static const String _bracketKey = 'worldcup_bracket';
  static const String _venuesKey = 'worldcup_venues';

  // Cache durations - optimized for match freshness needs
  static const Duration _matchesCacheDuration = Duration(hours: 2); // Non-live matches
  static const Duration _liveMatchesCacheDuration = Duration(seconds: 30); // Live matches need frequent updates
  static const Duration _todaysMatchesCacheDuration = Duration(minutes: 15); // Today's matches need moderate freshness
  static const Duration _completedMatchesCacheDuration = Duration(hours: 24); // Completed matches rarely change
  static const Duration _upcomingMatchesCacheDuration = Duration(hours: 1); // Upcoming matches moderate freshness
  static const Duration _teamsCacheDuration = Duration(hours: 24);
  static const Duration _groupsCacheDuration = Duration(minutes: 15);
  static const Duration _bracketCacheDuration = Duration(minutes: 15);
  static const Duration _venuesCacheDuration = Duration(days: 7);

  WorldCupCacheDataSource({
    CacheService? cacheService,
  }) : _cacheService = cacheService ?? CacheService.instance;

  // ==================== MATCHES ====================

  /// Gets all cached matches
  Future<List<WorldCupMatch>?> getCachedMatches() async {
    try {
      final cached = await _cacheService.get<List<dynamic>>(_matchesKey);
      if (cached != null) {
        // Debug output removed
        return cached
            .map((e) => WorldCupMatch.fromMap(e as Map<String, dynamic>))
            .toList();
      }
      // Debug output removed
      return null;
    } catch (e) {
      // Debug output removed
      return null;
    }
  }

  /// Caches all matches
  Future<void> cacheMatches(List<WorldCupMatch> matches) async {
    try {
      final data = matches.map((m) => m.toMap()).toList();
      await _cacheService.set(_matchesKey, data, duration: _matchesCacheDuration);
      // Debug output removed
    } catch (e) {
      // Debug output removed
    }
  }

  /// Gets cached match by ID
  Future<WorldCupMatch?> getCachedMatch(String matchId) async {
    final matches = await getCachedMatches();
    if (matches != null) {
      try {
        return matches.firstWhere((m) => m.matchId == matchId);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Gets cached matches by stage
  Future<List<WorldCupMatch>?> getCachedMatchesByStage(MatchStage stage) async {
    final matches = await getCachedMatches();
    if (matches != null) {
      return matches.where((m) => m.stage == stage).toList();
    }
    return null;
  }

  /// Gets cached matches by group
  Future<List<WorldCupMatch>?> getCachedMatchesByGroup(String groupLetter) async {
    final matches = await getCachedMatches();
    if (matches != null) {
      return matches.where((m) => m.group == groupLetter.toUpperCase()).toList();
    }
    return null;
  }

  /// Gets cached live matches
  Future<List<WorldCupMatch>?> getCachedLiveMatches() async {
    try {
      final cached = await _cacheService.get<List<dynamic>>('${_matchesKey}_live');
      if (cached != null) {
        return cached
            .map((e) => WorldCupMatch.fromMap(e as Map<String, dynamic>))
            .toList();
      }
      return null;
    } catch (e) {
      // Debug output removed
      return null;
    }
  }

  /// Caches live matches with shorter duration
  Future<void> cacheLiveMatches(List<WorldCupMatch> matches) async {
    try {
      final data = matches.map((m) => m.toMap()).toList();
      await _cacheService.set(
        '${_matchesKey}_live',
        data,
        duration: _liveMatchesCacheDuration,
      );
    } catch (e) {
      // Debug output removed
    }
  }

  /// Gets cached today's matches
  Future<List<WorldCupMatch>?> getCachedTodaysMatches() async {
    try {
      final cached = await _cacheService.get<List<dynamic>>(_matchesTodayKey);
      if (cached != null) {
        // Debug output removed
        return cached
            .map((e) => WorldCupMatch.fromMap(e as Map<String, dynamic>))
            .toList();
      }
      return null;
    } catch (e) {
      // Debug output removed
      return null;
    }
  }

  /// Caches today's matches with moderate duration
  Future<void> cacheTodaysMatches(List<WorldCupMatch> matches) async {
    try {
      final data = matches.map((m) => m.toMap()).toList();
      await _cacheService.set(
        _matchesTodayKey,
        data,
        duration: _todaysMatchesCacheDuration,
      );
      // Debug output removed
    } catch (e) {
      // Debug output removed
    }
  }

  /// Gets cached completed matches
  Future<List<WorldCupMatch>?> getCachedCompletedMatches() async {
    try {
      final cached = await _cacheService.get<List<dynamic>>(_matchesCompletedKey);
      if (cached != null) {
        // Debug output removed
        return cached
            .map((e) => WorldCupMatch.fromMap(e as Map<String, dynamic>))
            .toList();
      }
      return null;
    } catch (e) {
      // Debug output removed
      return null;
    }
  }

  /// Caches completed matches with long duration (they don't change)
  Future<void> cacheCompletedMatches(List<WorldCupMatch> matches) async {
    try {
      final data = matches.map((m) => m.toMap()).toList();
      await _cacheService.set(
        _matchesCompletedKey,
        data,
        duration: _completedMatchesCacheDuration,
      );
      // Debug output removed
    } catch (e) {
      // Debug output removed
    }
  }

  /// Gets cached upcoming matches
  Future<List<WorldCupMatch>?> getCachedUpcomingMatches() async {
    try {
      final cached = await _cacheService.get<List<dynamic>>(_matchesUpcomingKey);
      if (cached != null) {
        // Debug output removed
        return cached
            .map((e) => WorldCupMatch.fromMap(e as Map<String, dynamic>))
            .toList();
      }
      return null;
    } catch (e) {
      // Debug output removed
      return null;
    }
  }

  /// Caches upcoming matches with moderate duration
  Future<void> cacheUpcomingMatches(List<WorldCupMatch> matches) async {
    try {
      final data = matches.map((m) => m.toMap()).toList();
      await _cacheService.set(
        _matchesUpcomingKey,
        data,
        duration: _upcomingMatchesCacheDuration,
      );
      // Debug output removed
    } catch (e) {
      // Debug output removed
    }
  }

  // ==================== TEAMS ====================

  /// Gets all cached teams
  Future<List<NationalTeam>?> getCachedTeams() async {
    try {
      final cached = await _cacheService.get<List<dynamic>>(_teamsKey);
      if (cached != null) {
        // Debug output removed
        return cached
            .map((e) => NationalTeam.fromMap(e as Map<String, dynamic>))
            .toList();
      }
      // Debug output removed
      return null;
    } catch (e) {
      // Debug output removed
      return null;
    }
  }

  /// Caches all teams
  Future<void> cacheTeams(List<NationalTeam> teams) async {
    try {
      final data = teams.map((t) => t.toMap()).toList();
      await _cacheService.set(_teamsKey, data, duration: _teamsCacheDuration);
      // Debug output removed
    } catch (e) {
      // Debug output removed
    }
  }

  /// Gets cached team by code
  Future<NationalTeam?> getCachedTeam(String fifaCode) async {
    final teams = await getCachedTeams();
    if (teams != null) {
      try {
        return teams.firstWhere(
          (t) => t.fifaCode.toUpperCase() == fifaCode.toUpperCase(),
        );
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Gets cached teams by group
  Future<List<NationalTeam>?> getCachedTeamsByGroup(String groupLetter) async {
    final teams = await getCachedTeams();
    if (teams != null) {
      return teams.where((t) => t.group == groupLetter.toUpperCase()).toList();
    }
    return null;
  }

  // ==================== GROUPS ====================

  /// Gets all cached groups
  Future<List<WorldCupGroup>?> getCachedGroups() async {
    try {
      final cached = await _cacheService.get<List<dynamic>>(_groupsKey);
      if (cached != null) {
        // Debug output removed
        return cached
            .map((e) => WorldCupGroup.fromMap(e as Map<String, dynamic>))
            .toList();
      }
      // Debug output removed
      return null;
    } catch (e) {
      // Debug output removed
      return null;
    }
  }

  /// Caches all groups
  Future<void> cacheGroups(List<WorldCupGroup> groups) async {
    try {
      final data = groups.map((g) => g.toMap()).toList();
      await _cacheService.set(_groupsKey, data, duration: _groupsCacheDuration);
      // Debug output removed
    } catch (e) {
      // Debug output removed
    }
  }

  /// Gets cached group by letter
  Future<WorldCupGroup?> getCachedGroup(String groupLetter) async {
    final groups = await getCachedGroups();
    if (groups != null) {
      try {
        return groups.firstWhere(
          (g) => g.groupLetter.toUpperCase() == groupLetter.toUpperCase(),
        );
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  // ==================== BRACKET ====================

  /// Gets cached bracket
  Future<WorldCupBracket?> getCachedBracket() async {
    try {
      final cached = await _cacheService.get<Map<String, dynamic>>(_bracketKey);
      if (cached != null) {
        // Debug output removed
        return WorldCupBracket.fromMap(cached);
      }
      // Debug output removed
      return null;
    } catch (e) {
      // Debug output removed
      return null;
    }
  }

  /// Caches bracket
  Future<void> cacheBracket(WorldCupBracket bracket) async {
    try {
      await _cacheService.set(
        _bracketKey,
        bracket.toMap(),
        duration: _bracketCacheDuration,
      );
      // Debug output removed
    } catch (e) {
      // Debug output removed
    }
  }

  // ==================== VENUES ====================

  /// Gets all cached venues
  Future<List<WorldCupVenue>?> getCachedVenues() async {
    try {
      final cached = await _cacheService.get<List<dynamic>>(_venuesKey);
      if (cached != null) {
        // Debug output removed
        return cached
            .map((e) => WorldCupVenue.fromMap(e as Map<String, dynamic>))
            .toList();
      }
      // Debug output removed
      return null;
    } catch (e) {
      // Debug output removed
      return null;
    }
  }

  /// Caches all venues
  Future<void> cacheVenues(List<WorldCupVenue> venues) async {
    try {
      final data = venues.map((v) => v.toMap()).toList();
      await _cacheService.set(_venuesKey, data, duration: _venuesCacheDuration);
      // Debug output removed
    } catch (e) {
      // Debug output removed
    }
  }

  /// Gets cached venue by ID
  Future<WorldCupVenue?> getCachedVenue(String venueId) async {
    final venues = await getCachedVenues();
    if (venues != null) {
      try {
        return venues.firstWhere((v) => v.venueId == venueId);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  // ==================== UTILITIES ====================

  /// Clears all World Cup cache
  Future<void> clearAllCache() async {
    try {
      await _cacheService.remove(_matchesKey);
      await _cacheService.remove('${_matchesKey}_live');
      await _cacheService.remove(_matchesTodayKey);
      await _cacheService.remove(_matchesCompletedKey);
      await _cacheService.remove(_matchesUpcomingKey);
      await _cacheService.remove(_teamsKey);
      await _cacheService.remove(_groupsKey);
      await _cacheService.remove(_bracketKey);
      await _cacheService.remove(_venuesKey);
      // Debug output removed
    } catch (e) {
      // Debug output removed
    }
  }

  /// Clears specific cache
  Future<void> clearCache(String key) async {
    try {
      await _cacheService.remove(key);
      // Debug output removed
    } catch (e) {
      // Debug output removed
    }
  }

  /// Checks if cache is valid (not expired)
  Future<bool> isCacheValid(String key) async {
    try {
      final data = await _cacheService.get(key);
      return data != null;
    } catch (e) {
      return false;
    }
  }
}

import 'package:flutter/foundation.dart';
import '../../../../core/services/cache_service.dart';
import '../../domain/entities/entities.dart';

/// Local cache data source for World Cup 2026 data
/// Uses Hive for fast local storage
class WorldCupCacheDataSource {
  final CacheService _cacheService;

  // Cache keys
  static const String _matchesKey = 'worldcup_matches';
  static const String _teamsKey = 'worldcup_teams';
  static const String _groupsKey = 'worldcup_groups';
  static const String _bracketKey = 'worldcup_bracket';
  static const String _venuesKey = 'worldcup_venues';

  // Cache durations
  static const Duration _matchesCacheDuration = Duration(minutes: 5);
  static const Duration _liveMatchesCacheDuration = Duration(seconds: 30);
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
        debugPrint('Cache HIT: Found ${cached.length} cached matches');
        return cached
            .map((e) => WorldCupMatch.fromMap(e as Map<String, dynamic>))
            .toList();
      }
      debugPrint('Cache MISS: No cached matches');
      return null;
    } catch (e) {
      debugPrint('Cache error getting matches: $e');
      return null;
    }
  }

  /// Caches all matches
  Future<void> cacheMatches(List<WorldCupMatch> matches) async {
    try {
      final data = matches.map((m) => m.toMap()).toList();
      await _cacheService.set(_matchesKey, data, duration: _matchesCacheDuration);
      debugPrint('Cached ${matches.length} matches');
    } catch (e) {
      debugPrint('Cache error saving matches: $e');
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
      debugPrint('Cache error getting live matches: $e');
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
      debugPrint('Cache error saving live matches: $e');
    }
  }

  // ==================== TEAMS ====================

  /// Gets all cached teams
  Future<List<NationalTeam>?> getCachedTeams() async {
    try {
      final cached = await _cacheService.get<List<dynamic>>(_teamsKey);
      if (cached != null) {
        debugPrint('Cache HIT: Found ${cached.length} cached teams');
        return cached
            .map((e) => NationalTeam.fromMap(e as Map<String, dynamic>))
            .toList();
      }
      debugPrint('Cache MISS: No cached teams');
      return null;
    } catch (e) {
      debugPrint('Cache error getting teams: $e');
      return null;
    }
  }

  /// Caches all teams
  Future<void> cacheTeams(List<NationalTeam> teams) async {
    try {
      final data = teams.map((t) => t.toMap()).toList();
      await _cacheService.set(_teamsKey, data, duration: _teamsCacheDuration);
      debugPrint('Cached ${teams.length} teams');
    } catch (e) {
      debugPrint('Cache error saving teams: $e');
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
        debugPrint('Cache HIT: Found ${cached.length} cached groups');
        return cached
            .map((e) => WorldCupGroup.fromMap(e as Map<String, dynamic>))
            .toList();
      }
      debugPrint('Cache MISS: No cached groups');
      return null;
    } catch (e) {
      debugPrint('Cache error getting groups: $e');
      return null;
    }
  }

  /// Caches all groups
  Future<void> cacheGroups(List<WorldCupGroup> groups) async {
    try {
      final data = groups.map((g) => g.toMap()).toList();
      await _cacheService.set(_groupsKey, data, duration: _groupsCacheDuration);
      debugPrint('Cached ${groups.length} groups');
    } catch (e) {
      debugPrint('Cache error saving groups: $e');
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
        debugPrint('Cache HIT: Found cached bracket');
        return WorldCupBracket.fromMap(cached);
      }
      debugPrint('Cache MISS: No cached bracket');
      return null;
    } catch (e) {
      debugPrint('Cache error getting bracket: $e');
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
      debugPrint('Cached bracket');
    } catch (e) {
      debugPrint('Cache error saving bracket: $e');
    }
  }

  // ==================== VENUES ====================

  /// Gets all cached venues
  Future<List<WorldCupVenue>?> getCachedVenues() async {
    try {
      final cached = await _cacheService.get<List<dynamic>>(_venuesKey);
      if (cached != null) {
        debugPrint('Cache HIT: Found ${cached.length} cached venues');
        return cached
            .map((e) => WorldCupVenue.fromMap(e as Map<String, dynamic>))
            .toList();
      }
      debugPrint('Cache MISS: No cached venues');
      return null;
    } catch (e) {
      debugPrint('Cache error getting venues: $e');
      return null;
    }
  }

  /// Caches all venues
  Future<void> cacheVenues(List<WorldCupVenue> venues) async {
    try {
      final data = venues.map((v) => v.toMap()).toList();
      await _cacheService.set(_venuesKey, data, duration: _venuesCacheDuration);
      debugPrint('Cached ${venues.length} venues');
    } catch (e) {
      debugPrint('Cache error saving venues: $e');
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
      await _cacheService.remove(_teamsKey);
      await _cacheService.remove(_groupsKey);
      await _cacheService.remove(_bracketKey);
      await _cacheService.remove(_venuesKey);
      debugPrint('Cleared all World Cup cache');
    } catch (e) {
      debugPrint('Cache error clearing all: $e');
    }
  }

  /// Clears specific cache
  Future<void> clearCache(String key) async {
    try {
      await _cacheService.remove(key);
      debugPrint('Cleared cache: $key');
    } catch (e) {
      debugPrint('Cache error clearing $key: $e');
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

import 'package:flutter/foundation.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/world_cup_match_repository.dart';
import '../datasources/world_cup_api_datasource.dart';
import '../datasources/world_cup_firestore_datasource.dart';
import '../datasources/world_cup_cache_datasource.dart';
import '../mock/world_cup_mock_data.dart';

/// Implementation of WorldCupMatchRepository
/// Coordinates between API, Firestore, and local cache
class WorldCupMatchRepositoryImpl implements WorldCupMatchRepository {
  final WorldCupApiDataSource _apiDataSource;
  final WorldCupFirestoreDataSource _firestoreDataSource;
  final WorldCupCacheDataSource _cacheDataSource;

  WorldCupMatchRepositoryImpl({
    required WorldCupApiDataSource apiDataSource,
    required WorldCupFirestoreDataSource firestoreDataSource,
    required WorldCupCacheDataSource cacheDataSource,
  })  : _apiDataSource = apiDataSource,
        _firestoreDataSource = firestoreDataSource,
        _cacheDataSource = cacheDataSource;

  @override
  Future<List<WorldCupMatch>> getAllMatches() async {
    try {
      // Try cache first
      final cached = await _cacheDataSource.getCachedMatches();
      if (cached != null && cached.isNotEmpty) {
        debugPrint('Returning ${cached.length} matches from cache');
        return cached;
      }

      // Try Firestore
      try {
        final firestoreMatches = await _firestoreDataSource.getAllMatches();
        if (firestoreMatches.isNotEmpty) {
          await _cacheDataSource.cacheMatches(firestoreMatches);
          debugPrint('Returning ${firestoreMatches.length} matches from Firestore');
          return firestoreMatches;
        }
      } catch (e) {
        debugPrint('Firestore fetch failed: $e');
      }

      // Fetch from API
      try {
        final apiMatches = await refreshMatches();
        if (apiMatches.isNotEmpty) {
          return apiMatches;
        }
      } catch (e) {
        debugPrint('API fetch failed: $e');
      }

      // Fallback to mock data for development/testing
      debugPrint('Using mock data fallback');
      final mockMatches = WorldCupMockData.groupStageMatches;
      await _cacheDataSource.cacheMatches(mockMatches);
      return mockMatches;
    } catch (e) {
      debugPrint('Error getting all matches: $e');
      // Return mock data as final fallback
      return WorldCupMockData.groupStageMatches;
    }
  }

  @override
  Future<List<WorldCupMatch>> getMatchesByStage(MatchStage stage) async {
    try {
      final cached = await _cacheDataSource.getCachedMatchesByStage(stage);
      if (cached != null && cached.isNotEmpty) {
        return cached;
      }

      final matches = await _firestoreDataSource.getMatchesByStage(stage);
      return matches;
    } catch (e) {
      debugPrint('Error getting matches by stage: $e');
      return [];
    }
  }

  @override
  Future<List<WorldCupMatch>> getMatchesByGroup(String groupLetter) async {
    try {
      final cached = await _cacheDataSource.getCachedMatchesByGroup(groupLetter);
      if (cached != null && cached.isNotEmpty) {
        return cached;
      }

      return await _firestoreDataSource.getMatchesByGroup(groupLetter);
    } catch (e) {
      debugPrint('Error getting matches by group: $e');
      return [];
    }
  }

  @override
  Future<List<WorldCupMatch>> getMatchesByDate(DateTime date) async {
    try {
      final allMatches = await getAllMatches();
      return allMatches.where((match) {
        if (match.dateTime == null) return false;
        return match.dateTime!.year == date.year &&
               match.dateTime!.month == date.month &&
               match.dateTime!.day == date.day;
      }).toList();
    } catch (e) {
      debugPrint('Error getting matches by date: $e');
      return [];
    }
  }

  @override
  Future<List<WorldCupMatch>> getMatchesByTeam(String teamCode) async {
    try {
      return await _firestoreDataSource.getMatchesByTeam(teamCode);
    } catch (e) {
      debugPrint('Error getting matches by team: $e');
      return [];
    }
  }

  @override
  Future<List<WorldCupMatch>> getMatchesByVenue(String venueId) async {
    try {
      final allMatches = await getAllMatches();
      return allMatches.where((m) => m.venueId == venueId).toList();
    } catch (e) {
      debugPrint('Error getting matches by venue: $e');
      return [];
    }
  }

  @override
  Future<WorldCupMatch?> getMatchById(String matchId) async {
    try {
      // Try cache first
      final cached = await _cacheDataSource.getCachedMatch(matchId);
      if (cached != null) {
        return cached;
      }

      return await _firestoreDataSource.getMatchById(matchId);
    } catch (e) {
      debugPrint('Error getting match by ID: $e');
      return null;
    }
  }

  @override
  Future<List<WorldCupMatch>> getUpcomingMatches({int limit = 10}) async {
    try {
      // Try cache first
      final cached = await _cacheDataSource.getCachedUpcomingMatches();
      if (cached != null && cached.isNotEmpty) {
        debugPrint('Returning ${cached.length} upcoming matches from cache');
        return cached.take(limit).toList();
      }

      // Fetch from Firestore and cache
      final matches = await _firestoreDataSource.getUpcomingMatches(limit: limit);
      if (matches.isNotEmpty) {
        await _cacheDataSource.cacheUpcomingMatches(matches);
      }
      return matches;
    } catch (e) {
      debugPrint('Error getting upcoming matches: $e');
      return [];
    }
  }

  @override
  Future<List<WorldCupMatch>> getLiveMatches() async {
    try {
      // Check cache first (short duration)
      final cached = await _cacheDataSource.getCachedLiveMatches();
      if (cached != null) {
        return cached;
      }

      // Try API for most up-to-date data
      try {
        final apiMatches = await _apiDataSource.fetchLiveMatches();
        if (apiMatches.isNotEmpty) {
          await _cacheDataSource.cacheLiveMatches(apiMatches);
          // Also update Firestore
          for (final match in apiMatches) {
            await _firestoreDataSource.saveMatch(match);
          }
          return apiMatches;
        }
      } catch (_) {
        // Fall through to Firestore
      }

      return await _firestoreDataSource.getLiveMatches();
    } catch (e) {
      debugPrint('Error getting live matches: $e');
      return [];
    }
  }

  @override
  Future<List<WorldCupMatch>> getTodaysMatches() async {
    try {
      // Try cache first
      final cached = await _cacheDataSource.getCachedTodaysMatches();
      if (cached != null && cached.isNotEmpty) {
        debugPrint('Returning ${cached.length} today matches from cache');
        return cached;
      }

      // Get from date filter and cache
      final matches = await getMatchesByDate(DateTime.now());
      if (matches.isNotEmpty) {
        await _cacheDataSource.cacheTodaysMatches(matches);
      }
      return matches;
    } catch (e) {
      debugPrint('Error getting today matches: $e');
      return [];
    }
  }

  @override
  Future<List<WorldCupMatch>> getCompletedMatches({int limit = 10}) async {
    try {
      // Try cache first (24-hour cache for completed matches)
      final cached = await _cacheDataSource.getCachedCompletedMatches();
      if (cached != null && cached.isNotEmpty) {
        debugPrint('Returning ${cached.length} completed matches from cache');
        return cached.take(limit).toList();
      }

      // Fetch and compute
      final allMatches = await getAllMatches();
      final completed = allMatches
          .where((m) => m.status == MatchStatus.completed)
          .toList();

      // Sort by date descending (most recent first)
      completed.sort((a, b) {
        if (a.dateTime == null && b.dateTime == null) return 0;
        if (a.dateTime == null) return 1;
        if (b.dateTime == null) return -1;
        return b.dateTime!.compareTo(a.dateTime!);
      });

      // Cache all completed matches (they don't change)
      if (completed.isNotEmpty) {
        await _cacheDataSource.cacheCompletedMatches(completed);
      }

      return completed.take(limit).toList();
    } catch (e) {
      debugPrint('Error getting completed matches: $e');
      return [];
    }
  }

  @override
  Future<List<WorldCupMatch>> getMatchesByGroupMatchDay(int matchDay) async {
    try {
      final allMatches = await getAllMatches();
      return allMatches
          .where((m) => m.stage == MatchStage.groupStage &&
                        m.groupMatchDay == matchDay)
          .toList();
    } catch (e) {
      debugPrint('Error getting matches by group match day: $e');
      return [];
    }
  }

  @override
  Future<void> updateMatch(WorldCupMatch match) async {
    try {
      await _firestoreDataSource.saveMatch(match);
      // Invalidate cache
      await _cacheDataSource.clearCache('worldcup_matches');
    } catch (e) {
      debugPrint('Error updating match: $e');
      throw Exception('Failed to update match: $e');
    }
  }

  @override
  Future<List<WorldCupMatch>> refreshMatches() async {
    try {
      debugPrint('Refreshing matches from API...');
      final apiMatches = await _apiDataSource.fetchAllMatches();

      if (apiMatches.isNotEmpty) {
        // Save to Firestore
        await _firestoreDataSource.saveMatches(apiMatches);
        // Cache locally
        await _cacheDataSource.cacheMatches(apiMatches);
        debugPrint('Refreshed ${apiMatches.length} matches');
        return apiMatches;
      }

      return [];
    } catch (e) {
      debugPrint('Error refreshing matches: $e');
      throw Exception('Failed to refresh matches: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    await _cacheDataSource.clearCache('worldcup_matches');
    await _cacheDataSource.clearCache('worldcup_matches_live');
    await _cacheDataSource.clearCache('worldcup_matches_today');
    await _cacheDataSource.clearCache('worldcup_matches_completed');
    await _cacheDataSource.clearCache('worldcup_matches_upcoming');
  }

  @override
  Stream<List<WorldCupMatch>> watchLiveMatches() {
    return _firestoreDataSource.watchLiveMatches();
  }

  @override
  Stream<WorldCupMatch?> watchMatch(String matchId) {
    return _firestoreDataSource.watchMatch(matchId);
  }
}

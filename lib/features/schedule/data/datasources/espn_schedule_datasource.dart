import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pregame_world_cup/core/services/cache_service.dart';
import 'package:pregame_world_cup/core/services/logging_service.dart';
import 'package:pregame_world_cup/features/schedule/domain/entities/game_schedule.dart';
import 'package:pregame_world_cup/services/espn_service.dart';

/// ESPN Schedule Data Source
/// Provides 2025 college football schedule data with real dates and times
/// This integrates with your existing ESPN service to fetch actual 2025 season data
class ESPNScheduleDataSource {
  final ESPNService _espnService;
  final CacheService _cacheService;
  
  // Cache duration for different types of data
  static const Duration _upcomingGamesCacheDuration = Duration(minutes: 10);
  static const Duration _fullSeasonCacheDuration = Duration(hours: 6);
  
  ESPNScheduleDataSource({
    ESPNService? espnService,
    CacheService? cacheService,
  }) : _espnService = espnService ?? ESPNService(),
       _cacheService = cacheService ?? CacheService.instance;

  /// Fetch upcoming games from ESPN API with caching
  Future<List<GameSchedule>> fetchUpcomingGames({int limit = 10}) async {
    final cacheKey = 'espn_upcoming_games_$limit';
    
    try {
      debugPrint('🏈 ESPN DataSource: Fetching upcoming games...');
      
      // Check cache first
      final cachedGames = await _cacheService.get<List<dynamic>>(cacheKey);
      if (cachedGames != null) {
        debugPrint('📦 ESPN Cache HIT: Found cached upcoming games');
        return cachedGames.map((e) => GameSchedule.fromMap(e as Map<String, dynamic>)).toList();
      }
      
      // Fetch from ESPN API
      final games = await _espnService.getUpcomingGames(limit: limit);
      
      if (games.isNotEmpty) {
        // Cache the results
        final gamesMaps = games.map((game) => game.toMap()).toList();
        await _cacheService.set(cacheKey, gamesMaps, duration: _upcomingGamesCacheDuration);
        
        debugPrint('✅ ESPN DataSource: Successfully fetched ${games.length} upcoming games');
        LoggingService.info('ESPN DataSource: Fetched ${games.length} upcoming games');
        
        return games;
      } else {
        debugPrint('⚠️ ESPN DataSource: No upcoming games found');
        return [];
      }
    } catch (e) {
      debugPrint('❌ ESPN DataSource Error: $e');
      LoggingService.error('ESPN DataSource error fetching upcoming games: $e');
      return [];
    }
  }

  /// Fetch 2025 full season schedule from ESPN API with caching
  Future<List<GameSchedule>> fetch2025SeasonSchedule({int limit = 100}) async {
    final cacheKey = 'espn_2025_season_schedule_$limit';
    
    try {
      debugPrint('🏈 ESPN DataSource: Fetching 2025 season schedule...');
      
      // Check cache first (longer cache for full season)
      final cachedGames = await _cacheService.get<List<dynamic>>(cacheKey);
      if (cachedGames != null) {
        debugPrint('📦 ESPN Cache HIT: Found cached 2025 season schedule');
        return cachedGames.map((e) => GameSchedule.fromMap(e as Map<String, dynamic>)).toList();
      }
      
      // Fetch from ESPN API
      final games = await _espnService.get2025Schedule(limit: limit);
      
      if (games.isNotEmpty) {
        // Cache the results
        final gamesMaps = games.map((game) => game.toMap()).toList();
        await _cacheService.set(cacheKey, gamesMaps, duration: _fullSeasonCacheDuration);
        
        debugPrint('✅ ESPN DataSource: Successfully fetched ${games.length} games for 2025 season');
        debugPrint('🎯 ESPN DataSource: First game: ${games.first.awayTeamName} vs ${games.first.homeTeamName} on ${games.first.dateTime}');
        
        LoggingService.info('ESPN DataSource: Fetched ${games.length} games for 2025 season');
        
        return games;
      } else {
        debugPrint('⚠️ ESPN DataSource: No 2025 season games found');
        return [];
      }
    } catch (e) {
      debugPrint('❌ ESPN DataSource Error: $e');
      LoggingService.error('ESPN DataSource error fetching 2025 season: $e');
      return [];
    }
  }

  /// Fetch historical season schedule (2023, 2024) from ESPN API with caching
  /// Returns complete season data including historical scores and game results
  Future<List<GameSchedule>> fetchHistoricalSeasonSchedule(int year, {int limit = 500}) async {
    final cacheKey = 'espn_${year}_season_schedule_$limit';
    
    try {
      debugPrint('🏈 ESPN DataSource: Fetching $year historical season schedule...');
      
      // Check cache first (longer cache for historical data since it doesn't change)
      final cachedGames = await _cacheService.get<List<dynamic>>(cacheKey);
      if (cachedGames != null) {
        debugPrint('📦 ESPN Cache HIT: Found cached $year season schedule');
        return cachedGames.map((e) => GameSchedule.fromMap(e as Map<String, dynamic>)).toList();
      }
      
      // Fetch from ESPN API using the new historical method
      final games = await _espnService.getScheduleForYear(year, limit: limit);
      
      if (games.isNotEmpty) {
        // Cache the results (longer cache for historical data)
        final gamesMaps = games.map((game) => game.toMap()).toList();
        await _cacheService.set(cacheKey, gamesMaps, duration: const Duration(hours: 24));
        
        // Count completed games with scores
        final completedGames = games.where((game) => 
          game.awayScore != null && game.homeScore != null).length;
        
        debugPrint('✅ ESPN DataSource: Successfully fetched ${games.length} games for $year season');
        debugPrint('🎯 ESPN DataSource: $completedGames games have historical scores');
        if (games.isNotEmpty) {
          debugPrint('🎯 ESPN DataSource: First game: ${games.first.awayTeamName} vs ${games.first.homeTeamName} on ${games.first.dateTime}');
          if (games.first.awayScore != null && games.first.homeScore != null) {
            debugPrint('🎯 ESPN DataSource: Score: ${games.first.awayTeamName} ${games.first.awayScore} - ${games.first.homeScore} ${games.first.homeTeamName}');
          }
        }
        
        LoggingService.info('ESPN DataSource: Fetched ${games.length} games for $year season ($completedGames with scores)');
        
        return games;
      } else {
        debugPrint('⚠️ ESPN DataSource: No $year season games found');
        return [];
      }
    } catch (e) {
      debugPrint('❌ ESPN DataSource Error: $e');
      LoggingService.error('ESPN DataSource error fetching $year season: $e');
      return [];
    }
  }

  /// Clear ESPN-related cache
  Future<void> clearCache() async {
    try {
      // Clear all ESPN-related cache keys
      final keysToRemove = [
        'espn_upcoming_games_10',
        'espn_upcoming_games_20',
        'espn_upcoming_games_50',
        'espn_2025_season_schedule_100',
        'espn_2025_season_schedule_200',
        'espn_2025_season_schedule_500',
      ];
      
      for (final key in keysToRemove) {
        await _cacheService.remove(key);
      }
      
      debugPrint('🧹 ESPN DataSource: Cache cleared successfully');
      LoggingService.info('ESPN DataSource: Cache cleared');
    } catch (e) {
      debugPrint('❌ ESPN DataSource: Error clearing cache: $e');
      LoggingService.error('ESPN DataSource: Error clearing cache: $e');
    }
  }

  /// Test ESPN API connectivity
  Future<bool> testConnection() async {
    try {
      debugPrint('🔍 ESPN DataSource: Testing API connectivity...');
      
      final testGames = await _espnService.getCurrentGames();
      
      if (testGames.isNotEmpty) {
        debugPrint('✅ ESPN DataSource: API connection successful');
        return true;
      } else {
        debugPrint('⚠️ ESPN DataSource: API connected but no games found');
        return false;
      }
    } catch (e) {
      debugPrint('❌ ESPN DataSource: API connection failed: $e');
      return false;
    }
  }

  /// Get filtered games by team names
  Future<List<GameSchedule>> getGamesByTeams(List<String> teamNames, {int limit = 50}) async {
    try {
      debugPrint('🏈 ESPN DataSource: Filtering games by teams: $teamNames');
      
      final allGames = await fetch2025SeasonSchedule(limit: limit);
      
      final filteredGames = allGames.where((game) {
        return teamNames.any((teamName) => 
          game.homeTeamName.toLowerCase().contains(teamName.toLowerCase()) ||
          game.awayTeamName.toLowerCase().contains(teamName.toLowerCase())
        );
      }).toList();
      
      debugPrint('🎯 ESPN DataSource: Found ${filteredGames.length} games for specified teams');
      
      return filteredGames;
    } catch (e) {
      debugPrint('❌ ESPN DataSource Error filtering by teams: $e');
      return [];
    }
  }

  /// Get games for a specific date range
  Future<List<GameSchedule>> getGamesInDateRange(DateTime startDate, DateTime endDate, {int limit = 100}) async {
    try {
      debugPrint('🏈 ESPN DataSource: Fetching games between ${startDate.toIso8601String()} and ${endDate.toIso8601String()}');
      
      final allGames = await fetch2025SeasonSchedule(limit: limit);
      
      final filteredGames = allGames.where((game) {
        final gameDate = game.dateTime;
        if (gameDate == null) return false;
        return gameDate.isAfter(startDate) && gameDate.isBefore(endDate);
      }).toList();
      
      debugPrint('🎯 ESPN DataSource: Found ${filteredGames.length} games in date range');
      
      return filteredGames;
    } catch (e) {
      debugPrint('❌ ESPN DataSource Error filtering by date range: $e');
      return [];
    }
  }
} 
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
      // Debug output removed
      
      // Check cache first
      final cachedGames = await _cacheService.get<List<dynamic>>(cacheKey);
      if (cachedGames != null) {
        // Debug output removed
        return cachedGames.map((e) => GameSchedule.fromMap(e as Map<String, dynamic>)).toList();
      }
      
      // Fetch from ESPN API
      final games = await _espnService.getUpcomingGames(limit: limit);
      
      if (games.isNotEmpty) {
        // Cache the results
        final gamesMaps = games.map((game) => game.toMap()).toList();
        await _cacheService.set(cacheKey, gamesMaps, duration: _upcomingGamesCacheDuration);
        
        // Debug output removed
        LoggingService.info('ESPN DataSource: Fetched ${games.length} upcoming games');
        
        return games;
      } else {
        // Debug output removed
        return [];
      }
    } catch (e) {
      // Debug output removed
      LoggingService.error('ESPN DataSource error fetching upcoming games: $e');
      return [];
    }
  }

  /// Fetch 2025 full season schedule from ESPN API with caching
  Future<List<GameSchedule>> fetch2025SeasonSchedule({int limit = 100}) async {
    final cacheKey = 'espn_2025_season_schedule_$limit';
    
    try {
      // Debug output removed
      
      // Check cache first (longer cache for full season)
      final cachedGames = await _cacheService.get<List<dynamic>>(cacheKey);
      if (cachedGames != null) {
        // Debug output removed
        return cachedGames.map((e) => GameSchedule.fromMap(e as Map<String, dynamic>)).toList();
      }
      
      // Fetch from ESPN API
      final games = await _espnService.get2025Schedule(limit: limit);
      
      if (games.isNotEmpty) {
        // Cache the results
        final gamesMaps = games.map((game) => game.toMap()).toList();
        await _cacheService.set(cacheKey, gamesMaps, duration: _fullSeasonCacheDuration);
        
        // Debug output removed
        // Debug output removed
        
        LoggingService.info('ESPN DataSource: Fetched ${games.length} games for 2025 season');
        
        return games;
      } else {
        // Debug output removed
        return [];
      }
    } catch (e) {
      // Debug output removed
      LoggingService.error('ESPN DataSource error fetching 2025 season: $e');
      return [];
    }
  }

  /// Fetch historical season schedule (2023, 2024) from ESPN API with caching
  /// Returns complete season data including historical scores and game results
  Future<List<GameSchedule>> fetchHistoricalSeasonSchedule(int year, {int limit = 500}) async {
    final cacheKey = 'espn_${year}_season_schedule_$limit';
    
    try {
      // Debug output removed
      
      // Check cache first (longer cache for historical data since it doesn't change)
      final cachedGames = await _cacheService.get<List<dynamic>>(cacheKey);
      if (cachedGames != null) {
        // Debug output removed
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
        
        // Debug output removed
        // Debug output removed
        if (games.isNotEmpty) {
          // Debug output removed
          if (games.first.awayScore != null && games.first.homeScore != null) {
            // Debug output removed
          }
        }
        
        LoggingService.info('ESPN DataSource: Fetched ${games.length} games for $year season ($completedGames with scores)');
        
        return games;
      } else {
        // Debug output removed
        return [];
      }
    } catch (e) {
      // Debug output removed
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
      
      // Debug output removed
      LoggingService.info('ESPN DataSource: Cache cleared');
    } catch (e) {
      // Debug output removed
      LoggingService.error('ESPN DataSource: Error clearing cache: $e');
    }
  }

  /// Test ESPN API connectivity
  Future<bool> testConnection() async {
    try {
      // Debug output removed
      
      final testGames = await _espnService.getCurrentGames();
      
      if (testGames.isNotEmpty) {
        // Debug output removed
        return true;
      } else {
        // Debug output removed
        return false;
      }
    } catch (e) {
      // Debug output removed
      return false;
    }
  }

  /// Get filtered games by team names
  Future<List<GameSchedule>> getGamesByTeams(List<String> teamNames, {int limit = 50}) async {
    try {
      // Debug output removed
      
      final allGames = await fetch2025SeasonSchedule(limit: limit);
      
      final filteredGames = allGames.where((game) {
        return teamNames.any((teamName) => 
          game.homeTeamName.toLowerCase().contains(teamName.toLowerCase()) ||
          game.awayTeamName.toLowerCase().contains(teamName.toLowerCase())
        );
      }).toList();
      
      // Debug output removed
      
      return filteredGames;
    } catch (e) {
      // Debug output removed
      return [];
    }
  }

  /// Get games for a specific date range
  Future<List<GameSchedule>> getGamesInDateRange(DateTime startDate, DateTime endDate, {int limit = 100}) async {
    try {
      // Debug output removed
      
      final allGames = await fetch2025SeasonSchedule(limit: limit);
      
      final filteredGames = allGames.where((game) {
        final gameDate = game.dateTime;
        if (gameDate == null) return false;
        return gameDate.isAfter(startDate) && gameDate.isBefore(endDate);
      }).toList();
      
      // Debug output removed
      
      return filteredGames;
    } catch (e) {
      // Debug output removed
      return [];
    }
  }
} 
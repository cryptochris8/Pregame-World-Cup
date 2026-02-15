import 'package:pregame_world_cup/core/services/cache_service.dart';
import 'package:pregame_world_cup/core/services/logging_service.dart';
import 'package:pregame_world_cup/features/schedule/domain/entities/game_schedule.dart';
import 'package:pregame_world_cup/services/espn_service.dart';

/// ESPN Schedule Data Source for World Cup 2026
/// Wraps ESPNService (soccer endpoints) for supplemental match data and analysis.
/// Primary World Cup 2026 match data comes from SportsData.io and Firebase.
/// This data source provides ESPN soccer data for AI analysis and historical context.
class ESPNScheduleDataSource {
  final ESPNService _espnService;
  final CacheService _cacheService;

  // Cache duration for different types of data
  static const Duration _upcomingGamesCacheDuration = Duration(minutes: 10);
  static const Duration _fullScheduleCacheDuration = Duration(hours: 6);

  ESPNScheduleDataSource({
    ESPNService? espnService,
    CacheService? cacheService,
  }) : _espnService = espnService ?? ESPNService(),
       _cacheService = cacheService ?? CacheService.instance;

  /// Fetch upcoming World Cup matches from ESPN Soccer API with caching
  Future<List<GameSchedule>> fetchUpcomingGames({int limit = 10}) async {
    final cacheKey = 'espn_upcoming_games_$limit';

    try {
      // Check cache first
      final cachedGames = await _cacheService.get<List<dynamic>>(cacheKey);
      if (cachedGames != null) {
        return cachedGames.map((e) => GameSchedule.fromMap(e as Map<String, dynamic>)).toList();
      }

      // Fetch from ESPN Soccer API
      final games = await _espnService.getUpcomingGames(limit: limit);

      if (games.isNotEmpty) {
        // Cache the results
        final gamesMaps = games.map((game) => game.toMap()).toList();
        await _cacheService.set(cacheKey, gamesMaps, duration: _upcomingGamesCacheDuration);

        LoggingService.info('ESPN DataSource: Fetched ${games.length} upcoming World Cup matches');

        return games;
      } else {
        return [];
      }
    } catch (e) {
      LoggingService.error('ESPN DataSource error fetching upcoming matches: $e');
      return [];
    }
  }

  /// Fetch World Cup 2026 full schedule from ESPN Soccer API with caching
  /// The tournament runs June 11 - July 19, 2026 with 104 matches
  Future<List<GameSchedule>> fetch2025SeasonSchedule({int limit = 100}) async {
    final cacheKey = 'espn_2025_season_schedule_$limit';

    try {
      // Check cache first (longer cache for tournament schedule)
      final cachedGames = await _cacheService.get<List<dynamic>>(cacheKey);
      if (cachedGames != null) {
        return cachedGames.map((e) => GameSchedule.fromMap(e as Map<String, dynamic>)).toList();
      }

      // Fetch from ESPN Soccer API (World Cup 2026 schedule)
      final games = await _espnService.get2025Schedule(limit: limit);

      if (games.isNotEmpty) {
        // Cache the results
        final gamesMaps = games.map((game) => game.toMap()).toList();
        await _cacheService.set(cacheKey, gamesMaps, duration: _fullScheduleCacheDuration);

        LoggingService.info('ESPN DataSource: Fetched ${games.length} World Cup 2026 matches');

        return games;
      } else {
        return [];
      }
    } catch (e) {
      LoggingService.error('ESPN DataSource error fetching World Cup schedule: $e');
      return [];
    }
  }

  /// Fetch historical World Cup schedule from ESPN Soccer API with caching
  /// Supports previous World Cup years (2018, 2022) and qualifiers (2025)
  /// Returns complete tournament data including scores and match results
  Future<List<GameSchedule>> fetchHistoricalSeasonSchedule(int year, {int limit = 500}) async {
    final cacheKey = 'espn_${year}_season_schedule_$limit';

    try {
      // Check cache first (longer cache for historical data since it doesn't change)
      final cachedGames = await _cacheService.get<List<dynamic>>(cacheKey);
      if (cachedGames != null) {
        return cachedGames.map((e) => GameSchedule.fromMap(e as Map<String, dynamic>)).toList();
      }

      // Fetch from ESPN Soccer API using historical World Cup data
      final games = await _espnService.getScheduleForYear(year, limit: limit);

      if (games.isNotEmpty) {
        // Cache the results (longer cache for historical data)
        final gamesMaps = games.map((game) => game.toMap()).toList();
        await _cacheService.set(cacheKey, gamesMaps, duration: const Duration(hours: 24));

        // Count completed matches with scores
        final completedGames = games.where((game) =>
          game.awayScore != null && game.homeScore != null).length;

        LoggingService.info('ESPN DataSource: Fetched ${games.length} matches for $year World Cup ($completedGames with scores)');

        return games;
      } else {
        return [];
      }
    } catch (e) {
      LoggingService.error('ESPN DataSource error fetching $year World Cup data: $e');
      return [];
    }
  }

  /// Clear ESPN soccer data cache
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

      LoggingService.info('ESPN DataSource: Cache cleared');
    } catch (e) {
      LoggingService.error('ESPN DataSource: Error clearing cache: $e');
    }
  }

  /// Test ESPN Soccer API connectivity
  Future<bool> testConnection() async {
    try {
      final testGames = await _espnService.getCurrentGames();

      if (testGames.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Get filtered matches by team/country names
  Future<List<GameSchedule>> getGamesByTeams(List<String> teamNames, {int limit = 50}) async {
    try {
      final allGames = await fetch2025SeasonSchedule(limit: limit);

      final filteredGames = allGames.where((game) {
        return teamNames.any((teamName) =>
          game.homeTeamName.toLowerCase().contains(teamName.toLowerCase()) ||
          game.awayTeamName.toLowerCase().contains(teamName.toLowerCase())
        );
      }).toList();

      return filteredGames;
    } catch (e) {
      return [];
    }
  }

  /// Get matches for a specific date range
  Future<List<GameSchedule>> getGamesInDateRange(DateTime startDate, DateTime endDate, {int limit = 100}) async {
    try {
      final allGames = await fetch2025SeasonSchedule(limit: limit);

      final filteredGames = allGames.where((game) {
        final gameDate = game.dateTime;
        if (gameDate == null) return false;
        return gameDate.isAfter(startDate) && gameDate.isBefore(endDate);
      }).toList();

      return filteredGames;
    } catch (e) {
      return [];
    }
  }
}

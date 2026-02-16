import 'package:dio/dio.dart';
import 'package:pregame_world_cup/core/entities/game_intelligence.dart';
import 'package:pregame_world_cup/features/schedule/domain/entities/game_schedule.dart';
import 'package:hive/hive.dart';
import 'espn_historical_service.dart';
import 'espn_schedule_parser.dart';
import 'espn_analysis_service.dart';
import 'espn_team_matcher.dart';

/// ESPN Soccer service for World Cup 2026 game intelligence and venue recommendations.
/// Uses ESPN's soccer API endpoints for FIFA World Cup data.
/// Primary match data comes from SportsData.io and Firebase;
/// this service provides supplemental intelligence and analysis.
///
/// This is a facade that delegates to focused sub-services:
/// - [ESPNScheduleParser] for parsing ESPN event data into GameSchedule objects
/// - [ESPNAnalysisService] for match analysis, crowd factors, and intelligence
/// - [ESPNTeamMatcher] for team name matching and rivalry detection
/// - [ESPNHistoricalService] for World Cup historical context
class ESPNService {
  // ESPN soccer API base URL
  // League slugs: fifa.world (World Cup), fifa.worldq (qualifiers),
  //   usa.1 (MLS), eng.1 (EPL), etc.
  static const String _baseUrl = 'https://site.api.espn.com/apis/site/v2/sports/soccer';

  /// ESPN league slug for FIFA World Cup 2026
  static const String _worldCupLeague = 'fifa.world';

  /// ESPN league slug for FIFA World Cup Qualifiers
  static const String _worldCupQualifiersLeague = 'fifa.worldq';

  final Dio _dio;
  Box<GameIntelligence>? _gameIntelligenceBox;
  late ESPNHistoricalService _historicalService;
  late ESPNScheduleParser _scheduleParser;
  late ESPNAnalysisService _analysisService;
  late ESPNTeamMatcher _teamMatcher;

  ESPNService({Dio? dio}) : _dio = dio ?? Dio() {
    _historicalService = ESPNHistoricalService();
    _scheduleParser = ESPNScheduleParser();
    _teamMatcher = ESPNTeamMatcher();
    _analysisService = ESPNAnalysisService(
      teamMatcher: _teamMatcher,
    );
  }

  Future<void> _initializeService() async {
    if (_gameIntelligenceBox != null) return; // Already initialized

    try {
      _gameIntelligenceBox = await Hive.openBox<GameIntelligence>('game_intelligence');
    } catch (e) {
      // If Hive isn't ready, we'll try again later
      _gameIntelligenceBox = null;
    }
  }

  /// Get enhanced game intelligence with crowd factors, venue recommendations, and historical context
  Future<GameIntelligence?> getGameIntelligence(String gameId) async {
    try {
      // Ensure service is initialized
      await _initializeService();

      // Check cache first (valid for 2 hours) - but only if Hive is available
      if (_gameIntelligenceBox != null) {
        final cached = _gameIntelligenceBox!.get(gameId);
        if (cached != null &&
            DateTime.now().difference(cached.lastUpdated).inHours < 2) {
          return cached;
        }
      }

      // Fetch fresh data from ESPN soccer API
      final gameData = await _fetchESPNGameData(gameId);
      if (gameData == null) return null;

      // Analyze and create intelligence (delegated to analysis service)
      final intelligence = await _analysisService.analyzeGameData(gameData);

      // Cache the result (if Hive is available)
      if (_gameIntelligenceBox != null) {
        await _gameIntelligenceBox!.put(gameId, intelligence);
      }

      return intelligence;
    } catch (e) {
      return null;
    }
  }

  /// Fetch raw game data from ESPN Soccer API.
  /// Uses the FIFA World Cup league endpoint for match summaries.
  Future<Map<String, dynamic>?> _fetchESPNGameData(String gameId) async {
    try {
      // ESPN soccer match summary endpoint
      final response = await _dio.get(
        '$_baseUrl/$_worldCupLeague/summary',
        queryParameters: {
          'event': gameId,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Fetch current World Cup matches from ESPN soccer scoreboard
  Future<List<Map<String, dynamic>>> getCurrentGames() async {
    try {
      final response = await _dio.get(
        '$_baseUrl/$_worldCupLeague/scoreboard',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final events = data['events'] as List? ?? [];
        return events.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Fetch World Cup 2026 schedule from ESPN Soccer API.
  /// The tournament runs June 11 - July 19, 2026.
  Future<List<GameSchedule>> get2025Schedule({int limit = 100}) async {
    try {
      final scheduleGames = <GameSchedule>[];

      // World Cup 2026 dates: June 11 - July 19, 2026
      final startDate = DateTime(2026, 6, 1);
      final endDate = DateTime(2026, 7, 31);

      final startDateStr = _scheduleParser.formatDateForESPN(startDate);
      final endDateStr = _scheduleParser.formatDateForESPN(endDate);

      final response = await _dio.get(
        '$_baseUrl/$_worldCupLeague/scoreboard',
        queryParameters: {
          'dates': '$startDateStr-$endDateStr',
          'limit': limit.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final events = data['events'] as List? ?? [];

        for (final event in events) {
          try {
            final gameSchedule = _scheduleParser.parseESPNEventToGameSchedule(event);
            if (gameSchedule != null) {
              scheduleGames.add(gameSchedule);
            }
          } catch (e) {
            // Skip events that fail to parse
          }
        }

        // Sort by date
        scheduleGames.sort((a, b) {
          final aDate = a.dateTime ?? DateTime(1970);
          final bDate = b.dateTime ?? DateTime(1970);
          return aDate.compareTo(bDate);
        });

        return scheduleGames.take(limit).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  /// Get upcoming World Cup matches from ESPN Soccer API (next 2 weeks)
  Future<List<GameSchedule>> getUpcomingGames({int limit = 10}) async {
    try {
      final now = DateTime.now();
      final twoWeeksFromNow = now.add(const Duration(days: 14));

      final startDateStr = _scheduleParser.formatDateForESPN(now);
      final endDateStr = _scheduleParser.formatDateForESPN(twoWeeksFromNow);

      final response = await _dio.get(
        '$_baseUrl/$_worldCupLeague/scoreboard',
        queryParameters: {
          'dates': '$startDateStr-$endDateStr',
          'limit': limit.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final events = data['events'] as List? ?? [];

        final upcomingGames = <GameSchedule>[];

        for (final event in events) {
          try {
            final gameSchedule = _scheduleParser.parseESPNEventToGameSchedule(event);
            if (gameSchedule != null) {
              // Only include future games
              final gameTime = gameSchedule.dateTime;
              if (gameTime != null && gameTime.isAfter(now)) {
                upcomingGames.add(gameSchedule);
              }
            }
          } catch (e) {
            // Skip events that fail to parse
          }
        }

        // Sort by date and limit results
        upcomingGames.sort((a, b) {
          final aDate = a.dateTime ?? DateTime(1970);
          final bDate = b.dateTime ?? DateTime(1970);
          return aDate.compareTo(bDate);
        });

        return upcomingGames.take(limit).toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get World Cup schedule for a specific year from ESPN Soccer API.
  /// Supports 2022 (Qatar), 2018 (Russia), and 2026 (USA/Mexico/Canada).
  Future<List<GameSchedule>> getScheduleForYear(int year, {int limit = 2000}) async {
    try {
      DateTime startDate;
      DateTime endDate;
      String league = _worldCupLeague;

      if (year == 2022) {
        // Qatar 2022: Nov 21 - Dec 18
        startDate = DateTime(2022, 11, 1);
        endDate = DateTime(2022, 12, 31);
      } else if (year == 2018) {
        // Russia 2018: June 14 - July 15
        startDate = DateTime(2018, 6, 1);
        endDate = DateTime(2018, 7, 31);
      } else if (year == 2026) {
        // USA/Mexico/Canada 2026: June 11 - July 19
        startDate = DateTime(2026, 6, 1);
        endDate = DateTime(2026, 7, 31);
      } else if (year == 2025) {
        // 2025 = World Cup Qualifiers
        startDate = DateTime(2025, 1, 1);
        endDate = DateTime(2025, 12, 31);
        league = _worldCupQualifiersLeague;
      } else {
        return [];
      }

      final startDateStr = _scheduleParser.formatDateForESPN(startDate);
      final endDateStr = _scheduleParser.formatDateForESPN(endDate);

      final response = await _dio.get(
        '$_baseUrl/$league/scoreboard',
        queryParameters: {
          'dates': '$startDateStr-$endDateStr',
          'limit': limit.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final events = data['events'] as List? ?? [];

        final games = <GameSchedule>[];
        for (final event in events) {
          final game = _scheduleParser.parseESPNEventToGameScheduleWithYear(event, year);
          if (game != null) {
            games.add(game);
          }
        }

        // Sort by date
        games.sort((a, b) {
          if (a.dateTime == null && b.dateTime == null) return 0;
          if (a.dateTime == null) return 1;
          if (b.dateTime == null) return -1;
          return a.dateTime!.compareTo(b.dateTime!);
        });

        return games;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  /// Get multiple games intelligence for venue dashboard
  Future<List<GameIntelligence>> getUpcomingGamesIntelligence(List<String> gameIds) async {
    final List<GameIntelligence> intelligenceList = [];

    // Process games in parallel for better performance
    final futures = gameIds.map((gameId) => getGameIntelligence(gameId));
    final results = await Future.wait(futures);

    for (final intelligence in results) {
      if (intelligence != null) {
        intelligenceList.add(intelligence);
      }
    }

    // Sort by crowd factor (highest impact games first)
    intelligenceList.sort((a, b) => b.crowdFactor.compareTo(a.crowdFactor));

    return intelligenceList;
  }

  /// Clear cached data (useful for testing or manual refresh)
  Future<void> clearCache() async {
    if (_gameIntelligenceBox != null) {
      await _gameIntelligenceBox!.clear();
    }
  }

  /// Get cache statistics for debugging
  Map<String, dynamic> getCacheStats() {
    if (_gameIntelligenceBox == null) {
      return {
        'cached_games': 0,
        'cache_size_kb': 0,
        'status': 'not_initialized',
      };
    }

    return {
      'cached_games': _gameIntelligenceBox!.length,
      'cache_size_kb': _gameIntelligenceBox!.toMap().toString().length / 1024,
      'status': 'initialized',
    };
  }

  /// Get comprehensive game intelligence including historical matchup data
  Future<Map<String, dynamic>?> getGameIntelligenceWithHistory(String gameId) async {
    try {
      // Get basic game intelligence
      final gameIntelligence = await getGameIntelligence(gameId);
      if (gameIntelligence == null) return null;

      // Get World Cup historical context
      final historicalContext = await _historicalService.getMatchupHistory(
        gameIntelligence.homeTeam,
        gameIntelligence.awayTeam
      );

      // Generate enhanced game summary with historical context
      final gameHistorySummary = _historicalService.generateGameSummaryWithHistory(
        gameIntelligence.homeTeam,
        gameIntelligence.awayTeam,
        gameIntelligence.homeTeamRank,
        gameIntelligence.awayTeamRank,
      );

      // Get venue-specific historical insights
      final venueHistoricalInsights = _historicalService.generateVenueHistoricalInsights(
        gameIntelligence.homeTeam,
        gameIntelligence.awayTeam,
      );

      return {
        'game_intelligence': gameIntelligence,
        'historical_context': historicalContext,
        'game_summary_with_history': gameHistorySummary,
        'venue_historical_insights': venueHistoricalInsights,
        'ai_generated_content': {
          'social_media_posts': venueHistoricalInsights['social_media_content'] ?? [],
          'marketing_hooks': venueHistoricalInsights['marketing_hooks'] ?? [],
          'preparation_tips': venueHistoricalInsights['venue_preparation']?['preparation_tips'] ?? [],
        }
      };
    } catch (e) {
      return null;
    }
  }

  /// Find ESPN game ID by matching team names and date
  Future<String?> findESPNGameId({
    required String homeTeam,
    required String awayTeam,
    DateTime? gameDate,
  }) async {
    try {
      final currentGames = await getCurrentGames();

      for (final game in currentGames) {
        final competitions = game['competitions'] as List? ?? [];

        if (competitions.isNotEmpty) {
          final competitors = competitions[0]['competitors'] as List? ?? [];

          String espnHomeTeam = '';
          String espnAwayTeam = '';

          for (var team in competitors) {
            final teamData = team['team'] ?? {};
            final isHome = team['homeAway'] == 'home';
            final teamName = teamData['displayName'] ?? '';

            if (isHome) {
              espnHomeTeam = teamName;
            } else {
              espnAwayTeam = teamName;
            }
          }

          // Check if teams match (case insensitive, partial matching)
          if (_teamMatcher.teamsMatch(homeTeam, espnHomeTeam) && _teamMatcher.teamsMatch(awayTeam, espnAwayTeam)) {
            // If date is provided, check if it's close (within 1 day)
            if (gameDate != null) {
              final espnDate = DateTime.tryParse(game['date'] ?? '');
              if (espnDate != null) {
                final difference = gameDate.difference(espnDate).inDays.abs();
                if (difference <= 1) {
                  return game['id']?.toString();
                }
              }
            } else {
              // No date provided, just match by teams
              return game['id']?.toString();
            }
          }
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get opening round matches with full historical context
  Future<List<Map<String, dynamic>>> getWeek1GamesWithHistory() async {
    try {
      final games = await getCurrentGames();
      final enhancedGames = <Map<String, dynamic>>[];

      for (final game in games.take(10)) { // Limit to first 10 for performance
        final gameId = game['id']?.toString();
        if (gameId != null) {
          final gameWithHistory = await getGameIntelligenceWithHistory(gameId);
          if (gameWithHistory != null) {
            enhancedGames.add({
              'raw_game_data': game,
              'enhanced_intelligence': gameWithHistory,
            });
          }
        }
      }

      return enhancedGames;
    } catch (e) {
      return [];
    }
  }
}

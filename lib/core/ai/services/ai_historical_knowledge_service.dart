import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../features/schedule/domain/entities/game_schedule.dart';
import '../../../features/schedule/data/datasources/ncaa_schedule_datasource.dart';
import '../../services/cache_service.dart';
import '../../services/logging_service.dart';
import '../../../injection_container.dart';
import '../../../config/api_keys.dart';

/// AI Historical Knowledge Service
/// 
/// This service builds a comprehensive knowledge base of historical college football
/// data for AI analysis. It uses the NCAA Schedule DataSource which intelligently routes:
/// - ESPN API for 2025 current season only (live schedules/scores)
/// - SportsData.io for ALL historical seasons (2020-2024) with complete game data
/// This ensures comprehensive AI predictions with complete historical context from SportsData.io.
class AIHistoricalKnowledgeService {
  static AIHistoricalKnowledgeService? _instance;
  static AIHistoricalKnowledgeService get instance => _instance ??= AIHistoricalKnowledgeService._();
  
  AIHistoricalKnowledgeService._();
  
  final NcaaScheduleDataSource _ncaaDataSource = sl<NcaaScheduleDataSource>();
  final CacheService _cacheService = CacheService.instance;
  final Dio _dio = Dio();
  
  // SportsData.io configuration
  static const String _sportsDataBaseUrl = 'https://api.sportsdata.io/v3/cfb';
  
  // Historical seasons: SportsData.io for 2022-2024, ESPN for 2025
  static const List<int> _sportsDataSeasons = [2022, 2023, 2024];
  static const List<int> _espnSeasons = [2025];
  static const List<int> _allHistoricalSeasons = [2022, 2023, 2024, 2025];
  
  // Cache duration for historical data (never expires since historical data doesn't change)
  static const Duration _historicalCacheDuration = Duration(days: 365);
  
  /// Initialize the AI knowledge base by fetching all historical seasons
  /// This should be called during app startup in the background
  Future<void> initializeKnowledgeBase() async {
    try {
      debugPrint('🧠 AI KNOWLEDGE: Starting hybrid historical data initialization...');
      debugPrint('🧠 AI KNOWLEDGE: SportsData.io seasons: $_sportsDataSeasons');
      debugPrint('🧠 AI KNOWLEDGE: ESPN seasons: $_espnSeasons');
      LoggingService.info('AI Knowledge Base initialization started (hybrid approach)', tag: 'AIKnowledge');
      
      // Check if we already have all seasons cached
      final cachedSeasons = await _getCachedSeasons();
      final missingSeasons = _allHistoricalSeasons.where((season) => !cachedSeasons.contains(season)).toList();
      
      if (missingSeasons.isEmpty) {
        debugPrint('🧠 AI KNOWLEDGE: All historical seasons already cached');
        LoggingService.info('AI Knowledge Base: All seasons cached', tag: 'AIKnowledge');
        return;
      }
      
      debugPrint('🧠 AI KNOWLEDGE: Need to fetch ${missingSeasons.length} seasons: $missingSeasons');
      
      // Fetch missing seasons using appropriate data source
      final futures = missingSeasons.map((season) => _fetchAndCacheSeason(season));
      await Future.wait(futures);
      
      // Update the cached seasons list
      await _updateCachedSeasonsList();
      
      debugPrint('🧠 AI KNOWLEDGE: Hybrid historical data initialization complete!');
      LoggingService.info('AI Knowledge Base initialization complete (hybrid)', tag: 'AIKnowledge');
      
    } catch (e) {
      debugPrint('🧠 AI KNOWLEDGE ERROR: Failed to initialize knowledge base: $e');
      LoggingService.error('AI Knowledge Base initialization failed: $e', tag: 'AIKnowledge');
    }
  }
  
  /// Fetch and cache a specific season's data using the appropriate data source
  Future<void> _fetchAndCacheSeason(int season) async {
    try {
      debugPrint('🧠 AI KNOWLEDGE: Fetching $season season data...');
      
      // Use NCAA datasource which properly routes:
      // - ESPN for 2025 current season
      // - SportsData.io for historical seasons (2020-2024)
      final games = await _ncaaDataSource.fetchFullSeasonSchedule(season);
      
      if (games.isNotEmpty) {
        // Cache the games data
        final cacheKey = 'ai_knowledge_season_$season';
        final gamesData = games.map((game) => game.toMap()).toList();
        
        await _cacheService.set(cacheKey, gamesData, duration: _historicalCacheDuration);
        
        debugPrint('🧠 AI KNOWLEDGE: Cached ${games.length} games for $season season');
        LoggingService.info('AI Knowledge: Cached ${games.length} games for $season', tag: 'AIKnowledge');
        
        // Debug: Show sample of teams in the data
        final uniqueTeams = <String>{};
        for (final game in games) {
          uniqueTeams.add(game.homeTeamName);
          uniqueTeams.add(game.awayTeamName);
        }
        debugPrint('🧠 AI KNOWLEDGE: Found ${uniqueTeams.length} unique teams in $season data');
        
        // Check specifically for Fresno State
        final fresnoGames = games.where((game) => 
          game.homeTeamName.contains('Fresno') || game.awayTeamName.contains('Fresno')
        ).toList();
        debugPrint('🧠 AI KNOWLEDGE: Fresno State has ${fresnoGames.length} games in $season data');
        
        // Also create season statistics for faster AI access
        await _createSeasonStatistics(season, games);
        
      } else {
        debugPrint('🧠 AI KNOWLEDGE WARNING: No games found for $season season');
      }
      
    } catch (e) {
      debugPrint('🧠 AI KNOWLEDGE ERROR: Failed to fetch $season season: $e');
      LoggingService.error('Failed to fetch $season season: $e', tag: 'AIKnowledge');
    }
  }
  
    /// Fetch season data from SportsData.io API
  Future<List<GameSchedule>> _fetchSportsDataSeason(int season) async {
    try {
      if (ApiKeys.sportsDataIo.isEmpty) {
        debugPrint('🧠 AI KNOWLEDGE ERROR: SportsData.io API key not available');
        return [];
      }

      // Debug: Show what API key we're actually using
      final keyPreview = ApiKeys.sportsDataIo.length > 10 
          ? '${ApiKeys.sportsDataIo.substring(0, 10)}...' 
          : ApiKeys.sportsDataIo;
      debugPrint('🔑 AI KNOWLEDGE DEBUG: Using SportsData API key: $keyPreview (${ApiKeys.sportsDataIo.length} chars total)');

      final url = '$_sportsDataBaseUrl/scores/json/Games/$season';
      debugPrint('🧠 AI KNOWLEDGE: Making SportsData.io API call to $url');
      
      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'Ocp-Apim-Subscription-Key': ApiKeys.sportsDataIo,
          },
        ),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> gameList = response.data;
        debugPrint('🧠 AI KNOWLEDGE: SportsData.io returned ${gameList.length} games for $season');
        
        final games = <GameSchedule>[];
        for (final gameJson in gameList) {
          if (gameJson is Map<String, dynamic>) {
            try {
              final game = GameSchedule.fromSportsDataIo(gameJson);
              games.add(game);
            } catch (parseError) {
              debugPrint('🧠 AI KNOWLEDGE: Error parsing SportsData.io game: $parseError');
            }
          }
        }
        
        debugPrint('🧠 AI KNOWLEDGE: Successfully parsed ${games.length} games from SportsData.io');
        return games;
        
      } else {
        debugPrint('🧠 AI KNOWLEDGE ERROR: SportsData.io API returned status ${response.statusCode}');
        return [];
      }
      
    } catch (e) {
      debugPrint('🧠 AI KNOWLEDGE ERROR: SportsData.io API call failed: $e');
      return [];
    }
  }
  
  /// Create and cache season statistics for faster AI analysis
  Future<void> _createSeasonStatistics(int season, List<GameSchedule> games) async {
    try {
      final stats = <String, dynamic>{
        'season': season,
        'totalGames': games.length,
        'completedGames': games.where((g) => g.awayScore != null && g.homeScore != null).length,
        'teamRecords': <String, Map<String, int>>{},
        'headToHeadRecords': <String, Map<String, dynamic>>{},
        'conferenceStats': <String, dynamic>{},
        'bowlGames': games.where((g) => g.week != null && g.week! >= 15).length,
        'playoffGames': games.where((g) => g.week != null && g.week! >= 16).length,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
      
      // Calculate team records
      for (final game in games) {
        if (game.awayScore != null && game.homeScore != null) {
          _updateTeamRecord(stats['teamRecords'], game.awayTeamName, game.homeTeamName, game.awayScore!, game.homeScore!);
          _updateHeadToHeadRecord(stats['headToHeadRecords'], game.awayTeamName, game.homeTeamName, game.awayScore!, game.homeScore!);
        }
      }
      
      // Cache the statistics
      final statsKey = 'ai_knowledge_stats_$season';
      await _cacheService.set(statsKey, stats, duration: _historicalCacheDuration);
      
      debugPrint('🧠 AI KNOWLEDGE: Created statistics for $season season');
      
    } catch (e) {
      debugPrint('🧠 AI KNOWLEDGE ERROR: Failed to create stats for $season: $e');
    }
  }
  
  /// Update team record in statistics
  void _updateTeamRecord(Map<String, dynamic> teamRecords, String team1, String team2, int score1, int score2) {
    // Update team1 record
    teamRecords[team1] ??= {'wins': 0, 'losses': 0, 'pointsFor': 0, 'pointsAgainst': 0};
    teamRecords[team1]['pointsFor'] += score1;
    teamRecords[team1]['pointsAgainst'] += score2;
    if (score1 > score2) {
      teamRecords[team1]['wins']++;
    } else {
      teamRecords[team1]['losses']++;
    }
    
    // Update team2 record
    teamRecords[team2] ??= {'wins': 0, 'losses': 0, 'pointsFor': 0, 'pointsAgainst': 0};
    teamRecords[team2]['pointsFor'] += score2;
    teamRecords[team2]['pointsAgainst'] += score1;
    if (score2 > score1) {
      teamRecords[team2]['wins']++;
    } else {
      teamRecords[team2]['losses']++;
    }
  }
  
  /// Update head-to-head record between two teams
  void _updateHeadToHeadRecord(Map<String, dynamic> headToHeadRecords, String team1, String team2, int score1, int score2) {
    final matchupKey = _createMatchupKey(team1, team2);
    
    headToHeadRecords[matchupKey] ??= {
      'team1': team1,
      'team2': team2,
      'team1Wins': 0,
      'team2Wins': 0,
      'totalGames': 0,
      'averageScore1': 0.0,
      'averageScore2': 0.0,
      'lastMeeting': null,
    };
    
    final record = headToHeadRecords[matchupKey];
    record['totalGames']++;
    
    if (score1 > score2) {
      record['team1Wins']++;
    } else {
      record['team2Wins']++;
    }
    
    // Update average scores
    final totalGames = record['totalGames'];
    record['averageScore1'] = ((record['averageScore1'] * (totalGames - 1)) + score1) / totalGames;
    record['averageScore2'] = ((record['averageScore2'] * (totalGames - 1)) + score2) / totalGames;
  }
  
  /// Create a consistent matchup key for two teams
  String _createMatchupKey(String team1, String team2) {
    final teams = [team1, team2]..sort();
    return '${teams[0]}_vs_${teams[1]}';
  }
  
  /// Get list of cached seasons
  Future<List<int>> _getCachedSeasons() async {
    try {
      final cachedList = await _cacheService.get<List<dynamic>>('ai_knowledge_cached_seasons');
      if (cachedList != null) {
        return cachedList.cast<int>();
      }
    } catch (e) {
      debugPrint('🧠 AI KNOWLEDGE: Error getting cached seasons: $e');
    }
    return [];
  }
  
  /// Update the list of cached seasons
  Future<void> _updateCachedSeasonsList() async {
    try {
      await _cacheService.set('ai_knowledge_cached_seasons', _allHistoricalSeasons, duration: _historicalCacheDuration);
    } catch (e) {
      debugPrint('🧠 AI KNOWLEDGE: Error updating cached seasons list: $e');
    }
  }
  
  /// Get historical games for a specific season
  Future<List<GameSchedule>> getHistoricalGames(int season) async {
    try {
      final cacheKey = 'ai_knowledge_season_$season';
      final cachedData = await _cacheService.get<List<dynamic>>(cacheKey);
      
      if (cachedData != null) {
        return cachedData.map((gameData) => GameSchedule.fromMap(gameData as Map<String, dynamic>)).toList();
      }
      
      // If not cached, fetch and cache it
      debugPrint('🧠 AI KNOWLEDGE: Season $season not cached, fetching...');
      await _fetchAndCacheSeason(season);
      
      // Try again after fetching
      final newCachedData = await _cacheService.get<List<dynamic>>(cacheKey);
      if (newCachedData != null) {
        return newCachedData.map((gameData) => GameSchedule.fromMap(gameData as Map<String, dynamic>)).toList();
      }
      
    } catch (e) {
      debugPrint('🧠 AI KNOWLEDGE ERROR: Failed to get historical games for $season: $e');
    }
    
    return [];
  }
  
  /// Get season statistics for AI analysis
  Future<Map<String, dynamic>?> getSeasonStatistics(int season) async {
    try {
      final statsKey = 'ai_knowledge_stats_$season';
      return await _cacheService.get<Map<String, dynamic>>(statsKey);
    } catch (e) {
      debugPrint('🧠 AI KNOWLEDGE ERROR: Failed to get season statistics for $season: $e');
      return null;
    }
  }
  
  /// Get head-to-head historical data between two teams across all seasons
  Future<Map<String, dynamic>?> getHeadToHeadHistory(String team1, String team2) async {
    try {
      final matchupKey = _createMatchupKey(team1, team2);
      final allHistory = <String, dynamic>{
        'team1': team1,
        'team2': team2,
        'allTimeRecord': {'team1Wins': 0, 'team2Wins': 0, 'totalGames': 0},
        'recentForm': <Map<String, dynamic>>[],
        'seasonBreakdown': <int, Map<String, dynamic>>{},
      };
      
      // Aggregate data across all historical seasons
      for (final season in _allHistoricalSeasons) {
        final seasonStats = await getSeasonStatistics(season);
        if (seasonStats != null && seasonStats['headToHeadRecords'] != null) {
          final headToHeadRecords = seasonStats['headToHeadRecords'] as Map<String, dynamic>;
          if (headToHeadRecords.containsKey(matchupKey)) {
            final seasonRecord = headToHeadRecords[matchupKey];
            allHistory['seasonBreakdown'][season] = seasonRecord;
            
            // Add to all-time record
            allHistory['allTimeRecord']['team1Wins'] += seasonRecord['team1Wins'];
            allHistory['allTimeRecord']['team2Wins'] += seasonRecord['team2Wins'];
            allHistory['allTimeRecord']['totalGames'] += seasonRecord['totalGames'];
          }
        }
      }
      
      return allHistory['allTimeRecord']['totalGames'] > 0 ? allHistory : null;
      
    } catch (e) {
      debugPrint('🧠 AI KNOWLEDGE ERROR: Failed to get head-to-head history: $e');
      return null;
    }
  }
  
  /// Get team performance trends across multiple seasons
  Future<Map<String, dynamic>?> getTeamTrends(String teamName) async {
    try {
      final trends = <String, dynamic>{
        'team': teamName,
        'seasonRecords': <int, Map<String, dynamic>>{},
        'overallTrend': 'stable',
        'strengthOfSchedule': <int, double>{},
        'bowlAppearances': 0,
        'championshipAppearances': 0,
      };
      
      for (final season in _allHistoricalSeasons) {
        final seasonStats = await getSeasonStatistics(season);
        if (seasonStats != null && seasonStats['teamRecords'] != null) {
          final teamRecords = seasonStats['teamRecords'] as Map<String, dynamic>;
          if (teamRecords.containsKey(teamName)) {
            trends['seasonRecords'][season] = teamRecords[teamName];
          }
        }
      }
      
      return trends['seasonRecords'].isNotEmpty ? trends : null;
      
    } catch (e) {
      debugPrint('🧠 AI KNOWLEDGE ERROR: Failed to get team trends: $e');
      return null;
    }
  }
  
  /// Check if knowledge base is fully initialized
  Future<bool> isKnowledgeBaseReady() async {
    final cachedSeasons = await _getCachedSeasons();
    return cachedSeasons.length == _allHistoricalSeasons.length;
  }
  
  /// Get knowledge base status for debugging
  Future<Map<String, dynamic>> getKnowledgeBaseStatus() async {
    final cachedSeasons = await _getCachedSeasons();
    final missingSeasons = _allHistoricalSeasons.where((season) => !cachedSeasons.contains(season)).toList();
    
    return {
      'totalSeasons': _allHistoricalSeasons.length,
      'cachedSeasons': cachedSeasons.length,
      'missingSeasons': missingSeasons,
      'isReady': missingSeasons.isEmpty,
      'historicalSeasons': _allHistoricalSeasons,
    };
  }
} 
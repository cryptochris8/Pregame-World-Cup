import '../../../features/schedule/domain/entities/game_schedule.dart';
import '../../services/cache_service.dart';
import '../../services/logging_service.dart';

/// AI Historical Knowledge Service
///
/// This service builds a comprehensive knowledge base of historical sports
/// data for AI analysis. Used for World Cup 2026 match predictions.
class AIHistoricalKnowledgeService {
  static AIHistoricalKnowledgeService? _instance;
  static AIHistoricalKnowledgeService get instance => _instance ??= AIHistoricalKnowledgeService._();

  AIHistoricalKnowledgeService._();

  final CacheService _cacheService = CacheService.instance;

  // Historical seasons for World Cup data
  static const List<int> _allHistoricalSeasons = [2022, 2023, 2024, 2025, 2026];

  // Cache duration for historical data (never expires since historical data doesn't change)
  static const Duration _historicalCacheDuration = Duration(days: 365);
  
  /// Initialize the AI knowledge base
  /// This should be called during app startup in the background
  Future<void> initializeKnowledgeBase() async {
    try {
      LoggingService.info('AI Knowledge Base initialization started', tag: 'AIKnowledge');

      // Check if we already have all seasons cached
      final cachedSeasons = await _getCachedSeasons();
      final missingSeasons = _allHistoricalSeasons.where((season) => !cachedSeasons.contains(season)).toList();

      if (missingSeasons.isEmpty) {
        LoggingService.info('AI Knowledge Base: All seasons cached', tag: 'AIKnowledge');
        return;
      }

      // Update the cached seasons list
      await _updateCachedSeasonsList();

      LoggingService.info('AI Knowledge Base initialization complete', tag: 'AIKnowledge');

    } catch (e) {
      LoggingService.error('AI Knowledge Base initialization failed: $e', tag: 'AIKnowledge');
    }
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
      // Debug output removed
    }
    return [];
  }
  
  /// Update the list of cached seasons
  Future<void> _updateCachedSeasonsList() async {
    try {
      await _cacheService.set('ai_knowledge_cached_seasons', _allHistoricalSeasons, duration: _historicalCacheDuration);
    } catch (e) {
      // Debug output removed
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

      // Debug output removed

    } catch (e) {
      // Debug output removed
    }

    return [];
  }
  
  /// Get season statistics for AI analysis
  Future<Map<String, dynamic>?> getSeasonStatistics(int season) async {
    try {
      final statsKey = 'ai_knowledge_stats_$season';
      return await _cacheService.get<Map<String, dynamic>>(statsKey);
    } catch (e) {
      // Debug output removed
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
      // Debug output removed
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
      // Debug output removed
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
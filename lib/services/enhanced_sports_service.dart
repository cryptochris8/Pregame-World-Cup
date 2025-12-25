import 'package:pregame_world_cup/services/espn_service.dart';
import 'package:pregame_world_cup/core/entities/game_intelligence.dart';
import 'package:pregame_world_cup/config/api_keys.dart';
import 'package:dio/dio.dart';

/// Enhanced sports service that combines existing SportsData.io API
/// with ESPN API for comprehensive game intelligence
class EnhancedSportsService {
  final ESPNService _espnService;
  
  // Your existing SportsData.io configuration
  static const String _sportsDataBaseUrl = 'https://api.sportsdata.io/v3/cfb';
  static String get _apiKey => ApiKeys.sportsDataIo; // Use the configured API key
  
  final Dio _dio;

  EnhancedSportsService({ESPNService? espnService, Dio? dio}) 
    : _espnService = espnService ?? ESPNService(),
      _dio = dio ?? Dio();

  /// Get comprehensive game intelligence combining both data sources
  Future<GameIntelligence?> getComprehensiveGameIntelligence(String gameId) async {
    try {
      // Get ESPN intelligence (primary source for analysis)
      final espnIntelligence = await _espnService.getGameIntelligence(gameId);
      
      if (espnIntelligence == null) {
        return null;
      }

      // Enhance with SportsData.io information if needed
      final enhancedIntelligence = await _enhanceWithSportsData(espnIntelligence);
      
      return enhancedIntelligence;
    } catch (e) {
      return null;
    }
  }

  /// Enhance ESPN data with additional SportsData.io information
  Future<GameIntelligence> _enhanceWithSportsData(GameIntelligence espnIntelligence) async {
    try {
      // Get additional team statistics from SportsData.io
      final additionalStats = await _getSportsDataTeamStats(
        espnIntelligence.homeTeam, 
        espnIntelligence.awayTeam
      );

      // Merge the statistics
      final enhancedStats = Map<String, dynamic>.from(espnIntelligence.teamStats);
      enhancedStats.addAll(additionalStats);

      // Recalculate crowd factor with additional data
      final enhancedCrowdFactor = _recalculateCrowdFactor(
        espnIntelligence.crowdFactor,
        additionalStats
      );

      // Update venue recommendations with enhanced data
      final enhancedRecommendations = _enhanceVenueRecommendations(
        espnIntelligence.venueRecommendations,
        enhancedCrowdFactor,
        additionalStats
      );

      return espnIntelligence.copyWith(
        crowdFactor: enhancedCrowdFactor,
        teamStats: enhancedStats,
        venueRecommendations: enhancedRecommendations,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      return espnIntelligence; // Return original if enhancement fails
    }
  }

  /// Get additional team statistics from SportsData.io
  Future<Map<String, dynamic>> _getSportsDataTeamStats(String homeTeam, String awayTeam) async {
    try {
      // This would call your existing SportsData.io API
      // Replace with your actual implementation
      final response = await _dio.get(
        '$_sportsDataBaseUrl/teams',
        queryParameters: {
          'key': _apiKey,
        },
      );

      if (response.statusCode == 200) {
        final teams = response.data as List;
        Map<String, dynamic> enhancedStats = {};

        for (final team in teams) {
          final teamName = team['Name'] ?? '';
          if (teamName.contains(homeTeam) || teamName.contains(awayTeam)) {
            enhancedStats[teamName] = {
              'conference': team['Conference'] ?? '',
              'division': team['Division'] ?? '',
              'stadium_capacity': team['StadiumCapacity'] ?? 0,
              'founded': team['Founded'] ?? 0,
            };
          }
        }

        return enhancedStats;
      }
    } catch (e) {
      // Error fetching SportsData team stats
    }
    
    return {};
  }

  /// Recalculate crowd factor with additional data
  double _recalculateCrowdFactor(double baseCrowdFactor, Map<String, dynamic> additionalStats) {
    double enhancedFactor = baseCrowdFactor;
    
    // Add adjustments based on additional statistics
    for (final teamStats in additionalStats.values) {
      if (teamStats is Map<String, dynamic>) {
        final capacity = teamStats['stadium_capacity'] as int? ?? 0;
        
        // Larger stadium capacity suggests bigger programs = more fan interest
        if (capacity > 80000) {
          enhancedFactor += 0.1; // Big program bonus
        } else if (capacity > 60000) {
          enhancedFactor += 0.05; // Medium program bonus
        }
      }
    }
    
    return enhancedFactor;
  }

  /// Enhance venue recommendations with additional insights
  VenueRecommendations _enhanceVenueRecommendations(
    VenueRecommendations baseRecommendations,
    double enhancedCrowdFactor,
    Map<String, dynamic> additionalStats
  ) {
    // Recalculate revenue projection with enhanced crowd factor
    double enhancedRevenue = baseRecommendations.revenueProjection * 
        (enhancedCrowdFactor / (enhancedCrowdFactor - 0.15)); // Adjust for enhancement

    // Add conference-specific recommendations
    List<String> enhancedSpecials = List.from(baseRecommendations.suggestedSpecials);
    
    for (final teamStats in additionalStats.values) {
      if (teamStats is Map<String, dynamic>) {
        final conference = teamStats['conference'] as String? ?? '';
        if (conference.toUpperCase().contains('SEC')) {
          enhancedSpecials.add('SEC Pride Special - Conference championship themed');
        }
      }
    }

    return VenueRecommendations(
      expectedTrafficIncrease: baseRecommendations.expectedTrafficIncrease,
      staffingRecommendation: baseRecommendations.staffingRecommendation,
      suggestedSpecials: enhancedSpecials,
      inventoryAdvice: baseRecommendations.inventoryAdvice,
      marketingOpportunity: baseRecommendations.marketingOpportunity,
      revenueProjection: enhancedRevenue,
    );
  }

  /// Get venue-specific game recommendations for dashboard
  Future<List<GameIntelligence>> getVenueGameRecommendations(
    String venueLocation, 
    List<String> gameIds
  ) async {
    try {
      // Get intelligence for all games
      final allGames = await Future.wait(
        gameIds.map((id) => getComprehensiveGameIntelligence(id))
      );

      // Filter out null results
      final validGames = allGames.where((game) => game != null).cast<GameIntelligence>().toList();

      // Sort by relevance to venue (crowd factor + location proximity)
      validGames.sort((a, b) {
        // Prioritize high crowd factor games
        final factorComparison = b.crowdFactor.compareTo(a.crowdFactor);
        if (factorComparison != 0) return factorComparison;

        // Then prioritize rivalry games
        if (b.isRivalryGame && !a.isRivalryGame) return 1;
        if (a.isRivalryGame && !b.isRivalryGame) return -1;

        // Then championship implications
        if (b.hasChampionshipImplications && !a.hasChampionshipImplications) return 1;
        if (a.hasChampionshipImplications && !b.hasChampionshipImplications) return -1;

        return 0;
      });

      return validGames;
    } catch (e) {
      return [];
    }
  }

  /// Generate a summary report for venue dashboard
  Future<Map<String, dynamic>> generateVenueSummaryReport(
    String venueId,
    List<String> upcomingGameIds
  ) async {
    try {
      final gameIntelligence = await getVenueGameRecommendations('', upcomingGameIds);
      
      if (gameIntelligence.isEmpty) {
        return {
          'total_games': 0,
          'high_impact_games': 0,
          'total_projected_revenue': 0.0,
          'recommendations': ['No upcoming games found'],
        };
      }

      final highImpactGames = gameIntelligence.where((game) => game.crowdFactor >= 2.0).length;
      final totalProjectedRevenue = gameIntelligence
          .map((game) => game.venueRecommendations.revenueProjection)
          .fold(0.0, (sum, revenue) => sum + revenue);

      final topRecommendations = gameIntelligence
          .take(3)
          .map((game) => '${game.homeTeam} vs ${game.awayTeam}: ${game.venueRecommendations.marketingOpportunity}')
          .toList();

      return {
        'total_games': gameIntelligence.length,
        'high_impact_games': highImpactGames,
        'rivalry_games': gameIntelligence.where((game) => game.isRivalryGame).length,
        'championship_games': gameIntelligence.where((game) => game.hasChampionshipImplications).length,
        'total_projected_revenue': totalProjectedRevenue,
        'average_crowd_factor': gameIntelligence.map((g) => g.crowdFactor).fold(0.0, (sum, factor) => sum + factor) / gameIntelligence.length,
        'top_recommendations': topRecommendations,
        'last_updated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'error': 'Failed to generate report',
        'total_games': 0,
        'high_impact_games': 0,
        'total_projected_revenue': 0.0,
        'recommendations': ['Error generating recommendations'],
      };
    }
  }

  /// Clear all cached data
  Future<void> clearAllCache() async {
    await _espnService.clearCache();
  }

  /// Get service statistics for monitoring
  Map<String, dynamic> getServiceStats() {
    return {
      'espn_cache_stats': _espnService.getCacheStats(),
      'service_initialized': DateTime.now().toIso8601String(),
    };
  }
} 
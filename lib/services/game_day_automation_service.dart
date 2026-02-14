import '../core/services/logging_service.dart';
import '../features/schedule/domain/entities/game_schedule.dart';
import '../core/entities/game_intelligence.dart';
import 'zapier_service.dart';
import '../injection_container.dart';

/// Service to handle game day automation and Zapier integrations
/// Monitors game events and triggers relevant workflows
class GameDayAutomationService {
  static const String _logTag = 'GameDayAutomation';
  
  /// Trigger automation when a high-impact game is detected
  Future<void> processHighImpactGame({
    required GameSchedule game,
    required GameIntelligence intelligence,
    required List<String> affectedVenueIds,
  }) async {
    try {
      final zapierService = sl<ZapierService>();
      
      // Only trigger for high crowd factor games
      if (intelligence.crowdFactor >= 1.5) {
        await zapierService.triggerGameDaySurge(
          gameId: game.gameId,
          crowdFactor: intelligence.crowdFactor,
          expectedTrafficIncrease: intelligence.venueRecommendations.expectedTrafficIncrease,
          affectedVenues: affectedVenueIds,
          gameDescription: '${game.awayTeamName} @ ${game.homeTeamName}',
        );
        
        LoggingService.info(
          '🏈 Triggered game day surge automation for ${game.awayTeamName} @ ${game.homeTeamName} (crowd factor: ${intelligence.crowdFactor})',
          tag: _logTag,
        );
      }
    } catch (e) {
      LoggingService.error('Failed to process high impact game: $e', tag: _logTag);
    }
  }

  /// Monitor live game events and trigger real-time notifications
  Future<void> processLiveGameEvent({
    required GameSchedule game,
    required String eventType, // 'kickoff', 'halftime', 'final', 'upset'
    Map<String, dynamic>? eventData,
  }) async {
    try {
      final zapierService = sl<ZapierService>();
      
      await zapierService.triggerMarketingEvent(
        eventType: 'live_game_event',
        eventData: {
          'game_id': game.gameId,
          'event_type': eventType,
          'home_team': game.homeTeamName,
          'away_team': game.awayTeamName,
          'home_score': game.homeScore,
          'away_score': game.awayScore,
          'period': game.period,
          'time_remaining': game.timeRemaining,
          ...?eventData,
        },
        targetAudience: ['sec_fans', '${game.homeTeamName.toLowerCase()}_fans', '${game.awayTeamName.toLowerCase()}_fans'],
      );
      
      LoggingService.info('🔴 Triggered live game event: $eventType for ${game.awayTeamName} @ ${game.homeTeamName}', tag: _logTag);
    } catch (e) {
      LoggingService.error('Failed to process live game event: $e', tag: _logTag);
    }
  }

  /// Process weekly game schedule and prepare venues
  Future<void> processWeeklySchedule({
    required List<GameSchedule> weekGames,
    required Map<String, GameIntelligence> gameIntelligence,
  }) async {
    try {
      final zapierService = sl<ZapierService>();
      
      // Find high-impact games for the week
      final highImpactGames = weekGames.where((game) {
        final intelligence = gameIntelligence[game.gameId];
        return intelligence != null && intelligence.crowdFactor >= 1.3;
      }).toList();

      if (highImpactGames.isNotEmpty) {
        await zapierService.triggerMarketingEvent(
          eventType: 'weekly_schedule_alert',
          eventData: {
            'week_start': DateTime.now().toIso8601String(),
            'total_games': weekGames.length,
            'high_impact_games': highImpactGames.length,
            'featured_games': highImpactGames.map((game) => {
              'game_id': game.gameId,
              'matchup': '${game.awayTeamName} @ ${game.homeTeamName}',
              'date': game.dateTimeUTC?.toIso8601String(),
              'crowd_factor': gameIntelligence[game.gameId]?.crowdFactor,
            }).toList(),
          },
          targetAudience: ['venue_partners', 'sec_fans'],
          campaignId: 'weekly_prep_${DateTime.now().millisecondsSinceEpoch}',
        );
        
        LoggingService.info('📅 Triggered weekly schedule automation for ${highImpactGames.length} high-impact games', tag: _logTag);
      }
    } catch (e) {
      LoggingService.error('Failed to process weekly schedule: $e', tag: _logTag);
    }
  }

  /// Process rivalry game detection and special promotions
  Future<void> processRivalryGame({
    required GameSchedule game,
    required GameIntelligence intelligence,
  }) async {
    try {
      if (!intelligence.isRivalryGame) return;
      
      final zapierService = sl<ZapierService>();
      
      await zapierService.triggerMarketingEvent(
        eventType: 'rivalry_game_alert',
        eventData: {
          'game_id': game.gameId,
          'home_team': game.homeTeamName,
          'away_team': game.awayTeamName,
          'rivalry_level': 'high',
          'crowd_factor': intelligence.crowdFactor,
          'championship_implications': intelligence.hasChampionshipImplications,
          'venue_recommendations': intelligence.venueRecommendations.toJson(),
        },
        targetAudience: ['venue_partners', 'sec_fans', 'media_partners'],
        campaignId: 'rivalry_${game.gameId}',
      );
      
      LoggingService.info('🥊 Triggered rivalry game automation for ${game.awayTeamName} @ ${game.homeTeamName}', tag: _logTag);
    } catch (e) {
      LoggingService.error('Failed to process rivalry game: $e', tag: _logTag);
    }
  }

  /// Process venue capacity alerts based on predicted traffic
  Future<void> processVenueCapacityAlerts({
    required String venueId,
    required String venueName,
    required double predictedTrafficIncrease,
    required GameSchedule relatedGame,
  }) async {
    try {
      // Alert venues when traffic is expected to increase significantly
      if (predictedTrafficIncrease >= 50.0) {
        final zapierService = sl<ZapierService>();
        
        await zapierService.triggerMarketingEvent(
          eventType: 'venue_capacity_alert',
          eventData: {
            'venue_id': venueId,
            'venue_name': venueName,
            'predicted_increase': predictedTrafficIncrease,
            'game_id': relatedGame.gameId,
            'game_time': relatedGame.dateTimeUTC?.toIso8601String(),
            'home_team': relatedGame.homeTeamName,
            'away_team': relatedGame.awayTeamName,
            'alert_level': predictedTrafficIncrease >= 100.0 ? 'critical' : 'high',
          },
          targetAudience: ['venue_partners'],
          campaignId: 'capacity_alert_${venueId}_${relatedGame.gameId}',
        );
        
        LoggingService.info('🚨 Triggered capacity alert for $venueName (+${predictedTrafficIncrease.toInt()}% traffic)', tag: _logTag);
      }
    } catch (e) {
      LoggingService.error('Failed to process venue capacity alert: $e', tag: _logTag);
    }
  }

  /// Process user milestone achievements (loyalty, engagement, etc.)
  Future<void> processUserMilestone({
    required String userId,
    required String milestoneType,
    required Map<String, dynamic> milestoneData,
  }) async {
    try {
      final zapierService = sl<ZapierService>();
      
      await zapierService.triggerMarketingEvent(
        eventType: 'user_milestone',
        eventData: {
          'user_id': userId,
          'milestone_type': milestoneType,
          'milestone_data': milestoneData,
          'achieved_at': DateTime.now().toIso8601String(),
        },
        targetAudience: ['user_engagement'],
        campaignId: 'milestone_${userId}_$milestoneType',
      );
      
      LoggingService.info('🏆 Triggered user milestone automation: $milestoneType for user $userId', tag: _logTag);
    } catch (e) {
      LoggingService.error('Failed to process user milestone: $e', tag: _logTag);
    }
  }

  /// Process new venue partner onboarding
  Future<void> processVenueOnboarding({
    required String venueName,
    required String ownerEmail,
    required String subscriptionTier,
    required String location,
    String? phone,
    double? estimatedMonthlyRevenue,
  }) async {
    try {
      final zapierService = sl<ZapierService>();
      
      await zapierService.triggerVenueSignup(
        venueName: venueName,
        ownerEmail: ownerEmail,
        subscriptionTier: subscriptionTier,
        location: location,
        phone: phone,
        monthlyRevenue: estimatedMonthlyRevenue,
      );
      
      LoggingService.info('🏪 Triggered venue onboarding automation for $venueName ($subscriptionTier tier)', tag: _logTag);
    } catch (e) {
      LoggingService.error('Failed to process venue onboarding: $e', tag: _logTag);
    }
  }

  /// Process business metrics for weekly/monthly reports
  Future<void> processBusinessMetrics({
    required int activeUsers,
    required int totalVenues,
    required double totalRevenue,
    required double aiSuccessRate,
    List<String>? topPerformingVenues,
    String reportPeriod = 'weekly',
  }) async {
    try {
      final zapierService = sl<ZapierService>();
      
      await zapierService.triggerBusinessMetrics(
        activeUsers: activeUsers,
        totalVenues: totalVenues,
        totalRevenue: totalRevenue,
        aiSuccessRate: aiSuccessRate,
        topPerformingVenues: topPerformingVenues,
        reportPeriod: reportPeriod,
      );
      
      LoggingService.info('📊 Triggered business metrics automation ($reportPeriod report)', tag: _logTag);
    } catch (e) {
      LoggingService.error('Failed to process business metrics: $e', tag: _logTag);
    }
  }
} 
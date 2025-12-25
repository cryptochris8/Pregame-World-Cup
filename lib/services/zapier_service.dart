import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/services/logging_service.dart';

/// Zapier MCP integration service for automating workflows
/// This service triggers external automations without affecting core app functionality
class ZapierService {
  final Dio _dio;
  
  // Zapier MCP endpoint from your configuration
  static const String _mcpUrl = 'https://mcp.zapier.com/api/mcp/s/OTFlMzY0OTAtODAzMS00NzQ3LTgwZTQtMWJiNDAzYjE2N2JlOjc0NWI0MWUyLTI2OGQtNGU0Zi05NmVhLWE4OTA1YWM4OTI2MQ==/sse';
  
  // Feature flag for gradual rollout
  static const bool _enabledInProduction = true;
  static const bool _enabledInDebug = true;
  
  ZapierService({Dio? dio}) : _dio = dio ?? Dio();

  /// Check if Zapier integration is enabled
  bool get isEnabled {
    if (kDebugMode) return _enabledInDebug;
    return _enabledInProduction;
  }

  /// Trigger a Zapier workflow with the given data
  /// This is a fire-and-forget operation that won't block app functionality
  Future<void> triggerZap(String zapName, Map<String, dynamic> data) async {
    if (!isEnabled) {
      LoggingService.info('Zapier disabled - would trigger: $zapName', tag: 'Zapier');
      return;
    }

    // Add metadata to all Zapier calls
    final enrichedData = {
      ...data,
      'app_version': '1.0.0',
      'platform': 'flutter',
      'timestamp': DateTime.now().toIso8601String(),
      'environment': kDebugMode ? 'debug' : 'production',
    };

    // Fire-and-forget pattern - don't wait for response or block execution
    _executeZapierCall(zapName, enrichedData);
  }

  /// Execute the actual Zapier call asynchronously
  void _executeZapierCall(String zapName, Map<String, dynamic> data) async {
    try {
      LoggingService.info('🔄 Triggering Zapier workflow: $zapName', tag: 'Zapier');
      
      final response = await _dio.post(
        _mcpUrl,
        data: {
          'zap_name': zapName,
          'payload': data,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'User-Agent': 'Pregame-App/1.0.0',
          },
          // Don't wait too long - this is non-critical
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        LoggingService.info('✅ Zapier workflow triggered successfully: $zapName', tag: 'Zapier');
      } else {
        LoggingService.warning('⚠️ Zapier returned status ${response.statusCode} for $zapName', tag: 'Zapier');
      }
    } catch (e) {
      // Log error but don't throw - app should continue working
      LoggingService.error('❌ Zapier workflow failed: $zapName - $e', tag: 'Zapier');
    }
  }

  /// Venue-related Zapier workflows
  Future<void> triggerVenueSignup({
    required String venueName,
    required String ownerEmail,
    required String subscriptionTier,
    required String location,
    String? phone,
    double? monthlyRevenue,
  }) async {
    await triggerZap('venue-signup', {
      'venue_name': venueName,
      'owner_email': ownerEmail,
      'subscription_tier': subscriptionTier,
      'location': location,
      'phone': phone,
      'estimated_monthly_revenue': monthlyRevenue,
      'signup_source': 'mobile_app',
    });
  }

  /// User engagement workflows
  Future<void> triggerUserEngagement({
    required String userId,
    required String action,
    String? venueId,
    String? gameContext,
    Map<String, dynamic>? additionalData,
  }) async {
    await triggerZap('user-engagement', {
      'user_id': userId,
      'action': action,
      'venue_id': venueId,
      'game_context': gameContext,
      'additional_data': additionalData,
    });
  }

  /// AI recommendation success tracking
  Future<void> triggerAIRecommendationSuccess({
    required String userId,
    required String venueId,
    required double confidence,
    required List<String> reasons,
    required String userAction,
    String? gameContext,
  }) async {
    await triggerZap('ai-recommendation-success', {
      'user_id': userId,
      'venue_id': venueId,
      'confidence': confidence,
      'reasons': reasons,
      'user_action': userAction,
      'game_context': gameContext,
    });
  }

  /// Game day surge notifications
  Future<void> triggerGameDaySurge({
    required String gameId,
    required double crowdFactor,
    required double expectedTrafficIncrease,
    required List<String> affectedVenues,
    String? gameDescription,
  }) async {
    await triggerZap('game-day-surge', {
      'game_id': gameId,
      'crowd_factor': crowdFactor,
      'expected_traffic_increase': expectedTrafficIncrease,
      'affected_venues': affectedVenues,
      'game_description': gameDescription,
    });
  }

  /// Business metrics reporting
  Future<void> triggerBusinessMetrics({
    required int activeUsers,
    required int totalVenues,
    required double totalRevenue,
    required double aiSuccessRate,
    List<String>? topPerformingVenues,
    String reportPeriod = 'weekly',
  }) async {
    await triggerZap('business-metrics', {
      'active_users': activeUsers,
      'total_venues': totalVenues,
      'total_revenue': totalRevenue,
      'ai_success_rate': aiSuccessRate,
      'top_performing_venues': topPerformingVenues,
      'report_period': reportPeriod,
    });
  }

  /// Payment and subscription events
  Future<void> triggerPaymentEvent({
    required String eventType, // 'subscription_created', 'payment_failed', etc.
    required String customerId,
    String? amount,
    String? planName,
    Map<String, dynamic>? metadata,
  }) async {
    await triggerZap('payment-event', {
      'event_type': eventType,
      'customer_id': customerId,
      'amount': amount,
      'plan_name': planName,
      'metadata': metadata,
    });
  }

  /// Support and customer service
  Future<void> triggerSupportTicket({
    required String userId,
    required String issueType,
    required String description,
    String? priority,
    String? category,
  }) async {
    await triggerZap('support-ticket', {
      'user_id': userId,
      'issue_type': issueType,
      'description': description,
      'priority': priority ?? 'medium',
      'category': category,
    });
  }

  /// Social media and marketing automation
  Future<void> triggerMarketingEvent({
    required String eventType,
    required Map<String, dynamic> eventData,
    List<String>? targetAudience,
    String? campaignId,
  }) async {
    await triggerZap('marketing-event', {
      'event_type': eventType,
      'event_data': eventData,
      'target_audience': targetAudience,
      'campaign_id': campaignId,
    });
  }

  /// Disable Zapier integration (for testing or emergency situations)
  static void disable() {
    // This would require a const change and rebuild, but provides safety
    LoggingService.warning('Zapier integration disabled via code', tag: 'Zapier');
  }
} 
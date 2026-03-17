import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'logging_service.dart';
import 'analytics/analytics_crashlytics_tracker.dart';

// Re-export extensions so existing callers get domain methods automatically.
export 'analytics/analytics_event_extensions.dart';

/// Analytics event names for consistent tracking across the app
class AnalyticsEvents {
  // Authentication Events
  static const String login = 'login';
  static const String signUp = 'sign_up';
  static const String logout = 'logout';

  // Navigation Events
  static const String screenView = 'screen_view';
  static const String tabChange = 'tab_change';

  // World Cup Events
  static const String viewMatch = 'view_match';
  static const String viewTeam = 'view_team';
  static const String viewBracket = 'view_bracket';
  static const String viewGroupStandings = 'view_group_standings';
  static const String setMatchReminder = 'set_match_reminder';
  static const String cancelMatchReminder = 'cancel_match_reminder';
  static const String favoriteTeam = 'favorite_team';
  static const String unfavoriteTeam = 'unfavorite_team';

  // Prediction Events
  static const String makePrediction = 'make_prediction';
  static const String updatePrediction = 'update_prediction';
  static const String viewLeaderboard = 'view_leaderboard';

  // Watch Party Events
  static const String createWatchParty = 'create_watch_party';
  static const String joinWatchParty = 'join_watch_party';
  static const String leaveWatchParty = 'leave_watch_party';
  static const String inviteToWatchParty = 'invite_to_watch_party';
  static const String viewWatchParty = 'view_watch_party';
  static const String discoverWatchParties = 'discover_watch_parties';

  // Social Events
  static const String sendFriendRequest = 'send_friend_request';
  static const String acceptFriendRequest = 'accept_friend_request';
  static const String rejectFriendRequest = 'reject_friend_request';
  static const String blockUser = 'block_user';
  static const String unblockUser = 'unblock_user';
  static const String reportContent = 'report_content';
  static const String viewProfile = 'view_profile';
  static const String editProfile = 'edit_profile';

  // Messaging Events
  static const String sendMessage = 'send_message';
  static const String sendVoiceMessage = 'send_voice_message';
  static const String sendMediaMessage = 'send_media_message';
  static const String createChat = 'create_chat';
  static const String createGroupChat = 'create_group_chat';
  static const String muteChat = 'mute_chat';
  static const String archiveChat = 'archive_chat';

  // Payment Events
  static const String viewPricing = 'view_pricing';
  static const String startCheckout = 'begin_checkout';
  static const String completePurchase = 'purchase';
  static const String subscriptionStart = 'subscription_start';
  static const String subscriptionCancel = 'subscription_cancel';
  static const String virtualAttendancePurchase = 'virtual_attendance_purchase';

  // Venue Events
  static const String viewVenue = 'view_venue';
  static const String searchVenues = 'search_venues';
  static const String getNearbyVenues = 'get_nearby_venues';

  // AI Events
  static const String aiPredictionRequest = 'ai_prediction_request';
  static const String aiAnalysisRequest = 'ai_analysis_request';
  static const String chatbotMessage = 'chatbot_message';

  // Engagement Events
  static const String appOpen = 'app_open';
  static const String shareContent = 'share';
  static const String notificationReceived = 'notification_received';
  static const String notificationOpened = 'notification_opened';
  static const String searchPerformed = 'search';

  // Error Events
  static const String apiError = 'api_error';
  static const String paymentError = 'payment_error';
  static const String authError = 'auth_error';
}

/// User property names for segmentation
class AnalyticsUserProperties {
  static const String userId = 'user_id';
  static const String subscriptionTier = 'subscription_tier';
  static const String favoriteTeamCount = 'favorite_team_count';
  static const String primaryFavoriteTeam = 'primary_favorite_team';
  static const String watchPartiesAttended = 'watch_parties_attended';
  static const String watchPartiesHosted = 'watch_parties_hosted';
  static const String predictionsCount = 'predictions_count';
  static const String friendsCount = 'friends_count';
  static const String userLevel = 'user_level';
  static const String appVersion = 'app_version';
  static const String platform = 'platform';
}

/// Centralized analytics facade for tracking user behavior and app performance.
///
/// Core responsibilities: initialization, generic event logging, screen views,
/// user identity, session metrics, and crash reporting. Domain-specific logging
/// methods (auth, world cup, social, etc.) live in extension methods that are
/// re-exported from this file — see `analytics/analytics_event_extensions.dart`.
class AnalyticsService {
  static AnalyticsService? _instance;

  final FirebaseAnalytics _analytics;
  final FirebaseCrashlytics _crashlytics;
  final FirebaseAuth _auth;
  late final AnalyticsCrashlyticsTracker _crashlyticsTracker;

  bool _isInitialized = false;
  String? _currentScreen;
  DateTime? _sessionStartTime;
  int _screenViewCount = 0;

  AnalyticsService._({
    FirebaseAnalytics? analytics,
    FirebaseCrashlytics? crashlytics,
    FirebaseAuth? auth,
  })  : _analytics = analytics ?? FirebaseAnalytics.instance,
        _crashlytics = crashlytics ?? FirebaseCrashlytics.instance,
        _auth = auth ?? FirebaseAuth.instance {
    _crashlyticsTracker = AnalyticsCrashlyticsTracker(_crashlytics);
  }

  factory AnalyticsService({
    FirebaseAnalytics? analytics,
    FirebaseCrashlytics? crashlytics,
    FirebaseAuth? auth,
  }) {
    _instance ??= AnalyticsService._(
      analytics: analytics,
      crashlytics: crashlytics,
      auth: auth,
    );
    return _instance!;
  }

  /// Get the Firebase Analytics instance for NavigatorObserver
  FirebaseAnalytics get analytics => _analytics;

  /// Get the analytics observer for navigation tracking
  FirebaseAnalyticsObserver get observer => FirebaseAnalyticsObserver(analytics: _analytics);

  /// Initialize analytics and crashlytics
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Enable analytics collection (can be disabled for GDPR compliance)
      await _analytics.setAnalyticsCollectionEnabled(true);

      // Configure Crashlytics
      await _crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);

      // Track session start
      _sessionStartTime = DateTime.now();

      // Set initial user ID if logged in
      final user = _auth.currentUser;
      if (user != null) {
        await setUserId(user.uid);
      }

      // Listen for auth changes
      _auth.authStateChanges().listen((user) {
        if (user != null) {
          setUserId(user.uid);
        } else {
          clearUserId();
        }
      });

      _isInitialized = true;
      LoggingService.info('AnalyticsService initialized', tag: 'Analytics');

      // Track app open
      await logEvent(AnalyticsEvents.appOpen);
    } catch (e) {
      LoggingService.error('Failed to initialize AnalyticsService: $e', tag: 'Analytics');
    }
  }

  // ==================== USER IDENTIFICATION ====================

  /// Set the user ID for analytics and crash reports
  Future<void> setUserId(String userId) async {
    try {
      await _analytics.setUserId(id: userId);
      await _crashlytics.setUserIdentifier(userId);
      LoggingService.debug('Set analytics user ID: ${userId.substring(0, 8)}...', tag: 'Analytics');
    } catch (e) {
      LoggingService.error('Failed to set user ID: $e', tag: 'Analytics');
    }
  }

  /// Clear user ID (on logout)
  Future<void> clearUserId() async {
    try {
      await _analytics.setUserId(id: null);
      await _crashlytics.setUserIdentifier('');
    } catch (e) {
      LoggingService.error('Failed to clear user ID: $e', tag: 'Analytics');
    }
  }

  /// Set a user property for segmentation
  Future<void> setUserProperty(String name, String? value) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
      LoggingService.debug('Set user property: $name = $value', tag: 'Analytics');
    } catch (e) {
      LoggingService.error('Failed to set user property: $e', tag: 'Analytics');
    }
  }

  /// Set multiple user properties at once
  Future<void> setUserProperties(Map<String, String?> properties) async {
    for (final entry in properties.entries) {
      await setUserProperty(entry.key, entry.value);
    }
  }

  // ==================== EVENT TRACKING ====================

  /// Log a custom analytics event
  Future<void> logEvent(
    String name, {
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: name,
        parameters: parameters,
      );

      if (kDebugMode) {
        LoggingService.debug(
          'Analytics event: $name ${parameters != null ? parameters.toString() : ''}',
          tag: 'Analytics',
        );
      }
    } catch (e) {
      LoggingService.error('Failed to log event $name: $e', tag: 'Analytics');
    }
  }

  /// Log screen view
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    _currentScreen = screenName;
    _screenViewCount++;

    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
    } catch (e) {
      LoggingService.error('Failed to log screen view: $e', tag: 'Analytics');
    }
  }

  // ==================== ERROR TRACKING ====================

  /// Log a non-fatal error
  Future<void> logError({
    required String errorType,
    required String message,
    String? endpoint,
    int? statusCode,
    StackTrace? stackTrace,
  }) async {
    // Log to Analytics
    await logEvent(AnalyticsEvents.apiError, parameters: {
      'error_type': errorType,
      'message': message.length > 100 ? message.substring(0, 100) : message,
      if (endpoint != null) 'endpoint': endpoint,
      if (statusCode != null) 'status_code': statusCode,
    });

    // Log to Crashlytics as non-fatal
    await _crashlytics.recordError(
      Exception('$errorType: $message'),
      stackTrace,
      reason: 'Non-fatal error: $errorType',
      fatal: false,
    );
  }

  /// Log a fatal error (crash) — delegates to [AnalyticsCrashlyticsTracker]
  Future<void> logFatalError({
    required Object error,
    required StackTrace stackTrace,
    String? context,
  }) async {
    await _crashlyticsTracker.logFatalError(
      error: error,
      stackTrace: stackTrace,
      context: context,
    );
  }

  /// Set custom Crashlytics key-value pair — delegates to [AnalyticsCrashlyticsTracker]
  Future<void> setCrashlyticsKey(String key, Object value) async {
    await _crashlyticsTracker.setCrashlyticsKey(key, value);
  }

  /// Log a breadcrumb for crash context — delegates to [AnalyticsCrashlyticsTracker]
  Future<void> logBreadcrumb(String message) async {
    await _crashlyticsTracker.logBreadcrumb(message);
  }

  // ==================== SESSION METRICS ====================

  /// Get current session duration in seconds
  int get sessionDurationSeconds {
    if (_sessionStartTime == null) return 0;
    return DateTime.now().difference(_sessionStartTime!).inSeconds;
  }

  /// Get number of screens viewed in current session
  int get screenViewsInSession => _screenViewCount;

  /// Get current screen name
  String? get currentScreen => _currentScreen;

  // ==================== CONSENT MANAGEMENT ====================

  /// Enable or disable analytics collection (for GDPR/CCPA compliance)
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    try {
      await _analytics.setAnalyticsCollectionEnabled(enabled);
      await _crashlytics.setCrashlyticsCollectionEnabled(enabled);
      LoggingService.info('Analytics collection ${enabled ? 'enabled' : 'disabled'}', tag: 'Analytics');
    } catch (e) {
      LoggingService.error('Failed to set analytics collection: $e', tag: 'Analytics');
    }
  }
}

import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'logging_service.dart';

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

/// Centralized analytics service for tracking user behavior and app performance
class AnalyticsService {
  static AnalyticsService? _instance;

  final FirebaseAnalytics _analytics;
  final FirebaseCrashlytics _crashlytics;
  final FirebaseAuth _auth;

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
        _auth = auth ?? FirebaseAuth.instance;

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

      // Set up error handling
      FlutterError.onError = (errorDetails) {
        _crashlytics.recordFlutterFatalError(errorDetails);
      };

      // Pass all uncaught async errors to Crashlytics
      PlatformDispatcher.instance.onError = (error, stack) {
        _crashlytics.recordError(error, stack, fatal: true);
        return true;
      };

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

  // ==================== AUTHENTICATION EVENTS ====================

  /// Log user login
  Future<void> logLogin({required String method}) async {
    await logEvent(AnalyticsEvents.login, parameters: {
      'method': method,
    });
  }

  /// Log user sign up
  Future<void> logSignUp({required String method}) async {
    await logEvent(AnalyticsEvents.signUp, parameters: {
      'method': method,
    });
  }

  /// Log user logout
  Future<void> logLogout() async {
    await logEvent(AnalyticsEvents.logout);
    await clearUserId();
  }

  // ==================== WORLD CUP EVENTS ====================

  /// Log match view
  Future<void> logMatchView({
    required String matchId,
    required String homeTeam,
    required String awayTeam,
    String? stage,
  }) async {
    await logEvent(AnalyticsEvents.viewMatch, parameters: {
      'match_id': matchId,
      'home_team': homeTeam,
      'away_team': awayTeam,
      if (stage != null) 'stage': stage,
    });
  }

  /// Log team view
  Future<void> logTeamView({
    required String teamId,
    required String teamName,
    String? group,
  }) async {
    await logEvent(AnalyticsEvents.viewTeam, parameters: {
      'team_id': teamId,
      'team_name': teamName,
      if (group != null) 'group': group,
    });
  }

  /// Log favorite team action
  Future<void> logFavoriteTeam({
    required String teamId,
    required String teamName,
    required bool isFavoriting,
  }) async {
    await logEvent(
      isFavoriting ? AnalyticsEvents.favoriteTeam : AnalyticsEvents.unfavoriteTeam,
      parameters: {
        'team_id': teamId,
        'team_name': teamName,
      },
    );
  }

  /// Log prediction made
  Future<void> logPrediction({
    required String matchId,
    required String predictedWinner,
    int? homeScore,
    int? awayScore,
  }) async {
    await logEvent(AnalyticsEvents.makePrediction, parameters: {
      'match_id': matchId,
      'predicted_winner': predictedWinner,
      if (homeScore != null) 'home_score': homeScore,
      if (awayScore != null) 'away_score': awayScore,
    });
  }

  // ==================== WATCH PARTY EVENTS ====================

  /// Log watch party creation
  Future<void> logWatchPartyCreated({
    required String partyId,
    required String matchId,
    required bool isPublic,
    required bool allowsVirtual,
    double? virtualFee,
  }) async {
    await logEvent(AnalyticsEvents.createWatchParty, parameters: {
      'party_id': partyId,
      'match_id': matchId,
      'is_public': isPublic,
      'allows_virtual': allowsVirtual,
      if (virtualFee != null) 'virtual_fee': virtualFee,
    });
  }

  /// Log watch party join
  Future<void> logWatchPartyJoined({
    required String partyId,
    required bool isVirtual,
    double? amountPaid,
  }) async {
    await logEvent(AnalyticsEvents.joinWatchParty, parameters: {
      'party_id': partyId,
      'is_virtual': isVirtual,
      if (amountPaid != null) 'amount_paid': amountPaid,
    });
  }

  // ==================== SOCIAL EVENTS ====================

  /// Log friend request sent
  Future<void> logFriendRequestSent({required String recipientId}) async {
    await logEvent(AnalyticsEvents.sendFriendRequest, parameters: {
      'recipient_id': recipientId,
    });
  }

  /// Log content report
  Future<void> logContentReported({
    required String contentType,
    required String reason,
  }) async {
    await logEvent(AnalyticsEvents.reportContent, parameters: {
      'content_type': contentType,
      'reason': reason,
    });
  }

  // ==================== MESSAGING EVENTS ====================

  /// Log message sent
  Future<void> logMessageSent({
    required String chatType,
    required String messageType,
  }) async {
    await logEvent(AnalyticsEvents.sendMessage, parameters: {
      'chat_type': chatType,
      'message_type': messageType,
    });
  }

  // ==================== PAYMENT EVENTS ====================

  /// Log purchase started
  Future<void> logBeginCheckout({
    required String itemId,
    required String itemName,
    required double price,
    String? currency,
  }) async {
    await logEvent(AnalyticsEvents.startCheckout, parameters: {
      'item_id': itemId,
      'item_name': itemName,
      'value': price,
      'currency': currency ?? 'USD',
    });
  }

  /// Log purchase completed
  Future<void> logPurchase({
    required String transactionId,
    required String itemId,
    required String itemName,
    required double price,
    String? currency,
  }) async {
    await logEvent(AnalyticsEvents.completePurchase, parameters: {
      'transaction_id': transactionId,
      'item_id': itemId,
      'item_name': itemName,
      'value': price,
      'currency': currency ?? 'USD',
    });
  }

  /// Log subscription start
  Future<void> logSubscriptionStart({
    required String subscriptionId,
    required String tier,
    required double price,
  }) async {
    await logEvent(AnalyticsEvents.subscriptionStart, parameters: {
      'subscription_id': subscriptionId,
      'tier': tier,
      'value': price,
    });

    await setUserProperty(AnalyticsUserProperties.subscriptionTier, tier);
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

  /// Log a fatal error (crash)
  Future<void> logFatalError({
    required dynamic error,
    required StackTrace stackTrace,
    String? context,
  }) async {
    await _crashlytics.recordError(
      error,
      stackTrace,
      reason: context ?? 'Fatal error',
      fatal: true,
    );
  }

  /// Set custom Crashlytics key-value pair
  Future<void> setCrashlyticsKey(String key, dynamic value) async {
    try {
      if (value is String) {
        await _crashlytics.setCustomKey(key, value);
      } else if (value is int) {
        await _crashlytics.setCustomKey(key, value);
      } else if (value is double) {
        await _crashlytics.setCustomKey(key, value);
      } else if (value is bool) {
        await _crashlytics.setCustomKey(key, value);
      } else {
        await _crashlytics.setCustomKey(key, value.toString());
      }
    } catch (e) {
      LoggingService.error('Failed to set Crashlytics key: $e', tag: 'Analytics');
    }
  }

  /// Log a breadcrumb for crash context
  Future<void> logBreadcrumb(String message) async {
    await _crashlytics.log(message);
  }

  // ==================== NOTIFICATION EVENTS ====================

  /// Log notification received
  Future<void> logNotificationReceived({
    required String notificationType,
    String? title,
  }) async {
    await logEvent(AnalyticsEvents.notificationReceived, parameters: {
      'notification_type': notificationType,
      if (title != null) 'title': title,
    });
  }

  /// Log notification opened
  Future<void> logNotificationOpened({
    required String notificationType,
    String? action,
  }) async {
    await logEvent(AnalyticsEvents.notificationOpened, parameters: {
      'notification_type': notificationType,
      if (action != null) 'action': action,
    });
  }

  // ==================== SEARCH EVENTS ====================

  /// Log search performed
  Future<void> logSearch({
    required String searchTerm,
    String? searchType,
    int? resultsCount,
  }) async {
    await logEvent(AnalyticsEvents.searchPerformed, parameters: {
      'search_term': searchTerm,
      if (searchType != null) 'search_type': searchType,
      if (resultsCount != null) 'results_count': resultsCount,
    });
  }

  // ==================== SHARE EVENTS ====================

  /// Log content shared
  Future<void> logShare({
    required String contentType,
    required String itemId,
    String? method,
  }) async {
    await logEvent(AnalyticsEvents.shareContent, parameters: {
      'content_type': contentType,
      'item_id': itemId,
      if (method != null) 'method': method,
    });
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

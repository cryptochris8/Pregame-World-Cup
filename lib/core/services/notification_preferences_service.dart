import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'logging_service.dart';
import 'push_notification_service.dart';
import '../../features/worldcup/domain/entities/match_reminder.dart';

/// World Cup notification preferences
class NotificationPreferencesData {
  // Global settings
  final bool pushNotificationsEnabled;
  final bool quietHoursEnabled;
  final String quietHoursStart; // "22:00"
  final String quietHoursEnd; // "08:00"

  // Match notifications
  final bool matchRemindersEnabled;
  final ReminderTiming defaultReminderTiming;
  final bool favoriteTeamMatchesEnabled;
  final bool favoriteTeamMatchDayBefore; // Notify day before favorite team plays

  // Live match notifications
  final bool goalAlertsEnabled;
  final bool matchStartAlertsEnabled;
  final bool matchEndAlertsEnabled;
  final bool halftimeAlertsEnabled;
  final bool redCardAlertsEnabled;
  final bool penaltyAlertsEnabled;

  // Watch party notifications
  final bool watchPartyInvitesEnabled;
  final bool watchPartyRemindersEnabled;
  final ReminderTiming watchPartyReminderTiming;
  final bool watchPartyUpdatesEnabled; // Host messages, changes

  // Social notifications
  final bool friendRequestsEnabled;
  final bool messagesEnabled;
  final bool mentionsEnabled;

  // Prediction notifications
  final bool predictionResultsEnabled;
  final bool leaderboardUpdatesEnabled;

  const NotificationPreferencesData({
    this.pushNotificationsEnabled = true,
    this.quietHoursEnabled = false,
    this.quietHoursStart = '22:00',
    this.quietHoursEnd = '08:00',
    this.matchRemindersEnabled = true,
    this.defaultReminderTiming = ReminderTiming.thirtyMinutes,
    this.favoriteTeamMatchesEnabled = true,
    this.favoriteTeamMatchDayBefore = true,
    this.goalAlertsEnabled = true,
    this.matchStartAlertsEnabled = true,
    this.matchEndAlertsEnabled = false,
    this.halftimeAlertsEnabled = false,
    this.redCardAlertsEnabled = true,
    this.penaltyAlertsEnabled = true,
    this.watchPartyInvitesEnabled = true,
    this.watchPartyRemindersEnabled = true,
    this.watchPartyReminderTiming = ReminderTiming.oneHour,
    this.watchPartyUpdatesEnabled = true,
    this.friendRequestsEnabled = true,
    this.messagesEnabled = true,
    this.mentionsEnabled = true,
    this.predictionResultsEnabled = true,
    this.leaderboardUpdatesEnabled = false,
  });

  factory NotificationPreferencesData.fromJson(Map<String, dynamic> json) {
    return NotificationPreferencesData(
      pushNotificationsEnabled: json['pushNotificationsEnabled'] as bool? ?? true,
      quietHoursEnabled: json['quietHoursEnabled'] as bool? ?? false,
      quietHoursStart: json['quietHoursStart'] as String? ?? '22:00',
      quietHoursEnd: json['quietHoursEnd'] as String? ?? '08:00',
      matchRemindersEnabled: json['matchRemindersEnabled'] as bool? ?? true,
      defaultReminderTiming: ReminderTiming.fromMinutes(
        json['defaultReminderTimingMinutes'] as int? ?? 30,
      ),
      favoriteTeamMatchesEnabled: json['favoriteTeamMatchesEnabled'] as bool? ?? true,
      favoriteTeamMatchDayBefore: json['favoriteTeamMatchDayBefore'] as bool? ?? true,
      goalAlertsEnabled: json['goalAlertsEnabled'] as bool? ?? true,
      matchStartAlertsEnabled: json['matchStartAlertsEnabled'] as bool? ?? true,
      matchEndAlertsEnabled: json['matchEndAlertsEnabled'] as bool? ?? false,
      halftimeAlertsEnabled: json['halftimeAlertsEnabled'] as bool? ?? false,
      redCardAlertsEnabled: json['redCardAlertsEnabled'] as bool? ?? true,
      penaltyAlertsEnabled: json['penaltyAlertsEnabled'] as bool? ?? true,
      watchPartyInvitesEnabled: json['watchPartyInvitesEnabled'] as bool? ?? true,
      watchPartyRemindersEnabled: json['watchPartyRemindersEnabled'] as bool? ?? true,
      watchPartyReminderTiming: ReminderTiming.fromMinutes(
        json['watchPartyReminderTimingMinutes'] as int? ?? 60,
      ),
      watchPartyUpdatesEnabled: json['watchPartyUpdatesEnabled'] as bool? ?? true,
      friendRequestsEnabled: json['friendRequestsEnabled'] as bool? ?? true,
      messagesEnabled: json['messagesEnabled'] as bool? ?? true,
      mentionsEnabled: json['mentionsEnabled'] as bool? ?? true,
      predictionResultsEnabled: json['predictionResultsEnabled'] as bool? ?? true,
      leaderboardUpdatesEnabled: json['leaderboardUpdatesEnabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'pushNotificationsEnabled': pushNotificationsEnabled,
        'quietHoursEnabled': quietHoursEnabled,
        'quietHoursStart': quietHoursStart,
        'quietHoursEnd': quietHoursEnd,
        'matchRemindersEnabled': matchRemindersEnabled,
        'defaultReminderTimingMinutes': defaultReminderTiming.minutes,
        'favoriteTeamMatchesEnabled': favoriteTeamMatchesEnabled,
        'favoriteTeamMatchDayBefore': favoriteTeamMatchDayBefore,
        'goalAlertsEnabled': goalAlertsEnabled,
        'matchStartAlertsEnabled': matchStartAlertsEnabled,
        'matchEndAlertsEnabled': matchEndAlertsEnabled,
        'halftimeAlertsEnabled': halftimeAlertsEnabled,
        'redCardAlertsEnabled': redCardAlertsEnabled,
        'penaltyAlertsEnabled': penaltyAlertsEnabled,
        'watchPartyInvitesEnabled': watchPartyInvitesEnabled,
        'watchPartyRemindersEnabled': watchPartyRemindersEnabled,
        'watchPartyReminderTimingMinutes': watchPartyReminderTiming.minutes,
        'watchPartyUpdatesEnabled': watchPartyUpdatesEnabled,
        'friendRequestsEnabled': friendRequestsEnabled,
        'messagesEnabled': messagesEnabled,
        'mentionsEnabled': mentionsEnabled,
        'predictionResultsEnabled': predictionResultsEnabled,
        'leaderboardUpdatesEnabled': leaderboardUpdatesEnabled,
      };

  NotificationPreferencesData copyWith({
    bool? pushNotificationsEnabled,
    bool? quietHoursEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
    bool? matchRemindersEnabled,
    ReminderTiming? defaultReminderTiming,
    bool? favoriteTeamMatchesEnabled,
    bool? favoriteTeamMatchDayBefore,
    bool? goalAlertsEnabled,
    bool? matchStartAlertsEnabled,
    bool? matchEndAlertsEnabled,
    bool? halftimeAlertsEnabled,
    bool? redCardAlertsEnabled,
    bool? penaltyAlertsEnabled,
    bool? watchPartyInvitesEnabled,
    bool? watchPartyRemindersEnabled,
    ReminderTiming? watchPartyReminderTiming,
    bool? watchPartyUpdatesEnabled,
    bool? friendRequestsEnabled,
    bool? messagesEnabled,
    bool? mentionsEnabled,
    bool? predictionResultsEnabled,
    bool? leaderboardUpdatesEnabled,
  }) {
    return NotificationPreferencesData(
      pushNotificationsEnabled: pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      matchRemindersEnabled: matchRemindersEnabled ?? this.matchRemindersEnabled,
      defaultReminderTiming: defaultReminderTiming ?? this.defaultReminderTiming,
      favoriteTeamMatchesEnabled: favoriteTeamMatchesEnabled ?? this.favoriteTeamMatchesEnabled,
      favoriteTeamMatchDayBefore: favoriteTeamMatchDayBefore ?? this.favoriteTeamMatchDayBefore,
      goalAlertsEnabled: goalAlertsEnabled ?? this.goalAlertsEnabled,
      matchStartAlertsEnabled: matchStartAlertsEnabled ?? this.matchStartAlertsEnabled,
      matchEndAlertsEnabled: matchEndAlertsEnabled ?? this.matchEndAlertsEnabled,
      halftimeAlertsEnabled: halftimeAlertsEnabled ?? this.halftimeAlertsEnabled,
      redCardAlertsEnabled: redCardAlertsEnabled ?? this.redCardAlertsEnabled,
      penaltyAlertsEnabled: penaltyAlertsEnabled ?? this.penaltyAlertsEnabled,
      watchPartyInvitesEnabled: watchPartyInvitesEnabled ?? this.watchPartyInvitesEnabled,
      watchPartyRemindersEnabled: watchPartyRemindersEnabled ?? this.watchPartyRemindersEnabled,
      watchPartyReminderTiming: watchPartyReminderTiming ?? this.watchPartyReminderTiming,
      watchPartyUpdatesEnabled: watchPartyUpdatesEnabled ?? this.watchPartyUpdatesEnabled,
      friendRequestsEnabled: friendRequestsEnabled ?? this.friendRequestsEnabled,
      messagesEnabled: messagesEnabled ?? this.messagesEnabled,
      mentionsEnabled: mentionsEnabled ?? this.mentionsEnabled,
      predictionResultsEnabled: predictionResultsEnabled ?? this.predictionResultsEnabled,
      leaderboardUpdatesEnabled: leaderboardUpdatesEnabled ?? this.leaderboardUpdatesEnabled,
    );
  }

  /// Check if currently in quiet hours
  bool get isInQuietHours {
    if (!quietHoursEnabled) return false;

    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;

    final startParts = quietHoursStart.split(':');
    final endParts = quietHoursEnd.split(':');

    final startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
    final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

    // Handle overnight quiet hours (e.g., 22:00 to 08:00)
    if (startMinutes > endMinutes) {
      return currentMinutes >= startMinutes || currentMinutes <= endMinutes;
    }

    return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationPreferencesData &&
          runtimeType == other.runtimeType &&
          pushNotificationsEnabled == other.pushNotificationsEnabled &&
          quietHoursEnabled == other.quietHoursEnabled &&
          quietHoursStart == other.quietHoursStart &&
          quietHoursEnd == other.quietHoursEnd &&
          matchRemindersEnabled == other.matchRemindersEnabled &&
          defaultReminderTiming == other.defaultReminderTiming &&
          favoriteTeamMatchesEnabled == other.favoriteTeamMatchesEnabled &&
          favoriteTeamMatchDayBefore == other.favoriteTeamMatchDayBefore &&
          goalAlertsEnabled == other.goalAlertsEnabled &&
          matchStartAlertsEnabled == other.matchStartAlertsEnabled &&
          matchEndAlertsEnabled == other.matchEndAlertsEnabled &&
          halftimeAlertsEnabled == other.halftimeAlertsEnabled &&
          redCardAlertsEnabled == other.redCardAlertsEnabled &&
          penaltyAlertsEnabled == other.penaltyAlertsEnabled &&
          watchPartyInvitesEnabled == other.watchPartyInvitesEnabled &&
          watchPartyRemindersEnabled == other.watchPartyRemindersEnabled &&
          watchPartyReminderTiming == other.watchPartyReminderTiming &&
          watchPartyUpdatesEnabled == other.watchPartyUpdatesEnabled &&
          friendRequestsEnabled == other.friendRequestsEnabled &&
          messagesEnabled == other.messagesEnabled &&
          mentionsEnabled == other.mentionsEnabled &&
          predictionResultsEnabled == other.predictionResultsEnabled &&
          leaderboardUpdatesEnabled == other.leaderboardUpdatesEnabled;

  @override
  int get hashCode =>
      pushNotificationsEnabled.hashCode ^
      quietHoursEnabled.hashCode ^
      matchRemindersEnabled.hashCode ^
      goalAlertsEnabled.hashCode ^
      watchPartyInvitesEnabled.hashCode;
}

/// Service for managing notification preferences
class NotificationPreferencesService extends ChangeNotifier {
  static const String _logTag = 'NotificationPrefs';
  static const String _localPrefsKey = 'notification_preferences';
  static const String _firestoreCollection = 'user_notification_preferences';

  static NotificationPreferencesService? _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final PushNotificationService _pushService = PushNotificationService();

  NotificationPreferencesData _preferences = const NotificationPreferencesData();
  bool _isInitialized = false;
  SharedPreferences? _prefs;

  NotificationPreferencesService._();

  factory NotificationPreferencesService() {
    _instance ??= NotificationPreferencesService._();
    return _instance!;
  }

  /// Current preferences
  NotificationPreferencesData get preferences => _preferences;

  /// Whether the service is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize the service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadPreferences();
      _isInitialized = true;
      LoggingService.info('NotificationPreferencesService initialized', tag: _logTag);
    } catch (e) {
      LoggingService.error('Failed to initialize: $e', tag: _logTag);
    }
  }

  /// Load preferences from local storage and Firestore
  Future<void> _loadPreferences() async {
    // First, try loading from local storage for immediate access
    await _loadFromLocal();

    // Then, try to sync with Firestore if user is logged in
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      await _syncWithFirestore(userId);
    }
  }

  /// Load from local SharedPreferences
  Future<void> _loadFromLocal() async {
    if (_prefs == null) return;

    // Local preferences are stored as individual keys, loaded on demand
    // The main source of truth is Firestore, with local as a fallback
  }

  /// Sync with Firestore
  Future<void> _syncWithFirestore(String userId) async {
    try {
      final doc = await _firestore.collection(_firestoreCollection).doc(userId).get();

      if (doc.exists && doc.data() != null) {
        _preferences = NotificationPreferencesData.fromJson(doc.data()!);
        await _saveToLocal();
        notifyListeners();
        LoggingService.debug('Loaded preferences from Firestore', tag: _logTag);
      } else {
        // Create default preferences in Firestore
        await _saveToFirestore(userId);
        LoggingService.debug('Created default preferences in Firestore', tag: _logTag);
      }
    } catch (e) {
      LoggingService.error('Error syncing with Firestore: $e', tag: _logTag);
    }
  }

  /// Save to local storage
  Future<void> _saveToLocal() async {
    if (_prefs == null) return;

    try {
      final json = _preferences.toJson();
      // Store as individual keys for reliability
      for (final entry in json.entries) {
        final key = '${_localPrefsKey}_${entry.key}';
        if (entry.value is bool) {
          await _prefs!.setBool(key, entry.value);
        } else if (entry.value is int) {
          await _prefs!.setInt(key, entry.value);
        } else if (entry.value is String) {
          await _prefs!.setString(key, entry.value);
        }
      }
    } catch (e) {
      LoggingService.error('Error saving to local: $e', tag: _logTag);
    }
  }

  /// Save to Firestore
  Future<void> _saveToFirestore(String userId) async {
    try {
      await _firestore.collection(_firestoreCollection).doc(userId).set(
            _preferences.toJson(),
            SetOptions(merge: true),
          );
    } catch (e) {
      LoggingService.error('Error saving to Firestore: $e', tag: _logTag);
    }
  }

  /// Update preferences
  Future<void> updatePreferences(NotificationPreferencesData newPreferences) async {
    if (_preferences == newPreferences) return;

    _preferences = newPreferences;
    notifyListeners();

    // Save locally
    await _saveToLocal();

    // Save to Firestore if logged in
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      await _saveToFirestore(userId);
    }

    // Update FCM topic subscriptions based on new preferences
    await _updateTopicSubscriptions();

    LoggingService.debug('Preferences updated', tag: _logTag);
  }

  /// Update a single preference
  Future<void> updateSinglePreference({
    bool? pushNotificationsEnabled,
    bool? quietHoursEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
    bool? matchRemindersEnabled,
    ReminderTiming? defaultReminderTiming,
    bool? favoriteTeamMatchesEnabled,
    bool? favoriteTeamMatchDayBefore,
    bool? goalAlertsEnabled,
    bool? matchStartAlertsEnabled,
    bool? matchEndAlertsEnabled,
    bool? halftimeAlertsEnabled,
    bool? redCardAlertsEnabled,
    bool? penaltyAlertsEnabled,
    bool? watchPartyInvitesEnabled,
    bool? watchPartyRemindersEnabled,
    ReminderTiming? watchPartyReminderTiming,
    bool? watchPartyUpdatesEnabled,
    bool? friendRequestsEnabled,
    bool? messagesEnabled,
    bool? mentionsEnabled,
    bool? predictionResultsEnabled,
    bool? leaderboardUpdatesEnabled,
  }) async {
    await updatePreferences(_preferences.copyWith(
      pushNotificationsEnabled: pushNotificationsEnabled,
      quietHoursEnabled: quietHoursEnabled,
      quietHoursStart: quietHoursStart,
      quietHoursEnd: quietHoursEnd,
      matchRemindersEnabled: matchRemindersEnabled,
      defaultReminderTiming: defaultReminderTiming,
      favoriteTeamMatchesEnabled: favoriteTeamMatchesEnabled,
      favoriteTeamMatchDayBefore: favoriteTeamMatchDayBefore,
      goalAlertsEnabled: goalAlertsEnabled,
      matchStartAlertsEnabled: matchStartAlertsEnabled,
      matchEndAlertsEnabled: matchEndAlertsEnabled,
      halftimeAlertsEnabled: halftimeAlertsEnabled,
      redCardAlertsEnabled: redCardAlertsEnabled,
      penaltyAlertsEnabled: penaltyAlertsEnabled,
      watchPartyInvitesEnabled: watchPartyInvitesEnabled,
      watchPartyRemindersEnabled: watchPartyRemindersEnabled,
      watchPartyReminderTiming: watchPartyReminderTiming,
      watchPartyUpdatesEnabled: watchPartyUpdatesEnabled,
      friendRequestsEnabled: friendRequestsEnabled,
      messagesEnabled: messagesEnabled,
      mentionsEnabled: mentionsEnabled,
      predictionResultsEnabled: predictionResultsEnabled,
      leaderboardUpdatesEnabled: leaderboardUpdatesEnabled,
    ));
  }

  /// Update FCM topic subscriptions based on preferences
  Future<void> _updateTopicSubscriptions() async {
    // Goal alerts topic
    if (_preferences.goalAlertsEnabled && _preferences.pushNotificationsEnabled) {
      await _pushService.subscribeToTopic('goal_alerts');
    } else {
      await _pushService.unsubscribeFromTopic('goal_alerts');
    }

    // Match start alerts
    if (_preferences.matchStartAlertsEnabled && _preferences.pushNotificationsEnabled) {
      await _pushService.subscribeToTopic('match_start_alerts');
    } else {
      await _pushService.unsubscribeFromTopic('match_start_alerts');
    }

    // Red card alerts
    if (_preferences.redCardAlertsEnabled && _preferences.pushNotificationsEnabled) {
      await _pushService.subscribeToTopic('red_card_alerts');
    } else {
      await _pushService.unsubscribeFromTopic('red_card_alerts');
    }

    // Penalty alerts
    if (_preferences.penaltyAlertsEnabled && _preferences.pushNotificationsEnabled) {
      await _pushService.subscribeToTopic('penalty_alerts');
    } else {
      await _pushService.unsubscribeFromTopic('penalty_alerts');
    }
  }

  /// Subscribe to a specific team's notifications
  Future<void> subscribeToTeam(String teamCode) async {
    if (!_preferences.favoriteTeamMatchesEnabled) return;

    final topic = 'team_${teamCode.toLowerCase()}';
    await _pushService.subscribeToTopic(topic);
    LoggingService.info('Subscribed to team: $teamCode', tag: _logTag);
  }

  /// Unsubscribe from a specific team's notifications
  Future<void> unsubscribeFromTeam(String teamCode) async {
    final topic = 'team_${teamCode.toLowerCase()}';
    await _pushService.unsubscribeFromTopic(topic);
    LoggingService.info('Unsubscribed from team: $teamCode', tag: _logTag);
  }

  /// Check if a notification should be sent based on current preferences
  bool shouldSendNotification(String notificationType) {
    if (!_preferences.pushNotificationsEnabled) return false;
    if (_preferences.isInQuietHours) return false;

    switch (notificationType) {
      case 'goal_alert':
        return _preferences.goalAlertsEnabled;
      case 'match_start':
        return _preferences.matchStartAlertsEnabled;
      case 'match_end':
        return _preferences.matchEndAlertsEnabled;
      case 'halftime':
        return _preferences.halftimeAlertsEnabled;
      case 'red_card':
        return _preferences.redCardAlertsEnabled;
      case 'penalty':
        return _preferences.penaltyAlertsEnabled;
      case 'match_reminder':
        return _preferences.matchRemindersEnabled;
      case 'favorite_team_match':
        return _preferences.favoriteTeamMatchesEnabled;
      case 'watch_party_invite':
        return _preferences.watchPartyInvitesEnabled;
      case 'watch_party_reminder':
        return _preferences.watchPartyRemindersEnabled;
      case 'watch_party_update':
        return _preferences.watchPartyUpdatesEnabled;
      case 'friend_request':
        return _preferences.friendRequestsEnabled;
      case 'message':
        return _preferences.messagesEnabled;
      case 'mention':
        return _preferences.mentionsEnabled;
      case 'prediction_result':
        return _preferences.predictionResultsEnabled;
      case 'leaderboard_update':
        return _preferences.leaderboardUpdatesEnabled;
      default:
        return true;
    }
  }

  /// Reset preferences to defaults
  Future<void> resetToDefaults() async {
    await updatePreferences(const NotificationPreferencesData());
  }

  /// Clear cache on logout
  void clearCache() {
    _preferences = const NotificationPreferencesData();
    _isInitialized = false;
    notifyListeners();
  }
}

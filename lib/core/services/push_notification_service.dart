import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'logging_service.dart';

/// Service for managing push notifications and FCM token registration
class PushNotificationService {
  static const String _logTag = 'PushNotification';

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _currentToken;
  bool _isInitialized = false;

  /// Get the current FCM token
  String? get currentToken => _currentToken;

  /// Check if the service is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize push notification service
  /// Call this after user signs in
  Future<void> initialize() async {
    if (_isInitialized) {
      LoggingService.info('Already initialized', tag: _logTag);
      return;
    }

    try {
      // Request permission for notifications
      final settings = await _requestPermission();

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        LoggingService.info(
          'Notification permission granted: ${settings.authorizationStatus}',
          tag: _logTag,
        );

        // Get and register the FCM token
        await _getAndRegisterToken();

        // Listen for token refresh
        _messaging.onTokenRefresh.listen(_onTokenRefresh);

        // Configure foreground notification presentation
        await _configureForegroundNotifications();

        // Set up message handlers
        _setupMessageHandlers();

        _isInitialized = true;
        LoggingService.info('Push notification service initialized', tag: _logTag);
      } else {
        LoggingService.info(
          'Notification permission denied: ${settings.authorizationStatus}',
          tag: _logTag,
        );
      }
    } catch (e) {
      LoggingService.error('Error initializing push notifications: $e', tag: _logTag);
    }
  }

  /// Request notification permissions
  Future<NotificationSettings> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    return settings;
  }

  /// Get FCM token and register it in Firestore
  Future<void> _getAndRegisterToken() async {
    try {
      // Get the token
      // For web, you need to pass vapidKey
      String? token;
      if (kIsWeb) {
        // Web requires VAPID key - you'll need to configure this
        // token = await _messaging.getToken(vapidKey: 'YOUR_VAPID_KEY');
        LoggingService.info('Web FCM not configured - skipping token', tag: _logTag);
        return;
      } else {
        token = await _messaging.getToken();
      }

      if (token != null) {
        _currentToken = token;
        LoggingService.info('FCM token obtained: ${token.substring(0, 20)}...', tag: _logTag);
        await _saveTokenToFirestore(token);
      } else {
        LoggingService.error('Failed to get FCM token', tag: _logTag);
      }
    } catch (e) {
      LoggingService.error('Error getting FCM token: $e', tag: _logTag);
    }
  }

  /// Save FCM token to user's Firestore document
  Future<void> _saveTokenToFirestore(String token) async {
    final user = _auth.currentUser;
    if (user == null) {
      LoggingService.info('No user signed in, skipping token save', tag: _logTag);
      return;
    }

    try {
      // Save to users collection (for Cloud Functions to read)
      await _firestore.collection('users').doc(user.uid).set({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        'platform': _getPlatform(),
      }, SetOptions(merge: true));

      // Also update user_profiles if it exists
      final profileDoc = await _firestore.collection('user_profiles').doc(user.uid).get();
      if (profileDoc.exists) {
        await _firestore.collection('user_profiles').doc(user.uid).update({
          'fcmToken': token,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        });
      }

      LoggingService.info('FCM token saved to Firestore for user ${user.uid}', tag: _logTag);
    } catch (e) {
      LoggingService.error('Error saving FCM token to Firestore: $e', tag: _logTag);
    }
  }

  /// Handle token refresh
  void _onTokenRefresh(String newToken) {
    LoggingService.info('FCM token refreshed', tag: _logTag);
    _currentToken = newToken;
    _saveTokenToFirestore(newToken);
  }

  /// Configure how notifications appear when app is in foreground
  Future<void> _configureForegroundNotifications() async {
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// Set up message handlers for different app states
  void _setupMessageHandlers() {
    // Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification tap when app was in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Check if app was opened from a notification (when terminated)
    _checkInitialMessage();
  }

  /// Handle messages received while app is in foreground
  void _handleForegroundMessage(RemoteMessage message) {
    LoggingService.info(
      'Foreground message received: ${message.notification?.title}',
      tag: _logTag,
    );

    // The notification will be displayed automatically due to
    // setForegroundNotificationPresentationOptions

    // You can add custom handling here, like updating a badge count
    // or showing an in-app notification
  }

  /// Handle when user taps on a notification
  void _handleNotificationTap(RemoteMessage message) {
    LoggingService.info(
      'Notification tapped: ${message.data}',
      tag: _logTag,
    );

    // Handle navigation based on notification data
    _navigateFromNotification(message.data);
  }

  /// Check if app was opened from a terminated state via notification
  Future<void> _checkInitialMessage() async {
    final initialMessage = await _messaging.getInitialMessage();

    if (initialMessage != null) {
      LoggingService.info(
        'App opened from notification: ${initialMessage.data}',
        tag: _logTag,
      );
      _navigateFromNotification(initialMessage.data);
    }
  }

  /// Navigate to appropriate screen based on notification data
  void _navigateFromNotification(Map<String, dynamic> data) {
    final type = data['type'] as String?;

    switch (type) {
      case 'watch_party_invite':
        final watchPartyId = data['watchPartyId'] as String?;
        if (watchPartyId != null) {
          // Navigate to watch party detail
          // You'll need to implement this navigation
          LoggingService.info(
            'Should navigate to watch party: $watchPartyId',
            tag: _logTag,
          );
        }
        break;
      case 'watch_party_invite_response':
      case 'watch_party_cancelled':
        final watchPartyId = data['watchPartyId'] as String?;
        if (watchPartyId != null) {
          LoggingService.info(
            'Should navigate to watch party: $watchPartyId',
            tag: _logTag,
          );
        }
        break;
      default:
        LoggingService.info('Unknown notification type: $type', tag: _logTag);
    }
  }

  /// Get platform string for tracking
  String _getPlatform() {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'unknown';
  }

  /// Remove FCM token from Firestore (call on sign out)
  Future<void> removeToken() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Remove from users collection
      await _firestore.collection('users').doc(user.uid).update({
        'fcmToken': FieldValue.delete(),
        'fcmTokenUpdatedAt': FieldValue.delete(),
      });

      // Remove from user_profiles if it exists
      final profileDoc = await _firestore.collection('user_profiles').doc(user.uid).get();
      if (profileDoc.exists) {
        await _firestore.collection('user_profiles').doc(user.uid).update({
          'fcmToken': FieldValue.delete(),
          'fcmTokenUpdatedAt': FieldValue.delete(),
        });
      }

      _currentToken = null;
      LoggingService.info('FCM token removed from Firestore', tag: _logTag);
    } catch (e) {
      LoggingService.error('Error removing FCM token: $e', tag: _logTag);
    }
  }

  /// Delete the token entirely (unregister from FCM)
  Future<void> deleteToken() async {
    try {
      await removeToken();
      await _messaging.deleteToken();
      _currentToken = null;
      _isInitialized = false;
      LoggingService.info('FCM token deleted', tag: _logTag);
    } catch (e) {
      LoggingService.error('Error deleting FCM token: $e', tag: _logTag);
    }
  }

  /// Check current notification permission status
  Future<AuthorizationStatus> checkPermissionStatus() async {
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus;
  }

  /// Subscribe to a topic (e.g., for team-specific notifications)
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      LoggingService.info('Subscribed to topic: $topic', tag: _logTag);
    } catch (e) {
      LoggingService.error('Error subscribing to topic $topic: $e', tag: _logTag);
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      LoggingService.info('Unsubscribed from topic: $topic', tag: _logTag);
    } catch (e) {
      LoggingService.error('Error unsubscribing from topic $topic: $e', tag: _logTag);
    }
  }
}

/// Background message handler - must be a top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // This handler is called when app is in background or terminated
  // Firebase is already initialized by the time this is called
  debugPrint('Background message received: ${message.messageId}');

  // Handle background message processing here if needed
  // Note: You cannot update UI from here
}

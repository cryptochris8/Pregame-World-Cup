import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import '../entities/notification.dart';
import '../../../../core/services/performance_monitor.dart';

class NotificationService {
  static const String _logTag = 'NotificationService';
  static const String _notificationsBoxName = 'notifications';
  static const String _preferencesBoxName = 'notification_preferences';
  static const Duration _notificationCacheDuration = Duration(hours: 24);
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  late Box<SocialNotification> _notificationsBox;
  late Box<NotificationPreferences> _preferencesBox;
  
  // In-memory cache
  final Map<String, List<SocialNotification>> _userNotificationsCache = {};
  final Map<String, NotificationPreferences> _preferencesCache = {};

  /// Initialize the notification service
  Future<void> initialize() async {
    try {
      // Register Hive adapters if not already registered
      if (!Hive.isAdapterRegistered(16)) {
        Hive.registerAdapter(SocialNotificationAdapter());
      }
      if (!Hive.isAdapterRegistered(17)) {
        Hive.registerAdapter(NotificationTypeAdapter());
      }
      if (!Hive.isAdapterRegistered(18)) {
        Hive.registerAdapter(NotificationPriorityAdapter());
      }
      if (!Hive.isAdapterRegistered(19)) {
        Hive.registerAdapter(NotificationPreferencesAdapter());
      }
      
      _notificationsBox = await Hive.openBox<SocialNotification>(_notificationsBoxName);
      _preferencesBox = await Hive.openBox<NotificationPreferences>(_preferencesBoxName);
      
      print('NotificationService initialized successfully');
    } catch (e) {
      print('Error initializing NotificationService: $e');
      rethrow;
    }
  }

  /// Send notification to user
  Future<bool> sendNotification(SocialNotification notification) async {
    try {
      PerformanceMonitor.startApiCall('send_notification');
      
      // Check user preferences first
      final preferences = await getUserNotificationPreferences(notification.userId);
      if (!preferences.shouldNotifyForType(notification.type)) {
        print('User has disabled notifications for type: ${notification.type.name}');
        return false;
      }
      
      // Check quiet hours
      if (preferences.isInQuietHours && notification.priority != NotificationPriority.urgent) {
        print('In quiet hours, skipping non-urgent notification');
        return false;
      }
      
      // Save to Firestore
      final data = _notificationToFirestore(notification);
      await _firestore
          .collection('notifications')
          .doc(notification.notificationId)
          .set(data);
      
      // Cache locally
      await _notificationsBox.put(notification.notificationId, notification);
      
      // Clear user's notifications cache
      _userNotificationsCache.remove(notification.userId);
      
      PerformanceMonitor.endApiCall('send_notification', success: true);
      return true;
      
    } catch (e) {
      PerformanceMonitor.endApiCall('send_notification', success: false);
      print('Error sending notification: $e');
      return false;
    }
  }

  /// Get notifications for user
  Future<List<SocialNotification>> getUserNotifications(String userId, {int limit = 50, bool unreadOnly = false}) async {
    try {
      // Check memory cache first
      final cacheKey = '${userId}_${unreadOnly ? 'unread' : 'all'}';
      if (_userNotificationsCache.containsKey(cacheKey)) {
        return _userNotificationsCache[cacheKey]!.take(limit).toList();
      }
      
      PerformanceMonitor.startApiCall('get_user_notifications');
      
      var query = _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true);
      
      if (unreadOnly) {
        query = query.where('isRead', isEqualTo: false);
      }
      
      final querySnapshot = await query.limit(limit).get();
      
      final notifications = <SocialNotification>[];
      
      for (final doc in querySnapshot.docs) {
        final notification = _notificationFromFirestore(doc.data(), doc.id);
        if (notification != null) {
          notifications.add(notification);
          await _notificationsBox.put(notification.notificationId, notification);
        }
      }
      
      // Cache notifications
      _userNotificationsCache[cacheKey] = notifications;
      
      PerformanceMonitor.endApiCall('get_user_notifications', success: true);
      return notifications;
      
    } catch (e) {
      PerformanceMonitor.endApiCall('get_user_notifications', success: false);
      print('Error getting user notifications: $e');
      return [];
    }
  }

  /// Mark notification as read
  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      PerformanceMonitor.startApiCall('mark_notification_read');
      
      // Update in Firestore
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
      
      // Update local cache
      final cachedNotification = _notificationsBox.get(notificationId);
      if (cachedNotification != null) {
        final updatedNotification = cachedNotification.markAsRead();
        await _notificationsBox.put(notificationId, updatedNotification);
      }
      
      // Clear relevant caches
      _userNotificationsCache.clear();
      
      PerformanceMonitor.endApiCall('mark_notification_read', success: true);
      return true;
      
    } catch (e) {
      PerformanceMonitor.endApiCall('mark_notification_read', success: false);
      print('Error marking notification as read: $e');
      return false;
    }
  }

  /// Mark all notifications as read for user
  Future<bool> markAllNotificationsAsRead(String userId) async {
    try {
      PerformanceMonitor.startApiCall('mark_all_notifications_read');
      
      // Batch update in Firestore
      final batch = _firestore.batch();
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();
      
      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      
      await batch.commit();
      
      // Clear caches
      _userNotificationsCache.clear();
      
      PerformanceMonitor.endApiCall('mark_all_notifications_read', success: true);
      return true;
      
    } catch (e) {
      PerformanceMonitor.endApiCall('mark_all_notifications_read', success: false);
      print('Error marking all notifications as read: $e');
      return false;
    }
  }

  /// Get unread notification count
  Future<int> getUnreadNotificationCount(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();
      
      return querySnapshot.docs.length;
      
    } catch (e) {
      print('Error getting unread notification count: $e');
      return 0;
    }
  }

  /// Get user notification preferences
  Future<NotificationPreferences> getUserNotificationPreferences(String userId) async {
    try {
      // Check memory cache first
      if (_preferencesCache.containsKey(userId)) {
        return _preferencesCache[userId]!;
      }
      
      // Check local cache
      final cachedPreferences = _preferencesBox.get(userId);
      if (cachedPreferences != null) {
        _preferencesCache[userId] = cachedPreferences;
        return cachedPreferences;
      }
      
      // Fetch from Firestore
      final doc = await _firestore
          .collection('notification_preferences')
          .doc(userId)
          .get();
      
      NotificationPreferences preferences;
      if (doc.exists) {
        preferences = _preferencesFromFirestore(doc.data()!);
      } else {
        preferences = NotificationPreferences.defaultPreferences();
        // Save default preferences
        await saveUserNotificationPreferences(userId, preferences);
      }
      
      // Cache preferences
      await _preferencesBox.put(userId, preferences);
      _preferencesCache[userId] = preferences;
      
      return preferences;
      
    } catch (e) {
      print('Error getting user notification preferences: $e');
      return NotificationPreferences.defaultPreferences();
    }
  }

  /// Save user notification preferences
  Future<bool> saveUserNotificationPreferences(String userId, NotificationPreferences preferences) async {
    try {
      PerformanceMonitor.startApiCall('save_notification_preferences');
      
      final data = _preferencesToFirestore(preferences);
      await _firestore
          .collection('notification_preferences')
          .doc(userId)
          .set(data);
      
      // Update caches
      await _preferencesBox.put(userId, preferences);
      _preferencesCache[userId] = preferences;
      
      PerformanceMonitor.endApiCall('save_notification_preferences', success: true);
      return true;
      
    } catch (e) {
      PerformanceMonitor.endApiCall('save_notification_preferences', success: false);
      print('Error saving notification preferences: $e');
      return false;
    }
  }

  /// Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      // Delete from Firestore
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .delete();
      
      // Remove from local cache
      await _notificationsBox.delete(notificationId);
      
      // Clear relevant caches
      _userNotificationsCache.clear();
      
      return true;
      
    } catch (e) {
      print('Error deleting notification: $e');
      return false;
    }
  }

  /// Listen to real-time notifications for user
  Stream<List<SocialNotification>> listenToUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
      final notifications = <SocialNotification>[];
      
      for (final doc in snapshot.docs) {
        final notification = _notificationFromFirestore(doc.data(), doc.id);
        if (notification != null) {
          notifications.add(notification);
        }
      }
      
      return notifications;
    });
  }

  /// Helper methods for convenience notifications
  Future<bool> sendFriendRequestNotification({
    required String userId,
    required String fromUserId,
    required String fromUserName,
    String? fromUserImage,
    required String connectionId,
  }) async {
    final notification = SocialNotification.friendRequest(
      userId: userId,
      fromUserId: fromUserId,
      fromUserName: fromUserName,
      fromUserImage: fromUserImage,
      connectionId: connectionId,
    );
    
    return await sendNotification(notification);
  }

  Future<bool> sendFriendRequestAcceptedNotification({
    required String userId,
    required String fromUserId,
    required String fromUserName,
    String? fromUserImage,
  }) async {
    final notification = SocialNotification.friendRequestAccepted(
      userId: userId,
      fromUserId: fromUserId,
      fromUserName: fromUserName,
      fromUserImage: fromUserImage,
    );
    
    return await sendNotification(notification);
  }

  Future<bool> sendActivityLikeNotification({
    required String userId,
    required String fromUserId,
    required String fromUserName,
    String? fromUserImage,
    required String activityId,
    required String activityContent,
  }) async {
    final notification = SocialNotification.activityLike(
      userId: userId,
      fromUserId: fromUserId,
      fromUserName: fromUserName,
      fromUserImage: fromUserImage,
      activityId: activityId,
      activityContent: activityContent,
    );
    
    return await sendNotification(notification);
  }

  Future<bool> sendActivityCommentNotification({
    required String userId,
    required String fromUserId,
    required String fromUserName,
    String? fromUserImage,
    required String activityId,
    required String comment,
  }) async {
    final notification = SocialNotification.activityComment(
      userId: userId,
      fromUserId: fromUserId,
      fromUserName: fromUserName,
      fromUserImage: fromUserImage,
      activityId: activityId,
      comment: comment,
    );
    
    return await sendNotification(notification);
  }

  /// Helper conversion methods
  Map<String, dynamic> _notificationToFirestore(SocialNotification notification) {
    return {
      'userId': notification.userId,
      'fromUserId': notification.fromUserId,
      'fromUserName': notification.fromUserName,
      'fromUserImage': notification.fromUserImage,
      'type': notification.type.name,
      'title': notification.title,
      'message': notification.message,
      'createdAt': Timestamp.fromDate(notification.createdAt),
      'isRead': notification.isRead,
      'data': notification.data,
      'actionUrl': notification.actionUrl,
      'priority': notification.priority.name,
    };
  }

  SocialNotification? _notificationFromFirestore(Map<String, dynamic> data, String id) {
    try {
      return SocialNotification(
        notificationId: id,
        userId: data['userId'],
        fromUserId: data['fromUserId'],
        fromUserName: data['fromUserName'],
        fromUserImage: data['fromUserImage'],
        type: NotificationType.values.firstWhere((e) => e.name == data['type']),
        title: data['title'],
        message: data['message'],
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        isRead: data['isRead'] ?? false,
        data: Map<String, dynamic>.from(data['data'] ?? {}),
        actionUrl: data['actionUrl'],
        priority: NotificationPriority.values.firstWhere((e) => e.name == data['priority']),
      );
    } catch (e) {
      print('Error parsing notification from Firestore: $e');
      return null;
    }
  }

  Map<String, dynamic> _preferencesToFirestore(NotificationPreferences preferences) {
    return {
      'friendRequests': preferences.friendRequests,
      'activityLikes': preferences.activityLikes,
      'activityComments': preferences.activityComments,
      'gameInvites': preferences.gameInvites,
      'venueRecommendations': preferences.venueRecommendations,
      'newFollowers': preferences.newFollowers,
      'groupActivity': preferences.groupActivity,
      'achievements': preferences.achievements,
      'systemUpdates': preferences.systemUpdates,
      'pushNotifications': preferences.pushNotifications,
      'emailNotifications': preferences.emailNotifications,
      'quietHoursStart': preferences.quietHoursStart,
      'quietHoursEnd': preferences.quietHoursEnd,
    };
  }

  NotificationPreferences _preferencesFromFirestore(Map<String, dynamic> data) {
    return NotificationPreferences(
      friendRequests: data['friendRequests'] ?? true,
      activityLikes: data['activityLikes'] ?? true,
      activityComments: data['activityComments'] ?? true,
      gameInvites: data['gameInvites'] ?? true,
      venueRecommendations: data['venueRecommendations'] ?? true,
      newFollowers: data['newFollowers'] ?? true,
      groupActivity: data['groupActivity'] ?? true,
      achievements: data['achievements'] ?? true,
      systemUpdates: data['systemUpdates'] ?? true,
      pushNotifications: data['pushNotifications'] ?? true,
      emailNotifications: data['emailNotifications'] ?? false,
      quietHoursStart: data['quietHoursStart'] ?? '22:00',
      quietHoursEnd: data['quietHoursEnd'] ?? '08:00',
    );
  }

  /// Get service statistics
  Map<String, dynamic> getServiceStats() {
    return {
      'cached_notifications': _notificationsBox.length,
      'cached_preferences': _preferencesBox.length,
      'memory_notifications': _userNotificationsCache.length,
      'memory_preferences': _preferencesCache.length,
    };
  }

  // Get unread notification count stream
  Stream<int> getUnreadCount(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
} 
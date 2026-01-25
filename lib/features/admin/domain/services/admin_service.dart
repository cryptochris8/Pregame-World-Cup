import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/services/logging_service.dart';
import '../../../../core/services/push_notification_service.dart';
import '../../../moderation/domain/entities/report.dart';
import '../../../moderation/domain/services/moderation_service.dart';
import '../../../social/domain/entities/user_profile.dart';
import '../../../watch_party/domain/entities/watch_party.dart';
import '../entities/admin_user.dart';

/// Service for admin operations
class AdminService {
  static const String _logTag = 'AdminService';
  static const String _adminsCollection = 'admins';
  static const String _featureFlagsCollection = 'feature_flags';
  static const String _statsCollection = 'admin_stats';
  static const String _adminLogsCollection = 'admin_logs';

  static AdminService? _instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final ModerationService _moderationService;
  // ignore: unused_field
  final PushNotificationService _pushService; // Used for future direct push

  AdminUser? _currentAdminUser;
  bool _isInitialized = false;

  AdminService._({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    ModerationService? moderationService,
    PushNotificationService? pushService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _moderationService = moderationService ?? ModerationService(),
        _pushService = pushService ?? PushNotificationService();

  factory AdminService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    ModerationService? moderationService,
    PushNotificationService? pushService,
  }) {
    _instance ??= AdminService._(
      firestore: firestore,
      auth: auth,
      moderationService: moderationService,
      pushService: pushService,
    );
    return _instance!;
  }

  /// Current admin user (if authenticated as admin)
  AdminUser? get currentAdminUser => _currentAdminUser;

  /// Whether the current user is an admin
  bool get isAdmin => _currentAdminUser != null && _currentAdminUser!.isActive;

  /// Current admin role
  AdminRole? get currentRole => _currentAdminUser?.role;

  /// Initialize the admin service and check admin status
  Future<void> initialize() async {
    if (_isInitialized) return;

    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      _isInitialized = true;
      return;
    }

    try {
      final adminDoc = await _firestore.collection(_adminsCollection).doc(userId).get();

      if (adminDoc.exists && adminDoc.data() != null) {
        _currentAdminUser = AdminUser.fromJson(adminDoc.data()!);

        // Update last login
        await _firestore.collection(_adminsCollection).doc(userId).update({
          'lastLoginAt': DateTime.now().toIso8601String(),
        });

        LoggingService.info(
          'Admin authenticated: ${_currentAdminUser!.displayName} (${_currentAdminUser!.role.displayName})',
          tag: _logTag,
        );
      }

      _isInitialized = true;
    } catch (e) {
      LoggingService.error('Error initializing admin service: $e', tag: _logTag);
      _isInitialized = true;
    }
  }

  /// Check if current user has a specific permission
  bool hasPermission(String permission) {
    if (_currentAdminUser == null) return false;
    return _currentAdminUser!.hasPermission(permission);
  }

  // ==================== DASHBOARD STATS ====================

  /// Get dashboard statistics
  Future<AdminDashboardStats> getDashboardStats() async {
    if (!isAdmin) return AdminDashboardStats.empty();

    try {
      // Try to get cached stats first
      final statsDoc = await _firestore.collection(_statsCollection).doc('dashboard').get();

      if (statsDoc.exists && statsDoc.data() != null) {
        final stats = AdminDashboardStats.fromJson(statsDoc.data()!);
        // If stats are less than 5 minutes old, use them
        if (DateTime.now().difference(stats.updatedAt).inMinutes < 5) {
          return stats;
        }
      }

      // Calculate fresh stats
      return await _calculateDashboardStats();
    } catch (e) {
      LoggingService.error('Error getting dashboard stats: $e', tag: _logTag);
      return AdminDashboardStats.empty();
    }
  }

  Future<AdminDashboardStats> _calculateDashboardStats() async {
    try {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(hours: 24));
      final todayStart = DateTime(now.year, now.month, now.day);

      // Get counts (using aggregation where possible)
      final usersCount = await _firestore.collection('user_profiles').count().get();
      final watchPartiesCount = await _firestore.collection('watch_parties').count().get();
      final pendingReportsCount = await _firestore
          .collection('reports')
          .where('status', isEqualTo: 'pending')
          .count()
          .get();

      // Active users (users who logged in within 24h)
      final activeUsersCount = await _firestore
          .collection('user_profiles')
          .where('lastSeenAt', isGreaterThan: Timestamp.fromDate(yesterday))
          .count()
          .get();

      // New users today
      final newUsersCount = await _firestore
          .collection('user_profiles')
          .where('createdAt', isGreaterThan: Timestamp.fromDate(todayStart))
          .count()
          .get();

      // Active watch parties (with upcoming matches)
      final activeWatchPartiesCount = await _firestore
          .collection('watch_parties')
          .where('matchDate', isGreaterThan: Timestamp.fromDate(now))
          .count()
          .get();

      final stats = AdminDashboardStats(
        totalUsers: usersCount.count ?? 0,
        activeUsers24h: activeUsersCount.count ?? 0,
        newUsersToday: newUsersCount.count ?? 0,
        totalWatchParties: watchPartiesCount.count ?? 0,
        activeWatchParties: activeWatchPartiesCount.count ?? 0,
        pendingReports: pendingReportsCount.count ?? 0,
        totalPredictions: 0, // TODO: Add predictions count
        totalMessages: 0, // TODO: Add messages count
        updatedAt: now,
      );

      // Cache the stats
      await _firestore.collection(_statsCollection).doc('dashboard').set({
        ...stats.toJson(),
      });

      return stats;
    } catch (e) {
      LoggingService.error('Error calculating dashboard stats: $e', tag: _logTag);
      return AdminDashboardStats.empty();
    }
  }

  // ==================== USER MANAGEMENT ====================

  /// Search users
  Future<List<UserProfile>> searchUsers({
    String? query,
    int limit = 50,
    DocumentSnapshot? startAfter,
  }) async {
    if (!isAdmin || !_currentAdminUser!.role.canManageUsers()) {
      return [];
    }

    try {
      Query<Map<String, dynamic>> queryRef = _firestore.collection('user_profiles');

      if (query != null && query.isNotEmpty) {
        // Search by display name or email
        queryRef = queryRef
            .where('displayName', isGreaterThanOrEqualTo: query)
            .where('displayName', isLessThanOrEqualTo: '$query\uf8ff');
      }

      queryRef = queryRef.orderBy('displayName').limit(limit);

      if (startAfter != null) {
        queryRef = queryRef.startAfterDocument(startAfter);
      }

      final snapshot = await queryRef.get();

      return snapshot.docs
          .map((doc) => UserProfile.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      LoggingService.error('Error searching users: $e', tag: _logTag);
      return [];
    }
  }

  /// Get user by ID
  Future<UserProfile?> getUserById(String userId) async {
    if (!isAdmin) return null;

    try {
      final doc = await _firestore.collection('user_profiles').doc(userId).get();
      if (!doc.exists) return null;
      return UserProfile.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      LoggingService.error('Error getting user: $e', tag: _logTag);
      return null;
    }
  }

  /// Suspend user
  Future<bool> suspendUser(String userId, String reason, Duration duration) async {
    if (!isAdmin || !_currentAdminUser!.role.canManageUsers()) return false;

    try {
      await _moderationService.suspendUser(
        userId: userId,
        reason: reason,
        duration: duration,
      );

      await _logAdminAction('suspend_user', {
        'userId': userId,
        'reason': reason,
        'durationHours': duration.inHours,
      });

      return true;
    } catch (e) {
      LoggingService.error('Error suspending user: $e', tag: _logTag);
      return false;
    }
  }

  /// Ban user permanently
  Future<bool> banUser(String userId, String reason) async {
    if (!isAdmin || !_currentAdminUser!.role.canManageUsers()) return false;

    try {
      await _moderationService.banUser(userId: userId, reason: reason);

      await _logAdminAction('ban_user', {
        'userId': userId,
        'reason': reason,
      });

      return true;
    } catch (e) {
      LoggingService.error('Error banning user: $e', tag: _logTag);
      return false;
    }
  }

  /// Delete user (soft delete - marks as deleted)
  Future<bool> deleteUser(String userId, String reason) async {
    if (!isAdmin || _currentAdminUser!.role != AdminRole.superAdmin) return false;

    try {
      await _firestore.collection('user_profiles').doc(userId).update({
        'isDeleted': true,
        'deletedAt': FieldValue.serverTimestamp(),
        'deletedBy': _currentAdminUser!.userId,
        'deletionReason': reason,
      });

      await _logAdminAction('delete_user', {
        'userId': userId,
        'reason': reason,
      });

      return true;
    } catch (e) {
      LoggingService.error('Error deleting user: $e', tag: _logTag);
      return false;
    }
  }

  // ==================== WATCH PARTY MANAGEMENT ====================

  /// Get watch parties with filters
  Future<List<WatchParty>> getWatchParties({
    bool? isActive,
    int limit = 50,
    DocumentSnapshot? startAfter,
  }) async {
    if (!isAdmin || !_currentAdminUser!.role.canManageWatchParties()) {
      return [];
    }

    try {
      Query<Map<String, dynamic>> queryRef = _firestore.collection('watch_parties');

      if (isActive == true) {
        queryRef = queryRef.where('matchDate', isGreaterThan: Timestamp.now());
      }

      queryRef = queryRef.orderBy('matchDate', descending: true).limit(limit);

      if (startAfter != null) {
        queryRef = queryRef.startAfterDocument(startAfter);
      }

      final snapshot = await queryRef.get();

      return snapshot.docs.map((doc) => WatchParty.fromFirestore(doc.data(), doc.id)).toList();
    } catch (e) {
      LoggingService.error('Error getting watch parties: $e', tag: _logTag);
      return [];
    }
  }

  /// Delete watch party
  Future<bool> deleteWatchParty(String partyId, String reason) async {
    if (!isAdmin || !_currentAdminUser!.role.canManageWatchParties()) return false;

    try {
      await _firestore.collection('watch_parties').doc(partyId).update({
        'isDeleted': true,
        'deletedAt': FieldValue.serverTimestamp(),
        'deletedBy': _currentAdminUser!.userId,
        'deletionReason': reason,
      });

      await _logAdminAction('delete_watch_party', {
        'partyId': partyId,
        'reason': reason,
      });

      return true;
    } catch (e) {
      LoggingService.error('Error deleting watch party: $e', tag: _logTag);
      return false;
    }
  }

  // ==================== CONTENT MODERATION ====================

  /// Get pending reports
  Future<List<Report>> getPendingReports({int limit = 50}) async {
    if (!isAdmin || !_currentAdminUser!.role.canModerateContent()) {
      return [];
    }

    return _moderationService.getPendingReports(limit: limit);
  }

  /// Resolve a report
  Future<bool> resolveReport(String reportId, ModerationAction action, String? notes) async {
    if (!isAdmin || !_currentAdminUser!.role.canModerateContent()) return false;

    final result = await _moderationService.resolveReport(
      reportId: reportId,
      action: action,
      moderatorNotes: notes,
    );

    if (result) {
      await _logAdminAction('resolve_report', {
        'reportId': reportId,
        'action': action.name,
        'notes': notes,
      });
    }

    return result;
  }

  // ==================== FEATURE FLAGS ====================

  /// Get all feature flags
  Future<List<FeatureFlag>> getFeatureFlags() async {
    if (!isAdmin) return [];

    try {
      final snapshot = await _firestore.collection(_featureFlagsCollection).get();
      return snapshot.docs.map((doc) => FeatureFlag.fromJson(doc.data())).toList();
    } catch (e) {
      LoggingService.error('Error getting feature flags: $e', tag: _logTag);
      return [];
    }
  }

  /// Update feature flag
  Future<bool> updateFeatureFlag(String flagId, bool isEnabled) async {
    if (!isAdmin || !_currentAdminUser!.role.canManageFeatureFlags()) return false;

    try {
      await _firestore.collection(_featureFlagsCollection).doc(flagId).update({
        'isEnabled': isEnabled,
        'updatedAt': DateTime.now().toIso8601String(),
        'updatedBy': _currentAdminUser!.userId,
      });

      await _logAdminAction('update_feature_flag', {
        'flagId': flagId,
        'isEnabled': isEnabled,
      });

      return true;
    } catch (e) {
      LoggingService.error('Error updating feature flag: $e', tag: _logTag);
      return false;
    }
  }

  /// Create a new feature flag
  Future<bool> createFeatureFlag(String name, String description) async {
    if (!isAdmin || !_currentAdminUser!.role.canManageFeatureFlags()) return false;

    try {
      final flagId = name.toLowerCase().replaceAll(' ', '_');
      final flag = FeatureFlag(
        id: flagId,
        name: name,
        description: description,
        isEnabled: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        updatedBy: _currentAdminUser!.userId,
      );

      await _firestore.collection(_featureFlagsCollection).doc(flagId).set(flag.toJson());

      await _logAdminAction('create_feature_flag', {
        'flagId': flagId,
        'name': name,
      });

      return true;
    } catch (e) {
      LoggingService.error('Error creating feature flag: $e', tag: _logTag);
      return false;
    }
  }

  // ==================== PUSH NOTIFICATIONS ====================

  /// Send push notification to users
  Future<bool> sendBroadcastNotification({
    required String title,
    required String body,
    NotificationAudience audience = NotificationAudience.allUsers,
    String? teamCode,
    String? topic,
    Map<String, String>? data,
  }) async {
    if (!isAdmin || !_currentAdminUser!.role.canSendPushNotifications()) return false;

    try {
      // Determine the FCM topic based on audience
      String targetTopic;
      switch (audience) {
        case NotificationAudience.allUsers:
          targetTopic = topic ?? 'all_users';
          break;
        case NotificationAudience.premiumUsers:
          targetTopic = 'premium_users';
          break;
        case NotificationAudience.teamFans:
          if (teamCode == null) return false;
          targetTopic = 'team_${teamCode.toLowerCase()}';
          break;
        case NotificationAudience.activeUsers:
          targetTopic = 'active_users';
          break;
      }

      // Store the notification for Cloud Functions to send
      await _firestore.collection('broadcast_notifications').add({
        'title': title,
        'body': body,
        'topic': targetTopic,
        'audience': audience.name,
        'teamCode': teamCode,
        'data': data,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': _currentAdminUser!.userId,
        'status': 'pending',
      });

      await _logAdminAction('send_broadcast_notification', {
        'title': title,
        'topic': targetTopic,
        'audience': audience.name,
        'teamCode': teamCode,
      });

      return true;
    } catch (e) {
      LoggingService.error('Error sending broadcast notification: $e', tag: _logTag);
      return false;
    }
  }

  // ==================== ADMIN LOGGING ====================

  Future<void> _logAdminAction(String action, Map<String, dynamic> details) async {
    try {
      await _firestore.collection(_adminLogsCollection).add({
        'action': action,
        'adminId': _currentAdminUser!.userId,
        'adminEmail': _currentAdminUser!.email,
        'adminRole': _currentAdminUser!.role.name,
        'details': details,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      LoggingService.error('Error logging admin action: $e', tag: _logTag);
    }
  }

  /// Get admin activity logs
  Future<List<Map<String, dynamic>>> getAdminLogs({int limit = 100}) async {
    if (!isAdmin || _currentAdminUser!.role != AdminRole.superAdmin) return [];

    try {
      final snapshot = await _firestore
          .collection(_adminLogsCollection)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      LoggingService.error('Error getting admin logs: $e', tag: _logTag);
      return [];
    }
  }

  /// Clear cached data
  void clearCache() {
    _currentAdminUser = null;
    _isInitialized = false;
  }
}

extension AdminDashboardStatsToJson on AdminDashboardStats {
  Map<String, dynamic> toJson() => {
        'totalUsers': totalUsers,
        'activeUsers24h': activeUsers24h,
        'newUsersToday': newUsersToday,
        'totalWatchParties': totalWatchParties,
        'activeWatchParties': activeWatchParties,
        'pendingReports': pendingReports,
        'totalPredictions': totalPredictions,
        'totalMessages': totalMessages,
        'updatedAt': updatedAt.toIso8601String(),
      };
}

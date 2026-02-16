import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import '../entities/social_connection.dart';
import '../../../../core/services/performance_monitor.dart';
import '../../../../core/services/logging_service.dart';
import 'social_profile_service.dart';

/// Handles friend request management, connections, blocking, and friend suggestions.
/// Manages the social_connections Firestore collection and local Hive cache.
class SocialFriendService {
  static const String _logTag = 'SocialFriendService';
  static const String _connectionsBoxName = 'social_connections';

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final SocialProfileService _profileService;

  late Box<SocialConnection> connectionsBox;

  // In-memory cache for connections
  final Map<String, List<SocialConnection>> connectionMemoryCache = {};

  SocialFriendService({
    required SocialProfileService profileService,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _profileService = profileService,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Initialize with the connections Hive box
  Future<void> initialize(Box<SocialConnection> box) async {
    connectionsBox = box;
    LoggingService.info('SocialFriendService initialized', tag: _logTag);
  }

  /// Open and return the connections Hive box
  static Future<Box<SocialConnection>> openBox() async {
    return await Hive.openBox<SocialConnection>(_connectionsBoxName);
  }

  /// Send friend request
  Future<bool> sendFriendRequest(String targetUserId, {String? source}) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      PerformanceMonitor.startApiCall('send_friend_request');

      final connection = SocialConnection.createFriendRequest(
        fromUserId: currentUser.uid,
        toUserId: targetUserId,
        source: source,
      );

      await _firestore.collection('social_connections').doc(connection.connectionId).set({
        'fromUserId': connection.fromUserId,
        'toUserId': connection.toUserId,
        'type': connection.type.name,
        'status': connection.status.name,
        'createdAt': Timestamp.fromDate(connection.createdAt),
        'connectionSource': connection.connectionSource,
        'metadata': connection.metadata,
      });

      // Cache locally
      await connectionsBox.put(connection.connectionId, connection);

      // Trigger push notification for friend request
      await _triggerFriendRequestNotification(
        targetUserId: targetUserId,
        connectionId: connection.connectionId,
      );

      PerformanceMonitor.endApiCall('send_friend_request', success: true);
      return true;
    } catch (e) {
      PerformanceMonitor.endApiCall('send_friend_request', success: false);
      LoggingService.error('Error sending friend request: $e', tag: _logTag);
      return false;
    }
  }

  /// Trigger push notification for friend request
  Future<void> _triggerFriendRequestNotification({
    required String targetUserId,
    required String connectionId,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      final senderProfile = await _profileService.getUserProfile(currentUser.uid);

      await _firestore.collection('friend_request_notifications').add({
        'connectionId': connectionId,
        'fromUserId': currentUser.uid,
        'fromUserName': senderProfile?.displayName ?? currentUser.displayName ?? 'Someone',
        'fromUserImageUrl': senderProfile?.profileImageUrl ?? currentUser.photoURL,
        'toUserId': targetUserId,
        'createdAt': FieldValue.serverTimestamp(),
        'processed': false,
        'type': 'friend_request',
      });

      LoggingService.info('Created friend request notification for $targetUserId', tag: _logTag);
    } catch (e) {
      LoggingService.error('Error triggering friend request notification: $e', tag: _logTag);
    }
  }

  /// Accept friend request
  Future<bool> acceptFriendRequest(String connectionId) async {
    try {
      PerformanceMonitor.startApiCall('accept_friend_request');

      final connection = await _getConnection(connectionId);
      if (connection == null) return false;

      final acceptedConnection = connection.accept();

      await _firestore.collection('social_connections').doc(connectionId).update({
        'status': acceptedConnection.status.name,
        'acceptedAt': Timestamp.fromDate(acceptedConnection.acceptedAt!),
      });

      // Update cache
      await connectionsBox.put(connectionId, acceptedConnection);

      // Update social stats for both users
      await _profileService.incrementSocialStat(connection.fromUserId, 'friendsCount');
      await _profileService.incrementSocialStat(connection.toUserId, 'friendsCount');

      // Notify the original sender that their request was accepted
      await _triggerFriendRequestAcceptedNotification(
        originalSenderId: connection.fromUserId,
        connectionId: connectionId,
      );

      PerformanceMonitor.endApiCall('accept_friend_request', success: true);
      return true;
    } catch (e) {
      PerformanceMonitor.endApiCall('accept_friend_request', success: false);
      LoggingService.error('Error accepting friend request: $e', tag: _logTag);
      return false;
    }
  }

  /// Trigger push notification when friend request is accepted
  Future<void> _triggerFriendRequestAcceptedNotification({
    required String originalSenderId,
    required String connectionId,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      final acceptorProfile = await _profileService.getUserProfile(currentUser.uid);

      await _firestore.collection('friend_request_notifications').add({
        'connectionId': connectionId,
        'fromUserId': currentUser.uid,
        'fromUserName': acceptorProfile?.displayName ?? currentUser.displayName ?? 'Someone',
        'fromUserImageUrl': acceptorProfile?.profileImageUrl ?? currentUser.photoURL,
        'toUserId': originalSenderId,
        'createdAt': FieldValue.serverTimestamp(),
        'processed': false,
        'type': 'friend_request_accepted',
      });

      LoggingService.info('Created friend request accepted notification for $originalSenderId', tag: _logTag);
    } catch (e) {
      LoggingService.error('Error triggering friend request accepted notification: $e', tag: _logTag);
    }
  }

  /// Get user's connections
  Future<List<SocialConnection>> getUserConnections(String userId) async {
    try {
      // Check memory cache
      if (connectionMemoryCache.containsKey(userId)) {
        return connectionMemoryCache[userId]!;
      }

      PerformanceMonitor.startApiCall('get_user_connections');

      final query = await _firestore
          .collection('social_connections')
          .where('fromUserId', isEqualTo: userId)
          .get();

      final query2 = await _firestore
          .collection('social_connections')
          .where('toUserId', isEqualTo: userId)
          .get();

      final connections = <SocialConnection>[];

      for (final doc in [...query.docs, ...query2.docs]) {
        final data = doc.data();
        final connection = SocialConnection(
          connectionId: doc.id,
          fromUserId: data['fromUserId'],
          toUserId: data['toUserId'],
          type: ConnectionType.values.firstWhere((e) => e.name == data['type']),
          status: ConnectionStatus.values.firstWhere((e) => e.name == data['status']),
          createdAt: (data['createdAt'] as Timestamp).toDate(),
          acceptedAt: data['acceptedAt'] != null
              ? (data['acceptedAt'] as Timestamp).toDate()
              : null,
          connectionSource: data['connectionSource'],
          metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
        );

        connections.add(connection);
        await connectionsBox.put(connection.connectionId, connection);
      }

      // Cache in memory
      connectionMemoryCache[userId] = connections;

      PerformanceMonitor.endApiCall('get_user_connections', success: true);
      return connections;
    } catch (e) {
      PerformanceMonitor.endApiCall('get_user_connections', success: false);
      LoggingService.error('Error getting user connections: $e', tag: _logTag);
      return [];
    }
  }

  /// Get friend suggestions for user
  Future<List<FriendSuggestion>> getFriendSuggestions(String userId, {int limit = 10}) async {
    try {
      PerformanceMonitor.startApiCall('get_friend_suggestions');

      final currentProfile = await _profileService.getUserProfile(userId);
      if (currentProfile == null) return [];

      final userConnections = await getUserConnections(userId);
      final friendIds = userConnections
          .where((c) => c.isFriend)
          .map((c) => c.fromUserId == userId ? c.toUserId : c.fromUserId)
          .toSet();

      final suggestions = <FriendSuggestion>[];

      // Query users with shared favorite teams
      for (final team in currentProfile.favoriteTeams) {
        final query = await _firestore
            .collection('user_profiles')
            .where('favoriteTeams', arrayContains: team)
            .limit(20)
            .get();

        for (final doc in query.docs) {
          final otherUserId = doc.id;
          if (otherUserId == userId || friendIds.contains(otherUserId)) continue;

          final data = doc.data();
          final suggestion = FriendSuggestion(
            userId: otherUserId,
            displayName: data['displayName'] ?? 'Unknown User',
            profileImageUrl: data['profileImageUrl'],
            sharedTeams: [team],
            connectionReason: 'Fan of $team',
            relevanceScore: 0.7,
            suggestedAt: DateTime.now(),
          );

          suggestions.add(suggestion);
        }
      }

      // Sort by relevance and limit
      suggestions.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
      final limitedSuggestions = suggestions.take(limit).toList();

      PerformanceMonitor.endApiCall('get_friend_suggestions', success: true);
      return limitedSuggestions;
    } catch (e) {
      PerformanceMonitor.endApiCall('get_friend_suggestions', success: false);
      LoggingService.error('Error getting friend suggestions: $e', tag: _logTag);
      return [];
    }
  }

  /// Decline friend request
  Future<bool> declineFriendRequest(String connectionId) async {
    try {
      PerformanceMonitor.startApiCall('decline_friend_request');

      await _firestore.collection('social_connections').doc(connectionId).delete();
      await connectionsBox.delete(connectionId);
      connectionMemoryCache.clear();

      PerformanceMonitor.endApiCall('decline_friend_request', success: true);
      return true;
    } catch (e) {
      PerformanceMonitor.endApiCall('decline_friend_request', success: false);
      LoggingService.error('Error declining friend request: $e', tag: _logTag);
      return false;
    }
  }

  /// Cancel friend request (for outgoing requests)
  Future<bool> cancelFriendRequest(String connectionId) async {
    try {
      PerformanceMonitor.startApiCall('cancel_friend_request');

      await _firestore.collection('social_connections').doc(connectionId).delete();
      await connectionsBox.delete(connectionId);
      connectionMemoryCache.clear();

      PerformanceMonitor.endApiCall('cancel_friend_request', success: true);
      return true;
    } catch (e) {
      PerformanceMonitor.endApiCall('cancel_friend_request', success: false);
      LoggingService.error('Error cancelling friend request: $e', tag: _logTag);
      return false;
    }
  }

  /// Remove friend
  Future<bool> removeFriend(String userId, String friendId) async {
    try {
      PerformanceMonitor.startApiCall('remove_friend');

      final userConnections = await getUserConnections(userId);
      final friendshipConnection = userConnections.firstWhere(
        (c) => (c.fromUserId == friendId || c.toUserId == friendId) && c.isFriend,
        orElse: () => throw Exception('Friendship not found'),
      );

      await _firestore.collection('social_connections').doc(friendshipConnection.connectionId).delete();
      await connectionsBox.delete(friendshipConnection.connectionId);

      // Update social stats for both users
      await _profileService.decrementSocialStat(userId, 'friendsCount');
      await _profileService.decrementSocialStat(friendId, 'friendsCount');

      connectionMemoryCache.clear();

      PerformanceMonitor.endApiCall('remove_friend', success: true);
      return true;
    } catch (e) {
      PerformanceMonitor.endApiCall('remove_friend', success: false);
      LoggingService.error('Error removing friend: $e', tag: _logTag);
      return false;
    }
  }

  /// Block user
  Future<bool> blockUser(String userId, String blockedUserId) async {
    try {
      PerformanceMonitor.startApiCall('block_user');

      // First remove any existing friendship
      try {
        await removeFriend(userId, blockedUserId);
      } catch (e) {
        // Friendship might not exist, that's okay
      }

      final blockConnection = SocialConnection(
        connectionId: '${userId}_blocks_$blockedUserId',
        fromUserId: userId,
        toUserId: blockedUserId,
        type: ConnectionType.block,
        status: ConnectionStatus.accepted,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('social_connections').doc(blockConnection.connectionId).set({
        'fromUserId': blockConnection.fromUserId,
        'toUserId': blockConnection.toUserId,
        'type': blockConnection.type.name,
        'status': blockConnection.status.name,
        'createdAt': Timestamp.fromDate(blockConnection.createdAt),
        'connectionSource': 'user_action',
        'metadata': {'reason': 'blocked_by_user'},
      });

      await connectionsBox.put(blockConnection.connectionId, blockConnection);
      connectionMemoryCache.clear();

      PerformanceMonitor.endApiCall('block_user', success: true);
      return true;
    } catch (e) {
      PerformanceMonitor.endApiCall('block_user', success: false);
      LoggingService.error('Error blocking user: $e', tag: _logTag);
      return false;
    }
  }

  /// Unblock a user
  Future<bool> unblockUser(String userId, String blockedUserId) async {
    try {
      final blockConnectionId = '${userId}_blocks_$blockedUserId';
      await _firestore.collection('social_connections').doc(blockConnectionId).delete();
      await connectionsBox.delete(blockConnectionId);
      connectionMemoryCache.clear();
      LoggingService.info('User $userId unblocked $blockedUserId', tag: _logTag);
      return true;
    } catch (e) {
      LoggingService.error('Error unblocking user: $e', tag: _logTag);
      return false;
    }
  }

  /// Check if a user is blocked by another user (either direction)
  Future<bool> isUserBlocked(String userId1, String userId2) async {
    try {
      final block1Id = '${userId1}_blocks_$userId2';
      final block1Doc = await _firestore.collection('social_connections').doc(block1Id).get();
      if (block1Doc.exists) {
        final data = block1Doc.data();
        if (data?['type'] == 'block') return true;
      }

      final block2Id = '${userId2}_blocks_$userId1';
      final block2Doc = await _firestore.collection('social_connections').doc(block2Id).get();
      if (block2Doc.exists) {
        final data = block2Doc.data();
        if (data?['type'] == 'block') return true;
      }

      return false;
    } catch (e) {
      LoggingService.error('Error checking block status: $e', tag: _logTag);
      return false;
    }
  }

  /// Check if current user has blocked a specific user
  Future<bool> hasBlockedUser(String blockedUserId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      final blockId = '${currentUser.uid}_blocks_$blockedUserId';
      final doc = await _firestore.collection('social_connections').doc(blockId).get();
      return doc.exists && doc.data()?['type'] == 'block';
    } catch (e) {
      LoggingService.error('Error checking if user is blocked: $e', tag: _logTag);
      return false;
    }
  }

  /// Check if current user is blocked by a specific user
  Future<bool> isBlockedByUser(String userId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      final blockId = '${userId}_blocks_${currentUser.uid}';
      final doc = await _firestore.collection('social_connections').doc(blockId).get();
      return doc.exists && doc.data()?['type'] == 'block';
    } catch (e) {
      LoggingService.error('Error checking if blocked by user: $e', tag: _logTag);
      return false;
    }
  }

  /// Get list of users blocked by current user
  Future<List<String>> getBlockedUserIds() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return [];

    try {
      final snapshot = await _firestore
          .collection('social_connections')
          .where('fromUserId', isEqualTo: currentUser.uid)
          .where('type', isEqualTo: 'block')
          .get();

      return snapshot.docs
          .map((doc) => doc.data()['toUserId'] as String)
          .toList();
    } catch (e) {
      LoggingService.error('Error getting blocked users: $e', tag: _logTag);
      return [];
    }
  }

  // -- Private helpers --

  Future<SocialConnection?> _getConnection(String connectionId) async {
    try {
      final cached = connectionsBox.get(connectionId);
      if (cached != null) return cached;

      final doc = await _firestore.collection('social_connections').doc(connectionId).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      return SocialConnection(
        connectionId: doc.id,
        fromUserId: data['fromUserId'],
        toUserId: data['toUserId'],
        type: ConnectionType.values.firstWhere((e) => e.name == data['type']),
        status: ConnectionStatus.values.firstWhere((e) => e.name == data['status']),
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        acceptedAt: data['acceptedAt'] != null
            ? (data['acceptedAt'] as Timestamp).toDate()
            : null,
        connectionSource: data['connectionSource'],
        metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      );
    } catch (e) {
      LoggingService.error('Error getting connection: $e', tag: _logTag);
      return null;
    }
  }
}

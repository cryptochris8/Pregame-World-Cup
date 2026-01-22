import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import '../entities/user_profile.dart';
import '../entities/social_connection.dart';
import '../../../../core/services/performance_monitor.dart';
import '../../../../core/services/logging_service.dart';

class SocialService {
  static const String _logTag = 'SocialService';
  static const String _profilesBoxName = 'user_profiles';
  static const String _connectionsBoxName = 'social_connections';
  static const Duration _profileCacheDuration = Duration(hours: 6);
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  late Box<UserProfile> _profilesBox;
  late Box<SocialConnection> _connectionsBox;
  
  // In-memory cache for active session
  final Map<String, UserProfile> _profileMemoryCache = {};
  final Map<String, List<SocialConnection>> _connectionMemoryCache = {};

  /// Initialize the social service with local caching
  Future<void> initialize() async {
    try {
      // Register Hive adapters if not already registered
      if (!Hive.isAdapterRegistered(4)) {
        Hive.registerAdapter(UserProfileAdapter());
      }
      if (!Hive.isAdapterRegistered(5)) {
        Hive.registerAdapter(UserPreferencesAdapter());
      }
      if (!Hive.isAdapterRegistered(6)) {
        Hive.registerAdapter(SocialStatsAdapter());
      }
      if (!Hive.isAdapterRegistered(7)) {
        Hive.registerAdapter(UserPrivacySettingsAdapter());
      }
      if (!Hive.isAdapterRegistered(8)) {
        Hive.registerAdapter(SocialConnectionAdapter());
      }
      if (!Hive.isAdapterRegistered(9)) {
        Hive.registerAdapter(ConnectionTypeAdapter());
      }
      if (!Hive.isAdapterRegistered(10)) {
        Hive.registerAdapter(ConnectionStatusAdapter());
      }
      if (!Hive.isAdapterRegistered(11)) {
        Hive.registerAdapter(FriendSuggestionAdapter());
      }
      
      _profilesBox = await Hive.openBox<UserProfile>(_profilesBoxName);
      _connectionsBox = await Hive.openBox<SocialConnection>(_connectionsBoxName);
      
      await _cleanExpiredCache();
      LoggingService.info('SocialService initialized successfully', tag: _logTag);
    } catch (e) {
      LoggingService.error('Error initializing SocialService: $e', tag: _logTag);
      rethrow;
    }
  }

  /// Clean expired cached data
  Future<void> _cleanExpiredCache() async {
    try {
      final now = DateTime.now();
      final keysToDelete = <String>[];
      
      // Clean expired profiles
      for (final key in _profilesBox.keys) {
        final profile = _profilesBox.get(key);
        if (profile != null && 
            now.difference(profile.updatedAt) > _profileCacheDuration) {
          keysToDelete.add(key.toString());
        }
      }
      
      for (final key in keysToDelete) {
        await _profilesBox.delete(key);
      }
      
      LoggingService.info('Cleaned ${keysToDelete.length} expired cache entries', tag: _logTag);
    } catch (e) {
      LoggingService.error('Error cleaning cache: $e', tag: _logTag);
    }
  }

  /// Get current user's profile
  Future<UserProfile?> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    
    return getUserProfile(user.uid);
  }

  /// Get user profile by ID with caching
  Future<UserProfile?> getUserProfile(String userId) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      // Check memory cache first
      if (_profileMemoryCache.containsKey(userId)) {
        PerformanceMonitor.recordCacheHit('memory_profile_$userId');
        return _profileMemoryCache[userId];
      }
      
      // Check local cache
      final cachedProfile = _profilesBox.get(userId);
      if (cachedProfile != null && 
          DateTime.now().difference(cachedProfile.updatedAt) < _profileCacheDuration) {
        _profileMemoryCache[userId] = cachedProfile;
        PerformanceMonitor.recordCacheHit('hive_profile_$userId');
        return cachedProfile;
      }
      
      // Fetch from Firestore
      PerformanceMonitor.startApiCall('fetch_profile_$userId');
      final doc = await _firestore.collection('user_profiles').doc(userId).get();
      
      if (!doc.exists) {
        PerformanceMonitor.endApiCall('fetch_profile_$userId', success: false);
        return null;
      }
      
      final data = doc.data()!;
      final profile = UserProfile(
        userId: userId,
        displayName: data['displayName'] ?? 'Unknown User',
        email: data['email'],
        profileImageUrl: data['profileImageUrl'],
        bio: data['bio'],
        favoriteTeams: List<String>.from(data['favoriteTeams'] ?? []),
        homeLocation: data['homeLocation'],
        preferences: _parsePreferences(data['preferences']),
        socialStats: _parseSocialStats(data['socialStats']),
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        updatedAt: (data['updatedAt'] as Timestamp).toDate(),
        privacySettings: _parsePrivacySettings(data['privacySettings']),
        badges: List<String>.from(data['badges'] ?? []),
        level: data['level'] ?? 1,
        experiencePoints: data['experiencePoints'] ?? 0,
      );
      
      // Cache the profile
      await _profilesBox.put(userId, profile);
      _profileMemoryCache[userId] = profile;
      
      PerformanceMonitor.endApiCall('fetch_profile_$userId', success: true);
      return profile;
      
    } catch (e) {
      PerformanceMonitor.endApiCall('fetch_profile_$userId', success: false);
      LoggingService.error('Error fetching user profile: $e', tag: _logTag);
      return null;
    } finally {
      stopwatch.stop();
    }
  }

  /// Create or update user profile
  Future<bool> saveUserProfile(UserProfile profile) async {
    try {
      PerformanceMonitor.startApiCall('save_profile_${profile.userId}');
      
      final updatedProfile = profile.copyWith(updatedAt: DateTime.now());
      
      final data = {
        'displayName': updatedProfile.displayName,
        'email': updatedProfile.email,
        'profileImageUrl': updatedProfile.profileImageUrl,
        'bio': updatedProfile.bio,
        'favoriteTeams': updatedProfile.favoriteTeams,
        'homeLocation': updatedProfile.homeLocation,
        'preferences': _preferencesToMap(updatedProfile.preferences),
        'socialStats': _socialStatsToMap(updatedProfile.socialStats),
        'createdAt': Timestamp.fromDate(updatedProfile.createdAt),
        'updatedAt': Timestamp.fromDate(updatedProfile.updatedAt),
        'privacySettings': _privacySettingsToMap(updatedProfile.privacySettings),
        'badges': updatedProfile.badges,
        'level': updatedProfile.level,
        'experiencePoints': updatedProfile.experiencePoints,
      };
      
      await _firestore.collection('user_profiles').doc(profile.userId).set(data);
      
      // Update caches
      await _profilesBox.put(profile.userId, updatedProfile);
      _profileMemoryCache[profile.userId] = updatedProfile;
      
      PerformanceMonitor.endApiCall('save_profile_${profile.userId}', success: true);
      return true;
      
    } catch (e) {
      PerformanceMonitor.endApiCall('save_profile_${profile.userId}', success: false);
      LoggingService.error('Error saving user profile: $e', tag: _logTag);
      return false;
    }
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
      await _connectionsBox.put(connection.connectionId, connection);

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
      // Get current user's profile for display name and image
      final senderProfile = await getUserProfile(currentUser.uid);

      // Create notification document for Cloud Function to process
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
      // Don't fail the friend request if notification fails
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
      await _connectionsBox.put(connectionId, acceptedConnection);

      // Update social stats for both users
      await _incrementSocialStat(connection.fromUserId, 'friendsCount');
      await _incrementSocialStat(connection.toUserId, 'friendsCount');

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
      // Get current user's profile for display name and image
      final acceptorProfile = await getUserProfile(currentUser.uid);

      // Create notification document for Cloud Function to process
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
      // Don't fail the accept if notification fails
      LoggingService.error('Error triggering friend request accepted notification: $e', tag: _logTag);
    }
  }

  /// Get user's connections
  Future<List<SocialConnection>> getUserConnections(String userId) async {
    try {
      // Check memory cache
      if (_connectionMemoryCache.containsKey(userId)) {
        return _connectionMemoryCache[userId]!;
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
        await _connectionsBox.put(connection.connectionId, connection);
      }
      
      // Cache in memory
      _connectionMemoryCache[userId] = connections;
      
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
      
      final currentProfile = await getUserProfile(userId);
      if (currentProfile == null) return [];
      
      final userConnections = await getUserConnections(userId);
      final friendIds = userConnections
          .where((c) => c.isFriend)
          .map((c) => c.fromUserId == userId ? c.toUserId : c.fromUserId)
          .toSet();
      
      // Get suggestions based on mutual friends and shared teams
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

  /// Search users by name or team
  Future<List<UserProfile>> searchUsers(String query, {int limit = 20}) async {
    try {
      if (query.trim().isEmpty) return [];
      
      PerformanceMonitor.startApiCall('search_users');
      
      final results = <UserProfile>[];
      
      // Search by display name
      final nameQuery = await _firestore
          .collection('user_profiles')
          .where('displayName', isGreaterThanOrEqualTo: query)
          .where('displayName', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(limit)
          .get();
      
      for (final doc in nameQuery.docs) {
        final profile = await _parseProfileFromDoc(doc);
        if (profile != null) results.add(profile);
      }
      
      PerformanceMonitor.endApiCall('search_users', success: true);
      return results;
      
    } catch (e) {
      PerformanceMonitor.endApiCall('search_users', success: false);
      LoggingService.error('Error searching users: $e', tag: _logTag);
      return [];
    }
  }

  // Helper methods
  Future<SocialConnection?> _getConnection(String connectionId) async {
    try {
      final cached = _connectionsBox.get(connectionId);
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

  Future<void> _incrementSocialStat(String userId, String statName) async {
    try {
      await _firestore.collection('user_profiles').doc(userId).update({
        'socialStats.$statName': FieldValue.increment(1),
        'updatedAt': Timestamp.now(),
      });
      
      // Invalidate cache
      _profileMemoryCache.remove(userId);
      await _profilesBox.delete(userId);
    } catch (e) {
      LoggingService.error('Error incrementing social stat: $e', tag: _logTag);
    }
  }

  Future<UserProfile?> _parseProfileFromDoc(DocumentSnapshot doc) async {
    try {
      if (!doc.exists || doc.data() == null) return null;
      
      final data = Map<String, dynamic>.from(doc.data()! as Map);
      return UserProfile(
        userId: doc.id,
        displayName: data['displayName'] ?? 'Unknown User',
        email: data['email'],
        profileImageUrl: data['profileImageUrl'],
        bio: data['bio'],
        favoriteTeams: List<String>.from(data['favoriteTeams'] ?? []),
        homeLocation: data['homeLocation'],
        preferences: _parsePreferences(data['preferences']),
        socialStats: _parseSocialStats(data['socialStats']),
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        updatedAt: (data['updatedAt'] as Timestamp).toDate(),
        privacySettings: _parsePrivacySettings(data['privacySettings']),
        badges: List<String>.from(data['badges'] ?? []),
        level: data['level'] ?? 1,
        experiencePoints: data['experiencePoints'] ?? 0,
      );
    } catch (e) {
      LoggingService.error('Error parsing profile: $e', tag: _logTag);
      return null;
    }
  }

  UserPreferences _parsePreferences(Map<String, dynamic>? data) {
    if (data == null) return UserPreferences.defaultPreferences();
    
    return UserPreferences(
      showLocation: data['showLocation'] ?? true,
      allowFriendRequests: data['allowFriendRequests'] ?? true,
      shareGameDayPlans: data['shareGameDayPlans'] ?? true,
      receiveNotifications: data['receiveNotifications'] ?? true,
      preferredVenueTypes: List<String>.from(data['preferredVenueTypes'] ?? []),
      maxTravelDistance: data['maxTravelDistance'] ?? 5,
      dietaryRestrictions: List<String>.from(data['dietaryRestrictions'] ?? []),
      preferredPriceRange: data['preferredPriceRange'] ?? '\$\$',
      autoShareCheckIns: data['autoShareCheckIns'] ?? false,
      joinGroupsAutomatically: data['joinGroupsAutomatically'] ?? false,
    );
  }

  SocialStats _parseSocialStats(Map<String, dynamic>? data) {
    if (data == null) return SocialStats.empty();
    
    return SocialStats(
      friendsCount: data['friendsCount'] ?? 0,
      checkInsCount: data['checkInsCount'] ?? 0,
      reviewsCount: data['reviewsCount'] ?? 0,
      gamesAttended: data['gamesAttended'] ?? 0,
      venuesVisited: data['venuesVisited'] ?? 0,
      photosShared: data['photosShared'] ?? 0,
      likesReceived: data['likesReceived'] ?? 0,
      helpfulVotes: data['helpfulVotes'] ?? 0,
      lastActivity: data['lastActivity'] != null 
          ? (data['lastActivity'] as Timestamp).toDate() 
          : null,
    );
  }

  UserPrivacySettings _parsePrivacySettings(Map<String, dynamic>? data) {
    if (data == null) return UserPrivacySettings.defaultSettings();
    
    return UserPrivacySettings(
      profileVisible: data['profileVisible'] ?? true,
      showRealName: data['showRealName'] ?? true,
      showLocation: data['showLocation'] ?? true,
      showFavoriteTeams: data['showFavoriteTeams'] ?? true,
      allowMessaging: data['allowMessaging'] ?? true,
      showOnlineStatus: data['showOnlineStatus'] ?? true,
      checkInVisibility: data['checkInVisibility'] ?? 'friends',
      friendListVisibility: data['friendListVisibility'] ?? 'friends',
    );
  }

  Map<String, dynamic> _preferencesToMap(UserPreferences preferences) {
    return {
      'showLocation': preferences.showLocation,
      'allowFriendRequests': preferences.allowFriendRequests,
      'shareGameDayPlans': preferences.shareGameDayPlans,
      'receiveNotifications': preferences.receiveNotifications,
      'preferredVenueTypes': preferences.preferredVenueTypes,
      'maxTravelDistance': preferences.maxTravelDistance,
      'dietaryRestrictions': preferences.dietaryRestrictions,
      'preferredPriceRange': preferences.preferredPriceRange,
      'autoShareCheckIns': preferences.autoShareCheckIns,
      'joinGroupsAutomatically': preferences.joinGroupsAutomatically,
    };
  }

  Map<String, dynamic> _socialStatsToMap(SocialStats stats) {
    return {
      'friendsCount': stats.friendsCount,
      'checkInsCount': stats.checkInsCount,
      'reviewsCount': stats.reviewsCount,
      'gamesAttended': stats.gamesAttended,
      'venuesVisited': stats.venuesVisited,
      'photosShared': stats.photosShared,
      'likesReceived': stats.likesReceived,
      'helpfulVotes': stats.helpfulVotes,
      'lastActivity': stats.lastActivity != null 
          ? Timestamp.fromDate(stats.lastActivity!) 
          : null,
    };
  }

  Map<String, dynamic> _privacySettingsToMap(UserPrivacySettings settings) {
    return {
      'profileVisible': settings.profileVisible,
      'showRealName': settings.showRealName,
      'showLocation': settings.showLocation,
      'showFavoriteTeams': settings.showFavoriteTeams,
      'allowMessaging': settings.allowMessaging,
      'showOnlineStatus': settings.showOnlineStatus,
      'checkInVisibility': settings.checkInVisibility,
      'friendListVisibility': settings.friendListVisibility,
    };
  }

  /// Decline friend request
  Future<bool> declineFriendRequest(String connectionId) async {
    try {
      PerformanceMonitor.startApiCall('decline_friend_request');
      
      // Delete the friend request from Firestore
      await _firestore.collection('social_connections').doc(connectionId).delete();
      
      // Remove from cache
      await _connectionsBox.delete(connectionId);
      
      // Clear memory cache for affected users
      _connectionMemoryCache.clear();
      
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
      
      // Delete the friend request from Firestore
      await _firestore.collection('social_connections').doc(connectionId).delete();
      
      // Remove from cache
      await _connectionsBox.delete(connectionId);
      
      // Clear memory cache for affected users
      _connectionMemoryCache.clear();
      
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
      
      // Find the friendship connection
      final userConnections = await getUserConnections(userId);
      final friendshipConnection = userConnections.firstWhere(
        (c) => (c.fromUserId == friendId || c.toUserId == friendId) && c.isFriend,
        orElse: () => throw Exception('Friendship not found'),
      );
      
      // Delete the friendship from Firestore
      await _firestore.collection('social_connections').doc(friendshipConnection.connectionId).delete();
      
      // Remove from cache
      await _connectionsBox.delete(friendshipConnection.connectionId);
      
      // Update social stats for both users
      await _decrementSocialStat(userId, 'friendsCount');
      await _decrementSocialStat(friendId, 'friendsCount');
      
      // Clear memory cache for affected users
      _connectionMemoryCache.clear();
      
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
      
      // Create a block connection
      final blockConnection = SocialConnection(
        connectionId: '${userId}_blocks_$blockedUserId',
        fromUserId: userId,
        toUserId: blockedUserId,
        type: ConnectionType.block,
        status: ConnectionStatus.accepted, // Use accepted for active blocks
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
      
      // Cache locally
      await _connectionsBox.put(blockConnection.connectionId, blockConnection);
      
      // Clear memory cache
      _connectionMemoryCache.clear();
      
      PerformanceMonitor.endApiCall('block_user', success: true);
      return true;
      
    } catch (e) {
      PerformanceMonitor.endApiCall('block_user', success: false);
      LoggingService.error('Error blocking user: $e', tag: _logTag);
      return false;
    }
  }

  /// Helper to decrement social stats
  Future<void> _decrementSocialStat(String userId, String statName) async {
    try {
      await _firestore.collection('user_profiles').doc(userId).update({
        'socialStats.$statName': FieldValue.increment(-1),
        'updatedAt': Timestamp.now(),
      });
      
      // Invalidate cache
      _profileMemoryCache.remove(userId);
      await _profilesBox.delete(userId);
    } catch (e) {
      LoggingService.error('Error decrementing social stat: $e', tag: _logTag);
    }
  }

  /// Get social service statistics
  Map<String, dynamic> getServiceStats() {
    return {
      'profileCacheSize': _profilesBox.length,
      'connectionCacheSize': _connectionsBox.length,
      'memoryCacheSize': _profileMemoryCache.length,
      'connectionMemoryCache': _connectionMemoryCache.length,
    };
  }

  // Get user's friends list
  Future<List<UserProfile>> getUserFriends() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return [];

    try {
      LoggingService.info('Getting user friends for ${currentUser.uid}', tag: _logTag);
      
      final snapshot = await _firestore
          .collection('friendships')
          .where('userId', isEqualTo: currentUser.uid)
          .where('status', isEqualTo: 'accepted')
          .get();

      final friendIds = snapshot.docs
          .map((doc) => doc.data()['friendId'] as String)
          .toList();

      if (friendIds.isEmpty) return [];

      // Get friend profiles
      final friendProfiles = <UserProfile>[];
      for (final friendId in friendIds) {
        final userDoc = await _firestore
            .collection('users')
            .doc(friendId)
            .get();
        
        if (userDoc.exists) {
          friendProfiles.add(UserProfile.fromJson(userDoc.data()!));
        }
      }

      LoggingService.info('Retrieved ${friendProfiles.length} friends', tag: _logTag);
      return friendProfiles;
    } catch (e) {
      LoggingService.error('Error getting user friends: $e', tag: _logTag);
      return [];
    }
  }
} 
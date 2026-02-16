import 'package:hive/hive.dart';
import '../entities/user_profile.dart';
import '../entities/social_connection.dart';
import '../../../../core/services/logging_service.dart';
import 'social_profile_service.dart';
import 'social_friend_service.dart';

/// Social service facade that delegates to focused sub-services:
/// - [SocialProfileService] for profile CRUD, caching, and user search
/// - [SocialFriendService] for friend requests, connections, and blocking
/// - [SocialDataMappers] for serialization/deserialization helpers
///
/// All public method signatures are preserved for backward compatibility.
class SocialService {
  static const String _logTag = 'SocialService';

  late SocialProfileService _profileService;
  late SocialFriendService _friendService;

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

      // Initialize sub-services
      _profileService = SocialProfileService();
      final profilesBox = await SocialProfileService.openBox();
      await _profileService.initialize(profilesBox);

      _friendService = SocialFriendService(profileService: _profileService);
      final connectionsBox = await SocialFriendService.openBox();
      await _friendService.initialize(connectionsBox);

      LoggingService.info('SocialService initialized successfully', tag: _logTag);
    } catch (e) {
      LoggingService.error('Error initializing SocialService: $e', tag: _logTag);
      rethrow;
    }
  }

  // -- Profile methods (delegated to SocialProfileService) --

  /// Get current user's profile
  Future<UserProfile?> getCurrentUserProfile() async {
    return _profileService.getCurrentUserProfile();
  }

  /// Get user profile by ID with caching
  Future<UserProfile?> getUserProfile(String userId) async {
    return _profileService.getUserProfile(userId);
  }

  /// Create or update user profile
  Future<bool> saveUserProfile(UserProfile profile) async {
    return _profileService.saveUserProfile(profile);
  }

  /// Search users by name or team (case-insensitive)
  Future<List<UserProfile>> searchUsers(String query, {int limit = 20}) async {
    return _profileService.searchUsers(query, limit: limit);
  }

  /// Get user's friends list
  Future<List<UserProfile>> getUserFriends() async {
    return _profileService.getUserFriends();
  }

  // -- Friend/connection methods (delegated to SocialFriendService) --

  /// Send friend request
  Future<bool> sendFriendRequest(String targetUserId, {String? source}) async {
    return _friendService.sendFriendRequest(targetUserId, source: source);
  }

  /// Accept friend request
  Future<bool> acceptFriendRequest(String connectionId) async {
    return _friendService.acceptFriendRequest(connectionId);
  }

  /// Get user's connections
  Future<List<SocialConnection>> getUserConnections(String userId) async {
    return _friendService.getUserConnections(userId);
  }

  /// Get friend suggestions for user
  Future<List<FriendSuggestion>> getFriendSuggestions(String userId, {int limit = 10}) async {
    return _friendService.getFriendSuggestions(userId, limit: limit);
  }

  /// Decline friend request
  Future<bool> declineFriendRequest(String connectionId) async {
    return _friendService.declineFriendRequest(connectionId);
  }

  /// Cancel friend request (for outgoing requests)
  Future<bool> cancelFriendRequest(String connectionId) async {
    return _friendService.cancelFriendRequest(connectionId);
  }

  /// Remove friend
  Future<bool> removeFriend(String userId, String friendId) async {
    return _friendService.removeFriend(userId, friendId);
  }

  /// Block user
  Future<bool> blockUser(String userId, String blockedUserId) async {
    return _friendService.blockUser(userId, blockedUserId);
  }

  /// Unblock a user
  Future<bool> unblockUser(String userId, String blockedUserId) async {
    return _friendService.unblockUser(userId, blockedUserId);
  }

  /// Check if a user is blocked by another user (either direction)
  Future<bool> isUserBlocked(String userId1, String userId2) async {
    return _friendService.isUserBlocked(userId1, userId2);
  }

  /// Check if current user has blocked a specific user
  Future<bool> hasBlockedUser(String blockedUserId) async {
    return _friendService.hasBlockedUser(blockedUserId);
  }

  /// Check if current user is blocked by a specific user
  Future<bool> isBlockedByUser(String userId) async {
    return _friendService.isBlockedByUser(userId);
  }

  /// Get list of users blocked by current user
  Future<List<String>> getBlockedUserIds() async {
    return _friendService.getBlockedUserIds();
  }

  /// Get social service statistics
  Map<String, dynamic> getServiceStats() {
    return {
      'profileCacheSize': _profileService.profilesBox.length,
      'connectionCacheSize': _friendService.connectionsBox.length,
      'memoryCacheSize': _profileService.profileMemoryCache.length,
      'connectionMemoryCache': _friendService.connectionMemoryCache.length,
    };
  }
}

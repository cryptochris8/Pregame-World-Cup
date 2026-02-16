import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import '../entities/user_profile.dart';
import '../../../../core/services/performance_monitor.dart';
import '../../../../core/services/logging_service.dart';
import 'social_data_mappers.dart';

/// Handles user profile CRUD operations, caching, and user search.
/// Manages both Hive local cache and in-memory cache for profiles.
class SocialProfileService {
  static const String _logTag = 'SocialProfileService';
  static const String _profilesBoxName = 'user_profiles';
  static const Duration _profileCacheDuration = Duration(hours: 6);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final SocialDataMappers _mappers;

  late Box<UserProfile> profilesBox;

  // In-memory cache for active session
  final Map<String, UserProfile> profileMemoryCache = {};

  SocialProfileService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    SocialDataMappers? mappers,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _mappers = mappers ?? SocialDataMappers();

  /// Initialize the profile service with local caching
  Future<void> initialize(Box<UserProfile> box) async {
    profilesBox = box;
    await _cleanExpiredCache();
    LoggingService.info('SocialProfileService initialized', tag: _logTag);
  }

  /// Open and return the profiles Hive box
  static Future<Box<UserProfile>> openBox() async {
    return await Hive.openBox<UserProfile>(_profilesBoxName);
  }

  /// Clean expired cached data
  Future<void> _cleanExpiredCache() async {
    try {
      final now = DateTime.now();
      final keysToDelete = <String>[];

      for (final key in profilesBox.keys) {
        final profile = profilesBox.get(key);
        if (profile != null &&
            now.difference(profile.updatedAt) > _profileCacheDuration) {
          keysToDelete.add(key.toString());
        }
      }

      for (final key in keysToDelete) {
        await profilesBox.delete(key);
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
      if (profileMemoryCache.containsKey(userId)) {
        PerformanceMonitor.recordCacheHit('memory_profile_$userId');
        return profileMemoryCache[userId];
      }

      // Check local cache
      final cachedProfile = profilesBox.get(userId);
      if (cachedProfile != null &&
          DateTime.now().difference(cachedProfile.updatedAt) < _profileCacheDuration) {
        profileMemoryCache[userId] = cachedProfile;
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

      final profile = _mappers.parseProfileFromData(userId, doc.data()!);

      if (profile != null) {
        // Cache the profile
        await profilesBox.put(userId, profile);
        profileMemoryCache[userId] = profile;
      }

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
      final data = _mappers.profileToMap(updatedProfile);

      await _firestore.collection('user_profiles').doc(profile.userId).set(data);

      // Update caches
      await profilesBox.put(profile.userId, updatedProfile);
      profileMemoryCache[profile.userId] = updatedProfile;

      PerformanceMonitor.endApiCall('save_profile_${profile.userId}', success: true);
      return true;
    } catch (e) {
      PerformanceMonitor.endApiCall('save_profile_${profile.userId}', success: false);
      LoggingService.error('Error saving user profile: $e', tag: _logTag);
      return false;
    }
  }

  /// Search users by name or team (case-insensitive)
  Future<List<UserProfile>> searchUsers(String query, {int limit = 20}) async {
    try {
      if (query.trim().isEmpty) return [];

      PerformanceMonitor.startApiCall('search_users');

      final results = <UserProfile>{};
      final lowerQuery = query.trim().toLowerCase();

      // Search by displayNameLowercase (case-insensitive, for profiles saved with this field)
      final lowercaseQuery = await _firestore
          .collection('user_profiles')
          .where('displayNameLowercase', isGreaterThanOrEqualTo: lowerQuery)
          .where('displayNameLowercase', isLessThanOrEqualTo: '$lowerQuery\uf8ff')
          .limit(limit)
          .get();

      for (final doc in lowercaseQuery.docs) {
        final profile = _mappers.parseProfileFromDoc(doc);
        if (profile != null) results.add(profile);
      }

      // Fallback: search by displayName with original casing (for legacy profiles)
      if (results.length < limit) {
        final nameQuery = await _firestore
            .collection('user_profiles')
            .where('displayName', isGreaterThanOrEqualTo: query.trim())
            .where('displayName', isLessThanOrEqualTo: '${query.trim()}\uf8ff')
            .limit(limit - results.length)
            .get();

        for (final doc in nameQuery.docs) {
          final profile = _mappers.parseProfileFromDoc(doc);
          if (profile != null) results.add(profile);
        }
      }

      PerformanceMonitor.endApiCall('search_users', success: true);
      return results.toList();
    } catch (e) {
      PerformanceMonitor.endApiCall('search_users', success: false);
      LoggingService.error('Error searching users: $e', tag: _logTag);
      return [];
    }
  }

  /// Increment a social stat for a user and invalidate cache
  Future<void> incrementSocialStat(String userId, String statName) async {
    try {
      await _firestore.collection('user_profiles').doc(userId).update({
        'socialStats.$statName': FieldValue.increment(1),
        'updatedAt': Timestamp.now(),
      });

      // Invalidate cache
      profileMemoryCache.remove(userId);
      await profilesBox.delete(userId);
    } catch (e) {
      LoggingService.error('Error incrementing social stat: $e', tag: _logTag);
    }
  }

  /// Decrement a social stat for a user and invalidate cache
  Future<void> decrementSocialStat(String userId, String statName) async {
    try {
      await _firestore.collection('user_profiles').doc(userId).update({
        'socialStats.$statName': FieldValue.increment(-1),
        'updatedAt': Timestamp.now(),
      });

      // Invalidate cache
      profileMemoryCache.remove(userId);
      await profilesBox.delete(userId);
    } catch (e) {
      LoggingService.error('Error decrementing social stat: $e', tag: _logTag);
    }
  }

  /// Get user's friends list
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

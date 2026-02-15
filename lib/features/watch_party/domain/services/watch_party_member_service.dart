import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';

import '../entities/watch_party.dart';
import '../entities/watch_party_member.dart';
import '../../../../core/services/performance_monitor.dart';
import '../../../../core/services/logging_service.dart';
import '../../../social/domain/entities/user_profile.dart';

/// Handles watch party membership operations: joining, leaving,
/// muting, removing, promoting, and demoting members.
class WatchPartyMemberService {
  static const String _logTag = 'WatchPartyMemberService';

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  late Box<WatchPartyMember> _membersBox;

  /// In-memory cache for members by watch party ID
  final Map<String, List<WatchPartyMember>> _membersMemoryCache = {};

  WatchPartyMemberService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Initialize the member service with the provided Hive box
  void initializeBox(Box<WatchPartyMember> membersBox) {
    _membersBox = membersBox;
  }

  /// Expose members memory cache for external invalidation
  void invalidateMembersCache(String watchPartyId) {
    _membersMemoryCache.remove(watchPartyId);
  }

  /// Add a member to a watch party
  Future<void> addMember(
    String watchPartyId,
    String userId,
    String displayName,
    String? profileImageUrl,
    WatchPartyMemberRole role,
    WatchPartyAttendanceType attendanceType,
  ) async {
    final member = WatchPartyMember.create(
      watchPartyId: watchPartyId,
      userId: userId,
      displayName: displayName,
      profileImageUrl: profileImageUrl,
      role: role,
      attendanceType: attendanceType,
    );

    await _firestore
        .collection('watch_parties')
        .doc(watchPartyId)
        .collection('members')
        .doc(userId)
        .set(member.toFirestore());

    await _membersBox.put(member.memberId, member);
  }

  /// Get a specific member from a watch party
  Future<WatchPartyMember?> getMember(String watchPartyId, String userId) async {
    try {
      final cachedKey = '${watchPartyId}_$userId';
      final cached = _membersBox.get(cachedKey);
      if (cached != null) return cached;

      final doc = await _firestore
          .collection('watch_parties')
          .doc(watchPartyId)
          .collection('members')
          .doc(userId)
          .get();

      if (!doc.exists) return null;

      final member = WatchPartyMember.fromFirestore(doc.data()!, doc.id);
      await _membersBox.put(cachedKey, member);
      return member;
    } catch (e) {
      LoggingService.error('Error getting member: $e', tag: _logTag);
      return null;
    }
  }

  /// Join a watch party
  Future<bool> joinWatchParty(
    String watchPartyId,
    WatchPartyAttendanceType attendanceType,
    WatchParty? party,
  ) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      PerformanceMonitor.startApiCall('join_watch_party');

      if (party == null) {
        LoggingService.error('Watch party not found', tag: _logTag);
        PerformanceMonitor.endApiCall('join_watch_party', success: false);
        return false;
      }

      if (!party.canJoin) {
        LoggingService.error('Cannot join party: full or not upcoming', tag: _logTag);
        PerformanceMonitor.endApiCall('join_watch_party', success: false);
        return false;
      }

      // Check if already a member
      final existingMember = await getMember(watchPartyId, user.uid);
      if (existingMember != null) {
        LoggingService.info('User already a member', tag: _logTag);
        PerformanceMonitor.endApiCall('join_watch_party', success: true);
        return true;
      }

      // Get user profile
      final userProfile = await _getUserProfile(user.uid);

      // Add member
      await addMember(
        watchPartyId,
        user.uid,
        userProfile?.displayName ?? 'Member',
        userProfile?.profileImageUrl,
        WatchPartyMemberRole.member,
        attendanceType,
      );

      // Update attendee count
      final countField = attendanceType == WatchPartyAttendanceType.virtual
          ? 'virtualAttendeesCount'
          : 'currentAttendeesCount';

      await _firestore.collection('watch_parties').doc(watchPartyId).update({
        countField: FieldValue.increment(1),
        'updatedAt': Timestamp.now(),
      });

      // Invalidate cache
      _membersMemoryCache.remove(watchPartyId);

      PerformanceMonitor.endApiCall('join_watch_party', success: true);
      return true;
    } catch (e) {
      PerformanceMonitor.endApiCall('join_watch_party', success: false);
      LoggingService.error('Error joining watch party: $e', tag: _logTag);
      return false;
    }
  }

  /// Get the display name of the user who just joined (for system messages)
  Future<String> getJoinDisplayName() async {
    final user = _auth.currentUser;
    if (user == null) return 'Someone';
    final profile = await _getUserProfile(user.uid);
    return profile?.displayName ?? 'Someone';
  }

  /// Leave a watch party
  Future<bool> leaveWatchParty(String watchPartyId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      PerformanceMonitor.startApiCall('leave_watch_party');

      final member = await getMember(watchPartyId, user.uid);
      if (member == null) {
        LoggingService.error('User is not a member', tag: _logTag);
        PerformanceMonitor.endApiCall('leave_watch_party', success: false);
        return false;
      }

      // Host cannot leave
      if (member.isHost) {
        LoggingService.warning('Host cannot leave watch party', tag: _logTag);
        PerformanceMonitor.endApiCall('leave_watch_party', success: false);
        return false;
      }

      // Remove member document
      await _firestore
          .collection('watch_parties')
          .doc(watchPartyId)
          .collection('members')
          .doc(user.uid)
          .delete();

      // Update count
      final countField = member.isVirtual
          ? 'virtualAttendeesCount'
          : 'currentAttendeesCount';

      await _firestore.collection('watch_parties').doc(watchPartyId).update({
        countField: FieldValue.increment(-1),
        'updatedAt': Timestamp.now(),
      });

      // Invalidate caches
      _membersMemoryCache.remove(watchPartyId);

      PerformanceMonitor.endApiCall('leave_watch_party', success: true);
      return true;
    } catch (e) {
      PerformanceMonitor.endApiCall('leave_watch_party', success: false);
      LoggingService.error('Error leaving watch party: $e', tag: _logTag);
      return false;
    }
  }

  /// Get the display name of the member who just left (for system messages)
  Future<String?> getLeavingMemberName(String watchPartyId) async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final member = await getMember(watchPartyId, user.uid);
    return member?.displayName;
  }

  /// Get members of a watch party
  Future<List<WatchPartyMember>> getMembers(String watchPartyId) async {
    try {
      // Check memory cache
      if (_membersMemoryCache.containsKey(watchPartyId)) {
        return _membersMemoryCache[watchPartyId]!;
      }

      PerformanceMonitor.startApiCall('get_watch_party_members');

      final snapshot = await _firestore
          .collection('watch_parties')
          .doc(watchPartyId)
          .collection('members')
          .orderBy('joinedAt')
          .get();

      final members = snapshot.docs
          .map((doc) => WatchPartyMember.fromFirestore(doc.data(), doc.id))
          .toList();

      // Cache in memory
      _membersMemoryCache[watchPartyId] = members;

      // Cache individual members
      for (final member in members) {
        await _membersBox.put(member.memberId, member);
      }

      PerformanceMonitor.endApiCall('get_watch_party_members', success: true);
      return members;
    } catch (e) {
      PerformanceMonitor.endApiCall('get_watch_party_members', success: false);
      LoggingService.error('Error getting members: $e', tag: _logTag);
      return [];
    }
  }

  /// Check if current user is a member of a watch party
  Future<bool> isUserMember(String watchPartyId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final member = await getMember(watchPartyId, user.uid);
    return member != null;
  }

  /// Get current user's membership in a watch party
  Future<WatchPartyMember?> getCurrentUserMembership(String watchPartyId) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    return getMember(watchPartyId, user.uid);
  }

  /// Mute a member (host only)
  Future<bool> muteMember(String watchPartyId, String userId) async {
    return _updateMemberStatus(watchPartyId, userId, isMuted: true);
  }

  /// Unmute a member (host only)
  Future<bool> unmuteMember(String watchPartyId, String userId) async {
    return _updateMemberStatus(watchPartyId, userId, isMuted: false);
  }

  /// Remove a member (host only)
  Future<bool> removeMember(
    String watchPartyId,
    String userId,
    WatchParty? party,
  ) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      if (party == null || party.hostId != user.uid) {
        LoggingService.error('User not authorized to remove members', tag: _logTag);
        return false;
      }

      final member = await getMember(watchPartyId, userId);
      if (member == null || member.isHost) {
        return false;
      }

      PerformanceMonitor.startApiCall('remove_member');

      await _firestore
          .collection('watch_parties')
          .doc(watchPartyId)
          .collection('members')
          .doc(userId)
          .delete();

      // Update count
      final countField = member.isVirtual
          ? 'virtualAttendeesCount'
          : 'currentAttendeesCount';

      await _firestore.collection('watch_parties').doc(watchPartyId).update({
        countField: FieldValue.increment(-1),
        'updatedAt': Timestamp.now(),
      });

      // Invalidate caches
      _membersMemoryCache.remove(watchPartyId);

      PerformanceMonitor.endApiCall('remove_member', success: true);
      return true;
    } catch (e) {
      PerformanceMonitor.endApiCall('remove_member', success: false);
      LoggingService.error('Error removing member: $e', tag: _logTag);
      return false;
    }
  }

  /// Get display name of a removed member (for system messages)
  Future<String?> getRemovedMemberName(String watchPartyId, String userId) async {
    final member = await getMember(watchPartyId, userId);
    return member?.displayName;
  }

  /// Promote a member to co-host
  Future<bool> promoteMember(String watchPartyId, String userId, WatchParty? party) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      if (party == null || party.hostId != currentUser.uid) {
        LoggingService.error('Only host can promote members', tag: _logTag);
        return false;
      }

      await _firestore
          .collection('watch_parties')
          .doc(watchPartyId)
          .collection('members')
          .doc(userId)
          .update({'role': WatchPartyMemberRole.coHost.name});

      _membersMemoryCache.remove(watchPartyId);
      return true;
    } catch (e) {
      LoggingService.error('Error promoting member: $e', tag: _logTag);
      return false;
    }
  }

  /// Demote a co-host to regular member
  Future<bool> demoteMember(String watchPartyId, String userId, WatchParty? party) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      if (party == null || party.hostId != currentUser.uid) {
        LoggingService.error('Only host can demote members', tag: _logTag);
        return false;
      }

      await _firestore
          .collection('watch_parties')
          .doc(watchPartyId)
          .collection('members')
          .doc(userId)
          .update({'role': WatchPartyMemberRole.member.name});

      _membersMemoryCache.remove(watchPartyId);
      return true;
    } catch (e) {
      LoggingService.error('Error demoting member: $e', tag: _logTag);
      return false;
    }
  }

  /// Update member payment status after successful payment
  Future<bool> updateMemberPaymentStatus(
    String watchPartyId,
    String userId,
    String paymentIntentId,
  ) async {
    try {
      await _firestore
          .collection('watch_parties')
          .doc(watchPartyId)
          .collection('members')
          .doc(userId)
          .update({
        'hasPaid': true,
        'paymentIntentId': paymentIntentId,
      });

      _membersMemoryCache.remove(watchPartyId);
      return true;
    } catch (e) {
      LoggingService.error('Error updating payment status: $e', tag: _logTag);
      return false;
    }
  }

  // ==================== HELPER METHODS ====================

  Future<bool> _updateMemberStatus(
    String watchPartyId,
    String userId, {
    bool? isMuted,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      // Note: host authorization should be checked by caller
      final updates = <String, dynamic>{};
      if (isMuted != null) updates['isMuted'] = isMuted;

      await _firestore
          .collection('watch_parties')
          .doc(watchPartyId)
          .collection('members')
          .doc(userId)
          .update(updates);

      _membersMemoryCache.remove(watchPartyId);
      return true;
    } catch (e) {
      LoggingService.error('Error updating member status: $e', tag: _logTag);
      return false;
    }
  }

  Future<UserProfile?> _getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('user_profiles').doc(userId).get();
      if (!doc.exists) return null;
      return UserProfile.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      LoggingService.error('Error getting user profile: $e', tag: _logTag);
      return null;
    }
  }

  /// Clear in-memory caches
  void clearCaches() {
    _membersMemoryCache.clear();
  }

  /// Get cache stats
  int get memoryCacheSize => _membersMemoryCache.length;
  int get hiveCacheSize => _membersBox.length;
}

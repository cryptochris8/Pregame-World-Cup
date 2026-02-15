import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';

import '../entities/watch_party.dart';
import '../entities/watch_party_invite.dart';
import '../../../../core/services/performance_monitor.dart';
import '../../../../core/services/logging_service.dart';
import '../../../social/domain/entities/user_profile.dart';

/// Handles watch party invitation operations: sending, retrieving,
/// and responding to invites.
class WatchPartyInviteService {
  static const String _logTag = 'WatchPartyInviteService';

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  late Box<WatchPartyInvite> _invitesBox;

  /// In-memory cache for invites
  final Map<String, List<WatchPartyInvite>> _invitesMemoryCache = {};

  WatchPartyInviteService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Initialize the invite service with the provided Hive box
  void initializeBox(Box<WatchPartyInvite> invitesBox) {
    _invitesBox = invitesBox;
  }

  /// Send invite to a user
  Future<bool> sendInvite(
    String watchPartyId,
    String inviteeId,
    WatchParty party, {
    String? message,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      PerformanceMonitor.startApiCall('send_invite');

      final userProfile = await _getUserProfile(user.uid);

      final invite = WatchPartyInvite.create(
        watchPartyId: watchPartyId,
        watchPartyName: party.name,
        inviterId: user.uid,
        inviterName: userProfile?.displayName ?? 'User',
        inviterImageUrl: userProfile?.profileImageUrl,
        inviteeId: inviteeId,
        expiresAt: party.gameDateTime,
        message: message,
        gameName: party.gameName,
        gameDateTime: party.gameDateTime,
        venueName: party.venueName,
      );

      await _firestore
          .collection('watch_party_invites')
          .doc(invite.inviteId)
          .set(invite.toFirestore());

      // Note: Cloud Function (onWatchPartyInviteCreated) handles push notification
      // and in-app notification creation automatically when invite is created

      PerformanceMonitor.endApiCall('send_invite', success: true);
      return true;
    } catch (e) {
      PerformanceMonitor.endApiCall('send_invite', success: false);
      LoggingService.error('Error sending invite: $e', tag: _logTag);
      return false;
    }
  }

  /// Get pending invites for current user
  Future<List<WatchPartyInvite>> getPendingInvites() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      // Check memory cache
      final cacheKey = 'pending_$user.uid';
      if (_invitesMemoryCache.containsKey(cacheKey)) {
        return _invitesMemoryCache[cacheKey]!
            .where((i) => i.isValid)
            .toList();
      }

      PerformanceMonitor.startApiCall('get_pending_invites');

      final snapshot = await _firestore
          .collection('watch_party_invites')
          .where('inviteeId', isEqualTo: user.uid)
          .where('status', isEqualTo: WatchPartyInviteStatus.pending.name)
          .orderBy('createdAt', descending: true)
          .get();

      final invites = snapshot.docs
          .map((doc) => WatchPartyInvite.fromFirestore(doc.data(), doc.id))
          .where((invite) => !invite.isExpired)
          .toList();

      // Cache
      _invitesMemoryCache[cacheKey] = invites;
      for (final invite in invites) {
        await _invitesBox.put(invite.inviteId, invite);
      }

      PerformanceMonitor.endApiCall('get_pending_invites', success: true);
      return invites;
    } catch (e) {
      PerformanceMonitor.endApiCall('get_pending_invites', success: false);
      LoggingService.error('Error getting pending invites: $e', tag: _logTag);
      return [];
    }
  }

  /// Respond to an invite, returns watchPartyId if accepted
  Future<String?> respondToInvite(String inviteId, bool accept) async {
    try {
      PerformanceMonitor.startApiCall('respond_to_invite');

      final status = accept
          ? WatchPartyInviteStatus.accepted.name
          : WatchPartyInviteStatus.declined.name;

      await _firestore
          .collection('watch_party_invites')
          .doc(inviteId)
          .update({'status': status});

      String? watchPartyId;
      if (accept) {
        final invite = await _getInvite(inviteId);
        if (invite != null) {
          watchPartyId = invite.watchPartyId;
        }
      }

      // Clear invites cache
      _invitesMemoryCache.clear();

      PerformanceMonitor.endApiCall('respond_to_invite', success: true);
      return watchPartyId;
    } catch (e) {
      PerformanceMonitor.endApiCall('respond_to_invite', success: false);
      LoggingService.error('Error responding to invite: $e', tag: _logTag);
      rethrow;
    }
  }

  /// Create an in-app notification for an invite
  Future<void> createInviteNotification(WatchPartyInvite invite) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': invite.inviteeId,
        'type': 'groupInvite',
        'title': 'Watch Party Invite',
        'message': '${invite.inviterName} invited you to ${invite.watchPartyName}',
        'data': {
          'inviteId': invite.inviteId,
          'watchPartyId': invite.watchPartyId,
        },
        'isRead': false,
        'createdAt': Timestamp.now(),
      });
    } catch (e) {
      LoggingService.error('Error creating invite notification: $e', tag: _logTag);
    }
  }

  // ==================== HELPER METHODS ====================

  Future<WatchPartyInvite?> _getInvite(String inviteId) async {
    try {
      final cached = _invitesBox.get(inviteId);
      if (cached != null) return cached;

      final doc = await _firestore
          .collection('watch_party_invites')
          .doc(inviteId)
          .get();

      if (!doc.exists) return null;

      return WatchPartyInvite.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      LoggingService.error('Error getting invite: $e', tag: _logTag);
      return null;
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
    _invitesMemoryCache.clear();
  }

  /// Get cache stats
  int get hiveCacheSize => _invitesBox.length;
}

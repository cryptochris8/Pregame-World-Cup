import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';

import '../entities/watch_party.dart';
import '../entities/watch_party_member.dart';
import '../entities/watch_party_message.dart';
import '../entities/watch_party_invite.dart';
import '../../../../core/services/performance_monitor.dart';
import '../../../../core/services/logging_service.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../social/domain/entities/user_profile.dart';
import '../../../moderation/moderation.dart';
import 'watch_party_chat_service.dart';
import 'watch_party_member_service.dart';
import 'watch_party_invite_service.dart';

/// Orchestrates watch party operations by delegating to focused sub-services.
///
/// Sub-services:
/// - [WatchPartyChatService] - real-time messaging
/// - [WatchPartyMemberService] - membership management
/// - [WatchPartyInviteService] - invite handling
///
/// This service retains party CRUD, discovery, status management,
/// initialization, and cache coordination.
class WatchPartyService {
  static const String _logTag = 'WatchPartyService';
  static const String _partiesBoxName = 'watch_parties';
  static const String _membersBoxName = 'watch_party_members';
  static const String _invitesBoxName = 'watch_party_invites';
  static const Duration _cacheDuration = Duration(hours: 1);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AnalyticsService _analyticsService = AnalyticsService();

  late Box<WatchParty> _partiesBox;

  // Sub-services
  final WatchPartyChatService _chatService = WatchPartyChatService();
  final WatchPartyMemberService _memberService = WatchPartyMemberService();
  final WatchPartyInviteService _inviteService = WatchPartyInviteService();

  // In-memory cache for active session
  final Map<String, WatchParty> _partyMemoryCache = {};

  // ==================== INITIALIZATION ====================

  /// Initialize the watch party service with local caching
  Future<void> initialize() async {
    try {
      // Register Hive adapters if not already registered
      if (!Hive.isAdapterRegistered(30)) {
        Hive.registerAdapter(WatchPartyAdapter());
      }
      if (!Hive.isAdapterRegistered(31)) {
        Hive.registerAdapter(WatchPartyVisibilityAdapter());
      }
      if (!Hive.isAdapterRegistered(32)) {
        Hive.registerAdapter(WatchPartyStatusAdapter());
      }
      if (!Hive.isAdapterRegistered(33)) {
        Hive.registerAdapter(WatchPartyMemberAdapter());
      }
      if (!Hive.isAdapterRegistered(34)) {
        Hive.registerAdapter(WatchPartyMemberRoleAdapter());
      }
      if (!Hive.isAdapterRegistered(35)) {
        Hive.registerAdapter(WatchPartyAttendanceTypeAdapter());
      }
      if (!Hive.isAdapterRegistered(36)) {
        Hive.registerAdapter(MemberRsvpStatusAdapter());
      }
      if (!Hive.isAdapterRegistered(37)) {
        Hive.registerAdapter(WatchPartyMessageAdapter());
      }
      if (!Hive.isAdapterRegistered(38)) {
        Hive.registerAdapter(WatchPartyMessageTypeAdapter());
      }
      if (!Hive.isAdapterRegistered(39)) {
        Hive.registerAdapter(WatchPartyInviteAdapter());
      }
      if (!Hive.isAdapterRegistered(40)) {
        Hive.registerAdapter(WatchPartyInviteStatusAdapter());
      }
      if (!Hive.isAdapterRegistered(41)) {
        Hive.registerAdapter(MessageReactionAdapter());
      }

      _partiesBox = await Hive.openBox<WatchParty>(_partiesBoxName);
      final membersBox = await Hive.openBox<WatchPartyMember>(_membersBoxName);
      final invitesBox = await Hive.openBox<WatchPartyInvite>(_invitesBoxName);

      // Initialize sub-services with their Hive boxes
      _memberService.initializeBox(membersBox);
      _inviteService.initializeBox(invitesBox);

      await _cleanExpiredCache();
      LoggingService.info('WatchPartyService initialized successfully', tag: _logTag);
    } catch (e) {
      LoggingService.error('Error initializing WatchPartyService: $e', tag: _logTag);
      rethrow;
    }
  }

  /// Clean expired cached data
  Future<void> _cleanExpiredCache() async {
    try {
      final now = DateTime.now();
      final keysToDelete = <String>[];

      for (final key in _partiesBox.keys) {
        final party = _partiesBox.get(key);
        if (party != null && now.difference(party.updatedAt) > _cacheDuration) {
          keysToDelete.add(key.toString());
        }
      }

      for (final key in keysToDelete) {
        await _partiesBox.delete(key);
      }

      LoggingService.info('Cleaned ${keysToDelete.length} expired cache entries', tag: _logTag);
    } catch (e) {
      LoggingService.error('Error cleaning cache: $e', tag: _logTag);
    }
  }

  // ==================== WATCH PARTY CRUD ====================

  /// Create a new watch party
  Future<WatchParty?> createWatchParty({
    required String name,
    required String description,
    required WatchPartyVisibility visibility,
    required String gameId,
    required String gameName,
    required DateTime gameDateTime,
    required String venueId,
    required String venueName,
    String? venueAddress,
    double? venueLatitude,
    double? venueLongitude,
    int maxAttendees = 20,
    bool allowVirtualAttendance = false,
    double virtualAttendanceFee = 0.0,
    String? imageUrl,
    List<String> tags = const [],
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      LoggingService.error('User not authenticated', tag: _logTag);
      return null;
    }

    try {
      PerformanceMonitor.startApiCall('create_watch_party');

      // Validate content with moderation service
      final moderationService = ModerationService();
      final validationResult = await moderationService.validateWatchParty(
        name: name,
        description: description,
      );

      if (!validationResult.isValid) {
        LoggingService.warning(
          'Watch party creation blocked by moderation: ${validationResult.errorMessage}',
          tag: _logTag,
        );
        throw Exception(validationResult.errorMessage ?? 'Content moderation failed');
      }

      final filteredName = validationResult.filteredName ?? name;
      final filteredDescription = validationResult.filteredDescription ?? description;

      // Get user profile for host info
      final userProfile = await _getUserProfile(user.uid);

      final watchParty = WatchParty.create(
        hostId: user.uid,
        hostName: userProfile?.displayName ?? 'Host',
        hostImageUrl: userProfile?.profileImageUrl,
        name: filteredName,
        description: filteredDescription,
        visibility: visibility,
        gameId: gameId,
        gameName: gameName,
        gameDateTime: gameDateTime,
        venueId: venueId,
        venueName: venueName,
        venueAddress: venueAddress,
        venueLatitude: venueLatitude,
        venueLongitude: venueLongitude,
        maxAttendees: maxAttendees,
        allowVirtualAttendance: allowVirtualAttendance,
        virtualAttendanceFee: virtualAttendanceFee,
        imageUrl: imageUrl,
        tags: tags,
      );

      // Save to Firestore
      await _firestore
          .collection('watch_parties')
          .doc(watchParty.watchPartyId)
          .set(watchParty.toFirestore());

      // Add host as first member
      await _memberService.addMember(
        watchParty.watchPartyId,
        user.uid,
        userProfile?.displayName ?? 'Host',
        userProfile?.profileImageUrl,
        WatchPartyMemberRole.host,
        WatchPartyAttendanceType.inPerson,
      );

      // Cache locally
      await _partiesBox.put(watchParty.watchPartyId, watchParty);
      _partyMemoryCache[watchParty.watchPartyId] = watchParty;

      // Add system message
      await sendSystemMessage(
        watchParty.watchPartyId,
        '${userProfile?.displayName ?? "Host"} created this watch party',
      );

      PerformanceMonitor.endApiCall('create_watch_party', success: true);
      LoggingService.info('Created watch party: ${watchParty.watchPartyId}', tag: _logTag);

      // Track analytics
      await _analyticsService.logWatchPartyCreated(
        partyId: watchParty.watchPartyId,
        matchId: gameId,
        isPublic: visibility == WatchPartyVisibility.public,
        allowsVirtual: allowVirtualAttendance,
        virtualFee: virtualAttendanceFee > 0 ? virtualAttendanceFee : null,
      );

      return watchParty;
    } catch (e) {
      PerformanceMonitor.endApiCall('create_watch_party', success: false);
      LoggingService.error('Error creating watch party: $e', tag: _logTag);
      return null;
    }
  }

  /// Get watch party by ID with three-level caching
  Future<WatchParty?> getWatchParty(String watchPartyId) async {
    try {
      // Level 1: Check memory cache first
      if (_partyMemoryCache.containsKey(watchPartyId)) {
        PerformanceMonitor.recordCacheHit('memory_watch_party_$watchPartyId');
        return _partyMemoryCache[watchPartyId];
      }

      // Level 2: Check local Hive cache
      final cachedParty = _partiesBox.get(watchPartyId);
      if (cachedParty != null &&
          DateTime.now().difference(cachedParty.updatedAt) < _cacheDuration) {
        _partyMemoryCache[watchPartyId] = cachedParty;
        PerformanceMonitor.recordCacheHit('hive_watch_party_$watchPartyId');
        return cachedParty;
      }

      // Level 3: Fetch from Firestore
      PerformanceMonitor.startApiCall('fetch_watch_party_$watchPartyId');
      final doc = await _firestore
          .collection('watch_parties')
          .doc(watchPartyId)
          .get();

      if (!doc.exists) {
        PerformanceMonitor.endApiCall('fetch_watch_party_$watchPartyId', success: false);
        return null;
      }

      final party = WatchParty.fromFirestore(doc.data()!, doc.id);

      // Cache the party
      await _partiesBox.put(watchPartyId, party);
      _partyMemoryCache[watchPartyId] = party;

      PerformanceMonitor.endApiCall('fetch_watch_party_$watchPartyId', success: true);
      return party;
    } catch (e) {
      PerformanceMonitor.endApiCall('fetch_watch_party_$watchPartyId', success: false);
      LoggingService.error('Error fetching watch party: $e', tag: _logTag);
      return null;
    }
  }

  /// Update a watch party with individual fields
  Future<bool> updateWatchParty(
    String watchPartyId, {
    String? name,
    String? description,
    WatchPartyVisibility? visibility,
    int? maxAttendees,
    bool? allowVirtualAttendance,
    double? virtualAttendanceFee,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final party = await getWatchParty(watchPartyId);
      if (party == null || party.hostId != user.uid) {
        LoggingService.error('User not authorized to update party', tag: _logTag);
        return false;
      }

      PerformanceMonitor.startApiCall('update_watch_party');

      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;
      if (visibility != null) updates['visibility'] = visibility.name;
      if (maxAttendees != null) updates['maxAttendees'] = maxAttendees;
      if (allowVirtualAttendance != null) updates['allowVirtualAttendance'] = allowVirtualAttendance;
      if (virtualAttendanceFee != null) updates['virtualAttendanceFee'] = virtualAttendanceFee;

      await _firestore
          .collection('watch_parties')
          .doc(watchPartyId)
          .update(updates);

      // Clear caches
      _partyMemoryCache.remove(watchPartyId);
      _partiesBox.delete(watchPartyId);

      PerformanceMonitor.endApiCall('update_watch_party', success: true);
      return true;
    } catch (e) {
      PerformanceMonitor.endApiCall('update_watch_party', success: false);
      LoggingService.error('Error updating watch party: $e', tag: _logTag);
      return false;
    }
  }

  /// Cancel a watch party
  Future<bool> cancelWatchParty(String watchPartyId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final party = await getWatchParty(watchPartyId);
      if (party == null || party.hostId != user.uid) {
        LoggingService.error('User not authorized to cancel party', tag: _logTag);
        return false;
      }

      PerformanceMonitor.startApiCall('cancel_watch_party');

      final cancelledParty = party.copyWith(
        status: WatchPartyStatus.cancelled,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('watch_parties')
          .doc(watchPartyId)
          .update(cancelledParty.toFirestore());

      // Update caches
      await _partiesBox.put(watchPartyId, cancelledParty);
      _partyMemoryCache[watchPartyId] = cancelledParty;

      // Send system message
      await sendSystemMessage(watchPartyId, 'This watch party has been cancelled');

      PerformanceMonitor.endApiCall('cancel_watch_party', success: true);
      return true;
    } catch (e) {
      PerformanceMonitor.endApiCall('cancel_watch_party', success: false);
      LoggingService.error('Error cancelling watch party: $e', tag: _logTag);
      return false;
    }
  }

  // ==================== DISCOVERY ====================

  /// Get public watch parties for discovery
  Future<List<WatchParty>> getPublicWatchParties({
    String? gameId,
    String? venueId,
    int limit = 20,
    DateTime? afterDate,
  }) async {
    try {
      PerformanceMonitor.startApiCall('get_public_watch_parties');

      Query<Map<String, dynamic>> query = _firestore
          .collection('watch_parties')
          .where('visibility', isEqualTo: WatchPartyVisibility.public.name)
          .where('status', isEqualTo: WatchPartyStatus.upcoming.name);

      if (gameId != null) {
        query = query.where('gameId', isEqualTo: gameId);
      }

      if (venueId != null) {
        query = query.where('venueId', isEqualTo: venueId);
      }

      if (afterDate != null) {
        query = query.where('gameDateTime', isGreaterThan: Timestamp.fromDate(afterDate));
      }

      query = query.orderBy('gameDateTime').limit(limit);

      final snapshot = await query.get();
      final parties = snapshot.docs
          .map((doc) => WatchParty.fromFirestore(doc.data(), doc.id))
          .toList();

      // Cache all results
      for (final party in parties) {
        await _partiesBox.put(party.watchPartyId, party);
        _partyMemoryCache[party.watchPartyId] = party;
      }

      PerformanceMonitor.endApiCall('get_public_watch_parties', success: true);
      return parties;
    } catch (e) {
      PerformanceMonitor.endApiCall('get_public_watch_parties', success: false);
      LoggingService.error('Error getting public watch parties: $e', tag: _logTag);
      return [];
    }
  }

  /// Get user's watch parties (as host or member)
  Future<List<WatchParty>> getUserWatchParties() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      PerformanceMonitor.startApiCall('get_user_watch_parties');

      final hostQuery = await _firestore
          .collection('watch_parties')
          .where('hostId', isEqualTo: user.uid)
          .get();

      final hostedParties = hostQuery.docs
          .map((doc) => WatchParty.fromFirestore(doc.data(), doc.id))
          .toList();

      final memberQuery = await _firestore
          .collectionGroup('members')
          .where('userId', isEqualTo: user.uid)
          .get();

      final memberPartyIds = memberQuery.docs
          .map((doc) => doc.reference.parent.parent!.id)
          .toSet();

      final memberParties = <WatchParty>[];
      for (final partyId in memberPartyIds) {
        if (hostedParties.any((p) => p.watchPartyId == partyId)) continue;
        final party = await getWatchParty(partyId);
        if (party != null) memberParties.add(party);
      }

      final allParties = [...hostedParties, ...memberParties];
      allParties.sort((a, b) => a.gameDateTime.compareTo(b.gameDateTime));

      // Cache all results
      for (final party in allParties) {
        await _partiesBox.put(party.watchPartyId, party);
        _partyMemoryCache[party.watchPartyId] = party;
      }

      PerformanceMonitor.endApiCall('get_user_watch_parties', success: true);
      return allParties;
    } catch (e) {
      PerformanceMonitor.endApiCall('get_user_watch_parties', success: false);
      LoggingService.error('Error getting user watch parties: $e', tag: _logTag);
      return [];
    }
  }

  // ==================== MEMBERSHIP (delegated) ====================

  Future<bool> joinWatchParty(
    String watchPartyId,
    WatchPartyAttendanceType attendanceType,
  ) async {
    final party = await getWatchParty(watchPartyId);
    final result = await _memberService.joinWatchParty(watchPartyId, attendanceType, party);
    if (result) {
      // Invalidate party cache since attendee count changed
      _partyMemoryCache.remove(watchPartyId);
      await _partiesBox.delete(watchPartyId);

      final displayName = await _memberService.getJoinDisplayName();
      await sendSystemMessage(watchPartyId, '$displayName joined the party');
    }
    return result;
  }

  Future<bool> leaveWatchParty(String watchPartyId) async {
    final memberName = await _memberService.getLeavingMemberName(watchPartyId);
    final result = await _memberService.leaveWatchParty(watchPartyId);
    if (result) {
      _partyMemoryCache.remove(watchPartyId);
      await _partiesBox.delete(watchPartyId);

      await sendSystemMessage(watchPartyId, '${memberName ?? "Someone"} left the party');
    }
    return result;
  }

  Future<List<WatchPartyMember>> getMembers(String watchPartyId) =>
      _memberService.getMembers(watchPartyId);

  Future<bool> isUserMember(String watchPartyId) =>
      _memberService.isUserMember(watchPartyId);

  Future<WatchPartyMember?> getCurrentUserMembership(String watchPartyId) =>
      _memberService.getCurrentUserMembership(watchPartyId);

  Future<bool> muteMember(String watchPartyId, String userId) =>
      _memberService.muteMember(watchPartyId, userId);

  Future<bool> unmuteMember(String watchPartyId, String userId) =>
      _memberService.unmuteMember(watchPartyId, userId);

  Future<bool> removeMember(String watchPartyId, String userId) async {
    final party = await getWatchParty(watchPartyId);
    final memberName = await _memberService.getRemovedMemberName(watchPartyId, userId);
    final result = await _memberService.removeMember(watchPartyId, userId, party);
    if (result && memberName != null) {
      await sendSystemMessage(watchPartyId, '$memberName was removed from the party');
    }
    return result;
  }

  Future<bool> promoteMember(String watchPartyId, String userId) async {
    final party = await getWatchParty(watchPartyId);
    final result = await _memberService.promoteMember(watchPartyId, userId, party);
    if (result) {
      await sendSystemMessage(watchPartyId, 'A member has been promoted to Co-Host');
    }
    return result;
  }

  Future<bool> demoteMember(String watchPartyId, String userId) async {
    final party = await getWatchParty(watchPartyId);
    return _memberService.demoteMember(watchPartyId, userId, party);
  }

  Future<bool> updateMemberPaymentStatus(
    String watchPartyId,
    String userId,
    String paymentIntentId,
  ) =>
      _memberService.updateMemberPaymentStatus(watchPartyId, userId, paymentIntentId);

  // ==================== CHAT (delegated) ====================

  Stream<List<WatchPartyMessage>> getMessagesStream(String watchPartyId) =>
      _chatService.getMessagesStream(watchPartyId);

  Future<WatchPartyMessage> sendMessage(
    String watchPartyId,
    String content, {
    String? replyToMessageId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final member = await _memberService.getMember(watchPartyId, user.uid);
    if (member == null) {
      throw Exception('User is not a member of this watch party');
    }

    return _chatService.sendMessage(
      watchPartyId,
      content,
      member,
      replyToMessageId: replyToMessageId,
    );
  }

  Future<bool> sendSystemMessage(String watchPartyId, String content) =>
      _chatService.sendSystemMessage(watchPartyId, content);

  Future<bool> deleteMessage(String watchPartyId, String messageId) async {
    final party = await getWatchParty(watchPartyId);
    return _chatService.deleteMessage(watchPartyId, messageId, party);
  }

  // ==================== INVITES (delegated) ====================

  Future<bool> sendInvite(
    String watchPartyId,
    String inviteeId, {
    String? message,
  }) async {
    final party = await getWatchParty(watchPartyId);
    if (party == null) return false;
    return _inviteService.sendInvite(watchPartyId, inviteeId, party, message: message);
  }

  Future<List<WatchPartyInvite>> getPendingInvites() =>
      _inviteService.getPendingInvites();

  Future<String?> respondToInvite(String inviteId, bool accept) async {
    final watchPartyId = await _inviteService.respondToInvite(inviteId, accept);
    if (accept && watchPartyId != null) {
      await joinWatchParty(watchPartyId, WatchPartyAttendanceType.inPerson);
    }
    return watchPartyId;
  }

  // ==================== STATUS MANAGEMENT ====================

  /// Start a watch party (change status to live)
  Future<bool> startWatchParty(String watchPartyId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      final party = await getWatchParty(watchPartyId);
      if (party == null || party.hostId != currentUser.uid) {
        LoggingService.error('Only host can start watch party', tag: _logTag);
        return false;
      }

      await _firestore
          .collection('watch_parties')
          .doc(watchPartyId)
          .update({
        'status': WatchPartyStatus.live.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _partyMemoryCache.remove(watchPartyId);
      _partiesBox.delete(watchPartyId);

      await sendSystemMessage(watchPartyId, 'The watch party has started! Enjoy the game!');

      return true;
    } catch (e) {
      LoggingService.error('Error starting watch party: $e', tag: _logTag);
      return false;
    }
  }

  /// End a watch party (change status to ended)
  Future<bool> endWatchParty(String watchPartyId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      final party = await getWatchParty(watchPartyId);
      if (party == null || party.hostId != currentUser.uid) {
        LoggingService.error('Only host can end watch party', tag: _logTag);
        return false;
      }

      await _firestore
          .collection('watch_parties')
          .doc(watchPartyId)
          .update({
        'status': WatchPartyStatus.ended.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _partyMemoryCache.remove(watchPartyId);
      _partiesBox.delete(watchPartyId);

      await sendSystemMessage(watchPartyId, 'The watch party has ended. Thanks for joining!');

      return true;
    } catch (e) {
      LoggingService.error('Error ending watch party: $e', tag: _logTag);
      return false;
    }
  }

  // ==================== HELPERS ====================

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

  /// Get service statistics
  Map<String, dynamic> getServiceStats() {
    return {
      'partyCacheSize': _partiesBox.length,
      'membersCacheSize': _memberService.hiveCacheSize,
      'invitesCacheSize': _inviteService.hiveCacheSize,
      'memoryPartyCacheSize': _partyMemoryCache.length,
      'memoryMembersCacheSize': _memberService.memoryCacheSize,
    };
  }

  /// Dispose of resources
  Future<void> dispose() async {
    await _chatService.dispose();
    _partyMemoryCache.clear();
    _memberService.clearCaches();
    _inviteService.clearCaches();
  }
}

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
import '../../../social/domain/services/social_service.dart';
import '../../../moderation/moderation.dart';

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
  late Box<WatchPartyMember> _membersBox;
  late Box<WatchPartyInvite> _invitesBox;

  // In-memory cache for active session
  final Map<String, WatchParty> _partyMemoryCache = {};
  final Map<String, List<WatchPartyMember>> _membersMemoryCache = {};
  final Map<String, List<WatchPartyInvite>> _invitesMemoryCache = {};

  // Stream subscriptions for real-time updates
  final Map<String, StreamSubscription> _messageSubscriptions = {};

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
      _membersBox = await Hive.openBox<WatchPartyMember>(_membersBoxName);
      _invitesBox = await Hive.openBox<WatchPartyInvite>(_invitesBoxName);

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

      // Clean expired parties
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

      // Use filtered content if profanity was detected
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
      await _addMember(
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

      // Track watch party creation in analytics
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

      // Query parties where user is host
      final hostQuery = await _firestore
          .collection('watch_parties')
          .where('hostId', isEqualTo: user.uid)
          .get();

      final hostedParties = hostQuery.docs
          .map((doc) => WatchParty.fromFirestore(doc.data(), doc.id))
          .toList();

      // Get party IDs where user is member (collection group query)
      final memberQuery = await _firestore
          .collectionGroup('members')
          .where('userId', isEqualTo: user.uid)
          .get();

      final memberPartyIds = memberQuery.docs
          .map((doc) => doc.reference.parent.parent!.id)
          .toSet();

      // Fetch member parties that aren't already in hosted
      final memberParties = <WatchParty>[];
      for (final partyId in memberPartyIds) {
        if (hostedParties.any((p) => p.watchPartyId == partyId)) continue;
        final party = await getWatchParty(partyId);
        if (party != null) memberParties.add(party);
      }

      // Combine and deduplicate
      final allParties = [...hostedParties, ...memberParties];

      // Sort by game date
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

  // ==================== MEMBERSHIP MANAGEMENT ====================

  /// Join a watch party
  Future<bool> joinWatchParty(
    String watchPartyId,
    WatchPartyAttendanceType attendanceType,
  ) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      PerformanceMonitor.startApiCall('join_watch_party');

      final party = await getWatchParty(watchPartyId);
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
      final existingMember = await _getMember(watchPartyId, user.uid);
      if (existingMember != null) {
        LoggingService.info('User already a member', tag: _logTag);
        PerformanceMonitor.endApiCall('join_watch_party', success: true);
        return true;
      }

      // Get user profile
      final userProfile = await _getUserProfile(user.uid);

      // Add member
      await _addMember(
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
      _partyMemoryCache.remove(watchPartyId);
      await _partiesBox.delete(watchPartyId);
      _membersMemoryCache.remove(watchPartyId);

      // Send system message
      await sendSystemMessage(
        watchPartyId,
        '${userProfile?.displayName ?? "Someone"} joined the party',
      );

      PerformanceMonitor.endApiCall('join_watch_party', success: true);
      return true;
    } catch (e) {
      PerformanceMonitor.endApiCall('join_watch_party', success: false);
      LoggingService.error('Error joining watch party: $e', tag: _logTag);
      return false;
    }
  }

  /// Leave a watch party
  Future<bool> leaveWatchParty(String watchPartyId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      PerformanceMonitor.startApiCall('leave_watch_party');

      final member = await _getMember(watchPartyId, user.uid);
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
      _partyMemoryCache.remove(watchPartyId);
      await _partiesBox.delete(watchPartyId);
      _membersMemoryCache.remove(watchPartyId);

      // Send system message
      await sendSystemMessage(
        watchPartyId,
        '${member.displayName} left the party',
      );

      PerformanceMonitor.endApiCall('leave_watch_party', success: true);
      return true;
    } catch (e) {
      PerformanceMonitor.endApiCall('leave_watch_party', success: false);
      LoggingService.error('Error leaving watch party: $e', tag: _logTag);
      return false;
    }
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

    final member = await _getMember(watchPartyId, user.uid);
    return member != null;
  }

  /// Get current user's membership in a watch party
  Future<WatchPartyMember?> getCurrentUserMembership(String watchPartyId) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    return _getMember(watchPartyId, user.uid);
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
  Future<bool> removeMember(String watchPartyId, String userId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final party = await getWatchParty(watchPartyId);
      if (party == null || party.hostId != user.uid) {
        LoggingService.error('User not authorized to remove members', tag: _logTag);
        return false;
      }

      final member = await _getMember(watchPartyId, userId);
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

      await sendSystemMessage(
        watchPartyId,
        '${member.displayName} was removed from the party',
      );

      PerformanceMonitor.endApiCall('remove_member', success: true);
      return true;
    } catch (e) {
      PerformanceMonitor.endApiCall('remove_member', success: false);
      LoggingService.error('Error removing member: $e', tag: _logTag);
      return false;
    }
  }

  // ==================== REAL-TIME CHAT ====================

  /// Get messages stream for real-time updates
  Stream<List<WatchPartyMessage>> getMessagesStream(String watchPartyId) {
    return _firestore
        .collection('watch_parties')
        .doc(watchPartyId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WatchPartyMessage.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// Send a text message to watch party chat
  Future<WatchPartyMessage> sendMessage(
    String watchPartyId,
    String content, {
    String? replyToMessageId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final member = await _getMember(watchPartyId, user.uid);
    if (member == null) {
      throw Exception('User is not a member of this watch party');
    }

    if (!member.canChat) {
      throw Exception('You cannot send messages (muted or unpaid virtual)');
    }

    final message = WatchPartyMessage.text(
      watchPartyId: watchPartyId,
      senderId: user.uid,
      senderName: member.displayName,
      senderImageUrl: member.profileImageUrl,
      senderRole: member.role,
      content: content,
      replyToMessageId: replyToMessageId,
    );

    await _firestore
        .collection('watch_parties')
        .doc(watchPartyId)
        .collection('messages')
        .doc(message.messageId)
        .set(message.toFirestore());

    return message;
  }

  /// Send a system message
  Future<bool> sendSystemMessage(String watchPartyId, String content) async {
    try {
      final message = WatchPartyMessage.system(
        watchPartyId: watchPartyId,
        content: content,
      );

      await _firestore
          .collection('watch_parties')
          .doc(watchPartyId)
          .collection('messages')
          .doc(message.messageId)
          .set(message.toFirestore());

      return true;
    } catch (e) {
      LoggingService.error('Error sending system message: $e', tag: _logTag);
      return false;
    }
  }

  /// Delete a message (sender or host only)
  Future<bool> deleteMessage(String watchPartyId, String messageId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final doc = await _firestore
          .collection('watch_parties')
          .doc(watchPartyId)
          .collection('messages')
          .doc(messageId)
          .get();

      if (!doc.exists) return false;

      final message = WatchPartyMessage.fromFirestore(doc.data()!, doc.id);
      final party = await getWatchParty(watchPartyId);

      // Only sender or host can delete
      if (message.senderId != user.uid && party?.hostId != user.uid) {
        return false;
      }

      await _firestore
          .collection('watch_parties')
          .doc(watchPartyId)
          .collection('messages')
          .doc(messageId)
          .update({
        'isDeleted': true,
        'content': 'This message was deleted',
      });

      return true;
    } catch (e) {
      LoggingService.error('Error deleting message: $e', tag: _logTag);
      return false;
    }
  }

  // ==================== INVITES ====================

  /// Send invite to a user
  Future<bool> sendInvite(
    String watchPartyId,
    String inviteeId, {
    String? message,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      PerformanceMonitor.startApiCall('send_invite');

      final party = await getWatchParty(watchPartyId);
      if (party == null) {
        PerformanceMonitor.endApiCall('send_invite', success: false);
        return false;
      }

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
          await joinWatchParty(
            invite.watchPartyId,
            WatchPartyAttendanceType.inPerson,
          );
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

  // ==================== HELPER METHODS ====================

  Future<void> _addMember(
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

  Future<WatchPartyMember?> _getMember(String watchPartyId, String userId) async {
    try {
      // Check Hive cache
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

  Future<bool> _updateMemberStatus(
    String watchPartyId,
    String userId, {
    bool? isMuted,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final party = await getWatchParty(watchPartyId);
      if (party == null || party.hostId != user.uid) {
        return false;
      }

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
      // Use SocialService if available, otherwise fetch directly
      final doc = await _firestore.collection('user_profiles').doc(userId).get();
      if (!doc.exists) return null;
      return UserProfile.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      LoggingService.error('Error getting user profile: $e', tag: _logTag);
      return null;
    }
  }

  Future<void> _createInviteNotification(WatchPartyInvite invite) async {
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

  // ==================== MEMBER MANAGEMENT ====================

  /// Promote a member to co-host
  Future<bool> promoteMember(String watchPartyId, String userId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      // Verify current user is the host
      final party = await getWatchParty(watchPartyId);
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

      // Send system message
      await sendSystemMessage(watchPartyId, 'A member has been promoted to Co-Host');

      return true;
    } catch (e) {
      LoggingService.error('Error promoting member: $e', tag: _logTag);
      return false;
    }
  }

  /// Demote a co-host to regular member
  Future<bool> demoteMember(String watchPartyId, String userId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      // Verify current user is the host
      final party = await getWatchParty(watchPartyId);
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

      // Clear cache
      _partyMemoryCache.remove(watchPartyId);
      _partiesBox.delete(watchPartyId);

      // Send system message
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

      // Clear cache
      _partyMemoryCache.remove(watchPartyId);
      _partiesBox.delete(watchPartyId);

      // Send system message
      await sendSystemMessage(watchPartyId, 'The watch party has ended. Thanks for joining!');

      return true;
    } catch (e) {
      LoggingService.error('Error ending watch party: $e', tag: _logTag);
      return false;
    }
  }

  /// Get service statistics
  Map<String, dynamic> getServiceStats() {
    return {
      'partyCacheSize': _partiesBox.length,
      'membersCacheSize': _membersBox.length,
      'invitesCacheSize': _invitesBox.length,
      'memoryPartyCacheSize': _partyMemoryCache.length,
      'memoryMembersCacheSize': _membersMemoryCache.length,
    };
  }

  /// Dispose of resources
  Future<void> dispose() async {
    for (final subscription in _messageSubscriptions.values) {
      await subscription.cancel();
    }
    _messageSubscriptions.clear();
    _partyMemoryCache.clear();
    _membersMemoryCache.clear();
    _invitesMemoryCache.clear();
  }
}

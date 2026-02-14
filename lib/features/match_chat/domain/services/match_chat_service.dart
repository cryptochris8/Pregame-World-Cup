import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/services/logging_service.dart';
import '../../../moderation/domain/services/moderation_service.dart';
import '../../../social/domain/entities/user_profile.dart';
import '../entities/match_chat.dart';

/// Service for managing live match chat functionality
class MatchChatService {
  static const String _logTag = 'MatchChatService';
  static const String _matchChatsCollection = 'match_chats';
  static const String _messagesSubcollection = 'messages';
  static const String _participantsSubcollection = 'participants';

  static MatchChatService? _instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final ModerationService _moderationService;

  // Rate limiting
  final Map<String, DateTime> _lastMessageTime = {};
  static const int _defaultRateLimitSeconds = 3;
  static const int _burstLimit = 5; // Max messages in burst window
  static const int _burstWindowSeconds = 10;
  final Map<String, List<DateTime>> _recentMessages = {};

  // Active streams
  final Map<String, StreamController<List<MatchChatMessage>>> _messageStreams = {};
  final Map<String, StreamSubscription> _messageSubscriptions = {};
  final Map<String, StreamController<int>> _participantCountStreams = {};

  // Current user info cache
  UserProfile? _currentUserProfile;

  MatchChatService._({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    ModerationService? moderationService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _moderationService = moderationService ?? ModerationService();

  factory MatchChatService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    ModerationService? moderationService,
  }) {
    _instance ??= MatchChatService._(
      firestore: firestore,
      auth: auth,
      moderationService: moderationService,
    );
    return _instance!;
  }

  String? get currentUserId => _auth.currentUser?.uid;

  // ==================== CHAT ROOM MANAGEMENT ====================

  /// Get or create a match chat room
  Future<MatchChat?> getOrCreateMatchChat({
    required String matchId,
    required String matchName,
    required String homeTeam,
    required String awayTeam,
    required DateTime matchDateTime,
  }) async {
    try {
      // Check if chat already exists
      final existingQuery = await _firestore
          .collection(_matchChatsCollection)
          .where('matchId', isEqualTo: matchId)
          .limit(1)
          .get();

      if (existingQuery.docs.isNotEmpty) {
        return MatchChat.fromFirestore(
          existingQuery.docs.first.data(),
          existingQuery.docs.first.id,
        );
      }

      // Create new chat room
      final chatData = MatchChat(
        chatId: '', // Will be set by Firestore
        matchId: matchId,
        matchName: matchName,
        homeTeam: homeTeam,
        awayTeam: awayTeam,
        matchDateTime: matchDateTime,
        createdAt: DateTime.now(),
      );

      final docRef = await _firestore
          .collection(_matchChatsCollection)
          .add(chatData.toFirestore());

      LoggingService.info('Created match chat for $matchName', tag: _logTag);

      return MatchChat(
        chatId: docRef.id,
        matchId: matchId,
        matchName: matchName,
        homeTeam: homeTeam,
        awayTeam: awayTeam,
        matchDateTime: matchDateTime,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      LoggingService.error('Error creating match chat: $e', tag: _logTag);
      return null;
    }
  }

  /// Get match chat by ID
  Future<MatchChat?> getMatchChat(String chatId) async {
    try {
      final doc = await _firestore
          .collection(_matchChatsCollection)
          .doc(chatId)
          .get();

      if (!doc.exists) return null;

      return MatchChat.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      LoggingService.error('Error getting match chat: $e', tag: _logTag);
      return null;
    }
  }

  /// Get active match chats (matches happening now or soon)
  Future<List<MatchChat>> getActiveMatchChats() async {
    try {
      final now = DateTime.now();
      final twoHoursAgo = now.subtract(const Duration(hours: 2));
      final twoHoursFromNow = now.add(const Duration(hours: 2));

      final query = await _firestore
          .collection(_matchChatsCollection)
          .where('matchDateTime', isGreaterThan: Timestamp.fromDate(twoHoursAgo))
          .where('matchDateTime', isLessThan: Timestamp.fromDate(twoHoursFromNow))
          .where('isActive', isEqualTo: true)
          .orderBy('matchDateTime')
          .limit(20)
          .get();

      return query.docs
          .map((doc) => MatchChat.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      LoggingService.error('Error getting active match chats: $e', tag: _logTag);
      return [];
    }
  }

  // ==================== JOIN/LEAVE ====================

  /// Join a match chat
  Future<bool> joinMatchChat(String chatId) async {
    final userId = currentUserId;
    if (userId == null) return false;

    try {
      // Add to participants subcollection
      await _firestore
          .collection(_matchChatsCollection)
          .doc(chatId)
          .collection(_participantsSubcollection)
          .doc(userId)
          .set({
        'userId': userId,
        'joinedAt': FieldValue.serverTimestamp(),
        'displayName': _currentUserProfile?.displayName ?? 'User',
        'imageUrl': _currentUserProfile?.profileImageUrl,
        'teamFlair': _currentUserProfile?.favoriteTeams.isNotEmpty == true
            ? _currentUserProfile!.favoriteTeams.first
            : null,
      });

      // Increment participant count
      await _firestore.collection(_matchChatsCollection).doc(chatId).update({
        'participantCount': FieldValue.increment(1),
      });

      LoggingService.info('User joined match chat: $chatId', tag: _logTag);
      return true;
    } catch (e) {
      LoggingService.error('Error joining match chat: $e', tag: _logTag);
      return false;
    }
  }

  /// Leave a match chat
  Future<bool> leaveMatchChat(String chatId) async {
    final userId = currentUserId;
    if (userId == null) return false;

    try {
      // Remove from participants
      await _firestore
          .collection(_matchChatsCollection)
          .doc(chatId)
          .collection(_participantsSubcollection)
          .doc(userId)
          .delete();

      // Decrement participant count
      await _firestore.collection(_matchChatsCollection).doc(chatId).update({
        'participantCount': FieldValue.increment(-1),
      });

      // Clean up streams
      _cleanupChatStreams(chatId);

      LoggingService.info('User left match chat: $chatId', tag: _logTag);
      return true;
    } catch (e) {
      LoggingService.error('Error leaving match chat: $e', tag: _logTag);
      return false;
    }
  }

  /// Check if user is in chat
  Future<bool> isUserInChat(String chatId) async {
    final userId = currentUserId;
    if (userId == null) return false;

    try {
      final doc = await _firestore
          .collection(_matchChatsCollection)
          .doc(chatId)
          .collection(_participantsSubcollection)
          .doc(userId)
          .get();

      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Get participant count stream
  Stream<int> getParticipantCountStream(String chatId) {
    if (!_participantCountStreams.containsKey(chatId)) {
      final controller = StreamController<int>.broadcast();
      _participantCountStreams[chatId] = controller;

      _firestore
          .collection(_matchChatsCollection)
          .doc(chatId)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          final count = snapshot.data()?['participantCount'] as int? ?? 0;
          controller.add(count);
        }
      });
    }

    return _participantCountStreams[chatId]!.stream;
  }

  // ==================== MESSAGES ====================

  /// Get messages stream for a chat
  Stream<List<MatchChatMessage>> getMessagesStream(String chatId) {
    if (!_messageStreams.containsKey(chatId)) {
      final controller = StreamController<List<MatchChatMessage>>.broadcast();
      _messageStreams[chatId] = controller;

      final subscription = _firestore
          .collection(_matchChatsCollection)
          .doc(chatId)
          .collection(_messagesSubcollection)
          .orderBy('sentAt', descending: true)
          .limit(100)
          .snapshots()
          .listen((snapshot) {
        final messages = snapshot.docs
            .map((doc) => MatchChatMessage.fromFirestore(doc.data(), doc.id))
            .toList();
        controller.add(messages);
      });

      _messageSubscriptions[chatId] = subscription;
    }

    return _messageStreams[chatId]!.stream;
  }

  /// Send a message with rate limiting
  Future<SendMessageResult> sendMessage({
    required String chatId,
    required String content,
    MatchChatMessageType type = MatchChatMessageType.text,
    MatchEventData? eventData,
  }) async {
    final userId = currentUserId;
    if (userId == null) {
      return SendMessageResult.notAuthenticated();
    }

    // Check rate limit
    final rateLimitResult = _checkRateLimit(userId, chatId);
    if (!rateLimitResult.allowed) {
      return SendMessageResult.rateLimited(rateLimitResult.waitSeconds);
    }

    // Validate content length
    if (content.length > 500) {
      return SendMessageResult.contentTooLong(500);
    }

    // Check for profanity/moderation
    final moderationResult = await _moderationService.validateMessage(content);
    if (!moderationResult.isValid) {
      return SendMessageResult.blocked(moderationResult.errorMessage ?? 'Content violation');
    }

    try {
      // Get user profile if needed
      await _ensureUserProfile();

      final message = MatchChatMessage(
        messageId: '', // Set by Firestore
        chatId: chatId,
        senderId: userId,
        senderName: _currentUserProfile?.displayName ?? 'User',
        senderImageUrl: _currentUserProfile?.profileImageUrl,
        senderTeamFlair: _currentUserProfile?.favoriteTeams.isNotEmpty == true
            ? _currentUserProfile!.favoriteTeams.first
            : null,
        content: moderationResult.filteredMessage ?? content,
        type: type,
        sentAt: DateTime.now(),
        eventData: eventData,
      );

      await _firestore
          .collection(_matchChatsCollection)
          .doc(chatId)
          .collection(_messagesSubcollection)
          .add(message.toFirestore());

      // Update message count
      await _firestore.collection(_matchChatsCollection).doc(chatId).update({
        'messageCount': FieldValue.increment(1),
      });

      // Record message time for rate limiting
      _recordMessage(userId, chatId);

      return SendMessageResult.success();
    } catch (e) {
      LoggingService.error('Error sending message: $e', tag: _logTag);
      return SendMessageResult.error(e.toString());
    }
  }

  /// Send a quick reaction (emoji burst)
  Future<bool> sendQuickReaction(String chatId, String emoji) async {
    final userId = currentUserId;
    if (userId == null) return false;

    // Quick reactions have a shorter rate limit
    final lastReaction = _lastMessageTime['reaction_$userId'];
    if (lastReaction != null &&
        DateTime.now().difference(lastReaction).inSeconds < 1) {
      return false; // 1 second between reactions
    }

    try {
      await _ensureUserProfile();

      final message = MatchChatMessage(
        messageId: '',
        chatId: chatId,
        senderId: userId,
        senderName: _currentUserProfile?.displayName ?? 'User',
        senderImageUrl: _currentUserProfile?.profileImageUrl,
        senderTeamFlair: _currentUserProfile?.favoriteTeams.isNotEmpty == true
            ? _currentUserProfile!.favoriteTeams.first
            : null,
        content: emoji,
        type: MatchChatMessageType.eventReaction,
        sentAt: DateTime.now(),
      );

      await _firestore
          .collection(_matchChatsCollection)
          .doc(chatId)
          .collection(_messagesSubcollection)
          .add(message.toFirestore());

      _lastMessageTime['reaction_$userId'] = DateTime.now();
      return true;
    } catch (e) {
      LoggingService.error('Error sending reaction: $e', tag: _logTag);
      return false;
    }
  }

  /// Add reaction to a message
  Future<bool> toggleMessageReaction(
    String chatId,
    String messageId,
    String emoji,
  ) async {
    final userId = currentUserId;
    if (userId == null) return false;

    try {
      final messageRef = _firestore
          .collection(_matchChatsCollection)
          .doc(chatId)
          .collection(_messagesSubcollection)
          .doc(messageId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(messageRef);
        if (!snapshot.exists) return;

        final data = snapshot.data()!;
        final reactions = Map<String, List<String>>.from(
          (data['reactions'] as Map<String, dynamic>? ?? {}).map(
            (key, value) => MapEntry(key, List<String>.from(value ?? [])),
          ),
        );

        final emojiReactions = reactions[emoji] ?? [];
        if (emojiReactions.contains(userId)) {
          emojiReactions.remove(userId);
        } else {
          emojiReactions.add(userId);
        }
        reactions[emoji] = emojiReactions;

        // Remove empty reaction lists
        reactions.removeWhere((key, value) => value.isEmpty);

        transaction.update(messageRef, {'reactions': reactions});
      });

      return true;
    } catch (e) {
      LoggingService.error('Error toggling reaction: $e', tag: _logTag);
      return false;
    }
  }

  /// Delete a message (moderator action)
  Future<bool> deleteMessage(String chatId, String messageId) async {
    final userId = currentUserId;
    if (userId == null) return false;

    try {
      await _firestore
          .collection(_matchChatsCollection)
          .doc(chatId)
          .collection(_messagesSubcollection)
          .doc(messageId)
          .update({
        'isDeleted': true,
        'deletedBy': userId,
        'content': '[Message deleted]',
      });

      return true;
    } catch (e) {
      LoggingService.error('Error deleting message: $e', tag: _logTag);
      return false;
    }
  }

  // ==================== RATE LIMITING ====================

  RateLimitResult _checkRateLimit(String userId, String chatId) {
    final key = '${chatId}_$userId';
    final now = DateTime.now();

    // Check burst limit
    final recentMsgs = _recentMessages[key] ?? [];
    final windowStart = now.subtract(const Duration(seconds: _burstWindowSeconds));
    final messagesInWindow = recentMsgs.where((t) => t.isAfter(windowStart)).toList();

    if (messagesInWindow.length >= _burstLimit) {
      final oldestInWindow = messagesInWindow.first;
      final waitSeconds = _burstWindowSeconds -
          now.difference(oldestInWindow).inSeconds;
      return RateLimitResult(allowed: false, waitSeconds: waitSeconds);
    }

    // Check simple rate limit
    final lastMessage = _lastMessageTime[key];
    if (lastMessage != null) {
      final secondsSinceLastMessage = now.difference(lastMessage).inSeconds;
      if (secondsSinceLastMessage < _defaultRateLimitSeconds) {
        return RateLimitResult(
          allowed: false,
          waitSeconds: _defaultRateLimitSeconds - secondsSinceLastMessage,
        );
      }
    }

    return RateLimitResult(allowed: true);
  }

  void _recordMessage(String userId, String chatId) {
    final key = '${chatId}_$userId';
    final now = DateTime.now();

    _lastMessageTime[key] = now;

    // Track recent messages for burst limiting
    final recentMsgs = _recentMessages[key] ?? [];
    recentMsgs.add(now);

    // Clean up old entries
    final windowStart = now.subtract(const Duration(seconds: _burstWindowSeconds));
    recentMsgs.removeWhere((t) => t.isBefore(windowStart));
    _recentMessages[key] = recentMsgs;
  }

  /// Get seconds until user can send next message
  int getSecondsUntilNextMessage(String chatId) {
    final userId = currentUserId;
    if (userId == null) return 0;

    final result = _checkRateLimit(userId, chatId);
    return result.waitSeconds;
  }

  // ==================== HELPERS ====================

  Future<void> _ensureUserProfile() async {
    if (_currentUserProfile != null) return;

    final userId = currentUserId;
    if (userId == null) return;

    try {
      final doc = await _firestore.collection('user_profiles').doc(userId).get();
      if (doc.exists) {
        _currentUserProfile = UserProfile.fromFirestore(doc.data()!, doc.id);
      }
    } catch (e) {
      LoggingService.error('Error getting user profile: $e', tag: _logTag);
    }
  }

  void setCurrentUserProfile(UserProfile profile) {
    _currentUserProfile = profile;
  }

  void _cleanupChatStreams(String chatId) {
    _messageSubscriptions[chatId]?.cancel();
    _messageSubscriptions.remove(chatId);
    _messageStreams[chatId]?.close();
    _messageStreams.remove(chatId);
    _participantCountStreams[chatId]?.close();
    _participantCountStreams.remove(chatId);
  }

  /// Dispose of all resources
  void dispose() {
    for (final subscription in _messageSubscriptions.values) {
      subscription.cancel();
    }
    _messageSubscriptions.clear();

    for (final controller in _messageStreams.values) {
      controller.close();
    }
    _messageStreams.clear();

    for (final controller in _participantCountStreams.values) {
      controller.close();
    }
    _participantCountStreams.clear();

    _lastMessageTime.clear();
    _recentMessages.clear();
  }
}

/// Result of rate limit check
class RateLimitResult {
  final bool allowed;
  final int waitSeconds;

  RateLimitResult({required this.allowed, this.waitSeconds = 0});
}

/// Result of sending a message
class SendMessageResult {
  final bool success;
  final String? error;
  final int? waitSeconds;
  final int? maxLength;

  SendMessageResult._({
    required this.success,
    this.error,
    this.waitSeconds,
    this.maxLength,
  });

  factory SendMessageResult.success() => SendMessageResult._(success: true);

  factory SendMessageResult.notAuthenticated() => SendMessageResult._(
        success: false,
        error: 'Not authenticated',
      );

  factory SendMessageResult.rateLimited(int seconds) => SendMessageResult._(
        success: false,
        error: 'Rate limited',
        waitSeconds: seconds,
      );

  factory SendMessageResult.contentTooLong(int maxLength) => SendMessageResult._(
        success: false,
        error: 'Message too long',
        maxLength: maxLength,
      );

  factory SendMessageResult.blocked(String reason) => SendMessageResult._(
        success: false,
        error: reason,
      );

  factory SendMessageResult.error(String error) => SendMessageResult._(
        success: false,
        error: error,
      );
}

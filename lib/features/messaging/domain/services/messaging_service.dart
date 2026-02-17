import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../entities/message.dart';
import '../entities/chat.dart';
import '../entities/typing_indicator.dart';
import '../../../../core/services/cache_service.dart';
import '../../../../core/services/logging_service.dart';
import '../../../social/domain/services/social_service.dart';
import 'messaging_group_management_service.dart';
import 'messaging_chat_settings_service.dart';
import 'messaging_message_service.dart';
import 'messaging_stream_service.dart';

/// Facade service for messaging: delegates to focused sub-services.
///
/// Sub-services:
/// - [MessagingMessageService]: Message CRUD, send, reactions, read status
/// - [MessagingStreamService]: Real-time streams and typing indicators
/// - [MessagingGroupManagementService]: Group member management
/// - [MessagingChatSettingsService]: Per-user chat settings (mute, archive, etc.)
class MessagingService {
  static final MessagingService _instance = MessagingService._internal();
  factory MessagingService() => _instance;
  MessagingService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isInitialized = false;

  // Cache keys
  static const String _chatsKey = 'user_chats';
  static const String _messagesKeyPrefix = 'chat_messages_';

  // Sub-services (lazily initialized)
  late final MessagingMessageService _messages = MessagingMessageService(
    firestore: _firestore,
    auth: _auth,
    messagesKeyPrefix: _messagesKeyPrefix,
    chatsKey: _chatsKey,
    chatFromFirestore: _chatFromFirestore,
  );

  late final MessagingStreamService _streams = MessagingStreamService(
    firestore: _firestore,
    auth: _auth,
    chatFromFirestore: _chatFromFirestore,
  );

  late final MessagingGroupManagementService _groupManagement = MessagingGroupManagementService(
    firestore: _firestore,
    auth: _auth,
    sendSystemMessage: sendSystemMessage,
    chatFromFirestore: _chatFromFirestore,
    chatsKey: _chatsKey,
  );

  late final MessagingChatSettingsService _chatSettings = MessagingChatSettingsService(
    firestore: _firestore,
    auth: _auth,
    chatsKey: _chatsKey,
  );

  Stream<List<Chat>> get chatsStream => _streams.chatsStream;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      LoggingService.info('Initializing MessagingService...', tag: 'MessagingService');

      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        _streams.listenToUserChats(currentUser.uid);
      }

      _isInitialized = true;
      LoggingService.info('MessagingService initialized successfully', tag: 'MessagingService');
    } catch (e) {
      LoggingService.error('Error initializing MessagingService: $e', tag: 'MessagingService');
      rethrow;
    }
  }

  void dispose() {
    _streams.dispose();
  }

  // ==================== Chat Management ====================

  Future<Chat?> getChatById(String chatId) async {
    try {
      final doc = await _firestore.collection('chats').doc(chatId).get();
      if (doc.exists) {
        return _chatFromFirestore(doc);
      }
      return null;
    } catch (e) {
      LoggingService.error('Error getting chat by ID: $e', tag: 'MessagingService');
      return null;
    }
  }

  Future<List<Chat>> getUserChats(String userId) async {
    try {
      final cached = await CacheService.instance.get<List<dynamic>>(_chatsKey);
      if (cached != null) {
        return cached.map((data) => Chat.fromJson(data)).toList();
      }

      final snapshot = await _firestore
          .collection('chats')
          .where('participantIds', arrayContains: userId)
          .where('isActive', isEqualTo: true)
          .orderBy('lastMessageTime', descending: true)
          .get();

      final chats = snapshot.docs.map(_chatFromFirestore).toList();

      await CacheService.instance.set(
        _chatsKey,
        chats.map((chat) => chat.toJson()).toList(),
        duration: const Duration(minutes: 10),
      );

      return chats;
    } catch (e) {
      LoggingService.error('Error getting user chats: $e', tag: 'MessagingService');
      return [];
    }
  }

  Future<Chat?> createDirectChat(String otherUserId, String otherUserName) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return null;

    try {
      final socialService = SocialService();
      final isBlocked = await socialService.isUserBlocked(currentUser.uid, otherUserId);
      if (isBlocked) {
        LoggingService.warning('Cannot create chat - user is blocked', tag: 'MessagingService');
        return null;
      }

      final existingChat = await _findDirectChat(currentUser.uid, otherUserId);
      if (existingChat != null) return existingChat;

      final chat = Chat.direct(
        currentUserId: currentUser.uid,
        participantUserId: otherUserId,
      );

      await _firestore.collection('chats').doc(chat.chatId).set(chat.toJson());
      await CacheService.instance.remove(_chatsKey);

      return chat;
    } catch (e) {
      LoggingService.error('Error creating direct chat: $e', tag: 'MessagingService');
      return null;
    }
  }

  Future<Chat?> createGroupChat({
    required String name,
    String? description,
    String? imageUrl,
    required List<String> participantIds,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return null;

    try {
      final chat = Chat.group(
        name: name,
        creatorId: currentUser.uid,
        participantIds: participantIds,
        description: description,
        imageUrl: imageUrl,
      );

      await _firestore.collection('chats').doc(chat.chatId).set(chat.toJson());

      await sendSystemMessage(
        chatId: chat.chatId,
        content: '${currentUser.displayName ?? 'Someone'} created the group',
      );

      await CacheService.instance.remove(_chatsKey);

      return chat;
    } catch (e) {
      LoggingService.error('Error creating group chat: $e', tag: 'MessagingService');
      return null;
    }
  }

  Future<Chat?> createTeamChat({
    required String teamName,
    String? description,
    String? imageUrl,
    required List<String> participantIds,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return null;

    try {
      final chat = Chat.team(
        teamName: teamName,
        creatorId: currentUser.uid,
        memberIds: participantIds,
        description: description,
        imageUrl: imageUrl,
      );

      await _firestore.collection('chats').doc(chat.chatId).set(chat.toJson());

      await sendSystemMessage(
        chatId: chat.chatId,
        content: 'Welcome to the $teamName fans chat! 🏈',
      );

      await CacheService.instance.remove(_chatsKey);

      return chat;
    } catch (e) {
      LoggingService.error('Error creating team chat: $e', tag: 'MessagingService');
      return null;
    }
  }

  Future<bool> createChat(Chat chat) async {
    try {
      await _firestore.collection('chats').doc(chat.chatId).set(chat.toJson());
      await CacheService.instance.set('chat_${chat.chatId}', chat.toJson(), duration: const Duration(minutes: 10));
      return true;
    } catch (e) {
      LoggingService.error('Error creating chat: $e', tag: 'MessagingService');
      return false;
    }
  }

  // ==================== Message Management (delegated) ====================

  Future<List<Message>> getChatMessages(String chatId, {int limit = 50}) =>
      _messages.getChatMessages(chatId, limit: limit);

  Future<List<Message>> getMessages(String chatId) =>
      _messages.getChatMessages(chatId);

  Future<bool> sendMessage({
    required String chatId,
    required String content,
    MessageType type = MessageType.text,
    String? replyToMessageId,
    Map<String, dynamic>? metadata,
  }) =>
      _messages.sendMessage(
        chatId: chatId,
        content: content,
        type: type,
        replyToMessageId: replyToMessageId,
        metadata: metadata,
      );

  Future<bool> sendSystemMessage({
    required String chatId,
    required String content,
    Map<String, dynamic>? metadata,
  }) =>
      _messages.sendSystemMessage(
        chatId: chatId,
        content: content,
        metadata: metadata,
      );

  Future<bool> addReactionToMessage(String messageId, String emoji) =>
      _messages.addReactionToMessage(messageId, emoji);

  Future<bool> markChatAsRead(String chatId) =>
      _messages.markChatAsRead(chatId);

  Future<void> markMessagesAsRead(String chatId) =>
      _messages.markMessagesAsRead(chatId);

  // ==================== Real-time Streams (delegated) ====================

  Stream<List<Message>> getMessageStream(String chatId) =>
      _streams.getMessageStream(chatId);

  Stream<List<TypingIndicator>> getTypingIndicatorsStream(String chatId) =>
      _streams.getTypingIndicatorsStream(chatId);

  Future<void> setTypingIndicator(String chatId, bool isTyping) =>
      _streams.setTypingIndicator(chatId, isTyping);

  // ==================== Group Management (delegated) ====================

  Future<bool> addMemberToChat(String chatId, String userId, String userName) =>
      _groupManagement.addMemberToChat(chatId, userId, userName);

  Future<bool> removeMemberFromChat(String chatId, String userId) =>
      _groupManagement.removeMemberFromChat(chatId, userId);

  Future<bool> leaveChat(String chatId) =>
      _groupManagement.leaveChat(chatId);

  Future<bool> promoteToAdmin(String chatId, String userId) =>
      _groupManagement.promoteToAdmin(chatId, userId);

  Future<bool> demoteFromAdmin(String chatId, String userId) =>
      _groupManagement.demoteFromAdmin(chatId, userId);

  Future<List<ChatMemberInfo>> getChatMembers(String chatId) =>
      _groupManagement.getChatMembers(chatId);

  // ==================== Chat Settings (delegated) ====================

  Future<bool> muteChat(String chatId, {Duration? duration}) =>
      _chatSettings.muteChat(chatId, duration: duration);

  Future<bool> unmuteChat(String chatId) =>
      _chatSettings.unmuteChat(chatId);

  Future<bool> isChatMuted(String chatId) =>
      _chatSettings.isChatMuted(chatId);

  Future<bool> archiveChat(String chatId) =>
      _chatSettings.archiveChat(chatId);

  Future<bool> unarchiveChat(String chatId) =>
      _chatSettings.unarchiveChat(chatId);

  Future<bool> isChatArchived(String chatId) =>
      _chatSettings.isChatArchived(chatId);

  Future<ChatSettings> getChatSettings(String chatId) =>
      _chatSettings.getChatSettings(chatId);

  Future<bool> deleteChat(String chatId) =>
      _chatSettings.deleteChat(chatId);

  Future<bool> clearChatHistory(String chatId) =>
      _chatSettings.clearChatHistory(chatId, _messagesKeyPrefix);

  Future<DateTime?> getChatClearedAt(String chatId) =>
      _chatSettings.getChatClearedAt(chatId);

  Future<BlockStatus> getChatBlockStatus(Chat chat) =>
      _chatSettings.getChatBlockStatus(chat);

  // ==================== Private Helpers ====================

  Future<Chat?> _findDirectChat(String userId1, String userId2) async {
    try {
      final sortedIds = [userId1, userId2]..sort();
      final chatId = 'dm_${sortedIds[0]}_${sortedIds[1]}';

      final doc = await _firestore.collection('chats').doc(chatId).get();
      if (doc.exists) {
        return _chatFromFirestore(doc);
      }
      return null;
    } catch (e) {
      LoggingService.error('Error finding direct chat: $e', tag: 'MessagingService');
      return null;
    }
  }

  Chat _chatFromFirestore(DocumentSnapshot doc) {
    final data = Map<String, dynamic>.from(doc.data() as Map);
    return Chat.fromJson({...data, 'chatId': doc.id});
  }
}

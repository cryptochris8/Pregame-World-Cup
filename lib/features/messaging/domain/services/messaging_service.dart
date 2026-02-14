import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../entities/message.dart';
import '../entities/chat.dart';
import '../entities/typing_indicator.dart';
import '../../../../core/services/cache_service.dart';
import '../../../../core/services/logging_service.dart';
import '../../../social/domain/services/social_service.dart';
import '../../../moderation/moderation.dart';
import 'messaging_group_management_service.dart';
import 'messaging_chat_settings_service.dart';

/// Facade service for messaging: delegates group management, chat settings,
/// and serialization to focused sub-services.
class MessagingService {
  static final MessagingService _instance = MessagingService._internal();
  factory MessagingService() => _instance;
  MessagingService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isInitialized = false;

  // Stream controllers for real-time updates
  final Map<String, StreamController<List<Message>>> _messageStreams = {};
  final Map<String, StreamController<List<TypingIndicator>>> _typingStreams = {};
  final StreamController<List<Chat>> _chatsStreamController = StreamController<List<Chat>>.broadcast();

  // Typing indicator timers
  final Map<String, Timer> _typingTimers = {};

  // Cache keys
  static const String _chatsKey = 'user_chats';
  static const String _messagesKeyPrefix = 'chat_messages_';

  // Cache durations
  static const Duration _chatsCacheDuration = Duration(minutes: 10);
  static const Duration _messagesCacheDuration = Duration(minutes: 5);

  // Sub-services (lazily initialized)
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

  Stream<List<Chat>> get chatsStream => _chatsStreamController.stream;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      LoggingService.info('Initializing MessagingService...', tag: 'MessagingService');

      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        _listenToUserChats(currentUser.uid);
      }

      _isInitialized = true;
      LoggingService.info('MessagingService initialized successfully', tag: 'MessagingService');
    } catch (e) {
      LoggingService.error('Error initializing MessagingService: $e', tag: 'MessagingService');
      rethrow;
    }
  }

  void dispose() {
    for (final controller in _messageStreams.values) {
      controller.close();
    }
    for (final controller in _typingStreams.values) {
      controller.close();
    }
    for (final timer in _typingTimers.values) {
      timer.cancel();
    }
    _messageStreams.clear();
    _typingStreams.clear();
    _typingTimers.clear();
    _chatsStreamController.close();
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
        duration: _chatsCacheDuration,
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

  // ==================== Message Management ====================

  Future<List<Message>> getChatMessages(String chatId, {int limit = 50}) async {
    try {
      final cacheKey = '$_messagesKeyPrefix$chatId';
      final cached = await CacheService.instance.get<List<dynamic>>(cacheKey);
      if (cached != null) {
        return cached.map((data) => Message.fromJson(data)).toList();
      }

      final snapshot = await _firestore
          .collection('messages')
          .where('chatId', isEqualTo: chatId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final messages = snapshot.docs
          .map(_messageFromFirestore)
          .toList()
          .reversed
          .toList();

      await CacheService.instance.set(
        cacheKey,
        messages.map((message) => message.toJson()).toList(),
        duration: _messagesCacheDuration,
      );

      return messages;
    } catch (e) {
      LoggingService.error('Error getting chat messages: $e', tag: 'MessagingService');
      return [];
    }
  }

  Future<List<Message>> getMessages(String chatId) async {
    return await getChatMessages(chatId);
  }

  Future<bool> sendMessage({
    required String chatId,
    required String content,
    MessageType type = MessageType.text,
    String? replyToMessageId,
    Map<String, dynamic>? metadata,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      final moderationService = ModerationService();
      final validationResult = await moderationService.validateMessage(content);

      if (!validationResult.isValid) {
        LoggingService.warning(
          'Message blocked by moderation: ${validationResult.errorMessage}',
          tag: 'MessagingService',
        );
        return false;
      }

      final filteredContent = validationResult.filteredMessage ?? content;

      // Check for blocks in direct chats
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      if (chatDoc.exists) {
        final chatData = chatDoc.data()!;
        final chatType = chatData['type'] as String?;

        if (chatType == 'direct') {
          final participants = List<String>.from(chatData['participantIds'] ?? []);
          final otherUserId = participants.firstWhere(
            (id) => id != currentUser.uid,
            orElse: () => '',
          );

          if (otherUserId.isNotEmpty) {
            final socialService = SocialService();
            final isBlocked = await socialService.isUserBlocked(currentUser.uid, otherUserId);
            if (isBlocked) {
              LoggingService.warning('Cannot send message - user is blocked', tag: 'MessagingService');
              return false;
            }
          }
        }
      }

      final message = Message(
        messageId: '${chatId}_${DateTime.now().millisecondsSinceEpoch}',
        chatId: chatId,
        senderId: currentUser.uid,
        senderName: currentUser.displayName ?? 'Anonymous',
        senderImageUrl: currentUser.photoURL,
        content: filteredContent,
        type: type,
        createdAt: DateTime.now(),
        status: MessageStatus.sent,
        replyToMessageId: replyToMessageId,
        metadata: metadata ?? {},
      );

      await _firestore.collection('messages').doc(message.messageId).set(message.toJson());
      await _updateChatLastMessage(chatId, message);
      await _triggerMessageNotifications(chatId, message);

      await CacheService.instance.remove('$_messagesKeyPrefix$chatId');
      await CacheService.instance.remove(_chatsKey);

      return true;
    } catch (e) {
      LoggingService.error('Error sending message: $e', tag: 'MessagingService');
      return false;
    }
  }

  Future<bool> sendSystemMessage({
    required String chatId,
    required String content,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final message = Message.system(
        chatId: chatId,
        content: content,
        metadata: metadata,
      );

      await _firestore.collection('messages').doc(message.messageId).set(message.toJson());
      await _updateChatLastMessage(chatId, message);

      await CacheService.instance.remove('$_messagesKeyPrefix$chatId');
      await CacheService.instance.remove(_chatsKey);

      return true;
    } catch (e) {
      LoggingService.error('Error sending system message: $e', tag: 'MessagingService');
      return false;
    }
  }

  Future<bool> addReactionToMessage(String messageId, String emoji) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      final messageRef = _firestore.collection('messages').doc(messageId);
      final messageDoc = await messageRef.get();

      if (!messageDoc.exists) return false;

      final message = _messageFromFirestore(messageDoc);
      final updatedMessage = message.addReaction(currentUser.uid, emoji);

      await messageRef.update(updatedMessage.toJson());

      await CacheService.instance.remove('$_messagesKeyPrefix${message.chatId}');

      return true;
    } catch (e) {
      LoggingService.error('Error adding reaction: $e', tag: 'MessagingService');
      return false;
    }
  }

  Future<bool> markChatAsRead(String chatId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      final chatRef = _firestore.collection('chats').doc(chatId);
      final chatDoc = await chatRef.get();

      if (!chatDoc.exists) return false;

      final chat = _chatFromFirestore(chatDoc);
      final updatedChat = chat.markAsRead(currentUser.uid);

      await chatRef.update(updatedChat.toJson());
      await markMessagesAsRead(chatId);
      await CacheService.instance.remove(_chatsKey);

      return true;
    } catch (e) {
      LoggingService.error('Error marking chat as read: $e', tag: 'MessagingService');
      return false;
    }
  }

  Future<void> markMessagesAsRead(String chatId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      final snapshot = await _firestore
          .collection('messages')
          .where('chatId', isEqualTo: chatId)
          .where('senderId', isNotEqualTo: currentUser.uid)
          .get();

      if (snapshot.docs.isEmpty) return;

      final batch = _firestore.batch();
      int updateCount = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final readBy = List<String>.from(data['readBy'] ?? []);

        if (readBy.contains(currentUser.uid)) continue;

        readBy.add(currentUser.uid);
        batch.update(doc.reference, {
          'readBy': readBy,
          'status': 'read',
        });
        updateCount++;

        if (updateCount >= 400) {
          await batch.commit();
          updateCount = 0;
        }
      }

      if (updateCount > 0) {
        await batch.commit();
      }

      LoggingService.info(
        'Marked ${snapshot.docs.length} messages as read in chat $chatId',
        tag: 'MessagingService',
      );
    } catch (e) {
      LoggingService.error('Error marking messages as read: $e', tag: 'MessagingService');
    }
  }

  // ==================== Real-time Streams ====================

  Stream<List<Message>> getMessageStream(String chatId) {
    if (!_messageStreams.containsKey(chatId)) {
      final controller = StreamController<List<Message>>();
      _messageStreams[chatId] = controller;

      _firestore
          .collection('messages')
          .where('chatId', isEqualTo: chatId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('createdAt', descending: false)
          .snapshots()
          .listen((snapshot) {
        final messages = snapshot.docs.map(_messageFromFirestore).toList();
        controller.add(messages);
      });
    }

    return _messageStreams[chatId]!.stream;
  }

  // ==================== Typing Indicators ====================

  Stream<List<TypingIndicator>> getTypingIndicatorsStream(String chatId) {
    if (!_typingStreams.containsKey(chatId)) {
      _typingStreams[chatId] = StreamController<List<TypingIndicator>>.broadcast();
      _listenToTypingIndicators(chatId);
    }
    return _typingStreams[chatId]!.stream;
  }

  Future<void> setTypingIndicator(String chatId, bool isTyping) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      final indicator = TypingIndicator(
        chatId: chatId,
        userId: currentUser.uid,
        userName: currentUser.displayName ?? 'Anonymous',
        timestamp: DateTime.now(),
        isTyping: isTyping,
      );

      await _firestore
          .collection('typing_indicators')
          .doc('${chatId}_${currentUser.uid}')
          .set(indicator.toJson());

      _typingTimers['${chatId}_${currentUser.uid}']?.cancel();

      if (isTyping) {
        _typingTimers['${chatId}_${currentUser.uid}'] = Timer(
          const Duration(seconds: 3),
          () => setTypingIndicator(chatId, false),
        );
      }
    } catch (e) {
      LoggingService.error('Error setting typing indicator: $e', tag: 'MessagingService');
    }
  }

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

  void _listenToUserChats(String userId) {
    _firestore
        .collection('chats')
        .where('participantIds', arrayContains: userId)
        .where('isActive', isEqualTo: true)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .listen((snapshot) {
      final chats = snapshot.docs.map(_chatFromFirestore).toList();
      _chatsStreamController.add(chats);
    });
  }

  void _listenToTypingIndicators(String chatId) {
    _firestore
        .collection('typing_indicators')
        .where('chatId', isEqualTo: chatId)
        .where('isTyping', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
      final indicators = snapshot.docs
          .map((doc) => TypingIndicator.fromJson(doc.data()))
          .where((indicator) => !indicator.isExpired)
          .toList();

      if (_typingStreams.containsKey(chatId)) {
        _typingStreams[chatId]!.add(indicators);
      }
    });
  }

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

  Future<void> _updateChatLastMessage(String chatId, Message message) async {
    try {
      final chatRef = _firestore.collection('chats').doc(chatId);
      final chatDoc = await chatRef.get();

      if (chatDoc.exists) {
        final chat = _chatFromFirestore(chatDoc);
        final updatedChat = chat.updateLastMessage(message);

        await chatRef.update(updatedChat.toJson());
      }
    } catch (e) {
      LoggingService.error('Error updating chat last message: $e', tag: 'MessagingService');
    }
  }

  Future<void> _triggerMessageNotifications(String chatId, Message message) async {
    try {
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      if (!chatDoc.exists) return;

      final chat = _chatFromFirestore(chatDoc);

      final recipients = chat.participantIds
          .where((id) => id != message.senderId)
          .toList();

      if (recipients.isEmpty) return;

      await _firestore.collection('message_notifications').add({
        'chatId': chatId,
        'messageId': message.messageId,
        'senderId': message.senderId,
        'senderName': message.senderName,
        'senderImageUrl': message.senderImageUrl,
        'content': _truncateMessage(message.content, 100),
        'messageType': message.type.name,
        'recipientIds': recipients,
        'chatName': chat.name ?? message.senderName,
        'chatType': chat.type.name,
        'chatImageUrl': chat.imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'processed': false,
      });

      LoggingService.info(
        'Created notification for ${recipients.length} recipients',
        tag: 'MessagingService',
      );
    } catch (e) {
      LoggingService.error('Error triggering notifications: $e', tag: 'MessagingService');
    }
  }

  String _truncateMessage(String content, int maxLength) {
    if (content.length <= maxLength) return content;
    return '${content.substring(0, maxLength - 3)}...';
  }

  Chat _chatFromFirestore(DocumentSnapshot doc) {
    final data = Map<String, dynamic>.from(doc.data() as Map);
    return Chat.fromJson({...data, 'chatId': doc.id});
  }

  Message _messageFromFirestore(DocumentSnapshot doc) {
    final data = Map<String, dynamic>.from(doc.data() as Map);
    return Message.fromJson({...data, 'messageId': doc.id});
  }
}

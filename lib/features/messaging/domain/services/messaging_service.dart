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

  // Chat Management
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
      // Try cache first
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
      
      // Cache the results
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
      // Check if either user has blocked the other
      final socialService = SocialService();
      final isBlocked = await socialService.isUserBlocked(currentUser.uid, otherUserId);
      if (isBlocked) {
        LoggingService.warning('Cannot create chat - user is blocked', tag: 'MessagingService');
        return null;
      }

      // Check if chat already exists
      final existingChat = await _findDirectChat(currentUser.uid, otherUserId);
      if (existingChat != null) return existingChat;

      final chat = Chat.direct(
        currentUserId: currentUser.uid,
        participantUserId: otherUserId,
      );

      await _firestore.collection('chats').doc(chat.chatId).set(chat.toJson());

      // Clear cache
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
      
      // Send system message
      await sendSystemMessage(
        chatId: chat.chatId,
        content: '${currentUser.displayName ?? 'Someone'} created the group',
      );
      
      // Clear cache
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
      
      // Send system message
      await sendSystemMessage(
        chatId: chat.chatId,
        content: 'Welcome to the $teamName fans chat! 🏈',
      );
      
      // Clear cache
      await CacheService.instance.remove(_chatsKey);
      
      return chat;
    } catch (e) {
      LoggingService.error('Error creating team chat: $e', tag: 'MessagingService');
      return null;
    }
  }

  // Message Management
  Future<List<Message>> getChatMessages(String chatId, {int limit = 50}) async {
    try {
      // Try cache first
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
      
      // Cache the results
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
      // Check moderation status and filter content
      final moderationService = ModerationService();
      final validationResult = await moderationService.validateMessage(content);

      if (!validationResult.isValid) {
        LoggingService.warning(
          'Message blocked by moderation: ${validationResult.errorMessage}',
          tag: 'MessagingService',
        );
        return false;
      }

      // Use filtered content if profanity was detected
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

      // Send message to Firestore
      await _firestore.collection('messages').doc(message.messageId).set(message.toJson());

      // Update chat with last message
      await _updateChatLastMessage(chatId, message);

      // Trigger push notifications for other participants
      await _triggerMessageNotifications(chatId, message);

      // Clear caches
      await CacheService.instance.remove('$_messagesKeyPrefix$chatId');
      await CacheService.instance.remove(_chatsKey);

      return true;
    } catch (e) {
      LoggingService.error('Error sending message: $e', tag: 'MessagingService');
      return false;
    }
  }

  /// Trigger push notifications for message recipients
  Future<void> _triggerMessageNotifications(String chatId, Message message) async {
    try {
      // Get chat to find participants
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      if (!chatDoc.exists) return;

      final chat = _chatFromFirestore(chatDoc);

      // Get recipients (all participants except sender)
      final recipients = chat.participantIds
          .where((id) => id != message.senderId)
          .toList();

      if (recipients.isEmpty) return;

      // Create notification document for Cloud Function to process
      // The Cloud Function will read FCM tokens and send notifications
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
      // Don't fail the message send if notification fails
      LoggingService.error('Error triggering notifications: $e', tag: 'MessagingService');
    }
  }

  /// Truncate message content for notification preview
  String _truncateMessage(String content, int maxLength) {
    if (content.length <= maxLength) return content;
    return '${content.substring(0, maxLength - 3)}...';
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
      
      // Clear caches
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
      
      // Clear cache
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

      // Also mark individual messages as read
      await markMessagesAsRead(chatId);

      // Clear cache
      await CacheService.instance.remove(_chatsKey);

      return true;
    } catch (e) {
      LoggingService.error('Error marking chat as read: $e', tag: 'MessagingService');
      return false;
    }
  }

  /// Mark all unread messages in a chat as read by the current user
  Future<void> markMessagesAsRead(String chatId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      // Get messages not yet read by current user
      final snapshot = await _firestore
          .collection('messages')
          .where('chatId', isEqualTo: chatId)
          .where('senderId', isNotEqualTo: currentUser.uid) // Don't mark own messages
          .get();

      if (snapshot.docs.isEmpty) return;

      // Use batched writes for efficiency
      final batch = _firestore.batch();
      int updateCount = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final readBy = List<String>.from(data['readBy'] ?? []);

        // Skip if already read by this user
        if (readBy.contains(currentUser.uid)) continue;

        readBy.add(currentUser.uid);
        batch.update(doc.reference, {
          'readBy': readBy,
          'status': 'read',
        });
        updateCount++;

        // Firestore batches have a limit of 500 operations
        if (updateCount >= 400) {
          await batch.commit();
          updateCount = 0;
        }
      }

      // Commit any remaining updates
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

  // Real-time streams
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

  // Helper methods for Firestore conversion
  Chat _chatFromFirestore(DocumentSnapshot doc) {
    final data = Map<String, dynamic>.from(doc.data() as Map);
    return Chat.fromJson({...data, 'chatId': doc.id});
  }

  Message _messageFromFirestore(DocumentSnapshot doc) {
    final data = Map<String, dynamic>.from(doc.data() as Map);
    return Message.fromJson({...data, 'messageId': doc.id});
  }

  // Typing indicator methods
  Stream<List<TypingIndicator>> getTypingIndicatorsStream(String chatId) {
    if (!_typingStreams.containsKey(chatId)) {
      _typingStreams[chatId] = StreamController<List<TypingIndicator>>.broadcast();
      _listenToTypingIndicators(chatId);
    }
    return _typingStreams[chatId]!.stream;
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

      // Cancel existing timer
      _typingTimers['${chatId}_${currentUser.uid}']?.cancel();

      if (isTyping) {
        // Auto-remove typing indicator after 3 seconds
        _typingTimers['${chatId}_${currentUser.uid}'] = Timer(
          const Duration(seconds: 3),
          () => setTypingIndicator(chatId, false),
        );
      }
    } catch (e) {
      LoggingService.error('Error setting typing indicator: $e', tag: 'MessagingService');
    }
  }

  // Create a new chat
  Future<bool> createChat(Chat chat) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chat.chatId)
          .set(chat.toJson());
      
      // Cache the new chat
      await CacheService.instance.set('chat_${chat.chatId}', chat.toJson(), duration: const Duration(minutes: 10));
      
      return true;
    } catch (e) {
      LoggingService.error('Error creating chat: $e', tag: 'MessagingService');
      return false;
    }
  }

  // Get messages for a chat (alias for getChatMessages)
  Future<List<Message>> getMessages(String chatId) async {
    return await getChatMessages(chatId);
  }

  // Group Chat Member Management

  /// Add a member to a group chat
  Future<bool> addMemberToChat(String chatId, String userId, String userName) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      if (!chatDoc.exists) return false;

      final chat = _chatFromFirestore(chatDoc);

      // Only admins can add members
      if (!chat.isAdmin(currentUser.uid)) {
        LoggingService.warning('User is not an admin, cannot add members', tag: 'MessagingService');
        return false;
      }

      // Check if user is already a participant
      if (chat.isParticipant(userId)) {
        LoggingService.warning('User is already a participant', tag: 'MessagingService');
        return false;
      }

      // Update the chat with new participant
      final updatedParticipants = List<String>.from(chat.participantIds)..add(userId);
      final updatedUnreadCounts = Map<String, int>.from(chat.unreadCounts);
      updatedUnreadCounts[userId] = 0;

      await _firestore.collection('chats').doc(chatId).update({
        'participantIds': updatedParticipants,
        'unreadCounts': updatedUnreadCounts,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Send system message
      await sendSystemMessage(
        chatId: chatId,
        content: '${currentUser.displayName ?? 'Someone'} added $userName to the group',
      );

      // Clear cache
      await CacheService.instance.remove(_chatsKey);

      LoggingService.info('Added member $userId to chat $chatId', tag: 'MessagingService');
      return true;
    } catch (e) {
      LoggingService.error('Error adding member to chat: $e', tag: 'MessagingService');
      return false;
    }
  }

  /// Remove a member from a group chat
  Future<bool> removeMemberFromChat(String chatId, String userId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      if (!chatDoc.exists) return false;

      final chat = _chatFromFirestore(chatDoc);

      // Only admins can remove members (and cannot remove themselves this way)
      if (!chat.isAdmin(currentUser.uid)) {
        LoggingService.warning('User is not an admin, cannot remove members', tag: 'MessagingService');
        return false;
      }

      // Cannot remove the chat creator
      if (chat.createdBy == userId) {
        LoggingService.warning('Cannot remove the chat creator', tag: 'MessagingService');
        return false;
      }

      // Get the user's name for the system message
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userName = userDoc.exists ? (userDoc.data()?['displayName'] ?? 'A member') : 'A member';

      // Update the chat
      final updatedParticipants = List<String>.from(chat.participantIds)..remove(userId);
      final updatedAdmins = List<String>.from(chat.adminIds)..remove(userId);
      final updatedUnreadCounts = Map<String, int>.from(chat.unreadCounts);
      updatedUnreadCounts.remove(userId);

      await _firestore.collection('chats').doc(chatId).update({
        'participantIds': updatedParticipants,
        'adminIds': updatedAdmins,
        'unreadCounts': updatedUnreadCounts,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Send system message
      await sendSystemMessage(
        chatId: chatId,
        content: '${currentUser.displayName ?? 'Someone'} removed $userName from the group',
      );

      // Clear cache
      await CacheService.instance.remove(_chatsKey);

      LoggingService.info('Removed member $userId from chat $chatId', tag: 'MessagingService');
      return true;
    } catch (e) {
      LoggingService.error('Error removing member from chat: $e', tag: 'MessagingService');
      return false;
    }
  }

  /// Leave a group chat
  Future<bool> leaveChat(String chatId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      if (!chatDoc.exists) return false;

      final chat = _chatFromFirestore(chatDoc);

      // Cannot leave direct chats
      if (chat.type == ChatType.direct) {
        LoggingService.warning('Cannot leave direct chats', tag: 'MessagingService');
        return false;
      }

      // Cannot leave if you're the only admin
      if (chat.isAdmin(currentUser.uid) && chat.adminIds.length == 1 && chat.participantIds.length > 1) {
        LoggingService.warning('Cannot leave - you are the only admin. Promote another admin first.', tag: 'MessagingService');
        return false;
      }

      // Update the chat
      final updatedParticipants = List<String>.from(chat.participantIds)..remove(currentUser.uid);
      final updatedAdmins = List<String>.from(chat.adminIds)..remove(currentUser.uid);
      final updatedUnreadCounts = Map<String, int>.from(chat.unreadCounts);
      updatedUnreadCounts.remove(currentUser.uid);

      // If no participants left, deactivate the chat
      if (updatedParticipants.isEmpty) {
        await _firestore.collection('chats').doc(chatId).update({
          'isActive': false,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      } else {
        await _firestore.collection('chats').doc(chatId).update({
          'participantIds': updatedParticipants,
          'adminIds': updatedAdmins,
          'unreadCounts': updatedUnreadCounts,
          'updatedAt': DateTime.now().toIso8601String(),
        });

        // Send system message
        await sendSystemMessage(
          chatId: chatId,
          content: '${currentUser.displayName ?? 'Someone'} left the group',
        );
      }

      // Clear cache
      await CacheService.instance.remove(_chatsKey);

      LoggingService.info('User left chat $chatId', tag: 'MessagingService');
      return true;
    } catch (e) {
      LoggingService.error('Error leaving chat: $e', tag: 'MessagingService');
      return false;
    }
  }

  /// Promote a member to admin
  Future<bool> promoteToAdmin(String chatId, String userId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      if (!chatDoc.exists) return false;

      final chat = _chatFromFirestore(chatDoc);

      // Only admins can promote
      if (!chat.isAdmin(currentUser.uid)) {
        LoggingService.warning('User is not an admin, cannot promote members', tag: 'MessagingService');
        return false;
      }

      // User must be a participant
      if (!chat.isParticipant(userId)) {
        LoggingService.warning('User is not a participant', tag: 'MessagingService');
        return false;
      }

      // Already an admin
      if (chat.isAdmin(userId)) {
        LoggingService.warning('User is already an admin', tag: 'MessagingService');
        return false;
      }

      // Get user name for system message
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userName = userDoc.exists ? (userDoc.data()?['displayName'] ?? 'A member') : 'A member';

      // Update the chat
      final updatedAdmins = List<String>.from(chat.adminIds)..add(userId);

      await _firestore.collection('chats').doc(chatId).update({
        'adminIds': updatedAdmins,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Send system message
      await sendSystemMessage(
        chatId: chatId,
        content: '${currentUser.displayName ?? 'Someone'} made $userName an admin',
      );

      // Clear cache
      await CacheService.instance.remove(_chatsKey);

      LoggingService.info('Promoted $userId to admin in chat $chatId', tag: 'MessagingService');
      return true;
    } catch (e) {
      LoggingService.error('Error promoting to admin: $e', tag: 'MessagingService');
      return false;
    }
  }

  /// Demote an admin to regular member
  Future<bool> demoteFromAdmin(String chatId, String userId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      if (!chatDoc.exists) return false;

      final chat = _chatFromFirestore(chatDoc);

      // Only the chat creator can demote admins
      if (chat.createdBy != currentUser.uid) {
        LoggingService.warning('Only the chat creator can demote admins', tag: 'MessagingService');
        return false;
      }

      // Cannot demote the creator
      if (userId == chat.createdBy) {
        LoggingService.warning('Cannot demote the chat creator', tag: 'MessagingService');
        return false;
      }

      // User must be an admin
      if (!chat.isAdmin(userId)) {
        LoggingService.warning('User is not an admin', tag: 'MessagingService');
        return false;
      }

      // Get user name for system message
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userName = userDoc.exists ? (userDoc.data()?['displayName'] ?? 'A member') : 'A member';

      // Update the chat
      final updatedAdmins = List<String>.from(chat.adminIds)..remove(userId);

      await _firestore.collection('chats').doc(chatId).update({
        'adminIds': updatedAdmins,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Send system message
      await sendSystemMessage(
        chatId: chatId,
        content: '${currentUser.displayName ?? 'Someone'} removed $userName as admin',
      );

      // Clear cache
      await CacheService.instance.remove(_chatsKey);

      LoggingService.info('Demoted $userId from admin in chat $chatId', tag: 'MessagingService');
      return true;
    } catch (e) {
      LoggingService.error('Error demoting from admin: $e', tag: 'MessagingService');
      return false;
    }
  }

  /// Get member profiles for a chat
  Future<List<ChatMemberInfo>> getChatMembers(String chatId) async {
    try {
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      if (!chatDoc.exists) return [];

      final chat = _chatFromFirestore(chatDoc);
      final members = <ChatMemberInfo>[];

      for (final participantId in chat.participantIds) {
        final userDoc = await _firestore.collection('users').doc(participantId).get();
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          members.add(ChatMemberInfo(
            userId: participantId,
            displayName: userData['displayName'] ?? 'Unknown',
            imageUrl: userData['profileImageUrl'],
            isAdmin: chat.isAdmin(participantId),
            isCreator: chat.createdBy == participantId,
          ));
        }
      }

      // Sort: creator first, then admins, then regular members
      members.sort((a, b) {
        if (a.isCreator) return -1;
        if (b.isCreator) return 1;
        if (a.isAdmin && !b.isAdmin) return -1;
        if (!a.isAdmin && b.isAdmin) return 1;
        return a.displayName.compareTo(b.displayName);
      });

      return members;
    } catch (e) {
      LoggingService.error('Error getting chat members: $e', tag: 'MessagingService');
      return [];
    }
  }

  // Chat Settings Management

  /// Mute a chat for the current user
  Future<bool> muteChat(String chatId, {Duration? duration}) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      final muteUntil = duration != null
          ? DateTime.now().add(duration).toIso8601String()
          : 'forever';

      await _firestore
          .collection('user_chat_settings')
          .doc('${currentUser.uid}_$chatId')
          .set({
        'userId': currentUser.uid,
        'chatId': chatId,
        'isMuted': true,
        'muteUntil': muteUntil,
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));

      LoggingService.info('Muted chat $chatId', tag: 'MessagingService');
      return true;
    } catch (e) {
      LoggingService.error('Error muting chat: $e', tag: 'MessagingService');
      return false;
    }
  }

  /// Unmute a chat for the current user
  Future<bool> unmuteChat(String chatId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      await _firestore
          .collection('user_chat_settings')
          .doc('${currentUser.uid}_$chatId')
          .set({
        'userId': currentUser.uid,
        'chatId': chatId,
        'isMuted': false,
        'muteUntil': null,
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));

      LoggingService.info('Unmuted chat $chatId', tag: 'MessagingService');
      return true;
    } catch (e) {
      LoggingService.error('Error unmuting chat: $e', tag: 'MessagingService');
      return false;
    }
  }

  /// Check if a chat is muted for the current user
  Future<bool> isChatMuted(String chatId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      final doc = await _firestore
          .collection('user_chat_settings')
          .doc('${currentUser.uid}_$chatId')
          .get();

      if (!doc.exists) return false;

      final data = doc.data()!;
      final isMuted = data['isMuted'] as bool? ?? false;

      if (!isMuted) return false;

      // Check if mute has expired
      final muteUntil = data['muteUntil'] as String?;
      if (muteUntil != null && muteUntil != 'forever') {
        final muteExpiry = DateTime.parse(muteUntil);
        if (DateTime.now().isAfter(muteExpiry)) {
          // Mute has expired, unmute automatically
          await unmuteChat(chatId);
          return false;
        }
      }

      return true;
    } catch (e) {
      LoggingService.error('Error checking mute status: $e', tag: 'MessagingService');
      return false;
    }
  }

  /// Archive a chat for the current user
  Future<bool> archiveChat(String chatId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      await _firestore
          .collection('user_chat_settings')
          .doc('${currentUser.uid}_$chatId')
          .set({
        'userId': currentUser.uid,
        'chatId': chatId,
        'isArchived': true,
        'archivedAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));

      // Clear cache
      await CacheService.instance.remove(_chatsKey);

      LoggingService.info('Archived chat $chatId', tag: 'MessagingService');
      return true;
    } catch (e) {
      LoggingService.error('Error archiving chat: $e', tag: 'MessagingService');
      return false;
    }
  }

  /// Unarchive a chat for the current user
  Future<bool> unarchiveChat(String chatId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      await _firestore
          .collection('user_chat_settings')
          .doc('${currentUser.uid}_$chatId')
          .set({
        'userId': currentUser.uid,
        'chatId': chatId,
        'isArchived': false,
        'archivedAt': null,
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));

      // Clear cache
      await CacheService.instance.remove(_chatsKey);

      LoggingService.info('Unarchived chat $chatId', tag: 'MessagingService');
      return true;
    } catch (e) {
      LoggingService.error('Error unarchiving chat: $e', tag: 'MessagingService');
      return false;
    }
  }

  /// Check if a chat is archived for the current user
  Future<bool> isChatArchived(String chatId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      final doc = await _firestore
          .collection('user_chat_settings')
          .doc('${currentUser.uid}_$chatId')
          .get();

      if (!doc.exists) return false;
      return doc.data()?['isArchived'] as bool? ?? false;
    } catch (e) {
      LoggingService.error('Error checking archive status: $e', tag: 'MessagingService');
      return false;
    }
  }

  /// Get chat settings for the current user
  Future<ChatSettings> getChatSettings(String chatId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return const ChatSettings(isMuted: false, isArchived: false);
    }

    try {
      final doc = await _firestore
          .collection('user_chat_settings')
          .doc('${currentUser.uid}_$chatId')
          .get();

      if (!doc.exists) {
        return const ChatSettings(isMuted: false, isArchived: false);
      }

      final data = doc.data()!;
      return ChatSettings(
        isMuted: data['isMuted'] as bool? ?? false,
        isArchived: data['isArchived'] as bool? ?? false,
        muteUntil: data['muteUntil'] as String?,
      );
    } catch (e) {
      LoggingService.error('Error getting chat settings: $e', tag: 'MessagingService');
      return const ChatSettings(isMuted: false, isArchived: false);
    }
  }

  /// Delete a chat for the current user (hides it from their list)
  Future<bool> deleteChat(String chatId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      await _firestore
          .collection('user_chat_settings')
          .doc('${currentUser.uid}_$chatId')
          .set({
        'userId': currentUser.uid,
        'chatId': chatId,
        'isDeleted': true,
        'deletedAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));

      // Clear cache
      await CacheService.instance.remove(_chatsKey);

      LoggingService.info('Deleted chat $chatId for user', tag: 'MessagingService');
      return true;
    } catch (e) {
      LoggingService.error('Error deleting chat: $e', tag: 'MessagingService');
      return false;
    }
  }

  /// Clear chat history for the current user
  Future<bool> clearChatHistory(String chatId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      // Store the timestamp from which to show messages (only show newer messages)
      await _firestore
          .collection('user_chat_settings')
          .doc('${currentUser.uid}_$chatId')
          .set({
        'userId': currentUser.uid,
        'chatId': chatId,
        'clearedAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));

      // Clear message cache for this chat
      await CacheService.instance.remove('$_messagesKeyPrefix$chatId');

      LoggingService.info('Cleared chat history for $chatId', tag: 'MessagingService');
      return true;
    } catch (e) {
      LoggingService.error('Error clearing chat history: $e', tag: 'MessagingService');
      return false;
    }
  }

  /// Get the timestamp from which to show messages (for cleared history)
  Future<DateTime?> getChatClearedAt(String chatId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return null;

    try {
      final doc = await _firestore
          .collection('user_chat_settings')
          .doc('${currentUser.uid}_$chatId')
          .get();

      if (!doc.exists) return null;

      final clearedAt = doc.data()?['clearedAt'] as String?;
      return clearedAt != null ? DateTime.parse(clearedAt) : null;
    } catch (e) {
      LoggingService.error('Error getting cleared at: $e', tag: 'MessagingService');
      return null;
    }
  }

  /// Check if a direct chat is blocked (either user blocked the other)
  /// Returns a BlockStatus with details about who blocked whom
  Future<BlockStatus> getChatBlockStatus(Chat chat) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return BlockStatus(isBlocked: false);
    }

    // Only check blocks for direct chats
    if (chat.type != ChatType.direct) {
      return BlockStatus(isBlocked: false);
    }

    try {
      final otherUserId = chat.participantIds.firstWhere(
        (id) => id != currentUser.uid,
        orElse: () => '',
      );

      if (otherUserId.isEmpty) {
        return BlockStatus(isBlocked: false);
      }

      final socialService = SocialService();

      // Check if current user blocked the other user
      final hasBlocked = await socialService.hasBlockedUser(otherUserId);
      if (hasBlocked) {
        return BlockStatus(
          isBlocked: true,
          blockedByCurrentUser: true,
          message: 'You blocked this user',
        );
      }

      // Check if other user blocked current user
      final isBlockedBy = await socialService.isBlockedByUser(otherUserId);
      if (isBlockedBy) {
        return BlockStatus(
          isBlocked: true,
          blockedByCurrentUser: false,
          message: 'You cannot message this user',
        );
      }

      return BlockStatus(isBlocked: false);
    } catch (e) {
      LoggingService.error('Error checking chat block status: $e', tag: 'MessagingService');
      return BlockStatus(isBlocked: false);
    }
  }
}

/// Block status for a chat
class BlockStatus {
  final bool isBlocked;
  final bool blockedByCurrentUser;
  final String? message;

  const BlockStatus({
    required this.isBlocked,
    this.blockedByCurrentUser = false,
    this.message,
  });
}

/// Member info for group chats
class ChatMemberInfo {
  final String userId;
  final String displayName;
  final String? imageUrl;
  final bool isAdmin;
  final bool isCreator;

  const ChatMemberInfo({
    required this.userId,
    required this.displayName,
    this.imageUrl,
    this.isAdmin = false,
    this.isCreator = false,
  });
}

/// Chat settings for a user
class ChatSettings {
  final bool isMuted;
  final bool isArchived;
  final String? muteUntil;

  const ChatSettings({
    required this.isMuted,
    required this.isArchived,
    this.muteUntil,
  });

  bool get isMutedForever => muteUntil == 'forever';

  Duration? get muteDuration {
    if (muteUntil == null || muteUntil == 'forever') return null;
    final muteExpiry = DateTime.parse(muteUntil!);
    final remaining = muteExpiry.difference(DateTime.now());
    return remaining.isNegative ? null : remaining;
  }
}

// Extension methods for JSON conversion
extension ChatJson on Chat {
  Map<String, dynamic> toJson() {
    return {
      'chatId': chatId,
      'type': type.name,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'participantIds': participantIds,
      'adminIds': adminIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'lastMessageId': lastMessageId,
      'lastMessageContent': lastMessageContent,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
      'lastMessageSenderId': lastMessageSenderId,
      'unreadCounts': unreadCounts,
      'settings': settings,
      'isActive': isActive,
      'createdBy': createdBy,
    };
  }

  static Chat fromJson(Map<String, dynamic> json) {
    return Chat(
      chatId: json['chatId'],
      type: ChatType.values.firstWhere((e) => e.name == json['type']),
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      participantIds: List<String>.from(json['participantIds'] ?? []),
      adminIds: List<String>.from(json['adminIds'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      lastMessageId: json['lastMessageId'],
      lastMessageContent: json['lastMessageContent'],
      lastMessageTime: json['lastMessageTime'] != null ? DateTime.parse(json['lastMessageTime']) : null,
      lastMessageSenderId: json['lastMessageSenderId'],
      unreadCounts: Map<String, int>.from(json['unreadCounts'] ?? {}),
      settings: Map<String, dynamic>.from(json['settings'] ?? {}),
      isActive: json['isActive'] ?? true,
      createdBy: json['createdBy'],
    );
  }
}

extension MessageJson on Message {
  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'senderImageUrl': senderImageUrl,
      'content': content,
      'type': type.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'status': status.name,
      'replyToMessageId': replyToMessageId,
      'reactions': reactions.map((r) => r.toJson()).toList(),
      'metadata': metadata,
      'isDeleted': isDeleted,
      'readBy': readBy,
    };
  }

  static Message fromJson(Map<String, dynamic> json) {
    return Message(
      messageId: json['messageId'],
      chatId: json['chatId'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      senderImageUrl: json['senderImageUrl'],
      content: json['content'],
      type: MessageType.values.firstWhere((e) => e.name == json['type']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      status: MessageStatus.values.firstWhere((e) => e.name == json['status']),
      replyToMessageId: json['replyToMessageId'],
      reactions: (json['reactions'] as List? ?? [])
          .map((r) => MessageReaction.fromJson(r))
          .toList(),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      isDeleted: json['isDeleted'] ?? false,
      readBy: List<String>.from(json['readBy'] ?? []),
    );
  }
}

extension MessageReactionJson on MessageReaction {
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'emoji': emoji,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static MessageReaction fromJson(Map<String, dynamic> json) {
    return MessageReaction(
      userId: json['userId'],
      emoji: json['emoji'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
} 
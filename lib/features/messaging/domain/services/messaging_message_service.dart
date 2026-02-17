import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../entities/message.dart';
import '../entities/chat.dart';
import '../../../../core/services/cache_service.dart';
import '../../../../core/services/logging_service.dart';
import '../../../social/domain/services/social_service.dart';
import '../../../moderation/moderation.dart';

/// Handles message CRUD operations: send, retrieve, reactions, read status.
class MessagingMessageService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final String messagesKeyPrefix;
  final String chatsKey;

  /// Callback to convert a Firestore doc to Chat.
  final Chat Function(DocumentSnapshot doc) chatFromFirestore;

  MessagingMessageService({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required this.messagesKeyPrefix,
    required this.chatsKey,
    required this.chatFromFirestore,
  })  : _firestore = firestore,
        _auth = auth;

  /// Get messages for a chat
  Future<List<Message>> getChatMessages(String chatId, {int limit = 50}) async {
    try {
      final cacheKey = '$messagesKeyPrefix$chatId';
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
        duration: const Duration(minutes: 5),
      );

      return messages;
    } catch (e) {
      LoggingService.error('Error getting chat messages: $e', tag: 'MessagingService');
      return [];
    }
  }

  /// Send a message in a chat
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

      await CacheService.instance.remove('$messagesKeyPrefix$chatId');
      await CacheService.instance.remove(chatsKey);

      return true;
    } catch (e) {
      LoggingService.error('Error sending message: $e', tag: 'MessagingService');
      return false;
    }
  }

  /// Send a system message
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

      await CacheService.instance.remove('$messagesKeyPrefix$chatId');
      await CacheService.instance.remove(chatsKey);

      return true;
    } catch (e) {
      LoggingService.error('Error sending system message: $e', tag: 'MessagingService');
      return false;
    }
  }

  /// Add a reaction to a message
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

      await CacheService.instance.remove('$messagesKeyPrefix${message.chatId}');

      return true;
    } catch (e) {
      LoggingService.error('Error adding reaction: $e', tag: 'MessagingService');
      return false;
    }
  }

  /// Mark a chat as read for the current user
  Future<bool> markChatAsRead(String chatId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      final chatRef = _firestore.collection('chats').doc(chatId);
      final chatDoc = await chatRef.get();

      if (!chatDoc.exists) return false;

      final chat = chatFromFirestore(chatDoc);
      final updatedChat = chat.markAsRead(currentUser.uid);

      await chatRef.update(updatedChat.toJson());
      await markMessagesAsRead(chatId);
      await CacheService.instance.remove(chatsKey);

      return true;
    } catch (e) {
      LoggingService.error('Error marking chat as read: $e', tag: 'MessagingService');
      return false;
    }
  }

  /// Mark all messages in a chat as read for the current user
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

  // ==================== Private Helpers ====================

  Future<void> _updateChatLastMessage(String chatId, Message message) async {
    try {
      final chatRef = _firestore.collection('chats').doc(chatId);
      final chatDoc = await chatRef.get();

      if (chatDoc.exists) {
        final chat = chatFromFirestore(chatDoc);
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

      final chat = chatFromFirestore(chatDoc);

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

  Message _messageFromFirestore(DocumentSnapshot doc) {
    final data = Map<String, dynamic>.from(doc.data() as Map);
    return Message.fromJson({...data, 'messageId': doc.id});
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../entities/chat.dart';
import '../../../../core/services/cache_service.dart';
import '../../../../core/services/logging_service.dart';
import 'messaging_chat_settings_service.dart';

/// Handles group chat member management: add, remove, leave, promote, demote.
class MessagingGroupManagementService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  /// Callback to send system messages through the main service.
  final Future<bool> Function({required String chatId, required String content, Map<String, dynamic>? metadata}) sendSystemMessage;

  /// Callback to convert a Firestore doc to Chat.
  final Chat Function(DocumentSnapshot doc) chatFromFirestore;

  /// Cache key for user chats list.
  final String chatsKey;

  MessagingGroupManagementService({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required this.sendSystemMessage,
    required this.chatFromFirestore,
    required this.chatsKey,
  })  : _firestore = firestore,
        _auth = auth;

  /// Add a member to a group chat
  Future<bool> addMemberToChat(String chatId, String userId, String userName) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      if (!chatDoc.exists) return false;

      final chat = chatFromFirestore(chatDoc);

      if (!chat.isAdmin(currentUser.uid)) {
        LoggingService.warning('User is not an admin, cannot add members', tag: 'MessagingService');
        return false;
      }

      if (chat.isParticipant(userId)) {
        LoggingService.warning('User is already a participant', tag: 'MessagingService');
        return false;
      }

      final updatedParticipants = List<String>.from(chat.participantIds)..add(userId);
      final updatedUnreadCounts = Map<String, int>.from(chat.unreadCounts);
      updatedUnreadCounts[userId] = 0;

      await _firestore.collection('chats').doc(chatId).update({
        'participantIds': updatedParticipants,
        'unreadCounts': updatedUnreadCounts,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      await sendSystemMessage(
        chatId: chatId,
        content: '${currentUser.displayName ?? 'Someone'} added $userName to the group',
      );

      await CacheService.instance.remove(chatsKey);

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

      final chat = chatFromFirestore(chatDoc);

      if (!chat.isAdmin(currentUser.uid)) {
        LoggingService.warning('User is not an admin, cannot remove members', tag: 'MessagingService');
        return false;
      }

      if (chat.createdBy == userId) {
        LoggingService.warning('Cannot remove the chat creator', tag: 'MessagingService');
        return false;
      }

      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userName = userDoc.exists ? (userDoc.data()?['displayName'] ?? 'A member') : 'A member';

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

      await sendSystemMessage(
        chatId: chatId,
        content: '${currentUser.displayName ?? 'Someone'} removed $userName from the group',
      );

      await CacheService.instance.remove(chatsKey);

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

      final chat = chatFromFirestore(chatDoc);

      if (chat.type == ChatType.direct) {
        LoggingService.warning('Cannot leave direct chats', tag: 'MessagingService');
        return false;
      }

      if (chat.isAdmin(currentUser.uid) && chat.adminIds.length == 1 && chat.participantIds.length > 1) {
        LoggingService.warning('Cannot leave - you are the only admin. Promote another admin first.', tag: 'MessagingService');
        return false;
      }

      final updatedParticipants = List<String>.from(chat.participantIds)..remove(currentUser.uid);
      final updatedAdmins = List<String>.from(chat.adminIds)..remove(currentUser.uid);
      final updatedUnreadCounts = Map<String, int>.from(chat.unreadCounts);
      updatedUnreadCounts.remove(currentUser.uid);

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

        await sendSystemMessage(
          chatId: chatId,
          content: '${currentUser.displayName ?? 'Someone'} left the group',
        );
      }

      await CacheService.instance.remove(chatsKey);

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

      final chat = chatFromFirestore(chatDoc);

      if (!chat.isAdmin(currentUser.uid)) {
        LoggingService.warning('User is not an admin, cannot promote members', tag: 'MessagingService');
        return false;
      }

      if (!chat.isParticipant(userId)) {
        LoggingService.warning('User is not a participant', tag: 'MessagingService');
        return false;
      }

      if (chat.isAdmin(userId)) {
        LoggingService.warning('User is already an admin', tag: 'MessagingService');
        return false;
      }

      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userName = userDoc.exists ? (userDoc.data()?['displayName'] ?? 'A member') : 'A member';

      final updatedAdmins = List<String>.from(chat.adminIds)..add(userId);

      await _firestore.collection('chats').doc(chatId).update({
        'adminIds': updatedAdmins,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      await sendSystemMessage(
        chatId: chatId,
        content: '${currentUser.displayName ?? 'Someone'} made $userName an admin',
      );

      await CacheService.instance.remove(chatsKey);

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

      final chat = chatFromFirestore(chatDoc);

      if (chat.createdBy != currentUser.uid) {
        LoggingService.warning('Only the chat creator can demote admins', tag: 'MessagingService');
        return false;
      }

      if (userId == chat.createdBy) {
        LoggingService.warning('Cannot demote the chat creator', tag: 'MessagingService');
        return false;
      }

      if (!chat.isAdmin(userId)) {
        LoggingService.warning('User is not an admin', tag: 'MessagingService');
        return false;
      }

      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userName = userDoc.exists ? (userDoc.data()?['displayName'] ?? 'A member') : 'A member';

      final updatedAdmins = List<String>.from(chat.adminIds)..remove(userId);

      await _firestore.collection('chats').doc(chatId).update({
        'adminIds': updatedAdmins,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      await sendSystemMessage(
        chatId: chatId,
        content: '${currentUser.displayName ?? 'Someone'} removed $userName as admin',
      );

      await CacheService.instance.remove(chatsKey);

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

      final chat = chatFromFirestore(chatDoc);
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
}

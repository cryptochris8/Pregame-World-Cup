import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../entities/chat.dart';
import '../../../../core/services/cache_service.dart';
import '../../../../core/services/logging_service.dart';
import '../../../social/domain/services/social_service.dart';

/// Handles per-user chat settings: mute, archive, delete, clear history, block status.
class MessagingChatSettingsService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final String chatsKey;

  MessagingChatSettingsService({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required this.chatsKey,
  })  : _firestore = firestore,
        _auth = auth;

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

      await CacheService.instance.remove(chatsKey);

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

      await CacheService.instance.remove(chatsKey);

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

      await CacheService.instance.remove(chatsKey);

      LoggingService.info('Deleted chat $chatId for user', tag: 'MessagingService');
      return true;
    } catch (e) {
      LoggingService.error('Error deleting chat: $e', tag: 'MessagingService');
      return false;
    }
  }

  /// Clear chat history for the current user
  Future<bool> clearChatHistory(String chatId, String messagesKeyPrefix) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      await _firestore
          .collection('user_chat_settings')
          .doc('${currentUser.uid}_$chatId')
          .set({
        'userId': currentUser.uid,
        'chatId': chatId,
        'clearedAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));

      await CacheService.instance.remove('$messagesKeyPrefix$chatId');

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
  Future<BlockStatus> getChatBlockStatus(Chat chat) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return const BlockStatus(isBlocked: false);
    }

    if (chat.type != ChatType.direct) {
      return const BlockStatus(isBlocked: false);
    }

    try {
      final otherUserId = chat.participantIds.firstWhere(
        (id) => id != currentUser.uid,
        orElse: () => '',
      );

      if (otherUserId.isEmpty) {
        return const BlockStatus(isBlocked: false);
      }

      final socialService = SocialService();

      final hasBlocked = await socialService.hasBlockedUser(otherUserId);
      if (hasBlocked) {
        return const BlockStatus(
          isBlocked: true,
          blockedByCurrentUser: true,
          message: 'You blocked this user',
        );
      }

      final isBlockedBy = await socialService.isBlockedByUser(otherUserId);
      if (isBlockedBy) {
        return const BlockStatus(
          isBlocked: true,
          blockedByCurrentUser: false,
          message: 'You cannot message this user',
        );
      }

      return const BlockStatus(isBlocked: false);
    } catch (e) {
      LoggingService.error('Error checking chat block status: $e', tag: 'MessagingService');
      return const BlockStatus(isBlocked: false);
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

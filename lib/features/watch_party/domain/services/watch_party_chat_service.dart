import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../entities/watch_party.dart';
import '../entities/watch_party_member.dart';
import '../entities/watch_party_message.dart';
import '../../../../core/services/logging_service.dart';

/// Handles real-time chat messaging within watch parties.
///
/// Responsibilities:
/// - Streaming messages for real-time updates
/// - Sending text and system messages
/// - Deleting messages (sender or host only)
class WatchPartyChatService {
  static const String _logTag = 'WatchPartyChatService';

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  /// Stream subscriptions for real-time updates
  final Map<String, StreamSubscription> _messageSubscriptions = {};

  WatchPartyChatService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

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
    String content,
    WatchPartyMember member, {
    String? replyToMessageId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

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
  Future<bool> deleteMessage(
    String watchPartyId,
    String messageId,
    WatchParty? party,
  ) async {
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

  /// Dispose of resources
  Future<void> dispose() async {
    for (final subscription in _messageSubscriptions.values) {
      await subscription.cancel();
    }
    _messageSubscriptions.clear();
  }
}

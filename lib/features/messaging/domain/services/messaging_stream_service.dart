import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../entities/message.dart';
import '../entities/chat.dart';
import '../entities/typing_indicator.dart';
import '../../../../core/services/logging_service.dart';

/// Handles real-time streams for messages, chats, and typing indicators.
class MessagingStreamService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  /// Callback to convert a Firestore doc to Chat.
  final Chat Function(DocumentSnapshot doc) chatFromFirestore;

  // Stream controllers for real-time updates
  final Map<String, StreamController<List<Message>>> _messageStreams = {};
  final Map<String, StreamController<List<TypingIndicator>>> _typingStreams = {};
  final StreamController<List<Chat>> _chatsStreamController = StreamController<List<Chat>>.broadcast();

  // Typing indicator timers
  final Map<String, Timer> _typingTimers = {};

  MessagingStreamService({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required this.chatFromFirestore,
  })  : _firestore = firestore,
        _auth = auth;

  Stream<List<Chat>> get chatsStream => _chatsStreamController.stream;

  /// Start listening to the user's chat list
  void listenToUserChats(String userId) {
    _firestore
        .collection('chats')
        .where('participantIds', arrayContains: userId)
        .where('isActive', isEqualTo: true)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .listen((snapshot) {
      final chats = snapshot.docs.map(chatFromFirestore).toList();
      _chatsStreamController.add(chats);
    });
  }

  /// Get a real-time message stream for a chat
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

  /// Get a real-time typing indicators stream for a chat
  Stream<List<TypingIndicator>> getTypingIndicatorsStream(String chatId) {
    if (!_typingStreams.containsKey(chatId)) {
      _typingStreams[chatId] = StreamController<List<TypingIndicator>>.broadcast();
      _listenToTypingIndicators(chatId);
    }
    return _typingStreams[chatId]!.stream;
  }

  /// Set typing indicator for the current user
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

  /// Dispose all stream controllers and timers
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

  // ==================== Private Helpers ====================

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

  Message _messageFromFirestore(DocumentSnapshot doc) {
    final data = Map<String, dynamic>.from(doc.data() as Map);
    return Message.fromJson({...data, 'messageId': doc.id});
  }
}

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/match_chat.dart';
import '../../domain/services/match_chat_service.dart';

// ==================== STATE ====================

abstract class MatchChatState extends Equatable {
  const MatchChatState();

  @override
  List<Object?> get props => [];
}

class MatchChatInitial extends MatchChatState {}

class MatchChatLoading extends MatchChatState {}

class MatchChatJoining extends MatchChatState {}

class MatchChatLoaded extends MatchChatState {
  final MatchChat chat;
  final List<MatchChatMessage> messages;
  final int participantCount;
  final bool isJoined;
  final int rateLimitSeconds;
  final String? sendError;

  const MatchChatLoaded({
    required this.chat,
    this.messages = const [],
    this.participantCount = 0,
    this.isJoined = false,
    this.rateLimitSeconds = 0,
    this.sendError,
  });

  MatchChatLoaded copyWith({
    MatchChat? chat,
    List<MatchChatMessage>? messages,
    int? participantCount,
    bool? isJoined,
    int? rateLimitSeconds,
    String? sendError,
  }) {
    return MatchChatLoaded(
      chat: chat ?? this.chat,
      messages: messages ?? this.messages,
      participantCount: participantCount ?? this.participantCount,
      isJoined: isJoined ?? this.isJoined,
      rateLimitSeconds: rateLimitSeconds ?? this.rateLimitSeconds,
      sendError: sendError,
    );
  }

  @override
  List<Object?> get props => [
        chat,
        messages,
        participantCount,
        isJoined,
        rateLimitSeconds,
        sendError,
      ];
}

class MatchChatError extends MatchChatState {
  final String message;

  const MatchChatError(this.message);

  @override
  List<Object?> get props => [message];
}

// ==================== CUBIT ====================

class MatchChatCubit extends Cubit<MatchChatState> {
  final MatchChatService _chatService;

  StreamSubscription? _messagesSubscription;
  StreamSubscription? _participantCountSubscription;
  Timer? _rateLimitTimer;

  MatchChatCubit({
    MatchChatService? chatService,
  })  : _chatService = chatService ?? MatchChatService(),
        super(MatchChatInitial());

  /// Initialize chat for a match
  Future<void> initializeChat({
    required String matchId,
    required String matchName,
    required String homeTeam,
    required String awayTeam,
    required DateTime matchDateTime,
  }) async {
    emit(MatchChatLoading());

    try {
      final chat = await _chatService.getOrCreateMatchChat(
        matchId: matchId,
        matchName: matchName,
        homeTeam: homeTeam,
        awayTeam: awayTeam,
        matchDateTime: matchDateTime,
      );

      if (chat == null) {
        emit(const MatchChatError('Failed to initialize chat'));
        return;
      }

      final isJoined = await _chatService.isUserInChat(chat.chatId);

      emit(MatchChatLoaded(
        chat: chat,
        isJoined: isJoined,
      ));

      // Start listening to messages
      _subscribeToMessages(chat.chatId);
      _subscribeToParticipantCount(chat.chatId);
    } catch (e) {
      emit(MatchChatError(e.toString()));
    }
  }

  /// Load existing chat by ID
  Future<void> loadChat(String chatId) async {
    emit(MatchChatLoading());

    try {
      final chat = await _chatService.getMatchChat(chatId);

      if (chat == null) {
        emit(const MatchChatError('Chat not found'));
        return;
      }

      final isJoined = await _chatService.isUserInChat(chatId);

      emit(MatchChatLoaded(
        chat: chat,
        isJoined: isJoined,
      ));

      _subscribeToMessages(chatId);
      _subscribeToParticipantCount(chatId);
    } catch (e) {
      emit(MatchChatError(e.toString()));
    }
  }

  void _subscribeToMessages(String chatId) {
    _messagesSubscription?.cancel();
    _messagesSubscription = _chatService.getMessagesStream(chatId).listen(
      (messages) {
        final currentState = state;
        if (currentState is MatchChatLoaded) {
          emit(currentState.copyWith(messages: messages));
        }
      },
      onError: (e) {
        // Don't emit error state, just log it
      },
    );
  }

  void _subscribeToParticipantCount(String chatId) {
    _participantCountSubscription?.cancel();
    _participantCountSubscription =
        _chatService.getParticipantCountStream(chatId).listen(
      (count) {
        final currentState = state;
        if (currentState is MatchChatLoaded) {
          emit(currentState.copyWith(participantCount: count));
        }
      },
    );
  }

  /// Join the chat
  Future<void> joinChat() async {
    final currentState = state;
    if (currentState is! MatchChatLoaded) return;

    emit(MatchChatJoining());

    final success = await _chatService.joinMatchChat(currentState.chat.chatId);

    if (success) {
      emit(currentState.copyWith(isJoined: true));
    } else {
      emit(currentState.copyWith(sendError: 'Failed to join chat'));
    }
  }

  /// Leave the chat
  Future<void> leaveChat() async {
    final currentState = state;
    if (currentState is! MatchChatLoaded) return;

    await _chatService.leaveMatchChat(currentState.chat.chatId);
    emit(currentState.copyWith(isJoined: false));
  }

  /// Send a message
  Future<void> sendMessage(String content) async {
    final currentState = state;
    if (currentState is! MatchChatLoaded) return;
    if (!currentState.isJoined) return;
    if (content.trim().isEmpty) return;

    final result = await _chatService.sendMessage(
      chatId: currentState.chat.chatId,
      content: content.trim(),
    );

    if (!result.success) {
      if (result.waitSeconds != null && result.waitSeconds! > 0) {
        _startRateLimitTimer(result.waitSeconds!);
        emit(currentState.copyWith(
          rateLimitSeconds: result.waitSeconds,
          sendError: 'Please wait ${result.waitSeconds} seconds',
        ));
      } else {
        emit(currentState.copyWith(sendError: result.error));
      }
    } else {
      emit(currentState.copyWith(sendError: null));
    }
  }

  /// Send a quick reaction emoji
  Future<void> sendQuickReaction(String emoji) async {
    final currentState = state;
    if (currentState is! MatchChatLoaded) return;
    if (!currentState.isJoined) return;

    await _chatService.sendQuickReaction(currentState.chat.chatId, emoji);
  }

  /// Toggle reaction on a message
  Future<void> toggleReaction(String messageId, String emoji) async {
    final currentState = state;
    if (currentState is! MatchChatLoaded) return;

    await _chatService.toggleMessageReaction(
      currentState.chat.chatId,
      messageId,
      emoji,
    );
  }

  /// Delete a message (moderator action)
  Future<void> deleteMessage(String messageId) async {
    final currentState = state;
    if (currentState is! MatchChatLoaded) return;

    await _chatService.deleteMessage(currentState.chat.chatId, messageId);
  }

  void _startRateLimitTimer(int seconds) {
    _rateLimitTimer?.cancel();
    var remaining = seconds;

    _rateLimitTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      remaining--;
      final currentState = state;
      if (currentState is MatchChatLoaded) {
        if (remaining <= 0) {
          timer.cancel();
          emit(currentState.copyWith(rateLimitSeconds: 0, sendError: null));
        } else {
          emit(currentState.copyWith(rateLimitSeconds: remaining));
        }
      } else {
        timer.cancel();
      }
    });
  }

  void clearError() {
    final currentState = state;
    if (currentState is MatchChatLoaded) {
      emit(currentState.copyWith(sendError: null));
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    _participantCountSubscription?.cancel();
    _rateLimitTimer?.cancel();
    return super.close();
  }
}

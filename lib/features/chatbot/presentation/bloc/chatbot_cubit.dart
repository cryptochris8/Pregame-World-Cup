import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/chat_message.dart';
import '../../domain/services/chatbot_service.dart';

// ==================== STATE ====================

abstract class ChatbotState extends Equatable {
  const ChatbotState();

  @override
  List<Object?> get props => [];
}

/// Initial state before the chat has started.
class ChatbotInitial extends ChatbotState {}

/// A response is being generated.
class ChatbotLoading extends ChatbotState {
  final List<ChatMessage> messages;

  const ChatbotLoading({required this.messages});

  @override
  List<Object?> get props => [messages];
}

/// Chat is active with a list of messages and current suggestion chips.
class ChatbotLoaded extends ChatbotState {
  final List<ChatMessage> messages;
  final List<String> currentSuggestions;

  const ChatbotLoaded({
    required this.messages,
    this.currentSuggestions = const [],
  });

  ChatbotLoaded copyWith({
    List<ChatMessage>? messages,
    List<String>? currentSuggestions,
  }) {
    return ChatbotLoaded(
      messages: messages ?? this.messages,
      currentSuggestions: currentSuggestions ?? this.currentSuggestions,
    );
  }

  @override
  List<Object?> get props => [messages, currentSuggestions];
}

/// An unrecoverable error occurred.
class ChatbotError extends ChatbotState {
  final String message;
  final List<ChatMessage> previousMessages;

  const ChatbotError({
    required this.message,
    this.previousMessages = const [],
  });

  @override
  List<Object?> get props => [message, previousMessages];
}

// ==================== CUBIT ====================

/// Manages the chatbot conversation flow.
///
/// Uses [ChatbotService] to generate knowledge-powered responses and maintains
/// the in-memory message list displayed in the UI. Messages are stored in
/// reverse chronological order (newest first) to match the reversed ListView.
class ChatbotCubit extends Cubit<ChatbotState> {
  final ChatbotService _chatbotService;

  ChatbotCubit({
    required ChatbotService chatbotService,
  })  : _chatbotService = chatbotService,
        super(ChatbotInitial());

  /// Start the chat session with a welcome message.
  ///
  /// Triggers knowledge base preload in the background.
  Future<void> initialize() async {
    final welcomeMessage = ChatMessage(
      text: ChatbotService.welcomeMessage,
      type: ChatMessageType.bot,
      suggestionChips: ChatbotService.welcomeSuggestions,
    );

    emit(ChatbotLoaded(
      messages: [welcomeMessage],
      currentSuggestions: ChatbotService.welcomeSuggestions,
    ));

    // Preload knowledge base in the background
    _chatbotService.initialize();
  }

  /// Send a user message and generate a response.
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final currentMessages = _getCurrentMessages();

    // Add the user's message immediately
    final userMessage = ChatMessage(
      text: text.trim(),
      type: ChatMessageType.user,
    );
    final updatedMessages = [userMessage, ...currentMessages];

    // Emit loading state with a typing indicator
    emit(ChatbotLoading(messages: updatedMessages));

    try {
      final response = await _chatbotService.getResponse(text.trim());

      final botMessage = ChatMessage(
        text: response.text,
        type: ChatMessageType.bot,
        suggestionChips: response.suggestionChips,
      );

      if (!isClosed) {
        emit(ChatbotLoaded(
          messages: [botMessage, ...updatedMessages],
          currentSuggestions: response.suggestionChips,
        ));
      }
    } catch (e) {
      if (!isClosed) {
        final errorMessage = ChatMessage(
          text: 'Sorry, I had trouble generating a response. Please try again!',
          type: ChatMessageType.bot,
        );
        emit(ChatbotLoaded(messages: [errorMessage, ...updatedMessages]));
      }
    }
  }

  /// Clear all messages and reset the conversation.
  void clearChat() {
    _chatbotService.clearHistory();

    final welcomeMessage = ChatMessage(
      text: ChatbotService.welcomeMessage,
      type: ChatMessageType.bot,
      suggestionChips: ChatbotService.welcomeSuggestions,
    );

    emit(ChatbotLoaded(
      messages: [welcomeMessage],
      currentSuggestions: ChatbotService.welcomeSuggestions,
    ));
  }

  List<ChatMessage> _getCurrentMessages() {
    final current = state;
    if (current is ChatbotLoaded) return current.messages;
    if (current is ChatbotLoading) return current.messages;
    if (current is ChatbotError) return current.previousMessages;
    return [];
  }
}

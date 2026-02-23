enum ChatMessageType { user, bot, thinking }

class ChatMessage {
  final String text;
  final ChatMessageType type;
  final DateTime timestamp;
  final List<String> suggestionChips;

  ChatMessage({
    required this.text,
    required this.type,
    DateTime? timestamp,
    this.suggestionChips = const [],
  }) : timestamp = timestamp ?? DateTime.now();
}

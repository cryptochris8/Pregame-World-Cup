enum ChatMessageType { user, bot }

class ChatMessage {
  final String text;
  final ChatMessageType type;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.type,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
} 
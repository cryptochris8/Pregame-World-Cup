import 'chat_intent.dart';

/// A generated chatbot response with text and contextual suggestion chips.
class ChatResponse {
  final String text;

  /// Suggested follow-up actions shown as tappable chips.
  final List<String> suggestionChips;

  /// The intent that was resolved to generate this response.
  final ChatIntent resolvedIntent;

  const ChatResponse({
    required this.text,
    this.suggestionChips = const [],
    required this.resolvedIntent,
  });
}

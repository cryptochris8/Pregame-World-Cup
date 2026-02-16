import 'dart:async';

import '../../../../core/ai/services/multi_provider_ai_service.dart';
import '../../../../core/services/logging_service.dart';

/// AI-powered chatbot service for the Pregame World Cup assistant.
///
/// Uses [MultiProviderAIService] to generate intelligent responses about the
/// 2026 FIFA World Cup. Maintains conversation history for contextual replies
/// and falls back to helpful default responses when the AI service is
/// unavailable or encounters errors.
class ChatbotService {
  static const String _logTag = 'ChatbotService';

  /// Maximum number of conversation turns kept for context.
  static const int _maxHistoryMessages = 10;

  /// Timeout for AI response generation.
  static const Duration _responseTimeout = Duration(seconds: 15);

  final MultiProviderAIService _aiService;

  /// Rolling conversation history sent as context with each request.
  final List<_ConversationTurn> _conversationHistory = [];

  ChatbotService({
    required MultiProviderAIService aiService,
  }) : _aiService = aiService;

  /// System prompt that grounds the assistant in World Cup 2026 knowledge.
  static const String systemPrompt = '''
You are the Pregame World Cup Assistant, a friendly and knowledgeable guide for the 2026 FIFA World Cup.

Key facts you know:
- Tournament: June 11 - July 19, 2026
- Format: 48 teams in 12 groups of 4, top 2 + 8 best 3rd-place teams advance to knockout round (104 total matches)
- Host countries: United States, Mexico, and Canada
- 16 host cities: New York/New Jersey (MetLife Stadium - Final), Los Angeles (SoFi Stadium), Dallas (AT&T Stadium), Miami (Hard Rock Stadium), Atlanta (Mercedes-Benz Stadium), Houston (NRG Stadium), Philadelphia (Lincoln Financial Field), Seattle (Lumen Field), San Francisco (Levi's Stadium), Kansas City (Arrowhead Stadium), Boston (Gillette Stadium), Toronto (BMO Field), Vancouver (BC Place), Guadalajara (Estadio Akron), Mexico City (Estadio Azteca), Monterrey (Estadio BBVA)
- Opening match: Mexico City, June 11, 2026
- Final: MetLife Stadium, New Jersey, July 19, 2026

You can help fans with:
- Match schedules, group standings, and bracket predictions
- Team information, player profiles, and squad analysis
- Venue details and directions to host stadiums
- Watch party recommendations and nearby bars/restaurants
- General World Cup history and trivia
- Tips for attending matches in person

Guidelines:
- Keep responses concise (2-4 sentences unless the user asks for detail)
- Be enthusiastic about soccer/football but stay factual
- If you are unsure about something, say so rather than guessing
- Reference the app features (schedule, predictions, venues, watch parties) when relevant
''';

  /// Generate an AI response for the user's message.
  ///
  /// Shows the user's message immediately via [ChatbotCubit], then this method
  /// produces the bot reply. Returns the response text.
  Future<String> getResponse(String userMessage) async {
    try {
      // Build the full prompt including conversation history
      final prompt = _buildPromptWithHistory(userMessage);

      String response;

      if (_aiService.isAnyServiceAvailable) {
        response = await _aiService
            .generateQuickResponse(
              prompt: prompt,
              systemMessage: systemPrompt,
            )
            .timeout(
              _responseTimeout,
              onTimeout: () {
                LoggingService.warning(
                  'AI response timed out after ${_responseTimeout.inSeconds}s',
                  tag: _logTag,
                );
                return _generateFallbackResponse(userMessage);
              },
            );
      } else {
        LoggingService.info(
          'No AI service available, using fallback',
          tag: _logTag,
        );
        response = _generateFallbackResponse(userMessage);
      }

      // Record this turn in conversation history
      _addToHistory(userMessage, response);

      return response;
    } on TimeoutException {
      LoggingService.warning('AI response timed out', tag: _logTag);
      final fallback = _generateFallbackResponse(userMessage);
      _addToHistory(userMessage, fallback);
      return fallback;
    } catch (e) {
      LoggingService.error('Chatbot response error: $e', tag: _logTag);
      final fallback = _generateFallbackResponse(userMessage);
      _addToHistory(userMessage, fallback);
      return fallback;
    }
  }

  /// Build a prompt that includes recent conversation history for context.
  String _buildPromptWithHistory(String currentMessage) {
    if (_conversationHistory.isEmpty) {
      return currentMessage;
    }

    final buffer = StringBuffer();
    buffer.writeln('Previous conversation:');

    for (final turn in _conversationHistory) {
      buffer.writeln('User: ${turn.userMessage}');
      buffer.writeln('Assistant: ${turn.botResponse}');
    }

    buffer.writeln();
    buffer.writeln('User: $currentMessage');

    return buffer.toString();
  }

  /// Add a conversation turn to history, trimming to the max limit.
  void _addToHistory(String userMessage, String botResponse) {
    _conversationHistory.add(_ConversationTurn(
      userMessage: userMessage,
      botResponse: botResponse,
    ));

    // Keep only the most recent turns
    while (_conversationHistory.length > _maxHistoryMessages) {
      _conversationHistory.removeAt(0);
    }
  }

  /// Clear all conversation history (used when the user resets the chat).
  void clearHistory() {
    _conversationHistory.clear();
  }

  /// Fallback rule-based responses when the AI service is unavailable.
  String _generateFallbackResponse(String userInput) {
    final lower = userInput.toLowerCase();

    if (lower.contains('hello') || lower.contains('hi') || lower.contains('hey')) {
      return "Hello! I'm here to help you with World Cup 2026 "
          "schedules, teams, venues, and predictions. What would you like to know?";
    }

    if (lower.contains('game') || lower.contains('schedule') || lower.contains('match')) {
      return 'You can view all 104 World Cup matches on the Schedule tab. '
          'Tap on any match to see details, AI predictions, and nearby venues!';
    }

    if (lower.contains('venue') || lower.contains('stadium') || lower.contains('bar') || lower.contains('restaurant')) {
      return 'The 2026 World Cup spans 16 host cities across the USA, Mexico, and Canada. '
          'Check the Venues section to explore stadiums and find nearby places to watch!';
    }

    if (lower.contains('team') || lower.contains('group') || lower.contains('squad')) {
      return 'All 48 qualified teams are listed in the World Cup section. '
          'You can set favorites and follow their group stage journey!';
    }

    if (lower.contains('predict') || lower.contains('winner') || lower.contains('who will win')) {
      return 'Check the Predictions feature for AI-powered match predictions! '
          'You can also make your own picks and compete with friends.';
    }

    if (lower.contains('watch party') || lower.contains('watchparty')) {
      return 'Head to the Watch Party section to create or discover '
          'watch parties near you. Invite friends and pick a great venue!';
    }

    if (lower.contains('ticket') || lower.contains('attend')) {
      return 'Tickets for the 2026 World Cup are managed through FIFA. '
          'Visit fifa.com/tickets for official ticket sales and information.';
    }

    if (lower.contains('help')) {
      return "I can help you with:\n"
          "- Match schedules and results\n"
          "- Team info and group standings\n"
          "- AI match predictions\n"
          "- Venue and watch party recommendations\n"
          "- World Cup 2026 general knowledge\n\n"
          "What would you like to know?";
    }

    if (lower.contains('thank')) {
      return "You're welcome! Enjoy the World Cup! Let me know if you have any other questions.";
    }

    return "I'm your World Cup 2026 assistant! I can help with match schedules, "
        "team information, predictions, venue recommendations, and watch parties. "
        "What would you like to know?";
  }

  /// The welcome message shown when the chat first opens.
  static const String welcomeMessage =
      "Hi! I'm the Pregame World Cup assistant. Ask me about matches, "
      "teams, predictions, venues, or anything about the 2026 FIFA World Cup!";
}

/// Internal model for a single conversation turn (user + bot).
class _ConversationTurn {
  final String userMessage;
  final String botResponse;

  _ConversationTurn({
    required this.userMessage,
    required this.botResponse,
  });
}

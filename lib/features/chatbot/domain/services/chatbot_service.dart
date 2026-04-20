import '../../../../core/services/logging_service.dart';
import '../entities/chat_response.dart';
import '../entities/chat_intent.dart';
import '../../data/services/chatbot_knowledge_base.dart';
import 'intent_classifier.dart';
import 'response_generator.dart';

/// Local knowledge-powered chatbot service for the Pregame assistant.
///
/// Uses [ChatbotKnowledgeBase] to answer questions from 318 JSON data files.
/// Zero API calls, sub-50ms response times.
class ChatbotService {
  static const String _logTag = 'ChatbotService';
  static const int _maxHistoryMessages = 10;

  final ChatbotKnowledgeBase _knowledgeBase;
  final IntentClassifier _classifier;
  final ResponseGenerator _responseGenerator;

  final List<_ConversationTurn> _conversationHistory = [];

  ChatbotService({
    required ChatbotKnowledgeBase knowledgeBase,
    required IntentClassifier classifier,
    required ResponseGenerator responseGenerator,
  })  : _knowledgeBase = knowledgeBase,
        _classifier = classifier,
        _responseGenerator = responseGenerator;

  /// Initialize the knowledge base (call once at startup or on first open).
  Future<void> initialize() async {
    await _knowledgeBase.initialize();
    LoggingService.info('Chatbot service initialized', tag: _logTag);
  }

  bool get isInitialized => _knowledgeBase.isInitialized;

  /// Generate a response for the user's message.
  Future<ChatResponse> getResponse(String userMessage) async {
    try {
      // Ensure knowledge base is loaded
      if (!_knowledgeBase.isInitialized) {
        await _knowledgeBase.initialize();
      }

      // Classify the intent
      final intent = _classifier.classify(userMessage.trim());
      LoggingService.info(
        'Classified: "$userMessage" → $intent',
        tag: _logTag,
      );

      // Generate the response
      final response = await _responseGenerator.generate(intent);

      // Record this turn
      _addToHistory(userMessage, response.text);

      return response;
    } catch (e) {
      LoggingService.error('Chatbot response error: $e', tag: _logTag);
      const fallback = ChatResponse(
        text: 'Sorry, I had trouble with that question. Try asking about a '
            'specific team, player, or match!',
        suggestionChips: ['Help', 'USA schedule', 'Tournament favorites'],
        resolvedIntent: ChatIntent(type: ChatIntentType.unknown),
      );
      _addToHistory(userMessage, fallback.text);
      return fallback;
    }
  }

  void _addToHistory(String userMessage, String botResponse) {
    _conversationHistory.add(_ConversationTurn(
      userMessage: userMessage,
      botResponse: botResponse,
    ));
    while (_conversationHistory.length > _maxHistoryMessages) {
      _conversationHistory.removeAt(0);
    }
  }

  /// Clear all conversation history.
  void clearHistory() {
    _conversationHistory.clear();
    _classifier.reset();
  }

  /// The welcome message shown when the chat first opens.
  static const String welcomeMessage =
      "Hey! I'm Copa, your 2026 tournament sidekick. I know all about "
      "the 48 teams, 104 matches, players, odds, and tournament history. "
      "What would you like to know?";

  /// Suggestion chips shown with the welcome message.
  static const List<String> welcomeSuggestions = [
    'USA schedule',
    'Who are the favorites?',
    'Countdown to Kickoff',
    'Help',
  ];
}

class _ConversationTurn {
  final String userMessage;
  final String botResponse;

  _ConversationTurn({
    required this.userMessage,
    required this.botResponse,
  });
}

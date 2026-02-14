import 'package:flutter/material.dart';
import '../widgets/chat_message_list_item.dart';
import '../../domain/entities/chat_message.dart';
import '../../../../core/ai/services/multi_provider_ai_service.dart';
import '../../../../injection_container.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isProcessing = false;

  MultiProviderAIService? _aiService;

  @override
  void initState() {
    super.initState();
    _initializeAIService();
    _addBotMessage(
      "Hi! I'm the Pregame World Cup assistant. Ask me about matches, "
      "teams, predictions, venues, or anything about the 2026 FIFA World Cup!",
    );
  }

  /// Try to get the AI service from DI; if unavailable, leave null and use fallback.
  void _initializeAIService() {
    try {
      _aiService = sl<MultiProviderAIService>();
    } catch (_) {
      // AI service not registered yet - will use fallback responses
      _aiService = null;
    }
  }

  void _addBotMessage(String text) {
    if (mounted) {
      setState(() {
        _messages.insert(0, ChatMessage(text: text, type: ChatMessageType.bot));
      });
      _scrollToBottom();
    }
  }

  void _addUserMessage(String text) {
    if (mounted) {
      setState(() {
        _messages.insert(0, ChatMessage(text: text, type: ChatMessageType.user));
      });
      _scrollToBottom();
    }
  }

  void _addThinkingIndicator() {
    if (mounted) {
      setState(() {
        _messages.insert(
          0,
          ChatMessage(text: 'Thinking...', type: ChatMessageType.thinking),
        );
      });
      _scrollToBottom();
    }
  }

  void _removeThinkingIndicator() {
    if (mounted) {
      setState(() {
        _messages.removeWhere((m) => m.type == ChatMessageType.thinking);
      });
    }
  }

  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty || _isProcessing) return;

    _textController.clear();
    _addUserMessage(text);

    _isProcessing = true;
    _addThinkingIndicator();

    String botResponse;

    // Attempt to use the AI service for a real response
    if (_aiService != null && _aiService!.isAnyServiceAvailable) {
      try {
        botResponse = await _aiService!.generateQuickResponse(
          prompt: text,
          systemMessage:
              'You are the Pregame World Cup assistant, an expert on the 2026 FIFA World Cup '
              '(June 11 - July 19, 2026) hosted across the USA, Mexico, and Canada. '
              '48 teams compete in 104 matches across 16 host cities. '
              'Help fans with match schedules, team info, predictions, venue recommendations, '
              'watch parties, and general World Cup knowledge. '
              'Keep responses concise (2-4 sentences) and enthusiastic about soccer.',
        );
      } catch (_) {
        // AI call failed - fall back to rule-based responses
        botResponse = _generateSimpleResponse(text.toLowerCase());
      }
    } else {
      // AI service not available - use rule-based fallback
      botResponse = _generateSimpleResponse(text.toLowerCase());
    }

    _removeThinkingIndicator();
    _isProcessing = false;
    _addBotMessage(botResponse);
  }

  /// Fallback rule-based responses when AI service is unavailable or fails.
  String _generateSimpleResponse(String userInput) {
    if (userInput.contains('hello') || userInput.contains('hi')) {
      return "Hello! I'm here to help you with World Cup 2026 schedules, teams, venues, and predictions.";
    } else if (userInput.contains('game') || userInput.contains('schedule') || userInput.contains('match')) {
      return "You can view all 104 World Cup matches on the schedule screen. Tap on any match to see details and nearby venues!";
    } else if (userInput.contains('venue') || userInput.contains('bar') || userInput.contains('restaurant')) {
      return "To find venues near a match, select a game from the schedule and I'll show you nearby bars and restaurants for watch parties!";
    } else if (userInput.contains('team') || userInput.contains('group')) {
      return "All 48 qualified teams are listed in the World Cup section. You can set favorites and follow their group stage journey!";
    } else if (userInput.contains('predict') || userInput.contains('winner') || userInput.contains('who will win')) {
      return "Check the predictions feature for AI-powered match predictions! You can also make your own picks and compete with friends.";
    } else if (userInput.contains('help')) {
      return "I can help you with:\n- Match schedules and results\n- Team info and group standings\n- AI match predictions\n- Venue and watch party recommendations\n- World Cup 2026 general knowledge\n\nWhat would you like to know?";
    } else if (userInput.contains('thank')) {
      return "You're welcome! Enjoy the World Cup!";
    } else {
      return "I'm your World Cup 2026 assistant! Ask me about match schedules, team information, predictions, or finding venues to watch the games.";
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pregame Assistant'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        titleTextStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 20),
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8.0),
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (_, int index) => ChatMessageListItem(message: _messages[index]),
            ),
          ),
          const Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _textController,
                onSubmitted: _isProcessing ? null : _handleSubmitted,
                decoration: const InputDecoration.collapsed(hintText: 'Send a message'),
                enabled: !_isProcessing,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: _isProcessing ? null : () => _handleSubmitted(_textController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

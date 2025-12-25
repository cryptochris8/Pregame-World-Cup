import 'package:flutter/material.dart';
import '../widgets/chat_message_list_item.dart'; // Adjust path if needed
import '../../domain/entities/chat_message.dart'; // Adjust path if needed

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _addBotMessage("Hi! I'm the Pregame assistant. How can I help you today?");
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

  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;

    _textController.clear();
    _addUserMessage(text);

    // Simple placeholder responses
    String botResponse = _generateSimpleResponse(text.toLowerCase());
    
    // Add a small delay to simulate processing
    await Future.delayed(const Duration(milliseconds: 500));
    _addBotMessage(botResponse);
  }

  String _generateSimpleResponse(String userInput) {
    if (userInput.contains('hello') || userInput.contains('hi')) {
      return "Hello! I'm here to help you with game schedules and venue recommendations.";
    } else if (userInput.contains('game') || userInput.contains('schedule')) {
      return "You can view upcoming games on the main schedule screen. Tap on any game to see nearby venues!";
    } else if (userInput.contains('venue') || userInput.contains('bar') || userInput.contains('restaurant')) {
      return "To find venues near a game, select a game from the schedule and I'll show you nearby bars and restaurants!";
    } else if (userInput.contains('help')) {
      return "I can help you with:\n• Finding game schedules\n• Discovering nearby venues\n• Setting favorite teams\n\nWhat would you like to know?";
    } else if (userInput.contains('thank')) {
      return "You're welcome! Enjoy the game!";
    } else {
      return "I'm still learning! For now, I can help you with game schedules and venue recommendations. Try asking about games or venues near you.";
    }
  }

  void _scrollToBottom() {
    // Scroll to the bottom of the list after a short delay
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
              reverse: true, // To keep messages at the bottom & new ones appear from bottom
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
                onSubmitted: _handleSubmitted,
                decoration: const InputDecoration.collapsed(hintText: 'Send a message'),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => _handleSubmitted(_textController.text),
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
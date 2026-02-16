import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection_container.dart';
import '../../domain/entities/chat_message.dart';
import '../bloc/chatbot_cubit.dart';
import '../widgets/chat_message_list_item.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChatbotCubit>(
      create: (_) => sl<ChatbotCubit>()..initialize(),
      child: const _ChatScreenBody(),
    );
  }
}

class _ChatScreenBody extends StatefulWidget {
  const _ChatScreenBody();

  @override
  State<_ChatScreenBody> createState() => _ChatScreenBodyState();
}

class _ChatScreenBodyState extends State<_ChatScreenBody> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;
    _textController.clear();
    context.read<ChatbotCubit>().sendMessage(text);
    _scrollToBottom();
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

  void _showClearChatDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear Chat'),
        content: const Text(
          'This will clear the conversation and start fresh. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<ChatbotCubit>().clearChat();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pregame Assistant'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: 20,
        ),
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            tooltip: 'Clear chat',
            onPressed: _showClearChatDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatbotCubit, ChatbotState>(
              listener: (context, state) {
                // Scroll to bottom whenever new messages arrive
                if (state is ChatbotLoaded || state is ChatbotLoading) {
                  _scrollToBottom();
                }
              },
              builder: (context, state) {
                final messages = _messagesFromState(state);
                final isLoading = state is ChatbotLoading;

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8.0),
                  reverse: true,
                  // +1 when loading so we can render the typing indicator
                  itemCount: messages.length + (isLoading ? 1 : 0),
                  itemBuilder: (_, int index) {
                    // The typing indicator goes at position 0 (newest)
                    if (isLoading && index == 0) {
                      return ChatMessageListItem(
                        message: ChatMessage(
                          text: 'Thinking...',
                          type: ChatMessageType.thinking,
                        ),
                      );
                    }

                    final messageIndex = isLoading ? index - 1 : index;
                    return ChatMessageListItem(
                      message: messages[messageIndex],
                    );
                  },
                );
              },
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
    return BlocBuilder<ChatbotCubit, ChatbotState>(
      builder: (context, state) {
        final isLoading = state is ChatbotLoading;

        return IconTheme(
          data: IconThemeData(
            color: Theme.of(context).colorScheme.secondary,
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    onSubmitted: isLoading ? null : _handleSubmitted,
                    decoration: const InputDecoration.collapsed(
                      hintText: 'Send a message',
                    ),
                    enabled: !isLoading,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: isLoading
                        ? null
                        : () => _handleSubmitted(_textController.text),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Extract the message list from the current cubit state.
  List<ChatMessage> _messagesFromState(ChatbotState state) {
    if (state is ChatbotLoaded) return state.messages;
    if (state is ChatbotLoading) return state.messages;
    if (state is ChatbotError) return state.previousMessages;
    return [];
  }
}

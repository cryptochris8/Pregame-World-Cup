import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/app_theme.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/chat_message.dart';
import '../bloc/chatbot_cubit.dart';
import '../widgets/chat_message_list_item.dart';
import '../widgets/copa_avatar.dart';
import '../widgets/suggestion_chips.dart';

class ChatScreen extends StatelessWidget {
  /// When true, renders without its own Scaffold AppBar (used inside a
  /// bottom sheet that already has a drag handle).
  final bool isBottomSheet;

  const ChatScreen({super.key, this.isBottomSheet = false});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChatbotCubit>(
      create: (_) => sl<ChatbotCubit>()..initialize(),
      child: _ChatScreenBody(isBottomSheet: isBottomSheet),
    );
  }
}

class _ChatScreenBody extends StatefulWidget {
  final bool isBottomSheet;

  const _ChatScreenBody({required this.isBottomSheet});

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
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.backgroundCard,
        title: Text(l10n.copaClearChat),
        content: Text(
          l10n.copaClearChatConfirm,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<ChatbotCubit>().clearChat();
            },
            child: Text(l10n.copaClearChat),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = Column(
      children: [
        Expanded(
          child: BlocConsumer<ChatbotCubit, ChatbotState>(
            listener: (context, state) {
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
                itemCount: messages.length + (isLoading ? 1 : 0),
                itemBuilder: (_, int index) {
                  if (isLoading && index == 0) {
                    return ChatMessageListItem(
                      message: ChatMessage(
                        text: AppLocalizations.of(context)!.copaThinking,
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
        // Suggestion chips
        BlocBuilder<ChatbotCubit, ChatbotState>(
          builder: (context, state) {
            final chips = state is ChatbotLoaded
                ? state.currentSuggestions
                : <String>[];
            if (chips.isEmpty) return const SizedBox.shrink();
            return SuggestionChips(
              chips: chips,
              onChipTapped: _handleSubmitted,
            );
          },
        ),
        const Divider(height: 1.0),
        Container(
          decoration: BoxDecoration(color: Theme.of(context).cardColor),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: _buildTextComposer(),
        ),
      ],
    );

    if (widget.isBottomSheet) {
      // Bottom-sheet mode: show a drag handle and title row instead of AppBar
      return Column(
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                const CopaAvatar(size: 28),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Copa',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: AppLocalizations.of(context)!.copaClearTooltip,
                  onPressed: _showClearChatDialog,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(child: body),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Copa'),
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
            tooltip: AppLocalizations.of(context)!.copaClearTooltip,
            onPressed: _showClearChatDialog,
          ),
        ],
      ),
      body: body,
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
                    decoration: InputDecoration.collapsed(
                      hintText: AppLocalizations.of(context)!.copaHintText,
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

  List<ChatMessage> _messagesFromState(ChatbotState state) {
    if (state is ChatbotLoaded) return state.messages;
    if (state is ChatbotLoading) return state.messages;
    if (state is ChatbotError) return state.previousMessages;
    return [];
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/services/match_chat_service.dart';
import '../cubit/match_chat_cubit.dart';
import '../widgets/match_chat_message_item.dart';
import '../widgets/match_chat_input.dart';
import '../widgets/quick_reactions_bar.dart';

/// Screen for live match chat
class MatchChatScreen extends StatefulWidget {
  final String matchId;
  final String matchName;
  final String homeTeam;
  final String awayTeam;
  final DateTime matchDateTime;
  final String? chatId; // If already have chatId

  const MatchChatScreen({
    super.key,
    required this.matchId,
    required this.matchName,
    required this.homeTeam,
    required this.awayTeam,
    required this.matchDateTime,
    this.chatId,
  });

  @override
  State<MatchChatScreen> createState() => _MatchChatScreenState();
}

class _MatchChatScreenState extends State<MatchChatScreen> {
  late MatchChatCubit _cubit;
  final ScrollController _scrollController = ScrollController();
  final MatchChatService _chatService = MatchChatService();

  @override
  void initState() {
    super.initState();
    _cubit = MatchChatCubit();

    if (widget.chatId != null) {
      _cubit.loadChat(widget.chatId!);
    } else {
      _cubit.initializeChat(
        matchId: widget.matchId,
        matchName: widget.matchName,
        homeTeam: widget.homeTeam,
        awayTeam: widget.awayTeam,
        matchDateTime: widget.matchDateTime,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Live Chat',
                style: theme.textTheme.titleMedium,
              ),
              Text(
                '${widget.homeTeam} vs ${widget.awayTeam}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          actions: [
            BlocBuilder<MatchChatCubit, MatchChatState>(
              builder: (context, state) {
                if (state is MatchChatLoaded) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${state.participantCount}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocConsumer<MatchChatCubit, MatchChatState>(
          listener: (context, state) {
            if (state is MatchChatLoaded && state.sendError != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.sendError!),
                  duration: const Duration(seconds: 2),
                ),
              );
              _cubit.clearError();
            }
          },
          builder: (context, state) {
            if (state is MatchChatLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is MatchChatJoining) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Joining chat...'),
                  ],
                ),
              );
            }

            if (state is MatchChatError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        _cubit.initializeChat(
                          matchId: widget.matchId,
                          matchName: widget.matchName,
                          homeTeam: widget.homeTeam,
                          awayTeam: widget.awayTeam,
                          matchDateTime: widget.matchDateTime,
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is MatchChatLoaded) {
              if (!state.isJoined) {
                return _buildJoinPrompt(theme, state);
              }

              return _buildChatView(theme, state);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildJoinPrompt(ThemeData theme, MatchChatLoaded state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Join the Live Chat',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Chat with other fans watching ${widget.homeTeam} vs ${widget.awayTeam}',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people,
                  size: 18,
                  color: theme.colorScheme.outline,
                ),
                const SizedBox(width: 4),
                Text(
                  '${state.participantCount} fans in chat',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => _cubit.joinChat(),
              icon: const Icon(Icons.login),
              label: const Text('Join Chat'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Be respectful. Offensive content will be removed.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatView(ThemeData theme, MatchChatLoaded state) {
    return Column(
      children: [
        // Quick reactions bar
        QuickReactionsBar(
          onReactionTap: (emoji) => _cubit.sendQuickReaction(emoji),
        ),

        // Messages list
        Expanded(
          child: state.messages.isEmpty
              ? _buildEmptyMessages(theme)
              : ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final message = state.messages[index];
                    final isOwnMessage =
                        message.senderId == _chatService.currentUserId;

                    return MatchChatMessageItem(
                      message: message,
                      isOwnMessage: isOwnMessage,
                      onReaction: (emoji) =>
                          _cubit.toggleReaction(message.messageId, emoji),
                      onDelete: isOwnMessage
                          ? () => _cubit.deleteMessage(message.messageId)
                          : null,
                    );
                  },
                ),
        ),

        // Rate limit indicator
        if (state.rateLimitSeconds > 0)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: theme.colorScheme.surfaceContainerHighest,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.timer,
                  size: 16,
                  color: theme.colorScheme.outline,
                ),
                const SizedBox(width: 4),
                Text(
                  'Slow mode: ${state.rateLimitSeconds}s',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),

        // Message input
        MatchChatInput(
          enabled: state.rateLimitSeconds == 0,
          onSend: (message) => _cubit.sendMessage(message),
          onLeave: () => _showLeaveConfirmation(context),
        ),
      ],
    );
  }

  Widget _buildEmptyMessages(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to say something!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  void _showLeaveConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Chat?'),
        content: const Text('You can rejoin anytime during the match.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _cubit.leaveChat();
            },
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/chat.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/typing_indicator.dart';
import '../../domain/services/messaging_service.dart';
import '../../domain/services/messaging_chat_settings_service.dart';
import '../../../social/domain/services/social_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/message_item_widget.dart';
import '../widgets/message_input_widget.dart';
import '../widgets/typing_indicator_widget.dart';
import '../widgets/message_search_widget.dart';
import '../widgets/chat_info_bottom_sheet.dart';
import '../widgets/add_member_bottom_sheet.dart';
import '../widgets/chat_app_bar_title.dart';
import '../widgets/chat_empty_state.dart';
import '../widgets/chat_blocked_banner.dart';
import '../widgets/chat_dialogs.dart';

class ChatScreen extends StatefulWidget {
  final Chat chat;

  const ChatScreen({
    super.key,
    required this.chat,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final MessagingService _messagingService = MessagingService();
  final ScrollController _scrollController = ScrollController();
  String? _replyToMessageId;
  bool _isLoading = true;
  List<Message> _messages = [];
  List<TypingIndicator> _typingUsers = [];
  BlockStatus _blockStatus = const BlockStatus(isBlocked: false);

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _markMessagesAsRead();
    _listenToTypingIndicators();
    _checkBlockStatus();
  }

  Future<void> _checkBlockStatus() async {
    final status = await _messagingService.getChatBlockStatus(widget.chat);
    if (mounted) {
      setState(() {
        _blockStatus = status;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      final messages =
          await _messagingService.getChatMessages(widget.chat.chatId);
      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).failedToLoadMessages(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _listenToTypingIndicators() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    _messagingService
        .getTypingIndicatorsStream(widget.chat.chatId)
        .listen((indicators) {
      // Filter out current user's typing indicator
      final filteredIndicators = indicators
          .where((indicator) => indicator.userId != currentUser.uid)
          .toList();

      if (mounted) {
        setState(() {
          _typingUsers = filteredIndicators;
        });
      }
    });
  }

  Future<void> _markMessagesAsRead() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        await _messagingService.markChatAsRead(widget.chat.chatId);
      } catch (e) {
        // Silently handle error - not critical
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _scrollToMessage(Message message) {
    // Find the message index
    final index =
        _messages.indexWhere((m) => m.messageId == message.messageId);
    if (index != -1) {
      // Calculate approximate scroll position
      final position = index * 80.0; // Approximate message height
      _scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );

      // Show a brief highlight or indication
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).foundMessageFrom(message.senderName)),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.orange[300],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[900],
      appBar: AppBar(
        backgroundColor: Colors.brown[800],
        foregroundColor: Colors.white,
        title: ChatAppBarTitle(
          chat: widget.chat,
          displayName: _getChatDisplayName(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showMessageSearch,
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: _startVideoCall,
          ),
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: _startVoiceCall,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: _handleMenuSelection,
            itemBuilder: (context) {
              final l10n = AppLocalizations.of(context);
              return [
                PopupMenuItem(
                  value: 'view_info',
                  child: Text(l10n.viewInfo),
                ),
                PopupMenuItem(
                  value: 'mute',
                  child: Text(l10n.muteNotifications),
                ),
                PopupMenuItem(
                  value: 'clear_history',
                  child: Text(l10n.clearChatHistory),
                ),
                if (widget.chat.type != ChatType.direct)
                  PopupMenuItem(
                    value: 'leave_chat',
                    child: Text(l10n.leaveChat),
                  ),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.orange),
                    ),
                  )
                : _messages.isEmpty
                    ? const ChatEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(8),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final previousMessage =
                              index > 0 ? _messages[index - 1] : null;

                          // Determine if we should show sender info
                          final showSenderInfo = _shouldShowSenderInfo(
                            message,
                            previousMessage,
                          );

                          return MessageItemWidget(
                            message: message,
                            chat: widget.chat,
                            showSenderInfo: showSenderInfo,
                            isFirstMessage: index == 0,
                            isLastMessage: index == _messages.length - 1,
                            onReply: _handleReply,
                            onReaction: _handleReaction,
                          );
                        },
                      ),
          ),

          // Typing indicator (only show if not blocked)
          if (!_blockStatus.isBlocked)
            TypingIndicatorWidget(typingUsers: _typingUsers),

          // Message input or blocked banner
          if (_blockStatus.isBlocked)
            ChatBlockedBanner(
              blockStatus: _blockStatus,
              onUnblock: _showUnblockDialog,
            )
          else
            MessageInputWidget(
              chatId: widget.chat.chatId,
              replyToMessageId: _replyToMessageId,
              onMessageSent: _handleMessageSent,
              onCancelReply: () {
                setState(() {
                  _replyToMessageId = null;
                });
              },
            ),
        ],
      ),
    );
  }

  Future<void> _showUnblockDialog() async {
    final result = await ChatDialogs.showUnblockDialog(context);
    if (result == true) {
      await _unblockUser();
    }
  }

  Future<void> _unblockUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // Get the other user's ID from the chat
    final otherUserId = widget.chat.participantIds.firstWhere(
      (id) => id != currentUser.uid,
      orElse: () => '',
    );

    if (otherUserId.isEmpty) return;

    try {
      final socialService = SocialService();
      final success =
          await socialService.unblockUser(currentUser.uid, otherUserId);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).userUnblocked),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh block status
        await _checkBlockStatus();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).failedToUnblock(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getChatDisplayName() {
    if (widget.chat.name != null && widget.chat.name!.isNotEmpty) {
      return widget.chat.name!;
    }

    if (widget.chat.type == ChatType.direct) {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId != null) {
        final otherParticipants = widget.chat.participantIds
            .where((id) => id != currentUserId)
            .toList();

        if (otherParticipants.isNotEmpty) {
          return 'User ${otherParticipants.first.substring(0, 8)}';
        }
      }
      return AppLocalizations.of(context).directChat;
    } else if (widget.chat.type == ChatType.group) {
      return AppLocalizations.of(context).groupChat;
    } else {
      return AppLocalizations.of(context).teamChat;
    }
  }

  bool _shouldShowSenderInfo(Message current, Message? previous) {
    if (previous == null) return true;

    if (current.senderId != previous.senderId) return true;

    final timeDifference = current.createdAt.difference(previous.createdAt);
    if (timeDifference.inMinutes > 5) return true;

    return false;
  }

  void _handleReply(String messageId) {
    setState(() {
      _replyToMessageId = messageId;
    });
  }

  Future<void> _handleReaction(String messageId, String emoji) async {
    try {
      await _messagingService.addReactionToMessage(messageId, emoji);
      // Refresh messages to show new reaction
      await _loadMessages();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).failedToAddReaction(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleMessageSent() {
    setState(() {
      _replyToMessageId = null;
    });
    // Reload messages to show the new message
    _loadMessages();
    _scrollToBottom();
  }

  void _startVideoCall() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).videoCallingComingSoon),
      ),
    );
  }

  void _startVoiceCall() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).voiceCallingComingSoon),
      ),
    );
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'view_info':
        _showChatInfo();
        break;
      case 'mute':
        _toggleMute();
        break;
      case 'clear_history':
        _handleClearHistory();
        break;
      case 'leave_chat':
        _handleLeaveChat();
        break;
    }
  }

  void _showChatInfo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.brown[900],
      isScrollControlled: true,
      builder: (context) => ChatInfoBottomSheet(
        chat: widget.chat,
        messagingService: _messagingService,
        onAddMember: _showAddMemberDialog,
      ),
    );
  }

  void _showAddMemberDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.brown[900],
      isScrollControlled: true,
      builder: (context) => AddMemberBottomSheet(
        chatId: widget.chat.chatId,
        existingMemberIds: widget.chat.participantIds,
        messagingService: _messagingService,
      ),
    );
  }

  Future<void> _toggleMute() async {
    final settings =
        await _messagingService.getChatSettings(widget.chat.chatId);

    bool success;
    if (settings.isMuted) {
      success = await _messagingService.unmuteChat(widget.chat.chatId);
    } else {
      if (!mounted) return;
      final duration = await ChatDialogs.showMuteDurationDialog(context);
      if (duration == null) return;
      success = await _messagingService.muteChat(widget.chat.chatId,
          duration: duration);
    }

    if (mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? (settings.isMuted ? l10n.chatUnmuted : l10n.chatMuted)
              : l10n.failedToUpdateMute),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _handleClearHistory() async {
    final result = await ChatDialogs.showClearHistoryDialog(context);
    if (result == true) {
      await _clearChatHistory();
    }
  }

  Future<void> _handleLeaveChat() async {
    final result = await ChatDialogs.showLeaveChatDialog(context);
    if (result == true) {
      await _leaveChat();
    }
  }

  Future<void> _clearChatHistory() async {
    final success =
        await _messagingService.clearChatHistory(widget.chat.chatId);

    if (success) {
      setState(() {
        _messages = [];
      });
    }

    if (mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? l10n.chatHistoryCleared
              : l10n.failedToClearHistory),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _leaveChat() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    // Check if user is the only admin
    if (widget.chat.isAdmin(currentUserId ?? '') &&
        widget.chat.adminIds.length == 1 &&
        widget.chat.participantIds.length > 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).promoteAdminFirst),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final success = await _messagingService.leaveChat(widget.chat.chatId);

    if (mounted) {
      final l10n = AppLocalizations.of(context);
      if (success) {
        Navigator.of(context).pop(); // Return to chats list
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.youLeftChat),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToLeaveChat),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showMessageSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MessageSearchWidget(
        chatId: widget.chat.chatId,
        onMessageSelected: _scrollToMessage,
      ),
    );
  }
}

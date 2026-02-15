import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/chat.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/typing_indicator.dart';
import '../../domain/services/messaging_service.dart';
import '../../domain/services/messaging_chat_settings_service.dart';
import '../../../social/domain/services/social_service.dart';
import '../widgets/message_item_widget.dart';
import '../widgets/message_input_widget.dart';
import '../widgets/typing_indicator_widget.dart';
import '../widgets/message_search_widget.dart';
import '../widgets/chat_info_bottom_sheet.dart';
import '../widgets/add_member_bottom_sheet.dart';

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
      final messages = await _messagingService.getChatMessages(widget.chat.chatId);
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
            content: Text('Failed to load messages: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _listenToTypingIndicators() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    _messagingService.getTypingIndicatorsStream(widget.chat.chatId).listen((indicators) {
      // Filter out current user's typing indicator
      final filteredIndicators = indicators.where((indicator) => 
          indicator.userId != currentUser.uid).toList();
      
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
    final index = _messages.indexWhere((m) => m.messageId == message.messageId);
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
          content: Text('Found message from ${message.senderName}'),
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
        title: _buildAppBarTitle(),
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
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'view_info',
                child: Text('View Info'),
              ),
              const PopupMenuItem(
                value: 'mute',
                child: Text('Mute Notifications'),
              ),
              const PopupMenuItem(
                value: 'clear_history',
                child: Text('Clear Chat History'),
              ),
              if (widget.chat.type != ChatType.direct)
                const PopupMenuItem(
                  value: 'leave_chat',
                  child: Text('Leave Chat'),
                ),
            ],
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
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                    ),
                  )
                : _messages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(8),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final previousMessage = index > 0 ? _messages[index - 1] : null;
                          
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
            _buildBlockedBanner()
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

  Widget _buildBlockedBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[900]?.withValues(alpha:0.8),
        border: Border(
          top: BorderSide(color: Colors.red[700]!, width: 1),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Icon(
              _blockStatus.blockedByCurrentUser ? Icons.block : Icons.do_not_disturb,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _blockStatus.message ?? 'Unable to send messages',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
            if (_blockStatus.blockedByCurrentUser)
              TextButton(
                onPressed: _showUnblockDialog,
                child: const Text(
                  'Unblock',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showUnblockDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.brown[800],
        title: const Text(
          'Unblock User',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to unblock this user? They will be able to message you again.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Unblock',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );

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
      // Import SocialService to unblock
      final socialService = SocialService();
      final success = await socialService.unblockUser(currentUser.uid, otherUserId);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User unblocked'),
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
            content: Text('Failed to unblock user: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildAppBarTitle() {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.orange[300],
          backgroundImage: widget.chat.imageUrl != null 
              ? NetworkImage(widget.chat.imageUrl!)
              : null,
          child: widget.chat.imageUrl == null
              ? Icon(
                  widget.chat.type == ChatType.direct 
                      ? Icons.person
                      : widget.chat.type == ChatType.team
                          ? Icons.groups
                          : Icons.group,
                  color: Colors.brown[800],
                  size: 20,
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getChatDisplayName(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (widget.chat.type != ChatType.direct) ...[
                Text(
                  '${widget.chat.participantIds.length} members',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha:0.7),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.white.withValues(alpha:0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withValues(alpha:0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start the conversation!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha:0.5),
            ),
          ),
        ],
      ),
    );
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
          // In a real app, you'd fetch the user's display name from a user service
          return 'User ${otherParticipants.first.substring(0, 8)}';
        }
      }
      return 'Direct Chat';
    } else if (widget.chat.type == ChatType.group) {
      return 'Group Chat';
    } else {
      return 'Team Chat';
    }
  }

  bool _shouldShowSenderInfo(Message current, Message? previous) {
    if (previous == null) return true;
    
    // Show sender info if:
    // 1. Different sender
    // 2. More than 5 minutes between messages
    // 3. System message in between
    
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
          content: Text('Failed to add reaction: $e'),
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
      const SnackBar(
        content: Text('Video calling coming soon!'),
      ),
    );
  }

  void _startVoiceCall() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice calling coming soon!'),
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
        _showClearHistoryDialog();
        break;
      case 'leave_chat':
        _showLeaveChatDialog();
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
    final settings = await _messagingService.getChatSettings(widget.chat.chatId);

    bool success;
    if (settings.isMuted) {
      success = await _messagingService.unmuteChat(widget.chat.chatId);
    } else {
      // Show mute duration options
      final duration = await _showMuteDurationDialog();
      if (duration == null) return;

      success = await _messagingService.muteChat(widget.chat.chatId, duration: duration);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? (settings.isMuted ? 'Chat unmuted' : 'Chat muted')
              : 'Failed to update mute settings'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<Duration?> _showMuteDurationDialog() async {
    return showDialog<Duration?>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.brown[800],
        title: const Text('Mute notifications', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('1 hour', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context, const Duration(hours: 1)),
            ),
            ListTile(
              title: const Text('8 hours', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context, const Duration(hours: 8)),
            ),
            ListTile(
              title: const Text('1 day', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context, const Duration(days: 1)),
            ),
            ListTile(
              title: const Text('1 week', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context, const Duration(days: 7)),
            ),
            ListTile(
              title: const Text('Forever', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context, const Duration(days: 36500)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.brown[800],
        title: const Text(
          'Clear Chat History',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to clear all messages in this chat? This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearChatHistory();
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showLeaveChatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.brown[800],
        title: const Text(
          'Leave Chat',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to leave this chat?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _leaveChat();
            },
            child: const Text(
              'Leave',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _clearChatHistory() async {
    final success = await _messagingService.clearChatHistory(widget.chat.chatId);

    if (success) {
      // Clear local messages and reload
      setState(() {
        _messages = [];
      });
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Chat history cleared' : 'Failed to clear chat history'),
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
        const SnackBar(
          content: Text('You must promote another admin before leaving'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final success = await _messagingService.leaveChat(widget.chat.chatId);

    if (mounted) {
      if (success) {
        Navigator.of(context).pop(); // Return to chats list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You left the chat'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to leave chat'),
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

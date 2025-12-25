import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/chat.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/typing_indicator.dart';
import '../../domain/services/messaging_service.dart';
import '../widgets/message_item_widget.dart';
import '../widgets/message_input_widget.dart';
import '../widgets/typing_indicator_widget.dart';
import '../widgets/message_search_widget.dart';

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

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _markMessagesAsRead();
    _listenToTypingIndicators();
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
                          final nextMessage = index < _messages.length - 1 ? _messages[index + 1] : null;
                          
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
          
          // Typing indicator
          TypingIndicatorWidget(typingUsers: _typingUsers),
          
          // Message input
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
                    color: Colors.white.withOpacity(0.7),
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
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start the conversation!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.5),
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
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chat Info',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.group, color: Colors.orange[300]),
              title: const Text('Members', style: TextStyle(color: Colors.white)),
              subtitle: Text(
                '${widget.chat.participantIds.length} participants',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            ListTile(
              leading: Icon(Icons.access_time, color: Colors.orange[300]),
              title: const Text('Created', style: TextStyle(color: Colors.white)),
              subtitle: Text(
                _formatDateTime(widget.chat.createdAt),
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            // TODO: Add more chat info items
          ],
        ),
      ),
    );
  }

  void _toggleMute() {
    // TODO: Implement mute functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mute notifications feature coming soon!'),
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

  void _clearChatHistory() {
    // TODO: Implement clear chat history
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Clear chat history feature coming soon!'),
      ),
    );
  }

  void _leaveChat() {
    // TODO: Implement leave chat
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Leave chat feature coming soon!'),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
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
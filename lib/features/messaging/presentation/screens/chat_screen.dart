import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/chat.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/typing_indicator.dart';
import '../../domain/services/messaging_service.dart';
import '../../../social/domain/services/social_service.dart';
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
        color: Colors.red[900]?.withOpacity(0.8),
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
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isAdmin = widget.chat.isAdmin(currentUserId ?? '');
    final isCreator = widget.chat.createdBy == currentUserId;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.brown[900],
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Text(
                    'Chat Info',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Chat name and description
              if (widget.chat.name != null) ...[
                Text(
                  widget.chat.name!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.chat.description != null && widget.chat.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      widget.chat.description!,
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ),
                const SizedBox(height: 16),
              ],

              // Created info
              Row(
                children: [
                  Icon(Icons.access_time, color: Colors.orange[300], size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Created ${_formatDateTime(widget.chat.createdAt)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Members header with add button
              Row(
                children: [
                  Text(
                    'Members (${widget.chat.participantIds.length})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (isAdmin && widget.chat.type != ChatType.direct)
                    TextButton.icon(
                      icon: const Icon(Icons.person_add, color: Colors.orange, size: 18),
                      label: const Text('Add', style: TextStyle(color: Colors.orange)),
                      onPressed: () {
                        Navigator.pop(context);
                        _showAddMemberDialog();
                      },
                    ),
                ],
              ),
              const Divider(color: Colors.white24),

              // Members list
              Expanded(
                child: FutureBuilder<List<ChatMemberInfo>>(
                  future: _messagingService.getChatMembers(widget.chat.chatId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.orange),
                      );
                    }

                    final members = snapshot.data ?? [];
                    if (members.isEmpty) {
                      return const Center(
                        child: Text('No members found', style: TextStyle(color: Colors.white70)),
                      );
                    }

                    return ListView.builder(
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        final member = members[index];
                        final isMe = member.userId == currentUserId;

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange[300],
                            backgroundImage: member.imageUrl != null
                                ? NetworkImage(member.imageUrl!)
                                : null,
                            child: member.imageUrl == null
                                ? Text(
                                    member.displayName.isNotEmpty
                                        ? member.displayName[0].toUpperCase()
                                        : '?',
                                    style: TextStyle(color: Colors.brown[800]),
                                  )
                                : null,
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  isMe ? '${member.displayName} (You)' : member.displayName,
                                  style: const TextStyle(color: Colors.white),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (member.isCreator)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Owner',
                                    style: TextStyle(color: Colors.white, fontSize: 10),
                                  ),
                                )
                              else if (member.isAdmin)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Admin',
                                    style: TextStyle(color: Colors.white, fontSize: 10),
                                  ),
                                ),
                            ],
                          ),
                          trailing: (!isMe && widget.chat.type != ChatType.direct)
                              ? _buildMemberActions(member, isAdmin, isCreator)
                              : null,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _buildMemberActions(ChatMemberInfo member, bool isAdmin, bool isCreator) {
    if (!isAdmin) return null;

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white70),
      color: Colors.brown[800],
      onSelected: (value) async {
        Navigator.pop(context); // Close the bottom sheet first

        switch (value) {
          case 'promote':
            await _promoteMember(member);
            break;
          case 'demote':
            await _demoteMember(member);
            break;
          case 'remove':
            await _removeMember(member);
            break;
        }
      },
      itemBuilder: (context) => [
        if (!member.isAdmin)
          const PopupMenuItem(
            value: 'promote',
            child: Row(
              children: [
                Icon(Icons.arrow_upward, color: Colors.green, size: 20),
                SizedBox(width: 8),
                Text('Make Admin', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        if (member.isAdmin && !member.isCreator && isCreator)
          const PopupMenuItem(
            value: 'demote',
            child: Row(
              children: [
                Icon(Icons.arrow_downward, color: Colors.orange, size: 20),
                SizedBox(width: 8),
                Text('Remove Admin', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        if (!member.isCreator)
          const PopupMenuItem(
            value: 'remove',
            child: Row(
              children: [
                Icon(Icons.person_remove, color: Colors.red, size: 20),
                SizedBox(width: 8),
                Text('Remove', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _promoteMember(ChatMemberInfo member) async {
    final success = await _messagingService.promoteToAdmin(
      widget.chat.chatId,
      member.userId,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? '${member.displayName} is now an admin'
              : 'Failed to promote member'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _demoteMember(ChatMemberInfo member) async {
    final success = await _messagingService.demoteFromAdmin(
      widget.chat.chatId,
      member.userId,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? '${member.displayName} is no longer an admin'
              : 'Failed to demote member'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _removeMember(ChatMemberInfo member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.brown[800],
        title: const Text('Remove Member', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to remove ${member.displayName} from this chat?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await _messagingService.removeMemberFromChat(
      widget.chat.chatId,
      member.userId,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? '${member.displayName} has been removed'
              : 'Failed to remove member'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _showAddMemberDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.brown[900],
      isScrollControlled: true,
      builder: (context) => _AddMemberBottomSheet(
        chatId: widget.chat.chatId,
        existingMemberIds: widget.chat.participantIds,
        messagingService: _messagingService,
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

/// Bottom sheet for adding members to a group chat
class _AddMemberBottomSheet extends StatefulWidget {
  final String chatId;
  final List<String> existingMemberIds;
  final MessagingService messagingService;

  const _AddMemberBottomSheet({
    required this.chatId,
    required this.existingMemberIds,
    required this.messagingService,
  });

  @override
  State<_AddMemberBottomSheet> createState() => _AddMemberBottomSheetState();
}

class _AddMemberBottomSheetState extends State<_AddMemberBottomSheet> {
  final SocialService _socialService = SocialService();
  List<dynamic> _friends = [];
  bool _isLoading = true;
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    try {
      final friends = await _socialService.getUserFriends();
      // Filter out existing members
      final availableFriends = friends
          .where((f) => !widget.existingMemberIds.contains(f.userId))
          .toList();

      if (mounted) {
        setState(() {
          _friends = availableFriends;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addMember(dynamic friend) async {
    setState(() {
      _isAdding = true;
    });

    final success = await widget.messagingService.addMemberToChat(
      widget.chatId,
      friend.userId,
      friend.displayName,
    );

    if (mounted) {
      setState(() {
        _isAdding = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${friend.displayName} added to chat'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add ${friend.displayName}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Add Members',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Select a friend to add to this chat',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const Divider(color: Colors.white24),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.orange),
                  )
                : _friends.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_off, size: 64, color: Colors.white.withOpacity(0.3)),
                            const SizedBox(height: 16),
                            const Text(
                              'No friends to add',
                              style: TextStyle(color: Colors.white70, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'All your friends are already in this chat',
                              style: TextStyle(color: Colors.white54, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _friends.length,
                        itemBuilder: (context, index) {
                          final friend = _friends[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.orange[300],
                              backgroundImage: friend.profileImageUrl != null
                                  ? NetworkImage(friend.profileImageUrl!)
                                  : null,
                              child: friend.profileImageUrl == null
                                  ? Text(
                                      friend.displayName.isNotEmpty
                                          ? friend.displayName[0].toUpperCase()
                                          : '?',
                                      style: TextStyle(color: Colors.brown[800]),
                                    )
                                  : null,
                            ),
                            title: Text(
                              friend.displayName,
                              style: const TextStyle(color: Colors.white),
                            ),
                            trailing: _isAdding
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.orange,
                                    ),
                                  )
                                : IconButton(
                                    icon: const Icon(Icons.add_circle, color: Colors.orange),
                                    onPressed: () => _addMember(friend),
                                  ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
} 
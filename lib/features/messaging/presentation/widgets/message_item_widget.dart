import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/chat.dart';

class MessageItemWidget extends StatelessWidget {
  final Message message;
  final Chat chat;
  final bool showSenderInfo;
  final bool isFirstMessage;
  final bool isLastMessage;
  final Function(String) onReply;
  final Function(String, String) onReaction;

  const MessageItemWidget({
    super.key,
    required this.message,
    required this.chat,
    required this.showSenderInfo,
    required this.isFirstMessage,
    required this.isLastMessage,
    required this.onReply,
    required this.onReaction,
  });

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isOwnMessage = currentUser?.uid == message.senderId;

    return Container(
      margin: EdgeInsets.only(
        bottom: isLastMessage ? 8 : 4,
        top: isFirstMessage ? 8 : 4,
      ),
      child: Row(
        mainAxisAlignment: isOwnMessage 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isOwnMessage && showSenderInfo) ...[
            _buildAvatar(),
            const SizedBox(width: 8),
          ] else if (!isOwnMessage && !showSenderInfo) ...[
            const SizedBox(width: 40), // Space for avatar alignment
          ],
          
          Flexible(
            child: GestureDetector(
              onLongPress: () => _showMessageOptions(context),
              child: Column(
                crossAxisAlignment: isOwnMessage 
                    ? CrossAxisAlignment.end 
                    : CrossAxisAlignment.start,
                children: [
                  // Sender name (for group chats)
                  if (!isOwnMessage && showSenderInfo && chat.type != ChatType.direct) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 12, bottom: 4),
                      child: Text(
                        message.senderName,
                        style: TextStyle(
                          color: _getSenderColor(),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  
                  // Reply preview
                  if (message.replyToMessageId != null) ...[
                    _buildReplyPreview(isOwnMessage),
                    const SizedBox(height: 4),
                  ],
                  
                  // Message bubble
                  _buildMessageBubble(isOwnMessage),
                  
                  // Reactions
                  if (message.reactions.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    _buildReactions(isOwnMessage),
                  ],
                  
                  // Timestamp and status
                  const SizedBox(height: 4),
                  _buildMessageInfo(isOwnMessage),
                ],
              ),
            ),
          ),
          
          if (isOwnMessage) ...[
            const SizedBox(width: 8),
            _buildAvatar(),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    if (!showSenderInfo) return const SizedBox.shrink();
    
    return CircleAvatar(
      radius: 16,
      backgroundColor: Colors.orange[300],
      backgroundImage: message.senderImageUrl != null
          ? NetworkImage(message.senderImageUrl!)
          : null,
      child: message.senderImageUrl == null
          ? Icon(
              Icons.person,
              size: 16,
              color: Colors.brown[800],
            )
          : null,
    );
  }

  Widget _buildMessageBubble(bool isOwnMessage) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isOwnMessage 
            ? Colors.orange[300]
            : Colors.brown[800]?.withValues(alpha:0.8),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isOwnMessage ? 18 : 4),
          bottomRight: Radius.circular(isOwnMessage ? 4 : 18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMessageContent(isOwnMessage),
          
          if (message.updatedAt != null) ...[
            const SizedBox(height: 4),
            Text(
              '(edited)',
              style: TextStyle(
                color: isOwnMessage 
                    ? Colors.grey[400]
                    : Colors.white.withValues(alpha:0.5),
                fontSize: 10,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageContent(bool isOwnMessage) {
    switch (message.type) {
      case MessageType.text:
        return Text(
          message.content,
          style: TextStyle(
            color: isOwnMessage ? Colors.brown[800] : Colors.white,
            fontSize: 16,
          ),
        );
      
      case MessageType.image:
        return Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                message.content,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error),
                ),
              ),
            ),
            if (message.metadata['caption'] != null) ...[
              const SizedBox(height: 8),
              Text(
                message.metadata['caption'],
                style: TextStyle(
                  color: isOwnMessage ? Colors.brown[800] : Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        );
      
      case MessageType.location:
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.location_on,
                color: isOwnMessage ? Colors.brown[800] : Colors.white,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Location shared',
                  style: TextStyle(
                    color: isOwnMessage ? Colors.brown[800] : Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        );
      
      case MessageType.system:
        return Text(
          message.content,
          style: TextStyle(
            color: Colors.white.withValues(alpha:0.7),
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        );
      
      default:
        return Text(
          message.content,
          style: TextStyle(
            color: isOwnMessage ? Colors.brown[800] : Colors.white,
            fontSize: 16,
          ),
        );
    }
  }

  Widget _buildReplyPreview(bool isOwnMessage) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: Colors.orange[300]!,
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Replying to message',
            style: TextStyle(
              color: isOwnMessage 
                  ? Colors.brown[800]?.withValues(alpha:0.7)
                  : Colors.white.withValues(alpha:0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Original message...', // In real app, fetch the original message
            style: TextStyle(
              color: isOwnMessage 
                  ? Colors.brown[800]?.withValues(alpha:0.8)
                  : Colors.white.withValues(alpha:0.8),
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildReactions(bool isOwnMessage) {
    return Wrap(
      children: message.reactions.map((reaction) {
        return Container(
          margin: const EdgeInsets.only(right: 4, bottom: 2),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.brown[700]?.withValues(alpha:0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                reaction.emoji,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 4),
              Text(
                '1', // In real app, count users who reacted with same emoji
                style: TextStyle(
                  color: Colors.white.withValues(alpha:0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMessageInfo(bool isOwnMessage) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatTime(message.createdAt),
          style: TextStyle(
            fontSize: 10,
            color: isOwnMessage
                ? Colors.brown[600]
                : Colors.white.withValues(alpha:0.7),
          ),
        ),

        if (isOwnMessage) ...[
          const SizedBox(width: 4),
          _buildMessageStatus(),
        ],
      ],
    );
  }

  Widget _buildMessageStatus() {
    // Check if message has been read by anyone (besides sender)
    final readByOthers = message.readBy.where((id) => id != message.senderId).toList();
    final hasBeenRead = readByOthers.isNotEmpty;

    // For group chats, show read count
    if (chat.type != ChatType.direct && hasBeenRead) {
      return _buildGroupReadReceipt(readByOthers.length);
    }

    // For direct chats or unread messages, show status icon
    if (hasBeenRead || message.status == MessageStatus.read) {
      return Icon(
        Icons.done_all,
        size: 14,
        color: Colors.orange[300],
      );
    }

    switch (message.status) {
      case MessageStatus.sending:
        return Icon(
          Icons.access_time,
          size: 12,
          color: Colors.white.withValues(alpha:0.6),
        );
      case MessageStatus.sent:
        return Icon(
          Icons.check,
          size: 12,
          color: Colors.white.withValues(alpha:0.6),
        );
      case MessageStatus.delivered:
        return Icon(
          Icons.done_all,
          size: 12,
          color: Colors.white.withValues(alpha:0.6),
        );
      case MessageStatus.read:
        return Icon(
          Icons.done_all,
          size: 14,
          color: Colors.orange[300],
        );
      case MessageStatus.failed:
        return const Icon(
          Icons.error_outline,
          size: 12,
          color: Colors.red,
        );
    }
  }

  /// Build read receipt indicator for group chats showing how many people read the message
  Widget _buildGroupReadReceipt(int readCount) {
    final totalRecipients = chat.participantIds.length - 1; // Exclude sender

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.done_all,
          size: 14,
          color: Colors.orange[300],
        ),
        const SizedBox(width: 2),
        Text(
          readCount >= totalRecipients ? 'All' : '$readCount',
          style: TextStyle(
            fontSize: 9,
            color: Colors.orange[300],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _getSenderColor() {
    // Generate a consistent color for each sender
    final colors = [
      Colors.blue[300]!,
      Colors.green[300]!,
      Colors.purple[300]!,
      Colors.orange[300]!,
      Colors.pink[300]!,
      Colors.teal[300]!,
    ];
    
    final index = message.senderId.hashCode % colors.length;
    return colors[index];
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  void _showMessageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.brown[900],
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.reply, color: Colors.orange[300]),
              title: const Text('Reply', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                onReply(message.messageId);
              },
            ),
            ListTile(
              leading: Icon(Icons.add_reaction, color: Colors.orange[300]),
              title: const Text('React', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showReactionPicker(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.copy, color: Colors.orange[300]),
              title: const Text('Copy', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Clipboard.setData(ClipboardData(text: message.content));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Message copied to clipboard'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showReactionPicker(BuildContext context) {
    final reactions = ['👍', '❤️', '😂', '😮', '😢', '😡'];
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.brown[900],
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'React to message',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: reactions.map((emoji) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    onReaction(message.messageId, emoji);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.brown[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
} 
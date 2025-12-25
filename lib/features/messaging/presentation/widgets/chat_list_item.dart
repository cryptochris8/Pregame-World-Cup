import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/chat.dart';

class ChatListItem extends StatelessWidget {
  final Chat chat;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const ChatListItem({
    super.key,
    required this.chat,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final unreadCount = currentUser != null ? chat.getUnreadCount(currentUser.uid) : 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.brown[800]?.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.orange[300]?.withOpacity(0.2) ?? Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Profile Picture/Avatar
                _buildAvatar(),
                const SizedBox(width: 12),
                
                // Chat Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _getChatDisplayName(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (chat.lastMessageTime != null) ...[
                            Text(
                              _formatTime(chat.lastMessageTime!),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              chat.lastMessage ?? 'No messages yet',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          
                          // Unread count badge
                          if (unreadCount > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                unreadCount > 99 ? '99+' : unreadCount.toString(),
                                style: TextStyle(
                                  color: Colors.brown[800],
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (chat.type == ChatType.direct && chat.participantIds.length == 2) {
      // For direct chats, show the other person's avatar
      return CircleAvatar(
        radius: 24,
        backgroundColor: Colors.orange[300],
        backgroundImage: chat.imageUrl != null ? NetworkImage(chat.imageUrl!) : null,
        child: chat.imageUrl == null
            ? Icon(
                Icons.person,
                color: Colors.brown[800],
                size: 24,
              )
            : null,
      );
    } else {
      // For group/team chats, show group icon or image
      return CircleAvatar(
        radius: 24,
        backgroundColor: Colors.orange[300],
        backgroundImage: chat.imageUrl != null ? NetworkImage(chat.imageUrl!) : null,
        child: chat.imageUrl == null
            ? Icon(
                chat.type == ChatType.team ? Icons.groups : Icons.group,
                color: Colors.brown[800],
                size: 24,
              )
            : null,
      );
    }
  }

  String _getChatDisplayName() {
    if (chat.name != null && chat.name!.isNotEmpty) {
      return chat.name!;
    }
    
    if (chat.type == ChatType.direct) {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId != null) {
        final otherParticipants = chat.participantIds
            .where((id) => id != currentUserId)
            .toList();
        
        if (otherParticipants.isNotEmpty) {
          // In a real app, you'd fetch the user's display name from a user service
          // For now, just return a placeholder
          return 'User ${otherParticipants.first.substring(0, 8)}';
        }
      }
      return 'Direct Chat';
    } else if (chat.type == ChatType.group) {
      return 'Group Chat';
    } else {
      return 'Team Chat';
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      // Today - show time
      final hour = dateTime.hour;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return _getDayName(dateTime.weekday);
    } else {
      return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
    }
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return '';
    }
  }
} 
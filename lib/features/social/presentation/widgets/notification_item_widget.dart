import 'package:flutter/material.dart';
import '../../domain/entities/notification.dart';

class NotificationItemWidget extends StatelessWidget {
  final SocialNotification notification;
  final VoidCallback onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final VoidCallback onDelete;

  const NotificationItemWidget({
    super.key,
    required this.notification,
    required this.onTap,
    this.onAccept,
    this.onDecline,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: notification.isRead ? 0.5 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: notification.isRead
            ? BorderSide.none
            : const BorderSide(
                color: Color(0xFF8B4513),
                width: 1,
              ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: notification.isRead ? Colors.white : const Color(0xFF8B4513).withValues(alpha:0.05),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    // User avatar
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: notification.fromUserImage != null
                          ? NetworkImage(notification.fromUserImage!)
                          : null,
                      backgroundColor: _getNotificationColor(),
                      child: notification.fromUserImage == null
                          ? Icon(
                              _getNotificationIcon(),
                              color: Colors.white,
                              size: 20,
                            )
                          : null,
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          
                          const SizedBox(height: 4),
                          
                          Text(
                            notification.message,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Unread indicator and menu
                    Column(
                      children: [
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF8C00),
                              shape: BoxShape.circle,
                            ),
                          ),
                        
                        const SizedBox(height: 8),
                        
                        PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.white70,
                            size: 18,
                          ),
                          onSelected: (value) {
                            if (value == 'delete') {
                              onDelete();
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Delete'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                
                // Action buttons for friend requests
                if (_hasFriendRequestActions()) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onAccept,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Accept'),
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onDecline,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white70,
                            side: const BorderSide(color: Colors.white30),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(Icons.close, size: 18),
                          label: const Text('Decline'),
                        ),
                      ),
                    ],
                  ),
                ],
                
                // Timestamp
                const SizedBox(height: 12),
                Text(
                  notification.timeAgo,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _hasFriendRequestActions() {
    return notification.type == NotificationType.friendRequest && 
           onAccept != null && 
           onDecline != null;
  }

  IconData _getNotificationIcon() {
    switch (notification.type) {
      case NotificationType.friendRequest:
        return Icons.person_add;
      case NotificationType.friendRequestAccepted:
        return Icons.people;
      case NotificationType.activityLike:
        return Icons.favorite;
      case NotificationType.activityComment:
        return Icons.comment;
      case NotificationType.venueRecommendation:
        return Icons.rate_review;
      case NotificationType.gameInvite:
        return Icons.sports_soccer;
      case NotificationType.newFollower:
        return Icons.person_add;
      case NotificationType.groupInvite:
        return Icons.group_add;
      case NotificationType.achievement:
        return Icons.emoji_events;
      case NotificationType.systemUpdate:
        return Icons.info;
      case NotificationType.watchPartyInvite:
        return Icons.celebration;
      case NotificationType.matchReminder:
        return Icons.alarm;
      case NotificationType.favoriteTeamMatch:
        return Icons.star;
    }
  }

  Color _getNotificationColor() {
    switch (notification.type) {
      case NotificationType.friendRequest:
        return Colors.blue;
      case NotificationType.friendRequestAccepted:
        return Colors.green;
      case NotificationType.activityLike:
        return Colors.red;
      case NotificationType.activityComment:
        return Colors.orange;
      case NotificationType.venueRecommendation:
        return Colors.purple;
      case NotificationType.gameInvite:
        return Colors.teal;
      case NotificationType.newFollower:
        return Colors.blue;
      case NotificationType.groupInvite:
        return Colors.indigo;
      case NotificationType.achievement:
        return Colors.amber;
      case NotificationType.systemUpdate:
        return Colors.grey;
      case NotificationType.watchPartyInvite:
        return Colors.deepOrange;
      case NotificationType.matchReminder:
        return Colors.green;
      case NotificationType.favoriteTeamMatch:
        return Colors.amber;
    }
  }
} 
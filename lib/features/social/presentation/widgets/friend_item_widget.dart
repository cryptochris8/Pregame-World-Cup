import 'package:flutter/material.dart';
import '../../domain/entities/user_profile.dart';

class FriendItemWidget extends StatelessWidget {
  final UserProfile friend;
  final VoidCallback onTap;
  final VoidCallback onMessage;
  final VoidCallback onRemove;
  final VoidCallback onBlock;

  const FriendItemWidget({
    super.key,
    required this.friend,
    required this.onTap,
    required this.onMessage,
    required this.onRemove,
    required this.onBlock,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar with online status
              Stack(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: friend.profileImageUrl != null
                        ? NetworkImage(friend.profileImageUrl!)
                        : null,
                    backgroundColor: const Color(0xFF8B4513),
                    child: friend.profileImageUrl == null
                        ? Text(
                            friend.displayName.isNotEmpty
                                ? friend.displayName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          )
                        : null,
                  ),
                  
                  // Online status indicator
                  if (friend.shouldShowOnlineStatus)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: friend.isOnline 
                              ? Colors.green 
                              : friend.isRecentlyActive 
                                  ? Colors.orange 
                                  : Colors.grey,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(width: 16),
              
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      friend.displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    
                    if (friend.bio != null && friend.bio!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        friend.bio!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    
                    // Online status text
                    if (friend.shouldShowOnlineStatus) ...[
                      const SizedBox(height: 4),
                      Text(
                        friend.lastSeenText,
                        style: TextStyle(
                          color: friend.isOnline 
                              ? Colors.green 
                              : Colors.grey[500],
                          fontSize: 12,
                          fontWeight: friend.isOnline ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ],
                    
                    if (friend.homeLocation != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              friend.homeLocation!,
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    
                    // Mutual teams or interests
                    if (friend.favoriteTeams.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        children: friend.favoriteTeams.take(3).map((team) => 
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              team,
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        ).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Action buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Message button
                  IconButton(
                    onPressed: onMessage,
                    icon: const Icon(Icons.message),
                    color: const Color(0xFF8B4513),
                    tooltip: 'Message',
                  ),
                  
                  // More options menu
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: Colors.grey[600],
                    ),
                    onSelected: (value) {
                      switch (value) {
                        case 'remove':
                          onRemove();
                          break;
                        case 'block':
                          onBlock();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'remove',
                        child: Row(
                          children: [
                            Icon(Icons.person_remove, color: Colors.orange),
                            SizedBox(width: 8),
                            Text('Remove Friend'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'block',
                        child: Row(
                          children: [
                            Icon(Icons.block, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Block User'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
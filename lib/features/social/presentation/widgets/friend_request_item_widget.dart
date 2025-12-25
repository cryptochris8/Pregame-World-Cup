import 'package:flutter/material.dart';
import '../../domain/entities/social_connection.dart';

class FriendRequestItemWidget extends StatelessWidget {
  final SocialConnection request;
  final bool isOutgoing;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final VoidCallback? onCancel;
  final VoidCallback onViewProfile;

  const FriendRequestItemWidget({
    super.key,
    required this.request,
    this.isOutgoing = false,
    this.onAccept,
    this.onDecline,
    this.onCancel,
    required this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isOutgoing ? Colors.orange : Colors.blue,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF8B4513),
                  child: Text(
                    request.connectedUserName?.isNotEmpty == true
                        ? request.connectedUserName![0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: onViewProfile,
                        child: Text(
                          request.connectedUserName ?? 'Unknown User',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      
                      Text(
                        isOutgoing 
                            ? 'Friend request sent'
                            : 'Wants to be friends',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Status indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isOutgoing ? Colors.orange[100] : Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isOutgoing ? 'SENT' : 'PENDING',
                    style: TextStyle(
                      color: isOutgoing ? Colors.orange[800] : Colors.blue[800],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Timestamp
            Text(
              request.timeAgo,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
            
            // Action buttons
            if (!isOutgoing && (onAccept != null || onDecline != null)) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  if (onAccept != null)
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
                  
                  if (onAccept != null && onDecline != null)
                    const SizedBox(width: 12),
                  
                  if (onDecline != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onDecline,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                          side: BorderSide(color: Colors.grey[400]!),
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
            
            // Cancel button for outgoing requests
            if (isOutgoing && onCancel != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.cancel, size: 18),
                  label: const Text('Cancel Request'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 
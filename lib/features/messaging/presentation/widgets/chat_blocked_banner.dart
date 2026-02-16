import 'package:flutter/material.dart';
import '../../domain/services/messaging_chat_settings_service.dart';

/// Displays a banner at the bottom of the chat when the user is blocked
/// or has blocked the other user.
class ChatBlockedBanner extends StatelessWidget {
  final BlockStatus blockStatus;
  final VoidCallback onUnblock;

  const ChatBlockedBanner({
    super.key,
    required this.blockStatus,
    required this.onUnblock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[900]?.withValues(alpha: 0.8),
        border: Border(
          top: BorderSide(color: Colors.red[700]!, width: 1),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Icon(
              blockStatus.blockedByCurrentUser
                  ? Icons.block
                  : Icons.do_not_disturb,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                blockStatus.message ?? 'Unable to send messages',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
            if (blockStatus.blockedByCurrentUser)
              TextButton(
                onPressed: onUnblock,
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
}

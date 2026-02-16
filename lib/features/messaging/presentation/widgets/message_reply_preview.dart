import 'package:flutter/material.dart';

/// Preview bar shown when replying to a message
class MessageReplyPreview extends StatelessWidget {
  final VoidCallback? onCancelReply;

  const MessageReplyPreview({
    super.key,
    this.onCancelReply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha:0.3)),
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha:0.1),
            Colors.white.withValues(alpha:0.05),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEA580C), Color(0xFFFBBF24)],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Replying to',
                  style: TextStyle(
                    color: Color(0xFFFBBF24),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Original message content...', // In real app, fetch the original message
                  style: TextStyle(
                    color: Colors.white.withValues(alpha:0.9),
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onCancelReply,
            icon: Icon(
              Icons.close,
              color: Colors.white.withValues(alpha:0.7),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

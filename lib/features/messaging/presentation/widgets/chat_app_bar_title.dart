import 'package:flutter/material.dart';
import '../../domain/entities/chat.dart';

/// Displays the app bar title for a chat screen with avatar and member count.
class ChatAppBarTitle extends StatelessWidget {
  final Chat chat;
  final String displayName;

  const ChatAppBarTitle({
    super.key,
    required this.chat,
    required this.displayName,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.orange[300],
          backgroundImage:
              chat.imageUrl != null ? NetworkImage(chat.imageUrl!) : null,
          child: chat.imageUrl == null
              ? Icon(
                  chat.type == ChatType.direct
                      ? Icons.person
                      : chat.type == ChatType.team
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
                displayName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (chat.type != ChatType.direct) ...[
                Text(
                  '${chat.participantIds.length} members',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

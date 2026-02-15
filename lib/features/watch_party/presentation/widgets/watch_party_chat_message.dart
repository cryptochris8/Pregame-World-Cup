import 'package:flutter/material.dart';

import '../../domain/entities/watch_party_message.dart';
import '../../domain/entities/watch_party_member.dart';

/// Widget displaying a single chat message
class WatchPartyChatMessage extends StatelessWidget {
  final WatchPartyMessage message;
  final bool isCurrentUser;
  final VoidCallback? onLongPress;
  final VoidCallback? onReply;

  const WatchPartyChatMessage({
    super.key,
    required this.message,
    required this.isCurrentUser,
    this.onLongPress,
    this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    if (message.isSystem) {
      return _buildSystemMessage(context);
    }

    if (message.isDeleted) {
      return _buildDeletedMessage(context);
    }

    return _buildUserMessage(context);
  }

  Widget _buildSystemMessage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            message.content,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildDeletedMessage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Align(
        alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(
            'Message deleted',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserMessage(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        child: Row(
          mainAxisAlignment:
              isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isCurrentUser) ...[
              _buildAvatar(),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment: isCurrentUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  // Sender info
                  if (!isCurrentUser)
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            message.senderName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _getRoleColor(message.senderRole),
                            ),
                          ),
                          if (message.isFromHost || message.isFromCoHost) ...[
                            const SizedBox(width: 4),
                            _buildRoleBadge(),
                          ],
                        ],
                      ),
                    ),

                  // Message bubble
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isCurrentUser
                          ? const Color(0xFF1E3A8A)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft:
                            Radius.circular(isCurrentUser ? 16 : 4),
                        bottomRight:
                            Radius.circular(isCurrentUser ? 4 : 16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image/GIF if present
                        if (message.isImage && message.imageUrl != null)
                          _buildImage(message.imageUrl!),
                        if (message.isGif && message.gifUrl != null)
                          _buildGif(message.gifUrl!),

                        // Text content
                        if (message.content.isNotEmpty)
                          Text(
                            message.content,
                            style: TextStyle(
                              fontSize: 14,
                              color: isCurrentUser ? Colors.white : Colors.black87,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Reactions
                  if (message.hasReactions) _buildReactions(),

                  // Time
                  Padding(
                    padding: const EdgeInsets.only(top: 2, left: 4, right: 4),
                    child: Text(
                      message.formattedTime,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: _getRoleColor(message.senderRole),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: message.senderImageUrl != null
            ? Image.network(
                message.senderImageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildAvatarPlaceholder(),
              )
            : _buildAvatarPlaceholder(),
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      color: _getRoleColor(message.senderRole),
      child: Center(
        child: Text(
          message.senderName.isNotEmpty
              ? message.senderName[0].toUpperCase()
              : '?',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildRoleBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getRoleColor(message.senderRole).withValues(alpha:0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message.isFromHost ? 'Host' : 'Co-Host',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: _getRoleColor(message.senderRole),
        ),
      ),
    );
  }

  Widget _buildImage(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 200,
            height: 150,
            color: Colors.grey[300],
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
        errorBuilder: (_, __, ___) => Container(
          width: 200,
          height: 150,
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image),
        ),
      ),
    );
  }

  Widget _buildGif(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 200,
          height: 150,
          color: Colors.grey[300],
          child: const Icon(Icons.gif),
        ),
      ),
    );
  }

  Widget _buildReactions() {
    final emojis = message.uniqueReactionEmojis;

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 4,
        children: emojis.map((emoji) {
          final count = message.getReactionCount(emoji);
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 12)),
                if (count > 1) ...[
                  const SizedBox(width: 2),
                  Text(
                    '$count',
                    style: const TextStyle(fontSize: 10),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getRoleColor(WatchPartyMemberRole role) {
    switch (role) {
      case WatchPartyMemberRole.host:
        return const Color(0xFF7C3AED);
      case WatchPartyMemberRole.coHost:
        return const Color(0xFF2563EB);
      case WatchPartyMemberRole.member:
        return const Color(0xFF6B7280);
    }
  }
}

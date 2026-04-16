import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../config/app_theme.dart';
import '../../domain/entities/watch_party_message.dart';
import '../../domain/entities/watch_party_member.dart';
import '../../../moderation/presentation/widgets/report_bottom_sheet.dart';
import '../../../moderation/domain/entities/report.dart';

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
            color: AppTheme.backgroundElevated,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            message.content,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
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
            color: AppTheme.backgroundCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.backgroundElevated),
          ),
          child: Text(
            'Message deleted',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textTertiary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ),
    );
  }

  void _showMessageOptionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onLongPress != null)
              ListTile(
                leading: const Icon(Icons.more_horiz),
                title: const Text('More Options'),
                onTap: () {
                  Navigator.pop(context);
                  onLongPress!();
                },
              ),
            if (!isCurrentUser)
              ListTile(
                leading: Icon(Icons.flag_outlined, color: Colors.red[400]),
                title: const Text('Report Message'),
                onTap: () {
                  Navigator.pop(context);
                  ReportBottomSheet.show(
                    context: context,
                    contentType: ReportableContentType.message,
                    contentId: message.messageId,
                    contentOwnerId: message.senderId,
                    contentOwnerDisplayName: message.senderName,
                    contentSnapshot: message.content,
                    title: 'Report Message',
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserMessage(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showMessageOptionsSheet(context),
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
                          : AppTheme.backgroundCard,
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
                              color: isCurrentUser ? Colors.white : AppTheme.textLight,
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
                        fontSize: 11,
                        color: AppTheme.textTertiary,
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
            ? CachedNetworkImage(
                imageUrl: message.senderImageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildAvatarPlaceholder(),
                errorWidget: (context, url, error) => _buildAvatarPlaceholder(),
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
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: _getRoleColor(message.senderRole),
        ),
      ),
    );
  }

  Widget _buildImage(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        width: 200,
        height: 150,
        placeholder: (context, url) => Container(
          width: 200,
          height: 150,
          color: AppTheme.backgroundElevated,
          child: const Center(
            child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryOrange)),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: 200,
          height: 150,
          color: AppTheme.backgroundElevated,
          child: const Icon(Icons.broken_image),
        ),
      ),
    );
  }

  Widget _buildGif(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        width: 200,
        height: 150,
        errorWidget: (context, url, error) => Container(
          width: 200,
          height: 150,
          color: AppTheme.backgroundElevated,
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
              color: AppTheme.backgroundElevated,
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
                    style: const TextStyle(fontSize: 11),
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

import 'package:flutter/material.dart';

import '../../domain/entities/watch_party_member.dart';
import 'member_avatar_row.dart';

/// List item widget for displaying a watch party member
class MemberListItem extends StatelessWidget {
  final WatchPartyMember member;
  final bool isCurrentUser;
  final bool canManage;
  final VoidCallback? onTap;
  final VoidCallback? onMute;
  final VoidCallback? onRemove;
  final VoidCallback? onPromote;
  final VoidCallback? onDemote;

  const MemberListItem({
    super.key,
    required this.member,
    this.isCurrentUser = false,
    this.canManage = false,
    this.onTap,
    this.onMute,
    this.onRemove,
    this.onPromote,
    this.onDemote,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: MemberAvatar(
        member: member,
        size: 44,
        showRoleBadge: true,
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              member.displayName,
              style: TextStyle(
                fontWeight: member.isHost ? FontWeight.bold : FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isCurrentUser) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'You',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: Row(
        children: [
          _buildRoleBadge(),
          const SizedBox(width: 8),
          _buildAttendanceIndicator(),
          if (member.isMuted) ...[
            const SizedBox(width: 8),
            Icon(
              Icons.mic_off,
              size: 14,
              color: Colors.red[400],
            ),
          ],
        ],
      ),
      trailing: canManage && !member.isHost && !isCurrentUser
          ? PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  case 'mute':
                    onMute?.call();
                    break;
                  case 'unmute':
                    onMute?.call();
                    break;
                  case 'remove':
                    onRemove?.call();
                    break;
                  case 'promote':
                    onPromote?.call();
                    break;
                  case 'demote':
                    onDemote?.call();
                    break;
                }
              },
              itemBuilder: (context) => [
                if (member.isMuted)
                  const PopupMenuItem(
                    value: 'unmute',
                    child: Row(
                      children: [
                        Icon(Icons.mic, size: 20),
                        SizedBox(width: 8),
                        Text('Unmute'),
                      ],
                    ),
                  )
                else
                  const PopupMenuItem(
                    value: 'mute',
                    child: Row(
                      children: [
                        Icon(Icons.mic_off, size: 20),
                        SizedBox(width: 8),
                        Text('Mute'),
                      ],
                    ),
                  ),
                if (member.isMember && !member.isCoHost)
                  const PopupMenuItem(
                    value: 'promote',
                    child: Row(
                      children: [
                        Icon(Icons.arrow_upward, size: 20),
                        SizedBox(width: 8),
                        Text('Promote to Co-Host'),
                      ],
                    ),
                  ),
                if (member.isCoHost)
                  const PopupMenuItem(
                    value: 'demote',
                    child: Row(
                      children: [
                        Icon(Icons.arrow_downward, size: 20),
                        SizedBox(width: 8),
                        Text('Demote to Member'),
                      ],
                    ),
                  ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'remove',
                  child: Row(
                    children: [
                      Icon(Icons.person_remove, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text(
                        'Remove',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildRoleBadge() {
    Color color;
    String label;

    switch (member.role) {
      case WatchPartyMemberRole.host:
        color = const Color(0xFF7C3AED);
        label = 'Host';
        break;
      case WatchPartyMemberRole.coHost:
        color = const Color(0xFF2563EB);
        label = 'Co-Host';
        break;
      case WatchPartyMemberRole.member:
        color = Colors.grey;
        label = 'Member';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildAttendanceIndicator() {
    final isVirtual = member.isVirtual;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isVirtual
            ? const Color(0xFF059669).withValues(alpha:0.1)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVirtual ? Icons.videocam : Icons.person,
            size: 10,
            color: isVirtual ? const Color(0xFF059669) : Colors.grey[600],
          ),
          const SizedBox(width: 2),
          Text(
            isVirtual ? 'Virtual' : 'In Person',
            style: TextStyle(
              fontSize: 10,
              color: isVirtual ? const Color(0xFF059669) : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

/// Section header for member list
class MemberListSection extends StatelessWidget {
  final String title;
  final int count;
  final IconData? icon;

  const MemberListSection({
    super.key,
    required this.title,
    required this.count,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: Colors.grey[600]),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

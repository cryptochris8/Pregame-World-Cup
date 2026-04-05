import 'package:flutter/material.dart';

import '../../../../config/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
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
                color: AppTheme.backgroundElevated,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                AppLocalizations.of(context).memberYou,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: Row(
        children: [
          _buildRoleBadge(context),
          const SizedBox(width: 8),
          _buildAttendanceIndicator(context),
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
              itemBuilder: (context) {
                final l10n = AppLocalizations.of(context);
                return [
                  if (member.isMuted)
                    PopupMenuItem(
                      value: 'unmute',
                      child: Row(
                        children: [
                          const Icon(Icons.mic, size: 20),
                          const SizedBox(width: 8),
                          Text(l10n.memberUnmute),
                        ],
                      ),
                    )
                  else
                    PopupMenuItem(
                      value: 'mute',
                      child: Row(
                        children: [
                          const Icon(Icons.mic_off, size: 20),
                          const SizedBox(width: 8),
                          Text(l10n.adminMute),
                        ],
                      ),
                    ),
                  if (member.isMember && !member.isCoHost)
                    PopupMenuItem(
                      value: 'promote',
                      child: Row(
                        children: [
                          const Icon(Icons.arrow_upward, size: 20),
                          const SizedBox(width: 8),
                          Text(l10n.memberPromoteCoHost),
                        ],
                      ),
                    ),
                  if (member.isCoHost)
                    PopupMenuItem(
                      value: 'demote',
                      child: Row(
                        children: [
                          const Icon(Icons.arrow_downward, size: 20),
                          const SizedBox(width: 8),
                          Text(l10n.memberDemoteToMember),
                        ],
                      ),
                    ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        const Icon(Icons.person_remove, size: 20, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(
                          l10n.memberRemove,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ];
              },
            )
          : null,
    );
  }

  Widget _buildRoleBadge(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Color color;
    String label;

    switch (member.role) {
      case WatchPartyMemberRole.host:
        color = const Color(0xFF7C3AED);
        label = l10n.watchPartyRoleHost;
        break;
      case WatchPartyMemberRole.coHost:
        color = const Color(0xFF2563EB);
        label = l10n.watchPartyRoleCoHost;
        break;
      case WatchPartyMemberRole.member:
        color = Colors.grey;
        label = l10n.watchPartyRoleMember;
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
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildAttendanceIndicator(BuildContext context) {
    final isVirtual = member.isVirtual;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isVirtual
            ? const Color(0xFF059669).withValues(alpha:0.1)
            : AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVirtual ? Icons.videocam : Icons.person,
            size: 10,
            color: isVirtual ? const Color(0xFF059669) : AppTheme.textTertiary,
          ),
          const SizedBox(width: 2),
          Text(
            isVirtual ? l10n.memberVirtual : l10n.memberInPerson,
            style: TextStyle(
              fontSize: 11,
              color: isVirtual ? const Color(0xFF059669) : AppTheme.textTertiary,
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
            Icon(icon, size: 18, color: AppTheme.textTertiary),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.backgroundElevated,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

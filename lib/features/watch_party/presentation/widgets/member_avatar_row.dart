import 'package:flutter/material.dart';

import '../../domain/entities/watch_party_member.dart';

/// Row of member avatars with overflow indicator
class MemberAvatarRow extends StatelessWidget {
  final List<WatchPartyMember> members;
  final int maxDisplay;
  final double avatarSize;
  final double overlap;
  final VoidCallback? onTap;

  const MemberAvatarRow({
    Key? key,
    required this.members,
    this.maxDisplay = 5,
    this.avatarSize = 32,
    this.overlap = 8,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final displayMembers = members.take(maxDisplay).toList();
    final overflowCount = members.length - maxDisplay;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: avatarSize,
        child: Stack(
          children: [
            for (int i = 0; i < displayMembers.length; i++)
              Positioned(
                left: i * (avatarSize - overlap),
                child: _MemberAvatar(
                  member: displayMembers[i],
                  size: avatarSize,
                ),
              ),
            if (overflowCount > 0)
              Positioned(
                left: displayMembers.length * (avatarSize - overlap),
                child: _OverflowIndicator(
                  count: overflowCount,
                  size: avatarSize,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MemberAvatar extends StatelessWidget {
  final WatchPartyMember member;
  final double size;

  const _MemberAvatar({
    required this.member,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
          ),
        ],
      ),
      child: ClipOval(
        child: member.profileImageUrl != null
            ? Image.network(
                member.profileImageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholder(),
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: _getRoleColor(),
      child: Center(
        child: Text(
          member.displayName.isNotEmpty
              ? member.displayName[0].toUpperCase()
              : '?',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.4,
          ),
        ),
      ),
    );
  }

  Color _getRoleColor() {
    switch (member.role) {
      case WatchPartyMemberRole.host:
        return const Color(0xFF7C3AED); // purple
      case WatchPartyMemberRole.coHost:
        return const Color(0xFF2563EB); // blue
      case WatchPartyMemberRole.member:
        return const Color(0xFF6B7280); // gray
    }
  }
}

class _OverflowIndicator extends StatelessWidget {
  final int count;
  final double size;

  const _OverflowIndicator({
    required this.count,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[300],
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          '+$count',
          style: TextStyle(
            color: Colors.grey[700],
            fontWeight: FontWeight.bold,
            fontSize: size * 0.35,
          ),
        ),
      ),
    );
  }
}

/// Single member avatar with optional badge
class MemberAvatar extends StatelessWidget {
  final WatchPartyMember member;
  final double size;
  final bool showRoleBadge;
  final bool showOnlineStatus;
  final bool isOnline;

  const MemberAvatar({
    Key? key,
    required this.member,
    this.size = 40,
    this.showRoleBadge = false,
    this.showOnlineStatus = false,
    this.isOnline = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: _getBorderColor(),
              width: 2,
            ),
          ),
          child: ClipOval(
            child: member.profileImageUrl != null
                ? Image.network(
                    member.profileImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholder(),
                  )
                : _buildPlaceholder(),
          ),
        ),
        if (showRoleBadge && (member.isHost || member.isCoHost))
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: member.isHost ? const Color(0xFF7C3AED) : const Color(0xFF2563EB),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: Icon(
                member.isHost ? Icons.star : Icons.person,
                size: size * 0.25,
                color: Colors.white,
              ),
            ),
          ),
        if (showOnlineStatus)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: size * 0.3,
              height: size * 0.3,
              decoration: BoxDecoration(
                color: isOnline ? Colors.green : Colors.grey,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: _getRoleColor(),
      child: Center(
        child: Text(
          member.displayName.isNotEmpty
              ? member.displayName[0].toUpperCase()
              : '?',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.4,
          ),
        ),
      ),
    );
  }

  Color _getRoleColor() {
    switch (member.role) {
      case WatchPartyMemberRole.host:
        return const Color(0xFF7C3AED);
      case WatchPartyMemberRole.coHost:
        return const Color(0xFF2563EB);
      case WatchPartyMemberRole.member:
        return const Color(0xFF6B7280);
    }
  }

  Color _getBorderColor() {
    if (member.isVirtual) {
      return const Color(0xFF059669); // green for virtual
    }
    return Colors.white;
  }
}

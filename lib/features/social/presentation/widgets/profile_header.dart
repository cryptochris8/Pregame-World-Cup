import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/user_profile.dart';

class ProfileHeader extends StatelessWidget {
  final UserProfile profile;
  final bool isCurrentUser;
  final String? connectionStatus;
  final VoidCallback? onEditPressed;
  final VoidCallback? onConnectPressed;
  final VoidCallback? onMessagePressed;

  const ProfileHeader({
    super.key,
    required this.profile,
    required this.isCurrentUser,
    this.connectionStatus,
    this.onEditPressed,
    this.onConnectPressed,
    this.onMessagePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar and basic info
          Row(
            children: [
              // Profile Avatar with online status indicator
              Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF8B4513),
                        width: 3,
                      ),
                    ),
                    child: ClipOval(
                      child: profile.profileImageUrl != null
                          ? Image.network(
                              profile.profileImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildDefaultAvatar(),
                            )
                          : _buildDefaultAvatar(),
                    ),
                  ),
                  // Online status indicator
                  if (!isCurrentUser && profile.shouldShowOnlineStatus)
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: profile.isOnline
                              ? Colors.green
                              : profile.isRecentlyActive
                                  ? Colors.orange
                                  : Colors.grey,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(width: 16),
              
              // Name and level info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.displayName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D1810),
                      ),
                    ),

                    // Online status text (for other users only)
                    if (!isCurrentUser && profile.shouldShowOnlineStatus) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: profile.isOnline
                                  ? Colors.green
                                  : profile.isRecentlyActive
                                      ? Colors.orange
                                      : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            profile.lastSeenText,
                            style: TextStyle(
                              fontSize: 13,
                              color: profile.isOnline
                                  ? Colors.green[700]
                                  : Colors.grey[600],
                              fontWeight: profile.isOnline
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 4),

                    // Level badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF8B4513),
                            Colors.orange[600]!,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            profile.levelTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    if (profile.homeLocation != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.grey[600],
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              profile.homeLocation!,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          
          // Bio section
          if (profile.bio != null && profile.bio!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                profile.bio!,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF2D1810),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          
          const SizedBox(height: 20),
          
          // Action buttons
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF8B4513),
            Colors.orange[600]!,
          ],
        ),
      ),
      child: Center(
        child: Text(
          profile.displayName.isNotEmpty 
              ? profile.displayName[0].toUpperCase()
              : '?',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (isCurrentUser) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            HapticFeedback.lightImpact();
            onEditPressed?.call();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B4513),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: const Icon(Icons.edit),
          label: const Text(
            'Edit Profile',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    } else {
      return Row(
        children: [
          // Connect/Friend button
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                onConnectPressed?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _getConnectionButtonColor(),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: Icon(_getConnectionButtonIcon()),
              label: Text(
                _getConnectionButtonText(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Message button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                onMessagePressed?.call();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF8B4513),
                side: const BorderSide(color: Color(0xFF8B4513)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.message, size: 18),
              label: const Text(
                'Message',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  Color _getConnectionButtonColor() {
    switch (connectionStatus) {
      case 'friends':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'following':
        return Colors.blue;
      default:
        return const Color(0xFF8B4513);
    }
  }

  IconData _getConnectionButtonIcon() {
    switch (connectionStatus) {
      case 'friends':
        return Icons.people;
      case 'pending':
        return Icons.schedule;
      case 'following':
        return Icons.person_add_disabled;
      default:
        return Icons.person_add;
    }
  }

  String _getConnectionButtonText() {
    switch (connectionStatus) {
      case 'friends':
        return 'Friends';
      case 'pending':
        return 'Pending';
      case 'following':
        return 'Following';
      default:
        return 'Add Friend';
    }
  }
} 
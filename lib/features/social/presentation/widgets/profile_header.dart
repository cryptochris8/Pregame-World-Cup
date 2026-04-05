import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../config/app_theme.dart';
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
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.1),
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
                        color: AppTheme.primaryOrange,
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
                              ? AppTheme.successColor
                              : profile.isRecentlyActive
                                  ? AppTheme.primaryOrange
                                  : AppTheme.textTertiary,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.backgroundCard, width: 3),
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
                        color: AppTheme.textLight,
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
                                  ? AppTheme.successColor
                                  : profile.isRecentlyActive
                                      ? AppTheme.primaryOrange
                                      : AppTheme.textTertiary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            profile.lastSeenText,
                            style: TextStyle(
                              fontSize: 13,
                              color: profile.isOnline
                                  ? AppTheme.successColor
                                  : AppTheme.textTertiary,
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
                            AppTheme.primaryOrange,
                            AppTheme.primaryOrange.withValues(alpha: 0.8),
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
                          const Icon(
                            Icons.location_on,
                            color: AppTheme.textTertiary,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              profile.homeLocation!,
                              style: const TextStyle(
                                color: AppTheme.textTertiary,
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
                color: AppTheme.backgroundCard,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.backgroundElevated),
              ),
              child: Text(
                profile.bio!,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppTheme.textLight,
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
            AppTheme.primaryOrange,
            AppTheme.primaryOrange.withValues(alpha: 0.8),
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
            backgroundColor: AppTheme.primaryOrange,
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
                foregroundColor: AppTheme.primaryOrange,
                side: const BorderSide(color: AppTheme.primaryOrange),
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
        return AppTheme.successColor;
      case 'pending':
        return AppTheme.primaryOrange;
      case 'following':
        return Colors.blue;
      default:
        return AppTheme.primaryOrange;
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
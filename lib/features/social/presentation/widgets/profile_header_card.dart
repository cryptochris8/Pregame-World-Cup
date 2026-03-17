import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../config/app_theme.dart';
import '../../domain/entities/user_profile.dart';
import '../../../../l10n/app_localizations.dart';

/// A card widget displaying the user's profile header information.
///
/// Shows the user's avatar, display name, online status, email, and join date.
class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    super.key,
    required this.profile,
    required this.currentUser,
    required this.isCurrentUser,
  });

  final UserProfile? profile;
  final User? currentUser;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.accentGold.withOpacity(0.1),
            AppTheme.primaryBlue.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.accentGold.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.accentGold,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentGold.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppTheme.primaryBlue.withOpacity(0.2),
                  backgroundImage: profile?.profileImageUrl != null
                      ? NetworkImage(profile!.profileImageUrl!)
                      : null,
                  child: profile?.profileImageUrl == null
                      ? Icon(
                          Icons.person,
                          size: 50,
                          color: AppTheme.accentGold,
                        )
                      : null,
                ),
              ),
              if (profile?.isOnline ?? false)
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.scaffoldBackgroundColor,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Display Name
          Text(
            profile?.displayName ?? currentUser?.displayName ?? 'Anonymous',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.accentGold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Online Status
          if (profile?.isOnline ?? false)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.green,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Online',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),

          // Email
          if (isCurrentUser && currentUser?.email != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.email_outlined,
                  size: 16,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
                const SizedBox(width: 8),
                Text(
                  currentUser!.email!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),

          // Join Date
          if (profile?.createdAt != null) ...[
            if (isCurrentUser && currentUser?.email != null)
              const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
                const SizedBox(width: 8),
                Text(
                  'Joined ${_formatJoinDate(profile!.createdAt)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatJoinDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

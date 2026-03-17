import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';
import '../../domain/entities/user_profile.dart';
import '../../../../l10n/app_localizations.dart';

/// A widget displaying feature cards for the user profile.
///
/// Shows cards for accessibility settings, profile customization,
/// activity feed, and achievements.
class ProfileFeatureCards extends StatelessWidget {
  const ProfileFeatureCards({
    super.key,
    required this.isCurrentUser,
    required this.profile,
    this.onAccessibilityTap,
    this.onProfileCustomizeTap,
  });

  final bool isCurrentUser;
  final UserProfile? profile;
  final VoidCallback? onAccessibilityTap;
  final VoidCallback? onProfileCustomizeTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Accessibility Settings Card (Current user only)
        if (isCurrentUser)
          _buildActiveFeatureCard(
            context,
            Icons.accessibility_new,
            l10n.accessibilitySettings,
            l10n.accessibilityCustomizeDesc,
            AppTheme.primaryBlue,
            onAccessibilityTap,
          ),

        if (isCurrentUser) const SizedBox(height: 16),

        // Profile Customization Card (Current user only)
        if (isCurrentUser)
          _buildActiveFeatureCard(
            context,
            Icons.edit,
            l10n.editProfile,
            l10n.profileCustomizationDesc,
            AppTheme.accentGold,
            onProfileCustomizeTap,
          ),

        if (isCurrentUser) const SizedBox(height: 16),

        // Activity Feed Card
        _buildFeatureCard(
          context,
          Icons.timeline,
          l10n.activityFeed,
          l10n.activityFeedDesc,
          Colors.purple,
        ),
        const SizedBox(height: 16),

        // Achievements Card
        _buildFeatureCard(
          context,
          Icons.emoji_events,
          l10n.achievements,
          l10n.achievementsDesc,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFeatureCard(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    Color color,
    VoidCallback? onTap,
  ) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}

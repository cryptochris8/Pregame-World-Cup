import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';
import '../../domain/entities/user_profile.dart';
import '../../../../l10n/app_localizations.dart';

/// A widget displaying feature cards for the user profile.
///
/// Shows tappable cards for accessibility settings and profile customization.
/// Cards are only rendered when their corresponding tap handler is provided —
/// no decorative/dead tiles.
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
    if (!isCurrentUser) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        _buildActiveFeatureCard(
          context,
          Icons.accessibility_new,
          l10n.accessibilitySettings,
          l10n.accessibilityCustomizeDesc,
          AppTheme.primaryBlue,
          onAccessibilityTap,
        ),
        const SizedBox(height: 16),
        _buildActiveFeatureCard(
          context,
          Icons.edit,
          l10n.editProfile,
          l10n.profileCustomizationDesc,
          AppTheme.accentGold,
          onProfileCustomizeTap,
        ),
      ],
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
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
                color: color.withValues(alpha: 0.1),
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
                          theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

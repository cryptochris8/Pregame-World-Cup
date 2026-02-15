import 'package:flutter/material.dart';
import '../../domain/entities/subscription_tier.dart';

/// Widget that gates premium features behind a subscription check.
/// Shows the child widget if the user has premium, otherwise shows an upgrade prompt.
class PremiumFeatureGate extends StatelessWidget {
  final Widget child;
  final String featureName;
  final SubscriptionTier currentTier;
  final VoidCallback? onUpgradePressed;
  final Widget? lockedWidget;
  final bool showLockIcon;

  const PremiumFeatureGate({
    super.key,
    required this.child,
    required this.featureName,
    required this.currentTier,
    this.onUpgradePressed,
    this.lockedWidget,
    this.showLockIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    if (currentTier == SubscriptionTier.premium) {
      return child;
    }

    return lockedWidget ?? _buildDefaultLockedWidget(context);
  }

  Widget _buildDefaultLockedWidget(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha:0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha:0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLockIcon) ...[
            Icon(
              Icons.lock_outline,
              size: 32,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 8),
          ],
          Text(
            featureName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Upgrade to Premium to unlock this feature',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (onUpgradePressed != null) ...[
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onUpgradePressed,
              icon: const Icon(Icons.star, size: 18),
              label: const Text('Upgrade to Premium'),
            ),
          ],
        ],
      ),
    );
  }
}

/// A card variant of the premium gate for use in lists
class PremiumFeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final SubscriptionTier currentTier;
  final VoidCallback? onTap;
  final VoidCallback? onUpgradePressed;

  const PremiumFeatureCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.currentTier,
    this.onTap,
    this.onUpgradePressed,
  });

  bool get isPremium => currentTier == SubscriptionTier.premium;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isPremium ? onTap : onUpgradePressed,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isPremium
                          ? colorScheme.primaryContainer
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: isPremium
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
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
                            fontWeight: FontWeight.w600,
                            color: isPremium ? null : colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isPremium ? Icons.chevron_right : Icons.lock_outline,
                    color: isPremium
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.primary,
                  ),
                ],
              ),
            ),
            if (!isPremium)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'PREMIUM',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Banner that shows upgrade prompts at the top of screens
class PremiumUpgradeBanner extends StatelessWidget {
  final VoidCallback? onUpgradePressed;
  final VoidCallback? onDismiss;
  final String? customMessage;

  const PremiumUpgradeBanner({
    super.key,
    this.onUpgradePressed,
    this.onDismiss,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.tertiary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha:0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: colorScheme.onPrimary,
              ),
              const SizedBox(width: 8),
              Text(
                'Unlock Premium Features',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (onDismiss != null)
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: colorScheme.onPrimary.withValues(alpha:0.7),
                    size: 20,
                  ),
                  onPressed: onDismiss,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            customMessage ??
                'Get advanced features like specific match scheduling, TV setup, game day specials, and real-time capacity updates.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onPrimary.withValues(alpha:0.9),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: onUpgradePressed,
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.onPrimary,
              foregroundColor: colorScheme.primary,
            ),
            child: const Text('Upgrade Now'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../bloc/venue_enhancement_state.dart';

/// Card displaying the venue's current subscription status (Free or Premium)
class VenueSubscriptionCard extends StatelessWidget {
  final VenueEnhancementState state;
  final VoidCallback onUpgrade;

  const VenueSubscriptionCard({
    super.key,
    required this.state,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final isPremium = state.isPremium;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isPremium
                    ? Colors.amber.withValues(alpha: 0.2)
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isPremium ? Icons.star : Icons.store,
                color:
                    isPremium ? Colors.amber : colorScheme.onSurfaceVariant,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPremium ? l10n.premiumVenue : l10n.freePlan,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    isPremium
                        ? l10n.allFeaturesUnlocked
                        : l10n.basicFeaturesOnly,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (!isPremium)
              FilledButton.tonal(
                onPressed: onUpgrade,
                child: Text(l10n.upgradeButton),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../bloc/venue_enhancement_state.dart';

/// Row of stat cards showing TVs, Active Specials, and Scheduled matches
class VenueQuickStats extends StatelessWidget {
  final VenueEnhancementState state;

  const VenueQuickStats({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _VenueStatCard(
            icon: Icons.tv,
            value:
                state.isPremium ? '${state.tvSetup?.totalScreens ?? 0}' : '-',
            label: 'TVs',
            isLocked: !state.isPremium,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _VenueStatCard(
            icon: Icons.local_offer,
            value:
                state.isPremium ? '${state.activeSpecials.length}' : '-',
            label: 'Active Specials',
            isLocked: !state.isPremium,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _VenueStatCard(
            icon: Icons.calendar_month,
            value: state.isPremium
                ? '${state.broadcastingSchedule?.matchIds.length ?? 0}'
                : '-',
            label: 'Scheduled',
            isLocked: !state.isPremium,
          ),
        ),
      ],
    );
  }
}

class _VenueStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool isLocked;

  const _VenueStatCard({
    required this.icon,
    required this.value,
    required this.label,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(
              icon,
              color: isLocked
                  ? colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
                  : colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isLocked
                    ? colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
                    : null,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

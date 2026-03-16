import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../bloc/venue_enhancement_cubit.dart';
import '../bloc/venue_enhancement_state.dart';

/// Toggle card for enabling/disabling match broadcasting at the venue
class ShowsMatchesToggle extends StatelessWidget {
  final VenueEnhancementState state;

  const ShowsMatchesToggle({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.sports_soccer,
              color: state.showsMatches
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.showWorldCupMatches,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    state.showsMatches
                        ? l10n.showsMatchesOnDesc
                        : l10n.showsMatchesOffDesc,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: state.showsMatches,
              onChanged: state.isSaving
                  ? null
                  : (value) {
                      context
                          .read<VenueEnhancementCubit>()
                          .updateShowsMatches(value);
                    },
            ),
          ],
        ),
      ),
    );
  }
}

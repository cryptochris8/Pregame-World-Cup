import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
                    'Show World Cup Matches',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    state.showsMatches
                        ? 'Your venue is listed as showing matches'
                        : 'Toggle on to appear in match venue searches',
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

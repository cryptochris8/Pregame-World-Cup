import 'package:flutter/material.dart';

import '../../../../config/app_theme.dart';
import '../../domain/entities/entities.dart';

/// Confederation filter chips
class ConfederationFilterChips extends StatelessWidget {
  final Confederation? selectedConfederation;
  final ValueChanged<Confederation?> onConfederationChanged;
  final Map<Confederation, int>? counts;

  const ConfederationFilterChips({
    super.key,
    this.selectedConfederation,
    required this.onConfederationChanged,
    this.counts,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          ChoiceChip(
            label: Text(
              'All',
              style: TextStyle(
                color: selectedConfederation == null ? Colors.white : Colors.white70,
              ),
            ),
            selected: selectedConfederation == null,
            onSelected: (_) => onConfederationChanged(null),
            backgroundColor: AppTheme.backgroundCard,
            selectedColor: AppTheme.secondaryEmerald.withValues(alpha: 0.3),
            side: BorderSide(
              color: selectedConfederation == null
                  ? AppTheme.secondaryEmerald
                  : Colors.white.withValues(alpha: 0.2),
            ),
          ),
          const SizedBox(width: 8),
          ...Confederation.values.map((conf) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    conf.name,
                    style: TextStyle(
                      color: selectedConfederation == conf ? Colors.white : Colors.white70,
                    ),
                  ),
                  if (counts != null && counts![conf] != null) ...[
                    const SizedBox(width: 4),
                    Text(
                      '(${counts![conf]})',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ],
              ),
              selected: selectedConfederation == conf,
              onSelected: (_) => onConfederationChanged(conf),
              backgroundColor: AppTheme.backgroundCard,
              selectedColor: AppTheme.primaryOrange.withValues(alpha: 0.3),
              side: BorderSide(
                color: selectedConfederation == conf
                    ? AppTheme.primaryOrange
                    : Colors.white.withValues(alpha: 0.2),
              ),
            ),
          )),
        ],
      ),
    );
  }
}

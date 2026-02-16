import 'package:flutter/material.dart';

import '../../../../config/app_theme.dart';

/// Group filter chips (A-L)
class GroupFilterChips extends StatelessWidget {
  final String? selectedGroup;
  final ValueChanged<String?> onGroupChanged;

  const GroupFilterChips({
    super.key,
    this.selectedGroup,
    required this.onGroupChanged,
  });

  @override
  Widget build(BuildContext context) {
    final groups = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          ChoiceChip(
            label: Text(
              'All Groups',
              style: TextStyle(
                color: selectedGroup == null ? Colors.white : Colors.white70,
              ),
            ),
            selected: selectedGroup == null,
            onSelected: (_) => onGroupChanged(null),
            backgroundColor: AppTheme.backgroundCard,
            selectedColor: AppTheme.secondaryEmerald.withValues(alpha: 0.3),
            side: BorderSide(
              color: selectedGroup == null
                  ? AppTheme.secondaryEmerald
                  : Colors.white.withValues(alpha: 0.2),
            ),
          ),
          const SizedBox(width: 8),
          ...groups.map((group) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                'Group $group',
                style: TextStyle(
                  color: selectedGroup == group ? Colors.white : Colors.white70,
                ),
              ),
              selected: selectedGroup == group,
              onSelected: (_) => onGroupChanged(group),
              backgroundColor: AppTheme.backgroundCard,
              selectedColor: AppTheme.primaryBlue.withValues(alpha: 0.3),
              side: BorderSide(
                color: selectedGroup == group
                    ? AppTheme.primaryBlue
                    : Colors.white.withValues(alpha: 0.2),
              ),
            ),
          )),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../config/app_theme.dart';
import '../bloc/bloc.dart';

/// Team sort options
class TeamSortChips extends StatelessWidget {
  final TeamsSortOption selectedOption;
  final ValueChanged<TeamsSortOption> onOptionChanged;

  const TeamSortChips({
    super.key,
    required this.selectedOption,
    required this.onOptionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: TeamsSortOption.values.map((option) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(
              _getOptionLabel(option),
              style: TextStyle(
                color: selectedOption == option ? Colors.white : Colors.white70,
              ),
            ),
            selected: selectedOption == option,
            onSelected: (_) => onOptionChanged(option),
            backgroundColor: AppTheme.backgroundCard,
            selectedColor: AppTheme.primaryPurple.withValues(alpha: 0.3),
            side: BorderSide(
              color: selectedOption == option
                  ? AppTheme.primaryPurple
                  : Colors.white.withValues(alpha: 0.2),
            ),
          ),
        )).toList(),
      ),
    );
  }

  String _getOptionLabel(TeamsSortOption option) {
    switch (option) {
      case TeamsSortOption.alphabetical:
        return 'A-Z';
      case TeamsSortOption.fifaRanking:
        return 'FIFA Ranking';
      case TeamsSortOption.confederation:
        return 'Confederation';
      case TeamsSortOption.group:
        return 'Group';
    }
  }
}

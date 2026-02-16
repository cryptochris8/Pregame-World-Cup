import 'package:flutter/material.dart';

import '../../../../config/app_theme.dart';
import '../../domain/entities/entities.dart';

/// Stage filter chips
class StageFilterChips extends StatelessWidget {
  final MatchStage? selectedStage;
  final ValueChanged<MatchStage?> onStageChanged;

  const StageFilterChips({
    super.key,
    this.selectedStage,
    required this.onStageChanged,
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
              'All Stages',
              style: TextStyle(
                color: selectedStage == null ? Colors.white : Colors.white70,
              ),
            ),
            selected: selectedStage == null,
            onSelected: (_) => onStageChanged(null),
            backgroundColor: AppTheme.backgroundCard,
            selectedColor: AppTheme.secondaryEmerald.withValues(alpha: 0.3),
            side: BorderSide(
              color: selectedStage == null
                  ? AppTheme.secondaryEmerald
                  : Colors.white.withValues(alpha: 0.2),
            ),
          ),
          const SizedBox(width: 8),
          ...MatchStage.values.map((stage) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                _getStageName(stage),
                style: TextStyle(
                  color: selectedStage == stage ? Colors.white : Colors.white70,
                ),
              ),
              selected: selectedStage == stage,
              onSelected: (_) => onStageChanged(stage),
              backgroundColor: AppTheme.backgroundCard,
              selectedColor: _getStageColor(stage).withValues(alpha: 0.3),
              side: BorderSide(
                color: selectedStage == stage
                    ? _getStageColor(stage)
                    : Colors.white.withValues(alpha: 0.2),
              ),
            ),
          )),
        ],
      ),
    );
  }

  String _getStageName(MatchStage stage) {
    switch (stage) {
      case MatchStage.groupStage:
        return 'Group Stage';
      case MatchStage.roundOf32:
        return 'Round of 32';
      case MatchStage.roundOf16:
        return 'Round of 16';
      case MatchStage.quarterFinal:
        return 'Quarter-Finals';
      case MatchStage.semiFinal:
        return 'Semi-Finals';
      case MatchStage.thirdPlace:
        return '3rd Place';
      case MatchStage.final_:
        return 'Final';
    }
  }

  Color _getStageColor(MatchStage stage) {
    switch (stage) {
      case MatchStage.groupStage:
        return AppTheme.primaryBlue;
      case MatchStage.roundOf32:
        return AppTheme.secondaryEmerald;
      case MatchStage.roundOf16:
        return const Color(0xFF22C55E);
      case MatchStage.quarterFinal:
        return AppTheme.primaryOrange;
      case MatchStage.semiFinal:
        return AppTheme.primaryPurple;
      case MatchStage.thirdPlace:
        return AppTheme.accentGold;
      case MatchStage.final_:
        return AppTheme.accentGold;
    }
  }
}

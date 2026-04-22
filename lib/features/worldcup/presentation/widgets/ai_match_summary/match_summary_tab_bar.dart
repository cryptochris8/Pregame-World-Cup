import 'package:flutter/material.dart';
import '../../../../../config/app_theme.dart';
import '../../../../../core/config/feature_flags.dart';

/// Tab bar for switching between match summary tabs.
/// When a narrative exists, adds a "Pregame" tab as the first tab.
/// The "Prediction" tab is hidden when predictions are disabled at the
/// app level (non-gambling build).
class MatchSummaryTabBar extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onTabSelected;
  final bool hasNarrative;

  const MatchSummaryTabBar({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
    this.hasNarrative = false,
  });

  List<String> get _tabs {
    final includePrediction = FeatureFlags.predictionsEnabled;
    if (hasNarrative) {
      return includePrediction
          ? const ['Pregame', 'Analysis', 'Players', 'Prediction']
          : const ['Pregame', 'Analysis', 'Players'];
    }
    return includePrediction
        ? const ['Analysis', 'Players', 'Prediction']
        : const ['Analysis', 'Players'];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: _tabs.asMap().entries.map((entry) {
          final isSelected = selectedTab == entry.key;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabSelected(entry.key),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected
                          ? AppTheme.primaryPurple
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  entry.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white54,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

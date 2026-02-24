import 'package:flutter/material.dart';
import '../../../../../config/app_theme.dart';

/// Tab bar for switching between Analysis, Players, and Prediction tabs.
class MatchSummaryTabBar extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onTabSelected;

  const MatchSummaryTabBar({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  static const _tabs = ['Analysis', 'Players', 'Prediction'];

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

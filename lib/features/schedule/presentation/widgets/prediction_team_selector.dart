import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../config/theme_helper.dart';

/// Widget for selecting which team will win a game prediction
class PredictionTeamSelector extends StatelessWidget {
  final String homeTeamName;
  final String awayTeamName;
  final String? selectedWinner;
  final ValueChanged<String> onWinnerSelected;

  const PredictionTeamSelector({
    super.key,
    required this.homeTeamName,
    required this.awayTeamName,
    this.selectedWinner,
    required this.onWinnerSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.sports_soccer,
                color: ThemeHelper.favoriteColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Who will win?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTeamOption(homeTeamName, true),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTeamOption(awayTeamName, false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamOption(String teamName, bool isHome) {
    final isSelected = selectedWinner == teamName;

    return GestureDetector(
      onTap: () {
        onWinnerSelected(teamName);
        HapticFeedback.selectionClick();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? ThemeHelper.favoriteColor.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? ThemeHelper.favoriteColor
                : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              isHome ? 'HOME' : 'AWAY',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              teamName,
              style: TextStyle(
                color: isSelected ? ThemeHelper.favoriteColor : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (isSelected) ...[
              const SizedBox(height: 8),
              Icon(
                Icons.check_circle,
                color: ThemeHelper.favoriteColor,
                size: 18,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

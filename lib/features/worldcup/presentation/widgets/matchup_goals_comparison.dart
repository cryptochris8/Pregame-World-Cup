import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';

/// Displays a goals comparison bar between two teams.
class MatchupGoalsComparison extends StatelessWidget {
  final int team1Goals;
  final int team2Goals;

  const MatchupGoalsComparison({
    super.key,
    required this.team1Goals,
    required this.team2Goals,
  });

  @override
  Widget build(BuildContext context) {
    final totalGoals = team1Goals + team2Goals;
    if (totalGoals == 0) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Goals',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              team1Goals.toString(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                ),
                clipBehavior: Clip.antiAlias,
                child: Row(
                  children: [
                    Expanded(
                      flex: team1Goals > 0 ? team1Goals : 1,
                      child: Container(color: AppTheme.primaryBlue),
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      flex: team2Goals > 0 ? team2Goals : 1,
                      child: Container(color: AppTheme.primaryOrange),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              team2Goals.toString(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryOrange,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

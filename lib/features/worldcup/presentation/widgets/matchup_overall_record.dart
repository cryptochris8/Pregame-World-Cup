import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';

/// Displays the overall head-to-head record between two teams
/// with a visual win bar and stat columns.
class MatchupOverallRecord extends StatelessWidget {
  final int team1Wins;
  final int team2Wins;
  final int draws;
  final int totalMatches;

  const MatchupOverallRecord({
    super.key,
    required this.team1Wins,
    required this.team2Wins,
    required this.draws,
    required this.totalMatches,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Visual bar comparison
        _buildWinBar(),
        const SizedBox(height: 12),
        // Stats row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatColumn(
              team1Wins.toString(),
              'Wins',
              AppTheme.primaryBlue,
            ),
            _buildStatColumn(
              draws.toString(),
              'Draws',
              Colors.grey,
            ),
            _buildStatColumn(
              team2Wins.toString(),
              'Wins',
              AppTheme.primaryOrange,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '$totalMatches total matches',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildWinBar() {
    final total = team1Wins + draws + team2Wins;
    if (total == 0) return const SizedBox.shrink();

    return Container(
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Expanded(
            flex: team1Wins > 0 ? team1Wins : 0,
            child: Container(color: AppTheme.primaryBlue),
          ),
          if (team1Wins > 0 && draws > 0) const SizedBox(width: 1),
          Expanded(
            flex: draws > 0 ? draws : 0,
            child: Container(color: Colors.grey),
          ),
          if (draws > 0 && team2Wins > 0) const SizedBox(width: 1),
          Expanded(
            flex: team2Wins > 0 ? team2Wins : 0,
            child: Container(color: AppTheme.primaryOrange),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

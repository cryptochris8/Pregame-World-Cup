import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';
import 'fan_pass_feature_gate.dart';

/// Displays match statistics (possession, shots, corners, fouls) as
/// horizontal bar comparisons between home and away teams.
class MatchStatsWidget extends StatelessWidget {
  final Color stageColor;

  const MatchStatsWidget({
    super.key,
    required this.stageColor,
  });

  @override
  Widget build(BuildContext context) {
    // Gate Advanced Stats behind Fan Pass
    return FanPassFeatureGate(
      feature: FanPassFeature.advancedStats,
      customMessage: 'Unlock detailed match statistics including possession, shots, corners, and more.',
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.backgroundCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.bar_chart, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Match Statistics',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildStatBar('Possession', 55, 45),
              const SizedBox(height: 12),
              _buildStatBar('Shots', 12, 8),
              const SizedBox(height: 12),
              _buildStatBar('Shots on Target', 5, 3),
              const SizedBox(height: 12),
              _buildStatBar('Corners', 6, 4),
              const SizedBox(height: 12),
              _buildStatBar('Fouls', 10, 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBar(String label, int home, int away) {
    final total = home + away;
    final homePercent = total > 0 ? home / total : 0.5;

    return Column(
      children: [
        Row(
          children: [
            Text(
              '$home',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white60,
                ),
              ),
            ),
            Text(
              '$away',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              flex: (homePercent * 100).round(),
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: stageColor,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(3),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 2),
            Expanded(
              flex: ((1 - homePercent) * 100).round(),
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(3),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

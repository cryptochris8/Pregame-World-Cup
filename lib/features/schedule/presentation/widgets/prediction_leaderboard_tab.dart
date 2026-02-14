import 'package:flutter/material.dart';
import '../../../../core/services/game_prediction_service.dart';
import '../../../worldcup/presentation/widgets/fan_pass_feature_gate.dart';
import 'prediction_accuracy_helpers.dart';

/// Tab displaying the prediction leaderboard rankings.
class PredictionLeaderboardTab extends StatelessWidget {
  final List<UserAccuracyStats> leaderboard;

  const PredictionLeaderboardTab({super.key, required this.leaderboard});

  @override
  Widget build(BuildContext context) {
    // Gate leaderboard behind Fan Pass (advanced social features)
    return FanPassFeatureGate(
      feature: FanPassFeature.advancedSocialFeatures,
      customMessage: 'See how you rank against other predictors! Unlock the leaderboard with Fan Pass.',
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (leaderboard.isEmpty) {
      return PredictionAccuracyHelpers.buildNoDataWidget('No leaderboard data available yet.\nBe the first to make predictions!');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Top Predictors',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'See how you rank against other users',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 24),

          // Leaderboard
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: leaderboard.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final user = leaderboard[index];
              final rank = index + 1;

              return Card(
                color: rank <= 3 ? Colors.orange[900] : Colors.brown[800],
                elevation: rank <= 3 ? 8 : 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Rank
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _getRankColor(rank),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: rank <= 3
                              ? Icon(
                                  _getRankIcon(rank),
                                  color: Colors.white,
                                  size: 24,
                                )
                              : Text(
                                  '$rank',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // User info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Player',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${user.totalPredictions} predictions',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Accuracy
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${(user.overallAccuracy * 100).round()}%',
                            style: TextStyle(
                              color: PredictionAccuracyHelpers.getAccuracyColor(user.overallAccuracy),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const Text(
                            'Accuracy',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.brown[400]!;
      default:
        return Colors.blue[600]!;
    }
  }

  IconData _getRankIcon(int rank) {
    switch (rank) {
      case 1:
        return Icons.emoji_events;
      case 2:
        return Icons.workspace_premium;
      case 3:
        return Icons.military_tech;
      default:
        return Icons.person;
    }
  }
}

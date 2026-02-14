import 'package:flutter/material.dart';
import '../../../../core/services/game_prediction_service.dart';
import 'prediction_accuracy_helpers.dart';

/// Tab displaying user's personal prediction statistics.
class UserStatsTab extends StatelessWidget {
  final PredictionAccuracyStats? accuracyStats;

  const UserStatsTab({super.key, required this.accuracyStats});

  @override
  Widget build(BuildContext context) {
    if (accuracyStats?.userAccuracy == null) {
      return PredictionAccuracyHelpers.buildNoDataWidget('No personal predictions yet.\nMake some predictions to see your stats!');
    }

    final userStats = accuracyStats!.userAccuracy!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Your Prediction Performance',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Track your prediction accuracy and see how you compare',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 24),

          // User Accuracy Card
          Card(
            color: Colors.brown[800],
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        color: Colors.blue[300],
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Your Accuracy',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Accuracy percentage circle
                  PredictionAccuracyHelpers.buildAccuracyCircle(userStats.overallAccuracy),

                  const SizedBox(height: 20),

                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      PredictionAccuracyHelpers.buildStatColumn(
                        'Total Predictions',
                        userStats.totalPredictions.toString(),
                        Icons.analytics,
                      ),
                      PredictionAccuracyHelpers.buildStatColumn(
                        'Correct Predictions',
                        userStats.correctPredictions.toString(),
                        Icons.check_circle,
                      ),
                      PredictionAccuracyHelpers.buildStatColumn(
                        'Score Accuracy',
                        '${(userStats.averageScoreAccuracy * 100).round()}%',
                        Icons.sports_score,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // AI vs User Comparison
          if (accuracyStats!.aiAccuracy.totalPredictions > 0) ...[
            Card(
              color: Colors.brown[700],
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.compare,
                          color: Colors.orange[300],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'You vs AI',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildComparisonBar(
                      'Overall Accuracy',
                      userStats.overallAccuracy,
                      accuracyStats!.aiAccuracy.overallAccuracy,
                    ),
                    const SizedBox(height: 12),
                    _buildComparisonBar(
                      'Score Accuracy',
                      userStats.averageScoreAccuracy,
                      accuracyStats!.aiAccuracy.averageScoreAccuracy,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildComparisonBar(String label, double userValue, double aiValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text(
              'You: ',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            Expanded(
              flex: (userValue * 100).round(),
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.blue[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${(userValue * 100).round()}%',
              style: TextStyle(
                color: Colors.blue[300],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Text(
              'AI: ',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            Expanded(
              flex: (aiValue * 100).round(),
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.orange[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${(aiValue * 100).round()}%',
              style: TextStyle(
                color: Colors.orange[300],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

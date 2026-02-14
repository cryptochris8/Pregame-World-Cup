import 'package:flutter/material.dart';
import '../../../../core/services/game_prediction_service.dart';
import '../../../worldcup/presentation/widgets/fan_pass_feature_gate.dart';
import 'prediction_accuracy_helpers.dart';

/// Tab displaying AI prediction performance statistics.
class AIPerformanceTab extends StatelessWidget {
  final PredictionAccuracyStats? accuracyStats;

  const AIPerformanceTab({super.key, required this.accuracyStats});

  @override
  Widget build(BuildContext context) {
    // Gate AI Performance insights behind Superfan Pass
    return FanPassFeatureGate(
      feature: FanPassFeature.aiMatchInsights,
      customMessage: 'Unlock detailed AI prediction performance analysis and accuracy tracking with Superfan Pass.',
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (accuracyStats?.aiAccuracy == null) {
      return PredictionAccuracyHelpers.buildNoDataWidget('No AI prediction data available yet');
    }

    final aiStats = accuracyStats!.aiAccuracy;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'AI Prediction Performance',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Track how well our AI system predicts game outcomes',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 24),

          // Overall Accuracy Card
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
                        Icons.psychology,
                        color: Colors.orange[300],
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Overall Accuracy',
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
                  PredictionAccuracyHelpers.buildAccuracyCircle(aiStats.overallAccuracy),

                  const SizedBox(height: 20),

                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      PredictionAccuracyHelpers.buildStatColumn(
                        'Total Predictions',
                        aiStats.totalPredictions.toString(),
                        Icons.analytics,
                      ),
                      PredictionAccuracyHelpers.buildStatColumn(
                        'Correct Predictions',
                        aiStats.correctPredictions.toString(),
                        Icons.check_circle,
                      ),
                      PredictionAccuracyHelpers.buildStatColumn(
                        'Score Accuracy',
                        '${(aiStats.averageScoreAccuracy * 100).round()}%',
                        Icons.sports_score,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Performance Insights
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
                        Icons.insights,
                        color: Colors.orange[300],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Performance Insights',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  PredictionAccuracyHelpers.buildInsightRow(
                    'Accuracy Level',
                    PredictionAccuracyHelpers.getAccuracyDescription(aiStats.overallAccuracy),
                    PredictionAccuracyHelpers.getAccuracyColor(aiStats.overallAccuracy),
                  ),
                  PredictionAccuracyHelpers.buildInsightRow(
                    'Prediction Volume',
                    PredictionAccuracyHelpers.getVolumeDescription(aiStats.totalPredictions),
                    Colors.blue[300]!,
                  ),
                  PredictionAccuracyHelpers.buildInsightRow(
                    'Score Precision',
                    PredictionAccuracyHelpers.getScoreAccuracyDescription(aiStats.averageScoreAccuracy),
                    Colors.purple[300]!,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

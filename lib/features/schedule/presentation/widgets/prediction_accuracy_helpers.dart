import 'package:flutter/material.dart';

/// Shared helper methods used across prediction accuracy tab widgets.
class PredictionAccuracyHelpers {
  PredictionAccuracyHelpers._();

  static Widget buildNoDataWidget(String message) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.brown[800],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.brown[600]!),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.analytics_outlined,
              color: Colors.orange[300],
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildStatColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.orange[300],
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  static Widget buildInsightRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildAccuracyCircle(double accuracy) {
    return SizedBox(
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: 120,
            width: 120,
            child: CircularProgressIndicator(
              value: accuracy,
              strokeWidth: 12,
              backgroundColor: Colors.white30,
              valueColor: AlwaysStoppedAnimation<Color>(
                getAccuracyColor(accuracy),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${(accuracy * 100).round()}%',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Text(
                'Correct',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Color getAccuracyColor(double accuracy) {
    if (accuracy >= 0.7) return Colors.green;
    if (accuracy >= 0.5) return Colors.orange;
    return Colors.red;
  }

  static String getAccuracyDescription(double accuracy) {
    if (accuracy >= 0.8) return 'Excellent';
    if (accuracy >= 0.7) return 'Good';
    if (accuracy >= 0.6) return 'Average';
    if (accuracy >= 0.5) return 'Below Average';
    return 'Needs Improvement';
  }

  static String getVolumeDescription(int total) {
    if (total >= 50) return 'High Volume';
    if (total >= 20) return 'Moderate Volume';
    if (total >= 10) return 'Getting Started';
    return 'Early Days';
  }

  static String getScoreAccuracyDescription(double accuracy) {
    if (accuracy >= 0.8) return 'Very Precise';
    if (accuracy >= 0.6) return 'Fairly Accurate';
    if (accuracy >= 0.4) return 'Room for Improvement';
    return 'Developing';
  }
}

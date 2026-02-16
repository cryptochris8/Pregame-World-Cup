import 'package:flutter/material.dart';
import '../../../../config/theme_helper.dart';
import '../../domain/entities/game_prediction.dart';

/// Action buttons for submitting or showing locked state for game predictions
class PredictionActionButtons extends StatelessWidget {
  final bool canPredict;
  final bool showScorePrediction;
  final bool isLoading;
  final String? selectedWinner;
  final GamePrediction? existingPrediction;
  final VoidCallback onShowScorePrediction;
  final VoidCallback onMakePrediction;

  const PredictionActionButtons({
    super.key,
    required this.canPredict,
    required this.showScorePrediction,
    required this.isLoading,
    this.selectedWinner,
    this.existingPrediction,
    required this.onShowScorePrediction,
    required this.onMakePrediction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!showScorePrediction && canPredict) ...[
          TextButton.icon(
            onPressed: onShowScorePrediction,
            icon: const Icon(Icons.add, color: Colors.white70),
            label: const Text(
              'Add Score Prediction',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          const SizedBox(height: 12),
        ],

        if (canPredict)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selectedWinner != null && !isLoading
                  ? onMakePrediction
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeHelper.favoriteColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.sports_soccer, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          existingPrediction != null
                              ? 'Update Prediction'
                              : 'Make Prediction',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock, color: Colors.white70, size: 20),
                SizedBox(width: 8),
                Text(
                  'Predictions Locked',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

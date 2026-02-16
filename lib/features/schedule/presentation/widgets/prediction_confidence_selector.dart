import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Star-based confidence level selector for game predictions (1-5)
class PredictionConfidenceSelector extends StatelessWidget {
  final int confidenceLevel;
  final ValueChanged<int> onConfidenceChanged;

  const PredictionConfidenceSelector({
    super.key,
    required this.confidenceLevel,
    required this.onConfidenceChanged,
  });

  String _getConfidenceText() {
    switch (confidenceLevel) {
      case 1: return 'Not very confident';
      case 2: return 'Slightly confident';
      case 3: return 'Moderately confident';
      case 4: return 'Very confident';
      case 5: return 'Absolutely certain!';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.star,
                color: Colors.amber,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Confidence Level: $confidenceLevel/5',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              final level = index + 1;
              final isSelected = level == confidenceLevel;

              return GestureDetector(
                onTap: () {
                  onConfidenceChanged(level);
                  HapticFeedback.selectionClick();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? Colors.amber.withValues(alpha: 0.2)
                        : Colors.transparent,
                  ),
                  child: Icon(
                    Icons.star,
                    color: level <= confidenceLevel
                        ? Colors.amber
                        : Colors.white.withValues(alpha: 0.3),
                    size: 24,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            _getConfidenceText(),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

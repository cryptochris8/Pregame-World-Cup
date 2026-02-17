import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';
import '../../domain/entities/entities.dart';

/// Compact chip-style AI insight for match cards.
///
/// Displays one of three states:
/// - Loading: spinner with "AI..." text
/// - Prediction available: gradient chip with quick insight text
/// - No prediction: tappable button with "AI Predict" / "Retry AI" label
class AIInsightsCompactChip extends StatelessWidget {
  final AIMatchPrediction? prediction;
  final bool isLoading;
  final bool hasError;
  final VoidCallback onTap;

  const AIInsightsCompactChip({
    super.key,
    this.prediction,
    this.isLoading = false,
    this.hasError = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'AI...',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      );
    }

    if (prediction != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppTheme.primaryPurple,
              AppTheme.primaryDeepPurple,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryPurple.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.psychology,
              size: 14,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              prediction!.quickInsight,
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    // Show button to load prediction
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.psychology_outlined,
              size: 14,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              hasError ? 'Retry AI' : 'AI Predict',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

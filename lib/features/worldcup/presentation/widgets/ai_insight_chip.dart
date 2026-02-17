import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/app_theme.dart';
import '../../domain/entities/entities.dart';
import '../bloc/bloc.dart';

/// AI Insight chip for match cards.
///
/// Displays one of three states:
/// - Loading: spinner with "AI..." text
/// - Prediction available: gradient chip with quick insight text
/// - No prediction: tappable "AI Predict" button
class AIInsightChip extends StatelessWidget {
  final WorldCupMatch match;
  final AIMatchPrediction? aiPrediction;
  final NationalTeam? homeTeam;
  final NationalTeam? awayTeam;

  const AIInsightChip({
    super.key,
    required this.match,
    this.aiPrediction,
    this.homeTeam,
    this.awayTeam,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Try to get cubit from context
    WorldCupAICubit? aiCubit;
    try {
      aiCubit = context.read<WorldCupAICubit>();
    } catch (_) {
      // Cubit not available
    }

    // If we have a pre-loaded prediction, display it
    if (aiPrediction != null) {
      return _buildPredictionChip(theme, aiPrediction!);
    }

    // If cubit is available, use BlocBuilder
    if (aiCubit != null) {
      return BlocBuilder<WorldCupAICubit, WorldCupAIState>(
        builder: (context, state) {
          final prediction = state.getPrediction(match.matchId);
          final isLoading = state.isLoadingMatch(match.matchId);

          if (isLoading) {
            return _buildLoadingChip(theme, colorScheme);
          }

          if (prediction != null && prediction.isValid) {
            return _buildPredictionChip(theme, prediction);
          }

          return _buildLoadButton(context, theme, colorScheme);
        },
      );
    }

    // No cubit available, show disabled state
    return const SizedBox.shrink();
  }

  Widget _buildLoadingChip(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryPurple.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryPurple.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppTheme.primaryPurple,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'AI...',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppTheme.primaryPurple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionChip(ThemeData theme, AIMatchPrediction prediction) {
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
            color: AppTheme.primaryPurple.withValues(alpha: 0.4),
            blurRadius: 6,
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
            prediction.quickInsight,
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadButton(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return InkWell(
      onTap: () {
        final cubit = context.read<WorldCupAICubit>();
        cubit.loadPredictionWithTeams(match, homeTeam, awayTeam);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.primaryPurple.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.primaryPurple.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.psychology_outlined,
              size: 14,
              color: AppTheme.primaryPurple,
            ),
            const SizedBox(width: 4),
            Text(
              'AI Predict',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppTheme.primaryPurple,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

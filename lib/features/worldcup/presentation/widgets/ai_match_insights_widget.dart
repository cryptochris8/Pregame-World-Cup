import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/entities.dart';
import '../bloc/bloc.dart';

/// Display mode for AI insights
enum AIInsightsMode {
  /// Small chip for match cards (e.g., "AI: Brazil 2-1 (72%)")
  compact,

  /// Full card with prediction, key factors, and analysis
  expanded,
}

/// Widget to display AI match prediction insights
///
/// Can be displayed in:
/// - Compact mode: Small chip showing predicted score and confidence
/// - Expanded mode: Full card with probability bars, key factors, and analysis
class AIMatchInsightsWidget extends StatelessWidget {
  /// The match to show insights for
  final WorldCupMatch match;

  /// Home team details (optional, for better predictions)
  final NationalTeam? homeTeam;

  /// Away team details (optional, for better predictions)
  final NationalTeam? awayTeam;

  /// Display mode
  final AIInsightsMode mode;

  /// Callback when user taps to load prediction
  final VoidCallback? onTapLoad;

  /// Whether to auto-load prediction on build
  final bool autoLoad;

  const AIMatchInsightsWidget({
    super.key,
    required this.match,
    this.homeTeam,
    this.awayTeam,
    this.mode = AIInsightsMode.compact,
    this.onTapLoad,
    this.autoLoad = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorldCupAICubit, WorldCupAIState>(
      builder: (context, state) {
        final prediction = state.getPrediction(match.matchId);
        final isLoading = state.isLoadingMatch(match.matchId);
        final hasError = state.hasError(match.matchId);

        if (mode == AIInsightsMode.compact) {
          return _CompactInsight(
            prediction: prediction,
            isLoading: isLoading,
            hasError: hasError,
            onTap: () => _loadPrediction(context),
          );
        } else {
          return _ExpandedInsight(
            match: match,
            prediction: prediction,
            isLoading: isLoading,
            hasError: hasError,
            onTap: () => _loadPrediction(context),
            onRefresh: () => _refreshPrediction(context),
          );
        }
      },
    );
  }

  void _loadPrediction(BuildContext context) {
    final cubit = context.read<WorldCupAICubit>();
    cubit.loadPredictionWithTeams(match, homeTeam, awayTeam);
    onTapLoad?.call();
  }

  void _refreshPrediction(BuildContext context) {
    final cubit = context.read<WorldCupAICubit>();
    cubit.refreshPrediction(match, homeTeam: homeTeam, awayTeam: awayTeam);
  }
}

/// Compact chip-style AI insight
class _CompactInsight extends StatelessWidget {
  final AIMatchPrediction? prediction;
  final bool isLoading;
  final bool hasError;
  final VoidCallback onTap;

  const _CompactInsight({
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
          color: colorScheme.primaryContainer.withOpacity(0.5),
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
          gradient: LinearGradient(
            colors: [
              Colors.purple.shade400,
              Colors.deepPurple.shade500,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.3),
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
            color: colorScheme.outline.withOpacity(0.5),
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

/// Expanded card-style AI insight with full details
class _ExpandedInsight extends StatelessWidget {
  final WorldCupMatch match;
  final AIMatchPrediction? prediction;
  final bool isLoading;
  final bool hasError;
  final VoidCallback onTap;
  final VoidCallback onRefresh;

  const _ExpandedInsight({
    required this.match,
    this.prediction,
    this.isLoading = false,
    this.hasError = false,
    required this.onTap,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isLoading) {
      return _buildLoadingCard(theme, colorScheme);
    }

    if (prediction != null) {
      return _buildPredictionCard(theme, colorScheme, prediction!);
    }

    return _buildLoadButton(theme, colorScheme);
  }

  Widget _buildLoadingCard(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.shade400.withOpacity(0.1),
            Colors.deepPurple.shade500.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.purple.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.psychology,
                color: Colors.purple,
              ),
              const SizedBox(width: 8),
              Text(
                'AI Analysis',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.purple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const CircularProgressIndicator(
            color: Colors.purple,
          ),
          const SizedBox(height: 8),
          Text(
            'Generating prediction...',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionCard(
    ThemeData theme,
    ColorScheme colorScheme,
    AIMatchPrediction prediction,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.shade400.withOpacity(0.15),
            Colors.deepPurple.shade600.withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.purple.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Colors.purple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Match Prediction',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: Colors.purple.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Powered by ${prediction.provider}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                color: Colors.purple,
                onPressed: onRefresh,
                tooltip: 'Refresh prediction',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Predicted Score
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    'Predicted Score',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        match.homeTeamName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        prediction.scoreDisplay,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        match.awayTeamName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Probability bars
          _ProbabilityBars(
            homeProb: prediction.homeWinProbability,
            drawProb: prediction.drawProbability,
            awayProb: prediction.awayWinProbability,
            homeTeamName: match.homeTeamName,
            awayTeamName: match.awayTeamName,
          ),

          const SizedBox(height: 16),

          // Confidence
          Row(
            children: [
              Text(
                'Confidence: ',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getConfidenceColor(prediction.confidence)
                      .withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${prediction.confidence}% (${prediction.confidenceDescription})',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: _getConfidenceColor(prediction.confidence),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Key factors
          if (prediction.keyFactors.isNotEmpty) ...[
            Text(
              'Key Factors',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.purple.shade700,
              ),
            ),
            const SizedBox(height: 8),
            ...prediction.keyFactors.take(4).map(
                  (factor) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 14,
                          color: Colors.purple.shade400,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            factor,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],

          // Analysis
          if (prediction.analysis.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                prediction.analysis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadButton(ThemeData theme, ColorScheme colorScheme) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.purple.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.psychology_outlined,
              color: Colors.purple.shade400,
            ),
            const SizedBox(width: 8),
            Text(
              hasError ? 'Retry AI Prediction' : 'Get AI Prediction',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.purple.shade400,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getConfidenceColor(int confidence) {
    if (confidence >= 75) return Colors.green;
    if (confidence >= 50) return Colors.orange;
    return Colors.red;
  }
}

/// Probability bars showing win/draw/loss chances
class _ProbabilityBars extends StatelessWidget {
  final int homeProb;
  final int drawProb;
  final int awayProb;
  final String homeTeamName;
  final String awayTeamName;

  const _ProbabilityBars({
    required this.homeProb,
    required this.drawProb,
    required this.awayProb,
    required this.homeTeamName,
    required this.awayTeamName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Labels
        Row(
          children: [
            Expanded(
              child: Text(
                homeTeamName,
                style: theme.textTheme.labelSmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              'Draw',
              style: theme.textTheme.labelSmall,
            ),
            Expanded(
              child: Text(
                awayTeamName,
                style: theme.textTheme.labelSmall,
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),

        // Probabilities
        Row(
          children: [
            Text(
              '$homeProb%',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const Spacer(),
            Text(
              '$drawProb%',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const Spacer(),
            Text(
              '$awayProb%',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),

        // Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 8,
            child: Row(
              children: [
                Expanded(
                  flex: homeProb,
                  child: Container(color: Colors.green),
                ),
                Expanded(
                  flex: drawProb,
                  child: Container(color: Colors.grey),
                ),
                Expanded(
                  flex: awayProb,
                  child: Container(color: Colors.blue),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

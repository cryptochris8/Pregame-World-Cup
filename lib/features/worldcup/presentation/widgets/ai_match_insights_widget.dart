import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/app_theme.dart';
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
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryPurple.withValues(alpha: 0.8),
            AppTheme.primaryBlue.withValues(alpha: 0.6),
            AppTheme.primaryOrange.withValues(alpha: 0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accentGold, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryOrange.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildEnhancedHeader(isLoading: true),
          const SizedBox(height: 20),
          const CircularProgressIndicator(
            color: AppTheme.primaryOrange,
            strokeWidth: 3,
          ),
          const SizedBox(height: 12),
          const Text(
            'Generating AI prediction...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedHeader({bool isLoading = false}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryPurple, AppTheme.primaryBlue],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🧠', style: TextStyle(fontSize: 16)),
              SizedBox(width: 6),
              Text(
                'Enhanced AI Analysis',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        if (!isLoading)
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh, color: AppTheme.primaryOrange, size: 20),
            tooltip: 'Refresh Analysis',
          ),
        if (isLoading)
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryOrange),
            ),
          ),
      ],
    );
  }

  Widget _buildPredictionCard(
    ThemeData theme,
    ColorScheme colorScheme,
    AIMatchPrediction prediction,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryPurple.withValues(alpha: 0.8),
            AppTheme.primaryBlue.withValues(alpha: 0.6),
            AppTheme.primaryOrange.withValues(alpha: 0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accentGold, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryOrange.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced Header
          _buildEnhancedHeader(),

          const SizedBox(height: 16),

          // AI Prediction Summary
          _buildPredictionSummary(prediction),

          const SizedBox(height: 16),

          // Key factors preview (top 2)
          if (prediction.keyFactors.isNotEmpty)
            _buildKeyFactorsPreview(prediction.keyFactors),

          const SizedBox(height: 16),

          // View Detailed Analysis button
          _buildViewDetailedAnalysisButton(),
        ],
      ),
    );
  }

  Widget _buildPredictionSummary(AIMatchPrediction prediction) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.sports_soccer, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              const Text(
                'AI Prediction:',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${match.homeTeamName} vs ${match.awayTeamName}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                prediction.scoreDisplay,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getConfidenceColor(prediction.confidence).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getConfidenceColor(prediction.confidence).withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  '${prediction.confidence}% confidence',
                  style: TextStyle(
                    color: _getConfidenceColor(prediction.confidence),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeyFactorsPreview(List<String> keyFactors) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb, color: AppTheme.accentGold, size: 18),
              SizedBox(width: 8),
              Text(
                'Key Factors',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...keyFactors.take(2).map(
            (factor) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: AppTheme.primaryOrange, fontSize: 14)),
                  Expanded(
                    child: Text(
                      factor,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (keyFactors.length > 2)
            Text(
              '+${keyFactors.length - 2} more factors...',
              style: TextStyle(
                color: AppTheme.accentGold.withValues(alpha: 0.8),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildViewDetailedAnalysisButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppTheme.buttonGradient,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryOrange.withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          // This would typically navigate to a detailed analysis screen
          // For now, we'll just refresh to show it's interactive
          onRefresh();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 0,
        ),
        icon: const Icon(Icons.analytics_outlined, size: 20),
        label: const Text(
          'View Detailed Analysis',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadButton(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryPurple.withValues(alpha: 0.8),
            AppTheme.primaryBlue.withValues(alpha: 0.6),
            AppTheme.primaryOrange.withValues(alpha: 0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accentGold, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryOrange.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryPurple, AppTheme.primaryBlue],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🧠', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 6),
                    Text(
                      'Enhanced AI Analysis',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Call to action button
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: AppTheme.buttonGradient,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryOrange.withValues(alpha: 0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.psychology, size: 20),
              label: Text(
                hasError ? 'Retry AI Prediction' : 'Get AI Prediction',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getConfidenceColor(int confidence) {
    if (confidence >= 75) return Colors.green;
    if (confidence >= 50) return Colors.orange;
    return Colors.red;
  }
}

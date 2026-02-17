import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/entities.dart';
import '../bloc/bloc.dart';
import 'ai_insights_compact_chip.dart';
import 'ai_insights_expanded_card.dart';

/// Display mode for AI insights
enum AIInsightsMode {
  /// Small chip for match cards (e.g., "AI: Brazil 2-1 (72%)")
  compact,

  /// Full card with prediction, key factors, and analysis
  expanded,
}

/// Widget to display AI match prediction insights.
///
/// Can be displayed in:
/// - Compact mode: Small chip showing predicted score and confidence
///   (delegates to [AIInsightsCompactChip])
/// - Expanded mode: Full card with probability bars, key factors, and analysis
///   (delegates to [AIInsightsExpandedCard])
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
          return AIInsightsCompactChip(
            prediction: prediction,
            isLoading: isLoading,
            hasError: hasError,
            onTap: () => _loadPrediction(context),
          );
        } else {
          return AIInsightsExpandedCard(
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

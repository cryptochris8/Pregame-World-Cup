import 'package:flutter/material.dart';
import '../../../../../config/app_theme.dart';
import '../../../../../core/config/feature_flags.dart';
import '../../../domain/entities/ai_match_prediction.dart';
import '../../../domain/entities/match_narrative.dart';
import '../../../domain/entities/match_summary.dart';
import 'analysis_tab.dart';
import 'firestore_prediction_tab.dart';
import 'match_summary_header.dart';
import 'match_summary_tab_bar.dart';
import 'narrative_tab.dart';
import 'players_tab.dart';
import 'prediction_tab.dart';

/// AI Match Summary Widget
/// Displays comprehensive AI-generated match analysis including:
/// - Pregame article (narrative, when available)
/// - Historical analysis
/// - Key storylines
/// - Players to watch
/// - Tactical preview
/// - Predictions
class AIMatchSummaryWidget extends StatefulWidget {
  final MatchSummary summary;
  final bool initiallyExpanded;

  /// The actual home team code from the match data.
  /// Used to correctly orient scores and probabilities when the
  /// summary's alphabetical team ordering differs from home/away.
  final String? homeTeamCode;

  /// Optional rich prediction from LocalPredictionEngine.
  /// When provided, the Prediction tab shows full engine output
  /// instead of the basic Firestore MatchPredictionSummary.
  final AIMatchPrediction? localPrediction;

  /// Optional pre-generated narrative article from MatchNarrativeService.
  /// When provided, a "Pregame" tab is shown as the first/default tab
  /// with a beautifully formatted sports journalism article.
  final MatchNarrative? narrative;

  const AIMatchSummaryWidget({
    super.key,
    required this.summary,
    this.initiallyExpanded = false,
    this.homeTeamCode,
    this.localPrediction,
    this.narrative,
  });

  @override
  State<AIMatchSummaryWidget> createState() => _AIMatchSummaryWidgetState();
}

class _AIMatchSummaryWidgetState extends State<AIMatchSummaryWidget> {
  late bool _isExpanded;
  int _selectedTab = 0;

  bool get _hasNarrative => widget.narrative != null;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.backgroundElevated,
            AppTheme.backgroundElevated.withValues(alpha: 0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryPurple.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          MatchSummaryHeader(
            summary: widget.summary,
            isExpanded: _isExpanded,
            onToggle: () => setState(() => _isExpanded = !_isExpanded),
            homeTeamCode: widget.homeTeamCode,
          ),
          if (_isExpanded) ...[
            MatchSummaryTabBar(
              selectedTab: _selectedTab,
              onTabSelected: (tab) => setState(() => _selectedTab = tab),
              hasNarrative: _hasNarrative,
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Padding(
                key: ValueKey(_selectedTab),
                padding: const EdgeInsets.all(16),
                child: _buildTabContent(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    if (_hasNarrative) {
      // With narrative: Pregame(0), Analysis(1), Players(2), Prediction(3)
      return switch (_selectedTab) {
        0 => NarrativeTab(narrative: widget.narrative!),
        1 => AnalysisTab(summary: widget.summary),
        2 => PlayersTab(summary: widget.summary),
        3 => _buildPredictionTab(),
        _ => const SizedBox.shrink(),
      };
    }
    // Without narrative: Analysis(0), Players(1), Prediction(2)
    return switch (_selectedTab) {
      0 => AnalysisTab(summary: widget.summary),
      1 => PlayersTab(summary: widget.summary),
      2 => _buildPredictionTab(),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildPredictionTab() {
    // Defense-in-depth: the tab bar hides this entry when predictions are
    // disabled, but if somehow selected, render nothing.
    if (!FeatureFlags.predictionsEnabled) {
      return const SizedBox.shrink();
    }
    final lp = widget.localPrediction;
    if (lp != null) {
      return PredictionTab(
        prediction: lp,
        summary: widget.summary,
        homeTeamCode: widget.homeTeamCode,
      );
    }
    return FirestorePredictionTab(
      summary: widget.summary,
      homeTeamCode: widget.homeTeamCode,
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../../config/app_theme.dart';
import '../../../domain/entities/ai_match_prediction.dart';
import '../../../domain/entities/match_summary.dart';
import 'analysis_tab.dart';
import 'firestore_prediction_tab.dart';
import 'match_summary_header.dart';
import 'match_summary_tab_bar.dart';
import 'players_tab.dart';
import 'prediction_tab.dart';

/// AI Match Summary Widget
/// Displays comprehensive AI-generated match analysis including:
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

  const AIMatchSummaryWidget({
    super.key,
    required this.summary,
    this.initiallyExpanded = false,
    this.homeTeamCode,
    this.localPrediction,
  });

  @override
  State<AIMatchSummaryWidget> createState() => _AIMatchSummaryWidgetState();
}

class _AIMatchSummaryWidgetState extends State<AIMatchSummaryWidget> {
  late bool _isExpanded;
  int _selectedTab = 0;

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
    return switch (_selectedTab) {
      0 => AnalysisTab(summary: widget.summary),
      1 => PlayersTab(summary: widget.summary),
      2 => _buildPredictionTab(),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildPredictionTab() {
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

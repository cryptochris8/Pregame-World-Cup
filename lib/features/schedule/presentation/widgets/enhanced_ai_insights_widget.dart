import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/game_schedule.dart';
import '../../../../core/services/logging_service.dart';
import 'ai_insights_analysis_helper.dart';
import 'ai_insights_header_widget.dart';
import 'ai_insights_state_widgets.dart';
import 'ai_insights_detail_sheet.dart';
import 'ai_prediction_tab_widget.dart';
import 'ai_key_factors_tab_widget.dart';
import 'ai_season_review_tab_widget.dart';
import 'ai_historical_analysis_tab_widget.dart';
import 'ai_compact_content_widget.dart';

/// Enhanced AI insights widget that displays comprehensive game analysis including:
/// - Realistic team-specific predictions with proper score variability
/// - Detailed AI-generated game summaries and narratives
/// - Real player information and matchup analysis
/// - Advanced predictions with confidence scores
/// - Key factors and storylines
class EnhancedAIInsightsWidget extends StatefulWidget {
  final GameSchedule game;
  final bool isCompact;

  const EnhancedAIInsightsWidget({
    super.key,
    required this.game,
    this.isCompact = true,
  });

  @override
  State<EnhancedAIInsightsWidget> createState() => _EnhancedAIInsightsWidgetState();
}

class _EnhancedAIInsightsWidgetState extends State<EnhancedAIInsightsWidget>
    with SingleTickerProviderStateMixin {
  late final AIInsightsAnalysisHelper _helper;

  Map<String, dynamic>? _analysisData;
  bool _isLoading = false;
  String? _error;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    LoggingService.info(
      'WIDGET INIT: EnhancedAIInsightsWidget initState called for '
      '${widget.game.awayTeamName} @ ${widget.game.homeTeamName}',
      tag: 'EnhancedInsights',
    );

    _helper = AIInsightsAnalysisHelper(game: widget.game);
    _tabController = TabController(length: 4, vsync: this);

    final initError = _helper.initializeServices();
    if (initError != null) {
      if (mounted) {
        setState(() {
          _error = initError;
          _isLoading = false;
        });
      }
    } else {
      _loadAnalysis();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Data loading
  // ---------------------------------------------------------------------------

  Future<void> _loadAnalysis() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final memoryPressure = _helper.detectMemoryPressure();
      final timeoutDuration =
          memoryPressure ? const Duration(seconds: 3) : const Duration(seconds: 6);

      final result = await Future.any([
        _helper.loadAnalysisCore(),
        Future.delayed(
          timeoutDuration,
          () => throw TimeoutException('Analysis loading timed out', timeoutDuration),
        ),
      ]);

      if (mounted) {
        setState(() {
          _analysisData = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      LoggingService.error('Error loading enhanced analysis: $e', tag: 'EnhancedInsights');
      if (mounted) {
        setState(() {
          _error = e is TimeoutException
              ? 'Analysis timed out. Please try again.'
              : 'Failed to load analysis: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // UI Build Methods
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E3A8A).withValues(alpha: 0.8),
            Colors.purple[800]!.withValues(alpha: 0.6),
            Colors.orange[800]!.withValues(alpha: 0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange[300]!, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.orange[900]!.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: widget.isCompact ? _buildCompactView() : _buildDetailedView(),
    );
  }

  Widget _buildCompactView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AIInsightsHeaderWidget(
            awayTeamName: widget.game.awayTeamName,
            homeTeamName: widget.game.homeTeamName,
            isLoading: _isLoading,
            onRefresh: _loadAnalysis,
          ),
          const SizedBox(height: 12),
          if (_isLoading) const AIInsightsLoadingWidget(),
          if (_error != null) AIInsightsErrorWidget(errorMessage: _error!),
          if (_analysisData != null)
            AICompactContentWidget(
              analysisData: _analysisData!,
              homeTeamName: widget.game.homeTeamName,
              awayTeamName: widget.game.awayTeamName,
              onViewDetailedAnalysis: () =>
                  showAIInsightsDetailSheet(context, widget.game),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailedView() {
    return Column(
      children: [
        AIInsightsHeaderWidget(
          awayTeamName: widget.game.awayTeamName,
          homeTeamName: widget.game.homeTeamName,
          isLoading: _isLoading,
          onRefresh: _loadAnalysis,
        ),
        if (_isLoading) const AIInsightsLoadingWidget(),
        if (_error != null) AIInsightsErrorWidget(errorMessage: _error!),
        if (_analysisData != null) ...[
          _buildTabBar(),
          SizedBox(
            height: 400,
            child: TabBarView(
              controller: _tabController,
              children: [
                AIPredictionTabWidget(
                  analysisData: _analysisData!,
                  homeTeamName: widget.game.homeTeamName,
                  awayTeamName: widget.game.awayTeamName,
                ),
                AIHistoricalAnalysisTabWidget(
                  analysisData: _analysisData,
                  homeTeamName: widget.game.homeTeamName,
                  awayTeamName: widget.game.awayTeamName,
                ),
                AIKeyFactorsTabWidget(
                  analysisData: _analysisData!,
                ),
                AISeasonReviewTabWidget(
                  homeTeamName: widget.game.homeTeamName,
                  awayTeamName: widget.game.awayTeamName,
                  seasonSummaryService: _helper.seasonSummaryService,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.orange,
        unselectedLabelColor: Colors.white70,
        indicatorColor: Colors.orange,
        tabs: const [
          Tab(text: 'Predict'),
          Tab(text: 'Analysis'),
          Tab(text: 'Key Factors'),
          Tab(text: 'Season'),
        ],
      ),
    );
  }
}

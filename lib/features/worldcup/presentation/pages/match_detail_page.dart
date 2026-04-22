import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/app_theme.dart';
import '../../../../core/config/feature_flags.dart';
import '../../../../injection_container.dart' as di;
import '../../../../l10n/app_localizations.dart';
import '../../data/services/local_match_summary_service.dart';
import '../../data/services/local_prediction_engine.dart';
import '../../data/services/match_narrative_service.dart';
import '../../domain/entities/entities.dart';
import '../../domain/entities/match_narrative.dart';
import '../bloc/nearby_venues_cubit.dart';
import '../widgets/widgets.dart';
import '../../../venue_portal/venue_portal.dart';

/// Detailed view of a tournament match
class MatchDetailPage extends StatefulWidget {
  final WorldCupMatch match;

  const MatchDetailPage({
    super.key,
    required this.match,
  });

  @override
  State<MatchDetailPage> createState() => _MatchDetailPageState();
}

class _MatchDetailPageState extends State<MatchDetailPage> {
  WorldCupVenue? _matchVenue;
  MatchSummary? _matchSummary;
  MatchNarrative? _matchNarrative;
  AIMatchPrediction? _localPrediction;
  bool _isLoadingSummary = false;
  bool _showAllNearbyVenues = false;
  static const int _defaultNearbyVenuesCount = 4;

  @override
  void initState() {
    super.initState();
    _findMatchVenue();
    _loadMatchSummary();
    _loadMatchNarrative();
    _loadLocalPrediction();
  }

  /// Load match summary from locally-bundled JSON assets.
  ///
  /// All match preview content is stored in assets/data/worldcup/match_summaries/
  /// as pre-researched JSON files. No live API or Firestore calls are made here —
  /// content is updated offline and shipped with each app release.
  Future<void> _loadMatchSummary() async {
    if (widget.match.homeTeamCode == null || widget.match.awayTeamCode == null) {
      return;
    }

    setState(() => _isLoadingSummary = true);

    try {
      final service = di.sl<LocalMatchSummaryService>();
      final summary = await service.getMatchSummary(
        widget.match.homeTeamCode!,
        widget.match.awayTeamCode!,
      );

      if (mounted) {
        setState(() {
          _matchSummary = summary;
          _isLoadingSummary = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingSummary = false);
      }
    }
  }

  /// Load narrative article from locally-bundled JSON assets.
  /// Falls back gracefully — if no narrative exists, the widget
  /// simply won't show the "Pregame" tab.
  Future<void> _loadMatchNarrative() async {
    if (widget.match.homeTeamCode == null || widget.match.awayTeamCode == null) {
      return;
    }

    try {
      final service = di.sl<MatchNarrativeService>();
      final narrative = await service.getNarrative(
        widget.match.homeTeamCode!,
        widget.match.awayTeamCode!,
      );

      if (mounted && narrative != null) {
        setState(() => _matchNarrative = narrative);
      }
    } catch (_) {
      // Non-critical — UI works fine without narrative
    }
  }

  /// Load prediction from LocalPredictionEngine (local data only)
  Future<void> _loadLocalPrediction() async {
    if (widget.match.homeTeamCode == null || widget.match.awayTeamCode == null) {
      return;
    }

    try {
      final engine = di.sl<LocalPredictionEngine>();
      final prediction = await engine.generatePrediction(match: widget.match);

      if (mounted) {
        setState(() => _localPrediction = prediction);
      }
    } catch (_) {
      // Silently fail — the Firestore prediction tab is the fallback
    }
  }

  /// Find the WorldCupVenue matching this match's venue name
  void _findMatchVenue() {
    if (widget.match.venueName == null) return;

    final venueName = widget.match.venueName!.toLowerCase();
    final venueCity = widget.match.venueCity?.toLowerCase() ?? '';

    for (final venue in WorldCupVenues.all) {
      if (venue.name.toLowerCase().contains(venueName) ||
          venueName.contains(venue.name.toLowerCase()) ||
          venue.worldCupName?.toLowerCase().contains(venueName) == true ||
          venue.city.toLowerCase() == venueCity) {
        setState(() {
          _matchVenue = venue;
        });
        break;
      }
    }
  }

  WorldCupMatch get match => widget.match;

  @override
  Widget build(BuildContext context) {
    Widget page = _buildPage(context);

    if (_matchVenue != null) {
      return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => di.sl<NearbyVenuesCubit>()
              ..loadNearbyVenues(_matchVenue!),
          ),
          BlocProvider(
            create: (context) => di.sl<VenueFilterCubit>(),
          ),
        ],
        child: page,
      );
    }

    return page;
  }

  Widget _buildPage(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.mainGradientDecoration,
        child: CustomScrollView(
        slivers: [
          // App bar with match info
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              if (match.status == MatchStatus.scheduled)
                ReminderButton(
                  match: match,
                  iconSize: 24,
                  activeColor: Colors.amber,
                  inactiveColor: Colors.white70,
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: MatchHeaderWidget(
                match: match,
                stageColor: _getStageColor(),
              ),
            ),
          ),

          // Match details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Live indicator
                  if (match.isLive) ...[
                    _buildLiveIndicatorBar(),
                    const SizedBox(height: 16),
                  ],

                  // Match info card
                  MatchInfoCard(match: match),
                  const SizedBox(height: 16),

                  // Extra time / Penalties info
                  if (match.hasExtraTime || match.hasPenalties)
                    MatchExtraTimeCard(match: match),

                  // Venue card
                  if (match.venueName != null) ...[
                    const SizedBox(height: 16),
                    MatchVenueCard(
                      venueName: match.venueName!,
                      venueCity: match.venueCity,
                    ),
                  ],

                  // Nearby venues (bars, restaurants near stadium)
                  if (_matchVenue != null) ...[
                    const SizedBox(height: 24),
                    NearbyVenuesWidget(
                      maxItems: _showAllNearbyVenues ? null : _defaultNearbyVenuesCount,
                      matchId: match.matchId,
                    ),
                    _buildShowMoreNearbyVenuesButton(),
                  ],

                  // Watch Parties section
                  const SizedBox(height: 16),
                  MatchWatchPartiesCard(match: match),

                  // Head to head
                  const SizedBox(height: 16),
                  _buildHeadToHeadSection(),

                  // Probability bar (visual win/draw/loss gauge) — the whole
                  // "WIN PROBABILITY" card is hidden in non-gambling builds,
                  // not just the bar itself.
                  if (FeatureFlags.aiProbabilityEnabled &&
                      _localPrediction != null &&
                      match.homeTeamCode != null &&
                      match.awayTeamCode != null) ...[
                    const SizedBox(height: 16),
                    _buildProbabilityBar(),
                  ],

                  // AI Match Summary
                  const SizedBox(height: 16),
                  _buildAIMatchSummarySection(),

                  // Penalty Kick Challenge promo (upcoming matches only)
                  if (match.status == MatchStatus.scheduled) ...[
                    const SizedBox(height: 16),
                    PenaltyKickPromoCard(
                      homeTeamName: match.homeTeamName,
                      awayTeamName: match.awayTeamName,
                    ),
                  ],

                  // Match stats
                  if (match.status == MatchStatus.completed ||
                      match.status == MatchStatus.inProgress) ...[
                    const SizedBox(height: 16),
                    MatchStatsWidget(stageColor: _getStageColor()),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildLiveIndicatorBar() {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha:0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha:0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const LiveIndicator(size: 10),
          const SizedBox(width: 8),
          Text(
            match.minute != null
                ? l10n.matchInProgressWithMinute(match.minute.toString())
                : l10n.matchInProgress,
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShowMoreNearbyVenuesButton() {
    return BlocBuilder<NearbyVenuesCubit, NearbyVenuesState>(
      buildWhen: (prev, curr) =>
          prev.venues != curr.venues || prev.selectedType != curr.selectedType,
      builder: (context, state) {
        final totalVenues = state.filteredVenues.length;

        if (totalVenues <= _defaultNearbyVenuesCount) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Center(
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _showAllNearbyVenues = !_showAllNearbyVenues;
                });
              },
              icon: Icon(
                _showAllNearbyVenues ? Icons.expand_less : Icons.expand_more,
                color: AppTheme.primaryPurple,
              ),
              label: Text(
                _showAllNearbyVenues
                    ? AppLocalizations.of(context).showLess
                    : AppLocalizations.of(context).showAllVenues(totalVenues),
                style: const TextStyle(
                  color: AppTheme.primaryPurple,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeadToHeadSection() {
    if (match.homeTeamCode == null || match.awayTeamCode == null) {
      return const SizedBox.shrink();
    }

    return MatchupPreviewWidget(
      team1Code: match.homeTeamCode!,
      team2Code: match.awayTeamCode!,
      team1Name: match.homeTeamName,
      team2Name: match.awayTeamName,
      team1FlagUrl: match.homeTeamFlagUrl,
      team2FlagUrl: match.awayTeamFlagUrl,
    );
  }

  Widget _buildProbabilityBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryPurple.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(
                Icons.bar_chart_rounded,
                color: AppTheme.primaryPurple,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'WIN PROBABILITY',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ProbabilityBar(
            prediction: _localPrediction!,
            homeTeamName: match.homeTeamName,
            awayTeamName: match.awayTeamName,
          ),
        ],
      ),
    );
  }

  Widget _buildAIMatchSummarySection() {
    if (_isLoadingSummary) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppTheme.backgroundElevated,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryPurple,
          ),
        ),
      );
    }

    // Show a teaser card when local research hasn't been written yet.
    // This is temporary — every match will eventually have a JSON file.
    if (_matchSummary == null) {
      return _buildAnalysisComingSoon();
    }

    return FanPassFeatureGate(
      feature: FanPassFeature.aiMatchInsights,
      customMessage: AppLocalizations.of(context).aiMatchAnalysisGate,
      child: AIMatchSummaryWidget(
        summary: _matchSummary!,
        initiallyExpanded: false,
        homeTeamCode: match.homeTeamCode,
        localPrediction: _localPrediction,
        narrative: _matchNarrative,
      ),
    );
  }

  /// Shown when a match hasn't had its research file written yet.
  Widget _buildAnalysisComingSoon() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryPurple.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.analytics_outlined,
            color: AppTheme.primaryPurple.withValues(alpha: 0.7),
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Match Analysis',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'In-depth analysis for this match is being researched and will be available soon.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStageColor() {
    switch (match.stage) {
      case MatchStage.groupStage:
        return Colors.blue.shade700;
      case MatchStage.roundOf32:
        return Colors.teal.shade700;
      case MatchStage.roundOf16:
        return Colors.green.shade700;
      case MatchStage.quarterFinal:
        return Colors.orange.shade700;
      case MatchStage.semiFinal:
        return Colors.purple.shade700;
      case MatchStage.thirdPlace:
        return Colors.brown.shade700;
      case MatchStage.final_:
        return Colors.amber.shade800;
    }
  }
}

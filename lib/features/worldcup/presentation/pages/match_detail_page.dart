import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/app_theme.dart';
import '../../../../injection_container.dart' as di;
import '../../../../l10n/app_localizations.dart';
import '../../data/datasources/world_cup_firestore_datasource.dart';
import '../../domain/entities/entities.dart';
import '../bloc/nearby_venues_cubit.dart';
import '../widgets/widgets.dart';
import '../../../venue_portal/venue_portal.dart';

/// Detailed view of a World Cup match
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
  bool _isLoadingSummary = false;
  bool _showAllNearbyVenues = false;
  static const int _defaultNearbyVenuesCount = 4;

  @override
  void initState() {
    super.initState();
    _findMatchVenue();
    _loadMatchSummary();
  }

  /// Load AI match summary from Firestore
  Future<void> _loadMatchSummary() async {
    if (widget.match.homeTeamCode == null || widget.match.awayTeamCode == null) {
      return;
    }

    setState(() => _isLoadingSummary = true);

    try {
      final datasource = WorldCupFirestoreDataSource();
      final summary = await datasource.getMatchSummary(
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

                  // AI Match Summary
                  const SizedBox(height: 16),
                  _buildAIMatchSummarySection(),

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

    if (_matchSummary == null) {
      return const SizedBox.shrink();
    }

    return FanPassFeatureGate(
      feature: FanPassFeature.aiMatchInsights,
      customMessage: AppLocalizations.of(context).aiMatchAnalysisGate,
      child: AIMatchSummaryWidget(
        summary: _matchSummary!,
        initiallyExpanded: false,
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

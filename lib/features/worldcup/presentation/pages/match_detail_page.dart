import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../config/app_theme.dart';
import '../../../../injection_container.dart' as di;
import '../../data/datasources/world_cup_firestore_datasource.dart';
import '../../domain/entities/entities.dart';
import '../bloc/nearby_venues_cubit.dart';
import '../widgets/widgets.dart';
import '../../../watch_party/presentation/bloc/watch_party_bloc.dart';
import '../../../watch_party/presentation/screens/screens.dart';
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
    // Debug output removed

    if (widget.match.homeTeamCode == null || widget.match.awayTeamCode == null) {
      // Debug output removed
      return;
    }

    setState(() => _isLoadingSummary = true);

    try {
      final datasource = WorldCupFirestoreDataSource();
      final summary = await datasource.getMatchSummary(
        widget.match.homeTeamCode!,
        widget.match.awayTeamCode!,
      );

      // Debug output removed

      if (mounted) {
        setState(() {
          _matchSummary = summary;
          _isLoadingSummary = false;
        });
      }
    } catch (e) {
      // Debug output removed
      if (mounted) {
        setState(() => _isLoadingSummary = false);
      }
    }
  }

  /// Find the WorldCupVenue matching this match's venue name
  void _findMatchVenue() {
    if (widget.match.venueName == null) {
      // Debug output removed
      return;
    }

    // Try to find venue by matching name or city
    final venueName = widget.match.venueName!.toLowerCase();
    final venueCity = widget.match.venueCity?.toLowerCase() ?? '';

    // Debug output removed

    for (final venue in WorldCupVenues.all) {
      if (venue.name.toLowerCase().contains(venueName) ||
          venueName.contains(venue.name.toLowerCase()) ||
          venue.worldCupName?.toLowerCase().contains(venueName) == true ||
          venue.city.toLowerCase() == venueCity) {
        // Debug output removed
        setState(() {
          _matchVenue = venue;
        });
        break;
      }
    }

    if (_matchVenue == null) {
      // Debug output removed
    }
  }

  WorldCupMatch get match => widget.match;

  @override
  Widget build(BuildContext context) {
    // Wrap with BlocProviders for NearbyVenuesCubit and VenueFilterCubit if we have a venue
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
              // Reminder button for scheduled matches
              if (match.status == MatchStatus.scheduled)
                ReminderButton(
                  match: match,
                  iconSize: 24,
                  activeColor: Colors.amber,
                  inactiveColor: Colors.white70,
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _getStageColor().withOpacity(0.8),
                      _getStageColor(),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Stage badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            match.stageDisplayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (match.group != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Group ${match.group}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),

                        // Teams and score
                        Row(
                          children: [
                            // Home team
                            Expanded(
                              child: Column(
                                children: [
                                  TeamFlag(
                                    flagUrl: match.homeFlagUrl,
                                    teamCode: match.homeTeamCode,
                                    size: 56,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    match.homeTeamName ?? match.homeTeamCode ?? 'TBD',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),

                            // Score
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: _buildScoreDisplay(),
                            ),

                            // Away team
                            Expanded(
                              child: Column(
                                children: [
                                  TeamFlag(
                                    flagUrl: match.awayFlagUrl,
                                    teamCode: match.awayTeamCode,
                                    size: 56,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    match.awayTeamName ?? match.awayTeamCode ?? 'TBD',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
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
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const LiveIndicator(size: 10),
                          const SizedBox(width: 8),
                          Text(
                            match.minute != null
                                ? "Match in progress - ${match.minute}'"
                                : 'Match in progress',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Match info card
                  _buildInfoCard(),
                  const SizedBox(height: 16),

                  // Extra time / Penalties info
                  if (match.hasExtraTime || match.hasPenalties)
                    _buildExtraTimeCard(),

                  // Venue card
                  if (match.venueName != null) ...[
                    const SizedBox(height: 16),
                    _buildVenueCard(),
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
                  _buildWatchPartiesSection(),

                  // Head to head (placeholder)
                  const SizedBox(height: 16),
                  _buildHeadToHeadSection(),

                  // AI Match Summary
                  const SizedBox(height: 16),
                  _buildAIMatchSummarySection(),

                  // Match stats (placeholder)
                  if (match.status == MatchStatus.completed ||
                      match.status == MatchStatus.inProgress) ...[
                    const SizedBox(height: 16),
                    _buildMatchStatsSection(),
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

  Widget _buildScoreDisplay() {
    if (match.status == MatchStatus.scheduled) {
      return Column(
        children: [
          Text(
            'vs',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          if (match.dateTime != null)
            Text(
              DateFormat.jm().format(match.dateTime!),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${match.homeScore ?? 0}',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: match.isLive ? Colors.red : Colors.black,
              ),
            ),
            Text(
              ' - ',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade400,
              ),
            ),
            Text(
              '${match.awayScore ?? 0}',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: match.isLive ? Colors.red : Colors.black,
              ),
            ),
          ],
        ),
        if (match.status == MatchStatus.completed)
          Text(
            'Full Time',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        if (match.status == MatchStatus.halfTime)
          Text(
            'Half Time',
            style: TextStyle(
              fontSize: 11,
              color: Colors.orange.shade700,
            ),
          ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(
              Icons.numbers,
              'Match Number',
              '${match.matchNumber}',
            ),
            Divider(color: Colors.white.withOpacity(0.1)),
            _buildInfoRow(
              Icons.calendar_today,
              'Date',
              match.dateTime != null
                  ? DateFormat('EEEE, MMMM d, yyyy').format(match.dateTime!)
                  : 'TBD',
            ),
            Divider(color: Colors.white.withOpacity(0.1)),
            _buildInfoRow(
              Icons.schedule,
              'Kick-off',
              match.dateTime != null
                  ? DateFormat.jm().format(match.dateTime!)
                  : 'TBD',
            ),
            Divider(color: Colors.white.withOpacity(0.1)),
            _buildInfoRow(
              Icons.emoji_events,
              'Stage',
              match.stageDisplayName,
            ),
            if (match.group != null) ...[
              Divider(color: Colors.white.withOpacity(0.1)),
              _buildInfoRow(
                Icons.grid_view,
                'Group',
                'Group ${match.group}',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.white60),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white60,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExtraTimeCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryOrange.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryOrange.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.timer, color: AppTheme.primaryOrange),
                SizedBox(width: 8),
                Text(
                  'Extra Time & Penalties',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (match.hasExtraTime)
              const Text(
                'Match went to extra time (AET)',
                style: TextStyle(color: AppTheme.primaryOrange),
              ),
            if (match.hasPenalties) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    match.homeTeamCode ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryOrange.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${match.homePenaltyScore} - ${match.awayPenaltyScore}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryOrange,
                      ),
                    ),
                  ),
                  Text(
                    match.awayTeamCode ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  'Penalty Shootout',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.primaryOrange.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVenueCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to venue detail
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.stadium,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        match.venueName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      if (match.venueCity != null)
                        Text(
                          match.venueCity!,
                          style: const TextStyle(
                            color: Colors.white60,
                          ),
                        ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.white38,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShowMoreNearbyVenuesButton() {
    return BlocBuilder<NearbyVenuesCubit, NearbyVenuesState>(
      builder: (context, state) {
        final totalVenues = state.filteredVenues.length;

        // Don't show button if there are fewer venues than the limit
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
                    ? 'Show less'
                    : 'Show all $totalVenues venues',
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
    // Only show if both teams have valid codes
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
    // Show loading indicator while fetching
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

    // Show nothing if no summary available
    if (_matchSummary == null) {
      return const SizedBox.shrink();
    }

    // Gate AI Match Insights behind Superfan Pass
    return FanPassFeatureGate(
      feature: FanPassFeature.aiMatchInsights,
      customMessage: 'Get AI-powered match analysis, historical insights, and key player matchups with Superfan Pass.',
      child: AIMatchSummaryWidget(
        summary: _matchSummary!,
        initiallyExpanded: false,
      ),
    );
  }

  Widget _buildMatchStatsSection() {
    // Gate Advanced Stats behind Fan Pass
    return FanPassFeatureGate(
      feature: FanPassFeature.advancedStats,
      customMessage: 'Unlock detailed match statistics including possession, shots, corners, and more.',
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.backgroundCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.bar_chart, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Match Statistics',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildStatBar('Possession', 55, 45),
              const SizedBox(height: 12),
              _buildStatBar('Shots', 12, 8),
              const SizedBox(height: 12),
              _buildStatBar('Shots on Target', 5, 3),
              const SizedBox(height: 12),
              _buildStatBar('Corners', 6, 4),
              const SizedBox(height: 12),
              _buildStatBar('Fouls', 10, 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBar(String label, int home, int away) {
    final total = home + away;
    final homePercent = total > 0 ? home / total : 0.5;

    return Column(
      children: [
        Row(
          children: [
            Text(
              '$home',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white60,
                ),
              ),
            ),
            Text(
              '$away',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              flex: (homePercent * 100).round(),
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: _getStageColor(),
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(3),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 2),
            Expanded(
              flex: ((1 - homePercent) * 100).round(),
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(3),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWatchPartiesSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryPurple.withOpacity(0.2),
            AppTheme.secondaryRose.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToWatchParties(),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryPurple, AppTheme.secondaryRose],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.groups,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Watch Parties',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Find or create a watch party for this match',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToWatchParties() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (context) => di.sl<WatchPartyBloc>()
            ..add(LoadPublicWatchPartiesEvent(gameId: match.matchId)),
          child: WatchPartiesDiscoveryScreen(
            gameId: match.matchId,
            gameName: '${match.homeTeamName ?? match.homeTeamCode ?? 'TBD'} vs ${match.awayTeamName ?? match.awayTeamCode ?? 'TBD'}',
            gameDateTime: match.dateTime,
          ),
        ),
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

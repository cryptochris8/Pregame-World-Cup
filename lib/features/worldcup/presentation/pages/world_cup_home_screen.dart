import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/app_theme.dart';
import '../../../../core/widgets/banner_ad_widget.dart';
import '../../domain/entities/entities.dart';
import '../bloc/bloc.dart';
import '../widgets/widgets.dart';
import '../screens/fan_pass_screen.dart';
import '../screens/tournament_leaderboards_screen.dart';
import '../screens/player_comparison_screen.dart';
import 'match_detail_page.dart';
import 'team_detail_page.dart';
import 'predictions_page.dart';
import '../../../../presentation/screens/player_spotlight_screen.dart';
import '../../../../presentation/screens/manager_profiles_screen.dart';
import '../../../../injection_container.dart' as di;
import '../../../watch_party/presentation/bloc/watch_party_bloc.dart';
import '../../../watch_party/presentation/screens/screens.dart';

/// Main World Cup screen with internal tab navigation
/// This screen is embedded in the main app navigation
class WorldCupHomeScreen extends StatefulWidget {
  const WorldCupHomeScreen({super.key});

  @override
  State<WorldCupHomeScreen> createState() => _WorldCupHomeScreenState();
}

class _WorldCupHomeScreenState extends State<WorldCupHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _tabs = const [
    Tab(icon: Icon(Icons.sports_soccer), text: 'Matches'),
    Tab(icon: Icon(Icons.grid_view), text: 'Groups'),
    Tab(icon: Icon(Icons.flag), text: 'Teams'),
    Tab(icon: Icon(Icons.person), text: 'Players'),
    Tab(icon: Icon(Icons.sports), text: 'Managers'),
    Tab(icon: Icon(Icons.favorite), text: 'Favorites'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/logos/pregame_logo.png',
                height: 32,
                width: 32,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryOrange, AppTheme.accentGold],
                ),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryOrange.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                '2026',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'World Cup',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          // Live matches indicator (priority - always visible)
          BlocBuilder<MatchListCubit, MatchListState>(
            builder: (context, state) {
              if (state.hasLiveMatches) {
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: ActionChip(
                    avatar: const LiveIndicator(size: 8),
                    label: Text(
                      '${state.liveCount} Live',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    onPressed: () {
                      _tabController.animateTo(0);
                      context.read<MatchListCubit>().setFilter(MatchListFilter.live);
                    },
                    backgroundColor: Colors.red.withOpacity(0.3),
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          // Fan Pass button (important - always visible)
          IconButton(
            icon: const Icon(Icons.star, color: Colors.amber, size: 22),
            tooltip: 'Fan Pass',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FanPassScreen()),
            ),
          ),
          // More options menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: AppTheme.backgroundCard,
            onSelected: (value) {
              switch (value) {
                case 'leaderboards':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TournamentLeaderboardsScreen()),
                  );
                  break;
                case 'compare':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PlayerComparisonScreen()),
                  );
                  break;
                case 'watch_parties':
                  _navigateToWatchParties(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'leaderboards',
                child: Row(
                  children: [
                    Icon(Icons.emoji_events, color: AppTheme.accentGold, size: 20),
                    SizedBox(width: 12),
                    Text('Leaderboards', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'compare',
                child: Row(
                  children: [
                    Icon(Icons.compare_arrows, color: Colors.white, size: 20),
                    SizedBox(width: 12),
                    Text('Compare Players', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'watch_parties',
                child: Row(
                  children: [
                    Icon(Icons.groups, color: Colors.white, size: 20),
                    SizedBox(width: 12),
                    Text('Watch Parties', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: AppTheme.primaryOrange,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Container(
        decoration: AppTheme.mainGradientDecoration,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _MatchesTab(
                      onMatchTap: (match) => _navigateToMatchDetail(context, match),
                    ),
                    _GroupsTab(
                      onTeamTap: (teamCode) => _navigateToTeamByCode(context, teamCode),
                    ),
                    _TeamsTab(
                      onTeamTap: (team) => _navigateToTeamDetail(context, team),
                    ),
                    const PlayerSpotlightScreen(),
                    const ManagerProfilesScreen(),
                    _FavoritesTab(
                      onMatchTap: (match) => _navigateToMatchDetail(context, match),
                      onTeamTap: (team) => _navigateToTeamDetail(context, team),
                    ),
                  ],
                ),
              ),
              // Banner ad at bottom (hidden for premium users)
              const BannerAdWidget(),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToMatchDetail(BuildContext context, WorldCupMatch match) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MatchDetailPage(match: match),
      ),
    );
  }

  void _navigateToTeamDetail(BuildContext context, NationalTeam team) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TeamDetailPage(team: team),
      ),
    );
  }

  void _navigateToTeamByCode(BuildContext context, String teamCode) async {
    final cubit = context.read<TeamsCubit>();
    final team = cubit.state.getTeamByCode(teamCode);
    if (team != null) {
      _navigateToTeamDetail(context, team);
    }
  }

  void _navigateToWatchParties(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (context) => di.sl<WatchPartyBloc>()
            ..add(LoadPublicWatchPartiesEvent()),
          child: const MyWatchPartiesScreen(),
        ),
      ),
    );
  }
}

/// Matches tab content
class _MatchesTab extends StatelessWidget {
  final void Function(WorldCupMatch) onMatchTap;

  const _MatchesTab({required this.onMatchTap});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MatchListCubit, MatchListState>(
      builder: (context, matchState) {
        if (matchState.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (matchState.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  matchState.errorMessage!,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: AppTheme.buttonGradientDecoration,
                  child: ElevatedButton(
                    onPressed: () => context.read<MatchListCubit>().loadMatches(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: const Text('Retry'),
                  ),
                ),
              ],
            ),
          );
        }

        return BlocBuilder<FavoritesCubit, FavoritesState>(
          builder: (context, favoritesState) {
            return BlocBuilder<PredictionsCubit, PredictionsState>(
              builder: (context, predictionsState) {
                // Get favorite match count
                final favoriteMatchIds = favoritesState.preferences.favoriteMatchIds;
                final favoritesCount = matchState.matches
                    .where((m) => favoriteMatchIds.contains(m.matchId))
                    .length;

                // Filter matches - apply favorites filter if selected
                List<WorldCupMatch> displayMatches = matchState.filteredMatches;
                if (matchState.filter == MatchListFilter.favorites) {
                  displayMatches = matchState.matches
                      .where((m) => favoriteMatchIds.contains(m.matchId))
                      .toList();
                }

                return Column(
                  children: [
                    // Filter chips
                    MatchFilterChips(
                      selectedFilter: matchState.filter,
                      onFilterChanged: (filter) =>
                          context.read<MatchListCubit>().setFilter(filter),
                      liveCount: matchState.liveCount,
                      upcomingCount: matchState.upcomingCount,
                      completedCount: matchState.completedCount,
                      favoritesCount: favoritesCount,
                    ),

                    // Match list
                    Expanded(
                      child: displayMatches.isEmpty
                          ? _buildEmptyState(matchState.filter)
                          : RefreshIndicator(
                              onRefresh: () =>
                                  context.read<MatchListCubit>().refreshMatches(),
                              child: ListView.builder(
                                padding: const EdgeInsets.only(bottom: 16),
                                itemCount: displayMatches.length,
                                itemBuilder: (context, index) {
                                  final match = displayMatches[index];
                                  return MatchCard(
                                    match: match,
                                    onTap: () => onMatchTap(match),
                                    isFavorite: favoritesState.isMatchFavorite(match.matchId),
                                    onFavoriteToggle: () => context
                                        .read<FavoritesCubit>()
                                        .toggleFavoriteMatch(match.matchId),
                                    prediction: predictionsState.getPredictionForMatch(match.matchId),
                                    onPrediction: (homeScore, awayScore) => context
                                        .read<PredictionsCubit>()
                                        .savePredictionForMatch(match, homeScore: homeScore, awayScore: awayScore),
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(MatchListFilter filter) {
    String message;
    IconData icon;

    switch (filter) {
      case MatchListFilter.favorites:
        message = 'No favorite matches yet';
        icon = Icons.favorite_border;
        break;
      case MatchListFilter.today:
        message = 'No matches scheduled for today';
        icon = Icons.today;
        break;
      case MatchListFilter.live:
        message = 'No live matches right now';
        icon = Icons.play_circle_outline;
        break;
      case MatchListFilter.upcoming:
        message = 'No upcoming matches';
        icon = Icons.schedule;
        break;
      case MatchListFilter.completed:
        message = 'No completed matches yet';
        icon = Icons.check_circle_outline;
        break;
      default:
        message = 'No matches found';
        icon = Icons.sports_soccer;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.white38),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }
}

/// Groups tab content
class _GroupsTab extends StatelessWidget {
  final void Function(String) onTeamTap;

  const _GroupsTab({required this.onTeamTap});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupStandingsCubit, GroupStandingsState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (state.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  state.errorMessage!,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: AppTheme.buttonGradientDecoration,
                  child: ElevatedButton(
                    onPressed: () =>
                        context.read<GroupStandingsCubit>().loadGroups(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: const Text('Retry'),
                  ),
                ),
              ],
            ),
          );
        }

        if (state.groups.isEmpty) {
          return const Center(
            child: Text(
              'No group data available',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => context.read<GroupStandingsCubit>().refreshGroups(),
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: state.groups.length,
            itemBuilder: (context, index) {
              final group = state.groups[index];
              return StandingsTable(
                group: group,
                compact: true,
                onTeamTap: (teamCode) => () => onTeamTap(teamCode),
              );
            },
          ),
        );
      },
    );
  }
}

/// Bracket tab content
class _BracketTab extends StatelessWidget {
  const _BracketTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BracketCubit, BracketState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (state.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  state.errorMessage!,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: AppTheme.buttonGradientDecoration,
                  child: ElevatedButton(
                    onPressed: () => context.read<BracketCubit>().loadBracket(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: const Text('Retry'),
                  ),
                ),
              ],
            ),
          );
        }

        if (state.bracket == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_tree, size: 64, color: Colors.white38),
                const SizedBox(height: 16),
                const Text(
                  'Knockout bracket not available yet',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white60,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Check back after group stage',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: Colors.white,
          backgroundColor: AppTheme.backgroundCard,
          onRefresh: () => context.read<BracketCubit>().refreshBracket(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current round indicator
                if (state.currentActiveRound != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryEmerald.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.secondaryEmerald.withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.play_arrow, color: AppTheme.secondaryEmerald),
                        const SizedBox(width: 8),
                        Text(
                          'Current: ${_getStageName(state.currentActiveRound!)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Round sections
                _buildRoundSection('Round of 32', state.bracket!.roundOf32),
                _buildRoundSection('Round of 16', state.bracket!.roundOf16),
                _buildRoundSection('Quarter-Finals', state.bracket!.quarterFinals),
                _buildRoundSection('Semi-Finals', state.bracket!.semiFinals),
                if (state.bracket!.thirdPlace != null)
                  _buildRoundSection('Third Place', [state.bracket!.thirdPlace!]),
                if (state.bracket!.finalMatch != null)
                  _buildRoundSection('Final', [state.bracket!.finalMatch!]),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoundSection(String title, List<BracketMatch> matches) {
    if (matches.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: matches.map((match) => BracketMatchCard(match: match)).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  String _getStageName(MatchStage stage) {
    switch (stage) {
      case MatchStage.roundOf32:
        return 'Round of 32';
      case MatchStage.roundOf16:
        return 'Round of 16';
      case MatchStage.quarterFinal:
        return 'Quarter-Finals';
      case MatchStage.semiFinal:
        return 'Semi-Finals';
      case MatchStage.thirdPlace:
        return 'Third Place';
      case MatchStage.final_:
        return 'Final';
      default:
        return '';
    }
  }
}

/// Teams tab content
class _TeamsTab extends StatelessWidget {
  final void Function(NationalTeam) onTeamTap;

  const _TeamsTab({required this.onTeamTap});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TeamsCubit, TeamsState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (state.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  state.errorMessage!,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: AppTheme.buttonGradientDecoration,
                  child: ElevatedButton(
                    onPressed: () => context.read<TeamsCubit>().loadTeams(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: const Text('Retry'),
                  ),
                ),
              ],
            ),
          );
        }

        return BlocBuilder<FavoritesCubit, FavoritesState>(
          builder: (context, favoritesState) {
            // Get favorite team codes
            final favoriteTeamCodes = favoritesState.preferences.favoriteTeamCodes;

            // Filter teams by favorites if enabled
            List<NationalTeam> displayTeams = state.displayTeams;
            if (state.showFavoritesOnly) {
              displayTeams = displayTeams
                  .where((t) => favoriteTeamCodes.contains(t.fifaCode))
                  .toList();
            }

            // Count favorites
            final favoritesCount = state.teams
                .where((t) => favoriteTeamCodes.contains(t.fifaCode))
                .length;

            return Column(
              children: [
                // Favorites filter chip
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      FilterChip(
                        selected: state.showFavoritesOnly,
                        onSelected: (_) =>
                            context.read<TeamsCubit>().toggleShowFavoritesOnly(),
                        avatar: Icon(
                          state.showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: state.showFavoritesOnly ? AppTheme.secondaryRose : Colors.white70,
                        ),
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Favorites',
                              style: TextStyle(
                                color: state.showFavoritesOnly ? Colors.white : Colors.white70,
                              ),
                            ),
                            if (favoritesCount > 0) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppTheme.secondaryRose,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$favoritesCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        backgroundColor: AppTheme.backgroundCard,
                        selectedColor: AppTheme.secondaryRose.withOpacity(0.3),
                        checkmarkColor: AppTheme.secondaryRose,
                        side: BorderSide(
                          color: state.showFavoritesOnly
                              ? AppTheme.secondaryRose
                              : Colors.white24,
                        ),
                      ),
                    ],
                  ),
                ),

                // Sort options
                TeamSortChips(
                  selectedOption: state.sortOption,
                  onOptionChanged: (option) =>
                      context.read<TeamsCubit>().setSortOption(option),
                ),

                // Confederation filter
                ConfederationFilterChips(
                  selectedConfederation: state.selectedConfederation,
                  onConfederationChanged: (conf) =>
                      context.read<TeamsCubit>().filterByConfederation(conf),
                  counts: context.read<TeamsCubit>().getConfederationCounts(),
                ),

                // Team count
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        '${displayTeams.length} of 48 teams',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                      if (state.selectedConfederation != null || state.showFavoritesOnly)
                        TextButton(
                          onPressed: () => context.read<TeamsCubit>().clearFilters(),
                          child: const Text(
                            'Clear',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.primaryOrange,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Teams list
                Expanded(
                  child: displayTeams.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.favorite_border, size: 64, color: Colors.white38),
                              const SizedBox(height: 16),
                              const Text(
                                'No favorite teams yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white60,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Tap the heart icon on any team to add it to your favorites',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white38,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () => context.read<TeamsCubit>().refreshTeams(),
                          child: ListView.separated(
                            itemCount: displayTeams.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final team = displayTeams[index];
                              return TeamTile(
                                team: team,
                                onTap: () => onTeamTap(team),
                                isFavorite: favoritesState.isTeamFavorite(team.fifaCode),
                                onFavoriteToggle: () => context
                                    .read<FavoritesCubit>()
                                    .toggleFavoriteTeam(team.fifaCode),
                              );
                            },
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// Favorites tab content - shows favorite matches and teams
class _FavoritesTab extends StatelessWidget {
  final void Function(WorldCupMatch) onMatchTap;
  final void Function(NationalTeam) onTeamTap;

  const _FavoritesTab({
    required this.onMatchTap,
    required this.onTeamTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, favoritesState) {
        return BlocBuilder<PredictionsCubit, PredictionsState>(
          builder: (context, predictionsState) {
            final favoriteMatchIds = favoritesState.preferences.favoriteMatchIds;
            final favoriteTeamCodes = favoritesState.preferences.favoriteTeamCodes;

            // Check if there are any favorites or predictions
            final hasFavorites = favoriteMatchIds.isNotEmpty || favoriteTeamCodes.isNotEmpty;
            final hasPredictions = predictionsState.predictions.isNotEmpty;

            if (!hasFavorites && !hasPredictions) {
              return _buildEmptyState(context);
            }

            return RefreshIndicator(
              onRefresh: () async {
                final matchCubit = context.read<MatchListCubit>();
                final teamsCubit = context.read<TeamsCubit>();
                await matchCubit.refreshMatches();
                await teamsCubit.refreshTeams();
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Prediction Stats Section
                    if (hasPredictions) ...[
                      InkWell(
                        onTap: () => _navigateToPredictions(context),
                        borderRadius: BorderRadius.circular(12),
                        child: PredictionStatsCard(stats: predictionsState.stats),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => _navigateToPredictions(context),
                          icon: const Icon(Icons.arrow_forward, size: 16),
                          label: const Text('View All Predictions'),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Favorite Matches Section
                    if (favoriteMatchIds.isNotEmpty) ...[
                  _buildSectionHeader(
                    context,
                    icon: Icons.sports_soccer,
                    title: 'Favorite Matches',
                    count: favoriteMatchIds.length,
                  ),
                  const SizedBox(height: 8),
                  BlocBuilder<MatchListCubit, MatchListState>(
                    builder: (context, matchState) {
                      return BlocBuilder<PredictionsCubit, PredictionsState>(
                        builder: (context, predictionsState) {
                          final favoriteMatches = matchState.matches
                              .where((m) => favoriteMatchIds.contains(m.matchId))
                              .toList();

                          if (favoriteMatches.isEmpty && matchState.isLoading) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          return Column(
                            children: favoriteMatches.map((match) => MatchCard(
                              match: match,
                              onTap: () => onMatchTap(match),
                              isFavorite: true,
                              onFavoriteToggle: () => context
                                  .read<FavoritesCubit>()
                                  .toggleFavoriteMatch(match.matchId),
                              prediction: predictionsState.getPredictionForMatch(match.matchId),
                              onPrediction: (homeScore, awayScore) => context
                                  .read<PredictionsCubit>()
                                  .savePredictionForMatch(match, homeScore: homeScore, awayScore: awayScore),
                            )).toList(),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],

                // Favorite Teams Section
                if (favoriteTeamCodes.isNotEmpty) ...[
                  _buildSectionHeader(
                    context,
                    icon: Icons.flag,
                    title: 'Favorite Teams',
                    count: favoriteTeamCodes.length,
                  ),
                  const SizedBox(height: 8),
                  BlocBuilder<TeamsCubit, TeamsState>(
                    builder: (context, teamsState) {
                      final favoriteTeams = teamsState.teams
                          .where((t) => favoriteTeamCodes.contains(t.fifaCode))
                          .toList();

                      if (favoriteTeams.isEmpty && teamsState.isLoading) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      return Card(
                        child: Column(
                          children: favoriteTeams.asMap().entries.map((entry) {
                            final index = entry.key;
                            final team = entry.value;
                            return Column(
                              children: [
                                TeamTile(
                                  team: team,
                                  onTap: () => onTeamTap(team),
                                  isFavorite: true,
                                  onFavoriteToggle: () => context
                                      .read<FavoritesCubit>()
                                      .toggleFavoriteTeam(team.fifaCode),
                                ),
                                if (index < favoriteTeams.length - 1)
                                  const Divider(height: 1),
                              ],
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                  ],
                ],
              ),
            ),
          );
        },
      );
      },
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    required int count,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.secondaryRose),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppTheme.secondaryRose.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.secondaryRose.withOpacity(0.5)),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryRose,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.secondaryRose.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.secondaryRose.withOpacity(0.3)),
              ),
              child: const Icon(
                Icons.favorite_border,
                size: 64,
                color: AppTheme.secondaryRose,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Favorites Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tap the heart icon on any match or team\nto add them to your favorites',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white60,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildHintChip(
                  icon: Icons.sports_soccer,
                  label: 'Browse Matches',
                  onTap: () {
                    // Navigate to Matches tab
                    DefaultTabController.of(context).animateTo(0);
                  },
                ),
                const SizedBox(width: 12),
                _buildHintChip(
                  icon: Icons.flag,
                  label: 'Browse Teams',
                  onTap: () {
                    // Navigate to Teams tab
                    DefaultTabController.of(context).animateTo(2);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHintChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: AppTheme.primaryOrange),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      onPressed: onTap,
      backgroundColor: AppTheme.backgroundCard,
      side: BorderSide(color: AppTheme.primaryOrange.withOpacity(0.5)),
    );
  }

  void _navigateToPredictions(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<PredictionsCubit>(),
          child: const PredictionsPage(),
        ),
      ),
    );
  }
}

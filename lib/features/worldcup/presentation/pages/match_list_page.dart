import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/app_theme.dart';
import '../../domain/entities/entities.dart';
import '../bloc/bloc.dart';
import '../widgets/widgets.dart';

/// Page displaying the World Cup match schedule
class MatchListPage extends StatefulWidget {
  const MatchListPage({super.key});

  @override
  State<MatchListPage> createState() => _MatchListPageState();
}

class _MatchListPageState extends State<MatchListPage> {
  @override
  void initState() {
    super.initState();
    context.read<MatchListCubit>().init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Match Schedule', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          BlocBuilder<MatchListCubit, MatchListState>(
            builder: (context, state) {
              if (state.isRefreshing) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  ),
                );
              }
              return IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () => context.read<MatchListCubit>().refreshMatches(),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: AppTheme.mainGradientDecoration,
        child: SafeArea(
          child: BlocBuilder<MatchListCubit, MatchListState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          if (state.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppTheme.secondaryRose),
                  const SizedBox(height: 16),
                  Text(state.errorMessage!, style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryEmerald,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => context.read<MatchListCubit>().loadMatches(),
                    child: const Text('Retry'),
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
                  final favoritesCount = state.matches
                      .where((m) => favoriteMatchIds.contains(m.matchId))
                      .length;

                  // Filter matches - apply favorites filter if selected
                  List<WorldCupMatch> displayMatches = state.filteredMatches;
                  if (state.filter == MatchListFilter.favorites) {
                    displayMatches = state.matches
                        .where((m) => favoriteMatchIds.contains(m.matchId))
                        .toList();
                  }

                  return Column(
                    children: [
                      // Live matches banner
                      if (state.hasLiveMatches)
                        _buildLiveBanner(state.liveMatches),

                      // Filter chips
                      MatchFilterChips(
                        selectedFilter: state.filter,
                        onFilterChanged: (filter) =>
                            context.read<MatchListCubit>().setFilter(filter),
                        liveCount: state.liveCount,
                        upcomingCount: state.upcomingCount,
                        completedCount: state.completedCount,
                        favoritesCount: favoritesCount,
                      ),

                      // Group filter (show when in group stage filter)
                      if (state.filter == MatchListFilter.groupStage)
                        GroupFilterChips(
                          selectedGroup: state.selectedGroup,
                          onGroupChanged: (group) =>
                              context.read<MatchListCubit>().filterByGroup(group),
                        ),

                      // Match list
                      Expanded(
                        child: displayMatches.isEmpty
                            ? _buildEmptyState(state.filter)
                            : RefreshIndicator(
                                color: AppTheme.secondaryEmerald,
                                onRefresh: () =>
                                    context.read<MatchListCubit>().refreshMatches(),
                                child: ListView.builder(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  itemCount: displayMatches.length,
                                  itemBuilder: (context, index) {
                                    final match = displayMatches[index];
                                    return MatchCard(
                                      match: match,
                                      onTap: () => _onMatchTap(match),
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
      ),
        ),
      ),
    );
  }

  Widget _buildLiveBanner(List<WorldCupMatch> liveMatches) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.15),
        border: Border(
          bottom: BorderSide(color: Colors.red.withOpacity(0.3)),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const LiveIndicator(size: 10, label: 'LIVE NOW'),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: liveMatches.map((match) => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () => _onMatchTap(match),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.red.withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            match.homeTeamCode ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          Text(
                            ' ${match.homeScore ?? 0}-${match.awayScore ?? 0} ',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                          ),
                          Text(
                            match.awayTeamCode ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                )).toList(),
              ),
            ),
          ),
        ],
      ),
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
          Icon(icon, size: 64, color: Colors.white.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  void _onMatchTap(WorldCupMatch match) {
    // Navigate to match detail
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${match.homeTeamName} vs ${match.awayTeamName}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

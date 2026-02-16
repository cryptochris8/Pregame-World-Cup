import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../config/theme_helper.dart';
import '../bloc/schedule_bloc.dart';
import '../../domain/entities/game_schedule.dart';
import '../widgets/schedule_game_card.dart';
import '../../../auth/presentation/screens/favorite_teams_screen.dart';

/// Tab displaying the full game schedule with filtering support
class ScheduleGamesTab extends StatelessWidget {
  final bool showLiveOnly;
  final bool showFavoritesOnly;
  final List<String> favoriteTeams;
  final VoidCallback onRefresh;
  final Future<void> Function() onLoadFavoriteTeams;

  const ScheduleGamesTab({
    super.key,
    required this.showLiveOnly,
    required this.showFavoritesOnly,
    required this.favoriteTeams,
    required this.onRefresh,
    required this.onLoadFavoriteTeams,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScheduleBloc, ScheduleState>(
      builder: (context, state) {
        if (state is ScheduleLoading) {
          return _buildLoadingWidget();
        } else if (state is ScheduleError) {
          return _buildErrorWidget(context, state.message);
        } else if (state is ScheduleLoaded) {
          return _buildGamesList(context, state.filteredSchedule);
        } else if (state is UpcomingGamesLoaded) {
          return _buildGamesList(context, state.filteredUpcomingGames);
        } else if (state is WeeklyScheduleLoaded) {
          return _buildWeeklyScheduleWidget(context, state);
        } else {
          return _buildUnknownStateWidget(context);
        }
      },
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String message) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.failedToLoadGames,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<ScheduleBloc>().add(const GetUpcomingGamesEvent(limit: 100));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeHelper.favoriteColor,
            ),
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildGamesList(BuildContext context, List<GameSchedule> games) {
    List<GameSchedule> filteredGames = List.from(games);

    // Apply live filter if needed
    if (showLiveOnly) {
      filteredGames = _applyLiveFilter(filteredGames);
    }

    if (filteredGames.isEmpty) {
      return _buildEmptyGamesWidget(context);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredGames.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ScheduleGameCard(
            game: filteredGames[index],
            favoriteTeams: favoriteTeams,
            onRefresh: onRefresh,
          ),
        );
      },
    );
  }

  Widget _buildWeeklyScheduleWidget(BuildContext context, WeeklyScheduleLoaded state) {
    List<GameSchedule> filteredGames = List.from(state.filteredWeeklySchedule);

    if (showLiveOnly) {
      filteredGames = _applyLiveFilter(filteredGames);
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          color: Colors.orange.withValues(alpha:0.2),
          child: Text(
            AppLocalizations.of(context).testDataWeek(state.year, state.week),
            style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: filteredGames.isEmpty
              ? _buildEmptyWeeklyGamesWidget(context, state.year, state.week)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredGames.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ScheduleGameCard(
                        game: filteredGames[index],
                        favoriteTeams: favoriteTeams,
                        onRefresh: onRefresh,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildUnknownStateWidget(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.unknownState,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.tapToReloadSchedule,
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<ScheduleBloc>().add(const GetUpcomingGamesEvent(limit: 100));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeHelper.favoriteColor,
            ),
            child: Text(l10n.reloadSchedule),
          ),
        ],
      ),
    );
  }

  List<GameSchedule> _applyLiveFilter(List<GameSchedule> games) {
    return games.where((game) =>
      game.isLive == true ||
      game.status?.toLowerCase().contains('progress') == true ||
      game.status?.toLowerCase().contains('quarter') == true ||
      game.status?.toLowerCase().contains('half') == true
    ).toList();
  }

  Widget _buildEmptyGamesWidget(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    String emptyMessage = l10n.noGamesFound;
    if (showFavoritesOnly && favoriteTeams.isNotEmpty) {
      emptyMessage = l10n.noGamesForFavorites;
    } else if (showLiveOnly) {
      emptyMessage = l10n.noLiveGames;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_soccer,
            size: 64,
            color: ThemeHelper.favoriteColor,
          ),
          const SizedBox(height: 16),
          Text(
            emptyMessage,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
            ),
          ),
          if (favoriteTeams.isEmpty && showFavoritesOnly) ...[
            const SizedBox(height: 8),
            Text(
              l10n.setFavoriteTeamsPrompt,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FavoriteTeamsScreen()),
                );
                await onLoadFavoriteTeams();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeHelper.favoriteColor,
              ),
              child: Text(l10n.setFavoriteTeams),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyWeeklyGamesWidget(BuildContext context, int year, int week) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_soccer,
            size: 64,
            color: ThemeHelper.favoriteColor,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).noGamesForWeek(year, week),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

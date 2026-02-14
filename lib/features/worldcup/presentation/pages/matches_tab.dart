import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/app_theme.dart';
import '../../domain/entities/entities.dart';
import '../bloc/bloc.dart';
import '../widgets/widgets.dart';

/// Matches tab content for the World Cup home screen.
/// Displays a date picker, filter chips, and a scrollable list of matches.
class MatchesTab extends StatelessWidget {
  final void Function(WorldCupMatch) onMatchTap;

  const MatchesTab({super.key, required this.onMatchTap});

  /// Calculate match counts per date for the date picker
  Map<DateTime, int> _calculateMatchCounts(List<WorldCupMatch> matches) {
    final Map<DateTime, int> counts = {};
    for (final match in matches) {
      if (match.dateTime != null) {
        // Convert to local time for accurate day grouping
        final localDateTime = match.dateTime!.toLocal();
        final dateOnly = DateTime(
          localDateTime.year,
          localDateTime.month,
          localDateTime.day,
        );
        counts[dateOnly] = (counts[dateOnly] ?? 0) + 1;
      }
    }
    return counts;
  }

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

        // Calculate match counts for date picker
        final matchCounts = _calculateMatchCounts(matchState.matches);

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
                    // Date picker strip
                    DatePickerStrip(
                      selectedDate: matchState.selectedDate,
                      onDateChanged: (date) =>
                          context.read<MatchListCubit>().filterByDate(date),
                      matchCounts: matchCounts,
                    ),

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

                    // Selected date indicator
                    if (matchState.selectedDate != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        color: AppTheme.primaryOrange.withOpacity(0.15),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: AppTheme.primaryOrange,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Showing matches for ${_formatSelectedDate(matchState.selectedDate!)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${displayMatches.length} match${displayMatches.length == 1 ? '' : 'es'}',
                              style: TextStyle(
                                color: AppTheme.primaryOrange,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Match list
                    Expanded(
                      child: displayMatches.isEmpty
                          ? _buildEmptyState(matchState.filter, matchState.selectedDate)
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

  String _formatSelectedDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  Widget _buildEmptyState(MatchListFilter filter, DateTime? selectedDate) {
    String message;
    IconData icon;

    // Check if a specific date is selected with no matches
    if (selectedDate != null) {
      message = 'No matches scheduled for this day';
      icon = Icons.calendar_today;
    } else {
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
          if (selectedDate != null) ...[
            const SizedBox(height: 8),
            Text(
              'Try selecting a different date',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white38,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

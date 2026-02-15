import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/app_theme.dart';
import '../../domain/entities/entities.dart';
import '../bloc/bloc.dart';
import '../widgets/widgets.dart';
import 'predictions_page.dart';

/// Favorites tab content for the World Cup home screen.
/// Shows favorite matches, favorite teams, and prediction stats.
class FavoritesTab extends StatelessWidget {
  final void Function(WorldCupMatch) onMatchTap;
  final void Function(NationalTeam) onTeamTap;

  const FavoritesTab({
    super.key,
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
            color: AppTheme.secondaryRose.withValues(alpha:0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.secondaryRose.withValues(alpha:0.5)),
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
                color: AppTheme.secondaryRose.withValues(alpha:0.2),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.secondaryRose.withValues(alpha:0.3)),
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
      side: BorderSide(color: AppTheme.primaryOrange.withValues(alpha:0.5)),
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

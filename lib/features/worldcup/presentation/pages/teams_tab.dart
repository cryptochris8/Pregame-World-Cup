import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/app_theme.dart';
import '../../domain/entities/entities.dart';
import '../bloc/bloc.dart';
import '../widgets/widgets.dart';

/// Teams tab content for the World Cup home screen.
/// Displays all 48 teams with favorites filtering, sort options,
/// and confederation filters.
class TeamsTab extends StatelessWidget {
  final void Function(NationalTeam) onTeamTap;

  const TeamsTab({super.key, required this.onTeamTap});

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
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.favorite_border, size: 64, color: Colors.white38),
                              SizedBox(height: 16),
                              Text(
                                'No favorite teams yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white60,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
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

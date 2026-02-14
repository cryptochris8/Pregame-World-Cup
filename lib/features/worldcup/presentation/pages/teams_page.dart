import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/app_theme.dart';
import '../../domain/entities/entities.dart';
import '../bloc/bloc.dart';
import '../widgets/widgets.dart';

/// Page displaying all World Cup national teams
class TeamsPage extends StatefulWidget {
  const TeamsPage({super.key});

  @override
  State<TeamsPage> createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
  final _searchController = TextEditingController();
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    context.read<TeamsCubit>().init();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Teams', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view, color: Colors.white),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
          BlocBuilder<TeamsCubit, TeamsState>(
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
                onPressed: () => context.read<TeamsCubit>().refreshTeams(),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: AppTheme.mainGradientDecoration,
        child: SafeArea(
          child: BlocBuilder<TeamsCubit, TeamsState>(
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
                    onPressed: () => context.read<TeamsCubit>().loadTeams(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search teams...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    prefixIcon: const Icon(Icons.search, color: Colors.white60),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white60),
                            onPressed: () {
                              _searchController.clear();
                              context.read<TeamsCubit>().search(null);
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.secondaryEmerald),
                    ),
                    filled: true,
                    fillColor: AppTheme.backgroundCard,
                  ),
                  onChanged: (value) =>
                      context.read<TeamsCubit>().search(value),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      '${state.displayTeams.length} teams',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (state.selectedConfederation != null ||
                        state.searchQuery != null) ...[
                      const Spacer(),
                      TextButton(
                        onPressed: () =>
                            context.read<TeamsCubit>().clearFilters(),
                        child: const Text('Clear filters', style: TextStyle(color: AppTheme.accentGold)),
                      ),
                    ],
                  ],
                ),
              ),

              // Teams list/grid
              Expanded(
                child: state.displayTeams.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        color: AppTheme.secondaryEmerald,
                        onRefresh: () =>
                            context.read<TeamsCubit>().refreshTeams(),
                        child: _isGridView
                            ? _buildGridView(state.displayTeams)
                            : _buildListView(state.displayTeams),
                      ),
              ),
            ],
          );
        },
      ),
        ),
      ),
    );
  }

  Widget _buildListView(List<NationalTeam> teams) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, favoritesState) {
        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: teams.length,
          separatorBuilder: (_, __) => Divider(height: 1, color: Colors.white.withOpacity(0.1)),
          itemBuilder: (context, index) {
            final team = teams[index];
            return TeamTile(
              team: team,
              onTap: () => _onTeamTap(team),
              isFavorite: favoritesState.isTeamFavorite(team.fifaCode),
              onFavoriteToggle: () => context
                  .read<FavoritesCubit>()
                  .toggleFavoriteTeam(team.fifaCode),
            );
          },
        );
      },
    );
  }

  Widget _buildGridView(List<NationalTeam> teams) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, favoritesState) {
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.85,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: teams.length,
          itemBuilder: (context, index) {
            final team = teams[index];
            return TeamCard(
              team: team,
              onTap: () => _onTeamTap(team),
              isFavorite: favoritesState.isTeamFavorite(team.fifaCode),
              onFavoriteToggle: () => context
                  .read<FavoritesCubit>()
                  .toggleFavoriteTeam(team.fifaCode),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.white.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text(
            'No teams found',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white38,
            ),
          ),
        ],
      ),
    );
  }

  void _onTeamTap(NationalTeam team) {
    context.read<TeamsCubit>().selectTeam(team);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${team.countryName} - ${team.confederation.displayName}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

/// Teams grouped by confederation
class TeamsByConfederationPage extends StatelessWidget {
  const TeamsByConfederationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TeamsCubit, TeamsState>(
      builder: (context, teamsState) {
        if (teamsState.isLoading) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }

        final teamsByConf = context.read<TeamsCubit>().getTeamsByConfederation();

        return BlocBuilder<FavoritesCubit, FavoritesState>(
          builder: (context, favoritesState) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: teamsByConf.length,
              itemBuilder: (context, index) {
                final entry = teamsByConf.entries.elementAt(index);
                return _buildConfederationSection(
                  context,
                  entry.key,
                  entry.value,
                  favoritesState,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildConfederationSection(
    BuildContext context,
    Confederation conf,
    List<NationalTeam> teams,
    FavoritesState favoritesState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Text(
                conf.displayName,
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
                  color: AppTheme.primaryOrange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${teams.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryOrange,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.backgroundCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            children: teams
                .map((team) => TeamTile(
                      team: team,
                      showConfederation: false,
                      isFavorite: favoritesState.isTeamFavorite(team.fifaCode),
                      onFavoriteToggle: () => context
                          .read<FavoritesCubit>()
                          .toggleFavoriteTeam(team.fifaCode),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

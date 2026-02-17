import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../bloc/schedule_bloc.dart';
import '../../domain/entities/game_schedule.dart';
import '../../../../config/theme_helper.dart';
import '../../../auth/domain/services/auth_service.dart';
import '../../../auth/presentation/screens/favorite_teams_screen.dart';
import '../../../recommendations/presentation/screens/game_details_screen.dart';
import '../../../../core/services/user_learning_service.dart';
import '../../../../core/utils/team_logo_helper.dart';
import '../widgets/upcoming_game_card.dart';
import '../widgets/team_name_matcher.dart';

class UpcomingGamesScreen extends StatefulWidget {
  const UpcomingGamesScreen({super.key});

  @override
  State<UpcomingGamesScreen> createState() => _UpcomingGamesScreenState();
}

class _UpcomingGamesScreenState extends State<UpcomingGamesScreen>
    with SingleTickerProviderStateMixin {
  bool _showFavoritesOnly = false;
  List<String> _favoriteTeams = [];
  final AuthService _authService = sl<AuthService>();
  late ScheduleBloc _scheduleBloc;

  @override
  void initState() {
    super.initState();
    _scheduleBloc = sl<ScheduleBloc>();
    _loadFavoriteTeams();
  }

  @override
  void dispose() {
    // Don't close the bloc here since it's shared
    super.dispose();
  }

  Future<void> _loadFavoriteTeams() async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId != null) {
        final favorites = await _authService.getFavoriteTeams(userId);
        setState(() {
          _favoriteTeams = favorites;
        });

        // Update the bloc with favorite teams
        _scheduleBloc.add(FilterByFavoriteTeamsEvent(
          showFavoritesOnly: _showFavoritesOnly,
          favoriteTeams: _favoriteTeams,
        ));
      }
    } catch (e) {
      // Error handled silently
    }
  }

  void _toggleFavoritesFilter() {
    setState(() {
      _showFavoritesOnly = !_showFavoritesOnly;
    });

    // Update the bloc with new filter state
    _scheduleBloc.add(FilterByFavoriteTeamsEvent(
      showFavoritesOnly: _showFavoritesOnly,
      favoriteTeams: _favoriteTeams,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Deep dark background
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          TeamLogoHelper.getPregameLogo(height: 32),
          const SizedBox(width: 8),
          const Text(
            'Upcoming Games',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
      backgroundColor: ThemeHelper.primaryColor(context),
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        _buildFavoritesToggle(),
        _buildPopupMenu(),
      ],
    );
  }

  Widget _buildFavoritesToggle() {
    return IconButton(
      icon: Icon(
        _showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
        color: _showFavoritesOnly ? ThemeHelper.favoriteColor : Colors.white,
      ),
      onPressed: () async {
        if (_favoriteTeams.isEmpty) {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FavoriteTeamsScreen()),
          );
          if (result != null || mounted) {
            await _loadFavoriteTeams();
          }
        } else {
          _toggleFavoritesFilter();
        }
      },
      tooltip: _favoriteTeams.isEmpty
          ? 'Set favorite teams'
          : (_showFavoritesOnly ? 'Show All Games' : 'Show Favorite Teams Only'),
    );
  }

  Widget _buildPopupMenu() {
    return PopupMenuButton<String>(
      iconColor: Colors.white,
      color: const Color(0xFF1E293B),
      onSelected: (value) async {
        switch (value) {
          case 'teams':
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FavoriteTeamsScreen()),
            );
            if (result != null || mounted) {
              await _loadFavoriteTeams();
            }
            break;
          case 'refresh':
            _scheduleBloc.add(const GetUpcomingGamesEvent(limit: 100));
            break;
        }
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'teams',
          child: Row(
            children: [
              Icon(Icons.favorite, color: ThemeHelper.favoriteColor),
              const SizedBox(width: 8),
              const Text('Favorite Teams', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'refresh',
          child: Row(
            children: [
              Icon(Icons.refresh, color: ThemeHelper.favoriteColor),
              const SizedBox(width: 8),
              const Text('Refresh', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return BlocBuilder<ScheduleBloc, ScheduleState>(
      bloc: _scheduleBloc,
      builder: (context, state) {
        if (state is ScheduleLoading) {
          return _buildLoadingState();
        }

        if (state is ScheduleError) {
          return _buildErrorState(state.message);
        }

        if (state is UpcomingGamesLoaded) {
          final gamesToShow = state.filteredUpcomingGames;
          if (gamesToShow.isEmpty) {
            return _buildEmptyState();
          }
          return _buildGamesList(gamesToShow);
        }

        return _buildWelcomeState();
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: ThemeHelper.favoriteColor),
          const SizedBox(height: 16),
          const Text(
            'Loading games...',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Error loading games',
            style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(fontSize: 14, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _scheduleBloc.add(const GetUpcomingGamesEvent(limit: 100)),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeHelper.favoriteColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _showFavoritesOnly ? Icons.favorite_border : Icons.sports_soccer,
            size: 64,
            color: ThemeHelper.favoriteColor,
          ),
          const SizedBox(height: 16),
          Text(
            _showFavoritesOnly
                ? 'No upcoming games for your favorite teams'
                : 'No upcoming games found',
            style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _showFavoritesOnly && _favoriteTeams.isEmpty
                ? 'Set your favorite teams to see filtered matches'
                : 'Check back later for the latest schedule',
            style: const TextStyle(fontSize: 14, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          if (_showFavoritesOnly && _favoriteTeams.isEmpty) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FavoriteTeamsScreen()),
                );
                await _loadFavoriteTeams();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeHelper.favoriteColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Set Favorite Teams'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGamesList(List<GameSchedule> games) {
    return RefreshIndicator(
      color: ThemeHelper.favoriteColor,
      backgroundColor: const Color(0xFF1E293B),
      onRefresh: () async {
        _scheduleBloc.add(const GetUpcomingGamesEvent(limit: 100));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: games.length,
        itemBuilder: (context, index) {
          final game = games[index];
          return UpcomingGameCard(
            game: game,
            isFavoriteGame: TeamNameMatcher.isFavoriteTeamGame(game, _favoriteTeams),
            onTap: () => _navigateToGameDetails(game),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sports_soccer, size: 64, color: ThemeHelper.favoriteColor),
          const SizedBox(height: 16),
          const Text(
            'Welcome to Pregame World Cup!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  void _navigateToGameDetails(GameSchedule game) {
    // Track user interaction
    final userLearningService = UserLearningService();
    userLearningService.trackGameInteraction(
      gameId: game.gameId,
      interactionType: 'card_tap',
      homeTeam: game.homeTeamName,
      awayTeam: game.awayTeamName,
      additionalData: {
        'screen': 'upcoming_games',
        'is_favorite_game': TeamNameMatcher.isFavoriteTeamGame(game, _favoriteTeams),
        'game_status': game.status,
        'is_live': game.isLive,
      },
    );

    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GameDetailsScreen(game: game),
        ),
      );
    } catch (e) {
      // Navigation error handled silently
    }
  }
}

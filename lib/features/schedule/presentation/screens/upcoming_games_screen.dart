import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../injection_container.dart';
import '../bloc/schedule_bloc.dart';
import '../../domain/entities/game_schedule.dart';
import '../../../../config/theme_helper.dart';
import '../../../auth/domain/services/auth_service.dart';
import '../../../auth/presentation/screens/favorite_teams_screen.dart';
import '../../../recommendations/presentation/screens/game_details_screen.dart';
import '../../../../core/services/user_learning_service.dart';
import '../../../../core/utils/team_logo_helper.dart';

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
      appBar: AppBar(
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
          // Favorite teams filter toggle
          IconButton(
            icon: Icon(
              _showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
              color: _showFavoritesOnly ? ThemeHelper.favoriteColor : Colors.white,
            ),
            // Always allow the heart to be clickable - if no favorites, navigate to set them
            onPressed: () async {
              if (_favoriteTeams.isEmpty) {
                // If no favorite teams, go directly to the favorite teams screen
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FavoriteTeamsScreen()),
                );
                // Reload favorite teams when returning from the screen
                if (result != null || mounted) {
                  await _loadFavoriteTeams();
                }
              } else {
                // If we have favorites, toggle the filter
                _toggleFavoritesFilter();
              }
            },
            tooltip: _favoriteTeams.isEmpty 
                ? 'Set favorite teams' 
                : (_showFavoritesOnly ? 'Show All Games' : 'Show Favorite Teams Only'),
          ),
          // More options menu
          PopupMenuButton<String>(
            iconColor: Colors.white,
            color: const Color(0xFF1E293B), // Dark surface menu background
            onSelected: (value) async {
              switch (value) {
                case 'teams':
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FavoriteTeamsScreen()),
                  );
                  // Reload favorite teams when returning from the screen
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
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<ScheduleBloc, ScheduleState>(
      bloc: _scheduleBloc,
      builder: (context, state) {
        if (state is ScheduleLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: ThemeHelper.favoriteColor, // Orange color
                ),
                const SizedBox(height: 16),
                const Text(
                  'Loading games...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        if (state is ScheduleError) {
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
                const Text(
                  'Error loading games',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _scheduleBloc.add(const GetUpcomingGamesEvent(limit: 100));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeHelper.favoriteColor, // Orange
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is UpcomingGamesLoaded) {
          final gamesToShow = state.filteredUpcomingGames;
          
          if (gamesToShow.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _showFavoritesOnly ? Icons.favorite_border : Icons.sports_football,
                    size: 64,
                    color: ThemeHelper.favoriteColor, // Orange color
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _showFavoritesOnly 
                        ? 'No upcoming games for your favorite teams'
                        : 'No upcoming games found',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _showFavoritesOnly && _favoriteTeams.isEmpty
                        ? 'Set your favorite SEC teams to see filtered games'
                        : 'Check back later for the latest schedule',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
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
          
          return RefreshIndicator(
            color: ThemeHelper.favoriteColor,
            backgroundColor: const Color(0xFF1E293B), // Dark surface
            onRefresh: () async {
              _scheduleBloc.add(const GetUpcomingGamesEvent(limit: 100));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: gamesToShow.length,
              itemBuilder: (context, index) {
                final game = gamesToShow[index];
                return _buildGameCard(game);
              },
            ),
          );
        }

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sports_football,
                size: 64,
                color: ThemeHelper.favoriteColor, // Orange color
              ),
              const SizedBox(height: 16),
              const Text(
                'Welcome to Pregame Football!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGameCard(GameSchedule game) {
    final isFavoriteGame = _isFavoriteTeamGame(game);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // Dark blue-gray card background
        borderRadius: BorderRadius.circular(16),
        border: isFavoriteGame 
            ? Border.all(color: ThemeHelper.favoriteColor, width: 2)
            : null,
        gradient: isFavoriteGame 
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ThemeHelper.favoriteColor.withOpacity(0.1),
                  const Color(0xFF1E293B),
                ],
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _navigateToGameDetails(game),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Teams Row with Logos
              Row(
                children: [
                  // Away Team with Logo
                  Expanded(
                    child: Row(
                      children: [
                        TeamLogoHelper.getTeamLogoWidget(
                          teamName: game.awayTeamName,
                          size: 32,
                          fallbackColor: Colors.white70,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            game.awayTeamName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // VS indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: ThemeHelper.favoriteColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: ThemeHelper.favoriteColor),
                    ),
                    child: Text(
                      '@',
                      style: TextStyle(
                        color: ThemeHelper.favoriteColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  
                  // Home Team with Logo
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            game.homeTeamName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isFavoriteGame ? ThemeHelper.favoriteColor : Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        ),
                        const SizedBox(width: 12),
                        TeamLogoHelper.getTeamLogoWidget(
                          teamName: game.homeTeamName,
                          size: 32,
                          fallbackColor: isFavoriteGame ? ThemeHelper.favoriteColor : Colors.white70,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Game Info Row
              Row(
                children: [
                  Icon(Icons.access_time, color: ThemeHelper.favoriteColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _formatGameTime(game),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              
              if (game.stadium?.name != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, color: ThemeHelper.favoriteColor, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        game.stadium!.name!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              
              if (game.channel != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.tv, color: ThemeHelper.favoriteColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'TV: ${game.channel}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
              
              if (game.week != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: ThemeHelper.favoriteColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Week ${game.week}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
              
              // Favorite team indicator
              if (isFavoriteGame) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: ThemeHelper.favoriteColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: ThemeHelper.favoriteColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: ThemeHelper.favoriteColor, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Favorite Team',
                        style: TextStyle(
                          color: ThemeHelper.favoriteColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool _isFavoriteTeamGame(GameSchedule game) {
    return _isTeamInFavorites(game.homeTeamName, _favoriteTeams) || 
           _isTeamInFavorites(game.awayTeamName, _favoriteTeams);
  }

  bool _isTeamInFavorites(String teamName, List<String> favorites) {
    // Direct match first
    if (favorites.contains(teamName)) {
      return true;
    }
    
    // Flexible matching - check if any favorite team name contains the team name or vice versa
    for (String favoriteTeam in favorites) {
      // Check if the team name contains key words from favorite team
      if (_teamNamesMatch(teamName, favoriteTeam)) {
        return true;
      }
    }
    
    return false;
  }

  // Helper method to match team names flexibly
  bool _teamNamesMatch(String apiTeamName, String favoriteTeamName) {
    final apiLower = apiTeamName.toLowerCase();
    final favLower = favoriteTeamName.toLowerCase();
    
    // Direct match
    if (apiLower == favLower) return true;
    
    // Check for key team identifiers
    final teamMappings = {
      'alabama': ['alabama', 'crimson tide'],
      'arkansas': ['arkansas', 'razorbacks'],
      'auburn': ['auburn', 'tigers'],
      'florida': ['florida', 'gators'],
      'georgia': ['georgia', 'bulldogs'],
      'kentucky': ['kentucky', 'wildcats'],
      'lsu': ['lsu', 'tigers'],
      'mississippi state': ['mississippi state', 'bulldogs', 'miss state'],
      'missouri': ['missouri', 'tigers'],
      'oklahoma': ['oklahoma', 'sooners'],
      'ole miss': ['ole miss', 'rebels', 'mississippi'],
      'south carolina': ['south carolina', 'gamecocks'],
      'tennessee': ['tennessee', 'volunteers', 'vols'],
      'texas a&m': ['texas a&m', 'aggies', 'tamu'],
      'texas': ['texas', 'longhorns'],
      'vanderbilt': ['vanderbilt', 'commodores'],
    };
    
    // Check if either name contains key identifiers
    for (String key in teamMappings.keys) {
      final identifiers = teamMappings[key]!;
      bool apiMatches = identifiers.any((id) => apiLower.contains(id));
      bool favMatches = identifiers.any((id) => favLower.contains(id));
      
      if (apiMatches && favMatches) {
        return true;
      }
    }
    
    return false;
  }

  String _formatGameTime(GameSchedule game) {
    String gameTime = 'Time TBD';
    if (game.dateTimeUTC != null) {
      gameTime = DateFormat('EEE, MMM d, h:mm a').format(game.dateTimeUTC!.toLocal());
    } else if (game.dateTime != null) {
      gameTime = DateFormat('EEE, MMM d, h:mm a').format(game.dateTime!);
    } else if (game.day != null) {
      gameTime = DateFormat('EEee, MMM d').format(game.day!);
    }
    return gameTime;
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
        'is_favorite_game': _isFavoriteTeamGame(game),
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
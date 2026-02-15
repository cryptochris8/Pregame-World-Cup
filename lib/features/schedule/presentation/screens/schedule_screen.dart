import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
// Import the model
import '../../domain/entities/game_schedule.dart'; // Import GameSchedule and TimeFilter
import '../../../recommendations/presentation/screens/game_details_screen.dart'; // Import for navigation
import '../../../auth/domain/services/auth_service.dart'; // Import AuthService
import '../../../../injection_container.dart'; // Import GetIt
// Import FavoriteTeamsScreen
// Import ChatScreen
import '../bloc/schedule_bloc.dart'; // Import ScheduleBloc
import '../../../../config/theme_helper.dart';
import '../../../../core/utils/team_logo_helper.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with TickerProviderStateMixin {
  final ScheduleBloc _scheduleBloc = sl<ScheduleBloc>();
  bool _showFavoritesOnly = false;
  List<String> _favoriteTeams = [];
  final AuthService _authService = sl<AuthService>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Load favorite teams and fetch schedule data when the screen initializes
    _loadFavoriteTeams();
    _scheduleBloc.add(const GetUpcomingGamesEvent(limit: 100));
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _scheduleBloc.close();
    _tabController.dispose();
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
      'united states': ['united states', 'usa', 'usmnt', 'stars and stripes'],
      'mexico': ['mexico', 'el tri', 'tricolor'],
      'brazil': ['brazil', 'selecao', 'canarinha'],
      'argentina': ['argentina', 'albiceleste'],
      'france': ['france', 'les bleus'],
      'germany': ['germany', 'die mannschaft'],
      'spain': ['spain', 'la roja'],
      'england': ['england', 'three lions'],
      'portugal': ['portugal'],
      'netherlands': ['netherlands', 'holland', 'oranje'],
      'italy': ['italy', 'azzurri'],
      'japan': ['japan', 'samurai blue'],
      'south korea': ['south korea', 'korea republic', 'taegeuk warriors'],
      'morocco': ['morocco', 'atlas lions'],
      'canada': ['canada', 'canmnt'],
      'croatia': ['croatia', 'vatreni'],
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
              'Schedule',
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: ThemeHelper.favoriteColor, // Orange selected tab
          unselectedLabelColor: Colors.white70,
          indicatorColor: ThemeHelper.favoriteColor, // Orange indicator
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.today, color: ThemeHelper.favoriteColor, size: 20),
                  const SizedBox(width: 8),
                  const Text('Today'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.date_range, color: ThemeHelper.favoriteColor, size: 20),
                  const SizedBox(width: 8),
                  const Text('This Week'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_month, color: ThemeHelper.favoriteColor, size: 20),
                  const SizedBox(width: 8),
                  const Text('All'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGamesTab(TimeFilter.today),
          _buildGamesTab(TimeFilter.thisWeek),
          _buildGamesTab(TimeFilter.all),
        ],
      ),
    );
  }

  Widget _buildGameCard(GameSchedule game) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // Dark blue-gray card background
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GameDetailsScreen(game: game),
            ),
          );
        },
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
                          size: 28,
                          fallbackColor: Colors.white70,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            game.awayTeamName,
                            style: const TextStyle(
                              fontSize: 16,
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
                  
                  // @ indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ThemeHelper.favoriteColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ThemeHelper.favoriteColor),
                    ),
                    child: Text(
                      '@',
                      style: TextStyle(
                        color: ThemeHelper.favoriteColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
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
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        ),
                        const SizedBox(width: 12),
                        TeamLogoHelper.getTeamLogoWidget(
                          teamName: game.homeTeamName,
                          size: 28,
                          fallbackColor: Colors.white70,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Game Info with Venues Button
              Row(
                children: [
                  Icon(Icons.access_time, color: ThemeHelper.favoriteColor, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _formatGameTime(game),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  // Venues Button - Same size as date widget
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GameDetailsScreen(game: game),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: ThemeHelper.favoriteColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: ThemeHelper.favoriteColor.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_city,
                            size: 16,
                            color: Colors.white,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Venues',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              if (game.stadium?.name != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.location_on, color: ThemeHelper.favoriteColor, size: 18),
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
            ],
          ),
        ),
      ),
    );
  }

  String _formatGameTime(GameSchedule game) {
    if (game.dateTimeUTC != null) {
      return DateFormat('h:mm a').format(game.dateTimeUTC!.toLocal());
    } else if (game.dateTime != null) {
      return DateFormat('h:mm a').format(game.dateTime!);
    }
    return 'Time TBD';
  }

  Widget _buildGamesTab(TimeFilter filter) {
    // Implement the logic to fetch and display games based on the filter
    // This is a placeholder and should be replaced with the actual implementation
    return Center(
      child: Text(
        'Games for ${filter.toString().split('.').last}',
        style: const TextStyle(
          fontSize: 18,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
} 
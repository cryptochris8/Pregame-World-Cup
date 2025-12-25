import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/schedule_bloc.dart';
import '../../domain/entities/game_schedule.dart';
import '../../../recommendations/presentation/screens/game_details_screen.dart';
import '../widgets/live_score_card.dart';
import '../widgets/espn_game_insights_widget.dart';
import '../widgets/enhanced_ai_insights_widget.dart';
import '../widgets/game_prediction_widget.dart';
import '../../../auth/domain/services/auth_service.dart';
import '../../../auth/presentation/screens/favorite_teams_screen.dart';
import 'prediction_leaderboard_screen.dart';
import '../../../../injection_container.dart';
import '../../../../core/services/logging_service.dart';
import '../../../../core/services/cache_service.dart';
import '../../../../core/utils/team_matching_helper.dart';
import '../../../../core/utils/team_logo_helper.dart';
import '../../../../config/theme_helper.dart';
import '../../../recommendations/domain/repositories/places_repository.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Enhanced schedule screen with live scores and social features
class EnhancedScheduleScreen extends StatefulWidget {
  const EnhancedScheduleScreen({super.key});

  @override
  State<EnhancedScheduleScreen> createState() => _EnhancedScheduleScreenState();
}

class _EnhancedScheduleScreenState extends State<EnhancedScheduleScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _showLiveOnly = false;
  bool _showFavoritesOnly = false;
  List<String> _favoriteTeams = [];
  final AuthService _authService = sl<AuthService>();
  Timer? _liveScoreTimer;
  int _currentYear = 2025; // Lock to 2025 season only

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Start live score refresh timer
    _startLiveScoreTimer();
    
    // Load initial data and favorite teams
    _loadFavoriteTeams();
    
    // Delay API calls until after the widget is built to prevent UI blocking
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // PRODUCTION FIX: Always clear cache and force refresh on app startup
        // This ensures the app NEVER shows 2024 games on first load
        _clearCacheAndForceRefresh();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _liveScoreTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadFavoriteTeams() async {
    try {
      List<String> favorites = [];
      
      final userId = _authService.currentUser?.uid;
      // Loading user favorites
      
      if (userId != null) {
        try {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();
          
          if (userDoc.exists && userDoc.data()?['favoriteTeams'] != null) {
            favorites = List<String>.from(userDoc.data()!['favoriteTeams']);
          } else {
            // Fall back to SharedPreferences if Firebase doesn't have data
            final prefs = await SharedPreferences.getInstance();
            favorites = prefs.getStringList('favorite_teams') ?? [];
          }
        } catch (e) {
          // Firebase error, use local storage
          final prefs = await SharedPreferences.getInstance();
          favorites = prefs.getStringList('favorite_teams') ?? [];
        }
      } else {
        // User not logged in, load from local storage
        final prefs = await SharedPreferences.getInstance();
        favorites = prefs.getStringList('favorite_teams') ?? [];
      }
      
      if (mounted) {
        setState(() {
          _favoriteTeams = favorites;
        });
        
        // Debug: Print loaded favorite teams
        print('🏈 Loaded favorite teams: $_favoriteTeams');
        print('🏈 Show favorites only: $_showFavoritesOnly');
        
        // Trigger a refresh of the current schedule state with new favorites
        _loadGames();
      }
    } catch (e) {
      // Error loading favorite teams - continue with empty list
      if (mounted) {
        setState(() {
          _favoriteTeams = [];
        });
      }
    }
  }

  void _toggleFavoritesFilter() {
    setState(() {
      _showFavoritesOnly = !_showFavoritesOnly;
    });
    
    // Debug: Print toggle state
    print('🏈 Toggled favorites filter to: $_showFavoritesOnly');
    print('🏈 Current favorite teams: $_favoriteTeams');
    
    // Update the bloc with new filter state
    _loadGames();
  }

  void _startLiveScoreTimer() {
    // Cancel any existing timer first
    _liveScoreTimer?.cancel();
    
    // Start a timer to refresh live scores every 30 seconds
    _liveScoreTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        context.read<ScheduleBloc>().add(const RefreshLiveScoresEvent());
      } else {
        timer.cancel();
        _liveScoreTimer = null;
      }
    });
  }

  void _loadGames() {
    print('🎯 SCHEDULE DEBUG: _loadGames() called');
    print('🎯 SCHEDULE DEBUG: Always loading 2025 season');
    print('🎯 SCHEDULE DEBUG: Show favorites only: $_showFavoritesOnly');
    print('🎯 SCHEDULE DEBUG: Favorite teams: $_favoriteTeams');
    
    // ALWAYS load 2025 season - no year confusion
    print('🎯 SCHEDULE DEBUG: Loading 2025 ESPN season schedule');
    context.read<ScheduleBloc>().add(const GetCollegeFootballScheduleEvent(2025));
    
    // Apply the favorite team filter
    context.read<ScheduleBloc>().add(FilterByFavoriteTeamsEvent(
      showFavoritesOnly: _showFavoritesOnly,
      favoriteTeams: _favoriteTeams,
    ));
  }

  /// PRODUCTION FIX: Clear cache and force refresh on every app startup
  /// This ensures the app always shows 2025 games immediately
  Future<void> _clearCacheAndForceRefresh() async {
    try {
      print('🚀 STARTUP: Forcing cache clear and 2025 refresh');
      
      // Use the same logic as the menu's clear_cache option
      await CacheService.instance.clearCache();
      print('🧹 STARTUP: Cache cleared');
      
      // Small delay to ensure cache is cleared
      await Future.delayed(Duration(milliseconds: 500));
      
      // Force refresh to get fresh 2025 data (same as menu refresh)
      if (mounted) {
        context.read<ScheduleBloc>().add(const ForceRefreshUpcomingGamesEvent(limit: 100));
        print('🔄 STARTUP: Force refresh event sent');
      }
      
      print('✅ STARTUP: Cache cleared and 2025 games loading');
    } catch (e) {
      print('⚠️ STARTUP: Error in cache clear and refresh: $e');
      // Fallback to regular load
      _loadGames();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Transparent to show main gradient
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/logos/pregame_logo.png',
              height: 40,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.sports_football, color: ThemeHelper.favoriteColor, size: 40);
              },
            ),
            const SizedBox(width: 12),
            const Text(
              'College Football',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        backgroundColor: ThemeHelper.primaryColor(context), // Consistent with other screens
        actions: [
          // Favorite teams filter toggle
          IconButton(
            icon: Icon(
              _showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
              color: _showFavoritesOnly ? ThemeHelper.favoriteColor : Colors.white,
            ),
            // Toggle filter to show only favorite SEC team games
            onPressed: () {
              // Always toggle the favorites filter
              _toggleFavoritesFilter();
            },
            tooltip: _showFavoritesOnly ? 'Show All Games' : 'Show Favorite SEC Teams Only',
          ),
          // Live games filter toggle
          IconButton(
            icon: Icon(
              _showLiveOnly ? Icons.live_tv : Icons.live_tv_outlined,
              color: _showLiveOnly ? ThemeHelper.favoriteColor : Colors.white,
            ),
            onPressed: () {
              setState(() {
                _showLiveOnly = !_showLiveOnly;
              });
            },
            tooltip: 'Show Live Games Only',
          ),
          // More options menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: const Color(0xFF1E293B), // Dark surface menu background
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
                  print('🔄 MENU: Regular refresh triggered');
                  context.read<ScheduleBloc>().add(const ForceRefreshUpcomingGamesEvent(limit: 100));
                  print('🔄 MENU: Force refresh event sent');
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'teams',
                child: Row(
                  children: [
                    Icon(Icons.favorite, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Favorite Teams', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Refresh', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab bar for different views
          Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFF7C3AED), // Vibrant purple
                    Color(0xFF3B82F6), // Electric blue
                    Color(0xFFEA580C), // Warm orange
                  ],
                ),
              ),
            child: TabBar(
              controller: _tabController,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
                labelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              tabs: const [
                Tab(text: 'Live Scores'),
                Tab(text: 'Schedule'),
                Tab(text: 'Social'),
              ],
            ),
          ),
          
          // 2025 Season Badge (no year selector - locked to 2025)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              border: Border(
                bottom: BorderSide(color: Color(0xFF334155), width: 1),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.sports_football, color: Colors.orange, size: 24),
                const SizedBox(width: 12),
                const Text(
                  '2025 College Football Season',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange, width: 1),
                  ),
                  child: const Text(
                    'LIVE ESPN DATA',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLiveScoresTab(),
                _buildScheduleTab(),
                _buildSocialTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveScoresTab() {
    return BlocBuilder<ScheduleBloc, ScheduleState>(
      builder: (context, state) {
        if (state is ScheduleLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
          );
        } else if (state is ScheduleLoaded || state is UpcomingGamesLoaded) {
          // Start with filtered schedule (respects favorite teams filter)
          List<GameSchedule> filteredGames;
          if (state is ScheduleLoaded) {
            filteredGames = state.filteredSchedule;
          } else {
            filteredGames = (state as UpcomingGamesLoaded).filteredUpcomingGames;
          }
          
          // Then filter for live games only
          final liveGames = filteredGames.where((game) => 
            game.isLive == true || 
            game.status?.toLowerCase().contains('progress') == true ||
            game.status?.toLowerCase().contains('quarter') == true ||
            game.status?.toLowerCase().contains('half') == true
          ).toList();
          
          // Live games filtered for display

          if (liveGames.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sports_football,
                    size: 64,
                    color: ThemeHelper.favoriteColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Live Games Currently Available',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'College football games typically occur on Saturdays.\nCheck back during game time for live scores!',
                    style: TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: const Text(
                      '🏈 Game day is coming soon!',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: liveGames.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: LiveScoreCard(
                  game: liveGames[index],
                ),
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildScheduleTab() {
    return BlocBuilder<ScheduleBloc, ScheduleState>(
      builder: (context, state) {
        if (state is ScheduleLoading) {
          return _buildLoadingWidget();
        } else if (state is ScheduleError) {
          return _buildErrorWidget(state.message);
        } else if (state is ScheduleLoaded) {
          return _buildGamesList(state.filteredSchedule);
        } else if (state is UpcomingGamesLoaded) {
          return _buildGamesList(state.filteredUpcomingGames);
        } else if (state is WeeklyScheduleLoaded) {
          return _buildWeeklyScheduleWidget(state);
        } else {
          return _buildUnknownStateWidget();
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

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to Load Games',
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
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildGamesList(List<GameSchedule> games) {
    List<GameSchedule> filteredGames = List.from(games);

    // Apply live filter if needed
    if (_showLiveOnly) {
      filteredGames = _applyLiveFilter(filteredGames);
    }

    if (filteredGames.isEmpty) {
      return _buildEmptyGamesWidget();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredGames.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildGameCard(filteredGames[index]),
        );
      },
    );
  }

  Widget _buildWeeklyScheduleWidget(WeeklyScheduleLoaded state) {
    List<GameSchedule> filteredGames = List.from(state.filteredWeeklySchedule);

    if (_showLiveOnly) {
      filteredGames = _applyLiveFilter(filteredGames);
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          color: Colors.orange.withOpacity(0.2),
          child: Text(
            'Test Data - ${state.year} Week ${state.week}',
            style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: filteredGames.isEmpty
              ? _buildEmptyWeeklyGamesWidget(state.year, state.week)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredGames.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildGameCard(filteredGames[index]),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildUnknownStateWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Unknown state',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap below to reload the schedule',
            style: TextStyle(color: Colors.white70),
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
            child: const Text('Reload Schedule'),
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

  Widget _buildEmptyGamesWidget() {
    String emptyMessage = 'No games found';
    if (_showFavoritesOnly && _favoriteTeams.isNotEmpty) {
      emptyMessage = 'No games for your favorite teams';
    } else if (_showLiveOnly) {
      emptyMessage = 'No live games at the moment';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_football,
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
          if (_favoriteTeams.isEmpty && _showFavoritesOnly) ...[
            const SizedBox(height: 8),
            const Text(
              'Set your favorite teams to see personalized games',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FavoriteTeamsScreen()),
                );
                if (result != null || mounted) {
                  await _loadFavoriteTeams();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeHelper.favoriteColor,
              ),
              child: const Text('Set Favorite Teams'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyWeeklyGamesWidget(int year, int week) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_football,
            size: 64,
            color: ThemeHelper.favoriteColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No games found for $year Week $week',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialTab() {
    return BlocBuilder<ScheduleBloc, ScheduleState>(
      builder: (context, state) {
        if (state is ScheduleLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
          );
        } else if (state is ScheduleLoaded) {
          // Show upcoming games with social features
          final upcomingGames = state.schedule.where((game) => 
            game.dateTimeUTC != null && 
            game.dateTimeUTC!.isAfter(DateTime.now()) &&
            game.status != 'Final'
          ).toList();

          if (upcomingGames.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.groups,
                    size: 64,
                    color: ThemeHelper.favoriteColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Upcoming Games',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Social features will be available for upcoming games',
                    style: TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: upcomingGames.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildSocialGameCard(upcomingGames[index]),
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildGameCard(GameSchedule game) {
    final bool isFavoriteGame = _isTeamInFavorites(game.homeTeamName, _favoriteTeams) ||
        _isTeamInFavorites(game.awayTeamName, _favoriteTeams);

    return Card(
      elevation: 8,
      color: const Color(0xFF1E293B), // Dark blue-gray card background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isFavoriteGame 
            ? BorderSide(color: ThemeHelper.favoriteColor, width: 2)
            : BorderSide.none,
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
                  
                  // VS indicator with favorite icon
                  Column(
                    children: [
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
                      if (isFavoriteGame) ...[
                        const SizedBox(height: 4),
                        Icon(
                          Icons.favorite,
                          color: ThemeHelper.favoriteColor,
                          size: 16,
                        ),
                      ],
                    ],
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
                              fontSize: 16,
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
              
              const SizedBox(height: 12),
              
              // Score or time info with Venues button
              Row(
                children: [
                  // Score display for completed/live games
                  if (game.status == 'Final' || game.isLive == true) ...[
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                                                            '${game.awayScore ?? 0}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                                                            '${game.homeScore ?? 0}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Time display for future games
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: ThemeHelper.favoriteColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _formatGameTime(game),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                  
                  const Spacer(),
                  
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_city,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Venues',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              // Venue information
              if (game.stadium?.name != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: ThemeHelper.favoriteColor,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        game.stadium!.name!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              
                              // Live game info
                if (game.isLive == true && game.period != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(
                          game.period!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (game.timeRemaining != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            game.timeRemaining!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                
                // Enhanced AI Game Intelligence with Series History
                const SizedBox(height: 8),
                EnhancedAIInsightsWidget(
                  game: game,
                  isCompact: true,
                ),
                
                // Game Prediction Widget (only for upcoming games)
                if (game.dateTimeUTC != null && 
                    game.dateTimeUTC!.isAfter(DateTime.now()) &&
                    game.status != 'Final') ...[
                  const SizedBox(height: 8),
                  GamePredictionWidget(
                    game: game,
                    onPredictionMade: () {
                      // Refresh to show updated prediction
                      if (mounted) {
                        setState(() {});
                      }
                    },
                  ),
                ],
              ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialGameCard(GameSchedule game) {
    return Card(
      elevation: 8,
      color: const Color(0xFF1E293B), // Dark blue-gray card background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
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
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            game.awayTeamName,
                            style: const TextStyle(
                              fontSize: 14,
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ThemeHelper.favoriteColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
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
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        ),
                        const SizedBox(width: 10),
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
              
              // Game time and Venues button
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: ThemeHelper.favoriteColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _formatGameTime(game),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_city,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Venues',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Social stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSocialStat(
                    Icons.psychology,
                    'Predictions',
                    game.userPredictions ?? 0,
                  ),
                  _buildSocialStat(
                    Icons.comment,
                    'Comments',
                    game.userComments ?? 0,
                  ),
                  _buildSocialStat(
                    Icons.photo_camera,
                    'Photos',
                    game.userPhotos ?? 0,
                  ),
                ],
              ),
              
              // Add prediction widget for upcoming games
              if (game.dateTimeUTC != null && 
                  game.dateTimeUTC!.isAfter(DateTime.now()) &&
                  game.status != 'Final') ...[
                const SizedBox(height: 12),
                GamePredictionWidget(
                  game: game,
                  onPredictionMade: () {
                    // Refresh the screen to show updated prediction state
                    if (mounted) {
                      setState(() {});
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialStat(IconData icon, String label, int count) {
    return Column(
      children: [
        Icon(
          icon,
          color: ThemeHelper.favoriteColor,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _formatGameTime(GameSchedule game) {
    if (game.isLive == true) {
      return 'LIVE';
    }
    
    if (game.status == 'Final') {
      return 'Final';
    }
    
    if (game.dateTimeUTC != null) {
      return DateFormat('MMM d, h:mm a').format(game.dateTimeUTC!.toLocal());
    } else if (game.dateTime != null) {
      return DateFormat('MMM d, h:mm a').format(game.dateTime!);
    } else if (game.day != null) {
      return DateFormat('MMM d').format(game.day!);
    }
    
    return 'Time TBD';
  }

  bool _isTeamInFavorites(String teamName, List<String> favorites) {
    return TeamMatchingHelper.isTeamInFavorites(teamName, favorites);
  }
} 
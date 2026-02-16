import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/schedule_bloc.dart';
import '../../../auth/domain/services/auth_service.dart';
import '../../../auth/presentation/screens/favorite_teams_screen.dart';
import '../../../../injection_container.dart';
import '../../../../core/services/cache_service.dart';
import '../../../../config/theme_helper.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'schedule_live_scores_tab.dart';
import 'schedule_games_tab.dart';
import 'schedule_social_tab.dart';

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
    // Load upcoming games
    context.read<ScheduleBloc>().add(const GetUpcomingGamesEvent(limit: 100));

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
      // Use the same logic as the menu's clear_cache option
      await CacheService.instance.clearCache();

      // Small delay to ensure cache is cleared
      await Future.delayed(const Duration(milliseconds: 500));

      // Force refresh to get fresh 2025 data (same as menu refresh)
      if (mounted) {
        context.read<ScheduleBloc>().add(const ForceRefreshUpcomingGamesEvent(limit: 100));
      }
    } catch (e) {
      // Fallback to regular load
      _loadGames();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent, // Transparent to show main gradient
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/logos/pregame_logo.png',
                height: 40,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.sports_soccer, color: ThemeHelper.favoriteColor, size: 40);
                },
              ),
            ),
            const SizedBox(width: 12),
            Text(
              l10n.worldCup2026Title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        backgroundColor: ThemeHelper.primaryColor(context),
        actions: [
          // Favorite teams filter toggle
          IconButton(
            icon: Icon(
              _showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
              color: _showFavoritesOnly ? ThemeHelper.favoriteColor : Colors.white,
            ),
            onPressed: () {
              _toggleFavoritesFilter();
            },
            tooltip: _showFavoritesOnly ? l10n.showAllMatches : l10n.showFavoriteTeamsOnly,
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
            tooltip: l10n.showLiveGamesOnly,
          ),
          // More options menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
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
                  context.read<ScheduleBloc>().add(const ForceRefreshUpcomingGamesEvent(limit: 100));
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'teams',
                child: Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(l10n.favoriteTeams, style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'refresh',
                child: Row(
                  children: [
                    const Icon(Icons.refresh, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(l10n.refresh, style: const TextStyle(color: Colors.white)),
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
              tabs: [
                Tab(text: l10n.liveScores),
                Tab(text: l10n.schedule),
                Tab(text: l10n.social),
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
                const Icon(Icons.sports_soccer, color: Colors.orange, size: 24),
                const SizedBox(width: 12),
                Text(
                  l10n.fifaWorldCup2026,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha:0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange, width: 1),
                  ),
                  child: Text(
                    l10n.liveEspnData,
                    style: const TextStyle(
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
                const ScheduleLiveScoresTab(),
                ScheduleGamesTab(
                  showLiveOnly: _showLiveOnly,
                  showFavoritesOnly: _showFavoritesOnly,
                  favoriteTeams: _favoriteTeams,
                  onRefresh: () {
                    if (mounted) setState(() {});
                  },
                  onLoadFavoriteTeams: _loadFavoriteTeams,
                ),
                ScheduleSocialTab(
                  onRefresh: () {
                    if (mounted) setState(() {});
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

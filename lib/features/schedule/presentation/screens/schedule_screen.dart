import 'package:flutter/material.dart';
// Import the model
import '../../domain/entities/game_schedule.dart'; // Import GameSchedule and TimeFilter
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
  final bool _showFavoritesOnly = false;
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
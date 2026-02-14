import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/app_theme.dart';
import '../../../../core/widgets/banner_ad_widget.dart';
import '../../domain/entities/entities.dart';
import '../bloc/bloc.dart';
import '../widgets/widgets.dart';
import '../screens/fan_pass_screen.dart';
import '../screens/tournament_leaderboards_screen.dart';
import '../screens/player_comparison_screen.dart';
import 'match_detail_page.dart';
import 'team_detail_page.dart';
import '../../../../presentation/screens/player_spotlight_screen.dart';
import '../../../../presentation/screens/manager_profiles_screen.dart';
import '../../../../injection_container.dart' as di;
import '../../../watch_party/presentation/bloc/watch_party_bloc.dart';
import '../../../watch_party/presentation/screens/screens.dart';
import 'matches_tab.dart';
import 'groups_tab.dart';
import 'teams_tab.dart';
import 'favorites_tab.dart';

/// Main World Cup screen with internal tab navigation
/// This screen is embedded in the main app navigation
class WorldCupHomeScreen extends StatefulWidget {
  const WorldCupHomeScreen({super.key});

  @override
  State<WorldCupHomeScreen> createState() => _WorldCupHomeScreenState();
}

class _WorldCupHomeScreenState extends State<WorldCupHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _tabs = const [
    Tab(icon: Icon(Icons.sports_soccer), text: 'Matches'),
    Tab(icon: Icon(Icons.grid_view), text: 'Groups'),
    Tab(icon: Icon(Icons.flag), text: 'Teams'),
    Tab(icon: Icon(Icons.person), text: 'Players'),
    Tab(icon: Icon(Icons.sports), text: 'Managers'),
    Tab(icon: Icon(Icons.favorite), text: 'Favorites'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/logos/pregame_logo.png',
                height: 32,
                width: 32,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryOrange, AppTheme.accentGold],
                ),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryOrange.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                '2026',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'World Cup',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          // Live matches indicator (priority - always visible)
          BlocBuilder<MatchListCubit, MatchListState>(
            builder: (context, state) {
              if (state.hasLiveMatches) {
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: ActionChip(
                    avatar: const LiveIndicator(size: 8),
                    label: Text(
                      '${state.liveCount} Live',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    onPressed: () {
                      _tabController.animateTo(0);
                      context.read<MatchListCubit>().setFilter(MatchListFilter.live);
                    },
                    backgroundColor: Colors.red.withOpacity(0.3),
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          // Fan Pass button (important - always visible)
          IconButton(
            icon: const Icon(Icons.star, color: Colors.amber, size: 22),
            tooltip: 'Fan Pass',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FanPassScreen()),
            ),
          ),
          // More options menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: AppTheme.backgroundCard,
            onSelected: (value) {
              switch (value) {
                case 'leaderboards':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TournamentLeaderboardsScreen()),
                  );
                  break;
                case 'compare':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PlayerComparisonScreen()),
                  );
                  break;
                case 'watch_parties':
                  _navigateToWatchParties(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'leaderboards',
                child: Row(
                  children: [
                    Icon(Icons.emoji_events, color: AppTheme.accentGold, size: 20),
                    SizedBox(width: 12),
                    Text('Leaderboards', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'compare',
                child: Row(
                  children: [
                    Icon(Icons.compare_arrows, color: Colors.white, size: 20),
                    SizedBox(width: 12),
                    Text('Compare Players', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'watch_parties',
                child: Row(
                  children: [
                    Icon(Icons.groups, color: Colors.white, size: 20),
                    SizedBox(width: 12),
                    Text('Watch Parties', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: AppTheme.primaryOrange,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Container(
        decoration: AppTheme.mainGradientDecoration,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    MatchesTab(
                      onMatchTap: (match) => _navigateToMatchDetail(context, match),
                    ),
                    GroupsTab(
                      onTeamTap: (teamCode) => _navigateToTeamByCode(context, teamCode),
                    ),
                    TeamsTab(
                      onTeamTap: (team) => _navigateToTeamDetail(context, team),
                    ),
                    const PlayerSpotlightScreen(),
                    const ManagerProfilesScreen(),
                    FavoritesTab(
                      onMatchTap: (match) => _navigateToMatchDetail(context, match),
                      onTeamTap: (team) => _navigateToTeamDetail(context, team),
                    ),
                  ],
                ),
              ),
              // Banner ad at bottom (hidden for premium users)
              const BannerAdWidget(),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToMatchDetail(BuildContext context, WorldCupMatch match) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MatchDetailPage(match: match),
      ),
    );
  }

  void _navigateToTeamDetail(BuildContext context, NationalTeam team) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TeamDetailPage(team: team),
      ),
    );
  }

  void _navigateToTeamByCode(BuildContext context, String teamCode) async {
    final cubit = context.read<TeamsCubit>();
    final team = cubit.state.getTeamByCode(teamCode);
    if (team != null) {
      _navigateToTeamDetail(context, team);
    }
  }

  void _navigateToWatchParties(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (context) => di.sl<WatchPartyBloc>()
            ..add(const LoadPublicWatchPartiesEvent()),
          child: const MyWatchPartiesScreen(),
        ),
      ),
    );
  }
}

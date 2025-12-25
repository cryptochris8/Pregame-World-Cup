import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/entities.dart';
import '../bloc/bloc.dart';
import 'match_list_page.dart';
import 'group_standings_page.dart';
import 'bracket_page.dart';
import 'teams_page.dart';

/// Main home page for World Cup 2026 feature
class WorldCupHomePage extends StatefulWidget {
  const WorldCupHomePage({super.key});

  @override
  State<WorldCupHomePage> createState() => _WorldCupHomePageState();
}

class _WorldCupHomePageState extends State<WorldCupHomePage> {
  int _currentIndex = 0;

  final _pages = const [
    MatchListPage(),
    GroupStandingsPage(),
    BracketPage(),
    TeamsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MatchListCubit>(
          create: (_) => sl<MatchListCubit>(),
        ),
        BlocProvider<GroupStandingsCubit>(
          create: (_) => sl<GroupStandingsCubit>(),
        ),
        BlocProvider<BracketCubit>(
          create: (_) => sl<BracketCubit>(),
        ),
        BlocProvider<TeamsCubit>(
          create: (_) => sl<TeamsCubit>(),
        ),
        BlocProvider<FavoritesCubit>(
          create: (_) => sl<FavoritesCubit>()..init(),
        ),
        BlocProvider<PredictionsCubit>(
          create: (_) => sl<PredictionsCubit>()..init(),
        ),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.sports_soccer_outlined),
              selectedIcon: Icon(Icons.sports_soccer),
              label: 'Matches',
            ),
            NavigationDestination(
              icon: Icon(Icons.grid_view_outlined),
              selectedIcon: Icon(Icons.grid_view),
              label: 'Groups',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_tree_outlined),
              selectedIcon: Icon(Icons.account_tree),
              label: 'Bracket',
            ),
            NavigationDestination(
              icon: Icon(Icons.flag_outlined),
              selectedIcon: Icon(Icons.flag),
              label: 'Teams',
            ),
          ],
        ),
      ),
    );
  }
}

/// Dashboard style home page alternative
class WorldCupDashboardPage extends StatelessWidget {
  const WorldCupDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MatchListCubit>(
          create: (_) => sl<MatchListCubit>()..init(),
        ),
        BlocProvider<GroupStandingsCubit>(
          create: (_) => sl<GroupStandingsCubit>()..init(),
        ),
        BlocProvider<BracketCubit>(
          create: (_) => sl<BracketCubit>()..init(),
        ),
        BlocProvider<FavoritesCubit>(
          create: (_) => sl<FavoritesCubit>()..init(),
        ),
        BlocProvider<PredictionsCubit>(
          create: (_) => sl<PredictionsCubit>()..init(),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/worldcup_logo.png',
                height: 32,
                errorBuilder: (_, __, ___) => const Icon(Icons.sports_soccer),
              ),
              const SizedBox(width: 8),
              const Text('World Cup 2026'),
            ],
          ),
          centerTitle: true,
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              context.read<MatchListCubit>().refreshMatches(),
              context.read<GroupStandingsCubit>().refreshGroups(),
              context.read<BracketCubit>().refreshBracket(),
            ]);
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Live matches section
                _buildSection(
                  context,
                  title: 'Live Now',
                  icon: Icons.play_circle_fill,
                  iconColor: Colors.red,
                  child: BlocBuilder<MatchListCubit, MatchListState>(
                    builder: (context, state) {
                      if (state.liveMatches.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'No live matches',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: state.liveMatches
                            .map((m) => _buildLiveMatchTile(context, m))
                            .toList(),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Upcoming matches
                _buildSection(
                  context,
                  title: 'Upcoming Matches',
                  icon: Icons.schedule,
                  action: TextButton(
                    onPressed: () => _navigateTo(context, 0),
                    child: const Text('See all'),
                  ),
                  child: BlocBuilder<MatchListCubit, MatchListState>(
                    builder: (context, state) {
                      final upcoming = state.matches
                          .where((m) => m.status == MatchStatus.scheduled)
                          .take(3)
                          .toList();

                      if (upcoming.isEmpty) {
                        return const Text('No upcoming matches');
                      }

                      return Column(
                        children: upcoming
                            .map((m) => _buildUpcomingMatchTile(m))
                            .toList(),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Quick navigation cards
                Row(
                  children: [
                    Expanded(
                      child: _buildNavCard(
                        context,
                        icon: Icons.grid_view,
                        label: 'Groups',
                        color: Colors.blue,
                        onTap: () => _navigateTo(context, 1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildNavCard(
                        context,
                        icon: Icons.account_tree,
                        label: 'Bracket',
                        color: Colors.purple,
                        onTap: () => _navigateTo(context, 2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildNavCard(
                        context,
                        icon: Icons.flag,
                        label: 'Teams',
                        color: Colors.green,
                        onTap: () => _navigateTo(context, 3),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Tournament info
                _buildTournamentInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    Color? iconColor,
    Widget? action,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: iconColor ?? Colors.grey.shade700),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (action != null) ...[
              const Spacer(),
              action,
            ],
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildLiveMatchTile(BuildContext context, WorldCupMatch match) {
    return Card(
      color: Colors.red.shade50,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 8,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        title: Text(
          '${match.homeTeamCode ?? "TBD"} ${match.homeScore}-${match.awayScore} ${match.awayTeamCode ?? "TBD"}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(match.minute != null ? "${match.minute}'" : 'Live'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  Widget _buildUpcomingMatchTile(WorldCupMatch match) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          '${match.homeTeamName ?? "TBD"} vs ${match.awayTeamName ?? "TBD"}',
        ),
        subtitle: Text(
          match.dateTime != null
              ? '${match.dateTime!.day}/${match.dateTime!.month} - ${match.venueName ?? ""}'
              : 'TBD',
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            match.stageDisplayName,
            style: TextStyle(
              fontSize: 11,
              color: Colors.blue.shade700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTournamentInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'FIFA World Cup 2026',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.groups, '48 Teams'),
            _buildInfoRow(Icons.stadium, '16 Venues'),
            _buildInfoRow(Icons.place, 'USA, Mexico, Canada'),
            _buildInfoRow(Icons.sports_soccer, '104 Matches'),
            _buildInfoRow(Icons.calendar_today, 'June 11 - July 19, 2026'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Text(text),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WorldCupHomePage(),
      ),
    );
  }
}

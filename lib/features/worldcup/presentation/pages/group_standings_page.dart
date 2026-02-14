import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/app_theme.dart';
import '../bloc/bloc.dart';
import '../widgets/widgets.dart';

/// Page displaying World Cup group standings
class GroupStandingsPage extends StatefulWidget {
  const GroupStandingsPage({super.key});

  @override
  State<GroupStandingsPage> createState() => _GroupStandingsPageState();
}

class _GroupStandingsPageState extends State<GroupStandingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 12, vsync: this);
    context.read<GroupStandingsCubit>().init();
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
        title: const Text('Group Standings', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          BlocBuilder<GroupStandingsCubit, GroupStandingsState>(
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
                onPressed: () =>
                    context.read<GroupStandingsCubit>().refreshGroups(),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppTheme.primaryOrange,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: List.generate(12, (index) {
            final letter = String.fromCharCode('A'.codeUnitAt(0) + index);
            return Tab(text: 'Group $letter');
          }),
        ),
      ),
      body: Container(
        decoration: AppTheme.mainGradientDecoration,
        child: SafeArea(
          child: BlocBuilder<GroupStandingsCubit, GroupStandingsState>(
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
                    onPressed: () =>
                        context.read<GroupStandingsCubit>().loadGroups(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state.groups.isEmpty) {
            return const Center(
              child: Text('No group data available', style: TextStyle(color: Colors.white70)),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: List.generate(12, (index) {
              final letter = String.fromCharCode('A'.codeUnitAt(0) + index);
              final group = state.getGroup(letter);

              if (group == null) {
                return Center(
                  child: Text('Group $letter data not available', style: const TextStyle(color: Colors.white70)),
                );
              }

              return RefreshIndicator(
                color: AppTheme.secondaryEmerald,
                onRefresh: () =>
                    context.read<GroupStandingsCubit>().refreshGroups(),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      StandingsTable(
                        group: group,
                        onTeamTap: (teamCode) => () => _onTeamTap(teamCode),
                      ),
                      const SizedBox(height: 16),
                      _buildLegend(),
                    ],
                  ),
                ),
              );
            }),
          );
        },
      ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Qualification',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryEmerald.withOpacity(0.2),
                    border: Border.all(color: AppTheme.secondaryEmerald),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Qualified (Top 2)',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange.withOpacity(0.2),
                    border: Border.all(color: AppTheme.primaryOrange),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Possible Qualification (Best 3rd place)',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Tiebreakers (in order):',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '1. Points\n'
              '2. Goal difference\n'
              '3. Goals scored\n'
              '4. Head-to-head points\n'
              '5. Fair play (yellow/red cards)\n'
              '6. Drawing of lots',
              style: TextStyle(fontSize: 12, height: 1.5, color: Colors.white60),
            ),
          ],
        ),
      ),
    );
  }

  void _onTeamTap(String teamCode) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Team: $teamCode'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

/// Grid view of all groups (alternative layout)
class GroupsGridPage extends StatelessWidget {
  const GroupsGridPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupStandingsCubit, GroupStandingsState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: state.groups.length,
          itemBuilder: (context, index) {
            final group = state.groups[index];
            return GroupCard(
              group: group,
              onTap: () {
                // Navigate to group detail
              },
            );
          },
        );
      },
    );
  }
}

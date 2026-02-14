import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/app_theme.dart';
import '../../domain/entities/entities.dart';
import '../bloc/bloc.dart';
import '../widgets/widgets.dart';

/// Page displaying the World Cup knockout bracket
class BracketPage extends StatefulWidget {
  const BracketPage({super.key});

  @override
  State<BracketPage> createState() => _BracketPageState();
}

class _BracketPageState extends State<BracketPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _rounds = [
    ('Round of 32', MatchStage.roundOf32),
    ('Round of 16', MatchStage.roundOf16),
    ('Quarter-Finals', MatchStage.quarterFinal),
    ('Semi-Finals', MatchStage.semiFinal),
    ('Finals', null), // Shows both 3rd place and final
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _rounds.length, vsync: this);
    context.read<BracketCubit>().init();
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
        title: const Text('Knockout Bracket', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          BlocBuilder<BracketCubit, BracketState>(
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
                onPressed: () => context.read<BracketCubit>().refreshBracket(),
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
          tabs: _rounds.map((r) => Tab(text: r.$1)).toList(),
        ),
      ),
      body: Container(
        decoration: AppTheme.mainGradientDecoration,
        child: SafeArea(
          child: BlocBuilder<BracketCubit, BracketState>(
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
                    onPressed: () => context.read<BracketCubit>().loadBracket(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state.bracket == null) {
            return const Center(
              child: Text('Bracket data not available yet', style: TextStyle(color: Colors.white70)),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildRoundView(state, MatchStage.roundOf32),
              _buildRoundView(state, MatchStage.roundOf16),
              _buildRoundView(state, MatchStage.quarterFinal),
              _buildRoundView(state, MatchStage.semiFinal),
              _buildFinalsView(state),
            ],
          );
        },
      ),
        ),
      ),
    );
  }

  Widget _buildRoundView(BracketState state, MatchStage stage) {
    final matches = state.getMatchesForRound(stage);

    if (matches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.schedule, size: 64, color: Colors.white.withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text(
              'Matches not yet determined',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Teams will be set after group stage',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white38,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppTheme.secondaryEmerald,
      onRefresh: () => context.read<BracketCubit>().refreshBracket(),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: matches.length,
        itemBuilder: (context, index) {
          return BracketMatchCard(
            match: matches[index],
            onTap: () => _onMatchTap(matches[index]),
          );
        },
      ),
    );
  }

  Widget _buildFinalsView(BracketState state) {
    final thirdPlace = state.bracket?.thirdPlace;
    final finalMatch = state.bracket?.finalMatch;
    final winner = context.read<BracketCubit>().getTournamentWinner();

    return RefreshIndicator(
      color: AppTheme.secondaryEmerald,
      onRefresh: () => context.read<BracketCubit>().refreshBracket(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Winner display
            WinnerDisplay(
              teamCode: winner,
              teamName: _getTeamName(winner),
            ),
            const SizedBox(height: 24),

            // Final match
            if (finalMatch != null) ...[
              const Text(
                'Final',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: BracketMatchCard(
                  match: finalMatch,
                  onTap: () => _onMatchTap(finalMatch),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Third place match
            if (thirdPlace != null) ...[
              const Text(
                'Third Place Play-off',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white60,
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: BracketMatchCard(
                  match: thirdPlace,
                  onTap: () => _onMatchTap(thirdPlace),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String? _getTeamName(String? teamCode) {
    // In a real app, look up the team name from the teams cubit
    return teamCode;
  }

  void _onMatchTap(BracketMatch match) {
    context.read<BracketCubit>().selectMatch(match);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${match.team1.teamCode ?? "TBD"} vs ${match.team2.teamCode ?? "TBD"}',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

/// Full bracket visualization (horizontal scrolling)
class FullBracketView extends StatelessWidget {
  const FullBracketView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BracketCubit, BracketState>(
      builder: (context, state) {
        if (state.bracket == null) {
          return const Center(child: Text('No bracket data'));
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Round of 32 (Left side)
                  _buildRoundColumn(
                    'Round of 32',
                    state.bracket!.roundOf32.take(8).toList(),
                  ),
                  const SizedBox(width: 20),

                  // Round of 16 (Left side)
                  _buildRoundColumn(
                    'Round of 16',
                    state.bracket!.roundOf16.take(4).toList(),
                  ),
                  const SizedBox(width: 20),

                  // Quarter-finals (Left side)
                  _buildRoundColumn(
                    'Quarter-Final',
                    state.bracket!.quarterFinals.take(2).toList(),
                  ),
                  const SizedBox(width: 20),

                  // Semi-final (Left side)
                  _buildRoundColumn(
                    'Semi-Final',
                    state.bracket!.semiFinals.take(1).toList(),
                  ),
                  const SizedBox(width: 40),

                  // Final
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'FINAL',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.accentGold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (state.bracket!.finalMatch != null)
                        BracketMatchCard(match: state.bracket!.finalMatch!),
                    ],
                  ),
                  const SizedBox(width: 40),

                  // Semi-final (Right side)
                  _buildRoundColumn(
                    'Semi-Final',
                    state.bracket!.semiFinals.skip(1).toList(),
                  ),
                  const SizedBox(width: 20),

                  // Quarter-finals (Right side)
                  _buildRoundColumn(
                    'Quarter-Final',
                    state.bracket!.quarterFinals.skip(2).toList(),
                  ),
                  const SizedBox(width: 20),

                  // Round of 16 (Right side)
                  _buildRoundColumn(
                    'Round of 16',
                    state.bracket!.roundOf16.skip(4).toList(),
                  ),
                  const SizedBox(width: 20),

                  // Round of 32 (Right side)
                  _buildRoundColumn(
                    'Round of 32',
                    state.bracket!.roundOf32.skip(8).toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoundColumn(String title, List<BracketMatch> matches) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),
        ...matches.map((match) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: BracketMatchCard(match: match),
        )),
      ],
    );
  }
}

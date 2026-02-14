import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/app_theme.dart';
import '../../domain/entities/entities.dart';
import '../bloc/bloc.dart';
import '../widgets/widgets.dart';

/// Bracket tab content for the World Cup home screen.
/// Displays the knockout stage bracket with round-by-round sections.
class BracketTab extends StatelessWidget {
  const BracketTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BracketCubit, BracketState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (state.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  state.errorMessage!,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: AppTheme.buttonGradientDecoration,
                  child: ElevatedButton(
                    onPressed: () => context.read<BracketCubit>().loadBracket(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: const Text('Retry'),
                  ),
                ),
              ],
            ),
          );
        }

        if (state.bracket == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_tree, size: 64, color: Colors.white38),
                const SizedBox(height: 16),
                const Text(
                  'Knockout bracket not available yet',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white60,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Check back after group stage',
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
          color: Colors.white,
          backgroundColor: AppTheme.backgroundCard,
          onRefresh: () => context.read<BracketCubit>().refreshBracket(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current round indicator
                if (state.currentActiveRound != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryEmerald.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.secondaryEmerald.withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.play_arrow, color: AppTheme.secondaryEmerald),
                        const SizedBox(width: 8),
                        Text(
                          'Current: ${_getStageName(state.currentActiveRound!)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Round sections
                _buildRoundSection('Round of 32', state.bracket!.roundOf32),
                _buildRoundSection('Round of 16', state.bracket!.roundOf16),
                _buildRoundSection('Quarter-Finals', state.bracket!.quarterFinals),
                _buildRoundSection('Semi-Finals', state.bracket!.semiFinals),
                if (state.bracket!.thirdPlace != null)
                  _buildRoundSection('Third Place', [state.bracket!.thirdPlace!]),
                if (state.bracket!.finalMatch != null)
                  _buildRoundSection('Final', [state.bracket!.finalMatch!]),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoundSection(String title, List<BracketMatch> matches) {
    if (matches.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: matches.map((match) => BracketMatchCard(match: match)).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  String _getStageName(MatchStage stage) {
    switch (stage) {
      case MatchStage.roundOf32:
        return 'Round of 32';
      case MatchStage.roundOf16:
        return 'Round of 16';
      case MatchStage.quarterFinal:
        return 'Quarter-Finals';
      case MatchStage.semiFinal:
        return 'Semi-Finals';
      case MatchStage.thirdPlace:
        return 'Third Place';
      case MatchStage.final_:
        return 'Final';
      default:
        return '';
    }
  }
}

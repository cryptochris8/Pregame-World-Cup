import 'package:flutter/material.dart';

import '../../../../config/app_theme.dart';
import '../../../../data/services/player_service.dart';
import '../../../../domain/models/player.dart';
import 'comparison_player_card.dart';
import 'comparison_stat_widgets.dart';
import 'player_selection_sheet.dart';

/// Screen for comparing two players side by side
/// Shows stats comparison with visual indicators
class PlayerComparisonScreen extends StatefulWidget {
  final Player? initialPlayer1;
  final Player? initialPlayer2;

  const PlayerComparisonScreen({
    super.key,
    this.initialPlayer1,
    this.initialPlayer2,
  });

  @override
  State<PlayerComparisonScreen> createState() => _PlayerComparisonScreenState();
}

class _PlayerComparisonScreenState extends State<PlayerComparisonScreen> {
  final PlayerService _playerService = PlayerService();

  Player? _player1;
  Player? _player2;
  List<Player> _allPlayers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _player1 = widget.initialPlayer1;
    _player2 = widget.initialPlayer2;
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    setState(() => _isLoading = true);
    try {
      final players = await _playerService.getAllPlayers();
      if (mounted) {
        setState(() {
          _allPlayers = players;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _selectPlayer(int slot) async {
    final selected = await showModalBottomSheet<Player>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PlayerSelectionSheet(
        players: _allPlayers,
        excludePlayer: slot == 1 ? _player2 : _player1,
      ),
    );

    if (selected != null && mounted) {
      setState(() {
        if (slot == 1) {
          _player1 = selected;
        } else {
          _player2 = selected;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.mainGradientDecoration,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppTheme.accentGold),
                      )
                    : _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryOrange.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.compare_arrows,
                color: AppTheme.primaryOrange, size: 28),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Player Comparison',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Compare stats side by side',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Player selection cards
          Row(
            children: [
              Expanded(
                child: ComparisonPlayerCard(
                  player: _player1,
                  slot: 1,
                  onTap: () => _selectPlayer(1),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.compare_arrows,
                  color: AppTheme.accentGold, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: ComparisonPlayerCard(
                  player: _player2,
                  slot: 2,
                  onTap: () => _selectPlayer(2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Comparison stats
          if (_player1 != null && _player2 != null) ...[
            const ComparisonSectionHeader(title: 'Basic Info'),
            ComparisonStatRow(label: 'Age', value1: _player1!.age.toDouble(), value2: _player2!.age.toDouble(), unit: 'years', lowerIsBetter: true),
            ComparisonStatRow(label: 'Height', value1: _player1!.height.toDouble(), value2: _player2!.height.toDouble(), unit: 'cm'),
            ComparisonStatRow(label: 'Weight', value1: _player1!.weight.toDouble(), value2: _player2!.weight.toDouble(), unit: 'kg'),
            ComparisonStatRow(label: 'Market Value', value1: _player1!.marketValue / 1000000, value2: _player2!.marketValue / 1000000, unit: 'M\u20AC'),

            const SizedBox(height: 16),
            const ComparisonSectionHeader(title: 'International Career'),
            ComparisonStatRow(label: 'Caps', value1: _player1!.caps.toDouble(), value2: _player2!.caps.toDouble(), unit: ''),
            ComparisonStatRow(label: 'Goals', value1: _player1!.goals.toDouble(), value2: _player2!.goals.toDouble(), unit: ''),
            ComparisonStatRow(label: 'Assists', value1: _player1!.assists.toDouble(), value2: _player2!.assists.toDouble(), unit: ''),
            ComparisonStatRow(label: 'Goals/Game', value1: _player1!.goalsPerGame, value2: _player2!.goalsPerGame, unit: '', decimals: 2),
            ComparisonStatRow(label: 'Assists/Game', value1: _player1!.assistsPerGame, value2: _player2!.assistsPerGame, unit: '', decimals: 2),

            const SizedBox(height: 16),
            const ComparisonSectionHeader(title: 'World Cup Stats'),
            ComparisonStatRow(label: 'WC Appearances', value1: _player1!.worldCupAppearances.toDouble(), value2: _player2!.worldCupAppearances.toDouble(), unit: ''),
            ComparisonStatRow(label: 'WC Goals', value1: _player1!.worldCupGoals.toDouble(), value2: _player2!.worldCupGoals.toDouble(), unit: ''),
            ComparisonStatRow(label: 'WC Assists', value1: _player1!.worldCupAssists.toDouble(), value2: _player2!.worldCupAssists.toDouble(), unit: ''),
            ComparisonStatRow(label: 'Legacy Rating', value1: _player1!.worldCupLegacyRating.toDouble(), value2: _player2!.worldCupLegacyRating.toDouble(), unit: ''),

            const SizedBox(height: 16),
            const ComparisonSectionHeader(title: 'Club Season Stats'),
            ComparisonStatRow(label: 'Appearances', value1: _player1!.stats.club.appearances.toDouble(), value2: _player2!.stats.club.appearances.toDouble(), unit: ''),
            ComparisonStatRow(label: 'Club Goals', value1: _player1!.stats.club.goals.toDouble(), value2: _player2!.stats.club.goals.toDouble(), unit: ''),
            ComparisonStatRow(label: 'Club Assists', value1: _player1!.stats.club.assists.toDouble(), value2: _player2!.stats.club.assists.toDouble(), unit: ''),
            ComparisonStatRow(label: 'Minutes', value1: _player1!.stats.club.minutesPlayed.toDouble(), value2: _player2!.stats.club.minutesPlayed.toDouble(), unit: ''),

            const SizedBox(height: 24),
          ] else ...[
            const ComparisonEmptyState(),
          ],
        ],
      ),
    );
  }
}

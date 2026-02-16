import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';
import '../../data/datasources/world_cup_firestore_datasource.dart';
import '../../domain/entities/head_to_head.dart';
import 'team_flag.dart';
import 'matchup_overall_record.dart';
import 'matchup_world_cup_record.dart';
import 'matchup_goals_comparison.dart';
import 'matchup_notable_matches.dart';

/// Displays head-to-head matchup data between two teams
class MatchupPreviewWidget extends StatefulWidget {
  final String team1Code;
  final String team2Code;
  final String? team1Name;
  final String? team2Name;
  final String? team1FlagUrl;
  final String? team2FlagUrl;
  final bool showNotableMatches;
  final int maxNotableMatches;
  final bool compact;

  const MatchupPreviewWidget({
    super.key,
    required this.team1Code,
    required this.team2Code,
    this.team1Name,
    this.team2Name,
    this.team1FlagUrl,
    this.team2FlagUrl,
    this.showNotableMatches = true,
    this.maxNotableMatches = 3,
    this.compact = false,
  });

  @override
  State<MatchupPreviewWidget> createState() => _MatchupPreviewWidgetState();
}

class _MatchupPreviewWidgetState extends State<MatchupPreviewWidget> {
  HeadToHead? _headToHead;
  bool _isLoading = true;
  String? _error;
  bool _showAllMatches = false;

  @override
  void initState() {
    super.initState();
    _loadHeadToHead();
  }

  @override
  void didUpdateWidget(MatchupPreviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.team1Code != widget.team1Code ||
        oldWidget.team2Code != widget.team2Code) {
      _loadHeadToHead();
    }
  }

  Future<void> _loadHeadToHead() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final datasource = WorldCupFirestoreDataSource();
      final h2h = await datasource.getHeadToHead(
        widget.team1Code,
        widget.team2Code,
      );
      if (mounted) {
        setState(() {
          _headToHead = h2h;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load head-to-head data';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_headToHead == null) {
      return _buildFirstMeetingState();
    }

    return _buildContent();
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      padding: const EdgeInsets.all(16),
      child: const Column(
        children: [
          Row(
            children: [
              Icon(Icons.compare_arrows, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Head to Head',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          CircularProgressIndicator(
            color: AppTheme.accentGold,
            strokeWidth: 2,
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.compare_arrows, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Head to Head',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _error!,
            style: const TextStyle(color: Colors.white38),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _loadHeadToHead,
            child: const Text(
              'Retry',
              style: TextStyle(color: AppTheme.accentGold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFirstMeetingState() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.accentGold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: AppTheme.accentGold.withValues(alpha: 0.3)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: AppTheme.accentGold, size: 20),
                SizedBox(width: 8),
                Text(
                  'Historic First Meeting!',
                  style: TextStyle(
                    color: AppTheme.accentGold,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'These teams have never played against each other',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final h2h = _headToHead!;

    // Determine which team code matches our widget teams
    final team1IsH2HTeam1 = widget.team1Code == h2h.team1Code;
    final displayT1Wins = team1IsH2HTeam1 ? h2h.team1Wins : h2h.team2Wins;
    final displayT2Wins = team1IsH2HTeam1 ? h2h.team2Wins : h2h.team1Wins;
    final displayT1Goals = team1IsH2HTeam1 ? h2h.team1Goals : h2h.team2Goals;
    final displayT2Goals = team1IsH2HTeam1 ? h2h.team2Goals : h2h.team1Goals;
    final displayT1WCWins =
        team1IsH2HTeam1 ? h2h.team1WorldCupWins : h2h.team2WorldCupWins;
    final displayT2WCWins =
        team1IsH2HTeam1 ? h2h.team2WorldCupWins : h2h.team1WorldCupWins;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                MatchupOverallRecord(
                  team1Wins: displayT1Wins,
                  team2Wins: displayT2Wins,
                  draws: h2h.draws,
                  totalMatches: h2h.totalMatches,
                ),
                if (h2h.worldCupMatches > 0) ...[
                  const SizedBox(height: 16),
                  MatchupWorldCupRecord(
                    team1Wins: displayT1WCWins,
                    team2Wins: displayT2WCWins,
                    worldCupMatches: h2h.worldCupMatches,
                    worldCupDraws: h2h.worldCupDraws,
                    team1Name: widget.team1Name ?? widget.team1Code,
                    team2Name: widget.team2Name ?? widget.team2Code,
                  ),
                ],
                const SizedBox(height: 16),
                MatchupGoalsComparison(
                  team1Goals: displayT1Goals,
                  team2Goals: displayT2Goals,
                ),
              ],
            ),
          ),
          if (widget.showNotableMatches && h2h.notableMatches.isNotEmpty) ...[
            const Divider(color: Colors.white12, height: 1),
            MatchupNotableMatches(
              matches: h2h.notableMatches,
              maxNotableMatches: widget.maxNotableMatches,
              showAllMatches: _showAllMatches,
              team1Code: widget.team1Code,
              team2Code: widget.team2Code,
              team1Name: widget.team1Name,
              team2Name: widget.team2Name,
              h2hTeam1Code: h2h.team1Code,
              onShowMore: () => setState(() => _showAllMatches = true),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        TeamFlag(
          teamCode: widget.team1Code,
          flagUrl: widget.team1FlagUrl,
          size: 32,
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            children: [
              Icon(Icons.compare_arrows, color: Colors.white, size: 20),
              SizedBox(height: 4),
              Text(
                'HEAD TO HEAD',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.white70,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        TeamFlag(
          teamCode: widget.team2Code,
          flagUrl: widget.team2FlagUrl,
          size: 32,
        ),
      ],
    );
  }
}

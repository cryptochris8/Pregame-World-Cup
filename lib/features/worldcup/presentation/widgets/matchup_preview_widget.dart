import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';
import '../../data/datasources/world_cup_firestore_datasource.dart';
import '../../domain/entities/head_to_head.dart';
import 'team_flag.dart';

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
        border: Border.all(color: Colors.white.withOpacity(0.1)),
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
        border: Border.all(color: Colors.white.withOpacity(0.1)),
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
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.accentGold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.accentGold.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: AppTheme.accentGold, size: 20),
                const SizedBox(width: 8),
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
              color: Colors.white.withOpacity(0.6),
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

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
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
                _buildOverallRecord(h2h),
                if (h2h.worldCupMatches > 0) ...[
                  const SizedBox(height: 16),
                  _buildWorldCupRecord(h2h),
                ],
                const SizedBox(height: 16),
                _buildGoalsComparison(h2h),
              ],
            ),
          ),
          if (widget.showNotableMatches && h2h.notableMatches.isNotEmpty) ...[
            const Divider(color: Colors.white12, height: 1),
            _buildNotableMatches(h2h),
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

  Widget _buildOverallRecord(HeadToHead h2h) {
    final total = h2h.totalMatches;
    final t1Wins = h2h.team1Wins;
    final t2Wins = h2h.team2Wins;
    final draws = h2h.draws;

    // Determine which team code matches our widget teams
    final team1IsH2HTeam1 = widget.team1Code == h2h.team1Code;
    final displayT1Wins = team1IsH2HTeam1 ? t1Wins : t2Wins;
    final displayT2Wins = team1IsH2HTeam1 ? t2Wins : t1Wins;

    return Column(
      children: [
        // Visual bar comparison
        _buildWinBar(displayT1Wins, draws, displayT2Wins),
        const SizedBox(height: 12),
        // Stats row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatColumn(
              displayT1Wins.toString(),
              'Wins',
              AppTheme.primaryBlue,
            ),
            _buildStatColumn(
              draws.toString(),
              'Draws',
              Colors.grey,
            ),
            _buildStatColumn(
              displayT2Wins.toString(),
              'Wins',
              AppTheme.primaryOrange,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '$total total matches',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildWinBar(int team1Wins, int draws, int team2Wins) {
    final total = team1Wins + draws + team2Wins;
    if (total == 0) return const SizedBox.shrink();

    return Container(
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Expanded(
            flex: team1Wins > 0 ? team1Wins : 0,
            child: Container(color: AppTheme.primaryBlue),
          ),
          if (team1Wins > 0 && draws > 0)
            const SizedBox(width: 1),
          Expanded(
            flex: draws > 0 ? draws : 0,
            child: Container(color: Colors.grey),
          ),
          if (draws > 0 && team2Wins > 0)
            const SizedBox(width: 1),
          Expanded(
            flex: team2Wins > 0 ? team2Wins : 0,
            child: Container(color: AppTheme.primaryOrange),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildWorldCupRecord(HeadToHead h2h) {
    final team1IsH2HTeam1 = widget.team1Code == h2h.team1Code;
    final displayT1Wins = team1IsH2HTeam1 ? h2h.team1WorldCupWins : h2h.team2WorldCupWins;
    final displayT2Wins = team1IsH2HTeam1 ? h2h.team2WorldCupWins : h2h.team1WorldCupWins;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.accentGold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.accentGold.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events, color: AppTheme.accentGold, size: 16),
              const SizedBox(width: 6),
              Text(
                'World Cup Meetings',
                style: TextStyle(
                  color: AppTheme.accentGold,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(
                    displayT1Wins.toString(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    widget.team1Name ?? widget.team1Code,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${h2h.worldCupMatches} matches',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white70,
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    displayT2Wins.toString(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    widget.team2Name ?? widget.team2Code,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (h2h.worldCupDraws > 0)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '${h2h.worldCupDraws} draw${h2h.worldCupDraws > 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGoalsComparison(HeadToHead h2h) {
    final team1IsH2HTeam1 = widget.team1Code == h2h.team1Code;
    final t1Goals = team1IsH2HTeam1 ? h2h.team1Goals : h2h.team2Goals;
    final t2Goals = team1IsH2HTeam1 ? h2h.team2Goals : h2h.team1Goals;
    final totalGoals = t1Goals + t2Goals;

    if (totalGoals == 0) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Goals',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              t1Goals.toString(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                ),
                clipBehavior: Clip.antiAlias,
                child: Row(
                  children: [
                    Expanded(
                      flex: t1Goals > 0 ? t1Goals : 1,
                      child: Container(color: AppTheme.primaryBlue),
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      flex: t2Goals > 0 ? t2Goals : 1,
                      child: Container(color: AppTheme.primaryOrange),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              t2Goals.toString(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryOrange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotableMatches(HeadToHead h2h) {
    final matches = h2h.notableMatches;
    final displayCount = _showAllMatches
        ? matches.length
        : (matches.length > widget.maxNotableMatches
            ? widget.maxNotableMatches
            : matches.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            'Notable Matches',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...matches.take(displayCount).map((match) =>
          _buildHistoricalMatchCard(match, h2h),
        ),
        if (matches.length > widget.maxNotableMatches && !_showAllMatches)
          TextButton(
            onPressed: () => setState(() => _showAllMatches = true),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Show ${matches.length - widget.maxNotableMatches} more',
                    style: TextStyle(
                      color: AppTheme.accentGold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppTheme.accentGold,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildHistoricalMatchCard(HistoricalMatch match, HeadToHead h2h) {
    final team1IsH2HTeam1 = widget.team1Code == h2h.team1Code;
    final t1Score = team1IsH2HTeam1 ? match.team1Score : match.team2Score;
    final t2Score = team1IsH2HTeam1 ? match.team2Score : match.team1Score;

    // Determine winner for highlighting
    final isT1Winner = match.winnerCode == widget.team1Code;
    final isT2Winner = match.winnerCode == widget.team2Code;
    final isDraw = match.isDraw;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tournament and stage
          Row(
            children: [
              Expanded(
                child: Text(
                  match.tournament,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (match.stage != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStageColor(match.stage!).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    match.stage!,
                    style: TextStyle(
                      fontSize: 10,
                      color: _getStageColor(match.stage!),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Score row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.team1Name ?? widget.team1Code,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isT1Winner ? FontWeight.bold : FontWeight.normal,
                  color: isT1Winner
                      ? AppTheme.secondaryEmerald
                      : Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isDraw
                      ? Colors.grey.withOpacity(0.3)
                      : (isT1Winner
                          ? AppTheme.secondaryEmerald.withOpacity(0.2)
                          : AppTheme.secondaryEmerald.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$t1Score - $t2Score',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                widget.team2Name ?? widget.team2Code,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isT2Winner ? FontWeight.bold : FontWeight.normal,
                  color: isT2Winner
                      ? AppTheme.secondaryEmerald
                      : Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Year and location
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                match.year.toString(),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
              if (match.location != null) ...[
                Text(
                  ' | ',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
                Text(
                  match.location!,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ],
          ),
          // Description
          if (match.description != null) ...[
            const SizedBox(height: 6),
            Text(
              match.description!,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.4),
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Color _getStageColor(String stage) {
    final stageLower = stage.toLowerCase();
    if (stageLower.contains('final') && !stageLower.contains('quarter') && !stageLower.contains('semi')) {
      return AppTheme.accentGold;
    } else if (stageLower.contains('semi')) {
      return Colors.purpleAccent;
    } else if (stageLower.contains('quarter')) {
      return Colors.blueAccent;
    } else if (stageLower.contains('round of 16') || stageLower.contains('knockout')) {
      return Colors.tealAccent;
    } else {
      return Colors.white70;
    }
  }
}

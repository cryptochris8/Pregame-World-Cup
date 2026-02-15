import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';
import '../../domain/entities/match_summary.dart';
import 'team_flag.dart';

/// AI Match Summary Widget
/// Displays comprehensive AI-generated match analysis including:
/// - Historical analysis
/// - Key storylines
/// - Players to watch
/// - Tactical preview
/// - Predictions
class AIMatchSummaryWidget extends StatefulWidget {
  final MatchSummary summary;
  final bool initiallyExpanded;

  const AIMatchSummaryWidget({
    super.key,
    required this.summary,
    this.initiallyExpanded = false,
  });

  @override
  State<AIMatchSummaryWidget> createState() => _AIMatchSummaryWidgetState();
}

class _AIMatchSummaryWidgetState extends State<AIMatchSummaryWidget> {
  late bool _isExpanded;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.backgroundElevated,
            AppTheme.backgroundElevated.withValues(alpha:0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryPurple.withValues(alpha:0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          if (_isExpanded) ...[
            _buildTabBar(),
            _buildTabContent(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return InkWell(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryPurple, AppTheme.primaryBlue],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI MATCH PREVIEW',
                    style: TextStyle(
                      color: AppTheme.primaryPurple,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.summary.team1Name} vs ${widget.summary.team2Name}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (widget.summary.isFirstMeeting)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withValues(alpha:0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      color: AppTheme.accentGold,
                      size: 12,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'FIRST MEETING',
                      style: TextStyle(
                        color: AppTheme.accentGold,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(width: 8),
            Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
              color: Colors.white54,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = ['Analysis', 'Players', 'Prediction'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final isSelected = _selectedTab == entry.key;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = entry.key),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected
                          ? AppTheme.primaryPurple
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  entry.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white54,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Padding(
        key: ValueKey(_selectedTab),
        padding: const EdgeInsets.all(16),
        child: switch (_selectedTab) {
          0 => _buildAnalysisTab(),
          1 => _buildPlayersTab(),
          2 => _buildPredictionTab(),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }

  Widget _buildAnalysisTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          'Historical Analysis',
          Icons.history,
          child: Text(
            widget.summary.historicalAnalysis,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildSection(
          'Key Storylines',
          Icons.article,
          child: Column(
            children: widget.summary.keyStorylines.map((storyline) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryPurple,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        storyline,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),
        _buildSection(
          'Tactical Preview',
          Icons.sports_soccer,
          child: Text(
            widget.summary.tacticalPreview,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ),
        if (widget.summary.funFacts.isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildSection(
            'Fun Facts',
            Icons.lightbulb_outline,
            child: Column(
              children: widget.summary.funFacts.map((fact) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '\u2022 ',
                        style: TextStyle(
                          color: AppTheme.accentGold,
                          fontSize: 14,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          fact,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPlayersTab() {
    // Group players by team
    final team1Players = widget.summary.playersToWatch
        .where((p) => p.teamCode == widget.summary.team1Code)
        .toList();
    final team2Players = widget.summary.playersToWatch
        .where((p) => p.teamCode == widget.summary.team2Code)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (team1Players.isNotEmpty) ...[
          _buildTeamPlayersSection(widget.summary.team1Name, widget.summary.team1Code, team1Players),
          const SizedBox(height: 24),
        ],
        if (team2Players.isNotEmpty)
          _buildTeamPlayersSection(widget.summary.team2Name, widget.summary.team2Code, team2Players),
      ],
    );
  }

  Widget _buildTeamPlayersSection(String teamName, String teamCode, List<PlayerToWatch> players) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            TeamFlag(
              teamCode: teamCode,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              teamName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...players.map((player) => _buildPlayerCard(player)),
      ],
    );
  }

  Widget _buildPlayerCard(PlayerToWatch player) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha:0.1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryPurple, AppTheme.primaryBlue],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  player.position,
                  style: const TextStyle(
                    color: AppTheme.primaryPurple,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  player.reason,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionTab() {
    final prediction = widget.summary.prediction;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Prediction header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryPurple.withValues(alpha:0.2),
                AppTheme.primaryBlue.withValues(alpha:0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.primaryPurple.withValues(alpha:0.3),
            ),
          ),
          child: Column(
            children: [
              const Text(
                'AI PREDICTION',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TeamFlag(
                    teamCode: widget.summary.team1Code,
                    size: 36,
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryPurple, AppTheme.primaryBlue],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      prediction.predictedScore,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  TeamFlag(
                    teamCode: widget.summary.team2Code,
                    size: 36,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildConfidenceMeter(prediction.confidence),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Reasoning
        _buildSection(
          'Reasoning',
          Icons.psychology,
          child: Text(
            prediction.reasoning,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ),

        if (prediction.alternativeScenario != null) ...[
          const SizedBox(height: 20),
          _buildSection(
            'Alternative Scenario',
            Icons.compare_arrows,
            child: Text(
              prediction.alternativeScenario!,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 14,
                height: 1.6,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],

        if (widget.summary.pastEncountersSummary != null) ...[
          const SizedBox(height: 20),
          _buildSection(
            'Past Encounters',
            Icons.history_edu,
            child: Text(
              widget.summary.pastEncountersSummary!,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildConfidenceMeter(int confidence) {
    Color getConfidenceColor() {
      if (confidence >= 75) return AppTheme.secondaryEmerald;
      if (confidence >= 50) return AppTheme.primaryOrange;
      return AppTheme.primaryRed;
    }

    String getConfidenceLabel() {
      if (confidence >= 80) return 'High Confidence';
      if (confidence >= 60) return 'Moderate Confidence';
      if (confidence >= 40) return 'Low Confidence';
      return 'Uncertain';
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$confidence%',
              style: TextStyle(
                color: getConfidenceColor(),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              getConfidenceLabel(),
              style: TextStyle(
                color: getConfidenceColor().withValues(alpha:0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: confidence / 100,
            backgroundColor: Colors.white.withValues(alpha:0.1),
            valueColor: AlwaysStoppedAnimation(getConfidenceColor()),
            minHeight: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, IconData icon, {required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: AppTheme.primaryPurple,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/entities.dart';
import '../widgets/widgets.dart';

/// Detailed view of a national team
class TeamDetailPage extends StatelessWidget {
  final NationalTeam team;

  const TeamDetailPage({
    super.key,
    required this.team,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Container(
        decoration: AppTheme.mainGradientDecoration,
        child: CustomScrollView(
        slivers: [
          // Team header
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getConfederationColor().withValues(alpha:0.8),
                      _getConfederationColor(),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Flag
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha:0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: TeamFlag(
                              flagUrl: team.flagUrl,
                              teamCode: team.fifaCode,
                              size: 80,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Country name
                        Text(
                          team.countryName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // FIFA code and confederation
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha:0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                team.fifaCode,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              team.confederation.displayName,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha:0.9),
                              ),
                            ),
                          ],
                        ),

                        // Host nation badge
                        if (team.isHostNation) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.home, size: 16, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  l10n.hostNation,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Team details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick stats row
                  _buildQuickStats(context),
                  const SizedBox(height: 16),

                  // Team info card
                  _buildInfoCard(context),
                  const SizedBox(height: 16),

                  // World Cup history
                  _buildWorldCupHistory(context),
                  const SizedBox(height: 16),

                  // Group info (if assigned)
                  if (team.group != null) ...[
                    _buildGroupInfo(context),
                    const SizedBox(height: 16),
                  ],

                  // Team matches
                  _buildTeamMatches(context),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.leaderboard,
            label: l10n.fifaRanking,
            value: team.fifaRanking != null ? '#${team.fifaRanking}' : 'N/A',
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.emoji_events,
            label: l10n.worldCupTitles,
            value: '${team.worldCupTitles}',
            color: Colors.amber.shade700,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.grid_view,
            label: l10n.group,
            value: team.group ?? 'TBD',
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha:0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white60,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha:0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.teamInformation,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.flag, l10n.country, team.countryName),
            Divider(color: Colors.white.withValues(alpha:0.1)),
            _buildInfoRow(Icons.code, l10n.fifaCode, team.fifaCode),
            Divider(color: Colors.white.withValues(alpha:0.1)),
            _buildInfoRow(Icons.public, l10n.confederation, team.confederation.displayName),
            Divider(color: Colors.white.withValues(alpha:0.1)),
            _buildInfoRow(
              Icons.star,
              l10n.shortName,
              team.shortName,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.white60),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(color: Colors.white60),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildWorldCupHistory(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha:0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.history, color: AppTheme.accentGold),
                const SizedBox(width: 8),
                Text(
                  l10n.worldCupHistory,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (team.worldCupTitles > 0) ...[
              Row(
                children: [
                  ...List.generate(
                    team.worldCupTitles,
                    (index) => const Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Icon(
                        Icons.emoji_events,
                        color: AppTheme.accentGold,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.titleCount(team.worldCupTitles),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentGold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _getWorldCupWinYears(),
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 13,
                ),
              ),
            ] else
              Text(
                l10n.noWorldCupTitlesYet,
                style: const TextStyle(color: Colors.white38),
              ),
          ],
        ),
      ),
    );
  }

  String _getWorldCupWinYears() {
    // Historical World Cup winners
    final winners = {
      'BRA': '1958, 1962, 1970, 1994, 2002',
      'GER': '1954, 1974, 1990, 2014',
      'ITA': '1934, 1938, 1982, 2006',
      'ARG': '1978, 1986, 2022',
      'FRA': '1998, 2018',
      'URU': '1930, 1950',
      'ENG': '1966',
      'ESP': '2010',
    };
    return winners[team.fifaCode] ?? '';
  }

  Widget _buildGroupInfo(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard.withValues(alpha:0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha:0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.grid_view, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  l10n.groupLabel(team.group!),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // Navigate to group standings
                  },
                  child: Text(l10n.viewStandings, style: const TextStyle(color: AppTheme.accentGold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.tapToSeeGroupStandings,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamMatches(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha:0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.sports_soccer, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  l10n.matches,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // Navigate to filtered match list
                  },
                  child: Text(l10n.viewAll, style: const TextStyle(color: AppTheme.accentGold)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                l10n.teamMatchesWillAppear,
                style: const TextStyle(color: Colors.white38),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getConfederationColor() {
    switch (team.confederation) {
      case Confederation.uefa:
        return Colors.blue.shade700;
      case Confederation.conmebol:
        return Colors.green.shade700;
      case Confederation.concacaf:
        return Colors.orange.shade700;
      case Confederation.caf:
        return Colors.brown.shade700;
      case Confederation.afc:
        return Colors.red.shade700;
      case Confederation.ofc:
        return Colors.teal.shade700;
    }
  }
}

/// Mini team card for inline display
class TeamMiniCard extends StatelessWidget {
  final NationalTeam team;
  final VoidCallback? onTap;

  const TeamMiniCard({
    super.key,
    required this.team,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha:0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                TeamFlag(
                  flagUrl: team.flagUrl,
                  teamCode: team.fifaCode,
                  size: 40,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        team.countryName,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Row(
                        children: [
                          if (team.fifaRanking != null) ...[
                            Text(
                              '#${team.fifaRanking}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white60,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            team.confederation.name,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white38),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

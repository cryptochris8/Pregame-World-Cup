import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../domain/models/player.dart';
import '../widgets/player_photo.dart';

/// Player Detail Screen - displays full profile for a single player.
/// Includes header card, career stats, World Cup history, honors,
/// strengths/weaknesses, play style, and trivia.
class PlayerDetailScreen extends StatelessWidget {
  final Player player;

  const PlayerDetailScreen({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(player.commonName),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card with gradient
            _PlayerHeaderCard(player: player),

            // Stats section
            _SectionCard(
              title: l10n.careerStatistics,
              child: Column(
                children: [
                  _StatRow(label: l10n.internationalCaps, value: '${player.caps}'),
                  _StatRow(label: l10n.internationalGoals, value: '${player.goals}'),
                  _StatRow(label: l10n.internationalAssists, value: '${player.assists}'),
                  _StatRow(label: l10n.worldCupAppearances, value: '${player.worldCupAppearances}'),
                  _StatRow(label: l10n.worldCupGoals, value: '${player.worldCupGoals}'),
                  if (player.worldCupAssists > 0)
                    _StatRow(label: 'World Cup Assists', value: '${player.worldCupAssists}'),
                  if (player.previousWorldCups.isNotEmpty)
                    _StatRow(
                      label: l10n.previousWorldCups,
                      value: player.previousWorldCups.join(', '),
                    ),
                ],
              ),
            ),

            // World Cup History section
            if (player.worldCupTournamentStats.isNotEmpty ||
                player.worldCupAwards.isNotEmpty ||
                player.memorableMoments.isNotEmpty)
              _WorldCupHistorySection(player: player),

            // Honors
            if (player.honors.isNotEmpty)
              _SectionCard(
                title: l10n.honors,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: player.honors.map((honor) =>
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 8),
                          Expanded(child: Text(honor)),
                        ],
                      ),
                    ),
                  ).toList(),
                ),
              ),

            // Strengths & Weaknesses
            _PlayerProfileSection(player: player),

            // Play style
            _SectionCard(
              title: l10n.playStyle,
              child: Text(player.playStyle),
            ),

            // Key moment
            _SectionCard(
              title: l10n.keyMoment,
              child: Text(player.keyMoment),
            ),

            // Legend comparison
            _SectionCard(
              title: l10n.comparisonToLegend,
              child: Text(player.comparisonToLegend),
            ),

            // World Cup 2026 prediction
            _SectionCard(
              title: l10n.worldCup2026Prediction,
              child: Text(player.worldCup2026Prediction),
            ),

            // Trivia
            if (player.trivia.isNotEmpty)
              _SectionCard(
                title: l10n.funFacts,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: player.trivia.asMap().entries.map((entry) =>
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${entry.key + 1}. ', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Expanded(child: Text(entry.value)),
                        ],
                      ),
                    ),
                  ).toList(),
                ),
              ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// Header card with gradient background, photo, name, and info chips
class _PlayerHeaderCard extends StatelessWidget {
  final Player player;

  const _PlayerHeaderCard({required this.player});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF7C3AED),
            Color(0xFF3B82F6),
            Color(0xFFEA580C),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha:0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircularPlayerPhoto(
              photoUrl: player.photoUrl,
              playerName: player.commonName,
              size: 120,
              borderColor: Colors.white,
              borderWidth: 3,
            ),
            const SizedBox(height: 16),
            Text(
              player.fullName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${player.club} • ${player.clubLeague}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha:0.9),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _InfoChip(label: '${player.fifaCode} #${player.jerseyNumber}'),
                _InfoChip(label: player.positionDisplayName),
                _InfoChip(label: '${player.age} years'),
                _InfoChip(label: player.formattedMarketValue),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Strengths and weaknesses profile section
class _PlayerProfileSection extends StatelessWidget {
  final Player player;

  const _PlayerProfileSection({required this.player});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return _SectionCard(
      title: l10n.profile,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.strengths, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: player.strengths.map((s) =>
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.secondaryEmerald, Color(0xFF059669)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  s,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ).toList(),
          ),
          const SizedBox(height: 16),
          Text(l10n.weaknesses, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: player.weaknesses.map((w) =>
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryOrange, AppTheme.primaryRed],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  w,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ).toList(),
          ),
        ],
      ),
    );
  }
}

/// World Cup History Section - displays tournament stats, awards, and memorable moments
class _WorldCupHistorySection extends StatelessWidget {
  final Player player;

  const _WorldCupHistorySection({required this.player});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with trophy icon
            Row(
              children: [
                const Icon(Icons.emoji_events, color: Colors.amber, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'World Cup History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (player.worldCupLegacyRating > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getLegacyColor(player.worldCupLegacyRating),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${player.worldCupLegacyRating}/10',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Tournament Stats
            if (player.worldCupTournamentStats.isNotEmpty) ...[
              const Text(
                'Tournament History',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              ...player.worldCupTournamentStats.map((stats) =>
                _TournamentStatsCard(stats: stats),
              ),
              const SizedBox(height: 12),
            ],

            // World Cup Awards
            if (player.worldCupAwards.isNotEmpty) ...[
              const Text(
                'World Cup Awards',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: player.worldCupAwards.map((award) =>
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.amber[700]!, Colors.amber[400]!],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.military_tech, size: 16, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          award,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).toList(),
              ),
              const SizedBox(height: 12),
            ],

            // Memorable Moments
            if (player.memorableMoments.isNotEmpty) ...[
              const Text(
                'Memorable Moments',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              ...player.memorableMoments.asMap().entries.map((entry) =>
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getLegacyColor(int rating) {
    if (rating >= 9) return Colors.amber[700]!;
    if (rating >= 7) return Colors.green[600]!;
    if (rating >= 5) return Colors.blue[600]!;
    return Colors.grey[600]!;
  }
}

/// Tournament Stats Card - shows individual World Cup performance
class _TournamentStatsCard extends StatelessWidget {
  final WorldCupTournamentStats stats;

  const _TournamentStatsCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha:0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Year and Stage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'World Cup ${stats.year}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _getStageGradient(stats.stage),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  stats.stage,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MiniStat(label: 'Matches', value: stats.matches),
              _MiniStat(label: 'Goals', value: stats.goals),
              _MiniStat(label: 'Assists', value: stats.assists),
            ],
          ),
          // Key moment
          if (stats.keyMoment != null) ...[
            const SizedBox(height: 10),
            Text(
              stats.keyMoment!,
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.white.withValues(alpha:0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Color> _getStageGradient(String stage) {
    final stageLower = stage.toLowerCase();
    if (stageLower.contains('winner') || stageLower == 'final') {
      return [AppTheme.accentGold, const Color(0xFFD97706)];
    } else if (stageLower.contains('third')) {
      return [const Color(0xFF92400E), const Color(0xFF78350F)];
    } else if (stageLower.contains('semi')) {
      return [AppTheme.primaryPurple, AppTheme.secondaryPurple];
    } else if (stageLower.contains('quarter')) {
      return [AppTheme.primaryBlue, const Color(0xFF1D4ED8)];
    } else if (stageLower.contains('round of 16')) {
      return [const Color(0xFF0D9488), const Color(0xFF0F766E)];
    } else {
      return [AppTheme.backgroundElevated, const Color(0xFF475569)];
    }
  }
}

/// Mini stat display for tournament cards
class _MiniStat extends StatelessWidget {
  final String label;
  final int value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha:0.6),
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;

  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: Colors.white.withValues(alpha:0.2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}

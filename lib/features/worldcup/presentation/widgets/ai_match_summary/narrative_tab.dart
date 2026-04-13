import 'package:flutter/material.dart';
import '../../../../../config/app_theme.dart';
import '../../../domain/entities/match_narrative.dart';
import 'prediction_components.dart';

/// The Pregame Article tab — renders the AI-generated sports journalism
/// narrative with headline, opening narrative, tactical breakdown,
/// data insights, player spotlights, verdict, and closing line.
class NarrativeTab extends StatelessWidget {
  final MatchNarrative narrative;

  const NarrativeTab({super.key, required this.narrative});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Headline + Subheadline
        _HeadlineSection(narrative: narrative),
        const SizedBox(height: 24),

        // Opening Narrative
        _NarrativeTextSection(text: narrative.openingNarrative),
        const SizedBox(height: 28),

        // Tactical Breakdown
        _TacticalSection(breakdown: narrative.tacticalBreakdown),
        const SizedBox(height: 28),

        // By The Numbers
        if (narrative.dataInsights.entries.isNotEmpty) ...[
          _DataInsightsSection(insights: narrative.dataInsights),
          const SizedBox(height: 28),
        ],

        // Player Spotlights
        if (narrative.playerSpotlights.isNotEmpty) ...[
          _PlayerSpotlightsSection(players: narrative.playerSpotlights),
          const SizedBox(height: 28),
        ],

        // The Verdict
        _VerdictSection(verdict: narrative.verdict),
        const SizedBox(height: 24),

        // Closing Line
        _ClosingLine(text: narrative.closingLine),
      ],
    );
  }
}

// ==========================================================================
// Headline Section — gradient banner like the city guide header
// ==========================================================================

class _HeadlineSection extends StatelessWidget {
  final MatchNarrative narrative;

  const _HeadlineSection({required this.narrative});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryPurple, AppTheme.primaryBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'PREGAME ANALYSIS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Semantics(
            header: true,
            child: Text(
              narrative.headline,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                height: 1.3,
                letterSpacing: -0.3,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            narrative.subheadline,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 14,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================================
// Narrative Text (the opening article body)
// ==========================================================================

class _NarrativeTextSection extends StatelessWidget {
  final String text;

  const _NarrativeTextSection({required this.text});

  @override
  Widget build(BuildContext context) {
    final paragraphs = text.split('\n\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: paragraphs.asMap().entries.map((entry) {
        return Padding(
          padding: EdgeInsets.only(bottom: entry.key < paragraphs.length - 1 ? 16 : 0),
          child: Text(
            entry.value.trim(),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.7,
              letterSpacing: 0.1,
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ==========================================================================
// Gradient Section Header
// ==========================================================================

class _GradientSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _GradientSectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Semantics(
        header: true,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryPurple, AppTheme.primaryBlue],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
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
      ),
    );
  }
}

// ==========================================================================
// Tactical Breakdown
// ==========================================================================

class _TacticalSection extends StatelessWidget {
  final TacticalBreakdown breakdown;

  const _TacticalSection({required this.breakdown});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GradientSectionHeader(title: breakdown.title, icon: Icons.schema_outlined),

        // Formation chips
        if (breakdown.team1Formation.isNotEmpty) ...[
          Row(
            children: [
              _FormationChip(formation: breakdown.team1Formation),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'vs',
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ),
              _FormationChip(formation: breakdown.team2Formation),
            ],
          ),
          const SizedBox(height: 16),
        ],

        // Tactical narrative
        _NarrativeTextSection(text: breakdown.narrative),

        // Key Matchup callout — gradient border
        if (breakdown.keyMatchup.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryPurple.withValues(alpha: 0.15),
                  AppTheme.primaryBlue.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppTheme.primaryPurple.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExcludeSemantics(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryOrange, AppTheme.accentGold],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.bolt, color: Colors.white, size: 14),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'KEY MATCHUP',
                        style: TextStyle(
                          color: AppTheme.accentGold,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        breakdown.keyMatchup,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _FormationChip extends StatelessWidget {
  final String formation;

  const _FormationChip({required this.formation});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Formation $formation',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryPurple.withValues(alpha: 0.2),
              AppTheme.primaryBlue.withValues(alpha: 0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primaryBlue.withValues(alpha: 0.4),
          ),
        ),
        child: Text(
          formation,
          style: const TextStyle(
            color: AppTheme.primaryBlue,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ==========================================================================
// Data Insights (By The Numbers) — gradient icon backgrounds
// ==========================================================================

class _DataInsightsSection extends StatelessWidget {
  final DataInsights insights;

  const _DataInsightsSection({required this.insights});

  static const _icons = {
    'Strength Rating': Icons.trending_up,
    'Current Form': Icons.show_chart,
    'Squad Investment': Icons.attach_money,
    'Availability': Icons.healing,
    'Market View': Icons.casino_outlined,
    'History': Icons.history_edu,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GradientSectionHeader(title: insights.title, icon: Icons.analytics_outlined),
        ...insights.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Semantics(
              label: '${entry.key}: ${entry.value}',
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExcludeSemantics(
                    child: Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryPurple.withValues(alpha: 0.2),
                            AppTheme.primaryBlue.withValues(alpha: 0.15),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        _icons[entry.key] ?? Icons.info_outline,
                        color: AppTheme.primaryBlue,
                        size: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          entry.value,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ==========================================================================
// Player Spotlights — gradient accent on cards
// ==========================================================================

class _PlayerSpotlightsSection extends StatelessWidget {
  final List<PlayerSpotlight> players;

  const _PlayerSpotlightsSection({required this.players});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GradientSectionHeader(title: 'Players To Watch', icon: Icons.stars_outlined),
        ...players.asMap().entries.map((entry) {
          final player = entry.value;
          final isLast = entry.key == players.length - 1;

          final semanticParts = [
            '${player.name}, ${player.teamCode}',
            player.narrative,
            if (player.statline != null) 'Stats: ${player.statline}',
          ];
          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
            child: Semantics(
              label: semanticParts.join('. '),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryPurple.withValues(alpha: 0.08),
                      AppTheme.primaryBlue.withValues(alpha: 0.04),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryPurple.withValues(alpha: 0.15),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.primaryOrange, AppTheme.primaryRed],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            player.teamCode,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            player.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      player.narrative,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),
                    if (player.statline != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryEmerald.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const ExcludeSemantics(
                              child: Icon(
                                Icons.bar_chart,
                                color: AppTheme.secondaryEmerald,
                                size: 14,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                player.statline!,
                                style: const TextStyle(
                                  color: AppTheme.secondaryEmerald,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
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
          );
        }),
      ],
    );
  }
}

// ==========================================================================
// The Verdict — gradient prediction card
// ==========================================================================

class _VerdictSection extends StatelessWidget {
  final NarrativeVerdict verdict;

  const _VerdictSection({required this.verdict});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GradientSectionHeader(title: verdict.title, icon: Icons.gavel_outlined),

        // Prediction score + confidence — bold gradient card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryPurple, AppTheme.primaryBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Text(
                verdict.prediction,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),
              Semantics(
                label: 'Confidence: ${verdict.confidence}%',
                child: ConfidenceMeter(confidence: verdict.confidence),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Verdict narrative
        _NarrativeTextSection(text: verdict.narrative),

        // Alternative scenarios
        if (verdict.alternativeScenarios.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'ALTERNATIVE SCENARIOS',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          ...verdict.alternativeScenarios.map((scenario) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryPurple.withValues(alpha: 0.06),
                      AppTheme.primaryBlue.withValues(alpha: 0.03),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primaryOrange, AppTheme.primaryRed],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${scenario.probability}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            scenario.scenario,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            scenario.reasoning,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ],
    );
  }
}

// ==========================================================================
// Closing Line — gradient divider
// ==========================================================================

class _ClosingLine extends StatelessWidget {
  final String text;

  const _ClosingLine({required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ExcludeSemantics(
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppTheme.primaryPurple.withValues(alpha: 0.5),
                  AppTheme.primaryBlue.withValues(alpha: 0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.accentGold.withValues(alpha: 0.8),
              fontSize: 14,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

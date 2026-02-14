import 'package:flutter/material.dart';
import '../../domain/models/manager.dart';
import '../widgets/manager_photo.dart';

/// Manager Detail Screen - displays full profile for a single manager.
/// Includes header card, managerial record, tactical approach, honors,
/// strengths/weaknesses, quotes, career history, and trivia.
class ManagerDetailScreen extends StatelessWidget {
  final Manager manager;

  const ManagerDetailScreen({super.key, required this.manager});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(manager.commonName),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card with gradient
            _ManagerHeaderCard(manager: manager),

            // Managerial stats
            _SectionCard(
              title: 'Managerial Record',
              child: Column(
                children: [
                  _StatRow(label: 'Matches Managed', value: '${manager.stats.matchesManaged}'),
                  _StatRow(label: 'Record (W-D-L)', value: manager.stats.recordDisplay),
                  _StatRow(label: 'Win Percentage', value: manager.stats.formattedWinPercentage),
                  _StatRow(label: 'Titles Won', value: '${manager.stats.titlesWon}'),
                  _StatRow(label: 'Career Started', value: '${manager.managerialCareerStart}'),
                  _StatRow(label: 'Years in Current Role', value: '${manager.yearsInCurrentRole}'),
                ],
              ),
            ),

            // Tactical info
            _SectionCard(
              title: 'Tactical Approach',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Formation:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(manager.tacticalStyle, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 12),
                  const Text('Philosophy:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(manager.philosophy),
                ],
              ),
            ),

            // Honors
            if (manager.honors.isNotEmpty)
              _SectionCard(
                title: 'Honors & Achievements',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: manager.honors.map((honor) =>
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          const Icon(Icons.emoji_events, size: 16, color: Colors.amber),
                          const SizedBox(width: 8),
                          Expanded(child: Text(honor)),
                        ],
                      ),
                    ),
                  ).toList(),
                ),
              ),

            // Strengths & Weaknesses
            _ManagerProfileAnalysis(manager: manager),

            // Manager style
            _SectionCard(
              title: 'Manager Style',
              child: Text(manager.managerStyle),
            ),

            // Key moment
            _SectionCard(
              title: 'Defining Moment',
              child: Text(manager.keyMoment),
            ),

            // Famous quote
            if (manager.famousQuote.isNotEmpty)
              _FamousQuoteCard(quote: manager.famousQuote),

            // World Cup 2026 prediction
            _SectionCard(
              title: 'World Cup 2026 Outlook',
              child: Text(manager.worldCup2026Prediction),
            ),

            // Previous clubs
            if (manager.previousClubs.isNotEmpty)
              _SectionCard(
                title: 'Previous Clubs',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: manager.previousClubs.map((club) =>
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.grey[300]!,
                            Colors.grey[200]!,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey[400]!,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        club,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ).toList(),
                ),
              ),

            // Controversies
            if (manager.controversies.isNotEmpty)
              _ControversiesCard(controversies: manager.controversies),

            // Trivia
            if (manager.trivia.isNotEmpty)
              _SectionCard(
                title: 'Did You Know?',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: manager.trivia.asMap().entries.map((entry) =>
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF7C3AED),
                                  Color(0xFF3B82F6),
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF7C3AED).withOpacity(0.4),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                '${entry.key + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
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
class _ManagerHeaderCard extends StatelessWidget {
  final Manager manager;

  const _ManagerHeaderCard({required this.manager});

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
            color: const Color(0xFF7C3AED).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircularManagerPhoto(
              photoUrl: manager.photoUrl,
              managerName: manager.fullName,
              size: 120,
              borderColor: Colors.white,
              borderWidth: 3,
            ),
            const SizedBox(height: 16),
            Text(
              manager.fullName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              manager.currentTeam,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _InfoChip(label: manager.fifaCode),
                _InfoChip(label: '${manager.age} years old'),
                _InfoChip(label: manager.nationality),
                _InfoChip(label: '${manager.yearsOfExperience}y experience'),
                _InfoChip(label: manager.experienceCategory),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Strengths and weaknesses profile analysis section
class _ManagerProfileAnalysis extends StatelessWidget {
  final Manager manager;

  const _ManagerProfileAnalysis({required this.manager});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Profile Analysis',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Strengths:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: manager.strengths.map((s) =>
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF059669),
                      Color(0xFF10B981),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
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
          const Text('Weaknesses:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: manager.weaknesses.map((w) =>
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFDC2626),
                      Color(0xFFF43F5E),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF43F5E).withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
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

/// Famous quote card with styled gradient border
class _FamousQuoteCard extends StatelessWidget {
  final String quote;

  const _FamousQuoteCard({required this.quote});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue[400]!.withOpacity(0.15),
            Colors.purple[300]!.withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue[300]!.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.format_quote, color: Colors.blue[700], size: 24),
                const SizedBox(width: 8),
                Text(
                  'Famous Quote',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '"$quote"',
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.grey[800],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Controversies card with warning-styled gradient border
class _ControversiesCard extends StatelessWidget {
  final List<String> controversies;

  const _ControversiesCard({required this.controversies});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange[300]!.withOpacity(0.2),
            Colors.red[200]!.withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.orange[400]!.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange[800], size: 24),
                const SizedBox(width: 8),
                Text(
                  'Controversies',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[900],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...controversies.map((controversy) =>
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(fontSize: 16, color: Colors.grey[800])),
                    Expanded(
                      child: Text(
                        controversy,
                        style: TextStyle(color: Colors.grey[800]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
      backgroundColor: Colors.white.withOpacity(0.2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}

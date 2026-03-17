import '../../../data/services/chatbot_knowledge_base.dart';
import '../../entities/chat_intent.dart';
import '../../entities/chat_response.dart';
import 'response_format_helpers.dart';

/// Handles generation of prediction-related chatbot responses.
///
/// This includes match predictions and recent form analysis.
class PredictionResponses {
  /// The knowledge base containing tournament data.
  final ChatbotKnowledgeBase _kb;

  /// Creates a [PredictionResponses] instance.
  const PredictionResponses(this._kb);

  /// Generates a match prediction response.
  Future<ChatResponse> prediction(ChatIntent intent) async {
    final teamCode = intent.team;

    if (teamCode != null) {
      // Team-specific prediction
      final teamName = _kb.getTeamName(teamCode) ?? teamCode;
      final odds = _kb.getBettingOdds(teamCode);
      final form = _kb.getRecentFormSummary(teamCode);
      final sv = _kb.getSquadValue(teamCode);
      final injuries = _kb.getInjuryConcerns(teamCode);

      final buf = StringBuffer('$teamName — World Cup 2026 Outlook:\n\n');

      if (odds != null) {
        final tier = odds['tier'] ?? '';
        final prob = odds['implied_probability_pct'] ?? '';
        final american = odds['odds_american'] ?? '';
        buf.writeln('Odds: $american ($prob% implied probability) — Tier: $tier');
      }
      if (sv != null) {
        buf.writeln('Squad value: ${sv['totalValueFormatted']} (ranked #${sv['rank']})');
        final mvp = sv['mostValuablePlayer'] as Map<String, dynamic>?;
        if (mvp != null) {
          buf.writeln('Most valuable: ${mvp['name']} (${mvp['value']})');
        }
      }
      if (form != null) {
        buf.writeln('Recent form: $form');
      }
      if (injuries.isNotEmpty) {
        buf.writeln('Injury concerns: ${injuries.map((i) => i['playerName']).join(', ')}');
      }

      return ChatResponse(
        text: buf.toString().trim(),
        suggestionChips: ['$teamName schedule', '$teamName squad', 'Tournament favorites'],
        resolvedIntent: intent,
      );
    }

    // General tournament favorites
    final favorites = _kb.getTopFavorites(limit: 8);
    if (favorites.isEmpty) {
      return ChatResponse(
        text: "I don't have odds data loaded yet. Try asking about a specific team!",
        suggestionChips: ['Brazil chances', 'France chances', 'England chances'],
        resolvedIntent: intent,
      );
    }

    final buf = StringBuffer('World Cup 2026 — Tournament Favorites:\n\n');

    final topTier = favorites.where((o) => o['tier'] == 'favorite').toList();
    final contenders = favorites.where((o) => o['tier'] == 'contender').toList();
    final darkHorses = favorites.where((o) => o['tier'] == 'dark_horse' || o['tier'] == 'dark horse').toList();

    if (topTier.isNotEmpty) {
      buf.writeln('Favorites:');
      for (final t in topTier) {
        buf.writeln('  ${t['team']} (${t['odds_american']}, ${t['implied_probability_pct']}%)');
      }
    }
    if (contenders.isNotEmpty) {
      buf.writeln('Contenders:');
      for (final t in contenders.take(4)) {
        buf.writeln('  ${t['team']} (${t['odds_american']}, ${t['implied_probability_pct']}%)');
      }
    }
    if (darkHorses.isNotEmpty) {
      buf.writeln('Dark horses:');
      for (final t in darkHorses.take(3)) {
        buf.writeln('  ${t['team']} (${t['odds_american']}, ${t['implied_probability_pct']}%)');
      }
    }

    final chipNames = favorites.take(3).map((t) => '${t['team']} outlook').toList();
    return ChatResponse(
      text: buf.toString().trim(),
      suggestionChips: [...chipNames, 'World Cup history'],
      resolvedIntent: intent,
    );
  }

  /// Generates a recent form analysis for a team.
  Future<ChatResponse> recentForm(ChatIntent intent) async {
    final teamCode = intent.team;

    if (teamCode == null) {
      return ChatResponse(
        text: "Which team's recent form would you like to see?",
        suggestionChips: ['USA form', 'Argentina form', 'France form', 'Brazil form'],
        resolvedIntent: intent,
      );
    }

    final teamName = _kb.getTeamName(teamCode) ?? teamCode;
    final formData = _kb.getRecentForm(teamCode);
    final formSummary = _kb.getRecentFormSummary(teamCode);

    if (formData == null && formSummary == null) {
      return ChatResponse(
        text: "I don't have recent form data for $teamName.",
        suggestionChips: ['$teamName schedule', '$teamName squad'],
        resolvedIntent: intent,
      );
    }

    final buf = StringBuffer('$teamName — Recent Form:\n\n');
    if (formSummary != null) {
      buf.writeln(formSummary);
      buf.writeln();
    }

    if (formData != null) {
      final matches = (formData['recent_matches'] ?? formData['matches']) as List<dynamic>?;
      if (matches != null && matches.isNotEmpty) {
        buf.writeln('Recent results:');
        for (final m in matches.take(5)) {
          final match = m as Map<String, dynamic>;
          final date = formatDate(match['date'] as String? ?? '');
          final opponent = match['opponent'] ?? '';
          final score = match['score'] ?? '';
          final result = match['result'] ?? '';
          final venue = match['venue'] ?? '';
          buf.writeln('  $result  $date: vs $opponent $score ($venue)');
        }
      }
    }

    return ChatResponse(
      text: buf.toString().trim(),
      suggestionChips: ['$teamName schedule', '$teamName prediction', '$teamName injuries'],
      resolvedIntent: intent,
    );
  }
}

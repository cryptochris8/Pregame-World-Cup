import '../../../data/services/chatbot_knowledge_base.dart';
import '../../entities/chat_intent.dart';
import '../../entities/chat_response.dart';
import 'response_format_helpers.dart';

/// Handles generation of match-related chatbot responses.
///
/// This includes schedules, head-to-head records, match previews,
/// odds, and standings.
class MatchResponses {
  /// The knowledge base containing tournament data.
  final ChatbotKnowledgeBase _kb;

  /// Creates a [MatchResponses] instance.
  const MatchResponses(this._kb);

  /// Generates a schedule response for a team or general schedule.
  Future<ChatResponse> schedule(ChatIntent intent) async {
    final teamCode = intent.team;
    if (teamCode == null) {
      return ChatResponse(
        text: "Which team's schedule would you like to see? The tournament runs "
            "June 11 - July 19, 2026, with 104 matches across 16 host cities.",
        suggestionChips: ['USA schedule', 'Mexico schedule', 'England schedule', 'Brazil schedule'],
        resolvedIntent: intent,
      );
    }

    final teamName = _kb.getTeamName(teamCode) ?? teamCode;
    final matches = _kb.getMatchesForTeam(teamCode);

    if (matches.isEmpty) {
      return ChatResponse(
        text: "I couldn't find any matches for $teamName. Make sure you're using a valid team name.",
        suggestionChips: ['Tournament schedule', 'Group stage', 'Help'],
        resolvedIntent: intent,
      );
    }

    final group = _kb.getTeamGroup(teamCode);
    final buf = StringBuffer('$teamName\'s World Cup 2026 schedule');
    if (group != null) buf.write(' (Group $group)');
    buf.writeln(':');
    buf.writeln();

    for (final m in matches) {
      final date = m['date'] as String? ?? '';
      final time = m['time'] as String? ?? '';
      final home = m['homeTeamName'] as String? ?? '';
      final away = m['awayTeamName'] as String? ?? '';
      final venue = m['venueName'] as String? ?? '';
      final city = m['venueCity'] as String? ?? '';
      final matchDay = m['groupMatchDay'];
      final stage = m['stage'] as String? ?? '';

      final dateFormatted = formatDate(date);
      final opponent = (m['homeTeamCode'] == teamCode) ? away : home;
      final homeAway = (m['homeTeamCode'] == teamCode) ? 'vs' : 'at';

      buf.write('- $dateFormatted');
      if (time.isNotEmpty) buf.write(', $time ET');
      buf.write(': $homeAway $opponent');
      if (venue.isNotEmpty) buf.write(' ($venue, $city)');
      if (stage == 'groupStage' && matchDay != null) {
        buf.write(' [MD$matchDay]');
      }
      buf.writeln();
    }

    final chips = <String>[];
    if (group != null) chips.add('Group $group matches');
    chips.add('$teamName squad');
    chips.add('$teamName prediction');

    return ChatResponse(
      text: buf.toString().trim(),
      suggestionChips: chips,
      resolvedIntent: intent,
    );
  }

  /// Generates a head-to-head comparison response between two teams.
  Future<ChatResponse> headToHead(ChatIntent intent) async {
    final code1 = intent.team1 ?? intent.team;
    final code2 = intent.team2;
    if (code1 == null || code2 == null) {
      return ChatResponse(
        text: "I need two teams for a head-to-head comparison. Try something like "
            "\"Argentina vs Brazil\" or \"USA vs Mexico\".",
        suggestionChips: ['Argentina vs Brazil', 'USA vs Mexico', 'England vs France'],
        resolvedIntent: intent,
      );
    }

    final name1 = _kb.getTeamName(code1) ?? code1;
    final name2 = _kb.getTeamName(code2) ?? code2;
    final h2h = await _kb.getHeadToHead(code1, code2);

    if (h2h == null) {
      return ChatResponse(
        text: "I don't have detailed head-to-head data for $name1 vs $name2, "
            "but I can help with their schedules or team info!",
        suggestionChips: ['$name1 schedule', '$name2 schedule', '$name1 vs $name2 preview'],
        resolvedIntent: intent,
      );
    }

    final total = h2h['totalMatches'] ?? 0;
    final t1Wins = h2h['team1Wins'] ?? 0;
    final t2Wins = h2h['team2Wins'] ?? 0;
    final draws = h2h['draws'] ?? 0;
    final t1Code = h2h['team1Code'] as String? ?? code1;
    final t2Code = h2h['team2Code'] as String? ?? code2;
    final t1Name = _kb.getTeamName(t1Code) ?? t1Code;
    final t2Name = _kb.getTeamName(t2Code) ?? t2Code;
    final wcMatches = h2h['worldCupMatches'] ?? 0;
    final lastMatch = h2h['lastMatch'] as String? ?? '';

    final buf = StringBuffer('$t1Name vs $t2Name — Head-to-Head:\n\n');
    buf.writeln('All-time: $total matches — $t1Name $t1Wins wins, $t2Name $t2Wins wins, $draws draws');
    if (wcMatches > 0) {
      buf.writeln('World Cup: $wcMatches meetings');
    }
    if (lastMatch.isNotEmpty) {
      buf.writeln('Last meeting: ${formatDate(lastMatch)}');
    }

    // Notable matches
    final notable = h2h['notableMatches'] as List<dynamic>?;
    if (notable != null && notable.isNotEmpty) {
      buf.writeln();
      buf.writeln('Notable World Cup encounters:');
      for (final nm in notable.take(3)) {
        final n = nm as Map<String, dynamic>;
        final year = n['year'];
        final stage = n['stage'] ?? '';
        final desc = n['description'] ?? '';
        buf.writeln('- $year $stage: $desc');
      }
    }

    return ChatResponse(
      text: buf.toString().trim(),
      suggestionChips: ['$t1Name schedule', '$t2Name schedule', '$t1Name vs $t2Name preview'],
      resolvedIntent: intent,
    );
  }

  /// Generates a match preview with detailed information.
  Future<ChatResponse> matchPreview(ChatIntent intent) async {
    final code1 = intent.team1 ?? intent.team;
    final code2 = intent.team2;
    if (code1 == null || code2 == null) {
      return ChatResponse(
        text: "I need two teams for a match preview. Try \"Argentina vs Brazil preview\".",
        suggestionChips: ['Brazil vs Argentina preview', 'USA vs Mexico preview'],
        resolvedIntent: intent,
      );
    }

    final name1 = _kb.getTeamName(code1) ?? code1;
    final name2 = _kb.getTeamName(code2) ?? code2;
    final summary = await _kb.getMatchSummary(code1, code2);

    if (summary == null) {
      return ChatResponse(
        text: "I don't have a detailed preview for $name1 vs $name2 yet.",
        suggestionChips: ['$name1 squad', '$name2 squad', '$name1 vs $name2 h2h'],
        resolvedIntent: intent,
      );
    }

    final buf = StringBuffer('$name1 vs $name2 — Match Preview:\n\n');

    final analysis = summary['historicalAnalysis'] as String?;
    if (analysis != null) {
      // Truncate to ~200 chars for brevity
      buf.writeln(analysis.length > 250 ? '${analysis.substring(0, 247)}...' : analysis);
      buf.writeln();
    }

    final storylines = summary['keyStorylines'] as List<dynamic>?;
    if (storylines != null && storylines.isNotEmpty) {
      buf.writeln('Key storylines:');
      for (final s in storylines.take(3)) {
        buf.writeln('- $s');
      }
      buf.writeln();
    }

    final prediction = summary['prediction'] as Map<String, dynamic>?;
    if (prediction != null) {
      final outcome = prediction['predictedOutcome'] ?? '';
      final score = prediction['predictedScore'] ?? '';
      final confidence = prediction['confidence'] ?? '';
      buf.writeln('Prediction: $outcome ($score) — $confidence% confidence');
    }

    final ptw = summary['playersToWatch'] as List<dynamic>?;
    if (ptw != null && ptw.isNotEmpty) {
      buf.writeln();
      buf.writeln('Players to watch:');
      for (final p in ptw.take(3)) {
        final pm = p as Map<String, dynamic>;
        buf.writeln('- ${pm['name']} (${pm['teamCode']}) — ${pm['reason']}');
      }
    }

    return ChatResponse(
      text: buf.toString().trim(),
      suggestionChips: ['$name1 vs $name2 h2h', '$name1 squad', '$name2 squad'],
      resolvedIntent: intent,
    );
  }

  /// Generates betting odds information for a match.
  ChatResponse odds(ChatIntent intent) {
    final favorites = _kb.getTopFavorites(limit: 10);
    if (favorites.isEmpty) {
      return ChatResponse(
        text: "Betting odds data is not available right now.",
        suggestionChips: ['Tournament favorites', 'Help'],
        resolvedIntent: intent,
      );
    }

    final buf = StringBuffer('World Cup 2026 — Betting Odds:\n\n');
    for (var i = 0; i < favorites.length; i++) {
      final t = favorites[i];
      buf.writeln('${i + 1}. ${t['team']} — ${t['odds_american']} '
          '(${t['implied_probability_pct']}% implied probability)');
    }
    buf.writeln();
    buf.writeln('Source: Consensus from major bookmakers (DraftKings, BetMGM, FanDuel)');

    return ChatResponse(
      text: buf.toString().trim(),
      suggestionChips: ['Top favorite outlook', 'Dark horses', 'World Cup history'],
      resolvedIntent: intent,
    );
  }

  /// Generates current tournament standings.
  ChatResponse standings(ChatIntent intent) {
    final groupLetter = intent.group;

    if (groupLetter != null) {
      final teams = _kb.getTeamsInGroup(groupLetter);
      final matches = _kb.getGroupMatches(groupLetter);

      if (teams.isEmpty) {
        return ChatResponse(
          text: "I couldn't find Group $groupLetter. Groups are labeled A through L.",
          suggestionChips: ['Group A', 'Group B', 'Group C'],
          resolvedIntent: intent,
        );
      }

      final buf = StringBuffer('Group $groupLetter:\n\n');
      buf.writeln('Teams: ${teams.map((c) => _kb.getTeamName(c) ?? c).join(', ')}');
      buf.writeln();
      buf.writeln('Matches:');
      for (final m in matches) {
        final date = formatDate(m['date'] as String? ?? '');
        final home = m['homeTeamName'] ?? '';
        final away = m['awayTeamName'] ?? '';
        final time = m['time'] as String? ?? '';
        final venue = m['venueName'] ?? '';
        buf.writeln('- $date, $time ET: $home vs $away ($venue)');
      }

      final chips = teams.take(2).map((c) => '${_kb.getTeamName(c)} schedule').toList();
      chips.add('Group ${groupLetter == 'L' ? 'A' : String.fromCharCode(groupLetter.codeUnitAt(0) + 1)}');

      return ChatResponse(
        text: buf.toString().trim(),
        suggestionChips: chips,
        resolvedIntent: intent,
      );
    }

    // Overview of all groups
    final buf = StringBuffer('World Cup 2026 Groups (48 teams, 12 groups):\n\n');
    for (final letter in ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L']) {
      final teams = _kb.getTeamsInGroup(letter);
      if (teams.isNotEmpty) {
        buf.writeln('Group $letter: ${teams.map((c) => _kb.getTeamName(c) ?? c).join(', ')}');
      }
    }

    return ChatResponse(
      text: buf.toString().trim(),
      suggestionChips: ['Group A', 'Group B', 'Group of Death'],
      resolvedIntent: intent,
    );
  }
}

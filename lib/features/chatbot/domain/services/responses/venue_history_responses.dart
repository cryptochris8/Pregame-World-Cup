import '../../../data/services/chatbot_knowledge_base.dart';
import '../../entities/chat_intent.dart';
import '../../entities/chat_response.dart';
import 'response_format_helpers.dart';

/// Handles generation of venue and history-related chatbot responses.
///
/// This includes venue information and tournament history.
class VenueHistoryResponses {
  /// The knowledge base containing tournament data.
  final ChatbotKnowledgeBase _kb;

  /// Creates a [VenueHistoryResponses] instance.
  const VenueHistoryResponses(this._kb);

  /// Generates venue information response.
  ChatResponse venue(ChatIntent intent) {
    final venueName = intent.venue;

    if (venueName != null) {
      final matches = _kb.getVenueMatches(venueName);
      final buf = StringBuffer('$venueName — this is going to be electric.\n\n');

      if (matches.isNotEmpty) {
        final city = matches.first['venueCity'] as String? ?? '';
        if (city.isNotEmpty) buf.writeln('Location: $city');
        buf.writeln('Hosting ${matches.length} matches — plenty of football to soak in.');
        buf.writeln();

        for (final m in matches.take(5)) {
          final date = formatDate(m['date'] as String? ?? '');
          final home = m['homeTeamName'] ?? '';
          final away = m['awayTeamName'] ?? '';
          final stage = m['stage'] as String? ?? '';
          final stageLabel = stage == 'groupStage' ? 'Group ${m['group']}' : stage;
          buf.writeln('- $date: $home vs $away ($stageLabel)');
        }
        if (matches.length > 5) {
          buf.writeln('...and ${matches.length - 5} more');
        }
      } else {
        buf.writeln('No match schedule for this venue just yet.');
      }

      return ChatResponse(
        text: buf.toString().trim(),
        suggestionChips: ['All venues', 'Tournament schedule'],
        resolvedIntent: intent,
      );
    }

    // List all venues
    final venues = _kb.getAllVenues();
    final buf = StringBuffer('2026 tournament — 16 iconic venues across North America. Here\'s the full list:\n\n');
    for (final v in venues) {
      // Get city from first match at this venue
      final matches = _kb.getVenueMatches(v);
      final city = matches.isNotEmpty ? (matches.first['venueCity'] ?? '') : '';
      buf.writeln('- $v${city.isNotEmpty ? ' ($city)' : ''} — ${matches.length} matches');
    }

    return ChatResponse(
      text: buf.toString().trim(),
      suggestionChips: ['MetLife Stadium', 'SoFi Stadium', 'Estadio Azteca'],
      resolvedIntent: intent,
    );
  }

  /// Generates tournament history response.
  ChatResponse history(ChatIntent intent) {
    final yearStr = intent.year;

    if (yearStr != null) {
      final year = int.tryParse(yearStr);
      if (year != null) {
        final tournament = _kb.getTournamentByYear(year);
        if (tournament != null) {
          final buf = StringBuffer('tournament $year — hosted by ${tournament['hostCountries']}. Here\'s the story:\n\n');
          buf.writeln('Champions: ${tournament['winner']} lifted the trophy.');
          buf.writeln('Runner-up: ${tournament['runnerUp']} came agonizingly close.');
          if (tournament['thirdPlace'] != null) {
            buf.writeln('Third place: ${tournament['thirdPlace']}');
          }
          buf.writeln('The final: ${tournament['finalScore']} at ${tournament['finalVenue']}, ${tournament['finalCity']}');
          buf.writeln('Golden Boot: ${tournament['topScorer']} found the back of the net ${tournament['topScorerGoals']} times.');
          buf.writeln('${tournament['totalMatches']} matches played, ${tournament['totalGoals']} goals scored.');

          final highlights = tournament['highlights'] as List<dynamic>?;
          if (highlights != null && highlights.isNotEmpty) {
            buf.writeln();
            buf.writeln('The moments that defined it:');
            for (final h in highlights.take(3)) {
              buf.writeln('- $h');
            }
          }

          // Suggest adjacent tournaments
          final chips = <String>[];
          if (year > 1930) chips.add('tournament ${year - 4}');
          if (year < 2022) chips.add('tournament ${year + 4}');
          chips.add('tournament records');

          return ChatResponse(
            text: buf.toString().trim(),
            suggestionChips: chips,
            resolvedIntent: intent,
          );
        }
      }
    }

    // General history / records
    final records = _kb.getRecords();
    if (records.isEmpty) {
      return ChatResponse(
        text: "Nearly a century of tournament football, from 1930 to 2022. "
            "Give me a year — \"2022 tournament\" or \"1970 tournament\" — and I'll tell you the story.",
        suggestionChips: ['2022 tournament', '2018 tournament', 'tournament records'],
        resolvedIntent: intent,
      );
    }

    final buf = StringBuffer('Tournament Records — numbers that tell the greatest stories in football:\n\n');
    for (final r in records.take(8)) {
      buf.writeln('${r['category']}: ${r['holder']} (${r['value']})');
      if (r['details'] != null) buf.writeln('  ${r['details']}');
    }

    // Recent winners
    final recentTournaments = _kb.getAllTournaments();
    if (recentTournaments.isNotEmpty) {
      buf.writeln();
      buf.writeln('The trophy\'s recent homes:');
      final recent = recentTournaments.reversed.take(5).toList();
      for (final t in recent) {
        buf.writeln('  ${t['year']}: ${t['winner']}');
      }
    }

    return ChatResponse(
      text: buf.toString().trim(),
      suggestionChips: ['2022 tournament', '2018 tournament', 'Most goals all time'],
      resolvedIntent: intent,
    );
  }
}

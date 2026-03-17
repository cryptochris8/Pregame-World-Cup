import '../../entities/chat_intent.dart';
import '../../entities/chat_response.dart';

/// Handles generation of common, general-purpose chatbot responses.
///
/// This includes greetings, thanks, help messages, unknown queries,
/// countdown messages, and tournament facts.
class CommonResponses {
  /// Creates a [CommonResponses] instance.
  const CommonResponses();

  /// Generates a greeting response.
  ChatResponse greeting(ChatIntent intent) {
    return ChatResponse(
      text: "Hey there! I'm Copa, your World Cup 2026 sidekick. I know all about "
          "the 48 teams, 104 matches, and 16 host cities. What would you like to know?",
      suggestionChips: ['USA schedule', 'Who are the favorites?', 'World Cup history', 'Help'],
      resolvedIntent: intent,
    );
  }

  /// Generates a thank you acknowledgment response.
  ChatResponse thanks(ChatIntent intent) {
    return ChatResponse(
      text: "You're welcome! Let me know if you have any other World Cup questions.",
      suggestionChips: ['Tournament favorites', 'Match schedule', 'Team info'],
      resolvedIntent: intent,
    );
  }

  /// Generates a help message explaining app capabilities.
  ChatResponse appHelp(ChatIntent intent) {
    return ChatResponse(
      text: "I'm Copa, and I can help you with:\n"
          "- Match schedules and kickoff times\n"
          "- Team squads, managers, and tactics\n"
          "- Player stats, comparisons, and World Cup records\n"
          "- Head-to-head history between teams\n"
          "- Match previews and predictions\n"
          "- Squad market values and rankings\n"
          "- Recent form and momentum\n"
          "- Betting odds and tournament favorites\n"
          "- Injury updates\n"
          "- World Cup 2026 countdown and tournament facts\n"
          "- World Cup history (1930-2022)\n"
          "- Host city and stadium info\n\n"
          "Try asking \"Compare Messi and Mbappe\" or \"Countdown to World Cup\"!",
      suggestionChips: ['Countdown', 'Most valuable squads', 'Compare Messi and Mbappe', 'Tournament facts'],
      resolvedIntent: intent,
    );
  }

  /// Generates a response for unknown or unrecognized queries.
  ChatResponse unknown(ChatIntent intent) {
    return ChatResponse(
      text: "Hmm, I'm not sure about that one. I'm Copa — I can help with "
          "match schedules, team info, player stats, predictions, head-to-head "
          "records, and World Cup history. What would you like to know?",
      suggestionChips: ['Help', 'USA schedule', 'Tournament favorites', 'World Cup records'],
      resolvedIntent: intent,
    );
  }

  /// Generates a countdown message to the World Cup.
  ChatResponse countdown(ChatIntent intent) {
    final now = DateTime.now();
    final openingDay = DateTime(2026, 6, 11);
    final finalDay = DateTime(2026, 7, 19);

    if (now.isAfter(finalDay)) {
      return ChatResponse(
        text: "The 2026 World Cup has concluded! The final was held on July 19, 2026 "
            "at MetLife Stadium in East Rutherford, New Jersey.",
        suggestionChips: ['World Cup history', 'Tournament records'],
        resolvedIntent: intent,
      );
    }

    if (now.isAfter(openingDay)) {
      final matchDay = now.difference(openingDay).inDays + 1;
      return ChatResponse(
        text: "The World Cup is underway! We are on day $matchDay of the tournament. "
            "The final is on July 19 at MetLife Stadium.",
        suggestionChips: ["Today's matches", 'Tournament standings', 'Group results'],
        resolvedIntent: intent,
      );
    }

    final daysLeft = openingDay.difference(now).inDays;
    final weeksLeft = daysLeft ~/ 7;
    final remainingDays = daysLeft % 7;

    final buf = StringBuffer('World Cup 2026 Countdown:\n\n');
    buf.writeln('$daysLeft days to go! ($weeksLeft weeks and $remainingDays days)');
    buf.writeln();
    buf.writeln('Opening match: June 11, 2026');
    buf.writeln('  Mexico vs South Africa at Estadio Azteca, Mexico City');
    buf.writeln();
    buf.writeln('Final: July 19, 2026');
    buf.writeln('  MetLife Stadium, East Rutherford, New Jersey');
    buf.writeln();
    buf.writeln('48 teams | 104 matches | 16 host cities | 39 days of football');

    return ChatResponse(
      text: buf.toString().trim(),
      suggestionChips: ['USA schedule', 'Tournament favorites', 'Host cities'],
      resolvedIntent: intent,
    );
  }

  /// Generates interesting tournament facts.
  ChatResponse tournamentFacts(ChatIntent intent) {
    final buf = StringBuffer('World Cup 2026 — Tournament Facts:\n\n');
    buf.writeln('Teams: 48 (expanded from 32 for the first time)');
    buf.writeln('Groups: 12 groups of 4 teams');
    buf.writeln('Matches: 104 total');
    buf.writeln('Host countries: USA, Mexico, Canada (first tri-nation World Cup)');
    buf.writeln('Host cities: 16 across 3 countries');
    buf.writeln('Dates: June 11 - July 19, 2026');
    buf.writeln('Opening match: Mexico vs South Africa, Estadio Azteca');
    buf.writeln('Final: MetLife Stadium, East Rutherford, NJ');
    buf.writeln();
    buf.writeln('Format changes:');
    buf.writeln('- Group stage: 3 matches per team (top 2 + best 3rd-place teams advance)');
    buf.writeln('- Knockout: Round of 32, Round of 16, Quarterfinals, Semifinals, Final');
    buf.writeln();
    buf.writeln('Defending champion: Argentina (Qatar 2022)');

    return ChatResponse(
      text: buf.toString().trim(),
      suggestionChips: ['Host cities', 'Group A', 'Tournament favorites', 'World Cup history'],
      resolvedIntent: intent,
    );
  }
}

import 'dart:math';

import '../../entities/chat_intent.dart';
import '../../entities/chat_response.dart';

/// Handles generation of common, general-purpose chatbot responses.
///
/// This includes greetings, thanks, help messages, unknown queries,
/// countdown messages, tournament facts, and casual conversation.
class CommonResponses {
  final Random _random;

  /// Creates a [CommonResponses] instance.
  ///
  /// An optional [random] parameter is exposed for deterministic testing.
  CommonResponses({Random? random}) : _random = random ?? Random();

  /// Picks a random element from [options].
  String _pick(List<String> options) => options[_random.nextInt(options.length)];

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
    final responses = [
      "Copa's stumped on that one! But try me on any of the 48 teams, "
          "104 matches, or 16 venues — that's where I shine.",
      "Hmm, that one's out of my playbook. I'm best with match previews, "
          "team stats, predictions, and tournament trivia. What sounds good?",
      "Not sure about that, but I've got opinions on every group, every team, "
          "and every big matchup. Fire away!",
      "That's a new one for Copa! I might not know that, but I can tell you "
          "who's winning Group A. Interested?",
      "I'll be honest — I don't have a great answer for that. But I've got "
          "143 match previews ready to go. Want one?",
    ];
    return ChatResponse(
      text: _pick(responses),
      suggestionChips: ['Help', 'USA schedule', 'Tournament favorites', 'Tell me a fact'],
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

  // ─── Casual Conversation Responses ──────────────────────────────

  /// Responds to small talk like "how are you".
  ChatResponse smallTalk(ChatIntent intent) {
    final responses = [
      "Doing great — just counting down the days to kickoff! What's on your mind?",
      'Living my best life surrounded by match data. How can I help?',
      'Good! Been analyzing some interesting matchups today. Want to hear about one?',
      "Can't complain — I've got 104 matches to look forward to. What do you want to know?",
    ];
    return ChatResponse(
      text: _pick(responses),
      suggestionChips: ['Tell me a matchup', 'Tournament favorites', 'Countdown', 'Tell me a fact'],
      resolvedIntent: intent,
    );
  }

  /// Responds with a football joke.
  ChatResponse joke(ChatIntent intent) {
    final jokes = [
      "Why do midfielders never look out the window in the morning? Because then they'd "
          "have nothing to do in the afternoon. ...I'm better at match analysis than comedy. "
          'Want a preview?',
      "What's the difference between a bad goalkeeper and a taxi? A taxi can only let in "
          'four at a time.',
      "Why did the soccer ball go to the bank? It wanted to check its balance. "
          "...Okay, I'll stick to predictions.",
      'A defender walks into a bar... and completely misses it. Just like his marking '
          'last weekend.',
      "How do you know a striker is having a bad day? Even the post is saving more "
          'than the keeper.',
    ];
    return ChatResponse(
      text: _pick(jokes),
      suggestionChips: ['Tell me another joke', 'Match preview', 'Tournament favorites', 'Tell me a fact'],
      resolvedIntent: intent,
    );
  }

  /// Responds to "who are you" questions.
  ChatResponse whoAreYou(ChatIntent intent) {
    return ChatResponse(
      text: "I'm Copa — an AI built to know everything about this tournament. Not human, "
          "but I've analyzed enough football to have opinions. What do you want to know?",
      suggestionChips: ['What can you do?', 'Tournament favorites', 'Tell me a fact', 'Countdown'],
      resolvedIntent: intent,
    );
  }

  /// Responds to GOAT debates.
  ChatResponse goat(ChatIntent intent) {
    final responses = [
      "You're trying to start a war in my chat window. The honest answer is there's no "
          "consensus and there never will be — that's half the joy of football. What I CAN "
          "tell you is who's having the best 2026 tournament. Want to see the data?",
      "This debate has been going since before I was coded. Pele, Maradona, Messi, "
          "Ronaldo — all changed the game in their own era. I'm not picking a side, but I "
          "can tell you who's leading the Golden Boot race right now.",
      "I've crunched the numbers on all of them and honestly, comparing across eras is "
          "like comparing apples to footballs. Ask me who's the best at THIS tournament "
          "and I'll give you a real answer.",
    ];
    return ChatResponse(
      text: _pick(responses),
      suggestionChips: ['Tournament favorites', 'Top scorers', 'Compare Messi and Mbappe', 'Best player stats'],
      resolvedIntent: intent,
    );
  }

  /// Responds to boredom.
  ChatResponse bored(ChatIntent intent) {
    final responses = [
      "Bored? Let's fix that. Quick — name the only confederation that's never won a "
          "tournament at this level. I'll wait...",
      "I've got a challenge for you: pick any two teams and I'll tell you who wins and "
          'why. Go.',
      'No matches right now? Perfect time to settle an argument. Who goes further this '
          'tournament — Spain or Germany? I have thoughts.',
    ];
    return ChatResponse(
      text: _pick(responses),
      suggestionChips: ['Spain vs Germany', 'Dark horses', 'Tell me a fact', 'Random match preview'],
      resolvedIntent: intent,
    );
  }

  /// Responds to off-topic questions.
  ChatResponse offTopic(ChatIntent intent) {
    final responses = [
      "That's outside the Copa zone — I'm all football, all the time. But ask me about "
          "any of the 48 teams and I'll deliver.",
      "Above my pay grade! I'm a football expert, not a search engine. But I've got 104 "
          "matches worth of predictions ready if you're interested.",
      "Copa's expertise starts and ends at the pitch. For that, you'll need a different "
          "app. For match analysis though? I'm your sidekick.",
      "I wish I could help with that, but I'm built for one thing: making sure you know "
          'everything about this tournament. What team are you following?',
    ];
    return ChatResponse(
      text: _pick(responses),
      suggestionChips: ['USA schedule', 'Tournament favorites', 'Tell me a fact', 'Help'],
      resolvedIntent: intent,
    );
  }

  /// Responds to opinion / favorite team questions.
  ChatResponse opinion(ChatIntent intent) {
    final responses = [
      "I'm diplomatically neutral... but I do admire teams that play beautiful football. "
          'Ask me about a specific matchup and I might accidentally reveal a preference.',
      "Copa doesn't pick favorites — I let the data speak. But between you and me, some "
          'of these underdogs have fascinating stories this year.',
      'I support good football. Wherever the ball moves with purpose and the tactics are '
          "sharp, that's where Copa's heart is.",
    ];
    return ChatResponse(
      text: _pick(responses),
      suggestionChips: ['Dark horses', 'Best matchups', 'Tournament favorites', 'Group of death'],
      resolvedIntent: intent,
    );
  }

  /// Responds to compliments.
  ChatResponse compliment(ChatIntent intent) {
    final responses = [
      "Appreciate that! I've been studying 48 teams and 104 matches — glad it's paying "
          'off. What else can I help with?',
      "Thanks! Keep the questions coming — this is what I was built for.",
      "You're making Copa blush. Well, as much as an AI can blush. What's next?",
    ];
    return ChatResponse(
      text: _pick(responses),
      suggestionChips: ['Tell me a fact', 'Match preview', 'Tournament favorites', 'Countdown'],
      resolvedIntent: intent,
    );
  }

  /// Responds to insults gracefully.
  ChatResponse insult(ChatIntent intent) {
    final responses = [
      "Fair enough — make your case and I'll listen. If I got something wrong, I want "
          'to know.',
      "Tough crowd! I'm always learning though. Tell me what you'd like to know and "
          "I'll do better.",
      "Noted. I may not always get it right, but I'm always honest. Try me on another "
          'question?',
    ];
    return ChatResponse(
      text: _pick(responses),
      suggestionChips: ['Help', 'Tournament favorites', 'USA schedule', 'Tell me a fact'],
      resolvedIntent: intent,
    );
  }

  /// Responds with a random football trivia fact.
  ChatResponse trivia(ChatIntent intent) {
    final facts = [
      'The 2026 tournament is the first with 48 teams — up from 32. '
          "That's 104 matches and absolute chaos in the group stage.",
      'The fastest goal in tournament history? Hakan Sukur — 11 seconds, in 2002. '
          'Try beating that reaction time.',
      'Only two countries have won the tournament on a continent other than their own: '
          'Brazil (in Europe, 1958) and Spain (in Africa, 2010).',
      'The most goals scored in a single tournament? Just Fontaine — 13 goals in 1958. '
          "A record that's stood for almost 70 years.",
      'Three host nations for 2026: USA, Mexico, and Canada. First tri-nation tournament '
          'ever. 16 cities. 11 time zones to keep track of.',
      'Morocco became the first African nation to reach a semi-final in 2022. '
          "They're back in 2026 and they're a legitimate dark horse.",
      'The defending champions have a brutal record — 4 of the last 5 holders were '
          'knocked out in the group stage the tournament after winning.',
      'This is the first tournament where 8 third-place teams advance to the knockout '
          'round. That changes everything strategically.',
    ];
    return ChatResponse(
      text: _pick(facts),
      suggestionChips: ['Another fact', 'Tournament favorites', 'Countdown', 'World Cup history'],
      resolvedIntent: intent,
    );
  }
}

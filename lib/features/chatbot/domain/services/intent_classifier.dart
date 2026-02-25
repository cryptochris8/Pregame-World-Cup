import '../entities/chat_intent.dart';
import '../../data/services/chatbot_knowledge_base.dart';

/// Classifies user messages into intent types with entity extraction.
///
/// Uses priority-ordered keyword/pattern matching across 16 intent types.
/// Extracts entities like team names, player names, venues, years, and groups.
class IntentClassifier {
  final ChatbotKnowledgeBase _knowledgeBase;

  /// Last mentioned team code, for pronoun resolution ("their", "them").
  String? _lastMentionedTeam;

  IntentClassifier({required ChatbotKnowledgeBase knowledgeBase})
      : _knowledgeBase = knowledgeBase;

  /// Classify a user message into an intent with extracted entities.
  ChatIntent classify(String message) {
    final lower = message.toLowerCase().trim();
    final entities = <String, String>{};

    // Extract entities first
    final teams = _extractTeams(lower);
    final player = _extractPlayer(lower);
    final venue = _extractVenue(lower);
    final year = _extractYear(lower);
    final group = _extractGroup(lower);

    if (teams.isNotEmpty) {
      entities['team'] = teams.first;
      _lastMentionedTeam = teams.first;
      if (teams.length > 1) {
        entities['team1'] = teams[0];
        entities['team2'] = teams[1];
      }
    }
    if (player != null) entities['player'] = player;
    if (venue != null) entities['venue'] = venue;
    if (year != null) entities['year'] = year;
    if (group != null) entities['group'] = group;

    // Resolve pronouns
    if (entities['team'] == null && _hasPronoun(lower) && _lastMentionedTeam != null) {
      entities['team'] = _lastMentionedTeam!;
    }

    // Priority-ordered intent detection
    // 1. Greeting
    if (_isGreeting(lower)) {
      return ChatIntent(type: ChatIntentType.greeting, entities: entities);
    }

    // 2. Thanks
    if (_isThanks(lower)) {
      return ChatIntent(type: ChatIntentType.thanks, entities: entities);
    }

    // 3. App help
    if (_isAppHelp(lower)) {
      return ChatIntent(type: ChatIntentType.appHelp, entities: entities);
    }

    // 4. Match preview (needs 2 teams + preview keyword — check BEFORE h2h)
    if (teams.length >= 2 && _isMatchPreview(lower)) {
      return ChatIntent(type: ChatIntentType.matchPreview, confidence: 0.9, entities: entities);
    }

    // 5. Head-to-head (needs 2 teams)
    if (teams.length >= 2 && _isHeadToHead(lower)) {
      return ChatIntent(type: ChatIntentType.headToHead, confidence: 0.9, entities: entities);
    }

    // 6. If two teams detected and none of the above, default to H2H
    if (teams.length >= 2) {
      return ChatIntent(type: ChatIntentType.headToHead, confidence: 0.7, entities: entities);
    }

    // 7. Countdown (before schedule — "when does it start" should be countdown)
    if (_isCountdown(lower)) {
      return ChatIntent(type: ChatIntentType.countdown, confidence: 0.9, entities: entities);
    }

    // 8. Schedule
    if (_isSchedule(lower)) {
      return ChatIntent(type: ChatIntentType.schedule, confidence: 0.9, entities: entities);
    }

    // 8. Prediction
    if (_isPrediction(lower)) {
      return ChatIntent(type: ChatIntentType.prediction, confidence: 0.85, entities: entities);
    }

    // 9. Injury (before player — "Mbappe injured" should be injury, not player)
    if (_isInjury(lower)) {
      return ChatIntent(type: ChatIntentType.injury, confidence: 0.85, entities: entities);
    }

    // 10. Player comparison (needs 2 players detected)
    if (_isPlayerComparison(lower)) {
      final twoPlayers = _extractTwoPlayers(lower);
      if (twoPlayers.length >= 2) {
        entities['player1'] = twoPlayers[0];
        entities['player2'] = twoPlayers[1];
        return ChatIntent(type: ChatIntentType.playerComparison, confidence: 0.9, entities: entities);
      }
    }

    // 11. Manager (before player — "USA manager" should be manager)
    if (_isManager(lower)) {
      return ChatIntent(type: ChatIntentType.manager, confidence: 0.85, entities: entities);
    }

    // 12. Squad value (before team — "most valuable squad" should not fall to team)
    if (_isSquadValue(lower)) {
      return ChatIntent(type: ChatIntentType.squadValue, confidence: 0.85, entities: entities);
    }

    // 13. Recent form (before team — "USA form" should not fall to team)
    if (_isRecentForm(lower)) {
      return ChatIntent(type: ChatIntentType.recentForm, confidence: 0.85, entities: entities);
    }

    // 14. Venue (before player — "stadiums" should be venue)
    if (_isVenue(lower) || venue != null) {
      return ChatIntent(type: ChatIntentType.venue, confidence: 0.85, entities: entities);
    }

    // 12. Player (after injury/manager/venue to avoid false positives)
    if (player != null || _isPlayerQuery(lower)) {
      return ChatIntent(type: ChatIntentType.player, confidence: 0.85, entities: entities);
    }

    // 13. Team
    if (teams.isNotEmpty && _isTeamQuery(lower)) {
      return ChatIntent(type: ChatIntentType.team, confidence: 0.85, entities: entities);
    }

    // 14. History
    if (_isHistory(lower)) {
      return ChatIntent(type: ChatIntentType.history, confidence: 0.85, entities: entities);
    }

    // 15. Odds
    if (_isOdds(lower)) {
      return ChatIntent(type: ChatIntentType.odds, confidence: 0.85, entities: entities);
    }

    // 19. Standings
    if (_isStandings(lower)) {
      return ChatIntent(type: ChatIntentType.standings, confidence: 0.85, entities: entities);
    }

    // 20. Tournament facts (general tournament questions)
    if (_isTournamentFacts(lower)) {
      return ChatIntent(type: ChatIntentType.tournamentFacts, confidence: 0.85, entities: entities);
    }

    // If a team was mentioned but no specific intent, give team info
    if (teams.isNotEmpty) {
      return ChatIntent(type: ChatIntentType.team, confidence: 0.6, entities: entities);
    }

    return ChatIntent(type: ChatIntentType.unknown, confidence: 0.0, entities: entities);
  }

  // ─── Intent Matchers ──────────────────────────────────────────

  bool _isGreeting(String s) {
    final greetings = ['hello', 'hi', 'hey', 'good morning', 'good afternoon',
      'good evening', 'howdy', 'yo', 'sup', 'what\'s up', 'greetings'];
    // Must be short or start with greeting word
    if (s.length < 20) {
      for (final g in greetings) {
        if (s == g || s.startsWith('$g ') || s.startsWith('$g!') || s.startsWith('$g,')) {
          return true;
        }
      }
    }
    return false;
  }

  bool _isThanks(String s) {
    return s.contains('thank') || s.contains('thanks') || s.contains('appreciate') ||
        s == 'ty' || s == 'thx' || s.contains('cheers');
  }

  bool _isAppHelp(String s) {
    return s.contains('how do i') || s.contains('how to use') ||
        s.contains('what can you do') || s.contains('features') ||
        (s.contains('help') && !s.contains('team') && !s.contains('play'));
  }

  bool _isSchedule(String s) {
    // Exclude "been playing" / "how has ... playing" (recent form queries)
    if (s.contains('been playing') || (s.contains('how has') && s.contains('playing'))) {
      return false;
    }
    return s.contains('when') || s.contains('schedule') || s.contains('next match') ||
        s.contains('next game') || s.contains('play') || s.contains('kickoff') ||
        s.contains('kick off') || s.contains('what time') || s.contains('fixture');
  }

  bool _isHeadToHead(String s) {
    return s.contains(' vs ') || s.contains(' versus ') || s.contains('against') ||
        s.contains('h2h') || s.contains('head to head') || s.contains('head-to-head') ||
        s.contains('record against') || s.contains('beaten');
  }

  bool _isMatchPreview(String s) {
    return s.contains('preview') || s.contains('analysis') || s.contains('breakdown') ||
        s.contains('tactical') || s.contains('key battle');
  }

  bool _isPrediction(String s) {
    return s.contains('predict') || s.contains('will win') || s.contains('who wins') ||
        s.contains('chance') || s.contains('favorite') || s.contains('favourite') ||
        s.contains('who will') || s.contains('can they') || s.contains('dark horse') ||
        s.contains('contender') || s.contains('going to win') ||
        RegExp(r'can\b.*\bwin').hasMatch(s);
  }

  bool _isPlayerQuery(String s) {
    return s.contains('player stats') || s.contains('stats') ||
        s.contains('goals scored') || s.contains('who is') || s.contains('scorer');
  }

  bool _isInjury(String s) {
    return s.contains('injur') || s.contains('ruled out') ||
        s.contains('hamstring') || s.contains('knee') ||
        (s.contains('fit') && (s.contains('is') || s.contains('are'))) ||
        (s.contains('available') && !s.contains('feature')) ||
        s.contains('doubt') || s.contains('concern');
  }

  bool _isManager(String s) {
    return s.contains('manager') || s.contains('coach') || s.contains('manages') ||
        s.contains('formation') || s.contains('tactic');
  }

  bool _isTeamQuery(String s) {
    return s.contains('squad') || s.contains('roster') || s.contains('tell me about') ||
        s.contains('team') || s.contains('lineup') || s.contains('players');
  }

  bool _isVenue(String s) {
    return s.contains('stadium') || s.contains('venue') || s.contains('where is') ||
        s.contains('host cit') || s.contains('arena') || s.contains('capacity') ||
        _containsVenueName(s);
  }

  bool _isHistory(String s) {
    return s.contains('history') || s.contains('record') || s.contains('all time') ||
        s.contains('all-time') || s.contains('most goals') || s.contains('most wins') ||
        s.contains('first world cup') || s.contains('previous world cup') ||
        s.contains('past winner') || s.contains('world cup winner') ||
        _extractYear(s) != null;
  }

  bool _isOdds(String s) {
    return s.contains('odds') || s.contains('betting') || s.contains('probability') ||
        s.contains('implied') || s.contains('bookmaker');
  }

  bool _isStandings(String s) {
    return s.contains('standing') || s.contains('table') ||
        (s.contains('group') && !s.contains('group stage'));
  }

  bool _isSquadValue(String s) {
    return s.contains('squad value') || s.contains('squad worth') ||
        s.contains('most valuable') || s.contains('most expensive') ||
        s.contains('market value') || (s.contains('worth') && s.contains('squad')) ||
        s.contains('cheapest squad') || s.contains('richest');
  }

  bool _isRecentForm(String s) {
    return (s.contains('form') && !s.contains('formation') && !s.contains('format')) ||
        s.contains('recent results') || s.contains('been playing') ||
        s.contains('current form') || s.contains('winning streak') ||
        s.contains('losing streak') || s.contains('last 5') ||
        (s.contains('how have') && !s.contains('how many')) ||
        (s.contains('how has') && !s.contains('how many')) ||
        s.contains('momentum');
  }

  bool _isPlayerComparison(String s) {
    return s.contains('compare') || s.contains('comparison') ||
        s.contains('better than') || s.contains('who is better');
  }

  bool _isCountdown(String s) {
    return s.contains('countdown') || s.contains('days until') ||
        s.contains('how long until') || s.contains('how many days') ||
        s.contains('when does it start') || s.contains('when does the world cup') ||
        s.contains('opening match') || s.contains('opening ceremony') ||
        s.contains('first match') || s.contains('start date');
  }

  bool _isTournamentFacts(String s) {
    return s.contains('how many teams') || s.contains('how many matches') ||
        s.contains('how many groups') || s.contains('how many cities') ||
        s.contains('how many stadiums') || (s.contains('format') && !s.contains('formation')) ||
        s.contains('tournament structure') || s.contains('where is the final') ||
        s.contains('host countries') || s.contains('prize money') ||
        s.contains('fun fact') || s.contains('did you know') ||
        s.contains('tournament facts');
  }

  bool _hasPronoun(String s) {
    return s.contains('their') || s.contains('them') || s.contains('they') ||
        s.contains('that team');
  }

  // ─── Entity Extraction ────────────────────────────────────────

  /// Extract team codes from the message using the alias map.
  List<String> _extractTeams(String lower) {
    final aliases = _knowledgeBase.teamAliases;
    final found = <String>[];
    final foundCodes = <String>{};

    // Sort aliases by length descending to match longer names first
    final sortedAliases = aliases.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    for (final alias in sortedAliases) {
      if (alias.length < 2) continue; // Skip too-short aliases
      // Word boundary match
      final pattern = RegExp('(?:^|\\s|,)${RegExp.escape(alias)}(?:\\s|,|\$|\\?|!|\\.)');
      if (pattern.hasMatch(' $lower ')) {
        final code = aliases[alias]!;
        if (!foundCodes.contains(code)) {
          foundCodes.add(code);
          found.add(code);
        }
      }
      if (found.length >= 2) break;
    }

    return found;
  }

  /// Extract a player name from the message.
  String? _extractPlayer(String lower) {
    final knownPlayers = _knowledgeBase.knownPlayerNames;
    // Sort by length descending for longest match
    final sorted = knownPlayers.toList()..sort((a, b) => b.length.compareTo(a.length));

    for (final name in sorted) {
      // Check if any part of the player name appears (with word boundaries)
      final parts = name.split(' ');
      for (final part in parts) {
        if (part.length >= 5 && _hasWord(lower, part)) {
          return name;
        }
      }
    }

    // Check for well-known names not in player_stats files
    // Use word-boundary matching to avoid false positives
    const wellKnown = {
      'messi': 'lionel messi',
      'ronaldo': 'cristiano ronaldo',
      'mbappe': 'kylian mbappe',
      'mbappé': 'kylian mbappe',
      'neymar': 'neymar jr',
      'haaland': 'erling haaland',
      'bellingham': 'jude bellingham',
      'vinicius': 'vinicius jr',
      'kane': 'harry kane',
      'salah': 'mohamed salah',
      'modric': 'luka modric',
      'de bruyne': 'kevin de bruyne',
      'pedri': 'pedri',
      'yamal': 'lamine yamal',
      'saka': 'bukayo saka',
      'foden': 'phil foden',
      'lewandowski': 'robert lewandowski',
      'son heung': 'son heung-min',
    };

    for (final entry in wellKnown.entries) {
      if (_hasWord(lower, entry.key)) return entry.value;
    }

    return null;
  }

  /// Extract two player names from the message (for comparisons).
  List<String> _extractTwoPlayers(String lower) {
    final knownPlayers = _knowledgeBase.knownPlayerNames.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    final found = <String>[];

    for (final name in knownPlayers) {
      final parts = name.split(' ');
      for (final part in parts) {
        if (part.length >= 5 && _hasWord(lower, part) && !found.contains(name)) {
          found.add(name);
          break;
        }
      }
      if (found.length >= 2) return found;
    }

    const wellKnown = {
      'messi': 'lionel messi',
      'ronaldo': 'cristiano ronaldo',
      'mbappe': 'kylian mbappe',
      'mbappé': 'kylian mbappe',
      'neymar': 'neymar jr',
      'haaland': 'erling haaland',
      'bellingham': 'jude bellingham',
      'vinicius': 'vinicius jr',
      'kane': 'harry kane',
      'salah': 'mohamed salah',
      'modric': 'luka modric',
      'de bruyne': 'kevin de bruyne',
      'pedri': 'pedri',
      'yamal': 'lamine yamal',
      'saka': 'bukayo saka',
      'foden': 'phil foden',
      'lewandowski': 'robert lewandowski',
      'son heung': 'son heung-min',
    };

    for (final entry in wellKnown.entries) {
      if (_hasWord(lower, entry.key) && !found.contains(entry.value)) {
        found.add(entry.value);
      }
      if (found.length >= 2) return found;
    }

    return found;
  }

  /// Check if [text] contains [word] as a whole word (word boundaries).
  bool _hasWord(String text, String word) {
    final pattern = RegExp('(?:^|\\s|[,!?.])${RegExp.escape(word)}(?:\\s|[,!?.]|\$)');
    return pattern.hasMatch(' $text ');
  }

  /// Extract a venue/stadium name from the message.
  String? _extractVenue(String lower) {
    const venues = {
      'metlife': 'MetLife Stadium',
      'sofi': 'SoFi Stadium',
      'at&t': 'AT&T Stadium',
      'hard rock': 'Hard Rock Stadium',
      'mercedes': 'Mercedes-Benz Stadium',
      'nrg': 'NRG Stadium',
      'lincoln financial': 'Lincoln Financial Field',
      'lumen': 'Lumen Field',
      'levi': "Levi's Stadium",
      'arrowhead': 'Arrowhead Stadium',
      'gillette': 'Gillette Stadium',
      'bmo': 'BMO Field',
      'bc place': 'BC Place',
      'akron': 'Estadio Akron',
      'azteca': 'Estadio Azteca',
      'bbva': 'Estadio BBVA',
    };

    for (final entry in venues.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return null;
  }

  /// Extract a year from the message (1930-2026).
  String? _extractYear(String s) {
    final yearPattern = RegExp(r'\b(19[3-9]\d|20[0-2]\d)\b');
    final match = yearPattern.firstMatch(s);
    if (match != null) {
      final year = int.parse(match.group(1)!);
      // Only WC years (every 4 years from 1930, or 2026)
      if (year == 2026 || (year >= 1930 && year <= 2022 && (year - 1930) % 4 == 0)) {
        return match.group(1);
      }
    }
    return null;
  }

  /// Extract a group letter from the message.
  String? _extractGroup(String lower) {
    final groupPattern = RegExp(r'group\s+([a-l])\b', caseSensitive: false);
    final match = groupPattern.firstMatch(lower);
    if (match != null) return match.group(1)!.toUpperCase();
    return null;
  }

  /// Check if the message contains a known venue name.
  bool _containsVenueName(String lower) {
    return _extractVenue(lower) != null;
  }

  /// Reset conversation context.
  void reset() {
    _lastMentionedTeam = null;
  }
}

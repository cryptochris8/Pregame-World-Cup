import '../entities/chat_intent.dart';
import '../entities/chat_response.dart';
import '../../data/services/chatbot_knowledge_base.dart';

/// Generates data-driven chatbot responses from classified intents.
///
/// Pulls real data from [ChatbotKnowledgeBase] and formats natural-sounding
/// answers with contextual suggestion chips.
class ResponseGenerator {
  final ChatbotKnowledgeBase _kb;

  ResponseGenerator({required ChatbotKnowledgeBase knowledgeBase})
      : _kb = knowledgeBase;

  /// Generate a response for the given classified intent.
  Future<ChatResponse> generate(ChatIntent intent) async {
    switch (intent.type) {
      case ChatIntentType.greeting:
        return _greeting(intent);
      case ChatIntentType.thanks:
        return _thanks(intent);
      case ChatIntentType.appHelp:
        return _appHelp(intent);
      case ChatIntentType.schedule:
        return await _schedule(intent);
      case ChatIntentType.headToHead:
        return await _headToHead(intent);
      case ChatIntentType.matchPreview:
        return await _matchPreview(intent);
      case ChatIntentType.prediction:
        return await _prediction(intent);
      case ChatIntentType.player:
        return await _player(intent);
      case ChatIntentType.injury:
        return await _injury(intent);
      case ChatIntentType.manager:
        return await _manager(intent);
      case ChatIntentType.team:
        return await _team(intent);
      case ChatIntentType.venue:
        return _venue(intent);
      case ChatIntentType.history:
        return _history(intent);
      case ChatIntentType.odds:
        return _odds(intent);
      case ChatIntentType.standings:
        return _standings(intent);
      case ChatIntentType.squadValue:
        return await _squadValue(intent);
      case ChatIntentType.recentForm:
        return await _recentForm(intent);
      case ChatIntentType.playerComparison:
        return await _playerComparison(intent);
      case ChatIntentType.countdown:
        return _countdown(intent);
      case ChatIntentType.tournamentFacts:
        return _tournamentFacts(intent);
      case ChatIntentType.unknown:
        return _unknown(intent);
    }
  }

  // ─── Response Generators ──────────────────────────────────────

  ChatResponse _greeting(ChatIntent intent) {
    return ChatResponse(
      text: "Hey there! I'm your World Cup 2026 assistant. I know all about "
          "the 48 teams, 104 matches, and 16 host cities. What would you like to know?",
      suggestionChips: ['USA schedule', 'Who are the favorites?', 'World Cup history', 'Help'],
      resolvedIntent: intent,
    );
  }

  ChatResponse _thanks(ChatIntent intent) {
    return ChatResponse(
      text: "You're welcome! Let me know if you have any other World Cup questions.",
      suggestionChips: ['Tournament favorites', 'Match schedule', 'Team info'],
      resolvedIntent: intent,
    );
  }

  ChatResponse _appHelp(ChatIntent intent) {
    return ChatResponse(
      text: "I can help you with:\n"
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

  Future<ChatResponse> _schedule(ChatIntent intent) async {
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

      final dateFormatted = _formatDate(date);
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

  Future<ChatResponse> _headToHead(ChatIntent intent) async {
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
      buf.writeln('Last meeting: ${_formatDate(lastMatch)}');
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

  Future<ChatResponse> _matchPreview(ChatIntent intent) async {
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

  Future<ChatResponse> _prediction(ChatIntent intent) async {
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

  Future<ChatResponse> _player(ChatIntent intent) async {
    final playerName = intent.player;
    if (playerName == null) {
      return ChatResponse(
        text: "Which player would you like to know about? I have detailed stats "
            "for 24 key players and squad data for all 48 teams.",
        suggestionChips: ['Messi stats', 'Mbappe stats', 'Kane stats', 'Vinicius stats'],
        resolvedIntent: intent,
      );
    }

    // Try player_stats files first
    final stats = await _kb.getPlayerStats(playerName);
    if (stats != null) {
      final name = stats['playerName'] ?? playerName;
      final code = stats['fifaCode'] ?? '';
      final teamName = _kb.getTeamName(code) ?? code;
      final apps = stats['worldCupAppearances'] ?? 0;
      final goals = stats['worldCupGoals'] ?? 0;
      final assists = stats['worldCupAssists'] ?? 0;
      final wcs = (stats['previousWorldCups'] as List<dynamic>?)?.join(', ') ?? '';
      final awards = (stats['worldCupAwards'] as List<dynamic>?) ?? [];
      final legacy = stats['worldCupLegacyRating'];
      final prediction = stats['worldCup2026Prediction'] as String?;

      final buf = StringBuffer('$name — $teamName\n\n');
      buf.writeln('World Cup career: $apps appearances, $goals goals, $assists assists');
      if (wcs.isNotEmpty) buf.writeln('Tournaments: $wcs');
      if (awards.isNotEmpty) buf.writeln('Awards: ${awards.join(', ')}');
      if (legacy != null) buf.writeln('Legacy rating: $legacy/10');

      // Tournament breakdown
      final tourneyStats = stats['tournamentStats'] as List<dynamic>?;
      if (tourneyStats != null && tourneyStats.isNotEmpty) {
        buf.writeln();
        buf.writeln('Tournament breakdown:');
        for (final ts in tourneyStats) {
          final t = ts as Map<String, dynamic>;
          buf.writeln('  ${t['year']}: ${t['matches']} matches, ${t['goals']} goals '
              '(${t['stage']})');
        }
      }

      if (prediction != null) {
        buf.writeln();
        buf.writeln('2026 outlook: ${prediction.length > 150 ? '${prediction.substring(0, 147)}...' : prediction}');
      }

      return ChatResponse(
        text: buf.toString().trim(),
        suggestionChips: ['$teamName schedule', '$teamName squad', 'World Cup records'],
        resolvedIntent: intent,
      );
    }

    // Try squad data
    final teamCode = intent.team;
    if (teamCode != null) {
      final teamData = await _kb.getTeamData(teamCode);
      if (teamData != null) {
        final squadResult = await _kb.searchPlayerInSquads(playerName);
        if (squadResult != null) {
          final p = squadResult['player'] as Map<String, dynamic>;
          final teamName = squadResult['teamName'] ?? teamCode;
          return ChatResponse(
            text: '${p['firstName']} ${p['lastName']} — $teamName\n\n'
                'Position: ${p['position']}\n'
                'Club: ${p['club']} (${p['clubLeague']})\n'
                'Jersey: #${p['jerseyNumber']}\n'
                'Caps: ${p['caps']}, Goals: ${p['goals']}\n'
                'Market value: \$${_formatNumber(p['marketValue'])}',
            suggestionChips: ['$teamName squad', '$teamName schedule'],
            resolvedIntent: intent,
          );
        }
      }
    }

    return ChatResponse(
      text: "I couldn't find detailed stats for \"$playerName\". "
          "I have data on 24 featured players and all 48 team squads. "
          "Try a well-known player name like Messi, Mbappe, or Kane.",
      suggestionChips: ['Messi stats', 'Mbappe stats', 'Kane stats'],
      resolvedIntent: intent,
    );
  }

  Future<ChatResponse> _injury(ChatIntent intent) async {
    final teamCode = intent.team;

    if (teamCode != null) {
      final teamName = _kb.getTeamName(teamCode) ?? teamCode;
      final injuries = _kb.getInjuryConcerns(teamCode);

      if (injuries.isEmpty) {
        return ChatResponse(
          text: "No injury concerns reported for $teamName heading into the tournament.",
          suggestionChips: ['$teamName squad', '$teamName schedule'],
          resolvedIntent: intent,
        );
      }

      final buf = StringBuffer('$teamName — Injury Report:\n\n');
      for (final inj in injuries) {
        final status = (inj['availabilityStatus'] as String? ?? '').replaceAll('_', ' ');
        buf.writeln('${inj['playerName']} (${inj['position']})');
        buf.writeln('  Status: $status');
        buf.writeln('  Issue: ${inj['injuryType']}');
        if (inj['expectedReturn'] != null) {
          buf.writeln('  Expected return: ${inj['expectedReturn']}');
        }
        buf.writeln();
      }

      return ChatResponse(
        text: buf.toString().trim(),
        suggestionChips: ['$teamName squad', '$teamName prediction'],
        resolvedIntent: intent,
      );
    }

    // General injury overview — show notable ones
    return ChatResponse(
      text: "Ask about a specific team's injury report, e.g. \"France injuries\" "
          "or \"Is Mbappe fit?\"",
      suggestionChips: ['France injuries', 'England injuries', 'Brazil injuries'],
      resolvedIntent: intent,
    );
  }

  Future<ChatResponse> _manager(ChatIntent intent) async {
    final teamCode = intent.team;
    if (teamCode == null) {
      return ChatResponse(
        text: "Which team's manager would you like to know about?",
        suggestionChips: ['Argentina coach', 'France coach', 'Brazil coach', 'USA coach'],
        resolvedIntent: intent,
      );
    }

    final teamName = _kb.getTeamName(teamCode) ?? teamCode;
    final mgr = await _kb.getManager(teamCode);

    if (mgr == null) {
      return ChatResponse(
        text: "I don't have manager data for $teamName yet.",
        suggestionChips: ['$teamName squad', '$teamName schedule'],
        resolvedIntent: intent,
      );
    }

    final name = mgr['commonName'] ?? '${mgr['firstName']} ${mgr['lastName']}';
    final formation = mgr['preferredFormation'] ?? '';
    final style = mgr['coachingStyle'] ?? '';
    final winRate = mgr['careerWinPercentage'] ?? '';
    final trophies = (mgr['trophies'] as List<dynamic>?) ?? [];
    final bio = mgr['bio'] as String?;

    final buf = StringBuffer('$name — $teamName Manager\n\n');
    buf.writeln('Formation: $formation | Style: $style');
    buf.writeln('Career win rate: $winRate%');
    buf.writeln('Record: ${mgr['careerWins']}W ${mgr['careerDraws']}D ${mgr['careerLosses']}L');

    if (trophies.isNotEmpty) {
      buf.writeln('Trophies: ${trophies.take(5).join(', ')}');
    }

    if (bio != null) {
      buf.writeln();
      buf.writeln(bio.length > 200 ? '${bio.substring(0, 197)}...' : bio);
    }

    return ChatResponse(
      text: buf.toString().trim(),
      suggestionChips: ['$teamName squad', '$teamName schedule', '$teamName prediction'],
      resolvedIntent: intent,
    );
  }

  Future<ChatResponse> _team(ChatIntent intent) async {
    final teamCode = intent.team;
    if (teamCode == null) {
      return ChatResponse(
        text: "Which team would you like to know about? There are 48 teams in the 2026 World Cup.",
        suggestionChips: ['USA', 'Brazil', 'France', 'Argentina'],
        resolvedIntent: intent,
      );
    }

    final teamName = _kb.getTeamName(teamCode) ?? teamCode;
    final group = _kb.getTeamGroup(teamCode);
    final sv = _kb.getSquadValue(teamCode);
    final form = _kb.getRecentFormSummary(teamCode);
    final odds = _kb.getBettingOdds(teamCode);
    final teamData = await _kb.getTeamData(teamCode);

    final buf = StringBuffer(teamName);
    if (group != null) buf.write(' (Group $group)');
    buf.writeln('\n');

    if (sv != null) {
      buf.writeln('Squad value: ${sv['totalValueFormatted']} (ranked #${sv['rank']})');
    }
    if (odds != null) {
      buf.writeln('Odds: ${odds['odds_american']} (${odds['tier']})');
    }
    if (form != null) {
      buf.writeln('Form: $form');
    }

    if (teamData != null) {
      final players = teamData['players'] as List<dynamic>?;
      if (players != null) {
        buf.writeln('Squad size: ${players.length} players');

        // Key players by position
        final fwd = players.where((p) => (p as Map<String, dynamic>)['position'] == 'FW').toList();
        final mid = players.where((p) => (p as Map<String, dynamic>)['position'] == 'MF').toList();

        if (fwd.isNotEmpty) {
          final topFwd = fwd.take(3).map((p) {
            final pm = p as Map<String, dynamic>;
            return '${pm['firstName']} ${pm['lastName']}';
          }).join(', ');
          buf.writeln('Key forwards: $topFwd');
        }
        if (mid.isNotEmpty) {
          final topMid = mid.take(3).map((p) {
            final pm = p as Map<String, dynamic>;
            return '${pm['firstName']} ${pm['lastName']}';
          }).join(', ');
          buf.writeln('Key midfielders: $topMid');
        }
      }
    }

    return ChatResponse(
      text: buf.toString().trim(),
      suggestionChips: ['$teamName schedule', '$teamName manager', '$teamName prediction'],
      resolvedIntent: intent,
    );
  }

  ChatResponse _venue(ChatIntent intent) {
    final venueName = intent.venue;

    if (venueName != null) {
      final matches = _kb.getVenueMatches(venueName);
      final buf = StringBuffer('$venueName\n\n');

      if (matches.isNotEmpty) {
        final city = matches.first['venueCity'] as String? ?? '';
        if (city.isNotEmpty) buf.writeln('Location: $city');
        buf.writeln('Matches scheduled: ${matches.length}');
        buf.writeln();

        for (final m in matches.take(5)) {
          final date = _formatDate(m['date'] as String? ?? '');
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
        buf.writeln('No match data found for this venue.');
      }

      return ChatResponse(
        text: buf.toString().trim(),
        suggestionChips: ['All venues', 'Tournament schedule'],
        resolvedIntent: intent,
      );
    }

    // List all venues
    final venues = _kb.getAllVenues();
    final buf = StringBuffer('World Cup 2026 — 16 Host Venues:\n\n');
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

  ChatResponse _history(ChatIntent intent) {
    final yearStr = intent.year;

    if (yearStr != null) {
      final year = int.tryParse(yearStr);
      if (year != null) {
        final tournament = _kb.getTournamentByYear(year);
        if (tournament != null) {
          final buf = StringBuffer('World Cup $year — ${tournament['hostCountries']}\n\n');
          buf.writeln('Winner: ${tournament['winner']}');
          buf.writeln('Runner-up: ${tournament['runnerUp']}');
          if (tournament['thirdPlace'] != null) {
            buf.writeln('Third place: ${tournament['thirdPlace']}');
          }
          buf.writeln('Final: ${tournament['finalScore']} at ${tournament['finalVenue']}, ${tournament['finalCity']}');
          buf.writeln('Top scorer: ${tournament['topScorer']} (${tournament['topScorerGoals']} goals)');
          buf.writeln('Total matches: ${tournament['totalMatches']} | Goals: ${tournament['totalGoals']}');

          final highlights = tournament['highlights'] as List<dynamic>?;
          if (highlights != null && highlights.isNotEmpty) {
            buf.writeln();
            buf.writeln('Highlights:');
            for (final h in highlights.take(3)) {
              buf.writeln('- $h');
            }
          }

          // Suggest adjacent tournaments
          final chips = <String>[];
          if (year > 1930) chips.add('World Cup ${year - 4}');
          if (year < 2022) chips.add('World Cup ${year + 4}');
          chips.add('World Cup records');

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
        text: "I have World Cup history from 1930 to 2022. Ask about a specific year "
            "(e.g. \"World Cup 2022\") or World Cup records!",
        suggestionChips: ['World Cup 2022', 'World Cup 2018', 'World Cup records'],
        resolvedIntent: intent,
      );
    }

    final buf = StringBuffer('World Cup Records & History:\n\n');
    for (final r in records.take(8)) {
      buf.writeln('${r['category']}: ${r['holder']} (${r['value']})');
      if (r['details'] != null) buf.writeln('  ${r['details']}');
    }

    // Recent winners
    final recentTournaments = _kb.getAllTournaments();
    if (recentTournaments.isNotEmpty) {
      buf.writeln();
      buf.writeln('Recent winners:');
      final recent = recentTournaments.reversed.take(5).toList();
      for (final t in recent) {
        buf.writeln('  ${t['year']}: ${t['winner']}');
      }
    }

    return ChatResponse(
      text: buf.toString().trim(),
      suggestionChips: ['World Cup 2022', 'World Cup 2018', 'Most goals all time'],
      resolvedIntent: intent,
    );
  }

  ChatResponse _odds(ChatIntent intent) {
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

  ChatResponse _standings(ChatIntent intent) {
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
        final date = _formatDate(m['date'] as String? ?? '');
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

  ChatResponse _unknown(ChatIntent intent) {
    return ChatResponse(
      text: "I'm not sure I understood that. I can help with match schedules, "
          "team info, player stats, predictions, head-to-head records, "
          "and World Cup history. What would you like to know?",
      suggestionChips: ['Help', 'USA schedule', 'Tournament favorites', 'World Cup records'],
      resolvedIntent: intent,
    );
  }

  // ─── New Response Generators ─────────────────────────────────

  Future<ChatResponse> _squadValue(ChatIntent intent) async {
    final teamCode = intent.team;

    if (teamCode != null) {
      final teamName = _kb.getTeamName(teamCode) ?? teamCode;
      final sv = _kb.getSquadValue(teamCode);

      if (sv == null) {
        return ChatResponse(
          text: "I don't have squad value data for $teamName.",
          suggestionChips: ['Most valuable squads', '$teamName squad'],
          resolvedIntent: intent,
        );
      }

      final buf = StringBuffer('$teamName — Squad Value:\n\n');
      buf.writeln('Total: ${sv['totalValueFormatted']} (ranked #${sv['rank']} in the tournament)');
      buf.writeln('Squad size: ${sv['playerCount']} players');
      buf.writeln('Average value: \$${_formatNumber(sv['averagePlayerValue'])}');

      final mvp = sv['mostValuablePlayer'] as Map<String, dynamic>?;
      if (mvp != null) {
        buf.writeln('Most valuable: ${mvp['name']} (${mvp['value']})');
      }
      final lvp = sv['leastValuablePlayer'] as Map<String, dynamic>?;
      if (lvp != null) {
        buf.writeln('Lowest valued: ${lvp['name']} (${lvp['value']})');
      }

      return ChatResponse(
        text: buf.toString().trim(),
        suggestionChips: ['$teamName squad', '$teamName prediction', 'Most valuable squads'],
        resolvedIntent: intent,
      );
    }

    // Global squad value ranking
    final allTeams = _kb.getAllTeamCodes();
    final withValues = <Map<String, dynamic>>[];
    for (final code in allTeams) {
      final sv = _kb.getSquadValue(code);
      if (sv != null) withValues.add(sv);
    }
    withValues.sort((a, b) =>
        ((b['totalValue'] as num?) ?? 0).compareTo((a['totalValue'] as num?) ?? 0));

    if (withValues.isEmpty) {
      return ChatResponse(
        text: "Squad value data is not available right now.",
        suggestionChips: ['Tournament favorites', 'Help'],
        resolvedIntent: intent,
      );
    }

    final buf = StringBuffer('World Cup 2026 — Most Valuable Squads:\n\n');
    for (var i = 0; i < withValues.length && i < 10; i++) {
      final t = withValues[i];
      final mvp = t['mostValuablePlayer'] as Map<String, dynamic>?;
      buf.writeln('${i + 1}. ${t['teamName']} — ${t['totalValueFormatted']}'
          '${mvp != null ? ' (star: ${mvp['name']})' : ''}');
    }

    final topChips = withValues.take(3).map((t) => '${t['teamName']} value').toList();
    return ChatResponse(
      text: buf.toString().trim(),
      suggestionChips: [...topChips, 'Tournament favorites'],
      resolvedIntent: intent,
    );
  }

  Future<ChatResponse> _recentForm(ChatIntent intent) async {
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
          final date = _formatDate(match['date'] as String? ?? '');
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

  Future<ChatResponse> _playerComparison(ChatIntent intent) async {
    final player1Name = intent.player1;
    final player2Name = intent.player2;

    if (player1Name == null || player2Name == null) {
      return ChatResponse(
        text: "I need two player names to compare. Try \"Compare Messi and Mbappe\" "
            "or \"Bellingham vs Kane\".",
        suggestionChips: ['Compare Messi and Mbappe', 'Compare Kane and Haaland'],
        resolvedIntent: intent,
      );
    }

    final stats1 = await _kb.getPlayerStats(player1Name);
    final stats2 = await _kb.getPlayerStats(player2Name);
    final squad1 = await _kb.searchPlayerInSquads(player1Name);
    final squad2 = await _kb.searchPlayerInSquads(player2Name);

    final name1 = stats1?['playerName'] ?? _capitalize(player1Name);
    final name2 = stats2?['playerName'] ?? _capitalize(player2Name);

    if (stats1 == null && squad1 == null && stats2 == null && squad2 == null) {
      return ChatResponse(
        text: "I couldn't find detailed data for both players. "
            "Try well-known names like Messi, Mbappe, Kane, or Bellingham.",
        suggestionChips: ['Messi stats', 'Mbappe stats'],
        resolvedIntent: intent,
      );
    }

    final buf = StringBuffer('$name1 vs $name2 — Player Comparison:\n\n');

    // WC career stats if available
    if (stats1 != null || stats2 != null) {
      buf.writeln('World Cup Career:');
      if (stats1 != null) {
        buf.writeln('  $name1: ${stats1['worldCupAppearances'] ?? 0} apps, '
            '${stats1['worldCupGoals'] ?? 0} goals, ${stats1['worldCupAssists'] ?? 0} assists'
            '${stats1['worldCupLegacyRating'] != null ? ' (legacy: ${stats1['worldCupLegacyRating']}/10)' : ''}');
      }
      if (stats2 != null) {
        buf.writeln('  $name2: ${stats2['worldCupAppearances'] ?? 0} apps, '
            '${stats2['worldCupGoals'] ?? 0} goals, ${stats2['worldCupAssists'] ?? 0} assists'
            '${stats2['worldCupLegacyRating'] != null ? ' (legacy: ${stats2['worldCupLegacyRating']}/10)' : ''}');
      }
      buf.writeln();
    }

    // Club/squad info
    if (squad1 != null || squad2 != null) {
      buf.writeln('Current:');
      if (squad1 != null) {
        final p = squad1['player'] as Map<String, dynamic>;
        buf.writeln('  $name1: ${p['club']} (${p['position']}) — '
            '${p['caps']} caps, ${p['goals']} goals, \$${_formatNumber(p['marketValue'])}');
      }
      if (squad2 != null) {
        final p = squad2['player'] as Map<String, dynamic>;
        buf.writeln('  $name2: ${p['club']} (${p['position']}) — '
            '${p['caps']} caps, ${p['goals']} goals, \$${_formatNumber(p['marketValue'])}');
      }
    }

    return ChatResponse(
      text: buf.toString().trim(),
      suggestionChips: ['$name1 stats', '$name2 stats'],
      resolvedIntent: intent,
    );
  }

  ChatResponse _countdown(ChatIntent intent) {
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

  ChatResponse _tournamentFacts(ChatIntent intent) {
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

  // ─── Helpers ──────────────────────────────────────────────────

  /// Capitalize each word in a string.
  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s.split(' ').map((word) =>
        word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}'
    ).join(' ');
  }

  /// Format a date string like "2026-06-11" to "Jun 11".
  String _formatDate(String isoDate) {
    if (isoDate.isEmpty) return '';
    try {
      final parts = isoDate.split('-');
      if (parts.length < 3) return isoDate;
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[month]} $day';
    } catch (_) {
      return isoDate;
    }
  }

  /// Format a large number with K/M suffix.
  String _formatNumber(dynamic value) {
    if (value == null) return '?';
    final num n = value is num ? value : num.tryParse(value.toString()) ?? 0;
    if (n >= 1e9) return '${(n / 1e9).toStringAsFixed(1)}B';
    if (n >= 1e6) return '${(n / 1e6).toStringAsFixed(1)}M';
    if (n >= 1e3) return '${(n / 1e3).toStringAsFixed(0)}K';
    return n.toString();
  }
}

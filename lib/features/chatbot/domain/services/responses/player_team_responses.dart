import '../../../data/services/chatbot_knowledge_base.dart';
import '../../entities/chat_intent.dart';
import '../../entities/chat_response.dart';
import 'response_format_helpers.dart';

/// Handles generation of player and team-related chatbot responses.
///
/// This includes player profiles, injury updates, manager info, team info,
/// squad values, and player comparisons.
class PlayerTeamResponses {
  /// The knowledge base containing tournament data.
  final ChatbotKnowledgeBase _kb;

  /// Creates a [PlayerTeamResponses] instance.
  const PlayerTeamResponses(this._kb);

  /// Generates a player profile response.
  Future<ChatResponse> player(ChatIntent intent) async {
    final playerName = intent.player;
    if (playerName == null) {
      return ChatResponse(
        text: "Who are we scouting? I've got the full rundown on all 1,248 players "
            "across 48 squads — pick a name and let's dive in.",
        suggestionChips: ['Messi stats', 'Mbappe stats', 'Kane stats', 'Pulisic stats'],
        resolvedIntent: intent,
      );
    }

    // Try player_stats files first
    final stats = await _kb.getPlayerStats(playerName);
    if (stats != null) {
      final name = stats['playerName'] ?? playerName;
      final code = stats['teamCode'] ?? '';
      final teamName = _kb.getTeamName(code) ?? code;
      final apps = stats['worldCupAppearances'] ?? 0;
      final goals = stats['worldCupGoals'] ?? 0;
      final assists = stats['worldCupAssists'] ?? 0;
      final wcs = (stats['previousWorldCups'] as List<dynamic>?)?.join(', ') ?? '';
      final awards = (stats['worldCupAwards'] as List<dynamic>?) ?? [];
      final legacy = stats['worldCupLegacyRating'];
      final prediction = stats['worldCup2026Prediction'] as String?;

      final buf = StringBuffer('$name — $teamName\n\n');
      buf.writeln('On the World Cup stage: $apps appearances, $goals goals, $assists assists.');
      if (wcs.isNotEmpty) buf.writeln('Tournament pedigree: $wcs');
      if (awards.isNotEmpty) buf.writeln('Honors: ${awards.join(', ')}');
      if (legacy != null) buf.writeln('Copa\'s legacy rating: $legacy/10');

      // Tournament breakdown
      final tourneyStats = stats['tournamentStats'] as List<dynamic>?;
      if (tourneyStats != null && tourneyStats.isNotEmpty) {
        buf.writeln();
        buf.writeln('How the story unfolded, tournament by tournament:');
        for (final ts in tourneyStats) {
          final t = ts as Map<String, dynamic>;
          buf.writeln('  ${t['year']}: ${t['matches']} matches, ${t['goals']} goals '
              '(${t['stage']})');
        }
      }

      if (prediction != null) {
        buf.writeln();
        buf.writeln('What to expect in 2026: ${prediction.length > 150 ? '${prediction.substring(0, 147)}...' : prediction}');
      }

      return ChatResponse(
        text: buf.toString().trim(),
        suggestionChips: ['$teamName schedule', '$teamName squad', 'World Cup records'],
        resolvedIntent: intent,
      );
    }

    // Try enriched player profiles
    final profile = await _kb.getPlayerProfile(playerName);
    if (profile != null) {
      final name = profile['playerName'] ?? capitalize(playerName);
      final code = profile['teamCode'] ?? '';
      final teamName = _kb.getTeamName(code) ?? code;
      final bio = profile['bio'] as String? ?? '';
      final style = profile['playingStyle'] as String? ?? '';
      final strengths = (profile['keyStrengths'] as List<dynamic>?) ?? [];
      final role = profile['worldCup2026Role'] as String? ?? '';
      final fact = profile['notableFact'] as String? ?? '';

      final buf = StringBuffer('$name — $teamName\n\n');
      if (bio.isNotEmpty) buf.writeln(bio);
      if (style.isNotEmpty) buf.writeln('\nHow they play: $style');
      if (strengths.isNotEmpty) {
        buf.writeln('What makes them dangerous: ${strengths.join(', ')}');
      }
      if (role.isNotEmpty) buf.writeln('\nTheir 2026 role: $role');
      if (fact.isNotEmpty) buf.writeln('\nOne more thing: $fact');

      // Also pull basic squad data if available
      final teamCode2 = _kb.resolveTeamCode(code) ?? code;
      await _kb.getTeamData(teamCode2);
      final squadResult = await _kb.searchPlayerInSquads(playerName);
      if (squadResult != null) {
        final p = squadResult['player'] as Map<String, dynamic>;
        buf.writeln('\nClub: ${p['club']} (${p['clubLeague']})');
        buf.writeln('Caps: ${p['caps']}, Goals: ${p['goals']}');
      }

      return ChatResponse(
        text: buf.toString().trim(),
        suggestionChips: ['$teamName squad', '$teamName schedule', '$teamName prediction'],
        resolvedIntent: intent,
      );
    }

    // Try squad data (bare fallback)
    final teamCode = intent.team ?? _kb.getTeamCodeForPlayer(playerName);
    if (teamCode != null) {
      final teamData = await _kb.getTeamData(teamCode);
      if (teamData != null) {
        final squadResult = await _kb.searchPlayerInSquads(playerName);
        if (squadResult != null) {
          final p = squadResult['player'] as Map<String, dynamic>;
          final teamName = squadResult['teamName'] ?? teamCode;
          return ChatResponse(
            text: '${p['firstName']} ${p['lastName']} — $teamName\n\n'
                'Lines up at ${p['position']} | Wears the #${p['jerseyNumber']}\n'
                'Club: ${p['club']} (${p['clubLeague']})\n'
                'International record: ${p['caps']} caps, ${p['goals']} goals\n'
                'Market value: \$${formatNumber(p['marketValue'])}',
            suggestionChips: ['$teamName squad', '$teamName schedule'],
            resolvedIntent: intent,
          );
        }
      }
    }

    return ChatResponse(
      text: "I couldn't track down \"$playerName\" in my database. "
          "Try their full name — or go with a well-known one like Messi, Mbappe, or Pulisic.",
      suggestionChips: ['Messi stats', 'Mbappe stats', 'Pulisic stats'],
      resolvedIntent: intent,
    );
  }

  /// Generates an injury status response for a team or player.
  Future<ChatResponse> injury(ChatIntent intent) async {
    final teamCode = intent.team;

    if (teamCode != null) {
      final teamName = _kb.getTeamName(teamCode) ?? teamCode;
      final injuries = _kb.getInjuryConcerns(teamCode);

      if (injuries.isEmpty) {
        return ChatResponse(
          text: "Good news — $teamName look to have a clean bill of health heading into the tournament. "
              "That's a massive advantage when the pressure ramps up.",
          suggestionChips: ['$teamName squad', '$teamName schedule'],
          resolvedIntent: intent,
        );
      }

      final buf = StringBuffer('$teamName — Injury Watch:\n\n');
      for (final inj in injuries) {
        final status = (inj['availabilityStatus'] as String? ?? '').replaceAll('_', ' ');
        buf.writeln('${inj['playerName']} (${inj['position']}) — a blow for the squad.');
        buf.writeln('  Status: $status');
        buf.writeln('  Issue: ${inj['injuryType']}');
        if (inj['expectedReturn'] != null) {
          buf.writeln('  Racing against time — expected back: ${inj['expectedReturn']}');
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
      text: "Injuries can make or break a World Cup campaign. Ask about a specific team — "
          "\"France injuries\" or \"Is Mbappe fit?\" — and I'll give you the latest.",
      suggestionChips: ['France injuries', 'England injuries', 'Brazil injuries'],
      resolvedIntent: intent,
    );
  }

  /// Generates manager information response.
  Future<ChatResponse> manager(ChatIntent intent) async {
    final teamCode = intent.team;
    if (teamCode == null) {
      return ChatResponse(
        text: "The manager can be the difference between a group exit and a deep run. Whose gaffer are we looking at?",
        suggestionChips: ['Argentina coach', 'France coach', 'Brazil coach', 'USA coach'],
        resolvedIntent: intent,
      );
    }

    final teamName = _kb.getTeamName(teamCode) ?? teamCode;
    final mgr = await _kb.getManager(teamCode);

    if (mgr == null) {
      return ChatResponse(
        text: "I haven't got the full coaching profile for $teamName loaded yet — check back soon.",
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

    final buf = StringBuffer('$name — the mind behind $teamName\n\n');
    buf.writeln('Tactically, lines up in a $formation | Style: $style');
    buf.writeln('Win rate of $winRate% across his career — the numbers speak.');
    buf.writeln('Record: ${mgr['careerWins']}W ${mgr['careerDraws']}D ${mgr['careerLosses']}L');

    if (trophies.isNotEmpty) {
      buf.writeln('Silverware: ${trophies.take(5).join(', ')}');
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

  /// Generates team information response.
  Future<ChatResponse> team(ChatIntent intent) async {
    final teamCode = intent.team;
    if (teamCode == null) {
      return ChatResponse(
        text: "48 nations, one dream. Which squad are we breaking down?",
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
    if (group != null) buf.write(' — drawn into Group $group');
    buf.writeln('\n');

    if (sv != null) {
      buf.writeln('This squad is valued at ${sv['totalValueFormatted']} (ranked #${sv['rank']} in the tournament).');
    }
    if (odds != null) {
      buf.writeln('The market has them at ${odds['odds_american']} — classified as a ${odds['tier']}.');
    }
    if (form != null) {
      buf.writeln('Coming in with: $form');
    }

    if (teamData != null) {
      final players = teamData['players'] as List<dynamic>?;
      if (players != null) {
        buf.writeln('${players.length} players selected — built for tournament football.');

        // Key players by position
        final fwd = players.where((p) => (p as Map<String, dynamic>)['position'] == 'FW').toList();
        final mid = players.where((p) => (p as Map<String, dynamic>)['position'] == 'MF').toList();

        if (fwd.isNotEmpty) {
          final topFwd = fwd.take(3).map((p) {
            final pm = p as Map<String, dynamic>;
            return '${pm['firstName']} ${pm['lastName']}';
          }).join(', ');
          buf.writeln('Up front: $topFwd — that\'s where the goals come from.');
        }
        if (mid.isNotEmpty) {
          final topMid = mid.take(3).map((p) {
            final pm = p as Map<String, dynamic>;
            return '${pm['firstName']} ${pm['lastName']}';
          }).join(', ');
          buf.writeln('Pulling the strings in midfield: $topMid');
        }
      }
    }

    return ChatResponse(
      text: buf.toString().trim(),
      suggestionChips: ['$teamName schedule', '$teamName manager', '$teamName prediction'],
      resolvedIntent: intent,
    );
  }

  /// Generates squad value information response.
  Future<ChatResponse> squadValue(ChatIntent intent) async {
    final teamCode = intent.team;

    if (teamCode != null) {
      final teamName = _kb.getTeamName(teamCode) ?? teamCode;
      final sv = _kb.getSquadValue(teamCode);

      if (sv == null) {
        return ChatResponse(
          text: "I haven't got squad value data for $teamName loaded up yet.",
          suggestionChips: ['Most valuable squads', '$teamName squad'],
          resolvedIntent: intent,
        );
      }

      final buf = StringBuffer('$teamName — Squad Value Breakdown:\n\n');
      buf.writeln('Combined worth: ${sv['totalValueFormatted']} (ranked #${sv['rank']} in the tournament).');
      buf.writeln('${sv['playerCount']} players, averaging \$${formatNumber(sv['averagePlayerValue'])} each.');

      final mvp = sv['mostValuablePlayer'] as Map<String, dynamic>?;
      if (mvp != null) {
        buf.writeln('The headline act: ${mvp['name']} (${mvp['value']})');
      }
      final lvp = sv['leastValuablePlayer'] as Map<String, dynamic>?;
      if (lvp != null) {
        buf.writeln('Value pick: ${lvp['name']} (${lvp['value']}) — don\'t let the price fool you.');
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
        text: "Squad value data isn't loaded right now — check back soon.",
        suggestionChips: ['Tournament favorites', 'Help'],
        resolvedIntent: intent,
      );
    }

    final buf = StringBuffer('World Cup 2026 — the richest squads in the tournament. Money doesn\'t guarantee the trophy, but it sure doesn\'t hurt:\n\n');
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

  /// Generates a player comparison response.
  Future<ChatResponse> playerComparison(ChatIntent intent) async {
    final player1Name = intent.player1;
    final player2Name = intent.player2;

    if (player1Name == null || player2Name == null) {
      return ChatResponse(
        text: "Now we're talking — give me two names and I'll break it down. "
            "Try \"Compare Messi and Mbappe\" or \"Bellingham vs Kane.\"",
        suggestionChips: ['Compare Messi and Mbappe', 'Compare Kane and Haaland'],
        resolvedIntent: intent,
      );
    }

    final stats1 = await _kb.getPlayerStats(player1Name);
    final stats2 = await _kb.getPlayerStats(player2Name);
    final squad1 = await _kb.searchPlayerInSquads(player1Name);
    final squad2 = await _kb.searchPlayerInSquads(player2Name);

    final name1 = stats1?['playerName'] ?? capitalize(player1Name);
    final name2 = stats2?['playerName'] ?? capitalize(player2Name);

    if (stats1 == null && squad1 == null && stats2 == null && squad2 == null) {
      return ChatResponse(
        text: "I couldn't pull up enough data on both of them for a fair comparison. "
            "Try household names — Messi, Mbappe, Kane, Bellingham.",
        suggestionChips: ['Messi stats', 'Mbappe stats'],
        resolvedIntent: intent,
      );
    }

    final buf = StringBuffer('$name1 vs $name2 — let\'s settle this.\n\n');

    // WC career stats if available
    if (stats1 != null || stats2 != null) {
      buf.writeln('On the World Cup stage:');
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
      buf.writeln('Where they stand today:');
      if (squad1 != null) {
        final p = squad1['player'] as Map<String, dynamic>;
        buf.writeln('  $name1: ${p['club']} (${p['position']}) — '
            '${p['caps']} caps, ${p['goals']} goals, \$${formatNumber(p['marketValue'])}');
      }
      if (squad2 != null) {
        final p = squad2['player'] as Map<String, dynamic>;
        buf.writeln('  $name2: ${p['club']} (${p['position']}) — '
            '${p['caps']} caps, ${p['goals']} goals, \$${formatNumber(p['marketValue'])}');
      }
    }

    return ChatResponse(
      text: buf.toString().trim(),
      suggestionChips: ['$name1 stats', '$name2 stats'],
      resolvedIntent: intent,
    );
  }
}

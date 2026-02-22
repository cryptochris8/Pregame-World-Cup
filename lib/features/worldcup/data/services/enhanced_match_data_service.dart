import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../../core/services/logging_service.dart';

/// Service that loads and provides enhanced match analysis data
/// from local JSON asset files.
///
/// Provides:
/// - Squad market values and rankings
/// - Recent international form (last 5-10 matches per team)
/// - Historical World Cup patterns and records
/// - Confederation head-to-head records
/// - Betting odds and predictions
/// - Player injury/availability tracker
/// - Manager tactical profiles
class EnhancedMatchDataService {
  static EnhancedMatchDataService? _instance;
  static EnhancedMatchDataService get instance =>
      _instance ??= EnhancedMatchDataService._();

  EnhancedMatchDataService._();

  static const String _logTag = 'EnhancedMatchData';

  // Cached data
  Map<String, dynamic>? _squadValues;
  Map<String, dynamic>? _recentForm;
  Map<String, dynamic>? _historicalPatterns;
  Map<String, dynamic>? _confederationRecords;
  Map<String, dynamic>? _bettingOdds;
  Map<String, dynamic>? _injuryTracker;
  bool _isInitialized = false;

  /// Initialize the service by loading all data files
  Future<void> initialize() async {
    if (_isInitialized) return;

    await Future.wait([
      _loadSquadValues(),
      _loadRecentForm(),
      _loadHistoricalPatterns(),
      _loadConfederationRecords(),
      _loadBettingOdds(),
      _loadInjuryTracker(),
    ]);

    _isInitialized = true;
    LoggingService.info('Enhanced match data service initialized', tag: _logTag);
  }

  // --- Data Loading ---

  Future<void> _loadSquadValues() async {
    _squadValues = await _loadJsonAsset('assets/data/worldcup/squad_values.json');
  }

  Future<void> _loadRecentForm() async {
    final form = <String, dynamic>{};
    for (final file in ['groups_a_d', 'groups_e_h', 'groups_i_l']) {
      final data = await _loadJsonAsset('assets/data/worldcup/recent_form/$file.json');
      if (data == null) continue;
      // Flatten: extract team entries from group_X keys
      for (final entry in data.entries) {
        if (entry.key == 'metadata') continue;
        if (entry.value is Map<String, dynamic>) {
          final groupTeams = entry.value as Map<String, dynamic>;
          for (final teamEntry in groupTeams.entries) {
            if (teamEntry.value is Map<String, dynamic>) {
              form[teamEntry.key] = teamEntry.value;
            }
          }
        }
      }
    }
    _recentForm = form.isNotEmpty ? form : null;
  }

  Future<void> _loadHistoricalPatterns() async {
    _historicalPatterns = await _loadJsonAsset('assets/data/worldcup/historical_patterns.json');
  }

  Future<void> _loadConfederationRecords() async {
    _confederationRecords = await _loadJsonAsset('assets/data/worldcup/confederation_records.json');
  }

  Future<void> _loadBettingOdds() async {
    _bettingOdds = await _loadJsonAsset('assets/data/worldcup/betting_odds.json');
  }

  Future<void> _loadInjuryTracker() async {
    _injuryTracker = await _loadJsonAsset('assets/data/worldcup/injury_tracker.json');
  }

  Future<Map<String, dynamic>?> _loadJsonAsset(String path) async {
    try {
      final jsonString = await rootBundle.loadString(path);
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      LoggingService.warning('Could not load $path: $e', tag: _logTag);
      return null;
    }
  }

  // --- Public Getters ---

  /// Get squad value data for a team by FIFA code
  Map<String, dynamic>? getSquadValue(String teamCode) {
    if (_squadValues == null) return null;
    final teams = _squadValues!['teams'] as List<dynamic>?;
    if (teams == null) return null;
    try {
      return teams.firstWhere(
        (t) => (t as Map<String, dynamic>)['teamCode'] == teamCode,
      ) as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  /// Get squad value comparison between two teams
  Map<String, dynamic>? getSquadValueComparison(String homeCode, String awayCode) {
    final home = getSquadValue(homeCode);
    final away = getSquadValue(awayCode);
    if (home == null || away == null) return null;

    final homeTotal = (home['totalValue'] as num?) ?? 0;
    final awayTotal = (away['totalValue'] as num?) ?? 0;
    final ratio = awayTotal > 0 ? homeTotal / awayTotal : 1.0;

    String narrative;
    if (ratio > 3.0) {
      narrative = '${home['teamName']} (${home['totalValueFormatted']}) '
          'vastly outspend ${away['teamName']} (${away['totalValueFormatted']}) '
          'in squad value — a true David vs Goliath matchup.';
    } else if (ratio > 1.5) {
      narrative = '${home['teamName']} (${home['totalValueFormatted']}) '
          'hold a significant squad value advantage over '
          '${away['teamName']} (${away['totalValueFormatted']}).';
    } else if (ratio > 1.1) {
      narrative = 'Comparable squad values: '
          '${home['teamName']} (${home['totalValueFormatted']}) vs '
          '${away['teamName']} (${away['totalValueFormatted']}).';
    } else if (ratio > 0.9) {
      narrative = 'Nearly identical squad investments: '
          '${home['teamName']} (${home['totalValueFormatted']}) vs '
          '${away['teamName']} (${away['totalValueFormatted']}).';
    } else if (ratio > 0.67) {
      narrative = '${away['teamName']} (${away['totalValueFormatted']}) '
          'hold a significant squad value advantage over '
          '${home['teamName']} (${home['totalValueFormatted']}).';
    } else {
      narrative = '${away['teamName']} (${away['totalValueFormatted']}) '
          'vastly outspend ${home['teamName']} (${home['totalValueFormatted']}) '
          '— a true David vs Goliath matchup.';
    }

    return {
      'homeValue': home['totalValueFormatted'],
      'awayValue': away['totalValueFormatted'],
      'homeRank': home['rank'],
      'awayRank': away['rank'],
      'homeMVP': home['mostValuablePlayer'],
      'awayMVP': away['mostValuablePlayer'],
      'ratio': ratio,
      'narrative': narrative,
    };
  }

  /// Get recent form for a team
  Map<String, dynamic>? getRecentForm(String teamCode) {
    if (_recentForm == null) return null;
    return _recentForm![teamCode] as Map<String, dynamic>?;
  }

  /// Get recent form summary string for a team
  String? getRecentFormSummary(String teamCode) {
    final form = getRecentForm(teamCode);
    if (form == null) return null;

    final matches = (form['recent_matches'] ?? form['matches']) as List<dynamic>?;
    if (matches == null || matches.isEmpty) return null;

    int wins = 0, draws = 0, losses = 0;
    for (final m in matches) {
      final result = (m as Map<String, dynamic>)['result'] as String?;
      if (result == 'W') {
        wins++;
      } else if (result == 'D') {
        draws++;
      } else if (result == 'L') {
        losses++;
      }
    }

    return 'Last ${matches.length} matches: ${wins}W ${draws}D ${losses}L';
  }

  /// Get relevant historical patterns for a matchup
  List<Map<String, dynamic>> getRelevantPatterns({
    String? homeConfederation,
    String? awayConfederation,
    bool isHostNation = false,
    bool isDefendingChampion = false,
    bool isDebutant = false,
  }) {
    if (_historicalPatterns == null) return [];

    final patterns = _historicalPatterns!['patterns'] as List<dynamic>?;
    if (patterns == null) return [];

    final relevant = <Map<String, dynamic>>[];

    for (final p in patterns) {
      final pattern = p as Map<String, dynamic>;
      final id = pattern['id'] as String? ?? '';
      final category = (pattern['category'] as String? ?? '').toLowerCase();

      // Match patterns by context using id/category
      if (isHostNation && id.contains('host_nation')) {
        relevant.add(pattern);
      } else if (isDefendingChampion &&
          (id.contains('defending_champion') || id.contains('champion'))) {
        relevant.add(pattern);
      } else if (isDebutant && id.contains('debutant')) {
        relevant.add(pattern);
      } else if (homeConfederation != awayConfederation &&
          (id.contains('confederation') || category.contains('confederation'))) {
        relevant.add(pattern);
      } else if (id.contains('group_stage') || id.contains('tournament_firsts')) {
        relevant.add(pattern);
      }
    }

    return relevant.take(5).toList();
  }

  /// Get confederation matchup record
  Map<String, dynamic>? getConfederationMatchup(String conf1, String conf2) {
    if (_confederationRecords == null) return null;

    final records = _confederationRecords!['headToHead'] as List<dynamic>?;
    if (records == null) return null;

    // Search for the pairing in either order
    for (final record in records) {
      final r = record as Map<String, dynamic>;
      final c1 = r['confederation1'] as String?;
      final c2 = r['confederation2'] as String?;
      if ((c1 == conf1 && c2 == conf2) || (c1 == conf2 && c2 == conf1)) {
        return r;
      }
    }
    return null;
  }

  /// Get betting odds for a team
  Map<String, dynamic>? getBettingOdds(String teamCode) {
    if (_bettingOdds == null) return null;
    final outrightOdds = _bettingOdds!['outright_winner_odds'] as Map<String, dynamic>?;
    final teams = outrightOdds?['teams'] as List<dynamic>?;
    if (teams == null) return null;
    try {
      return teams.firstWhere(
        (t) => (t as Map<String, dynamic>)['code'] == teamCode,
      ) as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  /// Get upset potential assessment for a match
  Map<String, dynamic>? getUpsetPotential(String homeCode, String awayCode) {
    final homeOdds = getBettingOdds(homeCode);
    final awayOdds = getBettingOdds(awayCode);
    if (homeOdds == null || awayOdds == null) return null;

    final homeProb = ((homeOdds['implied_probability_pct'] as num?) ?? 0).toDouble() / 100;
    final awayProb = ((awayOdds['implied_probability_pct'] as num?) ?? 0).toDouble() / 100;

    // Upset if underdog has 15-40% chance
    final favorite = homeProb > awayProb ? homeCode : awayCode;
    final underdog = homeProb > awayProb ? awayCode : homeCode;
    final underdogProb = homeProb > awayProb ? awayProb : homeProb;

    if (underdogProb >= 0.15 && underdogProb <= 0.40) {
      return {
        'isUpsetAlert': true,
        'favorite': favorite,
        'underdog': underdog,
        'underdogChance': '${(underdogProb * 100).toInt()}%',
        'narrative': 'Upset Alert: The odds suggest this could be closer than expected.',
      };
    }

    return {'isUpsetAlert': false};
  }

  /// Get injury concerns for a team
  List<Map<String, dynamic>> getInjuryConcerns(String teamCode) {
    if (_injuryTracker == null) return [];

    final players = _injuryTracker!['players'] as List<dynamic>?;
    if (players == null) return [];

    return players
        .where((p) => (p as Map<String, dynamic>)['teamCode'] == teamCode)
        .where((p) =>
            (p as Map<String, dynamic>)['availabilityStatus'] != 'fit')
        .map((p) => p as Map<String, dynamic>)
        .toList();
  }

  /// Get manager tactical profile for a team
  Future<Map<String, dynamic>?> getManagerProfile(String teamCode) async {
    return _loadJsonAsset(
        'assets/data/worldcup/managers/${teamCode.toLowerCase()}.json');
  }

  /// Build a comprehensive enhanced context for AI prompts
  Future<Map<String, dynamic>> buildEnhancedContext({
    required String homeTeamCode,
    required String awayTeamCode,
    required String homeTeamName,
    required String awayTeamName,
    String? homeConfederation,
    String? awayConfederation,
    bool isHostNation = false,
  }) async {
    await initialize();

    final context = <String, dynamic>{};

    // Squad values
    final valueComparison = getSquadValueComparison(homeTeamCode, awayTeamCode);
    if (valueComparison != null) {
      context['squadValueComparison'] = valueComparison;
    }

    // Recent form
    final homeForm = getRecentFormSummary(homeTeamCode);
    final awayForm = getRecentFormSummary(awayTeamCode);
    if (homeForm != null || awayForm != null) {
      context['recentForm'] = {
        'home': homeForm ?? 'No recent form data',
        'away': awayForm ?? 'No recent form data',
      };
    }

    // Historical patterns
    final patterns = getRelevantPatterns(
      homeConfederation: homeConfederation,
      awayConfederation: awayConfederation,
      isHostNation: isHostNation,
    );
    if (patterns.isNotEmpty) {
      context['historicalPatterns'] = patterns.map((p) => p['title']).toList();
    }

    // Confederation records
    if (homeConfederation != null &&
        awayConfederation != null &&
        homeConfederation != awayConfederation) {
      final confRecord =
          getConfederationMatchup(homeConfederation, awayConfederation);
      if (confRecord != null) {
        context['confederationClash'] = confRecord;
      }
    }

    // Betting odds / upset potential
    final upset = getUpsetPotential(homeTeamCode, awayTeamCode);
    if (upset != null && upset['isUpsetAlert'] == true) {
      context['upsetAlert'] = upset;
    }

    // Injury concerns
    final homeInjuries = getInjuryConcerns(homeTeamCode);
    final awayInjuries = getInjuryConcerns(awayTeamCode);
    if (homeInjuries.isNotEmpty || awayInjuries.isNotEmpty) {
      context['injuryConcerns'] = {
        'home': homeInjuries
            .map((i) => '${i['playerName']} (${i['injuryType']})')
            .toList(),
        'away': awayInjuries
            .map((i) => '${i['playerName']} (${i['injuryType']})')
            .toList(),
      };
    }

    // Manager profiles
    final homeManager = await _loadJsonAsset(
        'assets/data/worldcup/managers/${homeTeamCode.toLowerCase()}.json');
    final awayManager = await _loadJsonAsset(
        'assets/data/worldcup/managers/${awayTeamCode.toLowerCase()}.json');
    if (homeManager != null && awayManager != null) {
      context['managerMatchup'] = {
        'home': {
          'name': '${homeManager['firstName']} ${homeManager['lastName']}',
          'formation': homeManager['preferredFormation'],
          'style': homeManager['coachingStyle'],
          'winRate': homeManager['careerWinPercentage'],
        },
        'away': {
          'name': '${awayManager['firstName']} ${awayManager['lastName']}',
          'formation': awayManager['preferredFormation'],
          'style': awayManager['coachingStyle'],
          'winRate': awayManager['careerWinPercentage'],
        },
      };
    }

    return context;
  }

  /// Build enhanced prompt section from context data
  String buildEnhancedPromptSection(Map<String, dynamic> context) {
    final buffer = StringBuffer();

    // Squad Value Showdown
    if (context.containsKey('squadValueComparison')) {
      final sv = context['squadValueComparison'] as Map<String, dynamic>;
      buffer.writeln('\nSQUAD VALUE SHOWDOWN:');
      buffer.writeln(sv['narrative']);
      final homeMVP = sv['homeMVP'] as Map<String, dynamic>?;
      final awayMVP = sv['awayMVP'] as Map<String, dynamic>?;
      if (homeMVP != null) {
        buffer.writeln('  Home MVP: ${homeMVP['name']} (${homeMVP['value']})');
      }
      if (awayMVP != null) {
        buffer.writeln('  Away MVP: ${awayMVP['name']} (${awayMVP['value']})');
      }
    }

    // Recent Form
    if (context.containsKey('recentForm')) {
      final form = context['recentForm'] as Map<String, dynamic>;
      buffer.writeln('\nRECENT INTERNATIONAL FORM:');
      buffer.writeln('  Home: ${form['home']}');
      buffer.writeln('  Away: ${form['away']}');
    }

    // Manager Matchup
    if (context.containsKey('managerMatchup')) {
      final mm = context['managerMatchup'] as Map<String, dynamic>;
      final home = mm['home'] as Map<String, dynamic>;
      final away = mm['away'] as Map<String, dynamic>;
      buffer.writeln('\nMANAGER CHESS:');
      buffer.writeln('  ${home['name']}: ${home['formation']} (${home['style']}, '
          '${home['winRate']}% win rate)');
      buffer.writeln('  vs');
      buffer.writeln('  ${away['name']}: ${away['formation']} (${away['style']}, '
          '${away['winRate']}% win rate)');
    }

    // Historical Patterns
    if (context.containsKey('historicalPatterns')) {
      final patterns = context['historicalPatterns'] as List<dynamic>;
      buffer.writeln('\nHISTORICAL PATTERNS TO CONSIDER:');
      for (final p in patterns) {
        buffer.writeln('  - $p');
      }
    }

    // Confederation Clash
    if (context.containsKey('confederationClash')) {
      final cc = context['confederationClash'] as Map<String, dynamic>;
      buffer.writeln('\nCONFEDERATION CLASH:');
      buffer.writeln('  ${cc['summary'] ?? cc.toString()}');
    }

    // Upset Alert
    if (context.containsKey('upsetAlert')) {
      final ua = context['upsetAlert'] as Map<String, dynamic>;
      buffer.writeln('\nUPSET ALERT:');
      buffer.writeln('  ${ua['narrative']}');
      buffer.writeln('  Underdog chance: ${ua['underdogChance']}');
    }

    // Injury Concerns
    if (context.containsKey('injuryConcerns')) {
      final ic = context['injuryConcerns'] as Map<String, dynamic>;
      final homeInj = ic['home'] as List<dynamic>?;
      final awayInj = ic['away'] as List<dynamic>?;
      if ((homeInj != null && homeInj.isNotEmpty) ||
          (awayInj != null && awayInj.isNotEmpty)) {
        buffer.writeln('\nINJURY CONCERNS:');
        if (homeInj != null && homeInj.isNotEmpty) {
          buffer.writeln('  Home: ${homeInj.join(', ')}');
        }
        if (awayInj != null && awayInj.isNotEmpty) {
          buffer.writeln('  Away: ${awayInj.join(', ')}');
        }
      }
    }

    return buffer.toString();
  }
}

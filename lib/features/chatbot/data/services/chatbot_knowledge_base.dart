import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../../core/services/logging_service.dart';
import '../../../worldcup/data/services/enhanced_match_data_service.dart';

/// Loads and indexes all World Cup JSON data files for the chatbot.
///
/// Tier 1 (eager): matches, history — loaded at initialization.
/// Tier 2 (lazy): teams, managers, h2h, match_summaries, player_stats — loaded
/// on first access per team/file and cached.
///
/// Reuses [EnhancedMatchDataService] for squad values, recent form, betting
/// odds, historical patterns, confederation records, and injury tracker.
class ChatbotKnowledgeBase {
  static const String _logTag = 'ChatbotKnowledgeBase';

  final EnhancedMatchDataService _enhancedData;

  // Tier 1: loaded eagerly
  List<Map<String, dynamic>> _groupMatches = [];
  List<Map<String, dynamic>> _knockoutMatches = [];
  List<Map<String, dynamic>> _historyRecords = [];
  List<Map<String, dynamic>> _tournaments = [];

  // Tier 2: loaded lazily and cached
  final Map<String, Map<String, dynamic>> _teamCache = {};
  final Map<String, Map<String, dynamic>> _managerCache = {};
  final Map<String, Map<String, dynamic>> _h2hCache = {};
  final Map<String, Map<String, dynamic>> _matchSummaryCache = {};
  final Map<String, Map<String, dynamic>> _playerStatsCache = {};

  // Player stats filenames for lookup
  List<String>? _playerStatsFiles;

  // Indexes built from Tier 1 data
  final Map<String, List<Map<String, dynamic>>> _matchesByTeam = {};
  final Map<String, List<Map<String, dynamic>>> _matchesByGroup = {};
  final Map<String, List<Map<String, dynamic>>> _matchesByVenue = {};

  // Team alias map: alias → FIFA code (e.g. "usa" → "USA", "usmnt" → "USA")
  final Map<String, String> _teamAliases = {};

  // Player name map: lowercase name → {playerFile, teamCode}
  final Map<String, Map<String, String>> _playerIndex = {};

  bool _isInitialized = false;

  ChatbotKnowledgeBase({required EnhancedMatchDataService enhancedData})
      : _enhancedData = enhancedData;

  bool get isInitialized => _isInitialized;

  /// Initialize Tier 1 data and build indexes.
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _enhancedData.initialize();

    await Future.wait([
      _loadMatches(),
      _loadHistory(),
      _discoverPlayerStatsFiles(),
    ]);

    _buildIndexes();
    _buildTeamAliases();

    _isInitialized = true;
    LoggingService.info('Knowledge base initialized', tag: _logTag);
  }

  // ─── Data Loading ─────────────────────────────────────────────

  Future<void> _loadMatches() async {
    _groupMatches = await _loadJsonList('assets/data/worldcup/matches/group_stage.json');
    _knockoutMatches = await _loadJsonList('assets/data/worldcup/matches/knockout.json');
  }

  Future<void> _loadHistory() async {
    _historyRecords = await _loadJsonList('assets/data/worldcup/history/records.json');
    _tournaments = await _loadJsonList('assets/data/worldcup/history/tournaments.json');
  }

  Future<void> _discoverPlayerStatsFiles() async {
    try {
      final manifest = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifest);
      _playerStatsFiles = manifestMap.keys
          .where((k) => k.startsWith('assets/data/worldcup/player_stats/') && k.endsWith('.json'))
          .toList();
      // Build player index from filenames
      for (final file in _playerStatsFiles!) {
        final name = file.split('/').last.replaceAll('.json', '');
        final parts = name.split('_');
        if (parts.length >= 2) {
          final teamCode = parts.last.toUpperCase();
          final playerName = parts.sublist(0, parts.length - 1).join(' ').toLowerCase();
          _playerIndex[playerName] = {'file': file, 'teamCode': teamCode};
        }
      }
    } catch (e) {
      LoggingService.warning('Could not discover player stats files: $e', tag: _logTag);
      _playerStatsFiles = [];
    }
  }

  Future<List<Map<String, dynamic>>> _loadJsonList(String path) async {
    try {
      final jsonString = await rootBundle.loadString(path);
      final decoded = json.decode(jsonString);
      if (decoded is List) {
        return decoded.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      LoggingService.warning('Could not load $path: $e', tag: _logTag);
      return [];
    }
  }

  Future<Map<String, dynamic>?> _loadJsonMap(String path) async {
    try {
      final jsonString = await rootBundle.loadString(path);
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      LoggingService.warning('Could not load $path: $e', tag: _logTag);
      return null;
    }
  }

  // ─── Index Building ───────────────────────────────────────────

  void _buildIndexes() {
    final allMatches = [..._groupMatches, ..._knockoutMatches];
    for (final match in allMatches) {
      final home = (match['homeTeamCode'] as String?) ?? '';
      final away = (match['awayTeamCode'] as String?) ?? '';
      final group = (match['group'] as String?) ?? '';
      final venue = (match['venueName'] as String?) ?? '';

      if (home.isNotEmpty) {
        _matchesByTeam.putIfAbsent(home, () => []).add(match);
      }
      if (away.isNotEmpty) {
        _matchesByTeam.putIfAbsent(away, () => []).add(match);
      }
      if (group.isNotEmpty) {
        _matchesByGroup.putIfAbsent(group, () => []).add(match);
      }
      if (venue.isNotEmpty) {
        _matchesByVenue.putIfAbsent(venue.toLowerCase(), () => []).add(match);
      }
    }
  }

  void _buildTeamAliases() {
    // Build from match data (homeTeamCode → homeTeamName)
    final allMatches = [..._groupMatches, ..._knockoutMatches];
    for (final match in allMatches) {
      final code = (match['homeTeamCode'] as String?) ?? '';
      final name = (match['homeTeamName'] as String?) ?? '';
      if (code.isNotEmpty) {
        _teamAliases[code.toLowerCase()] = code;
        if (name.isNotEmpty) {
          _teamAliases[name.toLowerCase()] = code;
        }
      }
      final awayCode = (match['awayTeamCode'] as String?) ?? '';
      final awayName = (match['awayTeamName'] as String?) ?? '';
      if (awayCode.isNotEmpty) {
        _teamAliases[awayCode.toLowerCase()] = awayCode;
        if (awayName.isNotEmpty) {
          _teamAliases[awayName.toLowerCase()] = awayCode;
        }
      }
    }

    // Manual nicknames and common aliases
    const aliases = {
      'usmnt': 'USA', 'us': 'USA', 'united states': 'USA', 'america': 'USA', 'americans': 'USA',
      'el tri': 'MEX', 'la seleccion': 'MEX',
      'les bleus': 'FRA', 'france': 'FRA',
      'la albiceleste': 'ARG', 'argentina': 'ARG',
      'selecao': 'BRA', 'seleção': 'BRA', 'brazil': 'BRA', 'brasil': 'BRA',
      'three lions': 'ENG', 'england': 'ENG',
      'la roja': 'ESP', 'spain': 'ESP',
      'die mannschaft': 'GER', 'germany': 'GER',
      'azzurri': 'ITA', 'italy': 'ITA',
      'oranje': 'NED', 'netherlands': 'NED', 'holland': 'NED', 'dutch': 'NED',
      'atlas lions': 'MAR', 'morocco': 'MAR',
      'samurai blue': 'JPN', 'japan': 'JPN',
      'taegeuk warriors': 'KOR', 'south korea': 'KOR', 'korea': 'KOR', 'korea republic': 'KOR',
      'super eagles': 'NGA', 'nigeria': 'NGA',
      'black stars': 'GHA', 'ghana': 'GHA',
      'lions of teranga': 'SEN', 'senegal': 'SEN',
      'socceroos': 'AUS', 'australia': 'AUS',
      'les rouges': 'CAN', 'canada': 'CAN', 'canucks': 'CAN',
      'vatreni': 'CRO', 'croatia': 'CRO',
      'a selecao': 'POR', 'portugal': 'POR',
      'red devils': 'BEL', 'belgium': 'BEL',
      'la celeste': 'URU', 'uruguay': 'URU',
      'los cafeteros': 'COL', 'colombia': 'COL',
      'green falcons': 'KSA', 'saudi': 'KSA', 'saudi arabia': 'KSA',
      'team melli': 'IRN', 'iran': 'IRN',
      'nati': 'SUI', 'switzerland': 'SUI',
      'eagles': 'ALG', 'algeria': 'ALG', 'desert foxes': 'ALG',
      'pharaohs': 'EGY', 'egypt': 'EGY',
      'indomitable lions': 'CMR', 'cameroon': 'CMR',
      'ivory coast': 'CIV', 'cote divoire': 'CIV', "cote d'ivoire": 'CIV',
      'bafana bafana': 'RSA', 'south africa': 'RSA',
      'la bicolor': 'PER', 'peru': 'PER',
      'la verde': 'PAR', 'paraguay': 'PAR',
      'la tri': 'ECU', 'ecuador': 'ECU',
      'chile': 'CHI', 'la roja chilena': 'CHI',
      'denmark': 'DEN', 'danish dynamite': 'DEN',
      'poland': 'POL',
      'norway': 'NOR',
      'austria': 'AUT',
      'serbia': 'SRB',
      'scotland': 'SCO',
      'tunisia': 'TUN',
      'panama': 'PAN', 'canaleros': 'PAN',
      'costa rica': 'CRC', 'los ticos': 'CRC',
      'honduras': 'HON', 'los catrachos': 'HON',
      'jamaica': 'JAM', 'reggae boyz': 'JAM',
      'haiti': 'HAI',
      'curacao': 'CUR', 'curaçao': 'CUR',
      'cape verde': 'CPV', 'cabo verde': 'CPV', 'blue sharks': 'CPV',
      'qatar': 'QAT',
      'jordan': 'JOR',
      'uzbekistan': 'UZB', 'white wolves': 'UZB',
      'new zealand': 'NZL', 'all whites': 'NZL',
    };

    for (final entry in aliases.entries) {
      _teamAliases[entry.key] = entry.value;
    }
  }

  // ─── Public Query Methods ─────────────────────────────────────

  /// Resolve a team name, alias, or code to the FIFA code.
  String? resolveTeamCode(String input) {
    final lower = input.toLowerCase().trim();
    return _teamAliases[lower];
  }

  /// Get team name for a code (from match data).
  String? getTeamName(String code) {
    final allMatches = [..._groupMatches, ..._knockoutMatches];
    for (final m in allMatches) {
      if (m['homeTeamCode'] == code) return m['homeTeamName'] as String?;
      if (m['awayTeamCode'] == code) return m['awayTeamName'] as String?;
    }
    return code;
  }

  /// All known team aliases (for IntentClassifier entity extraction).
  Map<String, String> get teamAliases => Map.unmodifiable(_teamAliases);

  /// All known player names (lowercase) for entity extraction.
  Set<String> get knownPlayerNames => _playerIndex.keys.toSet();

  /// Get all matches for a team by FIFA code.
  List<Map<String, dynamic>> getMatchesForTeam(String teamCode) {
    return _matchesByTeam[teamCode] ?? [];
  }

  /// Get the next upcoming match for a team (first scheduled match).
  Map<String, dynamic>? getNextMatch(String teamCode) {
    final matches = getMatchesForTeam(teamCode);
    final scheduled = matches.where((m) => m['status'] == 'scheduled').toList();
    if (scheduled.isEmpty) return null;
    scheduled.sort((a, b) => (a['date'] as String).compareTo(b['date'] as String));
    return scheduled.first;
  }

  /// Get all matches in a group.
  List<Map<String, dynamic>> getGroupMatches(String groupLetter) {
    return _matchesByGroup[groupLetter.toUpperCase()] ?? [];
  }

  /// Get all matches at a venue (partial match on venue name).
  List<Map<String, dynamic>> getVenueMatches(String venueName) {
    final lower = venueName.toLowerCase();
    final results = <Map<String, dynamic>>[];
    for (final entry in _matchesByVenue.entries) {
      if (entry.key.contains(lower)) {
        results.addAll(entry.value);
      }
    }
    return results;
  }

  /// Get all unique venue names from match data.
  List<String> getAllVenues() {
    final venues = <String>{};
    final allMatches = [..._groupMatches, ..._knockoutMatches];
    for (final m in allMatches) {
      final v = m['venueName'] as String?;
      if (v != null && v.isNotEmpty) venues.add(v);
    }
    return venues.toList()..sort();
  }

  /// Get team squad data (lazy loaded).
  Future<Map<String, dynamic>?> getTeamData(String teamCode) async {
    final code = teamCode.toLowerCase();
    if (_teamCache.containsKey(code)) return _teamCache[code];
    final data = await _loadJsonMap('assets/data/worldcup/teams/$code.json');
    if (data != null) _teamCache[code] = data;
    return data;
  }

  /// Get manager data for a team (lazy loaded).
  Future<Map<String, dynamic>?> getManager(String teamCode) async {
    final code = teamCode.toLowerCase();
    if (_managerCache.containsKey(code)) return _managerCache[code];
    final data = await _loadJsonMap('assets/data/worldcup/managers/$code.json');
    if (data != null) _managerCache[code] = data;
    return data;
  }

  /// Get head-to-head data for two teams (lazy loaded).
  Future<Map<String, dynamic>?> getHeadToHead(String code1, String code2) async {
    // Try both orderings
    final key1 = '${code1.toUpperCase()}_${code2.toUpperCase()}';
    final key2 = '${code2.toUpperCase()}_${code1.toUpperCase()}';
    if (_h2hCache.containsKey(key1)) return _h2hCache[key1];
    if (_h2hCache.containsKey(key2)) return _h2hCache[key2];

    var data = await _loadJsonMap('assets/data/worldcup/head_to_head/$key1.json');
    if (data != null) {
      _h2hCache[key1] = data;
      return data;
    }
    data = await _loadJsonMap('assets/data/worldcup/head_to_head/$key2.json');
    if (data != null) {
      _h2hCache[key2] = data;
      return data;
    }
    return null;
  }

  /// Get match summary/preview for two teams (lazy loaded).
  Future<Map<String, dynamic>?> getMatchSummary(String code1, String code2) async {
    final key1 = '${code1.toUpperCase()}_${code2.toUpperCase()}';
    final key2 = '${code2.toUpperCase()}_${code1.toUpperCase()}';
    if (_matchSummaryCache.containsKey(key1)) return _matchSummaryCache[key1];
    if (_matchSummaryCache.containsKey(key2)) return _matchSummaryCache[key2];

    var data = await _loadJsonMap('assets/data/worldcup/match_summaries/$key1.json');
    if (data != null) {
      _matchSummaryCache[key1] = data;
      return data;
    }
    data = await _loadJsonMap('assets/data/worldcup/match_summaries/$key2.json');
    if (data != null) {
      _matchSummaryCache[key2] = data;
      return data;
    }
    return null;
  }

  /// Search for a player by name across player_stats files.
  Future<Map<String, dynamic>?> getPlayerStats(String playerName) async {
    final lower = playerName.toLowerCase();

    // Check cache first
    if (_playerStatsCache.containsKey(lower)) return _playerStatsCache[lower];

    // Find in the index (supports partial matches)
    String? matchedFile;
    for (final entry in _playerIndex.entries) {
      if (entry.key.contains(lower) || lower.contains(entry.key)) {
        matchedFile = entry.value['file'];
        break;
      }
    }

    if (matchedFile != null) {
      final data = await _loadJsonMap(matchedFile);
      if (data != null) {
        _playerStatsCache[lower] = data;
        return data;
      }
    }
    return null;
  }

  /// Search for a player by name across team squad data.
  Future<Map<String, dynamic>?> searchPlayerInSquads(String playerName) async {
    final lower = playerName.toLowerCase();
    // Search all cached teams first
    for (final team in _teamCache.values) {
      final players = team['players'] as List<dynamic>?;
      if (players == null) continue;
      for (final p in players) {
        final pm = p as Map<String, dynamic>;
        final firstName = (pm['firstName'] as String? ?? '').toLowerCase();
        final lastName = (pm['lastName'] as String? ?? '').toLowerCase();
        final fullName = '$firstName $lastName';
        if (fullName.contains(lower) || lower.contains(lastName)) {
          return {
            'player': pm,
            'teamCode': team['fifaCode'],
            'teamName': team['countryName'],
          };
        }
      }
    }
    return null;
  }

  /// Get all World Cup history records.
  List<Map<String, dynamic>> getRecords() => _historyRecords;

  /// Get tournament data for a specific year.
  Map<String, dynamic>? getTournamentByYear(int year) {
    try {
      return _tournaments.firstWhere(
        (t) => t['year'] == year,
      );
    } catch (_) {
      return null;
    }
  }

  /// Get all tournaments.
  List<Map<String, dynamic>> getAllTournaments() => _tournaments;

  // ─── Delegates to EnhancedMatchDataService ────────────────────

  Map<String, dynamic>? getSquadValue(String teamCode) =>
      _enhancedData.getSquadValue(teamCode);

  String? getRecentFormSummary(String teamCode) =>
      _enhancedData.getRecentFormSummary(teamCode);

  Map<String, dynamic>? getRecentForm(String teamCode) =>
      _enhancedData.getRecentForm(teamCode);

  Map<String, dynamic>? getBettingOdds(String teamCode) =>
      _enhancedData.getBettingOdds(teamCode);

  List<Map<String, dynamic>> getInjuryConcerns(String teamCode) =>
      _enhancedData.getInjuryConcerns(teamCode);

  /// Get top favorites by betting odds.
  List<Map<String, dynamic>> getTopFavorites({int limit = 5}) {
    final allMatches = [..._groupMatches, ..._knockoutMatches];
    final teamCodes = <String>{};
    for (final m in allMatches) {
      final h = m['homeTeamCode'] as String?;
      final a = m['awayTeamCode'] as String?;
      if (h != null) teamCodes.add(h);
      if (a != null) teamCodes.add(a);
    }

    final withOdds = <Map<String, dynamic>>[];
    for (final code in teamCodes) {
      final odds = getBettingOdds(code);
      if (odds != null) withOdds.add(odds);
    }

    withOdds.sort((a, b) {
      final aProb = (a['implied_probability_pct'] as num?) ?? 0;
      final bProb = (b['implied_probability_pct'] as num?) ?? 0;
      return bProb.compareTo(aProb);
    });

    return withOdds.take(limit).toList();
  }

  /// Get the group letter a team belongs to.
  String? getTeamGroup(String teamCode) {
    for (final m in _groupMatches) {
      if (m['homeTeamCode'] == teamCode || m['awayTeamCode'] == teamCode) {
        return m['group'] as String?;
      }
    }
    return null;
  }

  /// Get all teams in a group.
  List<String> getTeamsInGroup(String groupLetter) {
    final teams = <String>{};
    final matches = getGroupMatches(groupLetter);
    for (final m in matches) {
      final h = m['homeTeamCode'] as String?;
      final a = m['awayTeamCode'] as String?;
      if (h != null) teams.add(h);
      if (a != null) teams.add(a);
    }
    return teams.toList();
  }
}

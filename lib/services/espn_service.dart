import 'package:dio/dio.dart';
import 'package:pregame_world_cup/core/entities/game_intelligence.dart';
import 'package:pregame_world_cup/features/schedule/domain/entities/game_schedule.dart';
import 'package:hive/hive.dart';
import 'espn_historical_service.dart';

/// ESPN Soccer service for World Cup 2026 game intelligence and venue recommendations.
/// Uses ESPN's soccer API endpoints for FIFA World Cup data.
/// Primary match data comes from SportsData.io and Firebase;
/// this service provides supplemental intelligence and analysis.
class ESPNService {
  // ESPN soccer API base URL
  // League slugs: fifa.world (World Cup), fifa.worldq (qualifiers),
  //   usa.1 (MLS), eng.1 (EPL), etc.
  static const String _baseUrl = 'https://site.api.espn.com/apis/site/v2/sports/soccer';

  /// ESPN league slug for FIFA World Cup 2026
  static const String _worldCupLeague = 'fifa.world';

  /// ESPN league slug for FIFA World Cup Qualifiers
  static const String _worldCupQualifiersLeague = 'fifa.worldq';

  final Dio _dio;
  Box<GameIntelligence>? _gameIntelligenceBox;
  late ESPNHistoricalService _historicalService;

  ESPNService({Dio? dio}) : _dio = dio ?? Dio() {
    _historicalService = ESPNHistoricalService();
  }

  Future<void> _initializeService() async {
    if (_gameIntelligenceBox != null) return; // Already initialized

    try {
      _gameIntelligenceBox = await Hive.openBox<GameIntelligence>('game_intelligence');
    } catch (e) {
      // If Hive isn't ready, we'll try again later
      _gameIntelligenceBox = null;
    }
  }

  /// Get enhanced game intelligence with crowd factors, venue recommendations, and historical context
  Future<GameIntelligence?> getGameIntelligence(String gameId) async {
    try {
      // Ensure service is initialized
      await _initializeService();

      // Check cache first (valid for 2 hours) - but only if Hive is available
      if (_gameIntelligenceBox != null) {
        final cached = _gameIntelligenceBox!.get(gameId);
        if (cached != null &&
            DateTime.now().difference(cached.lastUpdated).inHours < 2) {
          return cached;
        }
      }

      // Fetch fresh data from ESPN soccer API
      final gameData = await _fetchESPNGameData(gameId);
      if (gameData == null) return null;

      // Analyze and create intelligence
      final intelligence = await _analyzeGameData(gameData);

      // Cache the result (if Hive is available)
      if (_gameIntelligenceBox != null) {
        await _gameIntelligenceBox!.put(gameId, intelligence);
      }

      return intelligence;
    } catch (e) {
      return null;
    }
  }

  /// Fetch raw game data from ESPN Soccer API
  /// Uses the FIFA World Cup league endpoint for match summaries.
  Future<Map<String, dynamic>?> _fetchESPNGameData(String gameId) async {
    try {
      // ESPN soccer match summary endpoint
      final response = await _dio.get(
        '$_baseUrl/$_worldCupLeague/summary',
        queryParameters: {
          'event': gameId,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Fetch current World Cup matches from ESPN soccer scoreboard
  Future<List<Map<String, dynamic>>> getCurrentGames() async {
    try {
      final response = await _dio.get(
        '$_baseUrl/$_worldCupLeague/scoreboard',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final events = data['events'] as List? ?? [];
        return events.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Fetch World Cup 2026 schedule from ESPN Soccer API
  /// The tournament runs June 11 - July 19, 2026
  Future<List<GameSchedule>> get2025Schedule({int limit = 100}) async {
    try {
      final scheduleGames = <GameSchedule>[];

      // World Cup 2026 dates: June 11 - July 19, 2026
      final startDate = DateTime(2026, 6, 1);
      final endDate = DateTime(2026, 7, 31);

      final startDateStr = _formatDateForESPN(startDate);
      final endDateStr = _formatDateForESPN(endDate);

      final response = await _dio.get(
        '$_baseUrl/$_worldCupLeague/scoreboard',
        queryParameters: {
          'dates': '$startDateStr-$endDateStr',
          'limit': limit.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final events = data['events'] as List? ?? [];

        for (final event in events) {
          try {
            final gameSchedule = _parseESPNEventToGameSchedule(event);
            if (gameSchedule != null) {
              scheduleGames.add(gameSchedule);
            }
          } catch (e) {
            // Skip events that fail to parse
          }
        }

        // Sort by date
        scheduleGames.sort((a, b) {
          final aDate = a.dateTime ?? DateTime(1970);
          final bDate = b.dateTime ?? DateTime(1970);
          return aDate.compareTo(bDate);
        });

        return scheduleGames.take(limit).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  /// Get upcoming World Cup matches from ESPN Soccer API (next 2 weeks)
  Future<List<GameSchedule>> getUpcomingGames({int limit = 10}) async {
    try {
      final now = DateTime.now();
      final twoWeeksFromNow = now.add(const Duration(days: 14));

      final startDateStr = _formatDateForESPN(now);
      final endDateStr = _formatDateForESPN(twoWeeksFromNow);

      final response = await _dio.get(
        '$_baseUrl/$_worldCupLeague/scoreboard',
        queryParameters: {
          'dates': '$startDateStr-$endDateStr',
          'limit': limit.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final events = data['events'] as List? ?? [];

        final upcomingGames = <GameSchedule>[];

        for (final event in events) {
          try {
            final gameSchedule = _parseESPNEventToGameSchedule(event);
            if (gameSchedule != null) {
              // Only include future games
              final gameTime = gameSchedule.dateTime;
              if (gameTime != null && gameTime.isAfter(now)) {
                upcomingGames.add(gameSchedule);
              }
            }
          } catch (e) {
            // Skip events that fail to parse
          }
        }

        // Sort by date and limit results
        upcomingGames.sort((a, b) {
          final aDate = a.dateTime ?? DateTime(1970);
          final bDate = b.dateTime ?? DateTime(1970);
          return aDate.compareTo(bDate);
        });

        return upcomingGames.take(limit).toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get World Cup schedule for a specific year from ESPN Soccer API
  /// Supports 2022 (Qatar), 2018 (Russia), and 2026 (USA/Mexico/Canada)
  Future<List<GameSchedule>> getScheduleForYear(int year, {int limit = 2000}) async {
    try {
      DateTime startDate;
      DateTime endDate;
      String league = _worldCupLeague;

      if (year == 2022) {
        // Qatar 2022: Nov 21 - Dec 18
        startDate = DateTime(2022, 11, 1);
        endDate = DateTime(2022, 12, 31);
      } else if (year == 2018) {
        // Russia 2018: June 14 - July 15
        startDate = DateTime(2018, 6, 1);
        endDate = DateTime(2018, 7, 31);
      } else if (year == 2026) {
        // USA/Mexico/Canada 2026: June 11 - July 19
        startDate = DateTime(2026, 6, 1);
        endDate = DateTime(2026, 7, 31);
      } else if (year == 2025) {
        // 2025 = World Cup Qualifiers
        startDate = DateTime(2025, 1, 1);
        endDate = DateTime(2025, 12, 31);
        league = _worldCupQualifiersLeague;
      } else {
        return [];
      }

      final startDateStr = _formatDateForESPN(startDate);
      final endDateStr = _formatDateForESPN(endDate);

      final response = await _dio.get(
        '$_baseUrl/$league/scoreboard',
        queryParameters: {
          'dates': '$startDateStr-$endDateStr',
          'limit': limit.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final events = data['events'] as List? ?? [];

        final games = <GameSchedule>[];
        for (final event in events) {
          final game = _parseESPNEventToGameScheduleWithYear(event, year);
          if (game != null) {
            games.add(game);
          }
        }

        // Sort by date
        games.sort((a, b) {
          if (a.dateTime == null && b.dateTime == null) return 0;
          if (a.dateTime == null) return 1;
          if (b.dateTime == null) return -1;
          return a.dateTime!.compareTo(b.dateTime!);
        });

        return games;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  /// Parse ESPN soccer event data to GameSchedule object
  /// Handles ESPN's soccer response format: competitions > competitors (teams),
  /// venue, broadcasts, match status, etc.
  GameSchedule? _parseESPNEventToGameSchedule(Map<String, dynamic> event) {
    try {
      final eventId = event['id']?.toString() ?? '';
      final date = event['date'] ?? '';

      // Parse teams from competitions
      final competitions = event['competitions'] as List? ?? [];
      if (competitions.isEmpty) return null;

      final competition = competitions[0] as Map<String, dynamic>;
      final competitors = competition['competitors'] as List? ?? [];

      if (competitors.length < 2) return null;

      String awayTeamName = '';
      String homeTeamName = '';
      String? awayTeamLogoUrl;
      String? homeTeamLogoUrl;
      int? awayTeamId;
      int? homeTeamId;

      for (final competitor in competitors) {
        final team = competitor['team'] as Map<String, dynamic>? ?? {};
        final homeAway = competitor['homeAway'] as String? ?? '';
        final teamName = team['displayName'] ?? team['name'] ?? '';
        final teamId = int.tryParse(team['id']?.toString() ?? '');
        // ESPN soccer uses 'logo' or 'logos' array
        final logo = team['logo'] as String?;
        final logos = team['logos'] as List?;
        final logoUrl = logo ?? (logos != null && logos.isNotEmpty ? logos[0]['href'] : null);

        if (homeAway == 'home') {
          homeTeamName = teamName;
          homeTeamId = teamId;
          homeTeamLogoUrl = logoUrl;
        } else {
          awayTeamName = teamName;
          awayTeamId = teamId;
          awayTeamLogoUrl = logoUrl;
        }
      }

      // Parse venue information (stadium for World Cup matches)
      final venue = competition['venue'] as Map<String, dynamic>? ?? {};
      final venueName = venue['fullName'] ?? venue['name'] ?? '';
      final venueCity = venue['address']?['city'] ?? '';
      // Soccer venues use 'country' instead of 'state' for international matches
      final venueCountry = venue['address']?['country'] ?? venue['address']?['state'] ?? '';

      // Parse broadcast info
      final broadcasts = competition['broadcasts'] as List? ?? [];
      String? channel;
      if (broadcasts.isNotEmpty) {
        final broadcast = broadcasts[0] as Map<String, dynamic>;
        final networks = broadcast['names'] as List? ?? [];
        if (networks.isNotEmpty) {
          channel = networks[0].toString();
        }
      }

      // Parse date and time
      DateTime? gameDateTime;
      try {
        gameDateTime = DateTime.parse(date);
      } catch (e) {
        // Failed to parse date
      }

      // Create Stadium object if venue info exists
      Stadium? stadium;
      if (venueName.isNotEmpty) {
        stadium = Stadium(
          stadiumId: venue['id'] != null ? int.tryParse(venue['id'].toString()) : null,
          name: venueName,
          city: venueCity,
          state: venueCountry, // Country for international matches
          capacity: null,
          yearOpened: null,
          geoLat: null,
          geoLong: null,
          team: homeTeamName,
        );
      }

      // Determine match round/stage from notes if available
      // Match stage can be extracted from notes if needed

      return GameSchedule(
        gameId: 'espn_$eventId',
        season: '2026',
        week: null,
        status: 'Scheduled',
        dateTime: gameDateTime,
        dateTimeUTC: gameDateTime?.toUtc(),
        day: gameDateTime,
        awayTeamId: awayTeamId,
        homeTeamId: homeTeamId,
        awayTeamName: awayTeamName,
        homeTeamName: homeTeamName,
        stadium: stadium,
        channel: channel,
        awayTeamLogoUrl: awayTeamLogoUrl,
        homeTeamLogoUrl: homeTeamLogoUrl,
        neutralVenue: venue['neutralSite'] == true,
        updatedApi: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Enhanced parser for historical/live soccer data with scores and match status
  /// Handles soccer-specific fields: goals, match period (1H/2H/ET/PK), etc.
  GameSchedule? _parseESPNEventToGameScheduleWithYear(Map<String, dynamic> event, int year) {
    try {
      final eventId = event['id']?.toString() ?? '';
      final date = event['date'] ?? '';

      // Parse teams and scores
      final competitions = event['competitions'] as List? ?? [];
      if (competitions.isEmpty) return null;

      final competition = competitions[0] as Map<String, dynamic>;
      final competitors = competition['competitors'] as List? ?? [];

      if (competitors.length < 2) return null;

      String awayTeamName = '';
      String homeTeamName = '';
      String? awayTeamLogoUrl;
      String? homeTeamLogoUrl;
      int? awayTeamId;
      int? homeTeamId;
      int? awayScore;
      int? homeScore;

      for (final competitor in competitors) {
        final team = competitor['team'] as Map<String, dynamic>? ?? {};
        final homeAway = competitor['homeAway'] as String? ?? '';
        final teamName = team['displayName'] ?? team['name'] ?? '';
        final teamId = int.tryParse(team['id']?.toString() ?? '');
        final logo = team['logo'] as String?;
        final logos = team['logos'] as List?;
        final logoUrl = logo ?? (logos != null && logos.isNotEmpty ? logos[0]['href'] : null);

        // Parse score (goals in soccer)
        final score = int.tryParse(competitor['score']?.toString() ?? '');

        if (homeAway == 'home') {
          homeTeamName = teamName;
          homeTeamId = teamId;
          homeTeamLogoUrl = logoUrl;
          homeScore = score;
        } else {
          awayTeamName = teamName;
          awayTeamId = teamId;
          awayTeamLogoUrl = logoUrl;
          awayScore = score;
        }
      }

      // Parse match status (soccer uses: 1st Half, 2nd Half, Halftime,
      // Extra Time, Penalty Shootout, Full Time, etc.)
      final status = competition['status'] as Map<String, dynamic>? ?? {};
      final statusType = status['type'] as Map<String, dynamic>? ?? {};
      final gameStatus = statusType['name'] ?? 'Scheduled';
      final gameState = statusType['state'] ?? 'pre';
      final statusDetail = status['type']?['detail'] ?? '';

      // Parse match clock for live games
      final clock = status['displayClock'] as String?;

      // Parse venue information
      final venue = competition['venue'] as Map<String, dynamic>? ?? {};
      final venueName = venue['fullName'] ?? venue['name'] ?? '';
      final venueCity = venue['address']?['city'] ?? '';
      final venueCountry = venue['address']?['country'] ?? venue['address']?['state'] ?? '';

      // Parse broadcast info
      final broadcasts = competition['broadcasts'] as List? ?? [];
      String? channel;
      if (broadcasts.isNotEmpty) {
        final broadcast = broadcasts[0] as Map<String, dynamic>;
        final networks = broadcast['names'] as List? ?? [];
        if (networks.isNotEmpty) {
          channel = networks[0].toString();
        }
      }

      // Parse date and time
      DateTime? gameDateTime;
      try {
        gameDateTime = DateTime.parse(date);
      } catch (e) {
        // Failed to parse date
      }

      // Create Stadium object if venue info exists
      Stadium? stadium;
      if (venueName.isNotEmpty) {
        stadium = Stadium(
          stadiumId: venue['id'] != null ? int.tryParse(venue['id'].toString()) : null,
          name: venueName,
          city: venueCity,
          state: venueCountry,
          capacity: null,
          yearOpened: null,
          geoLat: null,
          geoLong: null,
          team: homeTeamName,
        );
      }

      // Determine match period for soccer
      String? period;
      if (statusDetail.isNotEmpty) {
        period = statusDetail;
      } else if (clock != null) {
        period = clock;
      }

      return GameSchedule(
        gameId: 'espn_$eventId',
        season: year.toString(),
        week: null, // Soccer uses matchday/round, not weeks
        status: gameStatus,
        dateTime: gameDateTime,
        dateTimeUTC: gameDateTime?.toUtc(),
        day: gameDateTime,
        awayTeamId: awayTeamId,
        homeTeamId: homeTeamId,
        awayTeamName: awayTeamName,
        homeTeamName: homeTeamName,
        awayScore: awayScore,
        homeScore: homeScore,
        stadium: stadium,
        channel: channel,
        awayTeamLogoUrl: awayTeamLogoUrl,
        homeTeamLogoUrl: homeTeamLogoUrl,
        neutralVenue: venue['neutralSite'] == true,
        updatedApi: DateTime.now(),
        // Live match state
        isLive: gameState == 'in',
        period: period,
        lastScoreUpdate: gameState == 'post' ? gameDateTime : null,
      );
    } catch (e) {
      return null;
    }
  }

  /// Format date for ESPN API (YYYYMMDD format)
  String _formatDateForESPN(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year$month$day';
  }

  /// Analyze ESPN soccer match data to create actionable intelligence
  Future<GameIntelligence> _analyzeGameData(Map<String, dynamic> espnData) async {
    final header = espnData['header'] ?? {};
    final competitions = espnData['competitions'] ?? [];

    String homeTeam = '';
    String awayTeam = '';
    int? homeRank;
    int? awayRank;

    if (competitions.isNotEmpty) {
      final teams = competitions[0]['competitors'] ?? [];
      for (var team in teams) {
        final teamData = team['team'] ?? {};
        final isHome = team['homeAway'] == 'home';
        final teamName = teamData['displayName'] ?? '';
        // FIFA ranking from ESPN data
        final rank = _parseRank(team['curatedRank']?.toString());

        if (isHome) {
          homeTeam = teamName;
          homeRank = rank;
        } else {
          awayTeam = teamName;
          awayRank = rank;
        }
      }
    }

    // Calculate crowd factor based on FIFA rankings and match importance
    final crowdFactor = _calculateCrowdFactor(
      homeRank: homeRank,
      awayRank: awayRank,
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      gameData: espnData,
    );

    // Detect rivalry/derby matches
    final isRivalry = _isRivalryGame(homeTeam, awayTeam);

    // Analyze knockout/championship implications
    final hasChampImplications = _hasChampionshipImplications(espnData);

    // Extract broadcast information
    final broadcast = _extractBroadcastInfo(espnData);

    // Generate venue recommendations for watch parties and sports bars
    final venueRecommendations = _generateVenueRecommendations(
      crowdFactor: crowdFactor,
      isRivalry: isRivalry,
      hasChampImplications: hasChampImplications,
      homeTeam: homeTeam,
      awayTeam: awayTeam,
    );

    return GameIntelligence(
      gameId: header['id']?.toString() ?? '',
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      homeTeamRank: homeRank,
      awayTeamRank: awayRank,
      crowdFactor: crowdFactor,
      isRivalryGame: isRivalry,
      hasChampionshipImplications: hasChampImplications,
      broadcastNetwork: broadcast['network'] ?? 'TBD',
      expectedTvAudience: _estimateTvAudience(crowdFactor, isRivalry, broadcast['network']),
      keyStorylines: _extractKeyStorylines(espnData, isRivalry, hasChampImplications),
      teamStats: _extractTeamStats(espnData),
      lastUpdated: DateTime.now(),
      confidenceScore: _calculateConfidenceScore(espnData),
      venueRecommendations: venueRecommendations,
    );
  }

  /// Calculate crowd factor based on FIFA rankings, rivalry status, and match stage
  double _calculateCrowdFactor(
      {int? homeRank, int? awayRank, required String homeTeam, required String awayTeam, required Map<String, dynamic> gameData}) {
    double factor = 1.0; // Base factor

    // FIFA ranking impact (higher ranked = more interest)
    // Top 10 nations draw massive crowds
    if (homeRank != null && homeRank <= 50) {
      factor += (51 - homeRank) * 0.01; // Up to +0.5 for #1 ranked team
    }
    if (awayRank != null && awayRank <= 50) {
      factor += (51 - awayRank) * 0.01;
    }

    // Both teams in top 10 FIFA rankings
    if ((homeRank != null && homeRank <= 10) && (awayRank != null && awayRank <= 10)) {
      factor += 0.5; // Top 10 matchup bonus
    }

    // International rivalry/derby bonus
    if (_isRivalryGame(homeTeam, awayTeam)) {
      factor += 0.7; // Major rivalry bonus (World Cup rivalries draw huge interest)
    }

    // Knockout round / championship implications
    if (_hasChampionshipImplications(gameData)) {
      factor += 0.6;
    }

    // Weekend matches tend to draw bigger watch party crowds
    final gameTime = DateTime.tryParse(gameData['header']?['timeValid'] ?? '');
    if (gameTime != null && (gameTime.weekday == DateTime.saturday || gameTime.weekday == DateTime.sunday)) {
      factor += 0.2;
    }

    // Cap the maximum crowd factor at 3.0 (300% of normal)
    return factor > 3.0 ? 3.0 : factor;
  }

  /// Check if this is a major international soccer rivalry
  bool _isRivalryGame(String homeTeam, String awayTeam) {
    // Normalize team names for matching
    final home = _normalizeTeamName(homeTeam);
    final away = _normalizeTeamName(awayTeam);

    // Major World Cup rivalries and historic derby matches
    final rivalries = [
      {'brazil', 'argentina'},
      {'germany', 'netherlands'},
      {'germany', 'england'},
      {'germany', 'italy'},
      {'england', 'argentina'},
      {'brazil', 'germany'},
      {'brazil', 'france'},
      {'france', 'italy'},
      {'france', 'germany'},
      {'spain', 'portugal'},
      {'spain', 'italy'},
      {'mexico', 'united states'},
      {'mexico', 'usa'},
      {'united states', 'england'},
      {'usa', 'england'},
      {'south korea', 'japan'},
      {'uruguay', 'argentina'},
      {'colombia', 'argentina'},
      {'brazil', 'uruguay'},
      {'chile', 'argentina'},
      {'ghana', 'uruguay'},
      {'croatia', 'serbia'},
      {'netherlands', 'belgium'},
      {'england', 'scotland'},
      {'cameroon', 'nigeria'},
      {'egypt', 'algeria'},
      {'iran', 'iraq'},
      {'australia', 'japan'},
      {'costa rica', 'mexico'},
      {'canada', 'united states'},
      {'canada', 'usa'},
    ];

    for (final rivalry in rivalries) {
      final team1 = rivalry.first;
      final team2 = rivalry.last;
      if ((home.contains(team1) && away.contains(team2)) ||
          (home.contains(team2) && away.contains(team1))) {
        return true;
      }
    }

    return false;
  }

  /// Analyze if match has knockout/championship implications
  bool _hasChampionshipImplications(Map<String, dynamic> gameData) {
    final notes = gameData['notes']?.toString().toLowerCase() ?? '';
    final situation = gameData['situation']?.toString().toLowerCase() ?? '';
    final header = gameData['header']?.toString().toLowerCase() ?? '';

    return notes.contains('final') ||
           notes.contains('semifinal') ||
           notes.contains('semi-final') ||
           notes.contains('quarter-final') ||
           notes.contains('quarterfinal') ||
           notes.contains('knockout') ||
           notes.contains('round of 16') ||
           notes.contains('round of 32') ||
           situation.contains('elimination') ||
           situation.contains('knockout') ||
           header.contains('final') ||
           header.contains('knockout');
  }

  /// Extract broadcast information
  Map<String, String> _extractBroadcastInfo(Map<String, dynamic> gameData) {
    final competitions = gameData['competitions'] ?? [];
    if (competitions.isNotEmpty) {
      final broadcasts = competitions[0]['broadcasts'] ?? [];
      if (broadcasts.isNotEmpty) {
        return {
          'network': broadcasts[0]['names']?[0] ?? 'TBD',
          'type': broadcasts[0]['type']?['shortName'] ?? 'TV',
        };
      }
    }
    return {'network': 'TBD', 'type': 'TV'};
  }

  /// Estimate TV audience for a World Cup match based on various factors
  double _estimateTvAudience(double crowdFactor, bool isRivalry, String? network) {
    // World Cup matches draw massive global audiences
    double baseAudience = 10.0; // Million US viewers baseline for World Cup

    // Network influence for US broadcast
    switch (network?.toUpperCase()) {
      case 'FOX':
        baseAudience = 15.0; // FOX has primary English rights for WC 2026
        break;
      case 'FS1':
        baseAudience = 10.0;
        break;
      case 'TELEMUNDO':
      case 'UNIVERSO':
        baseAudience = 12.0; // Spanish-language draws huge audiences
        break;
      case 'PEACOCK':
        baseAudience = 8.0;
        break;
      default:
        baseAudience = 10.0;
    }

    // Apply crowd factor and rivalry bonus
    double estimatedAudience = baseAudience * crowdFactor;
    if (isRivalry) {
      estimatedAudience *= 1.4; // Rivalries draw even more viewers
    }

    return estimatedAudience;
  }

  /// Extract key storylines for marketing and engagement
  List<String> _extractKeyStorylines(Map<String, dynamic> gameData, bool isRivalry, bool hasChampImplications) {
    List<String> storylines = [];

    if (isRivalry) {
      storylines.add('Historic International Rivalry');
    }

    if (hasChampImplications) {
      storylines.add('Knockout Stage Match - Win or Go Home');
    }

    // Add storylines based on match data
    final situation = gameData['situation']?.toString() ?? '';
    if (situation.contains('unbeaten') || situation.contains('undefeated')) {
      storylines.add('Unbeaten Run on the Line');
    }

    final notes = gameData['notes']?.toString().toLowerCase() ?? '';
    if (notes.contains('group')) {
      storylines.add('Group Stage - Fight for Qualification');
    }
    if (notes.contains('final')) {
      storylines.add('World Cup Final - The Biggest Match in Football');
    }

    return storylines;
  }

  /// Extract relevant team statistics from ESPN soccer data
  Map<String, dynamic> _extractTeamStats(Map<String, dynamic> gameData) {
    Map<String, dynamic> stats = {};

    final competitions = gameData['competitions'] ?? [];
    if (competitions.isNotEmpty) {
      final teams = competitions[0]['competitors'] ?? [];
      for (var team in teams) {
        final teamData = team['team'] ?? {};
        final record = team['records']?[0] ?? {};
        final teamName = teamData['displayName'] ?? '';

        // Soccer records: W-D-L format (wins-draws-losses)
        stats[teamName] = {
          'wins': record['wins'] ?? 0,
          'draws': record['ties'] ?? record['draws'] ?? 0,
          'losses': record['losses'] ?? 0,
          'rank': _parseRank(team['curatedRank']?.toString()),
          'record_summary': record['displayValue'] ?? 'N/A',
        };
      }
    }

    return stats;
  }

  /// Generate venue recommendations for watch parties and sports bars
  VenueRecommendations _generateVenueRecommendations({
    required double crowdFactor,
    required bool isRivalry,
    required bool hasChampImplications,
    required String homeTeam,
    required String awayTeam,
  }) {
    // Calculate expected traffic increase
    double trafficIncrease = (crowdFactor - 1.0) * 100; // Convert to percentage

    // Generate staffing recommendations
    String staffingRec = _generateStaffingRecommendation(crowdFactor);

    // Suggest specials based on match type
    List<String> specials = _suggestSpecials(isRivalry, hasChampImplications, homeTeam, awayTeam);

    // Inventory advice
    String inventoryAdvice = _generateInventoryAdvice(crowdFactor, isRivalry);

    // Marketing opportunity
    String marketingOpp = _generateMarketingOpportunity(isRivalry, hasChampImplications, homeTeam, awayTeam);

    // Revenue projection (assuming average customer spends $30 at a watch party)
    double revenueProjection = trafficIncrease * 0.01 * 30 * 50; // Estimate for 50-person baseline

    return VenueRecommendations(
      expectedTrafficIncrease: trafficIncrease,
      staffingRecommendation: staffingRec,
      suggestedSpecials: specials,
      inventoryAdvice: inventoryAdvice,
      marketingOpportunity: marketingOpp,
      revenueProjection: revenueProjection,
    );
  }

  String _generateStaffingRecommendation(double crowdFactor) {
    if (crowdFactor >= 2.5) {
      return 'Schedule 3x normal staff - expect exceptional crowds for this World Cup match';
    } else if (crowdFactor >= 2.0) {
      return 'Schedule 2x normal staff - high crowd expected for this match';
    } else if (crowdFactor >= 1.5) {
      return 'Schedule 1.5x normal staff - above average crowd expected';
    } else {
      return 'Normal staffing should be sufficient';
    }
  }

  List<String> _suggestSpecials(bool isRivalry, bool hasChampImplications, String homeTeam, String awayTeam) {
    List<String> specials = [];

    if (isRivalry) {
      specials.add('Rivalry Special: Wear your team colors for 10% off');
      specials.add('$homeTeam vs $awayTeam Watch Party Platter');
    }

    if (hasChampImplications) {
      specials.add('Knockout Round Special: Premium beer buckets & shareables');
      specials.add('World Cup Final Watch Party Package');
    }

    specials.add('Match Day Brunch - catch morning kickoffs with breakfast specials');
    specials.add('Goal Celebration Shot Special - free shot on every goal');
    specials.add('Half-Time Happy Hour - drink specials during the break');

    return specials;
  }

  String _generateInventoryAdvice(double crowdFactor, bool isRivalry) {
    List<String> advice = [];

    if (crowdFactor >= 2.0) {
      advice.add('Stock 3x normal beer & cocktail inventory');
      advice.add('Extra appetizer platters - nachos, wings, sliders');
    }

    if (isRivalry) {
      advice.add('Country flags and team scarves for decoration');
      advice.add('Premium drinks for celebration toasts');
    }

    advice.add('Consider international food specials matching the teams playing');

    return advice.join(', ');
  }

  String _generateMarketingOpportunity(bool isRivalry, bool hasChampImplications, String homeTeam, String awayTeam) {
    if (isRivalry && hasChampImplications) {
      return 'HUGE OPPORTUNITY: Historic rivalry in a knockout match - host a mega watch party, social media blitz, reservation-only VIP seating';
    } else if (isRivalry) {
      return 'Major international rivalry - promote as THE place to watch, themed decorations with both countries\' flags, fan contests';
    } else if (hasChampImplications) {
      return 'Knockout stage drama - position as "the place to watch World Cup history unfold"';
    } else {
      return 'Group stage match - promote World Cup atmosphere with international food & drink specials';
    }
  }

  /// Helper method to parse ranking from various ESPN formats
  int? _parseRank(String? rankString) {
    if (rankString == null || rankString.isEmpty) return null;
    final rankMatch = RegExp(r'\d+').firstMatch(rankString);
    return rankMatch != null ? int.tryParse(rankMatch.group(0)!) : null;
  }

  /// Calculate confidence score based on data completeness
  double _calculateConfidenceScore(Map<String, dynamic> gameData) {
    double score = 0.0;

    // Check data completeness
    if (gameData['header'] != null) score += 0.2;
    if (gameData['competitions'] != null && gameData['competitions'].isNotEmpty) score += 0.3;
    if (gameData['competitions']?[0]?['competitors'] != null) score += 0.3;
    if (gameData['situation'] != null) score += 0.1;
    if (gameData['notes'] != null) score += 0.1;

    return score;
  }

  /// Get multiple games intelligence for venue dashboard
  Future<List<GameIntelligence>> getUpcomingGamesIntelligence(List<String> gameIds) async {
    final List<GameIntelligence> intelligenceList = [];

    // Process games in parallel for better performance
    final futures = gameIds.map((gameId) => getGameIntelligence(gameId));
    final results = await Future.wait(futures);

    for (final intelligence in results) {
      if (intelligence != null) {
        intelligenceList.add(intelligence);
      }
    }

    // Sort by crowd factor (highest impact games first)
    intelligenceList.sort((a, b) => b.crowdFactor.compareTo(a.crowdFactor));

    return intelligenceList;
  }

  /// Clear cached data (useful for testing or manual refresh)
  Future<void> clearCache() async {
    if (_gameIntelligenceBox != null) {
      await _gameIntelligenceBox!.clear();
    }
  }

  /// Get cache statistics for debugging
  Map<String, dynamic> getCacheStats() {
    if (_gameIntelligenceBox == null) {
      return {
        'cached_games': 0,
        'cache_size_kb': 0,
        'status': 'not_initialized',
      };
    }

    return {
      'cached_games': _gameIntelligenceBox!.length,
      'cache_size_kb': _gameIntelligenceBox!.toMap().toString().length / 1024,
      'status': 'initialized',
    };
  }

  /// Get comprehensive game intelligence including historical matchup data
  Future<Map<String, dynamic>?> getGameIntelligenceWithHistory(String gameId) async {
    try {
      // Get basic game intelligence
      final gameIntelligence = await getGameIntelligence(gameId);
      if (gameIntelligence == null) return null;

      // Get World Cup historical context
      final historicalContext = await _historicalService.getMatchupHistory(
        gameIntelligence.homeTeam,
        gameIntelligence.awayTeam
      );

      // Generate enhanced game summary with historical context
      final gameHistorySummary = _historicalService.generateGameSummaryWithHistory(
        gameIntelligence.homeTeam,
        gameIntelligence.awayTeam,
        gameIntelligence.homeTeamRank,
        gameIntelligence.awayTeamRank,
      );

      // Get venue-specific historical insights
      final venueHistoricalInsights = _historicalService.generateVenueHistoricalInsights(
        gameIntelligence.homeTeam,
        gameIntelligence.awayTeam,
      );

      return {
        'game_intelligence': gameIntelligence,
        'historical_context': historicalContext,
        'game_summary_with_history': gameHistorySummary,
        'venue_historical_insights': venueHistoricalInsights,
        'ai_generated_content': {
          'social_media_posts': venueHistoricalInsights['social_media_content'] ?? [],
          'marketing_hooks': venueHistoricalInsights['marketing_hooks'] ?? [],
          'preparation_tips': venueHistoricalInsights['venue_preparation']?['preparation_tips'] ?? [],
        }
      };
    } catch (e) {
      return null;
    }
  }

  /// Find ESPN game ID by matching team names and date
  Future<String?> findESPNGameId({
    required String homeTeam,
    required String awayTeam,
    DateTime? gameDate,
  }) async {
    try {
      final currentGames = await getCurrentGames();

      for (final game in currentGames) {
        final competitions = game['competitions'] as List? ?? [];

        if (competitions.isNotEmpty) {
          final competitors = competitions[0]['competitors'] as List? ?? [];

          String espnHomeTeam = '';
          String espnAwayTeam = '';

          for (var team in competitors) {
            final teamData = team['team'] ?? {};
            final isHome = team['homeAway'] == 'home';
            final teamName = teamData['displayName'] ?? '';

            if (isHome) {
              espnHomeTeam = teamName;
            } else {
              espnAwayTeam = teamName;
            }
          }

          // Check if teams match (case insensitive, partial matching)
          if (_teamsMatch(homeTeam, espnHomeTeam) && _teamsMatch(awayTeam, espnAwayTeam)) {
            // If date is provided, check if it's close (within 1 day)
            if (gameDate != null) {
              final espnDate = DateTime.tryParse(game['date'] ?? '');
              if (espnDate != null) {
                final difference = gameDate.difference(espnDate).inDays.abs();
                if (difference <= 1) {
                  return game['id']?.toString();
                }
              }
            } else {
              // No date provided, just match by teams
              return game['id']?.toString();
            }
          }
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Helper method to check if team names match (handles common variations)
  /// Supports international team name variations (e.g., "USA" vs "United States")
  bool _teamsMatch(String team1, String team2) {
    if (team1.isEmpty || team2.isEmpty) return false;

    // Remove common suffixes and normalize
    final normalized1 = _normalizeTeamName(team1);
    final normalized2 = _normalizeTeamName(team2);

    // Exact match
    if (normalized1 == normalized2) return true;

    // Check if one contains the other
    if (normalized1.contains(normalized2) || normalized2.contains(normalized1)) return true;

    // Check common international team name variations
    final abbreviations = {
      'united states': 'usa',
      'united states of america': 'usa',
      'korea republic': 'south korea',
      'republic of korea': 'south korea',
      'ir iran': 'iran',
      'islamic republic of iran': 'iran',
      'cote divoire': 'ivory coast',
      'congo dr': 'dr congo',
      'democratic republic of the congo': 'dr congo',
      'czech republic': 'czechia',
      'kingdom of saudi arabia': 'saudi arabia',
      'peoples republic of china': 'china',
      'china pr': 'china',
      'chinese taipei': 'taiwan',
      'bosnia and herzegovina': 'bosnia',
      'trinidad and tobago': 'trinidad',
      'antigua and barbuda': 'antigua',
      'saint kitts and nevis': 'st kitts',
      'new zealand': 'all whites',
      'costa rica': 'los ticos',
      'el salvador': 'la selecta',
    };

    for (final entry in abbreviations.entries) {
      if ((normalized1.contains(entry.key) && normalized2.contains(entry.value)) ||
          (normalized1.contains(entry.value) && normalized2.contains(entry.key))) {
        return true;
      }
    }

    return false;
  }

  /// Normalize team name for matching
  String _normalizeTeamName(String teamName) {
    return teamName.toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '') // Remove punctuation
        .replaceAll(RegExp(r'\s+'), ' ')     // Normalize whitespace
        .trim();
  }

  /// Get opening round matches with full historical context
  Future<List<Map<String, dynamic>>> getWeek1GamesWithHistory() async {
    try {
      final games = await getCurrentGames();
      final enhancedGames = <Map<String, dynamic>>[];

      for (final game in games.take(10)) { // Limit to first 10 for performance
        final gameId = game['id']?.toString();
        if (gameId != null) {
          final gameWithHistory = await getGameIntelligenceWithHistory(gameId);
          if (gameWithHistory != null) {
            enhancedGames.add({
              'raw_game_data': game,
              'enhanced_intelligence': gameWithHistory,
            });
          }
        }
      }

      return enhancedGames;
    } catch (e) {
      return [];
    }
  }
}

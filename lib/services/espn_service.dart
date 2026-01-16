import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pregame_world_cup/core/entities/game_intelligence.dart';
import 'package:pregame_world_cup/features/schedule/domain/entities/game_schedule.dart';
import 'package:hive/hive.dart';
import 'espn_historical_service.dart';

/// Enhanced sports service that integrates with ESPN API
/// for comprehensive game intelligence and venue recommendations
class ESPNService {
  static const String _baseUrl = 'https://site.api.espn.com/apis/site/v2/sports';
  
  final Dio _dio;
  Box<GameIntelligence>? _gameIntelligenceBox;
  late ESPNHistoricalService _historicalService;
  
  // SEC Teams for rivalry detection and enhanced analysis
  static const Map<String, List<String>> _secRivalries = {
    'Alabama': ['Auburn', 'Tennessee', 'LSU'],
    'Auburn': ['Alabama', 'Georgia'],
    'Florida': ['Georgia', 'FSU', 'Tennessee'],
    'Georgia': ['Florida', 'Auburn', 'Tennessee'],
    'Kentucky': ['Louisville', 'Tennessee'],
    'LSU': ['Alabama', 'Arkansas', 'Ole Miss'],
    'Mississippi State': ['Ole Miss'],
    'Ole Miss': ['Mississippi State', 'LSU'],
    'Missouri': ['Arkansas'],
    'South Carolina': ['Clemson'],
    'Tennessee': ['Alabama', 'Georgia', 'Kentucky', 'Vanderbilt'],
    'Texas A&M': ['Texas', 'LSU'],
    'Arkansas': ['LSU', 'Missouri'],
    'Vanderbilt': ['Tennessee'],
  };

  ESPNService({Dio? dio}) : _dio = dio ?? Dio() {
    _historicalService = ESPNHistoricalService();
    // Don't initialize immediately - do it lazily when needed
  }

  Future<void> _initializeService() async {
    if (_gameIntelligenceBox != null) return; // Already initialized
    
    try {
      _gameIntelligenceBox = await Hive.openBox<GameIntelligence>('game_intelligence');
              debugPrint('ESPN Service initialized successfully');
    } catch (e) {
              debugPrint('Error initializing ESPN Service: $e');
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

      // Fetch fresh data from ESPN
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
      debugPrint('Error getting game intelligence: $e');
      return null;
    }
  }

  /// Fetch raw game data from ESPN API
  Future<Map<String, dynamic>?> _fetchESPNGameData(String gameId) async {
    try {
      // ESPN uses different endpoints for different sports
      // Starting with college football - can expand to basketball, etc.
      final response = await _dio.get(
        '$_baseUrl/football/college-football/summary',
        queryParameters: {
          'event': gameId,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching ESPN data: $e');
      return null;
    }
  }

  /// Test method to fetch current college football games
  Future<List<Map<String, dynamic>>> getCurrentGames() async {
    try {
      final response = await _dio.get(
        '$_baseUrl/football/college-football/scoreboard',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final events = data['events'] as List? ?? [];
        
        debugPrint('✅ ESPN API Connected! Found ${events.length} games');
        return events.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      debugPrint('❌ ESPN API Error: $e');
      return [];
    }
  }

  /// Fetch 2025 college football schedule from ESPN API
  /// This method gets the complete 2025 season schedule with real dates and times
  Future<List<GameSchedule>> get2025Schedule({int limit = 100}) async {
    try {
      debugPrint('🏈 ESPN: Fetching 2025 college football schedule...');
      
      final scheduleGames = <GameSchedule>[];
      final now = DateTime.now();
      
      // Get the current date or start from August 2025 if we're before the season
      final startDate = now.isAfter(DateTime(2025, 8, 1)) ? now : DateTime(2025, 8, 1);
      final endDate = DateTime(2026, 1, 31); // End of 2025 season
      
      // ESPN API date format: YYYYMMDD
      final startDateStr = _formatDateForESPN(startDate);
      final endDateStr = _formatDateForESPN(endDate);
      
      debugPrint('🗓️ ESPN: Requesting games from $startDateStr to $endDateStr');
      
      final response = await _dio.get(
        '$_baseUrl/football/college-football/scoreboard',
        queryParameters: {
          'dates': '$startDateStr-$endDateStr',
          'limit': limit.toString(),
          'groups': '80', // FBS College Football
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final events = data['events'] as List? ?? [];
        
        debugPrint('📅 ESPN: Found ${events.length} total events');
        
        for (final event in events) {
          try {
            final gameSchedule = _parseESPNEventToGameSchedule(event);
            if (gameSchedule != null) {
              scheduleGames.add(gameSchedule);
            }
          } catch (e) {
            debugPrint('⚠️ ESPN: Error parsing event: $e');
          }
        }
        
        // Sort by date
        scheduleGames.sort((a, b) {
          final aDate = a.dateTime ?? DateTime(1970);
          final bDate = b.dateTime ?? DateTime(1970);
          return aDate.compareTo(bDate);
        });
        
        debugPrint('✅ ESPN: Successfully parsed ${scheduleGames.length} games for 2025 season');
        debugPrint('🎯 ESPN: First game: ${scheduleGames.isNotEmpty ? '${scheduleGames.first.awayTeamName} vs ${scheduleGames.first.homeTeamName} on ${scheduleGames.first.dateTime}' : 'No games found'}');
        
        return scheduleGames.take(limit).toList();
      } else {
        debugPrint('❌ ESPN: API returned status ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('❌ ESPN: Error fetching 2025 schedule: $e');
      return [];
    }
  }

  /// Get upcoming games from ESPN API (next 2 weeks)
  Future<List<GameSchedule>> getUpcomingGames({int limit = 10}) async {
    try {
      debugPrint('🏈 ESPN: Fetching upcoming games...');
      
      final now = DateTime.now();
      final twoWeeksFromNow = now.add(const Duration(days: 14));
      
      final startDateStr = _formatDateForESPN(now);
      final endDateStr = _formatDateForESPN(twoWeeksFromNow);
      
      final response = await _dio.get(
        '$_baseUrl/football/college-football/scoreboard',
        queryParameters: {
          'dates': '$startDateStr-$endDateStr',
          'limit': limit.toString(),
          'groups': '80', // FBS College Football
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
            debugPrint('⚠️ ESPN: Error parsing upcoming event: $e');
          }
        }
        
        // Sort by date and limit results
        upcomingGames.sort((a, b) {
          final aDate = a.dateTime ?? DateTime(1970);
          final bDate = b.dateTime ?? DateTime(1970);
          return aDate.compareTo(bDate);
        });
        
        debugPrint('✅ ESPN: Found ${upcomingGames.length} upcoming games');
        return upcomingGames.take(limit).toList();
      }
      
      return [];
    } catch (e) {
      debugPrint('❌ ESPN: Error fetching upcoming games: $e');
      return [];
    }
  }

  /// Get college football schedule for a specific year (supports 2023, 2024, 2025)
  /// Returns complete season data including historical scores for past years
  Future<List<GameSchedule>> getScheduleForYear(int year, {int limit = 2000}) async {
    try {
      debugPrint('🏈 ESPN: Fetching $year college football schedule...');
      
      // For historical years, get the full season
      DateTime startDate;
      DateTime endDate;
      
      if (year == 2023) {
        startDate = DateTime(2023, 8, 1);  // Season starts in August
        endDate = DateTime(2024, 1, 31);   // Includes bowl games and championship
      } else if (year == 2024) {
        startDate = DateTime(2024, 7, 1);  // Start earlier in case of summer games
        endDate = DateTime(2025, 2, 28);   // End later to catch any late bowl games
        debugPrint('🏈 ESPN: 2024 expanded date range: ${_formatDateForESPN(startDate)} to ${_formatDateForESPN(endDate)}');
      } else if (year == 2025) {
        startDate = DateTime(2025, 8, 1);
        endDate = DateTime(2026, 1, 31);
      } else {
        debugPrint('❌ ESPN: Unsupported year $year. Supported years: 2023, 2024, 2025');
        return [];
      }
      
      final startDateStr = _formatDateForESPN(startDate);
      final endDateStr = _formatDateForESPN(endDate);
      
              final response = await _dio.get(
        '$_baseUrl/football/college-football/scoreboard',
        queryParameters: {
          'dates': '$startDateStr-$endDateStr',
          'limit': limit.toString(),
          'groups': '80', // FBS College Football
        },
      );
      
      debugPrint('🏈 ESPN: API request URL: $_baseUrl/football/college-football/scoreboard?dates=$startDateStr-$endDateStr&limit=$limit&groups=80');

      if (response.statusCode == 200) {
        final data = response.data;
        final events = data['events'] as List? ?? [];
        
        debugPrint('✅ ESPN: Found ${events.length} events for $year season');
        
        final games = <GameSchedule>[];
        for (final event in events) {
          final game = _parseESPNEventToGameScheduleWithYear(event, year);
          if (game != null) {
            games.add(game);
          }
        }
        
        debugPrint('✅ ESPN: Successfully parsed ${games.length} games for $year season');
        
        // Sort by date for better user experience
        games.sort((a, b) {
          if (a.dateTime == null && b.dateTime == null) return 0;
          if (a.dateTime == null) return 1;
          if (b.dateTime == null) return -1;
          return a.dateTime!.compareTo(b.dateTime!);
        });
        
        return games;
      } else {
        debugPrint('❌ ESPN: HTTP ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('❌ ESPN: Error fetching $year schedule: $e');
      return [];
    }
  }

  /// Parse ESPN event data to GameSchedule object
  GameSchedule? _parseESPNEventToGameSchedule(Map<String, dynamic> event) {
    try {
      final eventId = event['id']?.toString() ?? '';
      final name = event['name'] ?? '';
      final shortName = event['shortName'] ?? '';
      final date = event['date'] ?? '';
      
      // Parse teams
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
        final logos = team['logos'] as List? ?? [];
        final logoUrl = logos.isNotEmpty ? logos[0]['href'] : null;
        
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
      
      // Parse venue information
      final venue = competition['venue'] as Map<String, dynamic>? ?? {};
      final venueName = venue['fullName'] ?? venue['name'] ?? '';
      final venueCity = venue['address']?['city'] ?? '';
      final venueState = venue['address']?['state'] ?? '';
      
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
        debugPrint('⚠️ ESPN: Error parsing date "$date": $e');
      }
      
      // Create Stadium object if venue info exists
      Stadium? stadium;
      if (venueName.isNotEmpty) {
        stadium = Stadium(
          stadiumId: venue['id'] != null ? int.tryParse(venue['id'].toString()) : null,
          name: venueName,
          city: venueCity,
          state: venueState,
          capacity: null, // ESPN doesn't always provide capacity
          yearOpened: null,
          geoLat: null, // Would need additional API call for coordinates
          geoLong: null,
          team: homeTeamName,
        );
      }
      
      return GameSchedule(
        gameId: 'espn_$eventId',
        season: '2025', // We're specifically fetching 2025 data
        week: null, // ESPN doesn't provide week number in this format
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
      debugPrint('❌ ESPN: Error parsing event data: $e');
      return null;
    }
  }

  /// Enhanced parser for historical data with scores and game status
  GameSchedule? _parseESPNEventToGameScheduleWithYear(Map<String, dynamic> event, int year) {
    try {
      final eventId = event['id']?.toString() ?? '';
      final name = event['name'] ?? '';
      final shortName = event['shortName'] ?? '';
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
      bool? awayWinner;
      bool? homeWinner;
      
      for (final competitor in competitors) {
        final team = competitor['team'] as Map<String, dynamic>? ?? {};
        final homeAway = competitor['homeAway'] as String? ?? '';
        final teamName = team['displayName'] ?? team['name'] ?? '';
        final teamId = int.tryParse(team['id']?.toString() ?? '');
        final logos = team['logos'] as List? ?? [];
        final logoUrl = logos.isNotEmpty ? logos[0]['href'] : null;
        
        // Parse score data
        final score = int.tryParse(competitor['score']?.toString() ?? '');
        final winner = competitor['winner'] == true;
        
        if (homeAway == 'home') {
          homeTeamName = teamName;
          homeTeamId = teamId;
          homeTeamLogoUrl = logoUrl;
          homeScore = score;
          homeWinner = winner;
        } else {
          awayTeamName = teamName;
          awayTeamId = teamId;
          awayTeamLogoUrl = logoUrl;
          awayScore = score;
          awayWinner = winner;
        }
      }
      
      // Parse game status
      final status = competition['status'] as Map<String, dynamic>? ?? {};
      final statusType = status['type'] as Map<String, dynamic>? ?? {};
      final gameStatus = statusType['name'] ?? 'Scheduled';
      final gameState = statusType['state'] ?? 'pre';
      final statusDetail = status['type']?['detail'] ?? '';
      
      // Parse venue information
      final venue = competition['venue'] as Map<String, dynamic>? ?? {};
      final venueName = venue['fullName'] ?? venue['name'] ?? '';
      final venueCity = venue['address']?['city'] ?? '';
      final venueState = venue['address']?['state'] ?? '';
      
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
        debugPrint('⚠️ ESPN: Error parsing date "$date": $e');
      }
      
      // Parse week number if available
      final seasonType = competition['season']?['type'] ?? 2; // Regular season = 2
      final week = competition['week']?['number'];
      
      // Create Stadium object if venue info exists
      Stadium? stadium;
      if (venueName.isNotEmpty) {
        stadium = Stadium(
          stadiumId: venue['id'] != null ? int.tryParse(venue['id'].toString()) : null,
          name: venueName,
          city: venueCity,
          state: venueState,
          capacity: null, // ESPN doesn't always provide capacity
          yearOpened: null,
          geoLat: null, // Would need additional API call for coordinates
          geoLong: null,
          team: homeTeamName,
        );
      }
      
      return GameSchedule(
        gameId: 'espn_$eventId',
        season: year.toString(),
        week: week,
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
        // Use existing fields for game state
        isLive: gameState == 'in',
        period: statusDetail.isNotEmpty ? statusDetail : null,
        lastScoreUpdate: gameState == 'post' ? gameDateTime : null,
      );
    } catch (e) {
      debugPrint('❌ ESPN: Error parsing historical event data: $e');
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

  /// Analyze ESPN game data to create actionable intelligence
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

    // Calculate crowd factor based on multiple variables
    final crowdFactor = _calculateCrowdFactor(
      homeRank: homeRank,
      awayRank: awayRank,
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      gameData: espnData,
    );

    // Detect rivalry games
    final isRivalry = _isRivalryGame(homeTeam, awayTeam);

    // Analyze championship implications
    final hasChampImplications = _hasChampionshipImplications(espnData);

    // Extract broadcast information
    final broadcast = _extractBroadcastInfo(espnData);

    // Generate venue recommendations
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

  /// Calculate crowd factor based on team rankings and game importance
  double _calculateCrowdFactor(
      {int? homeRank, int? awayRank, required String homeTeam, required String awayTeam, required Map<String, dynamic> gameData}) {
    double factor = 1.0; // Base factor

    // Team rankings impact (higher ranked = more interest)
    if (homeRank != null && homeRank <= 25) {
      factor += (26 - homeRank) * 0.02; // Up to +0.5 for #1 team
    }
    if (awayRank != null && awayRank <= 25) {
      factor += (26 - awayRank) * 0.02; // Up to +0.5 for #1 team
    }

    // Both teams ranked in top 10
    if ((homeRank != null && homeRank <= 10) && (awayRank != null && awayRank <= 10)) {
      factor += 0.4; // Top 10 matchup bonus
    }

    // Rivalry game bonus
    if (_isRivalryGame(homeTeam, awayTeam)) {
      factor += 0.6; // Major rivalry bonus
    }

    // Championship implications
    if (_hasChampionshipImplications(gameData)) {
      factor += 0.5;
    }

    // Weekend vs weekday (assuming Saturday games are bigger)
    final gameTime = DateTime.tryParse(gameData['header']?['timeValid'] ?? '');
    if (gameTime != null && gameTime.weekday == DateTime.saturday) {
      factor += 0.2;
    }

    // Cap the maximum crowd factor at 3.0 (300% of normal)
    return factor > 3.0 ? 3.0 : factor;
  }

  /// Check if this is a rivalry game
  bool _isRivalryGame(String homeTeam, String awayTeam) {
    final homeRivals = _secRivalries[homeTeam] ?? [];
    final awayRivals = _secRivalries[awayTeam] ?? [];
    
    return homeRivals.contains(awayTeam) || awayRivals.contains(homeTeam);
  }

  /// Analyze if game has championship implications
  bool _hasChampionshipImplications(Map<String, dynamic> gameData) {
    // Look for keywords in game description or notes
    final notes = gameData['notes']?.toString().toLowerCase() ?? '';
    final situation = gameData['situation']?.toString().toLowerCase() ?? '';
    
    return notes.contains('championship') ||
           notes.contains('playoff') ||
           notes.contains('division') ||
           situation.contains('sec championship') ||
           situation.contains('playoff implications');
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

  /// Estimate TV audience based on factors
  double _estimateTvAudience(double crowdFactor, bool isRivalry, String? network) {
    double baseAudience = 2.5; // Million viewers baseline for college football
    
    // Network influence
    switch (network?.toUpperCase()) {
      case 'ESPN':
      case 'ABC':
        baseAudience = 4.0;
        break;
      case 'CBS':
        baseAudience = 5.2; // CBS SEC games typically get higher ratings
        break;
      case 'FOX':
        baseAudience = 3.8;
        break;
      default:
        baseAudience = 2.5;
    }
    
    // Apply crowd factor and rivalry bonus
    double estimatedAudience = baseAudience * crowdFactor;
    if (isRivalry) {
      estimatedAudience *= 1.3; // Rivalry games get 30% more viewers
    }
    
    return estimatedAudience;
  }

  /// Extract key storylines for marketing
  List<String> _extractKeyStorylines(Map<String, dynamic> gameData, bool isRivalry, bool hasChampImplications) {
    List<String> storylines = [];
    
    if (isRivalry) {
      storylines.add('Historic Rivalry Matchup');
    }
    
    if (hasChampImplications) {
      storylines.add('Championship Implications');
    }
    
    // Add more storylines based on ESPN data analysis
    final situation = gameData['situation']?.toString() ?? '';
    if (situation.contains('undefeated')) {
      storylines.add('Undefeated Team Battle');
    }
    
    return storylines;
  }

  /// Extract relevant team statistics
  Map<String, dynamic> _extractTeamStats(Map<String, dynamic> gameData) {
    // Extract wins, losses, rankings, recent performance
    Map<String, dynamic> stats = {};
    
    final competitions = gameData['competitions'] ?? [];
    if (competitions.isNotEmpty) {
      final teams = competitions[0]['competitors'] ?? [];
      for (var team in teams) {
        final teamData = team['team'] ?? {};
        final record = team['records']?[0] ?? {};
        final teamName = teamData['displayName'] ?? '';
        
        stats[teamName] = {
          'wins': record['wins'] ?? 0,
          'losses': record['losses'] ?? 0,
          'rank': _parseRank(team['curatedRank']?.toString()),
          'record_summary': record['displayValue'] ?? 'N/A',
        };
      }
    }
    
    return stats;
  }

  /// Generate specific venue recommendations based on game analysis
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
    
    // Suggest specials based on game type
    List<String> specials = _suggestSpecials(isRivalry, hasChampImplications, homeTeam, awayTeam);
    
    // Inventory advice
    String inventoryAdvice = _generateInventoryAdvice(crowdFactor, isRivalry);
    
    // Marketing opportunity
    String marketingOpp = _generateMarketingOpportunity(isRivalry, hasChampImplications, homeTeam, awayTeam);
    
    // Revenue projection (assuming average customer spends $25)
    double revenueProjection = trafficIncrease * 0.01 * 25 * 50; // Estimate for 50-person baseline
    
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
      return 'Schedule 3x normal staff - expect exceptional crowds';
    } else if (crowdFactor >= 2.0) {
      return 'Schedule 2x normal staff - high crowd expected';
    } else if (crowdFactor >= 1.5) {
      return 'Schedule 1.5x normal staff - above average crowd';
    } else {
      return 'Normal staffing should be sufficient';
    }
  }

  List<String> _suggestSpecials(bool isRivalry, bool hasChampImplications, String homeTeam, String awayTeam) {
    List<String> specials = [];
    
    if (isRivalry) {
      specials.add('Rivalry Special: Buy team colors pitcher, get appetizer half off');
      specials.add('${homeTeam} vs ${awayTeam} Wings Challenge');
    }
    
    if (hasChampImplications) {
      specials.add('Championship Run Special: Premium beer buckets');
      specials.add('Playoff Push Platter - premium appetizer combo');
    }
    
    specials.add('Game Day Breakfast - morning crowd capture');
    specials.add('Victory Shot Special - post-game celebration');
    
    return specials;
  }

  String _generateInventoryAdvice(double crowdFactor, bool isRivalry) {
    List<String> advice = [];
    
    if (crowdFactor >= 2.0) {
      advice.add('Stock 3x normal beer inventory');
      advice.add('Extra wings and nachos - high-margin items');
    }
    
    if (isRivalry) {
      advice.add('Team-themed items and decorations');
      advice.add('Premium alcohol for celebration/commiseration');
    }
    
    return advice.join(', ');
  }

  String _generateMarketingOpportunity(bool isRivalry, bool hasChampImplications, String homeTeam, String awayTeam) {
    if (isRivalry && hasChampImplications) {
      return 'HUGE OPPORTUNITY: Rivalry game with championship implications - livestream atmosphere, social media blitz, reservation-only seating';
    } else if (isRivalry) {
      return 'Major rivalry game - livestream crowd energy, themed decorations, fan contests';
    } else if (hasChampImplications) {
      return 'Championship implications - position as "the place to watch history"';
    } else {
      return 'Standard game day promotions with social media updates';
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

      // Get historical context
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
      debugPrint('Error getting game intelligence with history: $e');
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
                  debugPrint('✅ Found ESPN game match: ${game['id']} for $awayTeam @ $homeTeam');
                  return game['id']?.toString();
                }
              }
            } else {
              // No date provided, just match by teams
              debugPrint('✅ Found ESPN game match: ${game['id']} for $awayTeam @ $homeTeam');
              return game['id']?.toString();
            }
          }
        }
      }
      
      debugPrint('❌ No ESPN game found for $awayTeam @ $homeTeam');
      return null;
    } catch (e) {
      debugPrint('Error finding ESPN game ID: $e');
      return null;
    }
  }

  /// Helper method to check if team names match (handles common variations)
  bool _teamsMatch(String team1, String team2) {
    if (team1.isEmpty || team2.isEmpty) return false;
    
    // Remove common suffixes and normalize
    final normalized1 = _normalizeTeamName(team1);
    final normalized2 = _normalizeTeamName(team2);
    
    // Exact match
    if (normalized1 == normalized2) return true;
    
    // Check if one contains the other (for cases like "Alabama" vs "Alabama Crimson Tide")
    if (normalized1.contains(normalized2) || normalized2.contains(normalized1)) return true;
    
    // Check common abbreviations
    final abbreviations = {
      'university of alabama': 'alabama',
      'university of georgia': 'georgia', 
      'university of florida': 'florida',
      'university of tennessee': 'tennessee',
      'university of kentucky': 'kentucky',
      'university of mississippi': 'ole miss',
      'university of south carolina': 'south carolina',
      'louisiana state university': 'lsu',
      'university of missouri': 'missouri',
      'university of arkansas': 'arkansas',
      'texas a&m university': 'texas a&m',
      'mississippi state university': 'mississippi state',
      'vanderbilt university': 'vanderbilt',
      'university of texas': 'texas',
      'oklahoma university': 'oklahoma',
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

  /// Get Week 1 games with full historical context
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
      debugPrint('Error getting Week 1 games with history: $e');
      return [];
    }
  }
} 

import 'package:dio/dio.dart';
import '../../../../config/api_keys.dart';
import '../../domain/entities/world_cup_match.dart';
import '../../domain/entities/national_team.dart';
import '../../../../core/services/logging_service.dart';
import '../../../../core/services/cache_service.dart';

/// Abstract interface for World Cup schedule data source
abstract class WorldCupScheduleDataSource {
  Future<List<WorldCupMatch>> fetchAllMatches();
  Future<List<WorldCupMatch>> fetchMatchesByDate(DateTime date);
  Future<List<WorldCupMatch>> fetchUpcomingMatches({int daysAhead = 7});
  Future<List<NationalTeam>> fetchAllTeams();
  Future<List<WorldCupMatch>> fetchTeamMatches(String teamCode);
  Future<Map<String, dynamic>> fetchStandings();
}

/// Implementation of World Cup schedule data source using SportsData.io Soccer API v4
/// with smart caching to reduce API calls by 80-90%
class WorldCupScheduleDataSourceImpl implements WorldCupScheduleDataSource {
  final Dio _dio;
  // Updated to Soccer API v4 for FIFA World Cup
  final String _baseUrl = 'https://api.sportsdata.io/v4/soccer/scores/json';
  final String _competition = 'FIFAWC'; // FIFA World Cup competition code

  // Cache durations optimized for different data types
  static const Duration _allMatchesCacheDuration = Duration(hours: 24); // Full schedule
  static const Duration _upcomingMatchesCacheDuration = Duration(hours: 6); // Upcoming matches
  static const Duration _teamsCacheDuration = Duration(hours: 48); // Teams data (static)
  static const Duration _standingsCacheDuration = Duration(hours: 12); // Group standings

  WorldCupScheduleDataSourceImpl({required Dio dio}) : _dio = dio;

  /// Fetch all World Cup matches with smart caching
  @override
  Future<List<WorldCupMatch>> fetchAllMatches() async {
    final cacheKey = 'world_cup_all_matches_$_competition';

    try {
      // 1. Check cache first
      final cachedMatches = await CacheService.instance.get<List<dynamic>>(cacheKey);
      if (cachedMatches != null) {
        LoggingService.info('📦 Cache HIT for all matches - Saved API call!', tag: 'WorldCupSchedule');
        return cachedMatches.map((matchJson) => _parseMatch(matchJson)).toList();
      }

      LoggingService.info('🌐 Cache MISS for all matches - Making API call', tag: 'WorldCupSchedule');

      // 2. Make API call if cache miss
      final url = '$_baseUrl/Games/$_competition';

      final response = await _dio.get(
        url,
        queryParameters: {
          'key': ApiKeys.sportsDataIo,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> matchList = response.data ?? [];

        if (matchList.isEmpty) {
          LoggingService.warning('No World Cup matches found', tag: 'WorldCupSchedule');
          await CacheService.instance.set(cacheKey, [], duration: _allMatchesCacheDuration);
          return [];
        }

        // 3. Cache the raw API response
        await CacheService.instance.set(cacheKey, matchList, duration: _allMatchesCacheDuration);

        final matches = matchList.map((matchJson) {
          try {
            return _parseMatch(matchJson);
          } catch (parseError) {
            LoggingService.error('Error parsing match: $parseError', tag: 'WorldCupSchedule');
            return null;
          }
        }).where((match) => match != null).cast<WorldCupMatch>().toList();

        LoggingService.info('✅ Cached ${matches.length} World Cup matches', tag: 'WorldCupSchedule');
        return matches;
      } else {
        throw Exception('Failed to load World Cup matches: ${response.statusCode}');
      }
    } catch (e) {
      LoggingService.error('Error fetching all World Cup matches: $e', tag: 'WorldCupSchedule');
      rethrow;
    }
  }

  /// Fetch matches by specific date
  @override
  Future<List<WorldCupMatch>> fetchMatchesByDate(DateTime date) async {
    final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final cacheKey = 'world_cup_matches_$dateString';

    try {
      final cachedMatches = await CacheService.instance.get<List<dynamic>>(cacheKey);
      if (cachedMatches != null) {
        LoggingService.info('📦 Cache HIT for date $dateString', tag: 'WorldCupSchedule');
        return cachedMatches.map((matchJson) => _parseMatch(matchJson)).toList();
      }

      final url = '$_baseUrl/GamesByDate/$_competition/$dateString';

      final response = await _dio.get(
        url,
        queryParameters: {
          'key': ApiKeys.sportsDataIo,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> matchList = response.data ?? [];

        await CacheService.instance.set(cacheKey, matchList, duration: _upcomingMatchesCacheDuration);

        return matchList.map((matchJson) => _parseMatch(matchJson)).toList();
      } else {
        throw Exception('Failed to load matches for $dateString: ${response.statusCode}');
      }
    } catch (e) {
      LoggingService.error('Error fetching matches for $dateString: $e', tag: 'WorldCupSchedule');
      rethrow;
    }
  }

  /// Fetch upcoming World Cup matches
  @override
  Future<List<WorldCupMatch>> fetchUpcomingMatches({int daysAhead = 7}) async {
    try {
      // Get all matches and filter for upcoming ones
      final allMatches = await fetchAllMatches();
      final now = DateTime.now();
      final futureDate = now.add(Duration(days: daysAhead));

      final upcomingMatches = allMatches.where((match) {
        if (match.dateTimeUtc == null) return false;
        return match.dateTimeUtc!.isAfter(now) && match.dateTimeUtc!.isBefore(futureDate);
      }).toList();

      // Sort by date
      upcomingMatches.sort((a, b) => a.dateTimeUtc!.compareTo(b.dateTimeUtc!));

      LoggingService.info('Found ${upcomingMatches.length} upcoming matches', tag: 'WorldCupSchedule');
      return upcomingMatches;
    } catch (e) {
      LoggingService.error('Error fetching upcoming matches: $e', tag: 'WorldCupSchedule');
      rethrow;
    }
  }

  /// Fetch all national teams in the World Cup
  @override
  Future<List<NationalTeam>> fetchAllTeams() async {
    final cacheKey = 'world_cup_teams_$_competition';

    try {
      final cachedTeams = await CacheService.instance.get<List<dynamic>>(cacheKey);
      if (cachedTeams != null) {
        LoggingService.info('📦 Cache HIT for teams', tag: 'WorldCupSchedule');
        return cachedTeams.map((teamJson) => NationalTeam.fromApi(teamJson)).toList();
      }

      final url = '$_baseUrl/Teams/$_competition';

      final response = await _dio.get(
        url,
        queryParameters: {
          'key': ApiKeys.sportsDataIo,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> teamList = response.data ?? [];

        await CacheService.instance.set(cacheKey, teamList, duration: _teamsCacheDuration);

        final teams = teamList.map((teamJson) => NationalTeam.fromApi(teamJson)).toList();
        LoggingService.info('✅ Fetched ${teams.length} national teams', tag: 'WorldCupSchedule');
        return teams;
      } else {
        throw Exception('Failed to load teams: ${response.statusCode}');
      }
    } catch (e) {
      LoggingService.error('Error fetching teams: $e', tag: 'WorldCupSchedule');
      rethrow;
    }
  }

  /// Fetch all matches for a specific team
  @override
  Future<List<WorldCupMatch>> fetchTeamMatches(String teamCode) async {
    try {
      final allMatches = await fetchAllMatches();
      final upperTeamCode = teamCode.toUpperCase();

      final teamMatches = allMatches.where((match) {
        return match.homeTeamCode?.toUpperCase() == upperTeamCode ||
               match.awayTeamCode?.toUpperCase() == upperTeamCode;
      }).toList();

      LoggingService.info('Found ${teamMatches.length} matches for team $teamCode', tag: 'WorldCupSchedule');
      return teamMatches;
    } catch (e) {
      LoggingService.error('Error fetching team matches for $teamCode: $e', tag: 'WorldCupSchedule');
      rethrow;
    }
  }

  /// Fetch group standings
  @override
  Future<Map<String, dynamic>> fetchStandings() async {
    final cacheKey = 'world_cup_standings_$_competition';

    try {
      final cachedStandings = await CacheService.instance.get<Map<String, dynamic>>(cacheKey);
      if (cachedStandings != null) {
        LoggingService.info('📦 Cache HIT for standings', tag: 'WorldCupSchedule');
        return cachedStandings;
      }

      final url = '$_baseUrl/Standings/$_competition';

      final response = await _dio.get(
        url,
        queryParameters: {
          'key': ApiKeys.sportsDataIo,
        },
      );

      if (response.statusCode == 200) {
        final standings = response.data as Map<String, dynamic>;

        await CacheService.instance.set(cacheKey, standings, duration: _standingsCacheDuration);

        LoggingService.info('✅ Fetched group standings', tag: 'WorldCupSchedule');
        return standings;
      } else {
        throw Exception('Failed to load standings: ${response.statusCode}');
      }
    } catch (e) {
      LoggingService.error('Error fetching standings: $e', tag: 'WorldCupSchedule');
      rethrow;
    }
  }

  /// Helper method to parse match data from API response
  WorldCupMatch _parseMatch(Map<String, dynamic> json) {
    // Map SportsData.io Soccer API fields to WorldCupMatch entity
    return WorldCupMatch(
      matchId: json['GameId']?.toString() ?? '',
      matchNumber: json['MatchNumber'] ?? json['RoundId'] ?? 0,
      stage: _parseMatchStage(json['RoundId'], json['Group']),
      group: json['Group'],
      homeTeamCode: json['HomeTeamKey'],
      homeTeamName: json['HomeTeamName'] ?? 'TBD',
      homeTeamFlagUrl: json['HomeTeamWikipediaLogoUrl'],
      awayTeamCode: json['AwayTeamKey'],
      awayTeamName: json['AwayTeamName'] ?? 'TBD',
      awayTeamFlagUrl: json['AwayTeamWikipediaLogoUrl'],
      dateTime: json['DateTime'] != null ? DateTime.tryParse(json['DateTime']) : null,
      dateTimeUtc: json['DateTimeUTC'] != null ? DateTime.tryParse(json['DateTimeUTC']) : null,
      venueId: json['VenueId']?.toString(),
      status: _parseMatchStatus(json['Status']),
      homeScore: json['HomeTeamScore'],
      awayScore: json['AwayTeamScore'],
      updatedAt: DateTime.now(),
    );
  }

  /// Parse match stage from round ID and group
  MatchStage _parseMatchStage(int? roundId, String? group) {
    if (group != null && group.isNotEmpty) {
      return MatchStage.groupStage;
    }
    // This is simplified - you may need to map roundId to actual stages
    // based on SportsData.io's round numbering for World Cup
    return MatchStage.groupStage;
  }

  /// Parse match status from API string
  MatchStatus _parseMatchStatus(String? status) {
    if (status == null) return MatchStatus.scheduled;

    switch (status.toLowerCase()) {
      case 'scheduled':
      case 'not started':
        return MatchStatus.scheduled;
      case 'inprogress':
      case 'in progress':
      case 'live':
        return MatchStatus.inProgress;
      case 'halftime':
      case 'half time':
        return MatchStatus.halfTime;
      case 'final':
      case 'full time':
      case 'complete':
      case 'completed':
        return MatchStatus.completed;
      case 'postponed':
        return MatchStatus.postponed;
      case 'cancelled':
      case 'canceled':
        return MatchStatus.cancelled;
      default:
        return MatchStatus.scheduled;
    }
  }
}

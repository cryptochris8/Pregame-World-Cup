import 'package:dio/dio.dart';
import '../../domain/entities/game_schedule.dart';
import '../../../../core/services/logging_service.dart';

/// Data source for fetching live soccer scores and match updates
/// for FIFA World Cup 2026 matches via SportsData.io Soccer v4 API.
abstract class LiveScoresDataSource {
  /// Fetch live scores for all current matches
  Future<List<GameSchedule>> getLiveScores();

  /// Fetch live score for a specific match
  Future<GameSchedule?> getGameLiveScore(String gameId);

  /// Check if any matches are currently live
  Future<List<GameSchedule>> getLiveGames();
}

/// Implementation using SportsData.io Soccer v4 API
/// TODO: Ensure SportsData.io API key has soccer/World Cup tier access enabled
class LiveScoresDataSourceImpl implements LiveScoresDataSource {
  final Dio dio;
  final String apiKey;
  final String baseUrl;

  LiveScoresDataSourceImpl({
    required this.dio,
    required this.apiKey,
    // SportsData.io Soccer v4 scores endpoint
    this.baseUrl = 'https://api.sportsdata.io/v4/soccer/scores/json',
  });

  @override
  Future<List<GameSchedule>> getLiveScores() async {
    try {
      // Fetch today's soccer matches with live scores
      // SportsData.io soccer API uses GamesByDate endpoint
      final today = _formatDateForApi(DateTime.now());
      final response = await dio.get(
        '$baseUrl/GamesByDate/$today',
        queryParameters: {
          'key': apiKey,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> gamesData = response.data;
        return gamesData
            .map((gameData) => _parseGameWithLiveScore(gameData))
            .toList();
      } else {
        throw Exception('Failed to fetch live scores: ${response.statusCode}');
      }
    } catch (e) {
      LoggingService.error('Error fetching live scores: $e', tag: 'LiveScores');
      throw Exception('Failed to fetch live scores: $e');
    }
  }

  @override
  Future<GameSchedule?> getGameLiveScore(String gameId) async {
    try {
      // Fetch specific match details from SportsData.io soccer API
      final response = await dio.get(
        '$baseUrl/Game/$gameId',
        queryParameters: {
          'key': apiKey,
        },
      );

      if (response.statusCode == 200) {
        return _parseGameWithLiveScore(response.data);
      } else {
        LoggingService.warning('Match not found: ${response.statusCode}', tag: 'LiveScores');
        return null;
      }
    } catch (e) {
      LoggingService.error('Error fetching match live score: $e', tag: 'LiveScores');
      return null;
    }
  }

  @override
  Future<List<GameSchedule>> getLiveGames() async {
    try {
      final allGames = await getLiveScores();

      // Filter for matches that are currently live
      return allGames.where((game) =>
        game.isLive == true ||
        game.status?.toLowerCase().contains('live') == true ||
        game.status?.toLowerCase().contains('progress') == true
      ).toList();
    } catch (e) {
      LoggingService.error('Error fetching live matches: $e', tag: 'LiveScores');
      return [];
    }
  }

  /// Parse soccer match data from SportsData.io v4 API with live score information.
  /// Handles soccer-specific fields: goals, halves, extra time, penalties, match clock.
  GameSchedule _parseGameWithLiveScore(Map<String, dynamic> gameData) {
    // Parse date and time
    DateTime? dateTimeUTC;
    if (gameData['DateTime'] != null) {
      try {
        dateTimeUTC = DateTime.parse(gameData['DateTime']).toUtc();
      } catch (e) {
        LoggingService.warning('Error parsing DateTime: ${gameData['DateTime']}', tag: 'LiveScores');
      }
    }

    final DateTime? gameDateTime = dateTimeUTC?.toLocal();
    final DateTime? gameDay = gameDateTime != null
        ? DateTime(gameDateTime.year, gameDateTime.month, gameDateTime.day)
        : null;

    // Determine if match is live based on status
    final String? status = gameData['Status'] as String?;
    final bool isLive = _isGameLive(status);

    // Parse scores (goals in soccer)
    final int? awayScore = gameData['AwayTeamScore'] as int?;
    final int? homeScore = gameData['HomeTeamScore'] as int?;

    // Parse match period and clock for live matches
    // Soccer periods: 1H (first half), HT (halftime), 2H (second half),
    // ET1/ET2 (extra time halves), PK (penalty shootout), FT (full time)
    final String? period = gameData['Period'] as String?;

    // Build time display from match clock or minute
    final String? clock = gameData['Clock'] as String?;
    final String? timeRemaining = clock ??
        (gameData['Minute'] != null ? "${gameData['Minute']}'" : null);

    return GameSchedule(
      gameId: gameData['GameID']?.toString() ?? '',
      globalGameId: gameData['GlobalGameID'] as int?,
      season: gameData['Season']?.toString(),
      seasonType: gameData['SeasonType'] as int?,
      week: gameData['Week'] as int?, // Matchday/round in soccer context
      status: status,
      day: gameDay,
      dateTime: gameDateTime,
      dateTimeUTC: dateTimeUTC,
      awayTeamId: gameData['AwayTeamID'] as int?,
      homeTeamId: gameData['HomeTeamID'] as int?,
      awayTeamName: gameData['AwayTeamName'] ?? gameData['AwayTeam'] ?? 'N/A',
      homeTeamName: gameData['HomeTeamName'] ?? gameData['HomeTeam'] ?? 'N/A',
      globalAwayTeamId: gameData['GlobalAwayTeamID'] as int?,
      globalHomeTeamId: gameData['GlobalHomeTeamID'] as int?,
      stadiumId: gameData['StadiumID'] as int?,
      channel: gameData['Channel'] as String?,
      neutralVenue: gameData['NeutralVenue'] as bool?,
      updatedApi: DateTime.now(), // Mark as just updated from API

      // Live score fields (goals in soccer)
      awayScore: awayScore,
      homeScore: homeScore,
      period: period,
      timeRemaining: timeRemaining,
      isLive: isLive,
      lastScoreUpdate: isLive ? DateTime.now() : null,

      // Social fields - initialize to 0 for API data
      userPredictions: 0,
      userComments: 0,
      userPhotos: 0,
      userRating: 0.0,
    );
  }

  /// Determine if a soccer match is currently live based on status.
  /// Soccer uses halves (not quarters): 1st Half, Halftime, 2nd Half,
  /// Extra Time, and Penalty Shootout for knockout matches.
  bool _isGameLive(String? status) {
    if (status == null) return false;

    final liveStatuses = [
      'InProgress',
      'Live',
      'FirstHalf',
      '1st Half',
      'SecondHalf',
      '2nd Half',
      'Halftime',
      'HalfTime',
      'ExtraTime',
      'Extra Time',
      'ExtraTimeHalfTime',
      'PenaltyShootout',
      'Penalty Shootout',
    ];

    return liveStatuses.any((liveStatus) =>
      status.toLowerCase().contains(liveStatus.toLowerCase())
    );
  }

  /// Format date for SportsData.io API (YYYY-MMM-DD format)
  /// SportsData.io soccer uses this date format for GamesByDate endpoints
  String _formatDateForApi(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}

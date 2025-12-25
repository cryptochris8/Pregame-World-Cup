import 'package:dio/dio.dart';
import '../../domain/entities/game_schedule.dart';
import '../../../../core/services/logging_service.dart';

/// Data source for fetching live scores and game updates
abstract class LiveScoresDataSource {
  /// Fetch live scores for all games
  Future<List<GameSchedule>> getLiveScores();
  
  /// Fetch live score for a specific game
  Future<GameSchedule?> getGameLiveScore(String gameId);
  
  /// Check if any games are currently live
  Future<List<GameSchedule>> getLiveGames();
}

class LiveScoresDataSourceImpl implements LiveScoresDataSource {
  final Dio dio;
  final String apiKey;
  final String baseUrl;

  LiveScoresDataSourceImpl({
    required this.dio,
    required this.apiKey,
    this.baseUrl = 'https://api.sportsdata.io/v3/cfb/scores/json',
  });

  @override
  Future<List<GameSchedule>> getLiveScores() async {
    try {
      // Fetch current week's games with live scores
      final response = await dio.get(
        '$baseUrl/ScoresCurrentWeek',
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
      // Fetch specific game details
      final response = await dio.get(
        '$baseUrl/Game/$gameId',
        queryParameters: {
          'key': apiKey,
        },
      );

      if (response.statusCode == 200) {
        return _parseGameWithLiveScore(response.data);
      } else {
        LoggingService.warning('Game not found: ${response.statusCode}', tag: 'LiveScores');
        return null;
      }
    } catch (e) {
      LoggingService.error('Error fetching game live score: $e', tag: 'LiveScores');
      return null;
    }
  }

  @override
  Future<List<GameSchedule>> getLiveGames() async {
    try {
      final allGames = await getLiveScores();
      
      // Filter for games that are currently live
      return allGames.where((game) => 
        game.isLive == true || 
        game.status?.toLowerCase().contains('live') == true ||
        game.status?.toLowerCase().contains('progress') == true
      ).toList();
    } catch (e) {
      LoggingService.error('Error fetching live games: $e', tag: 'LiveScores');
      return [];
    }
  }

  /// Parse game data from SportsData.io API with live score information
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

    // Determine if game is live based on status
    final String? status = gameData['Status'] as String?;
    final bool isLive = _isGameLive(status);

    // Parse scores - SportsData.io provides these fields for live/completed games
    final int? awayScore = gameData['AwayTeamScore'] as int?;
    final int? homeScore = gameData['HomeTeamScore'] as int?;

    // Parse period and time remaining for live games
    final String? period = gameData['Period'] as String?;
    final String? timeRemaining = gameData['TimeRemainingMinutes'] != null && gameData['TimeRemainingSeconds'] != null
        ? '${gameData['TimeRemainingMinutes']}:${gameData['TimeRemainingSeconds'].toString().padLeft(2, '0')}'
        : null;

    return GameSchedule(
      gameId: gameData['GameID']?.toString() ?? '',
      globalGameId: gameData['GlobalGameID'] as int?,
      season: gameData['Season']?.toString(),
      seasonType: gameData['SeasonType'] as int?,
      week: gameData['Week'] as int?,
      status: status,
      day: gameDay,
      dateTime: gameDateTime,
      dateTimeUTC: dateTimeUTC,
      awayTeamId: gameData['AwayTeamID'] as int?,
      homeTeamId: gameData['HomeTeamID'] as int?,
      awayTeamName: gameData['AwayTeam'] ?? 'N/A',
      homeTeamName: gameData['HomeTeam'] ?? 'N/A',
      globalAwayTeamId: gameData['GlobalAwayTeamID'] as int?,
      globalHomeTeamId: gameData['GlobalHomeTeamID'] as int?,
      stadiumId: gameData['StadiumID'] as int?,
      channel: gameData['Channel'] as String?,
      neutralVenue: gameData['NeutralVenue'] as bool?,
      updatedApi: DateTime.now(), // Mark as just updated from API
      
      // Live score fields
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

  /// Determine if a game is currently live based on status
  bool _isGameLive(String? status) {
    if (status == null) return false;
    
    final liveStatuses = [
      'InProgress',
      'Live',
      '1st Quarter',
      '2nd Quarter', 
      '3rd Quarter',
      '4th Quarter',
      'Halftime',
      'Overtime',
    ];
    
    return liveStatuses.any((liveStatus) => 
      status.toLowerCase().contains(liveStatus.toLowerCase())
    );
  }
} 
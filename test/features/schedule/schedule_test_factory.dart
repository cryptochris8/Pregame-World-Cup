import 'package:pregame_world_cup/features/schedule/domain/entities/game_schedule.dart';
import 'package:pregame_world_cup/features/schedule/domain/entities/game_prediction.dart';

/// Test data factories for schedule entities
class ScheduleTestFactory {
  static GameSchedule createGameSchedule({
    String gameId = 'game_001',
    int? globalGameId = 12345,
    String? season = '2026',
    int? seasonType = 1,
    int? week = 1,
    String? status = 'Scheduled',
    DateTime? day,
    DateTime? dateTime,
    DateTime? dateTimeUTC,
    String awayTeamName = 'Argentina',
    String homeTeamName = 'Brazil',
    int? awayScore,
    int? homeScore,
    String? period,
    String? timeRemaining,
    bool? isLive,
    DateTime? lastScoreUpdate,
    Stadium? stadium,
    String? channel,
    bool? neutralVenue,
    int? userPredictions,
    int? userComments,
    int? userPhotos,
    double? userRating,
  }) {
    return GameSchedule(
      gameId: gameId,
      globalGameId: globalGameId,
      season: season,
      seasonType: seasonType,
      week: week,
      status: status,
      day: day,
      dateTime: dateTime ?? DateTime(2026, 6, 20, 20, 0),
      dateTimeUTC: dateTimeUTC ?? DateTime.utc(2026, 6, 21, 0, 0),
      awayTeamName: awayTeamName,
      homeTeamName: homeTeamName,
      awayScore: awayScore,
      homeScore: homeScore,
      period: period,
      timeRemaining: timeRemaining,
      isLive: isLive,
      lastScoreUpdate: lastScoreUpdate,
      stadium: stadium,
      channel: channel,
      neutralVenue: neutralVenue,
      userPredictions: userPredictions,
      userComments: userComments,
      userPhotos: userPhotos,
      userRating: userRating,
    );
  }

  static GameSchedule createLiveGame({
    String gameId = 'live_game_001',
    String awayTeamName = 'Argentina',
    String homeTeamName = 'Brazil',
    int awayScore = 1,
    int homeScore = 2,
    String period = '2H',
    String timeRemaining = "65'",
  }) {
    return createGameSchedule(
      gameId: gameId,
      awayTeamName: awayTeamName,
      homeTeamName: homeTeamName,
      status: 'InProgress',
      awayScore: awayScore,
      homeScore: homeScore,
      period: period,
      timeRemaining: timeRemaining,
      isLive: true,
      lastScoreUpdate: DateTime.now(),
    );
  }

  static GameSchedule createCompletedGame({
    String gameId = 'completed_game_001',
    String awayTeamName = 'Germany',
    String homeTeamName = 'France',
    int awayScore = 0,
    int homeScore = 1,
  }) {
    return createGameSchedule(
      gameId: gameId,
      awayTeamName: awayTeamName,
      homeTeamName: homeTeamName,
      status: 'Final',
      awayScore: awayScore,
      homeScore: homeScore,
      isLive: false,
    );
  }

  static GameSchedule createUpcomingGame({
    String gameId = 'upcoming_game_001',
    String awayTeamName = 'Spain',
    String homeTeamName = 'Portugal',
    DateTime? dateTimeUTC,
    Stadium? stadium,
    String? channel = 'FOX',
    int? week = 1,
  }) {
    return createGameSchedule(
      gameId: gameId,
      awayTeamName: awayTeamName,
      homeTeamName: homeTeamName,
      status: 'Scheduled',
      dateTimeUTC: dateTimeUTC ?? DateTime.now().add(const Duration(days: 7)),
      stadium: stadium,
      channel: channel,
      week: week,
    );
  }

  static GameSchedule createGameWithStadium({
    String gameId = 'stadium_game_001',
    String stadiumName = 'MetLife Stadium',
    String city = 'East Rutherford',
    String state = 'NJ',
  }) {
    return createGameSchedule(
      gameId: gameId,
      stadium: Stadium(
        stadiumId: 1,
        name: stadiumName,
        city: city,
        state: state,
        capacity: 82500,
      ),
    );
  }

  static GameSchedule createGameWithSocialData({
    String gameId = 'social_game_001',
    int userPredictions = 150,
    int userComments = 45,
    int userPhotos = 20,
    double userRating = 4.5,
  }) {
    return createGameSchedule(
      gameId: gameId,
      userPredictions: userPredictions,
      userComments: userComments,
      userPhotos: userPhotos,
      userRating: userRating,
    );
  }

  static GamePrediction createGamePrediction({
    String predictionId = 'pred_001',
    String userId = 'user_001',
    String gameId = 'game_001',
    String predictedWinner = 'Brazil',
    int? predictedHomeScore = 2,
    int? predictedAwayScore = 1,
    int confidenceLevel = 3,
    DateTime? createdAt,
    bool? isCorrect,
    int pointsEarned = 0,
    bool isLocked = false,
  }) {
    return GamePrediction(
      predictionId: predictionId,
      userId: userId,
      gameId: gameId,
      predictedWinner: predictedWinner,
      predictedHomeScore: predictedHomeScore,
      predictedAwayScore: predictedAwayScore,
      confidenceLevel: confidenceLevel,
      createdAt: createdAt ?? DateTime(2026, 6, 10),
      isCorrect: isCorrect,
      pointsEarned: pointsEarned,
      isLocked: isLocked,
    );
  }

  static PredictionStats createPredictionStats({
    int totalPredictions = 20,
    int correctPredictions = 12,
    int currentStreak = 3,
    int longestStreak = 5,
    int totalPoints = 250,
    int rank = 42,
  }) {
    return PredictionStats(
      totalPredictions: totalPredictions,
      correctPredictions: correctPredictions,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      totalPoints: totalPoints,
      rank: rank,
    );
  }

  static Map<String, dynamic> createAiAnalysisData({
    String homeScore = '2',
    String awayScore = '1',
    String winner = 'Brazil',
    String confidence = '0.72',
    List<String>? keyFactors,
    String analysis = 'Brazil has a strong home record.',
    String summary = 'Exciting South American rivalry matchup.',
  }) {
    return {
      'prediction': {
        'homeScore': homeScore,
        'awayScore': awayScore,
        'winner': winner,
        'confidence': confidence,
        'keyFactors': keyFactors ?? [
          'Home field advantage',
          'Recent team momentum',
          'Defensive matchups',
        ],
        'analysis': analysis,
      },
      'summary': summary,
      'historical': {
        'home': {
          'record': '8-2',
          'wins': 8,
          'losses': 2,
        },
        'away': {
          'record': '7-3',
          'wins': 7,
          'losses': 3,
        },
        'headToHead': {
          'narrative': 'Historic rivalry - closely contested',
          'totalMeetings': 15,
        },
      },
      'aiInsights': {
        'summary': 'Two of the strongest teams face off.',
        'analysis': 'Both teams bring unique strengths to this matchup.',
      },
      'dataQuality': 'enhanced_analysis',
    };
  }
}

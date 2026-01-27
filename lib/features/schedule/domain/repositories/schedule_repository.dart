import '../../domain/entities/game_schedule.dart';

abstract class ScheduleRepository {
  /// Fetches upcoming matches.
  /// [limit] specifies the maximum number of games to return (default: 10).
  /// Throws a [Exception] if fetching fails.
  Future<List<GameSchedule>> getUpcomingGames({int limit = 10});

  /// Fetches schedule for a specific week.
  /// [year] the season year and [week] the week number.
  /// Throws a [Exception] if fetching fails.
  Future<List<GameSchedule>> getScheduleForWeek(int year, int week);
} 
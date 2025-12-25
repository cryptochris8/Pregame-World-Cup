import '../../domain/entities/game_schedule.dart';

abstract class ScheduleRepository {
  /// Fetches the full regular season college football schedule for a given year.
  /// Throws a [Exception] if fetching fails.
  Future<List<GameSchedule>> getCollegeFootballSchedule(int year);
  
  /// Fetches upcoming college football games.
  /// [limit] specifies the maximum number of games to return (default: 10).
  /// Throws a [Exception] if fetching fails.
  Future<List<GameSchedule>> getUpcomingGames({int limit = 10});
  
  /// Fetches college football schedule for a specific week.
  /// [year] the season year and [week] the week number (1-17).
  /// Throws a [Exception] if fetching fails.
  Future<List<GameSchedule>> getScheduleForWeek(int year, int week);
} 
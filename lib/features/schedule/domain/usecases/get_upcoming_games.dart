import '../../domain/entities/game_schedule.dart';
import '../../domain/repositories/schedule_repository.dart';

class GetUpcomingGames {
  final ScheduleRepository repository;

  GetUpcomingGames(this.repository);

  /// Fetches upcoming college football games.
  /// [limit] specifies the maximum number of games to return (default: 10).
  /// Returns a list of [GameSchedule] objects sorted by date.
  /// Throws an [Exception] if fetching fails.
  Future<List<GameSchedule>> call({int limit = 10}) async {
    return await repository.getUpcomingGames(limit: limit);
  }
} 
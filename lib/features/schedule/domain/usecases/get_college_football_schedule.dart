import '../../domain/entities/game_schedule.dart';
import '../../domain/repositories/schedule_repository.dart';

class GetCollegeFootballSchedule {
  final ScheduleRepository repository;

  GetCollegeFootballSchedule(this.repository);

  /// Fetches the full regular season college football schedule for the specified year.
  /// Returns a list of [GameSchedule] objects.
  /// Throws an [Exception] if fetching fails.
  Future<List<GameSchedule>> call(int year) async {
    return await repository.getCollegeFootballSchedule(year);
  }
} 
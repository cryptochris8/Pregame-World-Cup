import '../../domain/repositories/schedule_repository.dart';
import '../datasources/ncaa_schedule_datasource.dart';
import '../../domain/entities/game_schedule.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final NcaaScheduleDataSource remoteDataSource;

  ScheduleRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<GameSchedule>> getCollegeFootballSchedule(int year) async {
    // We can add caching logic or error handling here later if needed.
    // For now, directly call the data source.
    return await remoteDataSource.fetchFullSeasonSchedule(year);
  }

  @override
  Future<List<GameSchedule>> getUpcomingGames({int limit = 10}) async {
    return await remoteDataSource.fetchUpcomingGames(limit: limit);
  }

  @override
  Future<List<GameSchedule>> getScheduleForWeek(int year, int week) async {
    return await remoteDataSource.fetchScheduleForWeek(year, week);
  }
} 
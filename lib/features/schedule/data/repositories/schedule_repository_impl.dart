import '../../../../core/services/cache_service.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../datasources/ncaa_schedule_datasource.dart';
import '../../domain/entities/game_schedule.dart';

/// Cache key prefixes for schedule data
const String _scheduleSeasonCachePrefix = 'schedule_season_';
const String _scheduleWeekCachePrefix = 'schedule_week_';
const String _scheduleUpcomingCacheKey = 'schedule_upcoming';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final NcaaScheduleDataSource remoteDataSource;
  final CacheService _cacheService;

  /// Cache durations
  static const Duration _seasonCacheDuration = Duration(hours: 12);
  static const Duration _weekCacheDuration = Duration(hours: 2);
  static const Duration _upcomingCacheDuration = Duration(minutes: 30);

  ScheduleRepositoryImpl({
    required this.remoteDataSource,
    CacheService? cacheService,
  }) : _cacheService = cacheService ?? CacheService.instance;

  @override
  Future<List<GameSchedule>> getCollegeFootballSchedule(int year) async {
    final cacheKey = '$_scheduleSeasonCachePrefix$year';

    // Try to get from cache first
    final cached = await _loadFromCache(cacheKey);
    if (cached != null) {
      return cached;
    }

    // Fetch from remote and cache
    final games = await remoteDataSource.fetchFullSeasonSchedule(year);
    await _saveToCache(cacheKey, games, _seasonCacheDuration);
    return games;
  }

  @override
  Future<List<GameSchedule>> getUpcomingGames({int limit = 10}) async {
    final cacheKey = '${_scheduleUpcomingCacheKey}_$limit';

    // Try to get from cache first
    final cached = await _loadFromCache(cacheKey);
    if (cached != null) {
      return cached;
    }

    // Fetch from remote and cache
    final games = await remoteDataSource.fetchUpcomingGames(limit: limit);
    await _saveToCache(cacheKey, games, _upcomingCacheDuration);
    return games;
  }

  @override
  Future<List<GameSchedule>> getScheduleForWeek(int year, int week) async {
    final cacheKey = '$_scheduleWeekCachePrefix${year}_$week';

    // Try to get from cache first
    final cached = await _loadFromCache(cacheKey);
    if (cached != null) {
      return cached;
    }

    // Fetch from remote and cache
    final games = await remoteDataSource.fetchScheduleForWeek(year, week);
    await _saveToCache(cacheKey, games, _weekCacheDuration);
    return games;
  }

  /// Load games from Hive cache
  Future<List<GameSchedule>?> _loadFromCache(String key) async {
    try {
      final cachedData = await _cacheService.get<List<dynamic>>(key);
      if (cachedData != null) {
        return cachedData
            .map((item) => GameSchedule.fromMap(
                  Map<String, dynamic>.from(item as Map),
                ))
            .toList();
      }
    } catch (e) {
      // Ignore cache errors, will fetch from remote
    }
    return null;
  }

  /// Save games to Hive cache
  Future<void> _saveToCache(
    String key,
    List<GameSchedule> games,
    Duration duration,
  ) async {
    try {
      final data = games.map((g) => g.toMap()).toList();
      await _cacheService.set<List<Map<String, dynamic>>>(
        key,
        data,
        duration: duration,
      );
    } catch (e) {
      // Ignore cache errors
    }
  }
} 
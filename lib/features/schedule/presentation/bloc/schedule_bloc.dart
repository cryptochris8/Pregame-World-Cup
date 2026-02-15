import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pregame_world_cup/features/schedule/domain/entities/game_schedule.dart';
import 'package:pregame_world_cup/features/schedule/domain/usecases/get_upcoming_games.dart';
import 'package:pregame_world_cup/features/schedule/domain/repositories/schedule_repository.dart';
import '../../../../core/services/logging_service.dart';
import '../../../../core/utils/team_matching_helper.dart';

part 'schedule_event.dart';
part 'schedule_state.dart';

/// Enhanced Schedule Bloc with smart API call optimization
/// Reduces API usage through intelligent caching and refresh logic
class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final GetUpcomingGames getUpcomingGames;
  final ScheduleRepository scheduleRepository;

  // Track current filter state
  bool _showFavoritesOnly = false;
  List<String> _favoriteTeams = [];
  
  // Smart refresh tracking to prevent excessive API calls
  DateTime? _lastUpcomingGamesRefresh;
  DateTime? _lastLiveScoreRefresh;
  // Minimum intervals between API calls (prevents spam)
  static const Duration _upcomingGamesRefreshInterval = Duration(minutes: 10);
  static const Duration _liveScoreRefreshInterval = Duration(minutes: 2);

  ScheduleBloc({
    required this.getUpcomingGames,
    required this.scheduleRepository,
  }) : super(ScheduleInitial()) {
    on<GetUpcomingGamesEvent>(_onGetUpcomingGames);
    on<GetScheduleForWeekEvent>(_onGetScheduleForWeek);
    on<RefreshLiveScoresEvent>(_onRefreshLiveScores);
    on<FilterByFavoriteTeamsEvent>(_onFilterByFavoriteTeams);
    on<ForceRefreshUpcomingGamesEvent>(_onForceRefreshUpcomingGames);

    // Don't automatically load data - let screens trigger when needed
    // This prevents blocking the UI during app startup
  }

  void _onGetUpcomingGames(
    GetUpcomingGamesEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    // Smart refresh check for upcoming games
    if (_shouldSkipUpcomingGamesRefresh()) {
      LoggingService.info('⏭️ Skipping upcoming games refresh - too recent', tag: 'ScheduleBloc');
      return;
    }
    
    emit(ScheduleLoading());
    try {
      _lastUpcomingGamesRefresh = DateTime.now();
      final upcomingGames = await getUpcomingGames(limit: event.limit);
      emit(UpcomingGamesLoaded(
        upcomingGames,
        showFavoritesOnly: _showFavoritesOnly,
        favoriteTeams: _favoriteTeams,
      ));
      LoggingService.info('✅ Upcoming games loaded successfully (${upcomingGames.length} games)', tag: 'ScheduleBloc');
    } catch (e) {
      LoggingService.error('❌ Upcoming games load failed: $e', tag: 'ScheduleBloc');
      emit(ScheduleError(e.toString()));
    }
  }

  void _onGetScheduleForWeek(
    GetScheduleForWeekEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(ScheduleLoading());
    try {
      final weeklySchedule = await scheduleRepository.getScheduleForWeek(event.year, event.week);
      emit(WeeklyScheduleLoaded(
        weeklySchedule, 
        event.year, 
        event.week,
        showFavoritesOnly: _showFavoritesOnly,
        favoriteTeams: _favoriteTeams,
      ));
      LoggingService.info('✅ Weekly schedule loaded for week ${event.week}', tag: 'ScheduleBloc');
    } catch (e) {
      LoggingService.error('❌ Weekly schedule load failed: $e', tag: 'ScheduleBloc');
      emit(ScheduleError(e.toString()));
    }
  }

  void _onRefreshLiveScores(
    RefreshLiveScoresEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    // Smart refresh check for live scores
    if (_shouldSkipLiveScoreRefresh()) {
      LoggingService.info('⏭️ Skipping live score refresh - too recent', tag: 'ScheduleBloc');
      return;
    }
    
    // Only refresh if it's likely game day or there are active games
    if (!_isLikelyGameTime()) {
      LoggingService.info('⏭️ Skipping live score refresh - not game time', tag: 'ScheduleBloc');
      return;
    }
    
    // Refresh upcoming games to get latest scores
    try {
      _lastLiveScoreRefresh = DateTime.now();
      final upcomingGames = await getUpcomingGames(limit: 100);
      emit(UpcomingGamesLoaded(
        upcomingGames,
        showFavoritesOnly: _showFavoritesOnly,
        favoriteTeams: _favoriteTeams,
      ));
      LoggingService.info('✅ Live scores refreshed successfully', tag: 'ScheduleBloc');
    } catch (e) {
      // Don't emit error for live score refresh failures
      // Just keep the current state
      LoggingService.warning('⚠️ Live score refresh failed: $e', tag: 'ScheduleBloc');
    }
  }

  void _onFilterByFavoriteTeams(
    FilterByFavoriteTeamsEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    // Update filter state - this doesn't require API calls, just re-filtering existing data
    _showFavoritesOnly = event.showFavoritesOnly;
    _favoriteTeams = event.favoriteTeams;

    LoggingService.info('🔍 Filtering by favorite teams: ${event.favoriteTeams.join(", ")}', tag: 'ScheduleBloc');

    // Re-emit current state with updated filter (no API call needed!)
    final currentState = state;
    if (currentState is ScheduleLoaded) {
      emit(ScheduleLoaded(
        currentState.schedule,
        showFavoritesOnly: _showFavoritesOnly,
        favoriteTeams: _favoriteTeams,
      ));
    } else if (currentState is UpcomingGamesLoaded) {
      emit(UpcomingGamesLoaded(
        currentState.upcomingGames,
        showFavoritesOnly: _showFavoritesOnly,
        favoriteTeams: _favoriteTeams,
      ));
    } else if (currentState is WeeklyScheduleLoaded) {
      emit(WeeklyScheduleLoaded(
        currentState.weeklySchedule,
        currentState.year,
        currentState.week,
        showFavoritesOnly: _showFavoritesOnly,
        favoriteTeams: _favoriteTeams,
      ));
    }
  }

  void _onForceRefreshUpcomingGames(
    ForceRefreshUpcomingGamesEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    // Force refresh bypasses all smart refresh checks
    LoggingService.info('FORCE REFRESH: Bypassing smart refresh logic', tag: 'ScheduleBloc');

    emit(ScheduleLoading());
    try {
      // Reset the refresh timestamp to allow fresh API call
      _lastUpcomingGamesRefresh = null;

      final upcomingGames = await getUpcomingGames(limit: event.limit);

      // Update timestamp after successful call
      _lastUpcomingGamesRefresh = DateTime.now();

      emit(UpcomingGamesLoaded(
        upcomingGames,
        showFavoritesOnly: _showFavoritesOnly,
        favoriteTeams: _favoriteTeams,
      ));
      LoggingService.info('FORCE REFRESH: Successfully loaded ${upcomingGames.length} games', tag: 'ScheduleBloc');
    } catch (e) {
      LoggingService.error('FORCE REFRESH: Failed to load games: $e', tag: 'ScheduleBloc');
      emit(ScheduleError(e.toString()));
    }
  }
  
  /// Smart refresh logic - prevents API spam
  bool _shouldSkipUpcomingGamesRefresh() {
    if (_lastUpcomingGamesRefresh == null) return false;
    final timeSinceLastRefresh = DateTime.now().difference(_lastUpcomingGamesRefresh!);
    return timeSinceLastRefresh < _upcomingGamesRefreshInterval;
  }
  
  bool _shouldSkipLiveScoreRefresh() {
    if (_lastLiveScoreRefresh == null) return false;
    final timeSinceLastRefresh = DateTime.now().difference(_lastLiveScoreRefresh!);
    return timeSinceLastRefresh < _liveScoreRefreshInterval;
  }
  
  /// Determine if it's likely game time (avoid unnecessary live refreshes)
  bool _isLikelyGameTime() {
    final now = DateTime.now();
    final hour = now.hour;
    final month = now.month;
    
    // World Cup 2026: June 11 through July 19
    final isWorldCupSeason = (month == 6 && now.day >= 11) || month == 7 && now.day <= 19;
    if (!isWorldCupSeason) return false;

    // World Cup matches can be any day of the week
    // Game hours: 11 AM - 11 PM ET (typical World Cup match times in US)
    final isGameTime = hour >= 11 && hour <= 23;

    return isGameTime;
  }
} 
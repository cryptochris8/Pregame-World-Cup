part of 'schedule_bloc.dart';

abstract class ScheduleEvent extends Equatable {
  const ScheduleEvent();

  @override
  List<Object> get props => [];
}

class GetCollegeFootballScheduleEvent extends ScheduleEvent {
  final int year;

  const GetCollegeFootballScheduleEvent(this.year);

  @override
  List<Object> get props => [year];
}

class GetUpcomingGamesEvent extends ScheduleEvent {
  final int limit;

  const GetUpcomingGamesEvent({this.limit = 10});

  @override
  List<Object> get props => [limit];
}

class GetScheduleForWeekEvent extends ScheduleEvent {
  final int year;
  final int week;

  const GetScheduleForWeekEvent(this.year, this.week);

  @override
  List<Object> get props => [year, week];
}

class RefreshLiveScoresEvent extends ScheduleEvent {
  const RefreshLiveScoresEvent();
  
  @override
  List<Object> get props => [];
}

// New event for filtering by favorite teams
class FilterByFavoriteTeamsEvent extends ScheduleEvent {
  final bool showFavoritesOnly;
  final List<String> favoriteTeams;

  const FilterByFavoriteTeamsEvent({
    required this.showFavoritesOnly,
    required this.favoriteTeams,
  });

  @override
  List<Object> get props => [showFavoritesOnly, favoriteTeams];
}

// Force refresh event that bypasses smart refresh timing
class ForceRefreshUpcomingGamesEvent extends ScheduleEvent {
  final int limit;

  const ForceRefreshUpcomingGamesEvent({this.limit = 10});

  @override
  List<Object> get props => [limit];
}
 
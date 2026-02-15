part of 'schedule_bloc.dart';

abstract class ScheduleState extends Equatable {
  const ScheduleState();

  @override
  List<Object?> get props => [];
}

class ScheduleInitial extends ScheduleState {}

class ScheduleLoading extends ScheduleState {}

class ScheduleLoaded extends ScheduleState {
  final List<GameSchedule> schedule;
  final bool showFavoritesOnly;
  final List<String> favoriteTeams;

  const ScheduleLoaded(
    this.schedule, {
    this.showFavoritesOnly = false,
    this.favoriteTeams = const [],
  });

  @override
  List<Object> get props => [schedule, showFavoritesOnly, favoriteTeams];

  // Helper method to get filtered games
  List<GameSchedule> get filteredSchedule {
    if (!showFavoritesOnly || favoriteTeams.isEmpty) {
      return schedule;
    }
    
    return schedule.where((game) {
      // More flexible team name matching using shared helper
      return TeamMatchingHelper.isTeamInFavorites(game.homeTeamName, favoriteTeams) || 
             TeamMatchingHelper.isTeamInFavorites(game.awayTeamName, favoriteTeams);
    }).toList();
  }

}

class UpcomingGamesLoaded extends ScheduleState {
  final List<GameSchedule> upcomingGames;
  final bool showFavoritesOnly;
  final List<String> favoriteTeams;

  const UpcomingGamesLoaded(
    this.upcomingGames, {
    this.showFavoritesOnly = false,
    this.favoriteTeams = const [],
  });

  @override
  List<Object> get props => [upcomingGames, showFavoritesOnly, favoriteTeams];

  // Helper method to get filtered games
  List<GameSchedule> get filteredUpcomingGames {
    if (!showFavoritesOnly || favoriteTeams.isEmpty) {
      return upcomingGames;
    }
    
    return upcomingGames.where((game) {
      // The API stores team keys (ALA, GA, etc.) but favorites are full names
      // Use TeamMatchingHelper which handles the key-to-name mapping properly
      return TeamMatchingHelper.isTeamInFavorites(game.homeTeamName, favoriteTeams) || 
             TeamMatchingHelper.isTeamInFavorites(game.awayTeamName, favoriteTeams);
    }).toList();
  }

}

class WeeklyScheduleLoaded extends ScheduleState {
  final List<GameSchedule> weeklySchedule;
  final int year;
  final int week;
  final bool showFavoritesOnly;
  final List<String> favoriteTeams;

  const WeeklyScheduleLoaded(
    this.weeklySchedule, 
    this.year, 
    this.week, {
    this.showFavoritesOnly = false,
    this.favoriteTeams = const [],
  });

  @override
  List<Object> get props => [weeklySchedule, year, week, showFavoritesOnly, favoriteTeams];

  // Helper method to get filtered games
  List<GameSchedule> get filteredWeeklySchedule {
    if (!showFavoritesOnly || favoriteTeams.isEmpty) {
      return weeklySchedule;
    }
    
    return weeklySchedule.where((game) {
      // The API stores team keys (ALA, GA, etc.) but favorites are full names
      // Use TeamMatchingHelper which handles the key-to-name mapping properly
      return TeamMatchingHelper.isTeamInFavorites(game.homeTeamName, favoriteTeams) || 
             TeamMatchingHelper.isTeamInFavorites(game.awayTeamName, favoriteTeams);
    }).toList();
  }

}

class ScheduleError extends ScheduleState {
  final String message;

  const ScheduleError(this.message);

  @override
  List<Object> get props => [message];
} 
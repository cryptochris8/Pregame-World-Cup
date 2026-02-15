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

  // Helper method to check if a team is in favorites with flexible matching
  bool _isTeamInFavorites(String teamName, List<String> favoriteTeams) {
    // Direct match first
    if (favoriteTeams.contains(teamName)) {
      return true;
    }
    
    // Flexible matching - check if any favorite team name contains the team name or vice versa
    for (String favoriteTeam in favoriteTeams) {
      // Check if the team name contains key words from favorite team
      if (_teamNamesMatch(teamName, favoriteTeam)) {
        return true;
      }
    }
    
    return false;
  }

  // Helper method to match team names flexibly
  bool _teamNamesMatch(String apiTeamName, String favoriteTeamName) {
    final apiLower = apiTeamName.toLowerCase();
    final favLower = favoriteTeamName.toLowerCase();
    
    // Direct match
    if (apiLower == favLower) return true;
    
    // Check for key team identifiers
    final teamMappings = {
      'united states': ['united states', 'usa', 'usmnt', 'stars and stripes'],
      'mexico': ['mexico', 'el tri', 'tricolor'],
      'brazil': ['brazil', 'selecao', 'canarinha'],
      'argentina': ['argentina', 'albiceleste'],
      'france': ['france', 'les bleus'],
      'germany': ['germany', 'die mannschaft'],
      'spain': ['spain', 'la roja'],
      'england': ['england', 'three lions'],
      'portugal': ['portugal'],
      'netherlands': ['netherlands', 'holland', 'oranje'],
      'italy': ['italy', 'azzurri'],
      'japan': ['japan', 'samurai blue'],
      'south korea': ['south korea', 'korea republic', 'taegeuk warriors'],
      'morocco': ['morocco', 'atlas lions'],
      'canada': ['canada', 'canmnt'],
      'croatia': ['croatia', 'vatreni'],
    };
    
    // Check if either name contains key identifiers
    for (String key in teamMappings.keys) {
      final identifiers = teamMappings[key]!;
      bool apiMatches = identifiers.any((id) => apiLower.contains(id));
      bool favMatches = identifiers.any((id) => favLower.contains(id));
      
      if (apiMatches && favMatches) {
        return true;
      }
    }
    
    return false;
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

  // Helper method to check if a team is in favorites with flexible matching
  bool _isTeamInFavorites(String teamName, List<String> favoriteTeams) {
    // Direct match first
    if (favoriteTeams.contains(teamName)) {
      return true;
    }
    
    // Flexible matching - check if any favorite team name contains the team name or vice versa
    for (String favoriteTeam in favoriteTeams) {
      // Check if the team name contains key words from favorite team
      if (_teamNamesMatch(teamName, favoriteTeam)) {
        return true;
      }
    }
    
    return false;
  }

  // Helper method to match team names flexibly
  bool _teamNamesMatch(String apiTeamName, String favoriteTeamName) {
    final apiLower = apiTeamName.toLowerCase();
    final favLower = favoriteTeamName.toLowerCase();
    
    // Direct match
    if (apiLower == favLower) return true;
    
    // Check for key team identifiers
    final teamMappings = {
      'united states': ['united states', 'usa', 'usmnt', 'stars and stripes'],
      'mexico': ['mexico', 'el tri', 'tricolor'],
      'brazil': ['brazil', 'selecao', 'canarinha'],
      'argentina': ['argentina', 'albiceleste'],
      'france': ['france', 'les bleus'],
      'germany': ['germany', 'die mannschaft'],
      'spain': ['spain', 'la roja'],
      'england': ['england', 'three lions'],
      'portugal': ['portugal'],
      'netherlands': ['netherlands', 'holland', 'oranje'],
      'italy': ['italy', 'azzurri'],
      'japan': ['japan', 'samurai blue'],
      'south korea': ['south korea', 'korea republic', 'taegeuk warriors'],
      'morocco': ['morocco', 'atlas lions'],
      'canada': ['canada', 'canmnt'],
      'croatia': ['croatia', 'vatreni'],
    };
    
    // Check if either name contains key identifiers
    for (String key in teamMappings.keys) {
      final identifiers = teamMappings[key]!;
      bool apiMatches = identifiers.any((id) => apiLower.contains(id));
      bool favMatches = identifiers.any((id) => favLower.contains(id));
      
      if (apiMatches && favMatches) {
        return true;
      }
    }
    
    return false;
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

  // Helper method to check if a team is in favorites with flexible matching
  bool _isTeamInFavorites(String teamName, List<String> favoriteTeams) {
    // Direct match first
    if (favoriteTeams.contains(teamName)) {
      return true;
    }
    
    // Flexible matching - check if any favorite team name contains the team name or vice versa
    for (String favoriteTeam in favoriteTeams) {
      // Check if the team name contains key words from favorite team
      if (_teamNamesMatch(teamName, favoriteTeam)) {
        return true;
      }
    }
    
    return false;
  }

  // Helper method to match team names flexibly
  bool _teamNamesMatch(String apiTeamName, String favoriteTeamName) {
    final apiLower = apiTeamName.toLowerCase();
    final favLower = favoriteTeamName.toLowerCase();
    
    // Direct match
    if (apiLower == favLower) return true;
    
    // Check for key team identifiers
    final teamMappings = {
      'united states': ['united states', 'usa', 'usmnt', 'stars and stripes'],
      'mexico': ['mexico', 'el tri', 'tricolor'],
      'brazil': ['brazil', 'selecao', 'canarinha'],
      'argentina': ['argentina', 'albiceleste'],
      'france': ['france', 'les bleus'],
      'germany': ['germany', 'die mannschaft'],
      'spain': ['spain', 'la roja'],
      'england': ['england', 'three lions'],
      'portugal': ['portugal'],
      'netherlands': ['netherlands', 'holland', 'oranje'],
      'italy': ['italy', 'azzurri'],
      'japan': ['japan', 'samurai blue'],
      'south korea': ['south korea', 'korea republic', 'taegeuk warriors'],
      'morocco': ['morocco', 'atlas lions'],
      'canada': ['canada', 'canmnt'],
      'croatia': ['croatia', 'vatreni'],
    };
    
    // Check if either name contains key identifiers
    for (String key in teamMappings.keys) {
      final identifiers = teamMappings[key]!;
      bool apiMatches = identifiers.any((id) => apiLower.contains(id));
      bool favMatches = identifiers.any((id) => favLower.contains(id));
      
      if (apiMatches && favMatches) {
        return true;
      }
    }
    
    return false;
  }
}

class ScheduleError extends ScheduleState {
  final String message;

  const ScheduleError(this.message);

  @override
  List<Object> get props => [message];
} 
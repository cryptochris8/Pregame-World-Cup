import 'package:equatable/equatable.dart';
import '../../domain/entities/entities.dart';

/// Sort options for teams list
enum TeamsSortOption {
  /// Sort alphabetically by country name
  alphabetical,
  /// Sort by FIFA ranking
  fifaRanking,
  /// Sort by confederation
  confederation,
  /// Sort by group
  group,
}

/// State for TeamsCubit
class TeamsState extends Equatable {
  /// All teams
  final List<NationalTeam> teams;

  /// Filtered/sorted teams for display
  final List<NationalTeam> displayTeams;

  /// Currently selected team for detail view
  final NationalTeam? selectedTeam;

  /// Current sort option
  final TeamsSortOption sortOption;

  /// Filter by confederation
  final Confederation? selectedConfederation;

  /// Filter by group
  final String? selectedGroup;

  /// Search query
  final String? searchQuery;

  /// Show only favorites
  final bool showFavoritesOnly;

  /// Loading state
  final bool isLoading;

  /// Refreshing state
  final bool isRefreshing;

  /// Error message
  final String? errorMessage;

  /// Last updated timestamp
  final DateTime? lastUpdated;

  const TeamsState({
    this.teams = const [],
    this.displayTeams = const [],
    this.selectedTeam,
    this.sortOption = TeamsSortOption.alphabetical,
    this.selectedConfederation,
    this.selectedGroup,
    this.searchQuery,
    this.showFavoritesOnly = false,
    this.isLoading = false,
    this.isRefreshing = false,
    this.errorMessage,
    this.lastUpdated,
  });

  /// Initial state
  factory TeamsState.initial() => const TeamsState(isLoading: true);

  @override
  List<Object?> get props => [
    teams,
    displayTeams,
    selectedTeam,
    sortOption,
    selectedConfederation,
    selectedGroup,
    searchQuery,
    showFavoritesOnly,
    isLoading,
    isRefreshing,
    errorMessage,
    lastUpdated,
  ];

  /// Get team by FIFA code
  NationalTeam? getTeamByCode(String code) {
    try {
      return teams.firstWhere(
        (t) => t.fifaCode.toUpperCase() == code.toUpperCase(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Get teams by confederation
  List<NationalTeam> getTeamsByConfederation(Confederation conf) {
    return teams.where((t) => t.confederation == conf).toList();
  }

  /// Get teams by group
  List<NationalTeam> getTeamsByGroup(String groupLetter) {
    return teams.where(
      (t) => t.group?.toUpperCase() == groupLetter.toUpperCase(),
    ).toList();
  }

  /// Get host nations
  List<NationalTeam> get hostNations {
    return teams.where((t) => t.isHostNation).toList();
  }

  /// Get teams with most World Cup titles
  List<NationalTeam> get topTitleHolders {
    final sorted = List<NationalTeam>.from(teams);
    sorted.sort((a, b) => b.worldCupTitles.compareTo(a.worldCupTitles));
    return sorted.where((t) => t.worldCupTitles > 0).toList();
  }

  /// Get all unique groups
  List<String> get allGroups {
    final groups = teams
        .where((t) => t.group != null)
        .map((t) => t.group!)
        .toSet()
        .toList();
    groups.sort();
    return groups;
  }

  /// Copy with new values
  TeamsState copyWith({
    List<NationalTeam>? teams,
    List<NationalTeam>? displayTeams,
    NationalTeam? selectedTeam,
    TeamsSortOption? sortOption,
    Confederation? selectedConfederation,
    String? selectedGroup,
    String? searchQuery,
    bool? showFavoritesOnly,
    bool? isLoading,
    bool? isRefreshing,
    String? errorMessage,
    DateTime? lastUpdated,
    bool clearSelectedTeam = false,
    bool clearConfederation = false,
    bool clearGroup = false,
    bool clearSearch = false,
    bool clearError = false,
  }) {
    return TeamsState(
      teams: teams ?? this.teams,
      displayTeams: displayTeams ?? this.displayTeams,
      selectedTeam: clearSelectedTeam ? null : (selectedTeam ?? this.selectedTeam),
      sortOption: sortOption ?? this.sortOption,
      selectedConfederation: clearConfederation ? null : (selectedConfederation ?? this.selectedConfederation),
      selectedGroup: clearGroup ? null : (selectedGroup ?? this.selectedGroup),
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      showFavoritesOnly: showFavoritesOnly ?? this.showFavoritesOnly,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

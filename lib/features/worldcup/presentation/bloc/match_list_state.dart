import 'package:equatable/equatable.dart';
import '../../domain/entities/entities.dart';

/// Filter options for match list
enum MatchListFilter {
  all,
  favorites,
  today,
  upcoming,
  live,
  completed,
  groupStage,
  knockout,
}

/// State for MatchListCubit
class MatchListState extends Equatable {
  /// All matches
  final List<WorldCupMatch> matches;

  /// Filtered matches based on current filter
  final List<WorldCupMatch> filteredMatches;

  /// Live matches (subset, always tracked)
  final List<WorldCupMatch> liveMatches;

  /// Current filter
  final MatchListFilter filter;

  /// Selected stage filter (null = all stages)
  final MatchStage? selectedStage;

  /// Selected group filter (null = all groups)
  final String? selectedGroup;

  /// Selected team filter (null = all teams)
  final String? selectedTeamCode;

  /// Selected date filter
  final DateTime? selectedDate;

  /// Loading state
  final bool isLoading;

  /// Refreshing state
  final bool isRefreshing;

  /// Error message
  final String? errorMessage;

  /// Last updated timestamp
  final DateTime? lastUpdated;

  const MatchListState({
    this.matches = const [],
    this.filteredMatches = const [],
    this.liveMatches = const [],
    this.filter = MatchListFilter.all,
    this.selectedStage,
    this.selectedGroup,
    this.selectedTeamCode,
    this.selectedDate,
    this.isLoading = false,
    this.isRefreshing = false,
    this.errorMessage,
    this.lastUpdated,
  });

  /// Initial state
  factory MatchListState.initial() => const MatchListState(isLoading: true);

  /// Loading state
  factory MatchListState.loading() => const MatchListState(isLoading: true);

  @override
  List<Object?> get props => [
    matches,
    filteredMatches,
    liveMatches,
    filter,
    selectedStage,
    selectedGroup,
    selectedTeamCode,
    selectedDate,
    isLoading,
    isRefreshing,
    errorMessage,
    lastUpdated,
  ];

  /// Check if there are any live matches
  bool get hasLiveMatches => liveMatches.isNotEmpty;

  /// Get count of matches by status
  int get liveCount => liveMatches.length;
  int get upcomingCount => matches.where((m) => m.status == MatchStatus.scheduled).length;
  int get completedCount => matches.where((m) => m.status == MatchStatus.completed).length;

  /// Get today's matches
  List<WorldCupMatch> get todaysMatches {
    final now = DateTime.now();
    return matches.where((m) {
      if (m.dateTime == null) return false;
      return m.dateTime!.year == now.year &&
             m.dateTime!.month == now.month &&
             m.dateTime!.day == now.day;
    }).toList();
  }

  /// Copy with new values
  MatchListState copyWith({
    List<WorldCupMatch>? matches,
    List<WorldCupMatch>? filteredMatches,
    List<WorldCupMatch>? liveMatches,
    MatchListFilter? filter,
    MatchStage? selectedStage,
    String? selectedGroup,
    String? selectedTeamCode,
    DateTime? selectedDate,
    bool? isLoading,
    bool? isRefreshing,
    String? errorMessage,
    DateTime? lastUpdated,
    bool clearStage = false,
    bool clearGroup = false,
    bool clearTeam = false,
    bool clearDate = false,
    bool clearError = false,
  }) {
    return MatchListState(
      matches: matches ?? this.matches,
      filteredMatches: filteredMatches ?? this.filteredMatches,
      liveMatches: liveMatches ?? this.liveMatches,
      filter: filter ?? this.filter,
      selectedStage: clearStage ? null : (selectedStage ?? this.selectedStage),
      selectedGroup: clearGroup ? null : (selectedGroup ?? this.selectedGroup),
      selectedTeamCode: clearTeam ? null : (selectedTeamCode ?? this.selectedTeamCode),
      selectedDate: clearDate ? null : (selectedDate ?? this.selectedDate),
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

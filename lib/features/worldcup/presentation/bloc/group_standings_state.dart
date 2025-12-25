import 'package:equatable/equatable.dart';
import '../../domain/entities/entities.dart';

/// State for GroupStandingsCubit
class GroupStandingsState extends Equatable {
  /// All groups with standings
  final List<WorldCupGroup> groups;

  /// Currently selected group (for detail view)
  final WorldCupGroup? selectedGroup;

  /// Loading state
  final bool isLoading;

  /// Refreshing state
  final bool isRefreshing;

  /// Error message
  final String? errorMessage;

  /// Last updated timestamp
  final DateTime? lastUpdated;

  const GroupStandingsState({
    this.groups = const [],
    this.selectedGroup,
    this.isLoading = false,
    this.isRefreshing = false,
    this.errorMessage,
    this.lastUpdated,
  });

  /// Initial state
  factory GroupStandingsState.initial() => const GroupStandingsState(isLoading: true);

  @override
  List<Object?> get props => [
    groups,
    selectedGroup,
    isLoading,
    isRefreshing,
    errorMessage,
    lastUpdated,
  ];

  /// Get group by letter
  WorldCupGroup? getGroup(String letter) {
    try {
      return groups.firstWhere(
        (g) => g.groupLetter.toUpperCase() == letter.toUpperCase(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Get all group letters
  List<String> get groupLetters => groups.map((g) => g.groupLetter).toList();

  /// Copy with new values
  GroupStandingsState copyWith({
    List<WorldCupGroup>? groups,
    WorldCupGroup? selectedGroup,
    bool? isLoading,
    bool? isRefreshing,
    String? errorMessage,
    DateTime? lastUpdated,
    bool clearSelectedGroup = false,
    bool clearError = false,
  }) {
    return GroupStandingsState(
      groups: groups ?? this.groups,
      selectedGroup: clearSelectedGroup ? null : (selectedGroup ?? this.selectedGroup),
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

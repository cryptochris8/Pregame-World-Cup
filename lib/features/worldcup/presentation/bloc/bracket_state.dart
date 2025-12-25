import 'package:equatable/equatable.dart';
import '../../domain/entities/entities.dart';

/// View mode for bracket display
enum BracketViewMode {
  /// Full bracket view
  full,
  /// Round by round view
  byRound,
  /// Interactive bracket builder
  interactive,
}

/// State for BracketCubit
class BracketState extends Equatable {
  /// The complete bracket
  final WorldCupBracket? bracket;

  /// Currently selected match for detail view
  final BracketMatch? selectedMatch;

  /// Current view mode
  final BracketViewMode viewMode;

  /// Currently focused round
  final MatchStage? focusedRound;

  /// Loading state
  final bool isLoading;

  /// Refreshing state
  final bool isRefreshing;

  /// Error message
  final String? errorMessage;

  /// Last updated timestamp
  final DateTime? lastUpdated;

  const BracketState({
    this.bracket,
    this.selectedMatch,
    this.viewMode = BracketViewMode.full,
    this.focusedRound,
    this.isLoading = false,
    this.isRefreshing = false,
    this.errorMessage,
    this.lastUpdated,
  });

  /// Initial state
  factory BracketState.initial() => const BracketState(isLoading: true);

  @override
  List<Object?> get props => [
    bracket,
    selectedMatch,
    viewMode,
    focusedRound,
    isLoading,
    isRefreshing,
    errorMessage,
    lastUpdated,
  ];

  /// Get matches for a specific round
  List<BracketMatch> getMatchesForRound(MatchStage stage) {
    if (bracket == null) return [];

    switch (stage) {
      case MatchStage.roundOf32:
        return bracket!.roundOf32;
      case MatchStage.roundOf16:
        return bracket!.roundOf16;
      case MatchStage.quarterFinal:
        return bracket!.quarterFinals;
      case MatchStage.semiFinal:
        return bracket!.semiFinals;
      case MatchStage.thirdPlace:
        return bracket!.thirdPlace != null ? [bracket!.thirdPlace!] : [];
      case MatchStage.final_:
        return bracket!.finalMatch != null ? [bracket!.finalMatch!] : [];
      default:
        return [];
    }
  }

  /// Check if bracket is complete (all matches finished)
  bool get isBracketComplete {
    if (bracket == null) return false;
    return bracket!.finalMatch?.isComplete ?? false;
  }

  /// Get current active round (first round with incomplete matches)
  MatchStage? get currentActiveRound {
    if (bracket == null) return null;

    // Check rounds in order
    if (bracket!.roundOf32.any((m) => !m.isComplete)) {
      return MatchStage.roundOf32;
    }
    if (bracket!.roundOf16.any((m) => !m.isComplete)) {
      return MatchStage.roundOf16;
    }
    if (bracket!.quarterFinals.any((m) => !m.isComplete)) {
      return MatchStage.quarterFinal;
    }
    if (bracket!.semiFinals.any((m) => !m.isComplete)) {
      return MatchStage.semiFinal;
    }
    if (bracket!.thirdPlace != null && !bracket!.thirdPlace!.isComplete) {
      return MatchStage.thirdPlace;
    }
    if (bracket!.finalMatch != null && !bracket!.finalMatch!.isComplete) {
      return MatchStage.final_;
    }

    return null;
  }

  /// Copy with new values
  BracketState copyWith({
    WorldCupBracket? bracket,
    BracketMatch? selectedMatch,
    BracketViewMode? viewMode,
    MatchStage? focusedRound,
    bool? isLoading,
    bool? isRefreshing,
    String? errorMessage,
    DateTime? lastUpdated,
    bool clearSelectedMatch = false,
    bool clearFocusedRound = false,
    bool clearError = false,
  }) {
    return BracketState(
      bracket: bracket ?? this.bracket,
      selectedMatch: clearSelectedMatch ? null : (selectedMatch ?? this.selectedMatch),
      viewMode: viewMode ?? this.viewMode,
      focusedRound: clearFocusedRound ? null : (focusedRound ?? this.focusedRound),
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

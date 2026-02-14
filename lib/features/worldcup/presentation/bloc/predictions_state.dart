import 'package:equatable/equatable.dart';
import '../../domain/entities/entities.dart';

/// State for match predictions management
class PredictionsState extends Equatable {
  /// All predictions
  final List<MatchPrediction> predictions;

  /// Prediction statistics
  final PredictionStats stats;

  /// Whether predictions are loading
  final bool isLoading;

  /// Whether a save operation is in progress
  final bool isSaving;

  /// Error message if any
  final String? errorMessage;

  /// Success message (for showing feedback)
  final String? successMessage;

  /// Currently selected match for prediction
  final String? selectedMatchId;

  const PredictionsState({
    this.predictions = const [],
    this.stats = const PredictionStats(),
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
    this.selectedMatchId,
  });

  @override
  List<Object?> get props => [
        predictions,
        stats,
        isLoading,
        isSaving,
        errorMessage,
        successMessage,
        selectedMatchId,
      ];

  /// Initial state
  factory PredictionsState.initial() => const PredictionsState(isLoading: true);

  /// Get upcoming/pending predictions
  List<MatchPrediction> get upcomingPredictions =>
      predictions.where((p) => p.isPending).toList();

  /// Get completed/evaluated predictions
  List<MatchPrediction> get completedPredictions =>
      predictions.where((p) => !p.isPending).toList();

  /// Get correct predictions
  List<MatchPrediction> get correctPredictions =>
      predictions.where((p) => p.isCorrect).toList();

  /// Check if a prediction exists for a match
  bool hasPredictionForMatch(String matchId) =>
      predictions.any((p) => p.matchId == matchId);

  /// Get prediction for a specific match
  MatchPrediction? getPredictionForMatch(String matchId) {
    try {
      return predictions.firstWhere((p) => p.matchId == matchId);
    } catch (e) {
      return null;
    }
  }

  /// Total points earned
  int get totalPoints => stats.totalPoints;

  /// Create a copy with updated fields
  PredictionsState copyWith({
    List<MatchPrediction>? predictions,
    PredictionStats? stats,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
    String? selectedMatchId,
    bool clearSelectedMatch = false,
  }) {
    return PredictionsState(
      predictions: predictions ?? this.predictions,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      selectedMatchId: clearSelectedMatch ? null : (selectedMatchId ?? this.selectedMatchId),
    );
  }
}

import 'package:equatable/equatable.dart';
import '../../domain/entities/entities.dart';

/// State for World Cup AI predictions
class WorldCupAIState extends Equatable {
  /// Map of cached AI predictions by match ID
  final Map<String, AIMatchPrediction> predictions;

  /// Whether AI is currently loading a prediction
  final bool isLoading;

  /// Match ID currently being loaded (null if not loading)
  final String? loadingMatchId;

  /// Error message if prediction failed
  final String? error;

  /// Match ID that had the error
  final String? errorMatchId;

  /// Whether AI service is available
  final bool isAvailable;

  const WorldCupAIState({
    this.predictions = const {},
    this.isLoading = false,
    this.loadingMatchId,
    this.error,
    this.errorMatchId,
    this.isAvailable = true,
  });

  /// Initial state
  factory WorldCupAIState.initial() => const WorldCupAIState();

  @override
  List<Object?> get props => [
        predictions,
        isLoading,
        loadingMatchId,
        error,
        errorMatchId,
        isAvailable,
      ];

  /// Get prediction for a specific match
  AIMatchPrediction? getPrediction(String matchId) => predictions[matchId];

  /// Check if a prediction exists and is valid
  bool hasPrediction(String matchId) {
    final prediction = predictions[matchId];
    return prediction != null && prediction.isValid;
  }

  /// Check if currently loading a specific match
  bool isLoadingMatch(String matchId) =>
      isLoading && loadingMatchId == matchId;

  /// Check if a specific match had an error
  bool hasError(String matchId) => error != null && errorMatchId == matchId;

  /// Create a copy with updated fields
  WorldCupAIState copyWith({
    Map<String, AIMatchPrediction>? predictions,
    bool? isLoading,
    String? loadingMatchId,
    String? error,
    String? errorMatchId,
    bool? isAvailable,
    bool clearError = false,
    bool clearLoadingMatchId = false,
  }) {
    return WorldCupAIState(
      predictions: predictions ?? this.predictions,
      isLoading: isLoading ?? this.isLoading,
      loadingMatchId: clearLoadingMatchId ? null : (loadingMatchId ?? this.loadingMatchId),
      error: clearError ? null : (error ?? this.error),
      errorMatchId: clearError ? null : (errorMatchId ?? this.errorMatchId),
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  /// Add or update a prediction
  WorldCupAIState withPrediction(AIMatchPrediction prediction) {
    final newPredictions = Map<String, AIMatchPrediction>.from(predictions);
    newPredictions[prediction.matchId] = prediction;

    return copyWith(
      predictions: newPredictions,
      isLoading: false,
      clearLoadingMatchId: true,
      clearError: true,
    );
  }

  /// Remove a prediction
  WorldCupAIState withoutPrediction(String matchId) {
    final newPredictions = Map<String, AIMatchPrediction>.from(predictions);
    newPredictions.remove(matchId);

    return copyWith(predictions: newPredictions);
  }

  /// Set loading state for a match
  WorldCupAIState withLoading(String matchId) {
    return copyWith(
      isLoading: true,
      loadingMatchId: matchId,
      clearError: true,
    );
  }

  /// Set error state
  WorldCupAIState withError(String matchId, String errorMessage) {
    return copyWith(
      isLoading: false,
      clearLoadingMatchId: true,
      error: errorMessage,
      errorMatchId: matchId,
    );
  }

  @override
  String toString() =>
      'WorldCupAIState(predictions: ${predictions.length}, isLoading: $isLoading, error: $error)';
}

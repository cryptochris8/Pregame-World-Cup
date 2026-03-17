/// Interface for venue data used by AI scoring and fallback recommendation
/// helpers. Provides a type-safe contract so callers no longer need to rely
/// on `dynamic` dispatch.
abstract class ScoredVenueData {
  /// Display name of the venue (may be null for unknown venues).
  String? get name;

  /// Average user rating (e.g. 4.5 out of 5).
  double? get rating;

  /// Distance from the reference point in **kilometres**.
  double? get distance;

  /// Google Places type tags (e.g. `['restaurant', 'bar']`).
  List<String>? get types;

  /// Google Places price level (0–4).
  int? get priceLevel;
}

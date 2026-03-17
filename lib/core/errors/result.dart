import 'app_error.dart';

/// A discriminated union representing either a successful value or a failure.
///
/// ```dart
/// final result = await fetchUser(id);
/// switch (result) {
///   case Success(:final value):
///     print('Got user: ${value.name}');
///   case Failure(:final error):
///     print('Error: ${error.message}');
/// }
/// ```
sealed class Result<T> {
  const Result();

  /// `true` when this is a [Success].
  bool get isSuccess => this is Success<T>;

  /// `true` when this is a [Failure].
  bool get isFailure => this is Failure<T>;

  /// Returns the value if [Success], otherwise `null`.
  T? get valueOrNull => switch (this) {
        Success(:final value) => value,
        Failure() => null,
      };

  /// Returns the value if [Success], otherwise [fallback].
  T getOrElse(T fallback) => switch (this) {
        Success(:final value) => value,
        Failure() => fallback,
      };

  /// Returns the [AppError] if [Failure], otherwise `null`.
  AppError? get errorOrNull => switch (this) {
        Success() => null,
        Failure(:final error) => error,
      };

  /// Transforms the success value, leaving failures untouched.
  Result<R> map<R>(R Function(T value) transform) => switch (this) {
        Success(:final value) => Success(transform(value)),
        Failure(:final error) => Failure(error),
      };

  /// Transforms the success value into another [Result].
  Result<R> flatMap<R>(Result<R> Function(T value) transform) => switch (this) {
        Success(:final value) => transform(value),
        Failure(:final error) => Failure(error),
      };
}

/// Represents a successful result containing a [value].
class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);

  @override
  String toString() => 'Success($value)';
}

/// Represents a failed result containing an [error].
class Failure<T> extends Result<T> {
  final AppError error;
  const Failure(this.error);

  @override
  String toString() => 'Failure($error)';
}

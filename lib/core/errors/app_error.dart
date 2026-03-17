/// Unified error hierarchy for the application.
///
/// Using a sealed class lets consumers exhaustively switch over all possible
/// error kinds without a default branch.
sealed class AppError {
  /// Human-readable message for logging / display.
  final String message;

  /// Optional underlying exception or error.
  final Object? cause;

  const AppError(this.message, {this.cause});

  @override
  String toString() => '$runtimeType: $message';
}

/// A network-level error (timeout, no connectivity, DNS failure, etc.).
class NetworkError extends AppError {
  const NetworkError(super.message, {super.cause});
}

/// An authentication or authorisation error (expired token, 401/403, etc.).
class AuthError extends AppError {
  const AuthError(super.message, {super.cause});
}

/// Input validation failed (form fields, query parameters, etc.).
class ValidationError extends AppError {
  /// Optional map of field name -> error message.
  final Map<String, String>? fieldErrors;

  const ValidationError(super.message, {super.cause, this.fieldErrors});
}

/// A server-side error (5xx, Cloud Function failure, etc.).
class ServerError extends AppError {
  /// HTTP status code, if applicable.
  final int? statusCode;

  const ServerError(super.message, {super.cause, this.statusCode});
}

/// A local cache read/write error (Hive, SharedPreferences, etc.).
class CacheError extends AppError {
  const CacheError(super.message, {super.cause});
}

/// Requested resource was not found (404, missing document, etc.).
class NotFoundError extends AppError {
  const NotFoundError(super.message, {super.cause});
}

/// Catch-all for errors that don't fit other categories.
class UnknownError extends AppError {
  const UnknownError(super.message, {super.cause});
}

import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/errors/app_error.dart';

void main() {
  group('AppError', () {
    test('NetworkError stores message and cause', () {
      final cause = Exception('socket closed');
      final error = NetworkError('Connection failed', cause: cause);

      expect(error.message, equals('Connection failed'));
      expect(error.cause, equals(cause));
      expect(error.toString(), contains('NetworkError'));
      expect(error.toString(), contains('Connection failed'));
    });

    test('AuthError stores message', () {
      const error = AuthError('Token expired');
      expect(error.message, equals('Token expired'));
      expect(error.cause, isNull);
    });

    test('ValidationError stores field errors', () {
      const error = ValidationError(
        'Invalid input',
        fieldErrors: {'email': 'Invalid email format'},
      );
      expect(error.message, equals('Invalid input'));
      expect(error.fieldErrors, isNotNull);
      expect(error.fieldErrors!['email'], equals('Invalid email format'));
    });

    test('ValidationError without field errors', () {
      const error = ValidationError('Invalid input');
      expect(error.fieldErrors, isNull);
    });

    test('ServerError stores status code', () {
      const error = ServerError('Internal error', statusCode: 500);
      expect(error.message, equals('Internal error'));
      expect(error.statusCode, equals(500));
    });

    test('ServerError without status code', () {
      const error = ServerError('Internal error');
      expect(error.statusCode, isNull);
    });

    test('CacheError stores message', () {
      const error = CacheError('Failed to read cache');
      expect(error.message, equals('Failed to read cache'));
    });

    test('NotFoundError stores message', () {
      const error = NotFoundError('User not found');
      expect(error.message, equals('User not found'));
    });

    test('UnknownError stores message and cause', () {
      final cause = StateError('bad state');
      final error = UnknownError('Something went wrong', cause: cause);
      expect(error.message, equals('Something went wrong'));
      expect(error.cause, equals(cause));
    });

    test('exhaustive switch over all error types', () {
      const errors = <AppError>[
        NetworkError('net'),
        AuthError('auth'),
        ValidationError('val'),
        ServerError('srv'),
        CacheError('cache'),
        NotFoundError('404'),
        UnknownError('unknown'),
      ];

      final types = errors.map((e) => switch (e) {
            NetworkError() => 'network',
            AuthError() => 'auth',
            ValidationError() => 'validation',
            ServerError() => 'server',
            CacheError() => 'cache',
            NotFoundError() => 'notFound',
            UnknownError() => 'unknown',
          }).toList();

      expect(types, equals([
        'network', 'auth', 'validation', 'server',
        'cache', 'notFound', 'unknown',
      ]));
    });

    test('all subtypes are AppError', () {
      const errors = <AppError>[
        NetworkError(''),
        AuthError(''),
        ValidationError(''),
        ServerError(''),
        CacheError(''),
        NotFoundError(''),
        UnknownError(''),
      ];

      for (final error in errors) {
        expect(error, isA<AppError>());
      }
    });
  });
}

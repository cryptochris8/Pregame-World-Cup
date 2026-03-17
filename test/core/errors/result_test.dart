import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/errors/app_error.dart';
import 'package:pregame_world_cup/core/errors/result.dart';

void main() {
  group('Result', () {
    group('Success', () {
      test('isSuccess returns true', () {
        const result = Success(42);
        expect(result.isSuccess, isTrue);
        expect(result.isFailure, isFalse);
      });

      test('valueOrNull returns the value', () {
        const result = Success('hello');
        expect(result.valueOrNull, equals('hello'));
      });

      test('getOrElse returns the value', () {
        const result = Success(10);
        expect(result.getOrElse(0), equals(10));
      });

      test('errorOrNull returns null', () {
        const result = Success(42);
        expect(result.errorOrNull, isNull);
      });

      test('toString includes value', () {
        const result = Success(42);
        expect(result.toString(), equals('Success(42)'));
      });

      test('value getter returns stored value', () {
        const result = Success<String>('test');
        expect(result.value, equals('test'));
      });
    });

    group('Failure', () {
      test('isFailure returns true', () {
        const result = Failure<int>(NetworkError('timeout'));
        expect(result.isFailure, isTrue);
        expect(result.isSuccess, isFalse);
      });

      test('valueOrNull returns null', () {
        const result = Failure<int>(NetworkError('timeout'));
        expect(result.valueOrNull, isNull);
      });

      test('getOrElse returns the fallback', () {
        const result = Failure<int>(NetworkError('timeout'));
        expect(result.getOrElse(0), equals(0));
      });

      test('errorOrNull returns the error', () {
        const result = Failure<int>(NetworkError('timeout'));
        expect(result.errorOrNull, isA<NetworkError>());
        expect(result.errorOrNull!.message, equals('timeout'));
      });

      test('toString includes error', () {
        const result = Failure<int>(NetworkError('timeout'));
        expect(result.toString(), contains('Failure'));
        expect(result.toString(), contains('NetworkError'));
      });

      test('error getter returns stored error', () {
        const result = Failure<int>(AuthError('expired'));
        expect(result.error, isA<AuthError>());
      });
    });

    group('map', () {
      test('transforms Success value', () {
        const result = Success(5);
        final mapped = result.map((v) => v * 2);
        expect(mapped.isSuccess, isTrue);
        expect(mapped.valueOrNull, equals(10));
      });

      test('passes through Failure', () {
        const Result<int> result = Failure(NetworkError('err'));
        final mapped = result.map((v) => v * 2);
        expect(mapped.isFailure, isTrue);
        expect(mapped.errorOrNull!.message, equals('err'));
      });

      test('can change type', () {
        const result = Success(42);
        final mapped = result.map((v) => v.toString());
        expect(mapped.isSuccess, isTrue);
        expect(mapped.valueOrNull, equals('42'));
      });
    });

    group('flatMap', () {
      test('chains Success results', () {
        const result = Success(5);
        final chained = result.flatMap((v) => Success(v * 3));
        expect(chained.isSuccess, isTrue);
        expect(chained.valueOrNull, equals(15));
      });

      test('short-circuits on Failure', () {
        const Result<int> result = Failure(AuthError('denied'));
        final chained = result.flatMap((v) => Success(v * 3));
        expect(chained.isFailure, isTrue);
        expect(chained.errorOrNull!.message, equals('denied'));
      });

      test('can return Failure from Success', () {
        const result = Success(5);
        final chained = result.flatMap<String>(
          (v) => const Failure(ValidationError('too small')),
        );
        expect(chained.isFailure, isTrue);
        expect(chained.errorOrNull, isA<ValidationError>());
      });
    });

    group('pattern matching', () {
      test('exhaustive switch works', () {
        const Result<int> success = Success(42);
        const Result<int> failure = Failure(NetworkError('err'));

        final successLabel = switch (success) {
          Success(:final value) => 'got $value',
          Failure(:final error) => 'err: ${error.message}',
        };

        final failureLabel = switch (failure) {
          Success(:final value) => 'got $value',
          Failure(:final error) => 'err: ${error.message}',
        };

        expect(successLabel, equals('got 42'));
        expect(failureLabel, equals('err: err'));
      });
    });
  });
}

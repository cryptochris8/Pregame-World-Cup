import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/config/api_keys.dart';

/// Tests for the ApiKeys configuration class.
///
/// Note: API keys are loaded from compile-time environment variables
/// (String.fromEnvironment). In the test environment, these variables are
/// NOT set, so all keys default to empty strings. This is the expected
/// behavior in development/test.
void main() {
  // ============================================================================
  // Default values (no env vars set in test)
  // ============================================================================
  group('ApiKeys default values', () {
    test('googlePlaces defaults to empty string', () {
      expect(ApiKeys.googlePlaces, isEmpty);
    });

    test('sportsDataIo defaults to empty string', () {
      expect(ApiKeys.sportsDataIo, isEmpty);
    });

    test('openAI defaults to empty string', () {
      expect(ApiKeys.openAI, isEmpty);
    });

    test('claude defaults to empty string', () {
      expect(ApiKeys.claude, isEmpty);
    });

    test('stripePublishableKey defaults to empty string', () {
      expect(ApiKeys.stripePublishableKey, isEmpty);
    });

    test('revenueCatIos defaults to empty string', () {
      expect(ApiKeys.revenueCatIos, isEmpty);
    });

    test('revenueCatAndroid defaults to empty string', () {
      expect(ApiKeys.revenueCatAndroid, isEmpty);
    });

    test('cloudFunctionsBaseUrl has a non-empty default', () {
      expect(ApiKeys.cloudFunctionsBaseUrl, isNotEmpty);
    });

    test('cloudFunctionsBaseUrl points to pregame Firebase project', () {
      expect(ApiKeys.cloudFunctionsBaseUrl,
          'https://us-central1-pregame-b089e.cloudfunctions.net');
    });
  });

  // ============================================================================
  // validateApiKeys
  // ============================================================================
  group('validateApiKeys', () {
    test('returns false when API keys are not set (test environment)', () {
      // In the test environment, no compile-time env vars are set,
      // so all keys default to empty strings and validation fails.
      expect(ApiKeys.validateApiKeys(), false);
    });

    test('is a static method that returns a bool', () {
      final result = ApiKeys.validateApiKeys();
      expect(result, isA<bool>());
    });
  });

  // ============================================================================
  // isDevelopment
  // ============================================================================
  group('isDevelopment', () {
    test('returns true in test environment (no ENVIRONMENT variable set)', () {
      // When ENVIRONMENT is not set, it defaults to 'development',
      // which means isDevelopment should be true.
      expect(ApiKeys.isDevelopment, true);
    });

    test('is a boolean getter', () {
      expect(ApiKeys.isDevelopment, isA<bool>());
    });
  });

  // ============================================================================
  // Structure validation
  // ============================================================================
  group('ApiKeys structure', () {
    test('all key fields are String type', () {
      expect(ApiKeys.googlePlaces, isA<String>());
      expect(ApiKeys.sportsDataIo, isA<String>());
      expect(ApiKeys.openAI, isA<String>());
      expect(ApiKeys.claude, isA<String>());
      expect(ApiKeys.stripePublishableKey, isA<String>());
      expect(ApiKeys.revenueCatIos, isA<String>());
      expect(ApiKeys.revenueCatAndroid, isA<String>());
      expect(ApiKeys.cloudFunctionsBaseUrl, isA<String>());
    });

    test('cloudFunctionsBaseUrl is a valid HTTPS URL', () {
      final url = ApiKeys.cloudFunctionsBaseUrl;
      expect(url.startsWith('https://'), true);
      expect(Uri.tryParse(url), isNotNull);
      expect(Uri.parse(url).hasScheme, true);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/domain/services/payment_models.dart';
import 'package:pregame_world_cup/services/revenuecat_service.dart';

/// Tests for RevenueCatService and its result models.
///
/// Note: RevenueCatService is a singleton that uses:
/// - Platform.isIOS (dart:io) - not mockable in standard test environment
/// - Purchases SDK static methods (RevenueCat native SDK)
/// - FirebaseAuth.instance for user login
/// - ApiKeys constants loaded from environment
///
/// Direct instantiation of RevenueCatService() in tests triggers
/// the singleton factory which accesses Platform.isIOS at property-read
/// time (isConfigured getter). This makes full integration testing
/// impractical without DI refactoring.
///
/// This test file focuses on:
/// 1. PurchaseResult model
/// 2. RestoreResult model
/// 3. Product ID constants
/// 4. Entitlement ID contracts
/// 5. Service class existence and public API shape
void main() {
  // ============================================================================
  // PurchaseResult model
  // ============================================================================
  group('PurchaseResult', () {
    test('creates successful result', () {
      final result = PurchaseResult(success: true);

      expect(result.success, isTrue);
      expect(result.errorMessage, isNull);
      expect(result.userCancelled, isFalse);
      expect(result.customerInfo, isNull);
    });

    test('creates failed result with error message', () {
      final result = PurchaseResult(
        success: false,
        errorMessage: 'Payment declined',
      );

      expect(result.success, isFalse);
      expect(result.errorMessage, 'Payment declined');
      expect(result.userCancelled, isFalse);
    });

    test('creates user cancelled result', () {
      final result = PurchaseResult(
        success: false,
        errorMessage: 'Purchase was cancelled',
        userCancelled: true,
      );

      expect(result.success, isFalse);
      expect(result.userCancelled, isTrue);
      expect(result.errorMessage, 'Purchase was cancelled');
    });

    test('defaults userCancelled to false', () {
      final result = PurchaseResult(success: false);

      expect(result.userCancelled, isFalse);
    });

    test('customerInfo defaults to null', () {
      final result = PurchaseResult(success: true);

      expect(result.customerInfo, isNull);
    });

    test('can create result with all fields set', () {
      final result = PurchaseResult(
        success: false,
        errorMessage: 'Network error',
        userCancelled: false,
        customerInfo: null,
      );

      expect(result.success, isFalse);
      expect(result.errorMessage, 'Network error');
      expect(result.userCancelled, isFalse);
    });
  });

  // ============================================================================
  // RestoreResult model
  // ============================================================================
  group('RestoreResult', () {
    test('creates successful restore with purchases', () {
      final result = RestoreResult(
        success: true,
        hasRestoredPurchases: true,
        restoredPassType: FanPassType.superfanPass,
      );

      expect(result.success, isTrue);
      expect(result.hasRestoredPurchases, isTrue);
      expect(result.restoredPassType, FanPassType.superfanPass);
      expect(result.errorMessage, isNull);
      expect(result.customerInfo, isNull);
    });

    test('creates successful restore without purchases', () {
      final result = RestoreResult(
        success: true,
        hasRestoredPurchases: false,
      );

      expect(result.success, isTrue);
      expect(result.hasRestoredPurchases, isFalse);
      expect(result.restoredPassType, FanPassType.free);
    });

    test('creates failed restore with error', () {
      final result = RestoreResult(
        success: false,
        errorMessage: 'Failed to restore purchases. Please try again.',
      );

      expect(result.success, isFalse);
      expect(result.errorMessage, contains('Failed'));
      expect(result.hasRestoredPurchases, isFalse);
    });

    test('defaults hasRestoredPurchases to false', () {
      final result = RestoreResult(success: true);
      expect(result.hasRestoredPurchases, isFalse);
    });

    test('defaults restoredPassType to free', () {
      final result = RestoreResult(success: true);
      expect(result.restoredPassType, FanPassType.free);
    });

    test('defaults errorMessage to null', () {
      final result = RestoreResult(success: true);
      expect(result.errorMessage, isNull);
    });

    test('defaults customerInfo to null', () {
      final result = RestoreResult(success: true);
      expect(result.customerInfo, isNull);
    });

    test('restoreResult with fanPass type', () {
      final result = RestoreResult(
        success: true,
        hasRestoredPurchases: true,
        restoredPassType: FanPassType.fanPass,
      );

      expect(result.restoredPassType, FanPassType.fanPass);
    });
  });

  // ============================================================================
  // Product ID constants
  // ============================================================================
  group('RevenueCatService - product IDs', () {
    test('fanPassProductId follows App Store/Play Store convention', () {
      expect(
        RevenueCatService.fanPassProductId,
        'com.christophercampbell.pregameworldcup.fan_pass',
      );
    });

    test('superfanPassProductId follows App Store/Play Store convention', () {
      expect(
        RevenueCatService.superfanPassProductId,
        'com.christophercampbell.pregameworldcup.superfan_pass',
      );
    });

    test('product IDs start with package name', () {
      const packagePrefix = 'com.christophercampbell.pregameworldcup';

      expect(RevenueCatService.fanPassProductId, startsWith(packagePrefix));
      expect(RevenueCatService.superfanPassProductId, startsWith(packagePrefix));
    });

    test('fan pass and superfan pass product IDs are different', () {
      expect(
        RevenueCatService.fanPassProductId,
        isNot(equals(RevenueCatService.superfanPassProductId)),
      );
    });

    test('product IDs contain their pass type suffix', () {
      expect(RevenueCatService.fanPassProductId, endsWith('.fan_pass'));
      expect(RevenueCatService.superfanPassProductId, endsWith('.superfan_pass'));
    });
  });

  // ============================================================================
  // Service class structure
  // ============================================================================
  group('RevenueCatService - class structure', () {
    test('class type exists', () {
      expect(RevenueCatService, isA<Type>());
    });

    test('PurchaseResult type exists', () {
      expect(PurchaseResult, isA<Type>());
    });

    test('RestoreResult type exists', () {
      expect(RestoreResult, isA<Type>());
    });
  });

  // ============================================================================
  // PurchaseResult edge cases
  // ============================================================================
  group('PurchaseResult - edge cases', () {
    test('success true with error message is a valid state', () {
      // This is technically valid (e.g. partial success with warning)
      final result = PurchaseResult(
        success: true,
        errorMessage: 'Warning: verification pending',
      );

      expect(result.success, isTrue);
      expect(result.errorMessage, isNotNull);
    });

    test('userCancelled true with success false is standard cancel flow', () {
      final result = PurchaseResult(
        success: false,
        userCancelled: true,
      );

      expect(result.success, isFalse);
      expect(result.userCancelled, isTrue);
    });

    test('empty error message is valid', () {
      final result = PurchaseResult(
        success: false,
        errorMessage: '',
      );

      expect(result.errorMessage, '');
    });
  });

  // ============================================================================
  // RestoreResult edge cases
  // ============================================================================
  group('RestoreResult - edge cases', () {
    test('successful with no restored purchases and free pass type', () {
      // User has no previous purchases to restore
      final result = RestoreResult(
        success: true,
        hasRestoredPurchases: false,
        restoredPassType: FanPassType.free,
      );

      expect(result.success, isTrue);
      expect(result.hasRestoredPurchases, isFalse);
      expect(result.restoredPassType, FanPassType.free);
    });

    test('failed but with restoredPassType set (should not happen but valid)', () {
      final result = RestoreResult(
        success: false,
        hasRestoredPurchases: false,
        restoredPassType: FanPassType.superfanPass,
        errorMessage: 'Partial failure',
      );

      expect(result.success, isFalse);
      expect(result.restoredPassType, FanPassType.superfanPass);
    });
  });
}

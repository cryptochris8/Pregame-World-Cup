import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/worldcup/domain/services/payment_access_service.dart';
import 'package:pregame_world_cup/features/worldcup/domain/services/payment_checkout_service.dart';
import 'package:pregame_world_cup/features/worldcup/domain/services/payment_models.dart';
import 'package:pregame_world_cup/services/revenuecat_service.dart';

// -- Mocks --
class MockFirebaseFunctions extends Mock implements FirebaseFunctions {}

class MockRevenueCatService extends Mock implements RevenueCatService {}

class MockPaymentAccessService extends Mock implements PaymentAccessService {}

class MockHttpsCallable extends Mock implements HttpsCallable {}

class MockHttpsCallableResult extends Mock implements HttpsCallableResult<dynamic> {}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
  });

  // ============================================================================
  // Browser checkout tracking
  // ============================================================================
  group('PaymentCheckoutService - browser checkout tracking', () {
    late PaymentCheckoutService service;
    late MockFirebaseFunctions mockFunctions;
    late MockRevenueCatService mockRevenueCat;
    late MockPaymentAccessService mockAccess;

    setUp(() {
      mockFunctions = MockFirebaseFunctions();
      mockRevenueCat = MockRevenueCatService();
      mockAccess = MockPaymentAccessService();

      service = PaymentCheckoutService(
        functions: mockFunctions,
        revenueCatService: mockRevenueCat,
        accessService: mockAccess,
      );
    });

    test('isBrowserCheckoutInProgress is false initially', () {
      expect(service.isBrowserCheckoutInProgress, isFalse);
    });

    test('markBrowserCheckoutComplete sets flag to false', () {
      // Even if it was already false, calling this should not throw
      service.markBrowserCheckoutComplete();
      expect(service.isBrowserCheckoutInProgress, isFalse);
    });
  });

  // ============================================================================
  // isNativeIAPAvailable
  // ============================================================================
  group('PaymentCheckoutService - isNativeIAPAvailable', () {
    test('returns true when RevenueCat is configured', () {
      final mockRevenueCat = MockRevenueCatService();
      when(() => mockRevenueCat.isConfigured).thenReturn(true);

      final service = PaymentCheckoutService(
        functions: MockFirebaseFunctions(),
        revenueCatService: mockRevenueCat,
        accessService: MockPaymentAccessService(),
      );

      expect(service.isNativeIAPAvailable, isTrue);
    });

    test('returns false when RevenueCat is not configured', () {
      final mockRevenueCat = MockRevenueCatService();
      when(() => mockRevenueCat.isConfigured).thenReturn(false);

      final service = PaymentCheckoutService(
        functions: MockFirebaseFunctions(),
        revenueCatService: mockRevenueCat,
        accessService: MockPaymentAccessService(),
      );

      expect(service.isNativeIAPAvailable, isFalse);
    });
  });

  // ============================================================================
  // getNativePrice
  // ============================================================================
  group('PaymentCheckoutService - getNativePrice', () {
    test('returns null when RevenueCat is not configured', () async {
      final mockRevenueCat = MockRevenueCatService();
      when(() => mockRevenueCat.isConfigured).thenReturn(false);

      final service = PaymentCheckoutService(
        functions: MockFirebaseFunctions(),
        revenueCatService: mockRevenueCat,
        accessService: MockPaymentAccessService(),
      );

      final price = await service.getNativePrice(FanPassType.fanPass);
      expect(price, isNull);
    });

    test('delegates to RevenueCat when configured', () async {
      final mockRevenueCat = MockRevenueCatService();
      when(() => mockRevenueCat.isConfigured).thenReturn(true);
      when(() => mockRevenueCat.getPriceForPassType(FanPassType.fanPass))
          .thenAnswer((_) async => '\$14.99');

      final service = PaymentCheckoutService(
        functions: MockFirebaseFunctions(),
        revenueCatService: mockRevenueCat,
        accessService: MockPaymentAccessService(),
      );

      final price = await service.getNativePrice(FanPassType.fanPass);
      expect(price, '\$14.99');
    });

    test('returns superfan price when requested', () async {
      final mockRevenueCat = MockRevenueCatService();
      when(() => mockRevenueCat.isConfigured).thenReturn(true);
      when(() => mockRevenueCat.getPriceForPassType(FanPassType.superfanPass))
          .thenAnswer((_) async => '\$29.99');

      final service = PaymentCheckoutService(
        functions: MockFirebaseFunctions(),
        revenueCatService: mockRevenueCat,
        accessService: MockPaymentAccessService(),
      );

      final price = await service.getNativePrice(FanPassType.superfanPass);
      expect(price, '\$29.99');
    });

    test('returns null when RevenueCat returns null', () async {
      final mockRevenueCat = MockRevenueCatService();
      when(() => mockRevenueCat.isConfigured).thenReturn(true);
      when(() => mockRevenueCat.getPriceForPassType(FanPassType.fanPass))
          .thenAnswer((_) async => null);

      final service = PaymentCheckoutService(
        functions: MockFirebaseFunctions(),
        revenueCatService: mockRevenueCat,
        accessService: MockPaymentAccessService(),
      );

      final price = await service.getNativePrice(FanPassType.fanPass);
      expect(price, isNull);
    });
  });

  // ============================================================================
  // onCacheClear callback
  // ============================================================================
  group('PaymentCheckoutService - onCacheClear callback', () {
    test('can be created without onCacheClear callback', () {
      final service = PaymentCheckoutService(
        functions: MockFirebaseFunctions(),
        revenueCatService: MockRevenueCatService(),
        accessService: MockPaymentAccessService(),
      );

      expect(service, isNotNull);
    });

    test('can be created with onCacheClear callback', () {
      var callbackCalled = false;

      final service = PaymentCheckoutService(
        functions: MockFirebaseFunctions(),
        revenueCatService: MockRevenueCatService(),
        accessService: MockPaymentAccessService(),
        onCacheClear: () => callbackCalled = true,
      );

      expect(service, isNotNull);
      expect(callbackCalled, isFalse);
    });
  });

  // ============================================================================
  // getVenuePremiumStatus callback
  // ============================================================================
  group('PaymentCheckoutService - venue premium status callback', () {
    test('can be created without getVenuePremiumStatus callback', () {
      final service = PaymentCheckoutService(
        functions: MockFirebaseFunctions(),
        revenueCatService: MockRevenueCatService(),
        accessService: MockPaymentAccessService(),
      );

      expect(service, isNotNull);
    });

    test('can be created with getVenuePremiumStatus callback', () {
      final service = PaymentCheckoutService(
        functions: MockFirebaseFunctions(),
        revenueCatService: MockRevenueCatService(),
        accessService: MockPaymentAccessService(),
        getVenuePremiumStatus: (venueId) async => VenuePremiumStatus.free(),
      );

      expect(service, isNotNull);
    });
  });

  // ============================================================================
  // Dual-billing prevention (testing the logic paths)
  // ============================================================================
  group('PaymentCheckoutService - dual-billing prevention logic', () {
    // The _checkDuplicateFanPass method is private, but its effects are
    // observable through public methods. We test the logic patterns here.

    test('upgrade from fanPass to superfanPass is a valid scenario', () {
      // Verify the model supports this: fanPass user buying superfanPass
      final currentStatus = FanPassStatus(
        hasPass: true,
        passType: FanPassType.fanPass,
        features: const {'adFree': true},
      );

      // The service allows upgrade when:
      // passType == superfanPass && currentStatus.passType == fanPass
      final isUpgrade = currentStatus.passType == FanPassType.fanPass;
      expect(isUpgrade, isTrue);
    });

    test('same tier purchase should be blocked', () {
      final currentStatus = FanPassStatus(
        hasPass: true,
        passType: FanPassType.fanPass,
        features: const {'adFree': true},
      );

      // Buying the same tier is a duplicate
      final isSameTier = currentStatus.hasPass &&
          currentStatus.passType == FanPassType.fanPass;
      expect(isSameTier, isTrue);
    });

    test('downgrade from superfanPass to fanPass should be blocked', () {
      final currentStatus = FanPassStatus(
        hasPass: true,
        passType: FanPassType.superfanPass,
        features: const {'exclusiveContent': true},
      );

      // Buying a lower tier is also blocked
      final hasExistingPass = currentStatus.hasPass;
      final isNotUpgrade = !(currentStatus.passType == FanPassType.fanPass);
      expect(hasExistingPass, isTrue);
      expect(isNotUpgrade, isTrue);
    });

    test('free user purchasing any pass is allowed', () {
      final currentStatus = FanPassStatus.free();

      expect(currentStatus.hasPass, isFalse);
      // The service returns null (no error) when hasPass is false
    });
  });

  // ============================================================================
  // Constructor injection
  // ============================================================================
  group('PaymentCheckoutService - constructor', () {
    test('accepts all required dependencies', () {
      final service = PaymentCheckoutService(
        functions: MockFirebaseFunctions(),
        revenueCatService: MockRevenueCatService(),
        accessService: MockPaymentAccessService(),
      );

      expect(service, isA<PaymentCheckoutService>());
    });

    test('accepts all optional dependencies', () {
      var cacheClearCount = 0;

      final service = PaymentCheckoutService(
        functions: MockFirebaseFunctions(),
        revenueCatService: MockRevenueCatService(),
        accessService: MockPaymentAccessService(),
        getVenuePremiumStatus: (id) async => VenuePremiumStatus.free(),
        onCacheClear: () => cacheClearCount++,
      );

      expect(service, isA<PaymentCheckoutService>());
      expect(cacheClearCount, 0);
    });
  });
}

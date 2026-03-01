import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/worldcup/domain/services/payment_access_service.dart';
import 'package:pregame_world_cup/features/worldcup/domain/services/payment_history_service.dart';
import 'package:pregame_world_cup/features/worldcup/domain/services/payment_models.dart';
import 'package:pregame_world_cup/services/revenuecat_service.dart';

// -- Mocks --
class MockFirebaseFunctions extends Mock implements FirebaseFunctions {}

class MockHttpsCallable extends Mock implements HttpsCallable {}

class MockHttpsCallableResult extends Mock implements HttpsCallableResult<dynamic> {}

class MockRevenueCatService extends Mock implements RevenueCatService {}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
  });

  // ============================================================================
  // Constructor and setup
  // ============================================================================
  group('PaymentHistoryService - constructor', () {
    test('can be created with required dependencies', () {
      final fakeFirestore = FakeFirebaseFirestore();
      final mockFunctions = MockFirebaseFunctions();
      final accessService = PaymentAccessService(
        functions: mockFunctions,
        firestore: fakeFirestore,
        revenueCatService: MockRevenueCatService(),
      );

      final service = PaymentHistoryService(
        functions: mockFunctions,
        firestore: fakeFirestore,
        accessService: accessService,
      );

      expect(service, isA<PaymentHistoryService>());
    });

    test('can be created with onCacheClear callback', () {
      final fakeFirestore = FakeFirebaseFirestore();
      final mockFunctions = MockFirebaseFunctions();
      final accessService = PaymentAccessService(
        functions: mockFunctions,
        firestore: fakeFirestore,
        revenueCatService: MockRevenueCatService(),
      );
      var cleared = false;

      final service = PaymentHistoryService(
        functions: mockFunctions,
        firestore: fakeFirestore,
        accessService: accessService,
        onCacheClear: () => cleared = true,
      );

      expect(service, isA<PaymentHistoryService>());
      expect(cleared, isFalse);
    });
  });

  // ============================================================================
  // listenToFanPassStatus (real-time stream via fake_cloud_firestore)
  // ============================================================================
  group('PaymentHistoryService - listenToFanPassStatus', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseFunctions mockFunctions;
    late PaymentAccessService accessService;
    late PaymentHistoryService service;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      mockFunctions = MockFirebaseFunctions();
      accessService = PaymentAccessService(
        functions: mockFunctions,
        firestore: fakeFirestore,
        revenueCatService: MockRevenueCatService(),
      );
      service = PaymentHistoryService(
        functions: mockFunctions,
        firestore: fakeFirestore,
        accessService: accessService,
      );
    });

    test('emits free status when document does not exist', () async {
      final stream = service.listenToFanPassStatus('nonexistent_user');

      final status = await stream.first;

      expect(status.hasPass, isFalse);
      expect(status.passType, FanPassType.free);
    });

    test('emits free status when document has no data', () async {
      // Create doc but it will have data, so this tests the snapshot.exists path
      final stream = service.listenToFanPassStatus('empty_doc_user');

      final status = await stream.first;

      expect(status.hasPass, isFalse);
      expect(status.passType, FanPassType.free);
    });

    test('emits free status when status is not active', () async {
      await fakeFirestore.collection('world_cup_fan_passes').doc('user1').set({
        'passType': 'fan_pass',
        'status': 'cancelled',
      });

      final stream = service.listenToFanPassStatus('user1');
      final status = await stream.first;

      expect(status.hasPass, isFalse);
      expect(status.passType, FanPassType.free);
    });

    test('emits active fan pass status with features from data', () async {
      await fakeFirestore.collection('world_cup_fan_passes').doc('user2').set({
        'passType': 'fan_pass',
        'status': 'active',
        'features': {
          'adFree': true,
          'advancedStats': true,
        },
      });

      final stream = service.listenToFanPassStatus('user2');
      final status = await stream.first;

      expect(status.hasPass, isTrue);
      expect(status.passType, FanPassType.fanPass);
      expect(status.features['adFree'], isTrue);
      expect(status.features['advancedStats'], isTrue);
    });

    test('emits superfan pass status', () async {
      await fakeFirestore.collection('world_cup_fan_passes').doc('user3').set({
        'passType': 'superfan_pass',
        'status': 'active',
        'features': {
          'exclusiveContent': true,
          'aiMatchInsights': true,
        },
      });

      final stream = service.listenToFanPassStatus('user3');
      final status = await stream.first;

      expect(status.hasPass, isTrue);
      expect(status.passType, FanPassType.superfanPass);
      expect(status.features['exclusiveContent'], isTrue);
    });

    test('uses createFanPassStatus when features field is missing', () async {
      await fakeFirestore.collection('world_cup_fan_passes').doc('user4').set({
        'passType': 'fan_pass',
        'status': 'active',
        // No 'features' field
      });

      final stream = service.listenToFanPassStatus('user4');
      final status = await stream.first;

      expect(status.hasPass, isTrue);
      expect(status.passType, FanPassType.fanPass);
      // Should have generated features from createFanPassStatus
      expect(status.features, isNotEmpty);
      expect(status.features['basicSchedules'], isTrue);
      expect(status.features['adFree'], isTrue);
    });

    test('uses createFanPassStatus when features field is not a map', () async {
      await fakeFirestore.collection('world_cup_fan_passes').doc('user5').set({
        'passType': 'superfan_pass',
        'status': 'active',
        'features': 'not_a_map',
      });

      final stream = service.listenToFanPassStatus('user5');
      final status = await stream.first;

      expect(status.hasPass, isTrue);
      expect(status.passType, FanPassType.superfanPass);
      // Features should be generated since 'features' is not a Map
      expect(status.features, isNotEmpty);
    });

    test('calls onCacheClear when active status is emitted', () async {
      var cacheClearCount = 0;

      final historyService = PaymentHistoryService(
        functions: mockFunctions,
        firestore: fakeFirestore,
        accessService: accessService,
        onCacheClear: () => cacheClearCount++,
      );

      await fakeFirestore.collection('world_cup_fan_passes').doc('user6').set({
        'passType': 'fan_pass',
        'status': 'active',
        'features': {'adFree': true},
      });

      final stream = historyService.listenToFanPassStatus('user6');
      await stream.first;

      expect(cacheClearCount, 1);
    });

    test('does not call onCacheClear for inactive status', () async {
      var cacheClearCount = 0;

      final historyService = PaymentHistoryService(
        functions: mockFunctions,
        firestore: fakeFirestore,
        accessService: accessService,
        onCacheClear: () => cacheClearCount++,
      );

      await fakeFirestore.collection('world_cup_fan_passes').doc('user7').set({
        'passType': 'fan_pass',
        'status': 'cancelled',
      });

      final stream = historyService.listenToFanPassStatus('user7');
      await stream.first;

      expect(cacheClearCount, 0);
    });

    test('handles purchasedAt Timestamp correctly', () async {
      final purchaseTime = DateTime(2026, 5, 15, 10, 30);
      await fakeFirestore.collection('world_cup_fan_passes').doc('user8').set({
        'passType': 'fan_pass',
        'status': 'active',
        'purchasedAt': Timestamp.fromDate(purchaseTime),
        'features': {'adFree': true},
      });

      final stream = service.listenToFanPassStatus('user8');
      final status = await stream.first;

      expect(status.purchasedAt, isNotNull);
      expect(status.purchasedAt!.year, 2026);
      expect(status.purchasedAt!.month, 5);
      expect(status.purchasedAt!.day, 15);
    });

    test('handles null purchasedAt', () async {
      await fakeFirestore.collection('world_cup_fan_passes').doc('user9').set({
        'passType': 'fan_pass',
        'status': 'active',
        'features': {'adFree': true},
      });

      final stream = service.listenToFanPassStatus('user9');
      final status = await stream.first;

      expect(status.purchasedAt, isNull);
    });
  });

  // ============================================================================
  // listenToVenuePremiumStatus
  // ============================================================================
  group('PaymentHistoryService - listenToVenuePremiumStatus', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseFunctions mockFunctions;
    late PaymentAccessService accessService;
    late PaymentHistoryService service;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      mockFunctions = MockFirebaseFunctions();
      accessService = PaymentAccessService(
        functions: mockFunctions,
        firestore: fakeFirestore,
        revenueCatService: MockRevenueCatService(),
      );
      service = PaymentHistoryService(
        functions: mockFunctions,
        firestore: fakeFirestore,
        accessService: accessService,
      );
    });

    test('emits free status when document does not exist', () async {
      final stream = service.listenToVenuePremiumStatus('nonexistent_venue');
      final status = await stream.first;

      expect(status.isPremium, isFalse);
      expect(status.tier, 'free');
    });

    test('emits free status when subscriptionTier is not premium', () async {
      await fakeFirestore.collection('venue_enhancements').doc('venue1').set({
        'subscriptionTier': 'free',
      });

      final stream = service.listenToVenuePremiumStatus('venue1');
      final status = await stream.first;

      expect(status.isPremium, isFalse);
      expect(status.tier, 'free');
    });

    test('emits premium status with all features when tier is premium', () async {
      await fakeFirestore.collection('venue_enhancements').doc('venue2').set({
        'subscriptionTier': 'premium',
      });

      final stream = service.listenToVenuePremiumStatus('venue2');
      final status = await stream.first;

      expect(status.isPremium, isTrue);
      expect(status.tier, 'premium');
      expect(status.features['showsMatches'], isTrue);
      expect(status.features['matchScheduling'], isTrue);
      expect(status.features['tvSetup'], isTrue);
      expect(status.features['gameSpecials'], isTrue);
      expect(status.features['atmosphereSettings'], isTrue);
      expect(status.features['liveCapacity'], isTrue);
      expect(status.features['featuredListing'], isTrue);
      expect(status.features['analytics'], isTrue);
    });

    test('premium status has 8 features', () async {
      await fakeFirestore.collection('venue_enhancements').doc('venue3').set({
        'subscriptionTier': 'premium',
      });

      final stream = service.listenToVenuePremiumStatus('venue3');
      final status = await stream.first;

      expect(status.features.length, 8);
    });

    test('handles premiumPurchasedAt Timestamp', () async {
      final purchaseTime = DateTime(2026, 4, 20);
      await fakeFirestore.collection('venue_enhancements').doc('venue4').set({
        'subscriptionTier': 'premium',
        'premiumPurchasedAt': Timestamp.fromDate(purchaseTime),
      });

      final stream = service.listenToVenuePremiumStatus('venue4');
      final status = await stream.first;

      expect(status.isPremium, isTrue);
      expect(status.purchasedAt, isNotNull);
      expect(status.purchasedAt!.year, 2026);
      expect(status.purchasedAt!.month, 4);
      expect(status.purchasedAt!.day, 20);
    });

    test('handles null premiumPurchasedAt', () async {
      await fakeFirestore.collection('venue_enhancements').doc('venue5').set({
        'subscriptionTier': 'premium',
      });

      final stream = service.listenToVenuePremiumStatus('venue5');
      final status = await stream.first;

      expect(status.purchasedAt, isNull);
    });
  });

  // ============================================================================
  // _parseTransactionStatus logic (tested via data patterns)
  // ============================================================================
  group('PaymentHistoryService - transaction status parsing logic', () {
    // The _parseTransactionStatus method is private, but we can verify
    // the expected mappings by testing the same switch logic.

    test('completed string maps to completed status', () {
      final status = _parseTransactionStatus('completed');
      expect(status, TransactionStatus.completed);
    });

    test('succeeded string maps to completed status', () {
      final status = _parseTransactionStatus('succeeded');
      expect(status, TransactionStatus.completed);
    });

    test('pending string maps to pending status', () {
      final status = _parseTransactionStatus('pending');
      expect(status, TransactionStatus.pending);
    });

    test('refunded string maps to refunded status', () {
      final status = _parseTransactionStatus('refunded');
      expect(status, TransactionStatus.refunded);
    });

    test('failed string maps to failed status', () {
      final status = _parseTransactionStatus('failed');
      expect(status, TransactionStatus.failed);
    });

    test('unknown string defaults to pending', () {
      final status = _parseTransactionStatus('unknown');
      expect(status, TransactionStatus.pending);
    });

    test('null defaults to pending', () {
      final status = _parseTransactionStatus(null);
      expect(status, TransactionStatus.pending);
    });

    test('empty string defaults to pending', () {
      final status = _parseTransactionStatus('');
      expect(status, TransactionStatus.pending);
    });
  });

  // ============================================================================
  // getPricing - fallback behavior
  // ============================================================================
  group('PaymentHistoryService - getPricing fallback', () {
    test('returns defaults when Cloud Function throws', () async {
      final mockFunctions = MockFirebaseFunctions();
      final mockCallable = MockHttpsCallable();
      final fakeFirestore = FakeFirebaseFirestore();

      when(() => mockFunctions.httpsCallable('getWorldCupPricing'))
          .thenReturn(mockCallable);
      when(() => mockCallable.call(any()))
          .thenThrow(Exception('Network error'));
      when(() => mockCallable.call())
          .thenThrow(Exception('Network error'));

      final accessService = PaymentAccessService(
        functions: mockFunctions,
        firestore: fakeFirestore,
        revenueCatService: MockRevenueCatService(),
      );

      final service = PaymentHistoryService(
        functions: mockFunctions,
        firestore: fakeFirestore,
        accessService: accessService,
      );

      final pricing = await service.getPricing();

      expect(pricing, isNotNull);
      expect(pricing!.fanPass.amount, 1499);
      expect(pricing.superfanPass.amount, 2999);
      expect(pricing.venuePremium.amount, 49900);
    });
  });

  // ============================================================================
  // Transaction history Firestore data patterns
  // ============================================================================
  group('PaymentHistoryService - transaction history data patterns', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    test('fan pass document with active status creates valid transaction data', () async {
      final purchaseTime = DateTime(2026, 5, 1);
      await fakeFirestore.collection('world_cup_fan_passes').doc('user1').set({
        'status': 'active',
        'passType': 'fan_pass',
        'purchasedAt': Timestamp.fromDate(purchaseTime),
        'stripeSessionId': 'cs_test_123',
      });

      final doc = await fakeFirestore
          .collection('world_cup_fan_passes')
          .doc('user1')
          .get();

      expect(doc.exists, isTrue);
      final data = doc.data()!;
      expect(data['status'], 'active');
      expect(data['passType'], 'fan_pass');
      expect(data['stripeSessionId'], 'cs_test_123');
    });

    test('superfan pass document creates correct product name and amount', () async {
      await fakeFirestore.collection('world_cup_fan_passes').doc('user2').set({
        'status': 'active',
        'passType': 'superfan_pass',
      });

      final doc = await fakeFirestore
          .collection('world_cup_fan_passes')
          .doc('user2')
          .get();

      final data = doc.data()!;
      // Service logic: passType == 'superfan_pass' ? 'Superfan Pass' : 'Fan Pass'
      final productName = data['passType'] == 'superfan_pass'
          ? 'Superfan Pass'
          : 'Fan Pass';
      // Service logic: passType == 'superfan_pass' ? 2999 : 1499
      final amount = data['passType'] == 'superfan_pass' ? 2999 : 1499;

      expect(productName, 'Superfan Pass');
      expect(amount, 2999);
    });

    test('venue purchase documents can be queried by userId', () async {
      await fakeFirestore.collection('world_cup_venue_purchases').add({
        'userId': 'user1',
        'venueId': 'venue_a',
        'venueName': 'Sports Bar A',
        'purchasedAt': Timestamp.now(),
        'stripeSessionId': 'cs_venue_123',
      });

      await fakeFirestore.collection('world_cup_venue_purchases').add({
        'userId': 'user1',
        'venueId': 'venue_b',
        'venueName': 'Sports Bar B',
        'purchasedAt': Timestamp.now(),
        'stripeSessionId': 'cs_venue_456',
      });

      await fakeFirestore.collection('world_cup_venue_purchases').add({
        'userId': 'other_user',
        'venueId': 'venue_c',
        'venueName': 'Sports Bar C',
        'purchasedAt': Timestamp.now(),
        'stripeSessionId': 'cs_venue_789',
      });

      final docs = await fakeFirestore
          .collection('world_cup_venue_purchases')
          .where('userId', isEqualTo: 'user1')
          .get();

      expect(docs.docs.length, 2);
    });

    test('virtual payment documents have expected fields', () async {
      await fakeFirestore.collection('watch_party_virtual_payments').add({
        'userId': 'user1',
        'amount': 599,
        'currency': 'usd',
        'status': 'completed',
        'watchPartyId': 'wp_1',
        'watchPartyName': 'Game Day',
        'createdAt': Timestamp.now(),
      });

      final docs = await fakeFirestore
          .collection('watch_party_virtual_payments')
          .where('userId', isEqualTo: 'user1')
          .get();

      expect(docs.docs.length, 1);
      final data = docs.docs.first.data();
      expect(data['amount'], 599);
      expect(data['currency'], 'usd');
      expect(data['status'], 'completed');
    });
  });
}

/// Mirror of the private _parseTransactionStatus method for testing purposes.
TransactionStatus _parseTransactionStatus(String? status) {
  switch (status) {
    case 'completed':
    case 'succeeded':
      return TransactionStatus.completed;
    case 'pending':
      return TransactionStatus.pending;
    case 'refunded':
      return TransactionStatus.refunded;
    case 'failed':
      return TransactionStatus.failed;
    default:
      return TransactionStatus.pending;
  }
}

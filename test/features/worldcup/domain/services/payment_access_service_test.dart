import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/worldcup/domain/services/payment_access_service.dart';
import 'package:pregame_world_cup/features/worldcup/domain/services/payment_models.dart';
import 'package:pregame_world_cup/services/revenuecat_service.dart';

// -- Mocks --
class MockFirebaseFunctions extends Mock implements FirebaseFunctions {}

class MockRevenueCatService extends Mock implements RevenueCatService {}

class MockHttpsCallable extends Mock implements HttpsCallable {}

class MockHttpsCallableResult extends Mock implements HttpsCallableResult {}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
  });

  // ============================================================================
  // createFanPassStatus (pure logic, no Firebase Auth needed)
  // ============================================================================
  group('PaymentAccessService - createFanPassStatus', () {
    late PaymentAccessService service;
    late MockFirebaseFunctions mockFunctions;
    late FakeFirebaseFirestore fakeFirestore;
    late MockRevenueCatService mockRevenueCat;

    setUp(() {
      mockFunctions = MockFirebaseFunctions();
      fakeFirestore = FakeFirebaseFirestore();
      mockRevenueCat = MockRevenueCatService();

      service = PaymentAccessService(
        functions: mockFunctions,
        firestore: fakeFirestore,
        revenueCatService: mockRevenueCat,
      );
    });

    test('free pass type returns hasPass false', () {
      final status = service.createFanPassStatus(FanPassType.free);

      expect(status.hasPass, isFalse);
      expect(status.passType, FanPassType.free);
    });

    test('free pass type has basic features enabled', () {
      final status = service.createFanPassStatus(FanPassType.free);

      expect(status.features['basicSchedules'], isTrue);
      expect(status.features['venueDiscovery'], isTrue);
      expect(status.features['matchNotifications'], isTrue);
      expect(status.features['basicTeamFollowing'], isTrue);
      expect(status.features['communityAccess'], isTrue);
    });

    test('free pass type has premium features disabled', () {
      final status = service.createFanPassStatus(FanPassType.free);

      expect(status.features['adFree'], isFalse);
      expect(status.features['advancedStats'], isFalse);
      expect(status.features['customAlerts'], isFalse);
      expect(status.features['advancedSocialFeatures'], isFalse);
    });

    test('free pass type has superfan-only features disabled', () {
      final status = service.createFanPassStatus(FanPassType.free);

      expect(status.features['exclusiveContent'], isFalse);
      expect(status.features['priorityFeatures'], isFalse);
      expect(status.features['aiMatchInsights'], isFalse);
      expect(status.features['downloadableContent'], isFalse);
    });

    test('fanPass type returns hasPass true', () {
      final status = service.createFanPassStatus(FanPassType.fanPass);

      expect(status.hasPass, isTrue);
      expect(status.passType, FanPassType.fanPass);
    });

    test('fanPass type enables mid-tier features', () {
      final status = service.createFanPassStatus(FanPassType.fanPass);

      expect(status.features['adFree'], isTrue);
      expect(status.features['advancedStats'], isTrue);
      expect(status.features['customAlerts'], isTrue);
      expect(status.features['advancedSocialFeatures'], isTrue);
    });

    test('fanPass type does not enable superfan-only features', () {
      final status = service.createFanPassStatus(FanPassType.fanPass);

      expect(status.features['exclusiveContent'], isFalse);
      expect(status.features['priorityFeatures'], isFalse);
      expect(status.features['aiMatchInsights'], isFalse);
      expect(status.features['downloadableContent'], isFalse);
    });

    test('superfanPass type returns hasPass true', () {
      final status = service.createFanPassStatus(FanPassType.superfanPass);

      expect(status.hasPass, isTrue);
      expect(status.passType, FanPassType.superfanPass);
    });

    test('superfanPass type enables all features', () {
      final status = service.createFanPassStatus(FanPassType.superfanPass);

      expect(status.features['basicSchedules'], isTrue);
      expect(status.features['venueDiscovery'], isTrue);
      expect(status.features['matchNotifications'], isTrue);
      expect(status.features['basicTeamFollowing'], isTrue);
      expect(status.features['communityAccess'], isTrue);
      expect(status.features['adFree'], isTrue);
      expect(status.features['advancedStats'], isTrue);
      expect(status.features['customAlerts'], isTrue);
      expect(status.features['advancedSocialFeatures'], isTrue);
      expect(status.features['exclusiveContent'], isTrue);
      expect(status.features['priorityFeatures'], isTrue);
      expect(status.features['aiMatchInsights'], isTrue);
      expect(status.features['downloadableContent'], isTrue);
    });

    test('all pass types set purchasedAt to a recent time', () {
      for (final passType in FanPassType.values) {
        final before = DateTime.now();
        final status = service.createFanPassStatus(passType);
        final after = DateTime.now();

        expect(status.purchasedAt, isNotNull);
        expect(
          status.purchasedAt!.isAfter(before.subtract(const Duration(seconds: 1))),
          isTrue,
        );
        expect(
          status.purchasedAt!.isBefore(after.add(const Duration(seconds: 1))),
          isTrue,
        );
      }
    });

    test('features map has exactly 13 entries for all pass types', () {
      for (final passType in FanPassType.values) {
        final status = service.createFanPassStatus(passType);
        expect(status.features.length, 13);
      }
    });
  });

  // ============================================================================
  // getAdminFanPassStatus
  // ============================================================================
  group('PaymentAccessService - getAdminFanPassStatus', () {
    late PaymentAccessService service;
    late MockFirebaseFunctions mockFunctions;
    late FakeFirebaseFirestore fakeFirestore;
    late MockRevenueCatService mockRevenueCat;

    setUp(() {
      mockFunctions = MockFirebaseFunctions();
      fakeFirestore = FakeFirebaseFirestore();
      mockRevenueCat = MockRevenueCatService();

      service = PaymentAccessService(
        functions: mockFunctions,
        firestore: fakeFirestore,
        revenueCatService: mockRevenueCat,
      );
    });

    test('returns superfan pass status', () {
      final status = service.getAdminFanPassStatus();

      expect(status.hasPass, isTrue);
      expect(status.passType, FanPassType.superfanPass);
    });

    test('has all features enabled', () {
      final status = service.getAdminFanPassStatus();

      expect(status.features['basicSchedules'], isTrue);
      expect(status.features['venueDiscovery'], isTrue);
      expect(status.features['matchNotifications'], isTrue);
      expect(status.features['basicTeamFollowing'], isTrue);
      expect(status.features['communityAccess'], isTrue);
      expect(status.features['adFree'], isTrue);
      expect(status.features['advancedStats'], isTrue);
      expect(status.features['customAlerts'], isTrue);
      expect(status.features['advancedSocialFeatures'], isTrue);
      expect(status.features['exclusiveContent'], isTrue);
      expect(status.features['priorityFeatures'], isTrue);
      expect(status.features['aiMatchInsights'], isTrue);
      expect(status.features['downloadableContent'], isTrue);
    });

    test('has purchasedAt set', () {
      final before = DateTime.now();
      final status = service.getAdminFanPassStatus();
      final after = DateTime.now();

      expect(status.purchasedAt, isNotNull);
      expect(
        status.purchasedAt!.isAfter(before.subtract(const Duration(seconds: 1))),
        isTrue,
      );
      expect(
        status.purchasedAt!.isBefore(after.add(const Duration(seconds: 1))),
        isTrue,
      );
    });

    test('has 13 feature entries', () {
      final status = service.getAdminFanPassStatus();
      expect(status.features.length, 13);
    });
  });

  // ============================================================================
  // clearCaches
  // ============================================================================
  group('PaymentAccessService - clearCaches', () {
    late PaymentAccessService service;
    late MockFirebaseFunctions mockFunctions;
    late FakeFirebaseFirestore fakeFirestore;
    late MockRevenueCatService mockRevenueCat;

    setUp(() {
      mockFunctions = MockFirebaseFunctions();
      fakeFirestore = FakeFirebaseFirestore();
      mockRevenueCat = MockRevenueCatService();

      service = PaymentAccessService(
        functions: mockFunctions,
        firestore: fakeFirestore,
        revenueCatService: mockRevenueCat,
      );
    });

    test('does not throw when called on fresh service', () {
      expect(() => service.clearCaches(), returnsNormally);
    });

    test('can be called multiple times without error', () {
      service.clearCaches();
      service.clearCaches();
      service.clearCaches();
      // No assertion needed - just verifying no exceptions
    });
  });

  // ============================================================================
  // Admin/clearance Firestore lookup logic (via _isAdminOrClearanceEmail)
  // ============================================================================
  group('PaymentAccessService - admin/clearance lookup via Firestore', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseFunctions mockFunctions;
    late MockRevenueCatService mockRevenueCat;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      mockFunctions = MockFirebaseFunctions();
      mockRevenueCat = MockRevenueCatService();
    });

    test('admin_users collection with matching email returns true in Firestore query', () async {
      // Seed admin user
      await fakeFirestore.collection('admin_users').add({
        'email': 'admin@example.com',
      });

      // Verify the query works as the service would use it
      final snapshot = await fakeFirestore
          .collection('admin_users')
          .where('email', isEqualTo: 'admin@example.com')
          .limit(1)
          .get();

      expect(snapshot.docs.isNotEmpty, isTrue);
    });

    test('admin_users collection without matching email returns false', () async {
      await fakeFirestore.collection('admin_users').add({
        'email': 'other@example.com',
      });

      final snapshot = await fakeFirestore
          .collection('admin_users')
          .where('email', isEqualTo: 'notadmin@example.com')
          .limit(1)
          .get();

      expect(snapshot.docs.isEmpty, isTrue);
    });

    test('clearance_users collection with matching email returns true', () async {
      await fakeFirestore.collection('clearance_users').add({
        'email': 'vip@example.com',
      });

      final snapshot = await fakeFirestore
          .collection('clearance_users')
          .where('email', isEqualTo: 'vip@example.com')
          .limit(1)
          .get();

      expect(snapshot.docs.isNotEmpty, isTrue);
    });

    test('clearance_users collection without matching email returns false', () async {
      final snapshot = await fakeFirestore
          .collection('clearance_users')
          .where('email', isEqualTo: 'nobody@example.com')
          .limit(1)
          .get();

      expect(snapshot.docs.isEmpty, isTrue);
    });

    test('empty admin_users collection returns false for any email', () async {
      final snapshot = await fakeFirestore
          .collection('admin_users')
          .where('email', isEqualTo: 'anyone@example.com')
          .limit(1)
          .get();

      expect(snapshot.docs.isEmpty, isTrue);
    });

    test('case-sensitive email matching (service lowercases before querying)', () async {
      await fakeFirestore.collection('admin_users').add({
        'email': 'admin@example.com',
      });

      // The service calls email.toLowerCase() before querying
      // So uppercase email should NOT match if stored lowercase
      final snapshot = await fakeFirestore
          .collection('admin_users')
          .where('email', isEqualTo: 'Admin@Example.com')
          .limit(1)
          .get();

      expect(snapshot.docs.isEmpty, isTrue);

      // But lowercase should match
      final snapshotLower = await fakeFirestore
          .collection('admin_users')
          .where('email', isEqualTo: 'admin@example.com')
          .limit(1)
          .get();

      expect(snapshotLower.docs.isNotEmpty, isTrue);
    });
  });

  // ============================================================================
  // Feature access tier validation
  // ============================================================================
  group('PaymentAccessService - feature tier validation', () {
    late PaymentAccessService service;

    setUp(() {
      service = PaymentAccessService(
        functions: MockFirebaseFunctions(),
        firestore: FakeFirebaseFirestore(),
        revenueCatService: MockRevenueCatService(),
      );
    });

    test('free tier has exactly 5 true features', () {
      final status = service.createFanPassStatus(FanPassType.free);
      final trueFeatures = status.features.entries.where((e) => e.value).length;
      expect(trueFeatures, 5);
    });

    test('fanPass tier has exactly 9 true features', () {
      final status = service.createFanPassStatus(FanPassType.fanPass);
      final trueFeatures = status.features.entries.where((e) => e.value).length;
      expect(trueFeatures, 9);
    });

    test('superfanPass tier has all 13 features true', () {
      final status = service.createFanPassStatus(FanPassType.superfanPass);
      final trueFeatures = status.features.entries.where((e) => e.value).length;
      expect(trueFeatures, 13);
    });

    test('fanPass is a strict superset of free features', () {
      final freeStatus = service.createFanPassStatus(FanPassType.free);
      final fanPassStatus = service.createFanPassStatus(FanPassType.fanPass);

      for (final entry in freeStatus.features.entries) {
        if (entry.value) {
          expect(
            fanPassStatus.features[entry.key],
            isTrue,
            reason: '${entry.key} should be enabled in fanPass since it is enabled in free',
          );
        }
      }
    });

    test('superfanPass is a strict superset of fanPass features', () {
      final fanPassStatus = service.createFanPassStatus(FanPassType.fanPass);
      final superfanStatus = service.createFanPassStatus(FanPassType.superfanPass);

      for (final entry in fanPassStatus.features.entries) {
        if (entry.value) {
          expect(
            superfanStatus.features[entry.key],
            isTrue,
            reason: '${entry.key} should be enabled in superfan since it is enabled in fanPass',
          );
        }
      }
    });

    test('superfan has features that fanPass does not', () {
      final fanPassStatus = service.createFanPassStatus(FanPassType.fanPass);
      final superfanStatus = service.createFanPassStatus(FanPassType.superfanPass);

      final superfanOnlyFeatures = superfanStatus.features.entries
          .where((e) => e.value && !(fanPassStatus.features[e.key] ?? false))
          .map((e) => e.key)
          .toList();

      expect(superfanOnlyFeatures, contains('exclusiveContent'));
      expect(superfanOnlyFeatures, contains('priorityFeatures'));
      expect(superfanOnlyFeatures, contains('aiMatchInsights'));
      expect(superfanOnlyFeatures, contains('downloadableContent'));
      expect(superfanOnlyFeatures.length, 4);
    });
  });
}

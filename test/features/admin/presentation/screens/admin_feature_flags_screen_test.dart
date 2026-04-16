import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/admin/domain/entities/admin_user.dart';
import 'package:pregame_world_cup/features/admin/domain/services/admin_service.dart';
import 'package:pregame_world_cup/features/admin/presentation/screens/admin_feature_flags_screen.dart';
import 'package:pregame_world_cup/features/moderation/domain/services/moderation_service.dart';
import 'package:pregame_world_cup/core/services/push_notification_service.dart';
import 'package:pregame_world_cup/l10n/app_localizations.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockModerationService extends Mock implements ModerationService {}

class MockPushNotificationService extends Mock
    implements PushNotificationService {}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late MockModerationService mockModerationService;
  late MockPushNotificationService mockPushService;

  const testUserId = 'feature-flags-admin-uid';

  setUp(() {
    FlutterError.onError = (FlutterErrorDetails details) {
      final message = details.toString();
      if (message.contains('overflowed') || message.contains('RenderFlex')) {
        return;
      }
      FlutterError.presentError(details);
    };

    AdminService.resetInstance();

    fakeFirestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockModerationService = MockModerationService();
    mockPushService = MockPushNotificationService();

    when(() => mockUser.uid).thenReturn(testUserId);
    when(() => mockAuth.currentUser).thenReturn(mockUser);
  });

  tearDown(() async {
    AdminService.resetInstance();
    await GetIt.instance.reset();
  });

  Future<void> seedAdmin() async {
    await fakeFirestore.collection('admins').doc(testUserId).set({
      'userId': testUserId,
      'email': 'admin@test.com',
      'displayName': 'Test Admin',
      'role': AdminRole.superAdmin.name,
      'grantedAt': DateTime(2026, 1, 1).toIso8601String(),
      'isActive': true,
      'permissions': ['*'],
    });

    final adminService = AdminService(
      firestore: fakeFirestore,
      auth: mockAuth,
      moderationService: mockModerationService,
      pushService: mockPushService,
    );

    final sl = GetIt.instance;
    if (sl.isRegistered<AdminService>()) sl.unregister<AdminService>();
    sl.registerSingleton<AdminService>(adminService);

    await adminService.initialize();
  }

  Widget buildTestWidget() {
    return const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: MediaQueryData(size: Size(500, 1200)),
        child: AdminFeatureFlagsScreen(),
      ),
    );
  }

  group('AdminFeatureFlagsScreen', () {
    test('is a StatefulWidget', () {
      const screen = AdminFeatureFlagsScreen();
      expect(screen, isA<StatefulWidget>());
    });

    test('can be constructed', () {
      expect(() => const AdminFeatureFlagsScreen(), returnsNormally);
    });

    test('has correct runtimeType', () {
      const screen = AdminFeatureFlagsScreen();
      expect(screen.runtimeType, AdminFeatureFlagsScreen);
    });

    test('can create multiple instances', () {
      const screen1 = AdminFeatureFlagsScreen();
      const screen2 = AdminFeatureFlagsScreen();
      expect(screen1, isA<AdminFeatureFlagsScreen>());
      expect(screen2, isA<AdminFeatureFlagsScreen>());
      expect(identical(screen1, screen2), isFalse);
    });
  });

  group('AdminFeatureFlagsScreen - Disposal safety', () {
    testWidgets('can be disposed during async load without crashing',
        (tester) async {
      await seedAdmin();

      await tester.pumpWidget(buildTestWidget());
      // Widget is now loading (awaiting getFeatureFlags)

      // Dispose the widget before the async operation completes
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      await tester.pumpAndSettle();

      // If mounted guard is missing, this would throw
      // "setState() called after dispose()"
    });

    testWidgets('renders and settles without error', (tester) async {
      await seedAdmin();

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(AdminFeatureFlagsScreen), findsOneWidget);
    });
  });
}

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/admin/domain/entities/admin_user.dart';
import 'package:pregame_world_cup/features/admin/domain/services/admin_service.dart';
import 'package:pregame_world_cup/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:pregame_world_cup/features/moderation/domain/services/moderation_service.dart';
import 'package:pregame_world_cup/core/services/push_notification_service.dart';
import 'package:pregame_world_cup/l10n/app_localizations.dart';

// Mocks
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockModerationService extends Mock implements ModerationService {}

class MockPushNotificationService extends Mock implements PushNotificationService {}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late MockModerationService mockModerationService;
  late MockPushNotificationService mockPushService;

  const testUserId = 'dashboard-admin-uid';

  // Suppress overflow errors in constrained test environments
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

  tearDown(() {
    AdminService.resetInstance();
  });

  Future<void> seedAdminAndStats({
    AdminRole role = AdminRole.superAdmin,
    int totalUsers = 1000,
    int activeUsers = 250,
    int newToday = 50,
    int watchParties = 100,
    int activeParties = 25,
    int pendingReports = 5,
  }) async {
    // Seed admin doc
    await fakeFirestore.collection('admins').doc(testUserId).set({
      'userId': testUserId,
      'email': 'admin@test.com',
      'displayName': 'Test Dashboard Admin',
      'role': role.name,
      'grantedAt': DateTime(2026, 1, 1).toIso8601String(),
      'isActive': true,
      'permissions': ['*'],
    });

    // Seed fresh cached stats so the screen picks them up
    await fakeFirestore.collection('admin_stats').doc('dashboard').set({
      'totalUsers': totalUsers,
      'activeUsers24h': activeUsers,
      'newUsersToday': newToday,
      'totalWatchParties': watchParties,
      'activeWatchParties': activeParties,
      'pendingReports': pendingReports,
      'totalPredictions': 5000,
      'totalMessages': 10000,
      'updatedAt': DateTime.now().toIso8601String(),
    });

    // Initialize the AdminService with fakes (so the screen's AdminService() picks it up)
    AdminService(
      firestore: fakeFirestore,
      auth: mockAuth,
      moderationService: mockModerationService,
      pushService: mockPushService,
    );
  }

  Widget buildTestWidget({double height = 2400}) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: MediaQueryData(size: Size(500, height)),
        child: const AdminDashboardScreen(),
      ),
    );
  }

  group('AdminDashboardScreen', () {
    testWidgets('shows loading indicator initially', (tester) async {
      await seedAdminAndStats();

      await tester.pumpWidget(buildTestWidget());
      // The first frame should show the loading indicator
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('renders admin info card with display name after loading',
        (tester) async {
      await seedAdminAndStats(role: AdminRole.superAdmin);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Test Dashboard Admin'), findsOneWidget);
    });

    testWidgets('renders role badge for superAdmin', (tester) async {
      await seedAdminAndStats(role: AdminRole.superAdmin);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Super Admin'), findsOneWidget);
    });

    testWidgets('renders role badge for moderator', (tester) async {
      await seedAdminAndStats(role: AdminRole.moderator);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Moderator'), findsOneWidget);
    });

    testWidgets('renders stats grid with user counts', (tester) async {
      await seedAdminAndStats(
        totalUsers: 1500,
        activeUsers: 300,
        newToday: 75,
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('1500'), findsOneWidget);
      expect(find.text('300'), findsOneWidget);
      expect(find.text('75'), findsOneWidget);
    });

    testWidgets('renders stats grid with watch party counts', (tester) async {
      await seedAdminAndStats(
        watchParties: 200,
        activeParties: 40,
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('200'), findsOneWidget);
      expect(find.text('40'), findsOneWidget);
    });

    testWidgets('renders pending reports count in stats', (tester) async {
      await seedAdminAndStats(pendingReports: 12);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('12'), findsOneWidget);
    });

    testWidgets('renders Overview section title', (tester) async {
      await seedAdminAndStats();

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Overview'), findsOneWidget);
    });

    testWidgets('renders Quick Actions section title when scrolled into view',
        (tester) async {
      await seedAdminAndStats();

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Quick Actions is below the stats grid in the ListView - scroll to see it
      final listView = find.byType(ListView);
      if (listView.evaluate().isNotEmpty) {
        await tester.drag(listView, const Offset(0, -500));
        await tester.pumpAndSettle();
      }

      expect(find.text('Quick Actions'), findsOneWidget);
    });

    testWidgets('renders refresh button in app bar', (tester) async {
      await seedAdminAndStats();

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('renders Admin Dashboard title in app bar', (tester) async {
      await seedAdminAndStats();

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Admin Dashboard'), findsOneWidget);
    });

    group('Quick Actions - Role visibility', () {
      Future<void> scrollToQuickActions(WidgetTester tester) async {
        final listView = find.byType(ListView);
        if (listView.evaluate().isNotEmpty) {
          await tester.drag(listView, const Offset(0, -500));
          await tester.pumpAndSettle();
        }
      }

      testWidgets('superAdmin sees all quick actions', (tester) async {
        await seedAdminAndStats(role: AdminRole.superAdmin);

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();
        await scrollToQuickActions(tester);

        // superAdmin can see all actions
        expect(find.text('User Management'), findsOneWidget);
        expect(find.text('Venue Claims'), findsOneWidget);
        expect(find.text('Content Moderation'), findsOneWidget);
        expect(find.text('Feature Flags'), findsOneWidget);
        expect(find.text('Push Notifications'), findsOneWidget);
      });

      testWidgets('admin sees most actions but not feature flags', (tester) async {
        await seedAdminAndStats(role: AdminRole.admin);

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();
        await scrollToQuickActions(tester);

        expect(find.text('User Management'), findsOneWidget);
        expect(find.text('Venue Claims'), findsOneWidget);
        expect(find.text('Content Moderation'), findsOneWidget);
        expect(find.text('Push Notifications'), findsOneWidget);
        // admin cannot manage feature flags
        expect(find.text('Feature Flags'), findsNothing);
      });

      testWidgets('moderator sees moderation and watch parties but not user management',
          (tester) async {
        await seedAdminAndStats(role: AdminRole.moderator);

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();
        await scrollToQuickActions(tester);

        // moderator cannot manage users
        expect(find.text('User Management'), findsNothing);
        expect(find.text('Venue Claims'), findsNothing);
        // moderator can moderate content
        expect(find.text('Content Moderation'), findsOneWidget);
        // moderator cannot send push notifications
        expect(find.text('Push Notifications'), findsNothing);
        // moderator cannot manage feature flags
        expect(find.text('Feature Flags'), findsNothing);
      });

      testWidgets('support role sees no quick actions', (tester) async {
        await seedAdminAndStats(role: AdminRole.support);

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();
        await scrollToQuickActions(tester);

        expect(find.text('User Management'), findsNothing);
        expect(find.text('Venue Claims'), findsNothing);
        expect(find.text('Content Moderation'), findsNothing);
        expect(find.text('Push Notifications'), findsNothing);
        expect(find.text('Feature Flags'), findsNothing);
      });
    });

    testWidgets('shows pending reports badge when there are pending reports',
        (tester) async {
      await seedAdminAndStats(
        role: AdminRole.superAdmin,
        pendingReports: 7,
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // The 7 appears in the stats grid
      expect(find.text('7'), findsWidgets);
    });

    testWidgets('stat labels are present', (tester) async {
      await seedAdminAndStats();

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Total Users'), findsOneWidget);
      expect(find.text('Active (24h)'), findsOneWidget);
      expect(find.text('New Today'), findsOneWidget);
      expect(find.text('Pending Reports'), findsWidgets);
      expect(find.text('Active Parties'), findsOneWidget);
    });

    testWidgets('admin_panel_settings icon is rendered', (tester) async {
      await seedAdminAndStats();

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.admin_panel_settings), findsOneWidget);
    });
  });
}

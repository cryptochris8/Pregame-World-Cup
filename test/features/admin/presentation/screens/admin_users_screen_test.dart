import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/admin/domain/entities/admin_user.dart';
import 'package:pregame_world_cup/features/admin/domain/services/admin_service.dart';
import 'package:pregame_world_cup/features/admin/presentation/screens/admin_users_screen.dart';
import 'package:pregame_world_cup/features/moderation/domain/services/moderation_service.dart';
import 'package:pregame_world_cup/core/services/push_notification_service.dart';
import 'package:pregame_world_cup/l10n/app_localizations.dart';

// Mocks
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

  const testAdminUserId = 'admin-users-screen-uid';

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

    when(() => mockUser.uid).thenReturn(testAdminUserId);
    when(() => mockAuth.currentUser).thenReturn(mockUser);
  });

  tearDown(() async {
    AdminService.resetInstance();
    await GetIt.instance.reset();
  });

  /// Seed an admin user document, initialize the AdminService singleton
  /// with fakes, and call initialize() so that isAdmin becomes true.
  Future<AdminService> seedAdmin({
    AdminRole role = AdminRole.superAdmin,
  }) async {
    // Seed admin doc
    await fakeFirestore.collection('admins').doc(testAdminUserId).set({
      'userId': testAdminUserId,
      'email': 'admin@test.com',
      'displayName': 'Test Admin',
      'role': role.name,
      'grantedAt': DateTime(2026, 1, 1).toIso8601String(),
      'isActive': true,
      'permissions': ['*'],
    });

    // Create the singleton with fakes
    final service = AdminService(
      firestore: fakeFirestore,
      auth: mockAuth,
      moderationService: mockModerationService,
      pushService: mockPushService,
    );

    // Register in GetIt so the screen can resolve it via sl<AdminService>()
    final sl = GetIt.instance;
    if (sl.isRegistered<AdminService>()) sl.unregister<AdminService>();
    sl.registerSingleton<AdminService>(service);

    // Initialize so that isAdmin becomes true (loads admin doc)
    await service.initialize();

    return service;
  }

  /// Seed user profile documents in Firestore for the search results.
  Future<void> seedUsers(List<Map<String, dynamic>> users) async {
    for (final user in users) {
      await fakeFirestore
          .collection('user_profiles')
          .doc(user['userId'] as String)
          .set(user);
    }
  }

  Widget buildTestWidget({double height = 1200}) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: MediaQueryData(size: Size(500, height)),
        child: const AdminUsersScreen(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Rendering tests
  // ---------------------------------------------------------------------------

  group('AdminUsersScreen - Rendering', () {
    testWidgets('renders without crashing', (tester) async {
      await seedAdmin();

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(AdminUsersScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows User Management title in app bar', (tester) async {
      await seedAdmin();

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('User Management'), findsOneWidget);
    });

    testWidgets('shows loading indicator initially', (tester) async {
      await seedAdmin();

      await tester.pumpWidget(buildTestWidget());
      // On first frame, _isLoading should be true
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows search bar', (tester) async {
      await seedAdmin();

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('search bar has correct hint text', (tester) async {
      await seedAdmin();

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Search users by name...'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Admin user list structure
  // ---------------------------------------------------------------------------

  group('AdminUsersScreen - User list structure', () {
    testWidgets('shows "No users found" when no users exist', (tester) async {
      await seedAdmin();

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('No users found'), findsOneWidget);
    });

    testWidgets('shows user cards when users exist', (tester) async {
      await seedAdmin();
      await seedUsers([
        {
          'userId': 'user1',
          'displayName': 'John Doe',
          'email': 'john@example.com',
          'isOnline': true,
          'level': 5,
          'experiencePoints': 100,
          'favoriteTeams': ['Brazil'],
          'badges': [],
          'createdAt': DateTime(2026, 1, 15).toIso8601String(),
          'updatedAt': DateTime(2026, 2, 1).toIso8601String(),
        },
      ]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('john@example.com'), findsOneWidget);
    });

    testWidgets('shows multiple users in the list', (tester) async {
      await seedAdmin();
      await seedUsers([
        {
          'userId': 'user1',
          'displayName': 'Alice Smith',
          'email': 'alice@example.com',
          'isOnline': false,
          'level': 3,
          'experiencePoints': 50,
          'favoriteTeams': [],
          'badges': [],
          'createdAt': DateTime(2026, 1, 10).toIso8601String(),
          'updatedAt': DateTime(2026, 1, 20).toIso8601String(),
        },
        {
          'userId': 'user2',
          'displayName': 'Bob Johnson',
          'email': 'bob@example.com',
          'isOnline': true,
          'level': 10,
          'experiencePoints': 500,
          'favoriteTeams': ['Argentina'],
          'badges': [],
          'createdAt': DateTime(2026, 1, 5).toIso8601String(),
          'updatedAt': DateTime(2026, 1, 25).toIso8601String(),
        },
      ]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Alice Smith'), findsOneWidget);
      expect(find.text('Bob Johnson'), findsOneWidget);
    });

    testWidgets('user cards render as Card widgets', (tester) async {
      await seedAdmin();
      await seedUsers([
        {
          'userId': 'user1',
          'displayName': 'Test User',
          'email': 'test@example.com',
          'isOnline': false,
          'level': 1,
          'experiencePoints': 0,
          'favoriteTeams': [],
          'badges': [],
          'createdAt': DateTime(2026, 2, 1).toIso8601String(),
          'updatedAt': DateTime(2026, 2, 1).toIso8601String(),
        },
      ]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('user cards contain ExpansionTile for details', (tester) async {
      await seedAdmin();
      await seedUsers([
        {
          'userId': 'user1',
          'displayName': 'Test User',
          'email': 'test@example.com',
          'isOnline': false,
          'level': 1,
          'experiencePoints': 0,
          'favoriteTeams': [],
          'badges': [],
          'createdAt': DateTime(2026, 2, 1).toIso8601String(),
          'updatedAt': DateTime(2026, 2, 1).toIso8601String(),
        },
      ]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(ExpansionTile), findsOneWidget);
    });

    testWidgets('user card shows online status indicator', (tester) async {
      await seedAdmin();
      await seedUsers([
        {
          'userId': 'user1',
          'displayName': 'Online User',
          'email': 'online@example.com',
          'isOnline': true,
          'level': 1,
          'experiencePoints': 0,
          'favoriteTeams': [],
          'badges': [],
          'createdAt': DateTime(2026, 2, 1).toIso8601String(),
          'updatedAt': DateTime(2026, 2, 1).toIso8601String(),
        },
      ]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Online status shows a filled circle icon
      expect(find.byIcon(Icons.circle), findsOneWidget);
      expect(find.text('Online'), findsOneWidget);
    });

    testWidgets('user card shows CircleAvatar with initial letter',
        (tester) async {
      await seedAdmin();
      await seedUsers([
        {
          'userId': 'user1',
          'displayName': 'Test User',
          'email': 'test@example.com',
          'isOnline': false,
          'level': 1,
          'experiencePoints': 0,
          'favoriteTeams': [],
          'badges': [],
          'createdAt': DateTime(2026, 2, 1).toIso8601String(),
          'updatedAt': DateTime(2026, 2, 1).toIso8601String(),
        },
      ]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.text('T'), findsOneWidget); // First letter of "Test User"
    });
  });

  // ---------------------------------------------------------------------------
  // Expanded user details
  // ---------------------------------------------------------------------------

  group('AdminUsersScreen - Expanded user details', () {
    testWidgets('expanding a user card shows action buttons', (tester) async {
      await seedAdmin();
      await seedUsers([
        {
          'userId': 'user1',
          'displayName': 'Expandable User',
          'email': 'expand@example.com',
          'isOnline': false,
          'level': 5,
          'experiencePoints': 100,
          'favoriteTeams': ['Brazil'],
          'badges': [],
          'createdAt': DateTime(2026, 1, 15).toIso8601String(),
          'updatedAt': DateTime(2026, 2, 1).toIso8601String(),
        },
      ]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap to expand the ExpansionTile
      await tester.tap(find.text('Expandable User'));
      await tester.pumpAndSettle();

      // Action buttons should appear
      expect(find.text('Warn'), findsOneWidget);
      expect(find.text('Mute'), findsOneWidget);
      expect(find.text('Suspend'), findsOneWidget);
      expect(find.text('Ban'), findsOneWidget);
    });

    testWidgets('expanding a user card shows user details', (tester) async {
      await seedAdmin();
      await seedUsers([
        {
          'userId': 'user-detail-1',
          'displayName': 'Detail User',
          'email': 'detail@example.com',
          'isOnline': false,
          'level': 10,
          'experiencePoints': 500,
          'favoriteTeams': ['France'],
          'badges': [],
          'createdAt': DateTime(2026, 1, 15).toIso8601String(),
          'updatedAt': DateTime(2026, 2, 1).toIso8601String(),
        },
      ]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap to expand
      await tester.tap(find.text('Detail User'));
      await tester.pumpAndSettle();

      // Should show detail labels
      expect(find.text('User ID'), findsOneWidget);
      expect(find.text('Level'), findsOneWidget);
      expect(find.text('Joined'), findsOneWidget);
      expect(find.text('Friends'), findsOneWidget);
    });

    testWidgets('expanding a user card shows level title', (tester) async {
      await seedAdmin();
      await seedUsers([
        {
          'userId': 'user-level-1',
          'displayName': 'Level User',
          'email': 'level@example.com',
          'isOnline': false,
          'level': 10,
          'experiencePoints': 500,
          'favoriteTeams': [],
          'badges': [],
          'createdAt': DateTime(2026, 1, 15).toIso8601String(),
          'updatedAt': DateTime(2026, 2, 1).toIso8601String(),
        },
      ]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap to expand
      await tester.tap(find.text('Level User'));
      await tester.pumpAndSettle();

      // Level 10 -> "Regular" title
      expect(find.text('10 (Regular)'), findsOneWidget);
    });

    testWidgets('expanded user card shows favorite teams when present',
        (tester) async {
      await seedAdmin();
      await seedUsers([
        {
          'userId': 'user-teams-1',
          'displayName': 'Team Fan',
          'email': 'fan@example.com',
          'isOnline': false,
          'level': 1,
          'experiencePoints': 0,
          'favoriteTeams': ['Brazil', 'Germany'],
          'badges': [],
          'createdAt': DateTime(2026, 1, 15).toIso8601String(),
          'updatedAt': DateTime(2026, 2, 1).toIso8601String(),
        },
      ]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap to expand
      await tester.tap(find.text('Team Fan'));
      await tester.pumpAndSettle();

      // Should show favorite teams
      expect(find.text('Teams'), findsOneWidget);
      expect(find.text('Brazil, Germany'), findsOneWidget);
    });

    testWidgets('action buttons have correct icons', (tester) async {
      await seedAdmin();
      await seedUsers([
        {
          'userId': 'user-actions-1',
          'displayName': 'Action User',
          'email': 'action@example.com',
          'isOnline': false,
          'level': 1,
          'experiencePoints': 0,
          'favoriteTeams': [],
          'badges': [],
          'createdAt': DateTime(2026, 1, 15).toIso8601String(),
          'updatedAt': DateTime(2026, 2, 1).toIso8601String(),
        },
      ]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap to expand
      await tester.tap(find.text('Action User'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.warning_amber), findsOneWidget); // Warn
      expect(find.byIcon(Icons.volume_off), findsOneWidget); // Mute
      expect(find.byIcon(Icons.block), findsOneWidget); // Suspend
      expect(find.byIcon(Icons.gavel), findsOneWidget); // Ban
    });
  });

  // ---------------------------------------------------------------------------
  // Disposal safety
  // ---------------------------------------------------------------------------

  group('AdminUsersScreen - Disposal safety', () {
    testWidgets('can be disposed during async user load without crashing',
        (tester) async {
      await seedAdmin();

      // Seed a slow-loading user list by adding users that will take time
      // The key is disposing the widget before _loadUsers completes
      await tester.pumpWidget(buildTestWidget());
      // Widget is now in loading state (awaiting searchUsers)

      // Dispose the widget before the async operation completes
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      await tester.pumpAndSettle();

      // If mounted guard is missing, this would throw
      // "setState() called after dispose()"
    });

    testWidgets('can be disposed during async search without crashing',
        (tester) async {
      await seedAdmin();

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Start a search
      final textField = find.byType(TextField);
      await tester.enterText(textField, 'test query');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // Dispose while search is in progress
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      await tester.pumpAndSettle();

      // No crash = mounted guard is working
    });
  });

  // ---------------------------------------------------------------------------
  // Non-admin access
  // ---------------------------------------------------------------------------

  group('AdminUsersScreen - Non-admin behavior', () {
    testWidgets(
        'shows no users when admin role cannot manage users (moderator)',
        (tester) async {
      await seedAdmin(role: AdminRole.moderator);
      await seedUsers([
        {
          'userId': 'user1',
          'displayName': 'Should Not Appear',
          'email': 'hidden@example.com',
          'isOnline': false,
          'level': 1,
          'experiencePoints': 0,
          'favoriteTeams': [],
          'badges': [],
          'createdAt': DateTime(2026, 1, 15).toIso8601String(),
          'updatedAt': DateTime(2026, 2, 1).toIso8601String(),
        },
      ]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Moderator role cannot manage users (canManageUsers returns false)
      // so searchUsers returns empty list
      expect(find.text('No users found'), findsOneWidget);
      expect(find.text('Should Not Appear'), findsNothing);
    });

    testWidgets('shows no users when admin role is support', (tester) async {
      await seedAdmin(role: AdminRole.support);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('No users found'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Admin action dialogs
  // ---------------------------------------------------------------------------

  group('AdminUsersScreen - Action dialogs', () {
    Future<void> expandUserAndTapAction(
      WidgetTester tester,
      String userName,
      String actionLabel,
    ) async {
      await tester.tap(find.text(userName));
      await tester.pumpAndSettle();
      await tester.tap(find.text(actionLabel));
      await tester.pumpAndSettle();
    }

    testWidgets('tapping Warn button opens warning dialog', (tester) async {
      await seedAdmin();
      await seedUsers([
        {
          'userId': 'user-warn-1',
          'displayName': 'Warn Target',
          'email': 'warn@example.com',
          'isOnline': false,
          'level': 1,
          'experiencePoints': 0,
          'favoriteTeams': [],
          'badges': [],
          'createdAt': DateTime(2026, 1, 15).toIso8601String(),
          'updatedAt': DateTime(2026, 2, 1).toIso8601String(),
        },
      ]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await expandUserAndTapAction(tester, 'Warn Target', 'Warn');

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Warn Warn Target'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Send Warning'), findsOneWidget);
    });

    testWidgets('tapping Mute button opens mute dialog', (tester) async {
      await seedAdmin();
      await seedUsers([
        {
          'userId': 'user-mute-1',
          'displayName': 'Mute Target',
          'email': 'mute@example.com',
          'isOnline': false,
          'level': 1,
          'experiencePoints': 0,
          'favoriteTeams': [],
          'badges': [],
          'createdAt': DateTime(2026, 1, 15).toIso8601String(),
          'updatedAt': DateTime(2026, 2, 1).toIso8601String(),
        },
      ]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await expandUserAndTapAction(tester, 'Mute Target', 'Mute');

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Mute Mute Target'), findsOneWidget);
      expect(find.text('Mute User'), findsOneWidget);
    });

    testWidgets('tapping Ban button opens ban dialog with warning text',
        (tester) async {
      await seedAdmin();
      await seedUsers([
        {
          'userId': 'user-ban-1',
          'displayName': 'Ban Target',
          'email': 'ban@example.com',
          'isOnline': false,
          'level': 1,
          'experiencePoints': 0,
          'favoriteTeams': [],
          'badges': [],
          'createdAt': DateTime(2026, 1, 15).toIso8601String(),
          'updatedAt': DateTime(2026, 2, 1).toIso8601String(),
        },
      ]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await expandUserAndTapAction(tester, 'Ban Target', 'Ban');

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Ban Ban Target'), findsOneWidget);
      expect(find.text('This action is permanent and cannot be undone.'),
          findsOneWidget);
      expect(find.text('Permanently Ban'), findsOneWidget);
    });

    testWidgets('cancel button closes the warning dialog', (tester) async {
      await seedAdmin();
      await seedUsers([
        {
          'userId': 'user-cancel-1',
          'displayName': 'Cancel Target',
          'email': 'cancel@example.com',
          'isOnline': false,
          'level': 1,
          'experiencePoints': 0,
          'favoriteTeams': [],
          'badges': [],
          'createdAt': DateTime(2026, 1, 15).toIso8601String(),
          'updatedAt': DateTime(2026, 2, 1).toIso8601String(),
        },
      ]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await expandUserAndTapAction(tester, 'Cancel Target', 'Warn');
      expect(find.byType(AlertDialog), findsOneWidget);

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('mute dialog shows duration dropdown', (tester) async {
      await seedAdmin();
      await seedUsers([
        {
          'userId': 'user-mute-dur-1',
          'displayName': 'Duration Target',
          'email': 'duration@example.com',
          'isOnline': false,
          'level': 1,
          'experiencePoints': 0,
          'favoriteTeams': [],
          'badges': [],
          'createdAt': DateTime(2026, 1, 15).toIso8601String(),
          'updatedAt': DateTime(2026, 2, 1).toIso8601String(),
        },
      ]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await expandUserAndTapAction(tester, 'Duration Target', 'Mute');

      // The mute dialog has a DropdownButtonFormField for duration
      expect(find.byType(DropdownButtonFormField<Duration>), findsOneWidget);
      // Default shows "24 hours"
      expect(find.text('24 hours'), findsOneWidget);
    });

    testWidgets('suspend dialog shows duration dropdown', (tester) async {
      await seedAdmin();
      await seedUsers([
        {
          'userId': 'user-suspend-1',
          'displayName': 'Suspend Target',
          'email': 'suspend@example.com',
          'isOnline': false,
          'level': 1,
          'experiencePoints': 0,
          'favoriteTeams': [],
          'badges': [],
          'createdAt': DateTime(2026, 1, 15).toIso8601String(),
          'updatedAt': DateTime(2026, 2, 1).toIso8601String(),
        },
      ]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await expandUserAndTapAction(tester, 'Suspend Target', 'Suspend');

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Suspend Suspend Target'), findsOneWidget);
      expect(find.text('Suspend User'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<Duration>), findsOneWidget);
      // Default shows "7 days"
      expect(find.text('7 days'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Search functionality
  // ---------------------------------------------------------------------------

  group('AdminUsersScreen - Search', () {
    testWidgets('search field is present and editable', (tester) async {
      await seedAdmin();

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      // Enter text in the search field
      await tester.enterText(textField, 'John');
      await tester.pumpAndSettle();

      expect(find.text('John'), findsOneWidget);
    });

    testWidgets('shows RefreshIndicator when users are present',
        (tester) async {
      await seedAdmin();
      await seedUsers([
        {
          'userId': 'user-refresh-1',
          'displayName': 'Refresh User',
          'email': 'refresh@example.com',
          'isOnline': false,
          'level': 1,
          'experiencePoints': 0,
          'favoriteTeams': [],
          'badges': [],
          'createdAt': DateTime(2026, 2, 1).toIso8601String(),
          'updatedAt': DateTime(2026, 2, 1).toIso8601String(),
        },
      ]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });
  });
}

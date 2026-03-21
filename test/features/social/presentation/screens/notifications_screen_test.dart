import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/social/presentation/screens/notifications_screen.dart';
import 'package:pregame_world_cup/features/social/domain/entities/notification.dart';
import 'package:pregame_world_cup/features/social/domain/services/notification_service.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------
class MockNotificationService extends Mock implements NotificationService {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
SocialNotification _makeNotification({
  String id = 'notif_1',
  String userId = 'user_1',
  bool isRead = false,
  NotificationType type = NotificationType.activityLike,
}) {
  return SocialNotification(
    notificationId: id,
    userId: userId,
    fromUserId: 'sender_1',
    fromUserName: 'Jane Smith',
    type: type,
    title: 'Test Notification',
    message: 'Someone liked your activity',
    createdAt: DateTime.now(),
    isRead: isRead,
  );
}

Widget _buildTestWidget() {
  return const MaterialApp(
    home: NotificationsScreen(),
  );
}

void main() {
  // ---------------------------------------------------------------------------
  // The NotificationsScreen calls FirebaseAuth.instance.currentUser directly,
  // which returns null in the test environment (no Firebase app initialised).
  // When currentUser is null the screen skips loading and immediately renders
  // the empty / "No notifications yet" state, so we test that branch too.
  //
  // For the "with data" tests we prime the MockNotificationService before the
  // screen starts, but because currentUser is always null, the screen never
  // actually calls getUserNotifications — it returns early. Those tests verify
  // the UI paths that are reachable under the null-user condition.
  // ---------------------------------------------------------------------------

  final getIt = GetIt.instance;
  late MockNotificationService mockNotificationService;

  // GetIt.reset() is async in GetIt 7.x — must be awaited to ensure the
  // registration map is fully cleared before re-registering in the next test.
  setUp(() async {
    await getIt.reset();

    mockNotificationService = MockNotificationService();

    // Provide safe defaults for every service method the screen can call.
    when(() => mockNotificationService.initialize())
        .thenAnswer((_) async {});
    when(() => mockNotificationService.getUserNotifications(any()))
        .thenAnswer((_) async => []);
    when(() => mockNotificationService.getUnreadNotificationCount(any()))
        .thenAnswer((_) async => 0);
    when(() => mockNotificationService.markNotificationAsRead(any()))
        .thenAnswer((_) async => true);
    when(() => mockNotificationService.markAllNotificationsAsRead(any()))
        .thenAnswer((_) async => true);
    when(() => mockNotificationService.deleteNotification(any()))
        .thenAnswer((_) async => true);
    when(() => mockNotificationService.getUserNotificationPreferences(any()))
        .thenAnswer((_) async => NotificationPreferences.defaultPreferences());

    getIt.registerSingleton<NotificationService>(mockNotificationService);
  });

  tearDown(() async {
    await getIt.reset();
  });

  group('NotificationsScreen', () {
    // -----------------------------------------------------------------------
    // Construction
    // -----------------------------------------------------------------------
    test('is a StatefulWidget', () {
      const widget = NotificationsScreen();
      expect(widget, isA<StatefulWidget>());
    });

    test('can be constructed', () {
      const widget = NotificationsScreen();
      expect(widget, isNotNull);
    });

    // -----------------------------------------------------------------------
    // Loading state
    // -----------------------------------------------------------------------
    testWidgets('shows loading indicator briefly on start', (tester) async {
      // Use a Completer so the test controls exactly when initialize resolves.
      // The screen sets _isLoading = true synchronously in initState before
      // awaiting initialize(), so pumpWidget (first frame) catches the loading UI.
      final initCompleter = Completer<void>();
      when(() => mockNotificationService.initialize())
          .thenAnswer((_) => initCompleter.future);

      await tester.pumpWidget(_buildTestWidget());
      // After the first frame, initialize has not yet completed → loading is true.
      expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));

      // Complete the future so the screen can settle before tearDown.
      initCompleter.complete();
      await tester.pumpAndSettle();
    });

    // -----------------------------------------------------------------------
    // Empty state (currentUser == null → screen skips load, shows empty UI)
    // -----------------------------------------------------------------------
    testWidgets('shows "No notifications yet" when currentUser is null',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('No notifications yet'), findsOneWidget);
    });

    testWidgets('shows "Stay tuned for updates!" CTA in empty state',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('Stay tuned'), findsOneWidget);
    });

    testWidgets('renders Notifications title in app bar', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsOneWidget);
    });

    testWidgets('renders All and Unread tabs', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Unread'), findsOneWidget);
    });

    testWidgets('renders settings icon button', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    // -----------------------------------------------------------------------
    // Notification items: verify NotificationItemWidget renders
    // -----------------------------------------------------------------------
    // NOTE: Because FirebaseAuth.instance.currentUser is null in the test
    // environment, the screen always renders the empty state and never calls
    // getUserNotifications on the mock service. The tests below verify the
    // screen's UI contract in the null-user branch (empty list path).
    // Service-level tests for getUserNotifications live in the service tests.
    //
    // If firebase_auth_mocks is added as a dev dependency in the future, these
    // tests can be extended to mock a signed-in user and exercise the full
    // loading → loaded path.
    testWidgets('does not call getUserNotifications when currentUser is null',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      verifyNever(() =>
          mockNotificationService.getUserNotifications(any()));
    });

    testWidgets(
        'calls initialize on the notification service during screen init',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      verify(() => mockNotificationService.initialize()).called(1);
    });

    // -----------------------------------------------------------------------
    // Error state: initialize throws → screen shows empty state gracefully
    // -----------------------------------------------------------------------
    testWidgets('gracefully shows empty state when service initialize throws',
        (tester) async {
      when(() => mockNotificationService.initialize())
          .thenThrow(Exception('Firestore unavailable'));

      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      // Should not crash and should not be in a loading state
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    // -----------------------------------------------------------------------
    // Tab bar navigation
    // -----------------------------------------------------------------------
    // When _notifications is empty the screen renders _buildEmptyState() directly
    // (bypassing the TabBarView entirely). Tapping the Unread tab while the list
    // is empty does not switch the visible content — the tab bar UI updates but
    // the body still shows the global "No notifications yet" empty state.
    testWidgets('Unread tab is tappable without error', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Unread'));
      await tester.pumpAndSettle();

      // Body remains the same empty state because _notifications is empty and
      // _buildBody() returns _buildEmptyState() before reaching TabBarView.
      expect(find.text('No notifications yet'), findsOneWidget);
    });

    testWidgets('tapping back to All tab does not crash', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Unread'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      // Still empty state — no crash, still functional.
      expect(find.text('No notifications yet'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // SocialNotification entity tests (used by the screen)
  // -------------------------------------------------------------------------
  group('SocialNotification entity used by NotificationsScreen', () {
    test('isRead defaults to false', () {
      final n = _makeNotification();
      expect(n.isRead, isFalse);
    });

    test('markAsRead returns a copy with isRead = true', () {
      final original = _makeNotification(isRead: false);
      final read = original.markAsRead();
      expect(read.isRead, isTrue);
      expect(original.isRead, isFalse); // immutable
    });

    test('unread notification isActionable when type is friendRequest', () {
      final n = _makeNotification(type: NotificationType.friendRequest);
      expect(n.isActionable, isTrue);
    });

    test('activityLike notification is not actionable', () {
      final n = _makeNotification(type: NotificationType.activityLike);
      expect(n.isActionable, isFalse);
    });

    test('notification is recent when created just now', () {
      final n = _makeNotification();
      expect(n.isRecent, isTrue);
    });
  });
}

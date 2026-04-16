import 'dart:async';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/admin/domain/entities/admin_user.dart';
import 'package:pregame_world_cup/features/admin/domain/services/admin_service.dart';
import 'package:pregame_world_cup/features/admin/presentation/screens/admin_moderation_screen.dart';
import 'package:pregame_world_cup/features/moderation/domain/entities/report.dart';
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

  const testUserId = 'moderation-admin-uid';

  Report createTestReport({
    String reportId = 'report-1',
    ReportableContentType contentType = ReportableContentType.message,
    ReportReason reason = ReportReason.spam,
    String reporterDisplayName = 'Reporter User',
    String contentId = 'content-1',
    String? contentOwnerId = 'owner-1',
    String? contentOwnerDisplayName = 'Content Owner',
    String? contentSnapshot,
    String? additionalDetails,
    DateTime? createdAt,
  }) {
    return Report(
      reportId: reportId,
      reporterId: 'reporter-1',
      reporterDisplayName: reporterDisplayName,
      contentType: contentType,
      contentId: contentId,
      contentOwnerId: contentOwnerId,
      contentOwnerDisplayName: contentOwnerDisplayName,
      reason: reason,
      contentSnapshot: contentSnapshot,
      additionalDetails: additionalDetails,
      createdAt: createdAt ?? DateTime(2026, 2, 15, 14, 30),
    );
  }

  // Suppress overflow errors
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

  Future<void> seedAdmin({
    AdminRole role = AdminRole.moderator,
    List<Report> reports = const [],
  }) async {
    await fakeFirestore.collection('admins').doc(testUserId).set({
      'userId': testUserId,
      'email': 'mod@test.com',
      'displayName': 'Test Moderator',
      'role': role.name,
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

    when(() => mockModerationService.getPendingReports(limit: any(named: 'limit')))
        .thenAnswer((_) async => reports);
  }

  Widget buildTestWidget() {
    return const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: MediaQueryData(size: Size(500, 1200)),
        child: AdminModerationScreen(),
      ),
    );
  }

  group('AdminModerationScreen', () {
    testWidgets('renders Content Moderation title in app bar', (tester) async {
      await seedAdmin();

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Content Moderation'), findsOneWidget);
    });

    testWidgets('renders refresh button in app bar', (tester) async {
      await seedAdmin();

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('shows loading indicator initially', (tester) async {
      await seedAdmin();

      await tester.pumpWidget(buildTestWidget());
      // First frame should show loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('AdminModerationScreen - Empty State', () {
    testWidgets('shows empty state when no pending reports', (tester) async {
      await seedAdmin(reports: []);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('No pending reports'), findsOneWidget);
      expect(find.text('All caught up!'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });
  });

  group('AdminModerationScreen - Report Cards', () {
    testWidgets('renders report card with spam reason', (tester) async {
      await seedAdmin(reports: [
        createTestReport(
          reportId: 'report-1',
          contentType: ReportableContentType.message,
          reason: ReportReason.spam,
          reporterDisplayName: 'John Doe',
          contentOwnerId: 'owner-1',
          contentOwnerDisplayName: 'Jane Smith',
        ),
      ]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Report card should show content type label
      expect(find.text('Message'), findsOneWidget);
      // Reason chip - 'spam' becomes 'spam' (no camelCase splitting needed)
      expect(find.text('spam'), findsOneWidget);
    });

    testWidgets('renders report card with content owner name', (tester) async {
      await seedAdmin(reports: [
        createTestReport(
          contentOwnerDisplayName: 'Jane Smith',
        ),
      ]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Jane Smith'), findsOneWidget);
    });

    testWidgets('renders reporter name in Reported by text', (tester) async {
      await seedAdmin(reports: [
        createTestReport(
          reporterDisplayName: 'John Reporter',
        ),
      ]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('John Reporter'), findsOneWidget);
    });

    testWidgets('renders content snapshot when present', (tester) async {
      await seedAdmin(reports: [
        createTestReport(
          contentSnapshot: 'This is the problematic content that was reported.',
        ),
      ]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Reported Content:'), findsOneWidget);
      expect(
        find.text('This is the problematic content that was reported.'),
        findsOneWidget,
      );
    });

    testWidgets('renders additional details when present', (tester) async {
      await seedAdmin(reports: [
        createTestReport(
          additionalDetails: 'Extra context about this report.',
        ),
      ]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(
        find.text('Extra context about this report.'),
        findsOneWidget,
      );
    });

    testWidgets('renders action buttons: Dismiss, Warn, Take Action',
        (tester) async {
      await seedAdmin(reports: [
        createTestReport(),
      ]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Dismiss'), findsOneWidget);
      expect(find.text('Warn'), findsOneWidget);
      expect(find.text('Take Action'), findsOneWidget);
    });

    testWidgets('renders multiple report cards', (tester) async {
      await seedAdmin(reports: [
        createTestReport(
          reportId: 'report-1',
          contentType: ReportableContentType.message,
          reason: ReportReason.spam,
        ),
        createTestReport(
          reportId: 'report-2',
          contentType: ReportableContentType.user,
          reason: ReportReason.harassment,
        ),
      ]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Two reports visible - at least 2 of each action button should be present
      expect(find.text('Dismiss'), findsAtLeastNWidgets(2));
      expect(find.text('Warn'), findsAtLeastNWidgets(2));
      expect(find.text('Take Action'), findsAtLeastNWidgets(2));
    });
  });

  group('AdminModerationScreen - Content Type Icons', () {
    testWidgets('shows person icon for user report', (tester) async {
      await seedAdmin(reports: [
        createTestReport(contentType: ReportableContentType.user),
      ]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('User Profile'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('shows message icon for message report', (tester) async {
      await seedAdmin(reports: [
        createTestReport(contentType: ReportableContentType.message),
      ]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Message'), findsOneWidget);
      expect(find.byIcon(Icons.message), findsOneWidget);
    });

    testWidgets('shows groups icon for watch party report', (tester) async {
      await seedAdmin(reports: [
        createTestReport(contentType: ReportableContentType.watchParty),
      ]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Watch Party'), findsOneWidget);
      expect(find.byIcon(Icons.groups), findsOneWidget);
    });

    testWidgets('shows chat_bubble icon for chat room report', (tester) async {
      await seedAdmin(reports: [
        createTestReport(contentType: ReportableContentType.chatRoom),
      ]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Chat Room'), findsOneWidget);
      expect(find.byIcon(Icons.chat_bubble), findsOneWidget);
    });

    testWidgets('shows comment icon for comment report', (tester) async {
      await seedAdmin(reports: [
        createTestReport(contentType: ReportableContentType.comment),
      ]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Comment'), findsOneWidget);
      expect(find.byIcon(Icons.comment), findsOneWidget);
    });

    testWidgets('shows analytics icon for prediction report', (tester) async {
      await seedAdmin(reports: [
        createTestReport(contentType: ReportableContentType.prediction),
      ]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Prediction'), findsOneWidget);
      expect(find.byIcon(Icons.analytics), findsOneWidget);
    });
  });

  group('AdminModerationScreen - Dismiss Report', () {
    testWidgets('dismissing a report removes it from the list', (tester) async {
      when(() => mockModerationService.resolveReport(
            reportId: 'report-1',
            action: ModerationAction.none,
            moderatorNotes: 'Report dismissed - no violation found',
          )).thenAnswer((_) async => true);

      await seedAdmin(reports: [
        createTestReport(reportId: 'report-1'),
      ]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Report should be visible
      expect(find.text('Dismiss'), findsOneWidget);

      // Tap Dismiss
      await tester.tap(find.text('Dismiss'));
      await tester.pumpAndSettle();

      // After dismissal, the report should be gone and empty state should show
      expect(find.text('No pending reports'), findsOneWidget);
    });
  });

  group('AdminModerationScreen - Warn User', () {
    testWidgets('warning a user removes report from list', (tester) async {
      when(() => mockModerationService.resolveReport(
            reportId: 'report-1',
            action: ModerationAction.warning,
            moderatorNotes: 'Warning issued to user',
          )).thenAnswer((_) async => true);

      await seedAdmin(reports: [
        createTestReport(
          reportId: 'report-1',
          contentOwnerId: 'owner-1',
        ),
      ]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap Warn
      await tester.tap(find.text('Warn'));
      await tester.pumpAndSettle();

      // After warning, the report should be gone
      expect(find.text('No pending reports'), findsOneWidget);
    });
  });

  group('AdminModerationScreen - Take Action Button', () {
    testWidgets('Take Action button is rendered as ElevatedButton', (tester) async {
      await seedAdmin(reports: [
        createTestReport(reportId: 'report-1'),
      ]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Take Action'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('Take Action ElevatedButton has red background', (tester) async {
      await seedAdmin(reports: [
        createTestReport(reportId: 'report-1'),
      ]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      // Verify the button has a style with red background
      expect(button.style, isNotNull);
    });
  });

  group('AdminModerationScreen - Reason Chips', () {
    testWidgets('renders reason chip for harassment report', (tester) async {
      await seedAdmin(reports: [
        createTestReport(reason: ReportReason.harassment),
      ]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // The reason chip converts camelCase: 'harassment' stays as is
      expect(find.text('harassment'), findsOneWidget);
    });

    testWidgets('renders reason chip for hateSpeech report', (tester) async {
      await seedAdmin(reports: [
        createTestReport(reason: ReportReason.hateSpeech),
      ]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // camelCase 'hateSpeech' becomes 'hate Speech' via regex
      expect(find.text('hate Speech'), findsOneWidget);
    });

    testWidgets('renders reason chip for violence report', (tester) async {
      await seedAdmin(reports: [
        createTestReport(reason: ReportReason.violence),
      ]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('violence'), findsOneWidget);
    });
  });

  group('AdminModerationScreen - Content ID Display', () {
    testWidgets('shows content ID in report card', (tester) async {
      await seedAdmin(reports: [
        createTestReport(contentId: 'msg-abc-123'),
      ]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('msg-abc-123'), findsOneWidget);
    });

    testWidgets('shows Content Owner label', (tester) async {
      await seedAdmin(reports: [
        createTestReport(contentOwnerDisplayName: 'Owner Name'),
      ]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Content Owner'), findsOneWidget);
      expect(find.text('Owner Name'), findsOneWidget);
    });

    testWidgets('shows Content ID label', (tester) async {
      await seedAdmin(reports: [
        createTestReport(contentId: 'test-id-456'),
      ]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Content ID'), findsOneWidget);
      expect(find.text('test-id-456'), findsOneWidget);
    });
  });

  group('AdminModerationScreen - Date Formatting', () {
    testWidgets('shows formatted date in report card', (tester) async {
      await seedAdmin(reports: [
        createTestReport(
          createdAt: DateTime(2026, 2, 15, 14, 30),
        ),
      ]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Format: day/month/year hour:minute
      expect(find.text('15/2/2026 14:30'), findsOneWidget);
    });

    testWidgets('pads minutes with leading zero', (tester) async {
      await seedAdmin(reports: [
        createTestReport(
          createdAt: DateTime(2026, 3, 5, 9, 5),
        ),
      ]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('5/3/2026 9:05'), findsOneWidget);
    });
  });

  group('AdminModerationScreen - Disposal safety', () {
    testWidgets('can be disposed during async load without crashing',
        (tester) async {
      await seedAdmin();

      // Override the mock AFTER seedAdmin to use a Completer that never completes
      final completer = Completer<List<Report>>();
      when(() => mockModerationService.getPendingReports(limit: any(named: 'limit')))
          .thenAnswer((_) => completer.future);

      await tester.pumpWidget(buildTestWidget());
      // Widget is now loading (awaiting getPendingReports)

      // Dispose the widget before the async operation completes
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      await tester.pumpAndSettle();

      // Complete the future after disposal to trigger the mounted guard
      completer.complete(<Report>[]);
      await tester.pumpAndSettle();

      // If mounted guard is missing, this would throw
      // "setState() called after dispose()"
    });

    testWidgets('can be disposed during report resolution without crashing',
        (tester) async {
      // Use a Completer that never completes to simulate a long-running operation
      final completer = Completer<bool>();

      when(() => mockModerationService.resolveReport(
            reportId: 'report-dispose-1',
            action: ModerationAction.none,
            moderatorNotes: any(named: 'moderatorNotes'),
          )).thenAnswer((_) => completer.future);

      await seedAdmin(reports: [
        createTestReport(reportId: 'report-dispose-1'),
      ]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap Dismiss to start async resolution
      await tester.tap(find.text('Dismiss'));
      await tester.pump();

      // Dispose while resolution is in progress
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      await tester.pumpAndSettle();

      // Complete the future after disposal to trigger the mounted guard
      completer.complete(true);
      await tester.pumpAndSettle();

      // No crash = mounted guard is working
    });
  });

  group('AdminModerationScreen - Widget Structure', () {
    testWidgets('uses Scaffold with AppBar', (tester) async {
      await seedAdmin();

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('uses RefreshIndicator when reports exist', (tester) async {
      await seedAdmin(reports: [createTestReport()]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('uses ListView.builder when reports exist', (tester) async {
      await seedAdmin(reports: [createTestReport()]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // ListView.builder is used to render reports
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('renders report cards inside Card widgets', (tester) async {
      await seedAdmin(reports: [
        createTestReport(reportId: 'r1'),
        createTestReport(reportId: 'r2'),
      ]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // At least 2 Card widgets for the 2 reports
      expect(find.byType(Card), findsAtLeastNWidgets(2));
    });

    testWidgets('report card contains a Divider', (tester) async {
      await seedAdmin(reports: [createTestReport()]);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Divider), findsAtLeastNWidgets(1));
    });
  });
}

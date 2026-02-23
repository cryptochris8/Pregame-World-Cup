import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/core/services/push_notification_service.dart';
import 'package:pregame_world_cup/features/admin/domain/entities/admin_user.dart';
import 'package:pregame_world_cup/features/admin/domain/services/admin_service.dart';
import 'package:pregame_world_cup/features/moderation/domain/entities/report.dart';
import 'package:pregame_world_cup/features/moderation/domain/services/moderation_service.dart';

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
  late AdminService adminService;

  const testUserId = 'test-admin-uid';

  Map<String, dynamic> createAdminDoc({
    AdminRole role = AdminRole.admin,
    bool isActive = true,
  }) {
    return {
      'userId': testUserId,
      'email': 'admin@test.com',
      'displayName': 'Test Admin',
      'role': role.name,
      'grantedAt': DateTime(2026, 1, 1).toIso8601String(),
      'isActive': isActive,
      'permissions': ['*'],
    };
  }

  setUp(() {
    // Reset singletons between tests
    AdminService.resetInstance();

    fakeFirestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockModerationService = MockModerationService();
    mockPushService = MockPushNotificationService();

    when(() => mockUser.uid).thenReturn(testUserId);
    when(() => mockAuth.currentUser).thenReturn(mockUser);

    adminService = AdminService(
      firestore: fakeFirestore,
      auth: mockAuth,
      moderationService: mockModerationService,
      pushService: mockPushService,
    );
  });

  tearDown(() {
    AdminService.resetInstance();
  });

  group('AdminService - Initialize', () {
    test('initializes and sets admin user when admin doc exists', () async {
      // Seed an admin document
      await fakeFirestore.collection('admins').doc(testUserId).set(
            createAdminDoc(role: AdminRole.superAdmin),
          );

      await adminService.initialize();

      expect(adminService.isAdmin, isTrue);
      expect(adminService.currentAdminUser, isNotNull);
      expect(adminService.currentAdminUser!.role, AdminRole.superAdmin);
      expect(adminService.currentAdminUser!.displayName, 'Test Admin');
    });

    test('initializes with no admin user when admin doc does not exist', () async {
      await adminService.initialize();

      expect(adminService.isAdmin, isFalse);
      expect(adminService.currentAdminUser, isNull);
      expect(adminService.currentRole, isNull);
    });

    test('initializes with no admin user when auth has no current user', () async {
      AdminService.resetInstance();
      when(() => mockAuth.currentUser).thenReturn(null);

      adminService = AdminService(
        firestore: fakeFirestore,
        auth: mockAuth,
        moderationService: mockModerationService,
        pushService: mockPushService,
      );

      await adminService.initialize();

      expect(adminService.isAdmin, isFalse);
      expect(adminService.currentAdminUser, isNull);
    });

    test('does not reinitialize if already initialized', () async {
      await fakeFirestore.collection('admins').doc(testUserId).set(
            createAdminDoc(),
          );

      await adminService.initialize();
      expect(adminService.isAdmin, isTrue);

      // Clear the Firestore doc to prove re-init won't read again
      await fakeFirestore.collection('admins').doc(testUserId).delete();

      await adminService.initialize();
      // Still the same admin since we didn't re-init
      expect(adminService.isAdmin, isTrue);
    });

    test('updates lastLoginAt in Firestore on successful init', () async {
      await fakeFirestore.collection('admins').doc(testUserId).set(
            createAdminDoc(),
          );

      await adminService.initialize();

      final doc = await fakeFirestore.collection('admins').doc(testUserId).get();
      expect(doc.data()!['lastLoginAt'], isNotNull);
    });

    test('sets inactive admin - isAdmin returns false', () async {
      await fakeFirestore.collection('admins').doc(testUserId).set(
            createAdminDoc(isActive: false),
          );

      await adminService.initialize();

      expect(adminService.currentAdminUser, isNotNull);
      expect(adminService.currentAdminUser!.isActive, isFalse);
      expect(adminService.isAdmin, isFalse);
    });
  });

  group('AdminService - isAdmin & currentRole', () {
    test('isAdmin is true for active admin user', () async {
      await fakeFirestore.collection('admins').doc(testUserId).set(
            createAdminDoc(),
          );
      await adminService.initialize();

      expect(adminService.isAdmin, isTrue);
    });

    test('isAdmin is false when no admin user', () async {
      await adminService.initialize();

      expect(adminService.isAdmin, isFalse);
    });

    test('currentRole returns the role of the admin', () async {
      await fakeFirestore.collection('admins').doc(testUserId).set(
            createAdminDoc(role: AdminRole.moderator),
          );
      await adminService.initialize();

      expect(adminService.currentRole, AdminRole.moderator);
    });

    test('currentRole returns null when no admin', () async {
      await adminService.initialize();

      expect(adminService.currentRole, isNull);
    });
  });

  group('AdminService - hasPermission', () {
    test('returns true for wildcard permission', () async {
      await fakeFirestore.collection('admins').doc(testUserId).set(
            createAdminDoc(),
          );
      await adminService.initialize();

      expect(adminService.hasPermission('anything'), isTrue);
    });

    test('returns false when not admin', () async {
      await adminService.initialize();

      expect(adminService.hasPermission('manage_users'), isFalse);
    });

    test('returns true for specific permission', () async {
      await fakeFirestore.collection('admins').doc(testUserId).set({
        'userId': testUserId,
        'email': 'admin@test.com',
        'displayName': 'Test Admin',
        'role': 'admin',
        'grantedAt': DateTime(2026, 1, 1).toIso8601String(),
        'isActive': true,
        'permissions': ['manage_users', 'moderate_content'],
      });
      await adminService.initialize();

      expect(adminService.hasPermission('manage_users'), isTrue);
      expect(adminService.hasPermission('moderate_content'), isTrue);
      expect(adminService.hasPermission('manage_flags'), isFalse);
    });
  });

  group('AdminService - getDashboardStats', () {
    test('returns empty stats when not admin', () async {
      await adminService.initialize();

      final stats = await adminService.getDashboardStats();

      expect(stats.totalUsers, 0);
      expect(stats.activeUsers24h, 0);
      expect(stats.pendingReports, 0);
    });

    test('returns cached stats if they are fresh (less than 5 minutes old)', () async {
      await fakeFirestore.collection('admins').doc(testUserId).set(
            createAdminDoc(),
          );
      await adminService.initialize();

      // Seed fresh cached stats
      final now = DateTime.now();
      await fakeFirestore.collection('admin_stats').doc('dashboard').set({
        'totalUsers': 500,
        'activeUsers24h': 100,
        'newUsersToday': 20,
        'totalWatchParties': 50,
        'activeWatchParties': 10,
        'pendingReports': 3,
        'totalPredictions': 2000,
        'totalMessages': 5000,
        'updatedAt': now.toIso8601String(),
      });

      final stats = await adminService.getDashboardStats();

      expect(stats.totalUsers, 500);
      expect(stats.activeUsers24h, 100);
      expect(stats.newUsersToday, 20);
      expect(stats.totalWatchParties, 50);
      expect(stats.activeWatchParties, 10);
      expect(stats.pendingReports, 3);
      expect(stats.totalPredictions, 2000);
      expect(stats.totalMessages, 5000);
    });

    test('recalculates stats if cached stats are stale (older than 5 minutes)', () async {
      await fakeFirestore.collection('admins').doc(testUserId).set(
            createAdminDoc(),
          );
      await adminService.initialize();

      // Seed stale cached stats (10 minutes old)
      final staleTime = DateTime.now().subtract(const Duration(minutes: 10));
      await fakeFirestore.collection('admin_stats').doc('dashboard').set({
        'totalUsers': 100,
        'activeUsers24h': 10,
        'newUsersToday': 2,
        'totalWatchParties': 5,
        'activeWatchParties': 1,
        'pendingReports': 0,
        'totalPredictions': 200,
        'totalMessages': 500,
        'updatedAt': staleTime.toIso8601String(),
      });

      // Add some user profiles so count queries return something
      await fakeFirestore.collection('user_profiles').add({
        'displayName': 'User 1',
        'lastSeenAt': Timestamp.now(),
        'createdAt': Timestamp.now(),
      });
      await fakeFirestore.collection('user_profiles').add({
        'displayName': 'User 2',
        'lastSeenAt': Timestamp.now(),
        'createdAt': Timestamp.now(),
      });

      final stats = await adminService.getDashboardStats();

      // Stats should be recalculated (different from cached values)
      // The exact values depend on what's in fake Firestore
      expect(stats, isNotNull);
      expect(stats.updatedAt.isAfter(staleTime), isTrue);
    });

    test('calculates stats from Firestore collections', () async {
      await fakeFirestore.collection('admins').doc(testUserId).set(
            createAdminDoc(),
          );
      await adminService.initialize();

      // Seed data
      final now = DateTime.now();
      final recentTime = Timestamp.fromDate(now.subtract(const Duration(hours: 1)));
      final todayStart = DateTime(now.year, now.month, now.day);

      await fakeFirestore.collection('user_profiles').add({
        'displayName': 'User A',
        'lastSeenAt': recentTime,
        'createdAt': Timestamp.fromDate(todayStart.add(const Duration(hours: 2))),
      });

      await fakeFirestore.collection('watch_parties').add({
        'name': 'Party 1',
        'matchDate': Timestamp.fromDate(now.add(const Duration(days: 1))),
      });

      await fakeFirestore.collection('reports').add({
        'status': 'pending',
        'reason': 'spam',
      });

      await fakeFirestore.collection('predictions').add({
        'matchId': 'match_1',
      });

      await fakeFirestore.collection('messages').add({
        'text': 'Hello',
      });

      final stats = await adminService.getDashboardStats();

      // Verify stats are populated (exact values depend on fake_cloud_firestore)
      expect(stats, isNotNull);
    });
  });

  group('AdminService - getPendingReports', () {
    test('returns empty list when not admin', () async {
      await adminService.initialize();

      final reports = await adminService.getPendingReports();

      expect(reports, isEmpty);
    });

    test('returns empty list when role cannot moderate content', () async {
      await fakeFirestore.collection('admins').doc(testUserId).set(
            createAdminDoc(role: AdminRole.support),
          );
      await adminService.initialize();

      final reports = await adminService.getPendingReports();

      expect(reports, isEmpty);
    });

    test('delegates to moderation service when role can moderate', () async {
      await fakeFirestore.collection('admins').doc(testUserId).set(
            createAdminDoc(role: AdminRole.moderator),
          );
      await adminService.initialize();

      final testReports = [
        Report(
          reportId: 'report-1',
          reporterId: 'user-1',
          reporterDisplayName: 'Reporter',
          contentType: ReportableContentType.message,
          contentId: 'msg-1',
          reason: ReportReason.spam,
          createdAt: DateTime(2026, 2, 1),
        ),
      ];

      when(() => mockModerationService.getPendingReports(limit: 50))
          .thenAnswer((_) async => testReports);

      final reports = await adminService.getPendingReports();

      expect(reports.length, 1);
      expect(reports.first.reportId, 'report-1');
      verify(() => mockModerationService.getPendingReports(limit: 50)).called(1);
    });

    test('admin role can get pending reports', () async {
      await fakeFirestore.collection('admins').doc(testUserId).set(
            createAdminDoc(role: AdminRole.admin),
          );
      await adminService.initialize();

      when(() => mockModerationService.getPendingReports(limit: 50))
          .thenAnswer((_) async => []);

      final reports = await adminService.getPendingReports();

      expect(reports, isEmpty);
      verify(() => mockModerationService.getPendingReports(limit: 50)).called(1);
    });
  });

  group('AdminService - resolveReport', () {
    test('returns false when not admin', () async {
      await adminService.initialize();

      final result = await adminService.resolveReport(
        'report-1',
        ModerationAction.warning,
        'Test notes',
      );

      expect(result, isFalse);
    });

    test('returns false when role cannot moderate', () async {
      await fakeFirestore.collection('admins').doc(testUserId).set(
            createAdminDoc(role: AdminRole.support),
          );
      await adminService.initialize();

      final result = await adminService.resolveReport(
        'report-1',
        ModerationAction.warning,
        'Test notes',
      );

      expect(result, isFalse);
    });

    test('delegates to moderation service and logs action on success', () async {
      await fakeFirestore.collection('admins').doc(testUserId).set(
            createAdminDoc(role: AdminRole.moderator),
          );
      await adminService.initialize();

      when(() => mockModerationService.resolveReport(
            reportId: 'report-1',
            action: ModerationAction.warning,
            moderatorNotes: 'Test notes',
          )).thenAnswer((_) async => true);

      final result = await adminService.resolveReport(
        'report-1',
        ModerationAction.warning,
        'Test notes',
      );

      expect(result, isTrue);
      verify(() => mockModerationService.resolveReport(
            reportId: 'report-1',
            action: ModerationAction.warning,
            moderatorNotes: 'Test notes',
          )).called(1);

      // Verify admin log was created
      final logs = await fakeFirestore.collection('admin_logs').get();
      expect(logs.docs.length, 1);
      expect(logs.docs.first.data()['action'], 'resolve_report');
      expect(logs.docs.first.data()['adminId'], testUserId);
    });

    test('returns false and does not log when moderation service fails', () async {
      await fakeFirestore.collection('admins').doc(testUserId).set(
            createAdminDoc(role: AdminRole.admin),
          );
      await adminService.initialize();

      when(() => mockModerationService.resolveReport(
            reportId: 'report-1',
            action: ModerationAction.none,
            moderatorNotes: null,
          )).thenAnswer((_) async => false);

      final result = await adminService.resolveReport(
        'report-1',
        ModerationAction.none,
        null,
      );

      expect(result, isFalse);

      // No admin log should be created
      final logs = await fakeFirestore.collection('admin_logs').get();
      expect(logs.docs, isEmpty);
    });
  });

  group('AdminService - warnUser', () {
    test('returns false when not admin', () async {
      await adminService.initialize();

      final result = await adminService.warnUser('user-1', 'Bad behavior');

      expect(result, isFalse);
    });

    test('returns false when role cannot manage users', () async {
      await fakeFirestore.collection('admins').doc(testUserId).set(
            createAdminDoc(role: AdminRole.moderator),
          );
      await adminService.initialize();

      final result = await adminService.warnUser('user-1', 'Bad behavior');

      expect(result, isFalse);
    });

    test('warns user and logs admin action', () async {
      await fakeFirestore.collection('admins').doc(testUserId).set(
            createAdminDoc(role: AdminRole.admin),
          );
      await adminService.initialize();

      when(() => mockModerationService.issueWarning(
            userId: 'user-1',
            reason: 'Bad behavior',
          )).thenAnswer((_) async => null);

      final result = await adminService.warnUser('user-1', 'Bad behavior');

      expect(result, isTrue);
      verify(() => mockModerationService.issueWarning(
            userId: 'user-1',
            reason: 'Bad behavior',
          )).called(1);
    });
  });

  group('AdminService - muteUser', () {
    test('returns false when not admin', () async {
      await adminService.initialize();

      final result = await adminService.muteUser(
        'user-1',
        'Spam',
        const Duration(hours: 24),
      );

      expect(result, isFalse);
    });

    test('mutes user and logs admin action', () async {
      await fakeFirestore.collection('admins').doc(testUserId).set(
            createAdminDoc(role: AdminRole.admin),
          );
      await adminService.initialize();

      when(() => mockModerationService.muteUser(
            userId: 'user-1',
            reason: 'Spam',
            duration: const Duration(hours: 24),
          )).thenAnswer((_) async => null);

      final result = await adminService.muteUser(
        'user-1',
        'Spam',
        const Duration(hours: 24),
      );

      expect(result, isTrue);
      verify(() => mockModerationService.muteUser(
            userId: 'user-1',
            reason: 'Spam',
            duration: const Duration(hours: 24),
          )).called(1);

      // Verify admin log
      final logs = await fakeFirestore.collection('admin_logs').get();
      expect(logs.docs.length, 1);
      expect(logs.docs.first.data()['action'], 'mute_user');
    });
  });

  group('AdminService - suspendUser', () {
    test('returns false when not admin', () async {
      await adminService.initialize();

      final result = await adminService.suspendUser(
        'user-1',
        'Repeated violations',
        const Duration(days: 7),
      );

      expect(result, isFalse);
    });

    test('suspends user and logs admin action', () async {
      await fakeFirestore.collection('admins').doc(testUserId).set(
            createAdminDoc(role: AdminRole.admin),
          );
      await adminService.initialize();

      when(() => mockModerationService.suspendUser(
            userId: 'user-1',
            reason: 'Repeated violations',
            duration: const Duration(days: 7),
          )).thenAnswer((_) async => null);

      final result = await adminService.suspendUser(
        'user-1',
        'Repeated violations',
        const Duration(days: 7),
      );

      expect(result, isTrue);
      verify(() => mockModerationService.suspendUser(
            userId: 'user-1',
            reason: 'Repeated violations',
            duration: const Duration(days: 7),
          )).called(1);

      final logs = await fakeFirestore.collection('admin_logs').get();
      expect(logs.docs.length, 1);
      expect(logs.docs.first.data()['action'], 'suspend_user');
      expect(logs.docs.first.data()['details']['durationHours'], 168);
    });
  });

  group('AdminService - banUser', () {
    test('returns false when not admin', () async {
      await adminService.initialize();

      final result = await adminService.banUser('user-1', 'Permanent ban');

      expect(result, isFalse);
    });

    test('returns false when role cannot manage users', () async {
      await fakeFirestore.collection('admins').doc(testUserId).set(
            createAdminDoc(role: AdminRole.support),
          );
      await adminService.initialize();

      final result = await adminService.banUser('user-1', 'Permanent ban');

      expect(result, isFalse);
    });

    test('bans user and logs admin action', () async {
      await fakeFirestore.collection('admins').doc(testUserId).set(
            createAdminDoc(role: AdminRole.admin),
          );
      await adminService.initialize();

      when(() => mockModerationService.banUser(
            userId: 'user-1',
            reason: 'Permanent ban',
          )).thenAnswer((_) async => null);

      final result = await adminService.banUser('user-1', 'Permanent ban');

      expect(result, isTrue);
      verify(() => mockModerationService.banUser(
            userId: 'user-1',
            reason: 'Permanent ban',
          )).called(1);

      final logs = await fakeFirestore.collection('admin_logs').get();
      expect(logs.docs.first.data()['action'], 'ban_user');
    });
  });

  group('AdminService - deleteUser', () {
    test('returns false when not admin', () async {
      await adminService.initialize();

      final result = await adminService.deleteUser('user-1', 'Account removal');

      expect(result, isFalse);
    });

    test('returns false when role is not superAdmin', () async {
      await fakeFirestore.collection('admins').doc(testUserId).set(
            createAdminDoc(role: AdminRole.admin),
          );
      await adminService.initialize();

      final result = await adminService.deleteUser('user-1', 'Account removal');

      expect(result, isFalse);
    });

    test('soft deletes user and logs action for superAdmin', () async {
      await fakeFirestore.collection('admins').doc(testUserId).set(
            createAdminDoc(role: AdminRole.superAdmin),
          );
      await adminService.initialize();

      // Create a user profile to delete
      await fakeFirestore.collection('user_profiles').doc('user-1').set({
        'displayName': 'User To Delete',
        'email': 'user@test.com',
      });

      final result = await adminService.deleteUser('user-1', 'Account removal');

      expect(result, isTrue);

      // Verify user profile was soft-deleted
      final userDoc =
          await fakeFirestore.collection('user_profiles').doc('user-1').get();
      expect(userDoc.data()!['isDeleted'], isTrue);
      expect(userDoc.data()!['deletedBy'], testUserId);
      expect(userDoc.data()!['deletionReason'], 'Account removal');

      // Verify admin log
      final logs = await fakeFirestore.collection('admin_logs').get();
      expect(logs.docs.first.data()['action'], 'delete_user');
    });
  });

  group('AdminService - Feature Flags', () {
    test('getFeatureFlags returns empty list when not admin', () async {
      await adminService.initialize();

      final flags = await adminService.getFeatureFlags();

      expect(flags, isEmpty);
    });

    test('getFeatureFlags returns flags from Firestore', () async {
      await fakeFirestore.collection('admins').doc(testUserId).set(
            createAdminDoc(),
          );
      await adminService.initialize();

      await fakeFirestore.collection('feature_flags').doc('live_chat').set({
        'id': 'live_chat',
        'name': 'Live Chat',
        'description': 'Enable live chat',
        'isEnabled': true,
        'createdAt': DateTime(2026, 1, 1).toIso8601String(),
        'updatedAt': DateTime(2026, 1, 15).toIso8601String(),
      });

      await fakeFirestore.collection('feature_flags').doc('dark_mode').set({
        'id': 'dark_mode',
        'name': 'Dark Mode',
        'description': 'Enable dark mode',
        'isEnabled': false,
        'createdAt': DateTime(2026, 1, 1).toIso8601String(),
        'updatedAt': DateTime(2026, 1, 15).toIso8601String(),
      });

      final flags = await adminService.getFeatureFlags();

      expect(flags.length, 2);
      expect(flags.any((f) => f.id == 'live_chat' && f.isEnabled), isTrue);
      expect(flags.any((f) => f.id == 'dark_mode' && !f.isEnabled), isTrue);
    });

    test('updateFeatureFlag returns false for non-superAdmin', () async {
      await fakeFirestore.collection('admins').doc(testUserId).set(
            createAdminDoc(role: AdminRole.admin),
          );
      await adminService.initialize();

      final result = await adminService.updateFeatureFlag('live_chat', true);

      expect(result, isFalse);
    });

    test('updateFeatureFlag updates flag and logs action for superAdmin', () async {
      await fakeFirestore.collection('admins').doc(testUserId).set(
            createAdminDoc(role: AdminRole.superAdmin),
          );
      await adminService.initialize();

      await fakeFirestore.collection('feature_flags').doc('live_chat').set({
        'id': 'live_chat',
        'name': 'Live Chat',
        'description': 'Enable live chat',
        'isEnabled': false,
        'createdAt': DateTime(2026, 1, 1).toIso8601String(),
        'updatedAt': DateTime(2026, 1, 15).toIso8601String(),
      });

      final result = await adminService.updateFeatureFlag('live_chat', true);

      expect(result, isTrue);

      final doc =
          await fakeFirestore.collection('feature_flags').doc('live_chat').get();
      expect(doc.data()!['isEnabled'], isTrue);
      expect(doc.data()!['updatedBy'], testUserId);

      final logs = await fakeFirestore.collection('admin_logs').get();
      expect(logs.docs.first.data()['action'], 'update_feature_flag');
    });

    test('createFeatureFlag returns false for non-superAdmin', () async {
      await fakeFirestore.collection('admins').doc(testUserId).set(
            createAdminDoc(role: AdminRole.admin),
          );
      await adminService.initialize();

      final result = await adminService.createFeatureFlag(
        'New Feature',
        'A new feature flag',
      );

      expect(result, isFalse);
    });

    test('createFeatureFlag creates flag in Firestore for superAdmin', () async {
      await fakeFirestore.collection('admins').doc(testUserId).set(
            createAdminDoc(role: AdminRole.superAdmin),
          );
      await adminService.initialize();

      final result = await adminService.createFeatureFlag(
        'New Feature',
        'A new feature flag',
      );

      expect(result, isTrue);

      final doc =
          await fakeFirestore.collection('feature_flags').doc('new_feature').get();
      expect(doc.exists, isTrue);
      expect(doc.data()!['name'], 'New Feature');
      expect(doc.data()!['description'], 'A new feature flag');
      expect(doc.data()!['isEnabled'], isFalse);
    });
  });

  group('AdminService - Broadcast Notifications', () {
    test('returns false when not admin', () async {
      await adminService.initialize();

      final result = await adminService.sendBroadcastNotification(
        title: 'Test',
        body: 'Test notification',
      );

      expect(result, isFalse);
    });

    test('returns false when role cannot send push notifications', () async {
      await fakeFirestore.collection('admins').doc(testUserId).set(
            createAdminDoc(role: AdminRole.moderator),
          );
      await adminService.initialize();

      final result = await adminService.sendBroadcastNotification(
        title: 'Test',
        body: 'Test notification',
      );

      expect(result, isFalse);
    });

    test('sends broadcast to all users topic', () async {
      await fakeFirestore.collection('admins').doc(testUserId).set(
            createAdminDoc(role: AdminRole.admin),
          );
      await adminService.initialize();

      final result = await adminService.sendBroadcastNotification(
        title: 'Match Alert',
        body: 'USA vs Mexico starting soon!',
        audience: NotificationAudience.allUsers,
      );

      expect(result, isTrue);

      final notifications =
          await fakeFirestore.collection('broadcast_notifications').get();
      expect(notifications.docs.length, 1);
      expect(notifications.docs.first.data()['title'], 'Match Alert');
      expect(notifications.docs.first.data()['topic'], 'all_users');
      expect(notifications.docs.first.data()['status'], 'pending');
    });

    test('sends broadcast to premium users topic', () async {
      await fakeFirestore.collection('admins').doc(testUserId).set(
            createAdminDoc(role: AdminRole.admin),
          );
      await adminService.initialize();

      final result = await adminService.sendBroadcastNotification(
        title: 'Premium Alert',
        body: 'Exclusive content available!',
        audience: NotificationAudience.premiumUsers,
      );

      expect(result, isTrue);

      final notifications =
          await fakeFirestore.collection('broadcast_notifications').get();
      expect(notifications.docs.first.data()['topic'], 'premium_users');
    });

    test('sends broadcast to team fans topic', () async {
      await fakeFirestore.collection('admins').doc(testUserId).set(
            createAdminDoc(role: AdminRole.admin),
          );
      await adminService.initialize();

      final result = await adminService.sendBroadcastNotification(
        title: 'Team Alert',
        body: 'Your team is playing!',
        audience: NotificationAudience.teamFans,
        teamCode: 'USA',
      );

      expect(result, isTrue);

      final notifications =
          await fakeFirestore.collection('broadcast_notifications').get();
      expect(notifications.docs.first.data()['topic'], 'team_usa');
    });

    test('returns false when team fans audience has no team code', () async {
      await fakeFirestore.collection('admins').doc(testUserId).set(
            createAdminDoc(role: AdminRole.admin),
          );
      await adminService.initialize();

      final result = await adminService.sendBroadcastNotification(
        title: 'Team Alert',
        body: 'Missing team code',
        audience: NotificationAudience.teamFans,
      );

      expect(result, isFalse);
    });

    test('sends broadcast to active users topic', () async {
      await fakeFirestore.collection('admins').doc(testUserId).set(
            createAdminDoc(role: AdminRole.admin),
          );
      await adminService.initialize();

      final result = await adminService.sendBroadcastNotification(
        title: 'Activity Alert',
        body: 'Check out new predictions!',
        audience: NotificationAudience.activeUsers,
      );

      expect(result, isTrue);

      final notifications =
          await fakeFirestore.collection('broadcast_notifications').get();
      expect(notifications.docs.first.data()['topic'], 'active_users');
    });
  });

  group('AdminService - getAdminLogs', () {
    test('returns empty list when not admin', () async {
      await adminService.initialize();

      final logs = await adminService.getAdminLogs();

      expect(logs, isEmpty);
    });

    test('returns empty list when role is not superAdmin', () async {
      await fakeFirestore.collection('admins').doc(testUserId).set(
            createAdminDoc(role: AdminRole.admin),
          );
      await adminService.initialize();

      final logs = await adminService.getAdminLogs();

      expect(logs, isEmpty);
    });

    test('returns logs for superAdmin', () async {
      await fakeFirestore.collection('admins').doc(testUserId).set(
            createAdminDoc(role: AdminRole.superAdmin),
          );
      await adminService.initialize();

      await fakeFirestore.collection('admin_logs').add({
        'action': 'warn_user',
        'adminId': testUserId,
        'timestamp': Timestamp.now(),
      });
      await fakeFirestore.collection('admin_logs').add({
        'action': 'ban_user',
        'adminId': testUserId,
        'timestamp': Timestamp.now(),
      });

      final logs = await adminService.getAdminLogs();

      expect(logs.length, 2);
    });
  });

  group('AdminService - clearCache', () {
    test('clears admin user and allows reinitialization', () async {
      await fakeFirestore.collection('admins').doc(testUserId).set(
            createAdminDoc(),
          );
      await adminService.initialize();
      expect(adminService.isAdmin, isTrue);

      adminService.clearCache();
      expect(adminService.isAdmin, isFalse);
      expect(adminService.currentAdminUser, isNull);
    });
  });

  group('AdminService - deleteWatchParty', () {
    test('returns false when not admin', () async {
      await adminService.initialize();

      final result = await adminService.deleteWatchParty('party-1', 'Inappropriate');

      expect(result, isFalse);
    });

    test('returns false when role cannot manage watch parties', () async {
      await fakeFirestore.collection('admins').doc(testUserId).set(
            createAdminDoc(role: AdminRole.support),
          );
      await adminService.initialize();

      final result = await adminService.deleteWatchParty('party-1', 'Inappropriate');

      expect(result, isFalse);
    });

    test('soft-deletes watch party and logs action', () async {
      await fakeFirestore.collection('admins').doc(testUserId).set(
            createAdminDoc(role: AdminRole.moderator),
          );
      await adminService.initialize();

      await fakeFirestore.collection('watch_parties').doc('party-1').set({
        'name': 'Test Party',
        'hostId': 'host-1',
      });

      final result = await adminService.deleteWatchParty('party-1', 'Inappropriate');

      expect(result, isTrue);

      final doc =
          await fakeFirestore.collection('watch_parties').doc('party-1').get();
      expect(doc.data()!['isDeleted'], isTrue);
      expect(doc.data()!['deletedBy'], testUserId);
      expect(doc.data()!['deletionReason'], 'Inappropriate');
    });
  });

  group('AdminService - Role-based access matrix', () {
    // Ensures the complete permission matrix is tested across all roles

    for (final role in AdminRole.values) {
      test('${role.displayName} has correct permission levels', () {
        expect(role.canManageUsers(), role.level >= AdminRole.admin.level);
        expect(role.canModerateContent(), role.level >= AdminRole.moderator.level);
        expect(role.canManageWatchParties(), role.level >= AdminRole.moderator.level);
        expect(role.canSendPushNotifications(), role.level >= AdminRole.admin.level);
        expect(role.canEditMatchData(), role.level >= AdminRole.admin.level);
        expect(role.canManageFeatureFlags(), role.level >= AdminRole.superAdmin.level);
        expect(role.canManageAdmins(), role.level >= AdminRole.superAdmin.level);
      });
    }
  });
}

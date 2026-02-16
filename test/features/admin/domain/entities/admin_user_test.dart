import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/admin/domain/entities/admin_user.dart';

void main() {
  group('AdminRole', () {
    group('displayName', () {
      test('superAdmin returns Super Admin', () {
        expect(AdminRole.superAdmin.displayName, 'Super Admin');
      });

      test('admin returns Admin', () {
        expect(AdminRole.admin.displayName, 'Admin');
      });

      test('moderator returns Moderator', () {
        expect(AdminRole.moderator.displayName, 'Moderator');
      });

      test('support returns Support', () {
        expect(AdminRole.support.displayName, 'Support');
      });
    });

    group('level', () {
      test('superAdmin has level 100', () {
        expect(AdminRole.superAdmin.level, 100);
      });

      test('admin has level 75', () {
        expect(AdminRole.admin.level, 75);
      });

      test('moderator has level 50', () {
        expect(AdminRole.moderator.level, 50);
      });

      test('support has level 25', () {
        expect(AdminRole.support.level, 25);
      });
    });

    group('permission checks', () {
      test('superAdmin can manage users', () {
        expect(AdminRole.superAdmin.canManageUsers(), isTrue);
      });

      test('admin can manage users', () {
        expect(AdminRole.admin.canManageUsers(), isTrue);
      });

      test('moderator cannot manage users', () {
        expect(AdminRole.moderator.canManageUsers(), isFalse);
      });

      test('support cannot manage users', () {
        expect(AdminRole.support.canManageUsers(), isFalse);
      });

      test('superAdmin can moderate content', () {
        expect(AdminRole.superAdmin.canModerateContent(), isTrue);
      });

      test('admin can moderate content', () {
        expect(AdminRole.admin.canModerateContent(), isTrue);
      });

      test('moderator can moderate content', () {
        expect(AdminRole.moderator.canModerateContent(), isTrue);
      });

      test('support cannot moderate content', () {
        expect(AdminRole.support.canModerateContent(), isFalse);
      });

      test('superAdmin can manage watch parties', () {
        expect(AdminRole.superAdmin.canManageWatchParties(), isTrue);
      });

      test('moderator can manage watch parties', () {
        expect(AdminRole.moderator.canManageWatchParties(), isTrue);
      });

      test('support cannot manage watch parties', () {
        expect(AdminRole.support.canManageWatchParties(), isFalse);
      });

      test('superAdmin can send push notifications', () {
        expect(AdminRole.superAdmin.canSendPushNotifications(), isTrue);
      });

      test('admin can send push notifications', () {
        expect(AdminRole.admin.canSendPushNotifications(), isTrue);
      });

      test('moderator cannot send push notifications', () {
        expect(AdminRole.moderator.canSendPushNotifications(), isFalse);
      });

      test('superAdmin can edit match data', () {
        expect(AdminRole.superAdmin.canEditMatchData(), isTrue);
      });

      test('admin can edit match data', () {
        expect(AdminRole.admin.canEditMatchData(), isTrue);
      });

      test('moderator cannot edit match data', () {
        expect(AdminRole.moderator.canEditMatchData(), isFalse);
      });

      test('only superAdmin can manage feature flags', () {
        expect(AdminRole.superAdmin.canManageFeatureFlags(), isTrue);
        expect(AdminRole.admin.canManageFeatureFlags(), isFalse);
        expect(AdminRole.moderator.canManageFeatureFlags(), isFalse);
        expect(AdminRole.support.canManageFeatureFlags(), isFalse);
      });

      test('only superAdmin can manage admins', () {
        expect(AdminRole.superAdmin.canManageAdmins(), isTrue);
        expect(AdminRole.admin.canManageAdmins(), isFalse);
        expect(AdminRole.moderator.canManageAdmins(), isFalse);
        expect(AdminRole.support.canManageAdmins(), isFalse);
      });
    });
  });

  group('AdminUser', () {
    final now = DateTime(2026, 1, 15, 10, 30);
    final lastLogin = DateTime(2026, 1, 14, 8, 0);

    AdminUser createAdminUser({
      String userId = 'admin-1',
      String email = 'admin@example.com',
      String displayName = 'Test Admin',
      AdminRole role = AdminRole.admin,
      DateTime? grantedAt,
      String? grantedBy,
      bool isActive = true,
      List<String> permissions = const [],
      DateTime? lastLoginAt,
    }) {
      return AdminUser(
        userId: userId,
        email: email,
        displayName: displayName,
        role: role,
        grantedAt: grantedAt ?? now,
        grantedBy: grantedBy,
        isActive: isActive,
        permissions: permissions,
        lastLoginAt: lastLoginAt,
      );
    }

    test('creates admin user with required fields', () {
      final admin = createAdminUser();
      expect(admin.userId, 'admin-1');
      expect(admin.email, 'admin@example.com');
      expect(admin.displayName, 'Test Admin');
      expect(admin.role, AdminRole.admin);
      expect(admin.grantedAt, now);
      expect(admin.isActive, isTrue);
      expect(admin.permissions, isEmpty);
    });

    test('creates admin user with all optional fields', () {
      final admin = createAdminUser(
        grantedBy: 'super-admin-1',
        isActive: false,
        permissions: ['manage_users', 'moderate_content'],
        lastLoginAt: lastLogin,
      );
      expect(admin.grantedBy, 'super-admin-1');
      expect(admin.isActive, isFalse);
      expect(admin.permissions, ['manage_users', 'moderate_content']);
      expect(admin.lastLoginAt, lastLogin);
    });

    group('fromJson', () {
      test('parses all fields correctly', () {
        final json = {
          'userId': 'admin-1',
          'email': 'admin@example.com',
          'displayName': 'Test Admin',
          'role': 'admin',
          'grantedAt': '2026-01-15T10:30:00.000',
          'grantedBy': 'super-admin-1',
          'isActive': true,
          'permissions': ['manage_users'],
          'lastLoginAt': '2026-01-14T08:00:00.000',
        };

        final admin = AdminUser.fromJson(json);
        expect(admin.userId, 'admin-1');
        expect(admin.email, 'admin@example.com');
        expect(admin.displayName, 'Test Admin');
        expect(admin.role, AdminRole.admin);
        expect(admin.grantedBy, 'super-admin-1');
        expect(admin.isActive, isTrue);
        expect(admin.permissions, ['manage_users']);
        expect(admin.lastLoginAt, isNotNull);
      });

      test('uses defaults for missing optional fields', () {
        final json = {
          'userId': 'admin-1',
          'role': 'moderator',
        };

        final admin = AdminUser.fromJson(json);
        expect(admin.email, '');
        expect(admin.displayName, 'Unknown');
        expect(admin.role, AdminRole.moderator);
        expect(admin.isActive, isTrue);
        expect(admin.permissions, isEmpty);
        expect(admin.lastLoginAt, isNull);
      });

      test('falls back to support role for unknown role', () {
        final json = {
          'userId': 'admin-1',
          'role': 'unknown_role',
        };

        final admin = AdminUser.fromJson(json);
        expect(admin.role, AdminRole.support);
      });
    });

    group('toJson', () {
      test('serializes all fields correctly', () {
        final admin = createAdminUser(
          grantedBy: 'super-admin-1',
          permissions: ['manage_users'],
          lastLoginAt: lastLogin,
        );

        final json = admin.toJson();
        expect(json['userId'], 'admin-1');
        expect(json['email'], 'admin@example.com');
        expect(json['displayName'], 'Test Admin');
        expect(json['role'], 'admin');
        expect(json['grantedBy'], 'super-admin-1');
        expect(json['isActive'], isTrue);
        expect(json['permissions'], ['manage_users']);
        expect(json['lastLoginAt'], isNotNull);
      });

      test('serializes null optional fields', () {
        final admin = createAdminUser();
        final json = admin.toJson();
        expect(json['grantedBy'], isNull);
        expect(json['lastLoginAt'], isNull);
      });
    });

    group('hasPermission', () {
      test('returns true when user has specific permission', () {
        final admin = createAdminUser(permissions: ['manage_users', 'moderate']);
        expect(admin.hasPermission('manage_users'), isTrue);
        expect(admin.hasPermission('moderate'), isTrue);
      });

      test('returns false when user lacks permission', () {
        final admin = createAdminUser(permissions: ['manage_users']);
        expect(admin.hasPermission('moderate'), isFalse);
      });

      test('returns true for wildcard permission', () {
        final admin = createAdminUser(permissions: ['*']);
        expect(admin.hasPermission('anything'), isTrue);
        expect(admin.hasPermission('manage_users'), isTrue);
      });

      test('returns false for empty permissions', () {
        final admin = createAdminUser(permissions: []);
        expect(admin.hasPermission('manage_users'), isFalse);
      });
    });

    group('equality', () {
      test('two users with same props are equal', () {
        final admin1 = createAdminUser();
        final admin2 = createAdminUser();
        expect(admin1, equals(admin2));
      });

      test('two users with different userId are not equal', () {
        final admin1 = createAdminUser(userId: 'admin-1');
        final admin2 = createAdminUser(userId: 'admin-2');
        expect(admin1, isNot(equals(admin2)));
      });

      test('two users with different roles are not equal', () {
        final admin1 = createAdminUser(role: AdminRole.admin);
        final admin2 = createAdminUser(role: AdminRole.moderator);
        expect(admin1, isNot(equals(admin2)));
      });
    });

    group('JSON round-trip', () {
      test('fromJson(toJson()) preserves data', () {
        final original = createAdminUser(
          grantedBy: 'super-admin-1',
          permissions: ['manage_users', 'moderate'],
          lastLoginAt: lastLogin,
        );

        final json = original.toJson();
        final restored = AdminUser.fromJson(json);

        expect(restored.userId, original.userId);
        expect(restored.email, original.email);
        expect(restored.displayName, original.displayName);
        expect(restored.role, original.role);
        expect(restored.grantedBy, original.grantedBy);
        expect(restored.isActive, original.isActive);
        expect(restored.permissions, original.permissions);
      });
    });
  });

  group('FeatureFlag', () {
    final createdAt = DateTime(2026, 1, 10);
    final updatedAt = DateTime(2026, 1, 15);

    FeatureFlag createFlag({
      String id = 'live_chat',
      String name = 'Live Chat',
      String description = 'Enable live chat feature',
      bool isEnabled = false,
      String? enabledForGroups,
      DateTime? createdAtOverride,
      DateTime? updatedAtOverride,
      String? updatedBy,
    }) {
      return FeatureFlag(
        id: id,
        name: name,
        description: description,
        isEnabled: isEnabled,
        enabledForGroups: enabledForGroups,
        createdAt: createdAtOverride ?? createdAt,
        updatedAt: updatedAtOverride ?? updatedAt,
        updatedBy: updatedBy,
      );
    }

    test('creates feature flag with required fields', () {
      final flag = createFlag();
      expect(flag.id, 'live_chat');
      expect(flag.name, 'Live Chat');
      expect(flag.description, 'Enable live chat feature');
      expect(flag.isEnabled, isFalse);
      expect(flag.enabledForGroups, isNull);
    });

    group('fromJson', () {
      test('parses all fields correctly', () {
        final json = {
          'id': 'live_chat',
          'name': 'Live Chat',
          'description': 'Enable live chat feature',
          'isEnabled': true,
          'enabledForGroups': 'beta',
          'createdAt': '2026-01-10T00:00:00.000',
          'updatedAt': '2026-01-15T00:00:00.000',
          'updatedBy': 'admin-1',
        };

        final flag = FeatureFlag.fromJson(json);
        expect(flag.id, 'live_chat');
        expect(flag.name, 'Live Chat');
        expect(flag.description, 'Enable live chat feature');
        expect(flag.isEnabled, isTrue);
        expect(flag.enabledForGroups, 'beta');
        expect(flag.updatedBy, 'admin-1');
      });

      test('uses defaults for missing optional fields', () {
        final json = {
          'id': 'test_flag',
          'name': 'Test',
        };

        final flag = FeatureFlag.fromJson(json);
        expect(flag.description, '');
        expect(flag.isEnabled, isFalse);
        expect(flag.enabledForGroups, isNull);
        expect(flag.updatedBy, isNull);
      });
    });

    group('toJson', () {
      test('serializes all fields correctly', () {
        final flag = createFlag(
          isEnabled: true,
          enabledForGroups: 'all',
          updatedBy: 'admin-1',
        );

        final json = flag.toJson();
        expect(json['id'], 'live_chat');
        expect(json['name'], 'Live Chat');
        expect(json['description'], 'Enable live chat feature');
        expect(json['isEnabled'], isTrue);
        expect(json['enabledForGroups'], 'all');
        expect(json['updatedBy'], 'admin-1');
      });
    });

    group('copyWith', () {
      test('copies with updated isEnabled', () {
        final flag = createFlag(isEnabled: false);
        final updated = flag.copyWith(isEnabled: true);

        expect(updated.isEnabled, isTrue);
        expect(updated.id, flag.id);
        expect(updated.name, flag.name);
        expect(updated.description, flag.description);
      });

      test('copies with updated enabledForGroups', () {
        final flag = createFlag();
        final updated = flag.copyWith(enabledForGroups: 'beta');

        expect(updated.enabledForGroups, 'beta');
      });

      test('copies with updated updatedBy', () {
        final flag = createFlag();
        final updated = flag.copyWith(updatedBy: 'admin-2');

        expect(updated.updatedBy, 'admin-2');
      });

      test('preserves original values when not specified', () {
        final flag = createFlag(
          isEnabled: true,
          enabledForGroups: 'all',
          updatedBy: 'admin-1',
        );
        final updated = flag.copyWith();

        expect(updated.isEnabled, flag.isEnabled);
        expect(updated.enabledForGroups, flag.enabledForGroups);
        expect(updated.updatedBy, flag.updatedBy);
      });
    });

    group('equality', () {
      test('two flags with same id, name, isEnabled are equal', () {
        final flag1 = createFlag();
        final flag2 = createFlag();
        expect(flag1, equals(flag2));
      });

      test('two flags with different id are not equal', () {
        final flag1 = createFlag(id: 'flag_1');
        final flag2 = createFlag(id: 'flag_2');
        expect(flag1, isNot(equals(flag2)));
      });
    });
  });

  group('AdminDashboardStats', () {
    test('creates stats with all fields', () {
      final now = DateTime(2026, 1, 15);
      final stats = AdminDashboardStats(
        totalUsers: 1000,
        activeUsers24h: 250,
        newUsersToday: 50,
        totalWatchParties: 100,
        activeWatchParties: 25,
        pendingReports: 5,
        totalPredictions: 5000,
        totalMessages: 10000,
        updatedAt: now,
      );

      expect(stats.totalUsers, 1000);
      expect(stats.activeUsers24h, 250);
      expect(stats.newUsersToday, 50);
      expect(stats.totalWatchParties, 100);
      expect(stats.activeWatchParties, 25);
      expect(stats.pendingReports, 5);
      expect(stats.totalPredictions, 5000);
      expect(stats.totalMessages, 10000);
      expect(stats.updatedAt, now);
    });

    test('empty factory creates stats with all zeros', () {
      final stats = AdminDashboardStats.empty();
      expect(stats.totalUsers, 0);
      expect(stats.activeUsers24h, 0);
      expect(stats.newUsersToday, 0);
      expect(stats.totalWatchParties, 0);
      expect(stats.activeWatchParties, 0);
      expect(stats.pendingReports, 0);
      expect(stats.totalPredictions, 0);
      expect(stats.totalMessages, 0);
    });

    group('fromJson', () {
      test('parses all fields correctly', () {
        final json = {
          'totalUsers': 500,
          'activeUsers24h': 100,
          'newUsersToday': 20,
          'totalWatchParties': 50,
          'activeWatchParties': 10,
          'pendingReports': 3,
          'totalPredictions': 2000,
          'totalMessages': 5000,
          'updatedAt': '2026-01-15T10:30:00.000',
        };

        final stats = AdminDashboardStats.fromJson(json);
        expect(stats.totalUsers, 500);
        expect(stats.activeUsers24h, 100);
        expect(stats.newUsersToday, 20);
        expect(stats.totalWatchParties, 50);
        expect(stats.activeWatchParties, 10);
        expect(stats.pendingReports, 3);
        expect(stats.totalPredictions, 2000);
        expect(stats.totalMessages, 5000);
      });

      test('uses defaults for missing fields', () {
        final json = <String, dynamic>{};
        final stats = AdminDashboardStats.fromJson(json);
        expect(stats.totalUsers, 0);
        expect(stats.activeUsers24h, 0);
        expect(stats.pendingReports, 0);
      });
    });
  });

  group('NotificationAudience', () {
    test('has all expected values', () {
      expect(NotificationAudience.values, hasLength(4));
      expect(NotificationAudience.values, contains(NotificationAudience.allUsers));
      expect(NotificationAudience.values, contains(NotificationAudience.premiumUsers));
      expect(NotificationAudience.values, contains(NotificationAudience.teamFans));
      expect(NotificationAudience.values, contains(NotificationAudience.activeUsers));
    });
  });
}

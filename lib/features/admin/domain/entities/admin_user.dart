import 'package:equatable/equatable.dart';

/// Admin role levels
enum AdminRole {
  superAdmin, // Full access to everything
  admin, // User management, moderation, content
  moderator, // Content moderation only
  support, // Read-only access, can respond to users
}

extension AdminRoleExtension on AdminRole {
  String get displayName {
    switch (this) {
      case AdminRole.superAdmin:
        return 'Super Admin';
      case AdminRole.admin:
        return 'Admin';
      case AdminRole.moderator:
        return 'Moderator';
      case AdminRole.support:
        return 'Support';
    }
  }

  int get level {
    switch (this) {
      case AdminRole.superAdmin:
        return 100;
      case AdminRole.admin:
        return 75;
      case AdminRole.moderator:
        return 50;
      case AdminRole.support:
        return 25;
    }
  }

  bool canManageUsers() => level >= AdminRole.admin.level;
  bool canModerateContent() => level >= AdminRole.moderator.level;
  bool canManageWatchParties() => level >= AdminRole.moderator.level;
  bool canSendPushNotifications() => level >= AdminRole.admin.level;
  bool canEditMatchData() => level >= AdminRole.admin.level;
  bool canManageFeatureFlags() => level >= AdminRole.superAdmin.level;
  bool canManageAdmins() => level >= AdminRole.superAdmin.level;
}

/// Admin user entity
class AdminUser extends Equatable {
  final String userId;
  final String email;
  final String displayName;
  final AdminRole role;
  final DateTime grantedAt;
  final String? grantedBy;
  final bool isActive;
  final List<String> permissions;
  final DateTime? lastLoginAt;

  const AdminUser({
    required this.userId,
    required this.email,
    required this.displayName,
    required this.role,
    required this.grantedAt,
    this.grantedBy,
    this.isActive = true,
    this.permissions = const [],
    this.lastLoginAt,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      userId: json['userId'] as String,
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? 'Unknown',
      role: AdminRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => AdminRole.support,
      ),
      grantedAt: json['grantedAt'] != null
          ? DateTime.parse(json['grantedAt'] as String)
          : DateTime.now(),
      grantedBy: json['grantedBy'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      permissions: List<String>.from(json['permissions'] ?? []),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'email': email,
        'displayName': displayName,
        'role': role.name,
        'grantedAt': grantedAt.toIso8601String(),
        'grantedBy': grantedBy,
        'isActive': isActive,
        'permissions': permissions,
        'lastLoginAt': lastLoginAt?.toIso8601String(),
      };

  bool hasPermission(String permission) {
    return permissions.contains(permission) || permissions.contains('*');
  }

  @override
  List<Object?> get props => [userId, email, role, isActive];
}

/// Feature flag entity
class FeatureFlag extends Equatable {
  final String id;
  final String name;
  final String description;
  final bool isEnabled;
  final String? enabledForGroups; // 'all', 'beta', 'internal', 'percentage:10'
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? updatedBy;

  const FeatureFlag({
    required this.id,
    required this.name,
    required this.description,
    required this.isEnabled,
    this.enabledForGroups,
    required this.createdAt,
    required this.updatedAt,
    this.updatedBy,
  });

  factory FeatureFlag.fromJson(Map<String, dynamic> json) {
    return FeatureFlag(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      isEnabled: json['isEnabled'] as bool? ?? false,
      enabledForGroups: json['enabledForGroups'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      updatedBy: json['updatedBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'isEnabled': isEnabled,
        'enabledForGroups': enabledForGroups,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'updatedBy': updatedBy,
      };

  FeatureFlag copyWith({
    bool? isEnabled,
    String? enabledForGroups,
    String? updatedBy,
  }) {
    return FeatureFlag(
      id: id,
      name: name,
      description: description,
      isEnabled: isEnabled ?? this.isEnabled,
      enabledForGroups: enabledForGroups ?? this.enabledForGroups,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  @override
  List<Object?> get props => [id, name, isEnabled];
}

/// Dashboard statistics
class AdminDashboardStats {
  final int totalUsers;
  final int activeUsers24h;
  final int newUsersToday;
  final int totalWatchParties;
  final int activeWatchParties;
  final int pendingReports;
  final int totalPredictions;
  final int totalMessages;
  final DateTime updatedAt;

  const AdminDashboardStats({
    required this.totalUsers,
    required this.activeUsers24h,
    required this.newUsersToday,
    required this.totalWatchParties,
    required this.activeWatchParties,
    required this.pendingReports,
    required this.totalPredictions,
    required this.totalMessages,
    required this.updatedAt,
  });

  factory AdminDashboardStats.empty() {
    return AdminDashboardStats(
      totalUsers: 0,
      activeUsers24h: 0,
      newUsersToday: 0,
      totalWatchParties: 0,
      activeWatchParties: 0,
      pendingReports: 0,
      totalPredictions: 0,
      totalMessages: 0,
      updatedAt: DateTime.now(),
    );
  }

  factory AdminDashboardStats.fromJson(Map<String, dynamic> json) {
    return AdminDashboardStats(
      totalUsers: json['totalUsers'] as int? ?? 0,
      activeUsers24h: json['activeUsers24h'] as int? ?? 0,
      newUsersToday: json['newUsersToday'] as int? ?? 0,
      totalWatchParties: json['totalWatchParties'] as int? ?? 0,
      activeWatchParties: json['activeWatchParties'] as int? ?? 0,
      pendingReports: json['pendingReports'] as int? ?? 0,
      totalPredictions: json['totalPredictions'] as int? ?? 0,
      totalMessages: json['totalMessages'] as int? ?? 0,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }
}

/// Audience targets for broadcast notifications
enum NotificationAudience {
  allUsers,
  premiumUsers,
  teamFans,
  activeUsers,
}

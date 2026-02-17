import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

import '../../domain/entities/admin_user.dart';
import '../../domain/services/admin_service.dart';
import 'admin_users_screen.dart';
import 'admin_moderation_screen.dart';
import 'admin_watch_parties_screen.dart';
import 'admin_feature_flags_screen.dart';
import 'admin_notifications_screen.dart';

/// Main admin dashboard screen
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminService _adminService = AdminService();
  AdminDashboardStats _stats = AdminDashboardStats.empty();
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeAdmin();
  }

  Future<void> _initializeAdmin() async {
    await _adminService.initialize();

    if (!_adminService.isAdmin) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).noAdminAccess),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    await _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final stats = await _adminService.getDashboardStats();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final adminUser = _adminService.currentAdminUser;

    if (!_adminService.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context).admin)),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminDashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
            tooltip: l10n.refresh,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Admin info
            _buildAdminInfoCard(theme, adminUser),
            const SizedBox(height: 16),

            // Stats
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              _buildErrorCard(theme)
            else
              _buildStatsGrid(theme),

            const SizedBox(height: 24),

            // Quick actions
            _buildQuickActionsSection(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminInfoCard(ThemeData theme, AdminUser? adminUser) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.primary,
              child: Icon(
                Icons.admin_panel_settings,
                color: theme.colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    adminUser?.displayName ?? 'Admin',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getRoleColor(adminUser?.role),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      adminUser?.role.displayName ?? 'Unknown',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(AdminRole? role) {
    switch (role) {
      case AdminRole.superAdmin:
        return Colors.purple;
      case AdminRole.admin:
        return Colors.blue;
      case AdminRole.moderator:
        return Colors.orange;
      case AdminRole.support:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildErrorCard(ThemeData theme) {
    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).failedToLoadStats,
              style: TextStyle(color: theme.colorScheme.error),
            ),
            TextButton(
              onPressed: _loadStats,
              child: Text(AppLocalizations.of(context).retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).overview,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              theme,
              AppLocalizations.of(context).totalUsers,
              _stats.totalUsers.toString(),
              Icons.people,
              Colors.blue,
            ),
            _buildStatCard(
              theme,
              AppLocalizations.of(context).activeUsers24h,
              _stats.activeUsers24h.toString(),
              Icons.person,
              Colors.green,
            ),
            _buildStatCard(
              theme,
              AppLocalizations.of(context).newToday,
              _stats.newUsersToday.toString(),
              Icons.person_add,
              Colors.teal,
            ),
            _buildStatCard(
              theme,
              AppLocalizations.of(context).watchParties,
              _stats.totalWatchParties.toString(),
              Icons.groups,
              Colors.orange,
            ),
            _buildStatCard(
              theme,
              AppLocalizations.of(context).activeParties,
              _stats.activeWatchParties.toString(),
              Icons.celebration,
              Colors.purple,
            ),
            _buildStatCard(
              theme,
              AppLocalizations.of(context).pendingReports,
              _stats.pendingReports.toString(),
              Icons.flag,
              _stats.pendingReports > 0 ? Colors.red : Colors.grey,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(ThemeData theme) {
    final role = _adminService.currentRole;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).quickActions,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // User Management
        if (role?.canManageUsers() ?? false)
          _buildActionTile(
            theme,
            AppLocalizations.of(context).userManagement,
            AppLocalizations.of(context).userManagementDesc,
            Icons.people_outline,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminUsersScreen()),
            ),
          ),

        // Content Moderation
        if (role?.canModerateContent() ?? false)
          _buildActionTile(
            theme,
            AppLocalizations.of(context).contentModeration,
            '${_stats.pendingReports} ${AppLocalizations.of(context).pendingReports.toLowerCase()}',
            Icons.flag_outlined,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminModerationScreen()),
            ),
            badge: _stats.pendingReports > 0 ? _stats.pendingReports.toString() : null,
          ),

        // Watch Party Management
        if (role?.canManageWatchParties() ?? false)
          _buildActionTile(
            theme,
            AppLocalizations.of(context).watchParties,
            AppLocalizations.of(context).manageWatchPartyListings,
            Icons.groups_outlined,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminWatchPartiesScreen()),
            ),
          ),

        // Feature Flags
        if (role?.canManageFeatureFlags() ?? false)
          _buildActionTile(
            theme,
            AppLocalizations.of(context).featureFlags,
            AppLocalizations.of(context).toggleAppFeatures,
            Icons.toggle_on_outlined,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminFeatureFlagsScreen()),
            ),
          ),

        // Push Notifications
        if (role?.canSendPushNotifications() ?? false)
          _buildActionTile(
            theme,
            AppLocalizations.of(context).pushNotifications,
            AppLocalizations.of(context).sendBroadcastNotifications,
            Icons.notifications_outlined,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminNotificationsScreen()),
            ),
          ),
      ],
    );
  }

  Widget _buildActionTile(
    ThemeData theme,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    String? badge,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

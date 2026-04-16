import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';

import '../../../social/domain/entities/user_profile.dart';
import '../../domain/services/admin_service.dart';

/// Admin screen for user management
class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final AdminService _adminService = sl<AdminService>();
  final TextEditingController _searchController = TextEditingController();

  List<UserProfile> _users = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);

    try {
      final users = await _adminService.searchUsers(
        query: _searchController.text.isNotEmpty ? _searchController.text : null,
      );

      if (!mounted) return;
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load users: $e')),
      );
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.length < 2 && query.isNotEmpty) return;

    setState(() => _isLoading = true);

    try {
      final users = await _adminService.searchUsers(
        query: query.isNotEmpty ? query : null,
      );

      if (!mounted) return;
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to search users: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminUserManagement),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.adminSearchUsersHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadUsers();
                        },
                      )
                    : null,
              ),
              onSubmitted: _searchUsers,
              onChanged: (value) {
                if (value.isEmpty) _loadUsers();
              },
            ),
          ),

          // User list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryOrange)))
                : _users.isEmpty
                    ? Center(
                        child: Text(
                          l10n.adminNoUsersFound,
                          style: theme.textTheme.bodyLarge,
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadUsers,
                        child: ListView.builder(
                          itemCount: _users.length,
                          itemBuilder: (context, index) {
                            final user = _users[index];
                            return _buildUserTile(theme, l10n, user);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile(ThemeData theme, AppLocalizations l10n, UserProfile user) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundImage: user.profileImageUrl != null
              ? NetworkImage(user.profileImageUrl!)
              : null,
          child: user.profileImageUrl == null
              ? Text(user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?')
              : null,
        ),
        title: Text(user.displayName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user.email != null) Text(user.email!),
            Row(
              children: [
                Icon(
                  user.isOnline ? Icons.circle : Icons.circle_outlined,
                  size: 10,
                  color: user.isOnline ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  user.isOnline ? l10n.adminOnline : user.lastSeenText,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(l10n.adminUserId, user.userId),
                _buildInfoRow(l10n.adminLevel, l10n.adminLevelValue(user.level, user.levelTitle)),
                _buildInfoRow(l10n.adminJoined, _formatDate(user.createdAt)),
                _buildInfoRow(l10n.adminFriends, user.socialStats.friendsCount.toString()),
                if (user.favoriteTeams.isNotEmpty)
                  _buildInfoRow(l10n.adminTeams, user.favoriteTeams.join(', ')),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      l10n.adminWarn,
                      Icons.warning_amber,
                      Colors.orange,
                      () => _showWarningDialog(user),
                    ),
                    _buildActionButton(
                      l10n.adminMute,
                      Icons.volume_off,
                      Colors.blue,
                      () => _showMuteDialog(user),
                    ),
                    _buildActionButton(
                      l10n.adminSuspend,
                      Icons.block,
                      Colors.red,
                      () => _showSuspendDialog(user),
                    ),
                    _buildActionButton(
                      l10n.adminBan,
                      Icons.gavel,
                      Colors.purple,
                      () => _showBanDialog(user),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: color, size: 18),
      label: Text(label, style: TextStyle(color: color)),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showWarningDialog(UserProfile user) {
    final reasonController = TextEditingController();
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backgroundCard,
        title: Text(l10n.adminWarnUser(user.displayName)),
        content: TextField(
          controller: reasonController,
          decoration: InputDecoration(
            labelText: l10n.adminReason,
            hintText: l10n.adminEnterWarningReason,
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.isEmpty) return;
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              final success = await _adminService.warnUser(
                user.userId,
                reasonController.text,
              );
              if (mounted) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(success ? l10n.adminWarningSent : l10n.adminWarningFailed),
                  ),
                );
              }
            },
            child: Text(l10n.adminSendWarning),
          ),
        ],
      ),
    );
  }

  void _showMuteDialog(UserProfile user) {
    final reasonController = TextEditingController();
    final l10n = AppLocalizations.of(context);
    Duration selectedDuration = const Duration(hours: 24);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.backgroundCard,
          title: Text(l10n.adminMuteUser(user.displayName)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  labelText: l10n.adminReason,
                  hintText: l10n.adminEnterMuteReason,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Duration>(
                value: selectedDuration,
                decoration: InputDecoration(labelText: l10n.adminDuration),
                items: [
                  DropdownMenuItem(value: const Duration(hours: 1), child: Text(l10n.adminDuration1Hour)),
                  DropdownMenuItem(value: const Duration(hours: 24), child: Text(l10n.adminDuration24Hours)),
                  DropdownMenuItem(value: const Duration(days: 7), child: Text(l10n.adminDuration7Days)),
                  DropdownMenuItem(value: const Duration(days: 30), child: Text(l10n.adminDuration30Days)),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() => selectedDuration = value);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                if (reasonController.text.isEmpty) return;
                final messenger = ScaffoldMessenger.of(context);
                Navigator.pop(context);
                final success = await _adminService.muteUser(
                  user.userId,
                  reasonController.text,
                  selectedDuration,
                );
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(success ? l10n.adminUserMuted : l10n.adminMuteFailed),
                    ),
                  );
                }
              },
              child: Text(l10n.adminMuteUserButton),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuspendDialog(UserProfile user) {
    final reasonController = TextEditingController();
    final l10n = AppLocalizations.of(context);
    Duration selectedDuration = const Duration(days: 7);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.backgroundCard,
          title: Text(l10n.adminSuspendUser(user.displayName)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  labelText: l10n.adminReason,
                  hintText: l10n.adminEnterSuspensionReason,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Duration>(
                value: selectedDuration,
                decoration: InputDecoration(labelText: l10n.adminDuration),
                items: [
                  DropdownMenuItem(value: const Duration(days: 1), child: Text(l10n.adminDuration1Day)),
                  DropdownMenuItem(value: const Duration(days: 7), child: Text(l10n.adminDuration7Days)),
                  DropdownMenuItem(value: const Duration(days: 30), child: Text(l10n.adminDuration30Days)),
                  DropdownMenuItem(value: const Duration(days: 90), child: Text(l10n.adminDuration90Days)),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() => selectedDuration = value);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                if (reasonController.text.isEmpty) return;
                final messenger = ScaffoldMessenger.of(context);
                Navigator.pop(context);
                final success = await _adminService.suspendUser(
                  user.userId,
                  reasonController.text,
                  selectedDuration,
                );
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(success ? l10n.adminUserSuspended : l10n.adminSuspendFailed),
                    ),
                  );
                }
              },
              child: Text(l10n.adminSuspendUserButton),
            ),
          ],
        ),
      ),
    );
  }

  void _showBanDialog(UserProfile user) {
    final reasonController = TextEditingController();
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backgroundCard,
        title: Text(l10n.adminBanUser(user.displayName)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.adminBanPermanentWarning,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: l10n.adminReason,
                hintText: l10n.adminEnterBanReason,
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            onPressed: () async {
              if (reasonController.text.isEmpty) return;
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              final success = await _adminService.banUser(
                user.userId,
                reasonController.text,
              );
              if (mounted) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(success ? l10n.adminUserBanned : l10n.adminBanFailed),
                  ),
                );
              }
            },
            child: Text(l10n.adminPermanentlyBan),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../social/domain/entities/user_profile.dart';
import '../../domain/services/admin_service.dart';

/// Admin screen for user management
class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final AdminService _adminService = AdminService();
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

    final users = await _adminService.searchUsers(
      query: _searchController.text.isNotEmpty ? _searchController.text : null,
    );

    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  Future<void> _searchUsers(String query) async {
    if (query.length < 2 && query.isNotEmpty) return;

    setState(() => _isLoading = true);

    final users = await _adminService.searchUsers(
      query: query.isNotEmpty ? query : null,
    );

    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users by name...',
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
                ? const Center(child: CircularProgressIndicator())
                : _users.isEmpty
                    ? Center(
                        child: Text(
                          'No users found',
                          style: theme.textTheme.bodyLarge,
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadUsers,
                        child: ListView.builder(
                          itemCount: _users.length,
                          itemBuilder: (context, index) {
                            final user = _users[index];
                            return _buildUserTile(theme, user);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile(ThemeData theme, UserProfile user) {
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
                  user.isOnline ? 'Online' : user.lastSeenText,
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
                _buildInfoRow('User ID', user.userId),
                _buildInfoRow('Level', '${user.level} (${user.levelTitle})'),
                _buildInfoRow('Joined', _formatDate(user.createdAt)),
                _buildInfoRow('Friends', user.socialStats.friendsCount.toString()),
                if (user.favoriteTeams.isNotEmpty)
                  _buildInfoRow('Teams', user.favoriteTeams.join(', ')),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      'Warn',
                      Icons.warning_amber,
                      Colors.orange,
                      () => _showWarningDialog(user),
                    ),
                    _buildActionButton(
                      'Mute',
                      Icons.volume_off,
                      Colors.blue,
                      () => _showMuteDialog(user),
                    ),
                    _buildActionButton(
                      'Suspend',
                      Icons.block,
                      Colors.red,
                      () => _showSuspendDialog(user),
                    ),
                    _buildActionButton(
                      'Ban',
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Warn ${user.displayName}'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Reason',
            hintText: 'Enter warning reason...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
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
                    content: Text(success ? 'Warning sent' : 'Failed to send warning'),
                  ),
                );
              }
            },
            child: const Text('Send Warning'),
          ),
        ],
      ),
    );
  }

  void _showMuteDialog(UserProfile user) {
    final reasonController = TextEditingController();
    Duration selectedDuration = const Duration(hours: 24);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Mute ${user.displayName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  hintText: 'Enter mute reason...',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Duration>(
                value: selectedDuration,
                decoration: const InputDecoration(labelText: 'Duration'),
                items: const [
                  DropdownMenuItem(value: Duration(hours: 1), child: Text('1 hour')),
                  DropdownMenuItem(value: Duration(hours: 24), child: Text('24 hours')),
                  DropdownMenuItem(value: Duration(days: 7), child: Text('7 days')),
                  DropdownMenuItem(value: Duration(days: 30), child: Text('30 days')),
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
              child: const Text('Cancel'),
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
                      content: Text(success ? 'User muted' : 'Failed to mute user'),
                    ),
                  );
                }
              },
              child: const Text('Mute User'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuspendDialog(UserProfile user) {
    final reasonController = TextEditingController();
    Duration selectedDuration = const Duration(days: 7);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Suspend ${user.displayName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  hintText: 'Enter suspension reason...',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Duration>(
                value: selectedDuration,
                decoration: const InputDecoration(labelText: 'Duration'),
                items: const [
                  DropdownMenuItem(value: Duration(days: 1), child: Text('1 day')),
                  DropdownMenuItem(value: Duration(days: 7), child: Text('7 days')),
                  DropdownMenuItem(value: Duration(days: 30), child: Text('30 days')),
                  DropdownMenuItem(value: Duration(days: 90), child: Text('90 days')),
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
              child: const Text('Cancel'),
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
                      content: Text(success ? 'User suspended' : 'Failed to suspend user'),
                    ),
                  );
                }
              },
              child: const Text('Suspend User'),
            ),
          ],
        ),
      ),
    );
  }

  void _showBanDialog(UserProfile user) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ban ${user.displayName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'This action is permanent and cannot be undone.',
              style: TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason',
                hintText: 'Enter ban reason...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
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
                    content: Text(success ? 'User banned' : 'Failed to ban user'),
                  ),
                );
              }
            },
            child: const Text('Permanently Ban'),
          ),
        ],
      ),
    );
  }
}

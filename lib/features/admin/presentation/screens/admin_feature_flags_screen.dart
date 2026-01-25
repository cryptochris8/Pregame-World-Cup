import 'package:flutter/material.dart';

import '../../domain/entities/admin_user.dart';
import '../../domain/services/admin_service.dart';

/// Admin screen for feature flag management
class AdminFeatureFlagsScreen extends StatefulWidget {
  const AdminFeatureFlagsScreen({super.key});

  @override
  State<AdminFeatureFlagsScreen> createState() => _AdminFeatureFlagsScreenState();
}

class _AdminFeatureFlagsScreenState extends State<AdminFeatureFlagsScreen> {
  final AdminService _adminService = AdminService();

  List<FeatureFlag> _flags = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFlags();
  }

  Future<void> _loadFlags() async {
    setState(() => _isLoading = true);

    final flags = await _adminService.getFeatureFlags();

    setState(() {
      _flags = flags;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feature Flags'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateFlagDialog,
            tooltip: 'Add Flag',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFlags,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _flags.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.toggle_off_outlined,
                        size: 64,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No feature flags',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _showCreateFlagDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Create Flag'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadFlags,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _flags.length,
                    itemBuilder: (context, index) {
                      final flag = _flags[index];
                      return _buildFlagCard(theme, flag);
                    },
                  ),
                ),
    );
  }

  Widget _buildFlagCard(ThemeData theme, FeatureFlag flag) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        flag.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        flag.id,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: flag.isEnabled,
                  onChanged: (value) => _toggleFlag(flag, value),
                  activeColor: Colors.green,
                ),
              ],
            ),
            if (flag.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                flag.description,
                style: theme.textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  flag.isEnabled ? Icons.check_circle : Icons.cancel,
                  size: 16,
                  color: flag.isEnabled ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  flag.isEnabled ? 'Enabled' : 'Disabled',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: flag.isEnabled ? Colors.green : Colors.grey,
                  ),
                ),
                const Spacer(),
                if (flag.updatedBy != null)
                  Text(
                    'Updated: ${_formatDate(flag.updatedAt)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _toggleFlag(FeatureFlag flag, bool value) async {
    // Optimistic update
    setState(() {
      final index = _flags.indexWhere((f) => f.id == flag.id);
      if (index != -1) {
        _flags[index] = flag.copyWith(isEnabled: value);
      }
    });

    final success = await _adminService.updateFeatureFlag(flag.id, value);

    if (!success && mounted) {
      // Revert on failure
      setState(() {
        final index = _flags.indexWhere((f) => f.id == flag.id);
        if (index != -1) {
          _flags[index] = flag.copyWith(isEnabled: !value);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update flag')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${flag.name} ${value ? "enabled" : "disabled"}'),
        ),
      );
    }
  }

  void _showCreateFlagDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Feature Flag'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g., Live Chat Feature',
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'What does this flag control?',
              ),
              maxLines: 2,
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
              if (nameController.text.isEmpty) return;
              Navigator.pop(context);
              final success = await _adminService.createFeatureFlag(
                nameController.text,
                descController.text,
              );
              if (success && mounted) {
                _loadFlags();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Feature flag created')),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

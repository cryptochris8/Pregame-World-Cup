import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

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

    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.featureFlags),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateFlagDialog,
            tooltip: l10n.addFlag,
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
                        l10n.noFeatureFlags,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _showCreateFlagDialog,
                        icon: const Icon(Icons.add),
                        label: Text(l10n.createFlag),
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
                  flag.isEnabled ? AppLocalizations.of(context).enabled : AppLocalizations.of(context).disabled,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: flag.isEnabled ? Colors.green : Colors.grey,
                  ),
                ),
                const Spacer(),
                if (flag.updatedBy != null)
                  Text(
                    AppLocalizations.of(context).updatedDate(_formatDate(flag.updatedAt)),
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
        SnackBar(content: Text(AppLocalizations.of(context).failedToUpdateFlag)),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).flagToggled(flag.name, value ? AppLocalizations.of(context).enabled.toLowerCase() : AppLocalizations.of(context).disabled.toLowerCase())),
        ),
      );
    }
  }

  void _showCreateFlagDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.createFeatureFlag),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: l10n.name,
                hintText: l10n.featureFlagNameHint,
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: InputDecoration(
                labelText: l10n.description,
                hintText: l10n.featureFlagDescHint,
              ),
              maxLines: 2,
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
              if (nameController.text.isEmpty) return;
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              final success = await _adminService.createFeatureFlag(
                nameController.text,
                descController.text,
              );
              if (success && mounted) {
                _loadFlags();
                messenger.showSnackBar(
                  SnackBar(content: Text(l10n.featureFlagCreated)),
                );
              }
            },
            child: Text(l10n.create),
          ),
        ],
      ),
    );
  }
}

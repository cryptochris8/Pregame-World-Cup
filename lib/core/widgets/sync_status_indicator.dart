import 'package:flutter/material.dart';

import '../services/offline_service.dart';
import 'offline_indicator.dart';

/// A widget that shows the current sync status with progress
class SyncStatusIndicator extends StatelessWidget {
  final bool showLabel;
  final bool compact;

  const SyncStatusIndicator({
    super.key,
    this.showLabel = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: OfflineService.instance,
      builder: (context, _) {
        final service = OfflineService.instance;
        final status = service.syncStatus;

        // Don't show if online with nothing to sync
        if (service.isOnline && !service.hasPendingActions && !status.isSyncing) {
          return const SizedBox.shrink();
        }

        if (compact) {
          return _buildCompact(context, service, status);
        }

        return _buildFull(context, service, status);
      },
    );
  }

  Widget _buildCompact(BuildContext context, OfflineService service, SyncStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getBackgroundColor(service.state).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getBackgroundColor(service.state).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status.isSyncing)
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: status.progress,
                color: _getBackgroundColor(service.state),
              ),
            )
          else
            Icon(
              _getIcon(service.state),
              size: 14,
              color: _getBackgroundColor(service.state),
            ),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              _getLabel(service, status),
              style: TextStyle(
                fontSize: 12,
                color: _getBackgroundColor(service.state),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFull(BuildContext context, OfflineService service, SyncStatus status) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getBackgroundColor(service.state).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getBackgroundColor(service.state).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getIcon(service.state),
                  color: _getBackgroundColor(service.state),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTitle(service.state),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getSubtitle(service, status),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (service.isOnline && service.hasPendingActions && !status.isSyncing)
                TextButton(
                  onPressed: () => service.syncNow(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: const Text('Sync'),
                ),
            ],
          ),

          // Progress bar
          if (status.isSyncing) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: status.progress,
                backgroundColor: Colors.grey[300],
                color: _getBackgroundColor(service.state),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  status.currentAction ?? 'Processing...',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '${(status.progress * 100).toInt()}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],

          // Stats row
          if (service.hasPendingActions || status.hasErrors) ...[
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Row(
              children: [
                if (status.pendingActions > 0)
                  _buildStat(
                    icon: Icons.pending,
                    value: status.pendingActions.toString(),
                    label: 'Pending',
                    color: Colors.orange,
                  ),
                if (status.completedActions > 0) ...[
                  const SizedBox(width: 16),
                  _buildStat(
                    icon: Icons.check_circle,
                    value: status.completedActions.toString(),
                    label: 'Done',
                    color: Colors.green,
                  ),
                ],
                if (status.failedActions > 0) ...[
                  const SizedBox(width: 16),
                  _buildStat(
                    icon: Icons.error,
                    value: status.failedActions.toString(),
                    label: 'Failed',
                    color: Colors.red,
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Color _getBackgroundColor(ConnectivityState state) {
    switch (state) {
      case ConnectivityState.online:
        return Colors.green;
      case ConnectivityState.offline:
        return Colors.red;
      case ConnectivityState.syncing:
        return Colors.orange;
    }
  }

  IconData _getIcon(ConnectivityState state) {
    switch (state) {
      case ConnectivityState.online:
        return Icons.cloud_done;
      case ConnectivityState.offline:
        return Icons.cloud_off;
      case ConnectivityState.syncing:
        return Icons.sync;
    }
  }

  String _getTitle(ConnectivityState state) {
    switch (state) {
      case ConnectivityState.online:
        return 'Online';
      case ConnectivityState.offline:
        return 'Offline Mode';
      case ConnectivityState.syncing:
        return 'Syncing';
    }
  }

  String _getLabel(OfflineService service, SyncStatus status) {
    if (status.isSyncing) {
      return '${(status.progress * 100).toInt()}%';
    } else if (service.isOffline) {
      return 'Offline';
    } else if (service.hasPendingActions) {
      return '${status.pendingActions} pending';
    }
    return 'Online';
  }

  String _getSubtitle(OfflineService service, SyncStatus status) {
    if (status.isSyncing) {
      return 'Syncing ${status.pendingActions} items...';
    } else if (service.isOffline) {
      if (service.hasPendingActions) {
        return '${status.pendingActions} changes waiting to sync';
      }
      return 'Changes will sync when online';
    } else if (service.hasPendingActions) {
      return '${status.pendingActions} changes ready to sync';
    }
    return 'All changes synced';
  }
}

/// A floating action button that shows sync status
class SyncFAB extends StatelessWidget {
  final VoidCallback? onPressed;

  const SyncFAB({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: OfflineService.instance,
      builder: (context, _) {
        final service = OfflineService.instance;
        final status = service.syncStatus;

        // Don't show if fully synced
        if (service.isOnline && !service.hasPendingActions && !status.isSyncing) {
          return const SizedBox.shrink();
        }

        return FloatingActionButton.extended(
          onPressed: onPressed ?? () => _handlePress(context, service),
          backgroundColor: _getColor(service.state),
          icon: status.isSyncing
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    value: status.progress,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Icon(_getIcon(service.state)),
          label: Text(_getLabel(service, status)),
        );
      },
    );
  }

  void _handlePress(BuildContext context, OfflineService service) {
    if (service.isOnline && service.hasPendingActions) {
      service.syncNow();
    } else {
      showDialog(
        context: context,
        builder: (context) => const OfflineStatusDialog(),
      );
    }
  }

  Color _getColor(ConnectivityState state) {
    switch (state) {
      case ConnectivityState.online:
        return Colors.green;
      case ConnectivityState.offline:
        return Colors.red;
      case ConnectivityState.syncing:
        return Colors.orange;
    }
  }

  IconData _getIcon(ConnectivityState state) {
    switch (state) {
      case ConnectivityState.online:
        return Icons.sync;
      case ConnectivityState.offline:
        return Icons.cloud_off;
      case ConnectivityState.syncing:
        return Icons.sync;
    }
  }

  String _getLabel(OfflineService service, SyncStatus status) {
    if (status.isSyncing) {
      return 'Syncing...';
    } else if (service.isOffline) {
      return 'Offline';
    } else if (service.hasPendingActions) {
      return 'Sync ${status.pendingActions}';
    }
    return 'Synced';
  }
}

/// A tile for showing sync status in settings
class SyncStatusTile extends StatelessWidget {
  const SyncStatusTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: OfflineService.instance,
      builder: (context, _) {
        final service = OfflineService.instance;
        final status = service.syncStatus;

        return ListTile(
          leading: Icon(
            service.isOffline ? Icons.cloud_off : Icons.cloud_done,
            color: service.isOffline ? Colors.red : Colors.green,
          ),
          title: const Text('Sync Status'),
          subtitle: Text(
            service.isOffline
                ? 'Offline - ${status.pendingActions} pending'
                : status.lastSyncTime != null
                    ? 'Last synced ${_formatTime(status.lastSyncTime!)}'
                    : 'All synced',
          ),
          trailing: service.hasPendingActions && service.isOnline
              ? TextButton(
                  onPressed: () => service.syncNow(),
                  child: const Text('Sync Now'),
                )
              : null,
          onTap: () => showDialog(
            context: context,
            builder: (context) => const OfflineStatusDialog(),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}

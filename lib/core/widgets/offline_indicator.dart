import 'package:flutter/material.dart';

import '../../config/app_theme.dart';
import '../services/offline_service.dart';

/// A branded banner that shows when the app is offline.
///
/// Displays a thin, non-intrusive bar with AppTheme styling and a gradient
/// accent border. Automatically hides when the device regains connectivity.
class OfflineBanner extends StatelessWidget {
  final VoidCallback? onRetry;

  const OfflineBanner({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: OfflineService.instance,
      builder: (context, _) {
        final service = OfflineService.instance;

        if (service.isOnline && !service.hasPendingActions) {
          return const SizedBox.shrink();
        }

        return _BrandedBannerContent(
          state: service.state,
          hasPendingActions: service.hasPendingActions,
          pendingActionsCount: service.pendingActionsCount,
          isSyncing: service.isSyncing,
          isOffline: service.isOffline,
          onRetry: onRetry,
        );
      },
    );
  }
}

/// The visual content of the offline banner, extracted so it can be tested
/// without needing a live [OfflineService] singleton.
class _BrandedBannerContent extends StatelessWidget {
  final ConnectivityState state;
  final bool hasPendingActions;
  final int pendingActionsCount;
  final bool isSyncing;
  final bool isOffline;
  final VoidCallback? onRetry;

  const _BrandedBannerContent({
    required this.state,
    required this.hasPendingActions,
    required this.pendingActionsCount,
    required this.isSyncing,
    required this.isOffline,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          color: AppTheme.backgroundCard,
          border: Border(
            bottom: BorderSide(
              color: AppTheme.primaryOrange,
              width: 2,
            ),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildIcon(),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getTitle(),
                        style: const TextStyle(
                          color: AppTheme.textWhite,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        _getSubtitle(),
                        style: const TextStyle(
                          color: AppTheme.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isOffline && onRetry != null)
                  TextButton(
                    onPressed: onRetry,
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryOrange,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      minimumSize: const Size(0, 32),
                    ),
                    child: const Text('Retry'),
                  ),
                if (isSyncing)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryOrange,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    final IconData iconData;
    final Color iconColor;

    switch (state) {
      case ConnectivityState.online:
        iconData = Icons.cloud_done;
        iconColor = AppTheme.secondaryEmerald;
      case ConnectivityState.offline:
        iconData = Icons.cloud_off;
        iconColor = AppTheme.primaryOrange;
      case ConnectivityState.syncing:
        iconData = Icons.sync;
        iconColor = AppTheme.accentGold;
    }

    return Icon(iconData, color: iconColor, size: 20);
  }

  String _getTitle() {
    switch (state) {
      case ConnectivityState.online:
        return 'Back Online';
      case ConnectivityState.offline:
        return "You're offline";
      case ConnectivityState.syncing:
        return 'Syncing...';
    }
  }

  String _getSubtitle() {
    switch (state) {
      case ConnectivityState.online:
        if (hasPendingActions) {
          return '$pendingActionsCount pending actions';
        }
        return 'Connection restored';
      case ConnectivityState.offline:
        return 'Showing cached content';
      case ConnectivityState.syncing:
        if (hasPendingActions) {
          return '$pendingActionsCount actions remaining';
        }
        return 'Updating content...';
    }
  }
}

/// A small indicator chip for showing offline status
class OfflineChip extends StatelessWidget {
  const OfflineChip({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: OfflineService.instance,
      builder: (context, _) {
        final service = OfflineService.instance;

        if (service.isOnline && !service.isSyncing) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: service.isOffline ? Colors.red : Colors.orange,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                service.isOffline ? Icons.cloud_off : Icons.sync,
                color: Colors.white,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                service.isOffline ? 'Offline' : 'Syncing',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// An icon button that shows offline status in app bar
class OfflineStatusIcon extends StatelessWidget {
  final VoidCallback? onTap;

  const OfflineStatusIcon({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: OfflineService.instance,
      builder: (context, _) {
        final service = OfflineService.instance;

        // Don't show when fully online with no pending actions
        if (service.isOnline && !service.hasPendingActions) {
          return const SizedBox.shrink();
        }

        return IconButton(
          onPressed: onTap ?? () => _showStatusDialog(context),
          icon: Stack(
            children: [
              Icon(
                service.isOffline ? Icons.cloud_off : Icons.sync,
                color: service.isOffline ? Colors.red : Colors.orange,
              ),
              if (service.hasPendingActions)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: Text(
                      '${service.pendingActionsCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          tooltip: service.isOffline ? 'Offline' : 'Syncing',
        );
      },
    );
  }

  void _showStatusDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const OfflineStatusDialog(),
    );
  }
}

/// Dialog showing detailed offline/sync status
class OfflineStatusDialog extends StatelessWidget {
  const OfflineStatusDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: OfflineService.instance,
      builder: (context, _) {
        final service = OfflineService.instance;
        final status = service.syncStatus;
        final theme = Theme.of(context);

        return AlertDialog(
          title: Row(
            children: [
              Icon(
                service.isOffline ? Icons.cloud_off : Icons.sync,
                color: service.isOffline ? Colors.red : Colors.orange,
              ),
              const SizedBox(width: 12),
              Text(service.isOffline ? 'Offline Mode' : 'Sync Status'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status message
              Text(
                service.isOffline
                    ? 'You\'re currently offline. Changes will be synced when you reconnect.'
                    : 'Syncing your changes...',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),

              // Pending actions
              if (service.hasPendingActions) ...[
                _buildInfoRow(
                  context,
                  icon: Icons.pending_actions,
                  label: 'Pending Actions',
                  value: '${status.pendingActions}',
                ),
                const SizedBox(height: 8),
              ],

              // Completed actions (during sync)
              if (status.isSyncing && status.completedActions > 0) ...[
                _buildInfoRow(
                  context,
                  icon: Icons.check_circle,
                  label: 'Completed',
                  value: '${status.completedActions}',
                  color: Colors.green,
                ),
                const SizedBox(height: 8),
              ],

              // Failed actions
              if (status.failedActions > 0) ...[
                _buildInfoRow(
                  context,
                  icon: Icons.error,
                  label: 'Failed',
                  value: '${status.failedActions}',
                  color: Colors.red,
                ),
                const SizedBox(height: 8),
              ],

              // Last sync time
              if (status.lastSyncTime != null) ...[
                _buildInfoRow(
                  context,
                  icon: Icons.schedule,
                  label: 'Last Sync',
                  value: _formatTime(status.lastSyncTime!),
                ),
                const SizedBox(height: 8),
              ],

              // Sync progress
              if (status.isSyncing) ...[
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: status.progress,
                  backgroundColor: Colors.grey[300],
                ),
                const SizedBox(height: 4),
                Text(
                  status.currentAction ?? 'Processing...',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            if (service.isOnline && service.hasPendingActions)
              TextButton(
                onPressed: () {
                  service.syncNow();
                },
                child: const Text('Sync Now'),
              ),
            if (service.hasPendingActions)
              TextButton(
                onPressed: () {
                  _showClearQueueConfirmation(context);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Clear Queue'),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color ?? Colors.grey[600]),
        const SizedBox(width: 8),
        Text(label),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  void _showClearQueueConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Queue?'),
        content: const Text(
          'This will discard all pending changes that haven\'t been synced yet. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              OfflineService.instance.clearQueue();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

/// Wrapper widget that shows offline indicator at the top of the screen
class OfflineWrapper extends StatelessWidget {
  final Widget child;
  final VoidCallback? onRetry;

  const OfflineWrapper({
    super.key,
    required this.child,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OfflineBanner(onRetry: onRetry),
        Expanded(child: child),
      ],
    );
  }
}

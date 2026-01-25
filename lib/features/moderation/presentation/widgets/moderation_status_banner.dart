import 'package:flutter/material.dart';

import '../../domain/entities/user_sanction.dart';
import '../../domain/services/moderation_service.dart';

/// Banner widget that displays when a user has an active moderation restriction
class ModerationStatusBanner extends StatefulWidget {
  final Widget child;
  final bool showBanner;

  const ModerationStatusBanner({
    super.key,
    required this.child,
    this.showBanner = true,
  });

  @override
  State<ModerationStatusBanner> createState() => _ModerationStatusBannerState();
}

class _ModerationStatusBannerState extends State<ModerationStatusBanner> {
  final ModerationService _moderationService = ModerationService();
  String? _restrictionMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkModerationStatus();
  }

  Future<void> _checkModerationStatus() async {
    if (!widget.showBanner) {
      setState(() => _isLoading = false);
      return;
    }

    final message = await _moderationService.getCurrentUserRestriction();
    if (mounted) {
      setState(() {
        _restrictionMessage = message;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || !widget.showBanner || _restrictionMessage == null) {
      return widget.child;
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.orange[100],
            border: Border(
              bottom: BorderSide(color: Colors.orange[300]!),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange[800],
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _restrictionMessage!,
                  style: TextStyle(
                    color: Colors.orange[900],
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}

/// Widget that blocks input when user is muted
class MutedInputBlocker extends StatefulWidget {
  final Widget child;
  final Widget? mutedChild;

  const MutedInputBlocker({
    super.key,
    required this.child,
    this.mutedChild,
  });

  @override
  State<MutedInputBlocker> createState() => _MutedInputBlockerState();
}

class _MutedInputBlockerState extends State<MutedInputBlocker> {
  final ModerationService _moderationService = ModerationService();
  bool _isMuted = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkMuteStatus();
  }

  Future<void> _checkMuteStatus() async {
    final isMuted = await _moderationService.isCurrentUserMuted();
    if (mounted) {
      setState(() {
        _isMuted = isMuted;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.child;
    }

    if (_isMuted) {
      return widget.mutedChild ??
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.volume_off,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'You are currently muted and cannot send messages',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          );
    }

    return widget.child;
  }
}

/// Widget that displays user's moderation status summary
class ModerationStatusCard extends StatefulWidget {
  final String userId;
  final bool showIfClean;

  const ModerationStatusCard({
    super.key,
    required this.userId,
    this.showIfClean = false,
  });

  @override
  State<ModerationStatusCard> createState() => _ModerationStatusCardState();
}

class _ModerationStatusCardState extends State<ModerationStatusCard> {
  final ModerationService _moderationService = ModerationService();
  UserModerationStatus? _status;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final status =
        await _moderationService.getUserModerationStatus(widget.userId);
    if (mounted) {
      setState(() {
        _status = status;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_status == null) {
      return const SizedBox.shrink();
    }

    // Don't show anything if user has clean record and showIfClean is false
    if (!widget.showIfClean &&
        _status!.warningCount == 0 &&
        !_status!.isMuted &&
        !_status!.isSuspended &&
        !_status!.isBanned) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getStatusIcon(),
                  color: _getStatusColor(),
                ),
                const SizedBox(width: 8),
                Text(
                  'Account Status',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStatusRow('Warnings', '${_status!.warningCount}'),
            _buildStatusRow('Reports received', '${_status!.reportCount}'),
            if (_status!.isMuted)
              _buildStatusRow(
                'Muted until',
                _formatDateTime(_status!.mutedUntil),
                isWarning: true,
              ),
            if (_status!.isSuspended)
              _buildStatusRow(
                'Suspended until',
                _formatDateTime(_status!.suspendedUntil),
                isWarning: true,
              ),
            if (_status!.isBanned)
              _buildStatusRow(
                'Status',
                'Permanently banned',
                isError: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value,
      {bool isWarning = false, bool isError = false}) {
    Color valueColor = Colors.black87;
    if (isError) valueColor = Colors.red;
    if (isWarning) valueColor = Colors.orange;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[600]),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon() {
    if (_status!.isBanned) return Icons.block;
    if (_status!.isSuspended) return Icons.pause_circle;
    if (_status!.isMuted) return Icons.volume_off;
    if (_status!.warningCount > 0) return Icons.warning;
    return Icons.check_circle;
  }

  Color _getStatusColor() {
    if (_status!.isBanned) return Colors.red;
    if (_status!.isSuspended) return Colors.orange;
    if (_status!.isMuted) return Colors.amber;
    if (_status!.warningCount > 0) return Colors.yellow[700]!;
    return Colors.green;
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Unknown';
    return '${dateTime.month}/${dateTime.day}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

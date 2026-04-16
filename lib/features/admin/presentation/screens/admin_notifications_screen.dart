import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';
import '../../../../injection_container.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/admin_user.dart';
import '../../domain/services/admin_service.dart';

/// Admin screen for sending broadcast push notifications
class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() => _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  final AdminService _adminService = sl<AdminService>();
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  NotificationAudience _selectedAudience = NotificationAudience.allUsers;
  String? _selectedTeam;
  bool _isSending = false;

  final List<String> _teams = [
    'USA',
    'Mexico',
    'Canada',
    'Argentina',
    'Brazil',
    'England',
    'France',
    'Germany',
    'Spain',
    'Italy',
    'Portugal',
    'Netherlands',
    'Belgium',
    'Japan',
    'South Korea',
    'Australia',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).pushNotifications),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Warning card
              Card(
                color: Colors.amber.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.amber.shade800),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context).broadcastWarning,
                          style: TextStyle(color: Colors.amber.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Audience selection
              Text(
                AppLocalizations.of(context).targetAudience,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildAudienceSelector(theme),
              const SizedBox(height: 24),

              // Team selector (only for team fans)
              if (_selectedAudience == NotificationAudience.teamFans) ...[
                Text(
                  AppLocalizations.of(context).selectTeam,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedTeam,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).selectTeam,
                    border: const OutlineInputBorder(),
                  ),
                  items: _teams
                      .map((team) => DropdownMenuItem(
                            value: team,
                            child: Text(team),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedTeam = value),
                  validator: (value) =>
                      value == null ? AppLocalizations.of(context).pleaseSelectATeam : null,
                ),
                const SizedBox(height: 24),
              ],

              // Notification content
              Text(
                AppLocalizations.of(context).notificationContentLabel,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).titleLabel,
                  hintText: AppLocalizations.of(context).enterNotificationTitle,
                  border: const OutlineInputBorder(),
                ),
                maxLength: 65,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context).pleaseEnterTitle;
                  }
                  if (value.length < 3) {
                    return AppLocalizations.of(context).titleMinLength;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bodyController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).messageLabel,
                  hintText: AppLocalizations.of(context).enterNotificationMessage,
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                maxLength: 240,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context).pleaseEnterMessage;
                  }
                  if (value.length < 10) {
                    return AppLocalizations.of(context).messageMinLength;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Preview card
              Text(
                AppLocalizations.of(context).previewLabel,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildPreviewCard(theme),
              const SizedBox(height: 32),

              // Send button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSending ? null : _sendNotification,
                  icon: _isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  label: Text(_isSending ? AppLocalizations.of(context).sending : AppLocalizations.of(context).sendNotification),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Recent notifications
              _buildRecentNotifications(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAudienceSelector(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        _buildAudienceOption(
          theme,
          NotificationAudience.allUsers,
          l10n.allUsersAudience,
          l10n.sendToEveryone,
          Icons.public,
        ),
        _buildAudienceOption(
          theme,
          NotificationAudience.premiumUsers,
          l10n.premiumUsersAudience,
          l10n.superfanPassHoldersOnly,
          Icons.star,
        ),
        _buildAudienceOption(
          theme,
          NotificationAudience.teamFans,
          l10n.teamFansAudience,
          l10n.usersFollowSpecificTeam,
          Icons.groups,
        ),
        _buildAudienceOption(
          theme,
          NotificationAudience.activeUsers,
          l10n.activeUsersAudience,
          l10n.usersActiveLast7Days,
          Icons.trending_up,
        ),
      ],
    );
  }

  Widget _buildAudienceOption(
    ThemeData theme,
    NotificationAudience audience,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = _selectedAudience == audience;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected ? theme.colorScheme.primaryContainer : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              isSelected ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
          child: Icon(
            icon,
            color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
            : null,
        onTap: () => setState(() {
          _selectedAudience = audience;
          if (audience != NotificationAudience.teamFans) {
            _selectedTeam = null;
          }
        }),
      ),
    );
  }

  Widget _buildPreviewCard(ThemeData theme) {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceContainerHighest,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.sports_soccer,
                    color: theme.colorScheme.onPrimary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pregame',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      Text(
                        _titleController.text.isEmpty
                            ? AppLocalizations.of(context).notificationTitlePlaceholder
                            : _titleController.text,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Text(
                  AppLocalizations.of(context).nowLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _bodyController.text.isEmpty
                  ? AppLocalizations.of(context).notificationPreviewPlaceholder
                  : _bodyController.text,
              style: theme.textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentNotifications(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),
        Text(
          AppLocalizations.of(context).recentBroadcasts,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        // Placeholder for recent notifications
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.history,
                    size: 48,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context).recentBroadcastHistory,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _sendNotification() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedAudience == NotificationAudience.teamFans &&
        _selectedTeam == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).pleaseSelectATeam)),
      );
      return;
    }

    // Confirm dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backgroundCard,
        title: Text(AppLocalizations.of(context).confirmSend),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context).confirmSendNotification),
            const SizedBox(height: 16),
            _buildConfirmDetail(AppLocalizations.of(context).audienceLabel, _getAudienceLabel()),
            _buildConfirmDetail(AppLocalizations.of(context).titleLabel, _titleController.text),
            _buildConfirmDetail(AppLocalizations.of(context).messageLabel, _bodyController.text),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text(AppLocalizations.of(context).send),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSending = true);

    try {
      final success = await _adminService.sendBroadcastNotification(
        title: _titleController.text,
        body: _bodyController.text,
        audience: _selectedAudience,
        teamCode: _selectedTeam,
      );

      if (!mounted) return;
      setState(() => _isSending = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).notificationSentSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
        // Clear form
        _titleController.clear();
        _bodyController.clear();
        setState(() {
          _selectedAudience = NotificationAudience.allUsers;
          _selectedTeam = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).failedToSendNotification),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send notification: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildConfirmDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _getAudienceLabel() {
    final l10n = AppLocalizations.of(context);
    switch (_selectedAudience) {
      case NotificationAudience.allUsers:
        return l10n.allUsersAudience;
      case NotificationAudience.premiumUsers:
        return l10n.premiumUsersAudience;
      case NotificationAudience.teamFans:
        return l10n.teamFansWithTeam(_selectedTeam ?? '');
      case NotificationAudience.activeUsers:
        return l10n.activeUsers7Days;
    }
  }
}

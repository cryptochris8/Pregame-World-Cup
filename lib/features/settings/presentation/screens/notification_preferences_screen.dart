import 'package:flutter/material.dart';

import '../../../../core/services/notification_preferences_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../worldcup/domain/entities/match_reminder.dart';

/// Screen for managing notification preferences
class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() => _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState extends State<NotificationPreferencesScreen> {
  final NotificationPreferencesService _prefsService = NotificationPreferencesService();
  late NotificationPreferencesData _preferences;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    await _prefsService.initialize();
    setState(() {
      _preferences = _prefsService.preferences;
      _isLoading = false;
    });
  }

  Future<void> _updatePreference(NotificationPreferencesData newPrefs) async {
    setState(() => _preferences = newPrefs);
    await _prefsService.updatePreferences(newPrefs);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.notifications)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationSettings),
        actions: [
          TextButton(
            onPressed: () async {
              await _prefsService.resetToDefaults();
              setState(() => _preferences = _prefsService.preferences);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.settingsResetToDefaults)),
                );
              }
            },
            child: Text(
              l10n.resetLabel,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          // Master Switch
          _buildMasterSwitch(theme),

          if (_preferences.pushNotificationsEnabled) ...[
            const Divider(height: 32),

            // Quiet Hours
            _buildQuietHoursSection(theme),

            const Divider(height: 32),

            // Match Notifications
            _buildMatchNotificationsSection(theme),

            const Divider(height: 32),

            // Live Match Alerts
            _buildLiveMatchAlertsSection(theme),

            const Divider(height: 32),

            // Watch Party Notifications
            _buildWatchPartySection(theme),

            const Divider(height: 32),

            // Social Notifications
            _buildSocialSection(theme),

            const Divider(height: 32),

            // Predictions & Leaderboard
            _buildPredictionsSection(theme),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildMasterSwitch(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      label: l10n.pushNotifications,
      child: SwitchListTile(
        title: Text(
          l10n.pushNotifications,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          _preferences.pushNotificationsEnabled
              ? l10n.youWillReceiveNotifications
              : l10n.allNotificationsDisabled,
        ),
        value: _preferences.pushNotificationsEnabled,
        onChanged: (value) => _updatePreference(
          _preferences.copyWith(pushNotificationsEnabled: value),
        ),
        secondary: Icon(
          _preferences.pushNotificationsEnabled
              ? Icons.notifications_active
              : Icons.notifications_off,
          color: _preferences.pushNotificationsEnabled
              ? theme.colorScheme.primary
              : theme.colorScheme.outline,
        ),
      ),
    );
  }

  Widget _buildQuietHoursSection(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(theme, l10n.quietHours, Icons.bedtime),
        SwitchListTile(
          title: Text(l10n.enableQuietHours),
          subtitle: Text(
            _preferences.quietHoursEnabled
                ? l10n.noNotificationsFromTo(_preferences.quietHoursStart, _preferences.quietHoursEnd)
                : l10n.receiveNotificationsAnytime,
          ),
          value: _preferences.quietHoursEnabled,
          onChanged: (value) => _updatePreference(
            _preferences.copyWith(quietHoursEnabled: value),
          ),
        ),
        if (_preferences.quietHoursEnabled) ...[
          ListTile(
            title: Text(l10n.startTime),
            trailing: Text(
              _preferences.quietHoursStart,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            onTap: () => _selectTime(isStart: true),
          ),
          ListTile(
            title: Text(l10n.endTime),
            trailing: Text(
              _preferences.quietHoursEnd,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            onTap: () => _selectTime(isStart: false),
          ),
        ],
      ],
    );
  }

  Widget _buildMatchNotificationsSection(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(theme, l10n.matchReminders, Icons.sports_soccer),
        SwitchListTile(
          title: Text(l10n.matchReminders),
          subtitle: Text(l10n.getRemindedBeforeMatches),
          value: _preferences.matchRemindersEnabled,
          onChanged: (value) => _updatePreference(
            _preferences.copyWith(matchRemindersEnabled: value),
          ),
        ),
        if (_preferences.matchRemindersEnabled)
          ListTile(
            title: Text(l10n.defaultReminderTime),
            subtitle: Text(_preferences.defaultReminderTiming.displayName),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showReminderTimingPicker(
              currentTiming: _preferences.defaultReminderTiming,
              onSelected: (timing) => _updatePreference(
                _preferences.copyWith(defaultReminderTiming: timing),
              ),
            ),
          ),
        const Divider(indent: 16, endIndent: 16),
        SwitchListTile(
          title: Text(l10n.favoriteTeamMatchesLabel),
          subtitle: Text(l10n.favoriteTeamMatchesDesc),
          value: _preferences.favoriteTeamMatchesEnabled,
          onChanged: (value) => _updatePreference(
            _preferences.copyWith(favoriteTeamMatchesEnabled: value),
          ),
        ),
        if (_preferences.favoriteTeamMatchesEnabled)
          SwitchListTile(
            title: Text(l10n.dayBeforeNotification),
            subtitle: Text(l10n.dayBeforeNotificationDesc),
            value: _preferences.favoriteTeamMatchDayBefore,
            onChanged: (value) => _updatePreference(
              _preferences.copyWith(favoriteTeamMatchDayBefore: value),
            ),
          ),
      ],
    );
  }

  Widget _buildLiveMatchAlertsSection(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(theme, l10n.liveMatchAlerts, Icons.flash_on),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            l10n.liveMatchAlertsDesc,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: Text(l10n.goalAlerts),
          subtitle: Text(l10n.whenGoalScored),
          value: _preferences.goalAlertsEnabled,
          onChanged: (value) => _updatePreference(
            _preferences.copyWith(goalAlertsEnabled: value),
          ),
          secondary: const Text('', style: TextStyle(fontSize: 24)),
        ),
        SwitchListTile(
          title: Text(l10n.matchStart),
          subtitle: Text(l10n.whenMatchKicksOff),
          value: _preferences.matchStartAlertsEnabled,
          onChanged: (value) => _updatePreference(
            _preferences.copyWith(matchStartAlertsEnabled: value),
          ),
          secondary: const Text('', style: TextStyle(fontSize: 24)),
        ),
        SwitchListTile(
          title: Text(l10n.halftimeLabel),
          subtitle: Text(l10n.halftimeScoreUpdates),
          value: _preferences.halftimeAlertsEnabled,
          onChanged: (value) => _updatePreference(
            _preferences.copyWith(halftimeAlertsEnabled: value),
          ),
        ),
        SwitchListTile(
          title: Text(l10n.matchEnd),
          subtitle: Text(l10n.finalScoreNotifications),
          value: _preferences.matchEndAlertsEnabled,
          onChanged: (value) => _updatePreference(
            _preferences.copyWith(matchEndAlertsEnabled: value),
          ),
        ),
        SwitchListTile(
          title: Text(l10n.redCards),
          subtitle: Text(l10n.playerSentOff),
          value: _preferences.redCardAlertsEnabled,
          onChanged: (value) => _updatePreference(
            _preferences.copyWith(redCardAlertsEnabled: value),
          ),
          secondary: Container(
            width: 24,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        SwitchListTile(
          title: Text(l10n.penalties),
          subtitle: Text(l10n.penaltyKicksAwarded),
          value: _preferences.penaltyAlertsEnabled,
          onChanged: (value) => _updatePreference(
            _preferences.copyWith(penaltyAlertsEnabled: value),
          ),
        ),
      ],
    );
  }

  Widget _buildWatchPartySection(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(theme, l10n.watchParties, Icons.groups),
        SwitchListTile(
          title: Text(l10n.watchPartyInvites),
          subtitle: Text(l10n.watchPartyInvitesDesc),
          value: _preferences.watchPartyInvitesEnabled,
          onChanged: (value) => _updatePreference(
            _preferences.copyWith(watchPartyInvitesEnabled: value),
          ),
        ),
        SwitchListTile(
          title: Text(l10n.watchPartyReminders),
          subtitle: Text(l10n.watchPartyRemindersDesc),
          value: _preferences.watchPartyRemindersEnabled,
          onChanged: (value) => _updatePreference(
            _preferences.copyWith(watchPartyRemindersEnabled: value),
          ),
        ),
        if (_preferences.watchPartyRemindersEnabled)
          ListTile(
            title: Text(l10n.reminderTime),
            subtitle: Text(_preferences.watchPartyReminderTiming.displayName),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showReminderTimingPicker(
              currentTiming: _preferences.watchPartyReminderTiming,
              onSelected: (timing) => _updatePreference(
                _preferences.copyWith(watchPartyReminderTiming: timing),
              ),
            ),
          ),
        SwitchListTile(
          title: Text(l10n.watchPartyUpdates),
          subtitle: Text(l10n.watchPartyUpdatesDesc),
          value: _preferences.watchPartyUpdatesEnabled,
          onChanged: (value) => _updatePreference(
            _preferences.copyWith(watchPartyUpdatesEnabled: value),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialSection(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(theme, l10n.social, Icons.people),
        SwitchListTile(
          title: Text(l10n.friendRequests),
          subtitle: Text(l10n.friendRequestsDesc),
          value: _preferences.friendRequestsEnabled,
          onChanged: (value) => _updatePreference(
            _preferences.copyWith(friendRequestsEnabled: value),
          ),
        ),
        SwitchListTile(
          title: Text(l10n.messagesNotification),
          subtitle: Text(l10n.messagesNotificationDesc),
          value: _preferences.messagesEnabled,
          onChanged: (value) => _updatePreference(
            _preferences.copyWith(messagesEnabled: value),
          ),
        ),
        SwitchListTile(
          title: Text(l10n.mentionsLabel),
          subtitle: Text(l10n.mentionsDesc),
          value: _preferences.mentionsEnabled,
          onChanged: (value) => _updatePreference(
            _preferences.copyWith(mentionsEnabled: value),
          ),
        ),
      ],
    );
  }

  Widget _buildPredictionsSection(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(theme, l10n.predictionsAndLeaderboard, Icons.emoji_events),
        SwitchListTile(
          title: Text(l10n.predictionResults),
          subtitle: Text(l10n.predictionResultsDesc),
          value: _preferences.predictionResultsEnabled,
          onChanged: (value) => _updatePreference(
            _preferences.copyWith(predictionResultsEnabled: value),
          ),
        ),
        SwitchListTile(
          title: Text(l10n.leaderboardUpdates),
          subtitle: Text(l10n.leaderboardUpdatesDesc),
          value: _preferences.leaderboardUpdatesEnabled,
          onChanged: (value) => _updatePreference(
            _preferences.copyWith(leaderboardUpdatesEnabled: value),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime({required bool isStart}) async {
    final currentTime = isStart
        ? _preferences.quietHoursStart
        : _preferences.quietHoursEnd;
    final parts = currentTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    final selected = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (selected != null) {
      final timeStr =
          '${selected.hour.toString().padLeft(2, '0')}:${selected.minute.toString().padLeft(2, '0')}';
      await _updatePreference(
        isStart
            ? _preferences.copyWith(quietHoursStart: timeStr)
            : _preferences.copyWith(quietHoursEnd: timeStr),
      );
    }
  }

  void _showReminderTimingPicker({
    required ReminderTiming currentTiming,
    required ValueChanged<ReminderTiming> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.selectReminderTime,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const Divider(height: 1),
            ...ReminderTiming.values.map((timing) => ListTile(
                  title: Text(timing.displayName),
                  subtitle: Text(l10n.minutesBefore(timing.minutes)),
                  trailing: timing == currentTiming
                      ? Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () {
                    onSelected(timing);
                    Navigator.pop(context);
                  },
                )),
            const SizedBox(height: 16),
          ],
        ),
      );
      },
    );
  }
}

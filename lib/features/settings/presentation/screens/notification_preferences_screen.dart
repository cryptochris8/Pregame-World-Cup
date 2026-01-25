import 'package:flutter/material.dart';

import '../../../../core/services/notification_preferences_service.dart';
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

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notifications')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        actions: [
          TextButton(
            onPressed: () async {
              await _prefsService.resetToDefaults();
              setState(() => _preferences = _prefsService.preferences);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings reset to defaults')),
                );
              }
            },
            child: Text(
              'Reset',
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
    return Semantics(
      label: 'Push notifications master switch',
      hint: _preferences.pushNotificationsEnabled
          ? 'Tap to disable all notifications'
          : 'Tap to enable notifications',
      child: SwitchListTile(
        title: Text(
          'Push Notifications',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          _preferences.pushNotificationsEnabled
              ? 'You will receive notifications'
              : 'All notifications are disabled',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(theme, 'Quiet Hours', Icons.bedtime),
        SwitchListTile(
          title: const Text('Enable Quiet Hours'),
          subtitle: Text(
            _preferences.quietHoursEnabled
                ? 'No notifications from ${_preferences.quietHoursStart} to ${_preferences.quietHoursEnd}'
                : 'Receive notifications anytime',
          ),
          value: _preferences.quietHoursEnabled,
          onChanged: (value) => _updatePreference(
            _preferences.copyWith(quietHoursEnabled: value),
          ),
        ),
        if (_preferences.quietHoursEnabled) ...[
          ListTile(
            title: const Text('Start Time'),
            trailing: Text(
              _preferences.quietHoursStart,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            onTap: () => _selectTime(isStart: true),
          ),
          ListTile(
            title: const Text('End Time'),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(theme, 'Match Reminders', Icons.sports_soccer),
        SwitchListTile(
          title: const Text('Match Reminders'),
          subtitle: const Text('Get reminded before matches start'),
          value: _preferences.matchRemindersEnabled,
          onChanged: (value) => _updatePreference(
            _preferences.copyWith(matchRemindersEnabled: value),
          ),
        ),
        if (_preferences.matchRemindersEnabled)
          ListTile(
            title: const Text('Default Reminder Time'),
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
          title: const Text('Favorite Team Matches'),
          subtitle: const Text('Get notified when your favorite teams play'),
          value: _preferences.favoriteTeamMatchesEnabled,
          onChanged: (value) => _updatePreference(
            _preferences.copyWith(favoriteTeamMatchesEnabled: value),
          ),
        ),
        if (_preferences.favoriteTeamMatchesEnabled)
          SwitchListTile(
            title: const Text('Day Before Notification'),
            subtitle: const Text('Remind me the day before my team plays'),
            value: _preferences.favoriteTeamMatchDayBefore,
            onChanged: (value) => _updatePreference(
              _preferences.copyWith(favoriteTeamMatchDayBefore: value),
            ),
          ),
      ],
    );
  }

  Widget _buildLiveMatchAlertsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(theme, 'Live Match Alerts', Icons.flash_on),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Get instant notifications during live matches',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('Goal Alerts'),
          subtitle: const Text('When a goal is scored'),
          value: _preferences.goalAlertsEnabled,
          onChanged: (value) => _updatePreference(
            _preferences.copyWith(goalAlertsEnabled: value),
          ),
          secondary: const Text('', style: TextStyle(fontSize: 24)),
        ),
        SwitchListTile(
          title: const Text('Match Start'),
          subtitle: const Text('When a match kicks off'),
          value: _preferences.matchStartAlertsEnabled,
          onChanged: (value) => _updatePreference(
            _preferences.copyWith(matchStartAlertsEnabled: value),
          ),
          secondary: const Text('', style: TextStyle(fontSize: 24)),
        ),
        SwitchListTile(
          title: const Text('Halftime'),
          subtitle: const Text('Halftime score updates'),
          value: _preferences.halftimeAlertsEnabled,
          onChanged: (value) => _updatePreference(
            _preferences.copyWith(halftimeAlertsEnabled: value),
          ),
        ),
        SwitchListTile(
          title: const Text('Match End'),
          subtitle: const Text('Final score notifications'),
          value: _preferences.matchEndAlertsEnabled,
          onChanged: (value) => _updatePreference(
            _preferences.copyWith(matchEndAlertsEnabled: value),
          ),
        ),
        SwitchListTile(
          title: const Text('Red Cards'),
          subtitle: const Text('Player sent off'),
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
          title: const Text('Penalties'),
          subtitle: const Text('Penalty kicks awarded'),
          value: _preferences.penaltyAlertsEnabled,
          onChanged: (value) => _updatePreference(
            _preferences.copyWith(penaltyAlertsEnabled: value),
          ),
        ),
      ],
    );
  }

  Widget _buildWatchPartySection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(theme, 'Watch Parties', Icons.groups),
        SwitchListTile(
          title: const Text('Watch Party Invites'),
          subtitle: const Text('When someone invites you to a watch party'),
          value: _preferences.watchPartyInvitesEnabled,
          onChanged: (value) => _updatePreference(
            _preferences.copyWith(watchPartyInvitesEnabled: value),
          ),
        ),
        SwitchListTile(
          title: const Text('Watch Party Reminders'),
          subtitle: const Text('Remind me before watch parties I joined'),
          value: _preferences.watchPartyRemindersEnabled,
          onChanged: (value) => _updatePreference(
            _preferences.copyWith(watchPartyRemindersEnabled: value),
          ),
        ),
        if (_preferences.watchPartyRemindersEnabled)
          ListTile(
            title: const Text('Reminder Time'),
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
          title: const Text('Watch Party Updates'),
          subtitle: const Text('Host messages and party changes'),
          value: _preferences.watchPartyUpdatesEnabled,
          onChanged: (value) => _updatePreference(
            _preferences.copyWith(watchPartyUpdatesEnabled: value),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(theme, 'Social', Icons.people),
        SwitchListTile(
          title: const Text('Friend Requests'),
          subtitle: const Text('When someone sends you a friend request'),
          value: _preferences.friendRequestsEnabled,
          onChanged: (value) => _updatePreference(
            _preferences.copyWith(friendRequestsEnabled: value),
          ),
        ),
        SwitchListTile(
          title: const Text('Messages'),
          subtitle: const Text('New direct and group messages'),
          value: _preferences.messagesEnabled,
          onChanged: (value) => _updatePreference(
            _preferences.copyWith(messagesEnabled: value),
          ),
        ),
        SwitchListTile(
          title: const Text('Mentions'),
          subtitle: const Text('When someone mentions you'),
          value: _preferences.mentionsEnabled,
          onChanged: (value) => _updatePreference(
            _preferences.copyWith(mentionsEnabled: value),
          ),
        ),
      ],
    );
  }

  Widget _buildPredictionsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(theme, 'Predictions & Leaderboard', Icons.emoji_events),
        SwitchListTile(
          title: const Text('Prediction Results'),
          subtitle: const Text('How your predictions performed'),
          value: _preferences.predictionResultsEnabled,
          onChanged: (value) => _updatePreference(
            _preferences.copyWith(predictionResultsEnabled: value),
          ),
        ),
        SwitchListTile(
          title: const Text('Leaderboard Updates'),
          subtitle: const Text('Your ranking changes'),
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
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Select Reminder Time',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const Divider(height: 1),
            ...ReminderTiming.values.map((timing) => ListTile(
                  title: Text(timing.displayName),
                  subtitle: Text('${timing.minutes} minutes before'),
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
      ),
    );
  }
}

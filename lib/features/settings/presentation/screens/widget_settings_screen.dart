import 'package:flutter/material.dart';

import '../../../../core/services/widget_service.dart';
import '../../../../l10n/app_localizations.dart';

/// Screen for configuring home screen widget settings
class WidgetSettingsScreen extends StatefulWidget {
  const WidgetSettingsScreen({super.key});

  @override
  State<WidgetSettingsScreen> createState() => _WidgetSettingsScreenState();
}

class _WidgetSettingsScreenState extends State<WidgetSettingsScreen> {
  late WidgetConfiguration _config;
  bool _isLoading = true;
  String? _selectedTeam;

  // Available teams for favorite selection
  static const List<Map<String, String>> _teams = [
    {'code': 'USA', 'name': 'United States', 'flag': '🇺🇸'},
    {'code': 'MEX', 'name': 'Mexico', 'flag': '🇲🇽'},
    {'code': 'CAN', 'name': 'Canada', 'flag': '🇨🇦'},
    {'code': 'BRA', 'name': 'Brazil', 'flag': '🇧🇷'},
    {'code': 'ARG', 'name': 'Argentina', 'flag': '🇦🇷'},
    {'code': 'ENG', 'name': 'England', 'flag': '🏴󠁧󠁢󠁥󠁮󠁧󠁿'},
    {'code': 'FRA', 'name': 'France', 'flag': '🇫🇷'},
    {'code': 'GER', 'name': 'Germany', 'flag': '🇩🇪'},
    {'code': 'ESP', 'name': 'Spain', 'flag': '🇪🇸'},
    {'code': 'POR', 'name': 'Portugal', 'flag': '🇵🇹'},
    {'code': 'ITA', 'name': 'Italy', 'flag': '🇮🇹'},
    {'code': 'NED', 'name': 'Netherlands', 'flag': '🇳🇱'},
    {'code': 'BEL', 'name': 'Belgium', 'flag': '🇧🇪'},
    {'code': 'JPN', 'name': 'Japan', 'flag': '🇯🇵'},
    {'code': 'KOR', 'name': 'South Korea', 'flag': '🇰🇷'},
  ];

  @override
  void initState() {
    super.initState();
    _loadConfiguration();
  }

  Future<void> _loadConfiguration() async {
    try {
      final service = WidgetService.instance;
      setState(() {
        _config = service.configuration;
        _selectedTeam = _config.favoriteTeamCode;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _config = const WidgetConfiguration();
        _isLoading = false;
      });
    }
  }

  Future<void> _saveConfiguration() async {
    try {
      final service = WidgetService.instance;
      await service.updateConfiguration(_config);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Widget settings saved'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save settings: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.widgetSettings)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.widgetSettings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Instructions card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.widgets_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.addWidgetToHomeScreen,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.widgetInstructions,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Display settings section
          Text(
            l10n.displaySettings,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(l10n.showLiveScores),
                  subtitle: Text(l10n.showLiveScoresDescription),
                  value: _config.showLiveScores,
                  onChanged: (value) {
                    setState(() {
                      _config = _config.copyWith(showLiveScores: value);
                    });
                    _saveConfiguration();
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: Text(l10n.showUpcomingMatches),
                  subtitle: Text(l10n.showUpcomingMatchesDescription),
                  value: _config.showUpcomingMatches,
                  onChanged: (value) {
                    setState(() {
                      _config = _config.copyWith(showUpcomingMatches: value);
                    });
                    _saveConfiguration();
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: Text(l10n.compactMode),
                  subtitle: Text(l10n.compactModeDescription),
                  value: _config.compactMode,
                  onChanged: (value) {
                    setState(() {
                      _config = _config.copyWith(compactMode: value);
                    });
                    _saveConfiguration();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Match count section
          Text(
            l10n.numberOfMatches,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.upcomingMatchesCount(_config.upcomingMatchCount),
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: _config.upcomingMatchCount.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: _config.upcomingMatchCount.toString(),
                    onChanged: (value) {
                      setState(() {
                        _config = _config.copyWith(
                          upcomingMatchCount: value.toInt(),
                        );
                      });
                    },
                    onChangeEnd: (_) => _saveConfiguration(),
                  ),
                  Text(
                    l10n.matchCountDescription,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Favorite team section
          Text(
            l10n.favoriteTeam,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Text(
                    _selectedTeam != null
                        ? _teams.firstWhere(
                            (t) => t['code'] == _selectedTeam,
                            orElse: () => {'flag': '🏳️'},
                          )['flag']!
                        : '🏳️',
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(
                    _selectedTeam != null
                        ? _teams.firstWhere(
                            (t) => t['code'] == _selectedTeam,
                            orElse: () => {'name': l10n.noTeamSelected},
                          )['name']!
                        : l10n.noTeamSelected,
                  ),
                  subtitle: Text(l10n.favoriteTeamDescription),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showTeamPicker(),
                ),
                if (_selectedTeam != null) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.clear, color: Colors.red),
                    title: Text(
                      l10n.clearFavoriteTeam,
                      style: const TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedTeam = null;
                        _config = _config.copyWith(favoriteTeamCode: null);
                      });
                      _saveConfiguration();
                    },
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Preview section
          Text(
            l10n.widgetPreview,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          _buildWidgetPreview(theme),

          const SizedBox(height: 24),

          // Refresh button
          FilledButton.icon(
            onPressed: _refreshWidget,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.refreshWidget),
          ),
        ],
      ),
    );
  }

  Widget _buildWidgetPreview(ThemeData theme) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primaryContainer,
              theme.colorScheme.secondaryContainer,
            ],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.sports_soccer,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'World Cup 2026',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (_config.showLiveScores) ...[
              _buildPreviewMatch(
                theme,
                '🇺🇸',
                'USA',
                '🇲🇽',
                'MEX',
                '2',
                '1',
                'LIVE',
                Colors.red,
              ),
              const SizedBox(height: 8),
            ],

            if (_config.showUpcomingMatches) ...[
              _buildPreviewMatch(
                theme,
                '🇧🇷',
                'BRA',
                '🇦🇷',
                'ARG',
                '-',
                '-',
                '6:00 PM',
                null,
              ),
              if (_config.upcomingMatchCount > 1) ...[
                const SizedBox(height: 8),
                _buildPreviewMatch(
                  theme,
                  '🇫🇷',
                  'FRA',
                  '🇩🇪',
                  'GER',
                  '-',
                  '-',
                  'Tomorrow',
                  null,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewMatch(
    ThemeData theme,
    String flag1,
    String code1,
    String flag2,
    String code2,
    String score1,
    String score2,
    String status,
    Color? statusColor,
  ) {
    final compact = _config.compactMode;

    return Container(
      padding: EdgeInsets.all(compact ? 8 : 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(flag1, style: TextStyle(fontSize: compact ? 16 : 20)),
          const SizedBox(width: 4),
          Text(
            code1,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: compact ? 12 : 14,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor?.withValues(alpha: 0.1) ??
                  theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$score1 - $score2',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: compact ? 12 : 14,
                color: statusColor,
              ),
            ),
          ),
          const Spacer(),
          Text(
            code2,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: compact ? 12 : 14,
            ),
          ),
          const SizedBox(width: 4),
          Text(flag2, style: TextStyle(fontSize: compact ? 16 : 20)),
        ],
      ),
    );
  }

  void _showTeamPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    AppLocalizations.of(context).selectFavoriteTeam,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: _teams.length,
                    itemBuilder: (context, index) {
                      final team = _teams[index];
                      final isSelected = team['code'] == _selectedTeam;

                      return ListTile(
                        leading: Text(
                          team['flag']!,
                          style: const TextStyle(fontSize: 24),
                        ),
                        title: Text(team['name']!),
                        subtitle: Text(team['code']!),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle,
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : null,
                        selected: isSelected,
                        onTap: () {
                          setState(() {
                            _selectedTeam = team['code'];
                            _config = _config.copyWith(
                              favoriteTeamCode: team['code'],
                            );
                          });
                          _saveConfiguration();
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _refreshWidget() async {
    try {
      final service = WidgetService.instance;
      await service.syncToWidgets();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Widget refreshed'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

/// Settings tile for quick access to widget settings
class WidgetSettingsTile extends StatelessWidget {
  const WidgetSettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListTile(
      leading: const Icon(Icons.widgets_outlined),
      title: Text(l10n.widgetSettings),
      subtitle: Text(l10n.widgetSettingsDescription),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const WidgetSettingsScreen(),
          ),
        );
      },
    );
  }
}

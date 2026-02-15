import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/worldcup/domain/entities/world_cup_match.dart';
import 'logging_service.dart';

/// Configuration for widget display
class WidgetConfiguration {
  final bool showLiveScores;
  final bool showUpcomingMatches;
  final int upcomingMatchCount;
  final String? favoriteTeamCode;
  final bool compactMode;

  const WidgetConfiguration({
    this.showLiveScores = true,
    this.showUpcomingMatches = true,
    this.upcomingMatchCount = 3,
    this.favoriteTeamCode,
    this.compactMode = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'showLiveScores': showLiveScores,
      'showUpcomingMatches': showUpcomingMatches,
      'upcomingMatchCount': upcomingMatchCount,
      'favoriteTeamCode': favoriteTeamCode,
      'compactMode': compactMode,
    };
  }

  factory WidgetConfiguration.fromMap(Map<String, dynamic> map) {
    return WidgetConfiguration(
      showLiveScores: map['showLiveScores'] as bool? ?? true,
      showUpcomingMatches: map['showUpcomingMatches'] as bool? ?? true,
      upcomingMatchCount: map['upcomingMatchCount'] as int? ?? 3,
      favoriteTeamCode: map['favoriteTeamCode'] as String?,
      compactMode: map['compactMode'] as bool? ?? false,
    );
  }

  WidgetConfiguration copyWith({
    bool? showLiveScores,
    bool? showUpcomingMatches,
    int? upcomingMatchCount,
    String? favoriteTeamCode,
    bool? compactMode,
  }) {
    return WidgetConfiguration(
      showLiveScores: showLiveScores ?? this.showLiveScores,
      showUpcomingMatches: showUpcomingMatches ?? this.showUpcomingMatches,
      upcomingMatchCount: upcomingMatchCount ?? this.upcomingMatchCount,
      favoriteTeamCode: favoriteTeamCode ?? this.favoriteTeamCode,
      compactMode: compactMode ?? this.compactMode,
    );
  }
}

/// Match data formatted for widget display
class WidgetMatchData {
  final String matchId;
  final String homeTeam;
  final String awayTeam;
  final String homeTeamCode;
  final String awayTeamCode;
  final String homeFlag;
  final String awayFlag;
  final int? homeScore;
  final int? awayScore;
  final DateTime matchTime;
  final String status; // 'upcoming', 'live', 'halftime', 'completed'
  final String venue;
  final String stage;

  const WidgetMatchData({
    required this.matchId,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeTeamCode,
    required this.awayTeamCode,
    required this.homeFlag,
    required this.awayFlag,
    this.homeScore,
    this.awayScore,
    required this.matchTime,
    required this.status,
    required this.venue,
    required this.stage,
  });

  Map<String, dynamic> toMap() {
    return {
      'matchId': matchId,
      'homeTeam': homeTeam,
      'awayTeam': awayTeam,
      'homeTeamCode': homeTeamCode,
      'awayTeamCode': awayTeamCode,
      'homeFlag': homeFlag,
      'awayFlag': awayFlag,
      'homeScore': homeScore,
      'awayScore': awayScore,
      'matchTime': matchTime.toIso8601String(),
      'status': status,
      'venue': venue,
      'stage': stage,
    };
  }

  factory WidgetMatchData.fromMap(Map<String, dynamic> map) {
    return WidgetMatchData(
      matchId: map['matchId'] as String,
      homeTeam: map['homeTeam'] as String,
      awayTeam: map['awayTeam'] as String,
      homeTeamCode: map['homeTeamCode'] as String,
      awayTeamCode: map['awayTeamCode'] as String,
      homeFlag: map['homeFlag'] as String,
      awayFlag: map['awayFlag'] as String,
      homeScore: map['homeScore'] as int?,
      awayScore: map['awayScore'] as int?,
      matchTime: DateTime.parse(map['matchTime'] as String),
      status: map['status'] as String,
      venue: map['venue'] as String,
      stage: map['stage'] as String,
    );
  }

  factory WidgetMatchData.fromWorldCupMatch(WorldCupMatch match) {
    String status = 'upcoming';
    if (match.status == MatchStatus.inProgress) {
      status = 'live';
    } else if (match.status == MatchStatus.halfTime) {
      status = 'halftime';
    } else if (match.status == MatchStatus.completed) {
      status = 'completed';
    } else if (match.status == MatchStatus.extraTime || match.status == MatchStatus.penalties) {
      status = 'live';
    }

    // Get flag emoji from team code
    String getFlag(String? code) {
      if (code == null) return '';
      // Common World Cup team flags
      const flags = {
        'USA': '🇺🇸', 'MEX': '🇲🇽', 'CAN': '🇨🇦',
        'BRA': '🇧🇷', 'ARG': '🇦🇷', 'COL': '🇨🇴', 'URU': '🇺🇾', 'ECU': '🇪🇨', 'CHI': '🇨🇱', 'PER': '🇵🇪', 'VEN': '🇻🇪', 'PAR': '🇵🇾', 'BOL': '🇧🇴',
        'ENG': '🏴󠁧󠁢󠁥󠁮󠁧󠁿', 'FRA': '🇫🇷', 'GER': '🇩🇪', 'ESP': '🇪🇸', 'ITA': '🇮🇹', 'POR': '🇵🇹', 'NED': '🇳🇱', 'BEL': '🇧🇪',
        'POL': '🇵🇱', 'UKR': '🇺🇦', 'DEN': '🇩🇰', 'SWE': '🇸🇪', 'NOR': '🇳🇴', 'SUI': '🇨🇭', 'AUT': '🇦🇹', 'CRO': '🇭🇷', 'SRB': '🇷🇸',
        'JPN': '🇯🇵', 'KOR': '🇰🇷', 'AUS': '🇦🇺', 'IRN': '🇮🇷', 'QAT': '🇶🇦', 'KSA': '🇸🇦', 'UAE': '🇦🇪',
        'MAR': '🇲🇦', 'SEN': '🇸🇳', 'NGA': '🇳🇬', 'CMR': '🇨🇲', 'GHA': '🇬🇭', 'CIV': '🇨🇮', 'TUN': '🇹🇳', 'EGY': '🇪🇬', 'ALG': '🇩🇿', 'RSA': '🇿🇦',
        'WAL': '🏴󠁧󠁢󠁷󠁬󠁳󠁿', 'SCO': '🏴󠁧󠁢󠁳󠁣󠁴󠁿', 'CZE': '🇨🇿', 'ROU': '🇷🇴', 'HUN': '🇭🇺', 'GRE': '🇬🇷', 'TUR': '🇹🇷', 'RUS': '🇷🇺',
        'CRC': '🇨🇷', 'HON': '🇭🇳', 'PAN': '🇵🇦', 'JAM': '🇯🇲',
        'CHN': '🇨🇳', 'IND': '🇮🇳', 'THA': '🇹🇭', 'VIE': '🇻🇳', 'IDN': '🇮🇩', 'IRQ': '🇮🇶',
        'NZL': '🇳🇿',
      };
      return flags[code] ?? '';
    }

    return WidgetMatchData(
      matchId: match.matchId,
      homeTeam: match.homeTeamName,
      awayTeam: match.awayTeamName,
      homeTeamCode: match.homeTeamCode ?? 'TBD',
      awayTeamCode: match.awayTeamCode ?? 'TBD',
      homeFlag: getFlag(match.homeTeamCode),
      awayFlag: getFlag(match.awayTeamCode),
      homeScore: match.homeScore,
      awayScore: match.awayScore,
      matchTime: match.dateTimeUtc ?? DateTime.now(),
      status: status,
      venue: match.venue?.name ?? 'TBD',
      stage: match.stage.displayName,
    );
  }
}

/// Service for managing home screen widgets
class WidgetService extends ChangeNotifier {
  static const String _logTag = 'WidgetService';
  static const String _configKey = 'widget_configuration';
  static const String _appGroupId = 'group.com.christophercampbell.pregameworldcup';
  static const String _androidWidgetName = 'WorldCupWidgetProvider';
  static const String _iOSWidgetName = 'WorldCupWidget';

  static WidgetService? _instance;

  final SharedPreferences _prefs;
  WidgetConfiguration _configuration = const WidgetConfiguration();
  List<WidgetMatchData> _upcomingMatches = [];
  List<WidgetMatchData> _liveMatches = [];
  Timer? _updateTimer;

  WidgetService._({required SharedPreferences prefs}) : _prefs = prefs {
    _loadConfiguration();
    _startPeriodicUpdates();
  }

  /// Get singleton instance
  static Future<WidgetService> getInstance() async {
    if (_instance == null) {
      final prefs = await SharedPreferences.getInstance();
      _instance = WidgetService._(prefs: prefs);
    }
    return _instance!;
  }

  /// Get instance synchronously (must call getInstance first)
  static WidgetService get instance {
    if (_instance == null) {
      throw StateError('WidgetService not initialized. Call getInstance() first.');
    }
    return _instance!;
  }

  /// Current configuration
  WidgetConfiguration get configuration => _configuration;

  /// Update configuration
  Future<void> updateConfiguration(WidgetConfiguration config) async {
    _configuration = config;
    await _saveConfiguration();
    await _syncToWidgets();
    notifyListeners();
  }

  /// Update matches for widget display
  Future<void> updateMatches({
    List<WorldCupMatch>? upcoming,
    List<WorldCupMatch>? live,
  }) async {
    if (upcoming != null) {
      _upcomingMatches = upcoming
          .take(_configuration.upcomingMatchCount)
          .map((m) => WidgetMatchData.fromWorldCupMatch(m))
          .toList();
    }

    if (live != null) {
      _liveMatches = live.map((m) => WidgetMatchData.fromWorldCupMatch(m)).toList();
    }

    await _syncToWidgets();
    LoggingService.debug(
      'Updated widget data: ${_upcomingMatches.length} upcoming, ${_liveMatches.length} live',
      tag: _logTag,
    );
  }

  /// Force sync data to native widgets
  Future<void> syncToWidgets() async {
    await _syncToWidgets();
  }

  /// Initialize home widget
  Future<void> initialize() async {
    try {
      // Set app group ID for iOS
      await HomeWidget.setAppGroupId(_appGroupId);

      // Register widget update callback
      HomeWidget.widgetClicked.listen(_handleWidgetClick);

      // Register for background updates
      await HomeWidget.registerInteractivityCallback(backgroundCallback);

      LoggingService.info('Widget service initialized', tag: _logTag);
    } catch (e) {
      LoggingService.error('Failed to initialize widget service: $e', tag: _logTag);
    }
  }

  /// Handle widget click interactions
  void _handleWidgetClick(Uri? uri) {
    if (uri == null) return;

    LoggingService.info('Widget clicked: $uri', tag: _logTag);

    // Parse the URI to determine what was clicked
    final action = uri.queryParameters['action'];
    final matchId = uri.queryParameters['matchId'];

    if (action == 'openMatch' && matchId != null) {
      // Notify listeners to navigate to match
      _onMatchClicked?.call(matchId);
    } else if (action == 'openApp') {
      // Just open the app
    }
  }

  Function(String matchId)? _onMatchClicked;

  /// Set callback for match clicks
  void setOnMatchClicked(Function(String matchId) callback) {
    _onMatchClicked = callback;
  }

  /// Sync all data to native widgets
  Future<void> _syncToWidgets() async {
    try {
      // Save configuration
      await HomeWidget.saveWidgetData('config', json.encode(_configuration.toMap()));

      // Save upcoming matches
      await HomeWidget.saveWidgetData(
        'upcomingMatches',
        json.encode(_upcomingMatches.map((m) => m.toMap()).toList()),
      );

      // Save live matches
      await HomeWidget.saveWidgetData(
        'liveMatches',
        json.encode(_liveMatches.map((m) => m.toMap()).toList()),
      );

      // Save last update time
      await HomeWidget.saveWidgetData(
        'lastUpdate',
        DateTime.now().toIso8601String(),
      );

      // Update iOS widget
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await HomeWidget.updateWidget(
          iOSName: _iOSWidgetName,
        );
      }

      // Update Android widget
      if (defaultTargetPlatform == TargetPlatform.android) {
        await HomeWidget.updateWidget(
          androidName: _androidWidgetName,
        );
      }

      LoggingService.debug('Widget data synced', tag: _logTag);
    } catch (e) {
      LoggingService.error('Failed to sync widget data: $e', tag: _logTag);
    }
  }

  /// Load configuration from storage
  void _loadConfiguration() {
    try {
      final configJson = _prefs.getString(_configKey);
      if (configJson != null) {
        _configuration = WidgetConfiguration.fromMap(
          json.decode(configJson) as Map<String, dynamic>,
        );
      }
    } catch (e) {
      LoggingService.error('Error loading widget config: $e', tag: _logTag);
    }
  }

  /// Save configuration to storage
  Future<void> _saveConfiguration() async {
    try {
      await _prefs.setString(_configKey, json.encode(_configuration.toMap()));
    } catch (e) {
      LoggingService.error('Error saving widget config: $e', tag: _logTag);
    }
  }

  /// Start periodic widget updates
  void _startPeriodicUpdates() {
    // Update widgets every 15 minutes
    _updateTimer = Timer.periodic(
      const Duration(minutes: 15),
      (_) => _syncToWidgets(),
    );
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
}

/// Background callback for widget interactivity
@pragma('vm:entry-point')
Future<void> backgroundCallback(Uri? uri) async {
  if (uri == null) return;

  final action = uri.queryParameters['action'];

  if (action == 'refresh') {
    // Refresh widget data in background
    try {
      // Get shared preferences and load cached match data
      await SharedPreferences.getInstance();
      // Debug output removed
      // The widget will be updated on next app launch or periodic refresh
    } catch (e) {
      // Debug output removed
    }
  }
}

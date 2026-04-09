import 'dart:async';
import 'dart:io';

import 'package:live_activities/live_activities.dart';
import 'package:live_activities/models/activity_update.dart';
import 'package:live_activities/models/url_scheme_data.dart';

import '../../features/worldcup/domain/entities/world_cup_match.dart';
import 'logging_service.dart';

/// Service for managing iOS Live Activities and Dynamic Island
/// for real-time World Cup match score tracking.
///
/// Live Activities appear on the Lock Screen and Dynamic Island,
/// providing at-a-glance match information without opening the app.
///
/// Falls back gracefully on Android and older iOS versions.
class LiveActivityService {
  static const String _logTag = 'LiveActivity';
  static const String _appGroupId =
      'group.com.christophercampbell.pregameworldcup';

  final LiveActivities _plugin;

  /// Map of matchId -> activityId for tracking active Live Activities
  final Map<String, String> _activeActivities = {};

  /// Stream subscriptions
  StreamSubscription<ActivityUpdate>? _activityUpdateSub;
  StreamSubscription<UrlSchemeData>? _urlSchemeSub;

  /// Callback when user taps a Live Activity to open a specific match
  void Function(String matchId)? onMatchTapped;

  /// Whether Live Activities are supported on this device
  bool _isSupported = false;
  bool get isSupported => _isSupported;

  /// Whether the service has been initialized
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Currently active match IDs
  Set<String> get activeMatchIds => _activeActivities.keys.toSet();

  LiveActivityService({LiveActivities? plugin})
      : _plugin = plugin ?? LiveActivities();

  /// Initialize the Live Activity service.
  /// Must be called before any other methods.
  Future<void> init() async {
    if (_isInitialized) return;

    // Live Activities are iOS-only, iOS 16.1+
    if (!Platform.isIOS) {
      LoggingService.debug(
        'Live Activities not supported on this platform',
        tag: _logTag,
      );
      return;
    }

    try {
      await _plugin.init(appGroupId: _appGroupId);

      // Check if activities are enabled by the user
      _isSupported = await _plugin.areActivitiesEnabled();
      if (!_isSupported) {
        LoggingService.info(
          'Live Activities disabled by user or unsupported device',
          tag: _logTag,
        );
        return;
      }

      // Listen for activity lifecycle events (push tokens, ended states)
      _activityUpdateSub =
          _plugin.activityUpdateStream.listen(_handleActivityUpdate);

      // Listen for deep links when user taps a Live Activity
      _urlSchemeSub =
          _plugin.urlSchemeStream().listen(_handleUrlScheme);

      _isInitialized = true;
      LoggingService.info('Live Activity service initialized', tag: _logTag);
    } catch (e) {
      LoggingService.error(
        'Failed to initialize Live Activity service: $e',
        tag: _logTag,
      );
    }
  }

  /// Start a Live Activity for a match.
  /// Returns the activity ID, or null if it couldn't be started.
  Future<String?> startMatchActivity(WorldCupMatch match) async {
    if (!_isInitialized || !_isSupported) return null;

    // Don't create duplicate activities for the same match
    if (_activeActivities.containsKey(match.matchId)) {
      LoggingService.debug(
        'Activity already exists for match ${match.matchId}',
        tag: _logTag,
      );
      return _activeActivities[match.matchId];
    }

    try {
      final data = _matchToActivityData(match);
      final activityId = await _plugin.createActivity(match.matchId, data);

      if (activityId != null) {
        _activeActivities[match.matchId] = activityId;
        LoggingService.info(
          'Started Live Activity for ${match.homeTeamCode} vs ${match.awayTeamCode}',
          tag: _logTag,
        );
      }

      return activityId;
    } catch (e) {
      LoggingService.error(
        'Failed to start Live Activity for match ${match.matchId}: $e',
        tag: _logTag,
      );
      return null;
    }
  }

  /// Update an existing Live Activity with new match data.
  Future<void> updateMatchActivity(WorldCupMatch match) async {
    if (!_isInitialized || !_isSupported) return;

    final activityId = _activeActivities[match.matchId];
    if (activityId == null) {
      LoggingService.debug(
        'No active Live Activity for match ${match.matchId}',
        tag: _logTag,
      );
      return;
    }

    try {
      final data = _matchToActivityData(match);
      await _plugin.updateActivity(activityId, data);

      LoggingService.debug(
        'Updated Live Activity: ${match.homeTeamCode} ${match.homeScore ?? 0} - ${match.awayScore ?? 0} ${match.awayTeamCode} (${match.minute ?? 0}\')',
        tag: _logTag,
      );
    } catch (e) {
      LoggingService.error(
        'Failed to update Live Activity for match ${match.matchId}: $e',
        tag: _logTag,
      );
    }
  }

  /// End a Live Activity for a match.
  Future<void> endMatchActivity(String matchId) async {
    if (!_isInitialized || !_isSupported) return;

    final activityId = _activeActivities.remove(matchId);
    if (activityId == null) return;

    try {
      await _plugin.endActivity(activityId);
      LoggingService.info(
        'Ended Live Activity for match $matchId',
        tag: _logTag,
      );
    } catch (e) {
      LoggingService.error(
        'Failed to end Live Activity for match $matchId: $e',
        tag: _logTag,
      );
    }
  }

  /// End all active Live Activities.
  Future<void> endAllActivities() async {
    if (!_isInitialized || !_isSupported) return;

    try {
      await _plugin.endAllActivities();
      _activeActivities.clear();
      LoggingService.info('Ended all Live Activities', tag: _logTag);
    } catch (e) {
      LoggingService.error(
        'Failed to end all Live Activities: $e',
        tag: _logTag,
      );
    }
  }

  /// Check if a match has an active Live Activity.
  bool hasActiveActivity(String matchId) {
    return _activeActivities.containsKey(matchId);
  }

  /// Convert a WorldCupMatch to the data map for the Live Activity.
  /// Keys must match what the SwiftUI widget extension reads.
  Map<String, dynamic> _matchToActivityData(WorldCupMatch match) {
    String matchStatus;
    switch (match.status) {
      case MatchStatus.inProgress:
        matchStatus = 'In Progress';
      case MatchStatus.halfTime:
        matchStatus = 'Half Time';
      case MatchStatus.extraTime:
        matchStatus = 'Extra Time';
      case MatchStatus.penalties:
        matchStatus = 'Penalties';
      case MatchStatus.completed:
        matchStatus = 'Full Time';
      case MatchStatus.postponed:
        matchStatus = 'Postponed';
      case MatchStatus.cancelled:
        matchStatus = 'Cancelled';
      default:
        matchStatus = 'Upcoming';
    }

    final matchMinute = match.minute != null ? "${match.minute}'" : '';

    return {
      'matchId': match.matchId,
      'homeTeam': match.homeTeamCode ?? 'TBD',
      'awayTeam': match.awayTeamCode ?? 'TBD',
      'homeTeamName': match.homeTeamName,
      'awayTeamName': match.awayTeamName,
      'homeScore': match.homeScore ?? 0,
      'awayScore': match.awayScore ?? 0,
      'matchMinute': matchMinute,
      'matchStatus': matchStatus,
      'homeFlag': _getFlag(match.homeTeamCode),
      'awayFlag': _getFlag(match.awayTeamCode),
      'venue': match.venue?.name ?? '',
      'stage': match.stage.displayName,
    };
  }

  /// Handle activity lifecycle updates (push tokens, state changes).
  void _handleActivityUpdate(ActivityUpdate event) {
    LoggingService.debug('Activity update: $event', tag: _logTag);
    event.mapOrNull(
      active: (active) {
        // Push token available — send to server for remote updates
        LoggingService.debug(
          'Activity ${active.activityId} token: ${active.activityToken}',
          tag: _logTag,
        );
      },
      ended: (ended) {
        // Remove from tracking when system ends the activity
        _activeActivities.removeWhere(
          (_, activityId) => activityId == ended.activityId,
        );
      },
    );
  }

  /// Handle URL scheme deep links from tapping a Live Activity.
  void _handleUrlScheme(UrlSchemeData schemeData) {
    // Extract matchId from query parameters
    String? matchId;
    for (final param in schemeData.queryParameters) {
      if (param.containsKey('matchId')) {
        matchId = param['matchId'];
        break;
      }
    }

    if (matchId != null && onMatchTapped != null) {
      LoggingService.info(
        'Live Activity tapped for match: $matchId',
        tag: _logTag,
      );
      onMatchTapped!(matchId);
    }
  }

  /// Get flag emoji for a team code.
  static String _getFlag(String? code) {
    if (code == null) return '';
    const flags = {
      'USA': '🇺🇸', 'MEX': '🇲🇽', 'CAN': '🇨🇦',
      'BRA': '🇧🇷', 'ARG': '🇦🇷', 'COL': '🇨🇴', 'URU': '🇺🇾',
      'ECU': '🇪🇨', 'CHI': '🇨🇱', 'PER': '🇵🇪', 'VEN': '🇻🇪',
      'PAR': '🇵🇾', 'BOL': '🇧🇴',
      'ENG': '🏴󠁧󠁢󠁥󠁮󠁧󠁿', 'FRA': '🇫🇷', 'GER': '🇩🇪', 'ESP': '🇪🇸',
      'POR': '🇵🇹', 'NED': '🇳🇱', 'BEL': '🇧🇪',
      'POL': '🇵🇱', 'UKR': '🇺🇦', 'SWE': '🇸🇪',
      'SUI': '🇨🇭', 'AUT': '🇦🇹', 'CRO': '🇭🇷', 'SRB': '🇷🇸',
      'JPN': '🇯🇵', 'KOR': '🇰🇷', 'AUS': '🇦🇺', 'IRN': '🇮🇷',
      'QAT': '🇶🇦', 'KSA': '🇸🇦', 'UZB': '🇺🇿',
      'MAR': '🇲🇦', 'SEN': '🇸🇳', 'NGA': '🇳🇬', 'CMR': '🇨🇲',
      'GHA': '🇬🇭', 'CIV': '🇨🇮', 'TUN': '🇹🇳', 'EGY': '🇪🇬',
      'ALG': '🇩🇿', 'RSA': '🇿🇦', 'COD': '🇨🇩', 'MLI': '🇲🇱',
      'WAL': '🏴󠁧󠁢󠁷󠁬󠁳󠁿', 'SCO': '🏴󠁧󠁢󠁳󠁣󠁴󠁿',
      'CZE': '🇨🇿', 'ROU': '🇷🇴', 'HUN': '🇭🇺', 'GRE': '🇬🇷',
      'TUR': '🇹🇷', 'BIH': '🇧🇦',
      'CRC': '🇨🇷', 'HON': '🇭🇳', 'PAN': '🇵🇦', 'JAM': '🇯🇲',
      'IRQ': '🇮🇶', 'NZL': '🇳🇿',
    };
    return flags[code] ?? '';
  }

  /// Dispose the service and clean up resources.
  Future<void> dispose() async {
    await _activityUpdateSub?.cancel();
    await _urlSchemeSub?.cancel();
    if (_isInitialized && _isSupported) {
      await _plugin.dispose();
    }
    _activeActivities.clear();
    _isInitialized = false;
  }
}

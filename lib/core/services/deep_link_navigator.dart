import 'package:flutter/material.dart';
import 'deep_link_service.dart';
import 'logging_service.dart';

/// Navigator helper for handling deep link routing
class DeepLinkNavigator {
  static final DeepLinkNavigator _instance = DeepLinkNavigator._();
  factory DeepLinkNavigator() => _instance;
  DeepLinkNavigator._();

  GlobalKey<NavigatorState>? _navigatorKey;
  bool _isReady = false;

  /// Set the navigator key for routing
  void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
    _isReady = true;

    // Check for pending deep links
    final deepLinkService = DeepLinkService();
    final pendingLink = deepLinkService.pendingDeepLink;
    if (pendingLink != null) {
      handleDeepLink(pendingLink);
      deepLinkService.clearPendingDeepLink();
    }
  }

  /// Get the navigator state
  NavigatorState? get navigator => _navigatorKey?.currentState;

  /// Check if navigator is ready
  bool get isReady => _isReady && navigator != null;

  /// Handle a deep link and navigate to the appropriate screen
  Future<void> handleDeepLink(DeepLinkData data) async {
    if (!isReady) {
      LoggingService.warning(
        'Navigator not ready, storing deep link for later: $data',
        tag: 'DeepLinkNavigator',
      );
      return;
    }

    LoggingService.info('Navigating for deep link: $data', tag: 'DeepLinkNavigator');

    try {
      switch (data.type) {
        case DeepLinkType.match:
          await _navigateToMatch(data.id, data.additionalParams);
          break;
        case DeepLinkType.team:
          await _navigateToTeam(data.id, data.additionalParams);
          break;
        case DeepLinkType.watchParty:
          await _navigateToWatchParty(data.id, data.additionalParams);
          break;
        case DeepLinkType.prediction:
          await _navigateToPrediction(data.id, data.additionalParams);
          break;
        case DeepLinkType.userProfile:
          await _navigateToProfile(data.id, data.additionalParams);
          break;
        case DeepLinkType.venue:
          await _navigateToVenue(data.id, data.additionalParams);
          break;
        case DeepLinkType.leaderboard:
          await _navigateToLeaderboard(data.additionalParams);
          break;
      }
    } catch (e) {
      LoggingService.error('Error navigating for deep link: $e', tag: 'DeepLinkNavigator');
    }
  }

  /// Navigate to a match detail screen
  Future<void> _navigateToMatch(String matchId, Map<String, String>? params) async {
    // Navigate to main app first, then to match detail
    navigator?.pushNamedAndRemoveUntil(
      '/home',
      (route) => false,
    );

    // Small delay to let the home screen load
    await Future.delayed(const Duration(milliseconds: 300));

    navigator?.pushNamed(
      '/match-detail',
      arguments: {'matchId': matchId, ...?params},
    );
  }

  /// Navigate to a team detail screen
  Future<void> _navigateToTeam(String teamId, Map<String, String>? params) async {
    navigator?.pushNamedAndRemoveUntil(
      '/home',
      (route) => false,
    );

    await Future.delayed(const Duration(milliseconds: 300));

    navigator?.pushNamed(
      '/team-detail',
      arguments: {'teamId': teamId, ...?params},
    );
  }

  /// Navigate to a watch party detail screen
  Future<void> _navigateToWatchParty(String partyId, Map<String, String>? params) async {
    navigator?.pushNamedAndRemoveUntil(
      '/home',
      (route) => false,
    );

    await Future.delayed(const Duration(milliseconds: 300));

    navigator?.pushNamed(
      '/watch-party-detail',
      arguments: {'partyId': partyId, ...?params},
    );
  }

  /// Navigate to a prediction detail screen
  Future<void> _navigateToPrediction(String predictionId, Map<String, String>? params) async {
    navigator?.pushNamedAndRemoveUntil(
      '/home',
      (route) => false,
    );

    await Future.delayed(const Duration(milliseconds: 300));

    navigator?.pushNamed(
      '/predictions',
      arguments: {'predictionId': predictionId, ...?params},
    );
  }

  /// Navigate to a user profile screen
  Future<void> _navigateToProfile(String usualId, Map<String, String>? params) async {
    navigator?.pushNamedAndRemoveUntil(
      '/home',
      (route) => false,
    );

    await Future.delayed(const Duration(milliseconds: 300));

    navigator?.pushNamed(
      '/profile',
      arguments: {'usualId': usualId, ...?params},
    );
  }

  /// Navigate to a venue detail screen
  Future<void> _navigateToVenue(String venueId, Map<String, String>? params) async {
    navigator?.pushNamedAndRemoveUntil(
      '/home',
      (route) => false,
    );

    await Future.delayed(const Duration(milliseconds: 300));

    navigator?.pushNamed(
      '/venue-detail',
      arguments: {'venueId': venueId, ...?params},
    );
  }

  /// Navigate to the leaderboard screen
  Future<void> _navigateToLeaderboard(Map<String, String>? params) async {
    navigator?.pushNamedAndRemoveUntil(
      '/home',
      (route) => false,
    );

    await Future.delayed(const Duration(milliseconds: 300));

    navigator?.pushNamed(
      '/leaderboard',
      arguments: params,
    );
  }
}

/// Extension to easily show the share menu from any widget
extension ShareExtension on BuildContext {
  /// Get the share position for iPad (centered on the widget)
  Rect get sharePositionOrigin {
    final box = findRenderObject() as RenderBox?;
    if (box == null) return Rect.zero;
    return box.localToGlobal(Offset.zero) & box.size;
  }
}

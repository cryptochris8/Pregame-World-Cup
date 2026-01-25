import 'dart:async';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:app_links/app_links.dart';
import 'logging_service.dart';
import 'analytics_service.dart';

// NOTE: Firebase Dynamic Links is deprecated and will shut down August 25, 2025.
// This service uses app_links for handling incoming links and direct URLs for sharing.
// For production, configure your web domain (pregameworldcup.com) to handle app links:
// - Android: Add assetlinks.json to /.well-known/
// - iOS: Add apple-app-site-association to /.well-known/

/// Types of content that can be shared via deep links
enum DeepLinkType {
  match,
  team,
  watchParty,
  prediction,
  userProfile,
  venue,
  leaderboard,
}

/// Parsed deep link data
class DeepLinkData {
  final DeepLinkType type;
  final String id;
  final Map<String, String>? additionalParams;
  final String? referrerId;
  final String? campaign;

  const DeepLinkData({
    required this.type,
    required this.id,
    this.additionalParams,
    this.referrerId,
    this.campaign,
  });

  @override
  String toString() => 'DeepLinkData(type: $type, id: $id, params: $additionalParams)';
}

/// Callback type for handling deep links
typedef DeepLinkHandler = void Function(DeepLinkData data);

/// Service for handling deep links and generating shareable links
class DeepLinkService {
  static DeepLinkService? _instance;

  final AppLinks _appLinks;
  final AnalyticsService _analyticsService;

  // Deep link configuration
  static const String _webDomain = 'pregameworldcup.com';

  // Path prefixes for different content types
  static const Map<DeepLinkType, String> _pathPrefixes = {
    DeepLinkType.match: '/match',
    DeepLinkType.team: '/team',
    DeepLinkType.watchParty: '/watch-party',
    DeepLinkType.prediction: '/prediction',
    DeepLinkType.userProfile: '/profile',
    DeepLinkType.venue: '/venue',
    DeepLinkType.leaderboard: '/leaderboard',
  };

  // Callbacks for handling deep links
  final List<DeepLinkHandler> _handlers = [];

  // Stream subscription for app links
  StreamSubscription<Uri>? _appLinksSubscription;

  bool _isInitialized = false;
  DeepLinkData? _pendingDeepLink;

  DeepLinkService._({
    AppLinks? appLinks,
    AnalyticsService? analyticsService,
  })  : _appLinks = appLinks ?? AppLinks(),
        _analyticsService = analyticsService ?? AnalyticsService();

  factory DeepLinkService({
    AppLinks? appLinks,
    AnalyticsService? analyticsService,
  }) {
    _instance ??= DeepLinkService._(
      appLinks: appLinks,
      analyticsService: analyticsService,
    );
    return _instance!;
  }

  /// Get pending deep link that was received before handlers were registered
  DeepLinkData? get pendingDeepLink => _pendingDeepLink;

  /// Clear the pending deep link after handling
  void clearPendingDeepLink() {
    _pendingDeepLink = null;
  }

  /// Initialize the deep link service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Handle app link that opened the app
      final initialAppLink = await _appLinks.getInitialLink();
      if (initialAppLink != null) {
        _handleAppLink(initialAppLink);
      }

      // Listen for app links while app is running
      _appLinksSubscription = _appLinks.uriLinkStream.listen(
        _handleAppLink,
        onError: (error) {
          LoggingService.error('App link error: $error', tag: 'DeepLinkService');
        },
      );

      _isInitialized = true;
      LoggingService.info('DeepLinkService initialized', tag: 'DeepLinkService');
    } catch (e) {
      LoggingService.error('Failed to initialize DeepLinkService: $e', tag: 'DeepLinkService');
    }
  }

  /// Dispose resources
  void dispose() {
    _appLinksSubscription?.cancel();
    _handlers.clear();
  }

  /// Register a handler for deep links
  void addHandler(DeepLinkHandler handler) {
    _handlers.add(handler);

    // If there's a pending deep link, handle it immediately
    if (_pendingDeepLink != null) {
      handler(_pendingDeepLink!);
    }
  }

  /// Remove a handler
  void removeHandler(DeepLinkHandler handler) {
    _handlers.remove(handler);
  }

  /// Handle app link
  void _handleAppLink(Uri uri) {
    LoggingService.info('Received app link: $uri', tag: 'DeepLinkService');

    final deepLinkData = _parseUri(uri);
    if (deepLinkData != null) {
      _notifyHandlers(deepLinkData);

      // Track in analytics
      _analyticsService.logEvent('app_link_opened', parameters: {
        'type': deepLinkData.type.name,
        'id': deepLinkData.id,
      });
    }
  }

  /// Parse URI into DeepLinkData
  DeepLinkData? _parseUri(Uri uri) {
    try {
      final path = uri.path;
      final queryParams = uri.queryParameters;

      // Determine content type from path
      DeepLinkType? type;
      String? id;

      for (final entry in _pathPrefixes.entries) {
        if (path.startsWith(entry.value)) {
          type = entry.key;
          // Extract ID from path (e.g., /match/123 -> 123)
          final remainingPath = path.substring(entry.value.length);
          if (remainingPath.startsWith('/')) {
            id = remainingPath.substring(1).split('/').first;
          }
          break;
        }
      }

      if (type == null || id == null || id.isEmpty) {
        LoggingService.warning('Could not parse deep link: $uri', tag: 'DeepLinkService');
        return null;
      }

      return DeepLinkData(
        type: type,
        id: id,
        additionalParams: queryParams.isNotEmpty ? queryParams : null,
        referrerId: queryParams['ref'],
        campaign: queryParams['utm_campaign'],
      );
    } catch (e) {
      LoggingService.error('Error parsing deep link: $e', tag: 'DeepLinkService');
      return null;
    }
  }

  /// Notify all handlers of a deep link
  void _notifyHandlers(DeepLinkData data) {
    if (_handlers.isEmpty) {
      // Store for later if no handlers registered yet
      _pendingDeepLink = data;
      LoggingService.debug('Storing pending deep link: $data', tag: 'DeepLinkService');
      return;
    }

    for (final handler in _handlers) {
      try {
        handler(data);
      } catch (e) {
        LoggingService.error('Error in deep link handler: $e', tag: 'DeepLinkService');
      }
    }
  }

  // ==================== LINK GENERATION ====================

  /// Generate a shareable link
  /// Uses direct URLs that will be handled by the website and app
  Future<String> generateLink({
    required DeepLinkType type,
    required String id,
    required String title,
    required String description,
    String? imageUrl,
    Map<String, String>? additionalParams,
    String? campaign,
  }) async {
    final pathPrefix = _pathPrefixes[type] ?? '/content';
    var linkPath = '$pathPrefix/$id';

    // Add query parameters for tracking
    final queryParams = <String, String>{};
    if (additionalParams != null) {
      queryParams.addAll(additionalParams);
    }
    if (campaign != null) {
      queryParams['utm_campaign'] = campaign;
      queryParams['utm_source'] = 'app_share';
      queryParams['utm_medium'] = 'social';
    }

    if (queryParams.isNotEmpty) {
      linkPath += '?${queryParams.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&')}';
    }

    final link = 'https://$_webDomain$linkPath';
    LoggingService.debug('Generated link: $link', tag: 'DeepLinkService');
    return link;
  }

  /// Copy a link to clipboard
  Future<void> copyLinkToClipboard(String link) async {
    await Clipboard.setData(ClipboardData(text: link));
    LoggingService.debug('Copied link to clipboard: $link', tag: 'DeepLinkService');
  }

  /// Generate a match share link
  Future<String> generateMatchLink({
    required String matchId,
    required String homeTeam,
    required String awayTeam,
    String? matchDate,
    String? imageUrl,
  }) async {
    return generateLink(
      type: DeepLinkType.match,
      id: matchId,
      title: '$homeTeam vs $awayTeam - World Cup 2026',
      description: matchDate != null
          ? 'Watch the match on $matchDate! Get predictions, stats, and find watch parties.'
          : 'Get match predictions, live scores, and find nearby watch parties!',
      imageUrl: imageUrl,
      campaign: 'match_share',
    );
  }

  /// Generate a watch party share link
  Future<String> generateWatchPartyLink({
    required String partyId,
    required String partyName,
    required String matchName,
    required String venueName,
    String? imageUrl,
  }) async {
    return generateLink(
      type: DeepLinkType.watchParty,
      id: partyId,
      title: 'Join $partyName!',
      description: 'Watch $matchName at $venueName. Join this watch party on Pregame!',
      imageUrl: imageUrl,
      campaign: 'watch_party_share',
    );
  }

  /// Generate a team share link
  Future<String> generateTeamLink({
    required String teamId,
    required String teamName,
    String? group,
    String? imageUrl,
  }) async {
    return generateLink(
      type: DeepLinkType.team,
      id: teamId,
      title: '$teamName - World Cup 2026',
      description: group != null
          ? 'Follow $teamName in Group $group! Get updates, predictions, and find watch parties.'
          : 'Follow $teamName at World Cup 2026! Get updates, predictions, and find watch parties.',
      imageUrl: imageUrl,
      campaign: 'team_share',
    );
  }

  /// Generate a prediction share link
  Future<String> generatePredictionLink({
    required String predictionId,
    required String matchName,
    required String predictedOutcome,
    String? userName,
  }) async {
    return generateLink(
      type: DeepLinkType.prediction,
      id: predictionId,
      title: userName != null
          ? "$userName's Prediction: $matchName"
          : 'My Prediction: $matchName',
      description: 'Prediction: $predictedOutcome. Make your own predictions on Pregame!',
      campaign: 'prediction_share',
    );
  }

  /// Generate a user profile share link
  Future<String> generateProfileLink({
    required String usualId,
    required String displayName,
    String? imageUrl,
  }) async {
    return generateLink(
      type: DeepLinkType.userProfile,
      id: usualId,
      title: '$displayName on Pregame',
      description: 'Connect with $displayName and follow their World Cup 2026 journey!',
      imageUrl: imageUrl,
      campaign: 'profile_share',
    );
  }

  // ==================== SHARING ====================

  /// Share content using the native share dialog
  Future<void> share({
    required String text,
    String? subject,
    Rect? sharePositionOrigin,
  }) async {
    try {
      await Share.share(
        text,
        subject: subject,
        sharePositionOrigin: sharePositionOrigin,
      );

      // Track share in analytics
      _analyticsService.logEvent('content_shared', parameters: {
        'method': 'native_share',
      });
    } catch (e) {
      LoggingService.error('Error sharing: $e', tag: 'DeepLinkService');
    }
  }

  /// Share content with a generated link
  Future<void> shareWithLink({
    required DeepLinkType type,
    required String id,
    required String title,
    required String description,
    String? imageUrl,
    String? customMessage,
    Rect? sharePositionOrigin,
  }) async {
    try {
      final link = await generateLink(
        type: type,
        id: id,
        title: title,
        description: description,
        imageUrl: imageUrl,
      );

      final message = customMessage ?? '$title\n\n$description\n\n$link';

      await Share.share(
        message,
        subject: title,
        sharePositionOrigin: sharePositionOrigin,
      );

      // Track share in analytics
      _analyticsService.logShare(
        contentType: type.name,
        itemId: id,
        method: 'dynamic_link',
      );
    } catch (e) {
      LoggingService.error('Error sharing with link: $e', tag: 'DeepLinkService');
    }
  }

  /// Share a match
  Future<void> shareMatch({
    required String matchId,
    required String homeTeam,
    required String awayTeam,
    String? matchDate,
    String? imageUrl,
    Rect? sharePositionOrigin,
  }) async {
    final link = await generateMatchLink(
      matchId: matchId,
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      matchDate: matchDate,
      imageUrl: imageUrl,
    );

    final message = '''
$homeTeam vs $awayTeam - World Cup 2026

${matchDate != null ? 'Match Date: $matchDate\n\n' : ''}Check out this match on Pregame! Get predictions, live scores, and find watch parties nearby.

$link
''';

    await Share.share(
      message,
      subject: '$homeTeam vs $awayTeam - World Cup 2026',
      sharePositionOrigin: sharePositionOrigin,
    );

    _analyticsService.logShare(
      contentType: 'match',
      itemId: matchId,
      method: 'native_share',
    );
  }

  /// Share a watch party
  Future<void> shareWatchParty({
    required String partyId,
    required String partyName,
    required String matchName,
    required String venueName,
    String? venueAddress,
    String? dateTime,
    String? imageUrl,
    Rect? sharePositionOrigin,
  }) async {
    final link = await generateWatchPartyLink(
      partyId: partyId,
      partyName: partyName,
      matchName: matchName,
      venueName: venueName,
      imageUrl: imageUrl,
    );

    final message = '''
Join my Watch Party!

$partyName
Match: $matchName
Venue: $venueName${venueAddress != null ? '\nAddress: $venueAddress' : ''}${dateTime != null ? '\nWhen: $dateTime' : ''}

Join on Pregame:
$link
''';

    await Share.share(
      message,
      subject: 'Join $partyName - World Cup 2026',
      sharePositionOrigin: sharePositionOrigin,
    );

    _analyticsService.logShare(
      contentType: 'watch_party',
      itemId: partyId,
      method: 'native_share',
    );
  }

  /// Share a team
  Future<void> shareTeam({
    required String teamId,
    required String teamName,
    String? group,
    String? imageUrl,
    Rect? sharePositionOrigin,
  }) async {
    final link = await generateTeamLink(
      teamId: teamId,
      teamName: teamName,
      group: group,
      imageUrl: imageUrl,
    );

    final message = '''
$teamName - World Cup 2026${group != null ? ' (Group $group)' : ''}

Follow $teamName on Pregame! Get match updates, predictions, and find watch parties.

$link
''';

    await Share.share(
      message,
      subject: '$teamName - World Cup 2026',
      sharePositionOrigin: sharePositionOrigin,
    );

    _analyticsService.logShare(
      contentType: 'team',
      itemId: teamId,
      method: 'native_share',
    );
  }
}

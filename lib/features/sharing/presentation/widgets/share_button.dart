import 'package:flutter/material.dart';

import '../../domain/entities/shareable_content.dart';
import '../../domain/services/social_sharing_service.dart';
import 'share_sheet.dart';

/// A button that opens the share sheet
class ShareButton extends StatelessWidget {
  final ShareableContent content;
  final Widget? child;
  final bool showLabel;
  final bool compact;
  final GlobalKey? captureKey; // For capturing widget as image

  const ShareButton({
    super.key,
    required this.content,
    this.child,
    this.showLabel = false,
    this.compact = false,
    this.captureKey,
  });

  /// Create a share button for a prediction
  factory ShareButton.prediction({
    Key? key,
    required String matchId,
    required String homeTeam,
    required String awayTeam,
    required int predictedHomeScore,
    required int predictedAwayScore,
    String? predictedWinner,
    int? confidence,
    String? userName,
    bool showLabel = false,
    GlobalKey? captureKey,
  }) {
    final content = ShareablePrediction(
      matchName: '$homeTeam vs $awayTeam',
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      predictedHomeScore: predictedHomeScore,
      predictedAwayScore: predictedAwayScore,
      predictedWinner: predictedWinner,
      confidenceLevel: confidence,
      userDisplayName: userName,
      deepLink: 'https://pregameworldcup.com/prediction/$matchId',
      utmParams: const {
        'utm_source': 'app',
        'utm_medium': 'share',
        'utm_campaign': 'prediction',
      },
    );

    return ShareButton(
      key: key,
      content: content,
      showLabel: showLabel,
      captureKey: captureKey,
    );
  }

  /// Create a share button for a match result
  factory ShareButton.matchResult({
    Key? key,
    required String matchId,
    required String homeTeam,
    required String awayTeam,
    required int homeScore,
    required int awayScore,
    String? stage,
    String? commentary,
    bool isLive = false,
    String? matchMinute,
    bool showLabel = false,
    GlobalKey? captureKey,
  }) {
    final content = ShareableMatchResult(
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      homeScore: homeScore,
      awayScore: awayScore,
      stage: stage,
      commentary: commentary,
      isLive: isLive,
      matchMinute: matchMinute,
      deepLink: 'https://pregameworldcup.com/match/$matchId',
      utmParams: {
        'utm_source': 'app',
        'utm_medium': 'share',
        'utm_campaign': isLive ? 'live_score' : 'match_result',
      },
    );

    return ShareButton(
      key: key,
      content: content,
      showLabel: showLabel,
      captureKey: captureKey,
    );
  }

  /// Create a share button for a watch party
  factory ShareButton.watchParty({
    Key? key,
    required String partyId,
    required String partyName,
    required String matchName,
    required DateTime partyTime,
    String? venueName,
    String? venueAddress,
    required int currentAttendees,
    required int maxAttendees,
    required String hostName,
    bool isPrivate = false,
    bool showLabel = false,
    GlobalKey? captureKey,
  }) {
    final content = ShareableWatchParty(
      partyName: partyName,
      matchName: matchName,
      partyTime: partyTime,
      venueName: venueName,
      venueAddress: venueAddress,
      currentAttendees: currentAttendees,
      maxAttendees: maxAttendees,
      hostName: hostName,
      isPrivate: isPrivate,
      deepLink: 'https://pregameworldcup.com/watchparty/$partyId',
      utmParams: const {
        'utm_source': 'app',
        'utm_medium': 'share',
        'utm_campaign': 'watch_party',
      },
    );

    return ShareButton(
      key: key,
      content: content,
      showLabel: showLabel,
      captureKey: captureKey,
    );
  }

  /// Create a share button for app invite/referral
  factory ShareButton.invite({
    Key? key,
    required String userId,
    required String userName,
    String? referralCode,
    bool showLabel = true,
  }) {
    final content = ShareableInvite(
      inviterName: userName,
      referralCode: referralCode,
      deepLink: 'https://pregameworldcup.com/invite',
      utmParams: {
        'utm_source': 'referral',
        'utm_medium': 'share',
        'utm_campaign': 'user_invite',
        'utm_content': userId,
      },
    );

    return ShareButton(
      key: key,
      content: content,
      showLabel: showLabel,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (child != null) {
      return GestureDetector(
        onTap: () => _showShareSheet(context),
        child: child,
      );
    }

    if (compact) {
      return IconButton(
        icon: const Icon(Icons.share),
        onPressed: () => _showShareSheet(context),
        tooltip: 'Share',
      );
    }

    if (showLabel) {
      return TextButton.icon(
        onPressed: () => _showShareSheet(context),
        icon: const Icon(Icons.share, size: 18),
        label: const Text('Share'),
      );
    }

    return IconButton(
      icon: const Icon(Icons.share),
      onPressed: () => _showShareSheet(context),
      tooltip: 'Share',
    );
  }

  void _showShareSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ShareSheet(
        content: content,
        captureKey: captureKey,
      ),
    );
  }
}

/// A compact inline share button
class InlineShareButton extends StatelessWidget {
  final ShareableContent content;
  final Color? iconColor;
  final double iconSize;

  const InlineShareButton({
    super.key,
    required this.content,
    this.iconColor,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.share, size: iconSize),
      color: iconColor,
      onPressed: () => _share(context),
      tooltip: 'Share',
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }

  Future<void> _share(BuildContext context) async {
    final service = SocialSharingService();
    final result = await service.share(content);

    if (!result.success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Failed to share'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

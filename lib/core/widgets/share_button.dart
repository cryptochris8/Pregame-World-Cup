import 'package:flutter/material.dart';
import '../services/deep_link_service.dart';
import '../services/deep_link_navigator.dart';

/// A button widget for sharing content
class ShareButton extends StatelessWidget {
  final DeepLinkType contentType;
  final String contentId;
  final String title;
  final String description;
  final String? imageUrl;
  final Map<String, String>? additionalParams;
  final Widget? child;
  final bool showLabel;
  final Color? iconColor;
  final double iconSize;
  final VoidCallback? onShareComplete;

  const ShareButton({
    super.key,
    required this.contentType,
    required this.contentId,
    required this.title,
    required this.description,
    this.imageUrl,
    this.additionalParams,
    this.child,
    this.showLabel = false,
    this.iconColor,
    this.iconSize = 24,
    this.onShareComplete,
  });

  /// Factory for sharing a match
  factory ShareButton.match({
    Key? key,
    required String matchId,
    required String homeTeam,
    required String awayTeam,
    String? matchDate,
    String? imageUrl,
    bool showLabel = false,
    Color? iconColor,
    VoidCallback? onShareComplete,
  }) {
    return ShareButton(
      key: key,
      contentType: DeepLinkType.match,
      contentId: matchId,
      title: '$homeTeam vs $awayTeam',
      description: matchDate != null
          ? 'World Cup 2026 match on $matchDate'
          : 'World Cup 2026 match',
      imageUrl: imageUrl,
      showLabel: showLabel,
      iconColor: iconColor,
      onShareComplete: onShareComplete,
    );
  }

  /// Factory for sharing a watch party
  factory ShareButton.watchParty({
    Key? key,
    required String partyId,
    required String partyName,
    required String matchName,
    required String venueName,
    String? imageUrl,
    bool showLabel = false,
    Color? iconColor,
    VoidCallback? onShareComplete,
  }) {
    return ShareButton(
      key: key,
      contentType: DeepLinkType.watchParty,
      contentId: partyId,
      title: partyName,
      description: 'Watch $matchName at $venueName',
      imageUrl: imageUrl,
      showLabel: showLabel,
      iconColor: iconColor,
      onShareComplete: onShareComplete,
    );
  }

  /// Factory for sharing a team
  factory ShareButton.team({
    Key? key,
    required String teamId,
    required String teamName,
    String? group,
    String? imageUrl,
    bool showLabel = false,
    Color? iconColor,
    VoidCallback? onShareComplete,
  }) {
    return ShareButton(
      key: key,
      contentType: DeepLinkType.team,
      contentId: teamId,
      title: teamName,
      description: group != null
          ? '$teamName - Group $group, World Cup 2026'
          : '$teamName - World Cup 2026',
      imageUrl: imageUrl,
      showLabel: showLabel,
      iconColor: iconColor,
      onShareComplete: onShareComplete,
    );
  }

  /// Factory for sharing a user profile
  factory ShareButton.profile({
    Key? key,
    required String usualId,
    required String displayName,
    String? imageUrl,
    bool showLabel = false,
    Color? iconColor,
    VoidCallback? onShareComplete,
  }) {
    return ShareButton(
      key: key,
      contentType: DeepLinkType.userProfile,
      contentId: usualId,
      title: displayName,
      description: 'Check out $displayName on Pregame World Cup',
      imageUrl: imageUrl,
      showLabel: showLabel,
      iconColor: iconColor,
      onShareComplete: onShareComplete,
    );
  }

  Future<void> _share(BuildContext context) async {
    final deepLinkService = DeepLinkService();

    await deepLinkService.shareWithLink(
      type: contentType,
      id: contentId,
      title: title,
      description: description,
      imageUrl: imageUrl,
      sharePositionOrigin: context.sharePositionOrigin,
    );

    onShareComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (child != null) {
      return GestureDetector(
        onTap: () => _share(context),
        child: child,
      );
    }

    if (showLabel) {
      return TextButton.icon(
        onPressed: () => _share(context),
        icon: Icon(
          Icons.share_outlined,
          size: iconSize,
          color: iconColor ?? Theme.of(context).primaryColor,
        ),
        label: Text(
          'Share',
          style: TextStyle(
            color: iconColor ?? Theme.of(context).primaryColor,
          ),
        ),
      );
    }

    return IconButton(
      onPressed: () => _share(context),
      icon: Icon(
        Icons.share_outlined,
        size: iconSize,
        color: iconColor ?? Theme.of(context).iconTheme.color,
      ),
      tooltip: 'Share',
    );
  }
}

/// A floating action button for sharing
class ShareFloatingButton extends StatelessWidget {
  final DeepLinkType contentType;
  final String contentId;
  final String title;
  final String description;
  final String? imageUrl;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? heroTag;

  const ShareFloatingButton({
    super.key,
    required this.contentType,
    required this.contentId,
    required this.title,
    required this.description,
    this.imageUrl,
    this.backgroundColor,
    this.foregroundColor,
    this.heroTag,
  });

  Future<void> _share(BuildContext context) async {
    final deepLinkService = DeepLinkService();

    await deepLinkService.shareWithLink(
      type: contentType,
      id: contentId,
      title: title,
      description: description,
      imageUrl: imageUrl,
      sharePositionOrigin: context.sharePositionOrigin,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: heroTag,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      onPressed: () => _share(context),
      child: const Icon(Icons.share),
    );
  }
}

/// A menu item for use in PopupMenuButton or DropdownMenu
class ShareMenuItem extends PopupMenuEntry<String> {
  final DeepLinkType contentType;
  final String contentId;
  final String title;
  final String description;
  final String? imageUrl;

  const ShareMenuItem({
    super.key,
    required this.contentType,
    required this.contentId,
    required this.title,
    required this.description,
    this.imageUrl,
  });

  @override
  double get height => 48;

  @override
  bool represents(String? value) => value == 'share';

  @override
  State<ShareMenuItem> createState() => _ShareMenuItemState();
}

class _ShareMenuItemState extends State<ShareMenuItem> {
  Future<void> _share() async {
    Navigator.of(context).pop('share');

    final deepLinkService = DeepLinkService();

    await deepLinkService.shareWithLink(
      type: widget.contentType,
      id: widget.contentId,
      title: widget.title,
      description: widget.description,
      imageUrl: widget.imageUrl,
      sharePositionOrigin: context.sharePositionOrigin,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.share_outlined,
        color: Theme.of(context).primaryColor,
      ),
      title: const Text('Share'),
      onTap: _share,
    );
  }
}

/// Bottom sheet with multiple share options
class ShareBottomSheet extends StatelessWidget {
  final String title;
  final String description;
  final String? link;
  final String? imageUrl;
  final VoidCallback? onCopyLink;
  final VoidCallback? onShareNative;
  final VoidCallback? onShareTwitter;
  final VoidCallback? onShareFacebook;
  final VoidCallback? onShareWhatsApp;

  const ShareBottomSheet({
    super.key,
    required this.title,
    required this.description,
    this.link,
    this.imageUrl,
    this.onCopyLink,
    this.onShareNative,
    this.onShareTwitter,
    this.onShareFacebook,
    this.onShareWhatsApp,
  });

  static Future<void> show({
    required BuildContext context,
    required DeepLinkType contentType,
    required String contentId,
    required String title,
    required String description,
    String? imageUrl,
  }) async {
    final deepLinkService = DeepLinkService();
    final link = await deepLinkService.generateLink(
      type: contentType,
      id: contentId,
      title: title,
      description: description,
      imageUrl: imageUrl,
    );

    if (context.mounted) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => ShareBottomSheet(
          title: title,
          description: description,
          link: link,
          imageUrl: imageUrl,
          onCopyLink: () {
            // Copy to clipboard implementation
            Navigator.pop(context);
          },
          onShareNative: () async {
            Navigator.pop(context);
            await deepLinkService.share(
              text: '$title\n\n$description\n\n$link',
              subject: title,
              sharePositionOrigin: context.sharePositionOrigin,
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(Icons.share_outlined),
                  const SizedBox(width: 12),
                  Text(
                    'Share',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Content preview
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Share options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ShareOption(
                    icon: Icons.copy,
                    label: 'Copy Link',
                    onTap: onCopyLink,
                  ),
                  _ShareOption(
                    icon: Icons.share,
                    label: 'Share',
                    onTap: onShareNative,
                  ),
                  _ShareOption(
                    icon: Icons.more_horiz,
                    label: 'More',
                    onTap: onShareNative,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ShareOption({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

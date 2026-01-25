import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../config/app_theme.dart';
import '../../domain/entities/shareable_content.dart';
import '../../domain/services/social_sharing_service.dart';

/// Bottom sheet for sharing content to various platforms
class ShareSheet extends StatefulWidget {
  final ShareableContent content;
  final GlobalKey? captureKey;

  const ShareSheet({
    super.key,
    required this.content,
    this.captureKey,
  });

  @override
  State<ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<ShareSheet> {
  final SocialSharingService _sharingService = SocialSharingService();
  bool _isLoading = false;
  String? _loadingPlatform;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              'Share',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),

            // Content preview
            _buildContentPreview(context),
            const SizedBox(height: 24),

            // Platform options
            Text(
              'Share to',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 12),

            // Platform grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPlatformButton(
                  context,
                  platform: SharePlatform.twitter,
                  onTap: () => _shareToTwitter(),
                ),
                _buildPlatformButton(
                  context,
                  platform: SharePlatform.facebook,
                  onTap: () => _shareToFacebook(),
                ),
                _buildPlatformButton(
                  context,
                  platform: SharePlatform.whatsapp,
                  onTap: () => _shareToWhatsApp(),
                ),
                _buildPlatformButton(
                  context,
                  platform: SharePlatform.instagram,
                  onTap: () => _shareToInstagram(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // More options
            Text(
              'More options',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 12),

            // Copy link button
            _buildOptionTile(
              context,
              icon: Icons.link,
              title: 'Copy Link',
              subtitle: 'Copy shareable link to clipboard',
              onTap: () => _copyLink(),
            ),

            // System share button
            _buildOptionTile(
              context,
              icon: Icons.share,
              title: 'More Apps',
              subtitle: 'Share using other apps',
              onTap: () => _systemShare(),
            ),

            // Share with image (if capture key is provided)
            if (widget.captureKey != null)
              _buildOptionTile(
                context,
                icon: Icons.image,
                title: 'Share as Image',
                subtitle: 'Create a shareable image',
                onTap: () => _shareAsImage(),
              ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildContentPreview(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Content type icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getContentTypeIcon(),
              color: AppTheme.primaryPurple,
            ),
          ),
          const SizedBox(width: 12),

          // Content details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.content.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  widget.content.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getContentTypeIcon() {
    switch (widget.content.type) {
      case ShareableContentType.prediction:
        return Icons.analytics;
      case ShareableContentType.matchResult:
        return Icons.sports_soccer;
      case ShareableContentType.watchParty:
        return Icons.groups;
      case ShareableContentType.bracket:
        return Icons.account_tree;
      case ShareableContentType.achievement:
        return Icons.emoji_events;
      case ShareableContentType.invite:
        return Icons.person_add;
    }
  }

  Widget _buildPlatformButton(
    BuildContext context, {
    required SharePlatform platform,
    required VoidCallback onTap,
  }) {
    final isLoading = _isLoading && _loadingPlatform == platform.name;

    return InkWell(
      onTap: _isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: platform.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: isLoading
                  ? Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: platform.color,
                        ),
                      ),
                    )
                  : Icon(
                      platform.icon,
                      color: platform.color,
                      size: 28,
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              platform.displayName,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.grey[700]),
      ),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      ),
      onTap: _isLoading ? null : onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Future<void> _shareToTwitter() async {
    await _executeShare('twitter', () async {
      return await _sharingService.shareToTwitter(widget.content);
    });
  }

  Future<void> _shareToFacebook() async {
    await _executeShare('facebook', () async {
      return await _sharingService.shareToFacebook(widget.content);
    });
  }

  Future<void> _shareToWhatsApp() async {
    await _executeShare('whatsapp', () async {
      return await _sharingService.shareToWhatsApp(widget.content);
    });
  }

  Future<void> _shareToInstagram() async {
    if (widget.captureKey == null) {
      _showError('Instagram Stories requires an image. Use "Share as Image" instead.');
      return;
    }

    await _executeShare('instagram', () async {
      final imageBytes = await _sharingService.captureWidgetAsImage(widget.captureKey!);
      if (imageBytes == null) {
        return ShareResult.failure('Failed to capture image');
      }
      return await _sharingService.shareToInstagramStories(widget.content, imageBytes);
    });
  }

  Future<void> _copyLink() async {
    await Clipboard.setData(ClipboardData(text: widget.content.shareUrl));
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Link copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _systemShare() async {
    await _executeShare('system', () async {
      return await _sharingService.share(widget.content);
    });
  }

  Future<void> _shareAsImage() async {
    if (widget.captureKey == null) {
      _showError('No content available to capture');
      return;
    }

    await _executeShare('image', () async {
      final imageBytes = await _sharingService.captureWidgetAsImage(widget.captureKey!);
      if (imageBytes == null) {
        return ShareResult.failure('Failed to capture image');
      }
      return await _sharingService.shareWithImage(widget.content, imageBytes);
    });
  }

  Future<void> _executeShare(String platform, Future<ShareResult> Function() shareAction) async {
    setState(() {
      _isLoading = true;
      _loadingPlatform = platform;
    });

    try {
      final result = await shareAction();

      if (mounted) {
        Navigator.pop(context);
        if (!result.success) {
          _showError(result.error ?? 'Failed to share');
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('An error occurred while sharing');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingPlatform = null;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}

/// Quick share button that shows a compact share menu
class QuickShareMenu extends StatelessWidget {
  final ShareableContent content;
  final Widget child;

  const QuickShareMenu({
    super.key,
    required this.content,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<SharePlatform>(
      onSelected: (platform) => _shareToPlatform(context, platform),
      itemBuilder: (context) => SharePlatform.values.map((platform) {
        return PopupMenuItem(
          value: platform,
          child: Row(
            children: [
              Icon(platform.icon, color: platform.color, size: 20),
              const SizedBox(width: 12),
              Text(platform.displayName),
            ],
          ),
        );
      }).toList(),
      child: child,
    );
  }

  Future<void> _shareToPlatform(BuildContext context, SharePlatform platform) async {
    final service = SocialSharingService();
    ShareResult result;

    switch (platform) {
      case SharePlatform.system:
        result = await service.share(content);
        break;
      case SharePlatform.twitter:
        result = await service.shareToTwitter(content);
        break;
      case SharePlatform.facebook:
        result = await service.shareToFacebook(content);
        break;
      case SharePlatform.whatsapp:
        result = await service.shareToWhatsApp(content);
        break;
      case SharePlatform.instagram:
        // Instagram requires an image, fallback to system share
        result = await service.share(content);
        break;
      case SharePlatform.clipboard:
        result = await service.copyLink(content);
        break;
    }

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

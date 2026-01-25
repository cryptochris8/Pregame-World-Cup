import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/services/logging_service.dart';
import '../../../../core/services/analytics_service.dart';
import '../entities/shareable_content.dart';

/// Service for sharing content to social media platforms
class SocialSharingService {
  static const String _logTag = 'SocialSharingService';
  static SocialSharingService? _instance;

  final AnalyticsService _analytics;

  SocialSharingService._({AnalyticsService? analytics})
      : _analytics = analytics ?? AnalyticsService();

  factory SocialSharingService({AnalyticsService? analytics}) {
    _instance ??= SocialSharingService._(analytics: analytics);
    return _instance!;
  }

  // ==================== GENERIC SHARING ====================

  /// Share content using system share sheet
  Future<ShareResult> share(ShareableContent content) async {
    try {
      final result = await Share.share(
        content.getShareText(),
        subject: content.title,
      );

      _trackShare(content, 'system_share', result.status);
      return ShareResult.success(platform: 'system');
    } catch (e) {
      LoggingService.error('Error sharing: $e', tag: _logTag);
      return ShareResult.failure(e.toString());
    }
  }

  /// Share content with an image
  Future<ShareResult> shareWithImage(
    ShareableContent content,
    Uint8List imageBytes,
  ) async {
    try {
      // Save image to temp file
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/share_${DateTime.now().millisecondsSinceEpoch}.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(imageBytes);

      final result = await Share.shareXFiles(
        [XFile(imagePath)],
        text: content.getShareText(),
        subject: content.title,
      );

      // Clean up temp file
      await imageFile.delete().catchError((_) => imageFile);

      _trackShare(content, 'system_share_image', result.status);
      return ShareResult.success(platform: 'system');
    } catch (e) {
      LoggingService.error('Error sharing with image: $e', tag: _logTag);
      return ShareResult.failure(e.toString());
    }
  }

  // ==================== TWITTER/X ====================

  /// Share to Twitter/X
  Future<ShareResult> shareToTwitter(ShareableContent content) async {
    try {
      final text = content.getShareText(includeUrl: false);
      final url = content.shareUrl;
      final hashtags = content.hashtags.join(',');

      final twitterUrl = Uri.https('twitter.com', '/intent/tweet', {
        'text': text,
        'url': url,
        'hashtags': hashtags,
      });

      if (await canLaunchUrl(twitterUrl)) {
        await launchUrl(twitterUrl, mode: LaunchMode.externalApplication);
        _trackShare(content, 'twitter', null);
        return ShareResult.success(platform: 'twitter');
      } else {
        // Fallback to system share
        return await share(content);
      }
    } catch (e) {
      LoggingService.error('Error sharing to Twitter: $e', tag: _logTag);
      return ShareResult.failure(e.toString());
    }
  }

  // ==================== FACEBOOK ====================

  /// Share to Facebook
  Future<ShareResult> shareToFacebook(ShareableContent content) async {
    try {
      final url = content.shareUrl;

      final facebookUrl = Uri.https('www.facebook.com', '/sharer/sharer.php', {
        'u': url,
        'quote': content.getShareText(includeUrl: false),
      });

      if (await canLaunchUrl(facebookUrl)) {
        await launchUrl(facebookUrl, mode: LaunchMode.externalApplication);
        _trackShare(content, 'facebook', null);
        return ShareResult.success(platform: 'facebook');
      } else {
        return await share(content);
      }
    } catch (e) {
      LoggingService.error('Error sharing to Facebook: $e', tag: _logTag);
      return ShareResult.failure(e.toString());
    }
  }

  // ==================== WHATSAPP ====================

  /// Share to WhatsApp
  Future<ShareResult> shareToWhatsApp(ShareableContent content) async {
    try {
      final text = Uri.encodeComponent(content.getShareText());

      final whatsappUrl = Uri.parse('whatsapp://send?text=$text');

      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl);
        _trackShare(content, 'whatsapp', null);
        return ShareResult.success(platform: 'whatsapp');
      } else {
        // Try web fallback
        final webUrl = Uri.https('wa.me', '/', {'text': content.getShareText()});
        if (await canLaunchUrl(webUrl)) {
          await launchUrl(webUrl, mode: LaunchMode.externalApplication);
          _trackShare(content, 'whatsapp_web', null);
          return ShareResult.success(platform: 'whatsapp');
        }
        return await share(content);
      }
    } catch (e) {
      LoggingService.error('Error sharing to WhatsApp: $e', tag: _logTag);
      return ShareResult.failure(e.toString());
    }
  }

  // ==================== INSTAGRAM ====================

  /// Share to Instagram Stories (requires image)
  Future<ShareResult> shareToInstagramStories(
    ShareableContent content,
    Uint8List imageBytes,
  ) async {
    try {
      // Save image to temp file
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/instagram_story_${DateTime.now().millisecondsSinceEpoch}.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(imageBytes);

      // Instagram Stories URL scheme
      final instagramUrl = Uri.parse(
        'instagram-stories://share?source_application=com.pregame.worldcup',
      );

      if (Platform.isIOS && await canLaunchUrl(instagramUrl)) {
        // iOS: Use Instagram URL scheme
        await launchUrl(instagramUrl);
        _trackShare(content, 'instagram_stories', null);
        return ShareResult.success(platform: 'instagram');
      } else {
        // Fallback: Share image with system share sheet
        final result = await Share.shareXFiles(
          [XFile(imagePath)],
          text: content.getShareText(),
        );

        await imageFile.delete().catchError((_) => imageFile);
        _trackShare(content, 'instagram_fallback', result.status);
        return ShareResult.success(platform: 'system');
      }
    } catch (e) {
      LoggingService.error('Error sharing to Instagram: $e', tag: _logTag);
      return ShareResult.failure(e.toString());
    }
  }

  // ==================== COPY LINK ====================

  /// Copy share link to clipboard
  Future<ShareResult> copyLink(ShareableContent content) async {
    try {
      await Share.share(content.shareUrl);
      _trackShare(content, 'copy_link', null);
      return ShareResult.success(platform: 'clipboard');
    } catch (e) {
      LoggingService.error('Error copying link: $e', tag: _logTag);
      return ShareResult.failure(e.toString());
    }
  }

  // ==================== IMAGE GENERATION ====================

  /// Capture a widget as an image for sharing
  Future<Uint8List?> captureWidgetAsImage(GlobalKey key) async {
    try {
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      return byteData?.buffer.asUint8List();
    } catch (e) {
      LoggingService.error('Error capturing widget: $e', tag: _logTag);
      return null;
    }
  }

  // ==================== REFERRAL TRACKING ====================

  /// Generate UTM parameters for tracking
  Map<String, String> generateUtmParams({
    required String source,
    required String medium,
    required String campaign,
    String? content,
    String? term,
  }) {
    return {
      'utm_source': source,
      'utm_medium': medium,
      'utm_campaign': campaign,
      if (content != null) 'utm_content': content,
      if (term != null) 'utm_term': term,
    };
  }

  /// Generate referral link with tracking
  String generateReferralLink({
    required String userId,
    String? referralCode,
    String baseUrl = 'https://pregameworldcup.com/invite',
  }) {
    final params = {
      'ref': userId,
      if (referralCode != null) 'code': referralCode,
      ...generateUtmParams(
        source: 'referral',
        medium: 'share',
        campaign: 'user_invite',
        content: userId,
      ),
    };

    final uri = Uri.parse(baseUrl).replace(queryParameters: params);
    return uri.toString();
  }

  // ==================== ANALYTICS ====================

  void _trackShare(
    ShareableContent content,
    String platform,
    ShareResultStatus? result,
  ) {
    _analytics.logEvent(
      'share_content',
      parameters: {
        'content_type': content.type.name,
        'platform': platform,
        'success': result?.name ?? 'unknown',
      },
    );
  }
}

/// Result of a share operation
class ShareResult {
  final bool success;
  final String? platform;
  final String? error;

  const ShareResult._({
    required this.success,
    this.platform,
    this.error,
  });

  factory ShareResult.success({required String platform}) => ShareResult._(
        success: true,
        platform: platform,
      );

  factory ShareResult.failure(String error) => ShareResult._(
        success: false,
        error: error,
      );
}

/// Available sharing platforms
enum SharePlatform {
  system,
  twitter,
  facebook,
  whatsapp,
  instagram,
  clipboard,
}

extension SharePlatformExtension on SharePlatform {
  String get displayName {
    switch (this) {
      case SharePlatform.system:
        return 'Share';
      case SharePlatform.twitter:
        return 'Twitter/X';
      case SharePlatform.facebook:
        return 'Facebook';
      case SharePlatform.whatsapp:
        return 'WhatsApp';
      case SharePlatform.instagram:
        return 'Instagram';
      case SharePlatform.clipboard:
        return 'Copy Link';
    }
  }

  IconData get icon {
    switch (this) {
      case SharePlatform.system:
        return Icons.share;
      case SharePlatform.twitter:
        return Icons.alternate_email; // X logo approximation
      case SharePlatform.facebook:
        return Icons.facebook;
      case SharePlatform.whatsapp:
        return Icons.chat;
      case SharePlatform.instagram:
        return Icons.camera_alt;
      case SharePlatform.clipboard:
        return Icons.link;
    }
  }

  Color get color {
    switch (this) {
      case SharePlatform.system:
        return Colors.grey;
      case SharePlatform.twitter:
        return const Color(0xFF1DA1F2);
      case SharePlatform.facebook:
        return const Color(0xFF4267B2);
      case SharePlatform.whatsapp:
        return const Color(0xFF25D366);
      case SharePlatform.instagram:
        return const Color(0xFFE4405F);
      case SharePlatform.clipboard:
        return Colors.orange;
    }
  }
}

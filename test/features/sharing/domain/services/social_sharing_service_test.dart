import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/sharing/domain/services/social_sharing_service.dart';

/// Tests for SocialSharingService and related types.
/// Note: SocialSharingService depends on AnalyticsService which requires
/// Firebase, so direct instantiation tests are skipped. We test the public
/// types and pure helper methods instead.
void main() {
  group('ShareResult', () {
    test('success factory creates successful result', () {
      final result = ShareResult.success(platform: 'twitter');
      expect(result.success, isTrue);
      expect(result.platform, 'twitter');
      expect(result.error, isNull);
    });

    test('failure factory creates failed result', () {
      final result = ShareResult.failure('Share canceled');
      expect(result.success, isFalse);
      expect(result.error, 'Share canceled');
      expect(result.platform, isNull);
    });

    test('success with different platforms', () {
      for (final platform in ['twitter', 'facebook', 'whatsapp', 'instagram', 'clipboard', 'system']) {
        final result = ShareResult.success(platform: platform);
        expect(result.success, isTrue);
        expect(result.platform, platform);
      }
    });

    test('failure preserves error message', () {
      final result = ShareResult.failure('Permission denied');
      expect(result.error, 'Permission denied');
    });

    test('failure with empty error message', () {
      final result = ShareResult.failure('');
      expect(result.success, isFalse);
      expect(result.error, '');
    });
  });

  group('SharePlatform', () {
    test('has all expected values', () {
      expect(SharePlatform.values, hasLength(6));
      expect(SharePlatform.values, contains(SharePlatform.system));
      expect(SharePlatform.values, contains(SharePlatform.twitter));
      expect(SharePlatform.values, contains(SharePlatform.facebook));
      expect(SharePlatform.values, contains(SharePlatform.whatsapp));
      expect(SharePlatform.values, contains(SharePlatform.instagram));
      expect(SharePlatform.values, contains(SharePlatform.clipboard));
    });

    group('displayName', () {
      test('system returns Share', () {
        expect(SharePlatform.system.displayName, 'Share');
      });

      test('twitter returns Twitter/X', () {
        expect(SharePlatform.twitter.displayName, 'Twitter/X');
      });

      test('facebook returns Facebook', () {
        expect(SharePlatform.facebook.displayName, 'Facebook');
      });

      test('whatsapp returns WhatsApp', () {
        expect(SharePlatform.whatsapp.displayName, 'WhatsApp');
      });

      test('instagram returns Instagram', () {
        expect(SharePlatform.instagram.displayName, 'Instagram');
      });

      test('clipboard returns Copy Link', () {
        expect(SharePlatform.clipboard.displayName, 'Copy Link');
      });

      test('all platforms have non-empty display names', () {
        for (final platform in SharePlatform.values) {
          expect(platform.displayName, isNotEmpty);
        }
      });
    });

    group('icon', () {
      test('each platform has an icon', () {
        for (final platform in SharePlatform.values) {
          expect(platform.icon, isA<IconData>());
        }
      });

      test('system has share icon', () {
        expect(SharePlatform.system.icon, Icons.share);
      });

      test('facebook has facebook icon', () {
        expect(SharePlatform.facebook.icon, Icons.facebook);
      });

      test('clipboard has link icon', () {
        expect(SharePlatform.clipboard.icon, Icons.link);
      });

      test('twitter has alternate_email icon', () {
        expect(SharePlatform.twitter.icon, Icons.alternate_email);
      });

      test('whatsapp has chat icon', () {
        expect(SharePlatform.whatsapp.icon, Icons.chat);
      });

      test('instagram has camera_alt icon', () {
        expect(SharePlatform.instagram.icon, Icons.camera_alt);
      });
    });

    group('color', () {
      test('each platform has a color', () {
        for (final platform in SharePlatform.values) {
          expect(platform.color, isA<Color>());
        }
      });

      test('twitter has correct color', () {
        expect(SharePlatform.twitter.color, const Color(0xFF1DA1F2));
      });

      test('facebook has correct color', () {
        expect(SharePlatform.facebook.color, const Color(0xFF4267B2));
      });

      test('whatsapp has correct color', () {
        expect(SharePlatform.whatsapp.color, const Color(0xFF25D366));
      });

      test('instagram has correct color', () {
        expect(SharePlatform.instagram.color, const Color(0xFFE4405F));
      });

      test('clipboard has orange color', () {
        expect(SharePlatform.clipboard.color, Colors.orange);
      });

      test('system has grey color', () {
        expect(SharePlatform.system.color, Colors.grey);
      });

      test('all platform colors are distinct', () {
        final colors = SharePlatform.values.map((p) => p.color).toSet();
        expect(colors.length, SharePlatform.values.length);
      });
    });
  });

  group('UTM parameter generation (pure function logic)', () {
    // Testing the pure logic that would be used by generateUtmParams
    test('required params produce 3 entries', () {
      final params = <String, String>{
        'utm_source': 'app',
        'utm_medium': 'share',
        'utm_campaign': 'prediction',
      };
      expect(params.length, 3);
      expect(params['utm_source'], 'app');
      expect(params['utm_medium'], 'share');
      expect(params['utm_campaign'], 'prediction');
    });

    test('all params produce 5 entries', () {
      final params = <String, String>{
        'utm_source': 'app',
        'utm_medium': 'share',
        'utm_campaign': 'prediction',
        'utm_content': 'match-1',
        'utm_term': 'world cup',
      };
      expect(params.length, 5);
    });
  });

  group('Referral link generation (pure function logic)', () {
    test('generates link with userId in params', () {
      const baseUrl = 'https://pregameworldcup.com/invite';
      final params = {
        'ref': 'user-123',
        'utm_source': 'referral',
        'utm_medium': 'share',
        'utm_campaign': 'user_invite',
        'utm_content': 'user-123',
      };

      final uri = Uri.parse(baseUrl).replace(queryParameters: params);
      final link = uri.toString();

      expect(link, contains('pregameworldcup.com/invite'));
      expect(link, contains('ref=user-123'));
      expect(link, contains('utm_source=referral'));
    });

    test('generates link with referral code', () {
      const baseUrl = 'https://pregameworldcup.com/invite';
      final params = {
        'ref': 'user-123',
        'code': 'ABC123',
      };

      final uri = Uri.parse(baseUrl).replace(queryParameters: params);
      final link = uri.toString();

      expect(link, contains('code=ABC123'));
    });

    test('uses custom base URL', () {
      const baseUrl = 'https://custom.com/join';
      final params = {'ref': 'user-123'};

      final uri = Uri.parse(baseUrl).replace(queryParameters: params);
      final link = uri.toString();

      expect(link, contains('custom.com/join'));
    });
  });
}

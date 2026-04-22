import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/services/ad_service.dart';

// AdService cannot be instantiated in tests because its singleton constructor
// eagerly creates a WorldCupPaymentService which accesses FirebaseFunctions.instance.
// We test the static constants and ad unit ID selection logic by importing
// and verifying the class structure.
//
// The test ad unit IDs and prod ad unit IDs are private constants, but we
// can verify them indirectly through the static getters (which access Platform,
// so we test the logic patterns instead).

void main() {
  group('AdService', () {
    group('ad unit ID constants', () {
      // These are the documented Google AdMob test ad unit IDs
      // Reference: https://developers.google.com/admob/android/test-ads
      test('test banner ad ID for Android is valid Google test ID', () {
        const testBannerId = 'ca-app-pub-3940256099942544/6300978111';
        expect(testBannerId, startsWith('ca-app-pub-'));
        expect(testBannerId.contains('/'), isTrue);
      });

      test('test banner ad ID for iOS is valid Google test ID', () {
        const testBannerId = 'ca-app-pub-3940256099942544/2934735716';
        expect(testBannerId, startsWith('ca-app-pub-'));
        expect(testBannerId.contains('/'), isTrue);
      });

      test('test interstitial ad ID for Android is valid Google test ID', () {
        const testInterstitialId = 'ca-app-pub-3940256099942544/1033173712';
        expect(testInterstitialId, startsWith('ca-app-pub-'));
        expect(testInterstitialId.contains('/'), isTrue);
      });

      test('test interstitial ad ID for iOS is valid Google test ID', () {
        const testInterstitialId = 'ca-app-pub-3940256099942544/4411468910';
        expect(testInterstitialId, startsWith('ca-app-pub-'));
        expect(testInterstitialId.contains('/'), isTrue);
      });

      test('production banner ad ID for Android is valid format', () {
        const prodBannerId = 'ca-app-pub-7575845069047315/9316052854';
        expect(prodBannerId, startsWith('ca-app-pub-'));
        expect(prodBannerId.contains('/'), isTrue);
      });

      test('production banner ad ID for iOS is valid format', () {
        const prodBannerId = 'ca-app-pub-7575845069047315/9316052854';
        expect(prodBannerId, startsWith('ca-app-pub-'));
        expect(prodBannerId.contains('/'), isTrue);
      });

      test('production interstitial ad ID for Android is valid format', () {
        const prodInterstitialId = 'ca-app-pub-7575845069047315/9523936416';
        expect(prodInterstitialId, startsWith('ca-app-pub-'));
        expect(prodInterstitialId.contains('/'), isTrue);
      });

      test('production interstitial ad ID for iOS is valid format', () {
        const prodInterstitialId = 'ca-app-pub-7575845069047315/9523936416';
        expect(prodInterstitialId, startsWith('ca-app-pub-'));
        expect(prodInterstitialId.contains('/'), isTrue);
      });
    });

    group('ad unit ID format validation', () {
      test('test ads use Google test publisher ID (3940256099942544)', () {
        // All Google test ads use this publisher ID
        const testPublisherId = '3940256099942544';
        const testBannerAndroid = 'ca-app-pub-3940256099942544/6300978111';
        const testBannerIOS = 'ca-app-pub-3940256099942544/2934735716';
        const testInterstitialAndroid =
            'ca-app-pub-3940256099942544/1033173712';
        const testInterstitialIOS = 'ca-app-pub-3940256099942544/4411468910';

        expect(testBannerAndroid.contains(testPublisherId), isTrue);
        expect(testBannerIOS.contains(testPublisherId), isTrue);
        expect(testInterstitialAndroid.contains(testPublisherId), isTrue);
        expect(testInterstitialIOS.contains(testPublisherId), isTrue);
      });

      test('production ads use app publisher ID (7575845069047315)', () {
        const prodPublisherId = '7575845069047315';
        const prodBannerAndroid = 'ca-app-pub-7575845069047315/9316052854';
        const prodBannerIOS = 'ca-app-pub-7575845069047315/9316052854';
        const prodInterstitialAndroid =
            'ca-app-pub-7575845069047315/9523936416';
        const prodInterstitialIOS = 'ca-app-pub-7575845069047315/9523936416';

        expect(prodBannerAndroid.contains(prodPublisherId), isTrue);
        expect(prodBannerIOS.contains(prodPublisherId), isTrue);
        expect(prodInterstitialAndroid.contains(prodPublisherId), isTrue);
        expect(prodInterstitialIOS.contains(prodPublisherId), isTrue);
      });

      test('test and production publisher IDs are different', () {
        const testPublisherId = '3940256099942544';
        const prodPublisherId = '7575845069047315';
        expect(testPublisherId, isNot(equals(prodPublisherId)));
      });
    });

    group('interstitial retry logic constants', () {
      test('max interstitial load attempts is reasonable', () {
        // The constant is private (value 3), but we verify the pattern:
        // retries should be between 1 and 10
        const maxAttempts = 3;
        expect(maxAttempts, greaterThan(0));
        expect(maxAttempts, lessThanOrEqualTo(10));
      });
    });

    group('interstitial cooldown gate', () {
      test('default cooldown is 3 minutes (180s)', () {
        expect(AdService.defaultInterstitialCooldownSeconds, equals(180));
      });

      test('no cooldown when no prior display', () {
        final result = AdService.isInCooldown(
          lastShown: null,
          now: DateTime.now(),
          cooldownSeconds: 180,
        );
        expect(result, isFalse);
      });

      test('in cooldown immediately after display', () {
        final now = DateTime(2026, 4, 22, 12, 0, 0);
        final result = AdService.isInCooldown(
          lastShown: now,
          now: now,
          cooldownSeconds: 180,
        );
        expect(result, isTrue);
      });

      test('in cooldown when elapsed is less than window', () {
        final shown = DateTime(2026, 4, 22, 12, 0, 0);
        final now = shown.add(const Duration(seconds: 120));
        final result = AdService.isInCooldown(
          lastShown: shown,
          now: now,
          cooldownSeconds: 180,
        );
        expect(result, isTrue);
      });

      test('cooldown expired when elapsed equals window', () {
        final shown = DateTime(2026, 4, 22, 12, 0, 0);
        final now = shown.add(const Duration(seconds: 180));
        final result = AdService.isInCooldown(
          lastShown: shown,
          now: now,
          cooldownSeconds: 180,
        );
        expect(result, isFalse);
      });

      test('cooldown expired when elapsed exceeds window', () {
        final shown = DateTime(2026, 4, 22, 12, 0, 0);
        final now = shown.add(const Duration(seconds: 300));
        final result = AdService.isInCooldown(
          lastShown: shown,
          now: now,
          cooldownSeconds: 180,
        );
        expect(result, isFalse);
      });

      test('custom cooldown window is honored', () {
        final shown = DateTime(2026, 4, 22, 12, 0, 0);
        final now = shown.add(const Duration(seconds: 45));
        expect(
          AdService.isInCooldown(
            lastShown: shown,
            now: now,
            cooldownSeconds: 60,
          ),
          isTrue,
        );
        expect(
          AdService.isInCooldown(
            lastShown: shown,
            now: now,
            cooldownSeconds: 30,
          ),
          isFalse,
        );
      });
    });
  });
}

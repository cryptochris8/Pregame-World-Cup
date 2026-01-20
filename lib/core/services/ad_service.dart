import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../features/worldcup/domain/services/world_cup_payment_service.dart';
import 'logging_service.dart';

/// Service for managing Google AdMob ads throughout the app
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  static const String _logTag = 'AdService';

  bool _isInitialized = false;
  final WorldCupPaymentService _paymentService = WorldCupPaymentService();

  // Test Ad Unit IDs (use these during development)
  static const String _testBannerAdUnitIdAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testBannerAdUnitIdIOS = 'ca-app-pub-3940256099942544/2934735716';
  static const String _testInterstitialAdUnitIdAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testInterstitialAdUnitIdIOS = 'ca-app-pub-3940256099942544/4411468910';

  // Production Ad Unit IDs (replace with your actual ad unit IDs from AdMob)
  // You'll need to create these in AdMob console
  static const String _prodBannerAdUnitIdAndroid = 'ca-app-pub-7575845069047315/XXXXXXXXXX'; // TODO: Replace
  static const String _prodBannerAdUnitIdIOS = 'ca-app-pub-7575845069047315/XXXXXXXXXX'; // TODO: Replace
  static const String _prodInterstitialAdUnitIdAndroid = 'ca-app-pub-7575845069047315/XXXXXXXXXX'; // TODO: Replace
  static const String _prodInterstitialAdUnitIdIOS = 'ca-app-pub-7575845069047315/XXXXXXXXXX'; // TODO: Replace

  // Use test ads in debug mode
  static bool get _useTestAds => kDebugMode;

  /// Get the appropriate banner ad unit ID
  static String get bannerAdUnitId {
    if (_useTestAds) {
      return Platform.isAndroid ? _testBannerAdUnitIdAndroid : _testBannerAdUnitIdIOS;
    }
    return Platform.isAndroid ? _prodBannerAdUnitIdAndroid : _prodBannerAdUnitIdIOS;
  }

  /// Get the appropriate interstitial ad unit ID
  static String get interstitialAdUnitId {
    if (_useTestAds) {
      return Platform.isAndroid ? _testInterstitialAdUnitIdAndroid : _testInterstitialAdUnitIdIOS;
    }
    return Platform.isAndroid ? _prodInterstitialAdUnitIdAndroid : _prodInterstitialAdUnitIdIOS;
  }

  /// Initialize the Mobile Ads SDK
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      LoggingService.info('AdMob SDK initialized', tag: _logTag);
    } catch (e) {
      LoggingService.error('Failed to initialize AdMob SDK: $e', tag: _logTag);
    }
  }

  /// Check if user should see ads (not a premium user)
  Future<bool> shouldShowAds() async {
    try {
      final status = await _paymentService.getCachedFanPassStatus();
      // Users with Fan Pass or Superfan Pass get ad-free experience
      return !status.hasAdFree;
    } catch (e) {
      LoggingService.error('Error checking ad-free status: $e', tag: _logTag);
      // Default to showing ads if we can't determine status
      return true;
    }
  }

  /// Load a banner ad
  Future<BannerAd?> loadBannerAd({
    AdSize size = AdSize.banner,
    Function(Ad)? onAdLoaded,
    Function(Ad, LoadAdError)? onAdFailedToLoad,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final shouldShow = await shouldShowAds();
    if (!shouldShow) {
      LoggingService.info('User has ad-free access, not loading banner ad', tag: _logTag);
      return null;
    }

    final bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          LoggingService.info('Banner ad loaded', tag: _logTag);
          onAdLoaded?.call(ad);
        },
        onAdFailedToLoad: (ad, error) {
          LoggingService.error('Banner ad failed to load: ${error.message}', tag: _logTag);
          ad.dispose();
          onAdFailedToLoad?.call(ad, error);
        },
        onAdOpened: (ad) => LoggingService.info('Banner ad opened', tag: _logTag),
        onAdClosed: (ad) => LoggingService.info('Banner ad closed', tag: _logTag),
      ),
    );

    await bannerAd.load();
    return bannerAd;
  }

  /// Cached interstitial ad
  InterstitialAd? _interstitialAd;
  int _interstitialLoadAttempts = 0;
  static const int _maxInterstitialLoadAttempts = 3;

  /// Load an interstitial ad
  Future<void> loadInterstitialAd() async {
    if (!_isInitialized) {
      await initialize();
    }

    final shouldShow = await shouldShowAds();
    if (!shouldShow) {
      LoggingService.info('User has ad-free access, not loading interstitial ad', tag: _logTag);
      return;
    }

    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          LoggingService.info('Interstitial ad loaded', tag: _logTag);
          _interstitialAd = ad;
          _interstitialLoadAttempts = 0;

          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              LoggingService.info('Interstitial ad dismissed', tag: _logTag);
              ad.dispose();
              _interstitialAd = null;
              loadInterstitialAd(); // Pre-load next ad
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              LoggingService.error('Interstitial ad failed to show: ${error.message}', tag: _logTag);
              ad.dispose();
              _interstitialAd = null;
            },
          );
        },
        onAdFailedToLoad: (error) {
          LoggingService.error('Interstitial ad failed to load: ${error.message}', tag: _logTag);
          _interstitialLoadAttempts++;
          _interstitialAd = null;

          if (_interstitialLoadAttempts < _maxInterstitialLoadAttempts) {
            Future.delayed(const Duration(seconds: 3), loadInterstitialAd);
          }
        },
      ),
    );
  }

  /// Show the interstitial ad if loaded
  Future<bool> showInterstitialAd() async {
    final shouldShow = await shouldShowAds();
    if (!shouldShow) {
      return false;
    }

    if (_interstitialAd != null) {
      await _interstitialAd!.show();
      return true;
    } else {
      LoggingService.info('Interstitial ad not ready', tag: _logTag);
      loadInterstitialAd(); // Try to load for next time
      return false;
    }
  }

  /// Dispose of all ads
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}

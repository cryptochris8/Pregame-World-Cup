import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';

/// A widget that displays a banner ad
/// Automatically handles loading, premium user checks, and error states
class BannerAdWidget extends StatefulWidget {
  final AdSize adSize;
  final EdgeInsets padding;

  const BannerAdWidget({
    super.key,
    this.adSize = AdSize.banner,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
  });

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  final AdService _adService = AdService();
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _shouldShowAd = true;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  Future<void> _loadAd() async {
    // First check if user should see ads
    _shouldShowAd = await _adService.shouldShowAds();

    if (!_shouldShowAd) {
      if (mounted) {
        setState(() {});
      }
      return;
    }

    _bannerAd = await _adService.loadBannerAd(
      size: widget.adSize,
      onAdLoaded: (ad) {
        if (mounted) {
          setState(() {
            _isLoaded = true;
          });
        }
      },
      onAdFailedToLoad: (ad, error) {
        if (mounted) {
          setState(() {
            _isLoaded = false;
            _bannerAd = null;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Don't show anything if user has ad-free access
    if (!_shouldShowAd) {
      return const SizedBox.shrink();
    }

    // Don't show anything if ad hasn't loaded
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: widget.padding,
      child: SizedBox(
        width: widget.adSize.width.toDouble(),
        height: widget.adSize.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }
}

/// A widget that shows a banner ad at the bottom of a screen
/// Wraps content and places ad at the bottom
class ScreenWithBannerAd extends StatelessWidget {
  final Widget child;
  final bool showAd;

  const ScreenWithBannerAd({
    super.key,
    required this.child,
    this.showAd = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!showAd) {
      return child;
    }

    return Column(
      children: [
        Expanded(child: child),
        const BannerAdWidget(),
      ],
    );
  }
}

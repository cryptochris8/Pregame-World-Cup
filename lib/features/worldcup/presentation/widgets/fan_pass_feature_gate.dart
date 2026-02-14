import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';
import '../../domain/services/world_cup_payment_service.dart';
import '../screens/fan_pass_screen.dart';

/// Features that require Fan Pass or Superfan Pass
enum FanPassFeature {
  aiMatchInsights('aiMatchInsights', 'AI Match Insights', FanPassType.superfanPass),
  advancedStats('advancedStats', 'Advanced Statistics', FanPassType.fanPass),
  customAlerts('customAlerts', 'Custom Alerts', FanPassType.fanPass),
  advancedSocialFeatures('advancedSocialFeatures', 'Advanced Social Features', FanPassType.fanPass),
  exclusiveContent('exclusiveContent', 'Exclusive Content', FanPassType.superfanPass),
  downloadableContent('downloadableContent', 'Downloadable Content', FanPassType.superfanPass),
  adFree('adFree', 'Ad-Free Experience', FanPassType.fanPass);

  final String key;
  final String displayName;
  final FanPassType requiredPass;

  const FanPassFeature(this.key, this.displayName, this.requiredPass);
}

/// Widget that gates premium features behind a Fan Pass check.
/// Shows the child widget if the user has the required pass, otherwise shows an upgrade prompt.
class FanPassFeatureGate extends StatefulWidget {
  final Widget child;
  final FanPassFeature feature;
  final Widget? lockedWidget;
  final bool showLockIcon;
  final bool showPreview;
  final String? customMessage;

  const FanPassFeatureGate({
    super.key,
    required this.child,
    required this.feature,
    this.lockedWidget,
    this.showLockIcon = true,
    this.showPreview = false,
    this.customMessage,
  });

  @override
  State<FanPassFeatureGate> createState() => _FanPassFeatureGateState();
}

class _FanPassFeatureGateState extends State<FanPassFeatureGate> {
  final WorldCupPaymentService _paymentService = WorldCupPaymentService();
  FanPassStatus? _status;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final status = await _paymentService.getCachedFanPassStatus();
    if (mounted) {
      setState(() {
        _status = status;
        _isLoading = false;
      });
    }
  }

  bool get _hasAccess {
    if (_status == null) return false;
    return _status!.features[widget.feature.key] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(color: AppTheme.primaryPurple),
        ),
      );
    }

    if (_hasAccess) {
      return widget.child;
    }

    return widget.lockedWidget ?? _buildDefaultLockedWidget(context);
  }

  Widget _buildDefaultLockedWidget(BuildContext context) {
    final requiredPassName = widget.feature.requiredPass.displayName;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryPurple.withOpacity(0.15),
            AppTheme.accentGold.withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.accentGold.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showLockIcon) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.accentGold.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline,
                size: 32,
                color: AppTheme.accentGold,
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            widget.feature.displayName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            widget.customMessage ??
                'Upgrade to $requiredPassName to unlock this feature',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          _buildUpgradeButton(context),
        ],
      ),
    );
  }

  Widget _buildUpgradeButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryOrange, AppTheme.accentGold],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryOrange.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToFanPass(context),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Upgrade to ${widget.feature.requiredPass.displayName}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToFanPass(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const FanPassScreen(),
      ),
    );
  }
}

/// A banner variant for showing at the top of screens with premium content
class FanPassUpgradeBanner extends StatefulWidget {
  final FanPassFeature feature;
  final VoidCallback? onDismiss;
  final String? customMessage;

  const FanPassUpgradeBanner({
    super.key,
    required this.feature,
    this.onDismiss,
    this.customMessage,
  });

  @override
  State<FanPassUpgradeBanner> createState() => _FanPassUpgradeBannerState();
}

class _FanPassUpgradeBannerState extends State<FanPassUpgradeBanner> {
  final WorldCupPaymentService _paymentService = WorldCupPaymentService();
  FanPassStatus? _status;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final status = await _paymentService.getCachedFanPassStatus();
    if (mounted) {
      setState(() {
        _status = status;
        _isLoading = false;
      });
    }
  }

  bool get _hasAccess {
    if (_status == null) return false;
    return _status!.features[widget.feature.key] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // Don't show if loading or user has access
    if (_isLoading || _hasAccess) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppTheme.primaryOrange,
            AppTheme.accentGold,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryOrange.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Unlock ${widget.feature.displayName}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              if (widget.onDismiss != null)
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.white.withOpacity(0.7),
                    size: 20,
                  ),
                  onPressed: widget.onDismiss,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.customMessage ??
                'Get ${widget.feature.requiredPass.displayName} for full access to ${widget.feature.displayName.toLowerCase()}.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const FanPassScreen()),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryOrange,
            ),
            child: const Text('View Plans'),
          ),
        ],
      ),
    );
  }
}

/// A card variant showing premium feature preview with lock overlay
class FanPassLockedCard extends StatelessWidget {
  final Widget child;
  final FanPassFeature feature;
  final bool showBlur;

  const FanPassLockedCard({
    super.key,
    required this.child,
    required this.feature,
    this.showBlur = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Preview content (blurred or dimmed)
        if (showBlur)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.5),
                BlendMode.darken,
              ),
              child: child,
            ),
          )
        else
          child,

        // Lock overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.accentGold.withOpacity(0.5),
                    ),
                  ),
                  child: const Icon(
                    Icons.lock,
                    color: AppTheme.accentGold,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    feature.requiredPass.displayName.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const FanPassScreen()),
                  ),
                  child: const Text(
                    'Tap to Upgrade',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

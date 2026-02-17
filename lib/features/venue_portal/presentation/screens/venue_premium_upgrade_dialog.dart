import 'dart:async';

import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

import '../../../worldcup/domain/services/world_cup_payment_service.dart';
import '../../../../core/services/logging_service.dart';

/// Dialog for upgrading to Venue Premium
class VenuePremiumUpgradeDialog extends StatefulWidget {
  final String venueId;
  final String venueName;
  final VoidCallback? onPurchaseComplete;

  const VenuePremiumUpgradeDialog({
    super.key,
    required this.venueId,
    required this.venueName,
    this.onPurchaseComplete,
  });

  @override
  State<VenuePremiumUpgradeDialog> createState() =>
      _VenuePremiumUpgradeDialogState();
}

class _VenuePremiumUpgradeDialogState
    extends State<VenuePremiumUpgradeDialog> {
  static const String _logTag = 'VenuePremiumUpgrade';

  final WorldCupPaymentService _paymentService = WorldCupPaymentService();
  bool _isPurchasing = false;
  bool _isWaitingForActivation = false;
  WorldCupPricing? _pricing;

  /// Real-time listener for venue premium activation after browser checkout.
  StreamSubscription<VenuePremiumStatus>? _premiumStatusSubscription;

  /// Timeout timer: cancels the listener after 5 minutes.
  Timer? _listenerTimeoutTimer;

  @override
  void initState() {
    super.initState();
    _loadPricing();
  }

  @override
  void dispose() {
    _stopListeningForPremiumActivation();
    super.dispose();
  }

  Future<void> _loadPricing() async {
    final pricing = await _paymentService.getPricing();
    if (mounted) {
      setState(() => _pricing = pricing);
    }
  }

  Future<void> _startPurchase() async {
    setState(() => _isPurchasing = true);

    try {
      final success = await _paymentService.openVenuePremiumCheckout(
        venueId: widget.venueId,
        venueName: widget.venueName,
        context: context,
      );

      if (success && mounted) {
        _startListeningForPremiumActivation();

        setState(() {
          _isPurchasing = false;
          _isWaitingForActivation = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).completePremiumPurchaseInBrowser,
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted && !_isWaitingForActivation) {
        setState(() => _isPurchasing = false);
      }
    }
  }

  /// Start listening for real-time venue premium activation from Firestore.
  void _startListeningForPremiumActivation() {
    _stopListeningForPremiumActivation();

    LoggingService.info(
      'Starting real-time listener for venue premium activation: ${widget.venueId}',
      tag: _logTag,
    );

    _premiumStatusSubscription = _paymentService
        .listenToVenuePremiumStatus(widget.venueId)
        .listen((status) {
      if (!mounted) return;

      if (status.isPremium) {
        LoggingService.info(
          'Venue premium activated via real-time listener: ${widget.venueId}',
          tag: _logTag,
        );

        _stopListeningForPremiumActivation();

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).venuePremiumActivatedSuccessfully),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );

        widget.onPurchaseComplete?.call();
      }
    }, onError: (error) {
      LoggingService.error(
        'Error in venue premium status listener: $error',
        tag: _logTag,
      );
    });

    _listenerTimeoutTimer = Timer(const Duration(minutes: 5), () {
      LoggingService.info(
        'Venue premium listener timed out after 5 minutes',
        tag: _logTag,
      );
      _stopListeningForPremiumActivation();
      if (mounted) {
        setState(() => _isWaitingForActivation = false);
        Navigator.pop(context);
        widget.onPurchaseComplete?.call();
      }
    });
  }

  void _stopListeningForPremiumActivation() {
    _premiumStatusSubscription?.cancel();
    _premiumStatusSubscription = null;
    _listenerTimeoutTimer?.cancel();
    _listenerTimeoutTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final price = _pricing?.venuePremium.displayPrice ?? '\$99.00';

    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.star, color: Colors.amber),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(l10n.upgradeToPremium),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Price
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.tertiary,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    price,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    l10n.oneTimePaymentForWorldCup,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text(
              l10n.premiumFeaturesInclude,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _FeatureListItem(text: l10n.specificMatchScheduling),
            _FeatureListItem(text: l10n.tvScreenConfiguration),
            _FeatureListItem(text: l10n.gameDaySpecialsDeals),
            _FeatureListItem(text: l10n.atmosphereVibeSettings),
            _FeatureListItem(text: l10n.realTimeCapacityUpdates),
            _FeatureListItem(text: l10n.priorityListingInSearches),
            _FeatureListItem(text: l10n.analyticsDashboard),

            const SizedBox(height: 16),

            // Tournament info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.validForEntireTournament,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (_isWaitingForActivation) ...[
          TextButton(
            onPressed: () {
              _stopListeningForPremiumActivation();
              Navigator.pop(context);
              widget.onPurchaseComplete?.call();
            },
            child: Text(l10n.close),
          ),
          FilledButton.icon(
            onPressed: null,
            icon: const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            label: Text(l10n.waitingForActivation),
          ),
        ] else ...[
          TextButton(
            onPressed: _isPurchasing ? null : () => Navigator.pop(context),
            child: Text(l10n.notNow),
          ),
          FilledButton.icon(
            onPressed: _isPurchasing ? null : _startPurchase,
            icon: _isPurchasing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.shopping_cart, size: 18),
            label: Text(_isPurchasing ? l10n.processing : l10n.upgradeNow),
          ),
        ],
      ],
    );
  }
}

class _FeatureListItem extends StatelessWidget {
  final String text;

  const _FeatureListItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';

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
          const SnackBar(
            content: Text(
              'Complete your purchase in the browser. Your premium will activate automatically.',
            ),
            duration: Duration(seconds: 5),
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
          const SnackBar(
            content: Text('Venue Premium activated successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
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
          const Expanded(
            child: Text('Upgrade to Premium'),
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
                    'One-time payment for World Cup 2026',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Premium features include:',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const _FeatureListItem(text: 'Specific match scheduling'),
            const _FeatureListItem(text: 'TV & screen configuration'),
            const _FeatureListItem(text: 'Game day specials & deals'),
            const _FeatureListItem(text: 'Atmosphere & vibe settings'),
            const _FeatureListItem(text: 'Real-time capacity updates'),
            const _FeatureListItem(text: 'Priority listing in searches'),
            const _FeatureListItem(text: 'Analytics dashboard'),

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
                      'Valid for the entire tournament (June 11 - July 19, 2026)',
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
            child: const Text('Close'),
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
            label: const Text('Waiting for activation...'),
          ),
        ] else ...[
          TextButton(
            onPressed: _isPurchasing ? null : () => Navigator.pop(context),
            child: const Text('Not Now'),
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
            label: Text(_isPurchasing ? 'Processing...' : 'Upgrade Now'),
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

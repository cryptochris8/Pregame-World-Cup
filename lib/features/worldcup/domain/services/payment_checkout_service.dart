import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/services/logging_service.dart';
import '../../../../services/revenuecat_service.dart';
import 'payment_models.dart';

/// Handles checkout flows for fan passes (native IAP + Stripe fallback)
/// and venue premium (Stripe only).
///
/// Extracted from [WorldCupPaymentService] to keep the facade lean.
class PaymentCheckoutService {
  static const String _logTag = 'WorldCupPayment';

  final FirebaseFunctions _functions;
  final RevenueCatService _revenueCatService;

  // Browser checkout tracking
  bool _browserCheckoutInProgress = false;
  bool get isBrowserCheckoutInProgress => _browserCheckoutInProgress;
  void markBrowserCheckoutComplete() {
    _browserCheckoutInProgress = false;
  }

  /// Callback invoked after a successful purchase so the facade can clear
  /// its own caches.
  final VoidCallback? onCacheClear;

  PaymentCheckoutService({
    required FirebaseFunctions functions,
    required RevenueCatService revenueCatService,
    this.onCacheClear,
  })  : _functions = functions,
        _revenueCatService = revenueCatService;

  // ---------------------------------------------------------------------------
  // Fan pass checkout (Stripe browser)
  // ---------------------------------------------------------------------------

  Future<String?> createFanPassCheckout({
    required FanPassType passType,
    String? successUrl,
    String? cancelUrl,
    bool returnToApp = false,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Must be logged in to purchase');
      }

      final callable = _functions.httpsCallable('createFanPassCheckout');
      final result = await callable.call({
        'passType': passType.value,
        'successUrl': successUrl,
        'cancelUrl': cancelUrl,
        'returnToApp': returnToApp,
      });

      final data = result.data as Map<String, dynamic>;
      return data['url'] as String?;
    } catch (e) {
      LoggingService.error('Error creating fan pass checkout: $e', tag: _logTag);
      rethrow;
    }
  }

  Future<bool> openFanPassCheckout({
    required FanPassType passType,
    required BuildContext context,
  }) async {
    try {
      final url = await createFanPassCheckout(
        passType: passType,
        returnToApp: true,
      );

      if (url == null) {
        if (context.mounted) {
          _showErrorDialog(context, 'Failed to create checkout session');
        }
        return false;
      }

      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        _browserCheckoutInProgress = true;
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      } else {
        if (context.mounted) {
          _showErrorDialog(context, 'Could not open checkout page');
        }
        return false;
      }
    } catch (e) {
      LoggingService.error('Error opening checkout: $e', tag: _logTag);
      if (context.mounted) {
        _showErrorDialog(context, 'Failed to start checkout: ${e.toString()}');
      }
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Native IAP purchase (RevenueCat)
  // ---------------------------------------------------------------------------

  Future<FanPassPurchaseResult> purchaseFanPass({
    required FanPassType passType,
    required BuildContext context,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return FanPassPurchaseResult(
        success: false,
        errorMessage: 'Please sign in to purchase',
      );
    }

    if (passType == FanPassType.free) {
      return FanPassPurchaseResult(
        success: false,
        errorMessage: 'Cannot purchase free tier',
      );
    }

    if (!_revenueCatService.isConfigured) {
      LoggingService.warning('RevenueCat not configured, falling back to browser checkout', tag: _logTag);
      final success = await openFanPassCheckout(passType: passType, context: context);
      return FanPassPurchaseResult(
        success: success,
        usedFallback: true,
        errorMessage: success ? null : 'Failed to open checkout',
      );
    }

    final result = await _revenueCatService.purchaseFanPassByType(passType);

    if (result.success) {
      onCacheClear?.call();
      LoggingService.info('Fan pass purchased successfully via RevenueCat', tag: _logTag);
    }

    return FanPassPurchaseResult(
      success: result.success,
      errorMessage: result.errorMessage,
      userCancelled: result.userCancelled,
    );
  }

  Future<RestorePurchasesResult> restorePurchases({required BuildContext context}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return RestorePurchasesResult(
        success: false,
        errorMessage: 'Please sign in to restore purchases',
      );
    }

    if (!_revenueCatService.isConfigured) {
      return RestorePurchasesResult(
        success: false,
        errorMessage: 'In-app purchases not available',
      );
    }

    final result = await _revenueCatService.restorePurchases();

    if (result.success) {
      onCacheClear?.call();

      if (result.hasRestoredPurchases) {
        LoggingService.info('Purchases restored: ${result.restoredPassType}', tag: _logTag);
      } else {
        LoggingService.info('No purchases to restore', tag: _logTag);
      }
    }

    return RestorePurchasesResult(
      success: result.success,
      hasRestoredPurchases: result.hasRestoredPurchases,
      restoredPassType: result.restoredPassType,
      errorMessage: result.errorMessage,
    );
  }

  Future<String?> getNativePrice(FanPassType passType) async {
    if (!_revenueCatService.isConfigured) return null;
    return _revenueCatService.getPriceForPassType(passType);
  }

  bool get isNativeIAPAvailable => _revenueCatService.isConfigured;

  // ---------------------------------------------------------------------------
  // Venue Premium checkout (Stripe only)
  // ---------------------------------------------------------------------------

  Future<String?> createVenuePremiumCheckout({
    required String venueId,
    String? venueName,
    String? successUrl,
    String? cancelUrl,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Must be logged in to purchase');
      }

      final callable = _functions.httpsCallable('createVenuePremiumCheckout');
      final result = await callable.call({
        'venueId': venueId,
        'venueName': venueName,
        'successUrl': successUrl,
        'cancelUrl': cancelUrl,
      });

      final data = result.data as Map<String, dynamic>;
      return data['url'] as String?;
    } catch (e) {
      LoggingService.error('Error creating venue premium checkout: $e', tag: _logTag);
      rethrow;
    }
  }

  Future<bool> openVenuePremiumCheckout({
    required String venueId,
    String? venueName,
    required BuildContext context,
  }) async {
    try {
      final url = await createVenuePremiumCheckout(
        venueId: venueId,
        venueName: venueName,
      );

      if (url == null) {
        if (context.mounted) {
          _showErrorDialog(context, 'Failed to create checkout session');
        }
        return false;
      }

      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      } else {
        if (context.mounted) {
          _showErrorDialog(context, 'Could not open checkout page');
        }
        return false;
      }
    } catch (e) {
      LoggingService.error('Error opening venue checkout: $e', tag: _logTag);
      if (context.mounted) {
        _showErrorDialog(context, 'Failed to start checkout: ${e.toString()}');
      }
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // UI helpers
  // ---------------------------------------------------------------------------

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

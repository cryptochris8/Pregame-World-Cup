import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'zapier_service.dart';
import '../injection_container.dart';
import '../config/api_keys.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// Initialize Stripe with publishable key
  static Future<void> init() async {
    // Use environment variable instead of hardcoded key
    Stripe.publishableKey = ApiKeys.stripePublishableKey;
    Stripe.merchantIdentifier = 'merchant.com.pregame.app';
    await Stripe.instance.applySettings();
  }

  /// Create payment intent for one-time payments (fan features, tips, etc.)
  Future<String?> createPaymentIntent({
    required double amount,
    required String description,
    String currency = 'usd',
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Call Firebase Function to create payment intent
      final callable = _functions.httpsCallable('createPaymentIntent');
      final result = await callable.call({
        'amount': (amount * 100).round(), // Convert to cents
        'currency': currency,
        'description': description,
      });

      return result.data['clientSecret'] as String?;
    } catch (e) {
      // Debug output removed
      rethrow;
    }
  }

  /// Process payment with card details
  Future<bool> processPayment({
    required String clientSecret,
    required BuildContext context,
  }) async {
    try {
      // Confirm payment with Stripe
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );

      return true;
    } on StripeException catch (e) {
      // Debug output removed
      _showErrorDialog(context, e.error.localizedMessage ?? 'Payment failed');
      return false;
    } catch (e) {
      // Debug output removed
      _showErrorDialog(context, 'An unexpected error occurred');
      return false;
    }
  }

  /// Show payment sheet for easier payment processing
  Future<bool> presentPaymentSheet({
    required String clientSecret,
    required BuildContext context,
  }) async {
    try {
      // Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Pregame',
          style: ThemeMode.system,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Color(0xFF1E3A8A), // pregame-blue
            ),
          ),
        ),
      );

      // Present payment sheet
      await Stripe.instance.presentPaymentSheet();
      return true;
    } on StripeException catch (e) {
      // Debug output removed
      if (e.error.code != FailureCode.Canceled) {
        _showErrorDialog(context, e.error.localizedMessage ?? 'Payment failed');
      }
      return false;
    } catch (e) {
      // Debug output removed
      _showErrorDialog(context, 'An unexpected error occurred');
      return false;
    }
  }

  /// Tip a venue (one-time payment)
  Future<void> tipVenue({
    required String venueId,
    required double amount,
    required BuildContext context,
  }) async {
    try {
      final clientSecret = await createPaymentIntent(
        amount: amount,
        description: 'Tip for venue',
      );

      if (clientSecret == null) throw Exception('Failed to create payment intent');

      final success = await presentPaymentSheet(
        clientSecret: clientSecret,
        context: context,
      );

      if (success) {
        _showSuccessDialog(context, 'Thank you for your tip!');
        
        // Trigger Zapier workflow for successful tip payment
        _trackPaymentSuccess(
          eventType: 'tip_venue',
          amount: amount,
          metadata: {'venue_id': venueId},
        );
      }
    } catch (e) {
      _showErrorDialog(context, 'Failed to process tip: $e');
    }
  }

  /// Purchase premium fan features
  Future<void> purchasePremiumFeatures({
    required String featureType,
    required double amount,
    required BuildContext context,
  }) async {
    try {
      final clientSecret = await createPaymentIntent(
        amount: amount,
        description: 'Premium features: $featureType',
      );

      if (clientSecret == null) throw Exception('Failed to create payment intent');

      final success = await presentPaymentSheet(
        clientSecret: clientSecret,
        context: context,
      );

      if (success) {
        _showSuccessDialog(context, 'Premium features unlocked!');
        
        // Trigger Zapier workflow for premium feature purchase
        _trackPaymentSuccess(
          eventType: 'premium_features',
          amount: amount,
          metadata: {'feature_type': featureType},
        );
      }
    } catch (e) {
      _showErrorDialog(context, 'Failed to purchase features: $e');
    }
  }

  /// Pay for event tickets or special access
  Future<void> purchaseTicket({
    required String eventId,
    required String ticketType,
    required double amount,
    required BuildContext context,
  }) async {
    try {
      final clientSecret = await createPaymentIntent(
        amount: amount,
        description: 'Event ticket: $ticketType',
      );

      if (clientSecret == null) throw Exception('Failed to create payment intent');

      final success = await presentPaymentSheet(
        clientSecret: clientSecret,
        context: context,
      );

      if (success) {
        _showSuccessDialog(context, 'Ticket purchased successfully!');
        
        // Trigger Zapier workflow for ticket purchase
        _trackPaymentSuccess(
          eventType: 'ticket_purchase',
          amount: amount,
          metadata: {
            'event_id': eventId,
            'ticket_type': ticketType,
          },
        );
      }
    } catch (e) {
      _showErrorDialog(context, 'Failed to purchase ticket: $e');
    }
  }

  /// Show error dialog
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Error'),
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

  /// Show success dialog
  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success!'),
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

  /// Track successful payment events with Zapier integration
  void _trackPaymentSuccess({
    required String eventType,
    required double amount,
    Map<String, dynamic>? metadata,
  }) {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final zapierService = sl<ZapierService>();
      
      // Fire-and-forget Zapier call for payment tracking
      zapierService.triggerPaymentEvent(
        eventType: eventType,
        customerId: user.uid,
        amount: amount.toString(),
        metadata: metadata,
      );
    } catch (e) {
      // Debug output removed
      // Don't throw - this is non-critical
    }
  }
}

/// Payment-related widgets and utilities
class PaymentUtils {
  /// Format currency for display
  static String formatCurrency(double amount, {String symbol = '\$'}) {
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  /// Validate card number (basic check)
  static bool isValidCardNumber(String cardNumber) {
    if (cardNumber.isEmpty) return false;
    
    // Remove spaces and check length
    final cleanNumber = cardNumber.replaceAll(' ', '');
    return cleanNumber.length >= 13 && cleanNumber.length <= 19;
  }

  /// Format card number with spaces
  static String formatCardNumber(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < cleanNumber.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(cleanNumber[i]);
    }
    
    return buffer.toString();
  }
}

/// Widget for quick payment buttons
class QuickPaymentButton extends StatelessWidget {
  final String label;
  final double amount;
  final VoidCallback? onPressed;
  final Color? color;

  const QuickPaymentButton({
    Key? key,
    required this.label,
    required this.amount,
    this.onPressed,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? const Color(0xFF1E3A8A), // pregame-blue
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          Text(
            PaymentUtils.formatCurrency(amount),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
} 
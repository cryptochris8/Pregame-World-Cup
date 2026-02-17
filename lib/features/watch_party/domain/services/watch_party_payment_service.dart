import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../injection_container.dart';
import '../../../../services/zapier_service.dart';
import '../../../../core/services/logging_service.dart';
import '../../../../core/services/performance_monitor.dart';
import '../entities/watch_party.dart';
import '../entities/watch_party_member.dart';
import 'watch_party_service.dart';

/// Service for handling watch party virtual attendance payments via Stripe
class WatchPartyPaymentService {
  static final WatchPartyPaymentService _instance = WatchPartyPaymentService._internal();
  factory WatchPartyPaymentService() => _instance;
  WatchPartyPaymentService._internal();

  static const String _logTag = 'WatchPartyPayment';
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference for tracking virtual payments
  CollectionReference get _virtualPaymentsCollection =>
      _firestore.collection('watch_party_virtual_payments');

  /// Purchase virtual attendance for a watch party
  /// Returns true if payment was successful and user was added as virtual member
  Future<bool> purchaseVirtualAttendance({
    required String watchPartyId,
    required BuildContext context,
  }) async {
    final traceId = 'purchase_virtual_attendance_${DateTime.now().millisecondsSinceEpoch}';
    PerformanceMonitor.startApiCall(traceId);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (context.mounted) {
          _showErrorDialog(context, 'Please sign in to purchase virtual attendance');
        }
        return false;
      }

      // Get watch party details
      final watchPartyService = sl<WatchPartyService>();
      final watchParty = await watchPartyService.getWatchParty(watchPartyId);

      if (watchParty == null) {
        if (context.mounted) {
          _showErrorDialog(context, 'Watch party not found');
        }
        return false;
      }

      if (!watchParty.allowVirtualAttendance) {
        if (context.mounted) {
          _showErrorDialog(context, 'This watch party does not allow virtual attendance');
        }
        return false;
      }

      if (watchParty.virtualAttendanceFee <= 0) {
        // Free virtual attendance - just join directly
        await _joinAsVirtualMember(watchPartyId, watchParty, user);
        if (context.mounted) {
          _showSuccessDialog(context, 'You\'ve joined the watch party virtually!');
        }
        return true;
      }

      // Create payment intent for virtual attendance (amount determined server-side)
      final clientSecret = await _createVirtualAttendancePaymentIntent(
        watchPartyId: watchPartyId,
        watchPartyName: watchParty.name,
      );

      if (clientSecret == null) {
        if (context.mounted) {
          _showErrorDialog(context, 'Failed to create payment. Please try again.');
        }
        return false;
      }

      // Present payment sheet
      if (!context.mounted) return false;
      final paymentSuccess = await _presentPaymentSheet(
        clientSecret: clientSecret,
        watchPartyName: watchParty.name,
        context: context,
      );

      if (paymentSuccess) {
        // Payment successful - add user as virtual member
        await _joinAsVirtualMember(watchPartyId, watchParty, user);

        // Record payment in Firestore
        await _recordVirtualPayment(
          watchPartyId: watchPartyId,
          userId: user.uid,
          amount: watchParty.virtualAttendanceFee,
          paymentIntentClientSecret: clientSecret,
        );

        // Track with Zapier
        _trackPaymentSuccess(
          watchPartyId: watchPartyId,
          watchPartyName: watchParty.name,
          amount: watchParty.virtualAttendanceFee,
        );

        if (context.mounted) {
          _showSuccessDialog(context, 'Welcome to ${watchParty.name}! You\'re now a virtual attendee.');
        }
        PerformanceMonitor.endApiCall(traceId, success: true);
        return true;
      }

      PerformanceMonitor.endApiCall(traceId, success: false);
      return false;
    } catch (e) {
      LoggingService.error('Error purchasing virtual attendance: $e', tag: _logTag);
      if (context.mounted) {
        _showErrorDialog(context, 'An error occurred. Please try again.');
      }
      PerformanceMonitor.endApiCall(traceId, success: false);
      return false;
    }
  }

  /// Create payment intent for virtual attendance via Cloud Function
  /// Amount is determined server-side from the watch party document.
  Future<String?> _createVirtualAttendancePaymentIntent({
    required String watchPartyId,
    required String watchPartyName,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final callable = _functions.httpsCallable('createVirtualAttendancePayment');
      final result = await callable.call({
        'watchPartyId': watchPartyId,
        'watchPartyName': watchPartyName,
      });

      return result.data['clientSecret'] as String?;
    } catch (e) {
      LoggingService.error('Error creating payment intent: $e', tag: _logTag);
      return null;
    }
  }

  /// Present Stripe payment sheet
  Future<bool> _presentPaymentSheet({
    required String clientSecret,
    required String watchPartyName,
    required BuildContext context,
  }) async {
    try {
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

      await Stripe.instance.presentPaymentSheet();
      return true;
    } on StripeException catch (e) {
      // Debug output removed
      if (e.error.code != FailureCode.Canceled && context.mounted) {
        _showErrorDialog(context, e.error.localizedMessage ?? 'Payment failed');
      }
      return false;
    } catch (e) {
      LoggingService.error('Payment sheet error: $e', tag: _logTag);
      if (context.mounted) {
        _showErrorDialog(context, 'Payment failed. Please try again.');
      }
      return false;
    }
  }

  /// Join watch party as a virtual member
  Future<void> _joinAsVirtualMember(
    String watchPartyId,
    WatchParty watchParty,
    User user,
  ) async {
    final watchPartyService = sl<WatchPartyService>();

    // Join as virtual member with paid status
    await watchPartyService.joinWatchParty(
      watchPartyId,
      WatchPartyAttendanceType.virtual,
    );

    // Mark as paid (update member record)
    final membersRef = _firestore
        .collection('watch_parties')
        .doc(watchPartyId)
        .collection('members');

    await membersRef.doc(user.uid).update({
      'hasPaid': true,
      'paymentIntentId': 'virtual_${DateTime.now().millisecondsSinceEpoch}',
    });
  }

  /// Record virtual payment in Firestore for tracking
  Future<void> _recordVirtualPayment({
    required String watchPartyId,
    required String userId,
    required double amount,
    required String paymentIntentClientSecret,
  }) async {
    try {
      await _virtualPaymentsCollection.add({
        'watchPartyId': watchPartyId,
        'userId': userId,
        'amount': amount,
        'currency': 'usd',
        'status': 'completed',
        'paymentIntentClientSecret': paymentIntentClientSecret,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      LoggingService.error('Error recording virtual payment: $e', tag: _logTag);
      // Non-critical - don't throw
    }
  }

  /// Track payment success with Zapier
  void _trackPaymentSuccess({
    required String watchPartyId,
    required String watchPartyName,
    required double amount,
  }) {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final zapierService = sl<ZapierService>();

      zapierService.triggerPaymentEvent(
        eventType: 'virtual_attendance',
        customerId: user.uid,
        amount: amount.toString(),
        metadata: {
          'watch_party_id': watchPartyId,
          'watch_party_name': watchPartyName,
        },
      );
    } catch (e) {
      // Debug output removed
    }
  }

  /// Get user's virtual attendance payment history
  Future<List<Map<String, dynamic>>> getUserPaymentHistory() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return [];

      final snapshot = await _virtualPaymentsCollection
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    } catch (e) {
      LoggingService.error('Error fetching payment history: $e', tag: _logTag);
      return [];
    }
  }

  /// Check if user has already paid for virtual attendance
  Future<bool> hasUserPaidForWatchParty(String watchPartyId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      final memberDoc = await _firestore
          .collection('watch_parties')
          .doc(watchPartyId)
          .collection('members')
          .doc(user.uid)
          .get();

      if (!memberDoc.exists) return false;

      final data = memberDoc.data();
      return data?['hasPaid'] == true;
    } catch (e) {
      LoggingService.error('Error checking payment status: $e', tag: _logTag);
      return false;
    }
  }

  /// Request refund for virtual attendance (host cancellation only)
  Future<bool> requestRefund({
    required String watchPartyId,
    required String reason,
    required BuildContext context,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showErrorDialog(context, 'Please sign in to request a refund');
        return false;
      }

      final callable = _functions.httpsCallable('requestVirtualAttendanceRefund');
      final result = await callable.call({
        'watchPartyId': watchPartyId,
        'userId': user.uid,
        'reason': reason,
      });

      if (result.data['success'] == true) {
        if (context.mounted) {
          _showSuccessDialog(context, 'Refund request submitted. You\'ll be notified once processed.');
        }
        return true;
      } else {
        if (context.mounted) {
          _showErrorDialog(context, result.data['message'] ?? 'Refund request failed');
        }
        return false;
      }
    } catch (e) {
      LoggingService.error('Error requesting refund: $e', tag: _logTag);
      if (context.mounted) {
        _showErrorDialog(context, 'Failed to submit refund request');
      }
      return false;
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
}

/// Widget for virtual attendance purchase button
class VirtualAttendanceButton extends StatelessWidget {
  final WatchParty watchParty;
  final VoidCallback? onPressed;
  final bool isLoading;

  const VirtualAttendanceButton({
    super.key,
    required this.watchParty,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!watchParty.allowVirtualAttendance) {
      return const SizedBox.shrink();
    }

    final fee = watchParty.virtualAttendanceFee;
    final buttonText = fee <= 0
        ? 'Join Virtually (Free)'
        : 'Join Virtually - \$${fee.toStringAsFixed(2)}';

    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.videocam),
      label: Text(buttonText),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF059669), // emerald-600
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

/// Widget showing virtual attendance info card
class VirtualAttendanceInfoCard extends StatelessWidget {
  final WatchParty watchParty;
  final bool hasJoined;
  final bool hasPaid;
  final VoidCallback? onJoinPressed;

  const VirtualAttendanceInfoCard({
    super.key,
    required this.watchParty,
    this.hasJoined = false,
    this.hasPaid = false,
    this.onJoinPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (!watchParty.allowVirtualAttendance) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.videocam, color: Color(0xFF059669)),
                SizedBox(width: 8),
                Text(
                  'Virtual Attendance Available',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Can\'t make it in person? Join the watch party virtually and participate in the chat!',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  watchParty.virtualAttendanceFee <= 0
                      ? 'Free'
                      : '\$${watchParty.virtualAttendanceFee.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF059669),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${watchParty.virtualAttendeesCount} virtual attendees',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            if (!hasJoined) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: VirtualAttendanceButton(
                  watchParty: watchParty,
                  onPressed: onJoinPressed,
                ),
              ),
            ] else if (hasPaid) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF059669).withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 16, color: Color(0xFF059669)),
                    SizedBox(width: 4),
                    Text(
                      'You\'re attending virtually',
                      style: TextStyle(
                        color: Color(0xFF059669),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

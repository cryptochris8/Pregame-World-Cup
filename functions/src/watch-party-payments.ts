import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import Stripe from 'stripe';
import { getStripe, getConfigValue } from './stripe-config';

const db = admin.firestore();

// Server-side default price for virtual watch party attendance (in cents)
const DEFAULT_VIRTUAL_ATTENDANCE_PRICE_CENTS = 999; // $9.99

/**
 * Create a payment intent for virtual watch party attendance
 */
export const createVirtualAttendancePayment = functions.https.onCall(async (data: any, context: any) => {
  try {
    // Verify user is authenticated
    if (!context?.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    const watchPartyId = data.watchPartyId;
    const watchPartyName = data.watchPartyName;
    const currency = data.currency || 'usd';

    if (!watchPartyId) {
      throw new functions.https.HttpsError('invalid-argument', 'Missing required parameters');
    }

    const userId = context.auth.uid;
    const userEmail = context.auth.token.email || '';

    // Verify watch party exists and allows virtual attendance
    const watchPartyDoc = await db.collection('watch_parties').doc(watchPartyId).get();
    if (!watchPartyDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Watch party not found');
    }

    const watchPartyData = watchPartyDoc.data();
    if (!watchPartyData?.allowVirtualAttendance) {
      throw new functions.https.HttpsError('failed-precondition', 'This watch party does not allow virtual attendance');
    }

    // SECURITY: Use server-side price from the watch party document or default constant.
    // Never trust client-provided amounts.
    const amount: number = watchPartyData?.virtualAttendancePriceCents
      ?? DEFAULT_VIRTUAL_ATTENDANCE_PRICE_CENTS;

    if (!amount || amount <= 0) {
      throw new functions.https.HttpsError('failed-precondition', 'Invalid virtual attendance price configured for this watch party');
    }

    // Use a transaction to atomically check for existing payment AND create a new one
    // This prevents race conditions where two requests could both pass the check
    const paymentIntentResult = await db.runTransaction(async (transaction) => {
      // Check if user already has a pending or completed payment within the transaction
      const existingPaymentQuery = await db.collection('watch_party_virtual_payments')
        .where('watchPartyId', '==', watchPartyId)
        .where('userId', '==', userId)
        .where('status', 'in', ['pending', 'completed'])
        .limit(1)
        .get();

      if (!existingPaymentQuery.empty) {
        throw new functions.https.HttpsError('already-exists', 'You have already purchased or have a pending payment for this watch party');
      }

      // Create payment intent with Stripe (outside transaction scope, but before Firestore write)
      const paymentIntent = await getStripe().paymentIntents.create({
        amount,
        currency,
        description: `Virtual attendance for ${watchPartyName || 'Watch Party'}`,
        metadata: {
          type: 'virtual_attendance',
          watchPartyId,
          watchPartyName: watchPartyName || '',
          userId,
          userEmail,
        },
      });

      // Record pending payment in Firestore atomically
      const paymentRef = db.collection('watch_party_virtual_payments').doc();
      transaction.set(paymentRef, {
        watchPartyId,
        userId,
        userEmail,
        amount: amount / 100, // Store in dollars
        currency,
        status: 'pending',
        paymentIntentId: paymentIntent.id,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return paymentIntent;
    });

    functions.logger.info(`Virtual attendance payment intent created: ${paymentIntentResult.id} for party ${watchPartyId}`);

    return {
      clientSecret: paymentIntentResult.client_secret,
      paymentIntentId: paymentIntentResult.id,
    };
  } catch (error: any) {
    functions.logger.error('Error creating virtual attendance payment:', error);
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    throw new functions.https.HttpsError('internal', 'Unable to create payment');
  }
});

/**
 * Handle successful virtual attendance payment (webhook or confirmation)
 */
export const handleVirtualAttendancePayment = functions.https.onCall(async (data: any, context: any) => {
  try {
    if (!context?.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    const paymentIntentId = data.paymentIntentId;
    const watchPartyId = data.watchPartyId;

    if (!paymentIntentId || !watchPartyId) {
      throw new functions.https.HttpsError('invalid-argument', 'Missing required parameters');
    }

    const userId = context.auth.uid;

    // Verify payment intent with Stripe
    const paymentIntent = await getStripe().paymentIntents.retrieve(paymentIntentId);

    if (paymentIntent.status !== 'succeeded') {
      throw new functions.https.HttpsError('failed-precondition', 'Payment has not been completed');
    }

    // Verify payment is for this watch party and user
    if (paymentIntent.metadata?.watchPartyId !== watchPartyId ||
        paymentIntent.metadata?.userId !== userId) {
      throw new functions.https.HttpsError('permission-denied', 'Payment does not match');
    }

    // Use a transaction to ensure all updates happen atomically and prevent double-processing
    await db.runTransaction(async (transaction) => {
      // Find the payment record
      const paymentQuery = await db.collection('watch_party_virtual_payments')
        .where('paymentIntentId', '==', paymentIntentId)
        .limit(1)
        .get();

      if (paymentQuery.empty) {
        throw new functions.https.HttpsError('not-found', 'Payment record not found');
      }

      const paymentDoc = paymentQuery.docs[0];
      const paymentData = paymentDoc.data();

      // Idempotency: If already completed, skip
      if (paymentData.status === 'completed') {
        functions.logger.info(`Payment ${paymentIntentId} already completed, skipping`);
        return;
      }

      // Update payment record to completed
      transaction.update(paymentDoc.ref, {
        status: 'completed',
        completedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Update member record to mark as paid
      const memberRef = db.collection('watch_parties')
        .doc(watchPartyId)
        .collection('members')
        .doc(userId);

      const memberDoc = await transaction.get(memberRef);
      if (memberDoc.exists) {
        transaction.update(memberRef, {
          hasPaid: true,
          paymentIntentId,
          paidAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }

      // Increment virtual attendees count
      const watchPartyRef = db.collection('watch_parties').doc(watchPartyId);
      transaction.update(watchPartyRef, {
        virtualAttendeesCount: admin.firestore.FieldValue.increment(1),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });

    functions.logger.info(`Virtual attendance payment completed: ${paymentIntentId} for party ${watchPartyId}`);

    return { success: true };
  } catch (error: any) {
    functions.logger.error('Error handling virtual attendance payment:', error);
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    throw new functions.https.HttpsError('internal', 'Unable to process payment');
  }
});

/**
 * Request refund for virtual attendance (e.g., when host cancels)
 */
export const requestVirtualAttendanceRefund = functions.https.onCall(async (data: any, context: any) => {
  try {
    if (!context?.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    const watchPartyId = data.watchPartyId;
    const userId = data.userId || context.auth.uid;
    const reason = data.reason || 'Watch party cancelled';

    if (!watchPartyId) {
      throw new functions.https.HttpsError('invalid-argument', 'Watch party ID is required');
    }

    // Only allow host to request refunds for others, or user for themselves
    const watchPartyDoc = await db.collection('watch_parties').doc(watchPartyId).get();
    if (!watchPartyDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Watch party not found');
    }

    const watchPartyData = watchPartyDoc.data();
    const isHost = watchPartyData?.hostId === context.auth.uid;
    const isSelf = userId === context.auth.uid;

    if (!isHost && !isSelf) {
      throw new functions.https.HttpsError('permission-denied', 'Not authorized to request refund');
    }

    // Find completed payment
    const paymentQuery = await db.collection('watch_party_virtual_payments')
      .where('watchPartyId', '==', watchPartyId)
      .where('userId', '==', userId)
      .where('status', '==', 'completed')
      .limit(1)
      .get();

    if (paymentQuery.empty) {
      throw new functions.https.HttpsError('not-found', 'No completed payment found for refund');
    }

    const paymentDoc = paymentQuery.docs[0];
    const paymentData = paymentDoc.data();
    const paymentIntentId = paymentData.paymentIntentId;

    // Idempotency: If already refunded, return the existing refund info
    if (paymentData.status === 'refunded') {
      functions.logger.info(`Payment ${paymentIntentId} already refunded, returning existing refund`);
      return {
        success: true,
        refundId: paymentData.refundId,
        message: 'Refund was already processed',
      };
    }

    // Create refund with Stripe
    const refund = await getStripe().refunds.create({
      payment_intent: paymentIntentId,
      reason: 'requested_by_customer',
      metadata: {
        watchPartyId,
        userId,
        requestedBy: context.auth.uid,
        reason,
      },
    });

    // Use a batch write to update all records atomically
    const batch = db.batch();

    // Update payment record
    batch.update(paymentDoc.ref, {
      status: 'refunded',
      refundId: refund.id,
      refundedAt: admin.firestore.FieldValue.serverTimestamp(),
      refundReason: reason,
    });

    // Update member record
    const memberRef = db.collection('watch_parties')
      .doc(watchPartyId)
      .collection('members')
      .doc(userId);

    batch.update(memberRef, {
      hasPaid: false,
      refundedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Decrement virtual attendees count
    const watchPartyRef = db.collection('watch_parties').doc(watchPartyId);
    batch.update(watchPartyRef, {
      virtualAttendeesCount: admin.firestore.FieldValue.increment(-1),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    await batch.commit();

    functions.logger.info(`Virtual attendance refund processed: ${refund.id} for party ${watchPartyId}`);

    return {
      success: true,
      refundId: refund.id,
      message: 'Refund processed successfully',
    };
  } catch (error: any) {
    functions.logger.error('Error processing refund:', error);
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    throw new functions.https.HttpsError('internal', 'Unable to process refund');
  }
});

/**
 * Process refunds for all virtual attendees when a watch party is cancelled
 */
export const refundAllVirtualAttendees = functions.https.onCall(async (data: any, context: any) => {
  try {
    if (!context?.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    const watchPartyId = data.watchPartyId;

    if (!watchPartyId) {
      throw new functions.https.HttpsError('invalid-argument', 'Watch party ID is required');
    }

    // Verify caller is the host
    const watchPartyDoc = await db.collection('watch_parties').doc(watchPartyId).get();
    if (!watchPartyDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Watch party not found');
    }

    const watchPartyData = watchPartyDoc.data();
    if (watchPartyData?.hostId !== context.auth.uid) {
      throw new functions.https.HttpsError('permission-denied', 'Only the host can process mass refunds');
    }

    // Find all completed payments for this watch party
    const paymentsQuery = await db.collection('watch_party_virtual_payments')
      .where('watchPartyId', '==', watchPartyId)
      .where('status', '==', 'completed')
      .get();

    if (paymentsQuery.empty) {
      return { success: true, refundedCount: 0, message: 'No payments to refund' };
    }

    let refundedCount = 0;
    const errors: string[] = [];

    // Process refunds for each payment
    for (const paymentDoc of paymentsQuery.docs) {
      const paymentData = paymentDoc.data();

      try {
        const refund = await getStripe().refunds.create({
          payment_intent: paymentData.paymentIntentId,
          reason: 'requested_by_customer',
          metadata: {
            watchPartyId,
            userId: paymentData.userId,
            reason: 'Watch party cancelled by host',
          },
        });

        await paymentDoc.ref.update({
          status: 'refunded',
          refundId: refund.id,
          refundedAt: admin.firestore.FieldValue.serverTimestamp(),
          refundReason: 'Watch party cancelled by host',
        });

        refundedCount++;
      } catch (err: any) {
        errors.push(`Failed to refund user ${paymentData.userId}: ${err.message}`);
        functions.logger.error(`Refund failed for user ${paymentData.userId}:`, err);
      }
    }

    // Update watch party
    await db.collection('watch_parties').doc(watchPartyId).update({
      virtualAttendeesCount: 0,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    functions.logger.info(`Mass refund completed for party ${watchPartyId}: ${refundedCount} refunds processed`);

    return {
      success: true,
      refundedCount,
      errors: errors.length > 0 ? errors : undefined,
      message: `${refundedCount} refunds processed`,
    };
  } catch (error: any) {
    functions.logger.error('Error processing mass refunds:', error);
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    throw new functions.https.HttpsError('internal', 'Unable to process mass refunds');
  }
});

/**
 * Stripe webhook handler for watch party payment events.
 * Verifies the webhook signature before processing any events.
 */
export const handleWatchPartyWebhook = functions.https.onRequest(async (req, res) => {
  const sig = req.headers['stripe-signature'] as string;
  // SECURITY: Require a properly configured webhook secret - never fall back to insecure defaults
  const webhookSecret = process.env.STRIPE_WP_WEBHOOK_SECRET ||
                        getConfigValue('stripe', 'wp_webhook_secret');

  if (!webhookSecret) {
    functions.logger.error('Watch party webhook secret is not configured. Set stripe.wp_webhook_secret in Firebase config or STRIPE_WP_WEBHOOK_SECRET env var.');
    res.status(500).send('Webhook secret not configured');
    return;
  }

  let event: Stripe.Event;

  try {
    // SECURITY: Use req.rawBody for signature verification (not req.body)
    // Firebase Cloud Functions provides rawBody as the unparsed request body,
    // which is required for correct Stripe signature verification.
    event = getStripe().webhooks.constructEvent(req.rawBody, sig, webhookSecret);
  } catch (err) {
    functions.logger.error('Watch party webhook signature verification failed:', err);
    res.status(400).send('Webhook signature verification failed');
    return;
  }

  try {
    switch (event.type) {
      case 'payment_intent.succeeded': {
        const paymentIntent = event.data.object as Stripe.PaymentIntent;
        // Only handle virtual attendance payments
        if (paymentIntent.metadata?.type === 'virtual_attendance') {
          await handleWebhookPaymentSucceeded(paymentIntent);
        }
        break;
      }

      case 'payment_intent.payment_failed': {
        const paymentIntent = event.data.object as Stripe.PaymentIntent;
        if (paymentIntent.metadata?.type === 'virtual_attendance') {
          await handleWebhookPaymentFailed(paymentIntent);
        }
        break;
      }

      case 'charge.refunded': {
        const charge = event.data.object as Stripe.Charge;
        if (charge.metadata?.type === 'virtual_attendance' || charge.payment_intent) {
          functions.logger.info(`Refund webhook received for charge: ${charge.id}`);
        }
        break;
      }

      default:
        functions.logger.info(`Unhandled watch party webhook event type: ${event.type}`);
    }

    res.status(200).send('Webhook handled successfully');
  } catch (error) {
    functions.logger.error('Error handling watch party webhook:', error);
    res.status(500).send('Webhook handler failed');
  }
});

/**
 * Handle successful payment from webhook (server-side confirmation).
 */
async function handleWebhookPaymentSucceeded(paymentIntent: Stripe.PaymentIntent): Promise<void> {
  const watchPartyId = paymentIntent.metadata?.watchPartyId;
  const userId = paymentIntent.metadata?.userId;

  if (!watchPartyId || !userId) {
    functions.logger.warn(`Payment intent ${paymentIntent.id} missing watchPartyId or userId metadata`);
    return;
  }

  // Find the payment record
  const paymentQuery = await db.collection('watch_party_virtual_payments')
    .where('paymentIntentId', '==', paymentIntent.id)
    .limit(1)
    .get();

  if (paymentQuery.empty) {
    functions.logger.warn(`No payment record found for payment intent ${paymentIntent.id}`);
    return;
  }

  const paymentDoc = paymentQuery.docs[0];
  const paymentData = paymentDoc.data();

  // Idempotency: If already completed, skip
  if (paymentData.status === 'completed') {
    functions.logger.info(`Payment ${paymentIntent.id} already completed via webhook, skipping`);
    return;
  }

  const batch = db.batch();

  // Update payment record to completed
  batch.update(paymentDoc.ref, {
    status: 'completed',
    completedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // Update member record to mark as paid
  const memberRef = db.collection('watch_parties')
    .doc(watchPartyId)
    .collection('members')
    .doc(userId);

  const memberDoc = await memberRef.get();
  if (memberDoc.exists) {
    batch.update(memberRef, {
      hasPaid: true,
      paymentIntentId: paymentIntent.id,
      paidAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }

  // Increment virtual attendees count
  const watchPartyRef = db.collection('watch_parties').doc(watchPartyId);
  batch.update(watchPartyRef, {
    virtualAttendeesCount: admin.firestore.FieldValue.increment(1),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  await batch.commit();

  functions.logger.info(`Webhook: Virtual attendance payment completed: ${paymentIntent.id} for party ${watchPartyId}`);
}

/**
 * Handle failed payment from webhook.
 */
async function handleWebhookPaymentFailed(paymentIntent: Stripe.PaymentIntent): Promise<void> {
  const watchPartyId = paymentIntent.metadata?.watchPartyId;

  // Find and update the payment record
  const paymentQuery = await db.collection('watch_party_virtual_payments')
    .where('paymentIntentId', '==', paymentIntent.id)
    .limit(1)
    .get();

  if (!paymentQuery.empty) {
    const paymentDoc = paymentQuery.docs[0];
    await paymentDoc.ref.update({
      status: 'failed',
      failedAt: admin.firestore.FieldValue.serverTimestamp(),
      failureMessage: paymentIntent.last_payment_error?.message || 'Payment failed',
    });
  }

  functions.logger.warn(`Webhook: Virtual attendance payment failed: ${paymentIntent.id} for party ${watchPartyId}`);
}

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import Stripe from 'stripe';
import { getStripe, getConfigValue, isWebhookEventAlreadyProcessed, markWebhookEventProcessed } from './stripe-config';

const db = admin.firestore();

// New function to set up free fan accounts (no Stripe needed)
export const setupFreeFanAccount = functions.https.onCall(async (data: any, context: any) => {
  try {
    // Verify user is authenticated
    if (!context?.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    const fanId = data.fanId;
    const plan = data.plan || 'free';
    
    if (!fanId) {
      throw new functions.https.HttpsError('invalid-argument', 'Fan ID is required');
    }

    const userEmail = context.auth.token.email || '';
    const userId = context.auth.uid;

    // Create fan document in Firestore
    const fanData = {
      id: fanId,
      userId: userId,
      userEmail: userEmail,
      plan: plan,
      status: 'active',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      features: {
        basicSchedules: true,
        venueDiscovery: true,
        communityAccess: true,
        gameNotifications: true,
        basicTeamFollowing: true,
        // Premium features disabled for free plan
        advancedInsights: false,
        priorityReservations: false,
        exclusiveContent: false,
        customNotifications: false,
        adFreeExperience: false,
        premiumVenuePerks: false,
        advancedSocialFeatures: false
      },
      billing: {
        plan: plan,
        amount: 0,
        currency: 'usd',
        interval: 'month',
        status: 'active',
        stripeCustomerId: null,
        stripeSubscriptionId: null
      }
    };

    // Save fan to Firestore
    await db.collection('fans').doc(fanId).set(fanData);

    // Log the signup for analytics
    functions.logger.info(`Free fan account created: ${fanId} for user ${userId}`);

    return { 
      success: true, 
      fanId: fanId,
      plan: plan,
      message: 'Free fan account created successfully'
    };
  } catch (error) {
    console.error('Error setting up free fan account:', error);
    throw new functions.https.HttpsError('internal', 'Unable to create free fan account');
  }
});

// Create Stripe checkout session for fan subscriptions
export const createFanCheckoutSession = functions.https.onCall(async (data: any, context: any) => {
  try {
    // Verify user is authenticated
    if (!context?.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    const priceId = data.priceId;
    const fanId = data.fanId;
    const mode = data.mode || 'subscription';
    
    if (!priceId || !fanId) {
      throw new functions.https.HttpsError('invalid-argument', 'Missing required parameters');
    }

    // Get fan data from Firestore
    const fanDoc = await db.collection('fans').doc(fanId).get();
    if (!fanDoc.exists) {
      // Create fan document if it doesn't exist
      const fanData = {
        id: fanId,
        userId: context.auth.uid,
        userEmail: context.auth.token.email || '',
        plan: 'free',
        status: 'active',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      };
      await db.collection('fans').doc(fanId).set(fanData);
    }

    const fanData = fanDoc.exists ? fanDoc.data() : null;
    const userEmail = context.auth.token.email || '';

    // Create or retrieve Stripe customer
    let customerId = fanData?.stripeCustomerId;
    
    if (!customerId) {
      const customer = await getStripe().customers.create({
        email: userEmail,
        metadata: {
          fanId: fanId,
          userId: context.auth.uid,
          type: 'fan'
        }
      });
      customerId = customer.id;
      
      // Save customer ID to fan document
      await db.collection('fans').doc(fanId).update({
        stripeCustomerId: customerId
      });
    }

    // Create checkout session
    const session = await getStripe().checkout.sessions.create({
      customer: customerId,
      payment_method_types: ['card'],
      mode: mode as 'subscription' | 'payment',
      line_items: [
        {
          price: priceId,
          quantity: 1,
        },
      ],
      success_url: `https://pregame-b089e.web.app/fan/dashboard?success=true&session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: `https://pregame-b089e.web.app/fan/subscription?canceled=true`,
      metadata: {
        fanId: fanId,
        userId: context.auth.uid,
        type: 'fan'
      }
    });

    return { sessionId: session.id };
  } catch (error) {
    console.error('Error creating fan checkout session:', error);
    throw new functions.https.HttpsError('internal', 'Unable to create fan checkout session');
  }
});

// New function to set up free venue accounts (no Stripe needed)
export const setupFreeVenueAccount = functions.https.onCall(async (data: any, context: any) => {
  try {
    // Verify user is authenticated
    if (!context?.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    const venueId = data.venueId;
    const plan = data.plan || 'free';
    
    if (!venueId) {
      throw new functions.https.HttpsError('invalid-argument', 'Venue ID is required');
    }

    const userEmail = context.auth.token.email || '';
    const userId = context.auth.uid;

    // Create venue document in Firestore
    const venueData = {
      id: venueId,
      ownerId: userId,
      ownerEmail: userEmail,
      plan: plan,
      status: 'active',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      features: {
        basicProfile: true,
        customerMessaging: true,
        basicAnalytics: true,
        communityAccess: true,
        gameNotifications: true,
        // Premium features disabled for free plan
        advancedAnalytics: false,
        liveStreaming: false,
        prioritySupport: false,
        featuredListings: false,
        customPromotions: false,
        socialIntegration: false
      },
      billing: {
        plan: plan,
        amount: 0,
        currency: 'usd',
        interval: 'month',
        status: 'active',
        stripeCustomerId: null,
        stripeSubscriptionId: null
      }
    };

    // Save venue to Firestore
    await db.collection('venues').doc(venueId).set(venueData);

    // Log the signup for analytics
    functions.logger.info(`Free venue account created: ${venueId} for user ${userId}`);

    return { 
      success: true, 
      venueId: venueId,
      plan: plan,
      message: 'Free venue account created successfully'
    };
  } catch (error) {
    console.error('Error setting up free venue account:', error);
    throw new functions.https.HttpsError('internal', 'Unable to create free venue account');
  }
});

// Create Stripe checkout session for subscriptions
export const createCheckoutSession = functions.https.onCall(async (data: any, context: any) => {
  try {
    // Verify user is authenticated
    if (!context?.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    const priceId = data.priceId;
    const venueId = data.venueId;
    const mode = data.mode || 'subscription';
    
    if (!priceId || !venueId) {
      throw new functions.https.HttpsError('invalid-argument', 'Missing required parameters');
    }

    // Get venue data from Firestore
    const venueDoc = await db.collection('venues').doc(venueId).get();
    if (!venueDoc.exists) {
      // Create venue document if it doesn't exist
      const venueData = {
        id: venueId,
        ownerId: context.auth.uid,
        ownerEmail: context.auth.token.email || '',
        plan: 'free',
        status: 'active',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      };
      await db.collection('venues').doc(venueId).set(venueData);
    }

    const venueData = venueDoc.exists ? venueDoc.data() : null;
    const userEmail = context.auth.token.email || '';

    // Create or retrieve Stripe customer
    let customerId = venueData?.stripeCustomerId;
    
    if (!customerId) {
      const customer = await getStripe().customers.create({
        email: userEmail,
        metadata: {
          venueId: venueId,
          userId: context.auth.uid
        }
      });
      customerId = customer.id;
      
      // Save customer ID to venue document
      await db.collection('venues').doc(venueId).update({
        stripeCustomerId: customerId
      });
    }

    // Create checkout session
    const session = await getStripe().checkout.sessions.create({
      customer: customerId,
      payment_method_types: ['card'],
      mode: mode as 'subscription' | 'payment',
      line_items: [
        {
          price: priceId,
          quantity: 1,
        },
      ],
      success_url: `https://pregame-b089e.web.app/venue/billing/success?success=true&session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: `https://pregame-b089e.web.app/venue/billing/cancel?canceled=true`,
      metadata: {
        venueId: venueId,
        userId: context.auth.uid
      }
    });

    return { sessionId: session.id };
  } catch (error) {
    console.error('Error creating checkout session:', error);
    throw new functions.https.HttpsError('internal', 'Unable to create checkout session');
  }
});

// Create customer portal session for subscription management
export const createPortalSession = functions.https.onCall(async (data: any, context: any) => {
  try {
    if (!context?.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    const userId = context.auth.uid;
    const returnUrl = data.returnUrl;

    // SECURITY: Look up the Stripe customer from Firestore using the authenticated user's UID.
    // Never trust a client-provided customerId.
    const customerQuery = await admin.firestore().collection('stripe_customers')
      .where('userId', '==', userId)
      .limit(1)
      .get();

    if (customerQuery.empty) {
      throw new functions.https.HttpsError('not-found', 'No Stripe customer found for this user');
    }

    const customerId = customerQuery.docs[0].data().customerId;

    const portalSession = await getStripe().billingPortal.sessions.create({
      customer: customerId,
      return_url: returnUrl || `https://pregame-b089e.web.app/venue/billing`,
    });

    return { url: portalSession.url };
  } catch (error: any) {
    console.error('Error creating portal session:', error);
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    throw new functions.https.HttpsError('internal', 'Unable to create portal session');
  }
});

// Allowed one-time payment amounts (in cents) to prevent arbitrary charges
const ALLOWED_PAYMENT_AMOUNTS: Record<string, number> = {
  fan_pass: 1499,        // $14.99
  superfan_pass: 2999,   // $29.99
  venue_premium: 9900,   // $99.00
};

// Create payment intent for one-time payments
export const createPaymentIntent = functions.https.onCall(async (data: any, context: any) => {
  try {
    if (!context?.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    const productType = data.productType;
    const currency = data.currency || 'usd';
    const description = data.description;

    // SECURITY: Look up amount server-side from allowed products.
    // Never trust a client-provided amount.
    if (!productType || !ALLOWED_PAYMENT_AMOUNTS[productType]) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `Invalid product type. Must be one of: ${Object.keys(ALLOWED_PAYMENT_AMOUNTS).join(', ')}`
      );
    }

    const amount = ALLOWED_PAYMENT_AMOUNTS[productType];

    const paymentIntent = await getStripe().paymentIntents.create({
      amount,
      currency,
      description: description || `World Cup 2026 - ${productType}`,
      metadata: {
        userId: context.auth.uid,
        productType,
      }
    });

    return { clientSecret: paymentIntent.client_secret };
  } catch (error: any) {
    console.error('Error creating payment intent:', error);
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    throw new functions.https.HttpsError('internal', 'Unable to create payment intent');
  }
});

// Stripe webhook handler
export const handleStripeWebhook = functions.https.onRequest(async (req, res) => {
  const sig = req.headers['stripe-signature'] as string;
  // SECURITY: Require a properly configured webhook secret - never fall back to insecure defaults
  const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET ||
                        getConfigValue('stripe', 'webhook_secret');

  if (!webhookSecret) {
    functions.logger.error('Stripe webhook secret is not configured. Set stripe.webhook_secret in Firebase config or STRIPE_WEBHOOK_SECRET env var.');
    res.status(500).send('Webhook secret not configured');
    return;
  }

  let event: Stripe.Event;

  try {
    event = getStripe().webhooks.constructEvent(req.rawBody, sig, webhookSecret);
  } catch (err) {
    console.error('Webhook signature verification failed:', err);
    res.status(400).send('Webhook signature verification failed');
    return;
  }

  try {
    // Idempotency: Skip events that have already been processed
    if (await isWebhookEventAlreadyProcessed(event.id)) {
      functions.logger.info(`Webhook event ${event.id} already processed, skipping`);
      res.status(200).send('Event already processed');
      return;
    }

    switch (event.type) {
      case 'checkout.session.completed':
        await handleCheckoutCompleted(event.data.object as Stripe.Checkout.Session);
        break;
      
      case 'customer.subscription.created':
      case 'customer.subscription.updated':
        await handleSubscriptionChange(event.data.object as Stripe.Subscription);
        break;
      
      case 'customer.subscription.deleted':
        await handleSubscriptionCanceled(event.data.object as Stripe.Subscription);
        break;
      
      case 'invoice.payment_succeeded':
        await handlePaymentSucceeded(event.data.object as Stripe.Invoice);
        break;
      
      case 'invoice.payment_failed':
        await handlePaymentFailed(event.data.object as Stripe.Invoice);
        break;
      
      default:
        console.log(`Unhandled event type: ${event.type}`);
    }

    // Mark event as processed after successful handling
    await markWebhookEventProcessed(event.id, event.type);

    res.status(200).send('Webhook handled successfully');
  } catch (error) {
    console.error('Error handling webhook:', error);
    res.status(500).send('Webhook handler failed');
  }
});

// Helper function: Handle checkout session completion
async function handleCheckoutCompleted(session: Stripe.Checkout.Session) {
  const venueId = session.metadata?.venueId;
  const userId = session.metadata?.userId;

  if (venueId && userId) {
    try {
      // Update venue with successful payment
      await db.collection('venues').doc(venueId).update({
        'billing.status': 'active',
        'billing.stripeCustomerId': session.customer,
        'billing.stripeSubscriptionId': session.subscription,
        'billing.lastPaymentAt': admin.firestore.FieldValue.serverTimestamp(),
        'plan': 'premium', // Upgrade to premium plan
        'features.advancedAnalytics': true,
        'features.liveStreaming': true,
        'features.prioritySupport': true,
        'features.featuredListings': true,
        'features.customPromotions': true,
        'features.socialIntegration': true,
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });

      functions.logger.info(`Checkout completed for venue: ${venueId}`);
    } catch (error) {
      functions.logger.error('Error updating venue after checkout:', error);
    }
  }
}

// Helper function: Handle subscription changes
async function handleSubscriptionChange(subscription: Stripe.Subscription) {
  const customerId = subscription.customer as string;
  
  try {
    // Find venue by customer ID
    const venuesQuery = await db.collection('venues')
      .where('billing.stripeCustomerId', '==', customerId)
      .limit(1)
      .get();

    if (!venuesQuery.empty) {
      const venueDoc = venuesQuery.docs[0];
      const venueId = venueDoc.id;

      // Determine plan based on subscription status and price
      let plan = 'free';
      let features = {
        basicProfile: true,
        customerMessaging: true,
        basicAnalytics: true,
        communityAccess: true,
        gameNotifications: true,
        advancedAnalytics: false,
        liveStreaming: false,
        prioritySupport: false,
        featuredListings: false,
        customPromotions: false,
        socialIntegration: false
      };

      if (subscription.status === 'active') {
        plan = 'premium';
        features = {
          ...features,
          advancedAnalytics: true,
          liveStreaming: true,
          prioritySupport: true,
          featuredListings: true,
          customPromotions: true,
          socialIntegration: true
        };
      }

      await db.collection('venues').doc(venueId).update({
        plan: plan,
        features: features,
        'billing.status': subscription.status,
        'billing.stripeSubscriptionId': subscription.id,
        'billing.currentPeriodEnd': new Date((subscription as any).current_period_end * 1000),
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });

      functions.logger.info(`Subscription updated for venue: ${venueId}, status: ${subscription.status}`);
    }
  } catch (error) {
    functions.logger.error('Error handling subscription change:', error);
  }
}

// Helper function: Handle subscription cancellation
async function handleSubscriptionCanceled(subscription: Stripe.Subscription) {
  const customerId = subscription.customer as string;
  
  try {
    // Find venue by customer ID
    const venuesQuery = await db.collection('venues')
      .where('billing.stripeCustomerId', '==', customerId)
      .limit(1)
      .get();

    if (!venuesQuery.empty) {
      const venueDoc = venuesQuery.docs[0];
      const venueId = venueDoc.id;

      // Downgrade to free plan
      await db.collection('venues').doc(venueId).update({
        plan: 'free',
        'features.advancedAnalytics': false,
        'features.liveStreaming': false,
        'features.prioritySupport': false,
        'features.featuredListings': false,
        'features.customPromotions': false,
        'features.socialIntegration': false,
        'billing.status': 'canceled',
        'billing.canceledAt': admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });

      functions.logger.info(`Subscription canceled for venue: ${venueId}, downgraded to free plan`);
    }
  } catch (error) {
    functions.logger.error('Error handling subscription cancellation:', error);
  }
}

// Helper function: Handle successful payments
async function handlePaymentSucceeded(invoice: Stripe.Invoice) {
  const customerId = invoice.customer as string;
  
  try {
    // Find venue by customer ID and update last payment
    const venuesQuery = await db.collection('venues')
      .where('billing.stripeCustomerId', '==', customerId)
      .limit(1)
      .get();

    if (!venuesQuery.empty) {
      const venueDoc = venuesQuery.docs[0];
      const venueId = venueDoc.id;

      await db.collection('venues').doc(venueId).update({
        'billing.lastPaymentAt': admin.firestore.FieldValue.serverTimestamp(),
        'billing.lastPaymentAmount': invoice.amount_paid,
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });

      functions.logger.info(`Payment succeeded for venue: ${venueId}, amount: ${invoice.amount_paid}`);
    }
  } catch (error) {
    functions.logger.error('Error handling payment success:', error);
  }
}

// Helper function: Handle failed payments
async function handlePaymentFailed(invoice: Stripe.Invoice) {
  const customerId = invoice.customer as string;
  
  try {
    // Find venue by customer ID and update payment status
    const venuesQuery = await db.collection('venues')
      .where('billing.stripeCustomerId', '==', customerId)
      .limit(1)
      .get();

    if (!venuesQuery.empty) {
      const venueDoc = venuesQuery.docs[0];
      const venueId = venueDoc.id;

      await db.collection('venues').doc(venueId).update({
        'billing.lastFailedPaymentAt': admin.firestore.FieldValue.serverTimestamp(),
        'billing.paymentStatus': 'failed',
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });

      functions.logger.warn(`Payment failed for venue: ${venueId}, invoice: ${invoice.id}`);
    }
  } catch (error) {
    functions.logger.error('Error handling payment failure:', error);
  }
} 
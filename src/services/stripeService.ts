import { loadStripe, Stripe } from '@stripe/stripe-js';
import { environment } from '../config/environment';

// Initialize Stripe with secure environment configuration
let stripePromise: Promise<Stripe | null>;

export const getStripe = () => {
  if (!stripePromise) {
    stripePromise = loadStripe(environment.stripePublishableKey);
  }
  return stripePromise;
};

// Fan subscription plans - Free basic, $9.99 premium
export const FAN_SUBSCRIPTION_PLANS = {
  free: {
    name: 'Free',
    priceId: null, // No Stripe price ID needed for free plan
    price: 0,
    popular: true,
    features: [
      'Basic game schedules',
      'Venue discovery',
      'Community access',
      'Game notifications',
      'Basic team following'
    ]
  },
  premium: {
    name: 'Premium',
    priceId: 'price_1Rcg45Q811jRCI3CnKjV7qUw', // Real Stripe price ID for $9.99/month
    price: 9.99,
    features: [
      'Everything in Free',
      'Advanced game insights',
      'Priority venue reservations',
      'Exclusive fan content',
      'Custom notifications',
      'Ad-free experience',
      'Premium venue perks',
      'Advanced social features'
    ]
  }
};

// Venue subscription plans with Early Bird pricing (restored original)
export const SUBSCRIPTION_PLANS = {
  basic: {
    name: 'Basic (Early Bird Special)',
    priceId: 'price_1RYpTMQ811jRCI3C9vVGazTM', // Early Bird: $49/month
    price: 49,
    originalPrice: 79,
    earlyBird: true,
    features: [
      'Venue profile management',
      'Basic specials promotion',
      'Customer messaging',
      'Basic analytics'
    ]
  },
  pro: {
    name: 'Pro (Early Bird Special)',
    priceId: 'price_1RYqeoQ811jRCI3CAq5mVLGw', // Early Bird: $99/month
    price: 99,
    originalPrice: 149,
    earlyBird: true,
    features: [
      'Everything in Basic',
      'Live streaming capability',
      'Advanced analytics dashboard',
      'Priority support',
      'Featured listings'
    ]
  },
  enterprise: {
    name: 'Enterprise (Early Bird Special)',
    priceId: 'price_1RYqfIQ811jRCI3CAJbma9Lu', // Early Bird: $199/month
    price: 199,
    originalPrice: 299,
    earlyBird: true,
    features: [
      'Everything in Pro',
      'Multiple locations',
      'Custom integrations',
      'Dedicated account manager',
      'Revenue sharing options'
    ]
  }
};

// Regular pricing (for future use when early bird expires)
export const REGULAR_SUBSCRIPTION_PLANS = {
  basic: {
    name: 'Basic (Legacy)',
    priceId: 'price_1RYpTMQ811jRCI3C9vVGazTM',
    price: 49,
    originalPrice: 79,
    earlyBird: true,
    features: [
      'Venue profile management',
      'Basic specials promotion',
      'Customer messaging',
      'Basic analytics'
    ]
  },
  pro: {
    name: 'Pro (Legacy)',
    priceId: 'price_1RYqeoQ811jRCI3CAq5mVLGw',
    price: 99,
    originalPrice: 149,
    earlyBird: true,
    features: [
      'Everything in Basic',
      'Live streaming capability',
      'Advanced analytics dashboard',
      'Priority support',
      'Featured listings'
    ]
  },
  enterprise: {
    name: 'Enterprise (Legacy)',
    priceId: 'price_1RYqfIQ811jRCI3CAJbma9Lu',
    price: 199,
    originalPrice: 299,
    earlyBird: true,
    features: [
      'Everything in Pro',
      'Multiple locations',
      'Custom integrations',
      'Dedicated account manager',
      'Revenue sharing options'
    ]
  }
};

// Create subscription checkout session using Firebase Functions
export const createSubscriptionCheckout = async (priceId: string, venueId: string) => {
  try {
    // Import Firebase Functions
    const { getFunctions, httpsCallable } = await import('firebase/functions');
    const functions = getFunctions();
    
    // Call Firebase Function
    const createCheckout = httpsCallable(functions, 'createCheckoutSession');
    const result = await createCheckout({
      priceId,
      venueId,
      mode: 'subscription'
    });

    const sessionId = (result.data as any).sessionId;
    
    const stripe = await getStripe();
    if (!stripe) throw new Error('Stripe not loaded');
    
    const { error } = await stripe.redirectToCheckout({ sessionId });
    if (error) {
      console.error('Stripe redirect error:', error);
      throw error;
    }
  } catch (error) {
    console.error('Subscription checkout error:', error);
    throw error;
  }
};

// Handle free plan signup (no Stripe needed)
export const signupForFreePlan = async (venueId: string) => {
  try {
    // Import Firebase Functions for venue setup
    const { getFunctions, httpsCallable } = await import('firebase/functions');
    const functions = getFunctions();
    
    // Call Firebase Function to set up free venue account
    const setupFreeAccount = httpsCallable(functions, 'setupFreeVenueAccount');
    const result = await setupFreeAccount({
      venueId,
      plan: 'free'
    });

    return result.data;
  } catch (error) {
    console.error('Free plan signup error:', error);
    throw error;
  }
};

// Create customer portal session for subscription management using Firebase Functions
export const createCustomerPortalSession = async (customerId: string) => {
  try {
    // Import Firebase Functions
    const { getFunctions, httpsCallable } = await import('firebase/functions');
    const functions = getFunctions();
    
    // Call Firebase Function
    const createPortal = httpsCallable(functions, 'createPortalSession');
    const result = await createPortal({
      customerId,
      returnUrl: window.location.origin + '/venue/billing'
    });

    const url = (result.data as any).url;
    window.location.href = url;
  } catch (error) {
    console.error('Customer portal error:', error);
    throw error;
  }
};

// Process one-time payment (for fan features, etc.) using Firebase Functions
export const createOneTimePayment = async (amount: number, description: string) => {
  try {
    // Import Firebase Functions
    const { getFunctions, httpsCallable } = await import('firebase/functions');
    const functions = getFunctions();
    
    // Call Firebase Function
    const createPaymentIntent = httpsCallable(functions, 'createPaymentIntent');
    const result = await createPaymentIntent({
      amount: amount * 100, // Convert to cents
      currency: 'usd',
      description
    });

    const clientSecret = (result.data as any).clientSecret;
    return clientSecret;
  } catch (error) {
    console.error('Payment intent error:', error);
    throw error;
  }
};

export default {
  getStripe,
  SUBSCRIPTION_PLANS,
  FAN_SUBSCRIPTION_PLANS,
  REGULAR_SUBSCRIPTION_PLANS,
  createSubscriptionCheckout,
  signupForFreePlan,
  createCustomerPortalSession,
  createOneTimePayment
}; 
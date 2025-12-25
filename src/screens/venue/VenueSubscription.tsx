import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { auth, db } from '../../firebase/firebaseConfig';
import { doc, getDoc, updateDoc } from 'firebase/firestore';
import { getFunctions, httpsCallable } from 'firebase/functions';
import { SUBSCRIPTION_PLANS } from '../../services/stripeService';
import { getStripe } from '../../services/stripeService';

interface SubscriptionInfo {
  status: string;
  plan: string;
  currentPeriodEnd: Date | null;
  stripeCustomerId: string | null;
}

const VenueSubscription: React.FC = () => {
  const [loading, setLoading] = useState(true);
  const [subscriptionInfo, setSubscriptionInfo] = useState<SubscriptionInfo | null>(null);
  const [venueId, setVenueId] = useState<string | null>(null);
  const navigate = useNavigate();
  const functions = getFunctions();

  useEffect(() => {
    loadSubscriptionInfo();
  }, []);

  const loadSubscriptionInfo = async () => {
    try {
      // For demo purposes, set a mock venue ID and subscription info
      // In production, you'd check auth.currentUser and fetch from Firestore
      const mockVenueId = 'demo-venue-123';
      setVenueId(mockVenueId);
      
      // Set demo subscription info (no active subscription)
      setSubscriptionInfo({
        status: 'inactive',
        plan: 'none',
        currentPeriodEnd: null,
        stripeCustomerId: null
      });
      
      // Uncomment below for production with real authentication:
      /*
      const user = auth.currentUser;
      if (!user) {
        navigate('/login');
        return;
      }

      const venueDocRef = doc(db, 'venues', user.uid);
      const venueDoc = await getDoc(venueDocRef);
      
      if (venueDoc.exists()) {
        const venueData = venueDoc.data();
        setVenueId(user.uid);
        setSubscriptionInfo({
          status: venueData.subscriptionStatus || 'inactive',
          plan: venueData.subscriptionPlan || 'none',
          currentPeriodEnd: venueData.currentPeriodEnd?.toDate() || null,
          stripeCustomerId: venueData.stripeCustomerId || null
        });
      }
      */
    } catch (error) {
      console.error('Error loading subscription info:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleSubscribe = async (planKey: string) => {
    try {
      setLoading(true);
      const plan = SUBSCRIPTION_PLANS[planKey as keyof typeof SUBSCRIPTION_PLANS];
      
      if (!venueId) {
        alert('Venue ID not found. Please try refreshing the page.');
        return;
      }

      // Call Firebase Function to create checkout session
      const createCheckout = httpsCallable(functions, 'createCheckoutSession');
      const result = await createCheckout({
        priceId: plan.priceId,
        venueId: venueId,
        mode: 'subscription'
      });

      // Get session ID and redirect to Stripe Checkout
      const sessionId = (result.data as any).sessionId;
      const stripe = await getStripe();
      
      if (!stripe) {
        throw new Error('Stripe not loaded');
      }
      
      const { error } = await stripe.redirectToCheckout({ sessionId });
      if (error) {
        console.error('Stripe redirect error:', error);
        alert('Failed to redirect to checkout. Please try again.');
      }
    } catch (error) {
      console.error('Error creating subscription:', error);
      alert('Failed to start subscription process. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleManageSubscription = async () => {
    try {
      if (!subscriptionInfo?.stripeCustomerId) {
        alert('No customer found. Please contact support.');
        return;
      }

      // Call Firebase Function directly for customer portal
      const createPortal = httpsCallable(functions, 'createPortalSession');
      const result = await createPortal({
        customerId: subscriptionInfo.stripeCustomerId,
        returnUrl: window.location.origin + '/venue/billing'
      });

      const url = (result.data as any).url;
      window.location.href = url;
    } catch (error) {
      console.error('Error opening customer portal:', error);
      alert('Failed to open subscription management. Please try again.');
    }
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center min-h-screen">
        <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-orange-500"></div>
      </div>
    );
  }

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-pregame-green-500">Subscription Management</h1>
        <p className="text-gray-600 mt-2">Manage your Pregame venue subscription</p>
      </div>

      {/* Current Subscription Status */}
      {subscriptionInfo && (
        <div className="bg-white rounded-lg shadow-md p-6 mb-8">
          <h2 className="text-xl font-semibold text-pregame-green-500 mb-4">Current Subscription</h2>
          
          <div className="grid md:grid-cols-3 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700">Status</label>
              <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                subscriptionInfo.status === 'active' 
                  ? 'bg-green-100 text-green-800'
                  : subscriptionInfo.status === 'canceled'
                  ? 'bg-red-100 text-red-800'
                  : 'bg-gray-100 text-gray-800'
              }`}>
                {subscriptionInfo.status.charAt(0).toUpperCase() + subscriptionInfo.status.slice(1)}
              </span>
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700">Plan</label>
              <p className="text-gray-900 font-medium">
                {subscriptionInfo.plan === 'none' ? 'No active plan' : subscriptionInfo.plan}
              </p>
            </div>
            
            {subscriptionInfo.currentPeriodEnd && (
              <div>
                <label className="block text-sm font-medium text-gray-700">Next Billing Date</label>
                <p className="text-gray-900">
                  {subscriptionInfo.currentPeriodEnd.toLocaleDateString()}
                </p>
              </div>
            )}
          </div>

          {subscriptionInfo.status === 'active' && (
            <div className="mt-6">
              <button
                onClick={handleManageSubscription}
                className="bg-pregame-green-500 text-white px-6 py-2 rounded-lg hover:bg-pregame-green-600 transition-colors"
              >
                Manage Subscription
              </button>
            </div>
          )}
        </div>
      )}

      {/* Subscription Plans */}
      {(!subscriptionInfo || subscriptionInfo.status !== 'active') && (
        <div>
          <h2 className="text-2xl font-bold text-pregame-green-500 mb-6">Choose Your Plan</h2>
          
          <div className="grid md:grid-cols-3 gap-8">
            {Object.entries(SUBSCRIPTION_PLANS).map(([key, plan]) => (
              <div 
                key={key}
                className={`bg-white rounded-xl shadow-lg p-8 ${
                  key === 'pro' ? 'ring-2 ring-orange-500' : ''
                }`}
              >
                {key === 'pro' && (
                  <div className="text-center mb-4">
                    <span className="bg-orange-500 text-white px-4 py-1 rounded-full text-sm font-semibold">
                      Most Popular
                    </span>
                  </div>
                )}
                
                <div className="text-center mb-6">
                                      <h3 className="text-2xl font-bold text-pregame-green-500 mb-2">{plan.name}</h3>
                  <div className="text-4xl font-bold text-pregame-green-500 mb-4">
                    ${plan.price}
                    <span className="text-lg text-gray-600">/month</span>
                  </div>
                </div>

                <ul className="space-y-3 mb-8">
                  {plan.features.map((feature, index) => (
                    <li key={index} className="flex items-center">
                      <svg className="w-5 h-5 text-pregame-green-500 mr-3" fill="currentColor" viewBox="0 0 20 20">
                        <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd"/>
                      </svg>
                      <span className="text-gray-700">{feature}</span>
                    </li>
                  ))}
                </ul>

                <button
                  onClick={() => handleSubscribe(key)}
                  disabled={loading}
                  className={`w-full py-3 rounded-lg font-semibold transition-colors ${
                    key === 'pro'
                      ? 'bg-orange-500 text-white hover:bg-orange-600'
                      : 'bg-pregame-green-500 text-white hover:bg-pregame-green-600'
                  } ${loading ? 'opacity-50 cursor-not-allowed' : ''}`}
                >
                  {loading ? 'Processing...' : 'Subscribe Now'}
                </button>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Billing Information */}
      <div className="mt-12 bg-gray-50 rounded-lg p-6">
        <h3 className="text-lg font-semibold text-pregame-green-500 mb-4">Billing Information</h3>
        <div className="text-sm text-gray-600 space-y-2">
          <p>• All subscriptions are billed monthly</p>
          <p>• You can cancel or change your plan at any time</p>
          <p>• No setup fees or hidden charges</p>
          <p>• Secure payment processing via Stripe</p>
          <p>• 24/7 customer support included</p>
        </div>
      </div>
    </div>
  );
};

export default VenueSubscription; 
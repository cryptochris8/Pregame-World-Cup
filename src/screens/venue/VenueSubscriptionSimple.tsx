import React, { useState, useEffect } from 'react';
import { loadStripe } from '@stripe/stripe-js';
import PregameLogo from '../../assets/pregame_logo.png';
import { environment, validateEnvironment } from '../../config/environment';

// Initialize Stripe with secure environment configuration
const stripePromise = loadStripe(environment.stripePublishableKey);

interface SubscriptionInfo {
  status: string;
  plan: string;
  currentPeriodEnd: Date | null;
  stripeCustomerId: string | null;
}

const VenueSubscriptionSimple: React.FC = () => {
  const [loading, setLoading] = useState(false);
  const [subscriptionInfo, setSubscriptionInfo] = useState<SubscriptionInfo | null>(null);

  // Early Bird pricing structure (restored original)
  const subscriptionPlans = {
    basic: {
      name: 'Basic (Early Bird Special)',
      priceId: 'price_1RYpTMQ811jRCI3C9vVGazTM',
      price: 49,
      originalPrice: 79,
      earlyBird: true,
      popular: false,
      features: [
        'Venue profile management',
        'Basic specials promotion',
        'Customer messaging',
        'Basic analytics'
      ]
    },
    pro: {
      name: 'Pro (Early Bird Special)',
      priceId: 'price_1RYqeoQ811jRCI3CAq5mVLGw',
      price: 99,
      originalPrice: 149,
      earlyBird: true,
      popular: true,
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
      priceId: 'price_1RYqfIQ811jRCI3CAJbma9Lu',
      price: 199,
      originalPrice: 299,
      earlyBird: true,
      popular: false,
      features: [
        'Everything in Pro',
        'Multiple locations',
        'Custom integrations',
        'Dedicated account manager',
        'Revenue sharing options'
      ]
    }
  };

  useEffect(() => {
    // Simulate fetching subscription info
    // In real app, this would come from your backend
    setSubscriptionInfo(null); // No active subscription for demo
  }, []);

  const handleSubscribe = async (priceId: string) => {
    try {
      setLoading(true);
      
      const stripe = await stripePromise;
      if (!stripe) {
        throw new Error('Stripe failed to load');
      }

      // Create checkout session
      const response = await fetch(`https://us-central1-pregame-6c1e9.cloudfunctions.net/createCheckoutSession`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          priceId,
          venueId: `venue_${Date.now()}`, // In real app, get from user context
          successUrl: `${window.location.origin}/venue/dashboard?success=true`,
          cancelUrl: window.location.href,
        }),
      });

      if (!response.ok) {
        throw new Error('Failed to create checkout session');
      }

      const { sessionId } = await response.json();

      // Redirect to Stripe Checkout
      const result = await stripe.redirectToCheckout({
        sessionId,
      });

      if (result.error) {
        throw new Error(result.error.message);
      }
    } catch (error) {
      console.error('Subscription error:', error);
      alert('Subscription failed. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleManageSubscription = () => {
    // In real app, redirect to Stripe customer portal
    alert('Demo: Would redirect to Stripe customer portal for subscription management');
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center min-h-screen pregame-gradient">
        <div className="animate-spin rounded-full h-16 w-16 border-b-2 border-white"></div>
      </div>
    );
  }

  return (
    <div className="min-h-screen" style={{ background: 'var(--pregame-dark-bg)' }}>
      {/* Header with Pregame gradient */}
      <div className="pregame-gradient">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
          <div className="text-center text-white">
            <div className="flex items-center justify-center mb-6">
              <img src={PregameLogo} alt="Pregame" className="h-12 w-auto mr-4" />
              <h1 className="text-5xl font-bold">for Venues</h1>
            </div>
            <p className="mt-4 text-xl opacity-90 max-w-2xl mx-auto">
              Connect with college football fans and grow your game day business
            </p>
            <div className="mt-6 inline-flex items-center px-6 py-3 bg-white bg-opacity-20 backdrop-blur-sm text-white rounded-full text-lg font-medium">
              🔥 Early Bird Pricing - Limited Time!
            </div>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        {/* Current Subscription Status */}
        {subscriptionInfo && subscriptionInfo.status === 'active' && (
          <div className="pregame-card mb-12 border-l-4 border-green-500">
            <div className="flex items-center justify-between">
              <div>
                <h2 className="text-2xl font-bold mb-2" style={{ color: 'var(--pregame-text-light)' }}>✅ Active Subscription</h2>
                <div className="flex items-center space-x-6">
                  <div>
                    <p className="text-sm font-medium" style={{ color: 'var(--pregame-text-muted)' }}>Status</p>
                    <span className="inline-flex px-3 py-1 text-sm font-semibold rounded-full bg-green-500 bg-opacity-20 text-green-400">
                      Active
                    </span>
                  </div>
                  <div>
                    <p className="text-sm font-medium" style={{ color: 'var(--pregame-text-muted)' }}>Plan</p>
                    <p className="font-bold" style={{ color: 'var(--pregame-text-light)' }}>{subscriptionInfo.plan}</p>
                  </div>
                  <div>
                    <p className="text-sm font-medium" style={{ color: 'var(--pregame-text-muted)' }}>Next Billing</p>
                    <p className="font-bold" style={{ color: 'var(--pregame-text-light)' }}>
                      {subscriptionInfo.currentPeriodEnd?.toLocaleDateString()}
                    </p>
                  </div>
                </div>
              </div>
              <button
                onClick={handleManageSubscription}
                className="btn-pregame-primary"
              >
                Manage Subscription
              </button>
            </div>
          </div>
        )}

        {/* Subscription Plans */}
        {(!subscriptionInfo || subscriptionInfo.status !== 'active') && (
          <div className="grid lg:grid-cols-3 gap-8 mb-12">
            {Object.entries(subscriptionPlans).map(([key, plan]) => (
              <div 
                key={key} 
                className={`pregame-card relative ${plan.popular ? 'transform scale-105 border-orange-500' : ''}`}
                style={plan.popular ? { 
                  background: 'rgba(255, 165, 0, 0.05)',
                  borderColor: '#ff6b35'
                } : {}}
              >
                {plan.popular && (
                  <div className="absolute -top-4 left-1/2 transform -translate-x-1/2 z-10">
                    <span className="bg-orange-500 text-white px-6 py-2 rounded-full text-sm font-bold shadow-lg">
                      🏆 Most Popular
                    </span>
                  </div>
                )}
                
                {/* Plan Header */}
                <div className="text-center mb-8">
                  <h3 className="text-2xl font-bold mb-2" style={{ color: 'var(--pregame-text-light)' }}>
                    {plan.name}
                  </h3>
                  
                  {/* Early Bird Badge */}
                  {plan.earlyBird && (
                    <div className="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-red-500 bg-opacity-20 text-red-400 mb-4">
                      🔥 Early Bird Special
                    </div>
                  )}
                  
                  {/* Price Display */}
                  <div className="mb-6">
                    <div className="flex items-center justify-center">
                      <span className="text-5xl font-bold" style={{ color: plan.popular ? 'var(--pregame-orange)' : 'var(--pregame-text-light)' }}>
                        ${plan.price}
                      </span>
                      <span className="text-xl ml-2" style={{ color: 'var(--pregame-text-muted)' }}>/month</span>
                    </div>
                    {plan.earlyBird && (
                      <p className="text-sm" style={{ color: 'var(--pregame-text-muted)' }}>
                        Regular price: <span className="line-through">${plan.originalPrice}/month</span>
                      </p>
                    )}
                  </div>
                </div>

                {/* Features List */}
                <div className="mb-8">
                  <h4 className="font-semibold mb-4" style={{ color: 'var(--pregame-text-light)' }}>What's included:</h4>
                  <ul className="space-y-3">
                    {plan.features.map((feature, index) => (
                      <li key={index} className="flex items-start">
                        <span style={{ color: plan.popular ? 'var(--pregame-orange)' : '#22c55e' }} className="mr-3 mt-1">✓</span>
                        <span style={{ color: 'var(--pregame-text-muted)' }}>{feature}</span>
                      </li>
                    ))}
                  </ul>
                </div>

                {/* CTA Button */}
                <button
                  onClick={() => handleSubscribe(plan.priceId)}
                  disabled={loading}
                  className={`w-full py-4 px-6 rounded-lg font-bold text-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed ${
                    plan.popular 
                      ? 'btn-pregame-primary' 
                      : 'bg-white bg-opacity-10 hover:bg-opacity-20 text-white border border-gray-600'
                  }`}
                >
                  {loading ? 'Processing...' : `Get ${plan.name.split(' ')[0]}`}
                </button>
              </div>
            ))}
          </div>
        )}

        {/* Trust Indicators */}
        <div className="text-center py-12">
          <div className="max-w-4xl mx-auto">
            <h3 className="text-2xl font-bold mb-8" style={{ color: 'var(--pregame-text-light)' }}>
              Trusted by sports venues across the SEC
            </h3>
            <div className="grid md:grid-cols-3 gap-8">
              <div className="pregame-card text-center">
                <div className="text-3xl font-bold" style={{ color: 'var(--pregame-orange)' }}>500+</div>
                <p style={{ color: 'var(--pregame-text-muted)' }}>Venues Connected</p>
              </div>
              <div className="pregame-card text-center">
                <div className="text-3xl font-bold" style={{ color: 'var(--pregame-orange)' }}>50K+</div>
                <p style={{ color: 'var(--pregame-text-muted)' }}>Fans Engaged</p>
              </div>
              <div className="pregame-card text-center">
                <div className="text-3xl font-bold" style={{ color: 'var(--pregame-orange)' }}>$2M+</div>
                <p style={{ color: 'var(--pregame-text-muted)' }}>Revenue Generated</p>
              </div>
            </div>
          </div>
        </div>

        {/* FAQ Section */}
        <div className="max-w-4xl mx-auto py-12">
          <h3 className="text-2xl font-bold text-center mb-8" style={{ color: 'var(--pregame-text-light)' }}>
            Frequently Asked Questions
          </h3>
          <div className="space-y-6">
            <div className="pregame-card">
              <h4 className="font-semibold mb-2" style={{ color: 'var(--pregame-text-light)' }}>
                How long is the Early Bird pricing available?
              </h4>
              <p style={{ color: 'var(--pregame-text-muted)' }}>
                Early Bird pricing is available for a limited time during our launch phase. 
                Lock in these rates now and keep them as long as you maintain your subscription.
              </p>
            </div>
            <div className="pregame-card">
              <h4 className="font-semibold mb-2" style={{ color: 'var(--pregame-text-light)' }}>
                Can I change plans later?
              </h4>
              <p style={{ color: 'var(--pregame-text-muted)' }}>
                Yes! You can upgrade or downgrade your plan anytime. Changes take effect at your next billing cycle.
              </p>
            </div>
            <div className="pregame-card">
              <h4 className="font-semibold mb-2" style={{ color: 'var(--pregame-text-light)' }}>
                What payment methods do you accept?
              </h4>
              <p style={{ color: 'var(--pregame-text-muted)' }}>
                We accept all major credit cards (Visa, MasterCard, American Express) and debit cards 
                through our secure Stripe payment processing.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default VenueSubscriptionSimple; 
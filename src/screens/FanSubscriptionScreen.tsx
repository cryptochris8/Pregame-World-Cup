import React, { useState, useEffect } from 'react';
import { loadStripe } from '@stripe/stripe-js';
import PregameLogo from '../assets/pregame_logo.png';
import { environment, validateEnvironment } from '../config/environment';
import { FAN_SUBSCRIPTION_PLANS } from '../services/stripeService';

// Initialize Stripe with secure environment configuration
const stripePromise = loadStripe(environment.stripePublishableKey);

interface FanSubscriptionInfo {
  status: string;
  plan: string;
  currentPeriodEnd: Date | null;
  stripeCustomerId: string | null;
}

const FanSubscriptionScreen: React.FC = () => {
  const [loading, setLoading] = useState(false);
  const [subscriptionInfo, setSubscriptionInfo] = useState<FanSubscriptionInfo | null>(null);

  useEffect(() => {
    // Simulate fetching subscription info
    // In real app, this would come from your backend
    setSubscriptionInfo(null); // No active subscription for demo
  }, []);

  const handleFreePlanSignup = async () => {
    try {
      setLoading(true);
      
      // Generate a demo fan ID (in real app, this would come from user context)
      const fanId = `fan_${Date.now()}`;
      
      // Sign up for free plan (no Stripe needed)
      // This would create a free fan account in your database
      console.log('Free fan plan signup for:', fanId);
      
      // Show success message
      alert('🎉 Welcome to Pregame! Your free fan account is ready. You can upgrade to Premium anytime for exclusive features.');
      
      // In real app, redirect to fan dashboard
      console.log('Free fan plan signup successful');
      
    } catch (error) {
      console.error('Free fan plan signup error:', error);
      alert('Signup failed. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const handlePremiumSubscribe = async () => {
    try {
      setLoading(true);
      
      // Generate a demo fan ID (in real app, this would come from user context)
      const fanId = `fan_${Date.now()}`;
      
      // Create Stripe checkout for premium fan plan
      const stripe = await stripePromise;
      if (!stripe) {
        throw new Error('Stripe failed to load');
      }

      // Create checkout session for fan subscription
      const response = await fetch(`https://us-central1-pregame-6c1e9.cloudfunctions.net/createFanCheckoutSession`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          priceId: FAN_SUBSCRIPTION_PLANS.premium.priceId,
          fanId: fanId,
          successUrl: `${window.location.origin}/fan/dashboard?success=true`,
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
      console.error('Premium fan subscription error:', error);
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
              <h1 className="text-5xl font-bold">for Fans</h1>
            </div>
            <p className="mt-4 text-xl opacity-90 max-w-2xl mx-auto">
              Start free and unlock premium fan experiences
            </p>
            <div className="mt-6 inline-flex items-center px-6 py-3 bg-white bg-opacity-20 backdrop-blur-sm text-white rounded-full text-lg font-medium">
              🚀 Start Free Today - No Credit Card Required!
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
          <div className="grid lg:grid-cols-2 gap-8 mb-12 max-w-5xl mx-auto">
            {/* Free Plan */}
            <div className="pregame-card relative transform scale-105 border-green-500 bg-opacity-30" style={{ 
              background: 'rgba(34, 197, 94, 0.05)',
              borderColor: '#22c55e'
            }}>
              <div className="absolute -top-4 left-1/2 transform -translate-x-1/2 z-10">
                <span className="bg-green-500 text-white px-6 py-2 rounded-full text-sm font-bold shadow-lg">
                  🎉 Most Popular
                </span>
              </div>
              
              {/* Plan Header */}
              <div className="text-center mb-8">
                <h3 className="text-2xl font-bold mb-2" style={{ color: 'var(--pregame-text-light)' }}>
                  {FAN_SUBSCRIPTION_PLANS.free.name}
                </h3>
                <p className="mb-6" style={{ color: 'var(--pregame-text-muted)' }}>
                  Perfect to get started
                </p>
                
                {/* Price Display */}
                <div className="mb-6">
                  <div className="flex items-center justify-center">
                    <span className="text-5xl font-bold text-green-400">$0</span>
                    <span className="text-xl ml-2" style={{ color: 'var(--pregame-text-muted)' }}>/month</span>
                  </div>
                  <p className="text-lg font-medium text-green-400 mt-2">
                    Forever Free
                  </p>
                </div>
              </div>

              {/* Features List */}
              <div className="mb-8">
                <h4 className="font-semibold mb-4" style={{ color: 'var(--pregame-text-light)' }}>What's included:</h4>
                <ul className="space-y-3">
                  {FAN_SUBSCRIPTION_PLANS.free.features.map((feature, index) => (
                    <li key={index} className="flex items-start">
                      <span className="text-green-400 mr-3 mt-1">✓</span>
                      <span style={{ color: 'var(--pregame-text-muted)' }}>{feature}</span>
                    </li>
                  ))}
                </ul>
              </div>

              {/* CTA Button */}
              <button
                onClick={handleFreePlanSignup}
                disabled={loading}
                className="w-full bg-green-500 hover:bg-green-600 text-white font-bold py-4 px-6 rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed text-lg"
              >
                {loading ? 'Setting up...' : 'Start Free Today'}
              </button>
            </div>

            {/* Premium Plan */}
            <div className="pregame-card relative">
              {/* Plan Header */}
              <div className="text-center mb-8">
                <h3 className="text-2xl font-bold mb-2" style={{ color: 'var(--pregame-text-light)' }}>
                  {FAN_SUBSCRIPTION_PLANS.premium.name}
                </h3>
                <p className="mb-6" style={{ color: 'var(--pregame-text-muted)' }}>
                  Unlock exclusive features
                </p>
                
                {/* Price Display */}
                <div className="mb-6">
                  <div className="flex items-center justify-center">
                    <span className="text-5xl font-bold" style={{ color: 'var(--pregame-orange)' }}>
                      ${FAN_SUBSCRIPTION_PLANS.premium.price}
                    </span>
                    <span className="text-xl ml-2" style={{ color: 'var(--pregame-text-muted)' }}>/month</span>
                  </div>
                  <p className="text-lg font-medium" style={{ color: 'var(--pregame-orange)' }}>
                    Cancel anytime
                  </p>
                </div>
              </div>

              {/* Features List */}
              <div className="mb-8">
                <h4 className="font-semibold mb-4" style={{ color: 'var(--pregame-text-light)' }}>Everything in Free, plus:</h4>
                <ul className="space-y-3">
                  {FAN_SUBSCRIPTION_PLANS.premium.features.slice(1).map((feature, index) => (
                    <li key={index} className="flex items-start">
                      <span style={{ color: 'var(--pregame-orange)' }} className="mr-3 mt-1">✓</span>
                      <span style={{ color: 'var(--pregame-text-muted)' }}>{feature}</span>
                    </li>
                  ))}
                </ul>
              </div>

              {/* CTA Button */}
              <button
                onClick={handlePremiumSubscribe}
                disabled={loading}
                className="btn-pregame-primary w-full py-4 text-lg disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {loading ? 'Processing...' : 'Upgrade to Premium'}
              </button>
            </div>
          </div>
        )}

        {/* Trust Indicators */}
        <div className="text-center py-12">
          <div className="max-w-4xl mx-auto">
            <h3 className="text-2xl font-bold mb-8" style={{ color: 'var(--pregame-text-light)' }}>
              Join thousands of SEC fans already using Pregame
            </h3>
            <div className="grid md:grid-cols-3 gap-8">
              <div className="pregame-card text-center">
                <div className="text-3xl font-bold" style={{ color: 'var(--pregame-orange)' }}>50K+</div>
                <p style={{ color: 'var(--pregame-text-muted)' }}>Active Fans</p>
              </div>
              <div className="pregame-card text-center">
                <div className="text-3xl font-bold" style={{ color: 'var(--pregame-orange)' }}>500+</div>
                <p style={{ color: 'var(--pregame-text-muted)' }}>Partner Venues</p>
              </div>
              <div className="pregame-card text-center">
                <div className="text-3xl font-bold" style={{ color: 'var(--pregame-orange)' }}>4.8★</div>
                <p style={{ color: 'var(--pregame-text-muted)' }}>App Store Rating</p>
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
                Is the free plan really free forever?
              </h4>
              <p style={{ color: 'var(--pregame-text-muted)' }}>
                Yes! Our free plan includes all the essential features to get started and will always be free. 
                You can upgrade to Premium anytime for exclusive fan features.
              </p>
            </div>
            <div className="pregame-card">
              <h4 className="font-semibold mb-2" style={{ color: 'var(--pregame-text-light)' }}>
                What makes Premium worth it?
              </h4>
              <p style={{ color: 'var(--pregame-text-muted)' }}>
                Premium gives you advanced game insights, priority venue reservations, exclusive content, 
                ad-free experience, and special perks at partner venues.
              </p>
            </div>
            <div className="pregame-card">
              <h4 className="font-semibold mb-2" style={{ color: 'var(--pregame-text-light)' }}>
                Can I cancel my Premium subscription anytime?
              </h4>
              <p style={{ color: 'var(--pregame-text-muted)' }}>
                Absolutely! You can cancel your Premium subscription anytime and you'll automatically be moved 
                back to our free plan. No contracts or cancellation fees.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default FanSubscriptionScreen; 
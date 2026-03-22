import React, { useState } from 'react';
import { loadStripe } from '@stripe/stripe-js';
import PregameLogo from '../../assets/pregame_logo.png';
import { environment } from '../../config/environment';

// Initialize Stripe with secure environment configuration
const stripePromise = loadStripe(environment.stripePublishableKey);

const PRICE_ID = 'price_1RYpTMQ811jRCI3C9vVGazTM'; // One-time $499 World Cup listing fee

const VenueSubscriptionSimple: React.FC = () => {
  const [loading, setLoading] = useState(false);
  const [purchased, setPurchased] = useState(false);

  const handlePurchase = async () => {
    try {
      setLoading(true);

      const stripe = await stripePromise;
      if (!stripe) {
        throw new Error('Stripe failed to load');
      }

      const response = await fetch(`https://us-central1-pregame-6c1e9.cloudfunctions.net/createCheckoutSession`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          priceId: PRICE_ID,
          venueId: `venue_${Date.now()}`,
          successUrl: `${window.location.origin}/venue/dashboard?success=true`,
          cancelUrl: window.location.href,
        }),
      });

      if (!response.ok) {
        throw new Error('Failed to create checkout session');
      }

      const { sessionId } = await response.json();
      const result = await stripe.redirectToCheckout({ sessionId });

      if (result.error) {
        throw new Error(result.error.message);
      }
    } catch (error) {
      console.error('Purchase error:', error);
      alert('Payment failed. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center min-h-screen pregame-gradient">
        <div className="animate-spin rounded-full h-16 w-16 border-b-2 border-white"></div>
      </div>
    );
  }

  if (purchased) {
    return (
      <div className="flex justify-center items-center min-h-screen" style={{ background: 'var(--pregame-dark-bg)' }}>
        <div className="pregame-card text-center max-w-md">
          <div className="text-6xl mb-4">✅</div>
          <h2 className="text-2xl font-bold mb-2" style={{ color: 'var(--pregame-text-light)' }}>You're Listed!</h2>
          <p style={{ color: 'var(--pregame-text-muted)' }}>
            Your venue is now live on Pregame for World Cup 2026. Fans can find you, RSVP to watch parties, and see your match day specials.
          </p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen" style={{ background: 'var(--pregame-dark-bg)' }}>
      {/* Header */}
      <div className="pregame-gradient">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-16 text-center text-white">
          <div className="flex items-center justify-center mb-6">
            <img src={PregameLogo} alt="Pregame" className="h-12 w-auto mr-4" />
            <h1 className="text-5xl font-bold">for Venues</h1>
          </div>
          <p className="mt-4 text-xl opacity-90 max-w-2xl mx-auto">
            Get your venue in front of World Cup 2026 fans looking for the perfect place to watch every match
          </p>
        </div>
      </div>

      <div className="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8 py-16">

        {/* Single Pricing Card */}
        <div className="pregame-card text-center mb-12" style={{ borderColor: '#ff6b35', borderWidth: '2px' }}>
          <div className="inline-flex items-center px-4 py-2 rounded-full text-sm font-medium bg-orange-500 bg-opacity-20 text-orange-400 mb-6">
            ⚽ World Cup 2026 Venue Listing
          </div>

          <div className="mb-8">
            <div className="flex items-end justify-center gap-2 mb-2">
              <span className="text-7xl font-bold" style={{ color: 'var(--pregame-orange)' }}>$499</span>
            </div>
            <p className="text-lg" style={{ color: 'var(--pregame-text-muted)' }}>
              One-time fee — full access for the entire tournament
            </p>
          </div>

          {/* Features */}
          <div className="text-left mb-10">
            <h4 className="font-semibold mb-6 text-center text-lg" style={{ color: 'var(--pregame-text-light)' }}>
              Everything included:
            </h4>
            <ul className="space-y-4">
              {[
                'Venue profile listed in the Pregame app',
                'Appear in World Cup match day venue searches',
                'Host & promote watch parties with fan RSVP',
                'Post match day specials & drink deals',
                'Fan check-ins, reviews, and photos',
                'Live stream your venue atmosphere',
                'Direct fan messaging & notifications',
                'Match day crowd & revenue analytics',
                'Full access through the 2026 World Cup Final',
              ].map((feature, i) => (
                <li key={i} className="flex items-start gap-3">
                  <span className="text-orange-400 mt-0.5 text-lg">✓</span>
                  <span style={{ color: 'var(--pregame-text-muted)' }}>{feature}</span>
                </li>
              ))}
            </ul>
          </div>

          <button
            onClick={handlePurchase}
            disabled={loading}
            className="w-full btn-pregame-primary py-5 text-xl font-bold rounded-xl disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {loading ? 'Processing...' : 'Get Listed for $499'}
          </button>

          <p className="mt-4 text-sm" style={{ color: 'var(--pregame-text-muted)' }}>
            Secure payment via Stripe. No recurring charges.
          </p>
        </div>

        {/* Trust Indicators */}
        <div className="grid grid-cols-3 gap-6 mb-16">
          <div className="pregame-card text-center py-6">
            <div className="text-3xl font-bold" style={{ color: 'var(--pregame-orange)' }}>500+</div>
            <p className="text-sm mt-1" style={{ color: 'var(--pregame-text-muted)' }}>Venues Listed</p>
          </div>
          <div className="pregame-card text-center py-6">
            <div className="text-3xl font-bold" style={{ color: 'var(--pregame-orange)' }}>50K+</div>
            <p className="text-sm mt-1" style={{ color: 'var(--pregame-text-muted)' }}>Active Fans</p>
          </div>
          <div className="pregame-card text-center py-6">
            <div className="text-3xl font-bold" style={{ color: 'var(--pregame-orange)' }}>104</div>
            <p className="text-sm mt-1" style={{ color: 'var(--pregame-text-muted)' }}>Matches to Promote</p>
          </div>
        </div>

        {/* FAQ */}
        <div>
          <h3 className="text-2xl font-bold text-center mb-8" style={{ color: 'var(--pregame-text-light)' }}>
            Frequently Asked Questions
          </h3>
          <div className="space-y-4">
            {[
              {
                q: 'Is this really a one-time fee?',
                a: 'Yes. Pay $499 once and your venue is listed on Pregame for the entire 2026 FIFA World Cup — from the group stage through the Final in July 2026. No monthly charges, no renewals.',
              },
              {
                q: 'When does my listing go live?',
                a: 'Immediately after payment. Your venue profile will be visible to fans in the Pregame app right away, and you can start adding specials and watch parties.',
              },
              {
                q: 'What payment methods do you accept?',
                a: 'All major credit and debit cards (Visa, Mastercard, American Express) via secure Stripe checkout.',
              },
              {
                q: 'What happens after the World Cup?',
                a: 'Your listing covers the full 2026 tournament. We\'ll reach out closer to the end with options for continued listing for future events.',
              },
            ].map((item, i) => (
              <div key={i} className="pregame-card">
                <h4 className="font-semibold mb-2" style={{ color: 'var(--pregame-text-light)' }}>{item.q}</h4>
                <p style={{ color: 'var(--pregame-text-muted)' }}>{item.a}</p>
              </div>
            ))}
          </div>
        </div>

      </div>
    </div>
  );
};

export default VenueSubscriptionSimple;

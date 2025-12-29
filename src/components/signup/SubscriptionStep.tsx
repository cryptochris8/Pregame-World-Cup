import React from 'react';
import { WizardData } from '../../screens/venue/VenueSignupWizard';

interface SubscriptionStepProps {
  data: WizardData;
  updateData: (updates: Partial<WizardData>) => void;
  onNext: () => void;
  onBack: () => void;
}

interface PlanInfo {
  id: 'basic' | 'pro' | 'enterprise';
  name: string;
  price: number;
  description: string;
  features: string[];
  popular?: boolean;
}

const PLANS: PlanInfo[] = [
  {
    id: 'basic',
    name: 'Basic',
    price: 49,
    description: 'Perfect for getting started',
    features: [
      'Venue profile listing',
      'Basic analytics',
      'Game schedule integration',
      'Up to 3 photos',
      'Email support',
    ],
  },
  {
    id: 'pro',
    name: 'Pro',
    price: 99,
    description: 'Most popular for sports bars',
    features: [
      'Everything in Basic',
      'Advanced analytics dashboard',
      'Game day specials manager',
      'Unlimited photos',
      'Fan engagement tools',
      'Priority support',
      'Featured placement',
    ],
    popular: true,
  },
  {
    id: 'enterprise',
    name: 'Enterprise',
    price: 199,
    description: 'For multi-location venues',
    features: [
      'Everything in Pro',
      'Multi-location management',
      'Live streaming capabilities',
      'Custom branding',
      'API access',
      'Dedicated account manager',
      'White-glove onboarding',
    ],
  },
];

const SubscriptionStep: React.FC<SubscriptionStepProps> = ({
  data,
  updateData,
  onNext,
  onBack,
}) => {
  const handlePlanSelect = (planId: 'basic' | 'pro' | 'enterprise') => {
    updateData({ selectedPlan: planId });
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onNext();
  };

  return (
    <div className="pregame-card">
      <h2 className="text-2xl font-bold mb-2 text-center" style={{ color: 'var(--pregame-text-light)' }}>
        Choose Your Plan
      </h2>
      <p className="mb-8 text-center" style={{ color: 'var(--pregame-text-muted)' }}>
        Select the plan that works best for your venue
      </p>

      <form onSubmit={handleSubmit}>
        {/* Plan Cards */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-8">
          {PLANS.map((plan) => {
            const isSelected = data.selectedPlan === plan.id;

            return (
              <div
                key={plan.id}
                onClick={() => handlePlanSelect(plan.id)}
                className={`relative p-5 rounded-xl border-2 cursor-pointer transition-all duration-200 ${
                  isSelected
                    ? 'border-orange-500 bg-orange-500/10'
                    : 'border-gray-600 hover:border-gray-500'
                }`}
                style={{ background: isSelected ? 'rgba(255, 107, 53, 0.1)' : 'rgba(255, 255, 255, 0.03)' }}
              >
                {/* Popular Badge */}
                {plan.popular && (
                  <div className="absolute -top-3 left-1/2 transform -translate-x-1/2">
                    <span className="px-3 py-1 text-xs font-bold rounded-full bg-orange-500 text-white">
                      POPULAR
                    </span>
                  </div>
                )}

                {/* Plan Header */}
                <div className="text-center mb-4">
                  <h3 className="text-xl font-bold" style={{ color: 'var(--pregame-text-light)' }}>
                    {plan.name}
                  </h3>
                  <p className="text-sm" style={{ color: 'var(--pregame-text-muted)' }}>
                    {plan.description}
                  </p>
                </div>

                {/* Price */}
                <div className="text-center mb-4">
                  <span className="text-4xl font-bold" style={{ color: 'var(--pregame-text-light)' }}>
                    ${plan.price}
                  </span>
                  <span className="text-sm" style={{ color: 'var(--pregame-text-muted)' }}>
                    /month
                  </span>
                </div>

                {/* Features */}
                <ul className="space-y-2">
                  {plan.features.map((feature, index) => (
                    <li key={index} className="flex items-start gap-2 text-sm">
                      <span className="text-green-400 mt-0.5">✓</span>
                      <span style={{ color: 'var(--pregame-text-light)' }}>{feature}</span>
                    </li>
                  ))}
                </ul>

                {/* Selection Indicator */}
                {isSelected && (
                  <div className="absolute top-3 right-3">
                    <div className="w-6 h-6 rounded-full bg-orange-500 flex items-center justify-center">
                      <span className="text-white text-sm">✓</span>
                    </div>
                  </div>
                )}
              </div>
            );
          })}
        </div>

        <p className="text-xs text-center mb-6" style={{ color: 'var(--pregame-text-muted)' }}>
          All plans include a 14-day free trial. Cancel anytime. No credit card required to start.
        </p>

        {/* Navigation Buttons */}
        <div className="flex gap-4">
          <button
            type="button"
            onClick={onBack}
            className="flex-1 py-3 px-4 text-lg font-semibold rounded-xl border-2 transition-all duration-200 hover:border-orange-500"
            style={{
              background: 'transparent',
              color: 'var(--pregame-text-light)',
              borderColor: 'rgba(255, 255, 255, 0.2)',
            }}
          >
            Back
          </button>
          <button
            type="submit"
            className="flex-1 btn-pregame-primary py-3 px-4 text-lg font-semibold rounded-xl transition-all duration-200"
          >
            Start Free Trial
          </button>
        </div>
      </form>
    </div>
  );
};

export default SubscriptionStep;

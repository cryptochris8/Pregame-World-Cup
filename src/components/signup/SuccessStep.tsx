import React from 'react';

interface SuccessStepProps {
  venueName: string;
  selectedPlan: 'basic' | 'pro' | 'enterprise';
  onGoToDashboard: () => void;
  onSetupBilling: () => void;
}

const PLAN_NAMES = {
  basic: 'Basic',
  pro: 'Pro',
  enterprise: 'Enterprise',
};

const SuccessStep: React.FC<SuccessStepProps> = ({
  venueName,
  selectedPlan,
  onGoToDashboard,
  onSetupBilling,
}) => {
  return (
    <div className="pregame-card text-center">
      {/* Success Icon */}
      <div className="mb-6">
        <div className="w-20 h-20 mx-auto rounded-full bg-green-500/20 flex items-center justify-center">
          <svg
            className="w-10 h-10 text-green-500"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M5 13l4 4L19 7"
            />
          </svg>
        </div>
      </div>

      {/* Welcome Message */}
      <h2 className="text-3xl font-bold mb-2" style={{ color: 'var(--pregame-text-light)' }}>
        Welcome to Pregame!
      </h2>
      <p className="text-lg mb-6" style={{ color: 'var(--pregame-text-muted)' }}>
        <strong style={{ color: 'var(--pregame-text-light)' }}>{venueName}</strong> has been created successfully
      </p>

      {/* Plan Info */}
      <div
        className="inline-block px-6 py-3 rounded-xl mb-8"
        style={{ background: 'rgba(255, 255, 255, 0.05)' }}
      >
        <p className="text-sm" style={{ color: 'var(--pregame-text-muted)' }}>
          Your selected plan
        </p>
        <p className="text-xl font-bold" style={{ color: 'var(--pregame-orange)' }}>
          {PLAN_NAMES[selectedPlan]} Plan
        </p>
        <p className="text-sm" style={{ color: 'var(--pregame-text-muted)' }}>
          14-day free trial
        </p>
      </div>

      {/* Next Steps */}
      <div className="text-left mb-8 p-5 rounded-xl" style={{ background: 'rgba(255, 255, 255, 0.05)' }}>
        <h3 className="font-bold mb-4" style={{ color: 'var(--pregame-text-light)' }}>
          Next Steps:
        </h3>
        <ul className="space-y-3">
          <li className="flex items-start gap-3">
            <span
              className="w-6 h-6 rounded-full flex items-center justify-center flex-shrink-0 text-sm font-bold"
              style={{ background: 'var(--pregame-orange)', color: 'white' }}
            >
              1
            </span>
            <div>
              <p className="font-medium" style={{ color: 'var(--pregame-text-light)' }}>
                Complete your profile
              </p>
              <p className="text-sm" style={{ color: 'var(--pregame-text-muted)' }}>
                Add photos, amenities, and more details to attract fans
              </p>
            </div>
          </li>
          <li className="flex items-start gap-3">
            <span
              className="w-6 h-6 rounded-full flex items-center justify-center flex-shrink-0 text-sm font-bold"
              style={{ background: 'var(--pregame-orange)', color: 'white' }}
            >
              2
            </span>
            <div>
              <p className="font-medium" style={{ color: 'var(--pregame-text-light)' }}>
                Create game day specials
              </p>
              <p className="text-sm" style={{ color: 'var(--pregame-text-muted)' }}>
                Set up food & drink deals to bring in the crowds
              </p>
            </div>
          </li>
          <li className="flex items-start gap-3">
            <span
              className="w-6 h-6 rounded-full flex items-center justify-center flex-shrink-0 text-sm font-bold"
              style={{ background: 'var(--pregame-orange)', color: 'white' }}
            >
              3
            </span>
            <div>
              <p className="font-medium" style={{ color: 'var(--pregame-text-light)' }}>
                Get discovered by fans
              </p>
              <p className="text-sm" style={{ color: 'var(--pregame-text-muted)' }}>
                Your venue will appear in search results for World Cup 2026
              </p>
            </div>
          </li>
        </ul>
      </div>

      {/* Action Buttons */}
      <div className="space-y-3">
        <button
          onClick={onGoToDashboard}
          className="w-full btn-pregame-primary py-3 px-4 text-lg font-semibold rounded-xl transition-all duration-200"
        >
          Go to Dashboard
        </button>
        <button
          onClick={onSetupBilling}
          className="w-full py-3 px-4 text-lg font-semibold rounded-xl border-2 transition-all duration-200 hover:border-orange-500"
          style={{
            background: 'transparent',
            color: 'var(--pregame-text-light)',
            borderColor: 'rgba(255, 255, 255, 0.2)',
          }}
        >
          Set Up Billing Now
        </button>
      </div>

      <p className="text-xs mt-6" style={{ color: 'var(--pregame-text-muted)' }}>
        Your free trial starts today. We'll remind you before it ends.
      </p>
    </div>
  );
};

export default SuccessStep;

import React from 'react';

interface SuccessStepProps {
  venueName: string;
  onPayNow: () => void;
  onGoToDashboard: () => void;
}

const SuccessStep: React.FC<SuccessStepProps> = ({
  venueName,
  onPayNow,
  onGoToDashboard,
}) => {
  return (
    <div className="pregame-card text-center">
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

      <h2 className="text-3xl font-bold mb-2" style={{ color: 'var(--pregame-text-light)' }}>
        You're in!
      </h2>
      <p className="text-lg mb-6" style={{ color: 'var(--pregame-text-muted)' }}>
        <strong style={{ color: 'var(--pregame-text-light)' }}>{venueName}</strong> is verified and
        ready to go.
      </p>

      <div
        className="text-left mb-8 p-5 rounded-xl space-y-3"
        style={{ background: 'rgba(255, 255, 255, 0.05)' }}
      >
        <h3 className="font-bold" style={{ color: 'var(--pregame-text-light)' }}>
          One more step to go live
        </h3>
        <p className="text-sm" style={{ color: 'var(--pregame-text-muted)' }}>
          Your venue account is created and verified. Grab the Tournament Pass below to start
          appearing in fan searches, run game-day specials, and host watch parties — or jump into
          the dashboard now to add photos and finish your profile first.
        </p>
      </div>

      <div
        className="text-center mb-6 p-5 rounded-xl border-2"
        style={{
          background: 'rgba(234, 88, 12, 0.05)',
          borderColor: 'rgba(234, 88, 12, 0.4)',
        }}
      >
        <p className="text-sm uppercase tracking-wider font-bold mb-1" style={{ color: 'var(--pregame-orange)' }}>
          Tournament Pass
        </p>
        <p className="text-4xl font-bold mb-1" style={{ color: 'var(--pregame-text-light)' }}>
          $499
        </p>
        <p className="text-xs" style={{ color: 'var(--pregame-text-muted)' }}>
          One-time · Covers all 104 matches · No monthly fees
        </p>
      </div>

      <div className="space-y-3">
        <button
          onClick={onPayNow}
          className="w-full btn-pregame-primary py-3 px-4 text-lg font-semibold rounded-xl transition-all duration-200"
        >
          Buy Tournament Pass — $499
        </button>
        <button
          onClick={onGoToDashboard}
          className="w-full py-3 px-4 text-lg font-semibold rounded-xl border-2 transition-all duration-200 hover:border-orange-500"
          style={{
            background: 'transparent',
            color: 'var(--pregame-text-light)',
            borderColor: 'rgba(255, 255, 255, 0.2)',
          }}
        >
          I'll Pay Later — Go to Dashboard
        </button>
      </div>

      <p className="text-xs mt-6" style={{ color: 'var(--pregame-text-muted)' }}>
        Secure payment via Stripe. Pass activates immediately and stays active through the
        tournament final on July 19, 2026.
      </p>
    </div>
  );
};

export default SuccessStep;

import React, { useEffect, useState } from 'react';
import { useSearchParams, useNavigate } from 'react-router-dom';

const BillingSuccess: React.FC = () => {
  const [searchParams] = useSearchParams();
  const navigate = useNavigate();
  const [status, setStatus] = useState<'loading' | 'success' | 'canceled'>('loading');

  useEffect(() => {
    const success = searchParams.get('success');
    const canceled = searchParams.get('canceled');
    const sessionId = searchParams.get('session_id');

    if (success === 'true') {
      setStatus('success');
      // You could make an API call here to verify the session if needed
    } else if (canceled === 'true') {
      setStatus('canceled');
    }
  }, [searchParams]);

  const handleContinue = () => {
    if (status === 'success') {
      navigate('/venue');
    } else {
      navigate('/venue/billing');
    }
  };

  if (status === 'loading') {
    return (
      <div className="flex justify-center items-center min-h-screen">
        <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-orange-500"></div>
      </div>
    );
  }

  return (
    <div className="max-w-md mx-auto px-4 py-16 text-center">
      {status === 'success' ? (
        <div className="bg-green-50 rounded-lg p-8">
          <div className="w-16 h-16 bg-green-100 rounded-full mx-auto mb-4 flex items-center justify-center">
            <svg className="w-8 h-8 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
            </svg>
          </div>
          <h1 className="text-2xl font-bold text-green-800 mb-4">
            Subscription Activated!
          </h1>
          <p className="text-green-700 mb-6">
            Welcome to Pregame! Your venue subscription is now active and you can start managing your profile and connecting with fans.
          </p>
        </div>
      ) : (
        <div className="bg-yellow-50 rounded-lg p-8">
          <div className="w-16 h-16 bg-yellow-100 rounded-full mx-auto mb-4 flex items-center justify-center">
            <svg className="w-8 h-8 text-yellow-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z" />
            </svg>
          </div>
          <h1 className="text-2xl font-bold text-yellow-800 mb-4">
            Subscription Canceled
          </h1>
          <p className="text-yellow-700 mb-6">
            Your subscription signup was canceled. No charges have been made to your account. You can try again whenever you're ready.
          </p>
        </div>
      )}

      <button
        onClick={handleContinue}
        className="bg-pregame-green-500 text-white px-8 py-3 rounded-lg font-semibold hover:bg-pregame-green-600 transition-colors"
      >
        {status === 'success' ? 'Continue to Dashboard' : 'Back to Billing'}
      </button>
    </div>
  );
};

export default BillingSuccess; 
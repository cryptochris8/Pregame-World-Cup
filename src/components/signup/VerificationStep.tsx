import React, { useEffect, useRef, useState } from 'react';
import { sendVenueVerificationCode, verifyVenueCode } from '../../services/cloudFunctions';

interface VerificationStepProps {
  venueId: string | null;
  phone: string;
  onVerified: () => void;
  onBack: () => void;
}

const RESEND_COOLDOWN_SECONDS = 60;

function maskPhone(raw: string): string {
  const digits = raw.replace(/\D/g, '');
  if (digits.length < 4) return raw;
  return `••• ••• ${digits.slice(-4)}`;
}

const VerificationStep: React.FC<VerificationStepProps> = ({
  venueId,
  phone,
  onVerified,
  onBack,
}) => {
  const [code, setCode] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [info, setInfo] = useState<string | null>(null);
  const [cooldown, setCooldown] = useState(RESEND_COOLDOWN_SECONDS);
  const initialSendRef = useRef(false);

  useEffect(() => {
    if (!venueId || initialSendRef.current) return;
    initialSendRef.current = true;
    sendVenueVerificationCode({ venueId })
      .then(() => setInfo('Code sent. Check your phone.'))
      .catch((err: any) => setError(err.message || 'Failed to send code'));
  }, [venueId]);

  useEffect(() => {
    if (cooldown <= 0) return;
    const t = setTimeout(() => setCooldown((c) => c - 1), 1000);
    return () => clearTimeout(t);
  }, [cooldown]);

  const handleResend = async () => {
    if (!venueId || cooldown > 0) return;
    setError(null);
    setInfo(null);
    try {
      await sendVenueVerificationCode({ venueId });
      setInfo('A new code is on its way.');
      setCooldown(RESEND_COOLDOWN_SECONDS);
    } catch (err: any) {
      setError(err.message || 'Failed to resend code');
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!venueId) {
      setError('Missing venue context. Please go back and re-submit.');
      return;
    }
    if (code.length !== 6) {
      setError('Enter the 6-digit code from your text message.');
      return;
    }
    setSubmitting(true);
    setError(null);
    try {
      await verifyVenueCode({ venueId, code });
      onVerified();
    } catch (err: any) {
      setError(err.message || 'Verification failed');
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="pregame-card">
      <h2 className="text-2xl font-bold mb-2" style={{ color: 'var(--pregame-text-light)' }}>
        Verify Your Phone
      </h2>
      <p className="mb-6" style={{ color: 'var(--pregame-text-muted)' }}>
        We sent a 6-digit code to <strong>{maskPhone(phone)}</strong>. Enter it below to confirm
        ownership of this venue.
      </p>

      {error && (
        <div className="mb-4 p-4 rounded-lg bg-red-500/20 border border-red-500/50">
          <p className="text-red-400 text-sm">{error}</p>
        </div>
      )}
      {!error && info && (
        <div className="mb-4 p-4 rounded-lg bg-green-500/10 border border-green-500/30">
          <p className="text-green-400 text-sm">{info}</p>
        </div>
      )}

      <form onSubmit={handleSubmit} className="space-y-5">
        <div>
          <label
            className="block text-sm font-medium mb-2"
            style={{ color: 'var(--pregame-text-light)' }}
          >
            Verification Code
          </label>
          <input
            type="text"
            inputMode="numeric"
            autoComplete="one-time-code"
            value={code}
            onChange={(e) => setCode(e.target.value.replace(/\D/g, '').slice(0, 6))}
            className="w-full px-4 py-3 rounded-xl border focus:outline-none focus:ring-2 transition-all text-center text-2xl tracking-[0.5em]"
            style={{
              background: 'var(--pregame-card-bg)',
              color: 'var(--pregame-text-light)',
              borderColor: 'rgba(255, 255, 255, 0.1)',
            }}
            placeholder="••••••"
            maxLength={6}
          />
          <p className="text-xs mt-2" style={{ color: 'var(--pregame-text-muted)' }}>
            The code expires in 10 minutes. Five wrong attempts and you'll need to request a new
            one.
          </p>
        </div>

        <div>
          <button
            type="button"
            onClick={handleResend}
            disabled={cooldown > 0}
            className="text-sm hover:underline disabled:opacity-50 disabled:cursor-not-allowed"
            style={{ color: 'var(--pregame-orange)' }}
          >
            {cooldown > 0 ? `Resend code in ${cooldown}s` : 'Resend code'}
          </button>
        </div>

        <div className="flex gap-4 pt-2">
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
            disabled={submitting || code.length !== 6}
            className="flex-1 btn-pregame-primary py-3 px-4 text-lg font-semibold rounded-xl transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {submitting ? (
              <div className="flex items-center justify-center">
                <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-white mr-2"></div>
                Verifying...
              </div>
            ) : (
              'Verify & Continue'
            )}
          </button>
        </div>
      </form>
    </div>
  );
};

export default VerificationStep;

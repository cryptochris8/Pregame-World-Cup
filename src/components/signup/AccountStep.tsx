import React, { useState } from 'react';
import { WizardData } from '../../screens/venue/VenueSignupWizard';
import { authService } from '../../services/authService';

interface AccountStepProps {
  data: WizardData;
  updateData: (updates: Partial<WizardData>) => void;
  onNext: () => void;
  loading: boolean;
  error: string | null;
}

const AccountStep: React.FC<AccountStepProps> = ({
  data,
  updateData,
  onNext,
  loading,
  error,
}) => {
  const [localErrors, setLocalErrors] = useState<{ [key: string]: string }>({});

  const validate = (): boolean => {
    const errors: { [key: string]: string } = {};

    if (!data.firstName.trim()) {
      errors.firstName = 'First name is required';
    }

    if (!data.lastName.trim()) {
      errors.lastName = 'Last name is required';
    }

    if (!data.email.trim()) {
      errors.email = 'Email is required';
    } else if (!authService.isValidEmail(data.email)) {
      errors.email = 'Please enter a valid email address';
    }

    if (!data.password) {
      errors.password = 'Password is required';
    } else {
      const passwordValidation = authService.isValidPassword(data.password);
      if (!passwordValidation.isValid) {
        errors.password = passwordValidation.message;
      }
    }

    if (data.password !== data.confirmPassword) {
      errors.confirmPassword = 'Passwords do not match';
    }

    setLocalErrors(errors);
    return Object.keys(errors).length === 0;
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (validate()) {
      onNext();
    }
  };

  const inputStyle = {
    background: 'var(--pregame-card-bg)',
    color: 'var(--pregame-text-light)',
    borderColor: 'rgba(255, 255, 255, 0.1)',
  };

  return (
    <div className="pregame-card">
      <h2 className="text-2xl font-bold mb-6" style={{ color: 'var(--pregame-text-light)' }}>
        Create Your Account
      </h2>

      {error && (
        <div className="mb-4 p-4 rounded-lg bg-red-500/20 border border-red-500/50">
          <p className="text-red-400 text-sm">{error}</p>
        </div>
      )}

      <form onSubmit={handleSubmit} className="space-y-5">
        {/* Name Row */}
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium mb-2" style={{ color: 'var(--pregame-text-light)' }}>
              First Name *
            </label>
            <input
              type="text"
              value={data.firstName}
              onChange={(e) => updateData({ firstName: e.target.value })}
              className="w-full px-4 py-3 rounded-xl border focus:outline-none focus:ring-2 transition-all"
              style={inputStyle}
              placeholder="John"
            />
            {localErrors.firstName && (
              <p className="text-red-400 text-xs mt-1">{localErrors.firstName}</p>
            )}
          </div>
          <div>
            <label className="block text-sm font-medium mb-2" style={{ color: 'var(--pregame-text-light)' }}>
              Last Name *
            </label>
            <input
              type="text"
              value={data.lastName}
              onChange={(e) => updateData({ lastName: e.target.value })}
              className="w-full px-4 py-3 rounded-xl border focus:outline-none focus:ring-2 transition-all"
              style={inputStyle}
              placeholder="Smith"
            />
            {localErrors.lastName && (
              <p className="text-red-400 text-xs mt-1">{localErrors.lastName}</p>
            )}
          </div>
        </div>

        {/* Email */}
        <div>
          <label className="block text-sm font-medium mb-2" style={{ color: 'var(--pregame-text-light)' }}>
            Email Address *
          </label>
          <input
            type="email"
            value={data.email}
            onChange={(e) => updateData({ email: e.target.value })}
            className="w-full px-4 py-3 rounded-xl border focus:outline-none focus:ring-2 transition-all"
            style={inputStyle}
            placeholder="john@yourvenue.com"
          />
          {localErrors.email && (
            <p className="text-red-400 text-xs mt-1">{localErrors.email}</p>
          )}
        </div>

        {/* Phone */}
        <div>
          <label className="block text-sm font-medium mb-2" style={{ color: 'var(--pregame-text-light)' }}>
            Phone Number
          </label>
          <input
            type="tel"
            value={data.phone}
            onChange={(e) => updateData({ phone: e.target.value })}
            className="w-full px-4 py-3 rounded-xl border focus:outline-none focus:ring-2 transition-all"
            style={inputStyle}
            placeholder="(555) 123-4567"
          />
        </div>

        {/* Password */}
        <div>
          <label className="block text-sm font-medium mb-2" style={{ color: 'var(--pregame-text-light)' }}>
            Password *
          </label>
          <input
            type="password"
            value={data.password}
            onChange={(e) => updateData({ password: e.target.value })}
            className="w-full px-4 py-3 rounded-xl border focus:outline-none focus:ring-2 transition-all"
            style={inputStyle}
            placeholder="Create a strong password"
          />
          {localErrors.password && (
            <p className="text-red-400 text-xs mt-1">{localErrors.password}</p>
          )}
          <p className="text-xs mt-1" style={{ color: 'var(--pregame-text-muted)' }}>
            At least 6 characters with uppercase, lowercase, and number
          </p>
        </div>

        {/* Confirm Password */}
        <div>
          <label className="block text-sm font-medium mb-2" style={{ color: 'var(--pregame-text-light)' }}>
            Confirm Password *
          </label>
          <input
            type="password"
            value={data.confirmPassword}
            onChange={(e) => updateData({ confirmPassword: e.target.value })}
            className="w-full px-4 py-3 rounded-xl border focus:outline-none focus:ring-2 transition-all"
            style={inputStyle}
            placeholder="Confirm your password"
          />
          {localErrors.confirmPassword && (
            <p className="text-red-400 text-xs mt-1">{localErrors.confirmPassword}</p>
          )}
        </div>

        {/* Submit */}
        <button
          type="submit"
          disabled={loading}
          className="w-full btn-pregame-primary py-3 px-4 text-lg font-semibold rounded-xl transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {loading ? (
            <div className="flex items-center justify-center">
              <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-white mr-2"></div>
              Creating Account...
            </div>
          ) : (
            'Continue'
          )}
        </button>

        <p className="text-xs text-center" style={{ color: 'var(--pregame-text-muted)' }}>
          By creating an account, you agree to our Terms of Service and Privacy Policy
        </p>
      </form>
    </div>
  );
};

export default AccountStep;

import React from 'react';
import { WizardData, WeeklyHours, DayHours } from '../../screens/venue/VenueSignupWizard';

interface HoursStepProps {
  data: WizardData;
  updateData: (updates: Partial<WizardData>) => void;
  onNext: () => void;
  onBack: () => void;
  loading: boolean;
  error: string | null;
}

const DAYS = [
  { key: 'monday', label: 'Monday' },
  { key: 'tuesday', label: 'Tuesday' },
  { key: 'wednesday', label: 'Wednesday' },
  { key: 'thursday', label: 'Thursday' },
  { key: 'friday', label: 'Friday' },
  { key: 'saturday', label: 'Saturday' },
  { key: 'sunday', label: 'Sunday' },
];

const TIME_OPTIONS = [
  '06:00', '07:00', '08:00', '09:00', '10:00', '11:00', '12:00',
  '13:00', '14:00', '15:00', '16:00', '17:00', '18:00', '19:00',
  '20:00', '21:00', '22:00', '23:00', '00:00', '01:00', '02:00',
];

const formatTime = (time: string): string => {
  const [hours] = time.split(':');
  const hour = parseInt(hours, 10);
  if (hour === 0) return '12:00 AM';
  if (hour === 12) return '12:00 PM';
  if (hour > 12) return `${hour - 12}:00 PM`;
  return `${hour}:00 AM`;
};

const HoursStep: React.FC<HoursStepProps> = ({
  data,
  updateData,
  onNext,
  onBack,
  loading,
  error,
}) => {
  const updateDayHours = (day: string, updates: Partial<DayHours>) => {
    const newHours: WeeklyHours = {
      ...data.regularHours,
      [day]: {
        ...data.regularHours[day],
        ...updates,
      },
    };
    updateData({ regularHours: newHours });
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onNext();
  };

  const inputStyle: React.CSSProperties = {
    background: 'var(--pregame-card-bg)',
    color: 'var(--pregame-text-light)',
    borderColor: 'rgba(255, 255, 255, 0.1)',
  };

  return (
    <div className="pregame-card">
      <h2 className="text-2xl font-bold mb-2" style={{ color: 'var(--pregame-text-light)' }}>
        Set Your Operating Hours
      </h2>
      <p className="mb-6" style={{ color: 'var(--pregame-text-muted)' }}>
        Let fans know when you're open. You can always update these later.
      </p>

      {error && (
        <div className="mb-4 p-4 rounded-lg bg-red-500/20 border border-red-500/50">
          <p className="text-red-400 text-sm">{error}</p>
        </div>
      )}

      <form onSubmit={handleSubmit} className="space-y-4">
        {/* Hours Grid */}
        <div className="space-y-3">
          {DAYS.map(({ key, label }) => {
            const dayHours = data.regularHours[key];
            const isClosed = dayHours?.isClosed || false;

            return (
              <div
                key={key}
                className="flex items-center gap-3 p-3 rounded-lg"
                style={{ background: 'rgba(255, 255, 255, 0.05)' }}
              >
                {/* Day Label */}
                <div className="w-24 flex-shrink-0">
                  <span className="font-medium" style={{ color: 'var(--pregame-text-light)' }}>
                    {label}
                  </span>
                </div>

                {/* Closed Toggle */}
                <label className="flex items-center gap-2 cursor-pointer flex-shrink-0">
                  <input
                    type="checkbox"
                    checked={isClosed}
                    onChange={(e) => updateDayHours(key, { isClosed: e.target.checked })}
                    className="w-4 h-4 rounded accent-orange-500"
                  />
                  <span className="text-sm" style={{ color: 'var(--pregame-text-muted)' }}>
                    Closed
                  </span>
                </label>

                {/* Time Selectors */}
                {!isClosed && (
                  <div className="flex items-center gap-2 flex-1 justify-end">
                    <select
                      value={dayHours?.open || '11:00'}
                      onChange={(e) => updateDayHours(key, { open: e.target.value })}
                      className="px-2 py-1 rounded border text-sm focus:outline-none"
                      style={inputStyle}
                    >
                      {TIME_OPTIONS.map((time) => (
                        <option key={`open-${time}`} value={time}>
                          {formatTime(time)}
                        </option>
                      ))}
                    </select>
                    <span style={{ color: 'var(--pregame-text-muted)' }}>to</span>
                    <select
                      value={dayHours?.close || '23:00'}
                      onChange={(e) => updateDayHours(key, { close: e.target.value })}
                      className="px-2 py-1 rounded border text-sm focus:outline-none"
                      style={inputStyle}
                    >
                      {TIME_OPTIONS.map((time) => (
                        <option key={`close-${time}`} value={time}>
                          {formatTime(time)}
                        </option>
                      ))}
                    </select>
                  </div>
                )}

                {isClosed && (
                  <div className="flex-1 text-right">
                    <span className="text-sm italic" style={{ color: 'var(--pregame-text-muted)' }}>
                      Closed
                    </span>
                  </div>
                )}
              </div>
            );
          })}
        </div>

        <p className="text-xs text-center pt-2" style={{ color: 'var(--pregame-text-muted)' }}>
          You can set special game day hours after completing signup
        </p>

        {/* Navigation Buttons */}
        <div className="flex gap-4 pt-4">
          <button
            type="button"
            onClick={onBack}
            disabled={loading}
            className="flex-1 py-3 px-4 text-lg font-semibold rounded-xl border-2 transition-all duration-200 hover:border-orange-500 disabled:opacity-50"
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
            disabled={loading}
            className="flex-1 btn-pregame-primary py-3 px-4 text-lg font-semibold rounded-xl transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {loading ? (
              <div className="flex items-center justify-center">
                <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-white mr-2"></div>
                Creating Venue...
              </div>
            ) : (
              'Continue'
            )}
          </button>
        </div>
      </form>
    </div>
  );
};

export default HoursStep;

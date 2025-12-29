import React, { useState } from 'react';
import { WizardData } from '../../screens/venue/VenueSignupWizard';
import AddressAutocomplete from '../AddressAutocomplete';

interface VenueDetailsStepProps {
  data: WizardData;
  updateData: (updates: Partial<WizardData>) => void;
  onNext: () => void;
  onBack: () => void;
}

const VENUE_TYPES = [
  'Sports Bar',
  'Restaurant',
  'Brewery',
  'Pub',
  'Grill',
  'Cafe',
] as const;

const VenueDetailsStep: React.FC<VenueDetailsStepProps> = ({
  data,
  updateData,
  onNext,
  onBack,
}) => {
  const [errors, setErrors] = useState<{ [key: string]: string }>({});

  const validate = (): boolean => {
    const newErrors: { [key: string]: string } = {};

    if (!data.venueName.trim()) {
      newErrors.venueName = 'Venue name is required';
    }

    if (!data.address.trim()) {
      newErrors.address = 'Address is required';
    }

    if (!data.city.trim()) {
      newErrors.city = 'City is required';
    }

    if (!data.state.trim()) {
      newErrors.state = 'State is required';
    }

    if (!data.zip.trim()) {
      newErrors.zip = 'ZIP code is required';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (validate()) {
      onNext();
    }
  };

  const handlePlaceSelect = (place: {
    address: string;
    city: string;
    state: string;
    zip: string;
    latitude: number;
    longitude: number;
  }) => {
    updateData({
      address: place.address,
      city: place.city,
      state: place.state,
      zip: place.zip,
      latitude: place.latitude,
      longitude: place.longitude,
    });
  };

  const inputStyle: React.CSSProperties = {
    background: 'var(--pregame-card-bg)',
    color: 'var(--pregame-text-light)',
    borderColor: 'rgba(255, 255, 255, 0.1)',
  };

  return (
    <div className="pregame-card">
      <h2 className="text-2xl font-bold mb-2" style={{ color: 'var(--pregame-text-light)' }}>
        Tell Us About Your Venue
      </h2>
      <p className="mb-6" style={{ color: 'var(--pregame-text-muted)' }}>
        This information will be displayed to fans looking for places to watch games
      </p>

      <form onSubmit={handleSubmit} className="space-y-5">
        {/* Venue Name */}
        <div>
          <label className="block text-sm font-medium mb-2" style={{ color: 'var(--pregame-text-light)' }}>
            Venue Name *
          </label>
          <input
            type="text"
            value={data.venueName}
            onChange={(e) => updateData({ venueName: e.target.value })}
            className="w-full px-4 py-3 rounded-xl border focus:outline-none focus:ring-2 transition-all"
            style={inputStyle}
            placeholder="The Sports Grill"
          />
          {errors.venueName && (
            <p className="text-red-400 text-xs mt-1">{errors.venueName}</p>
          )}
        </div>

        {/* Venue Type */}
        <div>
          <label className="block text-sm font-medium mb-2" style={{ color: 'var(--pregame-text-light)' }}>
            Venue Type *
          </label>
          <select
            value={data.venueType}
            onChange={(e) => updateData({ venueType: e.target.value as typeof data.venueType })}
            className="w-full px-4 py-3 rounded-xl border focus:outline-none focus:ring-2 transition-all"
            style={inputStyle}
          >
            {VENUE_TYPES.map((type) => (
              <option key={type} value={type}>
                {type}
              </option>
            ))}
          </select>
        </div>

        {/* Description */}
        <div>
          <label className="block text-sm font-medium mb-2" style={{ color: 'var(--pregame-text-light)' }}>
            Description
          </label>
          <textarea
            value={data.description}
            onChange={(e) => updateData({ description: e.target.value })}
            className="w-full px-4 py-3 rounded-xl border focus:outline-none focus:ring-2 transition-all resize-none"
            style={inputStyle}
            rows={3}
            placeholder="Tell fans what makes your venue special for watching games..."
          />
        </div>

        {/* Address with Autocomplete */}
        <div>
          <label className="block text-sm font-medium mb-2" style={{ color: 'var(--pregame-text-light)' }}>
            Street Address *
          </label>
          <AddressAutocomplete
            value={data.address}
            onChange={(address) => updateData({ address })}
            onPlaceSelect={handlePlaceSelect}
            className="w-full px-4 py-3 rounded-xl border focus:outline-none focus:ring-2 transition-all"
            style={inputStyle}
            placeholder="Start typing to search..."
          />
          {errors.address && (
            <p className="text-red-400 text-xs mt-1">{errors.address}</p>
          )}
          {data.latitude !== 0 && (
            <p className="text-green-400 text-xs mt-1 flex items-center gap-1">
              <span>✓</span> Location verified
            </p>
          )}
        </div>

        {/* City, State, ZIP Row */}
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
          <div className="col-span-2">
            <label className="block text-sm font-medium mb-2" style={{ color: 'var(--pregame-text-light)' }}>
              City *
            </label>
            <input
              type="text"
              value={data.city}
              onChange={(e) => updateData({ city: e.target.value })}
              className="w-full px-4 py-3 rounded-xl border focus:outline-none focus:ring-2 transition-all"
              style={inputStyle}
              placeholder="Dallas"
            />
            {errors.city && (
              <p className="text-red-400 text-xs mt-1">{errors.city}</p>
            )}
          </div>
          <div>
            <label className="block text-sm font-medium mb-2" style={{ color: 'var(--pregame-text-light)' }}>
              State *
            </label>
            <input
              type="text"
              value={data.state}
              onChange={(e) => updateData({ state: e.target.value })}
              className="w-full px-4 py-3 rounded-xl border focus:outline-none focus:ring-2 transition-all"
              style={inputStyle}
              placeholder="TX"
              maxLength={2}
            />
            {errors.state && (
              <p className="text-red-400 text-xs mt-1">{errors.state}</p>
            )}
          </div>
          <div>
            <label className="block text-sm font-medium mb-2" style={{ color: 'var(--pregame-text-light)' }}>
              ZIP *
            </label>
            <input
              type="text"
              value={data.zip}
              onChange={(e) => updateData({ zip: e.target.value })}
              className="w-full px-4 py-3 rounded-xl border focus:outline-none focus:ring-2 transition-all"
              style={inputStyle}
              placeholder="75001"
              maxLength={10}
            />
            {errors.zip && (
              <p className="text-red-400 text-xs mt-1">{errors.zip}</p>
            )}
          </div>
        </div>

        {/* Navigation Buttons */}
        <div className="flex gap-4 pt-4">
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
            Continue
          </button>
        </div>
      </form>
    </div>
  );
};

export default VenueDetailsStep;

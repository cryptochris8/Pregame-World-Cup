import React, { useEffect, useRef, useState } from 'react';

interface AddressAutocompleteProps {
  value: string;
  onChange: (address: string) => void;
  onPlaceSelect: (place: {
    address: string;
    city: string;
    state: string;
    zip: string;
    latitude: number;
    longitude: number;
  }) => void;
  placeholder?: string;
  className?: string;
  style?: React.CSSProperties;
}

// Google Places API Key - same as used in Flutter app
const GOOGLE_API_KEY = 'AIzaSyDso9Xiayt0jjnUNvyKcf48ex3fbxyAehw';

declare global {
  interface Window {
    google: typeof google;
    initGooglePlaces: () => void;
  }
}

const AddressAutocomplete: React.FC<AddressAutocompleteProps> = ({
  value,
  onChange,
  onPlaceSelect,
  placeholder = 'Start typing your address...',
  className = '',
  style = {},
}) => {
  const inputRef = useRef<HTMLInputElement>(null);
  const autocompleteRef = useRef<google.maps.places.Autocomplete | null>(null);
  const [isLoaded, setIsLoaded] = useState(false);

  useEffect(() => {
    // Load Google Places API script
    if (!window.google) {
      const script = document.createElement('script');
      script.src = `https://maps.googleapis.com/maps/api/js?key=${GOOGLE_API_KEY}&libraries=places`;
      script.async = true;
      script.defer = true;
      script.onload = () => {
        setIsLoaded(true);
      };
      document.head.appendChild(script);
    } else {
      setIsLoaded(true);
    }
  }, []);

  useEffect(() => {
    if (isLoaded && inputRef.current && !autocompleteRef.current) {
      // Initialize autocomplete
      autocompleteRef.current = new window.google.maps.places.Autocomplete(inputRef.current, {
        types: ['address'],
        componentRestrictions: { country: ['us', 'mx', 'ca'] }, // USA, Mexico, Canada
        fields: ['address_components', 'geometry', 'formatted_address'],
      });

      // Listen for place selection
      autocompleteRef.current.addListener('place_changed', () => {
        const place = autocompleteRef.current?.getPlace();
        if (place && place.address_components && place.geometry) {
          const addressComponents = place.address_components;

          let streetNumber = '';
          let route = '';
          let city = '';
          let state = '';
          let zip = '';

          for (const component of addressComponents) {
            const types = component.types;

            if (types.includes('street_number')) {
              streetNumber = component.long_name;
            }
            if (types.includes('route')) {
              route = component.long_name;
            }
            if (types.includes('locality') || types.includes('sublocality')) {
              city = component.long_name;
            }
            if (types.includes('administrative_area_level_1')) {
              state = component.short_name;
            }
            if (types.includes('postal_code')) {
              zip = component.long_name;
            }
          }

          const streetAddress = `${streetNumber} ${route}`.trim();
          const lat = place.geometry.location?.lat() || 0;
          const lng = place.geometry.location?.lng() || 0;

          onPlaceSelect({
            address: streetAddress,
            city,
            state,
            zip,
            latitude: lat,
            longitude: lng,
          });

          onChange(streetAddress);
        }
      });
    }
  }, [isLoaded, onPlaceSelect, onChange]);

  return (
    <div className="relative">
      <input
        ref={inputRef}
        type="text"
        value={value}
        onChange={(e) => onChange(e.target.value)}
        placeholder={placeholder}
        className={className}
        style={style}
        autoComplete="off"
      />
      {!isLoaded && (
        <div className="absolute right-3 top-1/2 transform -translate-y-1/2">
          <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-gray-400"></div>
        </div>
      )}
    </div>
  );
};

export default AddressAutocomplete;

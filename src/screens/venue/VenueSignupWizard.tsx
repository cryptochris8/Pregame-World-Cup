import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import PregameLogo from '../../assets/pregame_logo.png';
import AccountStep from '../../components/signup/AccountStep';
import VenueDetailsStep from '../../components/signup/VenueDetailsStep';
import HoursStep from '../../components/signup/HoursStep';
import SubscriptionStep from '../../components/signup/SubscriptionStep';
import SuccessStep from '../../components/signup/SuccessStep';
import { authService } from '../../services/authService';
import { venueService, VenueProfile } from '../../services/venueService';

// Weekly hours type
export interface DayHours {
  open: string;
  close: string;
  isClosed: boolean;
}

export interface WeeklyHours {
  [key: string]: DayHours;
}

// Wizard data interface
export interface WizardData {
  // Step 1: Account
  email: string;
  password: string;
  confirmPassword: string;
  firstName: string;
  lastName: string;
  phone: string;

  // Step 2: Venue
  venueName: string;
  venueType: VenueProfile['venueType'];
  description: string;
  address: string;
  city: string;
  state: string;
  zip: string;
  latitude: number;
  longitude: number;

  // Step 3: Hours
  regularHours: WeeklyHours;

  // Step 4: Subscription
  selectedPlan: 'basic' | 'pro' | 'enterprise';
}

const defaultHours: WeeklyHours = {
  monday: { open: '11:00', close: '23:00', isClosed: false },
  tuesday: { open: '11:00', close: '23:00', isClosed: false },
  wednesday: { open: '11:00', close: '23:00', isClosed: false },
  thursday: { open: '11:00', close: '23:00', isClosed: false },
  friday: { open: '11:00', close: '00:00', isClosed: false },
  saturday: { open: '10:00', close: '00:00', isClosed: false },
  sunday: { open: '10:00', close: '22:00', isClosed: false },
};

const initialData: WizardData = {
  email: '',
  password: '',
  confirmPassword: '',
  firstName: '',
  lastName: '',
  phone: '',
  venueName: '',
  venueType: 'Sports Bar',
  description: '',
  address: '',
  city: '',
  state: '',
  zip: '',
  latitude: 0,
  longitude: 0,
  regularHours: defaultHours,
  selectedPlan: 'basic',
};

const STEPS = [
  { id: 1, name: 'Account', description: 'Create your account' },
  { id: 2, name: 'Venue', description: 'Tell us about your venue' },
  { id: 3, name: 'Hours', description: 'Set your operating hours' },
  { id: 4, name: 'Plan', description: 'Choose your subscription' },
  { id: 5, name: 'Done', description: 'Welcome aboard!' },
];

const VenueSignupWizard: React.FC = () => {
  const navigate = useNavigate();
  const [currentStep, setCurrentStep] = useState(1);
  const [data, setData] = useState<WizardData>(initialData);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [createdVenueId, setCreatedVenueId] = useState<string | null>(null);

  const updateData = (updates: Partial<WizardData>) => {
    setData(prev => ({ ...prev, ...updates }));
  };

  const handleNext = () => {
    setError(null);
    if (currentStep < STEPS.length) {
      setCurrentStep(prev => prev + 1);
    }
  };

  const handleBack = () => {
    setError(null);
    if (currentStep > 1) {
      setCurrentStep(prev => prev - 1);
    }
  };

  const handleSubmitAccount = async (): Promise<boolean> => {
    try {
      setLoading(true);
      setError(null);

      // Create the user account
      await authService.signUp(
        data.email,
        data.password,
        data.firstName,
        data.lastName,
        data.phone || undefined
      );

      return true;
    } catch (err: any) {
      setError(err.message || 'Failed to create account');
      return false;
    } finally {
      setLoading(false);
    }
  };

  const handleCreateVenue = async (): Promise<boolean> => {
    try {
      setLoading(true);
      setError(null);

      const user = authService.getCurrentUser();
      if (!user) {
        setError('No authenticated user found');
        return false;
      }

      // Create venue profile
      const venueData: Omit<VenueProfile, 'id' | 'createdAt' | 'updatedAt'> = {
        ownerId: user.uid,
        name: data.venueName,
        venueType: data.venueType,
        description: data.description,
        address: `${data.address}, ${data.city}, ${data.state} ${data.zip}`,
        phone: data.phone,
        email: data.email,
        capacity: 100, // Default, can be updated later
        amenities: [],
        regularHours: data.regularHours,
        gameDayHours: data.regularHours, // Same as regular for now
        socialMedia: {},
        images: [],
        rating: 0,
        reviewCount: 0,
        isVerified: false,
        location: {
          latitude: data.latitude,
          longitude: data.longitude,
        },
      };

      const venueId = await venueService.createVenueProfile(venueData);
      setCreatedVenueId(venueId);

      // Link venue to owner
      await authService.linkVenueToOwner(user.uid, venueId);

      return true;
    } catch (err: any) {
      setError(err.message || 'Failed to create venue');
      return false;
    } finally {
      setLoading(false);
    }
  };

  const handleGoToDashboard = () => {
    navigate('/venue');
  };

  const handleGoToStripe = () => {
    // Navigate to billing with selected plan
    navigate(`/venue/billing?plan=${data.selectedPlan}`);
  };

  const renderStepContent = () => {
    switch (currentStep) {
      case 1:
        return (
          <AccountStep
            data={data}
            updateData={updateData}
            onNext={async () => {
              const success = await handleSubmitAccount();
              if (success) handleNext();
            }}
            loading={loading}
            error={error}
          />
        );
      case 2:
        return (
          <VenueDetailsStep
            data={data}
            updateData={updateData}
            onNext={handleNext}
            onBack={handleBack}
          />
        );
      case 3:
        return (
          <HoursStep
            data={data}
            updateData={updateData}
            onNext={async () => {
              const success = await handleCreateVenue();
              if (success) handleNext();
            }}
            onBack={handleBack}
            loading={loading}
            error={error}
          />
        );
      case 4:
        return (
          <SubscriptionStep
            data={data}
            updateData={updateData}
            onNext={handleNext}
            onBack={handleBack}
          />
        );
      case 5:
        return (
          <SuccessStep
            venueName={data.venueName}
            selectedPlan={data.selectedPlan}
            onGoToDashboard={handleGoToDashboard}
            onSetupBilling={handleGoToStripe}
          />
        );
      default:
        return null;
    }
  };

  return (
    <div className="min-h-screen flex flex-col" style={{ background: 'var(--pregame-dark-bg)' }}>
      {/* Header */}
      <div className="py-6 px-4">
        <div className="max-w-3xl mx-auto flex items-center justify-between">
          <div className="flex items-center gap-3">
            <img src={PregameLogo} alt="Pregame" className="h-10 w-auto" />
            <span className="text-xl font-bold" style={{ color: 'var(--pregame-text-light)' }}>
              Venue Portal
            </span>
          </div>
          <button
            onClick={() => navigate('/')}
            className="text-sm hover:underline"
            style={{ color: 'var(--pregame-text-muted)' }}
          >
            Already have an account? Sign in
          </button>
        </div>
      </div>

      {/* Progress Bar */}
      <div className="py-4 px-4">
        <div className="max-w-3xl mx-auto">
          <div className="flex items-center justify-between mb-2">
            {STEPS.map((step, index) => (
              <React.Fragment key={step.id}>
                <div className="flex flex-col items-center">
                  <div
                    className={`w-10 h-10 rounded-full flex items-center justify-center text-sm font-bold transition-all ${
                      currentStep > step.id
                        ? 'bg-green-500 text-white'
                        : currentStep === step.id
                        ? 'pregame-gradient text-white'
                        : 'bg-gray-700 text-gray-400'
                    }`}
                  >
                    {currentStep > step.id ? '✓' : step.id}
                  </div>
                  <span
                    className="text-xs mt-1 hidden sm:block"
                    style={{ color: currentStep >= step.id ? 'var(--pregame-text-light)' : 'var(--pregame-text-muted)' }}
                  >
                    {step.name}
                  </span>
                </div>
                {index < STEPS.length - 1 && (
                  <div
                    className="flex-1 h-1 mx-2 rounded"
                    style={{
                      background: currentStep > step.id ? '#22c55e' : 'rgba(255,255,255,0.1)',
                    }}
                  />
                )}
              </React.Fragment>
            ))}
          </div>
          <div className="text-center mt-4">
            <p className="text-lg font-semibold" style={{ color: 'var(--pregame-text-light)' }}>
              {STEPS[currentStep - 1].description}
            </p>
            <p className="text-sm" style={{ color: 'var(--pregame-text-muted)' }}>
              Step {currentStep} of {STEPS.length}
            </p>
          </div>
        </div>
      </div>

      {/* Step Content */}
      <div className="flex-1 flex items-start justify-center px-4 py-8">
        <div className="w-full max-w-2xl">
          {renderStepContent()}
        </div>
      </div>
    </div>
  );
};

export default VenueSignupWizard;

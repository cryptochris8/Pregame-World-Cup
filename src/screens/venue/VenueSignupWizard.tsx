import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import PregameLogo from '../../assets/pregame_logo.png';
import AccountStep from '../../components/signup/AccountStep';
import VenueDetailsStep from '../../components/signup/VenueDetailsStep';
import HoursStep from '../../components/signup/HoursStep';
import VerificationStep from '../../components/signup/VerificationStep';
import SuccessStep from '../../components/signup/SuccessStep';
import { authService } from '../../services/authService';
import { VenueProfile } from '../../services/venueService';
import { claimVenue } from '../../services/cloudFunctions';
import { doc, collection } from 'firebase/firestore';
import { db } from '../../firebase/firebaseConfig';

export interface DayHours {
  open: string;
  close: string;
  isClosed: boolean;
}

export interface WeeklyHours {
  [key: string]: DayHours;
}

export interface WizardData {
  email: string;
  password: string;
  confirmPassword: string;
  firstName: string;
  lastName: string;
  phone: string;

  venueName: string;
  venueType: VenueProfile['venueType'];
  description: string;
  address: string;
  city: string;
  state: string;
  zip: string;
  latitude: number;
  longitude: number;

  regularHours: WeeklyHours;
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
};

const STEPS = [
  { id: 1, name: 'Account', description: 'Create your account' },
  { id: 2, name: 'Venue', description: 'Tell us about your venue' },
  { id: 3, name: 'Hours', description: 'Set your operating hours' },
  { id: 4, name: 'Verify', description: 'Verify your phone' },
  { id: 5, name: 'Done', description: 'Submit & set up billing' },
];

const VenueSignupWizard: React.FC = () => {
  const navigate = useNavigate();
  const [currentStep, setCurrentStep] = useState(1);
  const [data, setData] = useState<WizardData>(initialData);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [claimedVenueId, setClaimedVenueId] = useState<string | null>(null);

  const updateData = (updates: Partial<WizardData>) => {
    setData((prev) => ({ ...prev, ...updates }));
  };

  const handleNext = () => {
    setError(null);
    if (currentStep < STEPS.length) {
      setCurrentStep((prev) => prev + 1);
    }
  };

  const handleBack = () => {
    setError(null);
    if (currentStep > 1) {
      setCurrentStep((prev) => prev - 1);
    }
  };

  const handleSubmitAccount = async (): Promise<boolean> => {
    try {
      setLoading(true);
      setError(null);
      await authService.signUp(
        data.email,
        data.password,
        data.firstName,
        data.lastName,
        data.phone,
      );
      return true;
    } catch (err: any) {
      setError(err.message || 'Failed to create account');
      return false;
    } finally {
      setLoading(false);
    }
  };

  const handleSubmitClaim = async (): Promise<boolean> => {
    try {
      setLoading(true);
      setError(null);

      const user = authService.getCurrentUser();
      if (!user) {
        setError('Your session expired. Please go back and re-create your account.');
        return false;
      }

      // Generate a venueId for the new claim. claimVenue handles both
      // pre-existing and new venues atomically.
      const venueId = doc(collection(db, 'venue_enhancements')).id;

      await claimVenue({
        venueId,
        businessName: data.venueName,
        contactEmail: data.email,
        ownerRole: 'owner',
        venueType: data.venueType,
        venuePhoneNumber: data.phone,
      });

      setClaimedVenueId(venueId);
      return true;
    } catch (err: any) {
      setError(err.message || 'Failed to submit venue claim');
      return false;
    } finally {
      setLoading(false);
    }
  };

  const handleGoToDashboard = () => {
    navigate('/venue');
  };

  const handlePayNow = () => {
    if (claimedVenueId) {
      navigate(`/venue/billing?venueId=${claimedVenueId}`);
    } else {
      navigate('/venue/billing');
    }
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
              const success = await handleSubmitClaim();
              if (success) handleNext();
            }}
            onBack={handleBack}
            loading={loading}
            error={error}
          />
        );
      case 4:
        return (
          <VerificationStep
            venueId={claimedVenueId}
            phone={data.phone}
            onVerified={handleNext}
            onBack={handleBack}
          />
        );
      case 5:
        return (
          <SuccessStep
            venueName={data.venueName}
            onPayNow={handlePayNow}
            onGoToDashboard={handleGoToDashboard}
          />
        );
      default:
        return null;
    }
  };

  return (
    <div className="min-h-screen flex flex-col" style={{ background: 'var(--pregame-dark-bg)' }}>
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
                    style={{
                      color:
                        currentStep >= step.id
                          ? 'var(--pregame-text-light)'
                          : 'var(--pregame-text-muted)',
                    }}
                  >
                    {step.name}
                  </span>
                </div>
                {index < STEPS.length - 1 && (
                  <div
                    className="flex-1 h-1 mx-2 rounded"
                    style={{
                      background:
                        currentStep > step.id ? '#22c55e' : 'rgba(255,255,255,0.1)',
                    }}
                  />
                )}
              </React.Fragment>
            ))}
          </div>
          <div className="text-center mt-4">
            <p
              className="text-lg font-semibold"
              style={{ color: 'var(--pregame-text-light)' }}
            >
              {STEPS[currentStep - 1].description}
            </p>
            <p className="text-sm" style={{ color: 'var(--pregame-text-muted)' }}>
              Step {currentStep} of {STEPS.length}
            </p>
          </div>
        </div>
      </div>

      <div className="flex-1 flex items-start justify-center px-4 py-8">
        <div className="w-full max-w-2xl">{renderStepContent()}</div>
      </div>
    </div>
  );
};

export default VenueSignupWizard;

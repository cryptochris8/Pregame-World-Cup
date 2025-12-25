// Environment configuration for React app
// This file centralizes all environment variable access

declare global {
  interface Window {
    ENV?: {
      REACT_APP_STRIPE_PUBLISHABLE_KEY?: string;
      REACT_APP_FIREBASE_API_KEY?: string;
      REACT_APP_ENVIRONMENT?: string;
    };
  }
}

interface EnvironmentConfig {
  stripePublishableKey: string;
  firebaseApiKey: string;
  sportsDataApiKey: string;
  environment: 'development' | 'staging' | 'production';
  isDevelopment: boolean;
  isProduction: boolean;
}

// Get environment variable with fallback
function getEnvVar(key: string, defaultValue: string = ''): string {
  // Try environment variables (build time)
  try {
    // Use a type-safe way to access process.env
    const envValue = (window as any)?.__ENV__?.[key] || 
                    (typeof globalThis !== 'undefined' && (globalThis as any).process?.env?.[key]);
    if (envValue) return envValue;
  } catch (e) {
    // Process not available in browser
  }
  
  // Try window.ENV (runtime)
  if (typeof window !== 'undefined' && window.ENV) {
    const value = window.ENV[key as keyof typeof window.ENV];
    if (value) return value;
  }
  
  return defaultValue;
}

// Environment configuration
export const environment: EnvironmentConfig = {
  stripePublishableKey: getEnvVar(
    'REACT_APP_STRIPE_PUBLISHABLE_KEY',
    'pk_test_default_key_replace_me'
  ),
  firebaseApiKey: getEnvVar(
    'REACT_APP_FIREBASE_API_KEY',
    ''
  ),
  sportsDataApiKey: getEnvVar(
    'REACT_APP_SPORTSDATA_API_KEY',
    ''
  ),
  environment: (getEnvVar('REACT_APP_ENVIRONMENT', 'development') as any) || 'development',
  get isDevelopment() {
    return this.environment === 'development';
  },
  get isProduction() {
    return this.environment === 'production';
  }
};

// Validation function
export function validateEnvironment(): { isValid: boolean; missingKeys: string[] } {
  const required: Array<{ key: keyof EnvironmentConfig; value: string }> = [
    { key: 'stripePublishableKey', value: environment.stripePublishableKey }
  ];
  
  const missingKeys: string[] = [];
  
  for (const { key, value } of required) {
    if (!value || value === 'pk_test_default_key_replace_me') {
      missingKeys.push(key);
    }
  }
  
  if (missingKeys.length > 0) {
    console.warn('⚠️ Environment validation failed. Missing or invalid keys:', missingKeys);
  }
  
  return {
    isValid: missingKeys.length === 0,
    missingKeys
  };
}

// Initialize validation on module load
if (environment.isDevelopment) {
  validateEnvironment();
} 
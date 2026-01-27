/// Configuration file for API keys
/// 
/// SECURITY: API keys are now loaded from environment variables
/// DO NOT commit actual API keys to version control
class ApiKeys {
  // Google Places API Key - loaded from environment
  static const String googlePlaces = String.fromEnvironment(
    'GOOGLE_PLACES_API_KEY',
    defaultValue: '', // Will cause graceful failure if not set
  );
  
  // SportsData.io API Key - loaded from environment
  static const String sportsDataIo = String.fromEnvironment(
    'SPORTSDATA_API_KEY',
    defaultValue: '',
  );
  
  // Firebase Cloud Functions Base URL
  static const String cloudFunctionsBaseUrl = String.fromEnvironment(
    'FIREBASE_FUNCTIONS_URL',
    defaultValue: 'https://us-central1-pregame-b089e.cloudfunctions.net',
  );
  
  // OpenAI API Key - loaded from environment  
  static const String openAI = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: '',
  );
  
  // Claude API Key - loaded from environment
  static const String claude = String.fromEnvironment(
    'CLAUDE_API_KEY',
    defaultValue: '',
  );
  
  // Stripe keys - different for dev/prod
  static const String stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: '',
  );
  
  // Validation method to check if keys are properly configured
  static bool validateApiKeys() {
    final missingKeys = <String>[];

    // Check each key individually
    if (googlePlaces.isEmpty) {
      missingKeys.add('GOOGLE_PLACES_API_KEY');
    }

    if (sportsDataIo.isEmpty) {
      missingKeys.add('SPORTSDATA_API_KEY');
    }

    if (openAI.isEmpty) {
      missingKeys.add('OPENAI_API_KEY');
    }

    if (claude.isEmpty) {
      missingKeys.add('CLAUDE_API_KEY');
    }

    if (stripePublishableKey.isEmpty) {
      missingKeys.add('STRIPE_PUBLISHABLE_KEY');
    }

    return missingKeys.isEmpty;
  }
  
  // Check if running in development mode
  static bool get isDevelopment => 
    const String.fromEnvironment('ENVIRONMENT', defaultValue: 'development') == 'development';
} 
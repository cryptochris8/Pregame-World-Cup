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
    
    print('🔑 API KEYS VALIDATION - DETAILED DIAGNOSTIC:');
    print('   Environment: ${const String.fromEnvironment('ENVIRONMENT', defaultValue: 'unknown')}');
    
    // Check each key individually with detailed logging
    if (googlePlaces.isEmpty) {
      missingKeys.add('GOOGLE_PLACES_API_KEY');
      print('   ❌ GOOGLE_PLACES_API_KEY: MISSING/EMPTY');
    } else {
      print('   ✅ GOOGLE_PLACES_API_KEY: Present (${googlePlaces.length} chars, starts with ${googlePlaces.substring(0, 4)}...)');
    }
    
    if (sportsDataIo.isEmpty) {
      missingKeys.add('SPORTSDATA_API_KEY');
      print('   ❌ SPORTSDATA_API_KEY: MISSING/EMPTY');
    } else {
      print('   ✅ SPORTSDATA_API_KEY: Present (${sportsDataIo.length} chars)');
    }
    
    if (openAI.isEmpty) {
      missingKeys.add('OPENAI_API_KEY');
      print('   ❌ OPENAI_API_KEY: MISSING/EMPTY');
    } else {
      print('   ✅ OPENAI_API_KEY: Present (${openAI.length} chars)');
    }
    
    if (claude.isEmpty) {
      missingKeys.add('CLAUDE_API_KEY');
      print('   ❌ CLAUDE_API_KEY: MISSING/EMPTY');
    } else {
      print('   ✅ CLAUDE_API_KEY: Present (${claude.length} chars)');
    }
    
    if (stripePublishableKey.isEmpty) {
      missingKeys.add('STRIPE_PUBLISHABLE_KEY');
      print('   ❌ STRIPE_PUBLISHABLE_KEY: MISSING/EMPTY');
    } else {
      print('   ✅ STRIPE_PUBLISHABLE_KEY: Present (${stripePublishableKey.length} chars)');
    }
    
    if (missingKeys.isNotEmpty) {
      print('⚠️  SECURITY WARNING: Missing API keys: ${missingKeys.join(', ')}');
      print('   Set these as environment variables or --dart-define arguments');
      return false;
    }
    
    print('✅ API KEYS: All required keys are configured');
    return true;
  }
  
  // Check if running in development mode
  static bool get isDevelopment => 
    const String.fromEnvironment('ENVIRONMENT', defaultValue: 'development') == 'development';
} 
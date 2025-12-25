import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import '../../../config/api_keys.dart';
import 'logging_service.dart';

/// Firebase App Check service to protect APIs from abuse
/// App Check helps protect your API resources from abuse by preventing 
/// unauthorized clients from accessing your backend resources.
class FirebaseAppCheckService {
  static const String _logTag = 'FirebaseAppCheckService';
  static bool _isInitialized = false;

  /// Initialize Firebase App Check
  /// This should be called early in app startup, before any API calls
  static Future<void> initialize() async {
    if (_isInitialized) {
      LoggingService.info('App Check already initialized', tag: _logTag);
      return;
    }

    try {
      LoggingService.info('Initializing Firebase App Check...', tag: _logTag);
      
      if (kDebugMode || ApiKeys.isDevelopment) {
        // Use debug provider in development
        await FirebaseAppCheck.instance.activate(
          // Debug provider for development/testing
          // Note: debugProvider parameter has been removed in newer versions
          // App Check will automatically use debug tokens in debug mode
        );
        LoggingService.info('App Check initialized with debug provider', tag: _logTag);
      } else {
        // Production configuration
        await FirebaseAppCheck.instance.activate(
          // Production providers will be auto-configured
          // iOS: deviceCheckProvider (requires iOS 11+)
          // Android: playIntegrityProvider (replaces safetyNet)
        );
        LoggingService.info('App Check initialized with production providers', tag: _logTag);
      }

      _isInitialized = true;
      LoggingService.info('✅ Firebase App Check successfully initialized', tag: _logTag);
      
    } catch (e) {
      LoggingService.error('Failed to initialize Firebase App Check: $e', tag: _logTag);
      // Don't throw error - app should still work without App Check
      // but log the issue for monitoring
    }
  }

  /// Get current App Check token
  /// Useful for debugging or manual token verification
  static Future<String?> getToken({bool forceRefresh = false}) async {
    try {
      final token = await FirebaseAppCheck.instance.getToken(forceRefresh);
      LoggingService.info('App Check token obtained successfully', tag: _logTag);
      return token;
    } catch (e) {
      LoggingService.error('Failed to get App Check token: $e', tag: _logTag);
      return null;
    }
  }

  /// Verify App Check is working
  /// Call this after initialization to ensure everything is set up correctly
  static Future<bool> verifySetup() async {
    try {
      final token = await getToken();
      final isValid = token != null && token.isNotEmpty;
      
      if (isValid) {
        LoggingService.info('✅ App Check verification passed', tag: _logTag);
      } else {
        LoggingService.warning('⚠️ App Check verification failed - no valid token', tag: _logTag);
      }
      
      return isValid;
    } catch (e) {
      LoggingService.error('App Check verification error: $e', tag: _logTag);
      return false;
    }
  }

  /// Check if App Check is properly initialized
  static bool get isInitialized => _isInitialized;
} 
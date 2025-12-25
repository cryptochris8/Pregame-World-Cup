/// AI Performance Configuration
/// Centralized settings for AI analysis timeouts and optimization
class AIPerformanceConfig {
  // OPTIMIZED TIMEOUT SETTINGS
  static const Duration overallAnalysisTimeout = Duration(seconds: 6);
  static const Duration memoryPressureTimeout = Duration(seconds: 3);
  static const Duration parallelExecutionTimeout = Duration(seconds: 4);
  
  // Individual service timeouts (aggressive for better UX)
  static const Duration predictionTimeout = Duration(seconds: 2);
  static const Duration summaryTimeout = Duration(seconds: 1);
  static const Duration playerDataTimeout = Duration(seconds: 1);
  
  // API timeouts
  static const Duration openAITimeout = Duration(seconds: 5);
  static const Duration claudeTimeout = Duration(seconds: 5);
  static const Duration sportsDataTimeout = Duration(seconds: 3);
  
  // Cache settings
  static const Duration cacheExpiry = Duration(minutes: 30);
  static const int maxCacheSize = 100;
  
  // Memory optimization
  static const bool enableParallelExecution = true;
  static const bool enableAggressiveCaching = true;
  static const bool enableFastFallbacks = true;
  
  // Performance thresholds
  static const int memoryPressureThresholdMB = 512;
  static const int lowPerformanceDeviceThreshold = 1024;
  
  /// Get timeout based on current system conditions
  static Duration getAdaptiveTimeout({
    required Duration baseTimeout,
    bool isMemoryPressure = false,
    bool isLowPerformanceDevice = false,
  }) {
    if (isMemoryPressure) {
      return Duration(milliseconds: (baseTimeout.inMilliseconds * 0.5).round());
    }
    if (isLowPerformanceDevice) {
      return Duration(milliseconds: (baseTimeout.inMilliseconds * 0.7).round());
    }
    return baseTimeout;
  }
  
  /// Check if device is under memory pressure
  static bool isMemoryPressure() {
    // In a real implementation, you could check actual memory usage
    // For now, return false but this can be enhanced
    return false;
  }
  
  /// Check if device is low performance
  static bool isLowPerformanceDevice() {
    // In a real implementation, you could check device specs
    // For now, return false but this can be enhanced
    return false;
  }
} 
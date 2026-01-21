import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../features/worldcup/domain/services/world_cup_payment_service.dart';

/// RevenueCat Service for handling native in-app purchases
///
/// Manages Fan Pass and Superfan Pass purchases through Apple/Google IAP
/// Venue Premium stays on Stripe (B2B, exempt from IAP rules)
class RevenueCatService {
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  static const String _logTag = 'RevenueCat';

  // RevenueCat API Keys - replace with your actual keys from RevenueCat dashboard
  // These are public keys and safe to include in the app
  static const String _iosApiKey = 'YOUR_REVENUECAT_IOS_API_KEY';
  static const String _androidApiKey = 'YOUR_REVENUECAT_ANDROID_API_KEY';

  // Entitlement IDs (must match RevenueCat dashboard)
  static const String _fanPassEntitlement = 'fan_pass';
  static const String _superfanPassEntitlement = 'superfan_pass';

  // Product IDs (must match App Store Connect / Google Play Console)
  static const String fanPassProductId = 'com.christophercampbell.pregameworldcup.fan_pass';
  static const String superfanPassProductId = 'com.christophercampbell.pregameworldcup.superfan_pass';

  bool _isInitialized = false;
  CustomerInfo? _cachedCustomerInfo;

  /// Check if RevenueCat is properly configured with real API keys
  bool get isConfigured =>
      _iosApiKey != 'YOUR_REVENUECAT_IOS_API_KEY' &&
      _androidApiKey != 'YOUR_REVENUECAT_ANDROID_API_KEY';

  /// Initialize RevenueCat SDK
  /// Should be called once during app startup
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Skip initialization if API keys are not configured
      if (!isConfigured) {
        _log('RevenueCat API keys not configured - skipping initialization');
        return;
      }

      final apiKey = Platform.isIOS ? _iosApiKey : _androidApiKey;

      // Configure RevenueCat
      final configuration = PurchasesConfiguration(apiKey);

      // Enable debug logs in debug mode
      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      }

      await Purchases.configure(configuration);

      // If user is already authenticated, login to RevenueCat
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await loginUser(currentUser.uid);
      }

      _isInitialized = true;
      _log('RevenueCat initialized successfully');
    } catch (e) {
      _log('Error initializing RevenueCat: $e');
      // Don't rethrow - allow app to continue without IAP
    }
  }

  /// Login user to RevenueCat (called when Firebase auth succeeds)
  Future<void> loginUser(String userId) async {
    if (!_isInitialized || !isConfigured) return;

    try {
      final result = await Purchases.logIn(userId);
      _cachedCustomerInfo = result.customerInfo;
      _log('User logged in to RevenueCat: $userId');
    } catch (e) {
      _log('Error logging in to RevenueCat: $e');
    }
  }

  /// Logout user from RevenueCat (called when Firebase auth logs out)
  Future<void> logoutUser() async {
    if (!_isInitialized || !isConfigured) return;

    try {
      _cachedCustomerInfo = null;
      await Purchases.logOut();
      _log('User logged out from RevenueCat');
    } catch (e) {
      _log('Error logging out from RevenueCat: $e');
    }
  }

  /// Get current customer info (entitlements, purchases, etc.)
  Future<CustomerInfo?> getCustomerInfo({bool forceRefresh = false}) async {
    if (!_isInitialized || !isConfigured) return null;

    if (!forceRefresh && _cachedCustomerInfo != null) {
      return _cachedCustomerInfo;
    }

    try {
      _cachedCustomerInfo = await Purchases.getCustomerInfo();
      return _cachedCustomerInfo;
    } catch (e) {
      _log('Error getting customer info: $e');
      return null;
    }
  }

  /// Check if user has Fan Pass entitlement
  Future<bool> hasFanPass() async {
    final customerInfo = await getCustomerInfo();
    if (customerInfo == null) return false;

    // Check for fan_pass or superfan_pass (superfan includes all fan_pass features)
    return customerInfo.entitlements.active.containsKey(_fanPassEntitlement) ||
           customerInfo.entitlements.active.containsKey(_superfanPassEntitlement);
  }

  /// Check if user has Superfan Pass entitlement
  Future<bool> hasSuperfanPass() async {
    final customerInfo = await getCustomerInfo();
    if (customerInfo == null) return false;

    return customerInfo.entitlements.active.containsKey(_superfanPassEntitlement);
  }

  /// Get the current pass type based on entitlements
  Future<FanPassType> getPassType() async {
    final customerInfo = await getCustomerInfo();
    if (customerInfo == null) return FanPassType.free;

    if (customerInfo.entitlements.active.containsKey(_superfanPassEntitlement)) {
      return FanPassType.superfanPass;
    }
    if (customerInfo.entitlements.active.containsKey(_fanPassEntitlement)) {
      return FanPassType.fanPass;
    }
    return FanPassType.free;
  }

  /// Get available offerings (products) for display
  Future<Offerings?> getOfferings() async {
    if (!_isInitialized || !isConfigured) return null;

    try {
      return await Purchases.getOfferings();
    } catch (e) {
      _log('Error getting offerings: $e');
      return null;
    }
  }

  /// Get the package for a specific pass type
  Future<Package?> getPackageForPassType(FanPassType passType) async {
    final offerings = await getOfferings();
    if (offerings == null || offerings.current == null) return null;

    final packageIdentifier = passType == FanPassType.superfanPass
        ? 'superfan_pass_onetime'
        : 'fan_pass_onetime';

    // Try to find the specific package
    final packages = offerings.current!.availablePackages;
    for (final package in packages) {
      if (package.identifier == packageIdentifier) {
        return package;
      }
    }

    // Fallback: look by product ID
    final productId = passType == FanPassType.superfanPass
        ? superfanPassProductId
        : fanPassProductId;

    for (final package in packages) {
      if (package.storeProduct.identifier == productId) {
        return package;
      }
    }

    return null;
  }

  /// Purchase a package (Fan Pass or Superfan Pass)
  /// Returns true if purchase succeeded, false otherwise
  Future<PurchaseResult> purchasePackage(Package package) async {
    if (!_isInitialized || !isConfigured) {
      return PurchaseResult(
        success: false,
        errorMessage: 'RevenueCat not initialized',
      );
    }

    try {
      final customerInfo = await Purchases.purchasePackage(package);
      _cachedCustomerInfo = customerInfo;

      // Check if entitlement is now active
      final hasAccess = customerInfo.entitlements.active.containsKey(_fanPassEntitlement) ||
                        customerInfo.entitlements.active.containsKey(_superfanPassEntitlement);

      return PurchaseResult(
        success: hasAccess,
        customerInfo: customerInfo,
      );
    } on PurchasesErrorCode catch (e) {
      String errorMessage;
      bool userCancelled = false;

      switch (e) {
        case PurchasesErrorCode.purchaseCancelledError:
          errorMessage = 'Purchase was cancelled';
          userCancelled = true;
          break;
        case PurchasesErrorCode.purchaseNotAllowedError:
          errorMessage = 'Purchases are not allowed on this device';
          break;
        case PurchasesErrorCode.purchaseInvalidError:
          errorMessage = 'The purchase was invalid';
          break;
        case PurchasesErrorCode.productNotAvailableForPurchaseError:
          errorMessage = 'This product is not available for purchase';
          break;
        case PurchasesErrorCode.productAlreadyPurchasedError:
          errorMessage = 'You already own this product';
          break;
        case PurchasesErrorCode.networkError:
          errorMessage = 'Network error. Please check your connection';
          break;
        case PurchasesErrorCode.paymentPendingError:
          errorMessage = 'Payment is pending. Please wait for it to complete';
          break;
        default:
          errorMessage = 'Purchase failed: $e';
      }

      _log('Purchase error: $e');
      return PurchaseResult(
        success: false,
        errorMessage: errorMessage,
        userCancelled: userCancelled,
      );
    } catch (e) {
      _log('Purchase error: $e');
      return PurchaseResult(
        success: false,
        errorMessage: 'An unexpected error occurred',
      );
    }
  }

  /// Purchase a fan pass by type
  Future<PurchaseResult> purchaseFanPassByType(FanPassType passType) async {
    if (passType == FanPassType.free) {
      return PurchaseResult(
        success: false,
        errorMessage: 'Cannot purchase free tier',
      );
    }

    final package = await getPackageForPassType(passType);
    if (package == null) {
      return PurchaseResult(
        success: false,
        errorMessage: 'Product not available. Please try again later.',
      );
    }

    return purchasePackage(package);
  }

  /// Restore previous purchases
  Future<RestoreResult> restorePurchases() async {
    if (!_isInitialized || !isConfigured) {
      return RestoreResult(
        success: false,
        errorMessage: 'RevenueCat not initialized',
      );
    }

    try {
      final customerInfo = await Purchases.restorePurchases();
      _cachedCustomerInfo = customerInfo;

      // Check what was restored
      final hasAccess = customerInfo.entitlements.active.isNotEmpty;
      FanPassType restoredPassType = FanPassType.free;

      if (customerInfo.entitlements.active.containsKey(_superfanPassEntitlement)) {
        restoredPassType = FanPassType.superfanPass;
      } else if (customerInfo.entitlements.active.containsKey(_fanPassEntitlement)) {
        restoredPassType = FanPassType.fanPass;
      }

      return RestoreResult(
        success: true,
        hasRestoredPurchases: hasAccess,
        restoredPassType: restoredPassType,
        customerInfo: customerInfo,
      );
    } catch (e) {
      _log('Error restoring purchases: $e');
      return RestoreResult(
        success: false,
        errorMessage: 'Failed to restore purchases. Please try again.',
      );
    }
  }

  /// Get the price string for a pass type (for display)
  Future<String?> getPriceForPassType(FanPassType passType) async {
    final package = await getPackageForPassType(passType);
    if (package == null) return null;
    return package.storeProduct.priceString;
  }

  /// Clear cached data
  void clearCache() {
    _cachedCustomerInfo = null;
  }

  void _log(String message) {
    if (kDebugMode) {
      print('[$_logTag] $message');
    }
  }
}

/// Result of a purchase attempt
class PurchaseResult {
  final bool success;
  final String? errorMessage;
  final bool userCancelled;
  final CustomerInfo? customerInfo;

  PurchaseResult({
    required this.success,
    this.errorMessage,
    this.userCancelled = false,
    this.customerInfo,
  });
}

/// Result of a restore attempt
class RestoreResult {
  final bool success;
  final bool hasRestoredPurchases;
  final FanPassType restoredPassType;
  final String? errorMessage;
  final CustomerInfo? customerInfo;

  RestoreResult({
    required this.success,
    this.hasRestoredPurchases = false,
    this.restoredPassType = FanPassType.free,
    this.errorMessage,
    this.customerInfo,
  });
}

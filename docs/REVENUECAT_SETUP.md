# RevenueCat Setup Guide

This guide covers setting up RevenueCat for native in-app purchases in the Pregame World Cup app.

## Overview

- **Fan Pass**: $14.99 (one-time purchase)
- **Superfan Pass**: $29.99 (one-time purchase)
- **Venue Premium**: $99.00 (stays on Stripe - B2B, exempt from IAP rules)

---

## Step 1: RevenueCat Project Created

Project name: `Pregame World Cup`
Platform: Flutter

**Test Store API Key** (for development):
```
test_MFlhygrdunfDNFjjvGIVMCMlnwe
```

---

## Step 2: Configure iOS App

1. Go to **Apps & providers** → Click **New app configuration**
2. Select **App Store (iOS)**
3. Fill in:
   - **App name**: `Pregame World Cup iOS`
   - **Bundle ID**: `com.christophercampbell.pregameworldcup`
4. Click **Save**
5. **Copy the iOS API Key** (starts with `appl_...`)

### App Store Connect Setup (Required for real purchases)

1. Go to [App Store Connect](https://appstoreconnect.apple.com) → Your App → **In-App Purchases**
2. Click **+** → **Non-Consumable**
3. Create Fan Pass:
   - **Reference Name**: `Fan Pass`
   - **Product ID**: `com.christophercampbell.pregameworldcup.fan_pass`
   - **Price**: $14.99
   - Add localization (display name, description)
4. Create Superfan Pass:
   - **Reference Name**: `Superfan Pass`
   - **Product ID**: `com.christophercampbell.pregameworldcup.superfan_pass`
   - **Price**: $29.99
   - Add localization (display name, description)
5. Get your **App Store Connect Shared Secret**:
   - App Store Connect → Your App → In-App Purchases → App-Specific Shared Secret
   - Copy and paste into RevenueCat iOS app settings

---

## Step 3: Configure Android App

1. Go to **Apps & providers** → Click **New app configuration**
2. Select **Play Store (Android)**
3. Fill in:
   - **App name**: `Pregame World Cup Android`
   - **Package name**: `com.christophercampbell.pregameworldcup`
4. Click **Save**
5. **Copy the Android API Key** (starts with `goog_...`)

### Google Play Console Setup (Required for real purchases)

1. Go to [Google Play Console](https://play.google.com/console) → Your App → **Monetize** → **Products** → **In-app products**
2. Click **Create product**
3. Create Fan Pass:
   - **Product ID**: `fan_pass`
   - **Name**: `Fan Pass`
   - **Description**: `Ad-free experience, advanced stats, custom alerts, social features`
   - **Price**: $14.99
4. Create Superfan Pass:
   - **Product ID**: `superfan_pass`
   - **Name**: `Superfan Pass`
   - **Description**: `Everything in Fan Pass + exclusive content, AI insights, priority features`
   - **Price**: $29.99
5. **Service Account JSON** (for RevenueCat to verify purchases):
   - Google Cloud Console → Create Service Account
   - Grant "Pub/Sub Admin" and "Monitoring Viewer" roles
   - Download JSON key file
   - Upload to RevenueCat Android app settings
   - Grant service account access in Play Console → Users & Permissions

---

## Step 4: Create Entitlements

Go to **Product catalog** → **Entitlements** → **+ New**

| Identifier | Description |
|------------|-------------|
| `fan_pass` | Fan Pass features (ad-free, advanced stats, alerts) |
| `superfan_pass` | Superfan Pass (includes all fan_pass + exclusive content, AI insights) |

---

## Step 5: Create Products in RevenueCat

Go to **Product catalog** → **Products** → **+ New**

### Product 1 - Fan Pass
- **Identifier**: `com.christophercampbell.pregameworldcup.fan_pass` (iOS) / `fan_pass` (Android)
- **App**: Select iOS or Android app
- **Type**: Non-Consumable (Lifetime)
- Click **Attach to entitlement** → Select `fan_pass`

### Product 2 - Superfan Pass
- **Identifier**: `com.christophercampbell.pregameworldcup.superfan_pass` (iOS) / `superfan_pass` (Android)
- **App**: Select iOS or Android app
- **Type**: Non-Consumable (Lifetime)
- Click **Attach to entitlement** → Select `superfan_pass`

**Note**: Create products for BOTH iOS and Android apps (4 products total)

---

## Step 6: Create Offering

Go to **Product catalog** → **Offerings** → **+ New**

1. **Identifier**: `default`
2. **Description**: `World Cup 2026 Passes`
3. Click **Add Package**:

| Package Identifier | Description |
|-------------------|-------------|
| `fan_pass_onetime` | Fan Pass one-time purchase |
| `superfan_pass_onetime` | Superfan Pass one-time purchase |

4. For each package, click **Attach product** and add both iOS and Android products
5. Make sure this offering is set as the **Current Offering**

---

## Step 7: Update Code with API Keys

Once you have the API keys, update `lib/services/revenuecat_service.dart`:

```dart
// Replace these with your actual keys from RevenueCat dashboard
static const String _iosApiKey = 'appl_YOUR_IOS_KEY_HERE';
static const String _androidApiKey = 'goog_YOUR_ANDROID_KEY_HERE';
```

For testing only, you can use the Test Store key:
```dart
static const String _iosApiKey = 'test_MFlhygrdunfDNFjjvGIVMCMlnwe';
static const String _androidApiKey = 'test_MFlhygrdunfDNFjjvGIVMCMlnwe';
```

---

## Step 8: Configure Sandbox Testing

### iOS Sandbox Testing
1. App Store Connect → Users and Access → Sandbox → Testers
2. Create a sandbox tester account
3. On your test device, sign out of App Store, then sign in with sandbox account

### Android Testing
1. Google Play Console → Setup → License testing
2. Add tester email addresses
3. Testers can make purchases without being charged

### RevenueCat Sandbox
1. In RevenueCat dashboard → **Configure sandbox access**
2. Add your test user IDs or emails

---

## Verification Checklist

- [ ] iOS app configured in RevenueCat
- [ ] Android app configured in RevenueCat
- [ ] Products created in App Store Connect
- [ ] Products created in Google Play Console
- [ ] Entitlements created (`fan_pass`, `superfan_pass`)
- [ ] Products created in RevenueCat and linked to entitlements
- [ ] Offering created with packages
- [ ] API keys added to code
- [ ] App Store Shared Secret added (iOS)
- [ ] Service Account JSON uploaded (Android)
- [ ] Sandbox testers configured

---

## Testing Flow

1. **Test purchase flow:**
   - Open Fan Pass screen
   - Tap "Get Fan Pass" or "Get Superfan Pass"
   - Native iOS/Android payment sheet appears
   - Complete purchase (sandbox)
   - Features unlock immediately

2. **Test restore purchases:**
   - Reinstall app or use new device
   - Tap "Restore Purchases"
   - Previous purchases restore

3. **Test backward compatibility:**
   - User with existing Stripe purchase still has access
   - Admin account still has full access

4. **Test ads:**
   - Free user sees ads
   - Fan Pass user sees no ads

---

## Files Modified for RevenueCat Integration

| File | Changes |
|------|---------|
| `pubspec.yaml` | Added `purchases_flutter: ^8.3.0` |
| `lib/services/revenuecat_service.dart` | NEW - RevenueCat wrapper service |
| `lib/main.dart` | Added RevenueCat initialization |
| `lib/features/worldcup/domain/services/world_cup_payment_service.dart` | Hybrid RevenueCat + Stripe logic |
| `lib/features/worldcup/presentation/screens/fan_pass_screen.dart` | Native purchase UI + restore button |
| `lib/injection_container.dart` | Registered RevenueCatService |

---

## What Stays the Same

- **Venue Premium** - Keeps Stripe checkout (B2B payment)
- **Watch Party payments** - Keeps Stripe (one-time payments)
- **AdService** - No changes (already uses `getCachedFanPassStatus()`)
- **FanPassFeatureGate** - No changes (already uses payment service)
- **Admin test account** - Still works (checked before RevenueCat)
- **Existing Stripe purchases** - Still honored (Firestore fallback)

---

## Resources

- [RevenueCat Flutter SDK Docs](https://docs.revenuecat.com/docs/flutter)
- [App Store Connect Help](https://developer.apple.com/help/app-store-connect/)
- [Google Play Billing](https://developer.android.com/google/play/billing)
- [RevenueCat Dashboard](https://app.revenuecat.com)

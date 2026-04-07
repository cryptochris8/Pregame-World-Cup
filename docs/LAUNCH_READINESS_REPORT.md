# Pregame World Cup 2026 -- Launch Readiness Report

**Date**: February 27, 2026
**Author**: Comprehensive codebase review (automated)

---

## Table of Contents

1. [Getting the App Live with Apple](#1-getting-the-app-live-with-apple)
2. [Payment Systems](#2-payment-systems)
3. [Codemagic & Environment Variables](#3-codemagic--environment-variables)
4. [Google Play Store Submission](#4-google-play-store-submission)
5. [Overall Readiness Summary](#5-overall-readiness-summary)

---

## 1. Getting the App Live with Apple

### Critical Blockers (Must Fix)

| # | Issue | Details |
|---|-------|---------|
| 1 | **Bundle ID mismatch** | `firebase_options.dart` uses `com.christophercampbell.pregame` but Xcode project + Codemagic use `com.christophercampbell.pregameworldcup`. This will break Firebase Auth, FCM, and Analytics. |
| 2 | **Three different Firebase iOS App IDs** | Root `GoogleService-Info.plist`, `ios/Runner/GoogleService-Info.plist`, and `firebase_options.dart` all have different `GOOGLE_APP_ID` values. Must be unified. |
| 3 | **Missing `NSUserTrackingUsageDescription`** | App uses AdMob but has no App Tracking Transparency description in Info.plist. Apple **will reject** without it. |
| 4 | **Missing `ITSAppUsesNonExemptEncryption`** | Without this key, every TestFlight/App Store upload requires manual export compliance confirmation. |
| 5 | ~~**Push notification entitlement set to `development`**~~ | ~~`Runner.entitlements` has `aps-environment = development`.~~ **FIXED Feb 27** -- set to `production` |
| 6 | ~~**Entitlements keychain group uses old bundle ID**~~ | ~~`Runner.entitlements` references `com.christophercampbell.pregame`.~~ **FIXED Feb 27** -- updated to `pregameworldcup` |

### Bundle ID Mismatch Details

There are three different iOS bundle identifiers scattered across the project:

| Location | Bundle ID | Notes |
|----------|-----------|-------|
| `ios/Runner.xcodeproj/project.pbxproj` | `com.christophercampbell.pregameworldcup` | The ACTUAL Xcode build ID |
| `ios/Runner/GoogleService-Info.plist` | `com.christophercampbell.pregameworldcup` | Matches Xcode |
| `codemagic.yaml` | `com.christophercampbell.pregameworldcup` | Matches Xcode |
| `lib/firebase_options.dart` | `com.christophercampbell.pregame` | **MISMATCH** |
| `ios/Runner/Runner.entitlements` | `com.christophercampbell.pregame` | **MISMATCH** |
| Root `GoogleService-Info.plist` | `com.christophercampbell.pregame` | **MISMATCH** |
| `docs/TESTFLIGHT_GUIDE.md` | `com.christophercampbell.pregame` | **MISMATCH** |
| `docs/PAYMENT_MANUAL_SETUP_CHECKLIST.md` | `com.christophercampbell.pregame` | **MISMATCH** |

There are also **three different Firebase iOS app IDs**:

| File | GOOGLE_APP_ID | BUNDLE_ID |
|------|--------------|-----------|
| Root `GoogleService-Info.plist` | `1:942034010384:ios:bb3771c0d9596ccf99a595` | `com.christophercampbell.pregame` |
| `ios/Runner/GoogleService-Info.plist` | `1:942034010384:ios:3f7b887b3877f14e99a595` | `com.christophercampbell.pregameworldcup` |
| `lib/firebase_options.dart` | `1:942034010384:ios:c3264211ef6ee5a799a595` | `com.christophercampbell.pregame` |

### Resolution for Bundle ID Fix

```
1. Decide on: com.christophercampbell.pregameworldcup (matches Xcode + Codemagic)
2. Update lib/firebase_options.dart -> iosBundleId + appId
3. Update ios/Runner/Runner.entitlements -> keychain group
4. Re-download GoogleService-Info.plist from Firebase Console
5. Delete root-level GoogleService-Info.plist
6. Verify Firebase Console has iOS app for correct bundle ID
```

### High Priority (Required for Listing)

| # | Task | Details |
|---|------|---------|
| 7 | **Create App Store Connect listing** | App name, subtitle, description, keywords, categories, age rating, copyright |
| 8 | **Upload screenshots** | Need 6.7" and 6.5" iPhone screenshots (minimum). Currently only have website screenshots and raw photos. |
| 9 | **Enter privacy declarations** | 13 data types documented in `APP_STORE_PRIVACY_GUIDE.md` -- must be entered manually in App Store Connect. |
| 10 | **Create IAP products** | Fan Pass ($14.99) and Superfan Pass ($29.99) must be created in App Store Connect with display names, descriptions, and review screenshots. |
| 11 | **Set privacy policy URL** | `https://pregameworldcup.com/privacy` -- needs to be entered in App Store Connect. |
| 12 | **Verify RevenueCat iOS key** | Confirm Codemagic vault has `REVENUECAT_IOS_API_KEY` set to a production `appl_` key (not test). |
| 13 | **Implement ATT prompt** | Call `ATTrackingManager.requestTrackingAuthorization` before loading AdMob ads. |
| 14 | **Add privacy/terms links in-app** | Apple requires these be accessible within the app (settings screen). Currently no URL launcher calls to these pages. |

### App Store Connect Metadata Needed

- **App Name**: "Pregame WC26" (currently in Info.plist)
- **Subtitle**: Up to 30 characters
- **Description**: Up to 4,000 characters
- **Keywords**: Up to 100 characters, comma-separated
- **Promotional Text**: Up to 170 characters (can be updated without new build)
- **What's New**: Release notes for the version
- **Support URL**: `https://pregameworldcup.com/support`
- **Privacy Policy URL**: `https://pregameworldcup.com/privacy`
- **Primary Category**: Sports
- **Secondary Category**: Social Networking or Entertainment
- **Age Rating**: Fill out the questionnaire (contains user-generated content, social features)
- **Copyright**: "2026 Chris Campbell" or similar

### Screenshot Requirements

Since `TARGETED_DEVICE_FAMILY = "1"` (iPhone only):
- 6.7" display (iPhone 15 Pro Max / 14 Plus): 1290 x 2796 px -- **REQUIRED**
- 6.5" display (iPhone 14 Pro Max): 1284 x 2778 px or 1242 x 2688 px -- **REQUIRED**
- 5.5" display (iPhone 8 Plus): 1242 x 2208 px -- optional but recommended
- Minimum 3 screenshots, maximum 10, per device size

### IAP Products to Create in App Store Connect

| Product ID | Type | Price |
|-----------|------|-------|
| `com.christophercampbell.pregameworldcup.fan_pass` | Non-Consumable | $14.99 |
| `com.christophercampbell.pregameworldcup.superfan_pass` | Non-Consumable | $29.99 |

Each requires: display name, description, screenshot (for Apple review), pricing tier.

### Medium Priority

- **WorldCupWidget extension** not integrated into Xcode project (files exist but no build target)
- **Universal Links**: `apple-app-site-association` file missing from website; deep links won't work
- ~~**Analytics disabled** in `GoogleService-Info.plist`~~ **FIXED Feb 27** -- `IS_ANALYTICS_ENABLED` set to `true`
- ~~**Stale root-level `GoogleService-Info.plist`**~~ **FIXED Feb 27** -- deleted
- **No privacy policy / terms of service links** in the app UI (settings screens)
- **Version number** is `1.0.0+1` in pubspec.yaml (Codemagic overrides with `$BUILD_NUMBER` at build time)
- **iPad support excluded** (`TARGETED_DEVICE_FAMILY = "1"` iPhone only) -- deliberate choice, fine for now
- **`ENABLE_USER_SCRIPT_SANDBOXING = NO`** in Xcode project -- not a blocker but future Xcode versions may require it

### Lower Priority (Post-Launch)

- No App Preview video (recommended, not required)
- Missing `NSCalendarsUsageDescription` (only needed if calendar plugin requires direct EventKit access)
- Stale documentation referencing old bundle IDs (`ios/README.md`, `TESTFLIGHT_GUIDE.md`)

---

## 2. Payment Systems

### Architecture Overview

The payment system uses a **dual-billing architecture**:

- **Stripe** (web/backend): For all Stripe Checkout flows (browser-based) and Venue Premium (B2B, exempt from app store IAP rules)
- **RevenueCat** (native iOS/Android IAP): For Fan Pass and Superfan Pass via Apple App Store / Google Play Store native in-app purchase

### Products

| Product | Price | Type | Channel |
|---|---|---|---|
| Fan Pass | $14.99 | One-time | RevenueCat (native IAP) or Stripe (browser fallback) |
| Superfan Pass | $29.99 | One-time | RevenueCat (native IAP) or Stripe (browser fallback) |
| Venue Premium | $499 | One-time | Stripe only |

### What's Working

- Stripe Cloud Functions (20+ functions) deployed and active
- 3 webhook endpoints registered with signature verification + idempotency
- Fan Pass browser checkout flow (Stripe Checkout URL -> deep link return -> Firestore listener)
- Venue Premium checkout (Stripe-only, B2B exempt from IAP rules)
- Watch Party virtual attendance (in-app Stripe Payment Sheet)
- Feature gating (`FanPassFeatureGate` widget) controls 7 premium features
- Rate limiting on all 6 payment checkout functions (5 req/15 min/user)
- RevenueCat iOS fully configured (per previous setup)
- Transaction history screen
- Retry logic with jitter on all Stripe API calls
- Admin/clearance bypass (automatic Superfan access)
- Dual-billing prevention (checks for existing active pass before checkout)
- Scheduled cleanup (expired passes, idempotency records, rate limits)

### What Needs Work

| # | Issue | Priority |
|---|-------|----------|
| 1 | **RevenueCat Android NOT configured** | Critical -- Android users get Stripe browser fallback which may violate Google Play billing policy |
| 2 | **Venue Premium price discrepancy** | Critical -- MEMORY.md says $99, all code says $499. Stripe dashboard is source of truth -- reconcile. |
| 3 | **E2E payment testing NOT done** | Critical -- Step 8 of `PAYMENT_MANUAL_SETUP_CHECKLIST.md` is incomplete. No test payments verified. |
| 4 | **Watch party webhook missing idempotency** | High -- `handleWatchPartyWebhook` does NOT call `isWebhookEventAlreadyProcessed`. Duplicate deliveries could double-process. |
| 5 | **0% Flutter payment test coverage** | High -- No tests for any payment service, RevenueCat, or feature gate. |
| 6 | **Firestore TTL not configured** | Medium -- TTL policy on `expiresAt` for `rate_limits` and `processed_webhook_events` still not set in Firebase Console. |
| 7 | **Legacy `stripe-simple.ts` overlap** | Medium -- Contains old subscription functions that overlap with `world-cup-payments.ts`. `PaymentService` marked `@deprecated` but still exists. |
| 8 | **No Stripe Customer Portal UI** | Low -- `createPortalSession` exists but no Flutter screen calls it. |

### Stripe Cloud Functions

| File | Purpose |
|------|---------|
| `stripe-config.ts` | Shared config: lazy Stripe init, config value helper, webhook idempotency |
| `stripe-simple.ts` | Legacy: `createCheckoutSession`, `createFanCheckoutSession`, `createPaymentIntent`, `createPortalSession`, `setupFreeFanAccount`, `setupFreeVenueAccount`, `handleStripeWebhook` |
| `world-cup-payments.ts` | World Cup: `createFanPassCheckout`, `getFanPassStatus`, `createVenuePremiumCheckout`, `getVenuePremiumStatus`, `handleWorldCupPaymentWebhook`, `checkFanPassAccess`, `getWorldCupPricing`, `checkExpiredPasses` |
| `watch-party-payments.ts` | Watch party: `createVirtualAttendancePayment`, `handleVirtualAttendancePayment`, `requestVirtualAttendanceRefund`, `refundAllVirtualAttendees`, `handleWatchPartyWebhook` |

### Stripe Price IDs (hardcoded with env var override)

```typescript
const WORLD_CUP_PRICES = {
  FAN_PASS: process.env.STRIPE_FAN_PASS_PRICE_ID || 'price_1SnYT9LmA106gMF6SK1oDaWE',
  SUPERFAN_PASS: process.env.STRIPE_SUPERFAN_PASS_PRICE_ID || 'price_1SnYi4LmA106gMF6h5yRgzLL',
  VENUE_PREMIUM: process.env.STRIPE_VENUE_PREMIUM_PRICE_ID || 'price_1SnYm5LmA106gMF63sYAuEB5',
};
```

### Webhook Endpoints (3 separate handlers)

| Webhook | File | Secret Env Var | Events |
|---------|------|---------------|--------|
| `handleStripeWebhook` | stripe-simple.ts | `STRIPE_WEBHOOK_SECRET` | checkout.session.completed, subscription events, invoice events |
| `handleWorldCupPaymentWebhook` | world-cup-payments.ts | `STRIPE_WC_WEBHOOK_SECRET` | checkout.session.completed, payment_intent events |
| `handleWatchPartyWebhook` | watch-party-payments.ts | `STRIPE_WP_WEBHOOK_SECRET` | payment_intent events, charge.refunded |

### Purchase Flows

**Fan Pass (RevenueCat available):**
1. User taps Purchase on `FanPassScreen`
2. `WorldCupPaymentService.purchaseFanPass()` -> `PaymentCheckoutService`
3. Checks for existing pass (prevents re-purchase, allows upgrade)
4. Attempts native IAP via `RevenueCatService.purchaseFanPassByType()`
5. On success, entitlement activates immediately

**Fan Pass (RevenueCat NOT available -- Stripe fallback):**
1. `openFanPassCheckout()` calls `createFanPassCheckout` Cloud Function
2. Gets Stripe Checkout URL, opens in browser via `url_launcher`
3. On return: `didChangeAppLifecycleState` detects `resumed`
4. Starts Firestore real-time listener for pass activation
5. Webhook fires, backend activates pass, listener updates UI

**Venue Premium (always Stripe):**
1. `openVenuePremiumCheckout()` calls `createVenuePremiumCheckout` Cloud Function
2. Opens Stripe Checkout URL in browser
3. Webhook activates premium in `venue_enhancements` collection

**Watch Party Virtual Attendance (in-app Stripe Payment Sheet):**
1. `purchaseVirtualAttendance()` calls `createVirtualAttendancePayment` for clientSecret
2. Presents `Stripe.instance.initPaymentSheet()` + `presentPaymentSheet()` in-app
3. On success, joins as virtual member, records payment

### Environment Variables for Payments

**Flutter (via Codemagic `--dart-define`):**

| Variable | Status |
|----------|--------|
| `STRIPE_PUBLISHABLE_KEY` | Required -- build fails if missing |
| `REVENUECAT_IOS_API_KEY` | Warning only if missing |
| `REVENUECAT_ANDROID_API_KEY` | Warning only; currently test key |

**Cloud Functions (Firebase Functions config or `.env.pregame-b089e`):**

| Variable | Purpose |
|----------|---------|
| `STRIPE_SECRET_KEY` | Stripe API secret key |
| `STRIPE_WEBHOOK_SECRET` | Legacy webhook signing secret |
| `STRIPE_WC_WEBHOOK_SECRET` | World Cup webhook signing secret |
| `STRIPE_WP_WEBHOOK_SECRET` | Watch party webhook signing secret |
| `STRIPE_FAN_PASS_PRICE_ID` | Optional env override for Fan Pass price |
| `STRIPE_SUPERFAN_PASS_PRICE_ID` | Optional env override for Superfan Pass price |
| `STRIPE_VENUE_PREMIUM_PRICE_ID` | Optional env override for Venue Premium price |

### Scheduled Payment Functions

- **`checkExpiredPasses`** (daily 1:00 AM EST): Deactivates expired fan passes, downgrades expired venue premiums, cleans stale idempotency records
- **`cleanupRateLimits`** (daily 3:00 AM EST): Cleans rate_limits + processed_webhook_events collections

---

## 3. Codemagic & Environment Variables

### Workflows Summary

| Workflow | Trigger | Instance | Key Steps | Publishes To |
|----------|---------|----------|-----------|-------------|
| `test-workflow` | Push + PR to main | linux_x2 | Functions tests, Flutter analyze, Flutter test | None (coverage only) |
| `ios-workflow` | Push to main | mac_mini_m1 | Tests, Pod install, Build IPA (9 dart-defines) | TestFlight |
| `android-workflow` | Push to main | linux_x2 | Functions tests, Flutter tests, Build APK+AAB (9 dart-defines) | Play Store (internal, draft) |

### Complete Dart-Define Matrix

| Variable | Purpose | Status |
|----------|---------|--------|
| `ENVIRONMENT=production` | Hardcoded in yaml | OK |
| `SPORTSDATA_API_KEY` | Live scores (tournament only) | OK (empty until June) |
| `GOOGLE_PLACES_API_KEY` | Venue discovery | **Required -- build fails if missing** |
| `OPENAI_API_KEY` | AI features | **Required -- build fails if missing** |
| `CLAUDE_API_KEY` | AI features | **Required -- build fails if missing** |
| `STRIPE_PUBLISHABLE_KEY` | Payments | **Required -- build fails if missing** |
| `REVENUECAT_IOS_API_KEY` | iOS IAP | Warning only |
| `REVENUECAT_ANDROID_API_KEY` | Android IAP | Warning only; needs production `goog_` key |
| `FIREBASE_FUNCTIONS_URL` | Cloud Functions base URL | **Dead config -- declared but never consumed** |

### How Dart-Defines Map to Code

All dart-defines are consumed via `String.fromEnvironment()` in `lib/config/api_keys.dart`:

```dart
static const String googlePlaces = String.fromEnvironment(
  'GOOGLE_PLACES_API_KEY',
  defaultValue: '',
);
// ... similar pattern for all keys
```

### Variable Groups in Codemagic

| Group | Used By | Contains |
|-------|---------|----------|
| `apple_developer` | iOS workflow | `APP_STORE_CONNECT_KEY_IDENTIFIER`, `APP_STORE_CONNECT_ISSUER_ID`, `APP_STORE_CONNECT_PRIVATE_KEY` |
| `google_play` | Android workflow | `GCLOUD_SERVICE_ACCOUNT_CREDENTIALS` |
| *(missing)* | Both | All 7 API keys should be in an explicit group |

### Codemagic Explicit `vars:` Declarations

**iOS workflow:**
```yaml
vars:
  BUNDLE_ID: "com.christophercampbell.pregameworldcup"
  XCODE_WORKSPACE: "Runner.xcworkspace"
  XCODE_SCHEME: "Runner"
```

**Android workflow:**
```yaml
vars:
  PACKAGE_NAME: "com.christophercampbell.pregameworldcup"
```

### iOS Build Validation Script

The iOS workflow (lines 104-149) validates environment variables before building:
- `GOOGLE_PLACES_API_KEY` -- **FAILS build if missing**
- `OPENAI_API_KEY` -- **FAILS build if missing**
- `CLAUDE_API_KEY` -- **FAILS build if missing**
- `STRIPE_PUBLISHABLE_KEY` -- **FAILS build if missing**
- `REVENUECAT_IOS_API_KEY` -- Warning only
- `REVENUECAT_ANDROID_API_KEY` -- Warning only

### Cloud Functions Environment Variables

**In `functions/.env.pregame-b089e` (local-only, gitignored):**

| Variable | Purpose |
|----------|---------|
| `PLACES_API_KEY` | Google Places API for `getNearbyVenuesHttp`, `placePhotoProxy` |
| `STRIPE_SECRET_KEY` | Stripe secret key for `getStripeSecretKey()` |
| `TWILIO_ACCOUNT_SID` | Twilio SMS verification for venue claiming |
| `TWILIO_AUTH_TOKEN` | Twilio auth |
| `TWILIO_PHONE_NUMBER` | Twilio outbound number |

**Referenced in code but NOT in `.env.pregame-b089e` (must be in Firebase Functions config):**

| Variable | Purpose | Fallback |
|----------|---------|----------|
| `STRIPE_WEBHOOK_SECRET` | stripe-simple webhook | `functions.config().stripe.webhook_secret` |
| `STRIPE_WC_WEBHOOK_SECRET` | World Cup payments webhook | `functions.config().stripe.wc_webhook_secret` |
| `STRIPE_WP_WEBHOOK_SECRET` | Watch party payments webhook | `functions.config().stripe.wp_webhook_secret` |

### React Venue Portal Environment Variables

**In `.env.example`:**

| Variable | Purpose |
|----------|---------|
| `REACT_APP_FIREBASE_API_KEY` | Firebase Web API key |
| `REACT_APP_FIREBASE_AUTH_DOMAIN` | Firebase auth domain |
| `REACT_APP_FIREBASE_PROJECT_ID` | Firebase project ID |
| `REACT_APP_FIREBASE_STORAGE_BUCKET` | Firebase storage |
| `REACT_APP_FIREBASE_MESSAGING_SENDER_ID` | FCM sender ID |
| `REACT_APP_FIREBASE_APP_ID` | Firebase app ID |
| `REACT_APP_FIREBASE_MEASUREMENT_ID` | GA measurement ID |
| `REACT_APP_STRIPE_PUBLISHABLE_KEY` | Stripe publishable key |
| `REACT_APP_GOOGLE_PLACES_API_KEY` | Google Places API key |
| `REACT_APP_ENVIRONMENT` | Environment string |

**Missing from `.env.example`:** `REACT_APP_SPORTSDATA_API_KEY` (referenced in `environment.ts` but not in example file)

### Issues Found

| # | Issue | Fix |
|---|-------|-----|
| 1 | **API keys not in any Codemagic variable group** | The 7 API keys must be in the Codemagic vault at app-level since they aren't declared in any `groups:` section. Consider creating an `api_keys` group for clarity. |
| 2 | **`FIREBASE_FUNCTIONS_URL` is dead config** | `PlacesApiDataSource` hardcodes the URL instead of using `ApiKeys.cloudFunctionsBaseUrl`. Either fix the datasource or remove the dart-define. |
| 3 | **iOS workflow missing `flutter analyze`** | Test workflow runs it but iOS/Android build workflows don't. Analysis errors could slip into releases. |
| 4 | **Android workflow runs redundant Functions tests** | Already covered by test workflow. iOS workflow does NOT run them -- inconsistent. |
| 5 | **Webhook secrets missing from `.env.pregame-b089e`** | The 3 Stripe webhook secrets fall back to `functions.config()`. If neither is set, webhooks will fail silently. |
| 6 | **`REACT_APP_SPORTSDATA_API_KEY` missing from `.env.example`** | Referenced in `environment.ts` but not in the example file. |
| 7 | **`REVENUECAT_ANDROID_API_KEY` still test key** | Must be replaced with production `goog_` key once Google Play is set up. |
| 8 | **Test workflow has NO dart-defines** | Acceptable since `flutter test` uses defaults, but noted for completeness. |
| 9 | **No website/React portal CI workflow** | No Codemagic workflow for building or deploying the React venue portal. |

### Complete Environment Variable Matrix

| Variable | Required In | Codemagic Source | Status |
|----------|-------------|------------------|--------|
| `ENVIRONMENT` | Dart-define | Hardcoded `production` | OK |
| `SPORTSDATA_API_KEY` | Dart-define | Vault (app-level) | OK (empty until tournament) |
| `GOOGLE_PLACES_API_KEY` | Dart-define + iOS validation | Vault (app-level) | REQUIRED - build fails if missing |
| `OPENAI_API_KEY` | Dart-define + iOS validation | Vault (app-level) | REQUIRED - build fails if missing |
| `CLAUDE_API_KEY` | Dart-define + iOS validation | Vault (app-level) | REQUIRED - build fails if missing |
| `STRIPE_PUBLISHABLE_KEY` | Dart-define + iOS validation | Vault (app-level) | REQUIRED - build fails if missing |
| `REVENUECAT_IOS_API_KEY` | Dart-define | Vault (app-level) | WARNING only if missing |
| `REVENUECAT_ANDROID_API_KEY` | Dart-define | Vault (app-level) | WARNING only; currently test key |
| `FIREBASE_FUNCTIONS_URL` | Dart-define | Hardcoded in yaml | OK (but not actually consumed) |
| `BUILD_NUMBER` | Build versioning | Codemagic built-in | OK |
| `BUNDLE_ID` | iOS vars | Declared in yaml | OK |
| `XCODE_WORKSPACE` | iOS vars | Declared in yaml | OK |
| `XCODE_SCHEME` | iOS vars | Declared in yaml | OK |
| `PACKAGE_NAME` | Android vars | Declared in yaml | OK |
| `GCLOUD_SERVICE_ACCOUNT_CREDENTIALS` | Android publishing | `google_play` group | OK |
| `APP_STORE_CONNECT_KEY_IDENTIFIER` | iOS signing | `apple_developer` group | OK |
| `APP_STORE_CONNECT_ISSUER_ID` | iOS signing | `apple_developer` group | OK |
| `APP_STORE_CONNECT_PRIVATE_KEY` | iOS signing | `apple_developer` group | OK |

---

## 4. Google Play Store Submission

### Android Build Configuration Status

| Setting | Current Value | Play Store Requirement | Status |
|---------|--------------|----------------------|--------|
| `applicationId` | `com.christophercampbell.pregameworldcup` | Unique, can't change after publish | READY |
| `namespace` | `com.christophercampbell.pregameworldcup` | Must match applicationId | READY |
| `compileSdk` | 35 | Latest stable | READY |
| `targetSdk` | 35 | Must be 34+ for new apps | COMPLIANT |
| `minSdk` | 23 (Android 6.0) | No minimum enforced | READY |
| `versionCode` | From `local.properties` (default `1`) | Must increment each upload | OK (Codemagic uses `$BUILD_NUMBER`) |
| `multiDexEnabled` | `true` | Standard for large apps | READY |
| `isMinifyEnabled` | `true` (release) | Best practice | READY |
| `isShrinkResources` | `true` (release) | Best practice | READY |

### Blocking Issues

| # | Issue | Details |
|---|-------|---------|
| 1 | **Missing Google Maps API key in AndroidManifest.xml** | The `com.google.android.geo.API_KEY` meta-data entry is completely absent. Google Maps will crash or show gray. Must be added inside the `<application>` tag. |
| 2 | **`ACCESS_BACKGROUND_LOCATION` permission declared** | Triggers strict Google review requiring video proof + justification. The app appears to only need foreground location. **Remove this permission unless justified.** |
| 3 | **Google Play Console setup** | Need developer account ($25), identity verification (24-48 hrs), app listing creation. |
| 4 | **512x512 hi-res app icon** | Play Store requires a separate hi-res icon (PNG, no alpha). Not yet created. |
| 5 | **Feature graphic** | 1024x500 PNG/JPEG required for Play Store listing. Not created yet. |
| 6 | **Android phone screenshots** | Need 2-8 screenshots taken from Android device/emulator (not iOS). Current screenshots are from iOS/website. |
| 7 | **Content rating questionnaire** | Must complete in Play Console (user-generated content, social features, ads, IAP). |
| 8 | **Data Safety form** | Must manually enter in Play Console. Data types documented in `APP_STORE_PRIVACY_GUIDE.md` can be reused. |

### Android Manifest Permissions

| Permission | Justification Needed | Notes |
|-----------|---------------------|-------|
| `INTERNET` | No (standard) | Required for any network app |
| `ACCESS_NETWORK_STATE` | No (standard) | Connectivity checking |
| `ACCESS_FINE_LOCATION` | Yes | Watch party discovery, venue finder |
| `ACCESS_COARSE_LOCATION` | Yes | Watch party discovery, venue finder |
| `CAMERA` | Yes | Profile photos, chat media |
| `READ_EXTERNAL_STORAGE` | Yes | File picker for chat attachments |
| `WRITE_EXTERNAL_STORAGE` (max SDK 28) | No (legacy guard) | Correctly guarded with `maxSdkVersion=28` |
| `RECORD_AUDIO` | Yes | Voice messages in messaging |
| `VIBRATE` | No (standard) | Haptic feedback |
| `POST_NOTIFICATIONS` | Yes (Android 13+) | Push notifications (FCM) |
| `WAKE_LOCK` | No (standard) | Background task processing |
| `ACCESS_BACKGROUND_LOCATION` | **YES -- HIGH RISK** | **Will trigger Play Store review -- likely should be removed** |

### Signing Configuration

**Local signing:**
- Keystore: `android/upload-keystore.jks` (exists)
- `key.properties` contains plaintext password `Arlo0844!`

**CRITICAL SECURITY ISSUES:**
- `key.properties` contains plaintext keystore password in git history
- Both `storePassword` and `keyPassword` are identical
- Upload keystore may also be in git history

**CI signing:**
- Codemagic uses `keystore_reference` (uploaded to Codemagic, separate from local keystore)
- This is correctly configured

**Recommended Actions:**
- Rotate the keystore password (create new keystore, use Google Play App Signing to update upload key)
- Remove `key.properties` from git tracking (`git rm --cached`)
- Verify `upload-keystore.jks` is not tracked in git

### Firebase Configuration for Android

**`google-services.json`** contains 4 client entries:
1. `com.christophercampbell.pregame` (old iOS package name)
2. `com.christophercampbell.pregameworldcup` (current -- correct)
3. `com.example.pregame_app` (Flutter default)
4. `com.pregameapp.mobile` (another old name)

The correct entry is #2. Others are legacy clutter -- should be cleaned up.

- **Project ID**: `pregame-b089e`
- **Project Number**: `942034010384`

### RevenueCat / In-App Purchases -- Android Status

**Current State: NOT configured for production.**

When RevenueCat is not configured, the app falls back to Stripe browser checkout. This works functionally but:
- Provides worse UX than native IAP
- May violate Google Play billing policies for in-app digital content

**What's Missing:**
1. Add Android app in RevenueCat dashboard
2. Upload Google Play service account JSON to RevenueCat
3. Create 2 in-app products in Google Play Console:
   - `com.christophercampbell.pregameworldcup.fan_pass` -- $14.99
   - `com.christophercampbell.pregameworldcup.superfan_pass` -- $29.99
4. Import products into RevenueCat and link to entitlements
5. Get the production API key (`goog_...`) from RevenueCat
6. Set `REVENUECAT_ANDROID_API_KEY` in Codemagic vault with the real key

**Note:** Venue Premium ($499) stays on Stripe only (B2B, exempt from IAP rules).

### Store Listing Preparation

**Already prepared (in `PLAY_STORE_SUBMISSION.md`):**
- App name: Pregame World Cup 2026
- Short description (80 chars): "Your ultimate companion for World Cup 2026. Live scores, watch parties & more!"
- Full description (4000 chars): Detailed, covers features, premium upsell
- Category: App (not Game), Free with in-app purchases
- Default language: English (US)

**Graphics assets status:**

| Asset | Required Size | Status |
|-------|--------------|--------|
| App icon (Hi-res) | 512x512 PNG, no alpha | NEEDS CREATION |
| Feature graphic | 1024x500 PNG/JPEG | NOT CREATED |
| Phone screenshots | 320-3840px wide, 2-8 images | PARTIALLY READY (need Android-specific) |
| 7-inch tablet screenshots | Optional | NOT CREATED |
| 10-inch tablet screenshots | Optional | NOT CREATED |

**Intellectual Property Warning:** App name uses "World Cup" which may be trademarked. Position as "fan companion app" and don't imply official affiliation.

### Data Safety Section Mapping

| Data Type | Collected | Shared | Purpose |
|-----------|-----------|--------|---------|
| Email | Yes | No | Account authentication |
| Name | Yes | No | Profile display |
| Precise location | Yes | No | Watch party/venue discovery |
| Photos/Videos | Yes | No | Chat media, profile |
| Audio | Yes | No | Voice messages |
| User-generated content | Yes | No | Chat messages, predictions |
| User IDs | Yes | No | Firebase Auth |
| Device IDs | Yes | Yes (Analytics) | FCM, Analytics |
| Purchase history | Yes | No | Subscription management |
| App interactions | Yes | No | Analytics |
| Crash logs | Yes | Yes (Firebase) | Crashlytics |
| Ad data | Yes | Yes (AdMob) | Ad serving |

### Native Android Code

- **`MainActivity.kt`**: Standard FlutterActivity subclass
- **`WorldCupWidgetProvider.kt`**: Full native home screen widget (237 lines) showing live scores and upcoming matches
- Widget resources: layout XML, widget metadata, drawables, strings

### Missing: Adaptive Icon

No `ic_launcher_foreground.xml` / `ic_launcher_background.xml`. Without adaptive icons, the launcher icon may appear in a white square on Android 8.0+ devices. Should configure `adaptive_icon_foreground` and `adaptive_icon_background` in `pubspec.yaml` flutter_launcher_icons config.

### High Priority Items

| # | Task |
|---|------|
| 9 | **Rotate keystore password** -- `Arlo0844!` is in git history |
| 10 | **Add adaptive icon** for modern Android devices |
| 11 | **Set up RevenueCat Android** (or decide to launch with Stripe-only fallback) |
| 12 | **Create in-app products in Play Console** |
| 13 | **Configure Play Integrity** for Firebase App Check -- register app SHA-256 fingerprint |
| 14 | **Rotate service-account-key.json** in git history |
| 15 | **Set up `assetlinks.json`** for Android App Links verification |

### Medium Priority Items

- Clean up `google-services.json` -- remove 3 legacy client entries
- Test on multiple Android devices (Android 6, 10, 14/15)
- Create test account for Google Play reviewers
- Set up Play Store license testing (sandbox purchase emails)
- Verify JVM memory (-Xmx8G in `gradle.properties`) works on Codemagic linux_x2 instances
- Run `flutter analyze` with zero issues before submission
- Prepare release notes for initial release

### Codemagic Android Workflow Details

**Build steps:**
1. Set up `local.properties` with Flutter SDK path
2. Install Node.js 18 for Functions tests
3. Run Firebase Functions tests (npm ci + npm test)
4. Get Flutter packages
5. Run Flutter tests
6. Build APK (`flutter build apk --release` with 9 dart-defines)
7. Build AAB (`flutter build appbundle --release` with 9 dart-defines)

**Publishing:**
```yaml
publishing:
  google_play:
    credentials: $GCLOUD_SERVICE_ACCOUNT_CREDENTIALS
    track: internal
    submit_as_draft: true
```

**Artifacts collected:** APK, AAB, `mapping.txt` (for Crashlytics de-obfuscation)

### Existing Documentation

| Document | Path | Purpose |
|----------|------|---------|
| Android Launch Checklist | `docs/ANDROID_LAUNCH_CHECKLIST.md` | 6-step checklist (~72% done) |
| Play Store Submission Guide | `PLAY_STORE_SUBMISSION.md` | Full submission walkthrough |
| Payment Manual Setup | `docs/PAYMENT_MANUAL_SETUP_CHECKLIST.md` | 8-step payment config |
| Payment System Review | `docs/PAYMENT_SYSTEM_REVIEW.md` | 14 issues, 13 fixed |
| App Store Privacy Guide | `docs/APP_STORE_PRIVACY_GUIDE.md` | Data types (reusable for Play) |
| Privacy Policy | `docs/PRIVACY_POLICY.md` | Full privacy policy text |
| Launch Checklist | `LAUNCH_CHECKLIST.md` | Overall project launch checklist |

---

## 5. Overall Readiness Summary

| Area | Readiness | Key Blockers |
|------|-----------|-------------|
| **Apple App Store** | ~85% | screenshots, IAP products, App Store Connect listing |
| **Payment Systems** | ~85% | Android RevenueCat, price discrepancy, e2e testing |
| **Codemagic/ENV** | ~90% | Missing variable group, webhook secrets |
| **Google Play Store** | ~80% | store assets, Play Console setup, RevenueCat Android |

### Master Checklist

#### Apple App Store -- Code Fixes
- [x] Fix bundle ID in `lib/firebase_options.dart` (change to `com.christophercampbell.pregameworldcup`) -- DONE Feb 27
- [x] Fix bundle ID in `ios/Runner/Runner.entitlements` (keychain group) -- DONE Feb 27
- [ ] Re-download `ios/Runner/GoogleService-Info.plist` from Firebase Console for correct bundle ID
- [x] Add `NSUserTrackingUsageDescription` to `ios/Runner/Info.plist` -- DONE Feb 27
- [x] Add `ITSAppUsesNonExemptEncryption` to `ios/Runner/Info.plist` -- DONE Feb 27
- [x] Implement App Tracking Transparency prompt before loading AdMob ads -- DONE Feb 27 (app_tracking_transparency package + ATT request in _initializeAdMobBackground)
- [x] Add privacy policy and terms of service links in the app UI (profile screen) -- DONE Feb 27
- [ ] Update `Info.plist` URL schemes to match new `GoogleService-Info.plist`
- [x] Delete or update root-level `GoogleService-Info.plist` -- DELETED Feb 27
- [ ] Decide on WorldCupWidget -- either integrate into Xcode project or remove directory

#### Apple App Store -- App Store Connect
- [ ] Create app listing with bundle ID `com.christophercampbell.pregameworldcup`
- [ ] Enter App Store metadata (description, keywords, categories, age rating)
- [ ] Upload screenshots (6.7" and 6.5" at minimum)
- [ ] Enter privacy data declarations
- [ ] Set Privacy Policy URL
- [ ] Set Support URL
- [ ] Create IAP products (Fan Pass and Superfan Pass) with screenshots
- [ ] Configure Sandbox tester for IAP testing

#### Apple App Store -- External Services
- [ ] Verify Firebase Console has iOS app for `com.christophercampbell.pregameworldcup`
- [ ] Verify RevenueCat iOS app uses correct bundle ID
- [ ] Verify Codemagic vault has production `appl_` RevenueCat key
- [ ] Set up `apple-app-site-association` file on website (if using universal links)
- [ ] Run end-to-end payment tests

#### Google Play Store -- Code Fixes
- [x] Add Google Maps API key `<meta-data>` to AndroidManifest.xml -- DONE Feb 27 (via manifestPlaceholders in build.gradle.kts)
- [x] Remove `ACCESS_BACKGROUND_LOCATION` permission -- DONE Feb 27
- [x] Add adaptive icon configuration to pubspec.yaml -- DONE Feb 27 (foreground + #0F172A background, icons generated)
- [x] Clean up `google-services.json` (remove 3 legacy entries) -- DONE Feb 27

#### Google Play Store -- Play Console
- [ ] Create Google Play Console developer account ($25)
- [ ] Complete identity verification
- [ ] Create app listing (name, description, category, contact, privacy policy)
- [ ] Generate and upload 512x512 hi-res app icon
- [ ] Create and upload 1024x500 feature graphic
- [ ] Take and upload Android phone screenshots (2-8)
- [ ] Complete content rating questionnaire
- [ ] Complete Data Safety form
- [ ] Set target audience and content declaration
- [ ] Create in-app products (fan_pass, superfan_pass)
- [ ] Set up license testing emails

#### Google Play Store -- External Services
- [ ] Set up RevenueCat Android (or decide on Stripe-only)
- [ ] Configure Play Integrity for Firebase App Check
- [ ] Set up `assetlinks.json` for Android App Links

#### Payment Systems
- [x] Reconcile Venue Premium price -- confirmed $499 is correct, docs updated
- [x] Add idempotency to `handleWatchPartyWebhook` -- DONE Feb 27
- [ ] Run end-to-end payment tests (Stripe test mode)
- [ ] Configure Firestore TTL policies on `expiresAt` field
- [ ] Add 3 Stripe webhook secrets to `.env.pregame-b089e`

#### Security
- [ ] Rotate Android keystore password (in git history)
- [ ] Rotate service-account-key.json (in git history)
- [ ] Remove `key.properties` from git tracking

#### Codemagic
- [ ] Consider creating `api_keys` variable group for explicit dependency
- [x] Fix dead `FIREBASE_FUNCTIONS_URL` dart-define -- DONE Feb 27 (PlacesApiDataSource now uses ApiKeys.cloudFunctionsBaseUrl)
- [x] Add `flutter analyze` to iOS and Android build workflows -- DONE Feb 27
- [x] Add `REACT_APP_SPORTSDATA_API_KEY` to `.env.example` -- DONE Feb 27

**Estimated time to submission-ready**: 1-2 weeks of focused work for both stores simultaneously, with the bulk being manual Play Console/App Store Connect configuration and asset creation.

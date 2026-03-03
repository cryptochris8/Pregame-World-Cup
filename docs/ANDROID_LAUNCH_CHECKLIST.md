# Android Launch Checklist

## Current Status: ~72% Ready

The Android build infrastructure is fully configured (signing, CI/CD, Firebase, ProGuard, native widget). What remains is store listing, in-app purchases, and RevenueCat integration. Phases 4-6 improved overall codebase quality (DI modularization, retry utils, dead code removal, auth hardening with password reset + account deletion + global error handler).

---

## Already Done

- [x] Build config: `com.christophercampbell.pregameworldcup`, SDK 35, minSdk 23
- [x] Firebase: `google-services.json` configured for correct package
- [x] Signing: Keystore + upload key configured
- [x] Codemagic CI/CD: Full workflow (APK + AAB → Play Store internal track)
- [x] ProGuard: Rules for Flutter, Firebase, Stripe, RevenueCat, Maps, AdMob
- [x] Native widget: World Cup home screen widget with live scores
- [x] Manifest: All permissions, deep links, AdMob configured
- [x] All Flutter code: Shared with iOS, already works on Android
- [x] Dart defines: All API keys injected via Codemagic vault at build time
- [x] ProGuard keep rules updated (Phase 1 security hardening)
- [x] All Cloud Functions rate-limited and retry-wrapped (Phase 4)
- [x] Password reset flow (Phase 6)
- [x] GDPR account deletion (Phase 6)
- [x] Global error handler with Crashlytics (Phase 6)

---

## Step 1: Google Play Console Setup

- [ ] Create/finalize Play Store listing (app name, description, screenshots)
- [ ] Upload privacy policy URL
- [ ] Set content rating
- [ ] Configure target audience and content
- [ ] Create 2 in-app products under Monetize → In-app products:
  - `fan_pass` — Fan Pass — $14.99
  - `superfan_pass` — Superfan Pass — $29.99
- [ ] Add license testers (Settings → License testing) for sandbox purchases

---

## Step 2: RevenueCat Android Configuration

- [ ] Add Android app in RevenueCat (Apps & providers → + Add app config → Play Store)
  - App name: `Pregame World Cup Android`
  - Package name: `com.christophercampbell.pregameworldcup`
- [ ] Upload Google Play service account JSON for purchase verification
  - Create service account in Google Cloud Console
  - Grant "Pub/Sub Admin" and "Monitoring Viewer" roles
  - Download JSON key file
  - Upload to RevenueCat Android app settings
  - Grant service account access in Play Console → Users & Permissions
- [ ] Import the 2 Android products in RevenueCat and link to existing entitlements:
  - `fan_pass` → `fan_pass` entitlement
  - `superfan_pass` → `superfan_pass` entitlement
- [ ] Add Android products to existing `default` offering packages:
  - `fan_pass_onetime` → attach Android Fan Pass product
  - `superfan_pass_onetime` → attach Android Superfan Pass product
- [ ] Copy the Android public API key (`goog_...`) from RevenueCat API keys page

---

## Step 3: Code Update

- [ ] Replace test Android RevenueCat key in `lib/config/api_keys.dart`:
  - Current default: `test_MFlhygrdunfDNFjjvGIVMCMlnwe`
  - Replace with real `goog_...` key from RevenueCat
- [ ] Add `REVENUECAT_ANDROID_API_KEY` to Codemagic vault with the real key

---

## Step 4: Security Fixes (Before Launch)

- [ ] `service-account-key.json` is in `.gitignore` but still exists in git history — **key rotation required**
- [ ] `android/key.properties` has hardcoded passwords — use Codemagic vault only for production builds
- [ ] Verify no other secrets are committed to git
- Note: Firestore/Storage security rules already hardened in Phase 1 (~575 lines, default deny)

---

## Step 5: Testing

- [ ] Build and run on physical Android device
- [ ] Test Stripe payment flow (browser checkout fallback)
- [ ] Test RevenueCat native purchase flow (once configured)
- [ ] Test restore purchases
- [ ] Test push notifications (FCM)
- [ ] Test deep links
- [ ] Test home screen widget
- [ ] Test AdMob ads display
- [ ] Submit internal test build via Codemagic

---

## Step 6: Pre-Launch Verification

- [ ] Run full Flutter test suite (3,913 tests, ~28% coverage)
- [ ] Run full backend test suite (611 tests)
- [ ] Run `flutter analyze` — zero errors/warnings
- [ ] Verify Codemagic Android workflow produces clean AAB

---

## Notes

- Venue Premium ($499) stays on Stripe (B2B, exempt from IAP rules)
- If RevenueCat is not configured, the app gracefully falls back to Stripe browser checkout
- The Codemagic Android workflow automatically publishes to Play Store internal track on push to main
- All API keys are injected via `--dart-define` at build time, not hardcoded in the app

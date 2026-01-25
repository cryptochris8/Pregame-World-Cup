# Google Play Store Submission Guide

## Pre-Submission Checklist

### Phase 1: Code Preparation (COMPLETED)
- [x] Release signing configuration added to `build.gradle.kts`
- [x] `key.properties.example` created as template
- [x] `key.properties` added to `.gitignore`
- [x] Removed `usesCleartextTraffic="true"` (security)
- [x] Removed `REQUEST_INSTALL_PACKAGES` permission (will cause rejection)
- [x] Version set to 1.0.0+1 in `pubspec.yaml`

### Phase 2: Create Upload Keystore (YOU MUST DO THIS)

**IMPORTANT: Do this ONCE and keep the keystore file SAFE FOREVER. If you lose it, you cannot update your app!**

1. Open terminal and run:
```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalias upload -keyalg RSA -keysize 2048 -validity 10000
```

2. Answer the prompts:
   - Enter keystore password (SAVE THIS!)
   - Enter key password (can be same as keystore)
   - Enter your name, organization, city, state, country

3. Move the keystore file:
```bash
mv upload-keystore.jks android/
```

4. Create `android/key.properties` (copy from `key.properties.example`):
```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=../upload-keystore.jks
```

5. **BACKUP** the keystore and passwords somewhere secure (NOT in git!)

---

## Phase 3: Build Release APK/Bundle

### Build App Bundle (Recommended for Play Store)
```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### Build APK (for testing)
```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

---

## Phase 4: Google Play Console Setup

### 1. Create Developer Account
- Go to: https://play.google.com/console
- Pay $25 one-time registration fee
- Complete identity verification (can take 24-48 hours)

### 2. Create New App
1. Click "Create app"
2. Fill in:
   - App name: **Pregame World Cup 2026**
   - Default language: **English (US)**
   - App or game: **App**
   - Free or paid: **Free** (with in-app purchases)
3. Accept declarations

### 3. Complete Store Listing

#### Main Store Listing
- **App name**: Pregame World Cup 2026
- **Short description** (80 chars max):
  > Your ultimate companion for FIFA World Cup 2026. Live scores, watch parties & more!

- **Full description** (4000 chars max):
  ```
  Get ready for the biggest World Cup ever! Pregame World Cup 2026 is your all-in-one companion for the FIFA World Cup in USA, Canada, and Mexico.

  FEATURES:
  • Live Scores & Match Updates - Real-time scores and match events
  • Watch Parties - Host or join watch parties with fans near you
  • Match Predictions - Compete with friends on match outcomes
  • Team Profiles - Explore all 48 participating nations
  • Stadium Guide - Information on all 16 World Cup venues
  • Live Match Chat - Discuss matches with fans worldwide
  • Calendar Sync - Never miss a match with calendar integration
  • Multi-language - English, Spanish, Portuguese, French

  PREMIUM FEATURES (Superfan Pass):
  • Ad-free experience
  • Advanced statistics
  • Exclusive predictions leagues
  • Priority access to watch parties

  Whether you're watching from the stadium or your couch, Pregame World Cup 2026 keeps you connected to every moment of the tournament.

  Download now and join millions of fans celebrating the beautiful game!
  ```

#### Graphics Requirements
| Asset | Size | Format |
|-------|------|--------|
| App icon | 512 x 512 px | PNG (32-bit, no alpha) |
| Feature graphic | 1024 x 500 px | PNG or JPEG |
| Phone screenshots | Min 320px, Max 3840px | PNG or JPEG (2-8 images) |
| 7-inch tablet screenshots | 1024 x 500 px min | PNG or JPEG (optional) |
| 10-inch tablet screenshots | 1024 x 500 px min | PNG or JPEG (optional) |

### 4. Content Rating Questionnaire
1. Go to "App content" > "Content rating"
2. Start questionnaire
3. Answer questions about:
   - Violence: **No**
   - Sexual content: **No**
   - Language: **No** (profanity filter enabled)
   - Controlled substances: **No**
   - User interaction: **Yes** (chat features)
   - Shares location: **Yes** (for watch parties)
   - Contains ads: **Yes** (AdMob)
   - In-app purchases: **Yes** (Superfan Pass)

Expected rating: **Everyone** or **Everyone 10+**

### 5. Privacy Policy
- URL: `https://pregameworldcup.com/privacy` (or wherever you host it)
- Must include:
  - What data you collect
  - How you use data
  - Third-party services (Firebase, AdMob, Stripe)
  - Contact information

### 6. App Content Declarations

#### Data Safety Form
Fill out what data your app collects:

| Data Type | Collected | Shared | Purpose |
|-----------|-----------|--------|---------|
| Email | Yes | No | Account, Authentication |
| Name | Yes | No | Profile display |
| Location | Yes | No | Watch party discovery |
| Photos | Yes | No | Profile pictures |
| Crash logs | Yes | Yes (Firebase) | App improvement |
| Device ID | Yes | Yes (Analytics) | Analytics |
| Purchase history | Yes | No | Subscription management |

#### Ads Declaration
- App contains ads: **Yes**
- Ad networks: **Google AdMob**

#### Target Audience
- Primary: **18-35** (sports fans)
- Not directed at children

### 7. App Access (If needed)
If any features require login to review, provide:
- Test account email
- Test account password
- Instructions for reviewers

---

## Phase 5: Release Management

### 1. Create Production Release
1. Go to "Release" > "Production"
2. Click "Create new release"
3. Upload your `.aab` file
4. Add release notes:
   ```
   Initial release of Pregame World Cup 2026!

   • Live match scores and updates
   • Create and join watch parties
   • Make predictions and compete with friends
   • Explore all 48 World Cup teams
   • Chat with fans during matches
   ```

### 2. Staged Rollout (Recommended)
- Start with 10-20% of users
- Monitor crashes in Crashlytics
- Gradually increase to 100%

### 3. Review Time
- First submission: 3-7 days
- Updates: 1-3 days
- May request additional information

---

## Phase 6: Post-Launch

### Monitor Dashboard
- **Crash rate**: Should be < 1%
- **ANR rate**: Should be < 0.5%
- **User ratings**: Respond to reviews
- **Installation stats**: Track downloads

### Required Updates
- Update versionCode for EVERY release
- Keep targetSdk updated (currently 35)
- Address policy compliance issues promptly

---

## Common Rejection Reasons & Fixes

| Issue | Solution |
|-------|----------|
| Privacy policy missing | Add privacy policy URL |
| Misleading app name | Ensure name matches functionality |
| Broken functionality | Test all features before submission |
| Intellectual property | Don't use FIFA trademarks in listing |
| Deceptive ads | Ads must be clearly identifiable |
| Excessive permissions | Only request needed permissions |
| Data safety form incorrect | Be accurate about data collection |

---

## Quick Commands Reference

```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Build release bundle
flutter build appbundle --release

# Build release APK
flutter build apk --release

# Analyze code
flutter analyze

# Run tests
flutter test

# Check version
flutter --version
```

---

## Contact & Support

For app review issues:
- Google Play Console Help: https://support.google.com/googleplay/android-developer
- Policy Center: https://play.google.com/about/developer-content-policy/

---

## Version History

| Version | Code | Date | Notes |
|---------|------|------|-------|
| 1.0.0 | 1 | TBD | Initial release |

Remember to increment `versionCode` (the +X in pubspec.yaml) for every update!

# TestFlight Deployment Guide

Complete guide for deploying Pregame World Cup to TestFlight using Codemagic.

---

## Version Requirements

| Component | Required Version | Current Status |
|-----------|------------------|----------------|
| Flutter | >=3.29.0 stable | Codemagic uses `stable` |
| Dart | >=3.7.0 <4.0.0 | Included with Flutter |
| iOS Deployment Target | 14.0 | Configured in Podfile + Info.plist |
| Node.js (Functions) | 18+ | Configured in codemagic.yaml |
| Xcode | Latest | Codemagic uses `latest` |
| CocoaPods | Default | Codemagic uses `default` |

---

## Apple Developer Setup Checklist

Before running TestFlight, verify these items in [Apple Developer Portal](https://developer.apple.com/account).

### 1. App ID Registration

1. Go to **Certificates, Identifiers & Profiles** > **Identifiers**
2. Verify `com.christophercampbell.pregame` exists
3. Ensure these capabilities are enabled:
   - Push Notifications
   - Sign in with Apple (if used)
   - App Groups (if needed)

### 2. App Store Connect App

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Navigate to **My Apps**
3. Verify "Pregame World Cup" exists

**If the app doesn't exist, create it:**
1. Click **+** > **New App**
2. Fill in the details:
   - **Platform:** iOS
   - **Name:** Pregame World Cup
   - **Primary Language:** English (U.S.)
   - **Bundle ID:** `com.christophercampbell.pregame`
   - **SKU:** `pregame-worldcup-2026`
3. Click **Create**

### 3. TestFlight Setup

1. In App Store Connect, go to your app
2. Click **TestFlight** tab
3. Create an **Internal Testing Group** (if not exists):
   - Click **+** next to "Internal Testing"
   - Name: "Internal Testers"
   - Add yourself and any team members as testers

---

## Codemagic Setup

### Required Environment Variables

Your Codemagic `apple_developer` variable group should contain:

| Variable | Description | Where to Find |
|----------|-------------|---------------|
| `APP_STORE_CONNECT_KEY_IDENTIFIER` | API Key ID | App Store Connect > Keys |
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID | App Store Connect > Keys |
| `APP_STORE_CONNECT_PRIVATE_KEY` | Contents of .p8 file | Downloaded when creating key |

### Required API Keys (in variable groups)

| Variable | Purpose |
|----------|---------|
| `GOOGLE_PLACES_API_KEY` | Google Places API |
| `OPENAI_API_KEY` | OpenAI API for predictions |
| `CLAUDE_API_KEY` | Claude API for predictions |
| `STRIPE_PUBLISHABLE_KEY` | Stripe payments |
| `SPORTSDATA_API_KEY` | Sports data API |

---

## Step-by-Step Deployment Instructions

### Step 1: Grant Variable Group Access

The build requires access to your team's `apple_developer` variable group.

1. Go to [Codemagic Dashboard](https://codemagic.io)
2. Click your **Team** name (top-left dropdown)
3. Go to **Team Settings** > **Variable groups**
4. Find the `apple_developer` group
5. Click **Edit** (pencil icon)
6. Under **Applications**, check the box for **Pregame World Cup**
7. Click **Save changes**

### Step 2: Verify App Store Connect API Key

If you don't have an API key set up:

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Navigate to **Users and Access** > **Integrations** > **App Store Connect API**
3. Click **Keys** tab
4. Click **+** to generate a new key:
   - **Name:** `Codemagic`
   - **Access:** `App Manager`
5. Click **Generate**
6. **Important:** Download the .p8 file immediately (only available once!)
7. Copy the **Key ID** and **Issuer ID** shown on the page
8. Add these to your Codemagic `apple_developer` variable group

### Step 3: Verify Codemagic Integration

1. Go to your app in Codemagic
2. Click **Settings** (gear icon)
3. Go to **Integrations** tab
4. Under **App Store Connect**, verify it shows connected
5. If not connected:
   - Click **Connect**
   - Select your App Store Connect API key
   - Click **Save**

### Step 4: Trigger the iOS Build

1. In Codemagic dashboard, go to your app
2. Click **Start new build** button
3. Configure the build:
   - **Branch:** `main`
   - **Workflow:** `iOS TestFlight Build`
4. Click **Start new build**

### Step 5: Monitor the Build

The build process will:

1. Check environment variables
2. Set up local.properties
3. Get Flutter packages
4. Run Flutter tests
5. Clean build directory
6. Install CocoaPods dependencies
7. Set up code signing (automatic)
8. Build the IPA
9. Upload to TestFlight

**Expected build time:** 15-25 minutes

### Step 6: After Successful Build

1. Check your email for TestFlight notification from Apple
2. Wait for Apple's processing (usually 10-30 minutes)
3. Open **TestFlight** app on your iPhone
4. Accept the test invitation if prompted
5. Install and test the app

---

## Troubleshooting

### Common Errors and Solutions

| Error | Cause | Solution |
|-------|-------|----------|
| "Application does not have access to variable group(s)" | App not granted access to variable group | Follow Step 1 to grant access |
| "No signing certificate found" | Missing code signing | Automatic signing handles this - check API key setup |
| "Bundle ID mismatch" | Wrong bundle ID | Verify `com.christophercampbell.pregame` in App Store Connect |
| "Missing provisioning profile" | Signing issue | Automatic signing should handle this |
| "Pod install failed" | CocoaPods issue | Podfile is configured - try cleaning build |
| "API key not found" | Missing environment variable | Check variable group has all required keys |

### Build Logs

If a build fails:
1. Click on the failed build in Codemagic
2. Expand each step to see detailed logs
3. Look for red error messages
4. Check the specific step that failed

### Clean Build

If you're having persistent issues:
1. In Codemagic, go to your app settings
2. Check "Clean build" option before starting
3. This removes cached data and starts fresh

---

## Workflow Configuration

The iOS workflow is configured in `codemagic.yaml`:

```yaml
ios-workflow:
  name: iOS TestFlight Build
  max_build_duration: 120
  instance_type: mac_mini_m1
  triggering:
    events:
      - push
    branch_patterns:
      - pattern: 'main'
        include: true
        source: true
  integrations:
    app_store_connect: Pregame
  environment:
    ios_signing:
      distribution_type: app_store
      bundle_identifier: com.christophercampbell.pregame
    groups:
      - apple_developer
    flutter: stable
    cocoapods: default
    xcode: latest
```

---

## After TestFlight Success

Once your app is successfully on TestFlight:

1. **Internal Testing:** Test all features thoroughly
2. **External Testing:** Add external testers (requires App Review)
3. **Prepare for Production:**
   - Complete App Store listing (screenshots, description)
   - Set up App Privacy information
   - Submit for App Review

---

## Useful Links

- [Codemagic Dashboard](https://codemagic.io)
- [Apple Developer Portal](https://developer.apple.com/account)
- [App Store Connect](https://appstoreconnect.apple.com)
- [TestFlight Documentation](https://developer.apple.com/testflight/)
- [Codemagic iOS Code Signing Docs](https://docs.codemagic.io/yaml-code-signing/signing-ios/)

---

## Contact

For app support: support@pregameworldcup.com

# Payment System - Manual Setup Checklist

> These 8 items require manual action in external dashboards (Stripe, RevenueCat, Codemagic, App Store Connect, Google Play Console, Firebase). They cannot be completed through code changes alone.

**Project**: Pregame World Cup 2026
**Firebase Project ID**: `pregame-b089e`
**Functions Region**: `us-central1`

---

## 1. Verify Stripe Keys Are Set in Firebase Functions Config

The Stripe secret key and three webhook secrets must be configured in Firebase Functions config for the backend to process payments.

### Steps

1. Open a terminal and authenticate with Firebase:
   ```bash
   firebase login
   firebase use pregame-b089e
   ```

2. Check what's currently configured:
   ```bash
   firebase functions:config:get
   ```

3. Look for these four keys under the `stripe` namespace:
   ```
   stripe.secret_key         -> Your Stripe secret key (sk_live_...)
   stripe.webhook_secret     -> Signing secret for handleStripeWebhook
   stripe.wc_webhook_secret  -> Signing secret for handleWorldCupPaymentWebhook
   stripe.wp_webhook_secret  -> Signing secret for handleWatchPartyWebhook
   ```

4. If any are missing, set them:
   ```bash
   firebase functions:config:set \
     stripe.secret_key="sk_live_YOUR_KEY_HERE" \
     stripe.webhook_secret="whsec_YOUR_SECRET_1" \
     stripe.wc_webhook_secret="whsec_YOUR_SECRET_2" \
     stripe.wp_webhook_secret="whsec_YOUR_SECRET_3"
   ```
   > Note: The webhook secrets (`whsec_...`) are generated in Step 2 when you create the webhook endpoints in the Stripe Dashboard. Complete Step 2 first, then come back here with the secrets.

5. After setting config values, redeploy functions:
   ```bash
   cd functions
   npm run build
   firebase deploy --only functions
   ```

### How to find your Stripe secret key
- Go to [Stripe Dashboard](https://dashboard.stripe.com) > Developers > API keys
- Copy the **Secret key** (starts with `sk_live_` for production or `sk_test_` for testing)

---

## 2. Register 3 Webhook URLs in Stripe Dashboard

Stripe needs to know where to send payment event notifications. The app uses three separate webhook endpoints, each handling different payment flows.

### Steps

1. Go to [Stripe Dashboard](https://dashboard.stripe.com) > Developers > Webhooks

2. **Create Webhook Endpoint #1** (Legacy subscriptions):
   - Click **Add endpoint**
   - **Endpoint URL**: `https://us-central1-pregame-b089e.cloudfunctions.net/handleStripeWebhook`
   - **Events to listen to** (select these):
     - `checkout.session.completed`
     - `customer.subscription.created`
     - `customer.subscription.updated`
     - `customer.subscription.deleted`
     - `invoice.payment_succeeded`
     - `invoice.payment_failed`
   - Click **Add endpoint**
   - Copy the **Signing secret** (starts with `whsec_`) - this is your `stripe.webhook_secret`

3. **Create Webhook Endpoint #2** (Fan Pass & Venue Premium):
   - Click **Add endpoint**
   - **Endpoint URL**: `https://us-central1-pregame-b089e.cloudfunctions.net/handleWorldCupPaymentWebhook`
   - **Events to listen to**:
     - `checkout.session.completed`
     - `payment_intent.succeeded`
     - `payment_intent.payment_failed`
   - Click **Add endpoint**
   - Copy the **Signing secret** - this is your `stripe.wc_webhook_secret`

4. **Create Webhook Endpoint #3** (Watch Party Virtual Attendance):
   - Click **Add endpoint**
   - **Endpoint URL**: `https://us-central1-pregame-b089e.cloudfunctions.net/handleWatchPartyWebhook`
   - **Events to listen to**:
     - `payment_intent.succeeded`
     - `payment_intent.payment_failed`
     - `charge.refunded`
   - Click **Add endpoint**
   - Copy the **Signing secret** - this is your `stripe.wp_webhook_secret`

5. Now go back to **Step 1** and set all three webhook secrets in Firebase Functions config.

6. **Add allowed redirect domains** in Stripe Dashboard > Settings > Checkout:
   - `pregame-b089e.web.app`
   - `pregameworldcup.com`

---

## 3. Verify Stripe Price IDs Match Real Products

The app has three hardcoded Stripe Price IDs. These must correspond to real products in your Stripe account with the correct amounts.

### Steps

1. Go to [Stripe Dashboard](https://dashboard.stripe.com) > Products

2. Verify these three products exist (or create them):

   | Product | Type | Amount | Expected Price ID |
   |---------|------|--------|-------------------|
   | Fan Pass | One-time payment | $14.99 | `price_1SnYT9LmA106gMF6SK1oDaWE` |
   | Superfan Pass | One-time payment | $29.99 | `price_1SnYi4LmA106gMF6h5yRgzLL` |
   | Venue Premium | One-time payment | $99.00 | `price_1SnYm5LmA106gMF63sYAuEB5` |

3. Click each product and check:
   - The **Price ID** matches the value in the table above
   - The **Amount** is correct
   - The price is set to **One-time** (not recurring)
   - The price is in **USD**
   - The product is in **Live mode** (not test mode)

4. If the Price IDs don't match (e.g., you recreated the products), you have two options:
   - **Option A** (preferred): Set the correct IDs via environment variables:
     ```bash
     firebase functions:config:set \
       stripe.fan_pass_price_id="price_YOUR_ACTUAL_ID" \
       stripe.superfan_pass_price_id="price_YOUR_ACTUAL_ID" \
       stripe.venue_premium_price_id="price_YOUR_ACTUAL_ID"
     ```
     > Note: The code currently reads these from `process.env`, not `functions.config()`. If using Firebase config, you'll need to update the code to also check `functions.config().stripe.fan_pass_price_id`.
   - **Option B**: Update the fallback values directly in `functions/src/world-cup-payments.ts` (lines 54-58)

---

## 4. Replace Android RevenueCat Test Key

The Android RevenueCat API key is currently a test key (`test_MFlhygrdunfDNFjjvGIVMCMlnwe`). The app's `isConfigured` check will return `false` on Android, meaning RevenueCat native purchases won't work. The app will fall back to Stripe browser checkout on Android.

### Steps

1. Go to [RevenueCat Dashboard](https://app.revenuecat.com)

2. Select your project (or create one for Pregame World Cup)

3. Go to **Project Settings** > **API Keys**

4. Find or create the **Google Play** API key:
   - It should start with `goog_` (production) not `test_`
   - If you only see a test key, you need to connect your Google Play Console first (see Step 6)

5. Copy the production Google Play API key

6. Update in one of two ways:

   **Option A** (via Codemagic - preferred): Add to Codemagic vault and build commands (see Step 7)

   **Option B** (update default value): Edit `lib/config/api_keys.dart`:
   ```dart
   static const String revenueCatAndroid = String.fromEnvironment(
     'REVENUECAT_ANDROID_API_KEY',
     defaultValue: 'goog_YOUR_PRODUCTION_KEY_HERE',
   );
   ```

---

## 5. Create RevenueCat Products in App Store Connect & Google Play Console

RevenueCat acts as a wrapper around the native app stores. The actual in-app purchase products must be created in both stores, and then linked in the RevenueCat dashboard.

### App Store Connect (iOS)

1. Go to [App Store Connect](https://appstoreconnect.apple.com) > Your App > In-App Purchases

2. Create two **Non-Consumable** in-app purchases:

   | Reference Name | Product ID | Price |
   |----------------|-----------|-------|
   | Fan Pass | `com.christophercampbell.pregameworldcup.fan_pass` | $14.99 |
   | Superfan Pass | `com.christophercampbell.pregameworldcup.superfan_pass` | $29.99 |

3. For each product:
   - Set the **Display Name** (e.g., "World Cup 2026 Fan Pass")
   - Set the **Description** (e.g., "Ad-free experience, advanced stats, custom alerts, social features")
   - Upload a **Screenshot** (required for review)
   - Set **Pricing** to the correct tier
   - Submit for review (can be done alongside an app update)

### Google Play Console (Android)

1. Go to [Google Play Console](https://play.google.com/console) > Your App > Monetize > Products > In-app products

2. Create two **One-time products**:

   | Product ID | Name | Price |
   |-----------|------|-------|
   | `com.christophercampbell.pregameworldcup.fan_pass` | Fan Pass | $14.99 |
   | `com.christophercampbell.pregameworldcup.superfan_pass` | Superfan Pass | $29.99 |

3. For each product:
   - Set **Name** and **Description**
   - Set **Default price** to the correct amount
   - Set status to **Active**

### RevenueCat Dashboard

1. Go to [RevenueCat Dashboard](https://app.revenuecat.com) > Your Project

2. **Connect stores** (if not already done):
   - App Store Connect: Add your iOS app with the bundle ID `com.christophercampbell.pregame`
   - Google Play Console: Add your Android app with the package name `com.christophercampbell.pregameworldcup`
   - Upload the required credentials (App Store Connect shared secret, Google Play service account JSON)

3. **Create Entitlements**:
   - `fan_pass` - grants access to Fan Pass features
   - `superfan_pass` - grants access to Superfan Pass features (should also include fan_pass features)

4. **Create Products** and link to store products:
   - Link `com.christophercampbell.pregameworldcup.fan_pass` from both stores
   - Link `com.christophercampbell.pregameworldcup.superfan_pass` from both stores

5. **Create Offerings**:
   - Create an offering (e.g., "default")
   - Add two packages:
     - Package identifier: `fan_pass_onetime` -> linked to the Fan Pass product
     - Package identifier: `superfan_pass_onetime` -> linked to the Superfan Pass product

6. **Attach entitlements to products**:
   - Fan Pass product -> grants `fan_pass` entitlement
   - Superfan Pass product -> grants both `fan_pass` and `superfan_pass` entitlements

---

## 6. Add STRIPE_PUBLISHABLE_KEY to Codemagic Vault

The Stripe publishable key is already passed via `--dart-define` in the build commands, but the actual value must be stored in Codemagic's encrypted vault.

### Steps

1. Find your Stripe publishable key:
   - Go to [Stripe Dashboard](https://dashboard.stripe.com) > Developers > API keys
   - Copy the **Publishable key** (starts with `pk_live_` for production or `pk_test_` for testing)

2. Go to [Codemagic Dashboard](https://codemagic.io) > Your App > Settings > Environment variables

3. Check if `STRIPE_PUBLISHABLE_KEY` already exists:
   - If it exists, verify the value is a live key (`pk_live_...`) not a test key (`pk_test_...`)
   - If it doesn't exist, create it:
     - **Variable name**: `STRIPE_PUBLISHABLE_KEY`
     - **Variable value**: `pk_live_YOUR_KEY_HERE`
     - **Group**: Add to your existing variable group (or create `stripe_keys`)
     - **Secure**: Yes (encrypted)

4. Ensure the variable group is referenced in your workflow. In `codemagic.yaml`, the workflows should have:
   ```yaml
   environment:
     groups:
       - your_variable_group_name
   ```

---

## 7. Add RevenueCat Keys to Codemagic Build Commands

The RevenueCat API keys are NOT currently passed via `--dart-define` in the Codemagic build commands. Without this, builds use the hardcoded defaults (iOS works because the default is a real key, but Android defaults to a test key).

### Steps

1. **Add environment variables to Codemagic vault**:
   - Go to [Codemagic Dashboard](https://codemagic.io) > Your App > Settings > Environment variables
   - Add `REVENUECAT_IOS_API_KEY` with value `appl_ossGwqwpDoJlTmVSVZEHoZTFMHY` (or your current production key)
   - Add `REVENUECAT_ANDROID_API_KEY` with value `goog_YOUR_PRODUCTION_KEY` (from Step 4)
   - Mark both as **Secure**

2. **Update `codemagic.yaml`** to pass the keys in build commands. Add these two lines to ALL build commands (iOS `flutter build ipa`, Android `flutter build apk`, and Android `flutter build appbundle`):

   ```yaml
   --dart-define=REVENUECAT_IOS_API_KEY=$REVENUECAT_IOS_API_KEY \
   --dart-define=REVENUECAT_ANDROID_API_KEY=$REVENUECAT_ANDROID_API_KEY \
   ```

   For example, the iOS build command should become:
   ```bash
   flutter build ipa --release \
     --build-name=1.0.$BUILD_NUMBER \
     --build-number=$BUILD_NUMBER \
     --dart-define=ENVIRONMENT=production \
     --dart-define=SPORTSDATA_API_KEY=$SPORTSDATA_API_KEY \
     --dart-define=GOOGLE_PLACES_API_KEY=$GOOGLE_PLACES_API_KEY \
     --dart-define=OPENAI_API_KEY=$OPENAI_API_KEY \
     --dart-define=CLAUDE_API_KEY=$CLAUDE_API_KEY \
     --dart-define=STRIPE_PUBLISHABLE_KEY=$STRIPE_PUBLISHABLE_KEY \
     --dart-define=REVENUECAT_IOS_API_KEY=$REVENUECAT_IOS_API_KEY \
     --dart-define=REVENUECAT_ANDROID_API_KEY=$REVENUECAT_ANDROID_API_KEY \
     --dart-define=FIREBASE_FUNCTIONS_URL=https://us-central1-pregame-b089e.cloudfunctions.net \
     --export-options-plist=$HOME/export_options.plist
   ```

3. Commit and push the `codemagic.yaml` changes.

---

## 8. Test End-to-End with Stripe Test Mode

Before switching to live keys, test the complete payment flow using Stripe's test mode.

### Prerequisites
- All webhook URLs registered (Step 2)
- All webhook secrets configured (Step 1)
- Stripe test keys set (use `sk_test_...` and `pk_test_...` instead of live keys)
- App built with test publishable key
- [Stripe CLI](https://stripe.com/docs/stripe-cli) installed

### Test Fan Pass Purchase

1. Open the app and navigate to the Fan Pass screen
2. Tap **Purchase Fan Pass** ($14.99)
3. Complete checkout using Stripe test card: `4242 4242 4242 4242`, any future expiry, any CVC
4. Verify:
   - [ ] Checkout page loads correctly in browser
   - [ ] After payment, app shows success message
   - [ ] Fan Pass status updates to "active" in the app
   - [ ] Firestore `world_cup_fan_passes/{userId}` document has `status: 'active'`
   - [ ] Firestore `processed_webhook_events` has the webhook event ID
   - [ ] Stripe Dashboard shows the payment as successful

### Test Superfan Pass Upgrade

1. With an active Fan Pass, navigate to Fan Pass screen
2. Tap **Upgrade to Superfan Pass** ($29.99)
3. Complete checkout
4. Verify:
   - [ ] Upgrade succeeds (not blocked by dual billing prevention)
   - [ ] Pass type updates to `superfan_pass`
   - [ ] All Superfan features are unlocked

### Test Venue Premium Purchase

1. Navigate to a venue you own
2. Tap **Upgrade to Premium** ($99.00)
3. Complete checkout
4. Verify:
   - [ ] Checkout loads correctly
   - [ ] Venue enhancement document updates to `subscriptionTier: 'premium'`
   - [ ] Premium venue features are unlocked

### Test Watch Party Virtual Attendance

1. Find a watch party with virtual attendance enabled
2. Tap **Join Virtually**
3. Complete payment
4. Verify:
   - [ ] Payment sheet appears in-app (not browser redirect)
   - [ ] After payment, user is added as virtual member
   - [ ] `watch_party_virtual_payments` document created
   - [ ] Member document has `hasPaid: true`

### Test Webhook Delivery (via Stripe CLI)

1. Install and login to Stripe CLI:
   ```bash
   stripe login
   ```

2. Forward events to your local or deployed functions:
   ```bash
   # For local testing with Firebase emulator:
   stripe listen --forward-to http://localhost:5001/pregame-b089e/us-central1/handleWorldCupPaymentWebhook

   # For testing deployed functions directly:
   stripe trigger checkout.session.completed
   stripe trigger payment_intent.succeeded
   stripe trigger payment_intent.payment_failed
   stripe trigger charge.refunded
   ```

3. Verify each event is received and processed (check Firebase Functions logs):
   ```bash
   firebase functions:log --only handleWorldCupPaymentWebhook
   firebase functions:log --only handleWatchPartyWebhook
   firebase functions:log --only handleStripeWebhook
   ```

### Test RevenueCat (iOS Sandbox)

1. On an iOS device/simulator with a sandbox Apple ID:
   - Attempt to purchase Fan Pass via native IAP
   - Verify entitlement is granted in RevenueCat dashboard
   - Test **Restore Purchases** flow

### Test RevenueCat (Android)

1. Requires the production `goog_` API key (Step 4) and products created in Play Console (Step 5)
2. Use a Google Play test track with license testers configured
3. Attempt to purchase Fan Pass via native IAP

### Test Duplicate Prevention

1. Purchase a Fan Pass via Stripe
2. Attempt to purchase again - should be blocked with "You already have an active Fan Pass"
3. Attempt to upgrade to Superfan - should be allowed

### Go Live Checklist

After all tests pass with test keys:
- [ ] Switch `stripe.secret_key` to live key (`sk_live_...`)
- [ ] Switch `STRIPE_PUBLISHABLE_KEY` in Codemagic to live key (`pk_live_...`)
- [ ] Create new webhook endpoints pointing to the same URLs but in **Live mode**
- [ ] Update the three webhook secrets with the new live-mode signing secrets
- [ ] Redeploy functions: `firebase deploy --only functions`
- [ ] Trigger a new Codemagic build with production keys
- [ ] Verify one real purchase works end-to-end

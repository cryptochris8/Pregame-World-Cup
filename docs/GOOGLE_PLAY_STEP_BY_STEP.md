# Google Play Store Submission - Step by Step

This is the full walkthrough. Do each step in order. Check the box when done.

---

## PHASE 1: Developer Account (One-Time Setup)

If you already have a Google Play Developer account, skip to Phase 2.

- [ ] **Step 1:** Go to https://play.google.com/console
- [ ] **Step 2:** Sign in with your Google account
- [ ] **Step 3:** Click **"Get Started"** or **"Create account"**
- [ ] **Step 4:** Choose **"Developer"** (not Organization, unless you have an LLC)
- [ ] **Step 5:** Pay the **$25 one-time fee** (compared to Apple's $99/year)
- [ ] **Step 6:** Complete **identity verification** — Google will ask for:
  - Legal name
  - Address
  - Phone number (they may call/text to verify)
  - Photo ID (driver's license or passport)
- [ ] **Step 7:** Wait for verification — usually **24-48 hours**, sometimes same day

> **You cannot proceed until your account is verified.** Google will email you when it's done.

---

## PHASE 2: Build Your Release App Bundle

You need to create a signed `.aab` file to upload to Google Play.

### 2A: Create Your Upload Keystore (One-Time, CRITICAL)

> **WARNING: If you lose this keystore, you can NEVER update your app. Back it up!**

Check your Android checklist — this may already be done. If `android/upload-keystore.jks` exists, skip to 2B.

- [ ] **Step 1:** Open a terminal and run:
```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalias upload -keyalg RSA -keysize 2048 -validity 10000
```
- [ ] **Step 2:** Answer the prompts:
  - Keystore password → **write this down somewhere safe**
  - First and last name → your name
  - Organizational unit → can leave blank, press Enter
  - Organization → can leave blank, press Enter
  - City → your city
  - State → your state
  - Country code → US
  - Confirm with `yes`
- [ ] **Step 3:** Move the keystore into your android folder:
```bash
mv upload-keystore.jks android/
```
- [ ] **Step 4:** Create `android/key.properties` (if it doesn't exist):
```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=../upload-keystore.jks
```
- [ ] **Step 5:** Back up both `upload-keystore.jks` and `key.properties` somewhere safe (Google Drive, USB drive, etc.) — NOT in git

### 2B: Build the App Bundle

- [ ] **Step 1:** Open terminal in your project root (`C:\Users\chris\Pregame-World-Cup`)
- [ ] **Step 2:** Clean the project:
```bash
flutter clean
```
- [ ] **Step 3:** Get dependencies:
```bash
flutter pub get
```
- [ ] **Step 4:** Build the release app bundle:
```bash
flutter build appbundle --release
```
- [ ] **Step 5:** Wait for it to finish. Your file will be at:
```
build/app/outputs/bundle/release/app-release.aab
```
- [ ] **Step 6:** Verify the file exists and note its location — you'll upload this later

> If the build fails, run `flutter analyze` to check for errors first.

---

## PHASE 3: Create Your App in Google Play Console

- [ ] **Step 1:** Go to https://play.google.com/console
- [ ] **Step 2:** Click **"Create app"** (blue button, top right)
- [ ] **Step 3:** Fill in the form:
  - **App name:** `Pregame: World Cup 2026`
  - **Default language:** `English (United States) – en-US`
  - **App or game:** Select **App**
  - **Free or paid:** Select **Free**
- [ ] **Step 4:** Check all the declaration boxes:
  - "I acknowledge that my app is subject to Developer Program Policies"
  - "I acknowledge that my app is subject to US export laws"
- [ ] **Step 5:** Click **"Create app"**

You're now on your app's **Dashboard**. You'll see a checklist on the left sidebar with items to complete.

---

## PHASE 4: Complete the Dashboard Checklist

Google shows you a setup checklist. Here's every item, in the order they appear.

### 4A: App Access

This tells Google if reviewers need login credentials to test your app.

- [ ] **Step 1:** In the left sidebar, click **App content > App access**
- [ ] **Step 2:** Select **"All or some functionality is restricted"**
- [ ] **Step 3:** Click **"Add new instructions"**
- [ ] **Step 4:** Fill in:
  - **Name:** Test Account
  - **Email/username:** `reviewer@pregameworldcup.com`
  - **Password:** (create a test account password)
  - **Instructions:** `Sign in with the provided email and password. App requires Google Sign-In or email authentication. This test account has full access to all features including Fan Pass premium features.`
- [ ] **Step 5:** Click **Save**

> **Important:** Make sure this test account actually exists in your Firebase Auth and has been granted VIP/admin access before submission.

### 4B: Ads

- [ ] **Step 1:** Click **App content > Ads**
- [ ] **Step 2:** Select **"Yes, my app contains ads"**
- [ ] **Step 3:** Click **Save**

### 4C: Content Rating

- [ ] **Step 1:** Click **App content > Content rating**
- [ ] **Step 2:** Click **"Start questionnaire"**
- [ ] **Step 3:** Enter your email address
- [ ] **Step 4:** Select category: **"Utility, Productivity, Communication, or Other"**
- [ ] **Step 5:** Answer the questions:

| Question | Answer |
|----------|--------|
| Does the app contain violence? | **No** |
| Does the app contain sexual content? | **No** |
| Does the app involve controlled substances? | **No** |
| Does the app contain profanity? | **No** (you have a profanity filter) |
| Is there user interaction / sharing? | **Yes** |
| Does it share user location? | **Yes** |
| Does the app contain ads? | **Yes** |
| Does it involve real gambling? | **No** (predictions use virtual points only) |

- [ ] **Step 6:** Click **"Save"** then **"Next"**
- [ ] **Step 7:** Review your rating (should be **Everyone** or **Everyone 10+**)
- [ ] **Step 8:** Click **"Submit"**

### 4D: Target Audience

- [ ] **Step 1:** Click **App content > Target audience and content**
- [ ] **Step 2:** For target age group, select **"18 and over"** only
  - Do NOT select any age groups under 13 — this triggers stricter kids policies
- [ ] **Step 3:** Click **Next**
- [ ] **Step 4:** When asked "Is this app appealing to children?" select **No**
- [ ] **Step 5:** Click **Save**

### 4E: News Apps

- [ ] **Step 1:** Click **App content > News apps**
- [ ] **Step 2:** Select **"My app is not a news app"**
- [ ] **Step 3:** Click **Save**

### 4F: COVID-19 Apps

- [ ] **Step 1:** If this appears, select **"My app is not a COVID-19 app"**
- [ ] **Step 2:** Click **Save**

### 4G: Data Safety

This is Google's version of Apple's privacy labels. Be accurate — false info can get you rejected.

- [ ] **Step 1:** Click **App content > Data safety**
- [ ] **Step 2:** Click **"Start"**
- [ ] **Step 3:** First question — "Does your app collect or share any user data?"
  - Select **Yes**
- [ ] **Step 4:** "Does your app use encryption?"
  - Select **Yes** (Firebase uses HTTPS/TLS)
  - Select **"My app uses encryption that is exempt"** (standard HTTPS)

Now you'll go through each data type. Here's exactly what to select:

**Location:**
- [ ] Approximate location → **Collected**, Not shared, Required, Purpose: **App functionality**
- [ ] Precise location → **Collected**, Not shared, Not required (optional permission), Purpose: **App functionality**

**Personal info:**
- [ ] Name → **Collected**, Not shared, Required, Purpose: **App functionality, Account management**
- [ ] Email address → **Collected**, Not shared, Required, Purpose: **App functionality, Account management**

**Financial info:**
- [ ] Purchase history → **Collected**, Not shared, Required, Purpose: **App functionality**

**Photos and videos:**
- [ ] Photos → **Collected**, Not shared, Not required, Purpose: **App functionality** (profile pics, message attachments)

**Audio:**
- [ ] Voice or sound recordings → **Collected**, Not shared, Not required, Purpose: **App functionality** (voice messages)

**App activity:**
- [ ] App interactions → **Collected**, Not shared, Required, Purpose: **Analytics**

**App info and performance:**
- [ ] Crash logs → **Collected**, Shared (Firebase Crashlytics), Required, Purpose: **Analytics**

**Device or other IDs:**
- [ ] Device or other IDs → **Collected**, Shared (Firebase, AdMob), Required, Purpose: **Advertising, Analytics**

- [ ] **Step 5:** Review your data safety summary
- [ ] **Step 6:** Click **Submit**

### 4H: Government Apps

- [ ] **Step 1:** If this appears, select **"This is not a government app"**
- [ ] **Step 2:** Click **Save**

### 4I: Financial Features

- [ ] **Step 1:** If this appears, select **"My app does not provide financial features"**
- [ ] **Step 2:** Click **Save**

---

## PHASE 5: Store Listing (What Users See)

### 5A: Main Store Listing

- [ ] **Step 1:** In the left sidebar, click **Grow > Store listing > Main store listing**

**App Details:**
- [ ] **Step 2 — Short description** (max 80 characters):
```
Your ultimate companion for World Cup 2026. Predictions, chat & more!
```

- [ ] **Step 3 — Full description** (max 4000 characters):
```
Your ultimate companion for the 2026 World Cup in the USA, Mexico, and Canada.

Pregame brings everything a World Cup fan needs into one app -- live scores, AI-powered match predictions, watch party planning, real-time fan chat, venue discovery, and deep tournament coverage for all 48 teams across 104 matches.

COMPLETE MATCH COVERAGE
Follow every group stage, Round of 32, quarterfinal, semifinal, and final match with detailed previews and live score tracking. Browse the full schedule with smart filters by date, group, team, or stage. Set reminders so you never miss kickoff, and export matches directly to your calendar.

AI MATCH PREDICTIONS & ANALYSIS
Our local prediction engine uses a 10-factor weighted algorithm -- including Elo ratings, squad market values, recent form, head-to-head records, injury impact, and betting odds -- to deliver data-driven match predictions with projected scorelines.

WATCH PARTIES
Create or discover watch parties happening near you. Invite friends, choose a venue, and coordinate game-day plans. Browse public watch parties by match, location, or date.

VENUE DISCOVERY WITH MAP
Find nearby bars, restaurants, and fan zones showing World Cup matches on an interactive Google Map. View venue details including atmosphere ratings, capacity, TV setup info, game-day specials, and which matches they are broadcasting.

LIVE MATCH CHAT & FAN COMMUNITY
Join real-time match chat rooms with quick reactions for every goal, save, and foul. Connect with fans supporting the same team through the social activity feed, friend system, and direct messaging with voice messages, photo sharing, and file attachments.

ALL 48 TEAMS & SQUADS
Explore detailed profiles for every national team -- squad rosters, player stats, World Cup history, group standings, and confederation records. Compare players side by side with the Player Comparison tool.

COPA AI ASSISTANT
Meet Copa, your built-in World Cup sidekick. Ask Copa about any team, match schedule, player stats, group standings, or tournament history and get instant answers.

FAN PASS & PREMIUM FEATURES
Unlock an ad-free experience and premium features with Fan Pass.

BUILT FOR FANS WORLDWIDE
- Available in English, Spanish, French, and Portuguese
- Timezone-aware scheduling
- Offline-first architecture
- Push notifications for match reminders
- Share match details, predictions, and watch party invites with friends

Download free and start your Pregame today.
```

**Graphics (REQUIRED):**

- [ ] **Step 4 — App icon:** Upload a **512 x 512 px** PNG (no transparency, no rounded corners)
  - This should be your app icon on a solid background
  - Google will add rounding automatically

- [ ] **Step 5 — Feature graphic:** Upload a **1024 x 500 px** image (JPEG or PNG)
  - This is the banner at the top of your listing
  - Should show your app name/logo with World Cup branding
  - Think of it like a promotional banner
  - You can create one at https://www.canva.com (search "Google Play feature graphic" template)

- [ ] **Step 6 — Phone screenshots:** Upload **2 to 8 screenshots**
  - Minimum dimensions: **320px** on shortest side
  - Maximum dimensions: **3840px** on longest side
  - Aspect ratio must be **16:9 or 9:16**
  - **Unlike Apple, Google is much more flexible on exact sizes**
  - Good sizes: **1080 x 1920** or **1440 x 2560** (standard Android phone)
  - **Easiest method:** Use Android Studio emulator:
    1. Open Android Studio
    2. Run your app on a **Pixel 8 Pro** emulator
    3. Click the **camera icon** in the emulator toolbar to take screenshots
    4. Screenshots save to your Desktop
  - Alternative: Take screenshots on any Android phone — they'll likely work

**Recommended screenshot sequence:**
1. Home screen / match schedule
2. AI match prediction detail
3. Watch party discovery
4. Venue map with nearby locations
5. Live match chat
6. Copa AI assistant
7. Team detail / squad roster
8. Tournament bracket

- [ ] **Step 7:** Click **Save** at the bottom

---

## PHASE 6: Set Up Pricing & In-App Products

### 6A: Pricing

- [ ] **Step 1:** In the left sidebar, click **Monetize > App pricing**
- [ ] **Step 2:** Confirm the app is **Free**
- [ ] **Step 3:** Click **Save**

### 6B: Countries / Regions

- [ ] **Step 1:** Click **Reach > Countries / regions**
- [ ] **Step 2:** Click **"Add countries / regions"**
- [ ] **Step 3:** Select all countries (or at minimum: United States, Canada, Mexico, and all major markets)
- [ ] **Step 4:** Click **Add** then **Save**

### 6C: In-App Products

- [ ] **Step 1:** Click **Monetize > In-app products**
- [ ] **Step 2:** Click **"Create product"**
- [ ] **Step 3:** Create Fan Pass:
  - **Product ID:** `fan_pass`
  - **Name:** Fan Pass
  - **Description:** Ad-free experience with advanced stats, custom alerts, and social features
  - **Default price:** $14.99
  - **Status:** Active
- [ ] **Step 4:** Click **Save** then **Activate**
- [ ] **Step 5:** Click **"Create product"** again
- [ ] **Step 6:** Create Superfan Pass:
  - **Product ID:** `superfan_pass`
  - **Name:** Superfan Pass
  - **Description:** Everything in Fan Pass plus exclusive content, AI match insights, and downloadable content
  - **Default price:** $29.99
  - **Status:** Active
- [ ] **Step 7:** Click **Save** then **Activate**

### 6D: License Testing

- [ ] **Step 1:** Go to **Settings > License testing** (in the left sidebar under "Settings")
- [ ] **Step 2:** Add your email (`chris@pregameapp.io`) as a license tester
- [ ] **Step 3:** Add any other tester emails
- [ ] **Step 4:** Set license response to **"RESPOND_NORMALLY"**
- [ ] **Step 5:** Click **Save**

> License testers can make test purchases without being charged real money.

---

## PHASE 7: Privacy Policy

- [ ] **Step 1:** In the left sidebar, click **App content > Privacy policy**
- [ ] **Step 2:** Enter your privacy policy URL:
```
https://pregameworldcup.com/privacy
```
- [ ] **Step 3:** Click **Save**

> Make sure the URL is live and accessible before submitting. Google will check it.

---

## PHASE 8: Upload Your Build & Create a Release

### 8A: Set Up Google Play App Signing

- [ ] **Step 1:** In the left sidebar, click **Release > Setup > App signing**
- [ ] **Step 2:** Accept Google Play App Signing (recommended — Google manages your signing key and you use an upload key)
  - This is more secure and lets you reset your upload key if you ever lose it
- [ ] **Step 3:** Click **Save**

### 8B: Create Internal Testing Release (Recommended First)

Start with internal testing before going to production. This lets you verify everything works.

- [ ] **Step 1:** Click **Release > Testing > Internal testing**
- [ ] **Step 2:** Click **"Create new release"**
- [ ] **Step 3:** Under "App bundles", click **"Upload"**
- [ ] **Step 4:** Navigate to and select your `.aab` file:
```
C:\Users\chris\Pregame-World-Cup\build\app\outputs\bundle\release\app-release.aab
```
- [ ] **Step 5:** Wait for upload and processing (1-5 minutes)
- [ ] **Step 6:** Add release name (auto-filled, usually fine as-is)
- [ ] **Step 7:** Add release notes:
```
Initial release of Pregame: World Cup 2026!

- Full match schedule for all 104 matches
- AI-powered match predictions
- Watch party creation and discovery
- Venue finder with interactive map
- Live match chat with reactions
- Copa AI assistant
- Social feed, friends, and messaging
- Fan Pass and Superfan Pass premium tiers
- Available in English, Spanish, French, and Portuguese
```
- [ ] **Step 8:** Click **"Review release"**
- [ ] **Step 9:** Review for any errors or warnings
- [ ] **Step 10:** Click **"Start rollout to Internal testing"**

### 8C: Add Internal Testers

- [ ] **Step 1:** On the Internal testing page, click the **"Testers"** tab
- [ ] **Step 2:** Create a new email list (e.g., "Internal Testers")
- [ ] **Step 3:** Add your email and any other testers
- [ ] **Step 4:** Copy the **opt-in link** — send this to testers so they can install
- [ ] **Step 5:** Click **Save**

### 8D: Test on Internal Track

- [ ] **Step 1:** Open the opt-in link on your Android device
- [ ] **Step 2:** Accept the invitation
- [ ] **Step 3:** Install the app from the Play Store internal testing page
- [ ] **Step 4:** Test all features: login, predictions, chat, venues, payments, etc.
- [ ] **Step 5:** Fix any issues, rebuild, and upload a new bundle if needed

---

## PHASE 9: Production Release

Once you're happy with internal testing, go live.

- [ ] **Step 1:** Click **Release > Production**
- [ ] **Step 2:** Click **"Create new release"**
- [ ] **Step 3:** You can either:
  - **"Add from library"** — select the same bundle you already tested internally
  - **Upload** a new `.aab` if you've made changes
- [ ] **Step 4:** Add the same release notes as internal testing (or update them)
- [ ] **Step 5:** Click **"Review release"**
- [ ] **Step 6:** Check the dashboard — the left sidebar should show green checkmarks on all required items. If anything is yellow/red, complete those sections first
- [ ] **Step 7:** Click **"Start rollout to Production"**

### Staged Rollout (Recommended)

- [ ] **Step 8:** Google will ask for a rollout percentage — start with **20%**
- [ ] **Step 9:** Monitor your Play Console dashboard for 24-48 hours:
  - Check crash rate (should be under 1%)
  - Check ANR (App Not Responding) rate (should be under 0.5%)
- [ ] **Step 10:** If everything looks good, go back to Production and increase rollout to **100%**

### Review Timeline

- **First submission:** 3-7 business days (sometimes longer for new accounts)
- **Subsequent updates:** 1-3 days
- You'll get an email when your app is approved or if there are issues

---

## PHASE 10: Post-Launch Monitoring

- [ ] Check **Play Console > Quality > Android vitals** daily for the first week
- [ ] Respond to user reviews (Play Console > Ratings and reviews)
- [ ] Monitor Firebase Crashlytics for any crashes
- [ ] Set up **Play Console alerts** (Settings > Notifications) for:
  - New reviews with low ratings
  - Crash rate spikes
  - Policy violations

---

## Quick Troubleshooting

| Problem | Solution |
|---------|----------|
| "App not eligible for this device" | Check `minSdkVersion` in `build.gradle.kts` (yours is 23, which is fine) |
| Upload fails | Make sure the `.aab` is signed — check that `key.properties` is correct |
| "Version code already used" | Increment the number after `+` in `pubspec.yaml` (e.g., `1.0.0+2`) |
| Build fails | Run `flutter clean && flutter pub get` then try again |
| Screenshots rejected | Use 1080x1920 or 1440x2560, 9:16 aspect ratio, PNG or JPEG |
| Feature graphic rejected | Must be exactly 1024 x 500 px |
| Rejected for trademark | Remove trademarked terms from app name/description, use "World Cup 2026" only |
| Data safety form errors | Re-check every data type matches what your app actually collects |

---

## For Future Updates

Every time you release an update:
1. Increment version in `pubspec.yaml`: `1.0.0+1` → `1.0.1+2` (both version name AND version code)
2. `flutter clean && flutter pub get && flutter build appbundle --release`
3. Play Console > Production > Create new release > Upload new `.aab`
4. Add release notes describing what changed
5. Roll out

---

*Last updated: March 2026*

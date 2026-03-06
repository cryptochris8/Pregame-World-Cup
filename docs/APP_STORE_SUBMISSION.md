# App Store Submission Guide - Pregame World Cup

## Quick Reference: Can I Save Progress?

**YES.** App Store Connect supports drafts. You can work on your submission over multiple days/weeks. Only the final "Submit for Review" click sends it to Apple. You can save and return to any section at any time.

---

## SECTION 1: App Information (Copy-Paste Ready)

### App Name (max 30 characters)
```
Pregame: World Cup 2026
```

### Subtitle (max 30 characters)
```
Fan Hub, Predictions & Chat
```

### Bundle ID
```
com.pregameworldcup.app
```
*(Verify this matches your Xcode project exactly)*

### SKU
```
pregame_world_cup_2026
```

### Primary Language
```
English (U.S.)
```

### Primary Category
```
Sports
```

### Secondary Category
```
Social Networking
```

### Copyright
```
2026 Pregame World Cup
```

---

## SECTION 2: Version Information (Copy-Paste Ready)

### Promotional Text (max 170 characters - can be updated anytime)
```
The 2026 FIFA World Cup is coming to North America! Get AI match predictions, find watch parties near you, chat with fans worldwide, and never miss a match. Download free.
```

### Description (max 4000 characters)
```
Your ultimate companion for the 2026 FIFA World Cup in the USA, Mexico, and Canada.

Pregame brings everything a World Cup fan needs into one app -- live scores, AI-powered match predictions, watch party planning, real-time fan chat, venue discovery, and deep tournament coverage for all 48 teams across 104 matches.

COMPLETE MATCH COVERAGE
Follow every group stage, Round of 32, quarterfinal, semifinal, and final match with detailed previews and live score tracking. Browse the full schedule with smart filters by date, group, team, or stage. Set reminders so you never miss kickoff, and export matches directly to your calendar.

AI MATCH PREDICTIONS & ANALYSIS
Our local prediction engine uses a 10-factor weighted algorithm -- including Elo ratings, squad market values, recent form, head-to-head records, injury impact, and betting odds -- to deliver data-driven match predictions with projected scorelines. Tap into AI-generated match summaries, key player insights, and tactical analysis for every matchup.

WATCH PARTIES
Create or discover watch parties happening near you. Invite friends, choose a venue, and coordinate game-day plans. Browse public watch parties by match, location, or date. Whether you are watching at a bar downtown or hosting at home, Pregame makes it easy to gather your crew.

VENUE DISCOVERY WITH MAP
Find nearby bars, restaurants, and fan zones showing World Cup matches on an interactive Google Map. View venue details including atmosphere ratings, capacity, TV setup info, game-day specials, and which matches they are broadcasting. Get directions with one tap.

LIVE MATCH CHAT & FAN COMMUNITY
Join real-time match chat rooms with quick reactions for every goal, save, and foul. Connect with fans supporting the same team through the social activity feed, friend system, and direct messaging with voice messages, photo sharing, and file attachments.

ALL 48 TEAMS & SQUADS
Explore detailed profiles for every national team -- squad rosters, player stats, World Cup history, group standings, and confederation records. Compare players side by side with the Player Comparison tool. Browse manager profiles and track your favorite teams with personalized alerts.

COPA AI ASSISTANT
Meet Copa, your built-in World Cup sidekick. Ask Copa about any team, match schedule, player stats, group standings, or tournament history and get instant, data-backed answers right inside the app.

TOURNAMENT BRACKET & LEADERBOARDS
Follow the knockout stage with a visual bracket. Make your own match predictions and compete on the prediction leaderboard. Track who is climbing the standings and how your picks compare to the AI.

FAN PASS & PREMIUM FEATURES
Unlock an ad-free experience and premium features with Fan Pass. Choose the tier that fits your fandom -- with access to enhanced AI insights, advanced player comparisons, and more.

BUILT FOR FANS WORLDWIDE
- Available in English, Spanish, French, and Portuguese
- Timezone-aware scheduling -- see every match in your local time
- Offline-first architecture -- browse teams, groups, and match data even without a connection
- Push notifications for match reminders and social updates
- Home screen widget for quick match countdowns
- Share match details, predictions, and watch party invites with friends

Whether you are cheering from the stands in MetLife Stadium, watching from a bar in Mexico City, or streaming from your couch halfway around the world -- Pregame is your World Cup headquarters.

Download free and start your Pregame today.
```

### Keywords (max 100 characters, comma-separated)
```
world cup 2026,soccer,football,FIFA,predictions,watch party,live scores,fan,match,teams,chat,venues
```

### What's New (Version 1.0.0)
```
Welcome to Pregame -- your 2026 FIFA World Cup companion!

- Full match schedule for all 104 matches across USA, Mexico & Canada
- AI-powered match predictions with 10-factor analysis engine
- Watch party creation, discovery & friend invitations
- Venue finder with interactive map and atmosphere ratings
- Live match chat with quick reactions
- Copa AI assistant for instant World Cup answers
- Social feed, friends list & direct messaging with voice and media
- Player comparison tool and tournament leaderboards
- Prediction contests to compete with friends and the community
- Fan Pass premium tiers for an ad-free experience
- Available in English, Spanish, French & Portuguese
- Offline-first: browse teams, groups & matches without a connection
```

### Support URL
```
https://pregameworldcup.com/support
```

### Marketing URL (optional)
```
https://pregameworldcup.com
```

### Version Number
```
1.0.0
```

---

## SECTION 3: Age Rating Questionnaire Answers

| Question | Answer |
|----------|--------|
| Violence/Gore | **None** |
| Sexual Content/Nudity | **None** |
| Profanity/Crude Humor | **Infrequent/Mild** (UGC with profanity filter) |
| Alcohol/Tobacco/Drugs | **Infrequent/Mild** (sports bar venue discovery) |
| Gambling | **Infrequent/Mild Simulated** (predictions with virtual points, no real money) |
| Horror/Fear | **None** |
| Mature/Suggestive Themes | **None** |
| Medical/Treatment Info | **None** |
| User-Generated Content | **Yes** (messaging, chat, social features with moderation) |
| Unrestricted Web Access | **No** |

**Expected Age Rating: 12+**

---

## SECTION 4: App Privacy Questionnaire

### Data Types Collected - Quick Checklist

**Contact Info:**
- [x] Name (display name for profile)
- [x] Email Address (authentication)
- [ ] Phone Number - NOT collected
- [ ] Physical Address - NOT collected

**Financial Info:**
- [x] Purchase History (RevenueCat subscription status)
- [ ] Credit/Debit Card - NOT stored (handled by Stripe/Apple)

**Location:**
- [x] Precise Location (venue discovery, watch parties)
- [x] Coarse Location (same features)

**User Content:**
- [x] Photos/Videos (profile pics, message attachments)
- [x] Audio Data (voice messages)
- [x] Gameplay Content (match predictions, leaderboard scores)
- [x] Other User Content (messages, bios, favorite teams, watch parties)

**Identifiers:**
- [x] User ID (Firebase Auth UID)
- [x] Device ID (FCM push notification token)
- [x] Advertising ID / IDFA (AdMob, with ATT consent)

**Usage Data:**
- [x] Product Interaction (screen views, feature usage via Firebase Analytics)
- [x] Advertising Data (AdMob interaction data)

**Diagnostics:**
- [x] Crash Data (Firebase Crashlytics)
- [x] Performance Data (error logs)

### Data NOT Collected
- Health & Fitness data
- Sensitive Info (race, religion, etc.)
- Device Contacts
- Browsing History
- Search History (not persisted)
- Phone Number
- Physical Address

### Data Used for Tracking
- **Advertising ID (IDFA)** - for personalized ads via AdMob
- **Advertising Data** - ad performance metrics
- Note: Fan Pass subscribers don't see ads and are not tracked

### Data Linked to User Identity
- All collected data IS linked to user identity (Firebase Auth)

---

## SECTION 5: App Review Information

### Demo Account (REQUIRED - app has login)
```
Email: reviewer@pregameworldcup.com
Password: [CREATE A STRONG TEST PASSWORD]
```
*Create this account before submission with full access to all features. Ensure it has predictions, friends, and messages populated so the reviewer can see functionality.*

### Notes for Reviewer
```
Pregame World Cup 2026 is a fan companion app for the upcoming FIFA World Cup.

KEY FEATURES TO TEST:
1. Browse Matches: Main tab shows all World Cup matches with filters
2. AI Predictions: Tap any match to see AI-powered predictions
3. Watch Parties: Create or discover watch parties (Social tab)
4. Venue Finder: Find nearby venues on the map (Venues tab)
5. Match Chat: Join real-time chat for any match
6. Copa AI: Chat with our AI assistant about any World Cup topic
7. Messaging: Send messages to other users (text, voice, photos)

IN-APP PURCHASES:
- Fan Pass and Superfan Pass available via RevenueCat
- Virtual Attendance tickets available via Stripe
- All purchases use Apple's IAP system for digital content

LOCATION:
- Location is used only for finding nearby venues and watch parties
- App functions fully without location permission

PUSH NOTIFICATIONS:
- Used for match reminders, social updates, and friend requests

CONTENT MODERATION:
- Built-in profanity filter (English, Spanish, Portuguese)
- User reporting and blocking system
- Content moderation tools for flagged content

The app is not affiliated with or endorsed by FIFA.
```

### Contact Information
```
First Name: [YOUR FIRST NAME]
Last Name: [YOUR LAST NAME]
Phone: [YOUR PHONE NUMBER]
Email: [YOUR EMAIL]
```

---

## SECTION 6: Technical Answers

### Uses Non-Exempt Encryption?
```
NO
```
*(Already set in Info.plist: ITSAppUsesNonExemptEncryption = false)*

### Uses IDFA / App Tracking Transparency?
```
YES - for Third-Party Advertising (AdMob)
```

### Content Rights
```
YES - This app displays third-party content
```
*Note: Uses SportsData.io API (ensure your API license permits mobile distribution)*

### Made for Kids?
```
NO
```

---

## SECTION 7: Screenshots Required

### iPhone Screenshots (REQUIRED)
- **Size:** 1320 x 2868 pixels (6.9-inch iPhone 16 Pro Max)
- **Count:** Minimum 1, Maximum 10 (recommend 5-8)
- **Format:** PNG or JPEG (no transparency)

**Recommended screenshot sequence:**
1. Match schedule / home screen
2. AI match prediction detail
3. Watch party discovery
4. Venue map with nearby locations
5. Live match chat
6. Copa AI assistant conversation
7. Team detail / squad roster
8. Tournament bracket

### iPad Screenshots (if iPad supported)
- **Size:** 2064 x 2752 pixels (13-inch iPad)

### App Icon
- **Size:** 1024 x 1024 pixels
- **Format:** PNG, RGB, no transparency, no rounded corners (Apple adds them)

---

## SECTION 8: Release Settings

Choose one:
- **Automatic Release** - Goes live immediately after Apple approval
- **Manual Release** - You choose when to release after approval (RECOMMENDED for coordinated launch)
- **Scheduled Release** - Set specific date/time

---

## SECTION 9: Submission Workflow Checklist

### Before Starting
- [ ] Apple Developer Program membership active ($99/year)
- [ ] Bundle ID created in Apple Developer portal
- [ ] Privacy Policy hosted at accessible HTTPS URL
- [ ] Support URL page live and accessible
- [ ] Demo account created and populated with test data
- [ ] App icon (1024x1024 PNG) ready
- [ ] Screenshots captured for all required device sizes

### In App Store Connect
- [ ] Create new app record (name, bundle ID, SKU)
- [ ] Fill in App Information (subtitle, categories, copyright)
- [ ] Complete Age Rating questionnaire
- [ ] Complete App Privacy questionnaire
- [ ] Set Pricing (Free) and Availability (countries)
- [ ] Upload build via Xcode (Archive > Distribute > App Store Connect)
- [ ] Wait for build processing (email notification when ready)
- [ ] Fill in Version Information (description, keywords, what's new)
- [ ] Upload screenshots
- [ ] Select processed build
- [ ] Fill in App Review Information (demo account, notes, contact)
- [ ] Choose release setting (manual recommended)
- [ ] Review all sections for warnings
- [ ] Submit for Review

### After Submission
- [ ] Monitor status: Waiting for Review > In Review > Approved/Rejected
- [ ] Expected review time: 2-3 days for iOS (2026 average)
- [ ] If rejected: fix issues, resubmit (no need to re-upload build if metadata-only rejection)

---

## SECTION 10: Important Warnings

### FIFA Trademark Risk
The app name contains "World Cup" which is a FIFA trademark. Consider:
- Adding disclaimer: "Not affiliated with or endorsed by FIFA"
- Having legal review of app name and description
- Using terms like "soccer tournament" as alternatives if needed

### Common Rejection Reasons to Avoid
1. **Crashes** - Test thoroughly on multiple devices via TestFlight first
2. **Broken demo credentials** - Verify they work right before submission
3. **Missing privacy disclosures** - Ensure ALL third-party SDKs are declared
4. **Placeholder content** - Remove any "coming soon" or test data
5. **IAP issues** - All digital goods MUST use Apple's IAP (RevenueCat handles this)
6. **Misleading screenshots** - Must show actual app screens

### SDK Requirement (April 28, 2026)
Apps must be built with iOS 26 SDK or later. Ensure Xcode is updated.

---

*Generated: March 2026 | Version: 1.0*
*This document can be saved and referenced across multiple submission sessions.*

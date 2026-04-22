# Pregame — App Store Resubmission Report (V5)

**App:** Pregame 2026

**Date:** April 22, 2026

**Previous Rejection:** April 21, 2026 (Submission ID: aa84435a-a6a2-4d9e-ae48-553e2f9d0568, Version reviewed: 1.0.85)

**Rejection Guideline:** Simulated Gambling Policy — individual developer accounts restricted from distributing apps with prediction, contest, or gambling-adjacent features

---

## Summary

We understand and accept Apple's 2026 policy restricting apps with prediction or simulated-gambling features to Organization-account distribution. For this resubmission, every user-facing surface that could be interpreted as a prediction contest, handicapping display, or paid prediction tier has been **removed from the Pregame binary**.

The app is being resubmitted as a pure sports-companion and editorial experience — schedule, AI-written pregame journalism, team and player profiles, venue discovery, and social features. No picks, no odds, no leaderboards, no paid prediction tiers.

In parallel, our South Carolina LLC is pursuing Organization enrollment in the Apple Developer Program (DUNS request submitted). Once approved, future apps we build on this codebase will be distributed from that Organization account under the appropriate policy framework. **This Pregame app, however, is and will remain a non-gambling submission** regardless of Organization enrollment status.

---

## Features Removed from This Build (1.0.86+)

Every removal is implemented via compile-time feature flags, so the flagged code is *not executable* in the shipped binary — it is excluded from the compilation unit entirely. Source-level evidence is available on request.

### Prediction Surfaces
- User prediction submission ("Make Your Prediction" modal) — removed
- Quick Prediction button on match cards — removed
- AI Predict chip on match cards — removed
- Prediction save / edit / delete flows — removed
- Prediction cards in user feeds — removed
- Prediction history and statistics screens — removed
- "My Predictions" navigation entry and Predictions page — removed

### Contest / Leaderboard Surfaces
- Tournament prediction leaderboard — removed
- Prediction accuracy rankings — removed
- Leaderboard entry point from the main navigation menu — removed

### Handicapping / Odds Surfaces
- Win probability display (Home / Draw / Away percentages) — removed
- AI confidence meter display — removed
- "Win Probability" container on match detail views — removed
- "Market View" / betting-market analysis entry in the Pregame Article — removed
- Score prediction and alternative scenarios in match-summary Verdict cards — removed
- Prediction tab in the match-detail tab bar — removed

### Paid Tier Surfaces
- Fan Pass premium subscription tier — removed (IAP products deactivated in App Store Connect)
- Superfan Pass premium subscription tier — removed (IAP products deactivated)
- Fan Pass entry point in the header — removed
- Transaction history screen for prediction-tier purchases — removed
- Feature-gate wrappers that previously required paid tiers now pass content through unconditionally (all content is free)

---

## Features That Remain

Pregame continues to ship as an informational and editorial sports-companion app. The remaining surfaces are:

- Match schedule and live scores for all 104 matches across the 16 host cities (USA, Canada, Mexico)
- AI-written pregame articles — original sports journalism covering tactics, player stories, historical context, and team form. No picks, no odds, no handicapping content.
- Team and player profiles for all 48 participating nations
- City Guides for the 16 host cities — neighborhoods, transit, dining, points of interest
- Venue discovery — local bars, restaurants, and watch parties on match days via Google Places integration
- Watch Parties — group-viewing events with invitations and chat
- Activity Feed — social sharing (check-ins, photos, match moments) with full moderation stack (EULA, content filter, report, block, 24-hour admin response)
- iOS Widgets (Home Screen, Lock Screen) and Dynamic Island Live Activities for live scores and countdowns
- Copa — a conversational AI soccer companion. Copa does not provide predictions, picks, or handicapping content.
- Penalty Kick Challenge — an original arcade mini-game. No wagering, no prize pool, no point leaderboard.
- Full localization in English, Spanish, French, Portuguese, German, and Arabic

---

## Metadata Changes

- **App Name:** Pregame 2026 *(unchanged)*
- **Subtitle:** Soccer's biggest summer *(updated)*
- **Description:** rewritten to remove all prediction, odds, and contest references. Closing paragraph now reads: *"Pregame is an independent fan app. It is not affiliated with, endorsed by, or sponsored by any football federation, confederation, or tournament organizer. The app does not involve wagers, betting, prize contests, or simulated gambling of any kind."*
- **Keywords:** rewritten — no gambling-adjacent terms (no "predictions," "picks," "odds," "betting," "fantasy," "leaderboard," "contest," "handicap," or "pool")
- **Age Rating Questionnaire:** updated — Simulated Gambling, Contests, and Gambling and Contests Including Skill-Based Games all set to None / No
- **In-App Purchases:** Fan Pass and Superfan Pass products removed from the product list
- **App Store Screenshots:** all 10 slots re-captured from the new build (1.0.86+) showing the non-gambling UI

---

## Website Metadata

The marketing website at pregameworldcup.com was previously updated during the V4 submission to remove all "World Cup" trademark references. For this submission, it has also been reviewed to confirm no prediction, betting, or contest content is advertised. Current website content describes Pregame as a sports-companion and editorial app only.

---

## Independence Disclaimer

The following disclaimer appears on the login screen and on the user profile screen in-app, and in the App Store description:

> "Pregame is an independent fan app. It is not affiliated with, endorsed by, or sponsored by any football federation, confederation, or tournament organizer. The app does not involve wagers, betting, prize contests, or simulated gambling of any kind."

---

## Technical Implementation Note

The removals above are not UI-layer hiding. They are implemented via Dart compile-time constants (`bool.fromEnvironment` flags) passed as `--dart-define` arguments to `flutter build ipa`. When a flag is false, the Dart compiler's tree-shaker removes the gated widgets from the final binary. The shipped IPA contains no executable code for the removed features.

Source reference: `lib/core/config/feature_flags.dart`. The Codemagic CI/CD configuration passes `FEATURE_PREDICTIONS=false`, `FEATURE_PREDICTION_LEADERBOARD=false`, `FEATURE_BETTING_ODDS=false`, `FEATURE_AI_PROBABILITY=false`, and `FEATURE_FAN_PASS=false` for every App Store build.

---

## Organization Enrollment (Parallel Track, Unrelated to This Submission)

Our LLC, registered in South Carolina, has initiated D-U-N-S verification and Apple Developer Program Organization enrollment. This is a forward-looking step for future apps in our portfolio and **does not affect the compliance posture of this Pregame submission**. Pregame will remain a non-gambling submission under the individual account.

---

## Request

We have removed every feature in the app that could be interpreted as simulated gambling, prediction contest, or gambling-adjacent content. We have updated every App Store Connect surface — description, keywords, age rating questionnaire, in-app purchases, and screenshots — to reflect this scope.

We respectfully request review of this updated submission. If any remaining element is perceived as gambling-adjacent, please identify it specifically and we will address it in the next build.

Thank you for your continued review.

— The Pregame Team

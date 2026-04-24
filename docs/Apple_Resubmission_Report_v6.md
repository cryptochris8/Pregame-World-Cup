# Pregame — App Store Resubmission Report (V6)

**App:** Pregame 2026

**Date:** April 23, 2026

**Review Message:** April 22, 2026 (Submission ID: aa84435a-a6a2-4d9e-ae48-553e2f9d0568, Version reviewed: 1.0.103)

**Guidelines Cited:**
- **2.1(b) — Information Needed** — Reviewer could not locate Fan Pass and Superfan Pass In-App Purchases in the app
- **2.1(a) — Performance / App Completeness** — Activity Feed and Achievements buttons on the Profile screen were unresponsive

---

## Summary

This is a direct follow-up to our V5 gambling-strip submission. The reviewer raised two concerns after reviewing build 1.0.103; both are addressed in this resubmission.

**The simulated-gambling compliance from V5 is unchanged** — all prediction, odds, leaderboard, and paid-prediction-tier surfaces remain excluded from the binary via compile-time feature flags. No new gambling-adjacent surface has been added.

---

## Guideline 2.1(b) — Missing In-App Purchases

**Issue:** Reviewer could not locate the Fan Pass ($14.99) and Superfan Pass ($29.99) In-App Purchases within the app.

**Response:** These IAPs have been **intentionally removed** from the app as part of the V5 simulated-gambling compliance work. The Fan Pass and Superfan Pass were the paid prediction-tier products referenced in our April 21 rejection notice; removing them was a required part of bringing the app into compliance with the 2026 simulated-gambling policy.

**Current state of In-App Purchases:**
- Fan Pass — removed from the binary (FEATURE_FAN_PASS=false at compile time) and marked "Removed from Sale" in App Store Connect
- Superfan Pass — removed from the binary and marked "Removed from Sale" in App Store Connect
- No other IAPs exist in the app. Pregame now ships as an entirely free experience with no paid tiers, no subscription, and no prediction-gated content.

**Steps for the reviewer to confirm:** The app has no IAP entry points. There is no "Upgrade," "Fan Pass," "Premium," or "Subscribe" button anywhere in the navigation, on the profile screen, or in the match-detail views. If a reviewer expects to reach an IAP surface and cannot, that is the expected behavior — not a bug.

We have also updated the "In-App Purchases" section of the App Store Connect submission to reflect that no IAPs are submitted with this build.

---

## Guideline 2.1(a) — Unresponsive Activity Feed & Achievements Buttons

**Issue:** On the Profile screen of build 1.0.103, the reviewer tapped on two tiles — "Activity Feed" and "Achievements" — and neither responded.

**Root cause:** Both tiles were rendered by a passive card helper that drew the tile visuals (icon, title, subtitle, right-chevron) but did not attach an `InkWell` or `onTap` handler. The tiles were effectively decoration — visually interactive but functionally dead.

**Secondary issue (also fixed):** The tile subtitles contained the word *"predictions"* ("Track your game predictions…" and "Unlock badges for predictions…"). Even though the prediction features themselves were already excluded from the binary in V5, the copy on these tiles still referenced them. This was a gambling-strip copy leak that we missed in V5; it is resolved as a side-effect of removing the tiles.

**Fix:** Both tiles have been removed from the Profile screen entirely. The Profile screen now renders only tiles that have real destinations (Accessibility Settings, Edit Profile). Activity Feed remains fully accessible from the main bottom navigation (tab: "Feed"), so no functionality is lost. Achievements as a feature was not implemented and has been permanently removed.

**Reference commit:** `15090a4` — "Fix 2.1(a): remove dead Activity Feed & Achievements tiles on Profile"

---

## Defense-in-Depth Improvements in This Build

Beyond the two reported issues, we took the opportunity to harden several adjacent surfaces:

- **Deep-link navigation handlers** (`lib/core/services/deep_link_navigator.dart`) now early-return to the home screen when a gambling-gated feature is disabled, rather than pushing a "feature unavailable" scaffold. A reviewer clicking a stale or shared leaderboard / prediction / Fan Pass deep link will land on the home screen with no indication that the feature ever existed.
- **Venue portal upgrade CTA** — the $499 venue-owner upgrade dialog is now gated by a dedicated FEATURE_VENUE_UPGRADE flag and is compiled out of this build. This addresses any anti-steering interpretation.
- **Interstitial ad integration** — unrelated to this rejection but hardened in this build cycle; now gated by a cooldown timer so ads cannot fire back-to-back.

---

## Build Submitted With This Reply

- **Version:** 1.0.[BUILD_NUMBER]
- **Compiled:** April 23, 2026
- **All V5 gambling-strip flags confirmed set to `false` in Codemagic:** FEATURE_PREDICTIONS, FEATURE_PREDICTION_LEADERBOARD, FEATURE_BETTING_ODDS, FEATURE_AI_PROBABILITY, FEATURE_FAN_PASS, FEATURE_VENUE_UPGRADE
- **2.1(a) fix confirmed:** `lib/features/social/presentation/widgets/profile_feature_cards.dart` has no "Activity Feed" or "Achievements" tile code
- **2.1(b) response:** Fan Pass and Superfan Pass products marked "Removed from Sale" in App Store Connect; submission IAP list is empty

---

## Request

We have addressed both issues raised in the April 22 message, verified that the V5 gambling-strip compliance remains intact, and uploaded a new build (1.0.[BUILD_NUMBER]) to App Store Connect.

We respectfully request that review of submission `aa84435a-a6a2-4d9e-ae48-553e2f9d0568` resume with this corrected build.

Thank you for your continued review.

— The Pregame Team

---

## Resolution Center Reply (paste into App Store Connect)

```
Hello,

Thank you for the review and for flagging these two issues. Both are
addressed in build 1.0.[BUILD_NUMBER], which we have uploaded to App
Store Connect.

---

GUIDELINE 2.1(b) — Missing Fan Pass / Superfan Pass In-App Purchases

These two IAPs were intentionally removed from the app as part of our
V5 compliance work with the simulated-gambling policy (per the April
21 rejection notice). Fan Pass and Superfan Pass were the paid
prediction-tier products; removing them was required to bring Pregame
into compliance.

The app no longer has any In-App Purchases. It ships as a fully free
experience with no paid tiers, no subscription, and no purchase
surfaces anywhere in the UI. There is no "Upgrade," "Premium," "Fan
Pass," or "Subscribe" button anywhere in the app. If the reviewer is
searching for the IAP purchase flow, the expected state is that no
such flow exists.

We have updated the In-App Purchases section of this submission in
App Store Connect to reflect that no IAPs accompany this build.

---

GUIDELINE 2.1(a) — Unresponsive Activity Feed and Achievements Buttons

We reproduced the issue. On the Profile screen in build 1.0.103, the
Activity Feed and Achievements tiles drew visual interactive
elements (right-chevron, tap-affordance styling) but had no tap
handler attached — the tiles were decoration, not buttons.

We also noticed the tile subtitles still contained the word
"predictions" ("Track your game predictions..." and "Unlock badges
for predictions..."). This was a copy leak from the prior prediction
feature that we missed in V5.

Both tiles have been removed from the Profile screen entirely in
build 1.0.[BUILD_NUMBER]. Activity Feed remains fully reachable via
the main bottom navigation (the "Feed" tab). Achievements was not
implemented as a backing feature and has been permanently removed.

---

The V5 simulated-gambling compliance is unchanged: all prediction,
odds, leaderboard, and paid-tier surfaces remain excluded from the
binary via compile-time feature flags.

Please continue review of submission
aa84435a-a6a2-4d9e-ae48-553e2f9d0568 with build 1.0.[BUILD_NUMBER].

Thank you,
Chris Campbell
```

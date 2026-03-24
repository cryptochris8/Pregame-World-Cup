# Project Review & Fixes Summary — 2026-03-24

## Overview

A comprehensive review of the Pregame World Cup codebase was conducted using 4 specialized sub-agents (FIFA IP Scanner, EULA Compliance Auditor, Architecture Reviewer, Security Auditor). Critical fixes were then applied to address App Store rejection issues.

---

## Review Findings

### Architecture (Rating: 7.5/10)

**Strengths:**
- 17 feature modules with Clean Architecture patterns
- Three-tier data strategy (Firestore live + local JSON + Hive cache) with resilient fallback chains
- BLoC/Cubit state management with GetIt DI (28 Cubits across features)
- Full CI/CD via Codemagic (test, iOS TestFlight, Android internal track)
- 418 test files (72% test:source ratio)
- 4-language localization (EN, ES, FR, PT)
- Comprehensive Firestore security rules with default-deny

**Weaknesses identified:**
- Inconsistent Clean Architecture across features (worldcup is exemplary; venues, messaging, auth lack data layers)
- Almost no formal use cases (only 5 across the app)
- 61 files exceed 500 lines
- 418 test files untracked in git

---

## Fixes Applied

### P0-1: Remove FIFA from User-Facing Disclaimer
**Files modified: 8**
- `lib/l10n/app_en.arb` — Removed "FIFA" from appDisclaimer string
- `lib/l10n/app_es.arb` — Same (Spanish)
- `lib/l10n/app_fr.arb` — Same (French)
- `lib/l10n/app_pt.arb` — Same (Portuguese)
- `lib/l10n/app_localizations_en.dart` — Updated generated string
- `lib/l10n/app_localizations_es.dart` — Updated generated string
- `lib/l10n/app_localizations_fr.dart` — Updated generated string
- `lib/l10n/app_localizations_pt.dart` — Updated generated string

**Before:** "...not affiliated with, endorsed by, or sponsored by FIFA or any official tournament organization."
**After:** "...not affiliated with, endorsed by, or sponsored by any official tournament organization."

### P0-2: Add Profanity Filter to Watch Party Chat
**Files modified: 1**
- `lib/features/watch_party/domain/services/watch_party_chat_service.dart`
  - Added `ModerationService().validateMessage(content)` before message send
  - Blocked messages throw exception with error message
  - Mild profanity is censored; severe profanity is rejected
  - Added import for `moderation.dart`

### P0-3: Add Profanity Filter to Profile Save
**Files modified: 1**
- `lib/features/social/presentation/screens/edit_profile_screen.dart`
  - Added `ProfanityFilterService().validateUsername(displayName)` check — rejects impersonation and severe profanity
  - Added `ProfanityFilterService().filterContent(bio)` — censors mild profanity, rejects severe
  - Added import for `moderation.dart`
  - Fixed FIFA comment on line 45

### P0-4: Rename fifaCode/fifaRanking/fifaWorldCup Across Entire Codebase
**Files modified: ~250+** (executed by 3 parallel sub-agents)

#### fifaCode → teamCode (~202 files)
- 27 Dart lib files (entities, repositories, datasources, blocs, pages, widgets, services)
- 9 l10n files (ARB + generated)
- 7 TypeScript/JS Cloud Function files
- 16 test files
- 121 JSON asset files (teams, team_history, player_stats)
- 5 documentation files

#### fifaRanking → worldRanking (44 files)
- 16 Dart lib files (entities, datasources, repositories, blocs, cubits, services, pages, widgets)
- 9 l10n files (ARB + generated)
- 1 JSON asset file (teams_metadata.json)
- 15 test files

#### fifaWorldCup → worldCup, fifaWorldCup2026 → worldCup2026 (10 files)
- `lib/l10n/app_localizations.dart` — abstract getters
- 4 generated l10n files — concrete getters
- 4 ARB files — keys and @keys
- `lib/features/schedule/presentation/screens/enhanced_schedule_screen.dart` — usage site

### P0-5: Fix Firestore Security Rules (3 vulnerabilities)
**Files modified: 1**
- `firestore.rules`
  - `venue_reviews` create: Added `request.auth.uid == request.resource.data.userId` — prevents posting reviews as other users
  - `ai_recommendations` read: Changed to `request.auth.uid == resource.data.userId` — prevents reading other users' recommendations
  - `ai_recommendations` create: Added `request.auth.uid == request.resource.data.userId`
  - `message_notifications` create: Added `request.auth.uid == request.resource.data.senderId` — prevents notification spam

### P0-6: Remove Unnecessary Location Permission
**Files modified: 1**
- `ios/Runner/Info.plist`
  - Removed `NSLocationAlwaysAndWhenInUseUsageDescription` — app only uses `whileInUse` location
  - This key is a common Apple rejection trigger when "Always" location isn't actually used

### P0-8: Clean Up FIFA Comments Across Source Files
**Files modified: 43** (executed by sub-agent)
- 38 Dart files — replaced "FIFA" in doc comments and inline comments with neutral terms
- 5 non-Dart files (TypeScript, JavaScript, config)
- Replacements: "FIFA code" → "team code", "FIFA World Cup" → "World Cup", "FIFA ranking" → "world ranking", "FIFA confederation" → "confederation", "FIFA tiebreaker" → "tournament tiebreaker", etc.

### Additional Fixes Applied

#### Account Deletion — social_profiles Cleanup
**Files modified: 1**
- `lib/features/auth/domain/services/auth_service.dart`
  - Added `social_profiles/{uid}` deletion to `deleteAccount()` method
  - Previously, this Firestore document (containing terms acceptance data) was orphaned on account deletion

#### Generated l10n Doc Comments
**Files modified: 1**
- `lib/l10n/app_localizations.dart`
  - Fixed 5 auto-generated doc comments that still referenced "FIFA"

#### Android Manifest Security Fixes
**Files modified: 1**
- `android/app/src/main/AndroidManifest.xml`
  - Removed `firebase_app_check_debug_token` placeholder from release manifest
  - Added `android:maxSdkVersion="32"` to `READ_EXTERNAL_STORAGE`
  - Added `READ_MEDIA_IMAGES` permission for Android 13+

---

## Verification Results

### FIFA References — Final State

| Location | Count | Status |
|----------|-------|--------|
| Dart source (`lib/`) | 4 | All are ESPN API slugs (`fifa.world`, `fifa.worldq`) or profanity filter entry — leave as-is |
| JSON assets | 3 | All are external URLs (Polymarket, Dimers, fifa.com) — cannot change |
| `fifaCode` / `fifaRanking` / `fifaWorldCup` identifiers | 0 | Fully eliminated |
| User-facing "FIFA" text | 0 | Fully eliminated |

### Items Left As-Is (Intentional)
- ESPN API slugs: `'fifa.world'`, `'fifa.worldq'` — third-party API identifiers
- SportsData.io: `'FIFA_WORLDCUP_2026'` — API competition ID
- Profanity filter: `'fifa'` — protective UGC moderation entry
- External URLs in `betting_odds.json` — real web URLs

---

## Remaining Recommendations (Not Yet Applied)

### Near-Term (P1)
1. **Proxy AI API calls through Cloud Functions** — don't embed OpenAI/Claude keys in binary
2. **Add server-side content moderation** via Google Perspective API (Cloud Function trigger)
3. **Add Apple reviewer notes** explaining Venue Premium B2B exemption from Guideline 3.1.1
4. **Add release-mode guard to LoggingService** — suppress info logs in production
5. **Redact email PII** from auth service logs
6. **Add `service-account*.json`** to `functions/.gitignore`

### Longer-Term (P2)
7. Introduce BLoC/Cubit for `social` and `messaging` features
8. Refactor oversized widgets (800+ lines)
9. Strengthen `analysis_options.yaml` lint rules
10. Add terms version re-prompt mechanism
11. Complete GDPR message/post cleanup on account deletion
12. Remove or document root `webpack.config.js` / `tsconfig.json`

---

## Security Audit Summary

| Severity | Count | Key Findings |
|----------|-------|-------------|
| High | 5 | Firestore rule gaps (FIXED), Firebase keys in git (standard), Stripe Price ID fallbacks |
| Medium | 6 | PII in logs, no release-mode log guard, client-side-only profanity filter, App Check debug token (FIXED) |
| Low | 5 | Location permission (FIXED), Android storage permission (FIXED), generic ATT description |
| Informational | 8 | App Check correctly implemented, Sign in with Apple correct, Firebase rules default-deny, ATS enforced |

---

## Files Modified — Complete List

**Total unique files modified this session: ~300+**

Major categories:
- 8 ARB/l10n source files (disclaimer fix)
- ~250 files (fifaCode/fifaRanking/fifaWorldCup rename)
- 43 files (FIFA comment cleanup)
- 1 Firestore rules file (security fixes)
- 1 Info.plist (location permission)
- 1 AndroidManifest.xml (security/permission fixes)
- 1 watch_party_chat_service.dart (moderation)
- 1 edit_profile_screen.dart (moderation)
- 1 auth_service.dart (account deletion)

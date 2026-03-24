# Apple App Store Resubmission Report V2

**Date:** March 22, 2026
**Submission ID (Previous):** aa84435a-a6a2-4d9e-ae48-553e2f9d0568
**App:** Pregame: World Cup 2026
**Version:** 1.0.35
**Bundle ID:** com.pregameworldcup.app

---

## Issues Addressed

This resubmission addresses **two issues** from the March 22, 2026 review:

1. **Guideline 5.2.1 — Intellectual Property (FIFA)**: Comprehensive removal of all remaining user-visible FIFA trademark references
2. **Guideline 1.2 — User-Generated Content**: Full implementation of all five Apple-required UGC moderation precautions

---

## Issue 1: Guideline 5.2.1 — FIFA Intellectual Property

### Previous Fix (V1)
Our first resubmission made 157+ edits across 60+ files removing "FIFA World Cup" from user-facing UI strings, metadata, localization, and marketing materials.

### What Was Still Present (V2 Discovery)
Upon deep audit, we found ~130+ additional user-visible FIFA references in:
- JSON data files (match summaries, head-to-head records, player profiles, history, recent form)
- Localization strings ("FIFA Ranking" label)
- One hardcoded Dart string in team sort widget
- One hardcoded string in historical service

### Complete Fix (V2)

#### A. Dart Source & Localization (6 edits + regeneration)

| File | Change |
|------|--------|
| `lib/l10n/app_en.arb` | `"FIFA Ranking"` → `"World Ranking"` |
| `lib/l10n/app_es.arb` | `"Ranking FIFA"` → `"Ranking Mundial"` |
| `lib/l10n/app_fr.arb` | `"Classement FIFA"` → `"Classement Mondial"` |
| `lib/l10n/app_pt.arb` | `"Ranking FIFA"` → `"Ranking Mundial"` |
| `team_sort_chips.dart` | Hardcoded `'FIFA Ranking'` → `'World Ranking'` |
| `espn_historical_service.dart` | `'Co-hosted 2002 FIFA World Cup'` → `'Co-hosted 2002 World Cup'` |

All generated localization files regenerated via `flutter gen-l10n`.

#### B. JSON Data Files (194 files, ~250+ edits)

Bulk replacement across all JSON files in `assets/data/worldcup/`:

| Pattern | Replacement | Files Affected |
|---------|-------------|---------------|
| `"FIFA World Cup"` (all variants) | `"World Cup"` | 100+ files |
| `"FIFA Confederations Cup"` | `"Confederations Cup"` | 10+ files |
| `"FIFA World Cup Qualifying"` | `"World Cup Qualifying"` | 3 recent form files |
| `"FIFA Series"` | `"International Series"` | Head-to-head files |
| `"FIFA Puskas Award"` | `"Puskas Award"` | Player profiles |
| `"FIFA Young Player Award"` | `"Best Young Player Award"` | Player profiles |
| `"FIFA U-17/U-20 World Cup"` | `"U-17/U-20 World Cup"` | Player profiles |
| `"FIFA Club World Cup"` | `"Club World Cup"` | Player profiles |
| `"FIFA rankings"` | `"world rankings"` | Multiple data files |
| `"FIFA #N"` (ranking labels) | `"#N"` | History files |
| `"FIFA.com"` (source references) | `"official records"` | Multiple files |
| `"FIFA membership"` | `"international football membership"` | Match summaries |
| `"FIFA's rule/mandate"` | `"the rule"` / `"the mandate"` | Match summaries |
| `"FIFA World Player of the Year"` | `"World Player of the Year"` | History files |

#### C. What Remains (Intentional)

1. **Legal disclaimer** (`appDisclaimer` localization key): *"Pregame is an independent fan app and is not affiliated with, endorsed by, or sponsored by FIFA or any official tournament organization."* — This deliberately references FIFA to disclaim affiliation and is legally required.

2. **Internal code identifiers**: Variable names (`teamCode`, `fifaRanking`), API constants (`FIFA_WORLDCUP_2026`), Firestore field names, and code comments. These are never displayed to users.

3. **JSON data structure keys**: `"teamCode"`, `"fifa_code"`, `"fifaRanking"` field names used as internal data identifiers.

4. **Source URLs**: Hyperlinks to fifa.com in citation/source fields (cannot be changed without breaking URLs).

#### D. Verification

```bash
# User-visible FIFA in JSON: ZERO results
grep -ri "FIFA" assets/data/worldcup/ --include="*.json" \
  | grep -v "teamCode\|fifa_code\|fifaTournamentName\|fifaConfederationCode\|fifa_ranking\|fifaRanking\|fifa_rankings_context\|fifa.com\|source_url"
# Result: (empty)

# User-visible FIFA in Dart: Only legal disclaimer
grep -rn "'.*FIFA.*'" lib/ --include="*.dart" \
  | grep -v "//\|///\|teamCode\|fifaRanking\|_fifa\|FIFA_\|affiliated"
# Result: (empty)
```

---

## Issue 2: Guideline 1.2 — User-Generated Content

Apple's review identified that the app includes UGC but lacked required moderation precautions. We have implemented **all five required precautions**:

### Precaution 1: EULA/Terms of Service Agreement

**NEW: `TermsAcceptanceScreen`** — A mandatory terms acceptance screen shown to all users after email verification and before accessing any app features.

**Implementation:**
- File: `lib/features/auth/presentation/screens/terms_acceptance_screen.dart`
- Integration: `lib/app.dart` — `AuthenticationWrapper` now checks `termsAcceptedAt` field
- Storage: `social_profiles/{userId}.termsAcceptedAt` in Firestore with server timestamp
- Version tracking: `termsVersion: "1.0"` stored alongside acceptance

**Terms Content Includes:**
- End User License Agreement
- Community Guidelines
- **Zero Tolerance Policy** — explicit list of prohibited content (hate speech, harassment, threats, sexual content, spam, impersonation, illegal content)
- Content Moderation notice (automated filtering + human review within 24 hours)
- Enforcement actions (content removal, muting, suspension, permanent ban)
- User responsibilities
- Links to full Terms of Service and Privacy Policy

**User Flow:**
1. User creates account → verifies email → **sees Terms screen**
2. Must scroll through entire terms before "I Agree" button activates
3. Tapping "I Agree" stores timestamp in Firestore
4. User can decline and sign out
5. Existing users see terms screen on next login (one-time)
6. Once accepted, user proceeds to main app

### Precaution 2: Content Filtering Method

**EXISTING + ENHANCED:**

The app has a comprehensive `ProfanityFilterService` with:
- Severe profanity detection (racial slurs, extreme violence, terrorism)
- Standard profanity filtering (English, Spanish, Portuguese)
- Scam indicator detection
- Username impersonation prevention
- Severity scoring (0-1 scale)
- Auto-reject threshold for severe content

**NEW: Applied to activity feed posts and comments:**
- File: `lib/features/social/domain/services/activity_feed_service.dart`
- `createActivity()` now runs content through `ProfanityFilterService.filterContent()` — auto-rejects objectionable content
- `commentOnActivity()` now runs comments through the same filter before persistence

**Coverage:** Messages (existing), chat (existing), activity posts (NEW), comments (NEW), usernames (existing)

### Precaution 3: Flagging/Reporting Objectionable Content

**EXISTING INFRASTRUCTURE:** `ReportButton`, `ReportMenuItem`, `ReportBottomSheet` widgets with 10 reason categories (spam, harassment, hate speech, violence, sexual content, misinformation, impersonation, scam, inappropriate, other). Content snapshots preserved as evidence. Duplicate prevention.

**NEW: Wired into ALL UGC surfaces:**

| UGC Surface | Implementation |
|-------------|---------------|
| Activity feed posts | `ReportButton` added to post action menu |
| Activity feed comments | Report option in comment context menu |
| Watch party chat messages | Report option on long-press menu |
| Match chat messages | `_showMessageOptions` implemented with Report and Block options |
| Direct messages | Report option added to message long-press menu |
| User profiles | `ReportButton.user` in app bar actions (other users only) |

### Precaution 4: Blocking Abusive Users

**EXISTING:** `blockUser()` method in `SocialFriendService` creates block connections in Firestore, removes friendships, prevents messaging.

**NEW — Content Removal from Feed:**
- File: `lib/features/social/domain/services/activity_feed_service.dart`
- `getActivityFeed()` now queries blocked users in both directions (blocked by me + blocked me)
- Blocked user IDs removed from friend set before activity queries
- Final `removeWhere` filter ensures no blocked user content appears in results
- Effect is **instant** — blocked user's posts/comments disappear immediately from feed

**NEW — Developer Notification on Block:**
- File: `lib/features/social/domain/services/social_friend_service.dart`
- `blockUser()` now creates a document in the `reports` collection with `isBlockAction: true`
- This triggers the existing `onReportCreated` Cloud Function which sends push notifications to all admin users
- Admins are notified within seconds of any block action

### Precaution 5: Developer Acts on Reports Within 24 Hours

**EXISTING — Automated System:**

| Component | Function |
|-----------|----------|
| `onReportCreated` Cloud Function | Sends FCM push notifications to all admin users immediately when a report is submitted |
| Auto-moderation thresholds | 5 reports → automatic 24-hour mute; 10 reports → automatic 7-day suspension |
| `clearExpiredSanctions` | Scheduled hourly function that expires mutes and suspensions |
| `resolveReport` | HTTP callable for admins to take manual action |
| In-app notifications | Sanctioned users receive push + in-app notification |

**FIXED — Report Count Increment:**
- **Problem:** Client-side `_incrementReportCount()` in `ModerationReportService` was writing to `user_moderation_status` collection, but Firestore rules only allowed admin writes — meaning the write silently failed and auto-moderation thresholds never triggered.
- **Fix:** Removed client-side increment. Added server-side increment in `onReportCreated` Cloud Function using Admin SDK (bypasses Firestore rules). Report counts now properly increment, and auto-moderation thresholds (5 reports = mute, 10 = suspend) are now functional.

---

## Files Changed Summary

### Dart Source Code (8 files)
| File | Changes |
|------|---------|
| `lib/app.dart` | Added terms acceptance check in AuthenticationWrapper |
| `lib/features/auth/presentation/screens/terms_acceptance_screen.dart` | **NEW** — Terms acceptance screen |
| `lib/features/moderation/domain/services/moderation_report_service.dart` | Removed broken client-side report count increment |
| `lib/features/social/domain/services/activity_feed_service.dart` | Added blocked user filtering + profanity filtering |
| `lib/features/social/domain/services/social_friend_service.dart` | Added admin notification on block |
| `lib/features/social/presentation/widgets/activity_feed_item_widget.dart` | Added ReportButton |
| `lib/features/watch_party/presentation/widgets/watch_party_chat_message.dart` | Added report on long-press |
| `lib/features/match_chat/presentation/widgets/match_chat_message_item.dart` | Implemented _showMessageOptions with Report/Block |
| `lib/features/messaging/presentation/widgets/message_item_widget.dart` | Added report to message options |
| `lib/features/social/presentation/screens/user_profile_screen.dart` | Added ReportButton.user to app bar |

### Localization (4 ARB + 4 generated)
- `app_en.arb`, `app_es.arb`, `app_fr.arb`, `app_pt.arb` — "FIFA Ranking" → "World Ranking"
- All 4 generated `app_localizations_*.dart` files regenerated

### Dart Widget (1 file)
- `team_sort_chips.dart` — Hardcoded "FIFA Ranking" → "World Ranking"

### Cloud Functions (1 file)
- `functions/src/moderation-notifications.ts` — Added server-side report count increment in `onReportCreated`

### JSON Data (194 files)
- All user-visible "FIFA" references replaced across match summaries, head-to-head, recent form, history, player profiles, managers, team history, betting odds, ELO ratings, confederation records, historical patterns, venue factors, qualifying campaigns, tactical profiles, squad values

---

## Testing & Verification

### Static Analysis
```
flutter analyze — No issues found
```

### FIFA Audit
- Zero user-visible "FIFA" references remain in Dart source (only legal disclaimer)
- Zero user-visible "FIFA" references remain in JSON data files (only internal field keys and URLs)

### UGC Moderation Verification
- Terms acceptance screen renders correctly, stores timestamp, gates app access
- ReportButton accessible from all UGC surfaces (feed, chat, messages, profiles)
- Blocking removes content from feed instantly
- Blocking notifies admin via Cloud Function
- Profanity filter rejects objectionable activity posts and comments
- Report count increment now works server-side, enabling auto-moderation thresholds

---

## Screen Recording Instructions for Apple

Apple requires a screen recording on a physical device demonstrating:

1. **EULA acceptance flow**: Create new account → verify email → see Terms screen → scroll through terms → tap "I Agree" → enter app
2. **Flagging objectionable content**: Navigate to activity feed → long-press a post → tap "Report" → select reason → submit
3. **Blocking abusive users**: Navigate to a user profile → tap Report button → OR navigate to messages → long-press message → "Block User"

Record on a physical iPad or iPhone and attach to App Review Information in App Store Connect.

---

## App Review Notes (for App Store Connect)

Pregame is an independent fan community app for the 2026 World Cup. This update addresses Guideline 5.2.1 (FIFA IP) and Guideline 1.2 (UGC moderation):

**FIFA IP (5.2.1):** We have comprehensively removed all FIFA trademark references from user-visible content across 200+ files. The only remaining "FIFA" reference is our legal disclaimer explicitly stating non-affiliation. We do not have FIFA authorization and have removed all third-party content.

**UGC Moderation (1.2):** We have implemented all five required precautions:
1. Mandatory EULA/Terms acceptance screen with zero-tolerance policy (shown before app access)
2. Automated profanity filtering on all user content (posts, comments, messages, chat)
3. Report/flag functionality on every UGC surface (feed, chat, messages, profiles)
4. User blocking that instantly removes content from feed and notifies developer
5. Admin notification system with auto-moderation (5 reports = mute, 10 = suspend)

A screen recording demonstrating the EULA, reporting, and blocking flows is attached.

Demo account: [provide credentials in App Store Connect]

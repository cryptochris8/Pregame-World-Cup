# Pregame World Cup 2026 - Full Codebase Analysis

**Date:** February 20, 2026
**Analyst:** Claude Code (5 parallel agents)

---

## Project At A Glance

| Metric | Value |
|--------|-------|
| **Flutter Dart files** | 540 (421 in features, ~19,800 LOC) |
| **Cloud Functions** | 38 TypeScript files, 40+ exported functions |
| **Feature modules** | 17 active under `lib/features/` |
| **JSON data assets** | 301 files across 8 categories |
| **Test files** | 103 Flutter + 12 backend (427 Jest tests passing) |
| **Test coverage** | ~15% (up from 6%) |
| **Languages** | 4 (EN, ES, FR, PT - 1,078+ strings) |
| **Documentation** | 13 docs covering legal, setup, checklists |

---

## Architecture Assessment: 8/10

**Strengths:**
- Clean Architecture with strict domain/data/presentation layers per feature
- BLoC/Cubit state management (15+ cubits, properly using Factory vs Singleton)
- GetIt DI with 16-step staged initialization and fallback handling
- Barrel exports per feature for clean imports
- Zero analyzer warnings (technical debt actively addressed over 11 rounds)
- No TODO/FIXME/HACK comments in Flutter code

**Concerns:**
- 7 overlapping AI services need consolidation
- Some widgets over 500 lines (max 3,898-line widget, being refactored)
- Chatbot still rule-based (40% complete, needs real AI backend)

---

## Feature Completeness

| Feature | Files | Completeness | Status |
|---------|-------|-------------|--------|
| **worldcup** | 100+ | 95% | Core feature, 8 cubits, AI predictions |
| **schedule** | 40+ | 90% | Live scores (30s), ESPN integration |
| **navigation** | 1 | 90% | 6-tab bottom nav with badges |
| **social** | 40+ | 85% | Activity feed, friends, profiles |
| **recommendations** | 20+ | 85% | Google Places, AI venue discovery |
| **match_chat** | 8 | 85% | Real-time Firestore, reactions |
| **venues** | 30+ | 80% | Maps, photos, reviews, hours |
| **venue_portal** | 27+ | 80% | Owner dashboard, broadcasting |
| **messaging** | 40+ | 80% | DMs/groups, voice, files, search |
| **moderation** | 11 | 75% | Reports, profanity filter, auto-sanctions |
| **watch_party** | 30+ | 75% | Create/discover, payments, real-time chat |
| **settings** | 4 | 75% | Language, notifications, accessibility |
| **admin** | 9 | 70% | Users, moderation, feature flags |
| **auth** | 4 | 70% | Firebase Auth, email verification |
| **sharing** | 5 | 65% | Social sharing, deep links |
| **calendar** | 5 | 60% | Device calendar export, iCal |
| **chatbot** | 5 | 40% | Rule-based only, needs AI backend |

---

## Cloud Functions Backend: 85% Ready

- **40+ deployed functions** across payments, notifications, data sync, venue discovery
- **Stripe payment system**: 3 webhook endpoints, lazy initialization (v2 Cloud Run fix), idempotency helpers
- **All 427 backend tests passing** (10 Jest test suites)
- **TypeScript compiles cleanly** with strict mode
- Price tiers: Fan Pass $14.99, Superfan $29.99, Venue Premium $99
- Rate limiting implemented on HTTP functions
- Only issue: `getNearbyVenuesHttp` has PLACES_API_KEY conflict

### Function Categories

| Category | Count | Status |
|----------|-------|--------|
| Stripe Payment | 7 functions | Deployed, tested |
| World Cup Payment | 8 functions | Deployed, tested |
| Watch Party Payment | 5 functions | Deployed, tested |
| Notifications | 12 functions | Deployed, tested |
| Venue Discovery | 2 functions | Deployed (1 conflict) |
| Schedule Sync | 5 functions | Deployed |
| SportsData | 2 functions | Deployed |
| Moderation | 3 functions | Deployed, tested |

---

## Data Completeness: 95%

| Data | Count | Status |
|------|-------|--------|
| Matches | 104/104 | 100% |
| Teams | 48/48 | 100% |
| Venues | 16/16 | 100% |
| Managers | 48/48 | 100% |
| Match Summaries | 126 templates | 100% |
| WC History | 22 tournaments | 100% |
| Head-to-Head | 49 matchups | 85% |
| Player Squads | 44/48 | 92% (4 missing) |

---

## Security Assessment: CRITICAL ISSUES

### Secrets Exposed in Git

| File | Contents | Severity |
|------|----------|----------|
| `service-account-key.json` | Full Firebase Admin SDK private key | **CRITICAL** |
| `functions/.env.pregame-b089e` | Stripe LIVE secret key, Places API key, SportsData key | **CRITICAL** |
| `android/key.properties` | Keystore passwords in plaintext | **HIGH** |
| `android/upload-keystore.jks` | Android signing keystore binary | **HIGH** |

**The `service-account-key.json` is in `.gitignore` but exists in the repo root.** The `.env.pregame-b089e` file is NOT properly gitignored (functions/.gitignore only ignores `*.local`).

**Required Actions:**
1. Rotate all exposed keys (Firebase service account, Stripe live key, Android signing key)
2. Purge secrets from git history using `git filter-repo`
3. Fix `.gitignore` to properly exclude all secret files
4. Add pre-commit hooks to prevent re-exposure

### Firestore Rules: Strong (547 lines)
- Default deny architecture, 45+ collections explicitly defined
- All collections require authentication
- Proper admin/owner checks throughout
- **Minor issues**: `match_chats` too permissive (any auth user), typo `usualId` in sanctions rule

### Storage Rules: Good
- Path-based with size limits (5MB profile, 10MB chat/party)
- Type restrictions enforced
- Chat/party media lacks membership verification (documented, app-layer enforced)

---

## Test Coverage: 15%

### By Layer

| Layer | Tests | Coverage | Status |
|-------|-------|----------|--------|
| Domain - Entities | 31 | 62% | Good |
| Presentation - Cubits | 9 of 17+ | 50% | Medium |
| Core - Utilities | 9 | 30% | Medium |
| Domain - Services | 6 of 20+ | 30% | Critical Gap |
| Backend Functions | 12 suites | 40% | Medium |
| Presentation - Widgets | 26 of 200+ | 13% | Low |
| Presentation - Screens | 3 of 15+ | 20% | Critical Gap |
| Data - Repositories | 0 | 0% | Critical Gap |
| Integration | 2 flows | ~1% | Critical Gap |

### Untested Critical Services (16 total)
- All messaging services (4 services)
- `watch_party_service`, `chatbot_service`, `match_chat_service`
- All AI services (`world_cup_ai_service`, `nearby_venues_service`, `match_reminder_service`)
- `activity_feed_service`, `admin_service`, `venue_enhancement_service`

### Backend Tests: Strong Where They Exist
- 427 tests passing across 10 Jest suites
- Comprehensive payment webhook testing with idempotency
- Notification function tests with FCM mocking
- **Gaps**: Schedule sync, admin functions, venue portal, seed scripts

---

## Payment System Status

| Component | iOS | Android |
|-----------|-----|---------|
| **Stripe** | Working | Working |
| **RevenueCat** | Fully configured | NOT configured |
| **Webhooks** | 3 endpoints active | Same endpoints |
| **E2E tested** | No | No |

Android falls back to Stripe browser checkout without RevenueCat - poor UX and potential Play Store rejection risk.

### Price Configuration
- Fan Pass: $14.99 (`price_1SnYT9LmA106gMF6SK1oDaWE`)
- Superfan Pass: $29.99 (`price_1SnYi4LmA106gMF6h5yRgzLL`)
- Venue Premium: $99 (`price_1SnYm5LmA106gMF63sYAuEB5`) - Stripe only (B2B)

---

## CI/CD: Solid

| Workflow | Trigger | Instance | Status |
|----------|---------|----------|--------|
| Test | PR/push | Linux x2 | Functions tests + Flutter analyze + Flutter test |
| iOS | Push to main | Mac Mini M1 | Build IPA -> TestFlight |
| Android | Push to main | Linux x2 | Build APK+AAB -> Play Store internal |

- All API keys injected via Codemagic vault with dart-defines
- RevenueCat keys added to build commands (fixed Feb 19)
- Email notifications on failure

---

## Overall Launch Readiness

| Component | Ready | Risk |
|-----------|-------|------|
| iOS App | 85% | Low |
| Android App | 60% | High |
| Payment System | 70% | Medium |
| Cloud Functions | 80% | Low |
| Data Completeness | 95% | Low |
| Security | 40% | **CRITICAL** |
| Test Coverage | 15% | Medium |
| Legal/Compliance | 85% | Low |
| CI/CD | 90% | Low |
| Localization | 95% | Low |

---

## Success Probability: 70-75%

This assumes the critical security fixes and Android RevenueCat setup are completed within the next 2 weeks. The probability drops to **50-55%** if secrets remain exposed in git.

---

## Top 5 Priorities (In Order)

1. **Fix security vulnerabilities NOW** - Rotate all exposed keys (Firebase service account, Stripe live key, Android signing key), purge from git history, fix `.gitignore`
2. **Complete Android RevenueCat setup** - Create Play Store products, configure RevenueCat, test native IAP (~3-5 hours)
3. **E2E payment testing** - Test complete Stripe + RevenueCat flows on both platforms
4. **Complete 4 remaining player squads** - Source from FIFA.com/Transfermarkt
5. **Load testing** - Simulate World Cup match-day traffic before June 11

---

## Recommended Launch Timeline

### Week 1 (Feb 19-26): CRITICAL FIXES
- [ ] Fix security: Remove secrets from git, rotate keys
- [ ] Complete Android RevenueCat setup
- [ ] Complete 4 missing player squads
- [ ] Configure deep link domain validation

### Week 2-3 (Feb 27-Mar 12): QA & TESTING
- [ ] E2E payment testing (all flows)
- [ ] Internal testing on physical devices
- [ ] Beta tester signups and feedback
- [ ] Security audit and penetration testing

### Week 4-6 (Mar 13-27): OPTIMIZATION & LAUNCH PREP
- [ ] Load testing and performance optimization
- [ ] Admin dashboard final setup
- [ ] Marketing materials and press kit
- [ ] App Store/Play Store listing finalization

### Week 7-10 (Mar 28-Apr 25): SUBMISSION & REVIEW
- [ ] Submit to App Store (4-6 weeks before June 11)
- [ ] Submit to Play Store
- [ ] Prepare for editorial review
- [ ] Set up monitoring and on-call rotation

### Week 11-16 (Apr 26-Jun 10): FINAL PREP & SOFT LAUNCH
- [ ] Address App Store/Play Store review feedback
- [ ] Soft launch to limited regions
- [ ] Scale up infrastructure
- [ ] Final monitoring setup

### Feature Freeze: April 15, 2026 (recommended)

---

## Bottom Line

The codebase is well-architected and feature-rich with strong development velocity (30 commits in 30 days, 11 technical debt rounds). The critical blocker is **security** - exposed production secrets must be rotated immediately. Once that's resolved, Android payment setup and E2E testing are the remaining gaps. With 4 months to launch, the timeline is achievable with focused execution.

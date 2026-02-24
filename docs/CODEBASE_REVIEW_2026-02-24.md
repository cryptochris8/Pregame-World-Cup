# Pregame World Cup 2026 - Full Codebase Review
## Date: February 24, 2026 | Overall Status: ~78% Launch-Ready | 107 days to tournament

---

## 1. WHAT WE HAVE (The Good)

### Flutter App (7.5/10)
- Solid clean architecture across 17 feature modules with BLoC/Cubit state management
- 355+ Dart files with proper domain/data/presentation separation
- Local prediction engine (726 lines) - fully offline AI predictions using 9 data factors
- Local knowledge chatbot - replaced API-dependent chatbot with rule-based local engine (249 tests)
- 15-step staged dependency injection with graceful error recovery
- Material 3 dark theme with high-contrast accessibility mode
- 4-language localization (EN, ES, FR, PT) with 1,078+ strings
- 6-tab navigation with badge system

### Cloud Functions Backend (7/10)
- 40+ functions organized by domain (payments, notifications, moderation, seeding)
- 3 payment systems: Stripe core, World Cup passes (Fan $14.99/Superfan $29.99/Venue $499), watch party virtual attendance ($9.99)
- Stripe webhook idempotency, signature verification, server-side price enforcement
- Firestore-based distributed rate limiting (works across instances)
- Transaction-safe venue claiming with SMS verification (Twilio)
- Auto-moderation (5 reports = mute, 10 = suspension)
- 12 backend test suites with comprehensive mocks

### Data Assets (98% - Excellent)
- 104/104 matches (72 group + 32 knockout) - all kickoff times verified
- 48/48 teams with full 26-player squads (1,248 players total)
- 48/48 managers with tactics, formation, history
- 16/16 venues with capacities, coords, transit, weather
- 49 H2H matchup files, 22 World Cup history records
- 6 enhanced data files: squad values, betting odds, historical patterns, confederation records, injury tracker, recent form
- 126+ pre-written match summaries
- Zero legacy college football assets remaining

### CI/CD Pipeline (Codemagic)
- 3 workflows: test (PR/push), iOS (TestFlight), Android (Play Store internal)
- API keys injected via Codemagic vault
- All builds run tests before deploying

### React Web Portal (35% Complete)
- 37 TypeScript/TSX files, venue owner portal at MVP stage
- Venue signup wizard (5-step), profile editing, Stripe subscription UI
- Needs: auth flow, route guards, error boundaries, TypeScript strict mode

---

## 2. CRITICAL ISSUES

### Security - BLOCKERS

| # | Issue | Location | Severity |
|---|-------|----------|----------|
| 1 | Android keystore password in git history (`storePassword=Arlo0844!`) | `android/key.properties` | CRITICAL |
| 2 | Firebase service account private key in git history | `service-account-key.json` | CRITICAL |
| 3 | Hardcoded Firebase API key in React portal | `src/firebase/firebaseConfig.ts` | HIGH |
| 4 | Seed functions have NO auth checks - anyone can trigger Firestore writes | `functions/src/index.ts` | CRITICAL |
| 5 | No rate limiting on payment checkout functions | `stripe-simple.ts`, `world-cup-payments.ts` | HIGH |
| 6 | Chat Firestore rules too permissive - any auth user can read/write ALL chats | `firestore.rules:256` | HIGH |

### Code Quality - HIGH Priority

| # | Issue | Location |
|---|-------|----------|
| 7 | 4 dead AI service files still in codebase (~500 lines) | `lib/core/ai/services/` |
| 8 | 7 overlapping AI services need consolidation | `injection_container.dart` |
| 9 | Monolithic DI container (705 lines, 16 functions) | `lib/injection_container.dart` |
| 10 | `getNearbyVenuesHttp` broken - PLACES_API_KEY conflict | `functions/src/index.ts` |
| 11 | `enhanced_ai_insights_widget.dart` is 3,898 lines with 40+ build methods | `lib/features/worldcup/` |
| 12 | Legal docs still reference 2025 dates | `docs/PRIVACY_POLICY.md`, `TERMS_OF_SERVICE.md` |

---

## 3. TEST COVERAGE (~15%)

| Area | Files | Coverage | Quality |
|------|-------|----------|---------|
| Flutter unit tests | 141 | ~15% | Good BLoC/entity tests, shallow widget tests |
| Backend unit tests | 12 | ~40% of functions | Excellent mock patterns, comprehensive payment tests |
| Integration tests | 2 | Minimal | Mocked Firebase, not true e2e |
| **Major gaps** | | | Data layer (0%), payments Flutter-side (0%), AI services (0%) |

---

## 4. FEATURE MODULE STATUS

| Feature | Completeness | Notes |
|---------|-------------|-------|
| worldcup | 95% | Core: matches, groups, brackets, teams, predictions, 8 cubits |
| schedule | 90% | Live scores (30s refresh), filtering, AI insights |
| navigation | 90% | 6-tab bottom nav with badges |
| social | 85% | Activity feed, friends, profiles, badges |
| recommendations | 85% | Google Places, AI venue discovery, geocoding |
| match_chat | 85% | Real-time Firestore, reactions, rate-limited |
| venues | 80% | Details, maps, photos, reviews, hours |
| venue_portal | 80% | Owner dashboard: broadcasting, specials, capacity |
| messaging | 80% | DMs/groups, voice, files, search, admin tools |
| moderation | 75% | Reports, profanity filter, auto-mute/suspend/ban |
| watch_party | 75% | Create/discover parties, venue selection, payments |
| settings | 75% | Notifications, language, accessibility |
| admin | 70% | Users, moderation, feature flags, broadcasts |
| auth | 70% | Firebase Auth, email verification, onboarding |
| sharing | 65% | Social sharing, deep links |
| calendar | 60% | Device calendar export, iCal |
| chatbot | 40% | Local knowledge engine, needs real AI integration |

---

## 5. RECENT WORK (Feb 22-24, 2026)

### Last Focus Areas:
1. **Eliminating external API dependencies** (per API key policy):
   - Built LocalPredictionEngine - generates predictions from local JSON
   - Replaced chatbot with LocalKnowledgeEngine - 249 tests, no Claude/OpenAI calls
   - All pre-tournament features now use LOCAL DATA ONLY

2. **Testing push**:
   - Added 11,335 lines of new tests across 23 files
   - Fixed 23 failing tests (mock, pricing, case, currency)
   - Cleaned up 51 analyzer warnings
   - Test count: ~1,575 to ~1,900+

### Uncommitted Changes (now committed):
- `.gitignore` - adding `functions/coverage/`
- `admin_service.dart` - `@visibleForTesting resetInstance()` for test isolation
- `AddressAutocomplete.tsx` - security fix: replaced hardcoded Google API key with env var

---

## 6. PRIORITIZED ROADMAP TO LAUNCH

### Phase 1: Security Hardening (This Week)
- [ ] Rotate Android keystore & Firebase service account key
- [ ] Add auth guards to seed functions
- [ ] Add rate limiting to payment functions
- [ ] Fix chat Firestore rules (check participantIds)
- [ ] Move Firebase API key to env vars in React portal

### Phase 2: Code Cleanup (Week 2)
- [ ] Delete 4 dead AI service files
- [ ] Remove/archive legacy SportsData college football code
- [ ] Fix `getNearbyVenuesHttp` API key conflict
- [ ] Update legal docs 2025 to 2026
- [ ] Commit uncommitted changes

### Phase 3: Testing (Weeks 3-4)
- [ ] Add data layer repository tests (40+ tests needed)
- [ ] Add payment e2e flow tests (Flutter side)
- [ ] Add notification function backend tests
- [ ] Enable coverage thresholds in CI (40% minimum)
- [ ] Add error handling negative test cases

### Phase 4: Performance & Polish (Weeks 5-8)
- [ ] Reduce sendMatchReminders from 1-min to 5-min or event-driven
- [ ] Consolidate 7 AI services into unified facade
- [ ] Refactor enhanced_ai_insights_widget.dart (3,898 lines into 10 widgets)
- [ ] Split injection_container.dart into feature-specific files
- [ ] Add retry logic for FCM/SMS/Stripe transient failures

### Phase 5: Store Submission (Weeks 8-12)
- [ ] Android: Play Store listing + RevenueCat setup
- [ ] Payment end-to-end testing (Stripe test mode)
- [ ] Load testing notification system (100k+ users)
- [ ] Fill TBD playoff qualifiers as they finalize
- [ ] Update recent_form/ data through June 10
- [ ] Launch X/Twitter marketing campaign (14 posts ready)

### Phase 6: Tournament Go-Live (Week of June 11)
- [ ] Enable SportsData.io API for live scores
- [ ] Activate live match score refresh (30s intervals)
- [ ] Monitor Cloud Function costs and scaling
- [ ] Go live on App Store + Play Store

---

## 7. KEY METRICS

| Metric | Current | Target for Launch |
|--------|---------|-------------------|
| Flutter app completeness | 78% | 90%+ |
| Cloud Functions maturity | 70% | 85%+ |
| React portal completeness | 35% | 50%+ (venue portal only) |
| Data completeness | 98% | 100% |
| Test coverage | 15% | 40%+ |
| Security posture | 60% (secrets leaked) | 95%+ |
| Features complete | 14/17 | 16/17 |

---

## 8. DEAD CODE TO DELETE

- `lib/core/ai/services/enhanced_ai_prediction_service.dart`
- `lib/core/ai/services/enhanced_game_summary_service.dart`
- `lib/core/ai/services/enhanced_player_service.dart`
- `lib/core/ai/services/claude_sports_integration_service.dart`
- Legacy SportsData college football code in `functions/src/sportsdata-service.ts`
- Legacy test SDK functions in `functions/src/index.ts`

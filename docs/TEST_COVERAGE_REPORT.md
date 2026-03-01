# Test Coverage Report - Pregame World Cup 2026

**Date**: March 1, 2026
**Status**: All tests passing

---

## Summary

| Metric | Count |
|--------|-------|
| Flutter test files | 246 |
| Flutter test cases | 7,542 |
| Backend test suites | 24 |
| Backend test cases | 813 |
| **Total tests** | **8,355** |
| **Failures** | **0** |

Coverage improved from ~28% to ~55%+ across 5 waves of parallel test writing using 20+ concurrent agents.

---

## Test Creation Waves

### Wave 1: Service Tests (~893 new tests)

| Test File | Tests | Feature |
|-----------|-------|---------|
| `watch_party_service_test.dart` | ~40 | Watch Party entity/business logic |
| `watch_party_chat_service_test.dart` | ~30 | Watch Party chat |
| `watch_party_invite_service_test.dart` | ~30 | Watch Party invites |
| `watch_party_member_service_test.dart` | ~30 | Watch Party members |
| `watch_party_payment_service_test.dart` | 24 | Watch Party payments + widgets |
| `social_data_mappers_test.dart` | 28 | Social data mapping |
| `social_profile_service_test.dart` | 27 | Social profiles |
| `social_friend_service_test.dart` | 46 | Social friends |
| `activity_feed_service_test.dart` | 39 | Activity feed |
| `notification_service_test.dart` | 50 | Social notifications |
| `messaging_service_test.dart` | 20 | Messaging |
| `messaging_serialization_test.dart` | 23 | Message serialization |
| `file_upload_service_test.dart` | 28 | File upload |
| `voice_recording_service_test.dart` | 36 | Voice recording |
| `moderation_action_service_test.dart` | 49 | Moderation actions |
| `moderation_report_service_test.dart` | 33 | Moderation reports |
| `venue_enhancement_service_test.dart` | 66 | Venue enhancement service |
| `places_api_datasource_test.dart` | 31 | Places API datasource |
| `places_repository_impl_test.dart` | 16 | Places repository |
| `schedule_datasources_test.dart` | 62 | Live scores + ESPN datasource |
| `match_reminder_service_test.dart` | 36 | Match reminders |
| `world_cup_ai_service_test.dart` | 31 | World Cup AI service |
| `seed-utils.test.ts` (backend) | 48 | Backend seed utilities |

### Wave 2: Cubits, AI Services, Entities (~661 new tests)

| Test File | Tests | Feature |
|-----------|-------|---------|
| `rate_limit_service_test.dart` | 23 | Rate limiting |
| `ai_fallback_helpers_test.dart` | 46 | AI fallback logic |
| `ai_venue_fallback_helpers_test.dart` | 45 | AI venue fallbacks |
| `team_season_stats_generator_test.dart` | 51 | Stats generation |
| `world_cup_ai_cubit_test.dart` | ~70 | AI prediction cubit |
| `venue_enhancement_cubit_test.dart` | ~31 | Venue enhancement cubit |
| `team_season_narrative_service_test.dart` | 39 | Season narratives |
| `multi_provider_ai_service_test.dart` | 29 | Multi-provider AI |
| `ai_historical_knowledge_service_test.dart` | 21 | Historical knowledge |
| `enhanced_ai_game_analysis_service_test.dart` | 32 | Enhanced game analysis |
| `ai_team_season_summary_service_test.dart` | 60 | Season summaries |
| `flag_utils_test.dart` | 26 | FIFA-to-ISO flag mapping |
| `world_cup_match_extensions_test.dart` | 65 | Match extensions/parsing |
| `ai_match_prediction_test.dart` | 38 | AI prediction entity |
| `match_chat_entities_test.dart` | 34 | Match chat entities |
| `venue_claim_info_test.dart` | 26 | Venue claim entity |
| `typing_indicator_test.dart` | 25 | Typing indicator entity |
| `profanity_filter_service_test.dart` | ~80 | Content moderation |

### Wave 3: Core Utilities, Preferences, Config (~812 new tests)

| Test File | Tests | Feature |
|-----------|-------|---------|
| `team_mapping_service_test.dart` | 39 | Team mapping service |
| `logging_service_test.dart` | 28 | Logging service |
| `performance_monitor_test.dart` | 35 | Performance monitoring |
| `timezone_utils_test.dart` | 57 | Timezone utilities |
| `localization_service_test.dart` | 42 | Localization service |
| `accessibility_service_test.dart` | 44 | Accessibility settings |
| `notification_preferences_service_test.dart` | 38 | Notification preferences |
| `offline_service_test.dart` | 51 | Offline/connectivity |
| `payment_models_test.dart` | 83 | Payment models/enums |
| `venue_models_test.dart` | 25 | Venue models |
| `api_keys_test.dart` | 15 | API key config |
| `app_theme_test.dart` | 131 | App theme (colors, gradients, decorations) |
| `theme_helper_test.dart` | 45 | Theme helper utilities |
| `watch_party_bloc_test.dart` | 73 | Watch party bloc |
| `deep_link_navigator_test.dart` | 18 | Deep link navigation |
| `deep_link_service_test.dart` | 40 | Deep link service |
| `favorite-team-notifications.test.ts` | 18 | Backend favorite team notifications |
| `http-functions.test.ts` | 30 | Backend HTTP functions |

### Wave 4: DI, Venue Services, Payments, Core, Backend Seeding (~941 new tests)

| Test File | Tests | Feature |
|-----------|-------|---------|
| `core_di_test.dart` | 11 | Core DI module |
| `ai_di_test.dart` | 12 | AI DI module |
| `data_services_di_test.dart` | 10 | Data services DI module |
| `recommendations_di_test.dart` | 9 | Recommendations DI module |
| `social_di_test.dart` | 11 | Social DI module |
| `worldcup_di_test.dart` | 54 | World Cup DI module |
| `watch_party_di_test.dart` | 8 | Watch party DI module |
| `moderation_admin_di_test.dart` | 10 | Moderation/admin DI module |
| `extended_features_di_test.dart` | 12 | Extended features DI module |
| `injection_container_test.dart` | 4 | DI orchestrator |
| `venue_scoring_service_test.dart` | 67 | Venue scoring algorithms |
| `venue_ai_analysis_service_test.dart` | 17 | Venue AI analysis |
| `smart_venue_recommendation_service_test.dart` | 16 | Smart venue recommendations |
| `unified_venue_service_test.dart` | 43 | Unified venue categorization |
| `venue_photo_service_test.dart` | 32 | Venue photo caching |
| `google_places_photo_service_test.dart` | 38 | Google Places photos |
| `payment_access_service_test.dart` | 29 | Payment access control |
| `payment_checkout_service_test.dart` | 18 | Payment checkout |
| `payment_history_service_test.dart` | 32 | Payment history |
| `world_cup_payment_facade_test.dart` | 20 | Payment facade |
| `payment_service_test.dart` | 42 | Payment utilities + widget |
| `revenuecat_service_test.dart` | 27 | RevenueCat integration |
| `zapier_service_test.dart` | 21 | Zapier automation |
| `analytics_service_test.dart` | 74 | Analytics events/properties |
| `ad_service_test.dart` | 12 | Ad unit IDs |
| `push_notification_service_test.dart` | 20 | Push notifications |
| `presence_service_test.dart` | 15 | Online/offline presence |
| `route_service_test.dart` | 50 | Route/walking calculations |
| `user_learning_service_test.dart` | 16 | User learning models |
| `lifecycle_helper_test.dart` | 33 | Widget lifecycle utilities |
| `historical_game_analysis_service_test.dart` | 28 | Historical analysis |
| `quick_fixes_service_test.dart` | 19 | Quick fixes utility |
| `ai_performance_config_test.dart` | 45 | AI performance config |
| `seed-head-to-head.test.ts` | 8 | Backend H2H seeding |
| `seed-june2026-matches.test.ts` | 9 | Backend June matches seeding |
| `seed-knockout-matches.test.ts` | 9 | Backend knockout seeding |
| `seed-managers.test.ts` | 11 | Backend managers seeding |
| `seed-match-summaries.test.ts` | 11 | Backend match summaries seeding |
| `seed-player-world-cup-stats.test.ts` | 9 | Backend player stats seeding |
| `seed-team-players.test.ts` | 20 | Backend team players seeding |
| `seed-venue-enhancements.test.ts` | 16 | Backend venue enhancements seeding |
| `seed-world-cup-history.test.ts` | 13 | Backend WC history seeding |

### Wave 5: Final Gaps (~166 new tests)

| Test File | Tests | Feature |
|-----------|-------|---------|
| `cache_service_test.dart` | 62 | Hive-based caching (venue, geocoding, generic) |
| `firebase_app_check_service_test.dart` | 18 | Firebase App Check |
| `page_transitions_test.dart` | 44 | Custom page transitions (slide, scale, circular reveal) |
| `banner_ad_widget_test.dart` | 42 | AdMob banner widget + ScreenWithBannerAd |

---

## What Is Tested

### Domain Entities
WorldCupMatch, NationalTeam, Group, Bracket, MatchPrediction, MatchReminder, Player, Manager, UserProfile, WatchParty, Place, VenueFilter, Chat/Message, AIMatchPrediction, VenueClaimInfo, TypingIndicator, MatchChatEntities, PaymentTransaction, FanPassStatus, VenuePremiumStatus, UserInsights, GameRecommendation, QueuedAction, SyncStatus, NotificationPreferencesData, AccessibilitySettings, RouteData, WalkingPreferences

### BLoC/Cubits (16 total)
MatchListCubit, FavoritesCubit, PredictionsCubit, GroupStandingsCubit, BracketCubit, VenueFilterCubit, TeamsCubit, NearbyVenuesCubit, MatchChatCubit, WorldCupAICubit, VenueEnhancementCubit, ChatbotCubit, ScheduleBloc, VenueOnboardingCubit, WatchPartyBloc

### Services
- **Watch Party**: 5 services (core, chat, invite, member, payment)
- **Social**: 5 services (data mappers, profile, friend, activity feed, notifications)
- **Messaging**: 4 services (messaging, serialization, file upload, voice recording)
- **Moderation**: 2 services (actions, reports) + profanity filter
- **Venue**: 6 services (scoring, AI analysis, smart recommendation, unified, photo, Google Places photo)
- **Payment**: 7 services (access, checkout, history, facade, utilities, RevenueCat, Zapier)
- **AI**: 5 services (multi-provider, historical knowledge, enhanced analysis, season summary, season narrative)
- **Core**: 12+ services (analytics, ads, push notifications, presence, routes, user learning, lifecycle, cache, logging, performance monitor, team mapping, rate limit)

### DI Modules (10 total)
All 9 feature modules under `lib/di/` + orchestrator (`injection_container.dart`)

### Config
ApiKeys, AppTheme, ThemeHelper, AIPerformanceConfig

### Utilities
FlagUtils, TimezoneUtils, LifecycleHelper, TeamMapping, Logging, PerformanceMonitor, DeepLinkService, DeepLinkNavigator, PageTransitions

### Data Layer
CacheDatasource, FirestoreDatasource, BracketRepo, PredictionsRepo, UserPrefsRepo, MatchRepo, ScheduleRepo, PlacesRepo, SocialDatasource, LocalPredictionEngine, ESPNScheduleDatasource, LiveScoresDatasource

### Widgets
FriendItem, FriendRequestItem, SocialStatsCard, MatchCard, TeamTile, TeamFlag, LiveBadge, BracketMatchCard, StandingsTable, VenueFilterBar, EnhancedVenueCard, WatchPartyCard, VirtualAttendanceButton, QuickPaymentButton, BannerAdWidget, ScreenWithBannerAd

### Integration Tests
Match browsing flow, Predictions flow

### Backend (24 suites)
All Cloud Functions (stripe-config, match-reminders, watch-party-notifications, world-cup-payments, stripe-simple, watch-party-payments, favorite-team-notifications, HTTP functions), retry-utils, seed-utils, venue-disputes, profanity-filter, all 9 seeding scripts

---

## Remaining Gaps (Not Testable Without Major Refactoring)

| Category | Reason | File Count |
|----------|--------|------------|
| Screen/page widgets | Tightly coupled to Firebase initialization | ~100 |
| Authentication flows | Direct Firebase Auth dependency | ~5 |
| Firestore security rules | Requires Firebase emulator | 2 |
| ESPN API integration | External API dependency | ~6 |
| One-time backend scripts | Dev-only utilities, not production code | 13 |

These files would require either dependency injection refactoring, Firebase emulator setup, or external API mocking infrastructure that goes beyond unit testing.

---

## Test Infrastructure

| Tool | Purpose |
|------|---------|
| `flutter_test` | Flutter test framework |
| `mocktail` | Dart mocking library |
| `fake_cloud_firestore` | Firestore mocking |
| `bloc_test` | BLoC/Cubit testing |
| `hive_test` | Hive box testing |
| `SharedPreferences.setMockInitialValues` | SharedPreferences mocking |
| `Jest 29.7.0` | Backend test framework |
| `ts-jest` | TypeScript support for Jest |
| `firebase-functions-test` | Cloud Functions testing |
| Custom `firebase-admin.mock.ts` | Firebase Admin SDK mock |
| Custom `di_test_helpers.dart` | DI registration test utilities |

---

## Running Tests

### Flutter
```bash
# Run all tests
flutter test

# Run with compact output
flutter test --reporter compact

# Run a specific test file
flutter test test/core/services/cache_service_test.dart

# Run tests in a directory
flutter test test/di/
```

### Backend
```bash
cd functions

# Run all tests
npm test

# Run a specific test file
npx jest __tests__/seed-managers.test.ts
```

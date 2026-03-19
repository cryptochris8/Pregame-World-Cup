# Changelog

All notable changes to Pregame World Cup 2026 are documented in this file.

## [1.0.0] - 2026-03-14

Initial release for iOS App Store and Google Play Store.

### Features

#### Core World Cup Experience
- Full World Cup 2026 match schedule with all 104 matches across 16 venues
- All 48 qualified national teams with rosters, manager profiles, and team colors
- Multi-timezone support for match times with automatic local conversion
- Player Spotlight with detailed profiles, stats, and World Cup history
- Manager profiles with tactical information
- Head-to-head matchup previews with historical records
- Player comparison tool with side-by-side statistics
- Tournament leaderboards with World Cup statistics

#### AI & Predictions
- AI-powered match predictions with local prediction engine
- Elo ratings, Monte Carlo simulations, and venue factor analysis
- 24-hour Hive-cached match prediction persistence
- AI match summaries for all group stage matches
- Copa chatbot with gold trophy avatar, 1,376 player profiles, and natural language intents (squad value, recent form, player comparison, countdown, tournament facts)
- Local knowledge engine (no external API dependency)

#### Social & Community
- Real-time match chat with moderation
- Friends list with search, filtering, and friend management
- Activity feed with social interactions
- User profiles with online status indicators and presence tracking
- Push notifications for messages, friend requests, and match reminders
- Favorite team match notifications
- Read receipts for messages
- Block enforcement for messaging
- Group chat with member management
- Message features: mute, archive, delete, copy

#### Watch Parties
- Create and join Watch Parties for any match
- Game selector for watch parties
- Push notifications for watch party invites
- Virtual attendance support

#### Venues
- Nearby venue discovery with distance rings
- Venue detail screens with photos, ratings, and reviews
- Venue filtering (quality sit-down restaurants and bars)
- In-app venue navigation (instead of redirecting to Google Maps)
- AI-powered venue recommendations
- Route details with directions

#### Venue Portal (B2B)
- Venue owner onboarding flow
- Venue claim system with server-side verification
- Venue Premium subscription ($499) via Stripe
- Venue enhancement dashboard

#### Payments & Monetization
- Fan Pass with free and Superfan tiers
- RevenueCat integration for native in-app purchases (iOS/Android)
- Stripe integration for B2B Venue Premium
- iOS App Store payment compliance (digital goods via IAP only)
- Transaction history UI
- Premium feature gates for predictions and leaderboards
- AdMob ad integration
- Clearance list for complimentary Superfan Pass access

#### Calendar & Scheduling
- Calendar export for matches
- Week-based date picker for match filtering
- Add-to-calendar button for individual matches

#### Sharing
- Native share sheet integration
- Share buttons for matches and venues
- Deep linking with app_links

#### Localization
- Full localization in 4 languages: English, Spanish, French, Portuguese
- 400+ localized strings across all screens
- Localized venue portal (63 keys), chatbot, favorite teams, and all user-facing screens

#### Privacy & Security
- Sign in with Apple (iOS)
- Google Sign-In OAuth
- Email verification
- Privacy-first defaults (showRealName, showLocation, showOnlineStatus all off for new users)
- GDPR data export ("Download My Data" as JSON)
- Privacy Policy and Terms of Service links in-app
- Profanity filter with slur detection
- Content reporting and moderation
- Firebase App Check for API protection
- Rate limiting on API endpoints
- Firestore security rules
- Backend auth on HTTP endpoints

#### Offline & Performance
- Offline-first architecture with local JSON data assets
- Hive caching for schedule and predictions
- Cached network images
- Connectivity-aware data loading

#### Platform
- iOS home screen widget support
- Android home screen widget support
- Firebase Crashlytics for crash reporting
- Firebase Analytics for event tracking
- Codemagic CI/CD integration

### Data
- 48 national team rosters with accurate player profiles
- 11,335+ lines of comprehensive test data
- Historical head-to-head records
- Penalty records, top scorers, and squad files
- Team metadata, World Cup history, and confederation records
- Elo ratings, betting odds, injury tracker
- Recent form data with weighting

### Testing
- 7,771 tests passing (0 failures)
- Unit tests, widget tests, and integration tests
- Data layer, service, repository, and presentation tests
- 27.6% line coverage

### Technical Debt & Quality
- Zero static analyzer warnings
- Unified dependency injection via GetIt
- Service decomposition and widget refactoring
- Complete removal of legacy college football code (~3,200+ lines removed)
- Dead code cleanup (unused ESPN/venue widgets, unused dependencies)
- Global error handler

---

## Development Timeline

- **Dec 2025**: Initial commit, core app structure, team/player data, venue discovery
- **Jan 2026**: Watch parties, notifications, venue portal, payments, caching, leaderboards, player comparison, iOS prep, AdMob, RevenueCat
- **Feb 2026**: Security hardening (5 phases), technical debt reduction (11 rounds), college football removal, chatbot overhaul, prediction engine upgrades, data enrichment, comprehensive test suites
- **Mar 2026**: Google Sign-In, Sign in with Apple, App Store compliance, localization completion, final test fixes, data accuracy audit

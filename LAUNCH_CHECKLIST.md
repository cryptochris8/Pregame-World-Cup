# Pregame World Cup 2026 - Launch Checklist

## Project Status
- **Current Success Probability**: 65-75%
- **Target Success Probability**: 80-85%
- **World Cup Start Date**: June 11, 2026
- **Time Remaining**: ~5 months

---

## Critical (Must Have Before Launch)

### 1. Analytics & Crash Reporting
- [x] Add Firebase Analytics (firebase_analytics: ^11.3.6)
- [x] Integrate Firebase Crashlytics (firebase_crashlytics: ^4.1.6)
- [x] Track user engagement metrics (AnalyticsService with 50+ event types)
- [x] Track feature usage (screen views, actions, searches)
- [x] Track conversion rates (payment events, subscription tracking)
- [ ] Set up dashboards for monitoring (Firebase Console configuration)

### 2. Content Moderation
- [x] Report user functionality (lib/features/moderation/)
- [x] Block user functionality (already existed in SocialService)
- [x] Moderation queue for watch party descriptions (ModerationService + Cloud Functions)
- [x] Moderation queue for messages (ModerationService + Cloud Functions)
- [x] Automated profanity filtering (ProfanityFilterService - EN/ES/PT)
- [x] Review flagged content workflow (Cloud Functions: onReportCreated, resolveReport)

### 3. Admin Dashboard
- [ ] Web portal for admin access
- [x] User management (view, suspend, delete) - AdminUsersScreen
- [x] Watch party management - AdminWatchPartiesScreen
- [x] Content moderation interface - AdminModerationScreen
- [x] Feature flags for quick toggles - AdminFeatureFlagsScreen
- [ ] Manual match data corrections
- [x] Push notification sender - AdminNotificationsScreen

### 4. Push Notification Enhancements
- [x] Granular notification preferences screen (NotificationPreferencesScreen)
- [x] Match reminder timing options (15min, 30min, 1hr, 2hr, 1 day - ReminderTiming enum)
- [x] Goal alerts opt-in (goalAlertsEnabled, redCardAlertsEnabled, penaltyAlertsEnabled)
- [x] Favorite team notifications (favoriteTeamMatchesEnabled, favoriteTeamMatchDayBefore)
- [x] Watch party reminder notifications (watchPartyRemindersEnabled, watchPartyReminderTiming)
- [x] Live match alerts (matchStartAlertsEnabled, halftimeAlertsEnabled, matchEndAlertsEnabled)
- [x] Quiet hours support (quietHoursEnabled, quietHoursStart, quietHoursEnd)
- [x] FCM topic subscriptions for real-time alerts

### 5. Deep Linking
- [x] Configure app links (using app_links package - Firebase Dynamic Links deprecated)
- [x] Share match links to social media (ShareButton.match widget)
- [x] Share watch party links (ShareButton.watchParty widget)
- [x] Share prediction links (DeepLinkService.generatePredictionLink)
- [x] App install attribution tracking (UTM parameters in generated links)
- [x] Universal links (iOS - Runner.entitlements) / App Links (Android - AndroidManifest.xml)
- [ ] Configure web domain (pregameworldcup.com) with /.well-known/ files

### 6. Accessibility (WCAG Compliance)
- [x] Screen reader support (Semantics widgets - AccessibleButton, AccessibleCard, etc.)
- [x] High contrast mode (AppTheme.highContrastTheme)
- [x] Dynamic font scaling support (removed hardcoded 1.0 scale, respects system settings)
- [x] Touch target sizes (minimum 48x48 - MinimumTouchTarget, AccessibilityService.minimumTouchTargetSize)
- [x] Color contrast ratios (high contrast theme with WCAG-compliant colors)
- [x] Keyboard navigation support (FocusableWidget with Enter/Space key handlers)
- [x] Reduce motion support (AccessibleAnimatedContainer respects reduceMotion setting)
- [x] Bold text support (AccessibleText respects boldText setting)
- [x] Accessibility settings persistence (SharedPreferences via AccessibilityService)

---

## Important (Should Have)

### 7. Live Match Chat
- [x] Real-time chat rooms per match (MatchChatService with Firestore snapshots)
- [x] Join/leave chat functionality (joinMatchChat/leaveMatchChat with participant tracking)
- [x] Emoji reactions to goals/events (QuickReactionsBar with 8 quick reactions)
- [x] Moderation for live chats (ModerationService integration with profanity filter)
- [x] Rate limiting to prevent spam (3s between messages, burst limit of 5 in 10s)

### 8. Calendar Integration
- [x] Add single match to device calendar (AddToCalendarButton with CalendarOptionsSheet)
- [x] Add all favorite team matches to calendar (addFavoriteTeamMatches in CalendarService)
- [x] Export to Google Calendar (generateGoogleCalendarUrl with direct URL scheme)
- [x] Export to Apple Calendar (iCal .ics file download and share)
- [x] iCal feed generation (generateICalContent with VEVENT and VALARM support)

### 9. Widget Support
- [x] iOS home screen widget (WorldCupWidget with SwiftUI - small/medium/large sizes)
- [ ] iOS lock screen widget (live scores) - requires iOS 16+ Lock Screen widget API
- [x] Android home screen widget (WorldCupWidgetProvider with RemoteViews)
- [x] Widget configuration options (WidgetSettingsScreen with WidgetConfiguration)
- [x] Live score updates in widgets (WidgetService syncs liveMatches/upcomingMatches)

### 10. Social Media Sharing
- [x] Share predictions to Twitter/X (ShareButton.prediction with shareToTwitter)
- [x] Share predictions to Instagram Stories (shareToInstagramStories with image capture)
- [x] Share watch parties to social media (ShareButton.watchParty)
- [x] Pre-formatted graphics for shares (captureWidgetAsImage for shareable graphics)
- [x] Share match results with commentary (ShareButton.matchResult with ShareableMatchResult)
- [x] Referral tracking (UTM parameters, generateReferralLink in SocialSharingService)

### 11. Multi-language Support
- [x] Complete Spanish translation (Mexico market) - app_es.arb with 150+ strings
- [x] Portuguese translation (Brazil fans) - app_pt.arb with 150+ strings
- [x] French translation (Canada market) - app_fr.arb with 150+ strings
- [x] Language detection and auto-switch (LocalizationService with detectSystemLanguage)
- [x] In-app language selector (LanguageSelectorScreen, QuickLanguagePicker, LanguageSelectorTile)

### 12. Offline Mode Enhancement
- [x] Full schedule available offline (WorldCupCacheDataSource with matches, today's, upcoming, completed)
- [x] Cached team data offline (WorldCupCacheDataSource.cacheTeams with 24hr duration)
- [x] Cached venue data offline (WorldCupCacheDataSource.cacheVenues with 7-day duration)
- [x] Offline indicator in UI (OfflineBanner, OfflineChip, OfflineStatusIcon, OfflineWrapper)
- [x] Sync status indicator (SyncStatusIndicator, SyncFAB, SyncStatusTile)
- [x] Queue actions for when online (OfflineService with QueuedAction, action handlers)

---

## Nice to Have (Differentiators)

### 13. Live Video Streaming for Watch Parties
- [ ] Host can start video stream
- [ ] Attendees can join stream
- [ ] Chat alongside video
- [ ] Stream quality options
- [ ] Recording capability

### 14. AR Stadium Navigation
- [ ] AR venue map overlay
- [ ] Find seats with AR
- [ ] Find concessions/restrooms
- [ ] AR player info during matches
- [ ] AR photo filters with team logos

### 15. Fantasy World Cup Integration
- [ ] Create fantasy team
- [ ] Join/create leagues
- [ ] Scoring system
- [ ] Leaderboards
- [ ] Trade/transfer players

### 16. Ticket Purchasing
- [ ] StubHub integration
- [ ] Viagogo integration
- [ ] Official FIFA ticket links
- [ ] Price alerts
- [ ] Ticket verification

### 17. Travel Planning
- [ ] Nearby hotels for venues
- [ ] Flight search integration
- [ ] Trip itinerary builder
- [ ] Venue transportation info
- [ ] Local recommendations

### 18. Apple Watch / WearOS
- [ ] Live score notifications
- [ ] Match schedule glance
- [ ] Favorite team quick view
- [ ] Haptic goal alerts
- [ ] Complication support

### 19. Second Screen Experience
- [ ] Real-time match stats
- [ ] Player heat maps
- [ ] Possession statistics
- [ ] Formation visualization
- [ ] Live commentary feed

### 20. Gamification Expansion
- [ ] Daily challenges
- [ ] Weekly challenges
- [ ] Achievement badges system
- [ ] Country leaderboards
- [ ] Friend leaderboards
- [ ] Streak rewards
- [ ] XP multipliers

---

## Infrastructure & Technical Debt

### Testing
- [ ] Increase test coverage to 60%+
- [ ] Add integration tests for critical paths
- [ ] Add E2E tests for main user flows
- [ ] Set up CI test automation
- [ ] Add performance tests

### Performance
- [ ] Profile app startup time
- [ ] Optimize image loading
- [ ] Reduce bundle size
- [ ] Implement lazy loading
- [ ] Memory leak detection

### Security
- [ ] Security audit
- [ ] Penetration testing
- [ ] API rate limiting review
- [ ] Data encryption audit
- [ ] GDPR compliance check

### Backend
- [ ] Load testing (simulate World Cup traffic)
- [ ] Auto-scaling configuration
- [ ] Database indexing optimization
- [ ] CDN setup for static assets
- [ ] Backup and recovery testing

---

## Pre-Launch Checklist

### 1 Month Before
- [ ] All critical features complete
- [ ] Beta testing with 100+ users
- [ ] App Store / Play Store listings ready
- [ ] Privacy policy updated
- [ ] Terms of service updated

### 2 Weeks Before
- [ ] Final QA pass
- [ ] Performance testing complete
- [ ] Load testing complete
- [ ] Marketing assets ready
- [ ] Press kit prepared

### 1 Week Before
- [ ] App submitted to stores
- [ ] Server scaling verified
- [ ] Monitoring dashboards ready
- [ ] On-call rotation scheduled
- [ ] Rollback plan documented

### Launch Day
- [ ] Monitor crash rates
- [ ] Monitor API response times
- [ ] Monitor user signups
- [ ] Social media monitoring
- [ ] Customer support ready

---

## Success Metrics to Track

| Metric | Target |
|--------|--------|
| Daily Active Users | 100K+ during World Cup |
| App Store Rating | 4.5+ stars |
| Crash-free Rate | 99.5%+ |
| API Response Time | <200ms p95 |
| User Retention (D7) | 40%+ |
| Conversion Rate | 5%+ free to paid |
| Watch Parties Created | 10K+ |
| Predictions Made | 1M+ |

---

## Notes

- Token feature remains disabled pending legal review
- College football legacy code can be removed after World Cup
- Consider hiring additional developers for crunch time
- Plan for 10x traffic during knockout rounds vs group stage

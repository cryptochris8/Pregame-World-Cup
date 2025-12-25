# Pregame - Original Project Summary

## Overview

**Pregame** is a production-ready mobile sports fan ecosystem designed to connect fans with their teams and local sports venues. Currently optimized for American college football (SEC conference focus), the app was developed through to Apple TestFlight testing.

**Project Location**: `C:\Users\chris\Pregame`
**Firebase Project**: `pregame-b089e`
**Live Web Portal**: https://pregame-b089e.web.app

---

## Technology Stack

### Mobile App (Flutter/Dart)
| Component | Technology |
|-----------|------------|
| Framework | Flutter 3.0+ |
| Language | Dart 3.0+ |
| State Management | BLoC pattern (flutter_bloc ^8.1.3) |
| Architecture | Clean Architecture (features/domain/data layers) |
| Local Storage | Hive ^2.2.3 |
| Networking | Dio ^5.4.0 |
| Authentication | Firebase Auth ^5.5.4 |
| Database | Cloud Firestore ^5.6.8 |
| Real-time | Firebase Realtime Database ^11.1.4 |
| Payments | Flutter Stripe ^10.2.0 |
| Maps | Google Maps Flutter |
| Media | audio_waveforms, just_audio, video_player |

### Web Venue Portal (React/TypeScript)
| Component | Technology |
|-----------|------------|
| Framework | React ^18.2.0 |
| Language | TypeScript 5.0 |
| Build Tool | Webpack 5.75.0 |
| Styling | Tailwind CSS 3.3.0 |
| Routing | React Router DOM 6.8.0 |
| Charts | Recharts 2.15.4 |
| Payments | Stripe.js |

### Backend (Firebase)
- Firebase Authentication
- Cloud Firestore (NoSQL database)
- Firebase Realtime Database (presence/chat)
- Firebase Storage (media files)
- Firebase Cloud Functions (Node.js)
- Firebase Hosting

### External APIs Currently Integrated
| API | Purpose |
|-----|---------|
| SportsData.io | College football data (v3 API) |
| ESPN API | Game schedules and live scores |
| NCAA API | College sports data |
| Google Places API | Venue discovery and mapping |
| College Football Data API | Historical game data |
| OpenAI | AI game analysis |
| Claude API | Enhanced AI predictions |
| Stripe | Payment processing |
| Zapier | Game-day automation |

---

## Application Features

### Mobile App Features

#### 1. Authentication & Profile
- Firebase Auth login (email/password, Google Sign-In)
- User profile management
- Favorite teams selection
- Privacy settings and permissions
- Badge and level system (gamification)

#### 2. Game Schedule
- College football schedule display
- Live score updates with real-time data
- Game filtering (today, this week, all games)
- Team logos and stadium information
- Game status tracking (upcoming, live, completed)

#### 3. Venue Discovery
- Google Maps-based venue search
- Location-based recommendations
- Venue details with ratings, hours, contact info
- Photo galleries
- Distance calculation with route planning
- Smart venue recommendations based on preferences

#### 4. Social Features
- Activity feed with game-related posts
- Friend management and friend requests
- Notification system
- User profiles with badges and experience points
- Favorite teams display

#### 5. Real-time Messaging
- One-to-one and group chats
- Message types: text, voice, file attachments, video
- Voice recording with waveform visualization
- Message reactions and replies
- Typing indicators and read receipts
- Message search functionality

#### 6. Game Predictions
- User game predictions with confidence levels (1-5 stars)
- Prediction tracking and accuracy scoring
- Leaderboards by prediction accuracy
- Points system for correct predictions
- Prediction streaks tracking

#### 7. AI-Powered Analysis
- Game intelligence and analysis
- Enhanced predictions using Claude/OpenAI
- Historical game data integration
- Team season summaries
- User preference learning for personalization

### Web Venue Portal Features

#### 1. Venue Owner Dashboard
- Real-time analytics overview
- Visitor statistics (daily/total)
- Fan engagement metrics
- Live viewer count

#### 2. Venue Profile Management
- Business information editing
- Location and operating hours
- Photo gallery management

#### 3. Subscription Billing (Live)
| Tier | Monthly Price | Target Venue |
|------|---------------|--------------|
| Basic | $49 (was $79) | Cafes & quick bites |
| Pro | $99 (was $149) | Sports bars & restaurants |
| Enterprise | $199 (was $299) | Large venues & chains |

#### 4. Live Streaming Manager
- Multi-camera stream management
- Viewer chat integration
- Stream analytics and quality controls

#### 5. Specials/Promotions Manager
- Food and drink special creation
- Scheduling and campaign tracking
- Promotion analytics

---

## Data Models

### Core Entities

#### GameSchedule
```dart
- gameId, globalGameId, season, week, seasonType
- status: Scheduled | InProgress | Completed
- Teams: awayTeamId, homeTeamId, awayTeamName, homeTeamName
- Times: dateTime, dateTimeUTC, day
- Stadium: stadiumId, name, city, state, capacity, geoLat, geoLong
- Scores: awayScore, homeScore, period, timeRemaining, isLive
- Social: userPredictions, userComments, userPhotos, userRating
```

#### UserProfile
```dart
- userId, displayName, email, profileImageUrl
- bio, homeLocation
- favoriteTeams (list)
- UserPreferences, UserPrivacySettings
- SocialStats: followers, following, friends
- badges, level, experiencePoints
- isOnline, lastSeenAt
```

#### GamePrediction
```dart
- predictionId, userId, gameId
- predictedWinner, predictedScores
- confidenceLevel (1-5 stars)
- isCorrect, pointsEarned, isLocked
```

#### Message
```dart
- messageId, chatId, senderId
- content, type: text | voice | video | file
- status: pending | sent | delivered | read
- reactions, replies, attachments
- readBy tracking
```

### Firestore Collections
- `users/{userId}` - User profiles and settings
- `games/{gameId}` - Game schedule and live scores
- `venues/{venueId}` - Venue information
- `chats/{chatId}` - Messaging conversations
- `messages/{messageId}` - Individual messages
- `game_predictions/{predictionId}` - User predictions
- `activity_feed/{activityId}` - Social feed items
- `notifications/{notificationId}` - User notifications
- `friend_requests/{requestId}` - Friend management
- `userFavorites/{userId}` - Favorite teams

---

## Architecture Patterns

### BLoC State Management
- Event-driven architecture separating UI from business logic
- Bloc classes for schedule, recommendations, social features

### Clean Architecture Layers
```
Presentation (UI & Widgets)
    ↓
Domain (Entities & Usecases)
    ↓
Data (Repositories & Datasources)
```

### Dependency Injection
- GetIt service locator for dependency management
- Singleton patterns for core services
- Lazy initialization for heavy services

### Offline-First Approach
- Hive local caching for offline data
- Firestore offline persistence
- Graceful fallbacks for no connectivity

---

## Key Services

### Data Services
| Service | Purpose |
|---------|---------|
| NCAAScheduleDataSource | NCAA API integration |
| ESPNScheduleDataSource | ESPN schedule data |
| LiveScoresDatasource | Real-time scores |
| PlacesApiDatasource | Google Places venues |
| SocialDatasource | Social features backend |
| FileUploadService | Firebase Storage uploads |
| VoiceRecordingService | Audio capture & storage |

### AI Services
| Service | Purpose |
|---------|---------|
| ClaudeService | Claude API integration |
| MultiProviderAIService | Multiple AI providers |
| AIGameAnalysisService | Game intelligence |
| EnhancedAIPredictionService | Advanced predictions |
| AITeamSeasonSummaryService | Season statistics |
| UserPreferenceLearningService | Personalization |

### Utility Services
| Service | Purpose |
|---------|---------|
| CacheService | Hive-based caching |
| PresenceService | Real-time user presence |
| AuthService | Firebase authentication |
| PaymentService | Stripe integration |
| RateLimitService | API rate limiting |
| SmartVenueRecommendationService | Venue suggestions |

---

## Project Structure

```
C:\Users\chris\Pregame\
├── lib/                          # Flutter/Dart mobile app
│   ├── features/                 # Feature modules
│   │   ├── schedule/             # Game schedule feature
│   │   ├── venues/               # Venue discovery
│   │   ├── social/               # Social features
│   │   ├── messaging/            # Chat system
│   │   ├── predictions/          # Game predictions
│   │   └── auth/                 # Authentication
│   ├── services/                 # Core services
│   ├── core/                     # Shared utilities
│   └── injection_container.dart  # DI setup
├── src/                          # React web venue portal
│   ├── components/               # React components
│   ├── pages/                    # Page components
│   ├── services/                 # API services
│   └── styles/                   # CSS/Tailwind
├── functions/                    # Firebase Cloud Functions
├── assets/                       # Logos, images, media
│   └── logos/                    # Team logos (SEC)
├── android/                      # Android native code
├── ios/                          # iOS native code
├── firebase.json                 # Firebase config
├── pubspec.yaml                  # Flutter dependencies
├── package.json                  # React dependencies
└── [40+ documentation files]
```

---

## Deployment Status

| Platform | Status | Details |
|----------|--------|---------|
| Web Portal | LIVE | https://pregame-b089e.web.app |
| Android | Built | APK ready (59.5MB) |
| iOS | TestFlight | Beta testing completed |
| Firebase Functions | Deployed | 4 payment functions active |
| Stripe Integration | LIVE | Processing real payments |

---

## Assets

### Team Logos (SEC Conference)
- Alabama, Auburn, Florida, Georgia
- Kentucky, LSU, Mississippi, Mississippi State
- Missouri, Oklahoma, Ole Miss, South Carolina
- Tennessee, Texas A&M, Vanderbilt
- Pregame logo (main branding)

### Branding
- Primary Color: #355E3B (Pregame green)
- Dark theme support
- Material Design components

---

## Security Implementation

### Firestore Security Rules
- User-scoped read/write for profiles
- Public read for social features
- Authenticated access for game data
- Author-only write access for posts
- Friend management verification

### Authentication
- Email/password via Firebase Auth
- Google Sign-In integration
- API key validation on startup
- Webhook verification for Stripe

---

## Documentation Available

The project includes 40+ comprehensive markdown documentation files:
- API setup guides
- Deployment guides
- Firebase setup instructions
- Stripe integration docs
- Architecture documentation
- Roadmap files
- Marketing materials

---

## Summary

Pregame is a **production-ready, fully-featured sports fan ecosystem** with:

- **Dual platforms**: Flutter mobile app + React web portal
- **Complete payment system**: Stripe integration with live billing
- **Real-time features**: Messaging, live scores, presence
- **AI-powered insights**: Game analysis and predictions
- **Social engagement**: Friends, activity feeds, community
- **Venue discovery**: Google Maps integration, location-based
- **Clean architecture**: BLoC, dependency injection, offline support
- **Production deployment**: Firebase backend, live web app

The modular architecture and clean separation of concerns make this codebase well-suited for adaptation to other sports events like the FIFA World Cup 2026.

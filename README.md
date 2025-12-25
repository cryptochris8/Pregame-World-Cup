# Pregame World Cup 2026

A mobile sports fan app for FIFA World Cup 2026, connecting fans with matches, venues, watch parties, and fellow supporters across the USA, Mexico, and Canada.

**Forked from**: [Pregame](../Pregame) (College Football version)

## Overview

Pregame World Cup 2026 is a cross-platform mobile app (Flutter) with a companion web portal (React) designed to enhance the fan experience for the FIFA World Cup 2026 tournament.

### Key Features

- **Match Schedule** - All 104 World Cup matches with live scores
- **Team Tracking** - Follow your favorite national teams through the tournament
- **Venue Discovery** - Find FIFA Fan Festivals, sports bars, and watch parties
- **Predictions** - Predict match results and compete on leaderboards
- **Social Features** - Connect with fans, share photos, send messages
- **Real-time Chat** - Message friends with text, voice, and media
- **AI Analysis** - AI-powered match previews and predictions

### Tournament Info

| Detail | Value |
|--------|-------|
| Dates | June 11 - July 19, 2026 |
| Teams | 48 |
| Matches | 104 |
| Host Countries | USA, Mexico, Canada |
| Host Cities | 16 |
| Final | MetLife Stadium, NJ |

## Project Structure

```
pregame-world-cup/
├── lib/                    # Flutter/Dart mobile app
│   ├── features/           # Feature modules (schedule, venues, social, etc.)
│   ├── services/           # Core services (API, auth, AI, etc.)
│   └── core/               # Shared utilities
├── src/                    # React web portal (TypeScript)
├── functions/              # Firebase Cloud Functions
├── assets/                 # Images, logos, flags
├── android/                # Android native code
├── ios/                    # iOS native code
└── test/                   # Test files
```

## Tech Stack

### Mobile App
- **Framework**: Flutter 3.0+
- **Language**: Dart
- **State Management**: BLoC
- **Backend**: Firebase (Auth, Firestore, Storage)
- **Maps**: Google Maps Flutter
- **Payments**: Stripe

### Web Portal
- **Framework**: React 18
- **Language**: TypeScript
- **Styling**: Tailwind CSS
- **Charts**: Recharts

### APIs
- SportsData.io (World Cup data)
- Google Places API
- OpenAI / Claude (AI features)
- Stripe (payments)

## Getting Started

### Prerequisites
- Flutter SDK 3.0+
- Node.js 18+
- Firebase CLI
- Android Studio / Xcode

### Setup

1. **Install Flutter dependencies**:
   ```bash
   flutter pub get
   ```

2. **Install web portal dependencies**:
   ```bash
   npm install
   ```

3. **Configure environment**:
   - Copy `env.example` to `.env`
   - Add your API keys (SportsData.io, Google Places, etc.)

4. **Run the mobile app**:
   ```bash
   flutter run
   ```

5. **Run the web portal**:
   ```bash
   npm start
   ```

## Adaptation Checklist

This project is being adapted from the original college football version:

### Data Models
- [ ] Update GameSchedule entity for World Cup format
- [ ] Create NationalTeam entity (48 teams)
- [ ] Add Group entity (12 groups of 4)
- [ ] Add Bracket/Knockout entity
- [ ] Update Stadium entity for World Cup venues

### API Integration
- [ ] Switch SportsData.io from CFB to Soccer/World Cup endpoints
- [ ] Update ESPN integration for international soccer
- [ ] Add World Cup-specific data fetching

### UI/UX
- [ ] Replace SEC team logos with national team flags
- [ ] Create group stage tables view
- [ ] Create knockout bracket view
- [ ] Update venue discovery for FIFA Fan Festivals
- [ ] Add country selector for favorite teams

### Features
- [ ] Multi-match concurrent viewing (group stage)
- [ ] Bracket prediction challenge
- [ ] Fan Zone Finder for all 16 host cities
- [ ] Multi-timezone support (USA/Mexico/Canada)

### Localization
- [ ] Spanish language support (Mexico market)
- [ ] Time zone aware match schedules

## Documentation

- [Original Pregame Summary](./PREGAME_ORIGINAL_SUMMARY.md) - Full technical breakdown of the original app
- [World Cup 2026 Brainstorm](./WORLD_CUP_2026_BRAINSTORM.md) - Research, APIs, and adaptation strategy

## World Cup 2026 Key Dates

- **June 11, 2026**: Opening match (Mexico City - Estadio Azteca)
- **June 12, 2026**: USA & Canada opening matches
- **July 19, 2026**: Final (MetLife Stadium, New Jersey)

## Host Cities & Venues

### United States (11 cities)
- New York/NJ (MetLife Stadium - **FINAL**)
- Los Angeles (SoFi Stadium)
- Dallas (AT&T Stadium - **Semi-final**)
- Atlanta (Mercedes-Benz Stadium - **Semi-final**)
- Miami, Houston, Philadelphia, Seattle, San Francisco, Boston, Kansas City

### Mexico (3 cities)
- Mexico City (Estadio Azteca - **Opening Match**)
- Guadalajara, Monterrey

### Canada (2 cities)
- Toronto (BMO Field)
- Vancouver (BC Place)

## License

Private project - All rights reserved.

---

**Status**: Fork completed, ready for World Cup adaptation

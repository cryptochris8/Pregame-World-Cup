# Pregame World Cup 2026 - Brainstorm & Research

## FIFA World Cup 2026 Overview

### Tournament Details
| Aspect | Details |
|--------|---------|
| **Official Name** | FIFA World Cup 26 |
| **Dates** | June 11 - July 19, 2026 |
| **Host Countries** | USA, Canada, Mexico (first tri-nation World Cup) |
| **Teams** | 48 (expanded from 32) |
| **Total Matches** | 104 (up from 64) |
| **Format** | 12 groups of 4 teams |
| **Final Venue** | MetLife Stadium, New Jersey |

### Tournament Format
1. **Group Stage**: 12 groups of 4 teams each
2. **Round of 32**: Top 2 from each group + 8 best third-place teams
3. **Round of 16**: 16 teams
4. **Quarter-finals**: 8 teams
5. **Semi-finals**: 4 teams
6. **Third-place playoff & Final**

### Historic Significance
- First World Cup with 48 teams
- First World Cup hosted by three nations
- Mexico becomes first country to host 3 World Cups
- First World Cup in Canada
- Estadio Azteca becomes only stadium to host 3 World Cups (1970, 1986, 2026)
- First World Cup with mandatory hydration breaks (North American summer heat)
- First World Cup with a halftime show (Coldplay at MetLife Stadium final)

---

## Host Cities & Stadiums

### United States (11 Cities, 60 Matches)

| City | Stadium | Capacity | Key Matches |
|------|---------|----------|-------------|
| **New York/New Jersey** | MetLife Stadium | 82,500+ | **FINAL** (July 19), 8 matches total |
| **Dallas/Arlington** | AT&T Stadium | 80,000-100,000 | **Semi-final**, 9 matches (most of any venue) |
| **Atlanta** | Mercedes-Benz Stadium | 71,000 | **Semi-final** |
| **Los Angeles** | SoFi Stadium | 70,000 | **Quarter-final**, USA opening match (June 12) |
| **Miami** | Hard Rock Stadium | 65,000 | 7 matches |
| **Houston** | NRG Stadium | 72,000 | 5 matches |
| **Philadelphia** | Lincoln Financial Field | 69,000 | 6 matches |
| **Seattle** | Lumen Field | 69,000 | 6 matches |
| **San Francisco Bay** | Levi's Stadium | 68,500 | 6 matches |
| **Boston** | Gillette Stadium | 65,000 | 6 matches |
| **Kansas City** | GEHA Field at Arrowhead Stadium | 76,000 | 6 matches |

### Mexico (3 Cities, ~13 Matches)

| City | Stadium | Capacity | Key Matches |
|------|---------|----------|-------------|
| **Mexico City** | Estadio Azteca | 87,000+ | **Opening Match** (June 11 - Mexico vs South Africa) |
| **Guadalajara** | Estadio Akron | 49,850 | Group stage + knockout |
| **Monterrey** | Estadio BBVA | 53,500 | Group stage + knockout |

### Canada (2 Cities, ~13 Matches)

| City | Stadium | Capacity | Key Matches |
|------|---------|----------|-------------|
| **Toronto** | BMO Field | 45,500 | Canada opening match (June 12) |
| **Vancouver** | BC Place | 54,500 | Group stage + knockout |

---

## FIFA Fan Festivals (Key Feature Opportunity)

Each host city will have official FIFA Fan Festivals - free public viewing areas with:
- Giant LED screens for live matches
- Live entertainment & concerts
- Cultural performances
- Food from around the world
- Interactive football experiences (VR games, penalty shootouts)
- Official merchandise
- Family areas and cooling stations

### Confirmed Fan Festival Locations

| City | Location |
|------|----------|
| **Atlanta** | Centennial Olympic Park |
| **Kansas City** | National WWI Museum and Memorial |
| **New York/NJ** | Rockefeller Center (July 4-19) |
| **Miami** | TBA (family-friendly venue) |
| **Vancouver** | Outdoor venue TBA |
| **Mexico City** | Zócalo (expected) |
| **Los Angeles** | LA Memorial Coliseum (opening), Santa Monica, Inglewood |
| **Seattle** | Seattle Center |
| **Boston** | Boston Common or City Hall Plaza |
| **Bay Area** | Multiple venues in SF, Oakland, San Jose |

---

## Available APIs for World Cup Data

### Premium Options

#### 1. SportsData.io (Already Integrated!)
**Advantage**: You already have this integrated for college football!

| Feature | Details |
|---------|---------|
| Coverage | FIFA World Cup complete coverage |
| Real-time | Live match data, scores, game clock |
| Data Points | Player stats, HT/FT, extra time, penalties |
| Integration | Same API structure as college football |
| [Website](https://sportsdata.io/fifa-world-cup-api) | |

#### 2. API-Football
| Feature | Details |
|---------|---------|
| Coverage | 1,200+ leagues including World Cup |
| Updates | Real-time every 15 seconds |
| Pricing | Starting $19/month, free tier available |
| Widgets | Free widgets included |
| [Website](https://www.api-football.com/) | |

#### 3. Sportmonks
| Feature | Details |
|---------|---------|
| Coverage | Complete World Cup 2026 data |
| Data | Livescores, fixtures, events, odds |
| Pricing | Flexible plans, 14-day free trial |
| Developer-friendly | Clear docs, filters, code examples |
| [Website](https://www.sportmonks.com/football-api/world-cup-api/world-cup-2026/) | |

#### 4. Live-Score API
| Feature | Details |
|---------|---------|
| Coverage | Near real-time match events |
| Data | Goals, substitutions, cards, lineups |
| Requests | Up to 2,000/hour |
| Trial | 14-day free trial |
| [Website](https://live-score-api.com/world-cup-api) | |

#### 5. Data Sports Group (DSG)
| Feature | Details |
|---------|---------|
| Coverage | All 104 matches |
| Data | Goals, assists, passing networks, heatmaps |
| Widgets | Live widgets, automated insights |
| [Website](https://datasportsgroup.com/fifa-world-cup-data/) | |

#### 6. Statorium
| Feature | Details |
|---------|---------|
| Pricing | One-time flat fee |
| Data | Live scores, stats, news |
| Widgets | Included at no extra cost |
| Integration | WordPress & Joomla plugins |
| [Website](https://statorium.com/fifa-world-cup-2026-api) | |

### Free/Budget Options

#### RapidAPI - Free API Live Football Data
- 2,100+ leagues including World Cup
- Livescores, players, teams, statistics
- Free tier available

### Recommendation

**Primary**: Continue using **SportsData.io** since it's already integrated and has World Cup coverage. You'll need to update the API endpoints from college football to soccer/World Cup.

**Secondary**: Consider **API-Football** or **Sportmonks** for backup/additional data (especially odds if you want to add that feature).

---

## Adaptation Strategy

### Phase 1: Core Data Model Changes

#### 1. Replace Team Entity
**From**: College Football Teams (SEC focus)
```
- Team ID, Name, Conference
- Logo URL
- Stadium
```

**To**: National Teams
```
- FIFA Team Code (3-letter: USA, MEX, GER, etc.)
- Country Name
- Flag URL
- Confederation (UEFA, CONMEBOL, CONCACAF, AFC, CAF, OFC)
- FIFA Ranking
- Coach Name
- Squad List (players)
- Group Assignment (A-L)
```

#### 2. Replace Game/Match Entity
**From**: College Football Games
```
- Week, Season
- Home/Away Teams
- Stadium
- Quarter periods
```

**To**: World Cup Matches
```
- Match Number (1-104)
- Stage (Group, R32, R16, QF, SF, 3rd Place, Final)
- Group (A-L for group stage)
- Home/Away Teams (or Team 1/Team 2 for knockouts)
- Venue
- Match Time (local + UTC)
- Halftime scores
- Extra Time & Penalties support
- VAR decisions
```

#### 3. Replace Stadium Entity
**From**: College Stadiums
```
- Stadium ID
- Name, City, State
- Capacity
- Coordinates
```

**To**: World Cup Venues
```
- Venue ID
- Stadium Name
- City
- Country (USA/Mexico/Canada)
- Capacity
- Coordinates
- Time Zone
- Weather forecast integration
- Public transit info
- Matches hosted (list)
```

### Phase 2: Feature Adaptations

#### 1. Favorite Teams
**From**: Favorite SEC Teams
**To**: Favorite National Teams + Favorite to Win

Features to add:
- Pick your country (fan of)
- Pick your predicted winner
- Follow multiple teams through knockout stages
- "Second team" feature (e.g., support USA + another country)

#### 2. Game Predictions
**From**: Point spread, winner prediction
**To**:
- Match result prediction (Win/Draw/Loss)
- Score prediction
- Group stage standings prediction
- Bracket prediction (knockout stage)
- Golden Boot prediction (top scorer)
- Tournament winner prediction
- Fantasy-style player performance predictions

#### 3. Venue Discovery
**From**: Bars/restaurants near college stadiums
**To**:
- Official FIFA Fan Festival locations
- Sports bars showing World Cup
- Watch parties near user
- Stadium visit planning (for ticket holders)
- Public viewing areas
- Sports bar "World Cup specials" promotions

#### 4. Social Features
**From**: SEC fan community
**To**:
- Global fan community
- Country-specific chat rooms
- Multi-language support
- Time zone-aware notifications
- Rival match threads
- Live reaction feeds

#### 5. Activity Feed
**From**: Game reactions
**To**:
- Match reactions
- Goal celebrations
- VAR controversy discussions
- Penalty shootout reactions
- National team content
- Fan photos from stadiums/fan zones

### Phase 3: New World Cup Features

#### 1. Tournament Bracket View
- Visual bracket showing knockout stage progression
- User's predictions vs actual results
- "Bracket challenge" competition

#### 2. Group Stage Tables
- Live group standings
- Qualification scenarios
- Tiebreaker explanations
- "What-if" simulators

#### 3. Player Stats & Golden Boot Race
- Top scorers leaderboard
- Assists leaders
- Player of the Match tracking
- Squad rosters with player profiles

#### 4. Fan Zone Finder
- Map of all Fan Festival locations
- Operating hours
- Capacity estimates
- User check-ins
- Photos from fan zones
- "Best atmosphere" ratings

#### 5. Multi-Match Experience
- Multiple concurrent matches during group stage
- Picture-in-picture for key moments
- "Whip-around" style alerts for goals in other matches
- Goal notifications across all matches

#### 6. Countdown & Hype Features
- Days until World Cup
- Team arrival tracking
- Training session updates
- Pre-tournament friendlies

#### 7. Match Day Experience
- Stadium guides (parking, food, seating)
- Public transit directions
- Weather forecasts
- "Day of" checklists
- Nearby venue recommendations

#### 8. Historical Context
- Head-to-head records
- Previous World Cup meetings
- Country World Cup history
- Classic match highlights

---

## Technical Implementation Changes

### 1. API Integration Updates

**File**: `/lib/services/sports_data_service.dart`
- Change base URL from college football to soccer
- Update endpoints: `/v3/soccer/scores` instead of `/v3/cfb/scores`
- Add World Cup-specific endpoints

**New endpoints needed**:
- `/standings` - Group tables
- `/teams` - National team rosters
- `/players` - Player profiles
- `/competitions/world-cup-2026` - Tournament data

### 2. Data Model Updates

**Files to modify**:
- `/lib/features/schedule/domain/entities/game_schedule.dart` → `match.dart`
- `/lib/features/schedule/domain/entities/stadium.dart` → `venue.dart`
- Add: `/lib/features/teams/domain/entities/national_team.dart`
- Add: `/lib/features/tournament/domain/entities/group.dart`
- Add: `/lib/features/tournament/domain/entities/bracket.dart`

### 3. UI Updates

**Assets to create**:
- 48 national team flags (all qualified teams)
- FIFA World Cup 2026 logo
- Stadium images for all 16 venues
- Fan Festival icons

**Screens to adapt**:
- Schedule screen → Match schedule with group/knockout filters
- Game detail → Match detail with halftime, ET, penalties
- Team selection → Country selection
- Add: Group tables screen
- Add: Bracket view screen
- Add: Fan zone finder screen

### 4. Firebase Structure Updates

**Collections to add**:
```
matches/{matchId}
national_teams/{teamCode}
groups/{groupLetter}
brackets/{stage}
fan_zones/{zoneId}
players/{playerId}
user_brackets/{userId}
```

### 5. Time Zone Handling

Critical for tri-nation tournament:
- Store all times in UTC
- Convert to user's local time zone
- Support for 4 time zones (ET, CT, MT, PT) + Mexico + Canada
- Match kickoff time localization

---

## Monetization Opportunities

### 1. Venue Portal Adaptation
Rename "Venue Portal" to "Watch Party Host Portal"

**Target customers**:
- Sports bars hosting watch parties
- Fan zone organizers
- Restaurant/bar chains
- Community organizations
- Corporate watch parties

**New features**:
- Match schedule integration
- Specials tied to specific matches
- Capacity/reservation management
- Multi-screen setup guides
- Sound/atmosphere optimization tips

### 2. Premium Features
- Ad-free experience
- Exclusive predictions/insights
- Advanced bracket tools
- Early access to features

### 3. Partnerships
- Official FIFA Fan Festival integration
- Local tourism boards
- Sports bars/restaurants
- Beverage sponsors
- Betting partners (where legal)

---

## Timeline Considerations

### World Cup Schedule
- **June 11, 2026**: Opening match (Mexico City)
- **June 12, 2026**: USA & Canada open
- **July 19, 2026**: Final

### Development Windows
- **Now - June 2025**: Core adaptation (12 months before)
- **June 2025 - Dec 2025**: Feature additions
- **Jan 2026 - May 2026**: Polish, testing, soft launch
- **June 2026**: Full launch with tournament

### Pre-Tournament Content
- Qualification tracking (ongoing now)
- Team previews
- Group draw reactions (already happened)
- Fixture announcements
- Ticket sale alerts
- Fan zone announcements

---

## Competitive Analysis

Research similar apps:
- FIFA Official App
- OneFootball
- FotMob
- ESPN
- SofaScore
- Bleacher Report

**Pregame's Differentiator**:
Focus on the **local fan experience** - finding where to watch, connecting with nearby fans, venue discovery. Most apps focus only on match data. Pregame focuses on the **fan community and physical gathering places**.

---

## Key Questions to Consider

1. **Geographic Scope**: Focus on US fans only, or global?
2. **Language Support**: English only, or add Spanish (Mexico market)?
3. **Venue Type**: All venues, or only sports bars/fan zones?
4. **Predictions Scope**: Simple match predictions, or full bracket challenges?
5. **Launch Strategy**: Single launch or phased rollout?
6. **Naming**: Keep "Pregame" or create World Cup-specific branding?
7. **Post-Tournament**: Plan for 2027 (Club World Cup) or other events?

---

## Next Steps

1. **Decide on scope** (US-only vs tri-nation vs global)
2. **Choose primary API** (SportsData.io soccer endpoints)
3. **Create new data models** for World Cup entities
4. **Design new UI screens** (groups, bracket, fan zones)
5. **Gather assets** (flags, stadium images, etc.)
6. **Set up development environment** with World Cup project
7. **Build MVP** with core features
8. **Test with qualification data** before tournament

---

## Sources

- [2026 FIFA World Cup - Wikipedia](https://en.wikipedia.org/wiki/2026_FIFA_World_Cup)
- [FIFA Official - World Cup 2026](https://www.fifa.com/en/tournaments/mens/worldcup/canadamexicousa2026)
- [Sky Sports - World Cup 2026 Guide](https://www.skysports.com/football/news/11095/13272067/2026-world-cup-dates-venues-host-cities-format-and-schedule-for-usa-canada-and-mexico-tournament)
- [SportsData.io FIFA World Cup API](https://sportsdata.io/fifa-world-cup-api)
- [API-Football](https://www.api-football.com/)
- [Sportmonks World Cup 2026 API](https://www.sportmonks.com/football-api/world-cup-api/world-cup-2026/)
- [FIFA Fan Festival Official](https://www.fifa.com/en/tournaments/mens/worldcup/canadamexicousa2026/fifa-fan-festival)
- [World Cup Pass - Stadiums Guide](https://worldcuppass.com/stadiums/)
- [2026 World Cup Stadium Venues Guide](https://www.fifa2026.org/complete-guide-to-all-2026-world-cup-stadium-venues/)

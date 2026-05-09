# API Configuration Status - Pregame World Cup 2026

**Date**: December 26, 2025
**Last Updated**: After Priority #1-5 Completion

---

## 🎯 Currently Configured APIs

### 1. ✅ Firebase (WORKING - Fully Configured)

**Project**: `pregame-b089e`
**Status**: ✅ **ACTIVE AND WORKING**

**Services Configured**:
- ✅ **Firebase Auth** - User authentication
- ✅ **Firestore Database** - Real-time database with World Cup data
  - Collections: `national_teams` (25 teams)
  - Collections: `world_cup_matches` (4 sample matches)
  - Collections: `world_cup_venues` (16 stadiums)
  - Collections: `groups` (12 groups A-L)
- ✅ **Firebase Cloud Functions** - Backend serverless functions
- ✅ **Firebase Storage** - File storage
- ✅ **Firebase Realtime Database** - Presence system
- ✅ **Firebase App Check** - API protection

**API Keys**:
- Web API Key: `AIzaSyCmi4yeleQW3Oi-6VGmn7NPhpCYu88F4JM` (in `firebase_options.dart`)
- Android/iOS: Auto-configured via FlutterFire
- Service Account: Required for `populate_firestore.js` (you have this)

**Configuration File**: `lib/firebase_options.dart`

**Status**: ✅ **100% Working** - Used by app right now (Chrome test successful)

---

### 2. ⚠️ SportsData.io API (CONFIGURED - Needs API Key)

**API**: Soccer API v4 (FIFA World Cup)
**Endpoint**: `https://api.sportsdata.io/v4/soccer/scores/json`
**Competition**: `FIFAWC` (FIFA World Cup)

**Configuration**:
- ✅ Code updated to use Soccer API (Priority #1)
- ✅ Cloud Functions configured (`functions/src/sportsdata-wrapper.ts`)
- ✅ Flutter datasource created (`lib/features/worldcup/data/datasources/world_cup_schedule_datasource.dart`)

**API Key Setup**:
```dart
// In lib/config/api_keys.dart
static const String sportsDataIo = String.fromEnvironment(
  'SPORTSDATA_API_KEY',
  defaultValue: '',
);
```

**Cloud Functions**:
```typescript
// In functions/src/index.ts
const SPORTSDATA_API_KEY = process.env.SPORTSDATA_KEY;
```

**Status**: ⚠️ **Configured but needs API key to be set**

**How to Set**:

**Option 1: Environment Variable (Cloud Functions)**
```bash
# Set in Firebase Functions
firebase functions:config:set sportsdata.key="YOUR_API_KEY"
firebase deploy --only functions
```

**Option 2: Flutter App (for direct API calls)**
```bash
# Run app with API key
flutter run --dart-define=SPORTSDATA_API_KEY=YOUR_API_KEY
```

**Get API Key**:
1. Sign up at https://sportsdata.io/
2. Choose **Soccer** product
3. Copy API key
4. Set using options above

**Features Using This API**:
- Live World Cup match scores
- Match schedule updates
- Team statistics
- Player data (when available)

---

### 3. ⚠️ Google Places API (CONFIGURED - Needs API Key)

**API**: Google Places API / Maps JavaScript API
**Purpose**: Venue recommendations, stadium locations, nearby places

**Configuration**:
```dart
// In lib/config/api_keys.dart
static const String googlePlaces = String.fromEnvironment(
  'GOOGLE_PLACES_API_KEY',
  defaultValue: '',
);
```

**Cloud Functions**:
```typescript
// In functions/src/index.ts
const PLACES_API_KEY = process.env.PLACES_API_KEY;
```

**Status**: ⚠️ **Configured but needs API key**

**How to Set**:

**Get API Key**:
1. Go to https://console.cloud.google.com/
2. Select project or create new one
3. **APIs & Services** → **Credentials**
4. **Create Credentials** → **API Key**
5. Enable these APIs:
   - Maps JavaScript API
   - Places API
   - Geocoding API

**Set in Cloud Functions**:
```bash
firebase functions:config:set places.key="YOUR_API_KEY"
firebase deploy --only functions
```

**Set in Flutter App**:
```bash
flutter run --dart-define=GOOGLE_PLACES_API_KEY=YOUR_API_KEY
```

**Features Using This API**:
- Venue map display
- Nearby restaurants/bars around stadiums
- Route planning to venues
- Venue photos
- Place details

---

### 4. ❌ OpenAI API (CONFIGURED - Not Set, Optional)

**API**: OpenAI GPT API
**Purpose**: AI-powered features (chatbot, predictions, recommendations)

**Configuration**:
```dart
// In lib/config/api_keys.dart
static const String openAI = String.fromEnvironment(
  'OPENAI_API_KEY',
  defaultValue: '',
);
```

**Status**: ❌ **Optional - Not required for core functionality**

**Features Using This API** (Optional):
- AI match predictions
- Intelligent chatbot
- Personalized recommendations
- Natural language queries

**How to Set** (if needed):
1. Get API key from https://platform.openai.com/api-keys
2. Run: `flutter run --dart-define=OPENAI_API_KEY=YOUR_API_KEY`

---

### 5. ❌ Claude API (Anthropic) (CONFIGURED - Not Set, Optional)

**API**: Anthropic Claude API
**Purpose**: Alternative AI provider for chatbot/recommendations

**Configuration**:
```dart
// In lib/config/api_keys.dart
static const String claude = String.fromEnvironment(
  'CLAUDE_API_KEY',
  defaultValue: '',
);
```

**Status**: ❌ **Optional - Alternative to OpenAI**

**Features Using This API** (Optional):
- AI-powered chat
- Match analysis
- Team insights

**How to Set** (if needed):
1. Get API key from https://console.anthropic.com/
2. Run: `flutter run --dart-define=CLAUDE_API_KEY=YOUR_API_KEY`

---

### 6. ⚠️ Stripe API (CONFIGURED - Needs Keys for Payments)

**API**: Stripe Payment API
**Purpose**: In-app purchases, premium features

**Configuration**:
```dart
// In lib/config/api_keys.dart
static const String stripePublishableKey = String.fromEnvironment(
  'STRIPE_PUBLISHABLE_KEY',
  defaultValue: '',
);
```

**Status**: ⚠️ **Configured but not required unless monetizing**

**Features Using This API** (Optional):
- Premium subscriptions
- Ticket purchases
- Merchandise sales

**How to Set** (if needed):
1. Create account at https://stripe.com/
2. Get publishable key from Dashboard
3. Run: `flutter run --dart-define=STRIPE_PUBLISHABLE_KEY=YOUR_KEY`

---

## 📊 API Priority Matrix

### Required for Core Functionality ✅
| API | Status | Priority | Cost | Notes |
|-----|--------|----------|------|-------|
| **Firebase** | ✅ Working | CRITICAL | Free tier OK | Already working! |

### Important for Full Features ⚠️
| API | Status | Priority | Cost | Notes |
|-----|--------|----------|------|-------|
| **SportsData.io** | ⚠️ Need key | HIGH | $10-50/mo | Live scores, official data |
| **Google Places** | ⚠️ Need key | HIGH | Free tier OK | Venue maps, photos |

### Optional/Future Features ❌
| API | Status | Priority | Cost | Notes |
|-----|--------|----------|------|-------|
| **OpenAI** | ❌ Not set | LOW | Pay-per-use | AI predictions (optional) |
| **Claude** | ❌ Not set | LOW | Pay-per-use | Alternative AI (optional) |
| **Stripe** | ❌ Not set | LOW | 2.9% + 30¢ | Only if monetizing |

---

## 🚀 Quick Setup Guide

### Minimal Setup (App Works Now) ✅
You already have this! The app is working with:
- ✅ Firebase (authentication, Firestore, storage)
- ✅ Manual World Cup data (25 teams, 16 venues)

**App functionality right now**:
- ✅ View teams
- ✅ View matches
- ✅ View groups
- ✅ User authentication
- ✅ Social features
- ✅ Messaging

### Recommended Setup (For Production) ⚠️

**Add these 2 APIs for best experience**:

1. **SportsData.io** ($10-50/month)
   - Live match scores
   - Official FIFA data
   - Player statistics

2. **Google Places** (Free tier)
   - Stadium maps
   - Venue photos
   - Nearby recommendations

### Full Setup (All Features) 🌟

Add all APIs above for:
- Live scores ✅
- Venue maps ✅
- AI predictions ✅
- Chatbot ✅
- Payments ✅

---

## 🔧 How to Set API Keys

### Method 1: Command Line (Quick Testing)

```bash
# Run with all API keys
flutter run \
  --dart-define=SPORTSDATA_API_KEY=your_key \
  --dart-define=GOOGLE_PLACES_API_KEY=your_key \
  --dart-define=OPENAI_API_KEY=your_key \
  --dart-define=CLAUDE_API_KEY=your_key \
  --dart-define=STRIPE_PUBLISHABLE_KEY=your_key
```

### Method 2: Environment File (Recommended)

**Create**: `.env` file in project root
```
SPORTSDATA_API_KEY=your_key_here
GOOGLE_PLACES_API_KEY=your_key_here
OPENAI_API_KEY=your_key_here
CLAUDE_API_KEY=your_key_here
STRIPE_PUBLISHABLE_KEY=your_key_here
```

**Add to .gitignore**:
```
.env
firebase-service-account.json
```

**Load in Flutter** (requires flutter_dotenv package):
```yaml
# pubspec.yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

### Method 3: Firebase Functions Config

```bash
# Set for Cloud Functions
firebase functions:config:set \
  sportsdata.key="YOUR_KEY" \
  places.key="YOUR_KEY"

# Deploy functions
firebase deploy --only functions
```

---

## 📋 Current Working Features (No Additional APIs Needed)

### ✅ Working Right Now:
- User authentication (Firebase Auth)
- View 25 national teams with details
- View 16 World Cup stadiums
- View 12 groups (A-L)
- View 4 sample matches
- User profiles
- Social features (posts, friends)
- Messaging
- Favorites
- Predictions (manual)

### ⚠️ Requires API Keys:
- **Live match scores** (SportsData.io)
- **Auto-updating match schedule** (SportsData.io)
- **Venue maps with photos** (Google Places)
- **Nearby venue recommendations** (Google Places)
- **AI-powered predictions** (OpenAI/Claude)
- **Intelligent chatbot** (OpenAI/Claude)
- **Payment processing** (Stripe)

---

## 💰 Cost Estimate

### Free Tier (Current Setup) ✅
- **Firebase**: Free up to 50K reads/day ✅
- **Total**: $0/month ✅

**Good for**: Development, testing, small user base

### Recommended Setup (Production)
- **Firebase**: Free tier (or $25/mo for Blaze)
- **SportsData.io**: $10-50/month
- **Google Places**: Free tier (or pay-per-use ~$2-20/mo)
- **Total**: ~$10-75/month

**Good for**: Production app with 1,000-10,000 users

### Full Setup (All Features)
- **Firebase**: $25-100/month
- **SportsData.io**: $50-200/month
- **Google Places**: $20-50/month
- **OpenAI**: $10-100/month (usage-based)
- **Stripe**: 2.9% + 30¢ per transaction
- **Total**: ~$105-450/month + transaction fees

**Good for**: Large-scale production with 10,000+ users

---

## 🎯 Recommendation

### For Your Current Situation:

**You're good to go!** ✅

Your app is **fully functional right now** with:
- ✅ Firebase (working)
- ✅ Manual World Cup data (populated)
- ✅ All core features (teams, matches, groups, social)

### When to Add More APIs:

**Add SportsData.io when**:
- Tournament starts (June 2026)
- You need live scores
- You want official FIFA data

**Add Google Places when**:
- Users want venue maps
- You need stadium photos
- You want nearby recommendations

**Add AI APIs when**:
- You want prediction features
- You need chatbot functionality
- You want personalized recommendations

---

## 📚 Reference

### API Documentation
- Firebase: https://firebase.google.com/docs
- SportsData.io: https://sportsdata.io/developers/api-documentation/soccer
- Google Places: https://developers.google.com/maps/documentation/places/web-service
- OpenAI: https://platform.openai.com/docs/api-reference
- Claude: https://docs.anthropic.com/claude/reference
- Stripe: https://stripe.com/docs/api

### Configuration Files
- API Keys: `lib/config/api_keys.dart`
- Firebase Options: `lib/firebase_options.dart`
- Cloud Functions: `functions/src/index.ts`
- SportsData Wrapper: `functions/src/sportsdata-wrapper.ts`

---

## ✅ Summary

**Currently Working**:
- ✅ Firebase (100% configured and working)

**Configured But Need Keys**:
- ⚠️ SportsData.io (for live scores)
- ⚠️ Google Places (for maps)

**Optional (Not Required)**:
- ❌ OpenAI (AI features)
- ❌ Claude (alternative AI)
- ❌ Stripe (payments)

**App Status**: 🎉 **Fully functional without additional APIs!**

**Next Step**: Optionally add SportsData.io and Google Places keys when needed for enhanced features.

---

**Last Updated**: December 26, 2025
**App Version**: 1.0.0+1

# App Store Connect Metadata — Non-Gambling Build

Paste these values into App Store Connect for the Pregame non-gambling resubmission. All references to predictions, odds, contests, and paid prediction tiers are removed.

---

## App Information

**App Name:** `Pregame 2026`

**Subtitle (30 chars):** `Soccer's biggest summer`

**Primary Category:** Sports

**Secondary Category:** News

---

## Description

```
Your ultimate companion for soccer's biggest summer.

Pregame is a sports-companion and editorial app for soccer fans
following the 2026 summer tournament across the USA, Canada, and
Mexico. Pregame is not a betting app, not a prediction game, and
does not involve wagers, contests, or simulated gambling of any
kind.

WHAT'S INSIDE

• Full match schedule and live scores — all 104 matches, every
  kickoff time, every venue
• AI-written pregame articles for every match — deeply-researched
  editorial journalism covering tactics, player stories, historical
  context, and team form
• Team and player profiles for all 48 participating nations
• City Guides for the 16 host cities — transit, food, neighborhoods,
  fan zones, and what's worth seeing between matches
• Venue discovery — find bars, restaurants, and watch parties
  near you on match days
• Watch Parties — create or join a group viewing with friends
• Activity Feed — share check-ins and match moments with the
  Pregame community
• iOS widgets and Live Activities for live match scores and
  countdowns on Home Screen, Lock Screen, and Dynamic Island
• Copa — an AI soccer companion you can ask anything about teams,
  players, and tournament history
• Penalty Kick Challenge — an original arcade mini-game (no
  wagering, no points, no rewards — pure casual fun)
• Full localization in English, Spanish, French, Portuguese,
  German, and Arabic

Pregame is an independent app. Not affiliated with, endorsed by,
or sponsored by any football federation, confederation, or
tournament organizer.
```

---

## Promotional Text (170 chars)

```
48 teams, 104 matches, 16 host cities. Follow every story of soccer's biggest summer — expert AI pregame articles, match schedules, venues, and your pregame crew.
```

---

## Keywords (100 chars, comma-separated, no spaces after commas)

```
soccer,football,schedule,matches,live scores,tournament,2026,teams,venues,watch party,city guide
```

**Removed (do NOT include):** predictions, picks, odds, betting, fantasy, leaderboard, contest, handicap, pool

---

## What's New (release notes for this version)

```
Pregame is now a pure sports-companion experience. We've focused
on what we do best — expert AI pregame articles, live match
schedules, team and player profiles, venue discovery, and watch
party coordination for all 48 teams across the 2026 summer
tournament.
```

---

## Age Rating Questionnaire — CRITICAL

Open **App Store Connect → App Information → Age Rating → Edit**. Confirm every answer below:

| Question | Correct Answer |
|---|---|
| Cartoon or Fantasy Violence | None |
| Realistic Violence | None |
| Prolonged Graphic or Sadistic Realistic Violence | None |
| Profanity or Crude Humor | None |
| Mature/Suggestive Themes | None |
| Horror/Fear Themes | None |
| Medical/Treatment Information | None |
| Alcohol, Tobacco, or Drug Use or References | **Infrequent/Mild** (venue listings may reference bars) |
| Simulated Gambling | **None** ← must be None |
| **Contests** | **None** ← must be None |
| **Gambling and Contests Including Skill-Based Games** | **No** ← must be No |
| Sexual Content or Nudity | None |
| Graphic Sexual Content or Nudity | None |
| Unrestricted Web Access | No |
| User Generated Content | **Yes** (Activity Feed, Watch Party chat) |

The three highlighted rows are what specifically matter for this rejection. If any of them are anything other than None/No, 2.3 will trigger again even if the binary is clean.

---

## In-App Purchases — CRITICAL

Open **App Store Connect → Your App → Features → In-App Purchases**.

**Remove or mark as "Removed from Sale":**
- Fan Pass ($14.99)
- Superfan Pass ($29.99)

These gated prediction features. Even though the build no longer surfaces them, ASC having active IAPs linked to prediction tiers will trigger the reviewer to look for them.

Watch Party Virtual Attendance IAPs (if any) can stay — those are venue-related micropayments, not prediction-gated.

---

## Resolution Center Reply

Paste this into the Resolution Center reply field:

```
Hello,

Thank you for the guidance on the simulated gambling policy.
We are submitting a revised build (1.0.86+) of Pregame as a
non-gambling app.

CHANGES IN THIS BUILD:

All prediction, odds, and paid-tier features have been removed
from the user-facing app. Specifically:

• "Make Your Prediction" modal and user-submitted picks — removed
• Prediction leaderboards and prediction stats — removed
• Prediction save/history/transaction screens — removed
• Third-party bookmaker odds display — removed
• AI win-probability percentage displays — removed
• Power rankings, dark horse picks, and analyst-prediction content
  — removed
• Fan Pass and Superfan paid tiers — removed (IAP products
  de-listed from ASC)
• Betting Perspective section in the Pregame Article tab — removed
• Prediction tab in match detail views — removed

WHAT REMAINS:

• Match schedule and live scores
• AI-written pregame editorial articles (no picks, no handicapping)
• Team and player profiles
• City Guides
• Venue discovery and watch party features
• Social features (activity feed, friends, watch party chat)
• iOS widgets and Live Activities
• Copa AI chatbot (conversational only, no predictions)
• Penalty Kick Challenge mini-game (no wagering, no rewards)

METADATA UPDATES:

• Description rewritten to remove all prediction/odds/contest
  references
• Keywords updated — no gambling-adjacent terms
• Age Rating questionnaire updated: Simulated Gambling = None,
  Contests = None
• In-App Purchases removed
• All 10 App Store screenshots swapped for captures of the new
  non-gambling UI

Independence disclaimer remains visible on the login screen and
user profile: "Pregame is an independent fan app and is not
affiliated with, endorsed by, or sponsored by any official
tournament organization."

Please review the updated submission. Thank you.

Chris Campbell
```

---

## Before hitting Submit

Pre-flight checklist:

- [ ] Codemagic build with new `FEATURE_*=false` dart-defines has succeeded and uploaded to TestFlight
- [ ] Installed on iPhone — verified no "Make Your Prediction" button appears anywhere
- [ ] Verified Pregame Article tab → no "Market View" / bettingPerspective section
- [ ] Verified no "Prediction" tab in match detail views
- [ ] Verified no "Fan Pass" icon in the top bar
- [ ] Verified no "Leaderboards" entry in the header menu
- [ ] All 10 ASC screenshots re-captured from the new build
- [ ] Description and keywords updated in ASC
- [ ] Age Rating: Simulated Gambling / Contests set to None
- [ ] Fan Pass + Superfan IAPs removed from the product list
- [ ] Resolution Center reply posted
- [ ] Submit for Review

*Updated 2026-04-22 — replaces previous ASC metadata drafts.*

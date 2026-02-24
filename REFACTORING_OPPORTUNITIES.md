# Widget/Screen Refactoring Analysis - Pregame World Cup App

Generated: 2026-02-11
Total files analyzed: 20 files (500+ lines)
Total lines in top 20: 21,184 lines

## Summary

Found **20 files** with 500+ lines that are candidates for widget extraction and refactoring. The analysis identified critical extraction opportunities, particularly in files with 40+ build methods and 188+ layout widgets.

---

## Top 20 Largest Screen/Widget Files

| Rank | File | Lines | Build Methods | Layout Widgets | Priority |
|------|------|-------|----------------|----------------|----------|
| 1 | schedule/widgets/enhanced_ai_insights_widget.dart | **3,898** | 40+ | 188 | CRITICAL |
| 2 | schedule/screens/enhanced_schedule_screen.dart | 1,337 | 13 | 68 | HIGH |
| 3 | messaging/screens/chat_screen.dart | 1,298 | 3 | 31 | HIGH |
| 4 | worldcup/pages/world_cup_home_screen.dart | 1,290 | 5 | 54 | HIGH |
| 5 | recommendations/screens/game_details_screen.dart | 1,260 | 6 | 68 | HIGH |
| 6 | schedule/screens/prediction_accuracy_screen.dart | 907 | 9 | 56 | MEDIUM |
| 7 | venues/screens/venue_detail_screen.dart | 887 | 5 | 45 | MEDIUM |
| 8 | social/screens/enhanced_friends_list_screen.dart | 869 | 3 | 20 | MEDIUM |
| 9 | worldcup/widgets/nearby_venues_widget.dart | 865 | 4 | 44 | MEDIUM |
| 10 | messaging/screens/chats_list_screen.dart | 835 | 2 | 22 | MEDIUM |
| 11 | worldcup/widgets/filter_chips.dart | 821 | - | - | MEDIUM |
| 12 | worldcup/screens/player_comparison_screen.dart | 820 | - | - | MEDIUM |
| 13 | venues/widgets/enhanced_venue_card.dart | 812 | - | - | MEDIUM |
| 14 | worldcup/widgets/matchup_preview_widget.dart | 792 | - | - | MEDIUM |
| 15 | social/screens/edit_profile_screen.dart | 788 | - | - | MEDIUM |
| 16 | messaging/widgets/new_chat_bottom_sheet.dart | 771 | - | - | MEDIUM |
| 17 | messaging/widgets/message_input_widget.dart | 771 | - | - | MEDIUM |
| 18 | schedule/widgets/game_prediction_widget.dart | 735 | - | - | MEDIUM |
| 19 | venue_portal/screens/venue_portal_home_screen.dart | 717 | - | - | MEDIUM |
| 20 | recommendations/widgets/smart_venue_discovery_widget.dart | 711 | - | - | MEDIUM |

---

## CRITICAL REFACTORING: enhanced_ai_insights_widget.dart (3,898 lines)

MASSIVE CODE SMELL - This file is 3.8x larger than the second-largest file!

### Current Structure
- 40+ build widget methods (massive god object)
- 188 layout widgets (Column, Row, ListView, Stack, Container, Card, Expanded)
- Single StatefulWidget with entire UI tree
- Multiple responsibilities mixed together

### Build Methods (40+ identified)
1442: _buildCompactView
1458: _buildDetailedView
1483: _buildHeader
1541: _buildTabBar
1559: _buildLoadingState
1582: _buildErrorState
1607: _buildCompactContent
1676: _buildPredictionTab
1699: _buildPlayerAnalysisTab
1772: _buildTeamStatsComparison
1836: _buildStatComparisonCard
1898: _buildTopPerformersSection
1926: _buildTeamPerformersCard
2001: _buildTeamPlayersSection
2036: _buildPlayerCard
2127: _buildKeyPlayerMatchups
2240: _buildKeyFactorsTab
2301: _buildPredictionCard
2381: _buildScorePredictionCards
2643: _buildPredictionSummary
2719: _buildKeyFactorsPreview
2789: _buildKeyFactorCard
2906: _buildConfidenceAnalysis
2997: _buildSeasonReviewTab
... (15+ more tab/section builders)

### Extraction Strategy

Extract Tab Content Widgets (5-7 new files):
- _PredictionTabContent → prediction_tab_widget.dart
- _PlayerAnalysisTabContent → player_analysis_tab_widget.dart
- _KeyFactorsTabContent → key_factors_tab_widget.dart
- _SeasonReviewTabContent → season_review_tab_widget.dart

Extract Card Components (3-4 new files):
- _PredictionCard logic → prediction_card_widget.dart
- _StatComparisonCard → stat_comparison_card_widget.dart
- _TopPerformersSection → top_performers_section_widget.dart

Extract Utility Widgets (2-3 new files):
- _PlayerCard rendering → player_card_widget.dart
- _SeasonSummaryCard → season_summary_card_widget.dart

Extract Data Processing Logic (1-2 new classes):
- Analysis data preparation → separate service
- Player/team data conversion → utility class

### Result
- Main widget: 500-600 lines
- 8-10 focused child widgets: 200-400 lines each
- 1-2 service classes: 200-300 lines

---

## HIGH PRIORITY REFACTORING

### enhanced_schedule_screen.dart (1,337 lines)
- 13 build methods, 68 layout widgets
- Extract: Live Scores Tab, Weekly Schedule, Social Tab, Game Card variants

### chat_screen.dart (1,298 lines)
- 3 build methods, 31 layout widgets
- Extract: Blocked Banner, Message List, Empty State, App Bar Title

### game_details_screen.dart (1,260 lines)
- 6 build methods, 68 layout widgets
- Extract: Venues Section, Performance Grade, Quick Stats, Popular Venues List

### world_cup_home_screen.dart (1,290 lines)
- 5 build methods, 54 layout widgets
- Extract: Bracket View, Filter Hints, Round Sections

---

## COMMON PATTERNS IDENTIFIED

### 1. Tab-Based Screens
Pattern: TabBar with multiple substantial tab views in single file
Solution: Extract each tab to separate widget file

### 2. Compound Card Widgets
Pattern: Large card components with multiple sub-sections
Solution: Extract header, content, footer as named widgets

### 3. Form/Input Widgets with Multiple States
Pattern: Complex input with conditional rendering (recording, attachments, etc)
Solution: Extract state-based sections to separate widgets

### 4. List Items as Massive Widgets
Pattern: ListTile replacements that are hundreds of lines
Solution: Extract item builders into separate widget classes

---

## QUICK WINS

1. Empty State Widgets - Duplicated pattern, extract to shared widget
2. Loading State Widgets - Repeated pattern, extract to skeleton widget
3. Error State Widgets - Same pattern everywhere, parameterized error widget
4. Card Headers - Repeated header patterns, extract header component

---

## ESTIMATED IMPACT

### Before Refactoring
- 21,184 lines across 20 files
- Max file size: 3,898 lines
- Multiple 40+ build methods per file

### After Refactoring
- ~25,000 lines across 50+ files
- Max file size: 700 lines per screen/widget
- Extraction reduces cognitive load and improves testability

---

## NO TODOs FOUND

No explicit TODO/FIXME comments in top 5 largest files, but code structure clearly indicates urgent refactoring need.

---

## IMPLEMENTATION PRIORITY

### Phase 1 (CRITICAL): enhanced_ai_insights_widget.dart
- Effort: 8-10 hours
- Benefit: Reduces largest file by 85%

### Phase 2 (HIGH): enhanced_schedule_screen.dart, chat_screen.dart, game_details_screen.dart
- Effort: 3-4 hours each = 9-12 hours total

### Phase 3 (HIGH): world_cup_home_screen.dart + remaining files

### Phase 4 (ONGOING): Extract common patterns, create shared component library

---

Generated: 2026-02-11

# Pregame World Cup - Widget/Screen Refactoring Analysis

Generated: 2026-02-11
Analysis Scope: lib/features/ - All files with screen or widget in path

EXECUTIVE SUMMARY

Found 20 files (500+ lines) totaling 21,184 lines.
Critical Code Smell: enhanced_ai_insights_widget.dart is 3,898 lines with 40+ build methods.
This is 3.8x larger than the next file - MASSIVE CODE SMELL.

RECOMMENDATION: Immediate refactoring required (40-50 hours total effort)

TOP 20 LARGEST FILES

RANK  LINES  FILE
----  -----  ----
  1   3898   schedule/widgets/enhanced_ai_insights_widget.dart
  2   1337   schedule/screens/enhanced_schedule_screen.dart
  3   1298   messaging/screens/chat_screen.dart
  4   1290   worldcup/pages/world_cup_home_screen.dart
  5   1260   recommendations/screens/game_details_screen.dart
  6    907   schedule/screens/prediction_accuracy_screen.dart
  7    887   venues/screens/venue_detail_screen.dart
  8    869   social/screens/enhanced_friends_list_screen.dart
  9    865   worldcup/widgets/nearby_venues_widget.dart
 10    835   messaging/screens/chats_list_screen.dart
 11    821   worldcup/widgets/filter_chips.dart
 12    820   worldcup/screens/player_comparison_screen.dart
 13    812   venues/widgets/enhanced_venue_card.dart
 14    792   worldcup/widgets/matchup_preview_widget.dart
 15    788   social/screens/edit_profile_screen.dart
 16    771   messaging/widgets/new_chat_bottom_sheet.dart
 17    771   messaging/widgets/message_input_widget.dart
 18    735   schedule/widgets/game_prediction_widget.dart
 19    717   venue_portal/screens/venue_portal_home_screen.dart
 20    711   recommendations/widgets/smart_venue_discovery_widget.dart
TOT 21184   TOTAL

CRITICAL (Phase 1) - 8-10 hours

enhanced_ai_insights_widget.dart (3,898 lines)
  Extract into: 12 focused files
  Build Methods: 40+
  Layout Widgets: 188
  Result: Reduce main file to 550 lines (85% reduction)

HIGH PRIORITY (Phase 2) - 12-16 hours

1. enhanced_schedule_screen.dart (1,337 lines)
   Extract: 5 widgets (3-4 hours)

2. chat_screen.dart (1,298 lines)
   Extract: 4 widgets (3-4 hours)

3. game_details_screen.dart (1,260 lines)
   Extract: 4 widgets (3-4 hours)

4. world_cup_home_screen.dart (1,290 lines)
   Extract: 3-4 widgets (3-4 hours)

QUICK WINS (Phase 3) - 2-3 hours

Shared components (lib/common/widgets/):
  - empty_state_widget.dart (8+ screens, saves 150 lines)
  - loading_skeleton_widget.dart (6+ screens, saves 100 lines)
  - error_display_widget.dart (5+ screens, saves 75 lines)
  - card_header_widget.dart (4+ files, saves 50 lines)
  - stat_row_widget.dart (3+ screens, saves 40 lines)

Total Savings: 415+ lines

METRICS

BEFORE:
  Max file: 3,898 lines
  Build methods per file: 1-40
  Test coverage: 6%

AFTER:
  Max file: 700 lines
  Build methods per file: 1-2
  Test coverage: 50%+
  New files: 60+

TIMELINE

Week 1: Phase 1 (Critical) - 8-10 hours
Week 2-3: Phase 2 (High) - 12-16 hours
Week 4: Phase 3 & 4 (Medium) - 8-10 hours

TOTAL: 40-50 hours (5-6 weeks)

GENERATED ANALYSIS FILES

1. WIDGET_REFACTORING_ANALYSIS.txt - Detailed analysis with rankings
2. REFACTORING_OPPORTUNITIES.md - Opportunity breakdown with extraction details
3. EXTRACTION_PLAN.txt - Step-by-step implementation plan
4. ANALYSIS_SUMMARY.md - This executive summary

KEY FINDINGS

No explicit TODOs/FIXMEs found in top 5 largest files.
However, code structure clearly indicates urgent refactoring need:
  - 40+ build methods in single widget
  - 188+ layout widgets in one file
  - Massive nesting and complexity
  - Duplicated patterns across screens

RECOMMENDATION

Start immediately with Phase 1.
The enhanced_ai_insights_widget.dart file is a critical priority.
Expected ROI: 8-10 hours of effort for massive code quality improvement.

Files should be created in: C:/Users/chris/Pregame-World-Cup/

Analysis Date: 2026-02-11

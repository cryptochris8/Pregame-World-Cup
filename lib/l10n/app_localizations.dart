import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// Title for Player Spotlight screen
  ///
  /// In en, this message translates to:
  /// **'Player Spotlight'**
  String get playerSpotlight;

  /// Label for players
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get players;

  /// Hint text for player search field
  ///
  /// In en, this message translates to:
  /// **'Search players...'**
  String get searchPlayers;

  /// Refresh button tooltip
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// Filter option for all teams
  ///
  /// In en, this message translates to:
  /// **'All Teams'**
  String get allTeams;

  /// Filter option for goalkeepers
  ///
  /// In en, this message translates to:
  /// **'Goalkeepers'**
  String get goalkeepers;

  /// Filter option for defenders
  ///
  /// In en, this message translates to:
  /// **'Defenders'**
  String get defenders;

  /// Filter option for midfielders
  ///
  /// In en, this message translates to:
  /// **'Midfielders'**
  String get midfielders;

  /// Filter option for forwards
  ///
  /// In en, this message translates to:
  /// **'Forwards'**
  String get forwards;

  /// Filter option for top value players
  ///
  /// In en, this message translates to:
  /// **'Top Value'**
  String get topValue;

  /// Filter option for top scorers
  ///
  /// In en, this message translates to:
  /// **'Top Scorers'**
  String get topScorers;

  /// Filter option for most capped players
  ///
  /// In en, this message translates to:
  /// **'Most Capped'**
  String get mostCapped;

  /// Number of players displayed
  ///
  /// In en, this message translates to:
  /// **'{count} players'**
  String playersCount(int count);

  /// Button to clear all filters
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// Message when no players are found
  ///
  /// In en, this message translates to:
  /// **'No players found'**
  String get noPlayersFound;

  /// Section title for career statistics
  ///
  /// In en, this message translates to:
  /// **'Career Statistics'**
  String get careerStatistics;

  /// Label for international caps
  ///
  /// In en, this message translates to:
  /// **'International Caps'**
  String get internationalCaps;

  /// Label for international goals
  ///
  /// In en, this message translates to:
  /// **'International Goals'**
  String get internationalGoals;

  /// Label for international assists
  ///
  /// In en, this message translates to:
  /// **'International Assists'**
  String get internationalAssists;

  /// Label for World Cup appearances
  ///
  /// In en, this message translates to:
  /// **'World Cup Appearances'**
  String get worldCupAppearances;

  /// Label for World Cup goals
  ///
  /// In en, this message translates to:
  /// **'World Cup Goals'**
  String get worldCupGoals;

  /// Label for previous World Cups
  ///
  /// In en, this message translates to:
  /// **'Previous World Cups'**
  String get previousWorldCups;

  /// Section title for honors
  ///
  /// In en, this message translates to:
  /// **'Honors'**
  String get honors;

  /// Section title for profile
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Label for strengths
  ///
  /// In en, this message translates to:
  /// **'Strengths:'**
  String get strengths;

  /// Label for weaknesses
  ///
  /// In en, this message translates to:
  /// **'Weaknesses:'**
  String get weaknesses;

  /// Section title for play style
  ///
  /// In en, this message translates to:
  /// **'Play Style'**
  String get playStyle;

  /// Section title for key moment
  ///
  /// In en, this message translates to:
  /// **'Key Moment'**
  String get keyMoment;

  /// Section title for comparison to legend
  ///
  /// In en, this message translates to:
  /// **'Comparison to Legend'**
  String get comparisonToLegend;

  /// Section title for World Cup 2026 prediction
  ///
  /// In en, this message translates to:
  /// **'World Cup 2026 Prediction'**
  String get worldCup2026Prediction;

  /// Section title for fun facts
  ///
  /// In en, this message translates to:
  /// **'Fun Facts'**
  String get funFacts;

  /// Title for Manager Profiles screen
  ///
  /// In en, this message translates to:
  /// **'Manager Profiles'**
  String get managerProfiles;

  /// Label for managers
  ///
  /// In en, this message translates to:
  /// **'Managers'**
  String get managers;

  /// Hint text for manager search field
  ///
  /// In en, this message translates to:
  /// **'Search managers...'**
  String get searchManagers;

  /// Filter option for all managers
  ///
  /// In en, this message translates to:
  /// **'All Managers'**
  String get allManagers;

  /// Filter option for most experienced managers
  ///
  /// In en, this message translates to:
  /// **'Most Experienced'**
  String get mostExperienced;

  /// Filter option for youngest managers
  ///
  /// In en, this message translates to:
  /// **'Youngest'**
  String get youngest;

  /// Filter option for oldest managers
  ///
  /// In en, this message translates to:
  /// **'Oldest'**
  String get oldest;

  /// Filter option for highest win percentage
  ///
  /// In en, this message translates to:
  /// **'Highest Win %'**
  String get highestWinPercentage;

  /// Filter option for most titles
  ///
  /// In en, this message translates to:
  /// **'Most Titles'**
  String get mostTitles;

  /// Filter option for World Cup winners
  ///
  /// In en, this message translates to:
  /// **'WC Winners'**
  String get wcWinners;

  /// Filter option for controversial managers
  ///
  /// In en, this message translates to:
  /// **'Controversial'**
  String get controversial;

  /// Number of managers displayed
  ///
  /// In en, this message translates to:
  /// **'{count} managers'**
  String managersCount(int count);

  /// Message when no managers are found
  ///
  /// In en, this message translates to:
  /// **'No managers found'**
  String get noManagersFound;

  /// Section title for managerial record
  ///
  /// In en, this message translates to:
  /// **'Managerial Record'**
  String get managerialRecord;

  /// Label for matches managed
  ///
  /// In en, this message translates to:
  /// **'Matches Managed'**
  String get matchesManaged;

  /// Label for win-draw-loss record
  ///
  /// In en, this message translates to:
  /// **'Record (W-D-L)'**
  String get recordWDL;

  /// Label for win percentage
  ///
  /// In en, this message translates to:
  /// **'Win Percentage'**
  String get winPercentage;

  /// Label for titles won
  ///
  /// In en, this message translates to:
  /// **'Titles Won'**
  String get titlesWon;

  /// Label for career started year
  ///
  /// In en, this message translates to:
  /// **'Career Started'**
  String get careerStarted;

  /// Label for years in current role
  ///
  /// In en, this message translates to:
  /// **'Years in Current Role'**
  String get yearsInCurrentRole;

  /// Section title for tactical approach
  ///
  /// In en, this message translates to:
  /// **'Tactical Approach'**
  String get tacticalApproach;

  /// Label for formation
  ///
  /// In en, this message translates to:
  /// **'Formation:'**
  String get formation;

  /// Label for philosophy
  ///
  /// In en, this message translates to:
  /// **'Philosophy:'**
  String get philosophy;

  /// Section title for honors and achievements
  ///
  /// In en, this message translates to:
  /// **'Honors & Achievements'**
  String get honorsAchievements;

  /// Section title for profile analysis
  ///
  /// In en, this message translates to:
  /// **'Profile Analysis'**
  String get profileAnalysis;

  /// Section title for manager style
  ///
  /// In en, this message translates to:
  /// **'Manager Style'**
  String get managerStyle;

  /// Section title for defining moment
  ///
  /// In en, this message translates to:
  /// **'Defining Moment'**
  String get definingMoment;

  /// Section title for famous quote
  ///
  /// In en, this message translates to:
  /// **'Famous Quote'**
  String get famousQuote;

  /// Section title for World Cup 2026 outlook
  ///
  /// In en, this message translates to:
  /// **'World Cup 2026 Outlook'**
  String get worldCup2026Outlook;

  /// Section title for previous clubs
  ///
  /// In en, this message translates to:
  /// **'Previous Clubs'**
  String get previousClubs;

  /// Section title for controversies
  ///
  /// In en, this message translates to:
  /// **'Controversies'**
  String get controversies;

  /// Section title for trivia
  ///
  /// In en, this message translates to:
  /// **'Did You Know?'**
  String get didYouKnow;

  /// Label for tactical style
  ///
  /// In en, this message translates to:
  /// **'Tactical Style'**
  String get tacticalStyle;

  /// Tab label for matches
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get matches;

  /// Tab label for groups
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groups;

  /// Tab label for bracket
  ///
  /// In en, this message translates to:
  /// **'Bracket'**
  String get bracket;

  /// Tab label for teams
  ///
  /// In en, this message translates to:
  /// **'Teams'**
  String get teams;

  /// Tab label for favorites
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// Title for FIFA World Cup
  ///
  /// In en, this message translates to:
  /// **'FIFA World Cup'**
  String get fifaWorldCup;

  /// Label for live matches
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get live;

  /// Live matches count
  ///
  /// In en, this message translates to:
  /// **'{count} Live'**
  String liveCount(int count);

  /// Message when no matches scheduled for today
  ///
  /// In en, this message translates to:
  /// **'No matches scheduled for today'**
  String get noMatchesScheduledToday;

  /// Message when no live matches
  ///
  /// In en, this message translates to:
  /// **'No live matches right now'**
  String get noLiveMatchesRightNow;

  /// Message when no upcoming matches
  ///
  /// In en, this message translates to:
  /// **'No upcoming matches'**
  String get noUpcomingMatches;

  /// Message when no completed matches
  ///
  /// In en, this message translates to:
  /// **'No completed matches yet'**
  String get noCompletedMatchesYet;

  /// Message when no matches found
  ///
  /// In en, this message translates to:
  /// **'No matches found'**
  String get noMatchesFound;

  /// Message when no favorite matches
  ///
  /// In en, this message translates to:
  /// **'No favorite matches yet'**
  String get noFavoriteMatchesYet;

  /// Message when no group data available
  ///
  /// In en, this message translates to:
  /// **'No group data available'**
  String get noGroupDataAvailable;

  /// Message when knockout bracket not available
  ///
  /// In en, this message translates to:
  /// **'Knockout bracket not available yet'**
  String get knockoutBracketNotAvailableYet;

  /// Message to check back after group stage
  ///
  /// In en, this message translates to:
  /// **'Check back after group stage'**
  String get checkBackAfterGroupStage;

  /// Message when no favorite teams
  ///
  /// In en, this message translates to:
  /// **'No favorite teams yet'**
  String get noFavoriteTeamsYet;

  /// Instruction to add favorites
  ///
  /// In en, this message translates to:
  /// **'Tap the heart icon on any team to add it to your favorites'**
  String get tapHeartIconToAddFavorites;

  /// Teams count display
  ///
  /// In en, this message translates to:
  /// **'{count} of 48 teams'**
  String teamsCount(int count);

  /// Button to clear filters
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// Message when no favorites
  ///
  /// In en, this message translates to:
  /// **'No Favorites Yet'**
  String get noFavoritesYet;

  /// Message to add favorites
  ///
  /// In en, this message translates to:
  /// **'Tap the heart icon on any match or team\nto add them to your favorites'**
  String get tapHeartIconMessage;

  /// Button to browse matches
  ///
  /// In en, this message translates to:
  /// **'Browse Matches'**
  String get browseMatches;

  /// Button to browse teams
  ///
  /// In en, this message translates to:
  /// **'Browse Teams'**
  String get browseTeams;

  /// Button to view all predictions
  ///
  /// In en, this message translates to:
  /// **'View All Predictions'**
  String get viewAllPredictions;

  /// Section title for favorite matches
  ///
  /// In en, this message translates to:
  /// **'Favorite Matches'**
  String get favoriteMatches;

  /// Section title for favorite teams
  ///
  /// In en, this message translates to:
  /// **'Favorite Teams'**
  String get favoriteTeams;

  /// Loading message
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// Error message
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Retry button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No data found message
  ///
  /// In en, this message translates to:
  /// **'No data found'**
  String get noDataFound;

  /// Search label
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Filter label
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// Error message when loading players fails
  ///
  /// In en, this message translates to:
  /// **'Error loading players: {error}'**
  String errorLoadingPlayers(String error);

  /// Error message when filtering players fails
  ///
  /// In en, this message translates to:
  /// **'Error filtering players: {error}'**
  String errorFilteringPlayers(String error);

  /// Error message when loading managers fails
  ///
  /// In en, this message translates to:
  /// **'Error loading managers: {error}'**
  String errorLoadingManagers(String error);

  /// Error message when filtering managers fails
  ///
  /// In en, this message translates to:
  /// **'Error filtering managers: {error}'**
  String errorFilteringManagers(String error);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

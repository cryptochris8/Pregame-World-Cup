import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_pt.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('es'),
    Locale('fr'),
    Locale('pt')
  ];

  /// App title
  ///
  /// In en, this message translates to:
  /// **'Pregame World Cup'**
  String get appTitle;

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

  /// Watch party feature title
  ///
  /// In en, this message translates to:
  /// **'Watch Party'**
  String get watchParty;

  /// Watch parties list title
  ///
  /// In en, this message translates to:
  /// **'Watch Parties'**
  String get watchParties;

  /// Create watch party button
  ///
  /// In en, this message translates to:
  /// **'Create Watch Party'**
  String get createWatchParty;

  /// Join watch party button
  ///
  /// In en, this message translates to:
  /// **'Join Watch Party'**
  String get joinWatchParty;

  /// Leave watch party button
  ///
  /// In en, this message translates to:
  /// **'Leave Watch Party'**
  String get leaveWatchParty;

  /// Hosting watch party label
  ///
  /// In en, this message translates to:
  /// **'Hosting Watch Party'**
  String get hostingWatchParty;

  /// Attendees label
  ///
  /// In en, this message translates to:
  /// **'Attendees'**
  String get attendees;

  /// Number of attendees
  ///
  /// In en, this message translates to:
  /// **'{count} attendees'**
  String attendeesCount(int count);

  /// Spots remaining
  ///
  /// In en, this message translates to:
  /// **'{count} spots remaining'**
  String spotsRemaining(int count);

  /// Watch party full message
  ///
  /// In en, this message translates to:
  /// **'Watch Party Full'**
  String get watchPartyFull;

  /// Private watch party label
  ///
  /// In en, this message translates to:
  /// **'Private Watch Party'**
  String get privateWatchParty;

  /// Public watch party label
  ///
  /// In en, this message translates to:
  /// **'Public Watch Party'**
  String get publicWatchParty;

  /// Predictions feature title
  ///
  /// In en, this message translates to:
  /// **'Predictions'**
  String get predictions;

  /// Make prediction button
  ///
  /// In en, this message translates to:
  /// **'Make Prediction'**
  String get makePrediction;

  /// Your prediction label
  ///
  /// In en, this message translates to:
  /// **'Your Prediction'**
  String get yourPrediction;

  /// Prediction saved confirmation
  ///
  /// In en, this message translates to:
  /// **'Prediction saved!'**
  String get predictionSaved;

  /// Confidence label
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get confidence;

  /// Winner label
  ///
  /// In en, this message translates to:
  /// **'Winner'**
  String get winner;

  /// Draw label
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get draw;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Language setting
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Select language title
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Spanish language option
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// Portuguese language option
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get portuguese;

  /// French language option
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// System default language option
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// Notifications setting
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Notification preferences title
  ///
  /// In en, this message translates to:
  /// **'Notification Preferences'**
  String get notificationPreferences;

  /// Match reminders setting
  ///
  /// In en, this message translates to:
  /// **'Match Reminders'**
  String get matchReminders;

  /// Goal alerts setting
  ///
  /// In en, this message translates to:
  /// **'Goal Alerts'**
  String get goalAlerts;

  /// Live score updates setting
  ///
  /// In en, this message translates to:
  /// **'Live Score Updates'**
  String get liveScoreUpdates;

  /// Dark mode setting
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Accessibility settings
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get accessibility;

  /// High contrast mode
  ///
  /// In en, this message translates to:
  /// **'High Contrast'**
  String get highContrast;

  /// Reduce motion setting
  ///
  /// In en, this message translates to:
  /// **'Reduce Motion'**
  String get reduceMotion;

  /// Bold text setting
  ///
  /// In en, this message translates to:
  /// **'Bold Text'**
  String get boldText;

  /// About section
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Version label
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// Privacy policy link
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Terms of service link
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// Contact support link
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// Sign out button
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// Delete account button
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// Share button
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Share to Twitter option
  ///
  /// In en, this message translates to:
  /// **'Share to Twitter/X'**
  String get shareToTwitter;

  /// Share to Facebook option
  ///
  /// In en, this message translates to:
  /// **'Share to Facebook'**
  String get shareToFacebook;

  /// Share to WhatsApp option
  ///
  /// In en, this message translates to:
  /// **'Share to WhatsApp'**
  String get shareToWhatsApp;

  /// Share to Instagram option
  ///
  /// In en, this message translates to:
  /// **'Share to Instagram'**
  String get shareToInstagram;

  /// Copy link option
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get copyLink;

  /// Link copied confirmation
  ///
  /// In en, this message translates to:
  /// **'Link copied to clipboard'**
  String get linkCopied;

  /// More apps share option
  ///
  /// In en, this message translates to:
  /// **'More Apps'**
  String get moreApps;

  /// Share as image option
  ///
  /// In en, this message translates to:
  /// **'Share as Image'**
  String get shareAsImage;

  /// Add to calendar button
  ///
  /// In en, this message translates to:
  /// **'Add to Calendar'**
  String get addToCalendar;

  /// Google Calendar option
  ///
  /// In en, this message translates to:
  /// **'Google Calendar'**
  String get googleCalendar;

  /// Apple Calendar option
  ///
  /// In en, this message translates to:
  /// **'Apple Calendar'**
  String get appleCalendar;

  /// Download ICS file option
  ///
  /// In en, this message translates to:
  /// **'Download .ics File'**
  String get downloadIcs;

  /// Export all matches button
  ///
  /// In en, this message translates to:
  /// **'Export All Matches'**
  String get exportAllMatches;

  /// Export favorite matches button
  ///
  /// In en, this message translates to:
  /// **'Export Favorite Matches'**
  String get exportFavoriteMatches;

  /// Chat label
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// Match chat title
  ///
  /// In en, this message translates to:
  /// **'Match Chat'**
  String get matchChat;

  /// Send message hint
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get sendMessage;

  /// Type message placeholder
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessage;

  /// Join chat button
  ///
  /// In en, this message translates to:
  /// **'Join Chat'**
  String get joinChat;

  /// Leave chat button
  ///
  /// In en, this message translates to:
  /// **'Leave Chat'**
  String get leaveChat;

  /// Chat participants count
  ///
  /// In en, this message translates to:
  /// **'{count} participants'**
  String chatParticipants(int count);

  /// Venue label
  ///
  /// In en, this message translates to:
  /// **'Venue'**
  String get venue;

  /// Venues label
  ///
  /// In en, this message translates to:
  /// **'Venues'**
  String get venues;

  /// Stadium label
  ///
  /// In en, this message translates to:
  /// **'Stadium'**
  String get stadium;

  /// Capacity label
  ///
  /// In en, this message translates to:
  /// **'Capacity'**
  String get capacity;

  /// Location label
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// Get directions button
  ///
  /// In en, this message translates to:
  /// **'Get Directions'**
  String get getDirections;

  /// Nearby venues title
  ///
  /// In en, this message translates to:
  /// **'Nearby Venues'**
  String get nearbyVenues;

  /// Find bars button
  ///
  /// In en, this message translates to:
  /// **'Find Bars'**
  String get findBars;

  /// Find restaurants button
  ///
  /// In en, this message translates to:
  /// **'Find Restaurants'**
  String get findRestaurants;

  /// Kickoff label
  ///
  /// In en, this message translates to:
  /// **'Kickoff'**
  String get kickoff;

  /// Full time label
  ///
  /// In en, this message translates to:
  /// **'Full Time'**
  String get fullTime;

  /// Half time label
  ///
  /// In en, this message translates to:
  /// **'Half Time'**
  String get halfTime;

  /// Extra time label
  ///
  /// In en, this message translates to:
  /// **'Extra Time'**
  String get extraTime;

  /// Penalties label
  ///
  /// In en, this message translates to:
  /// **'Penalties'**
  String get penalties;

  /// Postponed label
  ///
  /// In en, this message translates to:
  /// **'Postponed'**
  String get postponed;

  /// Cancelled label
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// Upcoming label
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// Completed label
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// Today label
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Tomorrow label
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// Yesterday label
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// Group stage label
  ///
  /// In en, this message translates to:
  /// **'Group Stage'**
  String get groupStage;

  /// Round of 32 label
  ///
  /// In en, this message translates to:
  /// **'Round of 32'**
  String get roundOf32;

  /// Round of 16 label
  ///
  /// In en, this message translates to:
  /// **'Round of 16'**
  String get roundOf16;

  /// Quarter finals label
  ///
  /// In en, this message translates to:
  /// **'Quarter Finals'**
  String get quarterFinals;

  /// Semi finals label
  ///
  /// In en, this message translates to:
  /// **'Semi Finals'**
  String get semiFinals;

  /// Third place playoff label
  ///
  /// In en, this message translates to:
  /// **'Third Place'**
  String get thirdPlace;

  /// Final label
  ///
  /// In en, this message translates to:
  /// **'Final'**
  String get final_;

  /// Matches played abbreviation
  ///
  /// In en, this message translates to:
  /// **'Played'**
  String get played;

  /// Matches won abbreviation
  ///
  /// In en, this message translates to:
  /// **'Won'**
  String get won;

  /// Matches drawn abbreviation
  ///
  /// In en, this message translates to:
  /// **'Drawn'**
  String get drawn;

  /// Matches lost abbreviation
  ///
  /// In en, this message translates to:
  /// **'Lost'**
  String get lost;

  /// Goals for label
  ///
  /// In en, this message translates to:
  /// **'Goals For'**
  String get goalsFor;

  /// Goals against label
  ///
  /// In en, this message translates to:
  /// **'Goals Against'**
  String get goalsAgainst;

  /// Goal difference abbreviation
  ///
  /// In en, this message translates to:
  /// **'Goal Diff'**
  String get goalDifference;

  /// Points label
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get points;

  /// Invite friends button
  ///
  /// In en, this message translates to:
  /// **'Invite Friends'**
  String get inviteFriends;

  /// Referral code label
  ///
  /// In en, this message translates to:
  /// **'Referral Code'**
  String get referralCode;

  /// Your referral code label
  ///
  /// In en, this message translates to:
  /// **'Your Referral Code'**
  String get yourReferralCode;

  /// Premium label
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// Superfan Pass product name
  ///
  /// In en, this message translates to:
  /// **'Superfan Pass'**
  String get superfanPass;

  /// Upgrade to premium button
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremium;

  /// Premium features title
  ///
  /// In en, this message translates to:
  /// **'Premium Features'**
  String get premiumFeatures;

  /// Restore purchases button
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restorePurchases;

  /// OK button
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Edit button
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Done button
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Close button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Back button
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Next button
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Continue button
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue_;

  /// Confirm button
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Submit button
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// See all button
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// View more button
  ///
  /// In en, this message translates to:
  /// **'View More'**
  String get viewMore;

  /// Show less button
  ///
  /// In en, this message translates to:
  /// **'Show Less'**
  String get showLess;

  /// Widget settings screen title
  ///
  /// In en, this message translates to:
  /// **'Widget Settings'**
  String get widgetSettings;

  /// Widget settings description
  ///
  /// In en, this message translates to:
  /// **'Configure home screen widgets'**
  String get widgetSettingsDescription;

  /// Add widget instruction title
  ///
  /// In en, this message translates to:
  /// **'Add Widget to Home Screen'**
  String get addWidgetToHomeScreen;

  /// Instructions for adding widget
  ///
  /// In en, this message translates to:
  /// **'Long press on your home screen, tap the + button, search for \'Pregame World Cup\', and select a widget size.'**
  String get widgetInstructions;

  /// Display settings section title
  ///
  /// In en, this message translates to:
  /// **'Display Settings'**
  String get displaySettings;

  /// Show live scores toggle
  ///
  /// In en, this message translates to:
  /// **'Show Live Scores'**
  String get showLiveScores;

  /// Show live scores description
  ///
  /// In en, this message translates to:
  /// **'Display live match scores on widget'**
  String get showLiveScoresDescription;

  /// Show upcoming matches toggle
  ///
  /// In en, this message translates to:
  /// **'Show Upcoming Matches'**
  String get showUpcomingMatches;

  /// Show upcoming matches description
  ///
  /// In en, this message translates to:
  /// **'Display upcoming matches on widget'**
  String get showUpcomingMatchesDescription;

  /// Compact mode toggle
  ///
  /// In en, this message translates to:
  /// **'Compact Mode'**
  String get compactMode;

  /// Compact mode description
  ///
  /// In en, this message translates to:
  /// **'Use smaller text and spacing'**
  String get compactModeDescription;

  /// Number of matches section title
  ///
  /// In en, this message translates to:
  /// **'Number of Matches'**
  String get numberOfMatches;

  /// Upcoming matches count
  ///
  /// In en, this message translates to:
  /// **'Show {count} upcoming matches'**
  String upcomingMatchesCount(int count);

  /// Match count description
  ///
  /// In en, this message translates to:
  /// **'More matches require a larger widget size'**
  String get matchCountDescription;

  /// Favorite team section title
  ///
  /// In en, this message translates to:
  /// **'Favorite Team'**
  String get favoriteTeam;

  /// Favorite team description
  ///
  /// In en, this message translates to:
  /// **'Prioritize matches for this team'**
  String get favoriteTeamDescription;

  /// No team selected message
  ///
  /// In en, this message translates to:
  /// **'No team selected'**
  String get noTeamSelected;

  /// Select favorite team title
  ///
  /// In en, this message translates to:
  /// **'Select Favorite Team'**
  String get selectFavoriteTeam;

  /// Clear favorite team button
  ///
  /// In en, this message translates to:
  /// **'Clear Favorite Team'**
  String get clearFavoriteTeam;

  /// Widget preview section title
  ///
  /// In en, this message translates to:
  /// **'Widget Preview'**
  String get widgetPreview;

  /// Refresh widget button
  ///
  /// In en, this message translates to:
  /// **'Refresh Widget'**
  String get refreshWidget;

  /// Fan pass screen title
  ///
  /// In en, this message translates to:
  /// **'World Cup 2026 Pass'**
  String get worldCup2026Pass;

  /// Transaction history tooltip
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get transactionHistory;

  /// Snackbar when checking purchase after browser checkout
  ///
  /// In en, this message translates to:
  /// **'Checking purchase status...'**
  String get checkingPurchaseStatus;

  /// Success message when pass is activated
  ///
  /// In en, this message translates to:
  /// **'{passName} activated successfully!'**
  String passActivatedSuccessfully(String passName);

  /// Error when user not signed in for purchase
  ///
  /// In en, this message translates to:
  /// **'Please sign in to purchase'**
  String get pleaseSignInToPurchase;

  /// Success message after purchase
  ///
  /// In en, this message translates to:
  /// **'{passName} purchased successfully!'**
  String passPurchasedSuccessfully(String passName);

  /// Message when user needs to complete purchase in browser
  ///
  /// In en, this message translates to:
  /// **'Complete your purchase in the browser. Your pass will activate automatically.'**
  String get completePurchaseInBrowser;

  /// Error message when purchase fails
  ///
  /// In en, this message translates to:
  /// **'Purchase failed. Please try again.'**
  String get purchaseFailedRetry;

  /// Error when user not signed in for restore
  ///
  /// In en, this message translates to:
  /// **'Please sign in to restore purchases'**
  String get pleaseSignInToRestore;

  /// Success message when pass is restored
  ///
  /// In en, this message translates to:
  /// **'{passName} restored successfully!'**
  String passRestoredSuccessfully(String passName);

  /// Message when no purchases to restore
  ///
  /// In en, this message translates to:
  /// **'No previous purchases found'**
  String get noPreviousPurchases;

  /// Error restoring purchases
  ///
  /// In en, this message translates to:
  /// **'Failed to restore purchases'**
  String get failedToRestorePurchases;

  /// Free tier feature
  ///
  /// In en, this message translates to:
  /// **'Match schedules & results'**
  String get matchSchedulesResults;

  /// Free tier feature
  ///
  /// In en, this message translates to:
  /// **'Venue discovery'**
  String get venueDiscovery;

  /// Free tier feature
  ///
  /// In en, this message translates to:
  /// **'Basic notifications'**
  String get basicNotifications;

  /// Free tier feature
  ///
  /// In en, this message translates to:
  /// **'Follow teams'**
  String get followTeams;

  /// Premium feature
  ///
  /// In en, this message translates to:
  /// **'Ad-free experience'**
  String get adFreeExperience;

  /// Premium feature
  ///
  /// In en, this message translates to:
  /// **'Advanced stats'**
  String get advancedStats;

  /// Premium feature
  ///
  /// In en, this message translates to:
  /// **'Custom alerts'**
  String get customAlerts;

  /// Fan pass tier feature
  ///
  /// In en, this message translates to:
  /// **'Everything in Free'**
  String get everythingInFree;

  /// Fan pass feature
  ///
  /// In en, this message translates to:
  /// **'Advanced match stats'**
  String get advancedMatchStats;

  /// Fan pass feature
  ///
  /// In en, this message translates to:
  /// **'Custom match alerts'**
  String get customMatchAlerts;

  /// Fan pass feature
  ///
  /// In en, this message translates to:
  /// **'Advanced social features'**
  String get advancedSocialFeatures;

  /// Premium feature
  ///
  /// In en, this message translates to:
  /// **'Exclusive content'**
  String get exclusiveContent;

  /// Superfan feature
  ///
  /// In en, this message translates to:
  /// **'AI match insights'**
  String get aiMatchInsights;

  /// Superfan tier feature
  ///
  /// In en, this message translates to:
  /// **'Everything in Fan Pass'**
  String get everythingInFanPass;

  /// Superfan feature
  ///
  /// In en, this message translates to:
  /// **'Priority features'**
  String get priorityFeatures;

  /// Superfan feature
  ///
  /// In en, this message translates to:
  /// **'Downloadable content'**
  String get downloadableContent;

  /// Superfan feature
  ///
  /// In en, this message translates to:
  /// **'Early access to new features'**
  String get earlyAccessFeatures;

  /// Login screen title for returning users
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// Login screen title for new users
  ///
  /// In en, this message translates to:
  /// **'Join Pregame'**
  String get joinPregame;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Email field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Password field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// Email validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// Password validation error
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// Sign in button
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// Create account button
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// Prompt to sign up
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// Prompt to sign in
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// Sign up link
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// App tagline
  ///
  /// In en, this message translates to:
  /// **'Where Sports Fans Connect'**
  String get whereSportsFansConnect;

  /// Email verification screen title
  ///
  /// In en, this message translates to:
  /// **'Verify Your Email'**
  String get verifyYourEmail;

  /// Verification email sent message
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a verification link to:'**
  String get verificationLinkSent;

  /// Instruction to click verification link
  ///
  /// In en, this message translates to:
  /// **'Click the link in your email to verify your account.'**
  String get clickLinkToVerify;

  /// Spam folder tip
  ///
  /// In en, this message translates to:
  /// **'Check your spam folder if you don\'t see it.'**
  String get checkSpamFolder;

  /// Manual verification check button
  ///
  /// In en, this message translates to:
  /// **'I\'ve Verified My Email'**
  String get iveVerifiedMyEmail;

  /// Resend verification email button
  ///
  /// In en, this message translates to:
  /// **'Resend Email'**
  String get resendEmail;

  /// Resend cooldown timer
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String resendInSeconds(int seconds);

  /// Success message after email verification
  ///
  /// In en, this message translates to:
  /// **'Email verified! Redirecting...'**
  String get emailVerifiedRedirecting;

  /// Message when email not yet verified
  ///
  /// In en, this message translates to:
  /// **'Email not verified yet. Please check your inbox.'**
  String get emailNotVerifiedYet;

  /// Confirmation after resending verification
  ///
  /// In en, this message translates to:
  /// **'Verification email sent!'**
  String get verificationEmailSent;

  /// Error resending verification email
  ///
  /// In en, this message translates to:
  /// **'Failed to resend: {error}'**
  String failedToResend(String error);

  /// Prompt to sign out if wrong email
  ///
  /// In en, this message translates to:
  /// **'Wrong email? '**
  String get wrongEmail;

  /// Auto-check indicator text
  ///
  /// In en, this message translates to:
  /// **'Auto-checking verification status...'**
  String get autoCheckingVerification;

  /// World Cup nav label
  ///
  /// In en, this message translates to:
  /// **'World Cup'**
  String get worldCup;

  /// Fan Pass button tooltip
  ///
  /// In en, this message translates to:
  /// **'Fan Pass'**
  String get fanPass;

  /// Leaderboards menu item
  ///
  /// In en, this message translates to:
  /// **'Leaderboards'**
  String get leaderboards;

  /// Compare players menu item
  ///
  /// In en, this message translates to:
  /// **'Compare Players'**
  String get comparePlayers;

  /// Match schedule screen title
  ///
  /// In en, this message translates to:
  /// **'Match Schedule'**
  String get matchSchedule;

  /// Live now banner label
  ///
  /// In en, this message translates to:
  /// **'LIVE NOW'**
  String get liveNow;

  /// Live scores tab
  ///
  /// In en, this message translates to:
  /// **'Live Scores'**
  String get liveScores;

  /// Schedule tab
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// FIFA World Cup 2026 badge text
  ///
  /// In en, this message translates to:
  /// **'FIFA World Cup 2026'**
  String get fifaWorldCup2026;

  /// Live ESPN data badge
  ///
  /// In en, this message translates to:
  /// **'LIVE ESPN DATA'**
  String get liveEspnData;

  /// Tooltip for showing all matches
  ///
  /// In en, this message translates to:
  /// **'Show All Matches'**
  String get showAllMatches;

  /// Tooltip for favorite teams filter
  ///
  /// In en, this message translates to:
  /// **'Show Favorite Teams Only'**
  String get showFavoriteTeamsOnly;

  /// Tooltip for live games filter
  ///
  /// In en, this message translates to:
  /// **'Show Live Games Only'**
  String get showLiveGamesOnly;

  /// Empty state for live scores tab
  ///
  /// In en, this message translates to:
  /// **'No Live Games Currently Available'**
  String get noLiveGamesAvailable;

  /// Info text when no live games
  ///
  /// In en, this message translates to:
  /// **'World Cup matches are played daily during the tournament.\nCheck back during match time for live scores!'**
  String get worldCupMatchesDaily;

  /// Error title when games fail to load
  ///
  /// In en, this message translates to:
  /// **'Failed to Load Games'**
  String get failedToLoadGames;

  /// Instruction to reload schedule
  ///
  /// In en, this message translates to:
  /// **'Tap below to reload the schedule'**
  String get tapToReloadSchedule;

  /// Reload schedule button
  ///
  /// In en, this message translates to:
  /// **'Reload Schedule'**
  String get reloadSchedule;

  /// Empty state for schedule tab
  ///
  /// In en, this message translates to:
  /// **'No games found'**
  String get noGamesFound;

  /// Empty state when filtering by favorites
  ///
  /// In en, this message translates to:
  /// **'No games for your favorite teams'**
  String get noGamesForFavorites;

  /// Empty state for live filter
  ///
  /// In en, this message translates to:
  /// **'No live games at the moment'**
  String get noLiveGames;

  /// Prompt to set favorite teams
  ///
  /// In en, this message translates to:
  /// **'Set your favorite teams to see personalized games'**
  String get setFavoriteTeamsPrompt;

  /// Set favorite teams button
  ///
  /// In en, this message translates to:
  /// **'Set Favorite Teams'**
  String get setFavoriteTeams;

  /// Empty state for social tab
  ///
  /// In en, this message translates to:
  /// **'No Upcoming Games'**
  String get noUpcomingGames;

  /// Info text for social tab empty state
  ///
  /// In en, this message translates to:
  /// **'Social features will be available for upcoming games'**
  String get socialFeaturesAvailable;

  /// Activity feed screen title
  ///
  /// In en, this message translates to:
  /// **'Activity Feed'**
  String get activityFeed;

  /// Feed tab label
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get feed;

  /// Your posts tab label
  ///
  /// In en, this message translates to:
  /// **'Your Posts'**
  String get yourPosts;

  /// Loading activities message
  ///
  /// In en, this message translates to:
  /// **'Loading activities...'**
  String get loadingActivities;

  /// Empty state title for activity feed
  ///
  /// In en, this message translates to:
  /// **'No activities yet'**
  String get noActivitiesYet;

  /// Empty state description for activity feed
  ///
  /// In en, this message translates to:
  /// **'Be the first to share something!\nConnect with friends to see their activities.'**
  String get beFirstToShare;

  /// Create activity button
  ///
  /// In en, this message translates to:
  /// **'Create Activity'**
  String get createActivity;

  /// Error updating like
  ///
  /// In en, this message translates to:
  /// **'Failed to update like'**
  String get failedToUpdateLike;

  /// Comment added confirmation
  ///
  /// In en, this message translates to:
  /// **'Comment added!'**
  String get commentAdded;

  /// Error adding comment
  ///
  /// In en, this message translates to:
  /// **'Failed to add comment'**
  String get failedToAddComment;

  /// View chat info menu item
  ///
  /// In en, this message translates to:
  /// **'View Info'**
  String get viewInfo;

  /// Mute notifications menu item
  ///
  /// In en, this message translates to:
  /// **'Mute Notifications'**
  String get muteNotifications;

  /// Clear chat history menu item
  ///
  /// In en, this message translates to:
  /// **'Clear Chat History'**
  String get clearChatHistory;

  /// Empty state title for chat
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessagesYet;

  /// Empty state description for chat
  ///
  /// In en, this message translates to:
  /// **'Start the conversation!'**
  String get startConversation;

  /// Members count in chat
  ///
  /// In en, this message translates to:
  /// **'{count} members'**
  String members(int count);

  /// Direct chat fallback name
  ///
  /// In en, this message translates to:
  /// **'Direct Chat'**
  String get directChat;

  /// Group chat fallback name
  ///
  /// In en, this message translates to:
  /// **'Group Chat'**
  String get groupChat;

  /// Team chat fallback name
  ///
  /// In en, this message translates to:
  /// **'Team Chat'**
  String get teamChat;

  /// Unblock button
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get unblock;

  /// Unblock user dialog title
  ///
  /// In en, this message translates to:
  /// **'Unblock User'**
  String get unblockUser;

  /// Unblock user confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to unblock this user? They will be able to message you again.'**
  String get unblockUserConfirm;

  /// User unblocked confirmation
  ///
  /// In en, this message translates to:
  /// **'User unblocked'**
  String get userUnblocked;

  /// Failed to unblock error
  ///
  /// In en, this message translates to:
  /// **'Failed to unblock user: {error}'**
  String failedToUnblock(String error);

  /// Video calling coming soon message
  ///
  /// In en, this message translates to:
  /// **'Video calling coming soon!'**
  String get videoCallingComingSoon;

  /// Voice calling coming soon message
  ///
  /// In en, this message translates to:
  /// **'Voice calling coming soon!'**
  String get voiceCallingComingSoon;

  /// Message found in search
  ///
  /// In en, this message translates to:
  /// **'Found message from {sender}'**
  String foundMessageFrom(String sender);

  /// Chat muted confirmation
  ///
  /// In en, this message translates to:
  /// **'Chat muted'**
  String get chatMuted;

  /// Chat unmuted confirmation
  ///
  /// In en, this message translates to:
  /// **'Chat unmuted'**
  String get chatUnmuted;

  /// Failed to update mute settings error
  ///
  /// In en, this message translates to:
  /// **'Failed to update mute settings'**
  String get failedToUpdateMute;

  /// Chat history cleared confirmation
  ///
  /// In en, this message translates to:
  /// **'Chat history cleared'**
  String get chatHistoryCleared;

  /// Failed to clear chat history error
  ///
  /// In en, this message translates to:
  /// **'Failed to clear chat history'**
  String get failedToClearHistory;

  /// Left chat confirmation
  ///
  /// In en, this message translates to:
  /// **'You left the chat'**
  String get youLeftChat;

  /// Failed to leave chat error
  ///
  /// In en, this message translates to:
  /// **'Failed to leave chat'**
  String get failedToLeaveChat;

  /// Must promote admin before leaving
  ///
  /// In en, this message translates to:
  /// **'You must promote another admin before leaving'**
  String get promoteAdminFirst;

  /// Mute duration dialog title
  ///
  /// In en, this message translates to:
  /// **'Mute notifications'**
  String get muteNotificationsTitle;

  /// 1 hour mute option
  ///
  /// In en, this message translates to:
  /// **'1 hour'**
  String get oneHour;

  /// 8 hours mute option
  ///
  /// In en, this message translates to:
  /// **'8 hours'**
  String get eightHours;

  /// 1 day mute option
  ///
  /// In en, this message translates to:
  /// **'1 day'**
  String get oneDay;

  /// 1 week mute option
  ///
  /// In en, this message translates to:
  /// **'1 week'**
  String get oneWeek;

  /// Forever mute option
  ///
  /// In en, this message translates to:
  /// **'Forever'**
  String get forever;

  /// Clear chat history confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all messages in this chat? This action cannot be undone.'**
  String get clearChatHistoryConfirm;

  /// Leave chat confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave this chat?'**
  String get leaveChatConfirm;

  /// Blocked banner fallback text
  ///
  /// In en, this message translates to:
  /// **'Unable to send messages'**
  String get unableToSendMessages;

  /// Error loading chat messages
  ///
  /// In en, this message translates to:
  /// **'Failed to load messages: {error}'**
  String failedToLoadMessages(String error);

  /// Error adding reaction
  ///
  /// In en, this message translates to:
  /// **'Failed to add reaction: {error}'**
  String failedToAddReaction(String error);

  /// Alerts nav tab label
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alerts;

  /// Friends nav tab label
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friends;

  /// Messages nav tab label
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// Notification settings screen title
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// Reset button label
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetLabel;

  /// Settings reset confirmation
  ///
  /// In en, this message translates to:
  /// **'Settings reset to defaults'**
  String get settingsResetToDefaults;

  /// Push notifications master switch title
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// Notifications enabled subtitle
  ///
  /// In en, this message translates to:
  /// **'You will receive notifications'**
  String get youWillReceiveNotifications;

  /// Notifications disabled subtitle
  ///
  /// In en, this message translates to:
  /// **'All notifications are disabled'**
  String get allNotificationsDisabled;

  /// Quiet hours section title
  ///
  /// In en, this message translates to:
  /// **'Quiet Hours'**
  String get quietHours;

  /// Enable quiet hours toggle
  ///
  /// In en, this message translates to:
  /// **'Enable Quiet Hours'**
  String get enableQuietHours;

  /// Quiet hours enabled subtitle
  ///
  /// In en, this message translates to:
  /// **'No notifications from {start} to {end}'**
  String noNotificationsFromTo(String start, String end);

  /// Quiet hours disabled subtitle
  ///
  /// In en, this message translates to:
  /// **'Receive notifications anytime'**
  String get receiveNotificationsAnytime;

  /// Quiet hours start time label
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get startTime;

  /// Quiet hours end time label
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get endTime;

  /// Match reminders subtitle
  ///
  /// In en, this message translates to:
  /// **'Get reminded before matches start'**
  String get getRemindedBeforeMatches;

  /// Default reminder time label
  ///
  /// In en, this message translates to:
  /// **'Default Reminder Time'**
  String get defaultReminderTime;

  /// Favorite team matches toggle
  ///
  /// In en, this message translates to:
  /// **'Favorite Team Matches'**
  String get favoriteTeamMatchesLabel;

  /// Favorite team matches description
  ///
  /// In en, this message translates to:
  /// **'Get notified when your favorite teams play'**
  String get favoriteTeamMatchesDesc;

  /// Day before notification toggle
  ///
  /// In en, this message translates to:
  /// **'Day Before Notification'**
  String get dayBeforeNotification;

  /// Day before notification description
  ///
  /// In en, this message translates to:
  /// **'Remind me the day before my team plays'**
  String get dayBeforeNotificationDesc;

  /// Live match alerts section title
  ///
  /// In en, this message translates to:
  /// **'Live Match Alerts'**
  String get liveMatchAlerts;

  /// Live match alerts section description
  ///
  /// In en, this message translates to:
  /// **'Get instant notifications during live matches'**
  String get liveMatchAlertsDesc;

  /// Goal alerts subtitle
  ///
  /// In en, this message translates to:
  /// **'When a goal is scored'**
  String get whenGoalScored;

  /// Match start toggle
  ///
  /// In en, this message translates to:
  /// **'Match Start'**
  String get matchStart;

  /// Match start subtitle
  ///
  /// In en, this message translates to:
  /// **'When a match kicks off'**
  String get whenMatchKicksOff;

  /// Halftime toggle
  ///
  /// In en, this message translates to:
  /// **'Halftime'**
  String get halftimeLabel;

  /// Halftime subtitle
  ///
  /// In en, this message translates to:
  /// **'Halftime score updates'**
  String get halftimeScoreUpdates;

  /// Match end toggle
  ///
  /// In en, this message translates to:
  /// **'Match End'**
  String get matchEnd;

  /// Match end subtitle
  ///
  /// In en, this message translates to:
  /// **'Final score notifications'**
  String get finalScoreNotifications;

  /// Red cards toggle
  ///
  /// In en, this message translates to:
  /// **'Red Cards'**
  String get redCards;

  /// Red cards subtitle
  ///
  /// In en, this message translates to:
  /// **'Player sent off'**
  String get playerSentOff;

  /// Penalties subtitle
  ///
  /// In en, this message translates to:
  /// **'Penalty kicks awarded'**
  String get penaltyKicksAwarded;

  /// Watch party invites toggle
  ///
  /// In en, this message translates to:
  /// **'Watch Party Invites'**
  String get watchPartyInvites;

  /// Watch party invites description
  ///
  /// In en, this message translates to:
  /// **'When someone invites you to a watch party'**
  String get watchPartyInvitesDesc;

  /// Watch party reminders toggle
  ///
  /// In en, this message translates to:
  /// **'Watch Party Reminders'**
  String get watchPartyReminders;

  /// Watch party reminders description
  ///
  /// In en, this message translates to:
  /// **'Remind me before watch parties I joined'**
  String get watchPartyRemindersDesc;

  /// Reminder time label
  ///
  /// In en, this message translates to:
  /// **'Reminder Time'**
  String get reminderTime;

  /// Watch party updates toggle
  ///
  /// In en, this message translates to:
  /// **'Watch Party Updates'**
  String get watchPartyUpdates;

  /// Watch party updates description
  ///
  /// In en, this message translates to:
  /// **'Host messages and party changes'**
  String get watchPartyUpdatesDesc;

  /// Social section title
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get social;

  /// Friend requests toggle
  ///
  /// In en, this message translates to:
  /// **'Friend Requests'**
  String get friendRequests;

  /// Friend requests description
  ///
  /// In en, this message translates to:
  /// **'When someone sends you a friend request'**
  String get friendRequestsDesc;

  /// Messages notification toggle
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messagesNotification;

  /// Messages notification description
  ///
  /// In en, this message translates to:
  /// **'New direct and group messages'**
  String get messagesNotificationDesc;

  /// Mentions toggle
  ///
  /// In en, this message translates to:
  /// **'Mentions'**
  String get mentionsLabel;

  /// Mentions description
  ///
  /// In en, this message translates to:
  /// **'When someone mentions you'**
  String get mentionsDesc;

  /// Predictions and leaderboard section title
  ///
  /// In en, this message translates to:
  /// **'Predictions & Leaderboard'**
  String get predictionsAndLeaderboard;

  /// Prediction results toggle
  ///
  /// In en, this message translates to:
  /// **'Prediction Results'**
  String get predictionResults;

  /// Prediction results description
  ///
  /// In en, this message translates to:
  /// **'How your predictions performed'**
  String get predictionResultsDesc;

  /// Leaderboard updates toggle
  ///
  /// In en, this message translates to:
  /// **'Leaderboard Updates'**
  String get leaderboardUpdates;

  /// Leaderboard updates description
  ///
  /// In en, this message translates to:
  /// **'Your ranking changes'**
  String get leaderboardUpdatesDesc;

  /// Reminder time picker title
  ///
  /// In en, this message translates to:
  /// **'Select Reminder Time'**
  String get selectReminderTime;

  /// Minutes before reminder
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes before'**
  String minutesBefore(int minutes);

  /// World Cup 2026 app bar title
  ///
  /// In en, this message translates to:
  /// **'World Cup 2026'**
  String get worldCup2026Title;

  /// Message when no live games but tournament coming
  ///
  /// In en, this message translates to:
  /// **'Game day is coming soon!'**
  String get gameDayComingSoon;

  /// Unknown state error title
  ///
  /// In en, this message translates to:
  /// **'Unknown state'**
  String get unknownState;

  /// Empty state for weekly schedule
  ///
  /// In en, this message translates to:
  /// **'No games found for {year} Week {week}'**
  String noGamesForWeek(int year, int week);

  /// Test data banner for weekly schedule
  ///
  /// In en, this message translates to:
  /// **'Test Data - {year} Week {week}'**
  String testDataWeek(int year, int week);

  /// Share text footer
  ///
  /// In en, this message translates to:
  /// **'Shared from Pregame World Cup 2026'**
  String get sharedFromPregame;

  /// Live match indicator with minute
  ///
  /// In en, this message translates to:
  /// **'Match in progress - {minute}\''**
  String matchInProgressWithMinute(String minute);

  /// Live match indicator
  ///
  /// In en, this message translates to:
  /// **'Match in progress'**
  String get matchInProgress;

  /// Button to show all nearby venues
  ///
  /// In en, this message translates to:
  /// **'Show all {count} venues'**
  String showAllVenues(int count);

  /// Superfan gate message for AI match insights
  ///
  /// In en, this message translates to:
  /// **'Get AI-powered match analysis, historical insights, and key player matchups with Superfan Pass.'**
  String get aiMatchAnalysisGate;

  /// Host nation badge label
  ///
  /// In en, this message translates to:
  /// **'Host Nation'**
  String get hostNation;

  /// FIFA ranking stat label
  ///
  /// In en, this message translates to:
  /// **'FIFA Ranking'**
  String get fifaRanking;

  /// World Cup titles stat label
  ///
  /// In en, this message translates to:
  /// **'World Cup Titles'**
  String get worldCupTitles;

  /// Group label
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get group;

  /// Team information section title
  ///
  /// In en, this message translates to:
  /// **'Team Information'**
  String get teamInformation;

  /// Country label
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// FIFA code label
  ///
  /// In en, this message translates to:
  /// **'FIFA Code'**
  String get fifaCode;

  /// Confederation label
  ///
  /// In en, this message translates to:
  /// **'Confederation'**
  String get confederation;

  /// Short name label
  ///
  /// In en, this message translates to:
  /// **'Short Name'**
  String get shortName;

  /// World Cup history section title
  ///
  /// In en, this message translates to:
  /// **'World Cup History'**
  String get worldCupHistory;

  /// Number of titles
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, =1{Title} other{Titles}}'**
  String titleCount(int count);

  /// Message when team has no WC titles
  ///
  /// In en, this message translates to:
  /// **'No World Cup titles yet'**
  String get noWorldCupTitlesYet;

  /// Group with letter
  ///
  /// In en, this message translates to:
  /// **'Group {letter}'**
  String groupLabel(String letter);

  /// View standings button
  ///
  /// In en, this message translates to:
  /// **'View Standings'**
  String get viewStandings;

  /// Group info helper text
  ///
  /// In en, this message translates to:
  /// **'Tap to see full group standings and matches'**
  String get tapToSeeGroupStandings;

  /// Placeholder for team matches
  ///
  /// In en, this message translates to:
  /// **'Team matches will appear here'**
  String get teamMatchesWillAppear;

  /// View all button
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// Search teams hint
  ///
  /// In en, this message translates to:
  /// **'Search teams...'**
  String get searchTeams;

  /// Simple team count
  ///
  /// In en, this message translates to:
  /// **'{count} teams'**
  String teamsCountSimple(int count);

  /// No teams found message
  ///
  /// In en, this message translates to:
  /// **'No teams found'**
  String get noTeamsFound;

  /// Hint when no teams found
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or filters'**
  String get tryAdjustingFilters;

  /// My predictions page title
  ///
  /// In en, this message translates to:
  /// **'My Predictions'**
  String get myPredictions;

  /// Update results menu item
  ///
  /// In en, this message translates to:
  /// **'Update Results'**
  String get updateResults;

  /// Clear all menu item
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// All filter label
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// Pending filter label
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// Correct filter label
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get correct;

  /// Incorrect filter label
  ///
  /// In en, this message translates to:
  /// **'Incorrect'**
  String get incorrect;

  /// Empty state title for predictions
  ///
  /// In en, this message translates to:
  /// **'No Predictions Yet'**
  String get noPredictionsYet;

  /// Empty state description for predictions
  ///
  /// In en, this message translates to:
  /// **'Make predictions on upcoming matches\nto track your accuracy and earn points!'**
  String get makePredictionsPrompt;

  /// Go to matches button
  ///
  /// In en, this message translates to:
  /// **'Go to Matches'**
  String get goToMatches;

  /// No pending predictions message
  ///
  /// In en, this message translates to:
  /// **'No pending predictions'**
  String get noPendingPredictions;

  /// No correct predictions message
  ///
  /// In en, this message translates to:
  /// **'No correct predictions yet'**
  String get noCorrectPredictions;

  /// No incorrect predictions message
  ///
  /// In en, this message translates to:
  /// **'No incorrect predictions'**
  String get noIncorrectPredictions;

  /// No predictions message
  ///
  /// In en, this message translates to:
  /// **'No predictions'**
  String get noPredictions;

  /// Delete prediction dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Prediction?'**
  String get deletePrediction;

  /// Delete prediction confirmation
  ///
  /// In en, this message translates to:
  /// **'Delete your prediction for {homeTeam} vs {awayTeam}?'**
  String deletePredictionConfirm(String homeTeam, String awayTeam);

  /// Clear all predictions dialog title
  ///
  /// In en, this message translates to:
  /// **'Clear All Predictions?'**
  String get clearAllPredictions;

  /// Clear all predictions confirmation
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all your predictions. This action cannot be undone.'**
  String get clearAllPredictionsConfirm;

  /// Exact score prediction result
  ///
  /// In en, this message translates to:
  /// **'Exact Score!'**
  String get exactScore;

  /// Correct result prediction
  ///
  /// In en, this message translates to:
  /// **'Correct Result'**
  String get correctResult;

  /// Result label
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get result;

  /// Points earned label
  ///
  /// In en, this message translates to:
  /// **'Points Earned'**
  String get pointsEarned;

  /// Status label
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// Group standings page title
  ///
  /// In en, this message translates to:
  /// **'Group Standings'**
  String get groupStandings;

  /// Group data not available
  ///
  /// In en, this message translates to:
  /// **'Group {letter} data not available'**
  String noGroupDataAvailableForGroup(String letter);

  /// Qualification legend title
  ///
  /// In en, this message translates to:
  /// **'Qualification'**
  String get qualification;

  /// Qualified top 2 legend
  ///
  /// In en, this message translates to:
  /// **'Qualified (Top 2)'**
  String get qualifiedTop2;

  /// Possible qualification legend
  ///
  /// In en, this message translates to:
  /// **'Possible Qualification (Best 3rd place)'**
  String get possibleQualification;

  /// Tiebreakers title
  ///
  /// In en, this message translates to:
  /// **'Tiebreakers (in order):'**
  String get tiebreakers;

  /// Tiebreakers list
  ///
  /// In en, this message translates to:
  /// **'1. Points\n2. Goal difference\n3. Goals scored\n4. Head-to-head points\n5. Fair play (yellow/red cards)\n6. Drawing of lots'**
  String get tiebreakersList;

  /// Knockout bracket page title
  ///
  /// In en, this message translates to:
  /// **'Knockout Bracket'**
  String get knockoutBracket;

  /// Finals round label
  ///
  /// In en, this message translates to:
  /// **'Finals'**
  String get finals;

  /// Bracket not available message
  ///
  /// In en, this message translates to:
  /// **'Bracket data not available yet'**
  String get bracketDataNotAvailable;

  /// Matches not yet determined
  ///
  /// In en, this message translates to:
  /// **'Matches not yet determined'**
  String get matchesNotYetDetermined;

  /// Teams set after group stage
  ///
  /// In en, this message translates to:
  /// **'Teams will be set after group stage'**
  String get teamsSetAfterGroupStage;

  /// Third place playoff label
  ///
  /// In en, this message translates to:
  /// **'Third Place Play-off'**
  String get thirdPlacePlayoff;

  /// Current round indicator
  ///
  /// In en, this message translates to:
  /// **'Current: {round}'**
  String currentRound(String round);

  /// No bracket data message
  ///
  /// In en, this message translates to:
  /// **'No bracket data'**
  String get noBracketData;

  /// No matches for selected date
  ///
  /// In en, this message translates to:
  /// **'No matches scheduled for this day'**
  String get noMatchesScheduledForDay;

  /// Hint to try different date
  ///
  /// In en, this message translates to:
  /// **'Try selecting a different date'**
  String get tryDifferentDate;

  /// Showing matches for date
  ///
  /// In en, this message translates to:
  /// **'Showing matches for {date}'**
  String showingMatchesFor(String date);

  /// Match count
  ///
  /// In en, this message translates to:
  /// **'{count} match{count, plural, =1{} other{es}}'**
  String matchCount(int count);

  /// My profile title
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// Accessibility settings tooltip
  ///
  /// In en, this message translates to:
  /// **'Accessibility Settings'**
  String get accessibilitySettings;

  /// Timezone settings tooltip
  ///
  /// In en, this message translates to:
  /// **'Timezone Settings'**
  String get timezoneSettings;

  /// Error loading profile message
  ///
  /// In en, this message translates to:
  /// **'Error loading profile'**
  String get errorLoadingProfile;

  /// Error signing out message
  ///
  /// In en, this message translates to:
  /// **'Error signing out'**
  String get errorSigningOut;

  /// Default display name
  ///
  /// In en, this message translates to:
  /// **'Sports Fan'**
  String get sportsFan;

  /// Fan since date
  ///
  /// In en, this message translates to:
  /// **'Pregame Fan Since {date}'**
  String pregameFanSince(String date);

  /// Games tracked stat
  ///
  /// In en, this message translates to:
  /// **'Games Tracked'**
  String get gamesTracked;

  /// Profile customization title
  ///
  /// In en, this message translates to:
  /// **'Profile Customization'**
  String get profileCustomization;

  /// Profile customization description
  ///
  /// In en, this message translates to:
  /// **'Upload photos, set favorite teams, and personalize your sports fan profile'**
  String get profileCustomizationDesc;

  /// Activity feed description
  ///
  /// In en, this message translates to:
  /// **'Track your game predictions, venue check-ins, and social interactions'**
  String get activityFeedDesc;

  /// Achievements title
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// Achievements description
  ///
  /// In en, this message translates to:
  /// **'Unlock badges for predictions, social activity, and venue discoveries'**
  String get achievementsDesc;

  /// Accessibility customize description
  ///
  /// In en, this message translates to:
  /// **'Customize text size, contrast, motion, and more'**
  String get accessibilityCustomizeDesc;

  /// Find friends screen title
  ///
  /// In en, this message translates to:
  /// **'Find Friends'**
  String get findFriends;

  /// Search hint for user search
  ///
  /// In en, this message translates to:
  /// **'Search by name or favorite team...'**
  String get searchByNameOrTeam;

  /// Empty state for user search
  ///
  /// In en, this message translates to:
  /// **'Search for friends by name or favorite team'**
  String get searchForFriends;

  /// No users found message
  ///
  /// In en, this message translates to:
  /// **'No users found for \"{query}\"'**
  String noUsersFound(String query);

  /// Hint for no search results
  ///
  /// In en, this message translates to:
  /// **'Try searching for a different name or team'**
  String get tryDifferentSearch;

  /// Add button label
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Friend request sent confirmation
  ///
  /// In en, this message translates to:
  /// **'Friend request sent to {name}'**
  String friendRequestSentTo(String name);

  /// Failed to send friend request error
  ///
  /// In en, this message translates to:
  /// **'Failed to send friend request'**
  String get failedToSendFriendRequest;

  /// Error sending friend request
  ///
  /// In en, this message translates to:
  /// **'Error sending friend request'**
  String get errorSendingFriendRequest;

  /// Error searching users
  ///
  /// In en, this message translates to:
  /// **'Error searching users. Please try again.'**
  String get errorSearchingUsers;

  /// Requests tab label
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requests;

  /// Sent tab label
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get sent;

  /// Loading friends message
  ///
  /// In en, this message translates to:
  /// **'Loading friends...'**
  String get loadingFriends;

  /// Friend request accepted confirmation
  ///
  /// In en, this message translates to:
  /// **'Friend request accepted!'**
  String get friendRequestAccepted;

  /// Friend request declined confirmation
  ///
  /// In en, this message translates to:
  /// **'Friend request declined'**
  String get friendRequestDeclined;

  /// Failed to decline friend request error
  ///
  /// In en, this message translates to:
  /// **'Failed to decline friend request'**
  String get failedToDecline;

  /// Friend request cancelled confirmation
  ///
  /// In en, this message translates to:
  /// **'Friend request cancelled'**
  String get friendRequestCancelled;

  /// Failed to cancel friend request error
  ///
  /// In en, this message translates to:
  /// **'Failed to cancel friend request'**
  String get failedToCancelRequest;

  /// Removed from friends confirmation
  ///
  /// In en, this message translates to:
  /// **'{name} removed from friends'**
  String removedFromFriends(String name);

  /// Failed to remove friend error
  ///
  /// In en, this message translates to:
  /// **'Failed to remove {name}'**
  String failedToRemove(String name);

  /// User blocked confirmation
  ///
  /// In en, this message translates to:
  /// **'{name} has been blocked'**
  String userBlocked(String name);

  /// Failed to block user error
  ///
  /// In en, this message translates to:
  /// **'Failed to block {name}'**
  String failedToBlock(String name);

  /// Opening chat snackbar
  ///
  /// In en, this message translates to:
  /// **'Opening chat...'**
  String get openingChat;

  /// Unable to start chat error
  ///
  /// In en, this message translates to:
  /// **'Unable to start chat. User may be blocked.'**
  String get unableToStartChat;

  /// Failed to start chat error
  ///
  /// In en, this message translates to:
  /// **'Failed to start chat: {error}'**
  String failedToStartChat(String error);

  /// Successfully joined watch party
  ///
  /// In en, this message translates to:
  /// **'Successfully joined!'**
  String get successfullyJoined;

  /// Reload button
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get reload;

  /// Details tab label
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// Edit party menu item
  ///
  /// In en, this message translates to:
  /// **'Edit Party'**
  String get editParty;

  /// Start party menu item
  ///
  /// In en, this message translates to:
  /// **'Start Party'**
  String get startParty;

  /// End party menu item
  ///
  /// In en, this message translates to:
  /// **'End Party'**
  String get endParty;

  /// Cancel party menu item
  ///
  /// In en, this message translates to:
  /// **'Cancel Party'**
  String get cancelParty;

  /// View on map button
  ///
  /// In en, this message translates to:
  /// **'View on Map'**
  String get viewOnMap;

  /// Empty chat state title
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessagesYetChat;

  /// Empty chat state description
  ///
  /// In en, this message translates to:
  /// **'Be the first to say hello!'**
  String get beFirstToSayHello;

  /// Spots left in watch party
  ///
  /// In en, this message translates to:
  /// **'{count} spots left'**
  String spotsLeft(int count);

  /// Join in person button
  ///
  /// In en, this message translates to:
  /// **'Join In Person'**
  String get joinInPerson;

  /// Ended status label
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get ended;

  /// Cancel watch party dialog title
  ///
  /// In en, this message translates to:
  /// **'Cancel Watch Party?'**
  String get cancelWatchParty;

  /// Cancel watch party confirmation
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. All attendees will be notified.'**
  String get cancelWatchPartyConfirm;

  /// Keep button (don't cancel)
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get keep;

  /// Remove member dialog title
  ///
  /// In en, this message translates to:
  /// **'Remove Member?'**
  String get removeMember;

  /// Remove member confirmation
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from the watch party?'**
  String removeMemberConfirm(String name);

  /// Remove button
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// Chat disabled - not member
  ///
  /// In en, this message translates to:
  /// **'Join the party to chat'**
  String get joinPartToChat;

  /// Chat disabled - muted
  ///
  /// In en, this message translates to:
  /// **'You have been muted'**
  String get youHaveBeenMuted;

  /// Chat disabled - virtual unpaid
  ///
  /// In en, this message translates to:
  /// **'Pay for virtual attendance to chat'**
  String get payForVirtualToChat;

  /// Maps error
  ///
  /// In en, this message translates to:
  /// **'Could not open maps'**
  String get couldNotOpenMaps;

  /// Full settings reset confirmation
  ///
  /// In en, this message translates to:
  /// **'Settings reset to defaults'**
  String get settingsResetToDefaultsFull;

  /// Accessibility settings card title
  ///
  /// In en, this message translates to:
  /// **'Accessibility Settings'**
  String get accessibilitySettingsTitle;

  /// Accessibility settings intro text
  ///
  /// In en, this message translates to:
  /// **'Customize your experience to make Pregame World Cup easier to use.'**
  String get accessibilitySettingsIntro;

  /// Vision section title
  ///
  /// In en, this message translates to:
  /// **'Vision'**
  String get vision;

  /// High contrast subtitle
  ///
  /// In en, this message translates to:
  /// **'Use high contrast colors for better visibility'**
  String get highContrastSubtitle;

  /// Bold text subtitle
  ///
  /// In en, this message translates to:
  /// **'Make all text bolder and easier to read'**
  String get boldTextSubtitle;

  /// Motion section title
  ///
  /// In en, this message translates to:
  /// **'Motion'**
  String get motion;

  /// Reduce motion subtitle
  ///
  /// In en, this message translates to:
  /// **'Minimize animations and motion effects'**
  String get reduceMotionSubtitle;

  /// Interaction section title
  ///
  /// In en, this message translates to:
  /// **'Interaction'**
  String get interaction;

  /// Larger touch targets toggle
  ///
  /// In en, this message translates to:
  /// **'Larger Touch Targets'**
  String get largerTouchTargets;

  /// Larger touch targets subtitle
  ///
  /// In en, this message translates to:
  /// **'Make buttons and controls easier to tap'**
  String get largerTouchTargetsSubtitle;

  /// Text size section title
  ///
  /// In en, this message translates to:
  /// **'Text Size'**
  String get textSize;

  /// Text scale label
  ///
  /// In en, this message translates to:
  /// **'Text Scale'**
  String get textScale;

  /// Adjust text size description
  ///
  /// In en, this message translates to:
  /// **'Adjust the size of text throughout the app'**
  String get adjustTextSize;

  /// Sample text for preview
  ///
  /// In en, this message translates to:
  /// **'Sample Text Preview'**
  String get sampleTextPreview;

  /// Use system default button
  ///
  /// In en, this message translates to:
  /// **'Use System Default'**
  String get useSystemDefault;

  /// Small text scale
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get small;

  /// Default text scale
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get default_;

  /// Large text scale
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get large;

  /// Extra large text scale
  ///
  /// In en, this message translates to:
  /// **'Extra Large'**
  String get extraLarge;

  /// Maximum text scale
  ///
  /// In en, this message translates to:
  /// **'Maximum'**
  String get maximum;

  /// Screen reader section title
  ///
  /// In en, this message translates to:
  /// **'Screen Reader'**
  String get screenReader;

  /// Screen reader optimized toggle
  ///
  /// In en, this message translates to:
  /// **'Screen Reader Optimized'**
  String get screenReaderOptimized;

  /// Screen reader subtitle
  ///
  /// In en, this message translates to:
  /// **'Enhance compatibility with VoiceOver and TalkBack'**
  String get screenReaderSubtitle;

  /// System settings info title
  ///
  /// In en, this message translates to:
  /// **'System Settings'**
  String get systemSettings;

  /// System settings info text
  ///
  /// In en, this message translates to:
  /// **'These settings work alongside your device\'s accessibility settings. For more options, visit your device\'s Settings > Accessibility.'**
  String get systemSettingsInfo;

  /// Reset all settings button
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetAllSettings;

  /// Setting updated announcement
  ///
  /// In en, this message translates to:
  /// **'Setting updated'**
  String get settingUpdated;

  /// Teams count out of total
  ///
  /// In en, this message translates to:
  /// **'{count} of {total} teams'**
  String teamsOfTotal(int count, int total);

  /// Error opening maps with details
  ///
  /// In en, this message translates to:
  /// **'Error opening maps: {error}'**
  String errorOpeningMaps(String error);

  /// Attendees section header with count
  ///
  /// In en, this message translates to:
  /// **'Attendees ({count})'**
  String attendeesWithCount(int count);

  /// Message when user lacks admin privileges
  ///
  /// In en, this message translates to:
  /// **'You do not have admin access'**
  String get noAdminAccess;

  /// Admin label
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// Admin dashboard screen title
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminDashboard;

  /// Error loading dashboard stats
  ///
  /// In en, this message translates to:
  /// **'Failed to load stats'**
  String get failedToLoadStats;

  /// Overview section title
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// Total users stat label
  ///
  /// In en, this message translates to:
  /// **'Total Users'**
  String get totalUsers;

  /// Active users in last 24 hours
  ///
  /// In en, this message translates to:
  /// **'Active (24h)'**
  String get activeUsers24h;

  /// New users today stat label
  ///
  /// In en, this message translates to:
  /// **'New Today'**
  String get newToday;

  /// Active watch parties stat label
  ///
  /// In en, this message translates to:
  /// **'Active Parties'**
  String get activeParties;

  /// Pending reports stat label
  ///
  /// In en, this message translates to:
  /// **'Pending Reports'**
  String get pendingReports;

  /// Quick actions section title
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// User management action tile title
  ///
  /// In en, this message translates to:
  /// **'User Management'**
  String get userManagement;

  /// User management action description
  ///
  /// In en, this message translates to:
  /// **'View, edit, and manage user accounts'**
  String get userManagementDesc;

  /// Content moderation action tile title
  ///
  /// In en, this message translates to:
  /// **'Content Moderation'**
  String get contentModeration;

  /// Watch party management description
  ///
  /// In en, this message translates to:
  /// **'Manage watch party listings'**
  String get manageWatchPartyListings;

  /// Feature flags management title
  ///
  /// In en, this message translates to:
  /// **'Feature Flags'**
  String get featureFlags;

  /// Feature flags management description
  ///
  /// In en, this message translates to:
  /// **'Toggle app features'**
  String get toggleAppFeatures;

  /// Push notifications management description
  ///
  /// In en, this message translates to:
  /// **'Send broadcast notifications'**
  String get sendBroadcastNotifications;

  /// Empty state when no reports pending
  ///
  /// In en, this message translates to:
  /// **'No pending reports'**
  String get noPendingReports;

  /// Empty state subtitle for no reports
  ///
  /// In en, this message translates to:
  /// **'All caught up!'**
  String get allCaughtUp;

  /// Reporter attribution
  ///
  /// In en, this message translates to:
  /// **'Reported by {name}'**
  String reportedBy(String name);

  /// Content owner label in report
  ///
  /// In en, this message translates to:
  /// **'Content Owner'**
  String get contentOwner;

  /// Content ID label in report
  ///
  /// In en, this message translates to:
  /// **'Content ID'**
  String get contentId;

  /// Reported date label
  ///
  /// In en, this message translates to:
  /// **'Reported'**
  String get reported;

  /// Reported content section label
  ///
  /// In en, this message translates to:
  /// **'Reported Content:'**
  String get reportedContent;

  /// Dismiss report button
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// Warn user button
  ///
  /// In en, this message translates to:
  /// **'Warn'**
  String get warn;

  /// Take action button for moderation
  ///
  /// In en, this message translates to:
  /// **'Take Action'**
  String get takeAction;

  /// Report dismissed confirmation
  ///
  /// In en, this message translates to:
  /// **'Report dismissed'**
  String get reportDismissed;

  /// Warning issued confirmation
  ///
  /// In en, this message translates to:
  /// **'Warning issued'**
  String get warningIssued;

  /// Remove content moderation action
  ///
  /// In en, this message translates to:
  /// **'Remove Content'**
  String get removeContent;

  /// Remove content description
  ///
  /// In en, this message translates to:
  /// **'Delete the reported content'**
  String get deleteReportedContent;

  /// Mute user moderation action
  ///
  /// In en, this message translates to:
  /// **'Mute User (24h)'**
  String get muteUser24h;

  /// Mute user description
  ///
  /// In en, this message translates to:
  /// **'Temporarily prevent user from posting'**
  String get temporarilyPreventPosting;

  /// Suspend user moderation action
  ///
  /// In en, this message translates to:
  /// **'Suspend User (7 days)'**
  String get suspendUser7Days;

  /// Suspend user description
  ///
  /// In en, this message translates to:
  /// **'Suspend user account'**
  String get suspendUserAccount;

  /// Permanent ban moderation action
  ///
  /// In en, this message translates to:
  /// **'Permanent Ban'**
  String get permanentBan;

  /// Permanent ban description
  ///
  /// In en, this message translates to:
  /// **'Permanently ban user'**
  String get permanentlyBanUser;

  /// Moderation action confirmation
  ///
  /// In en, this message translates to:
  /// **'Action taken: {action}'**
  String actionTaken(String action);

  /// Add feature flag tooltip
  ///
  /// In en, this message translates to:
  /// **'Add Flag'**
  String get addFlag;

  /// Empty state when no feature flags
  ///
  /// In en, this message translates to:
  /// **'No feature flags'**
  String get noFeatureFlags;

  /// Create flag button
  ///
  /// In en, this message translates to:
  /// **'Create Flag'**
  String get createFlag;

  /// Enabled status label
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// Disabled status label
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// Updated date label
  ///
  /// In en, this message translates to:
  /// **'Updated: {date}'**
  String updatedDate(String date);

  /// Error updating feature flag
  ///
  /// In en, this message translates to:
  /// **'Failed to update flag'**
  String get failedToUpdateFlag;

  /// Feature flag toggled confirmation
  ///
  /// In en, this message translates to:
  /// **'{name} {status}'**
  String flagToggled(String name, String status);

  /// Create feature flag dialog title
  ///
  /// In en, this message translates to:
  /// **'Create Feature Flag'**
  String get createFeatureFlag;

  /// Name field label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Feature flag name hint text
  ///
  /// In en, this message translates to:
  /// **'e.g., Live Chat Feature'**
  String get featureFlagNameHint;

  /// Description field label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Feature flag description hint text
  ///
  /// In en, this message translates to:
  /// **'What does this flag control?'**
  String get featureFlagDescHint;

  /// Feature flag created confirmation
  ///
  /// In en, this message translates to:
  /// **'Feature flag created'**
  String get featureFlagCreated;

  /// Create button
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// Filter venues screen title
  ///
  /// In en, this message translates to:
  /// **'Filter Venues'**
  String get filterVenues;

  /// Venue types section title
  ///
  /// In en, this message translates to:
  /// **'Venue Types'**
  String get venueTypes;

  /// Maximum distance section title
  ///
  /// In en, this message translates to:
  /// **'Maximum Distance'**
  String get maximumDistance;

  /// Minimum rating section title
  ///
  /// In en, this message translates to:
  /// **'Minimum Rating'**
  String get minimumRating;

  /// Open now filter label
  ///
  /// In en, this message translates to:
  /// **'Open Now'**
  String get openNow;

  /// Price level section title
  ///
  /// In en, this message translates to:
  /// **'Price Level'**
  String get priceLevel;

  /// Keyword search section title
  ///
  /// In en, this message translates to:
  /// **'Search for Specific Features'**
  String get searchSpecificFeatures;

  /// Keyword search hint text
  ///
  /// In en, this message translates to:
  /// **'e.g., wings, craft beer, live music'**
  String get keywordSearchHint;

  /// Apply filters button
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// Single invite sent confirmation
  ///
  /// In en, this message translates to:
  /// **'Invite sent!'**
  String get inviteSent;

  /// Send button with count
  ///
  /// In en, this message translates to:
  /// **'Send ({count})'**
  String sendCount(int count);

  /// Personal message hint text
  ///
  /// In en, this message translates to:
  /// **'Add a personal message (optional)'**
  String get addPersonalMessage;

  /// Friends selected count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 friend selected} other{{count} friends selected}}'**
  String friendsSelected(int count);

  /// Empty state when no friends available
  ///
  /// In en, this message translates to:
  /// **'No friends to invite'**
  String get noFriendsToInvite;

  /// Empty state suggestion for invites
  ///
  /// In en, this message translates to:
  /// **'Follow some people to invite them to watch parties'**
  String get followPeopleToInvite;

  /// Send invites button text
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Send 1 Invite} other{Send {count} Invites}}'**
  String sendInvites(int count);

  /// Invites sent confirmation
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Sent 1 invite!} other{Sent {count} invites!}}'**
  String invitesSent(int count);

  /// Watch party created confirmation
  ///
  /// In en, this message translates to:
  /// **'Watch party created!'**
  String get watchPartyCreated;

  /// Party name field label
  ///
  /// In en, this message translates to:
  /// **'Party Name'**
  String get partyName;

  /// Party name hint text
  ///
  /// In en, this message translates to:
  /// **'Give your party a fun name'**
  String get partyNameHint;

  /// Name validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get pleaseEnterName;

  /// Description hint text
  ///
  /// In en, this message translates to:
  /// **'Tell guests what to expect...'**
  String get descriptionHint;

  /// Visibility section label
  ///
  /// In en, this message translates to:
  /// **'Visibility'**
  String get visibility;

  /// Public visibility description
  ///
  /// In en, this message translates to:
  /// **'Anyone can find and join'**
  String get anyoneCanJoin;

  /// Private visibility description
  ///
  /// In en, this message translates to:
  /// **'Only invited friends can join'**
  String get onlyInvitedCanJoin;

  /// Game field label
  ///
  /// In en, this message translates to:
  /// **'Game'**
  String get game;

  /// Maximum attendees field label
  ///
  /// In en, this message translates to:
  /// **'Maximum Attendees'**
  String get maximumAttendees;

  /// Virtual attendance section label
  ///
  /// In en, this message translates to:
  /// **'Virtual Attendance'**
  String get virtualAttendance;

  /// Virtual attendance description
  ///
  /// In en, this message translates to:
  /// **'Allow virtual attendees to join remotely'**
  String get virtualAttendanceDesc;

  /// Virtual fee field label
  ///
  /// In en, this message translates to:
  /// **'Virtual Attendance Fee'**
  String get virtualAttendanceFee;

  /// Free price hint
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get freeHint;

  /// Select game button
  ///
  /// In en, this message translates to:
  /// **'Select Game'**
  String get selectGame;

  /// Select venue button
  ///
  /// In en, this message translates to:
  /// **'Select Venue'**
  String get selectVenue;

  /// Game selection validation error
  ///
  /// In en, this message translates to:
  /// **'Please select a game'**
  String get pleaseSelectGame;

  /// Venue selection validation error
  ///
  /// In en, this message translates to:
  /// **'Please select a venue'**
  String get pleaseSelectVenue;

  /// Discovery screen placeholder text
  ///
  /// In en, this message translates to:
  /// **'Discover watch parties near you'**
  String get discoverWatchParties;

  /// Empty state title for watch party discovery
  ///
  /// In en, this message translates to:
  /// **'No Watch Parties Found'**
  String get noWatchPartiesFound;

  /// Empty state suggestion for specific match
  ///
  /// In en, this message translates to:
  /// **'Be the first to create a watch party for this match!'**
  String get beFirstToCreateForMatch;

  /// Empty state general suggestion
  ///
  /// In en, this message translates to:
  /// **'Be the first to create a watch party!'**
  String get beFirstToCreate;

  /// Filter and sort sheet title
  ///
  /// In en, this message translates to:
  /// **'Filter & Sort'**
  String get filterAndSort;

  /// Show section label in filter
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get show;

  /// Sort by section label
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// Date sort option
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// Most popular sort option
  ///
  /// In en, this message translates to:
  /// **'Most Popular'**
  String get mostPopular;

  /// My watch parties screen title
  ///
  /// In en, this message translates to:
  /// **'My Watch Parties'**
  String get myWatchParties;

  /// Hosting tab label
  ///
  /// In en, this message translates to:
  /// **'Hosting'**
  String get hosting;

  /// Attending tab label
  ///
  /// In en, this message translates to:
  /// **'Attending'**
  String get attending;

  /// Past tab label
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get past;

  /// Loading watch parties message
  ///
  /// In en, this message translates to:
  /// **'Loading your watch parties...'**
  String get loadingYourWatchParties;

  /// Empty state for hosting tab
  ///
  /// In en, this message translates to:
  /// **'No watch parties hosted'**
  String get noWatchPartiesHosted;

  /// Empty state suggestion for hosting
  ///
  /// In en, this message translates to:
  /// **'Create your first watch party!'**
  String get createFirstWatchParty;

  /// Empty state for attending tab
  ///
  /// In en, this message translates to:
  /// **'No watch parties to attend'**
  String get noWatchPartiesToAttend;

  /// Empty state suggestion for attending
  ///
  /// In en, this message translates to:
  /// **'Discover parties or accept invitations'**
  String get discoverOrAcceptInvitations;

  /// Empty state for past tab
  ///
  /// In en, this message translates to:
  /// **'No past watch parties'**
  String get noPastWatchParties;

  /// Empty state suggestion for past
  ///
  /// In en, this message translates to:
  /// **'Completed parties will appear here'**
  String get completedPartiesAppearHere;

  /// Live chat screen title
  ///
  /// In en, this message translates to:
  /// **'Live Chat'**
  String get liveChat;

  /// Joining chat loading message
  ///
  /// In en, this message translates to:
  /// **'Joining chat...'**
  String get joiningChat;

  /// Join live chat prompt title
  ///
  /// In en, this message translates to:
  /// **'Join the Live Chat'**
  String get joinLiveChat;

  /// Join chat prompt description
  ///
  /// In en, this message translates to:
  /// **'Chat with fellow fans about this match in real time!'**
  String get chatWithFans;

  /// Fans in chat count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 fan in chat} other{{count} fans in chat}}'**
  String fansInChat(int count);

  /// Chat guidelines reminder
  ///
  /// In en, this message translates to:
  /// **'Be respectful and follow community guidelines'**
  String get beRespectful;

  /// Slow mode rate limit indicator
  ///
  /// In en, this message translates to:
  /// **'Slow mode: wait {seconds}s between messages'**
  String slowMode(int seconds);

  /// Leave chat confirmation title
  ///
  /// In en, this message translates to:
  /// **'Leave Chat?'**
  String get leaveChatQuestion;

  /// Leave chat confirmation description
  ///
  /// In en, this message translates to:
  /// **'You can rejoin the chat anytime'**
  String get canRejoinAnytime;

  /// Search messages hint text
  ///
  /// In en, this message translates to:
  /// **'Search messages...'**
  String get searchMessages;

  /// Direct messages tab label
  ///
  /// In en, this message translates to:
  /// **'Direct'**
  String get direct;

  /// Loading conversations message
  ///
  /// In en, this message translates to:
  /// **'Loading conversations...'**
  String get loadingConversations;

  /// Empty state title for conversations
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get noConversationsYet;

  /// Empty state suggestion for conversations
  ///
  /// In en, this message translates to:
  /// **'Start a conversation with your friends!'**
  String get startConversationWithFriends;

  /// Start chatting button
  ///
  /// In en, this message translates to:
  /// **'Start Chatting'**
  String get startChatting;

  /// Error loading conversations title
  ///
  /// In en, this message translates to:
  /// **'Error loading conversations'**
  String get errorLoadingConversations;

  /// Generic retry suggestion
  ///
  /// In en, this message translates to:
  /// **'Please try again later'**
  String get pleaseTryAgainLater;

  /// Archive feature placeholder
  ///
  /// In en, this message translates to:
  /// **'Archive feature coming soon!'**
  String get archiveComingSoon;

  /// Marked as read confirmation
  ///
  /// In en, this message translates to:
  /// **'Marked as read'**
  String get markedAsRead;

  /// Snackbar message when venue premium checkout opens in browser
  ///
  /// In en, this message translates to:
  /// **'Complete your purchase in the browser. Your premium will activate automatically.'**
  String get completePremiumPurchaseInBrowser;

  /// Snackbar message when venue premium is activated
  ///
  /// In en, this message translates to:
  /// **'Venue Premium activated successfully!'**
  String get venuePremiumActivatedSuccessfully;

  /// Subtitle for venue premium price
  ///
  /// In en, this message translates to:
  /// **'One-time payment for World Cup 2026'**
  String get oneTimePaymentForWorldCup;

  /// Header for venue premium features list
  ///
  /// In en, this message translates to:
  /// **'Premium features include:'**
  String get premiumFeaturesInclude;

  /// Venue premium feature
  ///
  /// In en, this message translates to:
  /// **'Specific match scheduling'**
  String get specificMatchScheduling;

  /// Venue premium feature
  ///
  /// In en, this message translates to:
  /// **'TV & screen configuration'**
  String get tvScreenConfiguration;

  /// Venue premium feature
  ///
  /// In en, this message translates to:
  /// **'Game day specials & deals'**
  String get gameDaySpecialsDeals;

  /// Venue premium feature
  ///
  /// In en, this message translates to:
  /// **'Atmosphere & vibe settings'**
  String get atmosphereVibeSettings;

  /// Venue premium feature
  ///
  /// In en, this message translates to:
  /// **'Real-time capacity updates'**
  String get realTimeCapacityUpdates;

  /// Venue premium feature
  ///
  /// In en, this message translates to:
  /// **'Priority listing in searches'**
  String get priorityListingInSearches;

  /// Venue premium feature
  ///
  /// In en, this message translates to:
  /// **'Analytics dashboard'**
  String get analyticsDashboard;

  /// Info text about venue premium validity period
  ///
  /// In en, this message translates to:
  /// **'Valid for the entire tournament (June 11 - July 19, 2026)'**
  String get validForEntireTournament;

  /// Button label while waiting for premium activation
  ///
  /// In en, this message translates to:
  /// **'Waiting for activation...'**
  String get waitingForActivation;

  /// Dismiss button for upgrade dialog
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get notNow;

  /// Button label while processing purchase
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// Button label to start upgrade purchase
  ///
  /// In en, this message translates to:
  /// **'Upgrade Now'**
  String get upgradeNow;

  /// Error message when transactions fail to load
  ///
  /// In en, this message translates to:
  /// **'Error loading transactions'**
  String get errorLoadingTransactions;

  /// Empty state title for transaction history
  ///
  /// In en, this message translates to:
  /// **'No Transactions Yet'**
  String get noTransactionsYet;

  /// Empty state description for transaction history
  ///
  /// In en, this message translates to:
  /// **'Your purchase history will appear here\nonce you make your first transaction.'**
  String get purchaseHistoryWillAppearHere;

  /// Button to explore Fan Pass from empty transaction history
  ///
  /// In en, this message translates to:
  /// **'Explore Fan Pass'**
  String get exploreFanPass;

  /// Label for transaction ID in details
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get transactionId;

  /// Label for transaction type in details
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// Label for currency in transaction details
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;
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
      <String>['en', 'es', 'fr', 'pt'].contains(locale.languageCode);

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
    case 'fr':
      return AppLocalizationsFr();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

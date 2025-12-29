// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get playerSpotlight => 'Player Spotlight';

  @override
  String get players => 'Players';

  @override
  String get searchPlayers => 'Search players...';

  @override
  String get refresh => 'Refresh';

  @override
  String get allTeams => 'All Teams';

  @override
  String get goalkeepers => 'Goalkeepers';

  @override
  String get defenders => 'Defenders';

  @override
  String get midfielders => 'Midfielders';

  @override
  String get forwards => 'Forwards';

  @override
  String get topValue => 'Top Value';

  @override
  String get topScorers => 'Top Scorers';

  @override
  String get mostCapped => 'Most Capped';

  @override
  String playersCount(int count) {
    return '$count players';
  }

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get noPlayersFound => 'No players found';

  @override
  String get careerStatistics => 'Career Statistics';

  @override
  String get internationalCaps => 'International Caps';

  @override
  String get internationalGoals => 'International Goals';

  @override
  String get internationalAssists => 'International Assists';

  @override
  String get worldCupAppearances => 'World Cup Appearances';

  @override
  String get worldCupGoals => 'World Cup Goals';

  @override
  String get previousWorldCups => 'Previous World Cups';

  @override
  String get honors => 'Honors';

  @override
  String get profile => 'Profile';

  @override
  String get strengths => 'Strengths:';

  @override
  String get weaknesses => 'Weaknesses:';

  @override
  String get playStyle => 'Play Style';

  @override
  String get keyMoment => 'Key Moment';

  @override
  String get comparisonToLegend => 'Comparison to Legend';

  @override
  String get worldCup2026Prediction => 'World Cup 2026 Prediction';

  @override
  String get funFacts => 'Fun Facts';

  @override
  String get managerProfiles => 'Manager Profiles';

  @override
  String get managers => 'Managers';

  @override
  String get searchManagers => 'Search managers...';

  @override
  String get allManagers => 'All Managers';

  @override
  String get mostExperienced => 'Most Experienced';

  @override
  String get youngest => 'Youngest';

  @override
  String get oldest => 'Oldest';

  @override
  String get highestWinPercentage => 'Highest Win %';

  @override
  String get mostTitles => 'Most Titles';

  @override
  String get wcWinners => 'WC Winners';

  @override
  String get controversial => 'Controversial';

  @override
  String managersCount(int count) {
    return '$count managers';
  }

  @override
  String get noManagersFound => 'No managers found';

  @override
  String get managerialRecord => 'Managerial Record';

  @override
  String get matchesManaged => 'Matches Managed';

  @override
  String get recordWDL => 'Record (W-D-L)';

  @override
  String get winPercentage => 'Win Percentage';

  @override
  String get titlesWon => 'Titles Won';

  @override
  String get careerStarted => 'Career Started';

  @override
  String get yearsInCurrentRole => 'Years in Current Role';

  @override
  String get tacticalApproach => 'Tactical Approach';

  @override
  String get formation => 'Formation:';

  @override
  String get philosophy => 'Philosophy:';

  @override
  String get honorsAchievements => 'Honors & Achievements';

  @override
  String get profileAnalysis => 'Profile Analysis';

  @override
  String get managerStyle => 'Manager Style';

  @override
  String get definingMoment => 'Defining Moment';

  @override
  String get famousQuote => 'Famous Quote';

  @override
  String get worldCup2026Outlook => 'World Cup 2026 Outlook';

  @override
  String get previousClubs => 'Previous Clubs';

  @override
  String get controversies => 'Controversies';

  @override
  String get didYouKnow => 'Did You Know?';

  @override
  String get tacticalStyle => 'Tactical Style';

  @override
  String get matches => 'Matches';

  @override
  String get groups => 'Groups';

  @override
  String get bracket => 'Bracket';

  @override
  String get teams => 'Teams';

  @override
  String get favorites => 'Favorites';

  @override
  String get fifaWorldCup => 'FIFA World Cup';

  @override
  String get live => 'Live';

  @override
  String liveCount(int count) {
    return '$count Live';
  }

  @override
  String get noMatchesScheduledToday => 'No matches scheduled for today';

  @override
  String get noLiveMatchesRightNow => 'No live matches right now';

  @override
  String get noUpcomingMatches => 'No upcoming matches';

  @override
  String get noCompletedMatchesYet => 'No completed matches yet';

  @override
  String get noMatchesFound => 'No matches found';

  @override
  String get noFavoriteMatchesYet => 'No favorite matches yet';

  @override
  String get noGroupDataAvailable => 'No group data available';

  @override
  String get knockoutBracketNotAvailableYet =>
      'Knockout bracket not available yet';

  @override
  String get checkBackAfterGroupStage => 'Check back after group stage';

  @override
  String get noFavoriteTeamsYet => 'No favorite teams yet';

  @override
  String get tapHeartIconToAddFavorites =>
      'Tap the heart icon on any team to add it to your favorites';

  @override
  String teamsCount(int count) {
    return '$count of 48 teams';
  }

  @override
  String get clear => 'Clear';

  @override
  String get noFavoritesYet => 'No Favorites Yet';

  @override
  String get tapHeartIconMessage =>
      'Tap the heart icon on any match or team\nto add them to your favorites';

  @override
  String get browseMatches => 'Browse Matches';

  @override
  String get browseTeams => 'Browse Teams';

  @override
  String get viewAllPredictions => 'View All Predictions';

  @override
  String get favoriteMatches => 'Favorite Matches';

  @override
  String get favoriteTeams => 'Favorite Teams';

  @override
  String get loading => 'Loading';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Retry';

  @override
  String get noDataFound => 'No data found';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String errorLoadingPlayers(String error) {
    return 'Error loading players: $error';
  }

  @override
  String errorFilteringPlayers(String error) {
    return 'Error filtering players: $error';
  }

  @override
  String errorLoadingManagers(String error) {
    return 'Error loading managers: $error';
  }

  @override
  String errorFilteringManagers(String error) {
    return 'Error filtering managers: $error';
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/services/analytics_service.dart';

/// These tests verify that the analytics event extension methods are
/// re-exported from analytics_service.dart and that the extension types
/// and AnalyticsEvents/AnalyticsUserProperties constants are accessible.
///
/// Full integration tests of the extension methods would require mocking
/// FirebaseAnalytics + FirebaseCrashlytics + FirebaseAuth (the
/// AnalyticsService constructor). The extension methods are thin wrappers
/// around logEvent, so we verify the constants they depend on are correct.
void main() {
  group('AnalyticsEventExtensions re-export', () {
    test('AnalyticsEvents auth constants are accessible', () {
      expect(AnalyticsEvents.login, equals('login'));
      expect(AnalyticsEvents.signUp, equals('sign_up'));
      expect(AnalyticsEvents.logout, equals('logout'));
    });

    test('AnalyticsEvents world cup constants are accessible', () {
      expect(AnalyticsEvents.viewMatch, equals('view_match'));
      expect(AnalyticsEvents.viewTeam, equals('view_team'));
      expect(AnalyticsEvents.favoriteTeam, equals('favorite_team'));
      expect(AnalyticsEvents.unfavoriteTeam, equals('unfavorite_team'));
      expect(AnalyticsEvents.makePrediction, equals('make_prediction'));
    });

    test('AnalyticsEvents watch party constants are accessible', () {
      expect(AnalyticsEvents.createWatchParty, equals('create_watch_party'));
      expect(AnalyticsEvents.joinWatchParty, equals('join_watch_party'));
    });

    test('AnalyticsEvents social constants are accessible', () {
      expect(AnalyticsEvents.sendFriendRequest, equals('send_friend_request'));
      expect(AnalyticsEvents.reportContent, equals('report_content'));
    });

    test('AnalyticsEvents messaging constants are accessible', () {
      expect(AnalyticsEvents.sendMessage, equals('send_message'));
    });

    test('AnalyticsEvents payment constants are accessible', () {
      expect(AnalyticsEvents.startCheckout, equals('begin_checkout'));
      expect(AnalyticsEvents.completePurchase, equals('purchase'));
      expect(AnalyticsEvents.subscriptionStart, equals('subscription_start'));
    });

    test('AnalyticsEvents notification constants are accessible', () {
      expect(AnalyticsEvents.notificationReceived, equals('notification_received'));
      expect(AnalyticsEvents.notificationOpened, equals('notification_opened'));
    });

    test('AnalyticsEvents search constants are accessible', () {
      expect(AnalyticsEvents.searchPerformed, equals('search'));
    });

    test('AnalyticsEvents share constants are accessible', () {
      expect(AnalyticsEvents.shareContent, equals('share'));
    });

    test('AnalyticsUserProperties subscription tier is accessible', () {
      expect(AnalyticsUserProperties.subscriptionTier, equals('subscription_tier'));
    });
  });
}

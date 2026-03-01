import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/services/analytics_service.dart';

void main() {
  group('AnalyticsEvents', () {
    group('authentication event constants', () {
      test('login is correct', () {
        expect(AnalyticsEvents.login, 'login');
      });

      test('signUp is correct', () {
        expect(AnalyticsEvents.signUp, 'sign_up');
      });

      test('logout is correct', () {
        expect(AnalyticsEvents.logout, 'logout');
      });
    });

    group('navigation event constants', () {
      test('screenView is correct', () {
        expect(AnalyticsEvents.screenView, 'screen_view');
      });

      test('tabChange is correct', () {
        expect(AnalyticsEvents.tabChange, 'tab_change');
      });
    });

    group('world cup event constants', () {
      test('viewMatch is correct', () {
        expect(AnalyticsEvents.viewMatch, 'view_match');
      });

      test('viewTeam is correct', () {
        expect(AnalyticsEvents.viewTeam, 'view_team');
      });

      test('viewBracket is correct', () {
        expect(AnalyticsEvents.viewBracket, 'view_bracket');
      });

      test('viewGroupStandings is correct', () {
        expect(AnalyticsEvents.viewGroupStandings, 'view_group_standings');
      });

      test('setMatchReminder is correct', () {
        expect(AnalyticsEvents.setMatchReminder, 'set_match_reminder');
      });

      test('cancelMatchReminder is correct', () {
        expect(AnalyticsEvents.cancelMatchReminder, 'cancel_match_reminder');
      });

      test('favoriteTeam is correct', () {
        expect(AnalyticsEvents.favoriteTeam, 'favorite_team');
      });

      test('unfavoriteTeam is correct', () {
        expect(AnalyticsEvents.unfavoriteTeam, 'unfavorite_team');
      });
    });

    group('prediction event constants', () {
      test('makePrediction is correct', () {
        expect(AnalyticsEvents.makePrediction, 'make_prediction');
      });

      test('updatePrediction is correct', () {
        expect(AnalyticsEvents.updatePrediction, 'update_prediction');
      });

      test('viewLeaderboard is correct', () {
        expect(AnalyticsEvents.viewLeaderboard, 'view_leaderboard');
      });
    });

    group('watch party event constants', () {
      test('createWatchParty is correct', () {
        expect(AnalyticsEvents.createWatchParty, 'create_watch_party');
      });

      test('joinWatchParty is correct', () {
        expect(AnalyticsEvents.joinWatchParty, 'join_watch_party');
      });

      test('leaveWatchParty is correct', () {
        expect(AnalyticsEvents.leaveWatchParty, 'leave_watch_party');
      });

      test('inviteToWatchParty is correct', () {
        expect(AnalyticsEvents.inviteToWatchParty, 'invite_to_watch_party');
      });

      test('viewWatchParty is correct', () {
        expect(AnalyticsEvents.viewWatchParty, 'view_watch_party');
      });

      test('discoverWatchParties is correct', () {
        expect(AnalyticsEvents.discoverWatchParties, 'discover_watch_parties');
      });
    });

    group('social event constants', () {
      test('sendFriendRequest is correct', () {
        expect(AnalyticsEvents.sendFriendRequest, 'send_friend_request');
      });

      test('acceptFriendRequest is correct', () {
        expect(AnalyticsEvents.acceptFriendRequest, 'accept_friend_request');
      });

      test('rejectFriendRequest is correct', () {
        expect(AnalyticsEvents.rejectFriendRequest, 'reject_friend_request');
      });

      test('blockUser is correct', () {
        expect(AnalyticsEvents.blockUser, 'block_user');
      });

      test('unblockUser is correct', () {
        expect(AnalyticsEvents.unblockUser, 'unblock_user');
      });

      test('reportContent is correct', () {
        expect(AnalyticsEvents.reportContent, 'report_content');
      });

      test('viewProfile is correct', () {
        expect(AnalyticsEvents.viewProfile, 'view_profile');
      });

      test('editProfile is correct', () {
        expect(AnalyticsEvents.editProfile, 'edit_profile');
      });
    });

    group('messaging event constants', () {
      test('sendMessage is correct', () {
        expect(AnalyticsEvents.sendMessage, 'send_message');
      });

      test('sendVoiceMessage is correct', () {
        expect(AnalyticsEvents.sendVoiceMessage, 'send_voice_message');
      });

      test('sendMediaMessage is correct', () {
        expect(AnalyticsEvents.sendMediaMessage, 'send_media_message');
      });

      test('createChat is correct', () {
        expect(AnalyticsEvents.createChat, 'create_chat');
      });

      test('createGroupChat is correct', () {
        expect(AnalyticsEvents.createGroupChat, 'create_group_chat');
      });

      test('muteChat is correct', () {
        expect(AnalyticsEvents.muteChat, 'mute_chat');
      });

      test('archiveChat is correct', () {
        expect(AnalyticsEvents.archiveChat, 'archive_chat');
      });
    });

    group('payment event constants', () {
      test('viewPricing is correct', () {
        expect(AnalyticsEvents.viewPricing, 'view_pricing');
      });

      test('startCheckout is correct', () {
        expect(AnalyticsEvents.startCheckout, 'begin_checkout');
      });

      test('completePurchase is correct', () {
        expect(AnalyticsEvents.completePurchase, 'purchase');
      });

      test('subscriptionStart is correct', () {
        expect(AnalyticsEvents.subscriptionStart, 'subscription_start');
      });

      test('subscriptionCancel is correct', () {
        expect(AnalyticsEvents.subscriptionCancel, 'subscription_cancel');
      });

      test('virtualAttendancePurchase is correct', () {
        expect(AnalyticsEvents.virtualAttendancePurchase,
            'virtual_attendance_purchase');
      });
    });

    group('venue event constants', () {
      test('viewVenue is correct', () {
        expect(AnalyticsEvents.viewVenue, 'view_venue');
      });

      test('searchVenues is correct', () {
        expect(AnalyticsEvents.searchVenues, 'search_venues');
      });

      test('getNearbyVenues is correct', () {
        expect(AnalyticsEvents.getNearbyVenues, 'get_nearby_venues');
      });
    });

    group('AI event constants', () {
      test('aiPredictionRequest is correct', () {
        expect(AnalyticsEvents.aiPredictionRequest, 'ai_prediction_request');
      });

      test('aiAnalysisRequest is correct', () {
        expect(AnalyticsEvents.aiAnalysisRequest, 'ai_analysis_request');
      });

      test('chatbotMessage is correct', () {
        expect(AnalyticsEvents.chatbotMessage, 'chatbot_message');
      });
    });

    group('engagement event constants', () {
      test('appOpen is correct', () {
        expect(AnalyticsEvents.appOpen, 'app_open');
      });

      test('shareContent is correct', () {
        expect(AnalyticsEvents.shareContent, 'share');
      });

      test('notificationReceived is correct', () {
        expect(AnalyticsEvents.notificationReceived, 'notification_received');
      });

      test('notificationOpened is correct', () {
        expect(AnalyticsEvents.notificationOpened, 'notification_opened');
      });

      test('searchPerformed is correct', () {
        expect(AnalyticsEvents.searchPerformed, 'search');
      });
    });

    group('error event constants', () {
      test('apiError is correct', () {
        expect(AnalyticsEvents.apiError, 'api_error');
      });

      test('paymentError is correct', () {
        expect(AnalyticsEvents.paymentError, 'payment_error');
      });

      test('authError is correct', () {
        expect(AnalyticsEvents.authError, 'auth_error');
      });
    });

    test('all event names are non-empty strings', () {
      final events = [
        AnalyticsEvents.login,
        AnalyticsEvents.signUp,
        AnalyticsEvents.logout,
        AnalyticsEvents.screenView,
        AnalyticsEvents.tabChange,
        AnalyticsEvents.viewMatch,
        AnalyticsEvents.viewTeam,
        AnalyticsEvents.viewBracket,
        AnalyticsEvents.viewGroupStandings,
        AnalyticsEvents.setMatchReminder,
        AnalyticsEvents.cancelMatchReminder,
        AnalyticsEvents.favoriteTeam,
        AnalyticsEvents.unfavoriteTeam,
        AnalyticsEvents.makePrediction,
        AnalyticsEvents.updatePrediction,
        AnalyticsEvents.viewLeaderboard,
        AnalyticsEvents.createWatchParty,
        AnalyticsEvents.joinWatchParty,
        AnalyticsEvents.leaveWatchParty,
        AnalyticsEvents.inviteToWatchParty,
        AnalyticsEvents.viewWatchParty,
        AnalyticsEvents.discoverWatchParties,
        AnalyticsEvents.sendFriendRequest,
        AnalyticsEvents.acceptFriendRequest,
        AnalyticsEvents.rejectFriendRequest,
        AnalyticsEvents.blockUser,
        AnalyticsEvents.unblockUser,
        AnalyticsEvents.reportContent,
        AnalyticsEvents.viewProfile,
        AnalyticsEvents.editProfile,
        AnalyticsEvents.sendMessage,
        AnalyticsEvents.sendVoiceMessage,
        AnalyticsEvents.sendMediaMessage,
        AnalyticsEvents.createChat,
        AnalyticsEvents.createGroupChat,
        AnalyticsEvents.muteChat,
        AnalyticsEvents.archiveChat,
        AnalyticsEvents.viewPricing,
        AnalyticsEvents.startCheckout,
        AnalyticsEvents.completePurchase,
        AnalyticsEvents.subscriptionStart,
        AnalyticsEvents.subscriptionCancel,
        AnalyticsEvents.virtualAttendancePurchase,
        AnalyticsEvents.viewVenue,
        AnalyticsEvents.searchVenues,
        AnalyticsEvents.getNearbyVenues,
        AnalyticsEvents.aiPredictionRequest,
        AnalyticsEvents.aiAnalysisRequest,
        AnalyticsEvents.chatbotMessage,
        AnalyticsEvents.appOpen,
        AnalyticsEvents.shareContent,
        AnalyticsEvents.notificationReceived,
        AnalyticsEvents.notificationOpened,
        AnalyticsEvents.searchPerformed,
        AnalyticsEvents.apiError,
        AnalyticsEvents.paymentError,
        AnalyticsEvents.authError,
      ];

      for (final event in events) {
        expect(event, isA<String>());
        expect(event.isNotEmpty, isTrue);
      }
    });

    test('all event names are unique', () {
      final events = [
        AnalyticsEvents.login,
        AnalyticsEvents.signUp,
        AnalyticsEvents.logout,
        AnalyticsEvents.screenView,
        AnalyticsEvents.tabChange,
        AnalyticsEvents.viewMatch,
        AnalyticsEvents.viewTeam,
        AnalyticsEvents.viewBracket,
        AnalyticsEvents.viewGroupStandings,
        AnalyticsEvents.setMatchReminder,
        AnalyticsEvents.cancelMatchReminder,
        AnalyticsEvents.favoriteTeam,
        AnalyticsEvents.unfavoriteTeam,
        AnalyticsEvents.makePrediction,
        AnalyticsEvents.updatePrediction,
        AnalyticsEvents.viewLeaderboard,
        AnalyticsEvents.createWatchParty,
        AnalyticsEvents.joinWatchParty,
        AnalyticsEvents.leaveWatchParty,
        AnalyticsEvents.inviteToWatchParty,
        AnalyticsEvents.viewWatchParty,
        AnalyticsEvents.discoverWatchParties,
        AnalyticsEvents.sendFriendRequest,
        AnalyticsEvents.acceptFriendRequest,
        AnalyticsEvents.rejectFriendRequest,
        AnalyticsEvents.blockUser,
        AnalyticsEvents.unblockUser,
        AnalyticsEvents.reportContent,
        AnalyticsEvents.viewProfile,
        AnalyticsEvents.editProfile,
        AnalyticsEvents.sendMessage,
        AnalyticsEvents.sendVoiceMessage,
        AnalyticsEvents.sendMediaMessage,
        AnalyticsEvents.createChat,
        AnalyticsEvents.createGroupChat,
        AnalyticsEvents.muteChat,
        AnalyticsEvents.archiveChat,
        AnalyticsEvents.viewPricing,
        AnalyticsEvents.startCheckout,
        AnalyticsEvents.completePurchase,
        AnalyticsEvents.subscriptionStart,
        AnalyticsEvents.subscriptionCancel,
        AnalyticsEvents.virtualAttendancePurchase,
        AnalyticsEvents.viewVenue,
        AnalyticsEvents.searchVenues,
        AnalyticsEvents.getNearbyVenues,
        AnalyticsEvents.aiPredictionRequest,
        AnalyticsEvents.aiAnalysisRequest,
        AnalyticsEvents.chatbotMessage,
        AnalyticsEvents.appOpen,
        AnalyticsEvents.shareContent,
        AnalyticsEvents.notificationReceived,
        AnalyticsEvents.notificationOpened,
        AnalyticsEvents.searchPerformed,
        AnalyticsEvents.apiError,
        AnalyticsEvents.paymentError,
        AnalyticsEvents.authError,
      ];

      final uniqueEvents = events.toSet();
      expect(uniqueEvents.length, events.length,
          reason: 'All analytics event names should be unique');
    });

    test('event names follow snake_case convention', () {
      final events = [
        AnalyticsEvents.login,
        AnalyticsEvents.signUp,
        AnalyticsEvents.logout,
        AnalyticsEvents.screenView,
        AnalyticsEvents.viewMatch,
        AnalyticsEvents.makePrediction,
        AnalyticsEvents.createWatchParty,
        AnalyticsEvents.sendFriendRequest,
        AnalyticsEvents.sendMessage,
        AnalyticsEvents.startCheckout,
        AnalyticsEvents.completePurchase,
        AnalyticsEvents.viewVenue,
        AnalyticsEvents.aiPredictionRequest,
        AnalyticsEvents.appOpen,
        AnalyticsEvents.apiError,
      ];

      final snakeCaseRegex = RegExp(r'^[a-z][a-z0-9]*(_[a-z0-9]+)*$');

      for (final event in events) {
        expect(snakeCaseRegex.hasMatch(event), isTrue,
            reason: 'Event "$event" should follow snake_case convention');
      }
    });
  });

  group('AnalyticsUserProperties', () {
    test('userId is correct', () {
      expect(AnalyticsUserProperties.userId, 'user_id');
    });

    test('subscriptionTier is correct', () {
      expect(AnalyticsUserProperties.subscriptionTier, 'subscription_tier');
    });

    test('favoriteTeamCount is correct', () {
      expect(AnalyticsUserProperties.favoriteTeamCount, 'favorite_team_count');
    });

    test('primaryFavoriteTeam is correct', () {
      expect(
          AnalyticsUserProperties.primaryFavoriteTeam, 'primary_favorite_team');
    });

    test('watchPartiesAttended is correct', () {
      expect(AnalyticsUserProperties.watchPartiesAttended,
          'watch_parties_attended');
    });

    test('watchPartiesHosted is correct', () {
      expect(
          AnalyticsUserProperties.watchPartiesHosted, 'watch_parties_hosted');
    });

    test('predictionsCount is correct', () {
      expect(AnalyticsUserProperties.predictionsCount, 'predictions_count');
    });

    test('friendsCount is correct', () {
      expect(AnalyticsUserProperties.friendsCount, 'friends_count');
    });

    test('userLevel is correct', () {
      expect(AnalyticsUserProperties.userLevel, 'user_level');
    });

    test('appVersion is correct', () {
      expect(AnalyticsUserProperties.appVersion, 'app_version');
    });

    test('platform is correct', () {
      expect(AnalyticsUserProperties.platform, 'platform');
    });

    test('all property names are non-empty strings', () {
      final properties = [
        AnalyticsUserProperties.userId,
        AnalyticsUserProperties.subscriptionTier,
        AnalyticsUserProperties.favoriteTeamCount,
        AnalyticsUserProperties.primaryFavoriteTeam,
        AnalyticsUserProperties.watchPartiesAttended,
        AnalyticsUserProperties.watchPartiesHosted,
        AnalyticsUserProperties.predictionsCount,
        AnalyticsUserProperties.friendsCount,
        AnalyticsUserProperties.userLevel,
        AnalyticsUserProperties.appVersion,
        AnalyticsUserProperties.platform,
      ];

      for (final prop in properties) {
        expect(prop, isA<String>());
        expect(prop.isNotEmpty, isTrue);
      }
    });

    test('all property names are unique', () {
      final properties = [
        AnalyticsUserProperties.userId,
        AnalyticsUserProperties.subscriptionTier,
        AnalyticsUserProperties.favoriteTeamCount,
        AnalyticsUserProperties.primaryFavoriteTeam,
        AnalyticsUserProperties.watchPartiesAttended,
        AnalyticsUserProperties.watchPartiesHosted,
        AnalyticsUserProperties.predictionsCount,
        AnalyticsUserProperties.friendsCount,
        AnalyticsUserProperties.userLevel,
        AnalyticsUserProperties.appVersion,
        AnalyticsUserProperties.platform,
      ];

      final uniqueProps = properties.toSet();
      expect(uniqueProps.length, properties.length,
          reason: 'All user property names should be unique');
    });

    test('property names follow snake_case convention', () {
      final properties = [
        AnalyticsUserProperties.userId,
        AnalyticsUserProperties.subscriptionTier,
        AnalyticsUserProperties.favoriteTeamCount,
        AnalyticsUserProperties.primaryFavoriteTeam,
        AnalyticsUserProperties.watchPartiesAttended,
        AnalyticsUserProperties.watchPartiesHosted,
        AnalyticsUserProperties.predictionsCount,
        AnalyticsUserProperties.friendsCount,
        AnalyticsUserProperties.userLevel,
        AnalyticsUserProperties.appVersion,
        AnalyticsUserProperties.platform,
      ];

      final snakeCaseRegex = RegExp(r'^[a-z][a-z0-9]*(_[a-z0-9]+)*$');

      for (final prop in properties) {
        expect(snakeCaseRegex.hasMatch(prop), isTrue,
            reason: 'Property "$prop" should follow snake_case convention');
      }
    });
  });
}

import '../analytics_service.dart';

/// Domain-specific logging convenience methods as extensions on [AnalyticsService].
///
/// Keeping these as extensions means the core [AnalyticsService] class stays
/// small (initialization, generic `logEvent`, screen views, user identity)
/// while domain features can still call `analyticsService.logMatchView(...)`.
extension AuthAnalytics on AnalyticsService {
  /// Log user login
  Future<void> logLogin({required String method}) async {
    await logEvent(AnalyticsEvents.login, parameters: {
      'method': method,
    });
  }

  /// Log user sign up
  Future<void> logSignUp({required String method}) async {
    await logEvent(AnalyticsEvents.signUp, parameters: {
      'method': method,
    });
  }

  /// Log user logout
  Future<void> logLogout() async {
    await logEvent(AnalyticsEvents.logout);
    await clearUserId();
  }
}

extension WorldCupAnalytics on AnalyticsService {
  /// Log match view
  Future<void> logMatchView({
    required String matchId,
    required String homeTeam,
    required String awayTeam,
    String? stage,
  }) async {
    await logEvent(AnalyticsEvents.viewMatch, parameters: {
      'match_id': matchId,
      'home_team': homeTeam,
      'away_team': awayTeam,
      if (stage != null) 'stage': stage,
    });
  }

  /// Log team view
  Future<void> logTeamView({
    required String teamId,
    required String teamName,
    String? group,
  }) async {
    await logEvent(AnalyticsEvents.viewTeam, parameters: {
      'team_id': teamId,
      'team_name': teamName,
      if (group != null) 'group': group,
    });
  }

  /// Log favorite team action
  Future<void> logFavoriteTeam({
    required String teamId,
    required String teamName,
    required bool isFavoriting,
  }) async {
    await logEvent(
      isFavoriting ? AnalyticsEvents.favoriteTeam : AnalyticsEvents.unfavoriteTeam,
      parameters: {
        'team_id': teamId,
        'team_name': teamName,
      },
    );
  }

  /// Log prediction made
  Future<void> logPrediction({
    required String matchId,
    required String predictedWinner,
    int? homeScore,
    int? awayScore,
  }) async {
    await logEvent(AnalyticsEvents.makePrediction, parameters: {
      'match_id': matchId,
      'predicted_winner': predictedWinner,
      if (homeScore != null) 'home_score': homeScore,
      if (awayScore != null) 'away_score': awayScore,
    });
  }
}

extension WatchPartyAnalytics on AnalyticsService {
  /// Log watch party creation
  Future<void> logWatchPartyCreated({
    required String partyId,
    required String matchId,
    required bool isPublic,
    required bool allowsVirtual,
    double? virtualFee,
  }) async {
    await logEvent(AnalyticsEvents.createWatchParty, parameters: {
      'party_id': partyId,
      'match_id': matchId,
      'is_public': isPublic,
      'allows_virtual': allowsVirtual,
      if (virtualFee != null) 'virtual_fee': virtualFee,
    });
  }

  /// Log watch party join
  Future<void> logWatchPartyJoined({
    required String partyId,
    required bool isVirtual,
    double? amountPaid,
  }) async {
    await logEvent(AnalyticsEvents.joinWatchParty, parameters: {
      'party_id': partyId,
      'is_virtual': isVirtual,
      if (amountPaid != null) 'amount_paid': amountPaid,
    });
  }
}

extension SocialAnalytics on AnalyticsService {
  /// Log friend request sent
  Future<void> logFriendRequestSent({required String recipientId}) async {
    await logEvent(AnalyticsEvents.sendFriendRequest, parameters: {
      'recipient_id': recipientId,
    });
  }

  /// Log content report
  Future<void> logContentReported({
    required String contentType,
    required String reason,
  }) async {
    await logEvent(AnalyticsEvents.reportContent, parameters: {
      'content_type': contentType,
      'reason': reason,
    });
  }
}

extension MessagingAnalytics on AnalyticsService {
  /// Log message sent
  Future<void> logMessageSent({
    required String chatType,
    required String messageType,
  }) async {
    await logEvent(AnalyticsEvents.sendMessage, parameters: {
      'chat_type': chatType,
      'message_type': messageType,
    });
  }
}

extension PaymentAnalytics on AnalyticsService {
  /// Log purchase started
  Future<void> logBeginCheckout({
    required String itemId,
    required String itemName,
    required double price,
    String? currency,
  }) async {
    await logEvent(AnalyticsEvents.startCheckout, parameters: {
      'item_id': itemId,
      'item_name': itemName,
      'value': price,
      'currency': currency ?? 'USD',
    });
  }

  /// Log purchase completed
  Future<void> logPurchase({
    required String transactionId,
    required String itemId,
    required String itemName,
    required double price,
    String? currency,
  }) async {
    await logEvent(AnalyticsEvents.completePurchase, parameters: {
      'transaction_id': transactionId,
      'item_id': itemId,
      'item_name': itemName,
      'value': price,
      'currency': currency ?? 'USD',
    });
  }

  /// Log subscription start
  Future<void> logSubscriptionStart({
    required String subscriptionId,
    required String tier,
    required double price,
  }) async {
    await logEvent(AnalyticsEvents.subscriptionStart, parameters: {
      'subscription_id': subscriptionId,
      'tier': tier,
      'value': price,
    });

    await setUserProperty(AnalyticsUserProperties.subscriptionTier, tier);
  }
}

extension NotificationAnalytics on AnalyticsService {
  /// Log notification received
  Future<void> logNotificationReceived({
    required String notificationType,
    String? title,
  }) async {
    await logEvent(AnalyticsEvents.notificationReceived, parameters: {
      'notification_type': notificationType,
      if (title != null) 'title': title,
    });
  }

  /// Log notification opened
  Future<void> logNotificationOpened({
    required String notificationType,
    String? action,
  }) async {
    await logEvent(AnalyticsEvents.notificationOpened, parameters: {
      'notification_type': notificationType,
      if (action != null) 'action': action,
    });
  }
}

extension SearchAnalytics on AnalyticsService {
  /// Log search performed
  Future<void> logSearch({
    required String searchTerm,
    String? searchType,
    int? resultsCount,
  }) async {
    await logEvent(AnalyticsEvents.searchPerformed, parameters: {
      'search_term': searchTerm,
      if (searchType != null) 'search_type': searchType,
      if (resultsCount != null) 'results_count': resultsCount,
    });
  }
}

extension ShareAnalytics on AnalyticsService {
  /// Log content shared
  Future<void> logShare({
    required String contentType,
    required String itemId,
    String? method,
  }) async {
    await logEvent(AnalyticsEvents.shareContent, parameters: {
      'content_type': contentType,
      'item_id': itemId,
      if (method != null) 'method': method,
    });
  }
}

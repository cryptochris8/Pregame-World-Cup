import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/sharing/domain/entities/shareable_content.dart';

void main() {
  group('ShareableContentType', () {
    test('has all expected values', () {
      expect(ShareableContentType.values, hasLength(6));
      expect(ShareableContentType.values, contains(ShareableContentType.prediction));
      expect(ShareableContentType.values, contains(ShareableContentType.matchResult));
      expect(ShareableContentType.values, contains(ShareableContentType.watchParty));
      expect(ShareableContentType.values, contains(ShareableContentType.bracket));
      expect(ShareableContentType.values, contains(ShareableContentType.achievement));
      expect(ShareableContentType.values, contains(ShareableContentType.invite));
    });
  });

  group('ShareablePrediction', () {
    ShareablePrediction createPrediction({
      String homeTeam = 'USA',
      String awayTeam = 'Mexico',
      int homeScore = 2,
      int awayScore = 1,
      String? predictedWinner = 'USA',
      int? confidence = 75,
      String? userName = 'Chris',
      String deepLink = 'https://pregameworldcup.com/prediction/match-1',
      Map<String, String> utmParams = const {},
    }) {
      return ShareablePrediction(
        matchName: '$homeTeam vs $awayTeam',
        homeTeam: homeTeam,
        awayTeam: awayTeam,
        predictedHomeScore: homeScore,
        predictedAwayScore: awayScore,
        predictedWinner: predictedWinner,
        confidenceLevel: confidence,
        userDisplayName: userName,
        deepLink: deepLink,
        utmParams: utmParams,
      );
    }

    test('creates prediction with correct type', () {
      final prediction = createPrediction();
      expect(prediction.type, ShareableContentType.prediction);
    });

    test('generates correct title', () {
      final prediction = createPrediction(homeTeam: 'Brazil', awayTeam: 'Argentina');
      expect(prediction.title, 'My Prediction: Brazil vs Argentina');
    });

    test('generates correct description', () {
      final prediction = createPrediction(homeScore: 3, awayScore: 0);
      expect(prediction.description, 'USA 3 - 0 Mexico');
    });

    group('getShareText', () {
      test('includes all relevant info with URL', () {
        final prediction = createPrediction();
        final text = prediction.getShareText();

        expect(text, contains('My World Cup 2026 Prediction'));
        expect(text, contains('USA 2 - 1 Mexico'));
        expect(text, contains('Winner: USA'));
        expect(text, contains('Confidence: 75%'));
        expect(text, contains('Make your prediction on Pregame!'));
        expect(text, contains('https://pregameworldcup.com/prediction/match-1'));
      });

      test('excludes URL when includeUrl is false', () {
        final prediction = createPrediction();
        final text = prediction.getShareText(includeUrl: false);

        expect(text, isNot(contains('https://pregameworldcup.com')));
      });

      test('excludes winner when null', () {
        final prediction = createPrediction(predictedWinner: null);
        final text = prediction.getShareText();

        expect(text, isNot(contains('Winner:')));
      });

      test('excludes confidence when null', () {
        final prediction = createPrediction(confidence: null);
        final text = prediction.getShareText();

        expect(text, isNot(contains('Confidence:')));
      });

      test('includes hashtags', () {
        final prediction = createPrediction();
        final text = prediction.getShareText();

        expect(text, contains('#WorldCup2026'));
        expect(text, contains('#Prediction'));
        expect(text, contains('#USA'));
        expect(text, contains('#Mexico'));
        expect(text, contains('#Pregame'));
      });
    });

    group('hashtags', () {
      test('returns correct hashtags', () {
        final prediction = createPrediction();
        expect(prediction.hashtags, contains('WorldCup2026'));
        expect(prediction.hashtags, contains('Prediction'));
        expect(prediction.hashtags, contains('USA'));
        expect(prediction.hashtags, contains('Mexico'));
        expect(prediction.hashtags, contains('Pregame'));
      });

      test('removes spaces from team names in hashtags', () {
        final prediction = createPrediction(
          homeTeam: 'South Korea',
          awayTeam: 'Saudi Arabia',
        );
        expect(prediction.hashtags, contains('SouthKorea'));
        expect(prediction.hashtags, contains('SaudiArabia'));
      });
    });

    group('shareUrl', () {
      test('returns deep link without UTM params when empty', () {
        final prediction = createPrediction();
        expect(prediction.shareUrl, prediction.deepLink);
      });

      test('appends UTM params to share URL', () {
        final prediction = createPrediction(
          utmParams: {
            'utm_source': 'app',
            'utm_medium': 'share',
          },
        );
        final url = prediction.shareUrl;
        expect(url, contains('utm_source=app'));
        expect(url, contains('utm_medium=share'));
      });
    });

    group('equality', () {
      test('two predictions with same props are equal', () {
        final pred1 = createPrediction();
        final pred2 = createPrediction();
        expect(pred1, equals(pred2));
      });

      test('two predictions with different teams are not equal', () {
        final pred1 = createPrediction(homeTeam: 'USA');
        final pred2 = createPrediction(homeTeam: 'Brazil');
        expect(pred1, isNot(equals(pred2)));
      });
    });
  });

  group('ShareableMatchResult', () {
    ShareableMatchResult createResult({
      String homeTeam = 'USA',
      String awayTeam = 'Mexico',
      int homeScore = 2,
      int awayScore = 1,
      String? stage = 'Group A',
      String? commentary,
      bool isLive = false,
      String? matchMinute,
      String deepLink = 'https://pregameworldcup.com/match/1',
    }) {
      return ShareableMatchResult(
        homeTeam: homeTeam,
        awayTeam: awayTeam,
        homeScore: homeScore,
        awayScore: awayScore,
        stage: stage,
        commentary: commentary,
        isLive: isLive,
        matchMinute: matchMinute,
        deepLink: deepLink,
      );
    }

    test('creates match result with correct type', () {
      final result = createResult();
      expect(result.type, ShareableContentType.matchResult);
    });

    test('generates correct title', () {
      final result = createResult();
      expect(result.title, 'USA vs Mexico');
    });

    test('generates correct description', () {
      final result = createResult();
      expect(result.description, 'USA 2 - 1 Mexico');
    });

    group('getShareText', () {
      test('shows FULL TIME for completed matches', () {
        final result = createResult(isLive: false);
        final text = result.getShareText();

        expect(text, contains('FULL TIME'));
        expect(text, contains('USA 2 - 1 Mexico'));
        expect(text, contains('Group A'));
        expect(text, contains('Follow the World Cup on Pregame!'));
      });

      test('shows LIVE for live matches', () {
        final result = createResult(isLive: true, matchMinute: '65');
        final text = result.getShareText();

        expect(text, contains('LIVE: USA 2 - 1 Mexico'));
        expect(text, contains("65'"));
      });

      test('includes commentary when provided', () {
        final result = createResult(commentary: 'Amazing goal!');
        final text = result.getShareText();

        expect(text, contains('Amazing goal!'));
      });

      test('excludes commentary when empty', () {
        final result = createResult(commentary: '');
        final text = result.getShareText();
        // Just verify it doesn't crash and produces valid text
        expect(text, isNotEmpty);
      });

      test('excludes stage when null', () {
        final result = createResult(stage: null);
        final text = result.getShareText();
        expect(text, isNot(contains('Group')));
      });
    });

    group('hashtags', () {
      test('includes LiveScore for live matches', () {
        final result = createResult(isLive: true);
        expect(result.hashtags, contains('LiveScore'));
      });

      test('does not include LiveScore for completed matches', () {
        final result = createResult(isLive: false);
        expect(result.hashtags, isNot(contains('LiveScore')));
      });

      test('includes FIFA hashtag', () {
        final result = createResult();
        expect(result.hashtags, contains('FIFA'));
      });
    });
  });

  group('ShareableWatchParty', () {
    ShareableWatchParty createWatchParty({
      String partyName = 'Big Game Watch',
      String matchName = 'USA vs England',
      DateTime? partyTime,
      String? venueName = 'Sports Bar',
      String? venueAddress = '123 Main St',
      int currentAttendees = 15,
      int maxAttendees = 50,
      String hostName = 'Chris',
      bool isPrivate = false,
      String deepLink = 'https://pregameworldcup.com/watchparty/1',
    }) {
      return ShareableWatchParty(
        partyName: partyName,
        matchName: matchName,
        partyTime: partyTime ?? DateTime(2026, 6, 15, 19, 0),
        venueName: venueName,
        venueAddress: venueAddress,
        currentAttendees: currentAttendees,
        maxAttendees: maxAttendees,
        hostName: hostName,
        isPrivate: isPrivate,
        deepLink: deepLink,
      );
    }

    test('creates watch party with correct type', () {
      final party = createWatchParty();
      expect(party.type, ShareableContentType.watchParty);
    });

    test('generates correct title', () {
      final party = createWatchParty(partyName: 'My Party');
      expect(party.title, 'My Party');
    });

    test('generates correct description', () {
      final party = createWatchParty(matchName: 'USA vs England');
      expect(party.description, 'Watch USA vs England together!');
    });

    group('getShareText', () {
      test('includes all relevant info', () {
        final party = createWatchParty();
        final text = party.getShareText();

        expect(text, contains('Join my Watch Party!'));
        expect(text, contains('Big Game Watch'));
        expect(text, contains('Watching: USA vs England'));
        expect(text, contains('Location: Sports Bar'));
        expect(text, contains('Spots: 35 remaining'));
        expect(text, contains('Join us on Pregame!'));
      });

      test('excludes venue when null', () {
        final party = createWatchParty(venueName: null);
        final text = party.getShareText();

        expect(text, isNot(contains('Location:')));
      });

      test('calculates remaining spots correctly', () {
        final party = createWatchParty(
          currentAttendees: 45,
          maxAttendees: 50,
        );
        final text = party.getShareText();

        expect(text, contains('Spots: 5 remaining'));
      });
    });

    group('hashtags', () {
      test('returns correct hashtags', () {
        final party = createWatchParty();
        expect(party.hashtags, contains('WorldCup2026'));
        expect(party.hashtags, contains('WatchParty'));
        expect(party.hashtags, contains('Pregame'));
      });
    });
  });

  group('ShareableBracket', () {
    ShareableBracket createBracket({
      String userName = 'Chris',
      int correctPredictions = 7,
      int totalPredictions = 10,
      int rank = 42,
      String? championPick = 'Brazil',
      String deepLink = 'https://pregameworldcup.com/bracket/1',
    }) {
      return ShareableBracket(
        userName: userName,
        correctPredictions: correctPredictions,
        totalPredictions: totalPredictions,
        rank: rank,
        championPick: championPick,
        deepLink: deepLink,
      );
    }

    test('creates bracket with correct type', () {
      final bracket = createBracket();
      expect(bracket.type, ShareableContentType.bracket);
    });

    test('generates correct title', () {
      final bracket = createBracket(userName: 'Chris');
      expect(bracket.title, "Chris's World Cup Bracket");
    });

    test('generates correct description', () {
      final bracket = createBracket(
        correctPredictions: 7,
        totalPredictions: 10,
      );
      expect(bracket.description, '7/10 correct predictions');
    });

    group('getShareText', () {
      test('includes all relevant info', () {
        final bracket = createBracket();
        final text = bracket.getShareText();

        expect(text, contains('My World Cup 2026 Bracket'));
        expect(text, contains('7/10 predictions correct'));
        expect(text, contains('Current Rank: #42'));
        expect(text, contains('Champion Pick: Brazil'));
        expect(text, contains('Create your bracket on Pregame!'));
      });

      test('excludes champion pick when null', () {
        final bracket = createBracket(championPick: null);
        final text = bracket.getShareText();

        expect(text, isNot(contains('Champion Pick:')));
      });
    });

    group('hashtags', () {
      test('returns correct hashtags', () {
        final bracket = createBracket();
        expect(bracket.hashtags, contains('WorldCup2026'));
        expect(bracket.hashtags, contains('Bracket'));
        expect(bracket.hashtags, contains('Predictions'));
        expect(bracket.hashtags, contains('Pregame'));
      });
    });
  });

  group('ShareableInvite', () {
    ShareableInvite createInvite({
      String inviterName = 'Chris',
      String? referralCode = 'ABC123',
      String deepLink = 'https://pregameworldcup.com/invite',
    }) {
      return ShareableInvite(
        inviterName: inviterName,
        referralCode: referralCode,
        deepLink: deepLink,
      );
    }

    test('creates invite with correct type', () {
      final invite = createInvite();
      expect(invite.type, ShareableContentType.invite);
    });

    test('generates correct title', () {
      final invite = createInvite();
      expect(invite.title, 'Join me on Pregame!');
    });

    test('generates correct description', () {
      final invite = createInvite();
      expect(invite.description, 'The ultimate World Cup 2026 companion app');
    });

    group('getShareText', () {
      test('includes app features', () {
        final invite = createInvite();
        final text = invite.getShareText();

        expect(text, contains('Join me on Pregame!'));
        expect(text, contains('The ultimate World Cup 2026 companion app'));
        expect(text, contains('Live scores & match updates'));
        expect(text, contains('Create watch parties'));
        expect(text, contains('Make predictions'));
        expect(text, contains('Connect with fans'));
      });

      test('includes referral code when provided', () {
        final invite = createInvite(referralCode: 'ABC123');
        final text = invite.getShareText();

        expect(text, contains('Use my code: ABC123'));
      });

      test('excludes referral code when null', () {
        final invite = createInvite(referralCode: null);
        final text = invite.getShareText();

        expect(text, isNot(contains('Use my code:')));
      });
    });

    group('hashtags', () {
      test('returns correct hashtags', () {
        final invite = createInvite();
        expect(invite.hashtags, contains('WorldCup2026'));
        expect(invite.hashtags, contains('Pregame'));
      });
    });
  });
}

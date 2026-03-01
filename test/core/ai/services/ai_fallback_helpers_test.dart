import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/core/ai/services/ai_fallback_helpers.dart';

void main() {
  group('AIFallbackHelpers', () {
    group('generateFallbackResponse', () {
      test('returns venue recommendation for venue prompt', () {
        final response =
            AIFallbackHelpers.generateFallbackResponse('Find a venue nearby');
        expect(response, contains('sports bars'));
      });

      test('returns venue recommendation for restaurant prompt', () {
        final response = AIFallbackHelpers.generateFallbackResponse(
            'Best restaurant for match day');
        expect(response, contains('sports bars'));
      });

      test('returns venue recommendation for bar prompt', () {
        final response =
            AIFallbackHelpers.generateFallbackResponse('Which bar to go to');
        expect(response, contains('sports bars'));
      });

      test('returns prediction response for prediction prompt', () {
        final response = AIFallbackHelpers.generateFallbackResponse(
            'Give me a prediction for the match');
        expect(response, contains('exciting match'));
      });

      test('returns prediction response for game prompt', () {
        final response = AIFallbackHelpers.generateFallbackResponse(
            'How will the game go?');
        expect(response, contains('exciting match'));
      });

      test('returns prediction response for score prompt', () {
        final response = AIFallbackHelpers.generateFallbackResponse(
            'What will the final score be?');
        expect(response, contains('exciting match'));
      });

      test('returns generic response for unrecognized prompt', () {
        final response = AIFallbackHelpers.generateFallbackResponse(
            'Tell me about the weather');
        expect(response, contains('match day experience'));
      });

      test('is case insensitive', () {
        final responseLower =
            AIFallbackHelpers.generateFallbackResponse('find a VENUE');
        final responseUpper =
            AIFallbackHelpers.generateFallbackResponse('FIND A venue');
        expect(responseLower, equals(responseUpper));
      });

      test('handles empty prompt', () {
        final response = AIFallbackHelpers.generateFallbackResponse('');
        expect(response, isNotEmpty);
        expect(response, contains('match day experience'));
      });
    });

    group('generateMockEmbedding', () {
      test('returns a list of 1536 doubles', () {
        final embedding =
            AIFallbackHelpers.generateMockEmbedding('test input');
        expect(embedding, hasLength(1536));
      });

      test('all values are between -1 and 1', () {
        final embedding =
            AIFallbackHelpers.generateMockEmbedding('test input');
        for (final value in embedding) {
          expect(value, greaterThanOrEqualTo(-1.0));
          expect(value, lessThanOrEqualTo(1.0));
        }
      });

      test('produces deterministic output for same input', () {
        final embedding1 =
            AIFallbackHelpers.generateMockEmbedding('same text');
        final embedding2 =
            AIFallbackHelpers.generateMockEmbedding('same text');
        expect(embedding1, equals(embedding2));
      });

      test('produces different output for different input', () {
        final embedding1 =
            AIFallbackHelpers.generateMockEmbedding('text one');
        final embedding2 =
            AIFallbackHelpers.generateMockEmbedding('text two');
        expect(embedding1, isNot(equals(embedding2)));
      });

      test('handles empty text', () {
        final embedding = AIFallbackHelpers.generateMockEmbedding('');
        expect(embedding, hasLength(1536));
      });
    });

    group('generateFallbackUserInsights', () {
      test('returns expected keys', () {
        final insights = AIFallbackHelpers.generateFallbackUserInsights({});
        expect(insights, containsPair('teamAffinityScores', isA<Map>()));
        expect(
            insights, containsPair('interactionPatterns', isA<Map>()));
        expect(insights,
            containsPair('preferredGameTypes', isA<List>()));
        expect(
            insights, containsPair('recommendedVenues', isA<List>()));
        expect(
            insights, containsPair('engagementScore', isA<double>()));
      });

      test('returns empty team scores when no interactions', () {
        final insights = AIFallbackHelpers.generateFallbackUserInsights({});
        final teamScores =
            insights['teamAffinityScores'] as Map<String, double>;
        expect(teamScores, isEmpty);
      });

      test('returns low engagement score for few interactions', () {
        final insights = AIFallbackHelpers.generateFallbackUserInsights({
          'gameInteractions': [
            {'homeTeam': 'Brazil', 'awayTeam': 'France', 'interactionType': 'view'},
          ],
        });
        expect(insights['engagementScore'], equals(0.3));
      });

      test('returns high engagement score for many interactions', () {
        final interactions = List.generate(
          6,
          (i) => {
            'homeTeam': 'Brazil',
            'awayTeam': 'France',
            'interactionType': 'view',
          },
        );
        final insights = AIFallbackHelpers.generateFallbackUserInsights({
          'gameInteractions': interactions,
        });
        expect(insights['engagementScore'], equals(0.7));
      });

      test('calculates team affinity scores correctly', () {
        final insights = AIFallbackHelpers.generateFallbackUserInsights({
          'gameInteractions': [
            {'homeTeam': 'Brazil', 'awayTeam': 'France', 'interactionType': 'view'},
            {'homeTeam': 'Brazil', 'awayTeam': 'Germany', 'interactionType': 'view'},
          ],
        });
        final teamScores =
            insights['teamAffinityScores'] as Map<String, double>;

        // Brazil appears in both interactions (count=2), total=2
        // So Brazil affinity = 2/2 = 1.0
        expect(teamScores['Brazil'], equals(1.0));
        // France appears once, affinity = 1/2 = 0.5
        expect(teamScores['France'], equals(0.5));
        // Germany appears once, affinity = 1/2 = 0.5
        expect(teamScores['Germany'], equals(0.5));
      });

      test('calculates interaction patterns correctly', () {
        final insights = AIFallbackHelpers.generateFallbackUserInsights({
          'gameInteractions': [
            {'homeTeam': 'Brazil', 'awayTeam': 'France', 'interactionType': 'view'},
            {'homeTeam': 'Brazil', 'awayTeam': 'France', 'interactionType': 'favorite'},
            {'homeTeam': 'Brazil', 'awayTeam': 'France', 'interactionType': 'view'},
          ],
        });
        final patterns =
            insights['interactionPatterns'] as Map<String, dynamic>;

        // 2 views out of 3 total
        expect(patterns['gameViews'], closeTo(2 / 3, 0.01));
        // 1 favorite out of 3 total
        expect(patterns['favorites'], closeTo(1 / 3, 0.01));
      });

      test('handles null homeTeam and awayTeam gracefully', () {
        final insights = AIFallbackHelpers.generateFallbackUserInsights({
          'gameInteractions': [
            {'interactionType': 'view'},
            {'homeTeam': null, 'awayTeam': null, 'interactionType': 'view'},
          ],
        });
        final teamScores =
            insights['teamAffinityScores'] as Map<String, double>;
        expect(teamScores, isEmpty);
      });

      test('always includes default game types and venue recommendations', () {
        final insights = AIFallbackHelpers.generateFallbackUserInsights({});
        expect(insights['preferredGameTypes'],
            containsAll(['group_stage', 'knockout']));
        expect(insights['recommendedVenues'],
            containsAll(['sports_bar', 'fan_zone']));
      });
    });

    group('generateFallbackGameRecommendations', () {
      test('returns empty list when no upcoming games', () {
        final recommendations =
            AIFallbackHelpers.generateFallbackGameRecommendations(
          [],
          {'teamAffinityScores': <String, double>{}},
          5,
        );
        expect(recommendations, isEmpty);
      });

      test('respects limit parameter', () {
        final games = List.generate(
          10,
          (i) => <String, dynamic>{
            'GameID': i,
            'HomeTeam': 'Team$i',
            'AwayTeam': 'Opponent$i',
            'DateTimeUTC': '2026-06-15T18:00:00Z',
          },
        );
        final recommendations =
            AIFallbackHelpers.generateFallbackGameRecommendations(
          games,
          {'teamAffinityScores': <String, double>{}},
          3,
        );
        expect(recommendations, hasLength(3));
      });

      test('returns all games when fewer than limit', () {
        final games = [
          {
            'GameID': 1,
            'HomeTeam': 'Brazil',
            'AwayTeam': 'France',
            'DateTimeUTC': '2026-06-15T18:00:00Z',
          },
        ];
        final recommendations =
            AIFallbackHelpers.generateFallbackGameRecommendations(
          games,
          {'teamAffinityScores': <String, double>{}},
          5,
        );
        expect(recommendations, hasLength(1));
      });

      test('each recommendation has expected fields', () {
        final games = [
          {
            'GameID': 1,
            'HomeTeam': 'Brazil',
            'AwayTeam': 'France',
            'DateTimeUTC': '2026-06-15T18:00:00Z',
          },
        ];
        final recommendations =
            AIFallbackHelpers.generateFallbackGameRecommendations(
          games,
          {'teamAffinityScores': <String, double>{}},
          5,
        );
        final rec = recommendations.first;
        expect(rec, containsPair('gameId', '1'));
        expect(rec, containsPair('homeTeam', 'Brazil'));
        expect(rec, containsPair('awayTeam', 'France'));
        expect(rec['score'], isA<double>());
        expect(rec['reasons'], isA<List>());
        expect(rec['gameTime'], equals('2026-06-15T18:00:00Z'));
        expect(rec['gameData'], isA<Map>());
      });

      test('scores games higher when teams match user affinity', () {
        final games = [
          {
            'GameID': 1,
            'HomeTeam': 'Brazil',
            'AwayTeam': 'France',
            'DateTimeUTC': '2026-06-15T18:00:00Z',
          },
          {
            'GameID': 2,
            'HomeTeam': 'Unknown1',
            'AwayTeam': 'Unknown2',
            'DateTimeUTC': '2026-06-15T20:00:00Z',
          },
        ];
        // Run multiple times to account for randomness and check average
        var affinityGameRankedFirst = 0;
        const iterations = 20;
        for (var i = 0; i < iterations; i++) {
          final recommendations =
              AIFallbackHelpers.generateFallbackGameRecommendations(
            games,
            {
              'teamAffinityScores': {'Brazil': 0.9, 'France': 0.8},
            },
            2,
          );
          if (recommendations.first['gameId'] == '1') {
            affinityGameRankedFirst++;
          }
        }
        // The Brazil/France game should be ranked first most of the time
        expect(affinityGameRankedFirst, greaterThan(iterations ~/ 2));
      });

      test('uses DateTime fallback when DateTimeUTC not available', () {
        final games = [
          {
            'GameID': 1,
            'HomeTeam': 'Brazil',
            'AwayTeam': 'France',
            'DateTime': '2026-06-15T18:00:00',
          },
        ];
        final recommendations =
            AIFallbackHelpers.generateFallbackGameRecommendations(
          games,
          {'teamAffinityScores': <String, double>{}},
          5,
        );
        expect(recommendations.first['gameTime'], equals('2026-06-15T18:00:00'));
      });

      test('handles missing GameID gracefully', () {
        final games = [
          {
            'HomeTeam': 'Brazil',
            'AwayTeam': 'France',
          },
        ];
        final recommendations =
            AIFallbackHelpers.generateFallbackGameRecommendations(
          games,
          {'teamAffinityScores': <String, double>{}},
          5,
        );
        expect(recommendations.first['gameId'], equals(''));
      });

      test('handles missing team names gracefully', () {
        final games = [
          {
            'GameID': 1,
            'DateTimeUTC': '2026-06-15T18:00:00Z',
          },
        ];
        final recommendations =
            AIFallbackHelpers.generateFallbackGameRecommendations(
          games,
          {'teamAffinityScores': <String, double>{}},
          5,
        );
        expect(recommendations.first['homeTeam'], equals(''));
        expect(recommendations.first['awayTeam'], equals(''));
      });
    });

    group('generateFallbackPrediction', () {
      test('returns all expected keys', () {
        final prediction = AIFallbackHelpers.generateFallbackPrediction(
            'Brazil', 'France');
        expect(prediction, contains('prediction'));
        expect(prediction, contains('confidence'));
        expect(prediction, contains('predictedScore'));
        expect(prediction, contains('keyFactors'));
        expect(prediction, contains('analysis'));
        expect(prediction, contains('playerMatchups'));
        expect(prediction, contains('venueImpact'));
        expect(prediction, contains('source'));
      });

      test('prediction is one of home_win, away_win, or draw', () {
        final prediction = AIFallbackHelpers.generateFallbackPrediction(
            'Brazil', 'France');
        expect(
          prediction['prediction'],
          isIn(['home_win', 'away_win', 'draw']),
        );
      });

      test('confidence is between 0.55 and 0.85', () {
        // Test with multiple team combinations
        final teams = ['Brazil', 'France', 'Germany', 'Argentina', 'Spain',
            'England', 'USA', 'Mexico', 'Japan', 'South Korea'];
        for (final home in teams) {
          for (final away in teams) {
            if (home == away) continue;
            final prediction =
                AIFallbackHelpers.generateFallbackPrediction(home, away);
            final confidence = prediction['confidence'] as double;
            expect(confidence, greaterThanOrEqualTo(0.55),
                reason: 'Failed for $home vs $away');
            expect(confidence, lessThanOrEqualTo(0.85),
                reason: 'Failed for $home vs $away');
          }
        }
      });

      test('predicted score contains home and away', () {
        final prediction = AIFallbackHelpers.generateFallbackPrediction(
            'Brazil', 'France');
        final score = prediction['predictedScore'] as Map<String, dynamic>;
        expect(score, contains('home'));
        expect(score, contains('away'));
        expect(score['home'], isA<int>());
        expect(score['away'], isA<int>());
      });

      test('predicted scores are non-negative', () {
        final prediction = AIFallbackHelpers.generateFallbackPrediction(
            'Brazil', 'France');
        final score = prediction['predictedScore'] as Map<String, dynamic>;
        expect(score['home'] as int, greaterThanOrEqualTo(0));
        expect(score['away'] as int, greaterThanOrEqualTo(0));
      });

      test('produces deterministic output for same teams', () {
        final prediction1 = AIFallbackHelpers.generateFallbackPrediction(
            'Brazil', 'France');
        final prediction2 = AIFallbackHelpers.generateFallbackPrediction(
            'Brazil', 'France');
        expect(prediction1['prediction'], equals(prediction2['prediction']));
        expect(prediction1['predictedScore'],
            equals(prediction2['predictedScore']));
      });

      test('key factors is a non-empty list of strings', () {
        final prediction = AIFallbackHelpers.generateFallbackPrediction(
            'Brazil', 'France');
        final factors = prediction['keyFactors'] as List<String>;
        expect(factors, isNotEmpty);
        for (final factor in factors) {
          expect(factor, isNotEmpty);
        }
      });

      test('key factors include special entry for elite teams', () {
        // Brazil is in the elite team list
        final prediction = AIFallbackHelpers.generateFallbackPrediction(
            'Brazil', 'Mexico');
        final factors = prediction['keyFactors'] as List<String>;
        expect(
          factors.any((f) => f.contains('squad depth')),
          isTrue,
        );
      });

      test('key factors include special entry for Argentina/Spain away', () {
        final prediction = AIFallbackHelpers.generateFallbackPrediction(
            'USA', 'Argentina');
        final factors = prediction['keyFactors'] as List<String>;
        expect(
          factors.any((f) => f.contains('tactical identity')),
          isTrue,
        );
      });

      test('analysis contains team names', () {
        final prediction = AIFallbackHelpers.generateFallbackPrediction(
            'Brazil', 'France');
        final analysis = prediction['analysis'] as String;
        expect(analysis, contains('Brazil'));
      });

      test('player matchups is a list of 3 matchups', () {
        final prediction = AIFallbackHelpers.generateFallbackPrediction(
            'Brazil', 'France');
        final matchups = prediction['playerMatchups']
            as List<Map<String, String>>;
        expect(matchups, hasLength(3));
        for (final matchup in matchups) {
          expect(matchup, contains('matchup'));
          expect(matchup, contains('description'));
          expect(matchup, contains('impact'));
        }
      });

      test('player matchups reference team names', () {
        final prediction = AIFallbackHelpers.generateFallbackPrediction(
            'Brazil', 'France');
        final matchups = prediction['playerMatchups']
            as List<Map<String, String>>;
        for (final matchup in matchups) {
          final desc = matchup['description']!;
          expect(
            desc.contains('Brazil') || desc.contains('France'),
            isTrue,
            reason: 'Matchup description should reference team names: $desc',
          );
        }
      });

      test('venue impact references known venue for mapped teams', () {
        final prediction = AIFallbackHelpers.generateFallbackPrediction(
            'United States', 'France');
        final venueImpact = prediction['venueImpact'] as String;
        expect(venueImpact, contains('MetLife Stadium'));
      });

      test('venue impact uses generic text for unmapped teams', () {
        final prediction = AIFallbackHelpers.generateFallbackPrediction(
            'Japan', 'South Korea');
        final venueImpact = prediction['venueImpact'] as String;
        expect(venueImpact, contains('designated World Cup venue'));
      });

      test('source is Enhanced Statistical Analysis', () {
        final prediction = AIFallbackHelpers.generateFallbackPrediction(
            'Brazil', 'France');
        expect(prediction['source'], equals('Enhanced Statistical Analysis'));
      });

      test('draw prediction when home and away score equal', () {
        // We need to find teams that produce equal scores.
        // homeScore = (homeHash % 4) + (homeHash % 2)
        // awayScore = awayHash % 4
        // They're equal when homeBaseScore + homeBonus == awayBaseScore
        // Let's just verify the logic: if scores are equal, prediction is 'draw'
        final teams = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',
            'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T'];
        for (final home in teams) {
          for (final away in teams) {
            if (home == away) continue;
            final prediction =
                AIFallbackHelpers.generateFallbackPrediction(home, away);
            final score =
                prediction['predictedScore'] as Map<String, dynamic>;
            final homeScore = score['home'] as int;
            final awayScore = score['away'] as int;
            final pred = prediction['prediction'] as String;

            if (homeScore == awayScore) {
              expect(pred, equals('draw'),
                  reason: '$home vs $away: $homeScore-$awayScore should be draw');
            } else if (homeScore > awayScore) {
              expect(pred, equals('home_win'),
                  reason: '$home vs $away: $homeScore-$awayScore should be home_win');
            } else {
              expect(pred, equals('away_win'),
                  reason: '$home vs $away: $homeScore-$awayScore should be away_win');
            }
          }
        }
      });
    });
  });
}

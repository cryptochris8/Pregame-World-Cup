import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/chatbot/data/services/chatbot_knowledge_base.dart';
import 'package:pregame_world_cup/features/chatbot/domain/entities/chat_intent.dart';
import 'package:pregame_world_cup/features/chatbot/domain/services/intent_classifier.dart';
import 'package:pregame_world_cup/features/worldcup/data/services/enhanced_match_data_service.dart';

import '../../helpers/mock_knowledge_data.dart';

void main() {
  late ChatbotKnowledgeBase kb;
  late IntentClassifier classifier;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    setupMockAssetBundle();

    kb = ChatbotKnowledgeBase(enhancedData: EnhancedMatchDataService.instance);
    await kb.initialize();
    classifier = IntentClassifier(knowledgeBase: kb);
  });

  tearDownAll(() {
    tearDownMockAssetBundle();
  });

  setUp(() {
    classifier.reset();
  });

  group('Greeting intent', () {
    test('classifies "hello" as greeting', () {
      final result = classifier.classify('hello');
      expect(result.type, ChatIntentType.greeting);
    });

    test('classifies "hi" as greeting', () {
      final result = classifier.classify('hi');
      expect(result.type, ChatIntentType.greeting);
    });

    test('classifies "hey" as greeting', () {
      final result = classifier.classify('hey');
      expect(result.type, ChatIntentType.greeting);
    });

    test('classifies "good morning" as greeting', () {
      final result = classifier.classify('good morning');
      expect(result.type, ChatIntentType.greeting);
    });

    test('does NOT classify long messages starting with hi as greeting', () {
      final result = classifier.classify(
          'hi, can you tell me about the history of the world cup '
          'and all the records that have been set over the years');
      // Long message — should detect history instead
      expect(result.type, isNot(ChatIntentType.greeting));
    });
  });

  group('Thanks intent', () {
    test('classifies "thanks" as thanks', () {
      final result = classifier.classify('thanks');
      expect(result.type, ChatIntentType.thanks);
    });

    test('classifies "thank you" as thanks', () {
      final result = classifier.classify('thank you');
      expect(result.type, ChatIntentType.thanks);
    });

    test('classifies "appreciate it" as thanks', () {
      final result = classifier.classify('I appreciate it');
      expect(result.type, ChatIntentType.thanks);
    });
  });

  group('App help intent', () {
    test('classifies "help" as appHelp', () {
      final result = classifier.classify('help');
      expect(result.type, ChatIntentType.appHelp);
    });

    test('classifies "how do i use this" as appHelp', () {
      final result = classifier.classify('how do i use this');
      expect(result.type, ChatIntentType.appHelp);
    });

    test('classifies "what can you do" as appHelp', () {
      final result = classifier.classify('what can you do');
      expect(result.type, ChatIntentType.appHelp);
    });
  });

  group('Schedule intent', () {
    test('classifies "when does USA play" as schedule with team entity', () {
      final result = classifier.classify('when does USA play');
      expect(result.type, ChatIntentType.schedule);
      expect(result.team, 'USA');
    });

    test('classifies "next match for Brazil" as schedule', () {
      final result = classifier.classify('next match for Brazil');
      expect(result.type, ChatIntentType.schedule);
      expect(result.team, 'BRA');
    });

    test('classifies "Mexico schedule" as schedule', () {
      final result = classifier.classify('Mexico schedule');
      expect(result.type, ChatIntentType.schedule);
      expect(result.team, 'MEX');
    });

    test('classifies "what time is kickoff" as schedule', () {
      final result = classifier.classify('what time is kickoff');
      expect(result.type, ChatIntentType.schedule);
    });
  });

  group('Head-to-head intent', () {
    test('classifies "Argentina vs Brazil" as headToHead', () {
      final result = classifier.classify('Argentina vs Brazil');
      expect(result.type, ChatIntentType.headToHead);
      expect(result.entities['team1'], isNotNull);
      expect(result.entities['team2'], isNotNull);
    });

    test('classifies "USA versus Mexico" as headToHead', () {
      final result = classifier.classify('USA versus Mexico');
      expect(result.type, ChatIntentType.headToHead);
    });

    test('classifies "record against Brazil" with team context as headToHead', () {
      final result = classifier.classify('Argentina record against Brazil');
      expect(result.type, ChatIntentType.headToHead);
    });

    test('two teams without keywords defaults to headToHead', () {
      final result = classifier.classify('Argentina Brazil');
      expect(result.type, ChatIntentType.headToHead);
      expect(result.confidence, 0.7);
    });
  });

  group('Match preview intent', () {
    test('classifies "Argentina vs Brazil preview" as matchPreview', () {
      final result = classifier.classify('Argentina vs Brazil preview');
      expect(result.type, ChatIntentType.matchPreview);
    });

    test('classifies "analysis of USA vs Mexico" as matchPreview', () {
      final result = classifier.classify('analysis of USA vs Mexico');
      expect(result.type, ChatIntentType.matchPreview);
    });
  });

  group('Prediction intent', () {
    test('classifies "who will win the world cup" as prediction', () {
      final result = classifier.classify('who will win the world cup');
      expect(result.type, ChatIntentType.prediction);
    });

    test('classifies "favorites to win" as prediction', () {
      final result = classifier.classify('favorites to win');
      expect(result.type, ChatIntentType.prediction);
    });

    test('classifies "dark horse" as prediction', () {
      final result = classifier.classify('who is the dark horse');
      expect(result.type, ChatIntentType.prediction);
    });

    test('classifies "can Argentina win" as prediction with team', () {
      final result = classifier.classify('can Argentina win');
      expect(result.type, ChatIntentType.prediction);
      expect(result.team, 'ARG');
    });

    test('classifies "USA chances" as prediction', () {
      final result = classifier.classify('USA chances');
      expect(result.type, ChatIntentType.prediction);
      expect(result.team, 'USA');
    });
  });

  group('Player intent', () {
    test('classifies "Messi stats" as player', () {
      final result = classifier.classify('Messi stats');
      expect(result.type, ChatIntentType.player);
      expect(result.player, isNotNull);
      expect(result.player, contains('messi'));
    });

    test('classifies "tell me about Mbappe" as player', () {
      final result = classifier.classify('tell me about Mbappe');
      expect(result.type, ChatIntentType.player);
      expect(result.player, isNotNull);
    });

    test('classifies "Kane goals" as player', () {
      final result = classifier.classify('Kane goals scored');
      expect(result.type, ChatIntentType.player);
    });

    test('recognizes well-known player names', () {
      for (final name in ['messi', 'ronaldo', 'mbappe', 'bellingham', 'kane', 'salah']) {
        final result = classifier.classify('$name stats');
        expect(result.player, isNotNull, reason: '$name should be recognized');
      }
    });
  });

  group('Injury intent', () {
    test('classifies "is Mbappe injured" as injury', () {
      final result = classifier.classify('is Mbappe injured');
      expect(result.type, ChatIntentType.injury);
    });

    test('classifies "USA injuries" as injury with team', () {
      final result = classifier.classify('USA injuries');
      expect(result.type, ChatIntentType.injury);
      expect(result.team, 'USA');
    });

    test('classifies "who is ruled out" as injury', () {
      final result = classifier.classify('who is ruled out');
      expect(result.type, ChatIntentType.injury);
    });
  });

  group('Manager intent', () {
    test('classifies "who is the Argentina coach" as manager', () {
      final result = classifier.classify('who is the Argentina coach');
      expect(result.type, ChatIntentType.manager);
      expect(result.team, 'ARG');
    });

    test('classifies "USA manager" as manager', () {
      final result = classifier.classify('USA manager');
      expect(result.type, ChatIntentType.manager);
      expect(result.team, 'USA');
    });

    test('classifies "formation for Brazil" as manager', () {
      final result = classifier.classify('formation for Brazil');
      expect(result.type, ChatIntentType.manager);
      expect(result.team, 'BRA');
    });
  });

  group('Team intent', () {
    test('classifies "tell me about Argentina" as team', () {
      final result = classifier.classify('tell me about Argentina');
      expect(result.type, ChatIntentType.team);
      expect(result.team, 'ARG');
    });

    test('classifies "USA squad" as team', () {
      final result = classifier.classify('USA squad');
      expect(result.type, ChatIntentType.team);
      expect(result.team, 'USA');
    });

    test('classifies bare team name as team', () {
      final result = classifier.classify('Brazil');
      expect(result.type, ChatIntentType.team);
      expect(result.team, 'BRA');
    });
  });

  group('Venue intent', () {
    test('classifies "where is the final" as venue', () {
      final result = classifier.classify('where is the final');
      expect(result.type, ChatIntentType.venue);
    });

    test('classifies "MetLife Stadium" as venue with entity', () {
      final result = classifier.classify('MetLife Stadium');
      expect(result.type, ChatIntentType.venue);
      expect(result.venue, 'MetLife Stadium');
    });

    test('classifies "Estadio Azteca" as venue', () {
      final result = classifier.classify('tell me about Estadio Azteca');
      expect(result.type, ChatIntentType.venue);
      expect(result.venue, 'Estadio Azteca');
    });

    test('classifies "host cities" as venue', () {
      final result = classifier.classify('what are the host cities');
      expect(result.type, ChatIntentType.venue);
    });
  });

  group('History intent', () {
    test('classifies "World Cup history" as history', () {
      final result = classifier.classify('World Cup history');
      expect(result.type, ChatIntentType.history);
    });

    test('classifies "World Cup 2022" as history with year', () {
      final result = classifier.classify('World Cup 2022');
      expect(result.type, ChatIntentType.history);
      expect(result.year, '2022');
    });

    test('classifies "most goals all time" as history', () {
      final result = classifier.classify('most goals all time');
      expect(result.type, ChatIntentType.history);
    });

    test('classifies "who won in 2018" as history with year', () {
      final result = classifier.classify('who won in 2018');
      expect(result.type, ChatIntentType.history);
      expect(result.year, '2018');
    });

    test('classifies "all time leading scorer in world cup history" as history', () {
      final result = classifier.classify('who is the all time leading scorer in world cup history?');
      expect(result.type, ChatIntentType.history);
    });

    test('classifies "top scorer in world cup" as history', () {
      final result = classifier.classify('who is the top scorer in world cup?');
      expect(result.type, ChatIntentType.history);
    });

    test('classifies "fastest goal in world cup" as history', () {
      final result = classifier.classify('what was the fastest goal in world cup history?');
      expect(result.type, ChatIntentType.history);
    });

    test('classifies "youngest player to score" as history', () {
      final result = classifier.classify('who is the youngest player to score in a world cup?');
      expect(result.type, ChatIntentType.history);
    });

    test('extracts valid WC years only', () {
      // 2020 is not a WC year (should be null)
      final result = classifier.classify('what happened in 2020');
      expect(result.year, isNull);
    });
  });

  group('Odds intent', () {
    test('classifies "betting odds" as odds', () {
      final result = classifier.classify('betting odds');
      expect(result.type, ChatIntentType.odds);
    });

    test('classifies "what are the odds" as odds', () {
      final result = classifier.classify('what are the odds');
      expect(result.type, ChatIntentType.odds);
    });
  });

  group('Standings intent', () {
    test('classifies "Group A" as standings with group', () {
      final result = classifier.classify('Group A');
      expect(result.type, ChatIntentType.standings);
      expect(result.group, 'A');
    });

    test('classifies "group B standings" as standings', () {
      final result = classifier.classify('group B standings');
      expect(result.type, ChatIntentType.standings);
      expect(result.group, 'B');
    });
  });

  group('Squad value intent', () {
    test('classifies "most valuable squad" as squadValue', () {
      final result = classifier.classify('most valuable squad');
      expect(result.type, ChatIntentType.squadValue);
    });

    test('classifies "England squad worth" as squadValue with team', () {
      final result = classifier.classify('England squad worth');
      expect(result.type, ChatIntentType.squadValue);
      expect(result.team, 'ENG');
    });

    test('classifies "most expensive team" as squadValue', () {
      final result = classifier.classify('most expensive team');
      expect(result.type, ChatIntentType.squadValue);
    });
  });

  group('Recent form intent', () {
    test('classifies "USA form" as recentForm', () {
      final result = classifier.classify('USA form');
      expect(result.type, ChatIntentType.recentForm);
      expect(result.team, 'USA');
    });

    test('classifies "how has Argentina been playing" as recentForm', () {
      final result = classifier.classify('how has Argentina been playing');
      expect(result.type, ChatIntentType.recentForm);
      expect(result.team, 'ARG');
    });

    test('classifies "Brazil recent results" as recentForm', () {
      final result = classifier.classify('Brazil recent results');
      expect(result.type, ChatIntentType.recentForm);
      expect(result.team, 'BRA');
    });

    test('"USA formation" should NOT be recentForm (should be manager)', () {
      final result = classifier.classify('USA formation');
      expect(result.type, ChatIntentType.manager);
    });
  });

  group('Player comparison intent', () {
    test('classifies "compare Messi and Mbappe" as playerComparison', () {
      final result = classifier.classify('compare Messi and Mbappe');
      expect(result.type, ChatIntentType.playerComparison);
      expect(result.entities['player1'], isNotNull);
      expect(result.entities['player2'], isNotNull);
    });
  });

  group('Countdown intent', () {
    test('classifies "countdown to World Cup" as countdown', () {
      final result = classifier.classify('countdown to World Cup');
      expect(result.type, ChatIntentType.countdown);
    });

    test('classifies "how many days until the World Cup" as countdown', () {
      final result = classifier.classify('how many days until the World Cup');
      expect(result.type, ChatIntentType.countdown);
    });

    test('classifies "when does it start" as countdown', () {
      final result = classifier.classify('when does it start');
      expect(result.type, ChatIntentType.countdown);
    });
  });

  group('Tournament facts intent', () {
    test('classifies "how many teams" as tournamentFacts', () {
      final result = classifier.classify('how many teams');
      expect(result.type, ChatIntentType.tournamentFacts);
    });

    test('classifies "tournament format" as tournamentFacts', () {
      final result = classifier.classify('tournament format');
      expect(result.type, ChatIntentType.tournamentFacts);
    });

    test('classifies "tournament facts" as tournamentFacts', () {
      final result = classifier.classify('tournament facts');
      expect(result.type, ChatIntentType.tournamentFacts);
    });
  });

  group('Unknown intent', () {
    test('classifies gibberish as unknown', () {
      final result = classifier.classify('asdfghjkl');
      expect(result.type, ChatIntentType.unknown);
      expect(result.confidence, 0.0);
    });

    test('classifies unrelated question as unknown', () {
      final result = classifier.classify('what is the meaning of life');
      expect(result.type, ChatIntentType.unknown);
    });
  });

  group('Team alias resolution', () {
    test('resolves USMNT to USA', () {
      final result = classifier.classify('USMNT schedule');
      expect(result.team, 'USA');
    });

    test('resolves El Tri to MEX', () {
      final result = classifier.classify('el tri schedule');
      expect(result.team, 'MEX');
    });

    test('resolves Three Lions to ENG', () {
      final result = classifier.classify('three lions squad');
      expect(result.team, 'ENG');
    });

    test('resolves La Albiceleste to ARG', () {
      final result = classifier.classify('la albiceleste prediction');
      expect(result.team, 'ARG');
    });

    test('resolves "Holland" to NED', () {
      final result = classifier.classify('Holland squad');
      expect(result.team, 'NED');
    });
  });

  group('Group extraction', () {
    test('extracts group letter A-L', () {
      for (final letter in ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L']) {
        final result = classifier.classify('Group $letter');
        expect(result.group, letter, reason: 'Should extract Group $letter');
      }
    });

    test('does not extract invalid group letters', () {
      final result = classifier.classify('Group Z');
      expect(result.group, isNull);
    });
  });

  group('Year extraction', () {
    test('extracts valid WC years', () {
      for (final year in [1930, 1950, 1970, 1990, 2002, 2006, 2010, 2014, 2018, 2022, 2026]) {
        final result = classifier.classify('World Cup $year');
        expect(result.year, '$year', reason: 'Should extract year $year');
      }
    });

    test('does not extract non-WC years', () {
      final result = classifier.classify('the year 2023');
      expect(result.year, isNull);
    });
  });

  group('Pronoun resolution', () {
    test('resolves "their" to the last mentioned team', () {
      // First mention Argentina
      classifier.classify('tell me about Argentina');
      // Then ask with pronoun
      final result = classifier.classify('when is their next match');
      expect(result.team, 'ARG');
    });

    test('updates last mentioned team', () {
      classifier.classify('USA schedule');
      final r1 = classifier.classify('what is their squad');
      expect(r1.team, 'USA');

      classifier.classify('Brazil schedule');
      final r2 = classifier.classify('what is their squad');
      expect(r2.team, 'BRA');
    });

    test('reset clears last mentioned team', () {
      classifier.classify('USA schedule');
      classifier.reset();
      final result = classifier.classify('their schedule');
      // No team should be resolved after reset
      expect(result.team, isNull);
    });
  });

  group('Venue name extraction', () {
    test('extracts known venue names', () {
      final venues = {
        'metlife': 'MetLife Stadium',
        'sofi': 'SoFi Stadium',
        'azteca': 'Estadio Azteca',
        'hard rock': 'Hard Rock Stadium',
        'bc place': 'BC Place',
      };
      for (final entry in venues.entries) {
        final result = classifier.classify('tell me about ${entry.key}');
        expect(result.venue, entry.value, reason: '${entry.key} → ${entry.value}');
      }
    });
  });

  group('Priority ordering', () {
    test('greeting beats other intents for short messages', () {
      final result = classifier.classify('hi');
      expect(result.type, ChatIntentType.greeting);
    });

    test('h2h beats schedule when two teams present', () {
      final result = classifier.classify('USA vs Mexico schedule');
      // Two teams + "vs" → headToHead wins
      expect(result.type, ChatIntentType.headToHead);
    });

    test('schedule beats team when schedule keywords present', () {
      final result = classifier.classify('when does USA play');
      expect(result.type, ChatIntentType.schedule);
    });

    test('countdown beats schedule for "when does it start"', () {
      final result = classifier.classify('when does it start');
      expect(result.type, ChatIntentType.countdown);
    });

    test('squadValue beats team for "most valuable squad"', () {
      final result = classifier.classify('most valuable squad');
      expect(result.type, ChatIntentType.squadValue);
    });

    test('recentForm beats team for "USA form"', () {
      final result = classifier.classify('USA form');
      expect(result.type, ChatIntentType.recentForm);
    });
  });
}

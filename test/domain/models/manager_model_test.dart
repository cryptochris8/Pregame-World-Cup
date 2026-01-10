import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/domain/models/manager.dart';

/// Comprehensive tests for Manager data model and nested classes
void main() {
  group('Manager Model - Computed Properties', () {
    test('yearsInCurrentRole calculates correctly', () {
      final manager = _createManager(
        appointedDate: DateTime(2020, 1, 1),
      );
      final expectedYears = DateTime.now().year - 2020;
      expect(manager.yearsInCurrentRole, equals(expectedYears));
    });

    test('isControversial returns true when controversies exist', () {
      final manager = _createManager(
        controversies: ['Public disagreement with board'],
      );
      expect(manager.isControversial, isTrue);
    });

    test('isControversial returns false when controversies is empty', () {
      final manager = _createManager(controversies: []);
      expect(manager.isControversial, isFalse);
    });

    test('experienceCategory returns Emerging for < 5 years', () {
      final manager = _createManager(yearsOfExperience: 3);
      expect(manager.experienceCategory, equals('Emerging'));
    });

    test('experienceCategory returns Developing for 5-9 years', () {
      final manager = _createManager(yearsOfExperience: 7);
      expect(manager.experienceCategory, equals('Developing'));
    });

    test('experienceCategory returns Experienced for 10-19 years', () {
      final manager = _createManager(yearsOfExperience: 15);
      expect(manager.experienceCategory, equals('Experienced'));
    });

    test('experienceCategory returns Veteran for >= 20 years', () {
      final manager = _createManager(yearsOfExperience: 25);
      expect(manager.experienceCategory, equals('Veteran'));
    });

    test('experienceCategory edge case: exactly 5 years', () {
      final manager = _createManager(yearsOfExperience: 5);
      expect(manager.experienceCategory, equals('Developing'));
    });

    test('experienceCategory edge case: exactly 10 years', () {
      final manager = _createManager(yearsOfExperience: 10);
      expect(manager.experienceCategory, equals('Experienced'));
    });

    test('experienceCategory edge case: exactly 20 years', () {
      final manager = _createManager(yearsOfExperience: 20);
      expect(manager.experienceCategory, equals('Veteran'));
    });

    test('ageCategory returns Young for < 45', () {
      final manager = _createManager(age: 40);
      expect(manager.ageCategory, equals('Young'));
    });

    test('ageCategory returns Middle-aged for 45-54', () {
      final manager = _createManager(age: 50);
      expect(manager.ageCategory, equals('Middle-aged'));
    });

    test('ageCategory returns Experienced for 55-64', () {
      final manager = _createManager(age: 60);
      expect(manager.ageCategory, equals('Experienced'));
    });

    test('ageCategory returns Veteran for >= 65', () {
      final manager = _createManager(age: 70);
      expect(manager.ageCategory, equals('Veteran'));
    });

    test('ageCategory edge case: exactly 45', () {
      final manager = _createManager(age: 45);
      expect(manager.ageCategory, equals('Middle-aged'));
    });

    test('ageCategory edge case: exactly 55', () {
      final manager = _createManager(age: 55);
      expect(manager.ageCategory, equals('Experienced'));
    });

    test('ageCategory edge case: exactly 65', () {
      final manager = _createManager(age: 65);
      expect(manager.ageCategory, equals('Veteran'));
    });
  });

  group('Manager Model - toFirestore', () {
    test('toFirestore contains all required fields', () {
      final manager = _createFullManager();
      final map = manager.toFirestore();

      expect(map['managerId'], equals('manager_001'));
      expect(map['fifaCode'], equals('ARG'));
      expect(map['commonName'], equals('Lionel Scaloni'));
      expect(map['nationality'], equals('Argentine'));
      expect(map['currentTeam'], equals('Argentina'));
      expect(map['yearsOfExperience'], equals(8));
    });

    test('toFirestore includes nested stats', () {
      final manager = _createFullManager();
      final map = manager.toFirestore();

      expect(map['stats'], isNotNull);
      expect(map['stats']['matchesManaged'], equals(85));
      expect(map['stats']['wins'], equals(60));
    });

    test('toFirestore includes social media', () {
      final manager = _createFullManager();
      final map = manager.toFirestore();

      expect(map['socialMedia'], isNotNull);
      expect(map['socialMedia']['instagram'], equals('@scaloni'));
    });

    test('toFirestore converts dates to ISO strings', () {
      final manager = _createFullManager();
      final map = manager.toFirestore();

      expect(map['dateOfBirth'], isA<String>());
      expect(map['appointedDate'], isA<String>());
    });
  });

  group('ManagerStats Model', () {
    test('fromMap parses correctly', () {
      final map = {
        'matchesManaged': 450,
        'wins': 280,
        'draws': 100,
        'losses': 70,
        'winPercentage': 62.2,
        'titlesWon': 12,
      };
      final stats = ManagerStats.fromMap(map);

      expect(stats.matchesManaged, equals(450));
      expect(stats.wins, equals(280));
      expect(stats.draws, equals(100));
      expect(stats.losses, equals(70));
      expect(stats.winPercentage, equals(62.2));
      expect(stats.titlesWon, equals(12));
    });

    test('fromMap handles missing fields with defaults', () {
      final map = <String, dynamic>{};
      final stats = ManagerStats.fromMap(map);

      expect(stats.matchesManaged, equals(0));
      expect(stats.wins, equals(0));
      expect(stats.draws, equals(0));
      expect(stats.losses, equals(0));
      expect(stats.winPercentage, equals(0.0));
      expect(stats.titlesWon, equals(0));
    });

    test('fromMap handles integer winPercentage', () {
      final map = {
        'matchesManaged': 100,
        'wins': 60,
        'draws': 20,
        'losses': 20,
        'winPercentage': 60, // Integer instead of double
        'titlesWon': 2,
      };
      final stats = ManagerStats.fromMap(map);

      expect(stats.winPercentage, equals(60.0));
      expect(stats.winPercentage, isA<double>());
    });

    test('toMap returns correct structure', () {
      final stats = ManagerStats(
        matchesManaged: 450,
        wins: 280,
        draws: 100,
        losses: 70,
        winPercentage: 62.2,
        titlesWon: 12,
      );
      final map = stats.toMap();

      expect(map['matchesManaged'], equals(450));
      expect(map['wins'], equals(280));
      expect(map['draws'], equals(100));
      expect(map['losses'], equals(70));
      expect(map['winPercentage'], equals(62.2));
      expect(map['titlesWon'], equals(12));
    });

    test('formattedWinPercentage formats correctly', () {
      final stats = ManagerStats(
        matchesManaged: 100,
        wins: 62,
        draws: 20,
        losses: 18,
        winPercentage: 62.22,
        titlesWon: 5,
      );
      expect(stats.formattedWinPercentage, equals('62.2%'));
    });

    test('formattedWinPercentage handles round numbers', () {
      final stats = ManagerStats(
        matchesManaged: 100,
        wins: 70,
        draws: 15,
        losses: 15,
        winPercentage: 70.0,
        titlesWon: 5,
      );
      expect(stats.formattedWinPercentage, equals('70.0%'));
    });

    test('recordDisplay formats correctly', () {
      final stats = ManagerStats(
        matchesManaged: 450,
        wins: 280,
        draws: 100,
        losses: 70,
        winPercentage: 62.2,
        titlesWon: 12,
      );
      expect(stats.recordDisplay, equals('280-100-70'));
    });
  });

  group('ManagerSocialMedia Model', () {
    test('fromMap parses correctly', () {
      final map = {
        'instagram': '@scaloni',
        'twitter': '@scaloni',
        'followers': 8000000,
      };
      final social = ManagerSocialMedia.fromMap(map);

      expect(social.instagram, equals('@scaloni'));
      expect(social.twitter, equals('@scaloni'));
      expect(social.followers, equals(8000000));
    });

    test('fromMap handles missing fields with defaults', () {
      final map = <String, dynamic>{};
      final social = ManagerSocialMedia.fromMap(map);

      expect(social.instagram, equals(''));
      expect(social.twitter, equals(''));
      expect(social.followers, equals(0));
    });

    test('toMap returns correct structure', () {
      final social = ManagerSocialMedia(
        instagram: '@scaloni',
        twitter: '@scaloni',
        followers: 8000000,
      );
      final map = social.toMap();

      expect(map['instagram'], equals('@scaloni'));
      expect(map['twitter'], equals('@scaloni'));
      expect(map['followers'], equals(8000000));
    });

    test('formattedFollowers returns M for millions', () {
      final social = ManagerSocialMedia(
        instagram: '',
        twitter: '',
        followers: 8000000,
      );
      expect(social.formattedFollowers, equals('8.0M'));
    });

    test('formattedFollowers returns K for thousands', () {
      final social = ManagerSocialMedia(
        instagram: '',
        twitter: '',
        followers: 500000,
      );
      expect(social.formattedFollowers, equals('500K'));
    });

    test('formattedFollowers returns raw value for small numbers', () {
      final social = ManagerSocialMedia(
        instagram: '',
        twitter: '',
        followers: 500,
      );
      expect(social.formattedFollowers, equals('500'));
    });

    test('formattedFollowers handles edge case at 1 million', () {
      final social = ManagerSocialMedia(
        instagram: '',
        twitter: '',
        followers: 1000000,
      );
      expect(social.formattedFollowers, equals('1.0M'));
    });

    test('formattedFollowers handles edge case at 1 thousand', () {
      final social = ManagerSocialMedia(
        instagram: '',
        twitter: '',
        followers: 1000,
      );
      expect(social.formattedFollowers, equals('1K'));
    });

    test('hasSocialMedia returns true when instagram exists', () {
      final social = ManagerSocialMedia(
        instagram: '@scaloni',
        twitter: '',
        followers: 0,
      );
      expect(social.hasSocialMedia, isTrue);
    });

    test('hasSocialMedia returns true when twitter exists', () {
      final social = ManagerSocialMedia(
        instagram: '',
        twitter: '@scaloni',
        followers: 0,
      );
      expect(social.hasSocialMedia, isTrue);
    });

    test('hasSocialMedia returns true when both exist', () {
      final social = ManagerSocialMedia(
        instagram: '@scaloni',
        twitter: '@scaloni',
        followers: 0,
      );
      expect(social.hasSocialMedia, isTrue);
    });

    test('hasSocialMedia returns false when neither exists', () {
      final social = ManagerSocialMedia(
        instagram: '',
        twitter: '',
        followers: 1000000, // followers doesn't count
      );
      expect(social.hasSocialMedia, isFalse);
    });
  });

  group('Manager Model - Edge Cases', () {
    test('handles empty lists', () {
      final manager = _createManager(
        previousClubs: [],
        honors: [],
        strengths: [],
        weaknesses: [],
        controversies: [],
        trivia: [],
      );

      expect(manager.previousClubs, isEmpty);
      expect(manager.honors, isEmpty);
      expect(manager.strengths, isEmpty);
      expect(manager.weaknesses, isEmpty);
      expect(manager.controversies, isEmpty);
      expect(manager.trivia, isEmpty);
    });

    test('handles very long lists', () {
      final longList = List.generate(100, (i) => 'Item $i');
      final manager = _createManager(previousClubs: longList);

      expect(manager.previousClubs.length, equals(100));
      expect(manager.previousClubs.first, equals('Item 0'));
      expect(manager.previousClubs.last, equals('Item 99'));
    });
  });
}

/// Helper function to create a minimal Manager with specified properties
Manager _createManager({
  DateTime? appointedDate,
  int yearsOfExperience = 10,
  int age = 50,
  List<String> controversies = const [],
  List<String> previousClubs = const ['Club A'],
  List<String> honors = const [],
  List<String> strengths = const [],
  List<String> weaknesses = const [],
  List<String> trivia = const [],
}) {
  return Manager(
    managerId: 'test_001',
    fifaCode: 'TST',
    firstName: 'Test',
    lastName: 'Manager',
    fullName: 'Test Manager',
    commonName: 'Test',
    dateOfBirth: DateTime(1974, 1, 1),
    age: age,
    nationality: 'Test Nation',
    photoUrl: '',
    currentTeam: 'Test Team',
    appointedDate: appointedDate ?? DateTime(2020, 1, 1),
    previousClubs: previousClubs,
    managerialCareerStart: 2000,
    yearsOfExperience: yearsOfExperience,
    stats: ManagerStats(
      matchesManaged: 100,
      wins: 60,
      draws: 20,
      losses: 20,
      winPercentage: 60.0,
      titlesWon: 2,
    ),
    honors: honors,
    tacticalStyle: '4-3-3',
    philosophy: 'Attacking football',
    strengths: strengths,
    weaknesses: weaknesses,
    keyMoment: '',
    famousQuote: '',
    managerStyle: 'Calm',
    worldCup2026Prediction: '',
    controversies: controversies,
    socialMedia: ManagerSocialMedia(
      instagram: '',
      twitter: '',
      followers: 0,
    ),
    trivia: trivia,
  );
}

/// Helper function to create a full Manager with all fields populated
Manager _createFullManager() {
  return Manager(
    managerId: 'manager_001',
    fifaCode: 'ARG',
    firstName: 'Lionel',
    lastName: 'Scaloni',
    fullName: 'Lionel Sebastián Scaloni',
    commonName: 'Lionel Scaloni',
    dateOfBirth: DateTime(1978, 5, 16),
    age: 46,
    nationality: 'Argentine',
    photoUrl: 'https://example.com/scaloni.jpg',
    currentTeam: 'Argentina',
    appointedDate: DateTime(2018, 8, 3),
    previousClubs: ['Argentina U20'],
    managerialCareerStart: 2016,
    yearsOfExperience: 8,
    stats: ManagerStats(
      matchesManaged: 85,
      wins: 60,
      draws: 15,
      losses: 10,
      winPercentage: 70.6,
      titlesWon: 3,
    ),
    honors: ['World Cup 2022', 'Copa America 2021', 'Finalissima 2022'],
    tacticalStyle: '4-4-2 diamond with fluid attack',
    philosophy: 'Team unity and tactical discipline',
    strengths: ['Player relationships', 'Game reading'],
    weaknesses: ['Limited experience'],
    keyMoment: 'Winning World Cup 2022',
    famousQuote: 'This group deserves everything',
    managerStyle: 'Emotional and passionate',
    worldCup2026Prediction: 'Defending champions',
    controversies: [],
    socialMedia: ManagerSocialMedia(
      instagram: '@scaloni',
      twitter: '@scaloni',
      followers: 8000000,
    ),
    trivia: ['Youngest manager to win World Cup in modern era'],
  );
}

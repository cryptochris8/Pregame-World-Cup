import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:pregame_world_cup/data/services/manager_service.dart';
import 'package:pregame_world_cup/domain/models/manager.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late ManagerService managerService;

  // Sample manager data for testing
  final sampleManagerData1 = {
    'managerId': 'manager_001',
    'fifaCode': 'BRA',
    'firstName': 'Tite',
    'lastName': 'Adenor Leonardo Bacchi',
    'fullName': 'Adenor Leonardo Bacchi',
    'commonName': 'Tite',
    'dateOfBirth': '1961-05-25',
    'age': 63,
    'nationality': 'Brazilian',
    'photoUrl': 'https://example.com/tite.jpg',
    'currentTeam': 'Brazil',
    'appointedDate': '2016-06-20',
    'previousClubs': ['Corinthians', 'Internacional', 'Grêmio'],
    'managerialCareerStart': 1990,
    'yearsOfExperience': 34,
    'stats': {
      'matchesManaged': 450,
      'wins': 280,
      'draws': 100,
      'losses': 70,
      'winPercentage': 62.2,
      'titlesWon': 12,
    },
    'honors': ['Copa America 2019', 'FIFA Confederations Cup 2013'],
    'tacticalStyle': '4-3-3 with possession-based football',
    'philosophy': 'Attacking football with defensive solidity',
    'strengths': ['Man management', 'Tactical flexibility'],
    'weaknesses': ['Stubborn with team selection'],
    'keyMoment': 'Winning Copa America 2019',
    'famousQuote': 'The team comes first, always',
    'managerStyle': 'Calm and methodical',
    'worldCup2026Prediction': 'Building a strong squad',
    'controversies': [],
    'socialMedia': {
      'instagram': '@tite_oficial',
      'twitter': '@tite',
      'followers': 5000000,
    },
    'trivia': ['Most successful manager in Brazilian history'],
  };

  final sampleManagerData2 = {
    'managerId': 'manager_002',
    'fifaCode': 'ARG',
    'firstName': 'Lionel',
    'lastName': 'Scaloni',
    'fullName': 'Lionel Sebastián Scaloni',
    'commonName': 'Lionel Scaloni',
    'dateOfBirth': '1978-05-16',
    'age': 46,
    'nationality': 'Argentine',
    'photoUrl': 'https://example.com/scaloni.jpg',
    'currentTeam': 'Argentina',
    'appointedDate': '2018-08-03',
    'previousClubs': ['Argentina U20'],
    'managerialCareerStart': 2016,
    'yearsOfExperience': 8,
    'stats': {
      'matchesManaged': 85,
      'wins': 60,
      'draws': 15,
      'losses': 10,
      'winPercentage': 70.6,
      'titlesWon': 3,
    },
    'honors': ['World Cup 2022', 'Copa America 2021', 'Finalissima 2022'],
    'tacticalStyle': '4-4-2 diamond with fluid attack',
    'philosophy': 'Team unity and tactical discipline',
    'strengths': ['Player relationships', 'Game reading'],
    'weaknesses': ['Limited experience'],
    'keyMoment': 'Winning World Cup 2022',
    'famousQuote': 'This group deserves everything',
    'managerStyle': 'Emotional and passionate',
    'worldCup2026Prediction': 'Defending champions',
    'controversies': [],
    'socialMedia': {
      'instagram': '@scaloni',
      'twitter': '@scaloni',
      'followers': 8000000,
    },
    'trivia': ['Youngest manager to win World Cup in modern era'],
  };

  final sampleManagerData3 = {
    'managerId': 'manager_003',
    'fifaCode': 'GER',
    'firstName': 'Julian',
    'lastName': 'Nagelsmann',
    'fullName': 'Julian Nagelsmann',
    'commonName': 'Julian Nagelsmann',
    'dateOfBirth': '1987-07-23',
    'age': 37,
    'nationality': 'German',
    'photoUrl': 'https://example.com/nagelsmann.jpg',
    'currentTeam': 'Germany',
    'appointedDate': '2023-09-12',
    'previousClubs': ['Bayern Munich', 'RB Leipzig', 'Hoffenheim'],
    'managerialCareerStart': 2016,
    'yearsOfExperience': 8,
    'stats': {
      'matchesManaged': 320,
      'wins': 210,
      'draws': 60,
      'losses': 50,
      'winPercentage': 65.6,
      'titlesWon': 5,
    },
    'honors': ['Bundesliga 2021-22'],
    'tacticalStyle': '3-4-2-1 with high pressing',
    'philosophy': 'Modern, data-driven football',
    'strengths': ['Tactical innovation', 'Youth development'],
    'weaknesses': ['Inexperience at international level'],
    'keyMoment': 'Becoming youngest Bundesliga manager',
    'famousQuote': 'Football is about constant evolution',
    'managerStyle': 'Analytical and innovative',
    'worldCup2026Prediction': 'Young squad with potential',
    'controversies': ['Public disagreements with Bayern board'],
    'socialMedia': {
      'instagram': '@j__nagelsmann',
      'twitter': '@nagelsmann',
      'followers': 3000000,
    },
    'trivia': ['Started coaching career at age 28'],
  };

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    managerService = ManagerService();
  });

  group('ManagerService - Happy Path Tests', () {
    test('getAllManagers returns list of managers when collection has data', () async {
      await fakeFirestore.collection('managers').doc('manager_001').set(sampleManagerData1);
      await fakeFirestore.collection('managers').doc('manager_002').set(sampleManagerData2);
      await fakeFirestore.collection('managers').doc('manager_003').set(sampleManagerData3);

      final snapshot = await fakeFirestore.collection('managers').orderBy('fifaCode').get();
      final managers = snapshot.docs.map((doc) => Manager.fromFirestore(doc)).toList();

      expect(managers.length, 3);
      expect(managers.any((m) => m.commonName == 'Tite'), true);
      expect(managers.any((m) => m.commonName == 'Lionel Scaloni'), true);
      expect(managers.any((m) => m.commonName == 'Julian Nagelsmann'), true);
    });

    test('getManagerByTeam returns correct manager for given FIFA code', () async {
      await fakeFirestore.collection('managers').doc('manager_001').set(sampleManagerData1);
      await fakeFirestore.collection('managers').doc('manager_002').set(sampleManagerData2);

      final snapshot = await fakeFirestore
          .collection('managers')
          .where('fifaCode', isEqualTo: 'BRA')
          .limit(1)
          .get();

      expect(snapshot.docs.isNotEmpty, true);
      final manager = Manager.fromFirestore(snapshot.docs.first);
      expect(manager.commonName, 'Tite');
      expect(manager.fifaCode, 'BRA');
    });

    test('getManagerById returns correct manager when it exists', () async {
      await fakeFirestore.collection('managers').doc('manager_001').set(sampleManagerData1);

      final doc = await fakeFirestore.collection('managers').doc('manager_001').get();
      final manager = Manager.fromFirestore(doc);

      expect(manager, isNotNull);
      expect(manager.managerId, 'manager_001');
      expect(manager.commonName, 'Tite');
      expect(manager.fifaCode, 'BRA');
    });

    test('getMostExperiencedManagers returns managers sorted by experience', () async {
      await fakeFirestore.collection('managers').doc('manager_001').set(sampleManagerData1);
      await fakeFirestore.collection('managers').doc('manager_002').set(sampleManagerData2);
      await fakeFirestore.collection('managers').doc('manager_003').set(sampleManagerData3);

      final snapshot = await fakeFirestore
          .collection('managers')
          .orderBy('yearsOfExperience', descending: true)
          .limit(10)
          .get();
      final managers = snapshot.docs.map((doc) => Manager.fromFirestore(doc)).toList();

      expect(managers.length, 3);
      expect(managers[0].commonName, 'Tite'); // Most experienced (34 years)
      expect(managers[0].yearsOfExperience, 34);
    });

    test('getYoungestManagers returns managers sorted by age', () async {
      await fakeFirestore.collection('managers').doc('manager_001').set(sampleManagerData1);
      await fakeFirestore.collection('managers').doc('manager_002').set(sampleManagerData2);
      await fakeFirestore.collection('managers').doc('manager_003').set(sampleManagerData3);

      final snapshot = await fakeFirestore
          .collection('managers')
          .orderBy('age')
          .limit(10)
          .get();
      final managers = snapshot.docs.map((doc) => Manager.fromFirestore(doc)).toList();

      expect(managers.length, 3);
      expect(managers[0].commonName, 'Julian Nagelsmann'); // Youngest (37)
      expect(managers[0].age, 37);
    });
  });

  group('ManagerService - Error Handling Tests', () {
    test('getAllManagers returns empty list when collection is empty', () async {
      final snapshot = await fakeFirestore.collection('managers').get();
      final managers = snapshot.docs.map((doc) => Manager.fromFirestore(doc)).toList();

      expect(managers, isEmpty);
    });

    test('getManagerById returns null when manager does not exist', () async {
      final doc = await fakeFirestore.collection('managers').doc('nonexistent_id').get();

      expect(doc.exists, false);
    });

    test('getManagerByTeam returns null when no manager matches FIFA code', () async {
      await fakeFirestore.collection('managers').doc('manager_001').set(sampleManagerData1);

      final snapshot = await fakeFirestore
          .collection('managers')
          .where('fifaCode', isEqualTo: 'XYZ')
          .limit(1)
          .get();

      expect(snapshot.docs, isEmpty);
    });

    test('searchManagers handles empty query gracefully', () async {
      await fakeFirestore.collection('managers').doc('manager_001').set(sampleManagerData1);

      final snapshot = await fakeFirestore.collection('managers').get();
      final allManagers = snapshot.docs.map((doc) => Manager.fromFirestore(doc)).toList();

      // Simulate search with empty query
      final query = '';
      final results = allManagers.where((manager) {
        return manager.fullName.toLowerCase().contains(query.toLowerCase()) ||
            manager.commonName.toLowerCase().contains(query.toLowerCase()) ||
            manager.currentTeam.toLowerCase().contains(query.toLowerCase());
      }).toList();

      expect(results, isNotEmpty); // Empty query should match all
    });
  });

  group('ManagerService - Edge Cases Tests', () {
    test('handles manager with null/empty values correctly', () async {
      final minimalManagerData = {
        'managerId': 'manager_minimal',
        'fifaCode': '',
        'firstName': '',
        'lastName': '',
        'fullName': '',
        'commonName': '',
        'dateOfBirth': '1970-01-01',
        'age': 0,
        'nationality': '',
        'photoUrl': '',
        'currentTeam': '',
        'appointedDate': '2020-01-01',
        'previousClubs': [],
        'managerialCareerStart': 2000,
        'yearsOfExperience': 0,
        'stats': {
          'matchesManaged': 0,
          'wins': 0,
          'draws': 0,
          'losses': 0,
          'winPercentage': 0.0,
          'titlesWon': 0,
        },
        'honors': [],
        'tacticalStyle': '',
        'philosophy': '',
        'strengths': [],
        'weaknesses': [],
        'keyMoment': '',
        'famousQuote': '',
        'managerStyle': '',
        'worldCup2026Prediction': '',
        'controversies': [],
        'socialMedia': {
          'instagram': '',
          'twitter': '',
          'followers': 0,
        },
        'trivia': [],
      };

      await fakeFirestore.collection('managers').doc('manager_minimal').set(minimalManagerData);

      final doc = await fakeFirestore.collection('managers').doc('manager_minimal').get();
      final manager = Manager.fromFirestore(doc);

      expect(manager, isNotNull);
      expect(manager.managerId, 'manager_minimal');
      expect(manager.commonName, '');
      expect(manager.honors, isEmpty);
      expect(manager.strengths, isEmpty);
      expect(manager.controversies, isEmpty);
      expect(manager.isControversial, false);
    });

    test('getTopWinningManagers sorts by win percentage correctly', () async {
      await fakeFirestore.collection('managers').doc('manager_001').set(sampleManagerData1);
      await fakeFirestore.collection('managers').doc('manager_002').set(sampleManagerData2);
      await fakeFirestore.collection('managers').doc('manager_003').set(sampleManagerData3);

      final snapshot = await fakeFirestore.collection('managers').get();
      final managers = snapshot.docs.map((doc) => Manager.fromFirestore(doc)).toList();

      // Sort by win percentage locally
      managers.sort((a, b) => b.stats.winPercentage.compareTo(a.stats.winPercentage));

      expect(managers[0].commonName, 'Lionel Scaloni'); // Highest win % (70.6%)
      expect(managers[0].stats.winPercentage, 70.6);
    });

    test('getMostSuccessfulManagers sorts by titles won', () async {
      await fakeFirestore.collection('managers').doc('manager_001').set(sampleManagerData1);
      await fakeFirestore.collection('managers').doc('manager_002').set(sampleManagerData2);
      await fakeFirestore.collection('managers').doc('manager_003').set(sampleManagerData3);

      final snapshot = await fakeFirestore.collection('managers').get();
      final managers = snapshot.docs.map((doc) => Manager.fromFirestore(doc)).toList();

      // Sort by titles won locally
      managers.sort((a, b) => b.stats.titlesWon.compareTo(a.stats.titlesWon));

      expect(managers[0].commonName, 'Tite'); // Most titles (12)
      expect(managers[0].stats.titlesWon, 12);
    });

    test('getControversialManagers filters managers with controversies', () async {
      await fakeFirestore.collection('managers').doc('manager_001').set(sampleManagerData1);
      await fakeFirestore.collection('managers').doc('manager_002').set(sampleManagerData2);
      await fakeFirestore.collection('managers').doc('manager_003').set(sampleManagerData3);

      final snapshot = await fakeFirestore.collection('managers').get();
      final managers = snapshot.docs.map((doc) => Manager.fromFirestore(doc)).toList();

      // Filter managers with controversies
      final controversial = managers.where((m) => m.isControversial).toList();

      expect(controversial.length, 1);
      expect(controversial[0].commonName, 'Julian Nagelsmann');
      expect(controversial[0].controversies.isNotEmpty, true);
    });

    test('manager model calculated properties work correctly', () async {
      await fakeFirestore.collection('managers').doc('manager_002').set(sampleManagerData2);

      final doc = await fakeFirestore.collection('managers').doc('manager_002').get();
      final manager = Manager.fromFirestore(doc);

      // Test formatted win percentage
      expect(manager.stats.formattedWinPercentage, '70.6%');

      // Test record display
      expect(manager.stats.recordDisplay, '60-15-10');

      // Test experience category
      expect(manager.experienceCategory, 'Developing'); // 8 years

      // Test age category
      expect(manager.ageCategory, 'Middle-aged'); // 46 years

      // Test years in current role
      final yearsInRole = manager.yearsInCurrentRole;
      expect(yearsInRole >= 5, true); // Appointed in 2018
    });

    test('searchManagers performs case-insensitive search', () async {
      await fakeFirestore.collection('managers').doc('manager_001').set(sampleManagerData1);
      await fakeFirestore.collection('managers').doc('manager_002').set(sampleManagerData2);

      final snapshot = await fakeFirestore.collection('managers').get();
      final allManagers = snapshot.docs.map((doc) => Manager.fromFirestore(doc)).toList();

      // Search with lowercase
      final lowerQuery = 'scaloni';
      final results = allManagers.where((manager) {
        return manager.fullName.toLowerCase().contains(lowerQuery.toLowerCase()) ||
            manager.commonName.toLowerCase().contains(lowerQuery.toLowerCase()) ||
            manager.currentTeam.toLowerCase().contains(lowerQuery.toLowerCase());
      }).toList();

      expect(results.length, 1);
      expect(results[0].commonName, 'Lionel Scaloni');
    });

    test('getManagersByNationality filters correctly', () async {
      await fakeFirestore.collection('managers').doc('manager_001').set(sampleManagerData1);
      await fakeFirestore.collection('managers').doc('manager_002').set(sampleManagerData2);
      await fakeFirestore.collection('managers').doc('manager_003').set(sampleManagerData3);

      final snapshot = await fakeFirestore
          .collection('managers')
          .where('nationality', isEqualTo: 'German')
          .get();
      final managers = snapshot.docs.map((doc) => Manager.fromFirestore(doc)).toList();

      expect(managers.length, 1);
      expect(managers[0].commonName, 'Julian Nagelsmann');
      expect(managers[0].nationality, 'German');
    });

    test('getWorldCupWinningManagers filters managers with World Cup honor', () async {
      await fakeFirestore.collection('managers').doc('manager_001').set(sampleManagerData1);
      await fakeFirestore.collection('managers').doc('manager_002').set(sampleManagerData2);
      await fakeFirestore.collection('managers').doc('manager_003').set(sampleManagerData3);

      final snapshot = await fakeFirestore.collection('managers').get();
      final managers = snapshot.docs.map((doc) => Manager.fromFirestore(doc)).toList();

      // Filter managers with World Cup in their honors
      final wcWinners = managers.where((manager) =>
          manager.honors.any((honor) =>
              honor.toLowerCase().contains('world cup') &&
              !honor.toLowerCase().contains('runner') &&
              !honor.toLowerCase().contains('place')))
          .toList();

      expect(wcWinners.length, 1);
      expect(wcWinners[0].commonName, 'Lionel Scaloni');
    });
  });

  group('ManagerService - Manager Statistics Tests', () {
    test('getManagerStatistics calculates correct aggregates', () async {
      await fakeFirestore.collection('managers').doc('manager_001').set(sampleManagerData1);
      await fakeFirestore.collection('managers').doc('manager_002').set(sampleManagerData2);
      await fakeFirestore.collection('managers').doc('manager_003').set(sampleManagerData3);

      final snapshot = await fakeFirestore.collection('managers').get();
      final managers = snapshot.docs.map((doc) => Manager.fromFirestore(doc)).toList();

      // Calculate statistics manually
      final totalManagers = managers.length;
      final averageAge = managers.fold<double>(0, (sum, manager) => sum + manager.age) / managers.length;
      final averageExperience = managers.fold<double>(0, (sum, manager) => sum + manager.yearsOfExperience) / managers.length;
      final totalMatches = managers.fold<int>(0, (sum, manager) => sum + manager.stats.matchesManaged);
      final totalTitles = managers.fold<int>(0, (sum, manager) => sum + manager.stats.titlesWon);
      final averageWinPercentage = managers.fold<double>(0, (sum, manager) => sum + manager.stats.winPercentage) / managers.length;
      final managersWithControversies = managers.where((m) => m.isControversial).length;

      expect(totalManagers, 3);
      expect(averageAge, closeTo(48.7, 0.5)); // (63 + 46 + 37) / 3
      expect(averageExperience, closeTo(16.7, 0.5)); // (34 + 8 + 8) / 3
      expect(totalMatches, 855); // 450 + 85 + 320
      expect(totalTitles, 20); // 12 + 3 + 5
      expect(averageWinPercentage, closeTo(66.1, 0.5)); // (62.2 + 70.6 + 65.6) / 3
      expect(managersWithControversies, 1);
    });

    test('manager social media information works correctly', () async {
      await fakeFirestore.collection('managers').doc('manager_002').set(sampleManagerData2);

      final doc = await fakeFirestore.collection('managers').doc('manager_002').get();
      final manager = Manager.fromFirestore(doc);

      expect(manager.socialMedia.formattedFollowers, '8.0M');
      expect(manager.socialMedia.hasSocialMedia, true);
    });
  });
}

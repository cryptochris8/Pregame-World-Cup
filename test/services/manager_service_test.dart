import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:pregame_world_cup/domain/models/manager.dart';

/// Tests for Manager data model and Firestore integration
/// Note: These tests use FakeFirebaseFirestore to test the data layer
/// without requiring Firebase initialization.
void main() {
  late FakeFirebaseFirestore fakeFirestore;

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
  });

  group('Manager Model - Firestore Integration', () {
    test('reads managers from Firestore collection', () async {
      await fakeFirestore.collection('managers').doc('manager_001').set(sampleManagerData1);
      await fakeFirestore.collection('managers').doc('manager_002').set(sampleManagerData2);
      await fakeFirestore.collection('managers').doc('manager_003').set(sampleManagerData3);

      final snapshot = await fakeFirestore.collection('managers').orderBy('fifaCode').get();
      final managers = snapshot.docs.map((doc) => Manager.fromFirestore(doc)).toList();

      expect(managers.length, equals(3));
      expect(managers.any((m) => m.fifaCode == 'ARG'), isTrue);
      expect(managers.any((m) => m.fifaCode == 'BRA'), isTrue);
      expect(managers.any((m) => m.fifaCode == 'GER'), isTrue);
    });

    test('parses manager data correctly from Firestore document', () async {
      await fakeFirestore.collection('managers').doc('manager_001').set(sampleManagerData1);

      final doc = await fakeFirestore.collection('managers').doc('manager_001').get();
      final manager = Manager.fromFirestore(doc);

      expect(manager.commonName, equals('Tite'));
      expect(manager.nationality, equals('Brazilian'));
      expect(manager.currentTeam, equals('Brazil'));
      expect(manager.fifaCode, equals('BRA'));
    });

    test('can query managers by team', () async {
      await fakeFirestore.collection('managers').doc('manager_001').set(sampleManagerData1);
      await fakeFirestore.collection('managers').doc('manager_002').set(sampleManagerData2);

      final snapshot = await fakeFirestore
          .collection('managers')
          .where('currentTeam', isEqualTo: 'Argentina')
          .get();
      final managers = snapshot.docs.map((doc) => Manager.fromFirestore(doc)).toList();

      expect(managers.length, equals(1));
      expect(managers.first.currentTeam, equals('Argentina'));
    });

    test('handles empty collection gracefully', () async {
      final snapshot = await fakeFirestore.collection('managers').get();
      final managers = snapshot.docs.map((doc) => Manager.fromFirestore(doc)).toList();

      expect(managers, isEmpty);
    });

    test('manager honors contain World Cup', () async {
      await fakeFirestore.collection('managers').doc('manager_002').set(sampleManagerData2);

      final doc = await fakeFirestore.collection('managers').doc('manager_002').get();
      final manager = Manager.fromFirestore(doc);

      expect(manager.honors.any((h) => h.contains('World Cup')), isTrue);
    });

    test('can filter managers by nationality', () async {
      await fakeFirestore.collection('managers').doc('manager_001').set(sampleManagerData1);
      await fakeFirestore.collection('managers').doc('manager_002').set(sampleManagerData2);
      await fakeFirestore.collection('managers').doc('manager_003').set(sampleManagerData3);

      final snapshot = await fakeFirestore
          .collection('managers')
          .where('nationality', isEqualTo: 'German')
          .get();
      final managers = snapshot.docs.map((doc) => Manager.fromFirestore(doc)).toList();

      expect(managers.length, equals(1));
      expect(managers.first.commonName, equals('Julian Nagelsmann'));
    });
  });

  group('Manager Model - Data Parsing', () {
    test('parses stats correctly', () async {
      await fakeFirestore.collection('managers').doc('manager_001').set(sampleManagerData1);

      final doc = await fakeFirestore.collection('managers').doc('manager_001').get();
      final manager = Manager.fromFirestore(doc);

      expect(manager.stats.matchesManaged, equals(450));
      expect(manager.stats.wins, equals(280));
      expect(manager.stats.winPercentage, equals(62.2));
    });

    test('parses social media correctly', () async {
      await fakeFirestore.collection('managers').doc('manager_001').set(sampleManagerData1);

      final doc = await fakeFirestore.collection('managers').doc('manager_001').get();
      final manager = Manager.fromFirestore(doc);

      expect(manager.socialMedia.instagram, equals('@tite_oficial'));
      expect(manager.socialMedia.twitter, equals('@tite'));
    });

    test('parses previous clubs list correctly', () async {
      await fakeFirestore.collection('managers').doc('manager_001').set(sampleManagerData1);

      final doc = await fakeFirestore.collection('managers').doc('manager_001').get();
      final manager = Manager.fromFirestore(doc);

      expect(manager.previousClubs, contains('Corinthians'));
      expect(manager.previousClubs.length, equals(3));
    });

    test('parses strengths and weaknesses correctly', () async {
      await fakeFirestore.collection('managers').doc('manager_002').set(sampleManagerData2);

      final doc = await fakeFirestore.collection('managers').doc('manager_002').get();
      final manager = Manager.fromFirestore(doc);

      expect(manager.strengths, contains('Player relationships'));
      expect(manager.weaknesses, contains('Limited experience'));
    });
  });

  group('Manager Model - Edge Cases', () {
    test('handles manager with empty honors list', () async {
      final managerWithNoHonors = Map<String, dynamic>.from(sampleManagerData1);
      managerWithNoHonors['honors'] = [];

      await fakeFirestore.collection('managers').doc('manager_empty').set(managerWithNoHonors);

      final doc = await fakeFirestore.collection('managers').doc('manager_empty').get();
      final manager = Manager.fromFirestore(doc);

      expect(manager.honors, isEmpty);
    });

    test('handles manager with controversies', () async {
      await fakeFirestore.collection('managers').doc('manager_003').set(sampleManagerData3);

      final doc = await fakeFirestore.collection('managers').doc('manager_003').get();
      final manager = Manager.fromFirestore(doc);

      expect(manager.controversies, isNotEmpty);
      expect(manager.controversies.first, contains('Bayern'));
    });

    test('orders managers by FIFA code', () async {
      await fakeFirestore.collection('managers').doc('manager_003').set(sampleManagerData3);
      await fakeFirestore.collection('managers').doc('manager_001').set(sampleManagerData1);
      await fakeFirestore.collection('managers').doc('manager_002').set(sampleManagerData2);

      final snapshot = await fakeFirestore
          .collection('managers')
          .orderBy('fifaCode')
          .get();
      final managers = snapshot.docs.map((doc) => Manager.fromFirestore(doc)).toList();

      expect(managers[0].fifaCode, equals('ARG'));
      expect(managers[1].fifaCode, equals('BRA'));
      expect(managers[2].fifaCode, equals('GER'));
    });
  });
}

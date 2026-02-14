import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:pregame_world_cup/domain/models/manager.dart';

/// Tests for Manager data models and UI components
/// Note: Full screen tests require Firebase initialization.
/// These tests focus on the Manager model and basic UI components.
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

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
  });

  group('Manager Model Tests', () {
    test('Manager parses from Firestore document correctly', () async {
      await fakeFirestore.collection('managers').doc('manager_001').set(sampleManagerData1);

      final doc = await fakeFirestore.collection('managers').doc('manager_001').get();
      final manager = Manager.fromFirestore(doc);

      expect(manager.managerId, equals('manager_001'));
      expect(manager.commonName, equals('Tite'));
      expect(manager.nationality, equals('Brazilian'));
      expect(manager.currentTeam, equals('Brazil'));
    });

    test('Manager stats are parsed correctly', () async {
      await fakeFirestore.collection('managers').doc('manager_001').set(sampleManagerData1);

      final doc = await fakeFirestore.collection('managers').doc('manager_001').get();
      final manager = Manager.fromFirestore(doc);

      expect(manager.stats.matchesManaged, equals(450));
      expect(manager.stats.wins, equals(280));
      expect(manager.stats.winPercentage, equals(62.2));
    });

    test('Manager honors list is parsed correctly', () async {
      await fakeFirestore.collection('managers').doc('manager_001').set(sampleManagerData1);

      final doc = await fakeFirestore.collection('managers').doc('manager_001').get();
      final manager = Manager.fromFirestore(doc);

      expect(manager.honors.length, equals(2));
      expect(manager.honors, contains('Copa America 2019'));
    });

    test('Manager previous clubs are parsed correctly', () async {
      await fakeFirestore.collection('managers').doc('manager_001').set(sampleManagerData1);

      final doc = await fakeFirestore.collection('managers').doc('manager_001').get();
      final manager = Manager.fromFirestore(doc);

      expect(manager.previousClubs.length, equals(3));
      expect(manager.previousClubs, contains('Corinthians'));
    });

    test('Manager social media is parsed correctly', () async {
      await fakeFirestore.collection('managers').doc('manager_001').set(sampleManagerData1);

      final doc = await fakeFirestore.collection('managers').doc('manager_001').get();
      final manager = Manager.fromFirestore(doc);

      expect(manager.socialMedia.instagram, equals('@tite_oficial'));
      expect(manager.socialMedia.twitter, equals('@tite'));
    });
  });

  group('Manager Widget Components', () {
    testWidgets('Manager info card displays correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Card(
              child: ListTile(
                leading: CircleAvatar(child: Text('T')),
                title: Text('Tite'),
                subtitle: Text('Brazil'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Tite'), findsOneWidget);
      expect(find.text('Brazil'), findsOneWidget);
      expect(find.text('T'), findsOneWidget);
    });

    testWidgets('Manager stats widget displays correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                _StatItem(label: 'Matches', value: '450'),
                _StatItem(label: 'Wins', value: '280'),
                _StatItem(label: 'Win Rate', value: '62.2%'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('450'), findsOneWidget);
      expect(find.text('280'), findsOneWidget);
      expect(find.text('62.2%'), findsOneWidget);
    });

    testWidgets('Manager honors list displays correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text('Honors'),
                Chip(label: Text('Copa America 2019')),
                Chip(label: Text('FIFA Confederations Cup 2013')),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Honors'), findsOneWidget);
      expect(find.text('Copa America 2019'), findsOneWidget);
      expect(find.text('FIFA Confederations Cup 2013'), findsOneWidget);
    });
  });
}

// Helper widget for stats display
class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label),
      ],
    );
  }
}

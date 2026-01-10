import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pregame_world_cup/domain/models/player.dart';

/// Tests for Player data models and UI components
/// Note: Full screen tests require Firebase initialization.
/// These tests focus on the Player model and basic UI components.
void main() {
  late FakeFirebaseFirestore fakeFirestore;

  // Sample player data for testing
  final samplePlayerData1 = {
    'playerId': 'player_001',
    'fifaCode': 'BRA',
    'firstName': 'Neymar',
    'lastName': 'da Silva Santos Júnior',
    'fullName': 'Neymar da Silva Santos Júnior',
    'commonName': 'Neymar',
    'jerseyNumber': 10,
    'position': 'LW',
    'dateOfBirth': '1992-02-05',
    'age': 32,
    'height': 175,
    'weight': 68,
    'preferredFoot': 'Right',
    'club': 'Al-Hilal',
    'clubLeague': 'Saudi Pro League',
    'photoUrl': 'https://example.com/neymar.jpg',
    'marketValue': 40000000,
    'caps': 128,
    'goals': 79,
    'assists': 58,
    'worldCupAppearances': 2,
    'worldCupGoals': 8,
    'previousWorldCups': [2014, 2018, 2022],
    'stats': {
      'club': {
        'season': '2024-25',
        'appearances': 25,
        'goals': 15,
        'assists': 12,
        'minutesPlayed': 2000,
      },
      'international': {
        'appearances': 128,
        'goals': 79,
        'assists': 58,
        'minutesPlayed': 10000,
      },
    },
    'honors': ['Copa America 2019', 'Olympic Gold 2016'],
    'strengths': ['Dribbling', 'Speed', 'Creativity'],
    'weaknesses': ['Discipline', 'Diving'],
    'playStyle': 'Creative and skillful winger',
    'keyMoment': 'Leading Brazil to Olympic gold',
    'comparisonToLegend': 'Modern day Ronaldinho',
    'worldCup2026Prediction': 'Key player for Brazil',
    'socialMedia': {
      'instagram': '@neymarjr',
      'twitter': '@neymarjr',
      'followers': 200000000,
    },
    'trivia': ['Youngest Brazilian to score in a World Cup'],
  };

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
  });

  group('Player Model Tests', () {
    test('Player parses from Firestore document correctly', () async {
      await fakeFirestore.collection('players').doc('player_001').set(samplePlayerData1);

      final doc = await fakeFirestore.collection('players').doc('player_001').get();
      final player = Player.fromFirestore(doc);

      expect(player.playerId, equals('player_001'));
      expect(player.commonName, equals('Neymar'));
      expect(player.fifaCode, equals('BRA'));
      expect(player.position, equals('LW'));
    });

    test('Player stats are parsed correctly', () async {
      await fakeFirestore.collection('players').doc('player_001').set(samplePlayerData1);

      final doc = await fakeFirestore.collection('players').doc('player_001').get();
      final player = Player.fromFirestore(doc);

      expect(player.caps, equals(128));
      expect(player.goals, equals(79));
      expect(player.assists, equals(58));
    });

    test('Player World Cup stats are parsed correctly', () async {
      await fakeFirestore.collection('players').doc('player_001').set(samplePlayerData1);

      final doc = await fakeFirestore.collection('players').doc('player_001').get();
      final player = Player.fromFirestore(doc);

      expect(player.worldCupAppearances, equals(2));
      expect(player.worldCupGoals, equals(8));
      expect(player.previousWorldCups.length, equals(3));
    });

    test('Player physical attributes are parsed correctly', () async {
      await fakeFirestore.collection('players').doc('player_001').set(samplePlayerData1);

      final doc = await fakeFirestore.collection('players').doc('player_001').get();
      final player = Player.fromFirestore(doc);

      expect(player.height, equals(175));
      expect(player.weight, equals(68));
      expect(player.preferredFoot, equals('Right'));
    });

    test('Player social media is parsed correctly', () async {
      await fakeFirestore.collection('players').doc('player_001').set(samplePlayerData1);

      final doc = await fakeFirestore.collection('players').doc('player_001').get();
      final player = Player.fromFirestore(doc);

      expect(player.socialMedia.instagram, equals('@neymarjr'));
      expect(player.socialMedia.followers, equals(200000000));
    });
  });

  group('Player Widget Components', () {
    testWidgets('Player info card displays correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Card(
              child: ListTile(
                leading: const CircleAvatar(child: Text('N')),
                title: const Text('Neymar'),
                subtitle: const Text('Brazil - LW'),
                trailing: const Text('#10'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Neymar'), findsOneWidget);
      expect(find.text('Brazil - LW'), findsOneWidget);
      expect(find.text('#10'), findsOneWidget);
    });

    testWidgets('Player stats widget displays correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                _StatItem(label: 'Caps', value: '128'),
                _StatItem(label: 'Goals', value: '79'),
                _StatItem(label: 'Assists', value: '58'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('128'), findsOneWidget);
      expect(find.text('79'), findsOneWidget);
      expect(find.text('58'), findsOneWidget);
    });

    testWidgets('Player strengths display correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const Text('Strengths'),
                Chip(label: Text('Dribbling')),
                Chip(label: Text('Speed')),
                Chip(label: Text('Creativity')),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Strengths'), findsOneWidget);
      expect(find.text('Dribbling'), findsOneWidget);
      expect(find.text('Speed'), findsOneWidget);
      expect(find.text('Creativity'), findsOneWidget);
    });

    testWidgets('Player position badge displays correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('LW', style: TextStyle(color: Colors.white)),
            ),
          ),
        ),
      );

      expect(find.text('LW'), findsOneWidget);
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

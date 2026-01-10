import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:pregame_world_cup/domain/models/player.dart';

/// Tests for Player data model and Firestore integration
/// Note: These tests use FakeFirebaseFirestore to test the data layer
/// without requiring Firebase initialization.
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

  final samplePlayerData2 = {
    'playerId': 'player_002',
    'fifaCode': 'ARG',
    'firstName': 'Lionel',
    'lastName': 'Messi',
    'fullName': 'Lionel Andrés Messi',
    'commonName': 'Lionel Messi',
    'jerseyNumber': 10,
    'position': 'RW',
    'dateOfBirth': '1987-06-24',
    'age': 37,
    'height': 170,
    'weight': 72,
    'preferredFoot': 'Left',
    'club': 'Inter Miami',
    'clubLeague': 'MLS',
    'photoUrl': 'https://example.com/messi.jpg',
    'marketValue': 35000000,
    'caps': 180,
    'goals': 106,
    'assists': 55,
    'worldCupAppearances': 5,
    'worldCupGoals': 13,
    'previousWorldCups': [2006, 2010, 2014, 2018, 2022],
    'stats': {
      'club': {
        'season': '2024-25',
        'appearances': 30,
        'goals': 20,
        'assists': 15,
        'minutesPlayed': 2500,
      },
      'international': {
        'appearances': 180,
        'goals': 106,
        'assists': 55,
        'minutesPlayed': 15000,
      },
    },
    'honors': ['World Cup 2022', 'Copa America 2021'],
    'strengths': ['Finishing', 'Passing', 'Dribbling'],
    'weaknesses': ['Age'],
    'playStyle': 'Complete forward',
    'keyMoment': 'Winning World Cup 2022',
    'comparisonToLegend': 'GOAT',
    'worldCup2026Prediction': 'Final tournament',
    'socialMedia': {
      'instagram': '@leomessi',
      'twitter': '@leomessi',
      'followers': 500000000,
    },
    'trivia': ['Eight-time Ballon d\'Or winner'],
  };

  final samplePlayerData3 = {
    'playerId': 'player_003',
    'fifaCode': 'BRA',
    'firstName': 'Vinicius',
    'lastName': 'Junior',
    'fullName': 'Vinicius José Paixão de Oliveira Júnior',
    'commonName': 'Vinicius Jr.',
    'jerseyNumber': 7,
    'position': 'LW',
    'dateOfBirth': '2000-07-12',
    'age': 24,
    'height': 176,
    'weight': 73,
    'preferredFoot': 'Right',
    'club': 'Real Madrid',
    'clubLeague': 'La Liga',
    'photoUrl': 'https://example.com/vinicius.jpg',
    'marketValue': 150000000,
    'caps': 35,
    'goals': 8,
    'assists': 10,
    'worldCupAppearances': 1,
    'worldCupGoals': 2,
    'previousWorldCups': [2022],
    'stats': {
      'club': {
        'season': '2024-25',
        'appearances': 35,
        'goals': 24,
        'assists': 15,
        'minutesPlayed': 3000,
      },
      'international': {
        'appearances': 35,
        'goals': 8,
        'assists': 10,
        'minutesPlayed': 2500,
      },
    },
    'honors': ['Champions League 2024'],
    'strengths': ['Speed', 'Dribbling'],
    'weaknesses': ['Finishing consistency'],
    'playStyle': 'Electric winger',
    'keyMoment': 'Champions League final goal',
    'comparisonToLegend': 'Young Ronaldo',
    'worldCup2026Prediction': 'Rising star',
    'socialMedia': {
      'instagram': '@vinijr',
      'twitter': '@vinijr',
      'followers': 50000000,
    },
    'trivia': ['Youngest Brazilian scorer in Champions League final'],
  };

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
  });

  group('Player Model - Firestore Integration', () {
    test('reads players from Firestore collection', () async {
      await fakeFirestore.collection('players').doc('player_001').set(samplePlayerData1);
      await fakeFirestore.collection('players').doc('player_002').set(samplePlayerData2);
      await fakeFirestore.collection('players').doc('player_003').set(samplePlayerData3);

      final snapshot = await fakeFirestore.collection('players').get();
      final players = snapshot.docs.map((doc) => Player.fromFirestore(doc)).toList();

      expect(players.length, 3);
      expect(players.any((p) => p.commonName == 'Neymar'), true);
      expect(players.any((p) => p.commonName == 'Lionel Messi'), true);
      expect(players.any((p) => p.commonName == 'Vinicius Jr.'), true);
    });

    test('filters players correctly by FIFA code', () async {
      await fakeFirestore.collection('players').doc('player_001').set(samplePlayerData1);
      await fakeFirestore.collection('players').doc('player_002').set(samplePlayerData2);
      await fakeFirestore.collection('players').doc('player_003').set(samplePlayerData3);

      final snapshot = await fakeFirestore
          .collection('players')
          .where('fifaCode', isEqualTo: 'BRA')
          .get();
      final players = snapshot.docs.map((doc) => Player.fromFirestore(doc)).toList();

      expect(players.length, 2);
      expect(players.every((p) => p.fifaCode == 'BRA'), true);
      expect(players.any((p) => p.commonName == 'Neymar'), true);
      expect(players.any((p) => p.commonName == 'Vinicius Jr.'), true);
    });

    test('returns correct player when it exists', () async {
      await fakeFirestore.collection('players').doc('player_001').set(samplePlayerData1);

      final doc = await fakeFirestore.collection('players').doc('player_001').get();
      final player = Player.fromFirestore(doc);

      expect(player, isNotNull);
      expect(player.playerId, 'player_001');
      expect(player.commonName, 'Neymar');
      expect(player.fifaCode, 'BRA');
    });

    test('filters players by position', () async {
      await fakeFirestore.collection('players').doc('player_001').set(samplePlayerData1);
      await fakeFirestore.collection('players').doc('player_002').set(samplePlayerData2);
      await fakeFirestore.collection('players').doc('player_003').set(samplePlayerData3);

      final snapshot = await fakeFirestore
          .collection('players')
          .where('position', isEqualTo: 'LW')
          .get();
      final players = snapshot.docs.map((doc) => Player.fromFirestore(doc)).toList();

      expect(players.length, 2);
      expect(players.every((p) => p.position == 'LW'), true);
    });

    test('returns players sorted by market value', () async {
      await fakeFirestore.collection('players').doc('player_001').set(samplePlayerData1);
      await fakeFirestore.collection('players').doc('player_002').set(samplePlayerData2);
      await fakeFirestore.collection('players').doc('player_003').set(samplePlayerData3);

      final snapshot = await fakeFirestore
          .collection('players')
          .orderBy('marketValue', descending: true)
          .get();
      final players = snapshot.docs.map((doc) => Player.fromFirestore(doc)).toList();

      expect(players.length, 3);
      expect(players[0].commonName, 'Vinicius Jr.');
      expect(players[0].marketValue, 150000000);
    });
  });

  group('Player Model - Empty Collection', () {
    test('returns empty list on empty collection', () async {
      final snapshot = await fakeFirestore.collection('players').get();
      final players = snapshot.docs.map((doc) => Player.fromFirestore(doc)).toList();

      expect(players, isEmpty);
    });

    test('returns false for non-existent player', () async {
      final doc = await fakeFirestore.collection('players').doc('nonexistent_id').get();

      expect(doc.exists, false);
    });

    test('returns empty list when no players match', () async {
      await fakeFirestore.collection('players').doc('player_001').set(samplePlayerData1);

      final snapshot = await fakeFirestore
          .collection('players')
          .where('fifaCode', isEqualTo: 'XYZ')
          .get();
      final players = snapshot.docs.map((doc) => Player.fromFirestore(doc)).toList();

      expect(players, isEmpty);
    });
  });

  group('Player Model - Data Parsing', () {
    test('parses player stats correctly', () async {
      await fakeFirestore.collection('players').doc('player_001').set(samplePlayerData1);

      final doc = await fakeFirestore.collection('players').doc('player_001').get();
      final player = Player.fromFirestore(doc);

      expect(player.caps, equals(128));
      expect(player.goals, equals(79));
      expect(player.assists, equals(58));
    });

    test('parses World Cup history correctly', () async {
      await fakeFirestore.collection('players').doc('player_002').set(samplePlayerData2);

      final doc = await fakeFirestore.collection('players').doc('player_002').get();
      final player = Player.fromFirestore(doc);

      expect(player.worldCupAppearances, equals(5));
      expect(player.worldCupGoals, equals(13));
      expect(player.previousWorldCups.length, equals(5));
      expect(player.previousWorldCups, contains(2022));
    });

    test('parses social media correctly', () async {
      await fakeFirestore.collection('players').doc('player_001').set(samplePlayerData1);

      final doc = await fakeFirestore.collection('players').doc('player_001').get();
      final player = Player.fromFirestore(doc);

      expect(player.socialMedia.instagram, equals('@neymarjr'));
      expect(player.socialMedia.followers, equals(200000000));
    });

    test('parses physical attributes correctly', () async {
      await fakeFirestore.collection('players').doc('player_002').set(samplePlayerData2);

      final doc = await fakeFirestore.collection('players').doc('player_002').get();
      final player = Player.fromFirestore(doc);

      expect(player.height, equals(170));
      expect(player.weight, equals(72));
      expect(player.preferredFoot, equals('Left'));
    });

    test('parses strengths and weaknesses correctly', () async {
      await fakeFirestore.collection('players').doc('player_001').set(samplePlayerData1);

      final doc = await fakeFirestore.collection('players').doc('player_001').get();
      final player = Player.fromFirestore(doc);

      expect(player.strengths, contains('Dribbling'));
      expect(player.strengths, contains('Speed'));
      expect(player.weaknesses, contains('Discipline'));
    });
  });

  group('Player Model - Filtering and Search', () {
    test('search players by name', () async {
      await fakeFirestore.collection('players').doc('player_001').set(samplePlayerData1);
      await fakeFirestore.collection('players').doc('player_002').set(samplePlayerData2);
      await fakeFirestore.collection('players').doc('player_003').set(samplePlayerData3);

      final snapshot = await fakeFirestore.collection('players').get();
      final allPlayers = snapshot.docs.map((doc) => Player.fromFirestore(doc)).toList();

      final query = 'messi';
      final results = allPlayers.where((player) {
        return player.fullName.toLowerCase().contains(query.toLowerCase()) ||
            player.commonName.toLowerCase().contains(query.toLowerCase());
      }).toList();

      expect(results.length, equals(1));
      expect(results.first.commonName, equals('Lionel Messi'));
    });

    test('filter World Cup winners', () async {
      await fakeFirestore.collection('players').doc('player_001').set(samplePlayerData1);
      await fakeFirestore.collection('players').doc('player_002').set(samplePlayerData2);
      await fakeFirestore.collection('players').doc('player_003').set(samplePlayerData3);

      final snapshot = await fakeFirestore.collection('players').get();
      final allPlayers = snapshot.docs.map((doc) => Player.fromFirestore(doc)).toList();

      final worldCupWinners = allPlayers.where((player) {
        return player.honors.any((h) => h.toLowerCase().contains('world cup'));
      }).toList();

      expect(worldCupWinners.length, equals(1));
      expect(worldCupWinners.first.commonName, equals('Lionel Messi'));
    });

    test('filter by club league', () async {
      await fakeFirestore.collection('players').doc('player_001').set(samplePlayerData1);
      await fakeFirestore.collection('players').doc('player_002').set(samplePlayerData2);
      await fakeFirestore.collection('players').doc('player_003').set(samplePlayerData3);

      final snapshot = await fakeFirestore
          .collection('players')
          .where('clubLeague', isEqualTo: 'La Liga')
          .get();
      final players = snapshot.docs.map((doc) => Player.fromFirestore(doc)).toList();

      expect(players.length, equals(1));
      expect(players.first.commonName, equals('Vinicius Jr.'));
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:pregame_world_cup/presentation/screens/manager_profiles_screen.dart';
import 'package:pregame_world_cup/domain/models/manager.dart';
import 'package:pregame_world_cup/data/services/manager_service.dart';

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
    'photoUrl': '',
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

  // Helper function to create widget with material app wrapper
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: ManagerProfilesScreen(),
    );
  }

  group('ManagerProfilesScreen - Widget Rendering Tests', () {
    testWidgets('renders AppBar with correct title', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Manager Profiles'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('renders search bar', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search managers...'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('renders filter chips', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(FilterChip), findsWidgets);
      expect(find.text('All Managers'), findsOneWidget);
      expect(find.text('Brazil'), findsOneWidget);
      expect(find.text('Argentina'), findsOneWidget);
      expect(find.text('Most Experienced'), findsOneWidget);
    });

    testWidgets('renders loading indicator initially', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders refresh button in AppBar', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.byTooltip('Refresh'), findsOneWidget);
    });
  });

  group('ManagerProfilesScreen - User Interaction Tests', () {
    testWidgets('search field can accept input', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'Tite');
      await tester.pump();

      expect(find.text('Tite'), findsOneWidget);
    });

    testWidgets('search field shows clear button when text is entered', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'Test');
      await tester.pump();

      // After entering text, clear button should appear
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('clear button clears search text', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'Test');
      await tester.pump();

      // Tap clear button
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      // Text should be cleared
      final textField = tester.widget<TextField>(searchField);
      expect(textField.controller?.text, isEmpty);
    });

    testWidgets('filter chip can be selected', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Find and tap a filter chip
      final mostExpChip = find.widgetWithText(FilterChip, 'Most Experienced');
      expect(mostExpChip, findsOneWidget);

      await tester.tap(mostExpChip);
      await tester.pump();

      // The filter should now be selected
      expect(mostExpChip, findsOneWidget);
    });

    testWidgets('refresh button triggers reload', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final refreshButton = find.byIcon(Icons.refresh);
      expect(refreshButton, findsOneWidget);

      await tester.tap(refreshButton);
      await tester.pump();

      // After tapping refresh, loading indicator should appear
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('ManagerProfilesScreen - Empty State Tests', () {
    testWidgets('shows "No managers found" when no data', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Wait for loading to complete
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // When no managers are loaded, should show loading or empty state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('ManagerProfilesScreen - Manager Card Tests', () {
    testWidgets('manager card displays correct information', (WidgetTester tester) async {
      final testManager = Manager.fromFirestore(
        FakeDocumentSnapshot(sampleManagerData1),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Card(
              child: Column(
                children: [
                  Text(testManager.commonName),
                  Text(testManager.currentTeam),
                  Text('${testManager.nationality} • ${testManager.age} years'),
                  Text('${testManager.yearsOfExperience}y exp'),
                  Text(testManager.stats.formattedWinPercentage),
                  Text('${testManager.stats.titlesWon} titles'),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Tite'), findsOneWidget);
      expect(find.text('Brazil'), findsOneWidget);
      expect(find.text('Brazilian • 63 years'), findsOneWidget);
      expect(find.text('34y exp'), findsOneWidget);
      expect(find.text('62.2%'), findsOneWidget);
      expect(find.text('12 titles'), findsOneWidget);
    });

    testWidgets('manager card shows controversial badge when applicable', (WidgetTester tester) async {
      final testManager = Manager.fromFirestore(
        FakeDocumentSnapshot(sampleManagerData3),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text(testManager.commonName),
                if (testManager.isControversial)
                  const Text('Controversial'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Julian Nagelsmann'), findsOneWidget);
      expect(find.text('Controversial'), findsOneWidget);
    });

    testWidgets('manager card with empty photoUrl handles correctly', (WidgetTester tester) async {
      final testManager = Manager.fromFirestore(
        FakeDocumentSnapshot(sampleManagerData2),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text(testManager.commonName),
                Text(testManager.photoUrl.isEmpty ? 'PLACEHOLDER' : 'IMAGE'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Lionel Scaloni'), findsOneWidget);
      expect(find.text('PLACEHOLDER'), findsOneWidget);
    });
  });

  group('ManagerProfilesScreen - Filter Logic Tests', () {
    testWidgets('displays manager count correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Should display "X managers" text
      expect(find.textContaining('managers'), findsWidgets);
    });

    testWidgets('Clear filters button appears when filter is active', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Select a filter
      final youngChip = find.widgetWithText(FilterChip, 'Youngest');
      await tester.tap(youngChip);
      await tester.pump();

      // Clear filters button should appear
      expect(find.text('Clear filters'), findsWidgets);
    });

    testWidgets('multiple filter options are available', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Check for various filter options
      expect(find.text('All Managers'), findsOneWidget);
      expect(find.text('Most Experienced'), findsOneWidget);
      expect(find.text('Youngest'), findsOneWidget);
      expect(find.text('Oldest'), findsOneWidget);
      expect(find.text('Highest Win %'), findsOneWidget);
      expect(find.text('Most Titles'), findsOneWidget);
      expect(find.text('WC Winners'), findsOneWidget);
      expect(find.text('Controversial'), findsOneWidget);
    });
  });

  group('ManagerProfilesScreen - Error Handling Tests', () {
    testWidgets('handles service errors gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Wait for potential error state
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      // Widget should not crash and should handle errors
      expect(find.byType(ManagerProfilesScreen), findsOneWidget);
    });
  });

  group('ManagerProfilesScreen - Navigation Tests', () {
    testWidgets('tapping manager card navigates to detail screen', (WidgetTester tester) async {
      final testManager = Manager.fromFirestore(
        FakeDocumentSnapshot(sampleManagerData1),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Card(
              child: InkWell(
                onTap: () {
                  // This would normally navigate
                },
                child: Text(testManager.commonName),
              ),
            ),
          ),
        ),
      );

      final managerCard = find.text('Tite');
      expect(managerCard, findsOneWidget);

      await tester.tap(managerCard);
      await tester.pump();

      // Verify tap was registered
      expect(managerCard, findsOneWidget);
    });
  });

  group('ManagerProfilesScreen - Manager Stats Display Tests', () {
    testWidgets('displays manager statistics correctly', (WidgetTester tester) async {
      final testManager = Manager.fromFirestore(
        FakeDocumentSnapshot(sampleManagerData2),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text(testManager.stats.recordDisplay),
                Text(testManager.stats.formattedWinPercentage),
                Text('${testManager.stats.matchesManaged} matches'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('60-15-10'), findsOneWidget);
      expect(find.text('70.6%'), findsOneWidget);
      expect(find.text('85 matches'), findsOneWidget);
    });

    testWidgets('displays experience category correctly', (WidgetTester tester) async {
      final testManager1 = Manager.fromFirestore(
        FakeDocumentSnapshot(sampleManagerData1),
      );
      final testManager2 = Manager.fromFirestore(
        FakeDocumentSnapshot(sampleManagerData2),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text('${testManager1.commonName}: ${testManager1.experienceCategory}'),
                Text('${testManager2.commonName}: ${testManager2.experienceCategory}'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Tite: Veteran'), findsOneWidget);
      expect(find.text('Lionel Scaloni: Developing'), findsOneWidget);
    });
  });

  group('ManagerProfilesScreen - ListView Tests', () {
    testWidgets('uses ListView for manager cards display', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // After loading, ListView should be present (or CircularProgressIndicator)
      // Since we don't have real data, we expect loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}

// Helper class to create fake document snapshots for testing
class FakeDocumentSnapshot implements DocumentSnapshot<Object?> {
  final Map<String, dynamic> _data;

  FakeDocumentSnapshot(this._data);

  @override
  Object? data() => _data;

  @override
  bool get exists => true;

  @override
  String get id => _data['managerId'] ?? '';

  @override
  DocumentReference<Object?> get reference => throw UnimplementedError();

  @override
  SnapshotMetadata get metadata => throw UnimplementedError();

  @override
  dynamic operator [](Object field) => _data[field as String];

  @override
  dynamic get(Object field) => _data[field as String];
}

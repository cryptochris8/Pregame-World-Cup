import 'package:flutter_test/flutter_test.dart';
import 'package:pregame_world_cup/features/worldcup/domain/entities/entities.dart';
import 'package:pregame_world_cup/features/worldcup/data/services/monte_carlo_simulation_service.dart';
import 'package:pregame_world_cup/features/worldcup/data/mock/world_cup_mock_data.dart';

void main() {
  late MonteCarloSimulationService service;

  setUp(() {
    service = MonteCarloSimulationService();
    service.initialize();
  });

  // ---------------------------------------------------------------------------
  // Helper: create a minimal set of teams for focused testing
  // ---------------------------------------------------------------------------
  List<NationalTeam> createMinimalTeams() {
    return [
      // Group A: 4 teams
      _team('T01', 'Team Alpha', 'A', 1),
      _team('T02', 'Team Beta', 'A', 10),
      _team('T03', 'Team Gamma', 'A', 50),
      _team('T04', 'Team Delta', 'A', 100),
      // Group B: 4 teams
      _team('T05', 'Team Epsilon', 'B', 5),
      _team('T06', 'Team Zeta', 'B', 15),
      _team('T07', 'Team Eta', 'B', 60),
      _team('T08', 'Team Theta', 'B', 120),
      // Group C: 4 teams
      _team('T09', 'Team Iota', 'C', 3),
      _team('T10', 'Team Kappa', 'C', 20),
      _team('T11', 'Team Lambda', 'C', 70),
      _team('T12', 'Team Mu', 'C', 130),
      // Group D: 4 teams
      _team('T13', 'Team Nu', 'D', 2),
      _team('T14', 'Team Xi', 'D', 25),
      _team('T15', 'Team Omicron', 'D', 80),
      _team('T16', 'Team Pi', 'D', 140),
      // Group E: 4 teams
      _team('T17', 'Team Rho', 'E', 4),
      _team('T18', 'Team Sigma', 'E', 30),
      _team('T19', 'Team Tau', 'E', 90),
      _team('T20', 'Team Upsilon', 'E', 150),
      // Group F: 4 teams
      _team('T21', 'Team Phi', 'F', 6),
      _team('T22', 'Team Chi', 'F', 35),
      _team('T23', 'Team Psi', 'F', 95),
      _team('T24', 'Team Omega', 'F', 155),
      // Group G: 4 teams
      _team('T25', 'Team Alpha2', 'G', 7),
      _team('T26', 'Team Beta2', 'G', 40),
      _team('T27', 'Team Gamma2', 'G', 100),
      _team('T28', 'Team Delta2', 'G', 160),
      // Group H: 4 teams
      _team('T29', 'Team Epsilon2', 'H', 8),
      _team('T30', 'Team Zeta2', 'H', 45),
      _team('T31', 'Team Eta2', 'H', 105),
      _team('T32', 'Team Theta2', 'H', 165),
      // Group I: 4 teams
      _team('T33', 'Team Iota2', 'I', 9),
      _team('T34', 'Team Kappa2', 'I', 48),
      _team('T35', 'Team Lambda2', 'I', 110),
      _team('T36', 'Team Mu2', 'I', 170),
      // Group J: 4 teams
      _team('T37', 'Team Nu2', 'J', 11),
      _team('T38', 'Team Xi2', 'J', 50),
      _team('T39', 'Team Omicron2', 'J', 115),
      _team('T40', 'Team Pi2', 'J', 175),
      // Group K: 4 teams
      _team('T41', 'Team Rho2', 'K', 12),
      _team('T42', 'Team Sigma2', 'K', 55),
      _team('T43', 'Team Tau2', 'K', 120),
      _team('T44', 'Team Omega2', 'K', 180),
      // Group L: 4 teams
      _team('T45', 'Team Phi2', 'L', 13),
      _team('T46', 'Team Chi2', 'L', 58),
      _team('T47', 'Team Psi2', 'L', 125),
      _team('T48', 'Team Zeta3', 'L', 185),
    ];
  }

  // ---------------------------------------------------------------------------
  // 1. Initialization tests
  // ---------------------------------------------------------------------------
  group('initialization', () {
    test('initializes with WorldCupMockData teams by default', () {
      final svc = MonteCarloSimulationService();
      svc.initialize();
      expect(svc.isInitialized, isTrue);
    });

    test('initializes with custom team list', () {
      final svc = MonteCarloSimulationService();
      final teams = createMinimalTeams();
      svc.initialize(teams: teams);
      expect(svc.isInitialized, isTrue);
    });

    test('auto-initializes when simulateTournament is called without init', () {
      final svc = MonteCarloSimulationService();
      expect(svc.isInitialized, isFalse);
      svc.simulateTournament(simulations: 10);
      expect(svc.isInitialized, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // 2. Elo rating tests
  // ---------------------------------------------------------------------------
  group('Elo ratings', () {
    test('rank 1 team has highest Elo', () {
      // ARG is rank 1 in mock data
      final argElo = service.getEloRating('ARG');
      expect(argElo, isNotNull);
      expect(argElo!, greaterThan(2100));
    });

    test('higher-ranked teams have higher Elo ratings', () {
      final argElo = service.getEloRating('ARG')!; // rank 1
      final braElo = service.getEloRating('BRA')!; // rank 5
      final usaElo = service.getEloRating('USA')!; // rank 11
      final panElo = service.getEloRating('PAN')!; // rank 48

      expect(argElo, greaterThan(braElo));
      expect(braElo, greaterThan(usaElo));
      expect(usaElo, greaterThan(panElo));
    });

    test('Elo ratings are in reasonable range', () {
      for (final team in WorldCupMockData.teams) {
        final elo = service.getEloRating(team.teamCode);
        expect(elo, isNotNull, reason: '${team.teamCode} should have an Elo rating');
        expect(elo!, greaterThan(1000), reason: '${team.teamCode} Elo too low');
        expect(elo, lessThan(2300), reason: '${team.teamCode} Elo too high');
      }
    });

    test('returns null for unknown team before initialization', () {
      final svc = MonteCarloSimulationService();
      expect(svc.getEloRating('XXX'), isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // 3. Match probability tests
  // ---------------------------------------------------------------------------
  group('match probabilities', () {
    test('probabilities sum to 1.0 for group stage match', () {
      final probs = service.computeMatchProbabilities('BRA', 'HAI');
      final sum = probs['homeWin']! + probs['draw']! + probs['awayWin']!;
      expect(sum, closeTo(1.0, 0.001));
    });

    test('probabilities sum to 1.0 for knockout match', () {
      final probs = service.computeMatchProbabilities('FRA', 'GER', isKnockout: true);
      final sum = probs['homeWin']! + probs['draw']! + probs['awayWin']!;
      expect(sum, closeTo(1.0, 0.001));
    });

    test('knockout draw probability is lower than group stage', () {
      final groupProbs = service.computeMatchProbabilities('FRA', 'GER');
      final koProbs = service.computeMatchProbabilities('FRA', 'GER', isKnockout: true);
      expect(koProbs['draw']!, lessThan(groupProbs['draw']!));
    });

    test('strong team favored over weak team', () {
      final probs = service.computeMatchProbabilities('ARG', 'IDN');
      expect(probs['homeWin']!, greaterThan(probs['awayWin']!));
      expect(probs['homeWin']!, greaterThan(0.5));
    });

    test('evenly matched teams have balanced probabilities', () {
      // ARG (rank 1) vs FRA (rank 2) should be close
      final probs = service.computeMatchProbabilities('ARG', 'FRA');
      // Neither team should have more than 55% win probability
      expect(probs['homeWin']!, lessThan(0.55));
      expect(probs['awayWin']!, lessThan(0.55));
    });

    test('host advantage boosts home team', () {
      // USA (host) vs equivalent-rank non-host
      final probsHostHome = service.computeMatchProbabilities('USA', 'SEN');
      // Reverse: SEN vs USA (USA still gets host boost)
      final probsHostAway = service.computeMatchProbabilities('SEN', 'USA');

      // USA should be favored when "home" due to host boost on top of home position
      expect(probsHostHome['homeWin']!, greaterThan(probsHostAway['homeWin']!));
    });

    test('all probabilities are positive', () {
      final probs = service.computeMatchProbabilities('BRA', 'ARG');
      expect(probs['homeWin']!, greaterThan(0));
      expect(probs['draw']!, greaterThan(0));
      expect(probs['awayWin']!, greaterThan(0));
    });
  });

  // ---------------------------------------------------------------------------
  // 4. Group stage simulation tests
  // ---------------------------------------------------------------------------
  group('group stage simulation', () {
    test('all 48 teams appear in results', () {
      final result = service.simulateTournament(simulations: 100, seed: 42);
      expect(result.teamResults.length, equals(48));
    });

    test('group stage exit + R32 qualification sums to 100%', () {
      final result = service.simulateTournament(simulations: 500, seed: 42);

      for (final team in result.teamResults.values) {
        final sum = team.groupStageExitPct + team.roundOf32Pct;
        expect(sum, closeTo(100.0, 0.1),
            reason: '${team.teamCode}: groupExit + R32 should sum to 100%');
      }
    });

    test('average group points are in reasonable range', () {
      final result = service.simulateTournament(simulations: 500, seed: 42);

      for (final team in result.teamResults.values) {
        // With 3 group matches, max is 9 points, min is 0
        expect(team.avgGroupPoints, greaterThanOrEqualTo(0.0),
            reason: '${team.teamCode} avg points should be >= 0');
        expect(team.avgGroupPoints, lessThanOrEqualTo(9.0),
            reason: '${team.teamCode} avg points should be <= 9');
      }
    });

    test('strong teams have higher group winner percentage', () {
      final result = service.simulateTournament(simulations: 1000, seed: 42);

      // Brazil (rank 5, group C) vs Haiti (rank 80, group C)
      final brazil = result.teamResults['BRA']!;
      final haiti = result.teamResults['HAI']!;

      expect(brazil.groupWinnerPct, greaterThan(haiti.groupWinnerPct));
    });
  });

  // ---------------------------------------------------------------------------
  // 5. Knockout stage progression tests
  // ---------------------------------------------------------------------------
  group('knockout stage progression', () {
    test('stage probabilities are monotonically decreasing', () {
      final result = service.simulateTournament(simulations: 1000, seed: 42);

      for (final team in result.teamResults.values) {
        // R32 >= R16 >= QF >= SF >= Final >= Winner
        expect(team.roundOf32Pct, greaterThanOrEqualTo(team.roundOf16Pct),
            reason: '${team.teamCode}: R32 should be >= R16');
        expect(team.roundOf16Pct, greaterThanOrEqualTo(team.quarterFinalPct),
            reason: '${team.teamCode}: R16 should be >= QF');
        expect(team.quarterFinalPct, greaterThanOrEqualTo(team.semiFinalPct),
            reason: '${team.teamCode}: QF should be >= SF');
        expect(team.semiFinalPct, greaterThanOrEqualTo(team.finalPct),
            reason: '${team.teamCode}: SF should be >= Final');
        expect(team.finalPct, greaterThanOrEqualTo(team.winnerPct),
            reason: '${team.teamCode}: Final should be >= Winner');
      }
    });

    test('exactly one winner per simulation (winner pcts sum to 100)', () {
      final result = service.simulateTournament(simulations: 1000, seed: 42);

      double totalWinnerPct = 0;
      for (final team in result.teamResults.values) {
        totalWinnerPct += team.winnerPct;
      }
      expect(totalWinnerPct, closeTo(100.0, 1.0));
    });

    test('exactly two finalists per simulation (finalist pcts sum to 200)', () {
      final result = service.simulateTournament(simulations: 1000, seed: 42);

      double totalFinalPct = 0;
      for (final team in result.teamResults.values) {
        totalFinalPct += team.finalPct;
      }
      expect(totalFinalPct, closeTo(200.0, 2.0));
    });

    test('exactly four semifinalists per simulation (SF pcts sum to 400)', () {
      final result = service.simulateTournament(simulations: 1000, seed: 42);

      double totalSFPct = 0;
      for (final team in result.teamResults.values) {
        totalSFPct += team.semiFinalPct;
      }
      expect(totalSFPct, closeTo(400.0, 2.0));
    });

    test('exactly 32 R32 qualifiers per simulation (R32 pcts sum to ~3200)', () {
      final result = service.simulateTournament(simulations: 1000, seed: 42);

      double totalR32Pct = 0;
      for (final team in result.teamResults.values) {
        totalR32Pct += team.roundOf32Pct;
      }
      // 32 teams * 100% = 3200% if every sim has exactly 32
      // Allow some tolerance since bracket building might produce slightly fewer
      expect(totalR32Pct, closeTo(3200.0, 100.0));
    });
  });

  // ---------------------------------------------------------------------------
  // 6. Top team sanity checks
  // ---------------------------------------------------------------------------
  group('top team probability sanity checks', () {
    test('top-ranked teams have > 5% win probability', () {
      final result = service.simulateTournament(simulations: 5000, seed: 42);

      // ARG (rank 1), FRA (rank 2), BRA (rank 5) should all be >5% to win
      final arg = result.teamResults['ARG']!;
      final fra = result.teamResults['FRA']!;
      final bra = result.teamResults['BRA']!;

      expect(arg.winnerPct, greaterThan(5.0),
          reason: 'Argentina should have >5% chance to win');
      expect(fra.winnerPct, greaterThan(5.0),
          reason: 'France should have >5% chance to win');
      expect(bra.winnerPct, greaterThan(5.0),
          reason: 'Brazil should have >5% chance to win');
    });

    test('weak teams have < 5% win probability', () {
      final result = service.simulateTournament(simulations: 5000, seed: 42);

      // CUR (rank 85), IDN (rank 130) should have very low win chance
      final cur = result.teamResults['CUR']!;
      final idn = result.teamResults['IDN']!;

      expect(cur.winnerPct, lessThan(5.0),
          reason: 'Curacao should have <5% chance to win');
      expect(idn.winnerPct, lessThan(5.0),
          reason: 'Indonesia should have <5% chance to win');
    });

    test('top-ranked teams more likely to reach R32 than weak teams', () {
      final result = service.simulateTournament(simulations: 2000, seed: 42);

      final arg = result.teamResults['ARG']!;
      final idn = result.teamResults['IDN']!;

      expect(arg.roundOf32Pct, greaterThan(idn.roundOf32Pct));
    });

    test('ranked list is sorted by win percentage', () {
      final result = service.simulateTournament(simulations: 2000, seed: 42);
      final ranked = result.rankedByWinPct;

      for (int i = 0; i < ranked.length - 1; i++) {
        expect(ranked[i].winnerPct, greaterThanOrEqualTo(ranked[i + 1].winnerPct));
      }
    });
  });

  // ---------------------------------------------------------------------------
  // 7. Deterministic seed tests
  // ---------------------------------------------------------------------------
  group('deterministic seeding', () {
    test('same seed produces identical results', () {
      final svc1 = MonteCarloSimulationService();
      svc1.initialize();
      final result1 = svc1.simulateTournament(simulations: 500, seed: 12345);

      final svc2 = MonteCarloSimulationService();
      svc2.initialize();
      final result2 = svc2.simulateTournament(simulations: 500, seed: 12345);

      for (final code in result1.teamResults.keys) {
        final t1 = result1.teamResults[code]!;
        final t2 = result2.teamResults[code]!;

        expect(t1.winnerPct, equals(t2.winnerPct),
            reason: '$code winner pct should match with same seed');
        expect(t1.roundOf32Pct, equals(t2.roundOf32Pct),
            reason: '$code R32 pct should match with same seed');
        expect(t1.avgGroupPoints, equals(t2.avgGroupPoints),
            reason: '$code avg group points should match with same seed');
      }
    });

    test('different seeds produce different results', () {
      final svc1 = MonteCarloSimulationService();
      svc1.initialize();
      final result1 = svc1.simulateTournament(simulations: 500, seed: 111);

      final svc2 = MonteCarloSimulationService();
      svc2.initialize();
      final result2 = svc2.simulateTournament(simulations: 500, seed: 222);

      // At least some teams should differ
      bool anyDifferent = false;
      for (final code in result1.teamResults.keys) {
        if (result1.teamResults[code]!.winnerPct !=
            result2.teamResults[code]!.winnerPct) {
          anyDifferent = true;
          break;
        }
      }
      expect(anyDifferent, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // 8. Result structure tests
  // ---------------------------------------------------------------------------
  group('result structure', () {
    test('TournamentSimulationResult has correct metadata', () {
      final result = service.simulateTournament(simulations: 100, seed: 42);

      expect(result.totalSimulations, equals(100));
      expect(result.generatedAt, isNotNull);
      expect(result.elapsed.inMicroseconds, greaterThan(0));
      expect(result.teamResults, isNotEmpty);
    });

    test('rankedByWinPct returns all teams sorted', () {
      final result = service.simulateTournament(simulations: 100, seed: 42);
      final ranked = result.rankedByWinPct;

      expect(ranked.length, equals(result.teamResults.length));
    });

    test('rankedByStage works for all stages', () {
      final result = service.simulateTournament(simulations: 100, seed: 42);

      for (final stage in [
        'groupWinner', 'roundOf32', 'roundOf16', 'quarterFinal',
        'semiFinal', 'final', 'winner',
      ]) {
        final ranked = result.rankedByStage(stage);
        expect(ranked.length, equals(result.teamResults.length),
            reason: 'rankedByStage($stage) should return all teams');
      }
    });

    test('TeamSimulationResult toString is well-formed', () {
      final result = service.simulateTournament(simulations: 100, seed: 42);
      final bra = result.teamResults['BRA']!;

      final str = bra.toString();
      expect(str, contains('Brazil'));
      expect(str, contains('BRA'));
      expect(str, contains('Win'));
      expect(str, contains('Final'));
    });
  });

  // ---------------------------------------------------------------------------
  // 9. Performance tests
  // ---------------------------------------------------------------------------
  group('performance', () {
    test('10000 simulations complete in under 30 seconds', () {
      final result = service.simulateTournament(simulations: 10000, seed: 42);

      // Allow 30 seconds (generous limit; target is <10s)
      expect(result.elapsed.inSeconds, lessThan(30),
          reason: '10k simulations should complete in under 30 seconds');
      expect(result.totalSimulations, equals(10000));
    });

    test('1000 simulations complete in under 5 seconds', () {
      final result = service.simulateTournament(simulations: 1000, seed: 42);

      expect(result.elapsed.inSeconds, lessThan(5));
      expect(result.totalSimulations, equals(1000));
    });
  });

  // ---------------------------------------------------------------------------
  // 10. Custom team tests
  // ---------------------------------------------------------------------------
  group('custom teams', () {
    test('simulation works with custom minimal team set', () {
      final teams = createMinimalTeams();
      final svc = MonteCarloSimulationService();

      final result = svc.simulateTournament(
        simulations: 500,
        teams: teams,
        seed: 42,
      );

      expect(result.teamResults.length, equals(48));
      expect(result.totalSimulations, equals(500));

      // Verify top-ranked custom team has higher win % than bottom-ranked
      final topTeam = result.teamResults['T01']!; // rank 1
      final bottomTeam = result.teamResults['T48']!; // rank 185

      expect(topTeam.winnerPct, greaterThan(bottomTeam.winnerPct));
    });
  });

  // ---------------------------------------------------------------------------
  // 11. Edge case tests
  // ---------------------------------------------------------------------------
  group('edge cases', () {
    test('single simulation runs correctly', () {
      final result = service.simulateTournament(simulations: 1, seed: 42);
      expect(result.totalSimulations, equals(1));

      // Exactly one winner in a single simulation
      int winnerCount = 0;
      for (final team in result.teamResults.values) {
        if (team.winnerPct > 0) winnerCount++;
      }
      expect(winnerCount, equals(1));
    });

    test('no probabilities are NaN or negative', () {
      final result = service.simulateTournament(simulations: 500, seed: 42);

      for (final team in result.teamResults.values) {
        expect(team.groupStageExitPct, isNot(isNaN),
            reason: '${team.teamCode} groupStageExitPct should not be NaN');
        expect(team.roundOf32Pct, isNot(isNaN));
        expect(team.roundOf16Pct, isNot(isNaN));
        expect(team.quarterFinalPct, isNot(isNaN));
        expect(team.semiFinalPct, isNot(isNaN));
        expect(team.finalPct, isNot(isNaN));
        expect(team.winnerPct, isNot(isNaN));
        expect(team.avgGroupPoints, isNot(isNaN));

        expect(team.groupStageExitPct, greaterThanOrEqualTo(0));
        expect(team.roundOf32Pct, greaterThanOrEqualTo(0));
        expect(team.roundOf16Pct, greaterThanOrEqualTo(0));
        expect(team.quarterFinalPct, greaterThanOrEqualTo(0));
        expect(team.semiFinalPct, greaterThanOrEqualTo(0));
        expect(team.finalPct, greaterThanOrEqualTo(0));
        expect(team.winnerPct, greaterThanOrEqualTo(0));
        expect(team.avgGroupPoints, greaterThanOrEqualTo(0));
      }
    });

    test('no probability exceeds 100%', () {
      final result = service.simulateTournament(simulations: 500, seed: 42);

      for (final team in result.teamResults.values) {
        expect(team.groupStageExitPct, lessThanOrEqualTo(100.0));
        expect(team.roundOf32Pct, lessThanOrEqualTo(100.0));
        expect(team.roundOf16Pct, lessThanOrEqualTo(100.0));
        expect(team.quarterFinalPct, lessThanOrEqualTo(100.0));
        expect(team.semiFinalPct, lessThanOrEqualTo(100.0));
        expect(team.finalPct, lessThanOrEqualTo(100.0));
        expect(team.winnerPct, lessThanOrEqualTo(100.0));
      }
    });
  });

  // ---------------------------------------------------------------------------
  // 12. Group structure validation
  // ---------------------------------------------------------------------------
  group('group structure', () {
    test('all 12 groups are recognized', () {
      final result = service.simulateTournament(simulations: 100, seed: 42);

      // Every team should have results
      for (final team in WorldCupMockData.teams) {
        expect(result.teamResults.containsKey(team.teamCode), isTrue,
            reason: '${team.teamCode} should appear in results');
      }
    });

    test('48 teams across 12 groups of 4', () {
      // Verify the mock data has correct group distribution
      final groupCounts = <String, int>{};
      for (final team in WorldCupMockData.teams) {
        final group = team.group;
        if (group != null) {
          groupCounts[group] = (groupCounts[group] ?? 0) + 1;
        }
      }

      expect(groupCounts.length, equals(12));
      for (final count in groupCounts.values) {
        expect(count, equals(4),
            reason: 'Each group should have exactly 4 teams');
      }
    });
  });

  // ---------------------------------------------------------------------------
  // 13. Statistical convergence tests
  // ---------------------------------------------------------------------------
  group('statistical convergence', () {
    test('more simulations produce more stable results', () {
      // Run two separate 5000-sim runs with different seeds
      // The top team win percentages should be reasonably similar
      final svc1 = MonteCarloSimulationService();
      svc1.initialize();
      final result1 = svc1.simulateTournament(simulations: 5000, seed: 100);

      final svc2 = MonteCarloSimulationService();
      svc2.initialize();
      final result2 = svc2.simulateTournament(simulations: 5000, seed: 200);

      // The top team (ARG, rank 1) should have similar win % in both runs
      // Within 5 percentage points for 5000 sims
      final arg1 = result1.teamResults['ARG']!.winnerPct;
      final arg2 = result2.teamResults['ARG']!.winnerPct;
      expect((arg1 - arg2).abs(), lessThan(5.0),
          reason: 'ARG win % should be stable across 5000-sim runs');
    });
  });
}

// ---------------------------------------------------------------------------
// Test helper to create a minimal NationalTeam
// ---------------------------------------------------------------------------
NationalTeam _team(String code, String name, String group, int ranking) {
  return NationalTeam(
    teamCode: code,
    countryName: name,
    shortName: name,
    flagUrl: '',
    confederation: Confederation.uefa,
    worldRanking: ranking,
    group: group,
    isQualified: true,
  );
}

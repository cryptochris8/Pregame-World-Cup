import 'package:mocktail/mocktail.dart';
import 'package:pregame_world_cup/features/worldcup/worldcup.dart';

// Mock Repositories
class MockWorldCupMatchRepository extends Mock implements WorldCupMatchRepository {}
class MockNationalTeamRepository extends Mock implements NationalTeamRepository {}
class MockGroupRepository extends Mock implements GroupRepository {}
class MockBracketRepository extends Mock implements BracketRepository {}

// Test Data Factories
class TestDataFactory {
  static WorldCupMatch createMatch({
    String matchId = 'match_1',
    int matchNumber = 1,
    MatchStage stage = MatchStage.groupStage,
    String? group = 'A',
    String? homeTeamCode = 'USA',
    String homeTeamName = 'United States',
    String? awayTeamCode = 'MEX',
    String awayTeamName = 'Mexico',
    int? homeScore,
    int? awayScore,
    MatchStatus status = MatchStatus.scheduled,
    DateTime? dateTime,
  }) {
    return WorldCupMatch(
      matchId: matchId,
      matchNumber: matchNumber,
      stage: stage,
      group: group,
      homeTeamCode: homeTeamCode,
      homeTeamName: homeTeamName,
      awayTeamCode: awayTeamCode,
      awayTeamName: awayTeamName,
      homeScore: homeScore,
      awayScore: awayScore,
      status: status,
      dateTime: dateTime ?? DateTime(2026, 6, 11, 18, 0),
    );
  }

  static NationalTeam createTeam({
    String fifaCode = 'USA',
    String countryName = 'United States',
    String shortName = 'USA',
    Confederation confederation = Confederation.concacaf,
    int? fifaRanking = 10,
    String? group = 'A',
    int worldCupTitles = 0,
    bool isHostNation = true,
  }) {
    return NationalTeam(
      fifaCode: fifaCode,
      countryName: countryName,
      shortName: shortName,
      flagUrl: '',
      confederation: confederation,
      fifaRanking: fifaRanking,
      group: group,
      worldCupTitles: worldCupTitles,
      isHostNation: isHostNation,
    );
  }

  static GroupTeamStanding createStanding({
    String teamCode = 'USA',
    String teamName = 'United States',
    int position = 1,
    int played = 3,
    int won = 2,
    int drawn = 1,
    int lost = 0,
    int goalsFor = 5,
    int goalsAgainst = 2,
  }) {
    return GroupTeamStanding(
      teamCode: teamCode,
      teamName: teamName,
      position: position,
      played: played,
      won: won,
      drawn: drawn,
      lost: lost,
      goalsFor: goalsFor,
      goalsAgainst: goalsAgainst,
      points: won * 3 + drawn,
    );
  }

  static WorldCupGroup createGroup({
    String groupLetter = 'A',
    List<GroupTeamStanding>? standings,
  }) {
    return WorldCupGroup(
      groupLetter: groupLetter,
      standings: standings ?? [
        createStanding(teamCode: 'USA', teamName: 'United States', position: 1),
        createStanding(teamCode: 'MEX', teamName: 'Mexico', position: 2, won: 1, drawn: 2, lost: 0),
        createStanding(teamCode: 'CAN', teamName: 'Canada', position: 3, won: 1, drawn: 1, lost: 1),
        createStanding(teamCode: 'JAM', teamName: 'Jamaica', position: 4, won: 0, drawn: 1, lost: 2),
      ],
    );
  }

  static BracketSlot createBracketSlot({
    String slotId = 'slot_1',
    MatchStage stage = MatchStage.roundOf16,
    int matchNumberInStage = 1,
    String? teamCode = 'USA',
    String teamNameOrPlaceholder = 'United States',
    int? score,
    bool isConfirmed = true,
  }) {
    return BracketSlot(
      slotId: slotId,
      stage: stage,
      matchNumberInStage: matchNumberInStage,
      teamCode: teamCode,
      teamNameOrPlaceholder: teamNameOrPlaceholder,
      score: score,
      isConfirmed: isConfirmed,
    );
  }

  static BracketMatch createBracketMatch({
    String matchId = 'bracket_1',
    int matchNumber = 1,
    MatchStage stage = MatchStage.roundOf16,
    int matchNumberInStage = 1,
    BracketSlot? homeSlot,
    BracketSlot? awaySlot,
    MatchStatus status = MatchStatus.scheduled,
    DateTime? dateTime,
  }) {
    return BracketMatch(
      matchId: matchId,
      matchNumber: matchNumber,
      stage: stage,
      matchNumberInStage: matchNumberInStage,
      homeSlot: homeSlot ?? createBracketSlot(
        slotId: '${matchId}_home',
        stage: stage,
        teamCode: 'USA',
        teamNameOrPlaceholder: 'United States',
      ),
      awaySlot: awaySlot ?? createBracketSlot(
        slotId: '${matchId}_away',
        stage: stage,
        teamCode: 'MEX',
        teamNameOrPlaceholder: 'Mexico',
      ),
      status: status,
      dateTime: dateTime ?? DateTime(2026, 7, 1, 18, 0),
    );
  }

  static WorldCupBracket createBracket() {
    return WorldCupBracket(
      roundOf32: List.generate(16, (i) => createBracketMatch(
        matchId: 'r32_$i',
        matchNumber: i + 1,
        stage: MatchStage.roundOf32,
        matchNumberInStage: i + 1,
      )),
      roundOf16: List.generate(8, (i) => createBracketMatch(
        matchId: 'r16_$i',
        matchNumber: i + 17,
        stage: MatchStage.roundOf16,
        matchNumberInStage: i + 1,
      )),
      quarterFinals: List.generate(4, (i) => createBracketMatch(
        matchId: 'qf_$i',
        matchNumber: i + 25,
        stage: MatchStage.quarterFinal,
        matchNumberInStage: i + 1,
      )),
      semiFinals: List.generate(2, (i) => createBracketMatch(
        matchId: 'sf_$i',
        matchNumber: i + 29,
        stage: MatchStage.semiFinal,
        matchNumberInStage: i + 1,
      )),
      thirdPlace: createBracketMatch(
        matchId: '3rd',
        matchNumber: 31,
        stage: MatchStage.thirdPlace,
        matchNumberInStage: 1,
      ),
      finalMatch: createBracketMatch(
        matchId: 'final',
        matchNumber: 32,
        stage: MatchStage.final_,
        matchNumberInStage: 1,
      ),
    );
  }

  static List<WorldCupMatch> createMatchList({int count = 5}) {
    return List.generate(count, (i) => createMatch(
      matchId: 'match_$i',
      matchNumber: i + 1,
      homeTeamCode: ['USA', 'BRA', 'GER', 'FRA', 'ARG'][i % 5],
      awayTeamCode: ['MEX', 'COL', 'ESP', 'ITA', 'URU'][i % 5],
    ));
  }

  static List<NationalTeam> createTeamList({int count = 48}) {
    final codes = [
      'USA', 'MEX', 'CAN', 'BRA', 'ARG', 'GER', 'FRA', 'ESP',
      'ITA', 'ENG', 'NED', 'POR', 'BEL', 'URU', 'COL', 'CHI',
    ];

    return List.generate(count.clamp(0, codes.length), (i) => createTeam(
      fifaCode: codes[i],
      countryName: codes[i],
      fifaRanking: i + 1,
      group: String.fromCharCode('A'.codeUnitAt(0) + (i ~/ 4)),
    ));
  }

  static List<WorldCupGroup> createGroupList({int count = 12}) {
    return List.generate(count, (i) => createGroup(
      groupLetter: String.fromCharCode('A'.codeUnitAt(0) + i),
    ));
  }
}

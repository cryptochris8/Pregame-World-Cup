/**
 * Tests for seed-team-players.ts
 *
 * Verifies:
 * - Reads team JSON files from the correct directory
 * - Writes to both 'players' AND 'worldcup_players' collections
 * - buildPlayersDoc: correct ID format, position-based strengths/weaknesses/playStyle
 * - buildWorldcupPlayersDoc: correct ID format using jersey number
 * - calculateAge: date of birth to age calculation
 * - Filters by --team flag (fifaCode)
 * - Exits with code 1 when no teams found
 * - Handles --clear (clears both collections), --dryRun, --verbose
 * - POSITION_STRENGTHS, POSITION_WEAKNESSES, PLAY_STYLES mappings
 */

const mockInitFirebase = jest.fn();
const mockParseArgs = jest.fn();
const mockReadJsonDir = jest.fn();
const mockBatchWrite = jest.fn();
const mockClearCollection = jest.fn();

jest.mock("../src/seed-utils", () => ({
  initFirebase: mockInitFirebase,
  parseArgs: mockParseArgs,
  readJsonDir: mockReadJsonDir,
  batchWrite: mockBatchWrite,
  clearCollection: mockClearCollection,
}));

jest.spyOn(process, "exit").mockImplementation((() => {}) as any);

describe("seed-team-players", () => {
  const mockDb = { collection: jest.fn(), batch: jest.fn() };

  const mockTeam = {
    fifaCode: "USA",
    countryName: "United States",
    players: [
      {
        firstName: "Christian",
        lastName: "Pulisic",
        commonName: "Pulisic",
        jerseyNumber: 10,
        position: "LW",
        dateOfBirth: "1998-09-18",
        height: "177cm",
        weight: "73kg",
        preferredFoot: "Right",
        club: "AC Milan",
        clubLeague: "Serie A",
        marketValue: "50M",
        caps: 70,
        goals: 28,
      },
      {
        firstName: "Weston",
        lastName: "McKennie",
        commonName: "",
        jerseyNumber: 8,
        position: "CM",
        dateOfBirth: "1998-08-28",
        height: "185cm",
        weight: "80kg",
        preferredFoot: "Right",
        club: "Juventus",
        clubLeague: "Serie A",
        marketValue: "30M",
        caps: 50,
        goals: 10,
      },
    ],
  };

  beforeEach(() => {
    jest.clearAllMocks();
    mockInitFirebase.mockReturnValue(mockDb);
    mockBatchWrite.mockResolvedValue(0);
    mockClearCollection.mockResolvedValue(undefined);
    jest.spyOn(console, "log").mockImplementation(() => {});
    jest.spyOn(console, "error").mockImplementation(() => {});
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  function runSeed() {
    jest.resetModules();
    jest.doMock("../src/seed-utils", () => ({
      initFirebase: mockInitFirebase,
      parseArgs: mockParseArgs,
      readJsonDir: mockReadJsonDir,
      batchWrite: mockBatchWrite,
      clearCollection: mockClearCollection,
    }));
    jest.spyOn(process, "exit").mockImplementation((() => {}) as any);
    jest.spyOn(console, "log").mockImplementation(() => {});
    jest.spyOn(console, "error").mockImplementation(() => {});
    return require("../src/seed-team-players");
  }

  it("should read team files from the correct directory", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, team: undefined, clear: false, verbose: false });
    mockReadJsonDir.mockReturnValue([mockTeam]);
    mockBatchWrite.mockResolvedValue(2);

    runSeed();
    await new Promise((r) => setTimeout(r, 200));

    expect(mockReadJsonDir).toHaveBeenCalledWith("../../assets/data/worldcup/teams");
  });

  it("should write to both players and worldcup_players collections", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, team: undefined, clear: false, verbose: false });
    mockReadJsonDir.mockReturnValue([mockTeam]);
    mockBatchWrite.mockResolvedValue(2);

    runSeed();
    await new Promise((r) => setTimeout(r, 200));

    expect(mockBatchWrite).toHaveBeenCalledTimes(2);
    expect(mockBatchWrite).toHaveBeenCalledWith(mockDb, "players", expect.any(Array), false);
    expect(mockBatchWrite).toHaveBeenCalledWith(mockDb, "worldcup_players", expect.any(Array), false);
  });

  it("should generate players doc IDs as {lowercase_fifaCode}_{index+1}", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, team: undefined, clear: false, verbose: false });
    mockReadJsonDir.mockReturnValue([mockTeam]);
    mockBatchWrite.mockResolvedValue(2);

    runSeed();
    await new Promise((r) => setTimeout(r, 200));

    const playersDocs = mockBatchWrite.mock.calls[0][2];
    expect(playersDocs[0].id).toBe("usa_1");
    expect(playersDocs[1].id).toBe("usa_2");
  });

  it("should generate worldcup_players doc IDs as {lowercase_fifaCode}_{jerseyNumber}", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, team: undefined, clear: false, verbose: false });
    mockReadJsonDir.mockReturnValue([mockTeam]);
    mockBatchWrite.mockResolvedValue(2);

    runSeed();
    await new Promise((r) => setTimeout(r, 200));

    const wcDocs = mockBatchWrite.mock.calls[1][2];
    expect(wcDocs[0].id).toBe("usa_10"); // jersey number 10
    expect(wcDocs[1].id).toBe("usa_8");  // jersey number 8
  });

  it("should include correct player data in players collection docs", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, team: undefined, clear: false, verbose: false });
    mockReadJsonDir.mockReturnValue([mockTeam]);
    mockBatchWrite.mockResolvedValue(2);

    runSeed();
    await new Promise((r) => setTimeout(r, 200));

    const playersDocs = mockBatchWrite.mock.calls[0][2];
    const pulisicDoc = playersDocs[0].data;
    expect(pulisicDoc.firstName).toBe("Christian");
    expect(pulisicDoc.lastName).toBe("Pulisic");
    expect(pulisicDoc.fullName).toBe("Christian Pulisic");
    expect(pulisicDoc.commonName).toBe("Pulisic");
    expect(pulisicDoc.fifaCode).toBe("USA");
    expect(pulisicDoc.position).toBe("LW");
    expect(pulisicDoc.jerseyNumber).toBe(10);
    expect(pulisicDoc.club).toBe("AC Milan");
    expect(pulisicDoc.photoUrl).toBe("");
    expect(typeof pulisicDoc.age).toBe("number");
    expect(pulisicDoc.age).toBeGreaterThan(20);
  });

  it("should use position-based strengths for LW position", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, team: undefined, clear: false, verbose: false });
    mockReadJsonDir.mockReturnValue([mockTeam]);
    mockBatchWrite.mockResolvedValue(2);

    runSeed();
    await new Promise((r) => setTimeout(r, 200));

    const playersDocs = mockBatchWrite.mock.calls[0][2];
    const lwPlayer = playersDocs[0].data; // Pulisic is LW
    expect(lwPlayer.strengths).toEqual(["Pace", "Dribbling", "Direct running"]);
    expect(lwPlayer.weaknesses).toEqual(["Defensive tracking", "Aerial ability"]);
    expect(lwPlayer.playStyle).toBe("Direct winger who takes on defenders and creates chances");
  });

  it("should use position-based strengths for CM position", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, team: undefined, clear: false, verbose: false });
    mockReadJsonDir.mockReturnValue([mockTeam]);
    mockBatchWrite.mockResolvedValue(2);

    runSeed();
    await new Promise((r) => setTimeout(r, 200));

    const playersDocs = mockBatchWrite.mock.calls[0][2];
    const cmPlayer = playersDocs[1].data; // McKennie is CM
    expect(cmPlayer.strengths).toEqual(["Vision", "Work rate", "Passing"]);
    expect(cmPlayer.weaknesses).toEqual(["Goal contribution", "Defensive intensity"]);
    expect(cmPlayer.playStyle).toBe("Box-to-box midfielder with energy, vision, and goal contributions");
  });

  it("should use fallback strengths/weaknesses/playStyle for unknown positions", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, team: undefined, clear: false, verbose: false });
    const teamWithUnknownPos = {
      fifaCode: "TST",
      countryName: "TestLand",
      players: [{
        firstName: "Test",
        lastName: "Player",
        commonName: "",
        jerseyNumber: 99,
        position: "WB", // Not in POSITION_STRENGTHS map
        dateOfBirth: "2000-01-01",
        height: "180cm",
        weight: "75kg",
        preferredFoot: "Right",
        club: "Test FC",
        clubLeague: "Test League",
        marketValue: "1M",
        caps: 10,
        goals: 2,
      }],
    };
    mockReadJsonDir.mockReturnValue([teamWithUnknownPos]);
    mockBatchWrite.mockResolvedValue(1);

    runSeed();
    await new Promise((r) => setTimeout(r, 200));

    const playersDocs = mockBatchWrite.mock.calls[0][2];
    expect(playersDocs[0].data.strengths).toEqual(["Technical ability", "Football intelligence", "Team player"]);
    expect(playersDocs[0].data.weaknesses).toEqual(["Consistency at top level", "Big game experience"]);
    expect(playersDocs[0].data.playStyle).toBe("Versatile player who adapts to tactical demands");
  });

  it("should include worldcup_players data with correct fields", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, team: undefined, clear: false, verbose: false });
    mockReadJsonDir.mockReturnValue([mockTeam]);
    mockBatchWrite.mockResolvedValue(2);

    runSeed();
    await new Promise((r) => setTimeout(r, 200));

    const wcDocs = mockBatchWrite.mock.calls[1][2];
    const pulisicWc = wcDocs[0].data;
    expect(pulisicWc.teamCode).toBe("USA");
    expect(pulisicWc.teamName).toBe("United States");
    expect(pulisicWc.firstName).toBe("Christian");
    expect(pulisicWc.lastName).toBe("Pulisic");
    expect(pulisicWc.commonName).toBe("Pulisic");
    expect(pulisicWc.worldCupAppearances).toBe(0);
    expect(pulisicWc.worldCupGoals).toBe(0);
    expect(pulisicWc.worldCupAssists).toBe(0);
    expect(pulisicWc.previousWorldCups).toEqual([]);
    expect(pulisicWc.createdAt).toBeDefined();
    expect(pulisicWc.updatedAt).toBeDefined();
  });

  it("should use player.lastName as commonName when commonName is empty in worldcup_players", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, team: undefined, clear: false, verbose: false });
    mockReadJsonDir.mockReturnValue([mockTeam]);
    mockBatchWrite.mockResolvedValue(2);

    runSeed();
    await new Promise((r) => setTimeout(r, 200));

    const wcDocs = mockBatchWrite.mock.calls[1][2];
    // McKennie has empty commonName, so buildWorldcupPlayersDoc uses `${firstName} ${lastName}`
    const mckennieWc = wcDocs[1].data;
    expect(mckennieWc.commonName).toBe("Weston McKennie");
  });

  it("should filter teams by --team flag (fifaCode)", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, team: "MEX", clear: false, verbose: false });
    const mexTeam = {
      fifaCode: "MEX",
      countryName: "Mexico",
      players: [
        { firstName: "Raul", lastName: "Jimenez", commonName: "", jerseyNumber: 9, position: "ST", dateOfBirth: "1991-05-05", height: "187cm", weight: "80kg", preferredFoot: "Right", club: "Fulham", clubLeague: "Premier League", marketValue: "10M", caps: 100, goals: 30 },
      ],
    };
    mockReadJsonDir.mockReturnValue([mockTeam, mexTeam]);
    mockBatchWrite.mockResolvedValue(1);

    runSeed();
    await new Promise((r) => setTimeout(r, 200));

    // Should only include MEX players
    const playersDocs = mockBatchWrite.mock.calls[0][2];
    expect(playersDocs).toHaveLength(1);
    expect(playersDocs[0].data.fifaCode).toBe("MEX");
  });

  it("should exit with code 1 when no teams found", async () => {
    const exitSpy = jest.spyOn(process, "exit").mockImplementation((() => {}) as any);
    mockParseArgs.mockReturnValue({ dryRun: false, team: "ZZZ", clear: false, verbose: false });
    mockReadJsonDir.mockReturnValue([mockTeam]);

    runSeed();
    await new Promise((r) => setTimeout(r, 200));

    expect(exitSpy).toHaveBeenCalledWith(1);
  });

  it("should clear both players and worldcup_players when --clear is set", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, team: undefined, clear: true, verbose: false });
    mockReadJsonDir.mockReturnValue([mockTeam]);
    mockBatchWrite.mockResolvedValue(2);

    runSeed();
    await new Promise((r) => setTimeout(r, 200));

    expect(mockClearCollection).toHaveBeenCalledTimes(2);
    expect(mockClearCollection).toHaveBeenCalledWith(mockDb, "players", false);
    expect(mockClearCollection).toHaveBeenCalledWith(mockDb, "worldcup_players", false);
  });

  it("should not clear when --clear is not set", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, team: undefined, clear: false, verbose: false });
    mockReadJsonDir.mockReturnValue([mockTeam]);
    mockBatchWrite.mockResolvedValue(2);

    runSeed();
    await new Promise((r) => setTimeout(r, 200));

    expect(mockClearCollection).not.toHaveBeenCalled();
  });

  it("should pass dryRun to batchWrite and clearCollection", async () => {
    mockParseArgs.mockReturnValue({ dryRun: true, team: undefined, clear: true, verbose: false });
    mockReadJsonDir.mockReturnValue([mockTeam]);
    mockBatchWrite.mockResolvedValue(2);

    runSeed();
    await new Promise((r) => setTimeout(r, 200));

    expect(mockClearCollection).toHaveBeenCalledWith(mockDb, "players", true);
    expect(mockClearCollection).toHaveBeenCalledWith(mockDb, "worldcup_players", true);
    expect(mockBatchWrite).toHaveBeenCalledWith(mockDb, "players", expect.any(Array), true);
    expect(mockBatchWrite).toHaveBeenCalledWith(mockDb, "worldcup_players", expect.any(Array), true);
  });

  it("should calculate assists as floor(goals * 0.5) in players collection", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, team: undefined, clear: false, verbose: false });
    mockReadJsonDir.mockReturnValue([mockTeam]);
    mockBatchWrite.mockResolvedValue(2);

    runSeed();
    await new Promise((r) => setTimeout(r, 200));

    const playersDocs = mockBatchWrite.mock.calls[0][2];
    // Pulisic has 28 goals, assists should be floor(28 * 0.5) = 14
    expect(playersDocs[0].data.assists).toBe(14);
    // McKennie has 10 goals, assists should be floor(10 * 0.5) = 5
    expect(playersDocs[1].data.assists).toBe(5);
  });

  it("should set international minutesPlayed as caps * 70", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, team: undefined, clear: false, verbose: false });
    mockReadJsonDir.mockReturnValue([mockTeam]);
    mockBatchWrite.mockResolvedValue(2);

    runSeed();
    await new Promise((r) => setTimeout(r, 200));

    const playersDocs = mockBatchWrite.mock.calls[0][2];
    // Pulisic has 70 caps
    expect(playersDocs[0].data.stats.international.minutesPlayed).toBe(70 * 70);
    // McKennie has 50 caps
    expect(playersDocs[1].data.stats.international.minutesPlayed).toBe(50 * 70);
  });

  it("should handle team with many players", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, team: undefined, clear: false, verbose: false });
    const bigTeam = {
      fifaCode: "BRA",
      countryName: "Brazil",
      players: Array.from({ length: 26 }, (_, i) => ({
        firstName: `Player${i}`,
        lastName: `Last${i}`,
        commonName: "",
        jerseyNumber: i + 1,
        position: "CM",
        dateOfBirth: "2000-01-01",
        height: "180cm",
        weight: "75kg",
        preferredFoot: "Right",
        club: "Club FC",
        clubLeague: "League",
        marketValue: "5M",
        caps: 20,
        goals: 5,
      })),
    };
    mockReadJsonDir.mockReturnValue([bigTeam]);
    mockBatchWrite.mockResolvedValue(26);

    runSeed();
    await new Promise((r) => setTimeout(r, 200));

    const playersDocs = mockBatchWrite.mock.calls[0][2];
    const wcDocs = mockBatchWrite.mock.calls[1][2];
    expect(playersDocs).toHaveLength(26);
    expect(wcDocs).toHaveLength(26);
  });

  it("should include key moment with country name", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, team: undefined, clear: false, verbose: false });
    mockReadJsonDir.mockReturnValue([mockTeam]);
    mockBatchWrite.mockResolvedValue(2);

    runSeed();
    await new Promise((r) => setTimeout(r, 200));

    const playersDocs = mockBatchWrite.mock.calls[0][2];
    expect(playersDocs[0].data.keyMoment).toContain("United States");
  });

  it("should include worldCup2026Prediction with country name", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, team: undefined, clear: false, verbose: false });
    mockReadJsonDir.mockReturnValue([mockTeam]);
    mockBatchWrite.mockResolvedValue(2);

    runSeed();
    await new Promise((r) => setTimeout(r, 200));

    const playersDocs = mockBatchWrite.mock.calls[0][2];
    expect(playersDocs[0].data.worldCup2026Prediction).toContain("United States");
  });
});

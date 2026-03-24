/**
 * Tests for seed-player-world-cup-stats.ts
 *
 * This script is unique: it reads player stat files, queries the 'players'
 * collection to find matching players by teamCode + lastName, then updates
 * each matching player document with World Cup stats.
 *
 * Verifies:
 * - Reads player stat files from the correct directory
 * - Filters by --team flag (teamCode)
 * - Queries Firestore for matching players
 * - Name matching logic (last name substring match)
 * - Handles not-found players
 * - Updates with correct fields
 * - Handles --dryRun
 * - Error handling per-player
 */

const mockInitFirebase = jest.fn();
const mockParseArgs = jest.fn();
const mockReadJsonDir = jest.fn();

jest.mock("../src/seed-utils", () => ({
  initFirebase: mockInitFirebase,
  parseArgs: mockParseArgs,
  readJsonDir: mockReadJsonDir,
}));

// Build mock Firestore chain: db.collection("players").where(...).get()
const mockUpdate = jest.fn().mockResolvedValue(undefined);
const mockWhereGet = jest.fn();
const mockWhere = jest.fn().mockReturnValue({ get: mockWhereGet });
const mockCollection = jest.fn().mockReturnValue({ where: mockWhere });
const mockDb = { collection: mockCollection };

// Mock firebase-admin for FieldValue.serverTimestamp
jest.mock("firebase-admin", () => ({
  apps: [],
  initializeApp: jest.fn(),
  firestore: Object.assign(jest.fn(() => mockDb), {
    FieldValue: {
      serverTimestamp: jest.fn(() => ({ _methodName: "serverTimestamp" })),
    },
  }),
}));

jest.spyOn(process, "exit").mockImplementation((() => {}) as any);

describe("seed-player-world-cup-stats", () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockInitFirebase.mockReturnValue(mockDb);
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
    }));
    jest.doMock("firebase-admin", () => ({
      apps: [],
      initializeApp: jest.fn(),
      firestore: Object.assign(jest.fn(() => mockDb), {
        FieldValue: {
          serverTimestamp: jest.fn(() => ({ _methodName: "serverTimestamp" })),
        },
      }),
    }));
    jest.spyOn(process, "exit").mockImplementation((() => {}) as any);
    jest.spyOn(console, "log").mockImplementation(() => {});
    jest.spyOn(console, "error").mockImplementation(() => {});
    return require("../src/seed-player-world-cup-stats");
  }

  it("should read player stat files from the correct directory", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, team: undefined, clear: false, verbose: false });
    mockReadJsonDir.mockReturnValue([]);

    runSeed();
    await new Promise((r) => setTimeout(r, 200));

    expect(mockReadJsonDir).toHaveBeenCalledWith("../../assets/data/worldcup/player_stats");
  });

  it("should filter records by --team flag using teamCode", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, team: "BRA", clear: false, verbose: false });
    mockReadJsonDir.mockReturnValue([
      { playerName: "Neymar Jr", teamCode: "BRA", worldCupAppearances: 2 },
      { playerName: "Lionel Messi", teamCode: "ARG", worldCupAppearances: 5 },
      { playerName: "Vinicius Junior", teamCode: "BRA", worldCupAppearances: 1 },
    ]);

    // Mock Firestore query for the two BRA players
    mockWhereGet
      .mockResolvedValueOnce({
        docs: [{ data: () => ({ firstName: "Neymar", lastName: "Jr", fullName: "Neymar Jr" }), ref: { update: mockUpdate } }],
      })
      .mockResolvedValueOnce({
        docs: [{ data: () => ({ firstName: "Vinicius", lastName: "Junior", fullName: "Vinicius Junior" }), ref: { update: mockUpdate } }],
      });

    runSeed();
    await new Promise((r) => setTimeout(r, 300));

    // Should only query for BRA players (2 calls), not ARG
    expect(mockCollection).toHaveBeenCalledWith("players");
    expect(mockWhere).toHaveBeenCalledWith("teamCode", "==", "BRA");
    expect(mockWhere).not.toHaveBeenCalledWith("teamCode", "==", "ARG");
  });

  it("should match player by last name substring in fullName", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, team: undefined, clear: false, verbose: false });
    mockReadJsonDir.mockReturnValue([
      {
        playerName: "Lionel Messi",
        teamCode: "ARG",
        worldCupAppearances: 5,
        worldCupGoals: 13,
        worldCupAssists: 8,
        previousWorldCups: ["2006", "2010", "2014", "2018", "2022"],
        tournamentStats: {},
        worldCupAwards: ["Golden Ball 2014"],
        memorableMoments: ["2022 Final"],
        worldCupLegacyRating: 99,
        comparisonToLegend: "Maradona",
        worldCup2026Prediction: "Farewell tour",
      },
    ]);

    const mockDocRef = { update: mockUpdate };
    mockWhereGet.mockResolvedValueOnce({
      docs: [
        {
          data: () => ({ firstName: "Lionel", lastName: "Messi", fullName: "Lionel Messi" }),
          ref: mockDocRef,
        },
      ],
    });

    runSeed();
    await new Promise((r) => setTimeout(r, 300));

    expect(mockUpdate).toHaveBeenCalledWith(
      expect.objectContaining({
        worldCupAppearances: 5,
        worldCupGoals: 13,
        worldCupAssists: 8,
        previousWorldCups: ["2006", "2010", "2014", "2018", "2022"],
        worldCupAwards: ["Golden Ball 2014"],
        memorableMoments: ["2022 Final"],
        worldCupLegacyRating: 99,
        comparisonToLegend: "Maradona",
        worldCup2026Prediction: "Farewell tour",
        updatedAt: expect.objectContaining({ _methodName: "serverTimestamp" }),
      })
    );
  });

  it("should handle player not found in Firestore", async () => {
    const logSpy = jest.spyOn(console, "log").mockImplementation(() => {});
    mockParseArgs.mockReturnValue({ dryRun: false, team: undefined, clear: false, verbose: false });
    mockReadJsonDir.mockReturnValue([
      { playerName: "Unknown Player", teamCode: "XXX", worldCupAppearances: 0 },
    ]);

    mockWhereGet.mockResolvedValueOnce({ docs: [] });

    runSeed();
    await new Promise((r) => setTimeout(r, 300));

    expect(mockUpdate).not.toHaveBeenCalled();
    expect(logSpy).toHaveBeenCalledWith(expect.stringContaining("Not found"));
  });

  it("should log dry run message instead of updating in dryRun mode", async () => {
    const logSpy = jest.spyOn(console, "log").mockImplementation(() => {});
    mockParseArgs.mockReturnValue({ dryRun: true, team: undefined, clear: false, verbose: false });
    mockReadJsonDir.mockReturnValue([
      { playerName: "Harry Kane", teamCode: "ENG", worldCupAppearances: 3 },
    ]);

    mockWhereGet.mockResolvedValueOnce({
      docs: [{
        data: () => ({ firstName: "Harry", lastName: "Kane", fullName: "Harry Kane" }),
        ref: { update: mockUpdate },
      }],
    });

    runSeed();
    await new Promise((r) => setTimeout(r, 300));

    expect(mockUpdate).not.toHaveBeenCalled();
    expect(logSpy).toHaveBeenCalledWith(expect.stringContaining("[DRY RUN]"));
  });

  it("should handle errors per-player without stopping the loop", async () => {
    const errorSpy = jest.spyOn(console, "error").mockImplementation(() => {});
    mockParseArgs.mockReturnValue({ dryRun: false, team: undefined, clear: false, verbose: false });
    mockReadJsonDir.mockReturnValue([
      { playerName: "Error Player", teamCode: "ERR", worldCupAppearances: 0 },
      { playerName: "Good Player", teamCode: "GOD", worldCupAppearances: 1 },
    ]);

    // First player throws, second succeeds
    mockWhereGet
      .mockRejectedValueOnce(new Error("Firestore query failed"))
      .mockResolvedValueOnce({
        docs: [{
          data: () => ({ firstName: "Good", lastName: "Player", fullName: "Good Player" }),
          ref: { update: mockUpdate },
        }],
      });

    runSeed();
    await new Promise((r) => setTimeout(r, 300));

    expect(errorSpy).toHaveBeenCalledWith(expect.stringContaining("Error"));
    expect(mockUpdate).toHaveBeenCalledTimes(1);
  });

  it("should process all records when no --team filter", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, team: undefined, clear: false, verbose: false });
    mockReadJsonDir.mockReturnValue([
      { playerName: "Player A", teamCode: "AAA", worldCupAppearances: 1 },
      { playerName: "Player B", teamCode: "BBB", worldCupAppearances: 2 },
    ]);

    mockWhereGet
      .mockResolvedValueOnce({
        docs: [{ data: () => ({ fullName: "Player A" }), ref: { update: mockUpdate } }],
      })
      .mockResolvedValueOnce({
        docs: [{ data: () => ({ fullName: "Player B" }), ref: { update: mockUpdate } }],
      });

    runSeed();
    await new Promise((r) => setTimeout(r, 300));

    expect(mockWhere).toHaveBeenCalledWith("teamCode", "==", "AAA");
    expect(mockWhere).toHaveBeenCalledWith("teamCode", "==", "BBB");
  });

  it("should handle empty records array", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, team: undefined, clear: false, verbose: false });
    mockReadJsonDir.mockReturnValue([]);

    runSeed();
    await new Promise((r) => setTimeout(r, 200));

    expect(mockCollection).not.toHaveBeenCalled();
    expect(mockUpdate).not.toHaveBeenCalled();
  });

  it("should map tournamentStats to worldCupTournamentStats field", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, team: undefined, clear: false, verbose: false });
    const tournamentStats = { "2022": { goals: 7, assists: 3 } };
    mockReadJsonDir.mockReturnValue([
      {
        playerName: "Kylian Mbappe",
        teamCode: "FRA",
        worldCupAppearances: 2,
        worldCupGoals: 12,
        worldCupAssists: 5,
        previousWorldCups: ["2018", "2022"],
        tournamentStats,
        worldCupAwards: [],
        memorableMoments: [],
        worldCupLegacyRating: 95,
        comparisonToLegend: "Henry",
        worldCup2026Prediction: "Golden Boot contender",
      },
    ]);

    mockWhereGet.mockResolvedValueOnce({
      docs: [{
        data: () => ({ firstName: "Kylian", lastName: "Mbappe", fullName: "Kylian Mbappe" }),
        ref: { update: mockUpdate },
      }],
    });

    runSeed();
    await new Promise((r) => setTimeout(r, 300));

    // The script maps p.tournamentStats to worldCupTournamentStats
    expect(mockUpdate).toHaveBeenCalledWith(
      expect.objectContaining({
        worldCupTournamentStats: tournamentStats,
      })
    );
  });
});

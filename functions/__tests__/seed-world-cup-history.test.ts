/**
 * Tests for seed-world-cup-history.ts
 *
 * Verifies:
 * - Reads tournaments.json and records.json from the correct paths
 * - Tournament doc IDs are formatted as "wc_{year}"
 * - Record doc IDs are derived from category (lowercased, non-alphanumeric replaced with _)
 * - Writes to 'worldCupHistory' and 'worldCupRecords' collections
 * - Handles --clear (clears both collections)
 * - Handles --dryRun
 */

const mockInitFirebase = jest.fn();
const mockParseArgs = jest.fn();
const mockReadJsonFile = jest.fn();
const mockBatchWrite = jest.fn();
const mockClearCollection = jest.fn();

jest.mock("../src/seed-utils", () => ({
  initFirebase: mockInitFirebase,
  parseArgs: mockParseArgs,
  readJsonFile: mockReadJsonFile,
  batchWrite: mockBatchWrite,
  clearCollection: mockClearCollection,
}));

jest.spyOn(process, "exit").mockImplementation((() => {}) as any);

describe("seed-world-cup-history", () => {
  const mockDb = { collection: jest.fn(), batch: jest.fn() };

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
      readJsonFile: mockReadJsonFile,
      batchWrite: mockBatchWrite,
      clearCollection: mockClearCollection,
    }));
    jest.spyOn(process, "exit").mockImplementation((() => {}) as any);
    jest.spyOn(console, "log").mockImplementation(() => {});
    jest.spyOn(console, "error").mockImplementation(() => {});
    return require("../src/seed-world-cup-history");
  }

  it("should read tournaments and records from the correct JSON files", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: false, verbose: false });
    mockReadJsonFile
      .mockReturnValueOnce([{ year: 2022, host: "Qatar", winner: "Argentina" }])
      .mockReturnValueOnce([{ category: "Most Goals", holder: "Miroslav Klose" }]);
    mockBatchWrite.mockResolvedValue(1);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    expect(mockReadJsonFile).toHaveBeenCalledWith("../../assets/data/worldcup/history/tournaments.json");
    expect(mockReadJsonFile).toHaveBeenCalledWith("../../assets/data/worldcup/history/records.json");
  });

  it("should write tournaments to worldCupHistory collection", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: false, verbose: false });
    mockReadJsonFile
      .mockReturnValueOnce([{ year: 2022, host: "Qatar" }])
      .mockReturnValueOnce([]);
    mockBatchWrite.mockResolvedValue(1);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    expect(mockBatchWrite).toHaveBeenCalledWith(
      mockDb,
      "worldCupHistory",
      expect.any(Array),
      false
    );
  });

  it("should write records to worldCupRecords collection", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: false, verbose: false });
    mockReadJsonFile
      .mockReturnValueOnce([])
      .mockReturnValueOnce([{ category: "Most Goals", holder: "Klose" }]);
    mockBatchWrite.mockResolvedValue(1);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    expect(mockBatchWrite).toHaveBeenCalledWith(
      mockDb,
      "worldCupRecords",
      expect.any(Array),
      false
    );
  });

  it("should generate tournament doc IDs as wc_{year}", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: false, verbose: false });
    mockReadJsonFile
      .mockReturnValueOnce([
        { year: 1930, host: "Uruguay", winner: "Uruguay" },
        { year: 1950, host: "Brazil", winner: "Uruguay" },
        { year: 2022, host: "Qatar", winner: "Argentina" },
      ])
      .mockReturnValueOnce([]);
    mockBatchWrite.mockResolvedValue(3);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    const tournamentDocs = mockBatchWrite.mock.calls[0][2];
    expect(tournamentDocs[0].id).toBe("wc_1930");
    expect(tournamentDocs[1].id).toBe("wc_1950");
    expect(tournamentDocs[2].id).toBe("wc_2022");
  });

  it("should include id in tournament document data", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: false, verbose: false });
    mockReadJsonFile
      .mockReturnValueOnce([{ year: 2018, host: "Russia", winner: "France" }])
      .mockReturnValueOnce([]);
    mockBatchWrite.mockResolvedValue(1);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    const tournamentDocs = mockBatchWrite.mock.calls[0][2];
    expect(tournamentDocs[0].data.id).toBe("wc_2018");
    expect(tournamentDocs[0].data.year).toBe(2018);
    expect(tournamentDocs[0].data.host).toBe("Russia");
    expect(tournamentDocs[0].data.winner).toBe("France");
  });

  it("should generate record doc IDs from category (lowercase, non-alphanumeric -> _)", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: false, verbose: false });
    mockReadJsonFile
      .mockReturnValueOnce([])
      .mockReturnValueOnce([
        { category: "Most Goals", holder: "Miroslav Klose", count: 16 },
        { category: "Most Appearances", holder: "Lothar Matthaus", count: 25 },
        { category: "Best Goal-Scorer (Single)", holder: "Just Fontaine", count: 13 },
      ]);
    mockBatchWrite.mockResolvedValue(3);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    const recordDocs = mockBatchWrite.mock.calls[1][2];
    expect(recordDocs[0].id).toBe("most_goals");
    expect(recordDocs[1].id).toBe("most_appearances");
    expect(recordDocs[2].id).toBe("best_goal_scorer__single_");
  });

  it("should include id in record document data", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: false, verbose: false });
    mockReadJsonFile
      .mockReturnValueOnce([])
      .mockReturnValueOnce([{ category: "Most Goals", holder: "Klose", count: 16 }]);
    mockBatchWrite.mockResolvedValue(1);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    const recordDocs = mockBatchWrite.mock.calls[1][2];
    expect(recordDocs[0].data.id).toBe("most_goals");
    expect(recordDocs[0].data.category).toBe("Most Goals");
    expect(recordDocs[0].data.holder).toBe("Klose");
    expect(recordDocs[0].data.count).toBe(16);
  });

  it("should clear both collections when --clear is set", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: true, verbose: false });
    mockReadJsonFile
      .mockReturnValueOnce([])
      .mockReturnValueOnce([]);
    mockBatchWrite.mockResolvedValue(0);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    expect(mockClearCollection).toHaveBeenCalledTimes(2);
    expect(mockClearCollection).toHaveBeenCalledWith(mockDb, "worldCupHistory", false);
    expect(mockClearCollection).toHaveBeenCalledWith(mockDb, "worldCupRecords", false);
  });

  it("should not clear collections when --clear is not set", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: false, verbose: false });
    mockReadJsonFile
      .mockReturnValueOnce([])
      .mockReturnValueOnce([]);
    mockBatchWrite.mockResolvedValue(0);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    expect(mockClearCollection).not.toHaveBeenCalled();
  });

  it("should pass dryRun to all operations", async () => {
    mockParseArgs.mockReturnValue({ dryRun: true, clear: true, verbose: false });
    mockReadJsonFile
      .mockReturnValueOnce([{ year: 2022, host: "Qatar" }])
      .mockReturnValueOnce([{ category: "Test", holder: "Test" }]);
    mockBatchWrite.mockResolvedValue(1);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    expect(mockClearCollection).toHaveBeenCalledWith(mockDb, "worldCupHistory", true);
    expect(mockClearCollection).toHaveBeenCalledWith(mockDb, "worldCupRecords", true);
    expect(mockBatchWrite).toHaveBeenCalledWith(mockDb, "worldCupHistory", expect.any(Array), true);
    expect(mockBatchWrite).toHaveBeenCalledWith(mockDb, "worldCupRecords", expect.any(Array), true);
  });

  it("should handle empty tournaments and records arrays", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: false, verbose: false });
    mockReadJsonFile
      .mockReturnValueOnce([])
      .mockReturnValueOnce([]);
    mockBatchWrite.mockResolvedValue(0);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    expect(mockBatchWrite).toHaveBeenCalledWith(mockDb, "worldCupHistory", [], false);
    expect(mockBatchWrite).toHaveBeenCalledWith(mockDb, "worldCupRecords", [], false);
  });

  it("should handle all 22 World Cup tournaments", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: false, verbose: false });
    const tournaments = Array.from({ length: 22 }, (_, i) => ({
      year: 1930 + i * 4,
      host: `Host ${i}`,
      winner: `Winner ${i}`,
    }));
    mockReadJsonFile
      .mockReturnValueOnce(tournaments)
      .mockReturnValueOnce([]);
    mockBatchWrite.mockResolvedValue(22);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    const tournamentDocs = mockBatchWrite.mock.calls[0][2];
    expect(tournamentDocs).toHaveLength(22);
    expect(tournamentDocs[0].id).toBe("wc_1930");
    expect(tournamentDocs[21].id).toBe("wc_2014");
  });

  it("should preserve all original tournament data in the document", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: false, verbose: false });
    const tournament = {
      year: 2022,
      host: "Qatar",
      winner: "Argentina",
      runnerUp: "France",
      thirdPlace: "Croatia",
      topScorer: "Mbappe",
      goldenBall: "Messi",
      totalGoals: 172,
      matchesPlayed: 64,
    };
    mockReadJsonFile
      .mockReturnValueOnce([tournament])
      .mockReturnValueOnce([]);
    mockBatchWrite.mockResolvedValue(1);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    const docs = mockBatchWrite.mock.calls[0][2];
    expect(docs[0].data.host).toBe("Qatar");
    expect(docs[0].data.winner).toBe("Argentina");
    expect(docs[0].data.runnerUp).toBe("France");
    expect(docs[0].data.topScorer).toBe("Mbappe");
    expect(docs[0].data.totalGoals).toBe(172);
  });
});

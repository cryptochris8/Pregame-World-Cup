/**
 * Tests for seed-head-to-head.ts
 *
 * Verifies:
 * - Reads H2H JSON files from the correct directory
 * - Generates sorted team code IDs (e.g., ARG_BRA, not BRA_ARG)
 * - Writes to 'headToHead' collection
 * - Handles --clear flag
 * - Handles --dryRun flag
 */

// ---- Mocks must be set up before imports ----

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

// Mock process.exit to prevent test runner from exiting
const mockExit = jest.spyOn(process, "exit").mockImplementation((() => {}) as any);

describe("seed-head-to-head", () => {
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
    // Clear module cache so each test gets a fresh import (re-triggers main())
    jest.resetModules();
    // Re-apply mocks after resetModules
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
    return require("../src/seed-head-to-head");
  }

  it("should read H2H records and write to headToHead collection", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: false, verbose: false });
    mockReadJsonDir.mockReturnValue([
      { team1Code: "USA", team2Code: "MEX", totalMatches: 10 },
      { team1Code: "BRA", team2Code: "ARG", totalMatches: 20 },
    ]);
    mockBatchWrite.mockResolvedValue(2);

    runSeed();
    // Allow async main() to complete
    await new Promise((r) => setTimeout(r, 100));

    expect(mockInitFirebase).toHaveBeenCalled();
    expect(mockReadJsonDir).toHaveBeenCalledWith("../../assets/data/worldcup/head_to_head");
    expect(mockBatchWrite).toHaveBeenCalledWith(
      mockDb,
      "headToHead",
      expect.any(Array),
      false
    );
  });

  it("should generate sorted document IDs from team codes", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: false, verbose: false });
    mockReadJsonDir.mockReturnValue([
      { team1Code: "USA", team2Code: "MEX" },
      { team1Code: "GER", team2Code: "BRA" },
      { team1Code: "ARG", team2Code: "FRA" },
    ]);
    mockBatchWrite.mockResolvedValue(3);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    const docs = mockBatchWrite.mock.calls[0][2];
    // IDs should be alphabetically sorted
    expect(docs[0].id).toBe("MEX_USA");
    expect(docs[1].id).toBe("BRA_GER");
    expect(docs[2].id).toBe("ARG_FRA");
  });

  it("should include the sorted id in the document data", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: false, verbose: false });
    mockReadJsonDir.mockReturnValue([
      { team1Code: "USA", team2Code: "CAN", totalMatches: 5 },
    ]);
    mockBatchWrite.mockResolvedValue(1);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    const docs = mockBatchWrite.mock.calls[0][2];
    expect(docs[0].id).toBe("CAN_USA");
    expect(docs[0].data.id).toBe("CAN_USA");
    expect(docs[0].data.team1Code).toBe("USA");
    expect(docs[0].data.team2Code).toBe("CAN");
    expect(docs[0].data.totalMatches).toBe(5);
  });

  it("should clear collection when --clear flag is set", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: true, verbose: false });
    mockReadJsonDir.mockReturnValue([]);
    mockBatchWrite.mockResolvedValue(0);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    expect(mockClearCollection).toHaveBeenCalledWith(mockDb, "headToHead", false);
  });

  it("should not clear collection when --clear flag is not set", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: false, verbose: false });
    mockReadJsonDir.mockReturnValue([]);
    mockBatchWrite.mockResolvedValue(0);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    expect(mockClearCollection).not.toHaveBeenCalled();
  });

  it("should pass dryRun flag to batchWrite and clearCollection", async () => {
    mockParseArgs.mockReturnValue({ dryRun: true, clear: true, verbose: false });
    mockReadJsonDir.mockReturnValue([
      { team1Code: "JPN", team2Code: "KOR" },
    ]);
    mockBatchWrite.mockResolvedValue(1);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    expect(mockClearCollection).toHaveBeenCalledWith(mockDb, "headToHead", true);
    expect(mockBatchWrite).toHaveBeenCalledWith(
      mockDb,
      "headToHead",
      expect.any(Array),
      true
    );
  });

  it("should handle empty directory with no records", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: false, verbose: false });
    mockReadJsonDir.mockReturnValue([]);
    mockBatchWrite.mockResolvedValue(0);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    expect(mockBatchWrite).toHaveBeenCalledWith(mockDb, "headToHead", [], false);
  });

  it("should preserve all original record data in the document", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: false, verbose: false });
    const record = {
      team1Code: "ENG",
      team2Code: "BRA",
      totalMatches: 25,
      team1Wins: 10,
      team2Wins: 12,
      draws: 3,
      lastMeeting: "2022-11-21",
    };
    mockReadJsonDir.mockReturnValue([record]);
    mockBatchWrite.mockResolvedValue(1);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    const docs = mockBatchWrite.mock.calls[0][2];
    expect(docs[0].data.totalMatches).toBe(25);
    expect(docs[0].data.team1Wins).toBe(10);
    expect(docs[0].data.team2Wins).toBe(12);
    expect(docs[0].data.draws).toBe(3);
    expect(docs[0].data.lastMeeting).toBe("2022-11-21");
  });
});

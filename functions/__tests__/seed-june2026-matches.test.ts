/**
 * Tests for seed-june2026-matches.ts
 *
 * Verifies:
 * - Reads group stage match data from the correct JSON file
 * - Uses matchId as the document ID
 * - Writes to 'worldcup_matches' collection
 * - Handles --clear flag
 * - Handles --dryRun flag
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

describe("seed-june2026-matches", () => {
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
    return require("../src/seed-june2026-matches");
  }

  it("should read group stage matches from the correct JSON file", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: false, verbose: false });
    mockReadJsonFile.mockReturnValue([
      { matchId: "M01", homeTeam: "USA", awayTeam: "MEX" },
    ]);
    mockBatchWrite.mockResolvedValue(1);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    expect(mockReadJsonFile).toHaveBeenCalledWith("../../assets/data/worldcup/matches/group_stage.json");
  });

  it("should write to worldcup_matches collection", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: false, verbose: false });
    mockReadJsonFile.mockReturnValue([
      { matchId: "M01", homeTeam: "USA", awayTeam: "MEX" },
    ]);
    mockBatchWrite.mockResolvedValue(1);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    expect(mockBatchWrite).toHaveBeenCalledWith(
      mockDb,
      "worldcup_matches",
      expect.any(Array),
      false
    );
  });

  it("should use matchId as document ID", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: false, verbose: false });
    mockReadJsonFile.mockReturnValue([
      { matchId: "GS-01", homeTeam: "USA", awayTeam: "MEX", group: "A" },
      { matchId: "GS-02", homeTeam: "BRA", awayTeam: "ARG", group: "B" },
    ]);
    mockBatchWrite.mockResolvedValue(2);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    const docs = mockBatchWrite.mock.calls[0][2];
    expect(docs[0].id).toBe("GS-01");
    expect(docs[1].id).toBe("GS-02");
  });

  it("should pass the entire match object as document data", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: false, verbose: false });
    const match = {
      matchId: "GS-01",
      homeTeam: "USA",
      awayTeam: "MEX",
      group: "A",
      date: "2026-06-11",
      venue: "MetLife Stadium",
    };
    mockReadJsonFile.mockReturnValue([match]);
    mockBatchWrite.mockResolvedValue(1);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    const docs = mockBatchWrite.mock.calls[0][2];
    expect(docs[0].data).toEqual(match);
  });

  it("should clear worldcup_matches collection when --clear is set", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: true, verbose: false });
    mockReadJsonFile.mockReturnValue([]);
    mockBatchWrite.mockResolvedValue(0);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    expect(mockClearCollection).toHaveBeenCalledWith(mockDb, "worldcup_matches", false);
  });

  it("should not clear collection when --clear is not set", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: false, verbose: false });
    mockReadJsonFile.mockReturnValue([]);
    mockBatchWrite.mockResolvedValue(0);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    expect(mockClearCollection).not.toHaveBeenCalled();
  });

  it("should pass dryRun to batchWrite and clearCollection", async () => {
    mockParseArgs.mockReturnValue({ dryRun: true, clear: true, verbose: false });
    mockReadJsonFile.mockReturnValue([
      { matchId: "M01", homeTeam: "USA", awayTeam: "CAN" },
    ]);
    mockBatchWrite.mockResolvedValue(1);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    expect(mockClearCollection).toHaveBeenCalledWith(mockDb, "worldcup_matches", true);
    expect(mockBatchWrite).toHaveBeenCalledWith(mockDb, "worldcup_matches", expect.any(Array), true);
  });

  it("should handle empty matches array", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: false, verbose: false });
    mockReadJsonFile.mockReturnValue([]);
    mockBatchWrite.mockResolvedValue(0);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    expect(mockBatchWrite).toHaveBeenCalledWith(mockDb, "worldcup_matches", [], false);
  });

  it("should handle many matches (all 48 group stage)", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: false, verbose: false });
    const matches = Array.from({ length: 48 }, (_, i) => ({
      matchId: `GS-${String(i + 1).padStart(2, "0")}`,
      homeTeam: `T${i * 2}`,
      awayTeam: `T${i * 2 + 1}`,
    }));
    mockReadJsonFile.mockReturnValue(matches);
    mockBatchWrite.mockResolvedValue(48);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    const docs = mockBatchWrite.mock.calls[0][2];
    expect(docs).toHaveLength(48);
  });
});

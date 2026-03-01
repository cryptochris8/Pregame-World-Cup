/**
 * Tests for seed-knockout-matches.ts
 *
 * Verifies:
 * - Reads knockout match data from the correct JSON file
 * - Uses matchId as the document ID
 * - Writes to 'worldcup_matches' collection (same as group stage)
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

describe("seed-knockout-matches", () => {
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
    return require("../src/seed-knockout-matches");
  }

  it("should read knockout matches from the correct JSON file", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: false, verbose: false });
    mockReadJsonFile.mockReturnValue([
      { matchId: "R32-01", homeTeam: "1A", awayTeam: "2B" },
    ]);
    mockBatchWrite.mockResolvedValue(1);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    expect(mockReadJsonFile).toHaveBeenCalledWith("../../assets/data/worldcup/matches/knockout.json");
  });

  it("should write to worldcup_matches collection", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: false, verbose: false });
    mockReadJsonFile.mockReturnValue([
      { matchId: "R32-01", round: "Round of 32" },
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
      { matchId: "QF-01", round: "Quarter-final" },
      { matchId: "SF-01", round: "Semi-final" },
      { matchId: "F-01", round: "Final" },
    ]);
    mockBatchWrite.mockResolvedValue(3);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    const docs = mockBatchWrite.mock.calls[0][2];
    expect(docs[0].id).toBe("QF-01");
    expect(docs[1].id).toBe("SF-01");
    expect(docs[2].id).toBe("F-01");
  });

  it("should pass entire match object as document data", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: false, verbose: false });
    const match = {
      matchId: "R32-01",
      round: "Round of 32",
      homeTeam: "1A",
      awayTeam: "2B",
      date: "2026-07-05",
      venue: "SoFi Stadium",
    };
    mockReadJsonFile.mockReturnValue([match]);
    mockBatchWrite.mockResolvedValue(1);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    const docs = mockBatchWrite.mock.calls[0][2];
    expect(docs[0].data).toEqual(match);
  });

  it("should clear worldcup_matches when --clear is set", async () => {
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

  it("should pass dryRun to both clearCollection and batchWrite", async () => {
    mockParseArgs.mockReturnValue({ dryRun: true, clear: true, verbose: false });
    mockReadJsonFile.mockReturnValue([
      { matchId: "F-01", round: "Final" },
    ]);
    mockBatchWrite.mockResolvedValue(1);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    expect(mockClearCollection).toHaveBeenCalledWith(mockDb, "worldcup_matches", true);
    expect(mockBatchWrite).toHaveBeenCalledWith(mockDb, "worldcup_matches", expect.any(Array), true);
  });

  it("should handle empty knockout matches array", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: false, verbose: false });
    mockReadJsonFile.mockReturnValue([]);
    mockBatchWrite.mockResolvedValue(0);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    expect(mockBatchWrite).toHaveBeenCalledWith(mockDb, "worldcup_matches", [], false);
  });

  it("should handle all knockout rounds", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: false, verbose: false });
    const matches = [
      ...Array.from({ length: 16 }, (_, i) => ({ matchId: `R32-${i + 1}`, round: "Round of 32" })),
      ...Array.from({ length: 8 }, (_, i) => ({ matchId: `R16-${i + 1}`, round: "Round of 16" })),
      ...Array.from({ length: 4 }, (_, i) => ({ matchId: `QF-${i + 1}`, round: "Quarter-final" })),
      ...Array.from({ length: 2 }, (_, i) => ({ matchId: `SF-${i + 1}`, round: "Semi-final" })),
      { matchId: "3P-01", round: "Third-place" },
      { matchId: "F-01", round: "Final" },
    ];
    mockReadJsonFile.mockReturnValue(matches);
    mockBatchWrite.mockResolvedValue(matches.length);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    const docs = mockBatchWrite.mock.calls[0][2];
    expect(docs).toHaveLength(32);
  });
});

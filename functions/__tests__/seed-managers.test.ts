/**
 * Tests for seed-managers.ts
 *
 * Verifies:
 * - Reads manager JSON files from the correct directory
 * - Uses r.id as the document ID
 * - Writes to 'managers' collection
 * - Filters by --team flag (currentTeamCode)
 * - Handles --clear, --dryRun, --verbose flags
 * - Handles empty records gracefully
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

describe("seed-managers", () => {
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
      readJsonDir: mockReadJsonDir,
      batchWrite: mockBatchWrite,
      clearCollection: mockClearCollection,
    }));
    jest.spyOn(process, "exit").mockImplementation((() => {}) as any);
    jest.spyOn(console, "log").mockImplementation(() => {});
    jest.spyOn(console, "error").mockImplementation(() => {});
    return require("../src/seed-managers");
  }

  it("should read manager files from the correct directory", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, team: undefined, clear: false, verbose: false });
    mockReadJsonDir.mockReturnValue([
      { id: "mgr_usa", firstName: "Gregg", lastName: "Berhalter", currentTeamCode: "USA" },
    ]);
    mockBatchWrite.mockResolvedValue(1);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    expect(mockReadJsonDir).toHaveBeenCalledWith("../../assets/data/worldcup/managers");
  });

  it("should write to managers collection", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, team: undefined, clear: false, verbose: false });
    mockReadJsonDir.mockReturnValue([
      { id: "mgr_usa", firstName: "Gregg", lastName: "Berhalter", currentTeamCode: "USA" },
    ]);
    mockBatchWrite.mockResolvedValue(1);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    expect(mockBatchWrite).toHaveBeenCalledWith(
      mockDb,
      "managers",
      expect.any(Array),
      false
    );
  });

  it("should use r.id as document ID and r as document data", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, team: undefined, clear: false, verbose: false });
    const manager = {
      id: "mgr_bra",
      firstName: "Dorival",
      lastName: "Junior",
      currentTeamCode: "BRA",
      nationality: "Brazilian",
    };
    mockReadJsonDir.mockReturnValue([manager]);
    mockBatchWrite.mockResolvedValue(1);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    const docs = mockBatchWrite.mock.calls[0][2];
    expect(docs[0].id).toBe("mgr_bra");
    expect(docs[0].data).toEqual(manager);
  });

  it("should filter managers by --team flag (currentTeamCode)", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, team: "USA", clear: false, verbose: false });
    mockReadJsonDir.mockReturnValue([
      { id: "mgr_usa", firstName: "Gregg", lastName: "Berhalter", currentTeamCode: "USA" },
      { id: "mgr_mex", firstName: "Javier", lastName: "Aguirre", currentTeamCode: "MEX" },
      { id: "mgr_can", firstName: "Jesse", lastName: "Marsch", currentTeamCode: "CAN" },
    ]);
    mockBatchWrite.mockResolvedValue(1);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    const docs = mockBatchWrite.mock.calls[0][2];
    expect(docs).toHaveLength(1);
    expect(docs[0].id).toBe("mgr_usa");
  });

  it("should seed all managers when no --team filter is provided", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, team: undefined, clear: false, verbose: false });
    mockReadJsonDir.mockReturnValue([
      { id: "mgr_usa", firstName: "Gregg", lastName: "Berhalter", currentTeamCode: "USA" },
      { id: "mgr_mex", firstName: "Javier", lastName: "Aguirre", currentTeamCode: "MEX" },
    ]);
    mockBatchWrite.mockResolvedValue(2);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    const docs = mockBatchWrite.mock.calls[0][2];
    expect(docs).toHaveLength(2);
  });

  it("should log and return early when no managers found after filter", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, team: "ZZZ", clear: false, verbose: false });
    mockReadJsonDir.mockReturnValue([
      { id: "mgr_usa", firstName: "Gregg", lastName: "Berhalter", currentTeamCode: "USA" },
    ]);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    // batchWrite should NOT have been called since there are no managers matching ZZZ
    expect(mockBatchWrite).not.toHaveBeenCalled();
  });

  it("should clear managers collection when --clear is set", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, team: undefined, clear: true, verbose: false });
    mockReadJsonDir.mockReturnValue([
      { id: "mgr_usa", firstName: "Gregg", lastName: "Berhalter", currentTeamCode: "USA" },
    ]);
    mockBatchWrite.mockResolvedValue(1);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    expect(mockClearCollection).toHaveBeenCalledWith(mockDb, "managers", false);
  });

  it("should not clear when --clear is not set", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, team: undefined, clear: false, verbose: false });
    mockReadJsonDir.mockReturnValue([
      { id: "mgr_usa", firstName: "Gregg", lastName: "Berhalter", currentTeamCode: "USA" },
    ]);
    mockBatchWrite.mockResolvedValue(1);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    expect(mockClearCollection).not.toHaveBeenCalled();
  });

  it("should pass dryRun to batchWrite and clearCollection", async () => {
    mockParseArgs.mockReturnValue({ dryRun: true, team: undefined, clear: true, verbose: false });
    mockReadJsonDir.mockReturnValue([
      { id: "mgr_arg", firstName: "Lionel", lastName: "Scaloni", currentTeamCode: "ARG" },
    ]);
    mockBatchWrite.mockResolvedValue(1);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    expect(mockClearCollection).toHaveBeenCalledWith(mockDb, "managers", true);
    expect(mockBatchWrite).toHaveBeenCalledWith(mockDb, "managers", expect.any(Array), true);
  });

  it("should log verbose output when --verbose is set", async () => {
    const logSpy = jest.spyOn(console, "log").mockImplementation(() => {});
    mockParseArgs.mockReturnValue({ dryRun: false, team: undefined, clear: false, verbose: true });
    mockReadJsonDir.mockReturnValue([
      { id: "mgr_fra", firstName: "Didier", lastName: "Deschamps", currentTeamCode: "FRA" },
    ]);
    mockBatchWrite.mockResolvedValue(1);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    // Verbose mode should log each manager's team code and name
    expect(logSpy).toHaveBeenCalledWith(
      expect.stringContaining("FRA")
    );
  });

  it("should handle empty directory with no manager files", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, team: undefined, clear: false, verbose: false });
    mockReadJsonDir.mockReturnValue([]);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    // No managers found => batchWrite should not be called
    expect(mockBatchWrite).not.toHaveBeenCalled();
  });
});

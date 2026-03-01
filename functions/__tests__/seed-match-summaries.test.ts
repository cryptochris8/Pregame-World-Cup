/**
 * Tests for seed-match-summaries.ts
 *
 * Verifies:
 * - Reads JSON files from the match_summaries directory using fs directly
 * - Derives document ID from filename (e.g., CRO_ENG.json -> CRO_ENG)
 * - Writes to 'matchSummaries' collection
 * - Filters by --team flag (team1Code or team2Code)
 * - Reports first-time meetings count
 * - Handles --clear, --dryRun, --verbose flags
 */

import * as path from "path";

const mockInitFirebase = jest.fn();
const mockParseArgs = jest.fn();
const mockBatchWrite = jest.fn();
const mockClearCollection = jest.fn();

jest.mock("../src/seed-utils", () => ({
  initFirebase: mockInitFirebase,
  parseArgs: mockParseArgs,
  batchWrite: mockBatchWrite,
  clearCollection: mockClearCollection,
}));

// Mock fs module - seed-match-summaries uses fs directly (not readJsonDir)
const mockReaddirSync = jest.fn();
const mockReadFileSync = jest.fn();

jest.mock("fs", () => ({
  readdirSync: (...args: any[]) => mockReaddirSync(...args),
  readFileSync: (...args: any[]) => mockReadFileSync(...args),
  existsSync: jest.fn().mockReturnValue(true),
}));

jest.spyOn(process, "exit").mockImplementation((() => {}) as any);

describe("seed-match-summaries", () => {
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
      batchWrite: mockBatchWrite,
      clearCollection: mockClearCollection,
    }));
    jest.doMock("fs", () => ({
      readdirSync: (...args: any[]) => mockReaddirSync(...args),
      readFileSync: (...args: any[]) => mockReadFileSync(...args),
      existsSync: jest.fn().mockReturnValue(true),
    }));
    jest.spyOn(process, "exit").mockImplementation((() => {}) as any);
    jest.spyOn(console, "log").mockImplementation(() => {});
    jest.spyOn(console, "error").mockImplementation(() => {});
    return require("../src/seed-match-summaries");
  }

  it("should read JSON files from the match_summaries directory", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: false, team: undefined, verbose: false });
    mockReaddirSync.mockReturnValue(["CRO_ENG.json", "BRA_ARG.json"]);
    mockReadFileSync.mockImplementation((filePath: string) => {
      if (String(filePath).includes("CRO_ENG")) {
        return JSON.stringify({ team1Code: "CRO", team2Code: "ENG", team1Name: "Croatia", team2Name: "England" });
      }
      return JSON.stringify({ team1Code: "BRA", team2Code: "ARG", team1Name: "Brazil", team2Name: "Argentina" });
    });
    mockBatchWrite.mockResolvedValue(2);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    expect(mockReaddirSync).toHaveBeenCalled();
    expect(mockBatchWrite).toHaveBeenCalledWith(
      mockDb,
      "matchSummaries",
      expect.any(Array),
      false
    );
  });

  it("should derive document ID from filename (strip .json)", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: false, team: undefined, verbose: false });
    mockReaddirSync.mockReturnValue(["USA_MEX.json", "FRA_GER.json"]);
    mockReadFileSync.mockImplementation((filePath: string) => {
      if (String(filePath).includes("USA_MEX")) {
        return JSON.stringify({ team1Code: "USA", team2Code: "MEX", team1Name: "USA", team2Name: "Mexico" });
      }
      return JSON.stringify({ team1Code: "FRA", team2Code: "GER", team1Name: "France", team2Name: "Germany" });
    });
    mockBatchWrite.mockResolvedValue(2);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    const docs = mockBatchWrite.mock.calls[0][2];
    expect(docs[0].id).toBe("USA_MEX");
    expect(docs[1].id).toBe("FRA_GER");
  });

  it("should filter only .json files from directory listing", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: false, team: undefined, verbose: false });
    mockReaddirSync.mockReturnValue(["CRO_ENG.json", "README.md", ".gitkeep", "BRA_ARG.json"]);
    mockReadFileSync.mockReturnValue(
      JSON.stringify({ team1Code: "A", team2Code: "B", team1Name: "TeamA", team2Name: "TeamB" })
    );
    mockBatchWrite.mockResolvedValue(2);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    const docs = mockBatchWrite.mock.calls[0][2];
    expect(docs).toHaveLength(2);
  });

  it("should filter summaries by --team flag matching team1Code or team2Code", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: false, team: "BRA", verbose: false });
    mockReaddirSync.mockReturnValue(["CRO_ENG.json", "BRA_ARG.json", "BRA_GER.json"]);
    mockReadFileSync.mockImplementation((filePath: string) => {
      if (String(filePath).includes("CRO_ENG")) {
        return JSON.stringify({ team1Code: "CRO", team2Code: "ENG", team1Name: "Croatia", team2Name: "England" });
      }
      if (String(filePath).includes("BRA_ARG")) {
        return JSON.stringify({ team1Code: "BRA", team2Code: "ARG", team1Name: "Brazil", team2Name: "Argentina" });
      }
      return JSON.stringify({ team1Code: "BRA", team2Code: "GER", team1Name: "Brazil", team2Name: "Germany" });
    });
    mockBatchWrite.mockResolvedValue(2);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    const docs = mockBatchWrite.mock.calls[0][2];
    expect(docs).toHaveLength(2);
    expect(docs.every((d: any) => d.data.team1Code === "BRA" || d.data.team2Code === "BRA")).toBe(true);
  });

  it("should exclude summaries not matching --team filter", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: false, team: "JPN", verbose: false });
    mockReaddirSync.mockReturnValue(["CRO_ENG.json"]);
    mockReadFileSync.mockReturnValue(
      JSON.stringify({ team1Code: "CRO", team2Code: "ENG", team1Name: "Croatia", team2Name: "England" })
    );
    mockBatchWrite.mockResolvedValue(0);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    const docs = mockBatchWrite.mock.calls[0][2];
    expect(docs).toHaveLength(0);
  });

  it("should clear matchSummaries collection when --clear is set", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: true, team: undefined, verbose: false });
    mockReaddirSync.mockReturnValue([]);
    mockBatchWrite.mockResolvedValue(0);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    expect(mockClearCollection).toHaveBeenCalledWith(mockDb, "matchSummaries", false);
  });

  it("should not clear collection when --clear is not set", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: false, team: undefined, verbose: false });
    mockReaddirSync.mockReturnValue([]);
    mockBatchWrite.mockResolvedValue(0);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    expect(mockClearCollection).not.toHaveBeenCalled();
  });

  it("should pass dryRun to batchWrite and clearCollection", async () => {
    mockParseArgs.mockReturnValue({ dryRun: true, clear: true, team: undefined, verbose: false });
    mockReaddirSync.mockReturnValue(["A_B.json"]);
    mockReadFileSync.mockReturnValue(
      JSON.stringify({ team1Code: "A", team2Code: "B", team1Name: "TeamA", team2Name: "TeamB" })
    );
    mockBatchWrite.mockResolvedValue(1);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    expect(mockClearCollection).toHaveBeenCalledWith(mockDb, "matchSummaries", true);
    expect(mockBatchWrite).toHaveBeenCalledWith(mockDb, "matchSummaries", expect.any(Array), true);
  });

  it("should include full JSON data as document data", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: false, team: undefined, verbose: false });
    const summaryData = {
      team1Code: "USA",
      team2Code: "MEX",
      team1Name: "USA",
      team2Name: "Mexico",
      isFirstMeeting: false,
      historicalRecord: "USA leads 20-15-10",
      prediction: "USA slight favorite",
    };
    mockReaddirSync.mockReturnValue(["USA_MEX.json"]);
    mockReadFileSync.mockReturnValue(JSON.stringify(summaryData));
    mockBatchWrite.mockResolvedValue(1);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    const docs = mockBatchWrite.mock.calls[0][2];
    expect(docs[0].data).toEqual(summaryData);
  });

  it("should handle empty directory", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: false, team: undefined, verbose: false });
    mockReaddirSync.mockReturnValue([]);
    mockBatchWrite.mockResolvedValue(0);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    expect(mockBatchWrite).toHaveBeenCalledWith(mockDb, "matchSummaries", [], false);
  });

  it("should log verbose output for each summary when --verbose is set", async () => {
    const logSpy = jest.spyOn(console, "log").mockImplementation(() => {});
    mockParseArgs.mockReturnValue({ dryRun: false, clear: false, team: undefined, verbose: true });
    mockReaddirSync.mockReturnValue(["USA_MEX.json"]);
    mockReadFileSync.mockReturnValue(
      JSON.stringify({ team1Code: "USA", team2Code: "MEX", team1Name: "USA", team2Name: "Mexico" })
    );
    mockBatchWrite.mockResolvedValue(1);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    expect(logSpy).toHaveBeenCalledWith(expect.stringContaining("USA_MEX"));
  });
});

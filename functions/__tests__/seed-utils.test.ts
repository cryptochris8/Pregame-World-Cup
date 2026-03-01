/**
 * Seed Utils Tests
 *
 * Comprehensive tests for shared seed script utilities:
 * - initFirebase: Firebase Admin SDK initialization
 * - parseArgs: CLI argument parsing
 * - readJsonDir: Directory JSON file reading
 * - readJsonFile: Single JSON file reading
 * - batchWrite: Firestore batch document writes
 * - clearCollection: Firestore collection clearing
 */

import * as fs from "fs";
import * as path from "path";

// --- Mock firebase-admin before importing seed-utils ---
const mockBatchCommit = jest.fn().mockResolvedValue(undefined);
const mockBatchSet = jest.fn().mockReturnThis();
const mockBatchDelete = jest.fn().mockReturnThis();

const mockBatch = jest.fn(() => ({
  set: mockBatchSet,
  delete: mockBatchDelete,
  commit: mockBatchCommit,
}));

const mockDocRef = jest.fn((docId: string) => ({
  id: docId,
}));

const mockCollectionGet = jest.fn();

const mockCollection = jest.fn((collectionPath: string) => ({
  doc: mockDocRef,
  get: mockCollectionGet,
}));

const mockFirestore = jest.fn(() => ({
  collection: mockCollection,
  batch: mockBatch,
}));

// Track apps array to simulate initialization state
let mockApps: any[] = [];

jest.mock("firebase-admin", () => ({
  apps: mockApps,
  initializeApp: jest.fn(),
  firestore: Object.assign(mockFirestore, {
    FieldValue: {
      serverTimestamp: jest.fn(() => ({ _methodName: "serverTimestamp" })),
    },
  }),
}));

// --- Mock fs module ---
jest.mock("fs");

const mockedFs = fs as jest.Mocked<typeof fs>;

// --- Import seed-utils AFTER mocks are set up ---
import { initFirebase, parseArgs, readJsonDir, readJsonFile, batchWrite, clearCollection } from "../src/seed-utils";
import * as admin from "firebase-admin";

describe("seed-utils", () => {
  // Store original process.argv
  const originalArgv = process.argv;

  beforeEach(() => {
    jest.clearAllMocks();
    // Reset apps array to empty (no existing Firebase app)
    mockApps.length = 0;
    // Reset process.argv to a clean base
    process.argv = ["node", "seed-script.ts"];
    // Suppress console.log in tests
    jest.spyOn(console, "log").mockImplementation(() => {});
  });

  afterEach(() => {
    process.argv = originalArgv;
    jest.restoreAllMocks();
  });

  // ==========================================================================
  // initFirebase()
  // ==========================================================================
  describe("initFirebase", () => {
    it("should initialize Firebase and return Firestore instance when no app exists", () => {
      const db = initFirebase();

      expect(admin.initializeApp).toHaveBeenCalledTimes(1);
      expect(mockFirestore).toHaveBeenCalled();
      expect(db).toBeDefined();
      expect(db.collection).toBeDefined();
      expect(db.batch).toBeDefined();
    });

    it("should skip initializeApp when app already exists", () => {
      // Simulate existing app
      mockApps.push({ name: "[DEFAULT]" });

      const db = initFirebase();

      expect(admin.initializeApp).not.toHaveBeenCalled();
      expect(mockFirestore).toHaveBeenCalled();
      expect(db).toBeDefined();
    });

    it("should fall back to explicit projectId if default initializeApp throws", () => {
      (admin.initializeApp as jest.Mock).mockImplementationOnce(() => {
        throw new Error("No default credentials");
      }).mockImplementationOnce(() => {});

      const db = initFirebase();

      expect(admin.initializeApp).toHaveBeenCalledTimes(2);
      expect(admin.initializeApp).toHaveBeenNthCalledWith(1);
      expect(admin.initializeApp).toHaveBeenNthCalledWith(2, { projectId: "pregame-b089e" });
      expect(db).toBeDefined();
    });

    it("should return a Firestore instance with collection and batch methods", () => {
      const db = initFirebase();

      expect(typeof db.collection).toBe("function");
      expect(typeof db.batch).toBe("function");
    });
  });

  // ==========================================================================
  // parseArgs()
  // ==========================================================================
  describe("parseArgs", () => {
    it("should return default values when no arguments provided", () => {
      process.argv = ["node", "seed-script.ts"];

      const args = parseArgs();

      expect(args).toEqual({
        dryRun: false,
        clear: false,
        verbose: false,
        team: undefined,
      });
    });

    it("should parse --dryRun flag", () => {
      process.argv = ["node", "seed-script.ts", "--dryRun"];

      const args = parseArgs();

      expect(args.dryRun).toBe(true);
      expect(args.clear).toBe(false);
      expect(args.verbose).toBe(false);
      expect(args.team).toBeUndefined();
    });

    it("should parse --clear flag", () => {
      process.argv = ["node", "seed-script.ts", "--clear"];

      const args = parseArgs();

      expect(args.clear).toBe(true);
      expect(args.dryRun).toBe(false);
    });

    it("should parse --verbose flag", () => {
      process.argv = ["node", "seed-script.ts", "--verbose"];

      const args = parseArgs();

      expect(args.verbose).toBe(true);
    });

    it("should parse --team=USA and uppercase the value", () => {
      process.argv = ["node", "seed-script.ts", "--team=USA"];

      const args = parseArgs();

      expect(args.team).toBe("USA");
    });

    it("should uppercase lowercase team code", () => {
      process.argv = ["node", "seed-script.ts", "--team=mex"];

      const args = parseArgs();

      expect(args.team).toBe("MEX");
    });

    it("should handle mixed-case team code", () => {
      process.argv = ["node", "seed-script.ts", "--team=Bra"];

      const args = parseArgs();

      expect(args.team).toBe("BRA");
    });

    it("should parse combined flags", () => {
      process.argv = ["node", "seed-script.ts", "--dryRun", "--team=ARG", "--clear", "--verbose"];

      const args = parseArgs();

      expect(args).toEqual({
        dryRun: true,
        team: "ARG",
        clear: true,
        verbose: true,
      });
    });

    it("should ignore unknown flags", () => {
      process.argv = ["node", "seed-script.ts", "--unknownFlag", "--anotherOne=value"];

      const args = parseArgs();

      expect(args).toEqual({
        dryRun: false,
        clear: false,
        verbose: false,
        team: undefined,
      });
    });

    it("should return undefined team when --team flag has no value", () => {
      process.argv = ["node", "seed-script.ts", "--team="];

      const args = parseArgs();

      // Empty string uppercased is still empty string, which is falsy
      // The implementation does .split("=")[1]?.toUpperCase() which yields ""
      expect(args.team).toBe("");
    });
  });

  // ==========================================================================
  // readJsonDir()
  // ==========================================================================
  describe("readJsonDir", () => {
    it("should read and parse all JSON files from a directory", () => {
      const mockData1 = { id: "manager1", name: "Manager One" };
      const mockData2 = { id: "manager2", name: "Manager Two" };

      mockedFs.existsSync.mockReturnValue(true);
      mockedFs.readdirSync.mockReturnValue([
        "manager1.json" as any,
        "manager2.json" as any,
      ]);
      mockedFs.readFileSync.mockImplementation((filePath: any) => {
        if (String(filePath).includes("manager1.json")) {
          return JSON.stringify(mockData1);
        }
        return JSON.stringify(mockData2);
      });

      const result = readJsonDir("/test/dir");

      expect(result).toHaveLength(2);
      expect(result[0]).toEqual(mockData1);
      expect(result[1]).toEqual(mockData2);
    });

    it("should only include .json files, ignoring other extensions", () => {
      mockedFs.existsSync.mockReturnValue(true);
      mockedFs.readdirSync.mockReturnValue([
        "data.json" as any,
        "readme.md" as any,
        "script.ts" as any,
        "more.json" as any,
        ".gitkeep" as any,
      ]);
      mockedFs.readFileSync.mockReturnValue(JSON.stringify({ key: "value" }));

      const result = readJsonDir("/test/dir");

      expect(result).toHaveLength(2);
      expect(mockedFs.readFileSync).toHaveBeenCalledTimes(2);
    });

    it("should return empty array for directory with no JSON files", () => {
      mockedFs.existsSync.mockReturnValue(true);
      mockedFs.readdirSync.mockReturnValue([
        "readme.md" as any,
        "script.ts" as any,
      ]);

      const result = readJsonDir("/test/dir");

      expect(result).toHaveLength(0);
    });

    it("should return empty array for empty directory", () => {
      mockedFs.existsSync.mockReturnValue(true);
      mockedFs.readdirSync.mockReturnValue([]);

      const result = readJsonDir("/test/dir");

      expect(result).toHaveLength(0);
    });

    it("should throw for non-existent directory", () => {
      mockedFs.existsSync.mockReturnValue(false);

      expect(() => readJsonDir("/nonexistent/dir")).toThrow("Directory not found:");
    });

    it("should resolve relative paths from __dirname", () => {
      mockedFs.existsSync.mockReturnValue(true);
      mockedFs.readdirSync.mockReturnValue([]);

      readJsonDir("../../assets/data/worldcup/managers");

      // existsSync should have been called with a resolved absolute path
      const calledPath = (mockedFs.existsSync as jest.Mock).mock.calls[0][0];
      expect(path.isAbsolute(calledPath)).toBe(true);
    });

    it("should propagate JSON parse errors for malformed files", () => {
      mockedFs.existsSync.mockReturnValue(true);
      mockedFs.readdirSync.mockReturnValue(["bad.json" as any]);
      mockedFs.readFileSync.mockReturnValue("{ invalid json }");

      expect(() => readJsonDir("/test/dir")).toThrow();
    });
  });

  // ==========================================================================
  // readJsonFile()
  // ==========================================================================
  describe("readJsonFile", () => {
    it("should read and parse a single JSON file", () => {
      const mockData = { id: "team1", name: "USA", code: "USA" };
      mockedFs.existsSync.mockReturnValue(true);
      mockedFs.readFileSync.mockReturnValue(JSON.stringify(mockData));

      const result = readJsonFile("/test/data/team.json");

      expect(result).toEqual(mockData);
    });

    it("should throw for missing file", () => {
      mockedFs.existsSync.mockReturnValue(false);

      expect(() => readJsonFile("/nonexistent/file.json")).toThrow("File not found:");
    });

    it("should throw for invalid JSON content", () => {
      mockedFs.existsSync.mockReturnValue(true);
      mockedFs.readFileSync.mockReturnValue("not valid json {{{");

      expect(() => readJsonFile("/test/data/bad.json")).toThrow();
    });

    it("should handle JSON with nested objects", () => {
      const nestedData = {
        id: "match1",
        teams: { home: "USA", away: "MEX" },
        scores: { home: 2, away: 1 },
        stats: { possession: [55, 45] },
      };
      mockedFs.existsSync.mockReturnValue(true);
      mockedFs.readFileSync.mockReturnValue(JSON.stringify(nestedData));

      const result = readJsonFile("/test/data/match.json");

      expect(result).toEqual(nestedData);
    });

    it("should handle JSON arrays", () => {
      const arrayData = [
        { id: "1", name: "First" },
        { id: "2", name: "Second" },
      ];
      mockedFs.existsSync.mockReturnValue(true);
      mockedFs.readFileSync.mockReturnValue(JSON.stringify(arrayData));

      const result = readJsonFile("/test/data/list.json");

      expect(result).toEqual(arrayData);
      expect(Array.isArray(result)).toBe(true);
    });

    it("should resolve relative paths from __dirname", () => {
      mockedFs.existsSync.mockReturnValue(true);
      mockedFs.readFileSync.mockReturnValue(JSON.stringify({}));

      readJsonFile("../../assets/data/worldcup/teams.json");

      const calledPath = (mockedFs.existsSync as jest.Mock).mock.calls[0][0];
      expect(path.isAbsolute(calledPath)).toBe(true);
    });

    it("should read file with utf-8 encoding", () => {
      mockedFs.existsSync.mockReturnValue(true);
      mockedFs.readFileSync.mockReturnValue(JSON.stringify({ name: "Brasil" }));

      readJsonFile("/test/data/team.json");

      expect(mockedFs.readFileSync).toHaveBeenCalledWith(
        expect.any(String),
        "utf-8"
      );
    });
  });

  // ==========================================================================
  // batchWrite()
  // ==========================================================================
  describe("batchWrite", () => {
    let mockDb: any;

    beforeEach(() => {
      // Create a fresh mock Firestore instance for each test
      mockBatch.mockClear();
      mockBatchCommit.mockClear();
      mockBatchSet.mockClear();
      mockDocRef.mockClear();
      mockCollection.mockClear();

      mockDb = {
        collection: mockCollection,
        batch: mockBatch,
      };
    });

    it("should write documents to Firestore with merge and updatedAt", async () => {
      const docs = [
        { id: "doc1", data: { name: "Test 1" } },
        { id: "doc2", data: { name: "Test 2" } },
      ];

      const count = await batchWrite(mockDb, "testCollection", docs, false);

      expect(count).toBe(2);
      expect(mockBatch).toHaveBeenCalledTimes(1);
      expect(mockBatchSet).toHaveBeenCalledTimes(2);
      expect(mockBatchCommit).toHaveBeenCalledTimes(1);

      // Verify set was called with merge: true and updatedAt
      expect(mockBatchSet).toHaveBeenCalledWith(
        expect.objectContaining({ id: "doc1" }),
        expect.objectContaining({
          name: "Test 1",
          updatedAt: expect.objectContaining({ _methodName: "serverTimestamp" }),
        }),
        { merge: true }
      );
    });

    it("should return count and log without writing in dry run mode", async () => {
      const docs = [
        { id: "doc1", data: { name: "Test 1" } },
        { id: "doc2", data: { name: "Test 2" } },
        { id: "doc3", data: { name: "Test 3" } },
      ];

      const count = await batchWrite(mockDb, "testCollection", docs, true);

      expect(count).toBe(3);
      expect(mockBatch).not.toHaveBeenCalled();
      expect(mockBatchSet).not.toHaveBeenCalled();
      expect(mockBatchCommit).not.toHaveBeenCalled();
      expect(console.log).toHaveBeenCalledWith(
        expect.stringContaining("[DRY RUN]")
      );
    });

    it("should handle empty docs array", async () => {
      const count = await batchWrite(mockDb, "testCollection", [], false);

      expect(count).toBe(0);
      // batch() is still called (creates the initial batch), but commit is never called
      // because count stays 0 after the loop, the final if (count > 0) is false
      expect(mockBatchCommit).not.toHaveBeenCalled();
    });

    it("should handle empty docs array in dry run mode", async () => {
      const count = await batchWrite(mockDb, "testCollection", [], true);

      expect(count).toBe(0);
      expect(mockBatch).not.toHaveBeenCalled();
      expect(console.log).toHaveBeenCalledWith(
        expect.stringContaining("[DRY RUN] Would write 0 docs")
      );
    });

    it("should commit in batches of 490 for large document sets", async () => {
      // Create 1000 docs to trigger multiple batch commits
      const docs = Array.from({ length: 1000 }, (_, i) => ({
        id: `doc${i}`,
        data: { name: `Test ${i}` },
      }));

      const count = await batchWrite(mockDb, "testCollection", docs, false);

      expect(count).toBe(1000);
      // 1000 / 490 = 2 full batches (at 490 and 980), plus 1 final commit for remaining 20
      // batch() called: 1 initial + 2 resets after hitting 490 = 3 total
      expect(mockBatch).toHaveBeenCalledTimes(3);
      // commit() called: 2 at-490 commits + 1 final commit = 3 total
      expect(mockBatchCommit).toHaveBeenCalledTimes(3);
    });

    it("should commit exactly at 490 documents and create new batch", async () => {
      const docs = Array.from({ length: 490 }, (_, i) => ({
        id: `doc${i}`,
        data: { name: `Test ${i}` },
      }));

      const count = await batchWrite(mockDb, "testCollection", docs, false);

      expect(count).toBe(490);
      // When exactly 490: hits the >= 490 boundary, so commits mid-loop
      // Then count resets to 0, loop ends, final if (count > 0) is false => no extra commit
      // batch() called: 1 initial + 1 reset = 2
      expect(mockBatch).toHaveBeenCalledTimes(2);
      // commit() called: 1 mid-loop commit, 0 final commit = 1
      expect(mockBatchCommit).toHaveBeenCalledTimes(1);
    });

    it("should handle exactly 489 documents in a single batch", async () => {
      const docs = Array.from({ length: 489 }, (_, i) => ({
        id: `doc${i}`,
        data: { name: `Test ${i}` },
      }));

      const count = await batchWrite(mockDb, "testCollection", docs, false);

      expect(count).toBe(489);
      // Never hits 490 threshold, so only the initial batch + 1 final commit
      expect(mockBatch).toHaveBeenCalledTimes(1);
      expect(mockBatchCommit).toHaveBeenCalledTimes(1);
    });

    it("should handle exactly 491 documents (one doc in second batch)", async () => {
      const docs = Array.from({ length: 491 }, (_, i) => ({
        id: `doc${i}`,
        data: { name: `Test ${i}` },
      }));

      const count = await batchWrite(mockDb, "testCollection", docs, false);

      expect(count).toBe(491);
      // First 490 -> commit + reset, remaining 1 -> final commit
      expect(mockBatch).toHaveBeenCalledTimes(2);
      expect(mockBatchCommit).toHaveBeenCalledTimes(2);
    });

    it("should use collection reference with correct collection name", async () => {
      const docs = [{ id: "doc1", data: { name: "Test" } }];

      await batchWrite(mockDb, "managers", docs, false);

      expect(mockCollection).toHaveBeenCalledWith("managers");
    });

    it("should use doc reference with correct document id", async () => {
      const docs = [{ id: "usa-manager", data: { name: "Test" } }];

      await batchWrite(mockDb, "managers", docs, false);

      expect(mockDocRef).toHaveBeenCalledWith("usa-manager");
    });

    it("should log each document id during dry run", async () => {
      const docs = [
        { id: "alpha", data: { name: "A" } },
        { id: "bravo", data: { name: "B" } },
      ];

      await batchWrite(mockDb, "testCollection", docs, true);

      expect(console.log).toHaveBeenCalledWith(expect.stringContaining("alpha"));
      expect(console.log).toHaveBeenCalledWith(expect.stringContaining("bravo"));
    });

    it("should log progress during batch commits", async () => {
      const docs = Array.from({ length: 500 }, (_, i) => ({
        id: `doc${i}`,
        data: { value: i },
      }));

      await batchWrite(mockDb, "testCollection", docs, false);

      // Should log intermediate batch progress
      expect(console.log).toHaveBeenCalledWith(
        expect.stringContaining("Committed batch")
      );
      // Should log final count
      expect(console.log).toHaveBeenCalledWith(
        expect.stringContaining("Wrote 500 docs")
      );
    });
  });

  // ==========================================================================
  // clearCollection()
  // ==========================================================================
  describe("clearCollection", () => {
    let mockDb: any;

    beforeEach(() => {
      mockBatch.mockClear();
      mockBatchCommit.mockClear();
      mockBatchDelete.mockClear();
      mockCollection.mockClear();
      mockCollectionGet.mockClear();

      mockDb = {
        collection: mockCollection,
        batch: mockBatch,
      };
    });

    it("should delete all documents in a collection", async () => {
      const mockDocs = [
        { ref: { id: "doc1" } },
        { ref: { id: "doc2" } },
        { ref: { id: "doc3" } },
      ];
      mockCollectionGet.mockResolvedValue({
        empty: false,
        size: 3,
        docs: mockDocs,
      });

      await clearCollection(mockDb, "testCollection", false);

      expect(mockBatchDelete).toHaveBeenCalledTimes(3);
      expect(mockBatchCommit).toHaveBeenCalledTimes(1);
      expect(console.log).toHaveBeenCalledWith(
        expect.stringContaining("Cleared 3 docs")
      );
    });

    it("should not delete anything in dry run mode", async () => {
      await clearCollection(mockDb, "testCollection", true);

      expect(mockCollectionGet).not.toHaveBeenCalled();
      expect(mockBatch).not.toHaveBeenCalled();
      expect(mockBatchDelete).not.toHaveBeenCalled();
      expect(console.log).toHaveBeenCalledWith(
        expect.stringContaining("[DRY RUN]")
      );
    });

    it("should handle empty collection gracefully", async () => {
      mockCollectionGet.mockResolvedValue({
        empty: true,
        size: 0,
        docs: [],
      });

      await clearCollection(mockDb, "testCollection", false);

      expect(mockBatch).not.toHaveBeenCalled();
      expect(mockBatchDelete).not.toHaveBeenCalled();
      expect(console.log).toHaveBeenCalledWith(
        expect.stringContaining("already empty")
      );
    });

    it("should delete in batches of 490 for large collections", async () => {
      const mockDocs = Array.from({ length: 1000 }, (_, i) => ({
        ref: { id: `doc${i}` },
      }));
      mockCollectionGet.mockResolvedValue({
        empty: false,
        size: 1000,
        docs: mockDocs,
      });

      await clearCollection(mockDb, "testCollection", false);

      expect(mockBatchDelete).toHaveBeenCalledTimes(1000);
      // 1000 / 490 = 2 full batches + 1 final commit for remaining 20
      expect(mockBatch).toHaveBeenCalledTimes(3);
      expect(mockBatchCommit).toHaveBeenCalledTimes(3);
    });

    it("should use correct collection name", async () => {
      mockCollectionGet.mockResolvedValue({
        empty: true,
        size: 0,
        docs: [],
      });

      await clearCollection(mockDb, "managers", false);

      expect(mockCollection).toHaveBeenCalledWith("managers");
    });

    it("should log collection name in dry run message", async () => {
      await clearCollection(mockDb, "managers", true);

      expect(console.log).toHaveBeenCalledWith(
        expect.stringContaining("managers")
      );
    });

    it("should handle exactly 490 documents (single full batch)", async () => {
      const mockDocs = Array.from({ length: 490 }, (_, i) => ({
        ref: { id: `doc${i}` },
      }));
      mockCollectionGet.mockResolvedValue({
        empty: false,
        size: 490,
        docs: mockDocs,
      });

      await clearCollection(mockDb, "testCollection", false);

      // Hits 490 threshold -> commit + reset, then count is 0 so no final commit
      expect(mockBatch).toHaveBeenCalledTimes(2);
      expect(mockBatchCommit).toHaveBeenCalledTimes(1);
    });

    it("should pass document refs to batch.delete", async () => {
      const ref1 = { id: "doc1", path: "testCollection/doc1" };
      const ref2 = { id: "doc2", path: "testCollection/doc2" };
      mockCollectionGet.mockResolvedValue({
        empty: false,
        size: 2,
        docs: [{ ref: ref1 }, { ref: ref2 }],
      });

      await clearCollection(mockDb, "testCollection", false);

      expect(mockBatchDelete).toHaveBeenCalledWith(ref1);
      expect(mockBatchDelete).toHaveBeenCalledWith(ref2);
    });
  });
});

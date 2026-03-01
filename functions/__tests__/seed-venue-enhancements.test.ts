/**
 * Tests for seed-venue-enhancements.ts
 *
 * Verifies:
 * - Reads venue enhancement data from the correct JSON file
 * - Uses venueId as document ID
 * - Removes venueId and venueName from the document data
 * - Adds timestamps (createdAt, updatedAt)
 * - Adds timestamps to broadcastingSchedule, gameSpecials, liveCapacity
 * - Converts featuredUntil: true to a Timestamp one month from now
 * - Writes to 'venue_enhancements' collection
 * - Handles --clear, --dryRun, --verbose flags
 * - Handles empty venues array
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

// Mock firebase-admin for Timestamp
const mockTimestampNow = jest.fn().mockReturnValue({ seconds: 1000000, nanoseconds: 0 });
const mockTimestampFromDate = jest.fn().mockReturnValue({ seconds: 1000000 + 30 * 24 * 60 * 60, nanoseconds: 0 });

jest.mock("firebase-admin", () => ({
  apps: [],
  initializeApp: jest.fn(),
  firestore: Object.assign(jest.fn(), {
    Timestamp: {
      now: mockTimestampNow,
      fromDate: mockTimestampFromDate,
    },
    FieldValue: {
      serverTimestamp: jest.fn(() => ({ _methodName: "serverTimestamp" })),
    },
  }),
}));

jest.spyOn(process, "exit").mockImplementation((() => {}) as any);

describe("seed-venue-enhancements", () => {
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
    jest.doMock("firebase-admin", () => ({
      apps: [],
      initializeApp: jest.fn(),
      firestore: Object.assign(jest.fn(), {
        Timestamp: {
          now: mockTimestampNow,
          fromDate: mockTimestampFromDate,
        },
        FieldValue: {
          serverTimestamp: jest.fn(() => ({ _methodName: "serverTimestamp" })),
        },
      }),
    }));
    jest.spyOn(process, "exit").mockImplementation((() => {}) as any);
    jest.spyOn(console, "log").mockImplementation(() => {});
    jest.spyOn(console, "error").mockImplementation(() => {});
    return require("../src/seed-venue-enhancements");
  }

  it("should read venues from the correct JSON file", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: false, verbose: false });
    mockReadJsonFile.mockReturnValue([
      { venueId: "venue_1", venueName: "MetLife Stadium", subscriptionTier: "premium" },
    ]);
    mockBatchWrite.mockResolvedValue(1);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    expect(mockReadJsonFile).toHaveBeenCalledWith("../../assets/data/worldcup/venues/enhancements.json");
  });

  it("should write to venue_enhancements collection", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: false, verbose: false });
    mockReadJsonFile.mockReturnValue([
      { venueId: "venue_1", venueName: "MetLife Stadium", subscriptionTier: "premium" },
    ]);
    mockBatchWrite.mockResolvedValue(1);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    expect(mockBatchWrite).toHaveBeenCalledWith(
      mockDb,
      "venue_enhancements",
      expect.any(Array),
      false
    );
  });

  it("should use venueId as document ID", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: false, verbose: false });
    mockReadJsonFile.mockReturnValue([
      { venueId: "metlife_stadium", venueName: "MetLife Stadium", subscriptionTier: "premium" },
      { venueId: "sofi_stadium", venueName: "SoFi Stadium", subscriptionTier: "basic" },
    ]);
    mockBatchWrite.mockResolvedValue(2);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    const docs = mockBatchWrite.mock.calls[0][2];
    expect(docs[0].id).toBe("metlife_stadium");
    expect(docs[1].id).toBe("sofi_stadium");
  });

  it("should remove venueId and venueName from document data", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: false, verbose: false });
    mockReadJsonFile.mockReturnValue([
      { venueId: "venue_1", venueName: "Test Venue", subscriptionTier: "premium", capacity: 80000 },
    ]);
    mockBatchWrite.mockResolvedValue(1);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    const docs = mockBatchWrite.mock.calls[0][2];
    expect(docs[0].data.venueId).toBeUndefined();
    expect(docs[0].data.venueName).toBeUndefined();
    expect(docs[0].data.subscriptionTier).toBe("premium");
    expect(docs[0].data.capacity).toBe(80000);
  });

  it("should add createdAt and updatedAt timestamps", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: false, verbose: false });
    mockReadJsonFile.mockReturnValue([
      { venueId: "venue_1", venueName: "Test Venue", subscriptionTier: "basic" },
    ]);
    mockBatchWrite.mockResolvedValue(1);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    const docs = mockBatchWrite.mock.calls[0][2];
    expect(docs[0].data.createdAt).toBeDefined();
    expect(docs[0].data.updatedAt).toBeDefined();
  });

  it("should add lastUpdated timestamp to broadcastingSchedule", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: false, verbose: false });
    mockReadJsonFile.mockReturnValue([
      {
        venueId: "venue_1",
        venueName: "Test Venue",
        subscriptionTier: "premium",
        broadcastingSchedule: { channels: ["ESPN", "FOX"] },
      },
    ]);
    mockBatchWrite.mockResolvedValue(1);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    const docs = mockBatchWrite.mock.calls[0][2];
    expect(docs[0].data.broadcastingSchedule.lastUpdated).toBeDefined();
    expect(docs[0].data.broadcastingSchedule.channels).toEqual(["ESPN", "FOX"]);
  });

  it("should add createdAt timestamp to each game special", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: false, verbose: false });
    mockReadJsonFile.mockReturnValue([
      {
        venueId: "venue_1",
        venueName: "Test Venue",
        subscriptionTier: "premium",
        gameSpecials: [
          { name: "Happy Hour", discount: "20%" },
          { name: "Match Day Combo", discount: "15%" },
        ],
      },
    ]);
    mockBatchWrite.mockResolvedValue(1);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    const docs = mockBatchWrite.mock.calls[0][2];
    const specials = docs[0].data.gameSpecials;
    expect(specials[0].createdAt).toBeDefined();
    expect(specials[1].createdAt).toBeDefined();
    expect(specials[0].name).toBe("Happy Hour");
  });

  it("should add lastUpdated timestamp to liveCapacity", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: false, verbose: false });
    mockReadJsonFile.mockReturnValue([
      {
        venueId: "venue_1",
        venueName: "Test Venue",
        subscriptionTier: "premium",
        liveCapacity: { current: 500, max: 1000 },
      },
    ]);
    mockBatchWrite.mockResolvedValue(1);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    const docs = mockBatchWrite.mock.calls[0][2];
    expect(docs[0].data.liveCapacity.lastUpdated).toBeDefined();
  });

  it("should convert featuredUntil: true to a Timestamp one month from now", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: false, verbose: false });
    mockReadJsonFile.mockReturnValue([
      {
        venueId: "venue_1",
        venueName: "Test Venue",
        subscriptionTier: "premium",
        featuredUntil: true,
      },
    ]);
    mockBatchWrite.mockResolvedValue(1);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    expect(mockTimestampFromDate).toHaveBeenCalled();
    const docs = mockBatchWrite.mock.calls[0][2];
    // featuredUntil should be replaced with Timestamp, not true
    expect(docs[0].data.featuredUntil).not.toBe(true);
  });

  it("should not convert featuredUntil when it is not true", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: false, verbose: false });
    mockReadJsonFile.mockReturnValue([
      {
        venueId: "venue_1",
        venueName: "Test Venue",
        subscriptionTier: "basic",
        featuredUntil: false,
      },
    ]);
    mockBatchWrite.mockResolvedValue(1);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    const docs = mockBatchWrite.mock.calls[0][2];
    expect(docs[0].data.featuredUntil).toBe(false);
  });

  it("should clear venue_enhancements collection when --clear is set", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: true, verbose: false });
    mockReadJsonFile.mockReturnValue([
      { venueId: "v1", venueName: "Test", subscriptionTier: "basic" },
    ]);
    mockBatchWrite.mockResolvedValue(1);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    expect(mockClearCollection).toHaveBeenCalledWith(mockDb, "venue_enhancements", false);
  });

  it("should not clear when --clear is not set", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: false, verbose: false });
    mockReadJsonFile.mockReturnValue([
      { venueId: "v1", venueName: "Test", subscriptionTier: "basic" },
    ]);
    mockBatchWrite.mockResolvedValue(1);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    expect(mockClearCollection).not.toHaveBeenCalled();
  });

  it("should pass dryRun to batchWrite and clearCollection", async () => {
    mockParseArgs.mockReturnValue({ dryRun: true, clear: true, verbose: false });
    mockReadJsonFile.mockReturnValue([
      { venueId: "v1", venueName: "Test", subscriptionTier: "basic" },
    ]);
    mockBatchWrite.mockResolvedValue(1);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    expect(mockClearCollection).toHaveBeenCalledWith(mockDb, "venue_enhancements", true);
    expect(mockBatchWrite).toHaveBeenCalledWith(mockDb, "venue_enhancements", expect.any(Array), true);
  });

  it("should return early when venues array is empty", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: false, verbose: false });
    mockReadJsonFile.mockReturnValue([]);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    expect(mockBatchWrite).not.toHaveBeenCalled();
  });

  it("should log venue info when --verbose is set", async () => {
    const logSpy = jest.spyOn(console, "log").mockImplementation(() => {});
    mockParseArgs.mockReturnValue({ dryRun: false, clear: false, verbose: true });
    mockReadJsonFile.mockReturnValue([
      { venueId: "metlife", venueName: "MetLife Stadium", subscriptionTier: "premium" },
    ]);
    mockBatchWrite.mockResolvedValue(1);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    expect(logSpy).toHaveBeenCalledWith(expect.stringContaining("metlife"));
  });

  it("should handle venues without optional fields", async () => {
    mockParseArgs.mockReturnValue({ dryRun: false, clear: false, verbose: false });
    mockReadJsonFile.mockReturnValue([
      { venueId: "minimal_venue", venueName: "Minimal", subscriptionTier: "free" },
    ]);
    mockBatchWrite.mockResolvedValue(1);

    runSeed();
    await new Promise((r) => setTimeout(r, 100));

    const docs = mockBatchWrite.mock.calls[0][2];
    expect(docs[0].id).toBe("minimal_venue");
    expect(docs[0].data.subscriptionTier).toBe("free");
    expect(docs[0].data.createdAt).toBeDefined();
    expect(docs[0].data.updatedAt).toBeDefined();
  });
});

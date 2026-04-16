/**
 * Tests for Country Scout coordinator — argument parsing and team selection.
 *
 * Run: npx jest run.test.ts
 */

import { parseCLIArgs, resolveTeams, CLIFlags, GROUP_TEAMS } from "./run";

// ---------------------------------------------------------------------------
// parseCLIArgs
// ---------------------------------------------------------------------------

describe("parseCLIArgs", () => {
  it("returns defaults when no args provided", () => {
    const flags = parseCLIArgs(["node", "run.ts"]);
    expect(flags).toEqual({
      teams: [],
      group: null,
      dryRun: false,
      skipSeed: false,
      skipNarratives: false,
    });
  });

  it("parses --teams flag with multiple teams", () => {
    const flags = parseCLIArgs(["node", "run.ts", "--teams=ARG,BRA,FRA"]);
    expect(flags.teams).toEqual(["ARG", "BRA", "FRA"]);
  });

  it("normalises team codes to uppercase", () => {
    const flags = parseCLIArgs(["node", "run.ts", "--teams=arg,bra"]);
    expect(flags.teams).toEqual(["ARG", "BRA"]);
  });

  it("parses single team", () => {
    const flags = parseCLIArgs(["node", "run.ts", "--teams=MEX"]);
    expect(flags.teams).toEqual(["MEX"]);
  });

  it("strips whitespace from team codes", () => {
    const flags = parseCLIArgs(["node", "run.ts", "--teams= ARG , BRA "]);
    expect(flags.teams).toEqual(["ARG", "BRA"]);
  });

  it("filters out empty strings from teams", () => {
    const flags = parseCLIArgs(["node", "run.ts", "--teams=ARG,,BRA"]);
    expect(flags.teams).toEqual(["ARG", "BRA"]);
  });

  it("parses --group flag", () => {
    const flags = parseCLIArgs(["node", "run.ts", "--group=A"]);
    expect(flags.group).toBe("A");
  });

  it("normalises group to uppercase", () => {
    const flags = parseCLIArgs(["node", "run.ts", "--group=c"]);
    expect(flags.group).toBe("C");
  });

  it("parses --dryRun flag", () => {
    const flags = parseCLIArgs(["node", "run.ts", "--dryRun"]);
    expect(flags.dryRun).toBe(true);
  });

  it("parses --skipSeed flag", () => {
    const flags = parseCLIArgs(["node", "run.ts", "--skipSeed"]);
    expect(flags.skipSeed).toBe(true);
  });

  it("parses --skipNarratives flag", () => {
    const flags = parseCLIArgs(["node", "run.ts", "--skipNarratives"]);
    expect(flags.skipNarratives).toBe(true);
  });

  it("parses multiple flags together", () => {
    const flags = parseCLIArgs([
      "node",
      "run.ts",
      "--teams=ARG,BRA",
      "--dryRun",
      "--skipSeed",
      "--skipNarratives",
    ]);
    expect(flags.teams).toEqual(["ARG", "BRA"]);
    expect(flags.dryRun).toBe(true);
    expect(flags.skipSeed).toBe(true);
    expect(flags.skipNarratives).toBe(true);
  });

  it("ignores unknown flags", () => {
    const flags = parseCLIArgs(["node", "run.ts", "--verbose", "--teams=ARG"]);
    expect(flags.teams).toEqual(["ARG"]);
    expect(flags.dryRun).toBe(false);
  });
});

// ---------------------------------------------------------------------------
// resolveTeams
// ---------------------------------------------------------------------------

describe("resolveTeams", () => {
  const baseFlags: CLIFlags = {
    teams: [],
    group: null,
    dryRun: false,
    skipSeed: false,
    skipNarratives: false,
  };

  it("returns all 48 teams when no filter specified", () => {
    const teams = resolveTeams({ ...baseFlags });
    expect(teams.length).toBe(48);
    expect(teams).toContain("ARG");
    expect(teams).toContain("BRA");
    expect(teams).toContain("MEX");
  });

  it("returns explicit team list when --teams specified", () => {
    const teams = resolveTeams({ ...baseFlags, teams: ["ARG", "BRA"] });
    expect(teams).toEqual(["ARG", "BRA"]);
  });

  it("returns group teams when --group specified", () => {
    const teams = resolveTeams({ ...baseFlags, group: "A" });
    expect(teams).toEqual(GROUP_TEAMS["A"]);
  });

  it("--teams takes precedence over --group", () => {
    const teams = resolveTeams({
      ...baseFlags,
      teams: ["FRA", "ENG"],
      group: "A",
    });
    expect(teams).toEqual(["FRA", "ENG"]);
  });

  it("throws on unknown team code", () => {
    expect(() =>
      resolveTeams({ ...baseFlags, teams: ["ARG", "XXX"] })
    ).toThrow("Unknown team code(s): XXX");
  });

  it("throws on unknown group", () => {
    expect(() =>
      resolveTeams({ ...baseFlags, group: "Z" })
    ).toThrow("Unknown group: Z");
  });

  it("includes all valid groups A through L", () => {
    const validGroups = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L"];
    for (const g of validGroups) {
      const teams = resolveTeams({ ...baseFlags, group: g });
      expect(teams.length).toBe(4);
      // Every returned team should also appear in the all-teams list
      for (const t of teams) {
        expect(resolveTeams({ ...baseFlags })).toContain(t);
      }
    }
  });

  it("all 48 team codes are unique", () => {
    const all = resolveTeams({ ...baseFlags });
    const unique = new Set(all);
    expect(unique.size).toBe(48);
  });
});

// ---------------------------------------------------------------------------
// GROUP_TEAMS consistency
// ---------------------------------------------------------------------------

describe("GROUP_TEAMS", () => {
  it("has exactly 12 groups", () => {
    expect(Object.keys(GROUP_TEAMS).length).toBe(12);
  });

  it("each group has exactly 4 teams", () => {
    for (const [group, teams] of Object.entries(GROUP_TEAMS)) {
      expect(teams).toHaveLength(4);
    }
  });

  it("no team appears in multiple groups", () => {
    const seen = new Set<string>();
    for (const [group, teams] of Object.entries(GROUP_TEAMS)) {
      for (const t of teams) {
        expect(seen.has(t)).toBe(false);
        seen.add(t);
      }
    }
  });
});

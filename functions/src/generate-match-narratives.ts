/**
 * Generate Match Narratives — AI Sports Journalism Engine
 *
 * Reads ALL local statistical data (14 data layers) for each World Cup match,
 * assembles them into a rich prompt, sends to Claude API, and saves the output
 * as beautifully written, expert-level pregame journalism in JSON format.
 *
 * IMPORTANT: This script is ADDITIVE by design.
 *   - It NEVER overwrites existing narrative files unless --force is used.
 *   - It NEVER touches existing match_summaries/ files.
 *   - Output goes to a SEPARATE directory: assets/data/worldcup/match_narratives/
 *   - It can be run incrementally: generate one match, one group, or all.
 *
 * Usage:
 *   npx ts-node src/generate-match-narratives.ts                          # Generate ALL missing
 *   npx ts-node src/generate-match-narratives.ts --match=ARG_BRA          # Generate one match
 *   npx ts-node src/generate-match-narratives.ts --group=A                # Generate one group
 *   npx ts-node src/generate-match-narratives.ts --force                  # Regenerate ALL (overwrites)
 *   npx ts-node src/generate-match-narratives.ts --force --match=ARG_BRA  # Regenerate one match
 *   npx ts-node src/generate-match-narratives.ts --dryRun                 # Preview without writing
 *   npx ts-node src/generate-match-narratives.ts --list                   # List missing narratives
 *
 * Requires:
 *   CLAUDE_API_KEY environment variable (or .env file in functions/)
 */

import * as fs from "fs";
import * as path from "path";

// Path constants — relative to project root
const PROJECT_ROOT = path.resolve(__dirname, "../../");
const DATA_DIR = path.join(PROJECT_ROOT, "assets/data/worldcup");
const SUMMARIES_DIR = path.join(DATA_DIR, "match_summaries");
const NARRATIVES_DIR = path.join(DATA_DIR, "match_narratives");

// ============================================================================
// Data Loading — Each function reads one of the 14 data layers
// ============================================================================

function loadJson(filePath: string): any {
  try {
    const raw = fs.readFileSync(filePath, "utf-8");
    return JSON.parse(raw);
  } catch {
    return null;
  }
}

function loadMatchSummary(matchKey: string): any {
  return loadJson(path.join(SUMMARIES_DIR, `${matchKey}.json`));
}

function loadEloRatings(): Map<string, any> {
  const data = loadJson(path.join(DATA_DIR, "elo_ratings.json"));
  const map = new Map<string, any>();
  if (data?.ratings) {
    for (const r of data.ratings) {
      map.set(r.teamCode, r);
    }
  }
  return map;
}

function loadTacticalProfiles(): Map<string, any> {
  const data = loadJson(path.join(DATA_DIR, "tactical_profiles.json"));
  const map = new Map<string, any>();
  if (data?.teams) {
    for (const t of data.teams) {
      map.set(t.teamCode, t);
    }
  }
  return map;
}

function loadInjuryTracker(): Map<string, any[]> {
  const data = loadJson(path.join(DATA_DIR, "injury_tracker.json"));
  const map = new Map<string, any[]>();
  if (data?.players) {
    for (const p of data.players) {
      const list = map.get(p.teamCode) || [];
      list.push(p);
      map.set(p.teamCode, list);
    }
  }
  return map;
}

function loadSquadValues(): Map<string, any> {
  const data = loadJson(path.join(DATA_DIR, "squad_values.json"));
  const map = new Map<string, any>();
  if (data?.teams) {
    for (const t of data.teams) {
      map.set(t.teamCode, t);
    }
  }
  return map;
}

function loadBettingOdds(): Map<string, any> {
  const data = loadJson(path.join(DATA_DIR, "betting_odds.json"));
  const map = new Map<string, any>();
  if (data?.outright_winner_odds?.teams) {
    for (const t of data.outright_winner_odds.teams) {
      map.set(t.teamCode, t);
    }
  }
  return map;
}

function loadHistoricalPatterns(): any {
  return loadJson(path.join(DATA_DIR, "historical_patterns.json"));
}

function loadConfederationRecords(): any {
  return loadJson(path.join(DATA_DIR, "confederation_records.json"));
}

function loadQualifyingCampaigns(): Map<string, any> {
  const data = loadJson(path.join(DATA_DIR, "qualifying_campaigns.json"));
  const map = new Map<string, any>();
  if (data?.teams) {
    for (const t of data.teams) {
      map.set(t.teamCode, t);
    }
  }
  return map;
}

function loadVenueFactors(): any[] {
  const data = loadJson(path.join(DATA_DIR, "venue_factors.json"));
  return data?.venues || [];
}

function loadRecentForm(): Map<string, any> {
  const map = new Map<string, any>();
  const formFiles = ["recent_form/groups_a_d.json", "recent_form/groups_e_h.json", "recent_form/groups_i_l.json"];
  for (const file of formFiles) {
    const data = loadJson(path.join(DATA_DIR, file));
    if (data?.groups) {
      for (const group of Object.values(data.groups) as any[]) {
        if (group.teams) {
          for (const team of group.teams) {
            map.set(team.teamCode, team);
          }
        }
      }
    }
  }
  return map;
}

function loadHeadToHead(matchKey: string): any {
  // matchKey is "ARG_BRA", h2h files use same format
  return loadJson(path.join(DATA_DIR, `head_to_head/${matchKey}.json`));
}

function loadTeamData(teamCode: string): any {
  return loadJson(path.join(DATA_DIR, `teams/${teamCode}.json`));
}

function loadPlayerProfiles(teamCode: string): any {
  return loadJson(path.join(DATA_DIR, `player_profiles/${teamCode}.json`));
}

function loadTeamsMetadata(): Map<string, any> {
  const data = loadJson(path.join(DATA_DIR, "teams_metadata.json"));
  const map = new Map<string, any>();
  if (data?.teams) {
    for (const t of data.teams) {
      map.set(t.teamCode, t);
    }
  }
  return map;
}

// ============================================================================
// Match Discovery — Find all matches that need narratives
// ============================================================================

function getExistingMatchKeys(): string[] {
  if (!fs.existsSync(SUMMARIES_DIR)) return [];
  return fs.readdirSync(SUMMARIES_DIR)
    .filter((f) => f.endsWith(".json"))
    .map((f) => f.replace(".json", ""));
}

function getExistingNarrativeKeys(): Set<string> {
  if (!fs.existsSync(NARRATIVES_DIR)) return new Set();
  return new Set(
    fs.readdirSync(NARRATIVES_DIR)
      .filter((f) => f.endsWith(".json"))
      .map((f) => f.replace(".json", ""))
  );
}

function getMissingNarratives(): string[] {
  const allMatches = getExistingMatchKeys();
  const existingNarratives = getExistingNarrativeKeys();
  return allMatches.filter((key) => !existingNarratives.has(key));
}

// ============================================================================
// Prompt Assembly — Combines all 14 data layers into a Claude prompt
// ============================================================================

function assembleMatchContext(
  matchKey: string,
  globals: {
    elo: Map<string, any>;
    tactics: Map<string, any>;
    injuries: Map<string, any[]>;
    squadValues: Map<string, any>;
    bettingOdds: Map<string, any>;
    historicalPatterns: any;
    confederationRecords: any;
    qualifying: Map<string, any>;
    venueFactors: any[];
    recentForm: Map<string, any>;
    teamsMetadata: Map<string, any>;
  }
): string {
  const [team1, team2] = matchKey.split("_");

  const sections: string[] = [];

  // 1. Existing match summary (baseline research)
  const summary = loadMatchSummary(matchKey);
  if (summary) {
    sections.push(`=== EXISTING RESEARCH ===
Historical Analysis: ${summary.historicalAnalysis || "N/A"}
Key Storylines: ${JSON.stringify(summary.keyStorylines || [])}
Tactical Preview: ${summary.tacticalPreview || "N/A"}
Players to Watch: ${JSON.stringify(summary.playersToWatch || [])}
Prediction: ${JSON.stringify(summary.prediction || {})}
Past Encounters: ${summary.pastEncountersSummary || "N/A"}
Fun Facts: ${JSON.stringify(summary.funFacts || [])}
Is First Meeting: ${summary.isFirstMeeting || false}`);
  }

  // 2. Head-to-head history
  const h2h = loadHeadToHead(matchKey);
  if (h2h) {
    sections.push(`=== HEAD-TO-HEAD HISTORY ===
${JSON.stringify(h2h, null, 2)}`);
  }

  // 3. ELO ratings
  const elo1 = globals.elo.get(team1);
  const elo2 = globals.elo.get(team2);
  if (elo1 || elo2) {
    sections.push(`=== ELO RATINGS ===
${team1}: ${elo1 ? `Rating ${elo1.eloRating}, Rank #${elo1.rank}` : "N/A"}
${team2}: ${elo2 ? `Rating ${elo2.eloRating}, Rank #${elo2.rank}` : "N/A"}`);
  }

  // 4. Tactical profiles
  const tac1 = globals.tactics.get(team1);
  const tac2 = globals.tactics.get(team2);
  if (tac1 || tac2) {
    sections.push(`=== TACTICAL PROFILES ===
${team1}: ${tac1 ? JSON.stringify(tac1, null, 2) : "N/A"}
${team2}: ${tac2 ? JSON.stringify(tac2, null, 2) : "N/A"}`);
  }

  // 5. Recent form
  const form1 = globals.recentForm.get(team1);
  const form2 = globals.recentForm.get(team2);
  if (form1 || form2) {
    sections.push(`=== RECENT FORM ===
${team1}: ${form1 ? JSON.stringify(form1, null, 2) : "N/A"}
${team2}: ${form2 ? JSON.stringify(form2, null, 2) : "N/A"}`);
  }

  // 6. Injury tracker
  const inj1 = globals.injuries.get(team1) || [];
  const inj2 = globals.injuries.get(team2) || [];
  if (inj1.length || inj2.length) {
    sections.push(`=== INJURY/AVAILABILITY ===
${team1} concerns: ${JSON.stringify(inj1)}
${team2} concerns: ${JSON.stringify(inj2)}`);
  }

  // 7. Squad values
  const sv1 = globals.squadValues.get(team1);
  const sv2 = globals.squadValues.get(team2);
  if (sv1 || sv2) {
    sections.push(`=== SQUAD VALUES ===
${team1}: ${sv1 ? `Total: ${sv1.totalValue}, Most Valuable: ${sv1.mostValuablePlayer?.name} (${sv1.mostValuablePlayer?.value})` : "N/A"}
${team2}: ${sv2 ? `Total: ${sv2.totalValue}, Most Valuable: ${sv2.mostValuablePlayer?.name} (${sv2.mostValuablePlayer?.value})` : "N/A"}`);
  }

  // 8. Betting odds
  const odds1 = globals.bettingOdds.get(team1);
  const odds2 = globals.bettingOdds.get(team2);
  if (odds1 || odds2) {
    sections.push(`=== BETTING ODDS (Tournament Winner) ===
${team1}: ${odds1 ? `${odds1.impliedProbability || "N/A"}% implied probability` : "N/A"}
${team2}: ${odds2 ? `${odds2.impliedProbability || "N/A"}% implied probability` : "N/A"}`);
  }

  // 9. Qualifying campaigns
  const qual1 = globals.qualifying.get(team1);
  const qual2 = globals.qualifying.get(team2);
  if (qual1 || qual2) {
    sections.push(`=== QUALIFYING CAMPAIGNS ===
${team1}: ${qual1 ? `${qual1.wins}W ${qual1.draws}D ${qual1.losses}L, GD: ${qual1.goalDifference}, Top Scorer: ${qual1.topScorer?.name} (${qual1.topScorer?.goals})` : "N/A"}
${team2}: ${qual2 ? `${qual2.wins}W ${qual2.draws}D ${qual2.losses}L, GD: ${qual2.goalDifference}, Top Scorer: ${qual2.topScorer?.name} (${qual2.topScorer?.goals})` : "N/A"}`);
  }

  // 10. Team metadata
  const meta1 = globals.teamsMetadata.get(team1);
  const meta2 = globals.teamsMetadata.get(team2);
  if (meta1 || meta2) {
    sections.push(`=== TEAM METADATA ===
${team1}: ${meta1 ? `Nickname: ${meta1.nickname}, Confederation: ${meta1.confederation}, World Cup Titles: ${meta1.worldCupTitles}` : "N/A"}
${team2}: ${meta2 ? `Nickname: ${meta2.nickname}, Confederation: ${meta2.confederation}, World Cup Titles: ${meta2.worldCupTitles}` : "N/A"}`);
  }

  // 11. Historical patterns (global — summarize relevant ones)
  if (globals.historicalPatterns?.patterns) {
    const relevant = globals.historicalPatterns.patterns.slice(0, 5);
    sections.push(`=== HISTORICAL WORLD CUP PATTERNS ===
${relevant.map((p: any) => `- ${p.title || p.id}: ${p.description || ""}`).join("\n")}`);
  }

  // 12. Player profiles
  const players1 = loadPlayerProfiles(team1);
  const players2 = loadPlayerProfiles(team2);
  if (players1?.players) {
    const stars = players1.players.filter((p: any) => p.isKeyStar || p.marketValue > 50000000).slice(0, 3);
    if (stars.length) {
      sections.push(`=== ${team1} STAR PLAYERS ===
${stars.map((p: any) => `${p.name} (${p.position}): ${p.bio || p.description || ""}`).join("\n")}`);
    }
  }
  if (players2?.players) {
    const stars = players2.players.filter((p: any) => p.isKeyStar || p.marketValue > 50000000).slice(0, 3);
    if (stars.length) {
      sections.push(`=== ${team2} STAR PLAYERS ===
${stars.map((p: any) => `${p.name} (${p.position}): ${p.bio || p.description || ""}`).join("\n")}`);
    }
  }

  return sections.join("\n\n");
}

function buildPrompt(matchKey: string, context: string): string {
  const [team1, team2] = matchKey.split("_");

  return `You are an elite sports journalist — think Jonathan Wilson meets Sid Lowe meets Michael Cox. You write with the literary quality of The Athletic, the tactical depth of Zonal Marking, and the emotional resonance of a great World Cup documentary.

You are writing a pregame article for a World Cup 2026 match: ${team1} vs ${team2}.

Below is ALL the statistical and historical data available. Use it to write a compelling, deeply researched pregame piece. Every claim must be grounded in the data provided — never invent statistics or fabricate quotes.

${context}

Write the output as a JSON object with this EXACT schema:

{
  "matchKey": "${matchKey}",
  "team1Code": "${team1}",
  "team2Code": "${team2}",
  "team1Name": "<full country name>",
  "team2Name": "<full country name>",
  "generatedAt": "<ISO 8601 timestamp>",
  "dataVersion": 1,
  "headline": "<compelling, evocative headline — max 80 chars>",
  "subheadline": "<one-sentence summary — max 150 chars>",
  "openingNarrative": "<2-3 paragraphs of beautifully written pregame context. Set the scene. Establish the stakes. Make the reader FEEL the importance of this match. Use the historical data, recent form, and team context. This should read like the opening of a feature article in The Athletic.>",
  "tacticalBreakdown": {
    "title": "The Chess Match",
    "narrative": "<2 paragraphs analyzing the tactical matchup. Reference specific formations, playing styles, key tactical battles. Identify the area of the pitch where the match will be decided. Be specific about player roles and tactical adjustments.>",
    "team1Formation": "<formation from tactical profile>",
    "team2Formation": "<formation from tactical profile>",
    "keyMatchup": "<one-line description of the decisive individual/tactical battle>"
  },
  "dataInsights": {
    "title": "By The Numbers",
    "eloAnalysis": "<1-2 sentences weaving ELO ratings into narrative context>",
    "formAnalysis": "<1-2 sentences on recent form and qualifying campaign momentum>",
    "squadValueComparison": "<1-2 sentences comparing squad investment and what it means>",
    "injuryImpact": "<1-2 sentences on availability and how it affects tactics>",
    "bettingPerspective": "<1-2 sentences on what markets are saying>",
    "historicalPattern": "<1-2 sentences connecting a relevant historical World Cup pattern>"
  },
  "playerSpotlights": [
    {
      "name": "<player name>",
      "teamCode": "<team code>",
      "narrative": "<3-4 sentences about this player's story, their importance to this match, and what to watch for. Make it personal and compelling.>",
      "statline": "<one key stat or achievement>"
    }
  ],
  "theVerdict": {
    "title": "The Verdict",
    "prediction": "<predicted score, e.g. 'Argentina 2-1 Brazil'>",
    "confidence": <0-100>,
    "narrative": "<2 paragraphs explaining the prediction. Be confident but acknowledge uncertainty. End with something memorable.>",
    "alternativeScenarios": [
      {
        "scenario": "<alternative score>",
        "probability": <0-100>,
        "reasoning": "<2-3 sentences>"
      }
    ]
  },
  "closingLine": "<one powerful closing sentence that captures the essence of this matchup>"
}

CRITICAL RULES:
1. Every statistic must come from the data provided. Do NOT invent numbers.
2. Include 3-4 player spotlights (at least 1 from each team).
3. Write with passion and personality — this is sports journalism, not a Wikipedia entry.
4. The opening narrative should be at least 200 words.
5. Use the team's actual ELO ratings, squad values, and qualifying records from the data.
6. The prediction must be consistent with the confidence level and data analysis.
7. Output ONLY valid JSON — no markdown, no code fences, no explanation outside the JSON.`;
}

// ============================================================================
// Claude API Integration
// ============================================================================

async function callClaude(prompt: string): Promise<string> {
  const apiKey = process.env.CLAUDE_API_KEY;
  if (!apiKey) {
    throw new Error("CLAUDE_API_KEY environment variable is required");
  }

  const response = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "x-api-key": apiKey,
      "anthropic-version": "2023-06-01",
    },
    body: JSON.stringify({
      model: "claude-sonnet-4-20250514",
      max_tokens: 4096,
      messages: [{ role: "user", content: prompt }],
    }),
  });

  if (!response.ok) {
    const error = await response.text();
    throw new Error(`Claude API error (${response.status}): ${error}`);
  }

  const data = await response.json() as any;
  return data.content[0].text;
}

// ============================================================================
// Main Script
// ============================================================================

async function generateNarrative(
  matchKey: string,
  globals: any,
  dryRun: boolean
): Promise<boolean> {
  console.log(`\n📝 Generating narrative for ${matchKey}...`);

  // Assemble all data
  const context = assembleMatchContext(matchKey, globals);

  if (dryRun) {
    console.log(`  [DRY RUN] Would generate narrative (context: ${context.length} chars)`);
    return true;
  }

  // Build prompt and call Claude
  const prompt = buildPrompt(matchKey, context);
  console.log(`  Context assembled: ${context.length} chars across all data layers`);

  try {
    const response = await callClaude(prompt);

    // Parse and validate JSON response
    let narrative: any;
    try {
      // Sometimes Claude wraps in code fences
      const cleaned = response.replace(/```json\n?/g, "").replace(/```\n?/g, "").trim();
      narrative = JSON.parse(cleaned);
    } catch (parseErr) {
      console.error(`  ❌ Failed to parse Claude response as JSON: ${parseErr}`);
      console.error(`  Response preview: ${response.substring(0, 200)}...`);
      return false;
    }

    // Validate required fields
    if (!narrative.headline || !narrative.openingNarrative || !narrative.theVerdict) {
      console.error(`  ❌ Response missing required fields`);
      return false;
    }

    // Write to file
    const outPath = path.join(NARRATIVES_DIR, `${matchKey}.json`);
    fs.writeFileSync(outPath, JSON.stringify(narrative, null, 2), "utf-8");
    console.log(`  ✅ Saved to ${path.relative(PROJECT_ROOT, outPath)}`);
    return true;
  } catch (err) {
    console.error(`  ❌ Error generating narrative: ${err}`);
    return false;
  }
}

async function main() {
  const args = process.argv.slice(2);
  const dryRun = args.includes("--dryRun");
  const force = args.includes("--force");
  const listOnly = args.includes("--list");
  const matchArg = args.find((a) => a.startsWith("--match="))?.replace("--match=", "");
  const groupArg = args.find((a) => a.startsWith("--group="))?.replace("--group=", "");

  console.log("🏟️  Pregame World Cup — AI Match Narrative Generator");
  console.log("====================================================");

  // Ensure output directory exists
  if (!fs.existsSync(NARRATIVES_DIR)) {
    fs.mkdirSync(NARRATIVES_DIR, { recursive: true });
  }

  // Determine which matches to generate
  let matchKeys: string[];
  if (matchArg) {
    matchKeys = [matchArg.toUpperCase()];
  } else if (groupArg) {
    // TODO: Filter by group when match schedule data is loaded
    console.log(`Group filter not yet implemented — generating all missing`);
    matchKeys = force ? getExistingMatchKeys() : getMissingNarratives();
  } else {
    matchKeys = force ? getExistingMatchKeys() : getMissingNarratives();
  }

  if (listOnly) {
    const missing = getMissingNarratives();
    console.log(`\n📋 ${missing.length} matches missing narratives:`);
    for (const key of missing) {
      console.log(`  - ${key}`);
    }
    console.log(`\n✅ ${getExistingNarrativeKeys().size} narratives already exist`);
    return;
  }

  if (matchKeys.length === 0) {
    console.log("\n✅ All match narratives are up to date! Nothing to generate.");
    return;
  }

  console.log(`\n📊 Matches to generate: ${matchKeys.length}`);
  if (dryRun) console.log("🔍 DRY RUN — no files will be written\n");
  if (force) console.log("⚠️  FORCE MODE — existing narratives will be overwritten\n");

  // Load all global data once (shared across all matches)
  console.log("Loading data layers...");
  const globals = {
    elo: loadEloRatings(),
    tactics: loadTacticalProfiles(),
    injuries: loadInjuryTracker(),
    squadValues: loadSquadValues(),
    bettingOdds: loadBettingOdds(),
    historicalPatterns: loadHistoricalPatterns(),
    confederationRecords: loadConfederationRecords(),
    qualifying: loadQualifyingCampaigns(),
    venueFactors: loadVenueFactors(),
    recentForm: loadRecentForm(),
    teamsMetadata: loadTeamsMetadata(),
  };
  console.log(`  ✅ Loaded: ELO(${globals.elo.size}), Tactics(${globals.tactics.size}), Injuries(${globals.injuries.size}), SquadValues(${globals.squadValues.size}), Form(${globals.recentForm.size}), Qualifying(${globals.qualifying.size}), Metadata(${globals.teamsMetadata.size})`);

  // Generate narratives
  let success = 0;
  let failed = 0;

  for (const matchKey of matchKeys) {
    const ok = await generateNarrative(matchKey, globals, dryRun);
    if (ok) success++;
    else failed++;

    // Rate limiting: 1 second between API calls
    if (!dryRun && matchKeys.indexOf(matchKey) < matchKeys.length - 1) {
      await new Promise((r) => setTimeout(r, 1000));
    }
  }

  // Summary
  console.log("\n====================================================");
  console.log(`✅ Success: ${success}`);
  if (failed) console.log(`❌ Failed: ${failed}`);
  console.log(`📁 Output: assets/data/worldcup/match_narratives/`);
}

main().catch((err) => {
  console.error("Fatal error:", err);
  process.exit(1);
});

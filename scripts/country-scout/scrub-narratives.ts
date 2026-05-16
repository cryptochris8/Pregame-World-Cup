/**
 * Post-process scrub of "FIFA" and "World Cup" mentions out of regenerated
 * match narratives. Mirrors the historical scrub from commit ad55417, but
 * automated and order-sensitive so phrase forms don't fight each other.
 *
 * Run: npx ts-node scrub-narratives.ts [--dryRun]
 */

import * as fs from "fs";
import * as path from "path";

const NARR_DIR = path.resolve(
  __dirname,
  "../../assets/data/worldcup/match_narratives"
);

interface Rule {
  pattern: RegExp;
  replacement: string;
  label: string;
}

// Order matters: longer phrases first so they don't get partially substituted.
const RULES: Rule[] = [
  { pattern: /FIFA World Cup/g, replacement: "tournament", label: "FIFA World Cup → tournament" },
  { pattern: /World Cup 2026/g, replacement: "2026 tournament", label: "World Cup 2026 → 2026 tournament" },
  { pattern: /2026 World Cup/g, replacement: "2026 tournament", label: "2026 World Cup → 2026 tournament" },
  { pattern: /World Cup-winning/g, replacement: "tournament-winning", label: "World Cup-winning → tournament-winning" },
  { pattern: /World Cup qualifying/g, replacement: "qualifying", label: "World Cup qualifying → qualifying" },
  { pattern: /World Cup history/g, replacement: "tournament history", label: "World Cup history → tournament history" },
  { pattern: /World Cups/g, replacement: "tournaments", label: "World Cups → tournaments" },
  { pattern: /World Cup/g, replacement: "tournament", label: "World Cup → tournament" },
  // Handle stray FIFA mentions: context-specific where possible
  { pattern: /FIFA recognition/g, replacement: "international recognition", label: "FIFA recognition → international recognition" },
  { pattern: /FIFA ranking/g, replacement: "world ranking", label: "FIFA ranking → world ranking" },
  { pattern: /FIFA rankings/g, replacement: "world rankings", label: "FIFA rankings → world rankings" },
  { pattern: /FIFA['’]s /g, replacement: "the ", label: "FIFA's (possessive) → the" },
  { pattern: /FIFA /g, replacement: "", label: "FIFA (orphan) → (removed)" },
];

function main(): void {
  const dryRun = process.argv.includes("--dryRun");
  const files = fs.readdirSync(NARR_DIR).filter((f) => f.endsWith(".json")).sort();
  let totalReplacements = 0;
  let touchedFiles = 0;
  const ruleHits: Record<string, number> = {};

  for (const file of files) {
    const fp = path.join(NARR_DIR, file);
    const original = fs.readFileSync(fp, "utf-8");
    let scrubbed = original;
    let fileReplacements = 0;

    for (const rule of RULES) {
      const matches = scrubbed.match(rule.pattern);
      const count = matches ? matches.length : 0;
      if (count > 0) {
        scrubbed = scrubbed.replace(rule.pattern, rule.replacement);
        fileReplacements += count;
        ruleHits[rule.label] = (ruleHits[rule.label] || 0) + count;
      }
    }

    if (fileReplacements > 0) {
      touchedFiles++;
      totalReplacements += fileReplacements;
      if (!dryRun) {
        fs.writeFileSync(fp, scrubbed, "utf-8");
      }
    }
  }

  console.log("==========================================");
  console.log(` Scrub narratives (${dryRun ? "DRY RUN" : "LIVE"})`);
  console.log("==========================================");
  console.log(`Total files scanned: ${files.length}`);
  console.log(`Files touched: ${touchedFiles}`);
  console.log(`Total replacements: ${totalReplacements}`);
  console.log(`\nReplacements by rule:`);
  for (const [label, count] of Object.entries(ruleHits)) {
    console.log(`  ${count.toString().padStart(4)} × ${label}`);
  }
  if (dryRun) console.log("\nDRY RUN — no files modified.");
}

main();

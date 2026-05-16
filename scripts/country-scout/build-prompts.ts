/**
 * Generate per-team scout prompt files by substituting the template at
 * scripts/country-scout/country-scout.md against teams_metadata.json.
 *
 * Output: scripts/country-scout/scout-prompts/{TEAM_CODE}.md
 */

import * as fs from "fs";
import * as path from "path";

const ROOT = path.resolve(__dirname, "../../");
const TEMPLATE_PATH = path.join(__dirname, "country-scout.md");
const METADATA_PATH = path.join(ROOT, "assets/data/worldcup/teams_metadata.json");
const OUT_DIR = path.join(__dirname, "scout-prompts");

const GROUP_TO_FORM_FILE: Record<string, string> = {
  A: "groups_a_d.json", B: "groups_a_d.json", C: "groups_a_d.json", D: "groups_a_d.json",
  E: "groups_e_h.json", F: "groups_e_h.json", G: "groups_e_h.json", H: "groups_e_h.json",
  I: "groups_i_l.json", J: "groups_i_l.json", K: "groups_i_l.json", L: "groups_i_l.json",
};

function main(): void {
  const template = fs.readFileSync(TEMPLATE_PATH, "utf-8");
  const metadata = JSON.parse(fs.readFileSync(METADATA_PATH, "utf-8")) as Record<string, any>;

  if (!fs.existsSync(OUT_DIR)) fs.mkdirSync(OUT_DIR, { recursive: true });

  let count = 0;
  for (const [code, meta] of Object.entries(metadata)) {
    const formFile = GROUP_TO_FORM_FILE[meta.group] || "groups_a_d.json";
    const stars = Array.isArray(meta.starPlayers) ? meta.starPlayers.join(", ") : "";

    const populated = template
      .replace(/\{\{TEAM_CODE\}\}/g, code)
      .replace(/\{\{TEAM_NAME\}\}/g, meta.countryName || code)
      .replace(/\{\{GROUP\}\}/g, meta.group || "?")
      .replace(/\{\{CONFEDERATION\}\}/g, meta.confederation || "?")
      .replace(/\{\{COACH\}\}/g, meta.coachName || "Unknown")
      .replace(/\{\{CAPTAIN\}\}/g, meta.captainName || "Unknown")
      .replace(/\{\{STAR_PLAYERS\}\}/g, stars)
      .replace(/\{\{FORM_FILE\}\}/g, formFile);

    fs.writeFileSync(path.join(OUT_DIR, `${code}.md`), populated, "utf-8");
    count++;
  }

  console.log(`Wrote ${count} prompt files to ${OUT_DIR}`);
}

main();

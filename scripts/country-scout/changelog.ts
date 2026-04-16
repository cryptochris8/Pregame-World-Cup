/**
 * changelog.ts
 *
 * Generates a human-readable markdown diff/summary from all scout merge outputs.
 * Groups changes by type (injuries, form, tactical, squad, coach) and by team.
 *
 * IMPORTANT: Use teamCode, worldRanking, confederation — no trademarked terms.
 */

import type { ScoutOutput } from './types';
import type { ChangeSummary, MergeResult } from './merge-types';

// --- Public API ---

/**
 * Build a markdown changelog from an array of MergeResult objects
 * (the return values of the merge functions after they run).
 */
export function generateChangelog(
  results: MergeResult[],
  date?: string
): string {
  const allSummaries: ChangeSummary[] = [];
  for (const r of results) {
    allSummaries.push(...r.summary);
  }

  if (allSummaries.length === 0) {
    return `# Country Scout Changelog - ${date || today()}\n\nNo changes detected.\n`;
  }

  const lines: string[] = [];
  lines.push(`# Country Scout Changelog - ${date || today()}`);
  lines.push('');
  lines.push(`Total changes: ${allSummaries.length}`);
  lines.push('');

  // Group by type
  const byType = groupBy(allSummaries, (s) => s.type);
  const typeOrder: Array<ChangeSummary['type']> = ['injury', 'form', 'tactical', 'coach', 'squad'];
  const typeLabels: Record<string, string> = {
    injury: 'Injury Updates',
    form: 'Recent Form Updates',
    tactical: 'Tactical Profile Updates',
    coach: 'Coach Changes',
    squad: 'Squad Changes',
  };

  for (const type of typeOrder) {
    const items = byType[type];
    if (!items || items.length === 0) continue;

    lines.push(`## ${typeLabels[type] || type}`);
    lines.push('');

    // Group by teamCode within each type
    const byTeam = groupBy(items, (s) => s.teamCode);
    const teamCodes = Object.keys(byTeam).sort();

    for (const tc of teamCodes) {
      const teamItems = byTeam[tc];
      lines.push(`### ${tc}`);
      for (const item of teamItems) {
        lines.push(`- ${item.description}`);
      }
      lines.push('');
    }
  }

  return lines.join('\n');
}

/**
 * Generate a preview changelog from raw ScoutOutput objects,
 * before merges are actually applied. Useful for dry-run review.
 */
export function generatePreviewChangelog(
  scoutOutputs: ScoutOutput[],
  date?: string
): string {
  const lines: string[] = [];
  lines.push(`# Country Scout Preview - ${date || today()}`);
  lines.push('');

  let totalChanges = 0;

  // Collect all planned changes across scout outputs
  const injuryLines: string[] = [];
  const formLines: string[] = [];
  const tacticalLines: string[] = [];
  const squadLines: string[] = [];
  const coachLines: string[] = [];

  for (const scout of scoutOutputs) {
    const tc = scout.teamCode;

    // Injuries
    for (const u of scout.injuryUpdates) {
      if (u.action === 'no_change') continue;
      injuryLines.push(`- [${u.action.toUpperCase()}] ${u.playerName} (${tc}) - ${u.availabilityStatus}`);
      totalChanges++;
    }

    // Form
    if (scout.recentFormUpdates.length > 0) {
      formLines.push(`- ${tc}: ${scout.recentFormUpdates.length} new match(es)`);
      totalChanges++;
    }

    // Tactical
    if (scout.tacticalUpdates.length > 0) {
      for (const t of scout.tacticalUpdates) {
        tacticalLines.push(`- ${tc}: ${t.field} -> "${t.newValue}" (${t.confidence})`);
        totalChanges++;
      }
    }

    // Squad
    if (scout.squadChanges.length > 0) {
      for (const s of scout.squadChanges) {
        squadLines.push(`- ${tc}: ${s.playerName} - ${s.changeType}: ${s.details}`);
        totalChanges++;
      }
    }

    // Coach
    if (scout.coachUpdate.changed && scout.coachUpdate.newCoach) {
      coachLines.push(`- ${tc}: ${scout.coachUpdate.currentCoach} -> ${scout.coachUpdate.newCoach}`);
      totalChanges++;
    }
  }

  if (totalChanges === 0) {
    lines.push('No changes planned.');
    lines.push('');
    return lines.join('\n');
  }

  lines.push(`Total planned changes: ${totalChanges}`);
  lines.push('');

  if (injuryLines.length > 0) {
    lines.push('## Planned Injury Updates');
    lines.push('');
    lines.push(...injuryLines);
    lines.push('');
  }

  if (formLines.length > 0) {
    lines.push('## Planned Form Updates');
    lines.push('');
    lines.push(...formLines);
    lines.push('');
  }

  if (tacticalLines.length > 0) {
    lines.push('## Planned Tactical Updates');
    lines.push('');
    lines.push(...tacticalLines);
    lines.push('');
  }

  if (coachLines.length > 0) {
    lines.push('## Planned Coach Changes');
    lines.push('');
    lines.push(...coachLines);
    lines.push('');
  }

  if (squadLines.length > 0) {
    lines.push('## Planned Squad Changes');
    lines.push('');
    lines.push(...squadLines);
    lines.push('');
  }

  return lines.join('\n');
}

// --- Helpers ---

function today(): string {
  return new Date().toISOString().slice(0, 10);
}

function groupBy<T>(items: T[], keyFn: (item: T) => string): Record<string, T[]> {
  const result: Record<string, T[]> = {};
  for (const item of items) {
    const key = keyFn(item);
    if (!result[key]) result[key] = [];
    result[key].push(item);
  }
  return result;
}

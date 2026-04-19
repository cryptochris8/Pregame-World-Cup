/**
 * Firestore Rules Structural Regression Tests
 *
 * These tests parse `firestore.rules` as text and assert that specific
 * authorization guards are present. They are NOT a substitute for emulator-
 * based rules tests — a full authZ suite requires the Firebase emulator
 * (flagged as a gap in testing-detail.md). These tests guard against
 * accidental regressions of security-critical expressions that were added
 * in response to audit findings.
 *
 * When a rule below is intentionally changed, update the assertion to
 * reflect the new guard rather than deleting the test.
 */

import * as fs from 'fs';
import * as path from 'path';

const RULES_PATH = path.resolve(__dirname, '..', '..', 'firestore.rules');
const rules = fs.readFileSync(RULES_PATH, 'utf-8');

/**
 * Extract the body of a `match /path/{id} { ... }` block.
 * Handles nested braces.
 */
function extractMatchBlock(source: string, matchPath: string): string {
  const needle = `match ${matchPath} {`;
  const start = source.indexOf(needle);
  if (start === -1) {
    throw new Error(`Could not locate 'match ${matchPath}' in firestore.rules`);
  }
  let i = start + needle.length;
  let depth = 1;
  while (i < source.length && depth > 0) {
    if (source[i] === '{') depth++;
    else if (source[i] === '}') depth--;
    i++;
  }
  return source.slice(start, i);
}

describe('firestore.rules — structural guards', () => {
  describe('direct messages (/messages/{messageId}) — F3 audit fix', () => {
    const block = extractMatchBlock(rules, '/messages/{messageId}');

    it('allows update/delete only when caller is the senderId', () => {
      // Must include: request.auth.uid == resource.data.senderId on update/delete
      const updateLine = block.match(/allow update, delete:[^;]*;/);
      expect(updateLine).not.toBeNull();
      expect(updateLine![0]).toMatch(/request\.auth\.uid\s*==\s*resource\.data\.senderId/);
    });

    it('still requires the caller to be a chat participant on update/delete', () => {
      const updateLine = block.match(/allow update, delete:[^;]*;/);
      expect(updateLine).not.toBeNull();
      expect(updateLine![0]).toMatch(/isChatParticipant\(resource\.data\.chatId\)/);
    });

    it('rejects the permissive pre-audit form (participant-only, no sender check)', () => {
      // The pre-fix rule was:
      //   allow update, delete: if isAuth() && isChatParticipant(resource.data.chatId);
      // Regression guard: the rule must now have MORE conditions than that.
      const updateLine = block.match(/allow update, delete:[^;]*;/);
      expect(updateLine).not.toBeNull();
      // "senderId" anywhere in the update/delete clause confirms the new guard is present
      expect(updateLine![0]).toContain('senderId');
    });

    it('create rule still checks that caller is declared senderId', () => {
      const createLine = block.match(/allow create:[^;]*;/);
      expect(createLine).not.toBeNull();
      expect(createLine![0]).toMatch(/request\.auth\.uid\s*==\s*request\.resource\.data\.senderId/);
    });
  });

  describe('match_chats subcollection messages — existing guards (regression lock)', () => {
    // This block already had sender-ownership checks; lock them in to prevent
    // future regressions from silently drifting toward the weaker pattern.
    const block = extractMatchBlock(rules, '/match_chats/{chatId}');

    it('match_chats messages update/delete requires senderId ownership', () => {
      const nested = extractMatchBlock(block, '/messages/{messageId}');
      const updateLine = nested.match(/allow update, delete:[^;]*;/);
      expect(updateLine).not.toBeNull();
      expect(updateLine![0]).toMatch(/request\.auth\.uid\s*==\s*resource\.data\.senderId/);
    });
  });

  describe('global shape', () => {
    it('has no "allow read, write: if true" wildcard', () => {
      // Any match of this pattern would be a catastrophic misconfig.
      expect(rules).not.toMatch(/allow\s+read\s*,\s*write\s*:\s*if\s+true\s*;/);
    });

    it('has no "allow read: if true" wildcard', () => {
      expect(rules).not.toMatch(/allow\s+read\s*:\s*if\s+true\s*;/);
    });

    it('has no "allow write: if true" wildcard', () => {
      expect(rules).not.toMatch(/allow\s+write\s*:\s*if\s+true\s*;/);
    });
  });
});

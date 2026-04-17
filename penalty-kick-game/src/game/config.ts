import type { Difficulty } from '../types'

export const SOCCER_CONFIG = {
  // Field
  fieldWidth: 16,
  fieldLength: 20,

  // Goal (regulation standard: 7.32m x 2.44m)
  goalWidth: 7.32,
  goalHeight: 2.44,
  goalDepth: 2,
  goalPosition: [0, 0, -8] as [number, number, number],

  // Ball
  ballRadius: 0.11,
  ballMass: 0.45,
  ballRestitution: 0.6,
  ballLinearDamping: 0.2,
  ballAngularDamping: 2.5,
  ballFriction: 0.35,
  ballStartPosition: [0, 0.11, 2] as [number, number, number],

  // Kick
  minKickPower: 8,
  maxKickPower: 20,
  maxAimAngleX: 3.5,
  maxAimAngleY: 2.2,

  // Goalkeeper
  keeperWidth: 0.5,
  keeperHeight: 1.85,
  keeperDepth: 0.3,
  keeperStartPosition: [0, 0.925, -7.5] as [number, number, number],

  // Session
  totalKicks: 5,

  // Camera
  behindBallCam: [0, 2, 6] as [number, number, number],
} as const

export interface KeeperDifficulty {
  reactionDelayMs: number
  diveSpeed: number
  accuracy: number
}

export const KEEPER_DIFFICULTY: Record<Difficulty, KeeperDifficulty> = {
  easy: { reactionDelayMs: 400, diveSpeed: 3, accuracy: 0.33 },
  medium: { reactionDelayMs: 250, diveSpeed: 5, accuracy: 0.5 },
  hard: { reactionDelayMs: 100, diveSpeed: 7, accuracy: 0.7 },
}

const DIFFICULTY_KICKS: Record<Difficulty, number> = {
  easy: 7,
  medium: 5,
  hard: 4,
}

export function getTotalKicks(difficulty: Difficulty): number {
  return DIFFICULTY_KICKS[difficulty]
}

// Scoring constants
export const SCORING = {
  /** Number of top scores to keep in the leaderboard */
  maxHighScores: 5,
  /** localStorage key for persisted high scores */
  highScoreKey: 'pregame-pk-highscores',
  /** Combo thresholds for badge display */
  comboFireThreshold: 2,
  comboUnstoppableThreshold: 3,
} as const

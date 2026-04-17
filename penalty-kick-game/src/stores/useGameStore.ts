import { create } from 'zustand'
import type { Difficulty, GamePhase } from '../types'
import { SCORING } from '../game/config'

export interface HighScore {
  score: number
  accuracy: number
  maxCombo: number
  difficulty: Difficulty
  date: string
  suddenDeathWin: boolean
}

function loadHighScores(): HighScore[] {
  try {
    const raw = localStorage.getItem(SCORING.highScoreKey)
    if (!raw) return []
    const parsed = JSON.parse(raw)
    if (!Array.isArray(parsed)) return []
    return parsed.slice(0, SCORING.maxHighScores)
  } catch {
    return []
  }
}

function saveHighScores(scores: HighScore[]): void {
  try {
    localStorage.setItem(SCORING.highScoreKey, JSON.stringify(scores))
  } catch {
    // storage full or unavailable — silently ignore
  }
}

interface GameStore {
  gamePhase: GamePhase
  difficulty: Difficulty
  keeperScore: number
  combo: number
  maxCombo: number
  shotsOnTarget: number
  totalShots: number
  highScores: HighScore[]

  setDifficulty: (d: Difficulty) => void
  startGame: () => void
  endGame: () => void
  restart: () => void

  incrementCombo: () => void
  resetCombo: () => void
  incrementKeeperScore: () => void
  recordShot: (onTarget: boolean) => void
  submitHighScore: (score: number, suddenDeathWin: boolean) => boolean
}

export const useGameStore = create<GameStore>((set, get) => ({
  gamePhase: 'start',
  difficulty: 'medium',
  keeperScore: 0,
  combo: 0,
  maxCombo: 0,
  shotsOnTarget: 0,
  totalShots: 0,
  highScores: loadHighScores(),

  setDifficulty: (d) => set({ difficulty: d }),

  startGame: () => set({
    gamePhase: 'playing',
    keeperScore: 0,
    combo: 0,
    maxCombo: 0,
    shotsOnTarget: 0,
    totalShots: 0,
  }),

  endGame: () => set({ gamePhase: 'gameover' }),

  restart: () => set({
    gamePhase: 'start',
    keeperScore: 0,
    combo: 0,
    maxCombo: 0,
    shotsOnTarget: 0,
    totalShots: 0,
  }),

  incrementCombo: () => set((s) => {
    const newCombo = s.combo + 1
    return {
      combo: newCombo,
      maxCombo: Math.max(s.maxCombo, newCombo),
    }
  }),

  resetCombo: () => set({ combo: 0 }),

  incrementKeeperScore: () => set((s) => ({
    keeperScore: s.keeperScore + 1,
  })),

  recordShot: (onTarget: boolean) => set((s) => ({
    totalShots: s.totalShots + 1,
    shotsOnTarget: s.shotsOnTarget + (onTarget ? 1 : 0),
  })),

  submitHighScore: (score: number, suddenDeathWin: boolean) => {
    const { highScores, difficulty, shotsOnTarget, totalShots, maxCombo } = get()
    const accuracy = totalShots > 0 ? shotsOnTarget / totalShots : 0

    const entry: HighScore = {
      score,
      accuracy,
      maxCombo,
      difficulty,
      date: new Date().toLocaleDateString(),
      suddenDeathWin,
    }

    const updated = [...highScores, entry]
      .sort((a, b) => b.score - a.score)
      .slice(0, SCORING.maxHighScores)

    const isTopFive = updated.some(
      (e) => e === entry
    )

    if (isTopFive) {
      set({ highScores: updated })
      saveHighScores(updated)
    }

    return isTopFive
  },
}))

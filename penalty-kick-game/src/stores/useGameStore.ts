import { create } from 'zustand'
import type { Difficulty, GamePhase } from '../types'

interface GameStore {
  gamePhase: GamePhase
  difficulty: Difficulty
  setDifficulty: (d: Difficulty) => void
  startGame: () => void
  endGame: () => void
  restart: () => void
}

export const useGameStore = create<GameStore>((set) => ({
  gamePhase: 'start',
  difficulty: 'medium',
  setDifficulty: (d) => set({ difficulty: d }),
  startGame: () => set({ gamePhase: 'playing' }),
  endGame: () => set({ gamePhase: 'gameover' }),
  restart: () => set({ gamePhase: 'start' }),
}))

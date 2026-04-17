import { create } from 'zustand'
import { SOCCER_CONFIG } from './config'
import { useGameStore } from '../stores/useGameStore'

type SoccerPhase = 'aiming' | 'charging' | 'flying' | 'result' | 'done'
type KickResult = 'goal' | 'saved' | 'miss'

interface SoccerState {
  phase: SoccerPhase
  currentKick: number
  effectiveTotalKicks: number
  playerGoals: number
  opponentGoals: number
  aimX: number
  aimY: number
  power: number
  lastResult: KickResult | null
  keeperSlowed: boolean
  isSuddenDeath: boolean

  setAim: (x: number, y: number) => void
  startCharging: () => void
  setPower: (p: number) => void
  kick: () => { power: number; aimX: number; aimY: number }
  registerGoal: () => void
  registerSaved: () => void
  registerMiss: () => void
  nextKick: () => void
  setKeeperSlowed: (slowed: boolean) => void
  resetGame: (totalKicks?: number) => void
}

export const useSoccer = create<SoccerState>((set, get) => ({
  phase: 'aiming',
  currentKick: 1,
  effectiveTotalKicks: SOCCER_CONFIG.totalKicks,
  playerGoals: 0,
  opponentGoals: 0,
  aimX: 0,
  aimY: 1.2,
  power: 0,
  lastResult: null,
  keeperSlowed: false,
  isSuddenDeath: false,

  setAim: (x, y) => set({ aimX: x, aimY: y }),

  startCharging: () => set({ phase: 'charging', power: 0 }),

  setPower: (p) => set({ power: p }),

  kick: () => {
    const { power, aimX, aimY } = get()
    set({ phase: 'flying' })
    return { power, aimX, aimY }
  },

  registerGoal: () => {
    if (get().phase !== 'flying') return
    const gameStore = useGameStore.getState()
    gameStore.incrementCombo()
    gameStore.recordShot(true)
    set((s) => ({
      phase: 'result',
      lastResult: 'goal',
      playerGoals: s.playerGoals + 1,
    }))
  },

  registerSaved: () => {
    if (get().phase !== 'flying') return
    const gameStore = useGameStore.getState()
    gameStore.resetCombo()
    gameStore.incrementKeeperScore()
    gameStore.recordShot(true) // on target but saved
    set((s) => ({
      phase: 'result',
      lastResult: 'saved',
      opponentGoals: s.opponentGoals + 1,
    }))
  },

  registerMiss: () => {
    if (get().phase !== 'flying') return
    const gameStore = useGameStore.getState()
    gameStore.resetCombo()
    gameStore.recordShot(false) // off target
    set({ phase: 'result', lastResult: 'miss' })
  },

  nextKick: () => {
    const { currentKick, effectiveTotalKicks, playerGoals, opponentGoals } = get()

    if (currentKick >= effectiveTotalKicks) {
      // Check for sudden death: tied after all kicks
      if (playerGoals === opponentGoals) {
        // Enter or continue sudden death — add one more kick
        set((s) => ({
          isSuddenDeath: true,
          effectiveTotalKicks: s.effectiveTotalKicks + 1,
          currentKick: currentKick + 1,
          phase: 'aiming',
          aimX: 0,
          aimY: 1.2,
          power: 0,
          lastResult: null,
          keeperSlowed: false,
        }))
      } else {
        // Someone leads — game is over
        set({ phase: 'done' })
      }
    } else {
      set({
        currentKick: currentKick + 1,
        phase: 'aiming',
        aimX: 0,
        aimY: 1.2,
        power: 0,
        lastResult: null,
        keeperSlowed: false,
      })
    }
  },

  setKeeperSlowed: (slowed) => set({ keeperSlowed: slowed }),

  resetGame: (totalKicks?: number) => set({
    phase: 'aiming',
    currentKick: 1,
    effectiveTotalKicks: totalKicks ?? SOCCER_CONFIG.totalKicks,
    playerGoals: 0,
    opponentGoals: 0,
    aimX: 0,
    aimY: 1.2,
    power: 0,
    lastResult: null,
    keeperSlowed: false,
    isSuddenDeath: false,
  }),
}))

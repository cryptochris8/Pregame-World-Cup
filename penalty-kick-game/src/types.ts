export type Difficulty = 'easy' | 'medium' | 'hard'

export type AnimationState =
  | 'idle' | 'walk' | 'run' | 'charge' | 'throw'
  | 'kick' | 'swing' | 'celebrate' | 'disappointed'
  | 'jump' | 'sit' | 'interact'

export type GamePhase = 'start' | 'playing' | 'gameover'

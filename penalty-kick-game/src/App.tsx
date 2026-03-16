import { useEffect, Suspense } from 'react'
import { Canvas } from '@react-three/fiber'
import { useGameStore } from './stores/useGameStore'
import { loadSoccerAudio } from './core/AudioManager'
import { SoccerScene } from './game/SoccerScene'
import { StartScreen } from './ui/StartScreen'
import { GameOverScreen } from './ui/GameOverScreen'
import { SoccerHUD } from './ui/SoccerHUD'

export function App() {
  const gamePhase = useGameStore((s) => s.gamePhase)

  // Load audio once on mount
  useEffect(() => {
    loadSoccerAudio()
  }, [])

  return (
    <div style={{ width: '100%', height: '100%', position: 'relative' }}>
      {gamePhase === 'start' && <StartScreen />}
      {gamePhase === 'gameover' && <GameOverScreen />}
      {gamePhase === 'playing' && <SoccerHUD />}

      <Canvas
        shadows
        camera={{ fov: 60, near: 0.1, far: 500, position: [0, 2, 6] }}
        style={{
          width: '100%',
          height: '100%',
          display: gamePhase === 'start' ? 'none' : 'block',
        }}
      >
        <Suspense fallback={null}>
          {gamePhase !== 'start' && <SoccerScene />}
        </Suspense>
      </Canvas>
    </div>
  )
}

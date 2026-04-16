import { useGameStore } from '../stores/useGameStore'
import type { Difficulty } from '../types'

const isTouchDevice = typeof window !== 'undefined' && ('ontouchstart' in window || navigator.maxTouchPoints > 0)

const DIFFICULTIES: { value: Difficulty; label: string; desc: string }[] = [
  { value: 'easy', label: 'Easy', desc: '7 kicks, slower keeper' },
  { value: 'medium', label: 'Medium', desc: '5 kicks, balanced' },
  { value: 'hard', label: 'Hard', desc: '4 kicks, fast keeper' },
]

export function StartScreen() {
  const setDifficulty = useGameStore((s) => s.setDifficulty)
  const startGame = useGameStore((s) => s.startGame)
  const difficulty = useGameStore((s) => s.difficulty)

  const handleStart = () => {
    startGame()
  }

  return (
    <div style={{
      position: 'absolute',
      inset: 0,
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      background: 'linear-gradient(135deg, #0a1628 0%, #1a3a5c 50%, #0d2137 100%)',
      zIndex: 100,
    }}>
      <h1 style={{
        fontSize: '3.5rem',
        fontWeight: 900,
        marginBottom: '0.5rem',
        background: 'linear-gradient(135deg, #4CAF50, #81C784)',
        WebkitBackgroundClip: 'text',
        WebkitTextFillColor: 'transparent',
        textShadow: 'none',
        letterSpacing: '-1px',
      }}>
        Penalty Kick
      </h1>
      <p style={{
        fontSize: '1.1rem',
        color: 'rgba(255,255,255,0.6)',
        marginBottom: '2.5rem',
      }}>
        Score as many goals as you can!
      </p>

      <div style={{
        display: 'flex',
        flexWrap: 'wrap',
        justifyContent: 'center',
        gap: '16px',
        marginBottom: '2rem',
      }}>
        {DIFFICULTIES.map((d) => (
          <button
            key={d.value}
            onClick={() => setDifficulty(d.value)}
            style={{
              padding: '16px 28px',
              borderRadius: '12px',
              border: difficulty === d.value ? '2px solid #4CAF50' : '2px solid rgba(255,255,255,0.15)',
              background: difficulty === d.value
                ? 'rgba(76, 175, 80, 0.2)'
                : 'rgba(255,255,255,0.05)',
              color: '#fff',
              cursor: 'pointer',
              fontSize: '1rem',
              fontWeight: 700,
              transition: 'all 0.2s',
              minWidth: '130px',
            }}
          >
            <div>{d.label}</div>
            <div style={{
              fontSize: '0.75rem',
              fontWeight: 400,
              color: 'rgba(255,255,255,0.5)',
              marginTop: '4px',
            }}>
              {d.desc}
            </div>
          </button>
        ))}
      </div>

      <button
        onClick={handleStart}
        style={{
          padding: '16px 64px',
          borderRadius: '12px',
          border: 'none',
          background: 'linear-gradient(135deg, #4CAF50, #388E3C)',
          color: '#fff',
          fontSize: '1.2rem',
          fontWeight: 700,
          cursor: 'pointer',
          letterSpacing: '2px',
          textTransform: 'uppercase',
          boxShadow: '0 4px 20px rgba(76, 175, 80, 0.4)',
          transition: 'transform 0.15s, box-shadow 0.15s',
        }}
        onMouseEnter={(e) => {
          e.currentTarget.style.transform = 'scale(1.05)'
          e.currentTarget.style.boxShadow = '0 6px 30px rgba(76, 175, 80, 0.6)'
        }}
        onMouseLeave={(e) => {
          e.currentTarget.style.transform = 'scale(1)'
          e.currentTarget.style.boxShadow = '0 4px 20px rgba(76, 175, 80, 0.4)'
        }}
      >
        Play
      </button>

      <div style={{
        position: 'absolute',
        bottom: '24px',
        color: 'rgba(255,255,255,0.3)',
        fontSize: '0.8rem',
      }}>
        {isTouchDevice
          ? 'Drag to aim | Tap & hold to charge | Release to kick'
          : 'Mouse to aim | Click/Space to charge & release to kick'}
      </div>
    </div>
  )
}

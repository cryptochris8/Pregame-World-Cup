import { useGameStore } from '../stores/useGameStore'
import { useSoccer } from '../game/useSoccer'
import { getTotalKicks } from '../game/config'

export function GameOverScreen() {
  const restart = useGameStore((s) => s.restart)
  const difficulty = useGameStore((s) => s.difficulty)
  const playerGoals = useSoccer((s) => s.playerGoals)
  const opponentGoals = useSoccer((s) => s.opponentGoals)
  const totalKicks = getTotalKicks(difficulty)

  const isWin = playerGoals > opponentGoals

  return (
    <div style={{
      position: 'absolute',
      inset: 0,
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      background: 'rgba(0,0,0,0.85)',
      zIndex: 100,
    }}>
      <h1 style={{
        fontSize: '3rem',
        fontWeight: 900,
        marginBottom: '0.5rem',
        color: isWin ? '#2ECC71' : '#E74C3C',
      }}>
        {isWin ? 'You Win!' : 'Game Over'}
      </h1>

      <div style={{
        display: 'flex',
        gap: '40px',
        marginBottom: '1.5rem',
        alignItems: 'center',
      }}>
        <div style={{ textAlign: 'center' }}>
          <div style={{ fontSize: '3rem', fontWeight: 900, color: '#2ECC71' }}>{playerGoals}</div>
          <div style={{ fontSize: '0.9rem', color: 'rgba(255,255,255,0.6)' }}>Your Goals</div>
        </div>
        <div style={{
          fontSize: '1.5rem',
          fontWeight: 700,
          color: 'rgba(255,255,255,0.4)',
        }}>
          vs
        </div>
        <div style={{ textAlign: 'center' }}>
          <div style={{ fontSize: '3rem', fontWeight: 900, color: '#E74C3C' }}>{opponentGoals}</div>
          <div style={{ fontSize: '0.9rem', color: 'rgba(255,255,255,0.6)' }}>GK Saves</div>
        </div>
      </div>

      <p style={{
        fontSize: '1rem',
        color: 'rgba(255,255,255,0.5)',
        marginBottom: '2rem',
      }}>
        {playerGoals} / {totalKicks} penalties scored ({difficulty})
      </p>

      <button
        onClick={restart}
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
        Play Again
      </button>
    </div>
  )
}

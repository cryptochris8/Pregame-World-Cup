import { useGameStore } from '../stores/useGameStore'
import { useSoccer } from '../game/useSoccer'
import { useEffect, useState } from 'react'

export function GameOverScreen() {
  const restart = useGameStore((s) => s.restart)
  const difficulty = useGameStore((s) => s.difficulty)
  const playerGoals = useSoccer((s) => s.playerGoals)
  const keeperScore = useGameStore((s) => s.keeperScore)
  const shotsOnTarget = useGameStore((s) => s.shotsOnTarget)
  const totalShots = useGameStore((s) => s.totalShots)
  const maxCombo = useGameStore((s) => s.maxCombo)
  const highScores = useGameStore((s) => s.highScores)
  const submitHighScore = useGameStore((s) => s.submitHighScore)
  const isSuddenDeath = useSoccer((s) => s.isSuddenDeath)

  const isWin = playerGoals > keeperScore
  const accuracyPct = totalShots > 0 ? Math.round((shotsOnTarget / totalShots) * 100) : 0
  const suddenDeathWin = isWin && isSuddenDeath

  const [isNewHighScore, setIsNewHighScore] = useState(false)

  useEffect(() => {
    const result = submitHighScore(playerGoals, suddenDeathWin)
    setIsNewHighScore(result)
    // Run once on mount
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

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
      overflow: 'auto',
    }}>
      {/* Sudden death win banner */}
      {suddenDeathWin && (
        <div style={{
          fontSize: '1rem',
          fontWeight: 800,
          color: '#FF8F00',
          letterSpacing: '3px',
          textTransform: 'uppercase',
          marginBottom: '4px',
        }}>
          {'\u26A1'} SUDDEN DEATH WIN! {'\u26A1'}
        </div>
      )}

      <h1 style={{
        fontSize: '3rem',
        fontWeight: 900,
        marginBottom: '0.5rem',
        color: isWin ? '#2ECC71' : '#E74C3C',
      }}>
        {isWin ? 'You Win!' : 'Game Over'}
      </h1>

      {isNewHighScore && (
        <div style={{
          fontSize: '0.85rem',
          fontWeight: 700,
          color: '#FFD600',
          marginBottom: '0.5rem',
          letterSpacing: '2px',
        }}>
          NEW HIGH SCORE!
        </div>
      )}

      {/* Score display */}
      <div style={{
        display: 'flex',
        gap: '40px',
        marginBottom: '1rem',
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
          <div style={{ fontSize: '3rem', fontWeight: 900, color: '#E74C3C' }}>{keeperScore}</div>
          <div style={{ fontSize: '0.9rem', color: 'rgba(255,255,255,0.6)' }}>GK Saves</div>
        </div>
      </div>

      {/* Stats row */}
      <div style={{
        display: 'flex',
        gap: '24px',
        marginBottom: '1.5rem',
      }}>
        <StatBadge label="Accuracy" value={`${accuracyPct}%`} />
        <StatBadge label="Best Streak" value={String(maxCombo)} />
        <StatBadge label="Difficulty" value={difficulty.charAt(0).toUpperCase() + difficulty.slice(1)} />
      </div>

      {/* Mini leaderboard */}
      {highScores.length > 0 && (
        <div style={{
          background: 'rgba(255,255,255,0.05)',
          borderRadius: '12px',
          padding: '12px 24px',
          marginBottom: '1.5rem',
          minWidth: '260px',
          border: '1px solid rgba(255,255,255,0.08)',
        }}>
          <div style={{
            fontSize: '0.75rem',
            color: 'rgba(255,255,255,0.4)',
            textTransform: 'uppercase',
            letterSpacing: '1px',
            marginBottom: '8px',
            textAlign: 'center',
          }}>
            Top Scores
          </div>
          {highScores.map((hs, i) => (
            <div key={i} style={{
              display: 'flex',
              justifyContent: 'space-between',
              alignItems: 'center',
              padding: '4px 0',
              borderBottom: i < highScores.length - 1 ? '1px solid rgba(255,255,255,0.06)' : 'none',
            }}>
              <span style={{ color: 'rgba(255,255,255,0.5)', fontSize: '0.8rem', width: '20px' }}>
                {i + 1}.
              </span>
              <span style={{ color: '#fff', fontWeight: 700, fontSize: '0.9rem', flex: 1 }}>
                {hs.score} goal{hs.score !== 1 ? 's' : ''}
              </span>
              <span style={{ color: 'rgba(255,255,255,0.4)', fontSize: '0.75rem' }}>
                {Math.round(hs.accuracy * 100)}% &middot; {hs.difficulty}
                {hs.suddenDeathWin ? ' \u26A1' : ''}
              </span>
            </div>
          ))}
        </div>
      )}

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

function StatBadge({ label, value }: { label: string; value: string }) {
  return (
    <div style={{
      background: 'rgba(255,255,255,0.06)',
      borderRadius: '10px',
      padding: '8px 16px',
      textAlign: 'center',
      border: '1px solid rgba(255,255,255,0.08)',
    }}>
      <div style={{ fontSize: '1.1rem', fontWeight: 800, color: '#fff' }}>{value}</div>
      <div style={{ fontSize: '0.65rem', color: 'rgba(255,255,255,0.4)', textTransform: 'uppercase', letterSpacing: '1px' }}>{label}</div>
    </div>
  )
}

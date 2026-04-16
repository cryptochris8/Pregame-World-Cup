import { useSoccer } from '../game/useSoccer'
import { useGameStore } from '../stores/useGameStore'
import { SOCCER_CONFIG, getTotalKicks } from '../game/config'
import { PowerMeter } from '../components/PowerMeter'

const isTouchDevice = typeof window !== 'undefined' && ('ontouchstart' in window || navigator.maxTouchPoints > 0)

export function SoccerHUD() {
  const phase = useSoccer((s) => s.phase)
  const currentKick = useSoccer((s) => s.currentKick)
  const playerGoals = useSoccer((s) => s.playerGoals)
  const opponentGoals = useSoccer((s) => s.opponentGoals)
  const power = useSoccer((s) => s.power)
  const difficulty = useGameStore((s) => s.difficulty)
  const totalKicks = getTotalKicks(difficulty)

  return (
    <>
      {/* Scoreboard */}
      <div style={{
        position: 'absolute',
        top: '20px',
        left: '50%',
        transform: 'translateX(-50%)',
        display: 'flex',
        gap: '24px',
        alignItems: 'center',
        background: 'rgba(0,0,0,0.6)',
        padding: '12px 32px',
        borderRadius: '16px',
        backdropFilter: 'blur(10px)',
        border: '1px solid rgba(255,255,255,0.1)',
        zIndex: 50,
        pointerEvents: 'none',
      }}>
        <div style={{ textAlign: 'center' }}>
          <div style={{ fontSize: '2rem', fontWeight: 900, color: '#2ECC71' }}>{playerGoals}</div>
          <div style={{ fontSize: '0.7rem', color: 'rgba(255,255,255,0.5)', textTransform: 'uppercase', letterSpacing: '1px' }}>You</div>
        </div>
        <div style={{
          fontSize: '0.9rem',
          color: 'rgba(255,255,255,0.4)',
          fontWeight: 600,
        }}>
          Kick {currentKick}/{totalKicks}
        </div>
        <div style={{ textAlign: 'center' }}>
          <div style={{ fontSize: '2rem', fontWeight: 900, color: '#E74C3C' }}>{opponentGoals}</div>
          <div style={{ fontSize: '0.7rem', color: 'rgba(255,255,255,0.5)', textTransform: 'uppercase', letterSpacing: '1px' }}>GK</div>
        </div>
      </div>

      {/* Instructions */}
      {phase === 'aiming' && (
        <div style={{
          position: 'absolute',
          bottom: '40px',
          left: '50%',
          transform: 'translateX(-50%)',
          color: 'rgba(255,255,255,0.7)',
          fontSize: '0.9rem',
          textAlign: 'center',
          pointerEvents: 'none',
          zIndex: 50,
          textShadow: '0 2px 8px rgba(0,0,0,0.8)',
        }}>
          {isTouchDevice
            ? 'Drag to aim | Tap & hold to charge | Release to kick'
            : 'Move mouse to aim | Click or Space to charge'}
        </div>
      )}

      {phase === 'charging' && (
        <div style={{
          position: 'absolute',
          bottom: '40px',
          left: '50%',
          transform: 'translateX(-50%)',
          color: 'rgba(255,255,255,0.7)',
          fontSize: '0.9rem',
          textAlign: 'center',
          pointerEvents: 'none',
          zIndex: 50,
          textShadow: '0 2px 8px rgba(0,0,0,0.8)',
        }}>
          Release to kick!
        </div>
      )}

      {/* Power meter */}
      <PowerMeter
        power={power}
        maxPower={SOCCER_CONFIG.maxKickPower}
        isCharging={phase === 'charging'}
      />
    </>
  )
}

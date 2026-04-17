import { useSoccer } from '../game/useSoccer'
import { useGameStore } from '../stores/useGameStore'
import { SOCCER_CONFIG, getTotalKicks, SCORING } from '../game/config'
import { PowerMeter } from '../components/PowerMeter'

const isTouchDevice = typeof window !== 'undefined' && ('ontouchstart' in window || navigator.maxTouchPoints > 0)

export function SoccerHUD() {
  const phase = useSoccer((s) => s.phase)
  const currentKick = useSoccer((s) => s.currentKick)
  const playerGoals = useSoccer((s) => s.playerGoals)
  const isSuddenDeath = useSoccer((s) => s.isSuddenDeath)
  const power = useSoccer((s) => s.power)
  const difficulty = useGameStore((s) => s.difficulty)
  const keeperScore = useGameStore((s) => s.keeperScore)
  const combo = useGameStore((s) => s.combo)
  const totalKicks = getTotalKicks(difficulty)

  const comboLabel =
    combo >= SCORING.comboUnstoppableThreshold
      ? '\u26A1 Unstoppable!'
      : combo >= SCORING.comboFireThreshold
        ? '\uD83D\uDD25 On Fire!'
        : null

  return (
    <>
      {/* Sudden death banner */}
      {isSuddenDeath && (
        <div style={{
          position: 'absolute',
          top: '0px',
          left: '50%',
          transform: 'translateX(-50%)',
          background: 'linear-gradient(135deg, #FF6F00, #FF8F00)',
          padding: '6px 28px',
          borderRadius: '0 0 12px 12px',
          zIndex: 55,
          pointerEvents: 'none',
          boxShadow: '0 4px 20px rgba(255,111,0,0.5)',
        }}>
          <span style={{
            fontSize: '0.85rem',
            fontWeight: 800,
            color: '#fff',
            letterSpacing: '3px',
            textTransform: 'uppercase',
          }}>
            {'\u26A1'} SUDDEN DEATH
          </span>
        </div>
      )}

      {/* Scoreboard */}
      <div style={{
        position: 'absolute',
        top: isSuddenDeath ? '46px' : '20px',
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
        <div style={{ textAlign: 'center', minWidth: '48px' }}>
          <div style={{ fontSize: '0.65rem', color: 'rgba(255,255,255,0.5)', textTransform: 'uppercase', letterSpacing: '1px', marginBottom: '2px' }}>YOU</div>
          <div style={{ fontSize: '2rem', fontWeight: 900, color: '#2ECC71' }}>{playerGoals}</div>
        </div>
        <div style={{
          textAlign: 'center',
        }}>
          <div style={{
            fontSize: '0.9rem',
            color: 'rgba(255,255,255,0.4)',
            fontWeight: 600,
          }}>
            {isSuddenDeath ? 'SD' : `Kick ${currentKick}/${totalKicks}`}
          </div>
        </div>
        <div style={{ textAlign: 'center', minWidth: '48px' }}>
          <div style={{ fontSize: '0.65rem', color: 'rgba(255,255,255,0.5)', textTransform: 'uppercase', letterSpacing: '1px', marginBottom: '2px' }}>GK</div>
          <div style={{ fontSize: '2rem', fontWeight: 900, color: '#E74C3C' }}>{keeperScore}</div>
        </div>
      </div>

      {/* Combo badge */}
      {comboLabel && (
        <div style={{
          position: 'absolute',
          top: isSuddenDeath ? '120px' : '94px',
          left: '50%',
          transform: 'translateX(-50%)',
          background: combo >= SCORING.comboUnstoppableThreshold
            ? 'linear-gradient(135deg, #7C4DFF, #536DFE)'
            : 'linear-gradient(135deg, #FF6D00, #FF9100)',
          padding: '4px 18px',
          borderRadius: '20px',
          zIndex: 50,
          pointerEvents: 'none',
          boxShadow: combo >= SCORING.comboUnstoppableThreshold
            ? '0 2px 12px rgba(124,77,255,0.5)'
            : '0 2px 12px rgba(255,109,0,0.5)',
        }}>
          <span style={{
            fontSize: '0.8rem',
            fontWeight: 700,
            color: '#fff',
          }}>
            {comboLabel}
          </span>
        </div>
      )}

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

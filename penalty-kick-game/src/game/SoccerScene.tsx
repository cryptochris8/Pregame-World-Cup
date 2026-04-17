import { useEffect, useCallback, useRef, useMemo, useState } from 'react'
import { useFrame, useThree } from '@react-three/fiber'
import * as THREE from 'three'
import { Skybox } from '../components/Skybox'
import { RigidBody, type RapierRigidBody } from '@react-three/rapier'
import { useGameStore } from '../stores/useGameStore'
import { PhysicsProvider } from '../core/PhysicsProvider'
import { Field } from './Field'
import { Goal } from './Goal'
import { Goalkeeper } from './Goalkeeper'
import { useSoccer } from './useSoccer'
import { SOCCER_CONFIG, getTotalKicks } from './config'
import { ScorePopup } from '../components/ScorePopup'
import { Confetti } from '../components/Confetti'
import { audioManager } from '../core/AudioManager'
import { BallTrail } from '../components/BallTrail'
import { HytopiaAvatar } from '../components/HytopiaAvatar'
import type { AnimationState } from '../types'
import { Suspense } from 'react'

const PLAYER_SKIN = `${import.meta.env.BASE_URL}skins/avatars/1.png`

interface PopupData {
  id: number
  text: string
  position: [number, number, number]
  color: string
}

function SoccerBall() {
  const ballRef = useRef<RapierRigidBody>(null)
  const shotTimerRef = useRef<number | null>(null)
  const { camera } = useThree()

  const camTargetPos = useRef(new THREE.Vector3(0, 2, 6))
  const camLookAtTarget = useRef(new THREE.Vector3(0, 1.2, -8))

  const phase = useSoccer((s) => s.phase)
  const setAim = useSoccer((s) => s.setAim)
  const startCharging = useSoccer((s) => s.startCharging)
  const setPower = useSoccer((s) => s.setPower)
  const kick = useSoccer((s) => s.kick)
  const registerSaved = useSoccer((s) => s.registerSaved)
  const registerMiss = useSoccer((s) => s.registerMiss)

  // Initialize camera
  useEffect(() => {
    camera.position.set(0, 2, 6)
    camera.lookAt(0, 1.2, -8)
  }, [camera])

  // Shot timeout
  useEffect(() => {
    if (phase === 'flying') {
      shotTimerRef.current = window.setTimeout(() => {
        const currentPhase = useSoccer.getState().phase
        if (currentPhase === 'flying') {
          registerMiss()
        }
      }, 5000)
    }
    return () => {
      if (shotTimerRef.current) {
        clearTimeout(shotTimerRef.current)
        shotTimerRef.current = null
      }
    }
  }, [phase, registerMiss])

  // Power charge + ball physics + dynamic camera
  useFrame((state) => {
    if (phase === 'charging') {
      const t = state.clock.elapsedTime * 3
      const normalized = (Math.sin(t) + 1) / 2
      setPower(SOCCER_CONFIG.minKickPower + normalized * (SOCCER_CONFIG.maxKickPower - SOCCER_CONFIG.minKickPower))
    }

    if (phase === 'aiming' && ballRef.current) {
      const [bx, by, bz] = SOCCER_CONFIG.ballStartPosition
      ballRef.current.setTranslation({ x: bx, y: by, z: bz }, true)
      ballRef.current.setLinvel({ x: 0, y: 0, z: 0 }, true)
      ballRef.current.setAngvel({ x: 0, y: 0, z: 0 }, true)
    }

    if (phase === 'flying' && ballRef.current) {
      const vel = ballRef.current.linvel()
      const speed = Math.sqrt(vel.x * vel.x + vel.y * vel.y + vel.z * vel.z)
      const pos = ballRef.current.translation()

      if (speed < 0.3 || pos.z < -12 || pos.y < -2) {
        if (pos.z < -12 || pos.y < -2 || pos.y > SOCCER_CONFIG.goalHeight + 1) {
          registerMiss()
        } else if (pos.x > -SOCCER_CONFIG.goalWidth / 2 && pos.x < SOCCER_CONFIG.goalWidth / 2 && pos.z < -7) {
          registerSaved()
        } else {
          registerMiss()
        }
      }
    }

    // Dynamic camera
    if (phase === 'flying' && ballRef.current) {
      const pos = ballRef.current.translation()
      camTargetPos.current.set(
        pos.x * 0.2,
        2 + pos.y * 0.15,
        Math.max(pos.z + 5, -1)
      )
      camLookAtTarget.current.set(pos.x, pos.y, pos.z)
    } else if (phase === 'aiming' || phase === 'charging') {
      camTargetPos.current.set(0, 2, 6)
      camLookAtTarget.current.set(0, 1.2, -8)
    }

    camera.position.lerp(camTargetPos.current, 0.05)
    camera.lookAt(camLookAtTarget.current)
  })

  // Pointer Events (unified mouse + touch) + keyboard controls
  useEffect(() => {
    // Track whether the current pointer interaction is touch-based
    let isTouchPointer = false

    const handlePointerMove = (e: PointerEvent) => {
      const currentPhase = useSoccer.getState().phase
      // For mouse: only aim during 'aiming' phase
      // For touch: allow aim adjustment during both 'aiming' and 'charging'
      if (currentPhase === 'aiming' || (isTouchPointer && currentPhase === 'charging')) {
        const x = (e.clientX / window.innerWidth - 0.5) * SOCCER_CONFIG.maxAimAngleX * 2
        const y = (1 - e.clientY / window.innerHeight) * SOCCER_CONFIG.maxAimAngleY
        setAim(x, Math.max(0.3, y))
      }
    }

    const handlePointerDown = (e: PointerEvent) => {
      if (useGameStore.getState().gamePhase !== 'playing') return
      isTouchPointer = e.pointerType === 'touch'
      const currentPhase = useSoccer.getState().phase
      if (currentPhase === 'aiming') {
        // For touch, update aim position on tap before charging
        if (e.pointerType === 'touch') {
          const x = (e.clientX / window.innerWidth - 0.5) * SOCCER_CONFIG.maxAimAngleX * 2
          const y = (1 - e.clientY / window.innerHeight) * SOCCER_CONFIG.maxAimAngleY
          setAim(x, Math.max(0.3, y))
        }
        startCharging()
      }
    }

    const handlePointerUp = (_e: PointerEvent) => {
      if (useGameStore.getState().gamePhase !== 'playing') return
      const currentPhase = useSoccer.getState().phase
      if (currentPhase === 'charging') {
        const { power: p, aimX: ax, aimY: ay } = kick()
        launchBall(p, ax, ay)
      }
      isTouchPointer = false
    }

    const handleKeyDown = (e: KeyboardEvent) => {
      if (useGameStore.getState().gamePhase !== 'playing') return
      if (e.code === 'Space') {
        e.preventDefault()
        if (phase === 'aiming') startCharging()
      }
      if (phase === 'aiming') {
        const state = useSoccer.getState()
        const step = 0.3
        if (e.code === 'ArrowLeft') setAim(state.aimX - step, state.aimY)
        if (e.code === 'ArrowRight') setAim(state.aimX + step, state.aimY)
        if (e.code === 'ArrowUp') setAim(state.aimX, Math.min(SOCCER_CONFIG.maxAimAngleY, state.aimY + step))
        if (e.code === 'ArrowDown') setAim(state.aimX, Math.max(0.3, state.aimY - step))
      }
    }

    const handleKeyUp = (e: KeyboardEvent) => {
      if (useGameStore.getState().gamePhase !== 'playing') return
      if (e.code === 'Space' && phase === 'charging') {
        const { power: p, aimX: ax, aimY: ay } = kick()
        launchBall(p, ax, ay)
      }
    }

    // Prevent default touch behaviors (scroll, zoom) so pointer events fire reliably
    const preventTouchDefault = (e: TouchEvent) => {
      if (useGameStore.getState().gamePhase === 'playing') {
        e.preventDefault()
      }
    }

    window.addEventListener('pointermove', handlePointerMove)
    window.addEventListener('pointerdown', handlePointerDown)
    window.addEventListener('pointerup', handlePointerUp)
    window.addEventListener('keydown', handleKeyDown)
    window.addEventListener('keyup', handleKeyUp)
    // Passive: false is required to allow preventDefault on touch events
    window.addEventListener('touchstart', preventTouchDefault, { passive: false })
    window.addEventListener('touchmove', preventTouchDefault, { passive: false })
    return () => {
      window.removeEventListener('pointermove', handlePointerMove)
      window.removeEventListener('pointerdown', handlePointerDown)
      window.removeEventListener('pointerup', handlePointerUp)
      window.removeEventListener('keydown', handleKeyDown)
      window.removeEventListener('keyup', handleKeyUp)
      window.removeEventListener('touchstart', preventTouchDefault)
      window.removeEventListener('touchmove', preventTouchDefault)
    }
  }, [phase, setAim, startCharging, kick])

  const launchBall = useCallback((p: number, ax: number, ay: number) => {
    if (!ballRef.current) return
    audioManager.play('kick')
    const [bx, by, bz] = SOCCER_CONFIG.ballStartPosition
    ballRef.current.setTranslation({ x: bx, y: by, z: bz }, true)

    const targetZ = SOCCER_CONFIG.goalPosition[2]
    const dz = targetZ - bz
    const dx = ax
    const dy = ay

    const dist = Math.sqrt(dx * dx + dy * dy + dz * dz)
    ballRef.current.setLinvel({
      x: (dx / dist) * p,
      y: (dy / dist) * p * 0.7 + 2,
      z: (dz / dist) * p,
    }, true)
    ballRef.current.setAngvel({
      x: -p * 2,
      y: ax * 3,
      z: 0,
    }, true)
  }, [])

  return (
    <>
      <RigidBody
        ref={ballRef}
        colliders="ball"
        mass={SOCCER_CONFIG.ballMass}
        restitution={SOCCER_CONFIG.ballRestitution}
        linearDamping={SOCCER_CONFIG.ballLinearDamping}
        angularDamping={SOCCER_CONFIG.ballAngularDamping}
        friction={SOCCER_CONFIG.ballFriction}
        position={SOCCER_CONFIG.ballStartPosition}
        name="soccerball"
      >
        <mesh castShadow>
          <icosahedronGeometry args={[SOCCER_CONFIG.ballRadius, 1]} />
          <meshStandardMaterial color="#fff" roughness={0.5} />
        </mesh>
      </RigidBody>

      <BallTrail
        getPosition={() => ballRef.current?.translation() ?? null}
        color="#ffffff"
        isActive={phase === 'flying'}
      />
    </>
  )
}

export function SoccerScene() {
  const gamePhase = useGameStore((s) => s.gamePhase)
  const difficulty = useGameStore((s) => s.difficulty)
  const endGame = useGameStore((s) => s.endGame)
  const totalKicks = useMemo(() => getTotalKicks(difficulty), [difficulty])

  const {
    phase: soccerPhase,
    currentKick,
    aimX,
    aimY,
    lastResult,
    keeperSlowed,
    nextKick,
    resetGame,
  } = useSoccer()

  // Popup & confetti state (inlined from useGameScene)
  const [popups, setPopups] = useState<PopupData[]>([])
  const [showConfetti, setShowConfetti] = useState(false)
  const popupIdRef = useRef(0)

  const addPopup = useCallback((text: string, position: [number, number, number], color: string) => {
    const id = popupIdRef.current++
    setPopups((prev) => [...prev, { id, text, position, color }])
  }, [])

  const removePopup = useCallback((id: number) => {
    setPopups((prev) => prev.filter((p) => p.id !== id))
  }, [])

  const triggerConfetti = useCallback(() => {
    setShowConfetti(true)
    audioManager.play('confetti')
    setTimeout(() => setShowConfetti(false), 3500)
  }, [])

  // Initialize game
  useEffect(() => {
    resetGame(totalKicks)
    audioManager.playMusic('soccer')
    audioManager.playVoice('gameStart')
    return () => {
      audioManager.stopMusic()
    }
  }, [totalKicks, resetGame])

  const [reactionAnim, setReactionAnim] = useState<AnimationState | null>(null)
  const prevPhaseRef = useRef(soccerPhase)

  const avatarAnimation: AnimationState = useMemo(() => {
    if (reactionAnim) return reactionAnim
    if (soccerPhase === 'charging') return 'charge'
    return 'idle'
  }, [reactionAnim, soccerPhase])

  // Detect kick moment
  useEffect(() => {
    if (soccerPhase === 'flying' && prevPhaseRef.current === 'charging') {
      setReactionAnim('kick')
      const timer = setTimeout(() => setReactionAnim(null), 800)
      return () => clearTimeout(timer)
    }
    prevPhaseRef.current = soccerPhase
  }, [soccerPhase])

  // Celebrate/disappointed on result
  useEffect(() => {
    if (soccerPhase !== 'result' || !lastResult) return
    if (lastResult === 'goal') {
      setReactionAnim('celebrate')
    } else {
      setReactionAnim('disappointed')
    }
    const timer = setTimeout(() => setReactionAnim(null), 2000)
    return () => clearTimeout(timer)
  }, [soccerPhase, lastResult])

  const handleGoalScored = useCallback(() => {
    useSoccer.getState().registerGoal()
  }, [])

  const resultHandled = useRef(false)

  // Handle result phase
  useEffect(() => {
    if (soccerPhase === 'result' && !resultHandled.current) {
      resultHandled.current = true

      let text = ''
      let color = '#F7C948'

      if (lastResult === 'goal') {
        text = 'GOAL!'
        color = '#2ECC71'
        audioManager.play('goalCheer')
        audioManager.play('goalReaction')
        const goalVoices = ['whatAGoal', 'whatABeauty', 'crowdGoesWild'] as const
        audioManager.playVoice(goalVoices[Math.floor(Math.random() * goalVoices.length)])
        triggerConfetti()
      } else if (lastResult === 'saved') {
        text = 'Saved! GK +1'
        color = '#E74C3C'
        const saveVoices = ['beautifulSave', 'greatSave'] as const
        audioManager.playVoice(saveVoices[Math.floor(Math.random() * saveVoices.length)])
      } else {
        text = 'Wide!'
        color = '#888'
        audioManager.play('whistle')
        const missVoices = ['nearMiss', 'soClose'] as const
        audioManager.playVoice(missVoices[Math.floor(Math.random() * missVoices.length)])
      }

      addPopup(text, [0, 3, -5], color)

      setTimeout(() => {
        nextKick()
      }, 2500)
    }

    if (soccerPhase !== 'result') {
      resultHandled.current = false
    }
  }, [soccerPhase, lastResult, currentKick, triggerConfetti, addPopup, nextKick])

  // Game over
  useEffect(() => {
    if (soccerPhase === 'done') {
      audioManager.playVoice('itsAllOver')
      endGame()
    }
  }, [soccerPhase, endGame])

  return (
    <>
      <ambientLight intensity={0.5} />
      <directionalLight
        position={[5, 15, 10]}
        intensity={1.3}
        castShadow
        shadow-mapSize-width={2048}
        shadow-mapSize-height={2048}
      />
      <Skybox />
      <fog attach="fog" args={['#87CEEB', 30, 60]} />

      <PhysicsProvider paused={gamePhase !== 'playing'}>
        <Field />
        <Goal onGoalScored={handleGoalScored} />
        <Goalkeeper
          difficulty={difficulty}
          ballAimX={aimX}
          ballAimY={aimY}
          isBallKicked={soccerPhase === 'flying'}
          isSlowed={keeperSlowed}
        />
        <SoccerBall />

        {/* Player avatar */}
        <Suspense fallback={null}>
          <group position={[0, 0, 3]} rotation={[0, 0, 0]}>
            <HytopiaAvatar key={PLAYER_SKIN} skinUrl={PLAYER_SKIN} animation={avatarAnimation} scale={1} />
          </group>
        </Suspense>
      </PhysicsProvider>

      {popups.map((popup) => (
        <ScorePopup
          key={popup.id}
          text={popup.text}
          position={popup.position}
          color={popup.color}
          onComplete={() => removePopup(popup.id)}
        />
      ))}

      {showConfetti && <Confetti position={[0, 2, -8]} />}

      {soccerPhase === 'aiming' && (
        <mesh position={[aimX, aimY, SOCCER_CONFIG.goalPosition[2] + 0.5]}>
          <ringGeometry args={[0.15, 0.2, 16]} />
          <meshBasicMaterial color="#FF6B35" transparent opacity={0.8} />
        </mesh>
      )}
    </>
  )
}

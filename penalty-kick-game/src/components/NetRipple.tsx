import { useRef } from 'react'
import { useFrame } from '@react-three/fiber'
import * as THREE from 'three'
import { SOCCER_CONFIG } from '../game/config'

interface NetRippleProps {
  /** Whether ripple effect is active */
  active: boolean
}

/**
 * A brief visual ripple/highlight on the goal net when the ball enters.
 * Renders a glowing plane behind the net that pulses and fades.
 */
export function NetRipple({ active }: NetRippleProps) {
  const meshRef = useRef<THREE.Mesh>(null)
  const startTime = useRef(-1)
  const duration = 0.5 // seconds

  useFrame((state) => {
    if (!meshRef.current) return
    const mat = meshRef.current.material as THREE.MeshBasicMaterial

    if (!active) {
      mat.opacity = 0
      startTime.current = -1
      return
    }

    if (startTime.current < 0) {
      startTime.current = state.clock.elapsedTime
    }

    const elapsed = state.clock.elapsedTime - startTime.current
    if (elapsed > duration) {
      mat.opacity = 0
      return
    }

    const progress = elapsed / duration
    // Pulse: quick rise then decay
    const pulse = Math.sin(progress * Math.PI) * (1 - progress * 0.5)
    mat.opacity = pulse * 0.5

    // Slight scale wobble to simulate net distortion
    const wobble = 1 + Math.sin(elapsed * 25) * 0.03 * (1 - progress)
    meshRef.current.scale.set(wobble, wobble, 1)
  })

  const { goalWidth, goalHeight, goalDepth, goalPosition } = SOCCER_CONFIG

  return (
    <mesh
      ref={meshRef}
      position={[
        goalPosition[0],
        goalPosition[1] + goalHeight / 2,
        goalPosition[2] - goalDepth / 2 + 0.05,
      ]}
    >
      <planeGeometry args={[goalWidth * 0.95, goalHeight * 0.95]} />
      <meshBasicMaterial
        color="#00ff88"
        transparent
        opacity={0}
        side={THREE.DoubleSide}
        depthWrite={false}
      />
    </mesh>
  )
}

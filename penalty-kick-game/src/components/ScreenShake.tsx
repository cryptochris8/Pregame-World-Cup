import { useRef, useCallback } from 'react'
import { useFrame, useThree } from '@react-three/fiber'

interface ShakeState {
  active: boolean
  intensity: number
  duration: number
  startTime: number
}

/**
 * Hook that provides a camera screen-shake effect.
 * Returns a `triggerShake(intensity, duration)` function.
 * The shake applies a damped sinusoidal offset to the camera position each frame,
 * then returns to the original position when complete.
 */
export function useScreenShake() {
  const { camera } = useThree()
  const shakeRef = useRef<ShakeState>({
    active: false,
    intensity: 0,
    duration: 0,
    startTime: 0,
  })

  const triggerShake = useCallback((intensity: number, durationMs: number) => {
    shakeRef.current = {
      active: true,
      intensity,
      duration: durationMs / 1000, // convert to seconds
      startTime: -1, // will be set on first frame
    }
  }, [])

  useFrame((state) => {
    const shake = shakeRef.current
    if (!shake.active) return

    if (shake.startTime < 0) {
      shake.startTime = state.clock.elapsedTime
    }

    const elapsed = state.clock.elapsedTime - shake.startTime
    if (elapsed >= shake.duration) {
      shake.active = false
      return
    }

    // Progress 0..1
    const progress = elapsed / shake.duration
    // Damping envelope: starts at 1, decays to 0
    const damping = 1 - progress
    // High-frequency sinusoidal oscillation
    const frequency = 30
    const offsetX = Math.sin(elapsed * frequency) * shake.intensity * damping
    const offsetY = Math.cos(elapsed * frequency * 1.3) * shake.intensity * damping * 0.7

    camera.position.x += offsetX
    camera.position.y += offsetY
  })

  return { triggerShake }
}

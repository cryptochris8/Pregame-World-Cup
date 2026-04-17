import { useRef } from 'react'
import { useFrame } from '@react-three/fiber'
import * as THREE from 'three'

interface GoalFlashProps {
  /** Whether the flash is currently active */
  active: boolean
  /** Duration in seconds */
  duration?: number
}

/**
 * A full-screen white flash overlay that fades out quickly.
 * Rendered as a plane attached to the camera (via renderOrder and depthTest off).
 */
export function GoalFlash({ active, duration = 0.15 }: GoalFlashProps) {
  const meshRef = useRef<THREE.Mesh>(null)
  const startTime = useRef(-1)

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
    } else {
      // Quick fade: start at 0.6 opacity and decay to 0
      mat.opacity = 0.6 * (1 - elapsed / duration)
    }

    // Always face the camera
    meshRef.current.quaternion.copy(state.camera.quaternion)
    meshRef.current.position.copy(state.camera.position)
    // Place it slightly in front of camera
    const dir = new THREE.Vector3(0, 0, -1).applyQuaternion(state.camera.quaternion)
    meshRef.current.position.addScaledVector(dir, 1)
  })

  return (
    <mesh ref={meshRef} renderOrder={999}>
      <planeGeometry args={[20, 20]} />
      <meshBasicMaterial
        color="#ffffff"
        transparent
        opacity={0}
        depthTest={false}
        depthWrite={false}
      />
    </mesh>
  )
}

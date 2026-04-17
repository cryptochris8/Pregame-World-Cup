import { useRef, useMemo, useEffect } from 'react'
import { useFrame } from '@react-three/fiber'
import * as THREE from 'three'

interface ConfettiProps {
  position: [number, number, number]
  count?: number
  /** Optional team colors (hex strings) for themed confetti */
  teamColors?: string[]
}

export function Confetti({ position, count = 80, teamColors }: ConfettiProps) {
  // Skip confetti for reduced motion preference
  const reducedMotion = typeof window !== 'undefined'
    && window.matchMedia('(prefers-reduced-motion: reduce)').matches
  const meshRef = useRef<THREE.InstancedMesh>(null)
  const startClock = useRef(-1)

  const particles = useMemo(() => {
    if (reducedMotion) return []
    return Array.from({ length: count }, () => {
      let color: THREE.Color
      if (teamColors && teamColors.length > 0) {
        // Pick from team colors with some random variation
        const base = new THREE.Color(teamColors[Math.floor(Math.random() * teamColors.length)])
        // Slight HSL variation for visual richness
        const hsl = { h: 0, s: 0, l: 0 }
        base.getHSL(hsl)
        color = new THREE.Color().setHSL(
          hsl.h + (Math.random() - 0.5) * 0.05,
          Math.min(1, hsl.s + Math.random() * 0.1),
          Math.min(1, hsl.l + (Math.random() - 0.5) * 0.1),
        )
      } else {
        color = new THREE.Color().setHSL(Math.random(), 0.9, 0.6)
      }

      return {
        position: new THREE.Vector3(
          position[0] + (Math.random() - 0.5) * 3,
          position[1] + Math.random() * 0.5,
          position[2] + (Math.random() - 0.5) * 3,
        ),
        velocity: new THREE.Vector3(
          (Math.random() - 0.5) * 6,
          Math.random() * 8 + 3,
          (Math.random() - 0.5) * 6,
        ),
        color,
        rotation: Math.random() * Math.PI * 2,
        rotSpeed: (Math.random() - 0.5) * 12,
      }
    })
  }, [position, count, reducedMotion, teamColors])

  const dummy = useMemo(() => new THREE.Object3D(), [])

  useFrame((state) => {
    if (reducedMotion) return
    if (!meshRef.current) return
    if (startClock.current < 0) startClock.current = state.clock.elapsedTime
    const elapsed = state.clock.elapsedTime - startClock.current
    if (elapsed > 3.5) return

    particles.forEach((p, i) => {
      const t = elapsed
      dummy.position.set(
        p.position.x + p.velocity.x * t,
        p.position.y + p.velocity.y * t - 4.9 * t * t,
        p.position.z + p.velocity.z * t,
      )
      dummy.rotation.set(p.rotation + p.rotSpeed * t, p.rotation * 0.5, 0)
      dummy.scale.setScalar(Math.max(0, 1 - elapsed / 3.5))
      dummy.updateMatrix()
      meshRef.current!.setMatrixAt(i, dummy.matrix)
      meshRef.current!.setColorAt(i, p.color)
    })
    meshRef.current.instanceMatrix.needsUpdate = true
    if (meshRef.current.instanceColor) meshRef.current.instanceColor.needsUpdate = true
  })

  useEffect(() => {
    return () => {
      if (meshRef.current) {
        meshRef.current.geometry.dispose()
        if (Array.isArray(meshRef.current.material)) {
          meshRef.current.material.forEach(m => m.dispose())
        } else {
          meshRef.current.material.dispose()
        }
      }
    }
  }, [])

  if (reducedMotion) return null

  return (
    <instancedMesh ref={meshRef} args={[undefined, undefined, count]}>
      <boxGeometry args={[0.06, 0.06, 0.01]} />
      <meshStandardMaterial />
    </instancedMesh>
  )
}

import { useRef, useState } from 'react'
import { useFrame } from '@react-three/fiber'
import { Text } from '@react-three/drei'
import type { Group } from 'three'

interface ScorePopupProps {
  text: string
  position: [number, number, number]
  color?: string
  onComplete?: () => void
}

export function ScorePopup({ text, position, color = '#F7C948', onComplete }: ScorePopupProps) {
  const groupRef = useRef<Group>(null)
  const [opacity, setOpacity] = useState(1)
  const [scale, setScale] = useState(0.01)
  const startClock = useRef(-1)
  const completedRef = useRef(false)

  useFrame((state) => {
    if (completedRef.current) return
    if (!groupRef.current) return
    if (startClock.current < 0) startClock.current = state.clock.elapsedTime
    const elapsed = state.clock.elapsedTime - startClock.current

    // Scale bounce: 0 -> 1.4 -> 1.0 (spring-like entrance)
    let s: number
    if (elapsed < 0.12) {
      s = (elapsed / 0.12) * 1.4
    } else if (elapsed < 0.3) {
      s = 1.4 - ((elapsed - 0.12) / 0.18) * 0.4
    } else {
      s = 1
    }
    setScale(s)

    // Float up
    groupRef.current.position.y = position[1] + elapsed * 1.5

    // Fade out after 0.5s
    const fadeStart = 0.5
    const fadeDuration = 1.0
    const newOpacity = elapsed < fadeStart ? 1 : Math.max(0, 1 - (elapsed - fadeStart) / fadeDuration)
    setOpacity(newOpacity)

    if (newOpacity <= 0 && onComplete) {
      completedRef.current = true
      onComplete()
    }
  })

  return (
    <group ref={groupRef} position={position} scale={[scale, scale, scale]}>
      {/* Glow layer */}
      <Text
        fontSize={0.55}
        fontWeight={700}
        color={color}
        anchorX="center"
        anchorY="middle"
        fillOpacity={opacity * 0.3}
      >
        {text}
      </Text>
      {/* Main text */}
      <Text
        fontSize={0.5}
        fontWeight={700}
        color={color}
        anchorX="center"
        anchorY="middle"
        fillOpacity={opacity}
        outlineWidth={0.02}
        outlineColor="#000"
        outlineOpacity={opacity}
      >
        {text}
      </Text>
    </group>
  )
}

import { Physics } from '@react-three/rapier'
import type { ReactNode } from 'react'

const GRAVITY: [number, number, number] = [0, -9.81, 0]

interface PhysicsProviderProps {
  children: ReactNode
  paused?: boolean
}

export function PhysicsProvider({ children, paused = false }: PhysicsProviderProps) {
  return (
    <Physics gravity={GRAVITY} paused={paused}>
      {children}
    </Physics>
  )
}

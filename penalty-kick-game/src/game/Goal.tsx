import { useCallback } from 'react'
import { RigidBody, CuboidCollider, type IntersectionEnterPayload } from '@react-three/rapier'
import { SOCCER_CONFIG } from './config'

interface GoalProps {
  onGoalScored: () => void
}

export function Goal({ onGoalScored }: GoalProps) {
  const { goalWidth, goalHeight, goalDepth, goalPosition } = SOCCER_CONFIG
  const postRadius = 0.06

  const handleIntersection = useCallback((payload: IntersectionEnterPayload) => {
    const otherName = payload.other.rigidBodyObject?.name
    if (otherName === 'soccerball') {
      onGoalScored()
    }
  }, [onGoalScored])

  return (
    <group position={goalPosition}>
      {/* Left post */}
      <RigidBody type="fixed" colliders="cuboid" restitution={0.8}>
        <mesh position={[-goalWidth / 2, goalHeight / 2, 0]} castShadow>
          <cylinderGeometry args={[postRadius, postRadius, goalHeight, 8]} />
          <meshStandardMaterial color="#fff" metalness={0.6} roughness={0.3} />
        </mesh>
      </RigidBody>

      {/* Right post */}
      <RigidBody type="fixed" colliders="cuboid" restitution={0.8}>
        <mesh position={[goalWidth / 2, goalHeight / 2, 0]} castShadow>
          <cylinderGeometry args={[postRadius, postRadius, goalHeight, 8]} />
          <meshStandardMaterial color="#fff" metalness={0.6} roughness={0.3} />
        </mesh>
      </RigidBody>

      {/* Crossbar */}
      <RigidBody type="fixed" colliders="cuboid" restitution={0.8}>
        <mesh position={[0, goalHeight, 0]} rotation={[0, 0, Math.PI / 2]} castShadow>
          <cylinderGeometry args={[postRadius, postRadius, goalWidth, 8]} />
          <meshStandardMaterial color="#fff" metalness={0.6} roughness={0.3} />
        </mesh>
      </RigidBody>

      {/* Net (visual only) */}
      {/* Back */}
      <mesh position={[0, goalHeight / 2, -goalDepth / 2]}>
        <planeGeometry args={[goalWidth, goalHeight]} />
        <meshStandardMaterial color="#fff" transparent opacity={0.2} wireframe side={2} />
      </mesh>
      {/* Top */}
      <mesh position={[0, goalHeight, -goalDepth / 4]} rotation={[Math.PI / 2, 0, 0]}>
        <planeGeometry args={[goalWidth, goalDepth / 2]} />
        <meshStandardMaterial color="#fff" transparent opacity={0.15} wireframe side={2} />
      </mesh>

      {/* Goal sensor (detect ball entering) */}
      <RigidBody type="fixed" sensor onIntersectionEnter={handleIntersection}>
        <CuboidCollider
          args={[goalWidth / 2 - 0.1, goalHeight / 2 - 0.1, 0.1]}
          position={[0, goalHeight / 2, -0.5]}
        />
      </RigidBody>

      {/* Back wall to stop ball */}
      <RigidBody type="fixed" colliders="cuboid">
        <mesh position={[0, goalHeight / 2, -goalDepth]} visible={false}>
          <boxGeometry args={[goalWidth + 1, goalHeight + 1, 0.2]} />
        </mesh>
      </RigidBody>
    </group>
  )
}

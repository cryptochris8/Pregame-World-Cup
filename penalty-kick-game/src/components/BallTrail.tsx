import * as THREE from 'three'
import { useMemo, useRef, useEffect } from 'react'
import { useFrame } from '@react-three/fiber'

interface BallTrailProps {
  getPosition: () => { x: number; y: number; z: number } | null
  color?: string
  isActive?: boolean
  maxPoints?: number
}

export function BallTrail({ getPosition, color = '#ffffff', isActive = false, maxPoints = 40 }: BallTrailProps) {
  const positions = useRef<number[]>([])
  const wasActive = useRef(false)

  const { lineObj, geometry } = useMemo(() => {
    const geo = new THREE.BufferGeometry()
    const posArr = new Float32Array(maxPoints * 3)
    geo.setAttribute('position', new THREE.BufferAttribute(posArr, 3))
    geo.setDrawRange(0, 0)
    const mat = new THREE.LineBasicMaterial({
      color: new THREE.Color(color),
      transparent: true,
      opacity: 0.5,
    })
    return { lineObj: new THREE.Line(geo, mat), geometry: geo }
  }, [color, maxPoints])

  useEffect(() => {
    return () => {
      lineObj.geometry.dispose()
      ;(lineObj.material as THREE.Material).dispose()
    }
  }, [lineObj])

  useFrame(() => {
    if (isActive) {
      if (!wasActive.current) {
        positions.current = []
        wasActive.current = true
      }
      const pos = getPosition()
      if (pos) {
        positions.current.push(pos.x, pos.y, pos.z)
        if (positions.current.length > maxPoints * 3) {
          positions.current = positions.current.slice(3)
        }
      }
    } else {
      wasActive.current = false
      if (positions.current.length > 0) {
        positions.current = positions.current.slice(6)
      }
    }

    const attr = geometry.getAttribute('position') as THREE.BufferAttribute
    const arr = attr.array as Float32Array
    const count = Math.min(positions.current.length / 3, maxPoints)
    for (let i = 0; i < count * 3; i++) {
      arr[i] = positions.current[positions.current.length - count * 3 + i]
    }
    attr.needsUpdate = true
    geometry.setDrawRange(0, count)
  })

  return <primitive object={lineObj} />
}
